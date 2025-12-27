## Script para processar e salvar os dados de perfuração
## Caminho: data-raw/drilling_integration.R

# 1. Carregamento dos dados processados
# Nota: Verifique se o caminho bate com onde o script anterior salvou (data/processed_drilling_data.RData)
path_to_data <- "data/processed_drilling_data.RData"

if (!file.exists(path_to_data)) {
  # Tenta o caminho absoluto se o relativo não for encontrado (conforme seu snippet)
  path_to_data <- "C:/Projetos/scripts_miningKPI/data/processed_drilling_data.RData"
}

if (file.exists(path_to_data)) {
  load(path_to_data)
  message("Dados carregados de: ", path_to_data)
} else {
  stop("Arquivo .RData não encontrado no caminho especificado!")
}

# 2. Validação Básica (Garante que os objetos existem no Environment)
if (!exists("drill_maintenance_log_mine_d")) {
  warning("O objeto 'drill_maintenance_log_mine_d' não foi encontrado no .RData carregado.")
}

# 3. Exportação para o diretório data/ do pacote (compressão 'xz' é a padrão do CRAN)
usethis::use_data(drill_events_mine_d, overwrite = TRUE, compress = "xz")
usethis::use_data(drill_cycles_mine_d, overwrite = TRUE, compress = "xz")

# NOVO: Exportando a base de Manutenção Processada
usethis::use_data(drill_maintenance_log_mine_d, overwrite = TRUE, compress = "xz")

message(">>> Datasets (Eventos, Ciclos e Manutenção) integrados com sucesso ao pacote miningKPI.")
