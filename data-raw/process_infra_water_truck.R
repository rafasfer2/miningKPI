## data-raw/process_infra_water_truck.R

library(tidyverse)
library(readxl)
library(janitor)
library(fs)
library(lubridate)
library(usethis)

# --- 1. CONFIGURAÇÃO ---
path_events <- "K:/Meu Drive/Dados_Confidenciais/infra_water_truck_events.xlsx"
path_hm     <- "K:/Meu Drive/Dados_Confidenciais/infra_water_truck_hourmeter.xlsx"
path_cost   <- "K:/Meu Drive/Dados_Confidenciais/infra_water_truck_cost_plan.xlsx"
path_tasks  <- "K:/Meu Drive/Dados_Confidenciais/infra_water_truck_task_list.xlsx"

if (!file.exists(path_events)) stop("Arquivo de eventos não encontrado!")

# --- 2. PROCESSAMENTO: EVENTOS (Apontamentos) ---
message("Processando Eventos...")
# Ler como texto para evitar erro de data
raw_events <- read_excel(path_events, col_types = "text") %>% clean_names()

infra_water_truck_events_br <- raw_events %>%
  mutate(
    # Datas (dmy_hms do Brasil)
    inicio = parse_date_time(data_inicial, orders = c("dmy HMS", "ymd HMS")),
    fim = parse_date_time(data_final, orders = c("dmy HMS", "ymd HMS")),
    duracao_h = as.numeric(difftime(fim, inicio, units = "hours"))
  ) %>%
  filter(duracao_h > 0) %>%
  transmute(
    unidade = "Mina B",
    id_equipamento_real = equipamento,
    data_inicio = as.Date(inicio),
    inicio, fim, duracao_h,

    # Classificação
    categoria = categoria_tempo, # HMC, MPS...
    tipo_manutencao = categoria_tempo_tipo,
    razao = razao_descricao,

    # Texto
    comentario = str_trunc(comentario, 200), # Limita tamanho
    sistema = sistema,
    problema = problema,
    solucao = solucao
  ) %>%
  # Anonimização
  mutate(
    id_equipamento = paste0("PIPA-", sprintf("%02d", as.numeric(as.factor(id_equipamento_real)))),
    inicio = inicio - years(1),
    fim = fim - years(1),
    duracao_h = round(duracao_h * runif(n(), 0.99, 1.01), 2)
  ) %>%
  select(-id_equipamento_real)

# --- 3. PROCESSAMENTO: HORÍMETRO ---
message("Processando Horímetro...")
raw_hm <- read_excel(path_hm) %>% clean_names()

infra_water_truck_hourmeter_br <- raw_hm %>%
  transmute(
    data = as.Date(data),
    id_equipamento_real = equipamento,
    horimetro = as.numeric(horimetro)
  ) %>%
  # Tenta usar o mesmo ID anonimizado (se os nomes baterem)
  # Como é um script separado, criamos um mapa temporário ou assumimos consistência
  # Ideal: fazer um left_join com um mapa único, mas aqui simplificamos:
  mutate(
    id_equipamento = paste0("PIPA-", sprintf("%02d", as.numeric(as.factor(id_equipamento_real)))),
    data = data - years(1)
  ) %>%
  select(-id_equipamento_real) %>%
  filter(!is.na(horimetro), horimetro > 0) %>%
  arrange(id_equipamento, data)

# --- 4. PROCESSAMENTO: PLANO DE CUSTOS (MP) ---
message("Processando Custos de MP...")
# Pular a linha 1 (título) e ler a 2 como cabeçalho
raw_cost <- read_excel(path_cost, skip = 1) %>% clean_names()

infra_water_truck_cost_plan <- raw_cost %>%
  # Filtra linhas válidas (que têm descrição)
  filter(!is.na(descricao)) %>%
  transmute(
    item_manutencao = descricao,
    sistema_sap = descricao_sistema_sap,
    qtd = as.numeric(qtd),

    # Flags de Periodicidade (Transforma X em TRUE)
    mp_300h  = !is.na(x300_h),
    mp_600h  = !is.na(x600_h),
    mp_1200h = !is.na(x1200_h),
    mp_2400h = !is.na(x2400_h),

    tipo_revisao = tipo_revisao,

    # Custo Unitário (Limpeza de R$)
    # Remove "R$", espaço e troca vírgula por ponto
    valor_unitario = as.numeric(str_replace_all(valor_unitario, "[R$\\s]", "") %>% str_replace(",", "."))
  ) %>%
  # Perturbação no custo
  mutate(valor_unitario = round(valor_unitario * runif(n(), 0.95, 1.05), 2))

# --- 5. PROCESSAMENTO: LISTA DE TAREFAS ---
message("Processando Lista de Tarefas...")
# Sua limpeza prévia deixou o cabeçalho na linha 1
raw_tasks <- read_excel(path_tasks, sheet = "Lista Tarefa") %>% clean_names()

infra_water_truck_task_list <- raw_tasks %>%
  transmute(
    operacao_num = oper,
    descricao_curta = descricao_curto_e_ou_sistema,
    descricao_detalhada = descricao_detalhada_da_tarefa,
    duracao_estimada_h = as.numeric(str_replace(duracao_total_atividade_hh_mm_fomat_decimal, ",", ".")),
    qtd_homens = as.numeric(qtd_md_unitario),

    # Mapeamento de periodicidade (colunas 01..24)
    # Ex: Se coluna "x01" tem X, é revisão de 250h/1a?
    # Vamos simplificar e manter as colunas x01 a x24 como flags lógicos
    across(matches("^x[0-9]+$"), ~ !is.na(.))
  )

# --- 6. SALVAR TUDO ---
usethis::use_data(infra_water_truck_events_br, overwrite = TRUE)
usethis::use_data(infra_water_truck_hourmeter_br, overwrite = TRUE)
usethis::use_data(infra_water_truck_cost_plan, overwrite = TRUE)
usethis::use_data(infra_water_truck_task_list, overwrite = TRUE)

# CSVs
fs::dir_create("inst/extdata")
write_csv(infra_water_truck_events_br, "inst/extdata/infra_water_truck_events_br.csv")

message("Datasets de Infraestrutura (Caminhão Pipa) processados!")
