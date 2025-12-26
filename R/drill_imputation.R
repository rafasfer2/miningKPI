#' Add Missing Phases to Drilling Cycles
#'
#' @description
#' Ensures that every drilling cycle contains all 5 fundamental phases of the drilling identity:
#' \itemize{
#'   \item \strong{1 (Pi)}: Positioning
#'   \item \strong{2 (Ci)}: Collaring
#'   \item \strong{3 (Di)}: Drilling
#'   \item \strong{4 (Hi)}: Rod Handling
#'   \item \strong{5 (Mi)}: Tramming
#' }
#' If a phase is missing in the telemetry data, a zero-duration event is inserted
#' with category "SYSTEM_FILL" and description "System Imputed - Missing Phase".
#'
#' @param df A tibble containing drilling events. Must include columns:
#'   \code{drill_id}, \code{cycle}, \code{phase}, \code{first_time}, \code{exit_time},
#'   \code{borehole_uid}, \code{origin}, \code{drill_fleet}.
#'
#' @return A tibble with added rows for missing phases (duration = 0), sorted by drill_id, cycle, and phase.
#'
#' @importFrom tidyr expand_grid
#' @importFrom dplyr select distinct anti_join group_by summarise left_join mutate case_when bind_rows arrange first
#' @export
add_missing_drill_phases <- function(df) {

  # 1. Definir a estrutura ideal (Combinando Drill + Ciclo x Fases 1 a 5)
  # CORREÇÃO: Expandimos diretamente da lista única de (drill_id, cycle)
  # Isso evita o join many-to-many que causava o aviso.
  ideal_structure <- df %>%
    dplyr::distinct(drill_id, cycle) %>%
    tidyr::expand_grid(phase = c(1, 2, 3, 4, 5))

  # 2. Identificar quais fases NÃO existem no dataframe original
  # O anti_join agora considera drill_id, cycle e phase simultaneamente
  missing_phases <- ideal_structure %>%
    dplyr::anti_join(df, by = c("drill_id", "cycle", "phase"))

  # Se não faltar nada, retorna o original imediatamente
  if(nrow(missing_phases) == 0) return(df)

  # 3. Preparar metadados de referência para preencher as lacunas
  reference_data <- df %>%
    dplyr::group_by(drill_id, cycle) %>%
    dplyr::summarise(
      borehole_uid = dplyr::first(borehole_uid),
      origin       = dplyr::first(origin),
      drill_fleet  = dplyr::first(drill_fleet),
      # Timestamp de referência: Usamos o final do ciclo para inserir as linhas zeradas
      ref_time     = max(exit_time, na.rm = TRUE),
      .groups      = "drop"
    )

  # 4. Criar as linhas imputadas
  imputed_rows <- missing_phases %>%
    dplyr::left_join(reference_data, by = c("drill_id", "cycle")) %>%
    dplyr::mutate(
      event_type = dplyr::case_when(
        phase == 1 ~ "positioning",
        phase == 2 ~ "collaring",
        phase == 3 ~ "drilling",
        phase == 4 ~ "rods",
        phase == 5 ~ "tramming"
      ),
      category       = "SYSTEM_FILL",
      description_en = "System Imputed - Missing Phase",
      description_pt = "Imputado Sistema - Fase Ausente",

      # Lógica de Tempo Zero (Inserido no final do ciclo para não quebrar a ordem visual dos anteriores)
      first_time   = ref_time,
      exit_time    = ref_time,
      duration_min = 0,

      # KPIs zerados
      allocated_meters = 0,
      data_source      = "Algorithm Imputation"
    ) %>%
    dplyr::select(-ref_time) # Remove coluna auxiliar

  # 5. Unir com original e reordenar
  dplyr::bind_rows(df, imputed_rows) %>%
    dplyr::arrange(drill_id, cycle, phase, first_time)
}
