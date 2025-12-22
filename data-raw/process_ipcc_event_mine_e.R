library(tidyverse)
library(lubridate)
library(janitor)
library(usethis)

# --- 1. CONFIGURAÇÃO ---
caminho_real <- "L:/Meu Drive/Dados_Confidenciais/ipcc_s11d.Rdata"

if (!file.exists(caminho_real)) {
  stop("Arquivo .Rdata não encontrado! Verifique o caminho.")
}

message("=== PROCESSANDO MINA E (S11D - IPCC) ===")

# --- 2. LEITURA (.Rdata) ---
message("Carregando arquivo Rdata...")

# O load() carrega o objeto para o ambiente, mas não retorna o dataframe diretamente.
# Vamos capturar o nome do objeto carregado.
env_temp <- new.env()
load(caminho_real, envir = env_temp)
objetos_carregados <- ls(envir = env_temp)
nome_do_objeto <- objetos_carregados[1] # Assume que é o primeiro/único objeto
raw_data <- get(nome_do_objeto, envir = env_temp)

message(paste("Objeto carregado:", nome_do_objeto, "| Linhas:", nrow(raw_data)))

# --- 3. TRATAMENTO ---
ipcc_event_log_mine_e <- raw_data %>%
  as_tibble() %>%
  clean_names() %>% # Padroniza: "Unidade Operacional" -> "unidade_operacional"

  # A. Filtros e Tipagem
  mutate(
    # Garante formato de data (se já vier POSIXct do Rdata, o as_datetime mantém)
    inicio = as_datetime(inicio),
    fim = as_datetime(fim),
    duracao_h = as.numeric(duracao)
  ) %>%

  # B. Anonimização e Categorização (Lógica IPCC)
  mutate(
    mina_id = "Mina E",
    metodo_lavra = "IPCC (Truckless)",

    # Categorizar Ativo pelo Tag (TR=Correia, AL=Alimentador, MCAL=Britador Móvel)
    tipo_ativo = case_when(
      str_detect(equipamento, "^TR") ~ "Correia Transportadora",
      str_detect(equipamento, "^AL") ~ "Alimentador",
      str_detect(equipamento, "^MCAL") ~ "Britador Móvel",
      str_detect(equipamento, "^MSAL") ~ "Sizer/Peneira",
      TRUE ~ "Outros"
    ),

    # ID Anonimizado: IPCC-TIPO-NUMERO
    # Usamos o próprio equipamento como semente para garantir que
    # o mesmo TR1083KS01 vire sempre o mesmo código anonimizado.
    id_equipamento = paste0(
      case_when(
        tipo_ativo == "Correia Transportadora" ~ "CNV-", # Conveyor
        tipo_ativo == "Britador Móvel" ~ "CRH-",         # Crusher
        tipo_ativo == "Alimentador" ~ "FDR-",            # Feeder
        tipo_ativo == "Sizer/Peneira" ~ "SZR-",
        TRUE ~ "EQP-"
      ),
      "E-",
      as.numeric(as.factor(equipamento))
    ),

    # Extração limpa da categoria (HOI, HMC, HEF)
    # O regex "^[A-Z]{3}" pega as 3 primeiras letras maiúsculas
    categoria_kpi = str_extract(categoria_de_horas, "^[A-Z]{3}"),

    # Textos
    sistema = str_to_title(sistema_produtivo),
    subprocesso = str_to_title(subprocesso),
    descricao_evento = str_to_sentence(descricao_do_evento),
    observacao = str_trunc(str_squish(observacao), 150)
  ) %>%

  # C. Seleção Final (Schema do Pacote)
  transmute(
    mina_id,
    metodo_lavra,
    data_ref = as_date(inicio),

    # Hierarquia
    sistema,
    subprocesso,
    tipo_ativo,
    id_equipamento,

    # Tempos
    inicio,
    fim,
    duracao_h,

    # Evento
    codigo_evento = as.character(codigo_do_evento),
    descricao_evento,

    # Classificação
    categoria_kpi,
    impacta_indicador = case_when(
      str_detect(impacta_nos_indicadores, "(?i)Sim") ~ TRUE,
      TRUE ~ FALSE
    ),
    is_parada_oportunidade = str_detect(parada_de_oportunidade, "(?i)Sim"),

    # Detalhes de Falha
    causa_basica = causa,
    tipo_falha = falha,
    observacao
  ) %>%

  filter(!is.na(inicio)) %>%
  arrange(inicio)

# --- 4. SALVAR ---
usethis::use_data(ipcc_event_log_mine_e, overwrite = TRUE)
message("✅ Dataset 'ipcc_event_log_mine_e' processado e salvo!")
