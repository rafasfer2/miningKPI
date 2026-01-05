# --- INTEGRAÇÃO DE DATASETS: miningKPI ---

# 1. Carregamento dos dados processados (contendo as 4 entidades fundamentais)
# Certifique-se de que o arquivo .RData contém os objetos nomeados conforme abaixo
load("C:/Projetos/scripts_miningKPI/data/mine_a_processed_loading_data.rda")

# 2. Registro oficial dos dados no pacote com compressão xz para otimização
usethis::use_data(load_events_mine_a, overwrite = TRUE, compress = "xz")
usethis::use_data(load_cycles_mine_a, overwrite = TRUE, compress = "xz")
usethis::use_data(haul_events_mine_a, overwrite = TRUE, compress = "xz")
usethis::use_data(haul_cycles_mine_a, overwrite = TRUE, compress = "xz")

message(">>> Datasets integrados: load_events, load_cycles, haul_events e haul_cycles.")
