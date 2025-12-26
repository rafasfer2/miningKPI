# Define global variables to satisfy R CMD check
# These match the tidy, long-format datasets in the package
utils::globalVariables(c(
  # --- DRILLING (Adicionado para corrigir os Notes atuais) ---
  "drill_id", "drill_fleet", "borehole_uid", "cycle", "phase",
  "ref_time", "category", "category_kpi", "description_en",
  "description_pt", "allocated_meters", "data_source",

  # --- CORE TIME COLUMNS ---
  "first_time", "exit_time", "start_time", "duration_min",
  "start_time_inop", "exit_time_inop", "start_time_carga", "Fim",

  # --- IDENTIFICATION & CATEGORIZATION ---
  "load_fleet", "haul_fleet", "load_id", "haul_id", "trip_id",
  "origin", "destination", "material", "load_status", "fleet_id",

  # --- EVENT TYPES & OPERATIONAL STATES ---
  "event_type", "maneuver", "loading", "idle", "gap",
  "m_time", "l_time", "i_time", "q_time", "d_time",

  # --- TECHNICAL & PERFORMANCE DATA ---
  "payload", "salto", "cycle_id", "load_factor",
  "scale_weight", "scale_ok", "target_max",

  # --- HAULING SPECIFIC - DISTANCES ---
  "dmt_full", "dmt_empty", "dmt_total",
  "dist_km", "dist_total", "dist_empty", "dist_full",

  # --- HAULING SPECIFIC STATES (7 Events) ---
  "queue_at_load", "maneuver_at_load", "travel_full",
  "queue_at_dump", "maneuver_at_dump", "dumping", "travel_empty",
  "travel_time", "lj", "xj",

  # --- TIDYVERSE HELPERS ---
  "select", "where", "everything", "any_of", "all_of", ".data"
))
