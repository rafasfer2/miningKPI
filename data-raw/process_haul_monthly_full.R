## data-raw/process_haul_monthly_full.R

library(tidyverse)
library(lubridate)
library(fs)

# --- 1. CARREGAR DADOS JÁ PROCESSADOS DO PACOTE ---
# Não precisamos ler o bruto de novo, usamos o que já limpamos no pacote!

# Carrega os apontamentos (Fonte da Verdade para Horas)
load("data/haul_shift_log_sn.rda")

# Carrega o Requipam (Fonte da Verdade para Produção)
load("data/haul_kpi_monthly_sn.rda")

message("Iniciando consolidação mensal...")

# --- 2. CALCULAR HORAS A PARTIR DOS APONTAMENTOS ---
# Agrega o micro-dado (shift log) para mensal
horas_calculadas <- haul_shift_log_sn %>%
  mutate(mes = floor_date(data, "month")) %>%
  group_by(mes, id_equipamento, categoria) %>%
  summarise(horas = sum(duracao_h, na.rm = TRUE), .groups = "drop") %>%

  # Pivotar para ter colunas de horas (HMC, HEF, etc.)
  pivot_wider(
    names_from = categoria,
    values_from = horas,
    values_fill = 0
  ) %>%

  # Calcular os Agrupamentos (Ajuste conforme as siglas do seu sistema)
  mutate(
    # Exemplo de composição (Verifique se suas siglas batem: HMC, HAO, etc.)
    HM_calc = rowSums(across(any_of(c("HMC", "HAC", "MPS", "MPNS")))),
    HEF_calc = rowSums(across(any_of(c("HEF")))), # Horas Efetivas
    HAO_calc = rowSums(across(any_of(c("HAO")))), # Atraso Operacional
    HO_calc  = rowSums(across(any_of(c("HO", "HOI", "HOE")))), # Ociosidade

    HT_calc = HEF_calc + HAO_calc + rowSums(across(any_of(c("HTD", "HTI")))), # Horas Trabalhadas
    HC_calc = HM_calc + HT_calc + HO_calc # Hora Calendário (Deve dar ~720h ou 744h)
  ) %>%
  select(mes, id_equipamento, ends_with("_calc"))

# --- 3. BUSCAR PRODUÇÃO DO REQUIPAM ---
producao_oficial <- haul_kpi_monthly_sn %>%
  mutate(mes = floor_date(data, "month")) %>%
  select(mes, id_equipamento, producao_total, num_falhas) # Trazemos produção e nº falhas

# --- 4. O GRANDE JOIN (FUSÃO) ---
haul_monthly_consolidated_sn <- horas_calculadas %>%
  inner_join(producao_oficial, by = c("mes", "id_equipamento")) %>%

  # --- 5. RECALCULAR INDICADORES (KPIs) ---
  # Agora calculamos DF e UF com os dados limpos do R
  mutate(
    DF_final = (HC_calc - HM_calc) / HC_calc * 100,
    UF_final = HT_calc / (HC_calc - HM_calc) * 100,

    # Produtividade Física (ton/h)
    produtividade_media = ifelse(HEF_calc > 0, producao_total / HEF_calc, 0),

    # Validação de consistência
    horas_mes_validacao = days_in_month(mes) * 24
  ) %>%

  # Limpeza final
  filter(HC_calc > 0) %>%
  select(
    mes, id_equipamento,
    DF_final, UF_final, produtividade_media,
    producao_total, num_falhas,
    everything() # Mantém todas as horas calculadas
  )

# --- 6. VALIDAÇÃO ---
# Verifica se HC bate com as horas do mês (pode ter pequena variação por arredondamento)
summary(haul_monthly_consolidated_sn$HC_calc)

# --- 7. SALVAR ---
usethis::use_data(haul_monthly_consolidated_sn, overwrite = TRUE)
fs::dir_create("inst/extdata")
write_csv(haul_monthly_consolidated_sn, "inst/extdata/haul_monthly_consolidated_sn.csv")

message("Dataset MENSAL CONSOLIDADO (Híbrido) gerado com sucesso!")
