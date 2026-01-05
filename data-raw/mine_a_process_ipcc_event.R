## Script para integrar os dados IPCC ao pacote miningKPI
## Caminho: data-raw/process_ipcc_event_mine_e.R

# 1. Carregamento dos dados processados no Passo 1
load("C:/Projetos/scripts_miningKPI/data/mine_e_ipcc_event.rda")
# 3. Exportação para o diretório data/ do pacote
# Usamos usethis para garantir a compressão 'xz' (padrão CRAN)
usethis::use_data(ipcc_event_log_mine_e, overwrite = TRUE, compress = "xz")

message(">>> Passo 2 Concluído: ipcc_event_log_mine_e agora faz parte do pacote miningKPI.")
