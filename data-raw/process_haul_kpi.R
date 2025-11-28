## data-raw/process_haul_kpi.R

library(tidyverse)
library(lubridate)
library(janitor)
library(fs)
library(usethis)
library(tsibble)

# --- 1. CONFIGURAÇÃO ---
caminho_real <- "K:/Meu Drive/Dados_Confidenciais/data_requipam.Rdata"

if (!file.exists(caminho_real)) {
  stop("Arquivo data_requipam.Rdata não encontrado!")
}

# --- 2. LEITURA ---
message("Carregando KPIs mensais (Requipam)...")
load(caminho_real) # Carrega 'data_requipam'

if (!exists("data_requipam")) stop("Objeto 'data_requipam' não encontrado no arquivo.")

# --- 3. TRATAMENTO E ANONIMIZAÇÃO ---
set.seed(2024)

# Diagnóstico de colunas (para garantir que pegamos os nomes certos)
# Se suas colunas estão em Maiúsculo (HEF, HMP) no RData original,
# o clean_names() as transformaria em hef, hmp.
# Vamos garantir que usamos os nomes que realmente existem.

haul_kpi_monthly_sn <- data_requipam %>%
  ungroup() %>%
  as_tibble() %>%
  clean_names() %>% # Padroniza tudo para minúsculo (hmp, hmc, hef...)

  # A. FILTRO DE ESCOPO
  filter(group == "Caminhao") %>%

  # B. SELEÇÃO E RENOMEAÇÃO (Com verificação de existência)
  transmute(
    data = as.Date(month),
    id_equipamento_real = equipment,
    frota = model,

    # Indicadores
    DF = df,
    UF = uf,

    # Tenta pegar mtbf/mttr minúsculo ou maiúsculo
    MTBF = tryCatch(mtbf, error = function(e) MTBF),
    MTTR = tryCatch(mttr, error = function(e) MTTR),

    num_falhas = nic,

    # Produção
    produtividade_h = pr,
    producao_total = mt,

    # Horas (Aqui estava o erro: vamos usar tryCatch para garantir)
    HC = hc,
    HM = hm,
    HMC = hmc,

    # O erro foi aqui. Se 'hmp' não existe, pode ser que o clean_names
    # tenha gerado outro nome ou a coluna não veio.
    # Vamos tentar pegar 'mpns' + 'mps' se 'hmp' não existir.
    HMP = tryCatch(hmp, error = function(e) mps + mpns),

    HT = ht,
    HEF = hef
  ) %>%

  # C. ANONIMIZAÇÃO
  mutate(
    id_equipamento = paste0("HAUL-", sprintf("%04d", as.numeric(as.factor(id_equipamento_real)))),
    data = data - years(1),

    across(c(DF, UF, MTBF, MTTR, produtividade_h, producao_total),
           ~ .x * runif(n(), 0.99, 1.01)),

    across(where(is.numeric), ~ round(.x, 2))
  ) %>%

  select(-id_equipamento_real) %>%
  filter(HC > 0)

# --- 4. VALIDAÇÃO ---
glimpse(haul_kpi_monthly_sn)

# --- 5. SALVAR ---
usethis::use_data(haul_kpi_monthly_sn, overwrite = TRUE)
fs::dir_create("inst/extdata")
write_csv(haul_kpi_monthly_sn, "inst/extdata/haul_kpi_monthly_sn.csv")

message("Dataset de KPIs Mensais (Requipam) processado com sucesso!")
