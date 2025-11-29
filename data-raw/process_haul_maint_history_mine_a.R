## data-raw/process_haul_maint_history_sn.R

library(tidyverse)
library(lubridate)
library(janitor)
library(fs)
library(usethis)

# --- 1. CONFIGURAÇÃO ---
caminho_real <- "K:/Meu Drive/Dados_Confidenciais/data_maintenance.Rdata"

if (!file.exists(caminho_real)) {
  stop("Arquivo data_maintenance.Rdata não encontrado!")
}

# --- 2. LEITURA ---
message("Carregando histórico rico de manutenção...")
load(caminho_real)

if (!exists("data_maintenance")) stop("Objeto 'data_maintenance' não encontrado.")

# --- DIAGNÓSTICO (Para você ver no console) ---
message("Grupos encontrados no banco:")
print(unique(data_maintenance$group))

message("Total de linhas originais: ", nrow(data_maintenance))

# --- 3. TRATAMENTO ---
set.seed(2025)

haul_maint_history_sn <- data_maintenance %>%
  ungroup() %>% # Garante que não há agrupamentos residuais
  as_tibble() %>%
  clean_names() %>%

  # A. FILTRO DE ESCOPO (Mais robusto)
  # Usa (?i) para ignorar maiúsculas/minúsculas e aceita "Caminha" para pegar com/sem til
  filter(str_detect(group, "(?i)caminh")) %>%

  # B. PREPARAÇÃO DE COLUNAS
  mutate(
    # Datas (Garante formato)
    inicio = as_datetime(time_in),
    fim = as_datetime(time_end),
    duracao_h = as.numeric(time_gap),

    # Preventivas (MP) - Tratamento de NAs e Texto
    # Se MP for texto ("250 h"), extrai só números. Se for NA, vira NA.
    mp_limpo = str_extract(as.character(mp), "[0-9]+"),
    mp_intervalo = as.numeric(mp_limpo),
    is_preventiva = !is.na(mp_intervalo),

    # Correção de Typos (soluction -> solucao)
    # Verifica se a coluna 'soluction' existe, senão busca 'solucao' ou cria NA
    solucao_final = if("soluction" %in% names(.)) soluction else if("solucao" %in% names(.)) solucao else NA_character_
  ) %>%

  # C. SELEÇÃO E TRADUÇÃO
  transmute(
    unidade = "Mina A",
    id_equipamento_real = equipment,

    # Datas
    data_inicio = as.Date(inicio),
    inicio, fim, duracao_h,

    # Ordem
    num_ordem = om,
    tipo_ordem = type,
    status_ordem = status,

    # Datas de Gestão (Se existirem)
    previsao = tryCatch(as_datetime(forecast), error = function(e) NA),
    atualizacao = tryCatch(as_datetime(update), error = function(e) NA),

    # Classificação
    categoria = category,
    mp_intervalo,
    is_preventiva,

    # Taxonomia
    sistema = system,
    conjunto = set,
    item = item,

    # Texto
    descricao = description,
    problema = problem,
    solucao = solucao_final,
    comentario = comment,
    localizacao = location
  ) %>%

  # D. ANONIMIZAÇÃO
  mutate(
    # Mascarar Equipamento (HAUL-XXXX)
    id_equipamento = paste0("HAUL-", sprintf("%04d", as.numeric(as.factor(id_equipamento_real)))),

    # Deslocar Datas (-1 ano)
    inicio = inicio - years(1),
    fim = fim - years(1),
    data_inicio = data_inicio - years(1),
    previsao = previsao - years(1),
    atualizacao = atualizacao - years(1),

    # Perturbação numérica
    duracao_h = round(duracao_h * runif(n(), 0.99, 1.01), 2),

    # Limpeza de Texto
    problema = str_to_title(str_squish(problema)),
    solucao = str_to_title(str_squish(solucao)),
    comentario = str_trunc(str_squish(comentario), 250)
  ) %>%

  select(-id_equipamento_real) %>%

  # Filtro final: Garante que gerou ID e tem duração válida
  filter(!is.na(id_equipamento))

# --- 4. VALIDAÇÃO ---
message("Linhas finais processadas: ", nrow(haul_maint_history_sn))
glimpse(haul_maint_history_sn)

# --- 5. SALVAR ---
usethis::use_data(haul_maint_history_sn, overwrite = TRUE)
fs::dir_create("inst/extdata")
write_csv(head(haul_maint_history_sn, 10000), "inst/extdata/haul_maint_history_sn.csv")

message("Dataset 'haul_maint_history_sn' processado!")
