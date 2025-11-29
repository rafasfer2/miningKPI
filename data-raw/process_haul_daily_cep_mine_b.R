## data-raw/process_haul_daily_cep_br.R

library(tidyverse)
library(readxl)
library(janitor)
library(fs)
library(lubridate)
library(usethis)

# --- 1. CONFIGURAÇÃO ---
caminho_real <- "K:/Meu Drive/Dados_Confidenciais/frota_transporte_cep_2021.xlsx"

if (!file.exists(caminho_real)) {
  stop("Arquivo de transporte CEP não encontrado! Verifique o nome.")
}

# --- 2. LEITURA ---
dados_brutos <- read_excel(caminho_real)

# --- 3. LIMPEZA E CÁLCULOS (PADRÃO GPV-M BLINDADO) ---
set.seed(777)

haul_daily_cep_br <- dados_brutos %>%
  clean_names() %>%

  # Preparação de NAs e Zeros
  mutate(
    data = as.Date(data),
    turno = as.numeric(id_turno),

    # Tratamento de colunas que podem vir zeradas ou nulas
    hao_input  = coalesce(hao, 0),
    htnp_input = coalesce(htnp_hora_trabalhada_nao_produtiva, 0),
    viagens_val = ifelse(coalesce(viagens_validas, 0) == 0, 1, viagens_validas),

    # Velocidades (Evitar divisão por zero na engenharia reversa)
    vel_cheio = ifelse(coalesce(vel_cheio, 0) <= 0, NA, vel_cheio),
    vel_vazio = ifelse(coalesce(vel_vazio, 0) <= 0, NA, vel_vazio),
    relacao_km = coalesce(relacao_km_cheio_km_vazio, 1)
  ) %>%

  # --- CÁLCULOS DE ENGENHARIA ---
  mutate(
    # 1. Base (Turno de 6h)
    HC_calc = 6,

    # 2. Disponibilidade (HD) e Manutenção (HM)
    HD_calc = (df / 100) * HC_calc,
    HM_calc = HC_calc - HD_calc,

    # 3. Utilização (HT) e Ociosidade (HO)
    HT_calc = (uf / 100) * HD_calc,
    HO_calc = HD_calc - HT_calc,

    # 4. Detalhamento HT (Produtiva vs. Não Produtiva)
    # HT = HTP + HTNP
    # TRAVA 1: HTNP não pode ser maior que o tempo trabalhado total
    HTNP_final = pmin(htnp_input, HT_calc),
    HTP_calc = HT_calc - HTNP_final,

    # 5. Detalhamento HTP (Efetiva vs. Atraso)
    # HTP = HEF + HAO
    # TRAVA 2: HAO não pode ser maior que o tempo produtivo disponível
    HAO_final = pmin(hao_input, HTP_calc),
    HEF_calc = HTP_calc - HAO_final,

    # 6. Produção e Carga
    # Produção = Produtividade * HT
    producao_calc = produtividade * HT_calc,

    # Carga Média Recalculada
    carga_media_calc = producao_calc / viagens_val,

    # 7. Engenharia de Tempos (Reconstrução do Ciclo)
    dist_cheio = dmt,
    dist_vazio = dmt / relacao_km,

    # Tempo = Distância / Velocidade (h -> min)
    tvc_min = (dist_cheio / vel_cheio) * 60,
    tvv_min = (dist_vazio / vel_vazio) * 60,

    # Tempo Fixo
    tempo_fixo = fila_carga + manobra + carregamento + fila_basculo + basculamento,

    # TTC Total
    ttc_min = tempo_fixo + replace_na(tvc_min, 0) + replace_na(tvv_min, 0),

    # 8. TKPH
    tkph_calc = (producao_calc * dmt) / ifelse(HT_calc > 0, HT_calc, 1)
  ) %>%

  # --- MAPEAMENTO FINAL ---
  transmute(
    # Identificação
    data = data,
    turno = turno,
    id_equipamento_real = frota,

    # Indicadores
    DF = df,
    UF = uf,
    produtividade_ht = produtividade,

    # Produção
    producao_total = producao_calc,
    carga_media = carga_media, # Mantemos o original se quiser comparar, ou use carga_media_calc
    num_viagens = viagens_validas,

    # Transporte
    tkph = tkph_calc,
    dmt = dmt,

    # Velocidades
    vel_cheio = vel_cheio,
    vel_vazio = vel_vazio,
    vel_global = vel_global,

    # Tempos (Minutos)
    tempo_ciclo_total = ttc_min,
    tempo_fixo = tempo_fixo,
    tempo_viagem_cheio = tvc_min,
    tempo_viagem_vazio = tvv_min,

    tempo_carregamento = carregamento,
    tempo_manobra = manobra,
    tempo_fila_carga = fila_carga,
    tempo_fila_basculo = fila_basculo,
    tempo_basculo = basculamento,

    # Árvore de Horas (Consistente)
    HC = HC_calc,
    HM = HM_calc,
    HD = HD_calc,
    HO = HO_calc,
    HT = HT_calc,

    HTP = HTP_calc,
    HTNP = HTNP_final,

    HEF = HEF_calc,
    HAO = HAO_final
  ) %>%

  # --- ANONIMIZAÇÃO ---
  mutate(
    id_equipamento = paste0("HAUL-", sprintf("%03d", as.numeric(as.factor(id_equipamento_real)))),
    data = data - years(2),

    # Perturbação
    across(c(DF, UF, produtividade_ht, producao_total, tkph,
             vel_cheio, vel_vazio, HC, HM, HT, HEF),
           ~ .x * runif(n(), 0.99, 1.01)),

    across(where(is.numeric), ~ round(.x, 2))
  ) %>%

  select(-id_equipamento_real) %>%
  filter(!is.na(DF), HC > 0)

# --- 5. SALVAR ---
glimpse(haul_daily_cep_br)

usethis::use_data(haul_daily_cep_br, overwrite = TRUE)
fs::dir_create("inst/extdata")
write_csv(haul_daily_cep_br, "inst/extdata/haul_daily_cep_br.csv")

message("Dataset 'haul_daily_cep_br' (GPV-M Blindado) processado!")
