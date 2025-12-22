library(tidyverse)
library(lubridate)
library(janitor)
library(usethis)

# --- 1. CONFIGURAÇÃO ---
# Ajuste o nome do arquivo se necessário
caminho_real <- "L:/Meu Drive/Dados_Confidenciais/data_gpv.Rdata"

if (!file.exists(caminho_real)) {
  stop("Arquivo data_gpv.Rdata não encontrado!")
}

message("=== PROCESSANDO MINA E (S11D - USINA/PÁTIO) ===")
message("Carregando arquivo (2.5M linhas)... isso pode levar um tempo.")

# Carrega o objeto (assumindo que se chama 'data_gpv' lá dentro)
env_temp <- new.env()
load(caminho_real, envir = env_temp)
data_gpv <- get(ls(env_temp)[1], envir = env_temp) # Pega o primeiro objeto

# --- 2. TRATAMENTO ---
plant_event_log_mine_e <- data_gpv %>%
  as_tibble() %>%
  clean_names() %>%

  # A. Filtros Básicos
  filter(!is.na(inicio), !is.na(fim)) %>%

  # B. Anonimização Inteligente (Máquinas de Pátio)
  mutate(
    mina_id = "Mina E",

    # Identificar tipo de equipamento pelo prefixo original (EGP)
    # EP = Empilhadeira, RC = Recuperadora, CN = Carregador Navio (hipótese), TR = Correia
    tipo_ativo = case_when(
      str_detect(egp, "^EP") ~ "Empilhadeira",
      str_detect(egp, "^RC") ~ "Recuperadora",
      str_detect(egp, "^ER") ~ "Empilhadeira-Recuperadora",
      str_detect(egp, "^TR") ~ "Correia Transportadora",
      TRUE ~ "Outros"
    ),

    # Criar ID Anonimizado (Ex: STK-E-01)
    id_equipamento = paste0(
      case_when(
        tipo_ativo == "Empilhadeira" ~ "STK-", # Stacker
        tipo_ativo == "Recuperadora" ~ "RCL-", # Reclaimer
        tipo_ativo == "Empilhadeira-Recuperadora" ~ "SRC-",
        tipo_ativo == "Correia Transportadora" ~ "CNV-",
        TRUE ~ "EQP-"
      ),
      "E-",
      as.numeric(as.factor(egp))
    ),

    # Datas e Duração
    inicio = as_datetime(inicio),
    fim = as_datetime(fim),
    duracao_h = as.numeric(duracao),

    # Tratamento de Strings
    sistema = str_to_title(sistema_produtivo),
    subprocesso = str_to_title(subprocesso),
    descricao_evento = str_to_sentence(descricao_do_evento),

    # Extração de KPI (HOI, HMC...)
    categoria_kpi = str_extract(categoria_de_horas, "^[A-Z]{3}"),

    # Causalidade
    causa_basica = causa,
    tipo_falha = falha,

    # Observações (limitar tamanho para não inflar o pacote)
    observacao = str_trunc(str_squish(observacao), 100)
  ) %>%

  # C. Seleção Final
  transmute(
    mina_id,
    data_ref = as_date(inicio),
    sistema,
    subprocesso,
    tipo_ativo,
    id_equipamento,
    inicio,
    fim,
    duracao_h,
    descricao_evento,
    categoria_kpi,
    causa_basica,
    tipo_falha,
    observacao
  ) %>%

  # Ordenação
  arrange(inicio)

# --- 3. SALVAR ---
# Como é muito grande, vamos salvar com compressão máxima 'xz' para o pacote não explodir
usethis::use_data(plant_event_log_mine_e, overwrite = TRUE, compress = "xz")
message("✅ Dataset 'plant_event_log_mine_e' salvo! Linhas: ", nrow(plant_event_log_mine_e))
