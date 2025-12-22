## data-raw/process_haul_daily_cep_br.R

library(tidyverse)
library(readxl)
library(janitor)
library(lubridate)
library(usethis)

# --- 1. CONFIGURAÇÃO ---
# Alterado para facilitar portabilidade entre máquinas
caminho_real <- "L:/Meu Drive/Dados_Confidenciais/frota_transporte_cep_2021.xlsx"

if (!file.exists(caminho_real)) {
  stop("Arquivo de transporte CEP não encontrado!")
}

# --- 2. LEITURA ---
dados_brutos <- read_excel(caminho_real) %>% clean_names()

# --- 3. LIMPEZA E ENGENHARIA REVERSA ---
set.seed(777)

haul_daily_cep_mine_b <- dados_brutos %>% # Ajustado para seu padrão de nome: mine_b
  # Ordenação prévia para garantir anonimização consistente
  arrange(data, frota) %>%

  mutate(
    data = as.Date(data),
    turno = as.numeric(id_turno),

    # Tratamento de Inputs
    hao_input  = coalesce(hao, 0),
    htnp_input = coalesce(htnp_hora_trabalhada_nao_produtiva, 0),
    viagens_val = pmax(coalesce(viagens_validas, 0), 1), # Evita divisão por zero

    # Velocidades e Distâncias
    vel_cheio = ifelse(coalesce(vel_cheio, 0) <= 0, 20, vel_cheio), # Default técnico
    vel_vazio = ifelse(coalesce(vel_vazio, 0) <= 0, 25, vel_vazio),
    relacao_km = coalesce(relacao_km_cheio_km_vazio, 1)
  ) %>%

  # --- CÁLCULOS GPV-M ---
  mutate(
    HC_calc = 6,
    HD_calc = (df / 100) * HC_calc,
    HM_calc = HC_calc - HD_calc,
    HT_calc = (uf / 100) * HD_calc,
    HO_calc = pmax(HD_calc - HT_calc, 0),

    # Hierarquia de Horas (Travas de Segurança)
    HTNP_final = pmin(htnp_input, HT_calc),
    HTP_calc   = pmax(HT_calc - HTNP_final, 0),
    HAO_final  = pmin(hao_input, HTP_calc),
    HEF_calc   = pmax(HTP_calc - HAO_final, 0),

    # Produção e TKPH
    producao_calc = produtividade * HT_calc,
    tkph_calc     = (producao_calc * dmt) / pmax(HT_calc, 0.1),

    # Reconstrução do Ciclo (TTC)
    tvc_min = (dmt / vel_cheio) * 60,
    tvv_min = ((dmt / relacao_km) / vel_vazio) * 60,
    tempo_fixo_calc = fila_carga + manobra + carregamento + fila_basculo + basculamento,
    ttc_min = tempo_fixo_calc + coalesce(tvc_min, 0) + coalesce(tvv_min, 0)
  ) %>%

  # --- MAPEAMENTO E ANONIMIZAÇÃO ---
  transmute(
    data = data - years(2), # Deslocamento temporal
    turno,
    id_equipamento = paste0("HAUL-", as.numeric(as.factor(frota))), # ID consistente

    # KPIs
    DF = df, UF = uf,
    produtividade_ht = produtividade,
    tkph = tkph_calc,

    # Operacional
    producao_total = producao_calc,
    num_viagens = viagens_validas,
    dmt,

    # Tempos (Minutos)
    tempo_ciclo_total = ttc_min,
    tempo_fixo = tempo_fixo_calc,
    tempo_viagem_cheio = tvc_min,
    tempo_viagem_vazio = tvv_min,

    # Árvore de Horas Final
    HC = HC_calc, HM = HM_calc, HD = HD_calc, HO = HO_calc, HT = HT_calc,
    HTP = HTP_calc, HTNP = HTNP_final, HEF = HEF_calc, HAO = HAO_final
  ) %>%

  # Perturbação estatística para proteção de dados reais
  mutate(across(where(is.numeric), ~ .x * runif(n(), 0.98, 1.02))) %>%
  mutate(across(where(is.numeric), ~ round(.x, 2))) %>%
  filter(HC > 0)

# --- 4. EXPORTAÇÃO ---
usethis::use_data(haul_daily_cep_mine_b, overwrite = TRUE)

# Salvar CSV para interoperabilidade (opcional)
if(!dir.exists("inst/extdata")) dir.create("inst/extdata", recursive = TRUE)
write_csv(haul_daily_cep_mine_b, "inst/extdata/haul_daily_cep_mine_b.csv")

message("Dataset processado com sucesso!")
