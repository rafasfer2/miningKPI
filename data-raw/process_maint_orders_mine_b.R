## data-raw/process_maint_orders_mine_b.R

library(tidyverse)
library(readxl)
library(janitor)
library(usethis)
library(lubridate)

# --- CONFIGURAÇÃO ---
caminho_real <- "K:/Meu Drive/Dados_Confidenciais/manutencao_detalhada_2021_2022.xlsx"

if (!file.exists(caminho_real)) {
  stop("Arquivo 'manutencao_detalhada_2021_2022.xlsx' não encontrado.")
}

# --- LEITURA E TRATAMENTO ---
raw <- read_excel(caminho_real, col_types = "text") %>% clean_names()

maint_orders_mine_b <- raw %>%
  filter(classe == "Produção", categoria == "Transporte", grupo == "Caminhão") %>%
  mutate(
    data_inicio = as_datetime(data_inicial),
    data_fim = as_datetime(data_final_parada),
    duracao_horas = as.numeric(difftime(data_fim, data_inicio, units = "hours"))
  ) %>%
  transmute(
    unidade = "Mina B",
    data_inicio,
    duracao_horas,
    tipo_manutencao = categoria_tipo,
    sistema, conjunto, item,
    problema, solucao, comentario
  ) %>%
  mutate(
    duracao_horas = round(duracao_horas * 1.0, 2),
    data_inicio = data_inicio - years(1)
  ) %>%
  filter(duracao_horas > 0)

# --- SALVAR ---
usethis::use_data(maint_orders_mine_b, overwrite = TRUE)
message("✅ Dataset 'maint_orders_mine_b' criado!")
