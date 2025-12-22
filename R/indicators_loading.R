#' Summarize Loading Performance Indicators
#'
#' @description
#' Calculates KPIs for loading operations. It supports grouping by specific
#' columns or by time intervals (day, week, month) using the 'per' argument.
#'
#' @param data A tibble, typically `load_cycle_mine_a`.
#' @param per The dimension for grouping. Can be a column name (e.g., fleet_id)
#' or a string for time grouping ("day", "week", "month").
#'
#' @return A summarized tibble with standardized mining KPIs.
#'
#' @importFrom dplyr mutate group_by summarise n rename case_when .data
#' @importFrom magrittr %>%
#' @importFrom rlang enquo as_label := !!
#' @importFrom lubridate floor_date
#'
#' @export
#'
#' @examples
#' library(miningKPI)
#' library(dplyr)
#'
#' # 1. Analysis by Fleet
#' load_summarize_performance(data = load_cycle_mine_a, per = fleet_id)
#'
#' # 2. Temporal Analysis by Day
#' load_summarize_performance(data = load_cycle_mine_a, per = "day")
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

  # 2. Calculate Indicators
  processed_data %>%
    group_by(.data$period) %>%
    summarise(
      total_production = sum(.data$payload, na.rm = TRUE),
      avg_payload      = mean(.data$payload, na.rm = TRUE),
      avg_lct          = mean(.data$lct, na.rm = TRUE),
      avg_oct          = mean(.data$oct, na.rm = TRUE),
      avg_mct          = mean(.data$mct, na.rm = TRUE),
      mtbc             = .data$avg_lct + .data$avg_mct + .data$avg_oct,
      total_ht         = sum(.data$lct + .data$mct + .data$oct, na.rm = TRUE) / 60,
      productivity_th  = .data$total_production / .data$total_ht,
      n_cycles         = n(),
      .groups = "drop"
    ) %>%
    rename(!!group_label := .data$period)
}
