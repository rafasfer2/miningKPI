#' Summarize Loading Performance Indicators
#'
#' @description
#' Calculates KPIs for loading operations based on standard mining metrics.
#' Supports grouping by columns or time intervals (day, week, month).
#'
#' @param data A tibble, typically `load_cycle_mine_a`.
#' @param per The dimension for grouping (e.g., fleet_load_id, "day").
#'
#' @return A summarized tibble with standardized mining KPIs.
#'
#' @importFrom dplyr mutate group_by summarise n rename case_when .data
#' @importFrom magrittr %>%
#' @importFrom rlang enquo as_label := !!
#' @importFrom lubridate floor_date
#'
#' @export
load_summarize_performance <- function(data, per) {

  # 1. Handle Time Grouping vs Column Grouping
  group_var <- enquo(per)
  group_label <- as_label(group_var)

  processed_data <- data %>%
    mutate(
      period = case_when(
        group_label == "day"   ~ as.character(as.Date(.data$exit_time)),
        group_label == "week"  ~ as.character(lubridate::floor_date(.data$exit_time, "week")),
        group_label == "month" ~ as.character(lubridate::floor_date(.data$exit_time, "month")),
        TRUE                   ~ as.character(!!group_var)
      )
    )

  # 2. Calculate Indicators based on Normative Table
  processed_data %>%
    group_by(.data$period) %>%
    summarise(
      # 175. Total Production Load (TPL) - Mass Loaded
      TPL = sum(.data$payload, na.rm = TRUE),

      # 188. Mean Loading Cycle Time (MLCT) - TMC/Average Loading Time
      MLCT = mean(.data$lct, na.rm = TRUE),

      # 444. Operational Cycle Time (OCT) - Excavator Idleness
      # Represented as the average idle time per cycle
      OCT = mean(.data$oct, na.rm = TRUE),

      # Mean Maneuver Time
      avg_mct = mean(.data$mct, na.rm = TRUE),

      # 166. Mean Time Between Compositions (MTBC) - Loading Cycle Time
      # MTBC = Maneuver + Loading + Idle
      MTBC = .data$MLCT + .data$avg_mct + .data$OCT,

      # Worked Hours (WH) - Sum of cycle times converted to hours
      WH = sum(.data$lct + .data$mct + .data$oct, na.rm = TRUE) / 60,

      # 177. Loading Productivity (LP) - Loading Throughput
      # LP = TPL / WH
      LP = .data$TPL / .data$WH,

      # 634. Load Capacity (LC) - Total Ore + Waste
      # (Note: In a summarized view, this is equivalent to TPL)
      LC = .data$TPL,

      n_cycles = n(),
      .groups = "drop"
    ) %>%
    # Remove auxiliary mean maneuver for clean output
    select(-"avg_mct") %>%
    # Rename 'period' back to the name used in 'per' for clarity
    rename(!!group_label := .data$period)
}
