#' Add Missing Phases to Drilling Cycles
#'
#' @description
#' Garante que cada ciclo de perfuração contenha as 5 fases fundamentais (1-Posicionamento,
#' 2-Emboquilhamento, 3-Perfuração, 4-Hastes, 5-Deslocamento). Fases ausentes são
#' imputadas com duração zero. Marcadores técnicos são adicionados para conclusão do ciclo.
#'
#' @param df Um data frame ou tibble contendo eventos de perfuração (drill events).
#'
#' @return Um tibble com as fases faltantes imputadas e um marcador de saída (Fase 6).
#'
#' @examples
#' library(dplyr)
#' # Exemplo de uso básico com o dataset do pacote
#' drill_events_mine_d %>%
#'   add_missing_drill_phases() %>%
#'   filter(drill_id == "DRILL_100", cycle == 1)
#'
#' @export
add_missing_drill_phases <- function(df) {

  # 1. Limpeza inicial
  df <- df %>% dplyr::ungroup()

  # 2. Criar esqueleto ideal de fases 1 a 5 para cada ciclo existente
  ideal_structure <- df %>%
    dplyr::distinct(drill_id, cycle) %>%
    tidyr::expand_grid(phase = c(1, 2, 3, 4, 5))

  # 3. Identificar fases ausentes via anti-join
  missing_phases <- ideal_structure %>%
    dplyr::anti_join(df, by = c("drill_id", "cycle", "phase"))

  if(nrow(missing_phases) > 0) {
    # Coleta metadados e define o tempo âncora (início do ciclo)
    reference_data <- df %>%
      dplyr::group_by(drill_id, cycle) %>%
      dplyr::summarise(
        borehole_uid = dplyr::first(borehole_uid),
        origin       = dplyr::first(origin),
        drill_fleet  = dplyr::first(drill_fleet),
        # Ancoragem temporal para evitar NAs se a fase 1 for imputada
        anchor_time  = min(first_time, na.rm = TRUE),
        .groups      = "drop"
      )

    imputed_rows <- missing_phases %>%
      dplyr::left_join(reference_data, by = c("drill_id", "cycle")) %>%
      dplyr::mutate(
        event_type      = "imputed_phase",
        category        = "SYSTEM_FILL",
        description_en  = "System Imputed - Missing Phase",
        duration_min    = 0,
        allocated_meters = 0,
        data_source     = "Algorithm Imputation",
        first_time      = anchor_time,
        exit_time       = anchor_time
      ) %>%
      dplyr::select(-anchor_time)

    df <- dplyr::bind_rows(df, imputed_rows)
  }

  # 4. Sincronização de Timestamps e Adição da Fase 6 (Marcador Técnico)
  df_final <- df %>%
    dplyr::arrange(drill_id, cycle, phase, first_time) %>%
    dplyr::group_by(drill_id, cycle) %>%
    dplyr::mutate(
      # Se for imputada, tenta pegar o fim da fase anterior ou usa a âncora
      first_time = dplyr::if_else(
        category == "SYSTEM_FILL",
        dplyr::coalesce(dplyr::lag(exit_time), first_time),
        first_time
      ),
      exit_time = dplyr::if_else(category == "SYSTEM_FILL", first_time, exit_time)
    ) %>%
    # Inserção técnica da Fase 6 para sinalizar fim de ciclo no log
    dplyr::group_modify(~ {
      last_exit <- max(.x$exit_time, na.rm = TRUE)
      exit_row <- .x[1, ]
      exit_row$phase <- 6
      exit_row$event_type <- "exit_cycle"
      exit_row$description_en <- "Technical Cycle Completion Marker"
      exit_row$first_time <- last_exit
      exit_row$exit_time <- last_exit + 0.1
      exit_row$duration_min <- 0.0016 # Equivalente a 0.1s
      exit_row$category <- "SYSTEM_TECH"
      dplyr::bind_rows(.x, exit_row)
    }) %>%
    dplyr::ungroup()

  return(df_final)
}
