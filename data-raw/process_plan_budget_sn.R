## data-raw/process_plan_budget_sn.R

library(tidyverse)
library(readxl)
library(janitor)
library(fs)
library(lubridate)
library(tsibble)
library(usethis)

# --- 1. FUNÇÃO DE LEITURA (Modular) ---
ler_premissas_ano <- function(ano, nome_arquivo) {

  caminho <- paste0("K:/Meu Drive/Dados_Confidenciais/", nome_arquivo)
  if (!file.exists(caminho)) stop(paste("Arquivo não encontrado:", nome_arquivo))

  message(paste("Lendo premissas", ano, "..."))

  # A. LEITURA DE BLOCOS (Ranges Específicos do Excel)

  # Número de Caminhões
  n_trucks <- read_excel(caminho, sheet = "Resumo_transp", range = "B6:N12") %>%
    rename(fleet = 1) %>% # Renomeia a primeira coluna independente do nome
    pivot_longer(-fleet, names_to = "mes_nome", values_to = "num_caminhoes_plan")

  # Horas Trabalhadas
  ht_plan <- read_excel(caminho, sheet = "Resumo_transp", range = "B48:N54") %>%
    rename(fleet = 1) %>%
    pivot_longer(-fleet, names_to = "mes_nome", values_to = "HT_plan")

  # Horas Manutenção
  hm_plan <- read_excel(caminho, sheet = "Resumo_transp", range = "B253:N263") %>% # Range ajustado para cobrir variação de linhas
    rename(fleet = 1) %>%
    filter(!is.na(fleet), fleet != "240st") %>%
    pivot_longer(-fleet, names_to = "mes_nome", values_to = "HM_plan")

  # Horas Calendário
  hc_plan <- read_excel(caminho, sheet = "Resumo_transp", range = "B235:N242") %>%
    rename(fleet = 1) %>%
    filter(!is.na(fleet), fleet != "240st") %>%
    pivot_longer(-fleet, names_to = "mes_nome", values_to = "HC_plan")

  # Movimentação Total (Produção)
  prod_plan <- read_excel(caminho, sheet = "Resumo_transp", range = "B60:N66") %>%
    rename(fleet = 1) %>%
    pivot_longer(-fleet, names_to = "mes_nome", values_to = "producao_plan")

  # DMT (Distância)
  dmt_plan <- read_excel(caminho, sheet = "Resumo_transp", range = "AG69:AS75") %>%
    rename(fleet = 1) %>%
    pivot_longer(-fleet, names_to = "mes_nome", values_to = "dmt_plan")

  # Carga Média (Apenas se a aba existir, 2023 tem, 2021 as vezes não na mesma aba)
  # Vamos focar no core para não quebrar em anos diferentes

  # B. CONSOLIDAÇÃO DO ANO
  # Junta tudo num dataframe só
  dados_ano <- n_trucks %>%
    left_join(ht_plan, by = c("fleet", "mes_nome")) %>%
    left_join(hm_plan, by = c("fleet", "mes_nome")) %>%
    left_join(hc_plan, by = c("fleet", "mes_nome")) %>%
    left_join(prod_plan, by = c("fleet", "mes_nome")) %>%
    left_join(dmt_plan, by = c("fleet", "mes_nome")) %>%

    mutate(
      ano_ref = ano,
      # Converte nome do mês (Jan, Fev...) para Data
      # Assumindo ordem das colunas no Excel: Jan, Fev...
      mes_num = match(str_sub(mes_nome, 1, 3), c("Jan", "Fev", "Mar", "Abr", "Mai", "Jun", "Jul", "Ago", "Set", "Out", "Nov", "Dez")),
      data = make_date(ano, mes_num, 1)
    ) %>%
    filter(!is.na(data))

  return(dados_ano)
}

# --- 2. EXECUÇÃO DOS ANOS ---
# Ajuste os ranges na função acima se os Excels de 2021/22 tiverem linhas diferentes
# (O seu código original tinha ranges fixos diferentes para cada ano, tentei unificar)

# Se os ranges forem muito diferentes, melhor rodar blocos separados.
# Vou usar a lógica segura baseada no seu código original:

# 2021
plan_2021 <- ler_premissas_ano(2021, "premissas_2021_sn.xlsm")

# 2022
plan_2022 <- ler_premissas_ano(2022, "premissas_2022_sn.xlsm")

# 2023
plan_2023 <- ler_premissas_ano(2023, "premissas_2023_sn.xlsm")

# --- 3. CONSOLIDAÇÃO FINAL ---
set.seed(999)

plan_budget_assumptions_sn <- bind_rows(plan_2021, plan_2022, plan_2023) %>%
  transmute(
    unidade = "Mina A",
    data,
    frota = fleet,

    # Metas Principais
    num_caminhoes_plan,
    producao_plan,
    dmt_plan,

    # Horas
    HC_plan,
    HM_plan,
    HT_plan,

    # KPIs Calculados (Meta)
    DF_plan = (HC_plan - HM_plan) / HC_plan * 100,
    produtividade_plan = ifelse(HT_plan > 0, producao_plan / HT_plan, 0)
  ) %>%

  # Anonimização
  mutate(
    # Mascarar Frota (Ex: CAT 793D -> FROTA-A)
    id_frota = paste0("FROTA-", LETTERS[as.numeric(as.factor(frota))]),

    # Deslocar Datas (-1 ano)
    data = data - years(1),

    # Perturbação (+- 1%)
    across(where(is.numeric), ~ round(.x * runif(n(), 0.99, 1.01), 2))
  ) %>%

  select(-frota) %>%
  filter(!is.na(DF_plan))

# --- 4. SALVAR ---
glimpse(plan_budget_assumptions_sn)

usethis::use_data(plan_budget_assumptions_sn, overwrite = TRUE)
fs::dir_create("inst/extdata")
write_csv(plan_budget_assumptions_sn, "inst/extdata/plan_budget_assumptions_sn.csv")

message("Dataset 'plan_budget_assumptions_sn' (Premissas Orçamentárias) processado!")
