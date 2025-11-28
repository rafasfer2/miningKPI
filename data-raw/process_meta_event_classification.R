## data-raw/process_meta_event_classification.R

library(tidyverse)
library(janitor)
library(usethis)
library(fs)

# --- 1. DADOS BRUTOS (Inseridos diretamente) ---
# Copiei exatamente a tabela que você enviou
texto_dados <- "
Evento;Origem;Impacto_Disp;Impacto_Util;Classificacao
Falta de Energia;Falha na Concessionária ou Racionamento de Energia;;x;HOE
Falta de Energia;Desligamento para manobras operacionais;;x;HOI
Falta de Energia;Desligamento para manutenção preventiva;x;;HMP
Falta de Energia;Qualquer falha no sistema interno de energia;x;;HMNP
Sensor identificou falha;Existência de falha no Equipamento;x;;HMNP
Sensor identificou falha;Existência de perda Operacional;;x;HOI
Sensor identificou falha;Existência de perda no Processo;;x;HOI
Tempo de reboque;Após falha do Equipamento;x;;HMNP
Falta de Combustível;Problemas internos para fornecer;;x;HOI
Falta de Combustível;Indisponibilidade do Mercado Externo;;x;HOE
Falta de Combustível;Falha clara do Equipamento;x;;HMNP
Falta de Combustível;Perda no Processo (operar até acabar);;x;HOI
Sobrecarga (Térmico Atuado);Existência de falha no Equipamento;x;;HMNP
Sobrecarga (Térmico Atuado);Existência de perda Operacional;;x;HOI
Sobrecarga (Térmico Atuado);Existência de perda no Processo;;x;HOI
Sensor atuado por limpeza;Sensor foi danificado;x;;HMNP
Sensor atuado por limpeza;Sensor foi atuado;;x;HOI
Instrumento de proteção;Existência de falha no Equipamento;x;;HMNP
Instrumento de proteção;Existência de perda Operacional;;x;HOI
Instrumento de proteção;Existência de perda no Processo;;x;HOI
Período de resfriamento;Manutenção Corretiva;x;;HMNP
Período de resfriamento;Manutenção Preventiva;x;;HMP
Ramp up / Aquecimento;Após perda Operacional;;x;HTNP
Ramp up / Aquecimento;Após falha Externa a Vale;;x;HOE
Ramp up / Aquecimento;Após Manutenção Corretiva;;x;HOI
Ramp up / Aquecimento;Após Manutenção Preventiva;;x;HOI
Ramp up / Aquecimento;Problemas de Manutenção afetando Setup;x;;HMNP
Ramp up / Aquecimento;Após falha Externa a Área;;x;HTNP
Testes a pedido da operação;Considerar falha de manutenção;x;;HMNP
Testes a pedido da operação;Existência de perda Operacional;;x;HOI
Testes a pedido da operação;Existência de perda no Processo;;x;HOI
Parada sem causa aparente;Existência de falha no Equipamento;x;;HMNP
Parada sem causa aparente;Existência de perda Operacional;;x;HOI
Parada sem causa aparente;Existência de perda no Processo;;x;HOI
Parada sem causa aparente;Existência de falha Externa a Vale;;x;HOE
Falha Intermitente;Existência de falha no Equipamento;x;;HMNP
Falha Intermitente;Existência de perda Operacional;x;;HMNP
Falha Intermitente;Existência de perda no Processo;x;;HMNP
Acidentes com perda de função;Existência de falha no Equipamento;x;;HMNP
Acidentes com perda de função;Existência de perda Operacional;x;;HMNP
Acidentes com perda de função;Existência de perda no Processo;x;;HMNP
Parada horário de ponta;Economia de energia;;x;HOI
Falhas de manutenção;Falha de Manutenção;x;;HMNP
Parada programada;Para ajuste de Processo;;x;HOI
Parada programada;Para Manutenção Preventiva;x;;HMP
Parada programada;Para Obra de Ampliação (Engenharia);x;;HMP
Paradas corretivas projetos;Manutenção Corretiva;x;;HMNP
Perdas Operacionais;Sem perda de Função;;x;HOI
Perdas Operacionais;Com perda de Função;x;;HMNP
Aferição vagão INMETRO;Manutenção Preventiva;x;;HMP
Avaria de vagões Cliente;Falha Externa a Vale;x;;HMNP
Retenção no trecho;Acidente no Trecho;x;;HMNP
Vagões imobilizados;Transporte de Carga;;x;HTNP
Reboque locomotiva (areia);Falha Externa a Vale;;x;HOE
Calibragem de pneu;Item de Segurança;x;;HMP
Regulagem de retrovisor;Ajuste de Equipamento;;x;HOI
Troca haste perfuratriz;Fim de Vida Útil por Desgaste;;x;HOI
Troca haste perfuratriz;Existência de falha no Equipamento;x;;HMNP
Troca haste perfuratriz;Existência de perda Operacional;;x;HOI
Deslocamento para oficina;Para Manutenção Corretiva;x;;HMNP
Deslocamento para oficina;Para Manutenção Preventiva;x;;HMP
Falta de pneus;Em Estoque e com falha do Equipamento;x;;HMNP
Falta de pneus;Em Estoque e com parada preventiva;x;;HMP
Falta de pneus;Problemas de Mercado e com falha;x;;HMNP
Falta de pneus;Problemas de Mercado e com preventiva;x;;HMP
Liberação após intervenção;Após Manutenção Corretiva;;x;HOI
Liberação após intervenção;Após Manutenção Preventiva;;x;HOI
Limpeza de Equipamento;Conservação (Lavagem, Cabine, Esteiras);;x;HTNP
Limpeza de Equipamento;Limpeza para Preventiva (Op);x;;HMP
Limpeza de Equipamento;Limpeza para Preventiva (Manut);x;;HMP
Limpeza de Equipamento;Limpeza para Corretiva (Op);x;;HMNP
Limpeza de Equipamento;Limpeza para Corretiva (Manut);x;;HMNP
Manutenção > Acordado;Por perda Operacional;;x;HOI
Manutenção > Acordado;Extrapolação do Tempo Preventiva;x;;HMP
Manutenção de oportunidade;Janela de oportunidade;x;;HMP
Manutenção de oportunidade;Falha Externa - Baixa Demanda;x;;HMP
Manutenção de oportunidade;Fim da Janela e pendência impeditiva;x;;HMP
Deslocamento dep. apoio;Equipamento de apoio em Manutenção;;x;HOI
"

# --- 2. PROCESSAMENTO ---
meta_event_classification <- read_delim(texto_dados, delim = ";", show_col_types = FALSE) %>%
  clean_names() %>%
  mutate(
    # Converter os 'x' em Lógico (TRUE/FALSE)
    impacta_disponibilidade = !is.na(impacto_disp),
    impacta_utilizacao = !is.na(impacto_util),

    # Padronizar Classificação (Upper case)
    classificacao = str_trim(classificacao)
  ) %>%
  select(
    evento,
    origem_causa = origem,
    impacta_disponibilidade,
    impacta_utilizacao,
    classificacao_hora = classificacao
  )

# --- 3. SALVAR ---
glimpse(meta_event_classification)

usethis::use_data(meta_event_classification, overwrite = TRUE)
fs::dir_create("inst/extdata")
write_csv(meta_event_classification, "inst/extdata/meta_event_classification.csv")

message("Metadados de Classificação de Eventos salvos!")
