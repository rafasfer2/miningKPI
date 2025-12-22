#' Add Inoperable Gaps to Loading Cycles
#'
#' Identifies time gaps between consecutive loading cycles and inserts
#' "Inoperable" bridge rows to ensure a continuous timeline.
#'
#' @param df A data frame containing first_time and exit_time columns.
#' @param limit_gap Numeric. Minimum gap duration (in minutes) to be considered inoperable.
#'
#' @return A data frame with inserted inoperable events.
#' @export
add_inoperable_gaps <- function(df, limit_gap = 0.1) {

  # Usando .data$ para evitar notas de 'undefined global variables'
  base_prepared <- df %>%
    dplyr::group_by(.data$load_id) %>%
    dplyr::filter(!is.na(.data$exit_time)) %>%
    dplyr::arrange(.data$load_id, .data$exit_time) %>%
    dplyr::mutate(
      Salto = as.numeric(difftime(.data$first_time, dplyr::lag(.data$exit_time), units = "mins"))
    ) %>%
    dplyr::ungroup()

  inoperable_rows <- base_prepared %>%
    dplyr::filter(.data$Salto > limit_gap) %>%
    dplyr::mutate(
      exit_time_inop = .data$first_time,
      first_time_inop = dplyr::lag(.data$exit_time),
      first_time = .data$first_time_inop,
      exit_time = .data$exit_time_inop,
      load_status = "Inoperable",
      haul_id = NA_character_,
      payload = 0,
      duration_min = .data$Salto
    )

  final_df <- dplyr::bind_rows(base_prepared, inoperable_rows) %>%
    dplyr::group_by(.data$load_id) %>%
    dplyr::arrange(.data$load_id, .data$first_time, .data$exit_time) %>%
    dplyr::mutate(
      duration_min = as.numeric(difftime(.data$exit_time, .data$first_time, units = "mins"))
    ) %>%
    dplyr::ungroup() %>%
    dplyr::select(-.data$Salto)

  return(final_df)
}
