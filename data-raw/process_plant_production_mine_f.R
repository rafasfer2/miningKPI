library(tidyverse)
library(janitor)
library(lubridate)
library(usethis)

# --- 1. CONFIGURAÇÃO DO CAMINHO ---
caminho_taxa <- "L:/Meu Drive/Dados_Confidenciais/data_salobo_taxa.Rdata"

if (!file.exists(caminho_taxa)) {
  stop("ERRO: Arquivo não encontrado em: ", caminho_taxa)
}

message("=== CARREGANDO TAXAS DE PRODUÇÃO: SALOBO (MINA F) ===")

# --- 2. CARREGAMENTO ---
env_taxa <- new.env()
load(caminho_taxa, envir = env_taxa)
data_salobo_taxa_raw <- env_taxa$data_salobo_taxa

# --- 3. PROCESSAMENTO CORRIGIDO ---
plant_production_mine_f <- data_salobo_taxa_raw %>%
  as_tibble() %>%
  clean_names() %>%

  # A. Harmonização de Identidade e Tempo
  mutate(
    mina_id = "Mina F",
    commodity = "Cobre",
    data_ref = as_date(inicio), # Nota: clean_names transformou 'Início' em 'inicio'
    inicio = as_datetime(inicio),
    fim = as_datetime(fim),

    # ID de Equipamento anonimizado (FDR = Feeder/Alimentador)
    id_equipamento = paste0("FDR-F-", as.numeric(as.factor(equipment)))
  ) %>%

  # B. Tratamento de Strings (Nomes corrigidos conforme seu glimpse)
  mutate(
    subprocesso = str_to_title(subprocess), # De 'subprocess' para 'subprocesso'
    material = str_to_upper(material),
    origem = str_to_title(origem),
    destino = str_to_title(destino)
  ) %>%

  # C. Seleção do Schema Final
  transmute(
    mina_id,
    commodity,
    data_ref,
    inicio,
    fim,
    turno,
    subprocesso,
    id_equipamento,
    origem,
    destino,
    material,
    tonelagem = ton,
    status_validacao = status
  ) %>%
  arrange(inicio)

# --- 4. SALVAMENTO ---
usethis::use_data(plant_production_mine_f, overwrite = TRUE, compress = "xz")
message("✅ Dataset 'plant_production_mine_f' consolidado e salvo!")
