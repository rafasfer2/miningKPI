## Script para integrar os dados IPCC ao pacote miningKPI
## Caminho: data-raw/process_ipcc_event_mine_e.R

# 1. Carregamento dos dados processados no Passo 1
path_to_data <- "../scripts_miningKPI/data/ipcc_event_log_mine_e.RData"

if (!file.exists(path_to_data)) {
  # Tenta o caminho absoluto caso o relativo falhe
  path_to_data <- "C:/Projetos/scripts_miningKPI/data/ipcc_event_log_mine_e.RData"
}

if (file.exists(path_to_data)) {
  load(path_to_data)
  message("Dados IPCC carregados com sucesso de: ", path_to_data)
} else {
  stop("ERRO: Arquivo processado do IPCC não encontrado! Verifique o Passo 1.")
}

# 2. Validação Básica
if (!exists("ipcc_event_log_mine_e")) {
  stop("Objeto 'ipcc_event_log_mine_e' não encontrado no Environment.")
}

# 3. Exportação para o diretório data/ do pacote
# Usamos usethis para garantir a compressão 'xz' (padrão CRAN)
usethis::use_data(ipcc_event_log_mine_e, overwrite = TRUE, compress = "xz")

message(">>> Passo 2 Concluído: ipcc_event_log_mine_e agora faz parte do pacote miningKPI.")
