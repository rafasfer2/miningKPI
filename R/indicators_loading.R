#' Summarize Loading Performance Indicators
#'
#' @description
#' Calculates KPIs for loading operations based on the fundamental identity
#' Xi = Mi + Di + Oi. Supports grouping by specific columns or time intervals.
#'
#' @param data A tibble, containing columns: exit_time, payload, lct, mct, oct.
#' @param per The dimension for grouping (e.g., fleet_id, "day", "week").
#'
#' @return A summarized tibble with standardized mining KPIs: TPL, WH, MLCT, MOCT, MTBC, LP, LC.
#'
#' @importFrom dplyr mutate group_by summarise n rename case_when select .data
#' @importFrom magrittr %>%
#' @importFrom rlang enquo as_label := !!
#' @importFrom lubridate floor_date
#'
#' @export
load_summarize_performance <- function(data, per) {

  # 1. Captura da variável de agrupamento
  group_var <- rlang::enquo(per)
  group_label <- rlang::as_label(group_var)

  # 2. Preparação dos dados e tratamento de tempo
  # Criamos a coluna temporal apenas se 'per' for uma das palavras-chave de tempo
  processed_data <- data %>%
    dplyr::mutate(
      group_col = dplyr::case_when(
        group_label == "day"   ~ as.character(as.Date(.data$exit_time)),
        group_label == "week"  ~ as.character(lubridate::floor_date(.data$exit_time, "week")),
        group_label == "month" ~ as.character(lubridate::floor_date(.data$exit_time, "month")),
        TRUE                   ~ as.character(!!group_var)
      ),
      # Identidade Fundamental Individual: Xi = Mi + Di + Oi
      xi = .data$mct + .data$lct + .data$oct
    )

  # 3. Sumarização baseada nas fórmulas do livro
  summary_table <- processed_data %>%
    dplyr::group_by(.data$group_col) %>%
    dplyr::summarise(
      # Massa Total Carregada (TPL)
      TPL = sum(.data$payload, na.rm = TRUE),

      # Horas Trabalhadas (WH) - Soma dos Xi convertida para horas
      WH = sum(.data$xi, na.rm = TRUE) / 60,

      # Tempo Médio de Carregamento (MLCT) - Média de Di
      MLCT = mean(.data$lct, na.rm = TRUE),

      # Ociosidade Média (MOCT) - Média de Oi
      MOCT = mean(.data$oct, na.rm = TRUE),

      # Tempo Médio entre Composições (MTBC) - Média de Xi
      MTBC = mean(.data$xi, na.rm = TRUE),

      # Produtividade de Carregamento (LP) - TPL / WH
      LP = ifelse(.data$WH > 0, .data$TPL / .data$WH, 0),

      # Capacidade de Carga (LC) - Total movimentado (Ore + Waste)
      LC = sum(.data$payload, na.rm = TRUE),

      n_cycles = dplyr::n(),
      .groups = "drop"
    ) %>%
    # Renomeia a coluna de agrupamento de volta para o nome original (ex: "day" ou "fleet_id")
    dplyr::rename(!!group_label := .data$group_col)

  return(summary_table)
}
