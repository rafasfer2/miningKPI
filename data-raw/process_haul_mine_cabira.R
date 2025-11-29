## data-raw/process_haul_itabira.R

library(tidyverse)
library(readxl)
library(janitor)
library(fs)
library(lubridate)
library(usethis)

# --- 1. CONFIGURAÇÃO ---
caminho_real <- "K:/Meu Drive/Dados_Confidenciais/historico_frota_itabira_2020_2022.xlsx"

if (!file.exists(caminho_real)) {
  stop("Arquivo Itabira não encontrado!")
}

set.seed(31) # DDD de Itabira

# ==============================================================================
# PARTE A: DADOS REALIZADOS (HISTÓRICO)
# ==============================================================================
message("Processando Realizado (2020-2022)...")

abas_real <- c("Real 2020", "Real 2021", "Real 2022")

# Função para ler e limpar cada aba
ler_aba_real <- function(aba) {
  read_excel(caminho_real, sheet = aba) %>%
    clean_names() %>%
    mutate(origem_ano = aba)
}

# Empilhar tudo
dados_real_brutos <- map_df(abas_real, ler_aba_real)

haul_daily_summary_it <- dados_real_brutos %>%
  mutate(
    data = as.Date(data),

    # Tratamento de Nulos
    hao_val  = coalesce(hao_hora_de_atraso_operacional, 0),
    htnp_val = coalesce(htnp_hora_trabalhada_nao_produtiva, 0),
    viagens_val = ifelse(coalesce(viagens_validas, 0) == 0, 1, viagens_validas)
  ) %>%

  # --- CÁLCULOS GPV-M (Blindagem Matemática) ---
  mutate(
    HC_calc = 6, # Turno fixo

    # Disponibilidade e Utilização
    HD_calc = (df / 100) * HC_calc,
    HM_calc = HC_calc - HD_calc,
    HT_calc = (uf / 100) * HD_calc,
    HO_calc = HD_calc - HT_calc,

    # Árvore de Perdas
    HTNP_final = pmin(htnp_val, HT_calc),
    HTP_calc = HT_calc - HTNP_final,

    HAO_final = pmin(hao_val, HTP_calc),
    HEF_calc = HTP_calc - HAO_final,

    # Produção (Fórmula: Carga Média * Viagens é mais segura que Produtividade inversa)
    producao_calc = carga_media * viagens_val,
    produtividade_ht = ifelse(HT_calc > 0, producao_calc / HT_calc, 0)
  ) %>%

  # --- SELEÇÃO ---
  transmute(
    unidade = "Mina C", # Itabira
    data,
    id_equipamento_real = equipamento,

    # KPIs
    DF = df, UF = uf,
    produtividade_ht,
    producao_total = producao_calc,
    num_viagens = viagens_validas,
    dmt = dmt,

    # Horas
    HC = HC_calc, HM = HM_calc, HD = HD_calc, HO = HO_calc, HT = HT_calc,
    HTP = HTP_calc, HTNP = HTNP_final, HEF = HEF_calc, HAO = HAO_final,

    # Velocidades (Se existirem, senão NA)
    vel_media = tryCatch(vel_med, error = function(e) NA)
  ) %>%

  # --- ANONIMIZAÇÃO ---
  mutate(
    id_equipamento = paste0("TR-IT-", sprintf("%03d", as.numeric(as.factor(id_equipamento_real)))),
    # Deslocar datas (-1 ano para não bater com dados atuais)
    data = data - years(1),

    # Perturbação
    across(where(is.numeric), ~ round(.x * runif(n(), 0.99, 1.01), 2))
  ) %>%
  select(-id_equipamento_real) %>%
  filter(HC > 0)

# Salvar Realizado
usethis::use_data(haul_daily_summary_it, overwrite = TRUE)
fs::dir_create("inst/extdata")
write_csv(haul_daily_summary_it, "inst/extdata/haul_daily_summary_it.csv")


# ==============================================================================
# PARTE B: DADOS PLANEJADOS (METAS)
# ==============================================================================
message("Processando Metas (2020-2022)...")

abas_meta <- c("Meta_2020", "Meta_2021", "Meta_2022")

ler_aba_meta <- function(aba) {
  read_excel(caminho_real, sheet = aba) %>%
    clean_names() %>%
    mutate(origem_ano = aba)
}

dados_meta_brutos <- map_df(abas_meta, ler_aba_meta)

plan_daily_budget_it <- dados_meta_brutos %>%
  transmute(
    unidade = "Mina C",
    data = as.Date(dia), # Coluna original é "Dia"

    # Metas (Sufixo _plan)
    DF_plan = df,
    UF_plan = uf,
    produtividade_plan = pr, # PR = Produtividade Realizada (Meta)

    producao_plan = tm,      # TM = Toneladas Movimentadas (Meta)
    num_viagens_plan = nc,   # NC = Número de Ciclos
    carga_media_plan = cmt,  # CMT = Carga Média
    dmt_plan = dmt,

    num_caminhoes_plan = ntrucks,

    # Horas Planejadas
    HC_plan = hc,
    HD_plan = hd,
    HT_plan = ht,
    HM_plan = hm,
    HO_plan = ho
  ) %>%

  # Anonimização
  mutate(
    data = data - years(1),
    across(where(is.numeric), ~ round(.x * runif(n(), 0.99, 1.01), 2))
  ) %>%
  filter(!is.na(DF_plan))

# Salvar Planejado
usethis::use_data(plan_daily_budget_it, overwrite = TRUE)
write_csv(plan_daily_budget_it, "inst/extdata/plan_daily_budget_it.csv")

message("✅ Dados de Itabira (Real + Meta) processados!")
