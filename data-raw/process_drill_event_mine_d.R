library(tidyverse)
library(readxl)
library(lubridate)
library(janitor)
library(usethis)

# --- 1. CONFIGURAÇÃO ---
caminho_real <- "L:/Meu Drive/Dados_Confidenciais/historico_perfuratriz_sossego.xlsx"

if (!file.exists(caminho_real)) {
  stop("Arquivo Excel não encontrado!")
}

message("=== PROCESSANDO MINA D (5 ABAS = 5 DATASETS) ===")

# ==============================================================================
# ABA 1: APONTAMENTOS 2023 (Detalhados com GPS)
# ==============================================================================
message("> Processando Aba 1: apontamentos 2023...")
raw_2023 <- read_excel(caminho_real, sheet = "apontamentos 2023", guess_max = 20000)

drill_event_2023_mine_d <- raw_2023 %>%
  clean_names() %>%
  transmute(
    mina_id = "Mina D",
    # Simplifiquei aqui, pois não estamos mais unindo tabelas
    id_equipamento_real = equipament,
    modelo = model,
    porte = porte,
    regiao = regiao,

    # Telemetria
    gps_x = tryCatch(as.numeric(gps_x), error = function(e) NA),
    gps_y = tryCatch(as.numeric(gps_y), error = function(e) NA),
    horimetro = tryCatch(as.numeric(horimetro), error = function(e) NA),

    # --- CORREÇÃO DE DATAS AQUI ---
    # Converte para texto e deixa o lubridate resolver os formatos variados
    inicio = parse_date_time(as.character(time_in), orders = c("dmy HMS", "ymd HMS", "dmy", "ymd")),
    fim = parse_date_time(as.character(time_end), orders = c("dmy HMS", "ymd HMS", "dmy", "ymd")),

    duracao_h = as.numeric(str_replace(as.character(time_gap), ",", ".")),

    codigo_evento = as.character(code),
    status = status,
    categoria = category,
    descricao = str_to_upper(sector),
    comentario = comment,
    turma = turma,
    turno = turno
  ) %>%
  filter(!is.na(inicio)) %>%
  mutate(id_equipamento = paste0("DRILL-D-", as.numeric(as.factor(id_equipamento_real)))) %>%
  select(-id_equipamento_real)

usethis::use_data(drill_event_2023_mine_d, overwrite = TRUE)

# ==============================================================================
# ABA 2: APONTAMENTOS (Recentes/Outros)
# ==============================================================================
message("> Processando Aba 2: apontamentos...")
raw_apont <- read_excel(caminho_real, sheet = "apontamentos", guess_max = 5000)

drill_event_log_mine_d <- raw_apont %>%
  clean_names() %>%
  transmute(
    mina_id = "Mina D",
    id_equipamento_real = equipament,
    modelo = model,
    porte = porte,

    # --- CORREÇÃO DE DATAS AQUI TAMBÉM ---
    inicio = parse_date_time(as.character(time_in), orders = c("dmy HMS", "ymd HMS", "dmy", "ymd")),
    fim = parse_date_time(as.character(time_end), orders = c("dmy HMS", "ymd HMS", "dmy", "ymd")),

    duracao_h = as.numeric(str_replace(as.character(time_gap), ",", ".")),

    codigo_evento = as.character(code),
    status = status,
    categoria = category,
    descricao = str_to_upper(sector),
    comentario = comment,
    turma = turma,
    turno = turno
  ) %>%
  filter(!is.na(inicio)) %>%
  mutate(id_equipamento = paste0("DRILL-D-", as.numeric(as.factor(id_equipamento_real)))) %>%
  select(-id_equipamento_real)

usethis::use_data(drill_event_log_mine_d, overwrite = TRUE)

# ==============================================================================
# ABA 3: REQUIPAM (Performance Diária)
# ==============================================================================
message("> Processando Aba 3: requipam...")
raw_req <- read_excel(caminho_real, sheet = "requipam", guess_max = 20000)

equipment_daily_act_mine_d <- raw_req %>%
  clean_names() %>%
  transmute(
    mina_id = "Mina D",
    data = as_date(day),
    id_equipamento_real = equipament,
    grupo = group,
    modelo = model,
    turma = turma,

    hc = as.numeric(hc),
    ht = as.numeric(ht),
    hm = as.numeric(hm),
    ho = as.numeric(ho),
    producao = as.numeric(producao),
    atividade = tipo_global
  ) %>%
  mutate(id_equipamento = paste0(str_sub(str_to_upper(grupo), 1, 3), "-D-", as.numeric(as.factor(id_equipamento_real)))) %>%
  select(-id_equipamento_real)

usethis::use_data(equipment_daily_act_mine_d, overwrite = TRUE)


# ==============================================================================
# ABA 4: PROGRAMADOS (Metas)
# ==============================================================================
message("> Processando Aba 4: programados...")
raw_prog <- read_excel(caminho_real, sheet = "programados", guess_max = 5000)

equipment_daily_plan_mine_d <- raw_prog %>%
  clean_names() %>%
  rename_with(~str_remove(., "_$"), everything()) %>%
  transmute(
    mina_id = "Mina D",
    data = as_date(day),
    frota = equipament,
    df_plan = as.numeric(df),
    uf_plan = as.numeric(uf),
    prod_plan = as.numeric(pr)
  ) %>%
  filter(!is.na(data))

usethis::use_data(equipment_daily_plan_mine_d, overwrite = TRUE)


# ==============================================================================
# ABA 5: D+30 INFRA (Produção e Qualidade)
# ==============================================================================
message("> Processando Aba 5: D+30 infra...")
raw_prod <- read_excel(caminho_real, sheet = "D+30 infra", col_types = "text")

production_daily_mine_d <- raw_prod %>%
  clean_names() %>%
  filter(!is.na(dia), str_detect(dia, "^[0-9]")) %>%
  mutate(
    dia_num = suppressWarnings(as.numeric(dia)),
    data = case_when(
      !is.na(dia_num) ~ as_date(dia_num, origin = "1899-12-30"),
      TRUE ~ as_date(parse_date_time(dia, orders = c("dmy", "ymd", "dmy HMS")))
    ),
    data = if_else(year(data) < 2000 | year(data) > 2030, NA_Date_, data)
  ) %>%
  filter(!is.na(data)) %>%
  mutate(across(c(contains("mov"), contains("producao"), contains("teor"), contains("rem")),
                ~as.numeric(str_replace_all(str_replace(., "\\.", ""), ",", ".")))) %>%
  transmute(
    mina_id = "Mina D",
    data = data,
    movimentacao_t = mov_diaria_t,
    minerio_tbn = producao_minerio_rom_tbn,
    esteril_t = producao_esteril,
    teor_cu = teor_cu,
    rem_real = rem
  ) %>%
  mutate(across(where(is.numeric), ~replace_na(., 0))) %>%
  arrange(data)

usethis::use_data(production_daily_mine_d, overwrite = TRUE)

message("✅ SUCESSO! 5 Datasets gerados e salvos em data/")
