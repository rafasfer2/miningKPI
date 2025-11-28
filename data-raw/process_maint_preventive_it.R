## data-raw/process_maint_preventive_it.R

library(tidyverse)
library(readxl)
library(janitor)
library(fs)
library(lubridate)
library(usethis)

# --- 1. CONFIGURAÇÃO ---
caminho_real <- "K:/Meu Drive/Dados_Confidenciais/manutencao_preventiva_itabirito.xlsx"

if (!file.exists(caminho_real)) {
  stop("Arquivo não encontrado! Renomeie para 'manutencao_preventiva_itabirito.xlsx'")
}

# --- 2. LEITURA ---
# Lemos as 3 abas
raw_eventos   <- read_excel(caminho_real, sheet = "Apropriação Detalhada") %>% clean_names()
raw_horimetro <- read_excel(caminho_real, sheet = "horimetro") %>% clean_names()
raw_pautas    <- read_excel(caminho_real, sheet = "Tipo revisão") %>% clean_names()

set.seed(2023)

# --- 3. CRIAR MAPA DE ANONIMIZAÇÃO (CRUCIAL) ---
# Identificamos todos os caminhões únicos em todas as abas para criar um ID consistente
todos_caminhoes <- unique(c(raw_eventos$truck, raw_horimetro$truck, raw_pautas$truck))

mapa_ids <- tibble(
  id_real = todos_caminhoes,
  id_anonimo = paste0("TR-IT-", sprintf("%02d", as.numeric(as.factor(todos_caminhoes))))
)

# --- 4. PROCESSAMENTO: ABA 1 (EVENTOS) ---
maint_truck_events_it <- raw_eventos %>%
  left_join(mapa_ids, by = c("truck" = "id_real")) %>%
  mutate(
    # Tratamento de Datas (dmy_hms ou ymd_hms dependendo do Excel)
    # O user disse: "01/01/2023 00:00:00" -> dmy_hms
    inicio = dmy_hms(time_in),
    fim = dmy_hms(time_end),

    # Duração (Se time_gap estiver em texto ou decimal, forçar numérico)
    duracao_h = as.numeric(time_gap),

    # Classificação
    tipo_manutencao = category, # HMC, MPS
    descricao = description,
    comentario = comment,

    # Indicador de Preventiva (MP)
    is_preventiva = !is.na(mp)
  ) %>%
  transmute(
    unidade = "Mina C", # Itabirito
    id_equipamento = id_anonimo,
    data = date(inicio),
    inicio, fim, duracao_h,
    categoria = tipo_manutencao,
    descricao,
    horimetro_evento = as.numeric(hourmeter), # Horímetro no momento da falha
    is_preventiva
  ) %>%
  # Perturbação leve
  mutate(duracao_h = round(duracao_h * runif(n(), 0.99, 1.01), 2)) %>%
  filter(!is.na(id_equipamento))

# --- 5. PROCESSAMENTO: ABA 2 (HORÍMETRO DIÁRIO) ---
maint_truck_hourmeter_it <- raw_horimetro %>%
  left_join(mapa_ids, by = c("truck" = "id_real")) %>%
  transmute(
    id_equipamento = id_anonimo,
    data = as.Date(day),
    horimetro_acumulado = as.numeric(hourmeter)
  ) %>%
  # Limpeza de outliers (horímetro zerado ou descendo)
  group_by(id_equipamento) %>%
  arrange(data) %>%
  filter(horimetro_acumulado > 0) %>%
  ungroup()

# --- 6. PROCESSAMENTO: ABA 3 (PAUTAS REALIZADAS) ---
maint_truck_pautas_it <- raw_pautas %>%
  left_join(mapa_ids, by = c("truck" = "id_real")) %>%
  transmute(
    id_equipamento = id_anonimo,
    data_programada = as.Date(start),
    tipo_revisao = pauta # Ex: 250, 500, 1000
  ) %>%
  filter(!is.na(id_equipamento))

# --- 7. SALVAR TUDO ---
usethis::use_data(maint_truck_events_it, overwrite = TRUE)
usethis::use_data(maint_truck_hourmeter_it, overwrite = TRUE)
usethis::use_data(maint_truck_pautas_it, overwrite = TRUE)

# CSVs para exemplo
fs::dir_create("inst/extdata")
write_csv(maint_truck_events_it, "inst/extdata/maint_truck_events_it.csv")

message("Dados de Itabirito (Preventiva/Confiabilidade) processados!")
