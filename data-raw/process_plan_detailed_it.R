## data-raw/process_plan_detailed_it.R

library(tidyverse)
library(readxl)
library(janitor)
library(fs)
library(lubridate)
library(usethis)

# --- 1. CONFIGURAÇÃO ---
caminho_real <- "K:/Meu Drive/Dados_Confidenciais/planejamento_detalhado_2021_it.xlsx"

if (!file.exists(caminho_real)) {
  stop("Arquivo de planejamento detalhado não encontrado! Renomeou para 'planejamento_detalhado_2021_it.xlsx'?")
}

# --- 2. LEITURA ---
dados_brutos <- read_excel(caminho_real)

# --- 3. TRATAMENTO ---
set.seed(2021)

plan_daily_detailed_2021_it <- dados_brutos %>%
  clean_names() %>%

  # A. FILTRO E LIMPEZA
  # Remover linhas de total geral se houver (geralmente Tabela Dinâmica cria)
  filter(!is.na(data_dia), !str_detect(equipamento, "Total")) %>%

  # B. MAPEAMENTO (Removendo o prefixo 'soma_de_')
  transmute(
    unidade = "Mina C", # Itabira
    data = as.Date(data_dia),
    id_equipamento_real = equipamento,

    # KPIs Macro (Metas)
    DF_plan = df,
    UF_plan = uf,
    produtividade_plan = soma_de_produtividade,

    # Produção (Meta)
    num_viagens_plan = soma_de_viagens,
    carga_media_plan = soma_de_carga_media,
    # Recalcula produção meta baseada nos componentes
    producao_plan = num_viagens_plan * carga_media_plan,

    # Tempos de Ciclo (Metas em Minutos)
    meta_tempo_carregamento = soma_de_carregamento,
    meta_tempo_basculo = soma_de_basculo,
    meta_tempo_manobra = soma_de_manobra,
    meta_tempo_fila_carga = soma_de_fila_carga,
    meta_tempo_fila_basculo = soma_de_fila_basculo,

    # Transporte (Metas)
    meta_dmt = soma_de_dmt,
    meta_vel_global = soma_de_velocidade_global,
    meta_vel_cheio = soma_de_velocidade_cheio,
    meta_vel_vazio = soma_de_velocidade_vazio,

    # Horas (Metas)
    HC_plan = hc,
    HM_plan = hm,
    HT_plan = ht,
    HAO_plan = soma_de_hao,
    HO_plan = soma_de_ho
  ) %>%

  # C. ANONIMIZAÇÃO
  mutate(
    # Mascarar Equipamento (TR-IT-XXX)
    id_equipamento = paste0("TR-IT-", sprintf("%03d", as.numeric(as.factor(id_equipamento_real)))),

    # Deslocar data (Mantendo em 2021 ou ajustando para bater com o histórico se necessário)
    # Vamos manter 2021 pois é um deep-dive específico
    # data = data - years(1),

    # Perturbação numérica leve (+- 0.5% pois são metas fixas)
    across(where(is.numeric), ~ round(.x * runif(n(), 0.995, 1.005), 2))
  ) %>%

  select(-id_equipamento_real) %>%
  filter(HC_plan > 0)

# --- 4. SALVAR ---
glimpse(plan_daily_detailed_2021_it)

usethis::use_data(plan_daily_detailed_2021_it, overwrite = TRUE)
fs::dir_create("inst/extdata")
write_csv(plan_daily_detailed_2021_it, "inst/extdata/plan_daily_detailed_2021_it.csv")

message("Dataset de Metas Detalhadas 2021 (Itabira) processado!")
