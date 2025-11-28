## data-raw/process_sn_events.R

library(tidyverse)
library(lubridate)
library(janitor)
library(fs)
library(usethis) # <--- ADICIONADO: Essencial para o use_data funcionar

# --- 1. CONFIGURAÇÃO DE CAMINHOS ---
path_shift <- "K:/Meu Drive/Dados_Confidenciais/data_appoint.Rdata"
path_event <- "K:/Meu Drive/Dados_Confidenciais/data_trucks_appoint_for_event.Rdata"

if (!file.exists(path_shift)) stop(paste("Arquivo não encontrado:", path_shift))

# --- 2. FUNÇÃO AUXILIAR DE PROCESSAMENTO (Shift Logs) ---
processar_e_salvar_shift <- function(df_completo, grupo_filtro, nome_dataset, ano_filtro = 2023) {

  message(paste("Processando", nome_dataset, "..."))

  df_filtrado <- df_completo %>%
    ungroup() %>% # <--- ADICIONADO: Remove agrupamentos antigos para evitar avisos

    # Filtro de Ano e Grupo
    filter(year == ano_filtro) %>%
    filter(str_detect(group, grupo_filtro)) %>%

    # CORREÇÃO DE TYPO (Preventiva)
    rename_with(~ gsub("equipament", "equipment", .x), .cols = any_of("equipament")) %>%

    # ANONIMIZAÇÃO
    mutate(
      prefixo = str_to_upper(str_split(nome_dataset, "_")[[1]][1]),
      id_equipamento = paste0(prefixo, "-", sprintf("%04d", as.numeric(as.factor(equipment)))),
      data_evento = as.Date(day),
      duracao_h = as.numeric(time_gap) * runif(n(), 0.99, 1.01)
    ) %>%

    # SELEÇÃO FINAL
    select(
      id_equipamento,
      data = data_evento,
      turno = shift,
      equipe = team,
      inicio = time_in,
      fim = time_end,
      duracao_h,
      status,
      codigo = code,
      categoria = category,
      descricao = desc_category
    )

  # Salvar .rda
  assign(nome_dataset, df_filtrado)
  do.call("use_data", list(as.name(nome_dataset), overwrite = TRUE))

  # Salvar CSV
  fs::dir_create("inst/extdata")
  write_csv(head(df_filtrado, 5000), paste0("inst/extdata/", nome_dataset, ".csv"))

  message(paste("✅", nome_dataset, "salvo."))
}

# --- 3. EXECUÇÃO: LOGS DE TURNO (SHIFT) ---
message("Carregando base de turnos (data_appoint)...")
load(path_shift)

if (!exists("data_appoint")) stop("Objeto 'data_appoint' não encontrado.")

processar_e_salvar_shift(data_appoint, "Perfuratriz", "drill_event_sn")
processar_e_salvar_shift(data_appoint, "Escavadeira|Pa Mecanica|Minerador", "load_event_sn")
processar_e_salvar_shift(data_appoint, "Caminhao$", "haul_shift_log_sn")
processar_e_salvar_shift(data_appoint, "Patrol|Trator|Pipa|Prancha", "infra_event_sn")

# Limpar memória
rm(data_appoint)
gc()

# --- 4. EXECUÇÃO: LOG DE EVENTOS (FAILURE) ---
if (file.exists(path_event)) {
  message("Carregando base de eventos (data_trucks...)...")
  load(path_event)

  # Padronizar objeto
  if (exists("data_trucks_appoint_for_event")) {
    raw_event <- data_trucks_appoint_for_event
  } else if (exists("data_appoint_for_event")) {
    raw_event <- data_appoint_for_event
  } else {
    stop("Nenhum objeto de eventos encontrado.")
  }

  haul_failure_log_sn <- raw_event %>%
    ungroup() %>% # Previne erros de grouping
    filter(year == 2023) %>%

    rename_with(~ gsub("equipament", "equipment", .x), .cols = any_of("equipament")) %>%

    mutate(
      id_equipamento = paste0("HAUL-", sprintf("%04d", as.numeric(as.factor(equipment)))),
      data_inicio = as.Date(day),
      duracao_h = as.numeric(time_gap) * runif(n(), 0.99, 1.01)
    ) %>%

    select(
      id_equipamento,
      data_inicio,
      inicio = time_in,
      fim = time_end,
      duracao_h,
      status,
      codigo = code,
      categoria = category,
      descricao = desc_category,
      causa = cause
    )

  usethis::use_data(haul_failure_log_sn, overwrite = TRUE)
  write_csv(head(haul_failure_log_sn, 5000), "inst/extdata/haul_failure_log_sn.csv")
  message("✅ Dataset 'haul_failure_log_sn' salvo.")

} else {
  warning("Arquivo de eventos não encontrado.")
}

message("🚀 Processamento Serra Norte Finalizado!")
