library(tidyverse)
library(janitor)
library(usethis)
library(lubridate)

# --- 1. CONFIGURAÇÃO ---
caminho_input <- "L:/Meu Drive/Dados_Confidenciais/load_event_mine_a.Rdata"
if (!file.exists(caminho_input)) stop("Arquivo .Rdata não encontrado!")

load(caminho_input)

# --- 2. TRADUÇÃO E MASCARAMENTO ---
load_cycle_mine_a <- load_cycle_mine_a %>%
  clean_names() %>%
  mutate(
    # Tradução de Frota (Internacionalização e Categoria)
    fleet_id = case_when(
      str_detect(frota_cg, "Bucyrus 495") ~ "Electric Shovel - Ultra Class",
      str_detect(frota_cg, "PC5500")      ~ "Hydraulic Excavator - Large Class",
      str_detect(frota_cg, "L1850")       ~ "Wheel Loader - Large Class",
      TRUE ~ "Other"
    ),

    # Tradução de Material e Origem
    material = case_when(
      str_detect(material, "Esteril") ~ str_replace(material, "Esteril", "Waste"),
      str_detect(material, "Minério") ~ str_replace(material, "Minério", "Ore"),
      TRUE ~ material
    ),
    origin = case_when(
      origem == "Banco"           ~ "Bench",
      origem %in% c("Estoque", "Deposito") ~ "Stockpile",
      str_detect(origem, "Remanejo") ~ "Rehandling",
      TRUE ~ "Other"
    ),

    # Tradução de Status de Carga
    load_status = case_when(
      controle_cargas == "Aceitavel"    ~ "Acceptable",
      controle_cargas %in% c("CargaOK", "CargaOk") ~ "Target Met",
      controle_cargas == "Carga Baixa"  ~ "Low Load",
      controle_cargas == "Critica"      ~ "Critical",
      controle_cargas == "FalhaBalança" ~ "Scale Failure",
      controle_cargas == "Proibitiva"   ~ "Prohibitive",
      controle_cargas == "Subcarga"     ~ "Underload",
      TRUE ~ "Unknown"
    ),

    # Anonimização de Ativos
    haul_id = paste0("HAUL-", sprintf("%04d", as.numeric(as.factor(eqpto_tr)))),
    load_id = paste0("LOAD-", sprintf("%04d", as.numeric(as.factor(eqpto_cg)))),

    # Ajuste Temporal (t_i)
    exit_time = as_datetime(data_hora_carga) - years(1)
  ) %>%
  transmute(
    exit_time,
    fleet_id,
    load_id,
    haul_id,
    origin,
    material,
    payload = tons,
    load_status,
    lct = tp_cg,  # Loading Cycle Time (d_i)
    mct = mnb_cg, # Maneuver
    oct = oci_cg  # Operational/Idle
  ) %>%
  arrange(exit_time)

# --- 3. SALVAR ---
usethis::use_data(load_cycle_mine_a, overwrite = TRUE)

message(">>> Dataset 'load_cycle_mine_a' finalizado com nomes de frota internacionais!")
