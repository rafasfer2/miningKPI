## Script para processar e salvar os dados de perfuração
## Caminho: data-raw/drilling_integration.R

# 1. Carregamento dos dados processados
path_to_data <- "C:/Projetos/scripts_miningKPI/data/processed_drilling_data.RData"

if (file.exists(path_to_data)) {
  load(path_to_data)
} else {
  stop("Arquivo .RData não encontrado no caminho especificado!")
}

# 2. Limpeza ou ajustes finais (opcional)
# Certifique-se que drill_events_mine_d e drill_cycles_mine_d estão no Environment

# 3. Exportação para o diretório data/ do pacote
usethis::use_data(drill_events_mine_d, overwrite = TRUE, compress = "xz")
usethis::use_data(drill_cycles_mine_d, overwrite = TRUE, compress = "xz")

message(">>> Datasets integrados com sucesso ao pacote miningKPI.")
