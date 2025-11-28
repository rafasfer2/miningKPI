## data-raw/process_haul_costs.R

library(tidyverse)
library(lubridate)
library(janitor)
library(fs)
library(hablar) # Mantive pois você usou 'convert'

# --- 1. CONFIGURAÇÃO ---
caminho_real <- "K:/Meu Drive/Dados_Confidenciais/data_read_custo.Rdata"

if (!file.exists(caminho_real)) {
  stop("Arquivo Rdata de custos não encontrado!")
}

# --- 2. CARREGAMENTO ---
message("Carregando base de custos...")
load(caminho_real)

if (exists("data_read_custo")) {
  dados_brutos <- data_read_custo
} else {
  objs <- ls()
  dados_brutos <- get(objs[1])
}

# --- 3. LIMPEZA E TRATAMENTO (Sua Lógica Otimizada) ---
set.seed(999)

haul_maint_costs_sn <- dados_brutos %>%
  # A. SELEÇÃO E FILTROS TÉCNICOS (Baseado no seu código)
  rename(
    Modelo = `Descrição do Local de Instalação`,
    OM = `Ordem (KOB1)`,
    TAM = `Tipo de Atividade de Manutenção`,
    TAM_name = `Denominação TAM`,
    OM_type = `Tipo da Ordem`,
    CT = `Centro de Trabalho (Ordem)`,
    CT_name = `Denominação Centro de Trabalho (Ordem)`
  ) %>%

  # Extração de Frota e TAG via Posição (Sua lógica)
  mutate(
    Frota = str_sub(`Local de Instalação`, start = 17, end = 18),
    CAM = str_sub(`Local de Instalação`, start = 22, end = 25)
  ) %>%

  filter(CAM != "") %>%

  # Filtros de Negócio (Serra Norte / Transporte)
  filter(
    Gerência %in% "MANUT EQUIP TRANSPORTE MINA SN",
    `Centro (Operação da Ordem)` %in% "1058",
    Frota %in% c("40", "52", "53", "55", "57"), # Frotas Relevantes
    str_sub(`Local de Instalação`, start = 10, end = 12) %in% "CAM"
  ) %>%

  # Categorização de Custo (Simplificada para o livro)
  mutate(
    categoria_custo = case_when(
      str_detect(`Denominação (Classe de Custo)`, "PECA|MATERIAL|FILTRO") ~ "Pecas",
      str_detect(`Denominação (Classe de Custo)`, "SERVICO|MAO DE OBRA") ~ "Servicos_MO",
      str_detect(`Denominação (Classe de Custo)`, "OLEO|DIESEL|LUBRIF") ~ "Insumos",
      TRUE ~ "Outros"
    )
  ) %>%

  # Seleção Final
  transmute(
    data = as.Date(day_lancamento),
    frota_cod = Frota,
    id_caminhao_real = CAM, # ID Real (ex: 5501)

    # Ordem e Tipo
    num_ordem = OM,
    tipo_ordem = OM_type, # YPM, YEM...
    tipo_manut = TAM,     # SVC...

    # Custo
    categoria_custo,
    valor = as.numeric(Valor)
  ) %>%

  # B. AGREGAÇÃO MENSAL (Para o Pacote)
  # Agrupamos por mês e caminhão para anonimizar e reduzir volume
  group_by(data = floor_date(data, "month"), id_caminhao_real, tipo_ordem, categoria_custo) %>%
  summarise(valor_mensal = sum(valor, na.rm = TRUE), .groups = "drop") %>%

  # C. PIVOTAGEM
  pivot_wider(
    names_from = categoria_custo,
    values_from = valor_mensal,
    values_fill = 0,
    names_prefix = "custo_"
  ) %>%
  clean_names() %>%

  # D. ANONIMIZAÇÃO E PERTURBAÇÃO
  mutate(
    # Mascarar Caminhão: Tenta manter consistência (5501 -> HAUL-XXXX)
    # Como não temos o mapeamento exato dos outros scripts aqui, geramos um novo
    # mas mantendo a ordem numérica para tentar bater.
    id_equipamento = paste0("HAUL-", sprintf("%04d", as.numeric(as.factor(id_caminhao_real)))),

    # Perturbação (+- 5%)
    across(starts_with("custo_"), ~ round(.x * runif(n(), 0.95, 1.05), 2)),

    # Total
    custo_total = rowSums(across(starts_with("custo_")))
  ) %>%

  select(data, id_equipamento, tipo_ordem, everything(), -id_caminhao_real)

# --- 4. VALIDAÇÃO ---
glimpse(haul_maint_costs_sn)

# --- 5. SALVAR ---
usethis::use_data(haul_maint_costs_sn, overwrite = TRUE)
fs::dir_create("inst/extdata")
write_csv(haul_maint_costs_sn, "inst/extdata/haul_maint_costs_sn.csv")

message("Dataset de Custos (Baseado na sua lógica de frota) processado!")
