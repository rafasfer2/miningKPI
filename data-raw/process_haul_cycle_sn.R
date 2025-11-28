## data-raw/process_haul_cycle_sn.R

library(tidyverse)
library(readxl)
library(janitor)
library(fs)
library(lubridate)
library(usethis)

# --- 1. CONFIGURAÇÃO ---
caminho_real <- "K:/Meu Drive/Dados_Confidenciais/dados_brutos_ciclo.xlsx"

if (!file.exists(caminho_real)) {
  stop("Arquivo não encontrado! Verifique se renomeou para 'dados_brutos_ciclo.xlsx'")
}

# --- 2. LEITURA ---
# Lê todas as colunas. O janitor vai limpar os nomes (ex: TpVz -> tp_vz)
dados_brutos <- read_excel(caminho_real) %>% clean_names()

# --- 3. TRATAMENTO ---
set.seed(123)

haul_cycle_sn <- dados_brutos %>%
  # Filtro de Frotas (Se necessário, ajuste conforme os nomes reais na coluna frota_tr)
  filter(str_detect(frota_tr, "797|793")) %>%

  transmute(
    # Identificação
    unidade = "Mina A", # Serra Norte
    id_ciclo_real = id, # Coluna Id original

    # Datas e Turno
    data_hora_inicio = as_datetime(data_hora_carga),
    data_hora_fim = as_datetime(data_hora_bascu),
    turno = turno,
    equipe = turma,

    # Equipamentos
    frota = frota_tr,
    id_equipamento_real = eqpto_tr,
    id_carga_real = frota_cg, # Escavadeira

    # Produção e Material
    material = material,
    massa_transportada = tons,
    carga_alvo = max_tr, # MaxTr
    fator_carga = fator_carga,
    balanca_ok = balanca_ok, # Pode ser útil para filtrar dados ruins

    # --- TEMPOS DO CICLO (Mapeamento Exato) ---
    TVV = tp_vz,    # Tempo Viagem Vazio
    TFC = fl_cg,    # Fila Carga
    TMC = mnb_cg,   # Manobra Carga
    TC  = tp_cg,    # Tempo Carga
    TVC = tp_ch,    # Tempo Viagem Cheio
    TFB = fl_bc,    # Fila Bascula
    TMB = mnb_bc,   # Manobra Bascula (Importante: separada do basculamento)
    TB  = tp_bc,    # Tempo Basculamento (Apenas descarga)

    # Totais
    tempo_ciclo_total = tp_ciclo,
    tempo_fixo = tp_fixo,

    # --- DISTÂNCIAS (DMT) ---
    dmt_vazio = dmt_vz,
    dmt_cheio = dmt_ch,
    dmt_total = dmt,

    # --- VELOCIDADES ---
    vel_vazio = vel_vz,
    vel_cheio = vel_ch,
    vel_global = vel_gl,

    # --- TKPH (Indicador de Pneus) ---
    tkph_viagem = dmt_chx_tons, # TKPH Real da viagem (calculado pelo sistema)

    # Localização
    origem = origem,
    destino = destino
  ) %>%

  # --- ANONIMIZAÇÃO ---
  mutate(
    # Mascarar Caminhão (HAUL-XXXX)
    id_equipamento = paste0("HAUL-", sprintf("%04d", as.numeric(as.factor(id_equipamento_real)))),

    # Mascarar Escavadeira (LOAD-XXXX)
    id_carga = paste0("LOAD-", sprintf("%04d", as.numeric(as.factor(id_carga_real)))),

    # Criar ID único sequencial para o dataset público
    id_ciclo = row_number(),

    # Deslocar datas (-1 ano)
    data_hora_inicio = data_hora_inicio - years(1),
    data_hora_fim = data_hora_fim - years(1),

    # Perturbação Numérica (+- 1%)
    across(
      c(massa_transportada, carga_alvo,
        TVV, TFC, TMC, TC, TVC, TFB, TMB, TB, tempo_ciclo_total,
        dmt_vazio, dmt_cheio, dmt_total,
        vel_vazio, vel_cheio, vel_global, tkph_viagem),
      ~ .x * runif(n(), 0.99, 1.01)
    ),

    # Arredondamento
    across(where(is.numeric) & !matches("id_ciclo|turno"), ~ round(.x, 2))
  ) %>%

  select(
    id_ciclo, data_hora_inicio, turno, equipe,
    id_equipamento, id_carga,
    massa_transportada, carga_alvo,
    TVV, TFC, TMC, TC, TVC, TFB, TMB, TB,
    tempo_ciclo_total, dmt_total, tkph_viagem
  ) %>%

  # Filtro de consistência
  filter(!is.na(massa_transportada), tempo_ciclo_total > 0)

# --- 4. SALVAR ---
# Validação rápida
glimpse(haul_cycle_sn)

usethis::use_data(haul_cycle_sn, overwrite = TRUE)
fs::dir_create("inst/extdata")
write_csv(head(haul_cycle_sn, 10000), "inst/extdata/haul_cycle_sn.csv") # Amostra CSV

message("Dataset 'haul_cycle_sn' (Ciclo Detalhado) processado!")
