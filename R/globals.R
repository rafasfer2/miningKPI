# Define global variables to satisfy R CMD check
# These match the tidy, long-format datasets in the package
utils::globalVariables(c(
  # Core Time Columns
  "first_time", "exit_time", "start_time", "duration_min",
  "start_time_inop", "exit_time_inop", "start_time_carga",

  # Identification & Categorization
  "fleet_id", "load_id", "haul_id", "trip_id",
  "origin", "destination", "material", "load_status",

  # Event Types & Operational States
  "event_type", "maneuver", "loading", "idle", "gap",
  "m_time", "l_time", "i_time",

  # Technical & Performance Data
  "payload", "salto", "cycle_id",

  # Hauling Specific States
  "queue_at_load", "maneuver_at_load", "travel_full",
  "queue_at_dump", "maneuver_at_dump", "dumping",

  # Common tidyverse functions that sometimes trigger notes
  "select", "where", "everything", "any_of", "all_of"
))
