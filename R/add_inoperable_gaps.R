#' Add Inoperable Gaps to Operational Cycles
#'
#' Identifies time gaps between consecutive cycles and inserts
#' "IIH" bridge rows to ensure a continuous timeline.
#'
#' @param df A data frame containing first_time and exit_time columns.
#' @param limit_gap Numeric. Minimum gap duration (in minutes) to be considered inoperable.
#'
#' @return A data frame with inserted inoperable events.
#'
#' @examples
#' \dontrun{
#' # Exemplo de uso com dados de perfuração
#' drill_events_mine_d %>%
#'   filter(drill_id == "DRILL_01") %>%
#'   add_inoperable_gaps(limit_gap = 0.5)
#' }
#'
#' @export
add_inoperable_gaps <- function(df, limit_gap = 0.1) {

  # 1. Preparação: Calculamos a saída anterior antes de filtrar
  base_prepared <- df %>%
    dplyr::group_by(.data$drill_id) %>%
    dplyr::filter(!is.na(.data$exit_time)) %>%
    dplyr::arrange(.data$drill_id, .data$first_time) %>%
    dplyr::mutate(
      prev_exit = dplyr::lag(.data$exit_time),
      Salto = as.numeric(difftime(.data$first_time, .data$prev_exit, units = "mins"))
    ) %>%
    dplyr::ungroup()

  # 2. Criação das linhas de Inoperabilidade (Gaps)
  inoperable_rows <- base_prepared %>%
    dplyr::filter(.data$Salto > limit_gap) %>%
    dplyr::mutate(
      exit_time_new  = .data$first_time,
      first_time_new = .data$prev_exit,

      # Sobrescrevendo colunas para o padrão do pacote e anonimização
      first_time     = .data$first_time_new,
      exit_time      = .data$exit_time_new,
      category       = "IIH",
      code           = "299", # Código sintético para Inoperável conforme nossa tabela
      description_en = "Inoperable Gap (Automatic)",
      comment_en     = paste0("Automatic gap insertion: ", round(.data$Salto, 2), " min"),
      duration_min   = .data$Salto,

      # Limpando IDs operacionais para evitar duplicidade
      borehole_uid   = NA_character_,
      cycle          = NA_real_,
      phase          = NA_real_
    ) %>%
    dplyr::select(-.data$first_time_new, -.data$exit_time_new, -.data$prev_exit)

  # 3. União e Re-sumarização Final
  final_df <- dplyr::bind_rows(base_prepared, inoperable_rows) %>%
    dplyr::select(-.data$Salto, -.data$prev_exit) %>%
    dplyr::group_by(.data$drill_id) %>%
    dplyr::arrange(.data$drill_id, .data$first_time) %>%
    dplyr::mutate(
      duration_min = as.numeric(difftime(.data$exit_time, .data$first_time, units = "mins"))
    ) %>%
    dplyr::ungroup()

  return(final_df)
}
