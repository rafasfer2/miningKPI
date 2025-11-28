## data-raw/process_cep_data.R

library(tidyverse)
library(readxl)
library(janitor)
library(fs)
library(usethis)

# --- 1. CONFIGURAÇÃO ---
path_carga <- "K:/Meu Drive/Dados_Confidenciais/frota_carga_cep_2021.xlsx"
path_transporte <- "K:/Meu Drive/Dados_Confidenciais/frota_transporte_cep_2021.xlsx"

if (!file.exists(path_carga) | !file.exists(path_transporte)) {
  stop("Arquivos de CEP não encontrados! Verifique os nomes na pasta.")
}

# --- 2. PROCESSAMENTO: CARGA (Escavadeiras) ---
message("Processando CEP Carga...")
dados_carga <- read_excel(path_carga, sheet = "dados") %>%
  clean_names()

# Tratamento do HAO Climático (Se existir)
has_hao <- "HAO" %in% excel_sheets(path_carga)
if (has_hao) {
  dados_hao <- read_excel(path_carga, sheet = "HAO") %>%
    clean_names() %>%
    pivot_longer(cols = starts_with("x"), names_to = "turno", names_prefix = "x", values_to = "hao_real") %>%
    mutate(turno = as.numeric(turno), data = as.Date(data)) %>%
    select(data, frota, turno, periodo_climatico = periodo, hao_real)

  dados_carga <- dados_carga %>%
    mutate(data = as.Date(data), turno = as.numeric(id_turno)) %>%
    left_join(dados_hao, by = c("data", "frota", "turno"))
} else {
  dados_carga <- dados_carga %>% mutate(periodo_climatico = NA_character_, hao_real = NA_real_)
}

load_daily_cep_br <- dados_carga %>%
  transmute(
    data = as.Date(data),
    turno = as.numeric(id_turno),
    id_equipamento_real = frota,
    periodo_climatico,

    # KPIs
    DF = df, UF = uf,
    produtividade = produtividade,

    # CORREÇÃO AQUI: Calculamos a produção em vez de buscar a coluna
    # Produção = Produtividade * HEF
    producao_total = as.numeric(produtividade) * as.numeric(hef),

    # Tempos
    tempo_carregamento = carregamento,
    tempo_manobra = manobra,

    # Horas
    # HAO estimado ou real
    HAO = coalesce(hao_real, (htnp / ifelse(viagens_validas==0, 1, viagens_validas)) * 60)
  ) %>%

  # Anonimização
  mutate(
    id_equipamento = paste0("LOAD-", sprintf("%03d", as.numeric(as.factor(id_equipamento_real)))),
    data = data - years(2),

    # Perturbação
    across(where(is.numeric), ~ round(.x * runif(n(), 0.99, 1.01), 2))
  ) %>%
  select(-id_equipamento_real) %>%
  filter(!is.na(DF))

# Salvar Carga
usethis::use_data(load_daily_cep_br, overwrite = TRUE)
write_csv(load_daily_cep_br, "inst/extdata/load_daily_cep_br.csv")


# --- 3. PROCESSAMENTO: TRANSPORTE (Caminhões) ---
message("Processando CEP Transporte...")
dados_transporte <- read_excel(path_transporte) %>% clean_names()

haul_daily_cep_br <- dados_transporte %>%
  transmute(
    data = as.Date(data),
    turno = id_turno,
    id_equipamento_real = frota,

    DF = df, UF = uf,
    produtividade = produtividade,

    # Para transporte, calculamos produção via Carga Média * Viagens (se disponível) ou deixamos NA se não tiver HEF
    # Como seu arquivo de transporte não listou HEF, vamos usar CargaMedia * Viagens se possível
    producao_total = if("carga_media" %in% names(.) & "viagens_validas" %in% names(.)) carga_media * viagens_validas else NA_real_,

    # KPIs Específicos
    dmt = dmt,
    vel_global = vel_global,

    # Tratamento de erro caso a coluna não exista
    tempo_ciclo = tryCatch(tempo_ciclo, error = function(e) NA),
    tempo_fila_carga = fila_carga,

    HAO = hao
  ) %>%

  # Anonimização
  mutate(
    id_equipamento = paste0("HAUL-", sprintf("%03d", as.numeric(as.factor(id_equipamento_real)))),
    data = data - years(2),
    across(where(is.numeric), ~ round(.x * runif(n(), 0.99, 1.01), 2))
  ) %>%
  select(-id_equipamento_real) %>%
  filter(!is.na(DF))

# Salvar Transporte
usethis::use_data(haul_daily_cep_br, overwrite = TRUE)
write_csv(haul_daily_cep_br, "inst/extdata/haul_daily_cep_br.csv")

message("✅ Datasets de CEP (Carga e Transporte) processados!")
