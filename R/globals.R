# Define global variables to satisfy R CMD check
# These match the tidy, long-format datasets in the package
utils::globalVariables(c(
  # Core Time Columns
  "first_time", "exit_time", "start_time", "duration_min",
  "start_time_inop", "exit_time_inop", "start_time_carga", "Fim",

  # Identification & Categorization
  "load_fleet", "haul_fleet", "load_id", "haul_id", "trip_id",
  "origin", "destination", "material", "load_status", "fleet_id",

  # Event Types & Operational States
  "event_type", "maneuver", "loading", "idle", "gap",
  "m_time", "l_time", "i_time", "q_time", "d_time",

  # Technical & Performance Data
  "payload", "salto", "cycle_id", "load_factor",
  "scale_weight", "scale_ok", "target_max",

  # Hauling Specific - Distances
  "dmt_full", "dmt_empty", "dmt_total",

  # Hauling Specific States (7 Events)
  "queue_at_load", "maneuver_at_load", "travel_full",
  "queue_at_dump", "maneuver_at_dump", "dumping", "travel_empty",

  # Common tidyverse functions that sometimes trigger notes
  "select", "where", "everything", "any_of", "all_of", ".data",

  "dist_km", "lj", "xj", "dist_total",
  "travel_time", "dist_empty", "dist_full"
))
