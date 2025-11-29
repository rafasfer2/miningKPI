## data-raw/process_load_daily_cep_br.R

library(tidyverse)
library(readxl)
library(janitor)
library(fs)
library(lubridate)
library(usethis)

# --- 1. CONFIGURAÇÃO ---
caminho_real <- "K:/Meu Drive/Dados_Confidenciais/frota_carga_cep_2021.xlsx"

if (!file.exists(caminho_real)) {
  stop("Arquivo não encontrado! Verifique se o nome é 'frota_carga_cep_2021.xlsx'")
}

# --- 2. LEITURA DA ABA "HAO" (Dados Climáticos/Reais) ---
# Transforma a tabela dinâmica (turnos 1, 2, 3, 4 nas colunas) em tabela vertical
dados_hao <- read_excel(caminho_real, sheet = "HAO") %>%
  clean_names() %>%
  pivot_longer(
    cols = matches("^[0-9]+$|^x[0-9]+$"),
    names_to = "turno_char",
    values_to = "hao_real"
  ) %>%
  mutate(
    turno = as.numeric(str_remove(turno_char, "x")),
    data = as.Date(data)
  ) %>%
  select(data, frota, turno, periodo_climatico = periodo, hao_real)

# --- 3. LEITURA DA ABA "DADOS" (Principal) ---
dados_principal <- read_excel(caminho_real, sheet = "dados") %>%
  clean_names()

# --- 4. JUNÇÃO E CÁLCULOS (LÓGICA GPV-M BLINDADA) ---
set.seed(555)

load_daily_cep_br <- dados_principal %>%
  # Prepara chaves para o join
  mutate(data = as.Date(data), turno = as.numeric(id_turno)) %>%
  # Cruza com os dados de HAO (Chuva/Seco)
  left_join(dados_hao, by = c("data", "frota", "turno")) %>%

  # === ENGENHARIA DE TEMPOS (GPV-M) ===
  mutate(
    # 1. Base: Turno Fixo de 6 horas
    HC_calc = 6,

    # 2. Disponibilidade (HD) e Manutenção (HM)
    # HD = %DF do HC
    HD_calc = (df / 100) * HC_calc,
    HM_calc = HC_calc - HD_calc,

    # 3. Utilização (HT) e Ociosidade (HO)
    # HT = %UF do HD
    HT_calc = (uf / 100) * HD_calc,
    HO_calc = HD_calc - HT_calc,

    # 4. Detalhamento da HT (HTP e HTNP)
    # HT = HTP + HTNP
    # TRAVA DE SEGURANÇA 1: O HTNP informado não pode ser maior que o HT calculado.
    # Se for maior, limitamos ao valor de HT (HTP vira 0).
    HTNP_input = coalesce(htnp, 0),
    HTNP_final = pmin(HTNP_input, HT_calc),

    HTP_calc = HT_calc - HTNP_final,

    # 5. Detalhamento da HTP (HEF e HAO)
    # HTP = HEF + HAO
    # TRAVA DE SEGURANÇA 2: O HAO não pode ser maior que o HTP disponível.
    HAO_input = coalesce(hao_real, 0),
    HAO_final = pmin(HAO_input, HTP_calc),

    HEF_calc = HTP_calc - HAO_final,

    # 6. Produção e Produtividade
    # Definição do usuário: Produtividade = Produção / HT
    # Logo: Produção Calculada = Produtividade * HT
    producao_calc = produtividade * HT_calc,

    # 7. Carga Média
    # Evita divisão por zero
    viagens_val = ifelse(coalesce(viagens_validas, 0) == 0, 1, viagens_validas),
    carga_media_calc = producao_calc / viagens_val,

    # 8. Validação (Check deve ser sempre ZERO ou muito próximo de zero)
    # HT - (HEF + HAO + HTNP)
    check_soma = HT_calc - (HEF_calc + HAO_final + HTNP_final)
  ) %>%

  # --- MAPEAMENTO FINAL E SELEÇÃO ---
  transmute(
    # Identificação
    data = data,
    turno = turno,
    periodo_climatico = periodo_climatico,
    id_equipamento_real = frota,

    # Indicadores de Gestão
    DF = df,
    UF = uf,
    produtividade_ht = produtividade,

    # Produção Física
    massa_carregada = producao_calc,
    carga_media = carga_media_calc,
    num_ciclos = viagens_validas,

    # Tempos Médios (Ciclo)
    tmc = carregamento,
    tempo_manobra = manobra,

    # Árvore de Horas GPV-M (Consistente)
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
    # Classificação
    tipo_equipamento = case_when(
      str_detect(id_equipamento_real, "L1850") ~ "Pa Carregadeira",
      TRUE ~ "Escavadeira"
    ),

    # Mascarar Nomes (ESC-01, PA-01...)
    id_equipamento = paste0(ifelse(tipo_equipamento == "Escavadeira", "ESC-", "PA-"),
                            sprintf("%02d", as.numeric(as.factor(id_equipamento_real)))),

    # Deslocar Datas (-2 anos)
    data = data - years(2),

    # Perturbação Numérica (+- 1%)
    # Protege os dados reais mantendo as correlações
    across(c(DF, UF, produtividade_ht, massa_carregada, HC, HM, HT, HEF),
           ~ .x * runif(n(), 0.99, 1.01)),

    # Arredondamento
    across(where(is.numeric), ~ round(.x, 2))
  ) %>%

  select(-id_equipamento_real, -tipo_equipamento) %>%

  # Filtro de consistência: Remove dias/turnos parados (DF vazio ou HC zero)
  filter(!is.na(DF), HC > 0)

# --- 5. SALVAR ---
glimpse(load_daily_cep_br)

usethis::use_data(load_daily_cep_br, overwrite = TRUE)
fs::dir_create("inst/extdata")
write_csv(load_daily_cep_br, "inst/extdata/load_daily_cep_br.csv")

message("Dataset 'load_daily_cep_br' (Carga Brucutu) processado e validado!")
