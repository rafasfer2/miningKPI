# --- IMPORTAÇÃO DOS DADOS PROCESSADOS DO PROJETO PRIVADO ---

# 1. Carrega os dados gerados pelo projeto 'scripts_miningKPI'
# Certifique-se de ajustar o caminho relativo ou absoluto corretamente
load("C:/Projetos/scripts_miningKPI/data/processed_load_mine_a_data.Rdata")

# 2. Disponibiliza os objetos no pacote 'miningKPI'
usethis::use_data(load_events_mine_a, overwrite = TRUE, compress = "xz")
usethis::use_data(load_cycles_mine_a, overwrite = TRUE, compress = "xz")
usethis::use_data(haul_events_mine_a, overwrite = TRUE, compress = "xz")

message(">>> Datasets da Mina A integrados ao pacote miningKPI com sucesso!")
