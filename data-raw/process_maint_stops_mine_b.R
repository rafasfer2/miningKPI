## data-raw/process_maint_stops_mine_b.R

library(tidyverse)
library(readxl)
library(janitor)
library(usethis)
library(lubridate)

# --- CONFIGURAÇÃO ---
caminho_real <- "K:/Meu Drive/Dados_Confidenciais/paradas_completas_2022.xlsx"

if (!file.exists(caminho_real)) {
  stop("Arquivo 'paradas_completas_2022.xlsx' não encontrado.")
}

# --- LEITURA E TRATAMENTO ---
raw <- read_excel(caminho_real, col_types = "text") %>% clean_names()

maint_stops_mine_b <- raw %>%
  mutate(
    data_inicio = as_datetime(data_inicial),
    data_fim = as_datetime(data_final),
    duracao_horas = as.numeric(difftime(data_fim, data_inicio, units = "hours"))
  ) %>%
  filter(classe == "Produção", categoria == "Transporte", duracao_horas > 0) %>%
  transmute(
    unidade = "Mina B",
    data_inicio,
    duracao_horas,
    categoria_macro = categoria_tempo,
    tipo_evento = categoria_tempo_tipo,
    sistema, problema, solucao
  ) %>%
  mutate(data_inicio = data_inicio - years(1))

# --- SALVAR ---
usethis::use_data(maint_stops_mine_b, overwrite = TRUE)
message("✅ Dataset 'maint_stops_mine_b' criado!")
