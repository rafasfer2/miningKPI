library(tidyverse)
library(readxl)
library(janitor)
library(usethis)

# --- 1. CONFIGURAÇÃO DO CAMINHO ---
caminho_base <- "L:/Meu Drive/Dados_Confidenciais/"
caminho_excel_taxa <- paste0(caminho_base, "data_salobo_taxa.xlsx")

if (!file.exists(caminho_excel_taxa)) {
  stop("ERRO: O arquivo Excel não foi encontrado em: ", caminho_excel_taxa)
}

message("=== EXTRAINDO DADOS BRUTOS DA PILHA PULMÃO (SALOBO) ===")

# --- 2. LEITURA DAS DUAS PRIMEIRAS COLUNAS (SHEET 2) ---
# Lendo apenas subday e nivel conforme sua instrução
inventory_raw_mine_f <- read_excel(
  caminho_excel_taxa,
  sheet = 2
) %>%
  # Selecionando as duas primeiras colunas (subday e o nível)
  # Usando select(1:2) para garantir que pegamos exatamente as duas primeiras
  select(1:2) %>%
  clean_names() %>%

  # A. Ajuste de Tipagem e Identidade
  mutate(
    mina_id = "Mina F",
    localizacao = "Pilha Pulmão - Circuito Singelo",
    # Renomeando para nomes claros dentro do pacote
    timestamp = subday,
    nivel_percentual = nivel # Ou o nome que o janitor der à segunda coluna
  ) %>%

  # B. Seleção Final
  select(mina_id, localizacao, timestamp, nivel_percentual) %>%
  filter(!is.na(timestamp)) %>%
  arrange(timestamp)

# --- 3. SALVAMENTO ---
usethis::use_data(inventory_raw_mine_f, overwrite = TRUE, compress = "xz")
message("✅ Dados brutos da pilha 'inventory_raw_mine_f' salvos com sucesso!")
