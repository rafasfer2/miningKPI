################################################################################
## Script para integrar e salvar os dados de perfuração e previsão (Mina D)
## Caminho: data-raw/drilling_integration.R
################################################################################

# 1. DEFINIÇÃO DOS ARQUIVOS E CAMINHOS
# Criamos uma lista de arquivos que precisam ser carregados
arquivos <- c(
  "processed_drilling_data.RData",
  "drill_planning_mine_d.RData",
  "production_forecast_mine_d.RData"
)

for (arq in arquivos) {
  path_to_data <- paste0("data/", arq)

  # --- LOGICA DE REDUNDÂNCIA RESTAURADA ---
  if (!file.exists(path_to_data)) {
    # Tenta o caminho absoluto se o relativo não for encontrado
    path_to_data <- paste0("C:/Projetos/scripts_miningKPI/data/", arq)
  }

  # Carregamento se o arquivo existir
  if (file.exists(path_to_data)) {
    load(path_to_data)
    message(">>> Sucesso: Carregado ", arq, " de ", path_to_data)
  } else {
    warning("!!! Erro: Arquivo ", arq, " não encontrado em nenhum dos caminhos!")
  }
}

# 2. VALIDAÇÃO DE OBJETOS NO ENVIRONMENT
# Verificamos se os objetos táticos e estratégicos estão presentes
objetos_obrigatorios <- c(
  "drill_events_mine_d", "drill_cycles_mine_d",
  "drill_maintenance_log_mine_d", "drill_planning_mine_d",
  "production_forecast_mine_d" # O dado D+30 renomeado corretamente
)

for (obj in objetos_obrigatorios) {
  if (!exists(obj)) stop("Objeto '", obj, "' não encontrado! Rode o ETL primeiro.")
}

################################################################################
# 3. EXPORTAÇÃO PARA O PACOTE (usethis)
################################################################################

# --- Realizado (Actuals) ---
usethis::use_data(drill_events_mine_d, overwrite = TRUE, compress = "xz")
usethis::use_data(drill_cycles_mine_d, overwrite = TRUE, compress = "xz")
usethis::use_data(drill_maintenance_log_mine_d, overwrite = TRUE, compress = "xz")

# --- Planejado (Budget/Strategic) ---
usethis::use_data(drill_planning_mine_d, overwrite = TRUE, compress = "xz")

# --- Previsão (Forecast/Tactical D+30) ---
usethis::use_data(production_forecast_mine_d, overwrite = TRUE, compress = "xz")

message(">>> Integração concluída: 5 datasets adicionados ao miningKPI.")
