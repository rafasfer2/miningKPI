################################################################################
## Script para integrar e salvar os dados de perfuração e previsão (Mina D)
## Caminho: data-raw/drilling_integration.R
################################################################################

load("C:/Projetos/scripts_miningKPI/data/mine_d_processed_drilling_data.rda")

usethis::use_data(drill_events_mine_d, overwrite = TRUE, compress = "xz")
usethis::use_data(drill_cycles_mine_d, overwrite = TRUE, compress = "xz")
usethis::use_data(drill_maintenance_log_mine_d, overwrite = TRUE, compress = "xz")
usethis::use_data(drill_planning_mine_d, overwrite = TRUE, compress = "xz")
usethis::use_data(drill_production_forecast_mine_d, overwrite = TRUE, compress = "xz")

message(">>> Integração concluída: 5 datasets adicionados ao miningKPI.")
