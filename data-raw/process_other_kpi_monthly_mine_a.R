## data-raw/process_other_kpi_monthly_sn.R

library(tidyverse)
library(lubridate)
library(janitor)
library(fs)
library(usethis)
library(tsibble)

# --- 1. CONFIGURAÇÃO ---
caminho_real <- "L:/Meu Drive/Dados_Confidenciais/data_requipam.Rdata"

if (!file.exists(caminho_real)) {
  stop("Arquivo data_requipam.Rdata não encontrado!")
}

# --- 2. LEITURA ---
message("Carregando base completa Requipam...")
load(caminho_real)

if (!exists("data_requipam")) stop("Objeto 'data_requipam' não encontrado.")

# --- 3. FUNÇÃO DE PROCESSAMENTO PADRÃO ---
processar_kpi_mensal <- function(df_completo, grupo_filtro, nome_dataset, prefixo_id) {

  message(paste("Processando", nome_dataset, "..."))

  df_final <- df_completo %>%
    ungroup() %>%
    as_tibble() %>%
    clean_names() %>%

    # Filtro do Grupo
    filter(str_detect(group, grupo_filtro)) %>%

    # Seleção e Tradução
    transmute(
      data = as.Date(month),
      id_equipamento_real = equipment,
      modelo = model,

      # KPIs Principais
      DF = df,
      UF = uf,
      MTBF = tryCatch(mtbf, error = function(e) NA),
      MTTR = tryCatch(mttr, error = function(e) NA),
      num_falhas = nic,

      # Produção (Se houver)
      producao_total = mt,
      produtividade = pr,

      # Horas
      HC = hc, HM = hm,
      HMC = hmc,
      HMP = tryCatch(hmp, error = function(e) mps + mpns), # Tratamento de erro HMP
      HT = ht, HEF = hef
    ) %>%

    # Anonimização
    mutate(
      id_equipamento = paste0(prefixo_id, "-", sprintf("%03d", as.numeric(as.factor(id_equipamento_real)))),
      data = data - years(1),

      # Perturbação (+- 1%)
      across(where(is.numeric), ~ round(.x * runif(n(), 0.99, 1.01), 2))
    ) %>%

    select(data, id_equipamento, everything(), -id_equipamento_real) %>%
    filter(HC > 0)

  # Salvar
  assign(nome_dataset, df_final)
  do.call("use_data", list(as.name(nome_dataset), overwrite = TRUE))

  # CSV
  fs::dir_create("inst/extdata")
  write_csv(df_final, paste0("inst/extdata/", nome_dataset, ".csv"))

  message(paste("✅", nome_dataset, "salvo."))
}

# --- 4. EXECUÇÃO EM LOTE ---

# A. PERFURAÇÃO (Drill)
processar_kpi_mensal(data_requipam, "Perfuratriz", "drill_kpi_monthly_sn", "DRILL")

# B. CARGA (Load) - Escavadeira + Pá Mecânica
processar_kpi_mensal(data_requipam, "Escavadeira|Pa Mecanica", "load_kpi_monthly_sn", "LOAD")

# C. INFRAESTRUTURA (Infra) - Trator + Patrol
processar_kpi_mensal(data_requipam, "Trator|Patrol", "infra_kpi_monthly_sn", "INFRA")

message("🚀 Todos os KPIs mensais de Serra Norte foram processados!")
