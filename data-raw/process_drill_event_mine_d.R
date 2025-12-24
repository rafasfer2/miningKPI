# --- INTEGRAÇÃO DE DATASETS: miningKPI (Chapter 01: Drilling) ---

# 1. Carregamento dos dados processados do diretório de scripts
# Use o caminho absoluto ou relativo conforme sua estrutura
path_to_data <- "C:/Projetos/scripts_miningKPI/data/processed_drilling_data.RData"

if (file.exists(path_to_data)) {
  load(path_to_data)
} else {
  stop("Arquivo .RData não encontrado no caminho especificado!")
}

# 2. Registro oficial no pacote (disponível em data/)
# O usethis::use_data exporta os objetos para arquivos .rda otimizados
usethis::use_data(drill_events_mine_d, overwrite = TRUE, compress = "xz")
usethis::use_data(drill_cycles_mine_d, overwrite = TRUE, compress = "xz")

message(">>> Datasets de perfuração integrados ao pacote: drill_events_mine_d e drill_cycles_mine_d.")
