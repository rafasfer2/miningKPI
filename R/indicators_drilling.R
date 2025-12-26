#' Summarize Drilling Performance Indicators
#'
#' @description
#' Calcula KPIs de perfuração (TDM, WH, ROP, GDR) baseados na identidade fundamental
#' de 5 fases: Xi = Pi + Ci + Di + Hi + Mi. Suporta agregação por dimensões físicas,
#' períodos temporais e blocos de ciclos.
#'
#' @param data A tibble contendo drill_events (após add_missing_drill_phases).
#' @param per Dimensão de agrupamento (ex: drill_id, drill_fleet, origin).
#' @param time_unit Unidade de tempo para agregação ("day", "week", "month").
#' @param n_cycles Número de ciclos para agrupamento em blocos (ex: 5, 10).
#'
#' @return A summarized tibble with standardized mining KPIs: TDM, ROP, GDR, WH, and phase breakdown.
#'
#' @importFrom rlang enquo as_label !! sym quo_is_null
#' @importFrom dplyr group_by summarise mutate n_distinct ungroup if_else n across any_of arrange row_number
#' @importFrom lubridate floor_date
#'
#' @examples
#' library(dplyr)
#'
#' # Exemplo 1: KPI por Perfuratriz (Tradicional)
#' drill_events_mine_d %>%
#'   add_missing_drill_phases() %>%
#'   drill_summarize_performance(per = drill_id)
#'
#' # Exemplo 2: KPI por Frota e por Dia
#' drill_events_mine_d %>%
#'   add_missing_drill_phases() %>%
#'   drill_summarize_performance(per = drill_fleet, time_unit = "day")
#'
#' # Exemplo 3: KPI a cada bloco de 5 ciclos por Perfuratriz
#' drill_events_mine_d %>%
#'   add_missing_drill_phases() %>%
#'   drill_summarize_performance(per = drill_id, n_cycles = 5)
#'
#' @export
drill_summarize_performance <- function(data, per = NULL, time_unit = NULL, n_cycles = NULL) {

  # 1. Correção de duplicação de colunas
  data <- data[, !duplicated(names(data))]

  # 2. Captura da variável de agrupamento
  group_var <- rlang::enquo(per)

  date_col <- if("timestamp" %in% names(data)) {
    "timestamp"
  } else {
    names(data)[sapply(data, lubridate::is.POSIXct)][1]
  }

  # 3. Adiciona coluna de Período
  if (!is.null(time_unit) && time_unit != "all") {
    data <- data %>%
      dplyr::mutate(periodo = lubridate::floor_date(!!rlang::sym(date_col), unit = time_unit))
  }

  # 4. Consolidação por Ciclo Individual (Nível i)
  group_cols_i <- c(rlang::as_label(group_var), "drill_id", "cycle")
  if ("periodo" %in% names(data)) group_cols_i <- c(group_cols_i, "periodo")
  group_cols_i <- group_cols_i[group_cols_i != "NULL"]

  cycles_i <- data %>%
    dplyr::group_by(dplyr::across(dplyr::any_of(group_cols_i))) %>%
    dplyr::summarise(
      xi_min = sum(duration_min, na.rm = TRUE),
      # CORREÇÃO AQUI: Se todos forem NA, retorna 0 em vez de -Inf
      li     = if(all(is.na(allocated_meters))) 0 else max(allocated_meters, na.rm = TRUE),
      pi_min = sum(duration_min[!is.na(phase) & phase == 1], na.rm = TRUE),
      ci_min = sum(duration_min[!is.na(phase) & phase == 2], na.rm = TRUE),
      di_min = sum(duration_min[!is.na(phase) & phase == 3], na.rm = TRUE),
      hi_min = sum(duration_min[!is.na(phase) & phase == 4], na.rm = TRUE),
      mi_min = sum(duration_min[!is.na(phase) & phase == 5], na.rm = TRUE),
      .groups = "drop"
    )

  # 5. Lógica de Blocos de Ciclos
  if (!is.null(n_cycles) && n_cycles != "all") {
    group_cols_bucket <- c(rlang::as_label(group_var), "drill_id")
    if ("periodo" %in% names(cycles_i)) group_cols_bucket <- c(group_cols_bucket, "periodo")
    group_cols_bucket <- group_cols_bucket[group_cols_bucket != "NULL"]

    cycles_i <- cycles_i %>%
      dplyr::group_by(dplyr::across(dplyr::any_of(group_cols_bucket))) %>%
      dplyr::arrange(cycle) %>%
      dplyr::mutate(cycle_bucket = (dplyr::row_number() - 1) %/% as.numeric(n_cycles) + 1) %>%
      dplyr::ungroup()
  }

  # 6. Sumarização Final de KPIs
  final_groups <- c(rlang::as_label(group_var))
  if ("periodo" %in% names(cycles_i)) final_groups <- c(final_groups, "periodo")
  if ("cycle_bucket" %in% names(cycles_i)) final_groups <- c(final_groups, "cycle_bucket")
  final_groups <- final_groups[final_groups != "NULL"]

  summary_table <- cycles_i %>%
    dplyr::group_by(dplyr::across(dplyr::any_of(final_groups))) %>%
    dplyr::summarise(
      TDM = sum(.data$li, na.rm = TRUE),
      WH  = sum(.data$xi_min, na.rm = TRUE) / 60,
      ROP = dplyr::if_else(sum(di_min) > 0, TDM / (sum(di_min) / 60), 0),
      GDR = dplyr::if_else(sum(xi_min) > 0, TDM / (sum(xi_min) / 60), 0),
      Pct_Drilling    = sum(di_min) / sum(xi_min),
      Pct_Positioning = sum(pi_min) / sum(xi_min),
      Pct_Collaring   = sum(ci_min) / sum(xi_min),
      Pct_Rods        = sum(hi_min) / sum(xi_min),
      Pct_Tramming    = sum(mi_min) / sum(xi_min),
      n_holes = dplyr::n(),
      .groups = "drop"
    )

  return(summary_table)
}
