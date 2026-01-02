# Define global variables to satisfy R CMD check
utils::globalVariables(c(
  # --- IPCC / MINA E (Novo Ciclo) ---
  "mining_method", "validated", "production_system", "subprocess", "line",
  "equipment", "event_code", "event_description", "activity_code",
  "activity_description", "duration_h", "egp", "asset_family", "asset_class",
  "cause", "failure", "hour_category", "hour_category_phase",
  "hour_category_system", "hour_category_sub", "hour_category_line",
  "shift", "auto_manual", "maint_order", "virtual_equipment",

  # --- DRILLING (Métricas de Performance e Higienização) ---
  "anchor_time", "li", "xi_min", "pi_min", "ci_min", "di_min",
  "hi_min", "mi_min", "TDM", "WH", "per\u00edodo", "cycle_bucket", "timestamp",
  "drill_id", "drill_fleet", "borehole_uid", "cycle", "phase",
  "ref_time", "category", "category_kpi", "description_en",
  "description_pt", "allocated_meters", "data_source", "comment_en",

  # --- ANONIMIZAÇÃO E PROCESSAMENTO (IPCC & GERAL) ---
  "original_code", "code", "original_id", "anon_id", "raw_desc_br",
  "comment_clean", "sector_clean", "ids_tmp", "tag_tmp", "category_raw",
  "cycle_trigger", "is_tramming", "is_pos", "total_min_efh_day", "prod_day_tmp",
  "asset_id", "asset_anon", "orig_prefix", "new_prefix", "sigla_pt", "egp_prefix",

  # --- CORE TIME COLUMNS & GAP FILLING ---
  "first_time", "exit_time", "start_time", "end_time", "duration_min", "date",
  "start_time_inop", "exit_time_inop", "start_time_carga", "Fim",
  "prev_exit", "Salto", "first_time_new", "exit_time_new",

  # --- IDENTIFICATION & CATEGORIZATION (Sossego & Serra Sul) ---
  "load_fleet", "haul_fleet", "load_id", "haul_id", "trip_id",
  "origin", "destination", "material", "load_status", "fleet_id",
  "equipament", "equipment", "sector", "comment", "Ids", "TAGId", "time_in",
  "time_gap", "group", "day", "HO", "HM", "HT", "HC", "Produ\u00e7\u00e3o",

  # --- EVENT TYPES & OPERATIONAL STATES ---
  "event_type", "maneuver", "loading", "idle", "gap",
  "m_time", "l_time", "i_time", "q_time", "d_time",

  # --- TECHNICAL & PERFORMANCE DATA ---
  "payload", "salto", "cycle_id", "load_factor",
  "scale_weight", "scale_ok", "target_max",

  # --- HAULING SPECIFIC - DISTANCES & STATES ---
  "dmt_full", "dmt_empty", "dmt_total", "dist_km", "dist_total",
  "dist_empty", "dist_full", "queue_at_load", "maneuver_at_load",
  "travel_full", "queue_at_dump", "maneuver_at_dump", "dumping",
  "travel_empty", "travel_time", "lj", "xj",

  # --- TIDYVERSE HELPERS & LUBRIDATE ---
  "select", "where", "everything", "any_of", "all_of", ".data", "is.POSIXct", "n"
))
