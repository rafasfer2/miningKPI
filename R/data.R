#' Mine A Loading Events (Base Notation)
#'
#' A tidy, long-format dataset representing the stochastic process of loading.
#' It contains the three fundamental states for each composition.
#'
#' @format A tibble with 11 columns:
#' \describe{
#'   \item{first_time}{Start of the specific event (maneuver, loading, or idle).}
#'   \item{exit_time}{End of the specific event (Exit Time - $T_i$).}
#'   \item{fleet_id}{International classification of the loading equipment.}
#'   \item{load_id}{Anonymized identifier for the loading unit.}
#'   \item{haul_id}{Anonymized identifier for the hauling unit (NA for idle).}
#'   \item{origin}{Loading face location (Bench, Stockpile, or Rehandling).}
#'   \item{material}{Type of material: Ore or Waste.}
#'   \item{payload}{Loaded mass ($L_i$) in tonnes. Recorded only during 'loading'.}
#'   \item{load_status}{Qualitative status of the load (e.g., Target Met, Underload).}
#'   \item{event_type}{The operational state: maneuver, loading, or idle.}
#'   \item{duration_min}{Event duration in decimal minutes.}
#' }
"load_events_mine_a"

#' Mine A Loading Cycles (Aggregated + Inoperable)
#'
#' A wide-format dataset where each row is a full loading cycle. It includes
#' "Inoperable" bridge rows to account for equipment downtime.
#'
#' @format A tibble with 12 columns:
#' \describe{
#'   \item{first_time}{Start of the cycle (Maneuver start).}
#'   \item{exit_time}{End of the cycle (Departure from face).}
#'   \item{duration_min}{Total cycle time ($X_i$) including gaps.}
#'   \item{fleet_id}{Loading fleet category.}
#'   \item{load_id}{Anonymized loading unit ID.}
#'   \item{haul_id}{Anonymized truck ID (NA for inoperable).}
#'   \item{origin}{Loading location.}
#'   \item{material}{Material type.}
#'   \item{payload}{Total tonnes loaded in the cycle.}
#'   \item{load_status}{Status (Target Met, Acceptable, Inoperable, etc.).}
#'   \item{m_time}{Specific duration for maneuver ($M_i$).}
#'   \item{l_time}{Specific duration for loading ($D_i$).}
#'   \item{i_time}{Specific duration for operational idle ($O_i$).}
#' }
"load_cycles_mine_a"

#' Mine A Hauling Events (Full Journey)
#'
#' A detailed dataset containing the 7-event hauling cycle, from loading queue
#' to return trip.
#'
#' @format A tibble with the full hauling journey events:
#' \describe{
#'   \item{load_id}{ID of the excavator providing the load.}
#'   \item{haul_id}{ID of the truck performing the transport.}
#'   \item{origin}{Extraction point.}
#'   \item{destination}{Dump point (Crusher or Stockpile).}
#'   \item{event_type}{One of 7 states: queue_at_load, maneuver_at_load, loading, travel_full, queue_at_dump, maneuver_at_dump, dumping.}
#'   \item{duration_min}{Time spent in each state.}
#'   \item{payload}{Mass transported ($L_i$).}
#' }
"haul_events_mine_a"
