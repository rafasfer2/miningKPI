## data-raw/process_plan_budget_sn.R

library(tidyverse)
library(readxl)
library(janitor)
library(fs)
library(lubridate)
library(usethis)

# --- 1. CONFIGURAÇÃO ---
path_2021 <- "K:/Meu Drive/Dados_Confidenciais/premissas_2021_sn.xlsm"
path_2022 <- "K:/Meu Drive/Dados_Confidenciais/premissas_2022_sn.xlsm"
path_2023 <- "K:/Meu Drive/Dados_Confidenciais/premissas_2023_sn.xlsm"

if (!all(file.exists(path_2021, path_2022, path_2023))) {
  stop("Algum arquivo de premissas não foi encontrado!")
}

# --- 2. FUNÇÃO DE LEITURA SEGURA ---
ler_range <- function(arquivo, range_excel, nome_valor, ano) {
  # Lê sem cabeçalho
  raw <- suppressMessages(
    read_excel(arquivo, sheet = "Resumo_transp", range = range_excel, col_names = FALSE)
  )

  # Garante que pegou dados
  if (nrow(raw) == 0) return(NULL)

  # Seleciona as 13 colunas (Frota + 12 meses)
  # Se o range pegou mais colunas vazias à direita, cortamos
  raw <- raw[, 1:13]
  colnames(raw) <- c("frota_orig", "01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12")

  raw %>%
    # Remove linhas onde o nome da frota está vazio
    filter(!is.na(frota_orig)) %>%
    pivot_longer(-frota_orig, names_to = "mes_num", values_to = "valor") %>%
    mutate(
      ano = ano,
      indicador = nome_valor,
      data = make_date(ano, as.numeric(mes_num), 1),
      # Força numérico e trata lixo de texto como NA
      valor = as.numeric(as.character(valor))
    ) %>%
    filter(!is.na(valor)) %>%
    select(data, frota_orig, indicador, valor)
}

# --- 3. PROCESSAMENTO ANO A ANO ---
message("Processando 2021...")
df_2021 <- bind_rows(
  ler_range(path_2021, "B6:N12",    "num_caminhoes_plan", 2021),
  ler_range(path_2021, "B48:N54",   "HT_plan", 2021),
  ler_range(path_2021, "B255:N263", "HM_plan", 2021),
  ler_range(path_2021, "B235:N242", "HC_plan", 2021),
  ler_range(path_2021, "B60:N66",   "producao_plan", 2021),
  ler_range(path_2021, "AG69:AS75", "dmt_plan", 2021)
)

message("Processando 2022...")
df_2022 <- bind_rows(
  ler_range(path_2022, "B6:N12",    "num_caminhoes_plan", 2022),
  ler_range(path_2022, "B48:N54",   "HT_plan", 2022),
  ler_range(path_2022, "B255:N263", "HM_plan", 2022),
  ler_range(path_2022, "B235:N242", "HC_plan", 2022),
  ler_range(path_2022, "B60:N66",   "producao_plan", 2022),
  ler_range(path_2022, "AG69:AS75", "dmt_plan", 2022)
)

message("Processando 2023...")
df_2023 <- bind_rows(
  ler_range(path_2023, "B6:N12",    "num_caminhoes_plan", 2023),
  ler_range(path_2023, "B48:N54",   "HT_plan", 2023),
  ler_range(path_2023, "B253:N259", "HM_plan", 2023),
  ler_range(path_2023, "B235:N241", "HC_plan", 2023),
  ler_range(path_2023, "B60:N66",   "producao_plan", 2023),
  ler_range(path_2023, "AG69:AS75", "dmt_plan", 2023)
)

# --- 4. CONSOLIDAÇÃO E PIVOTAGEM ---
set.seed(999)

dados_totais <- bind_rows(df_2021, df_2022, df_2023)

plan_budget_assumptions_sn <- dados_totais %>%
  # A. PADRONIZAÇÃO DE NOMES (Mais permissiva)
  mutate(
    frota_limpa = case_when(
      str_detect(frota_orig, "797") ~ "CAT 797F",
      str_detect(frota_orig, "793") ~ "CAT 793D",
      str_detect(frota_orig, "930") ~ "Komatsu 930E",
      str_detect(frota_orig, "830") ~ "Komatsu 830E",
      str_detect(frota_orig, "794") ~ "CAT 794AC",
      # Se não reconhecer, mantem o original para não perder dados no filtro
      TRUE ~ frota_orig
    )
  ) %>%

  # Agrupa para somar duplicatas (caso existam)
  group_by(data, frota_limpa, indicador) %>%
  summarise(valor = sum(valor, na.rm = TRUE), .groups = "drop") %>%

  # B. PIVOTAGEM (Cria as colunas hc_plan, hm_plan, etc.)
  pivot_wider(
    names_from = indicador,
    values_from = valor,
    values_fill = 0
  ) %>%
  clean_names()

# --- 4.5 GARANTIA DE COLUNAS ---
# Se alguma coluna não foi criada (porque estava vazia no Excel), cria ela com 0
cols_necessarias <- c("hc_plan", "hm_plan", "ht_plan", "producao_plan", "num_caminhoes_plan", "dmt_plan")
for(col in cols_necessarias) {
  if(!col %in% names(plan_budget_assumptions_sn)) {
    plan_budget_assumptions_sn[[col]] <- 0
    warning(paste("Coluna", col, "não encontrada nos dados brutos. Preenchida com 0."))
  }
}

# --- 5. CÁLCULOS FINAIS ---
plan_budget_assumptions_sn <- plan_budget_assumptions_sn %>%
  mutate(
    # Cálculos
    DF_plan = ifelse(hc_plan > 0, (hc_plan - hm_plan) / hc_plan * 100, 0),
    produtividade_plan = ifelse(ht_plan > 0, producao_plan / ht_plan, 0)
  ) %>%

  # Filtro Final: Só mantem linhas que parecem ser de frota válida (tem disponibilidade calculada)
  filter(hc_plan > 0) %>%

  # Anonimização
  mutate(
    unidade = "Mina A",
    id_frota = paste0("FROTA-", sprintf("%02d", as.numeric(as.factor(frota_limpa)))),

    data = data - years(1),

    across(where(is.numeric), ~ round(.x * runif(n(), 0.99, 1.01), 2))
  ) %>%

  select(data, id_frota, everything(), -frota_limpa)

# --- 6. SALVAR ---
if (nrow(plan_budget_assumptions_sn) > 0) {
  glimpse(plan_budget_assumptions_sn)
  usethis::use_data(plan_budget_assumptions_sn, overwrite = TRUE)
  fs::dir_create("inst/extdata")
  write_csv(plan_budget_assumptions_sn, "inst/extdata/plan_budget_assumptions_sn.csv")
  message("Dataset 'plan_budget_assumptions_sn' processado com sucesso!")
} else {
  warning("O dataset final ficou vazio. Verifique os ranges do Excel.")
}
