#' Summarize Hauling Performance Indicators
#'
#' @description
#' Calculates KPIs for hauling operations based on the 7-event journey and
#' the fundamental identity Xj = FTj + Vcj + Vvj.
#'
#' @param data A tibble, containing haul_events with columns: event_type, duration_min, payload, dist_km.
#' @param per The dimension for grouping (e.g., haul_id, fleet_id, "day").
#'
#' @return A summarized tibble with standardized mining KPIs: Mean_Payload, WH, DMT, V_mean, LP, Compliance.
#'
#' @export
haul_summarize_performance <- function(data, per) {

  # 1. Captura da variável de agrupamento
  group_var <- rlang::enquo(per)
  group_label <- rlang::as_label(group_var)

  # 2. Consolidação dos ciclos individuais (j) antes da sumarização final
  # Esta etapa transforma os eventos de jornada em métricas de viagem
  cycles_j <- data %>%
    dplyr::group_by(!!group_var, cycle_id) %>% # Assume-se um ID de ciclo único
    dplyr::summarise(
      xj = sum(duration_min, na.rm = TRUE),
      lj = max(payload, na.rm = TRUE),
      dist_total = sum(dist_km, na.rm = TRUE),
      dist_full = sum(dist_km[event_type == "travel_full"], na.rm = TRUE),
      dist_empty = sum(dist_km[event_type == "travel_empty"], na.rm = TRUE),
      travel_time = sum(duration_min[event_type %in% c("travel_full", "travel_empty")]),
      .groups = "drop"
    )

  # 3. Sumarização baseada nas fórmulas do Capítulo 6
  summary_table <- cycles_j %>%
    dplyr::group_by(!!group_var) %>%
    dplyr::summarise(
      # Carga Média (Mean Payload)
      Mean_Payload = mean(lj, na.rm = TRUE),

      # Horas Trabalhadas (WH)
      WH = sum(xj, na.rm = TRUE) / 60,

      # Distância Média de Transporte (DMT) - Ponderada pela massa
      DMT = sum(lj * dist_total, na.rm = TRUE) / sum(lj, na.rm = TRUE),

      # Velocidade Média (Mean Travel Speed)
      V_mean = sum(dist_total, na.rm = TRUE) / (sum(travel_time, na.rm = TRUE) / 60),

      # Produtividade de Transporte (LP)
      LP = sum(lj, na.rm = TRUE) / (sum(xj, na.rm = TRUE) / 60),

      # Razão kmVz/kmCh
      Empty_Full_Ratio = sum(dist_empty, na.rm = TRUE) / sum(dist_full, na.rm = TRUE),

      n_trips = dplyr::n(),
      .groups = "drop"
    )

  return(summary_table)
}
