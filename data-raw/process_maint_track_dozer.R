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
  stop("Arquivo não encontrado! Verifique o nome 'manutencao_preventiva_itabirito.xlsx'")
}

# --- 2. LEITURA ---
# Lemos as abas. Importante: ler como texto para evitar conversão automática errada,
# ou confiar no read_excel mas tratar depois. Vamos deixar automático mas usar parse_date_time.
raw_eventos   <- read_excel(caminho_real, sheet = "Apropriação Detalhada") %>% clean_names()
raw_horimetro <- read_excel(caminho_real, sheet = "horimetro") %>% clean_names()
raw_pautas    <- read_excel(caminho_real, sheet = "Tipo revisão") %>% clean_names()

set.seed(2023)

# --- 3. CRIAR MAPA DE ANONIMIZAÇÃO ---
# Identificamos todos os caminhões únicos em todas as abas
todos_caminhoes <- unique(c(raw_eventos$truck, raw_horimetro$truck, raw_pautas$truck))

mapa_ids <- tibble(
  id_real = todos_caminhoes,
  id_anonimo = paste0("TR-IT-", sprintf("%02d", as.numeric(as.factor(todos_caminhoes))))
)

# --- 4. PROCESSAMENTO: ABA 1 (EVENTOS) ---
maint_truck_events_it <- raw_eventos %>%
  left_join(mapa_ids, by = c("truck" = "id_real")) %>%
  mutate(
    # TRATAMENTO DE DATAS ROBUSTO
    # Tenta ler DMY_HMS (Brasil) ou YMD_HMS (Excel Padrão/ISO)
    inicio = parse_date_time(time_in, orders = c("dmy HMS", "ymd HMS", "dmy", "ymd")),
    fim = parse_date_time(time_end, orders = c("dmy HMS", "ymd HMS", "dmy", "ymd")),

    # Se parse_date_time falhar (gerar NA) e o dado for numérico (Excel Serial), tenta converter
    inicio = coalesce(inicio, as_datetime(as.numeric(time_in), origin = "1899-12-30")),
    fim = coalesce(fim, as_datetime(as.numeric(time_end), origin = "1899-12-30")),

    # CÁLCULO DE DURAÇÃO (Mais seguro calcular no R que pegar do Excel)
    duracao_calc = as.numeric(difftime(fim, inicio, units = "hours")),

    # Classificação
    tipo_manutencao = category,
    descricao = description,

    # Indicador de Preventiva
    is_preventiva = !is.na(mp)
  ) %>%

  transmute(
    unidade = "Mina C", # Itabirito
    id_equipamento = id_anonimo,
    data = as.Date(inicio),
    inicio,
    fim,
    duracao_h = duracao_calc,
    categoria = tipo_manutencao,
    descricao,
    horimetro_evento = as.numeric(hourmeter),
    is_preventiva
  ) %>%

  # Perturbação leve e filtro
  mutate(duracao_h = round(duracao_h * runif(n(), 0.99, 1.01), 2)) %>%
  filter(!is.na(id_equipamento), duracao_h > 0)

# --- 5. PROCESSAMENTO: ABA 2 (HORÍMETRO DIÁRIO) ---
maint_truck_hourmeter_it <- raw_horimetro %>%
  left_join(mapa_ids, by = c("truck" = "id_real")) %>%
  mutate(
    # Tratamento de data robusto também para o horímetro
    data_leitura = parse_date_time(day, orders = c("dmy", "ymd", "dmy HMS", "ymd HMS")),
    data_leitura = coalesce(data_leitura, as_datetime(as.numeric(day), origin = "1899-12-30"))
  ) %>%
  transmute(
    id_equipamento = id_anonimo,
    data = as.Date(data_leitura),
    horimetro_acumulado = as.numeric(hourmeter)
  ) %>%
  group_by(id_equipamento) %>%
  arrange(data) %>%
  filter(horimetro_acumulado > 0) %>%
  ungroup()

# --- 6. PROCESSAMENTO: ABA 3 (PAUTAS REALIZADAS) ---
maint_truck_pautas_it <- raw_pautas %>%
  left_join(mapa_ids, by = c("truck" = "id_real")) %>%
  mutate(
    data_prog = parse_date_time(start, orders = c("dmy", "ymd", "dmy HMS", "ymd HMS")),
    data_prog = coalesce(data_prog, as_datetime(as.numeric(start), origin = "1899-12-30"))
  ) %>%
  transmute(
    id_equipamento = id_anonimo,
    data_programada = as.Date(data_prog),
    tipo_revisao = pauta # Ex: 250, 500
  ) %>%
  filter(!is.na(id_equipamento))

# --- 7. SALVAR TUDO ---
usethis::use_data(maint_truck_events_it, overwrite = TRUE)
usethis::use_data(maint_truck_hourmeter_it, overwrite = TRUE)
usethis::use_data(maint_truck_pautas_it, overwrite = TRUE)

# CSVs
fs::dir_create("inst/extdata")
write_csv(maint_truck_events_it, "inst/extdata/maint_truck_events_it.csv")

message("✅ Dados de Itabirito (Preventiva/Confiabilidade) processados com sucesso!")
