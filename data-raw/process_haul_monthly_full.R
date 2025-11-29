## data-raw/process_haul_monthly_full.R

library(tidyverse)
library(lubridate)
library(fs)
library(usethis)
library(devtools) # Necessário para load_all()

# --- 1. CARREGAR DADOS JÁ PROCESSADOS DO PACOTE ---
devtools::load_all()

if (!exists("haul_shift_log_sn")) {
  stop("ERRO: O objeto 'haul_shift_log_sn' não existe. Rode o script 'process_sn_events.R' primeiro.")
}
if (!exists("haul_kpi_monthly_sn")) {
  stop("ERRO: O objeto 'haul_kpi_monthly_sn' não existe. Rode o script 'process_haul_kpi.R' primeiro.")
}

message("Dados de dependência carregados via load_all().")

# --- 2. CALCULAR HORAS A PARTIR DOS APONTAMENTOS ---
horas_calculadas <- haul_shift_log_sn %>%
  mutate(mes = floor_date(data, "month")) %>%
  group_by(mes, id_equipamento, categoria) %>%
  summarise(horas = sum(duracao_h, na.rm = TRUE), .groups = "drop") %>%

  pivot_wider(
    names_from = categoria,
    values_from = horas,
    values_fill = 0
  ) %>%

  # A. DEFINIÇÃO DOS COMPONENTES
  mutate(
    HM_calc = rowSums(across(any_of(c("HMC", "HAC", "MPS", "MPNS"))), na.rm = TRUE),
    HEF_calc = rowSums(across(any_of(c("HEF"))), na.rm = TRUE),
    HAO_calc = rowSums(across(any_of(c("HAO"))), na.rm = TRUE),
    HO_calc  = rowSums(across(any_of(c("HO", "HOI", "HOE"))), na.rm = TRUE),
    HT_calc = HEF_calc + HAO_calc + rowSums(across(any_of(c("HTD", "HTI"))), na.rm = TRUE),

    # B. CALCULAR HC E HD (A LINHA QUE FALTAVA)
    HC_calc = HM_calc + HT_calc + HO_calc,
    HD_calc = HC_calc - HM_calc # <--- INSERÇÃO DA FÓRMULA HD = HC - HM
  ) %>%
  select(mes, id_equipamento, ends_with("_calc"))


# --- 3. BUSCAR PRODUÇÃO DO REQUIPAM ---
producao_oficial <- haul_kpi_monthly_sn %>%
  mutate(mes = floor_date(data, "month")) %>%
  select(mes, id_equipamento, producao_total, num_falhas)

# --- 4. O GRANDE JOIN (FUSÃO) ---
haul_monthly_consolidated_sn <- horas_calculadas %>%
  distinct() %>%
  # O join agora vai funcionar, pois HD_calc está presente na horas_calculadas
  inner_join(producao_oficial, by = c("mes", "id_equipamento")) %>%

  # --- 5. RECALCULAR INDICADORES (KPIs) ---
  mutate(
    # UF_final AGORA PODE ACESSAR HD_calc:
    DF_final = ifelse(HC_calc > 0, (HC_calc - HM_calc) / HC_calc * 100, 0),
    UF_final = ifelse(HD_calc > 0, HT_calc / HD_calc * 100, 0),

    # Produtividade e Validação
    produtividade_media = ifelse(HEF_calc > 0, producao_total / HEF_calc, 0),
    horas_mes_validacao = days_in_month(mes) * 24
  ) %>%

  filter(HC_calc > 0) %>%
  select(
    mes, id_equipamento,
    DF_final, UF_final, produtividade_media,
    producao_total, num_falhas,
    everything()
  )

# --- 6. SALVAR ---
usethis::use_data(haul_monthly_consolidated_sn, overwrite = TRUE)
fs::dir_create("inst/extdata")
write_csv(haul_monthly_consolidated_sn, "inst/extdata/haul_monthly_consolidated_sn.csv")

message("Dataset MENSAL CONSOLIDADO (Híbrido) gerado com sucesso!")
