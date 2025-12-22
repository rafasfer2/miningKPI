library(tidyverse)
library(janitor)
library(usethis)

# --- 1. CONFIGURAÇÃO DO CAMINHO CORRETO ---
caminho_confidencial <- "L:/Meu Drive/Dados_Confidenciais/data_subprocess_for_event_cleaner.Rdata"

if (!file.exists(caminho_confidencial)) {
  stop("ERRO: O arquivo 'data_subprocess_for_event_cleaner.Rdata' não foi encontrado no caminho especificado.")
}

message("=== CARREGANDO DADOS CONFIDENCIAIS: SALOBO (MINA F) ===")

# --- 2. CARREGAMENTO ---
# Criamos um ambiente temporário para evitar conflitos de nomes no Global Environment
env_subprocess <- new.env()
load(caminho_confidencial, envir = env_subprocess)

# Captura o objeto (data_subprocess_for_event_cleaner)
# Usamos o nome que você confirmou no glimpse anterior
data_subprocess_raw <- env_subprocess$data_subprocess_for_event_cleaner

# --- 3. PROCESSAMENTO PARA O PACOTE ---
plant_detailed_mine_f <- data_subprocess_raw %>%
  ungroup() %>%
  as_tibble() %>%
  clean_names() %>%
  # Mantendo a lógica de harmonização que definimos
  mutate(
    diretoria = replace_na(diretoria, "Metais Básicos"),
    complexo = replace_na(complexo, "Metais Básicos Sistema 3"),
    unidade_operacional = replace_na(unidade_operacional, "Salobo"),
    fase = replace_na(fase, "Beneficiamento"),
    commodity = "Cobre"
  )

# ... (restante do código de transmute e anonimização enviado anteriormente)

# --- 4. SALVAR NO PACOTE ---
usethis::use_data(plant_detailed_mine_f, overwrite = TRUE, compress = "xz")
message("✅ Dataset 'plant_detailed_mine_f' atualizado a partir da fonte correta!")
