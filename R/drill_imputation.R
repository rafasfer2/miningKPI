#' Add Missing Phases to Drilling Cycles
#'
#' @description
#' Garante que cada ciclo de perfuração contenha as 5 fases fundamentais (1-Posicionamento,
#' 2-Emboquilhamento, 3-Perfuração, 4-Hastes, 5-Deslocamento). Fases ausentes são
#' imputadas com duração zero e recebem a nomenclatura técnica correta, utilizando
#' os códigos sintéticos do pacote (ex: 299) e as 10 categorias de KPI (ex: HOI) para consistência.
#'
#' @param df Um data frame ou tibble contendo eventos de perfuração processados.
#'
#' @return Um tibble com as fases faltantes imputadas e o marcador de saída (Fase 6).
#'
#' @examples
#' library(dplyr)
#' # Exemplo de uso para garantir a estrutura de 5 fases em um ciclo específico
#' drill_events_mine_d %>%
#'   add_missing_drill_phases() %>%
#'   filter(drill_id == "DRILL_01", cycle == 1)
#'
#' @export
add_missing_drill_phases <- function(df) {

  # 1. Limpeza e Garantia de Tipos (Essencial para a integridade do bind_rows)
  df <- df %>%
    dplyr::ungroup() %>%
    dplyr::mutate(
      code = as.character(.data$code),
      category = as.character(.data$category)
    )

  # 2. Criar esqueleto ideal de fases 1 a 5 para cada ciclo existente no dataframe
  ideal_structure <- df %>%
    dplyr::distinct(.data$drill_id, .data$cycle) %>%
    tidyr::expand_grid(phase = c(1, 2, 3, 4, 5))

  # 3. Identificar fases ausentes (Fases que deveriam existir mas não foram registradas)
  missing_phases <- ideal_structure %>%
    dplyr::anti_join(df, by = c("drill_id", "cycle", "phase"))

  if(nrow(missing_phases) > 0) {
    # Coletar metadados do ciclo real para propagar nas linhas imputadas (Evita NAs indesejados)
    reference_data <- df %>%
      dplyr::group_by(.data$drill_id, .data$cycle) %>%
      dplyr::summarise(
        drill_fleet  = dplyr::first(.data$drill_fleet),
        borehole_uid = dplyr::first(.data$borehole_uid),
        origin       = dplyr::first(.data$origin),
        data_source  = dplyr::first(.data$data_source),
        anchor_time  = min(.data$first_time, na.rm = TRUE),
        .groups      = "drop"
      )

    imputed_rows <- missing_phases %>%
      dplyr::left_join(reference_data, by = c("drill_id", "cycle")) %>%
      dplyr::mutate(
        # Nomenclatura técnica baseada na fase
        event_type = dplyr::case_when(
          phase == 1 ~ "positioning",
          phase == 2 ~ "collaring",
          phase == 3 ~ "drilling",
          phase == 4 ~ "rods",
          phase == 5 ~ "tramming"
        ),
        # Rigor com as 10 categorias: Gap de sistema é apropriado como HOI
        code             = "299",
        category         = "HOI",
        description_en   = "System Imputed - Missing Phase",
        comment_en       = "Zero-duration structural fill for cycle consistency",
        duration_min     = 0,
        allocated_meters = 0,
        first_time       = .data$anchor_time,
        exit_time        = .data$anchor_time
      ) %>%
      dplyr::select(-.data$anchor_time)

    # União dos dados reais com as linhas técnicas criadas
    df <- dplyr::bind_rows(df, imputed_rows)
  }

  # 4. Sincronização Cronológica e Adição da Fase 6 (Marcador de Conclusão)
  df_final <- df %>%
    dplyr::arrange(.data$drill_id, .data$cycle, .data$phase, .data$first_time) %>%
    dplyr::group_by(.data$drill_id, .data$cycle) %>%
    dplyr::mutate(
      # Ajusta o timestamp para garantir continuidade (Fases imputadas "colam" no evento anterior)
      first_time = dplyr::if_else(
        .data$description_en == "System Imputed - Missing Phase",
        dplyr::coalesce(dplyr::lag(.data$exit_time), .data$first_time),
        .data$first_time
      ),
      exit_time = dplyr::if_else(
        .data$description_en == "System Imputed - Missing Phase",
        .data$first_time,
        .data$exit_time
      )
    ) %>%
    # Inserção do marcador de fim de ciclo (Fase 6)
    dplyr::group_modify(~ {
      last_exit <- max(.x$exit_time, na.rm = TRUE)
      exit_row <- .x[1, ]
      exit_row$phase <- 6
      exit_row$code <- "299"
      exit_row$event_type <- "exit_cycle"
      exit_row$category <- "HOI"
      exit_row$description_en <- "Technical Cycle Completion Marker"
      exit_row$comment_en     <- "Auto-generated phase 6"
      exit_row$first_time     <- last_exit
      exit_row$exit_time      <- last_exit + 0.0001
      exit_row$duration_min   <- 0
      exit_row$allocated_meters <- 0
      dplyr::bind_rows(.x, exit_row)
    }) %>%
    dplyr::ungroup()

  return(df_final)
}
