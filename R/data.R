# ==============================================================================
# DADOS DE SERRA NORTE (EVENTOS MICRO)
# ==============================================================================

#' Log de Turno: Perfuração (Serra Norte)
#'
#' Dados de apontamento de perfuratrizes, segmentados por turno de trabalho.
#' Focados em KPIs de gestão diária (Disponibilidade, Utilização).
#' Eventos que atravessam a virada do turno são fragmentados para garantir o fechamento de 24h.
#'
#' @format Tibble com registros de eventos por turno:
#' \describe{
#'   \item{id_equipamento}{Identificador anonimizado (DRILL-XXXX).}
#'   \item{data}{Data de referência do apontamento.}
#'   \item{turno}{Turno de operação.}
#'   \item{equipe}{Equipe responsável.}
#'   \item{inicio}{Timestamp de início do estado.}
#'   \item{fim}{Timestamp de fim do estado.}
#'   \item{duracao_h}{Duração do evento em horas (fracionado por turno).}
#'   \item{status}{Estado macro (Apto, Parada, Manutenção).}
#'   \item{codigo}{Código numérico do apontamento.}
#'   \item{categoria}{Categoria da hora (HEF, HMC, etc.).}
#'   \item{descricao}{Descrição textual do apontamento.}
#' }
"drill_event_sn"

#' Log de Turno: Carga (Serra Norte)
#'
#' Dados de apontamento de escavadeiras e pás carregadeiras.
#' Segue a mesma estrutura de fragmentação por turno.
#' @rdname drill_event_sn
"load_event_sn"

#' Log de Turno: Infraestrutura (Serra Norte)
#'
#' Dados de apontamento de equipamentos de apoio (Tratores, Motoniveladoras, Pipa).
#' Segue a mesma estrutura de fragmentação por turno.
#' @rdname drill_event_sn
"infra_event_sn"

#' Log de Turno: Transporte (Serra Norte)
#'
#' Dados de apontamento de caminhões fora de estrada, segmentados por turno.
#' Ideal para cálculo de OEE e KPIs operacionais diários.
#' @rdname drill_event_sn
"haul_shift_log_sn"

#' Log de Falhas: Transporte (Serra Norte)
#'
#' Dados de eventos de falha contínuos para caminhões fora de estrada.
#' Diferente do log de turno, aqui os eventos **NÃO** são quebrados na virada do dia.
#' Fundamental para cálculos precisos de MTBF, MTTR e análises de Confiabilidade (Weibull/NHPP).
#'
#' @format Tibble com registros de falhas:
#' \describe{
#'   \item{id_equipamento}{Identificador anonimizado (HAUL-XXXX).}
#'   \item{data_inicio}{Data de início da falha.}
#'   \item{inicio}{Timestamp de início.}
#'   \item{fim}{Timestamp de fim.}
#'   \item{duracao_h}{Duração total real da falha (horas).}
#'   \item{causa}{Descrição da causa da falha (se disponível).}
#'   \item{categoria}{Categoria da manutenção (HMC, MPNS...).}
#'   \item{status}{Status do equipamento durante a falha.}
#' }
"haul_failure_log_sn"

# ==============================================================================
# DADOS DE SERRA NORTE (FINANCEIRO E KPI MENSAL)
# ==============================================================================

#' Histórico de Custos Detalhados: Transporte (Serra Norte)
#'
#' Dados financeiros mensais por equipamento individual (Caminhões Fora de Estrada).
#' Diferente do sumário de frota, este dataset permite análises de custo específico
#' por ativo e por tipo de ordem (Preventiva vs. Corretiva).
#'
#' @format Tibble com registros mensais:
#' \describe{
#'   \item{data}{Mês de competência.}
#'   \item{id_equipamento}{Identificador anonimizado do caminhão (HAUL-XXXX).}
#'   \item{tipo_ordem}{Classificação da Ordem (ex: YPM=Preventiva, YEM=Emergencial).}
#'   \item{custo_pecas}{Valor gasto em peças e materiais (R$).}
#'   \item{custo_servicos_mo}{Valor gasto em serviços e mão de obra (R$).}
#'   \item{custo_combustivel}{Valor gasto em óleo diesel e lubrificantes (R$).}
#'   \item{custo_pneus}{Custos específicos de gestão de pneus (R$).}
#'   \item{custo_outros}{Outras despesas administrativas ou não categorizadas.}
#'   \item{custo_total}{Soma dos custos do equipamento naquele mês/tipo de ordem.}
#' }
#' @source Dados internos de ERP, filtrados para a Gerência de Transporte SN.
"haul_maint_costs_sn"

#' Indicadores Mensais de Manutenção e Produção (Requipam)
#'
#' Série histórica mensal consolidada dos principais KPIs da frota de transporte (Serra Norte).
#' Este dataset provém dos relatórios gerenciais ("Requipam") e contém os cálculos
#' oficiais de MTBF e MTTR utilizados pela gestão da mina, além dos dados de produção física.
#'
#' @format Tibble com registros mensais:
#' \describe{
#'   \item{data}{Mês de referência.}
#'   \item{id_equipamento}{Identificador anonimizado do caminhão.}
#'   \item{frota}{Modelo do equipamento (ex: CAT 793D).}
#'   \item{DF}{Disponibilidade Física registrada (%).}
#'   \item{UF}{Utilização Física registrada (%).}
#'   \item{MTBF}{Tempo Médio Entre Falhas (horas).}
#'   \item{MTTR}{Tempo Médio Para Reparo (horas).}
#'   \item{num_falhas}{Número de intervenções corretivas (NIC).}
#'   \item{producao_total}{Total movimentado no mês (ton).}
#'   \item{HC, HM, HMC, HMP...}{Horas de apontamento consolidadas.}
#' }
#' @source Relatórios gerenciais internos (Requipam).
"haul_kpi_monthly_sn"

#' Consolidado Mensal de Transporte: Horas Reais + Produção
#'
#' O dataset "Definitivo" para análises mensais no livro.
#' Este conjunto de dados é um híbrido (Join) que combina o melhor de dois mundos:
#' 1. As **Horas** (HM, HEF, HAO) foram recalculadas a partir dos apontamentos brutos
#' (`haul_shift_log_sn`) para garantir precisão decimal e consistência matemática.
#' 2. A **Produção** (toneladas) foi importada do relatório gerencial (`haul_kpi_monthly_sn`),
#' já que o sistema de despacho nem sempre possui balança calibrada.
#'
#' @format Tibble mensal por equipamento:
#' \describe{
#'   \item{mes}{Mês de referência.}
#'   \item{id_equipamento}{ID anonimizado.}
#'   \item{DF_final}{Disponibilidade Física recalculada pelo R (%).}
#'   \item{UF_final}{Utilização Física recalculada pelo R (%).}
#'   \item{produtividade_media}{Produtividade física (ton/h_efetiva).}
#'   \item{producao_total}{Massa transportada em ton (Origem: Requipam).}
#'   \item{num_falhas}{Número de falhas (Origem: Requipam).}
#'   \item{HM_calc}{Horas de Manutenção somadas do log de eventos.}
#'   \item{HEF_calc}{Horas Efetivas somadas do log de eventos.}
#'   \item{HAO_calc}{Horas de Atraso Operacional somadas do log de eventos.}
#' }
"haul_monthly_consolidated_sn"

# ==============================================================================
# DADOS DE BRUCUTU (VARIABILIDADE / CEP / GPV-M)
# ==============================================================================

#' Histórico de Performance: Frota de Carga (Padrão GPV-M)
#'
#' Dados diários de operação de escavadeiras e pás carregadeiras (Brucutu).
#' A árvore de tempos foi recalculada seguindo o padrão de mercado (GPV-M) para
#' garantir o fechamento matemático: HT = (HEF + HAO) + (HTD + HTI).
#'
#' @format Tibble diária:
#' \describe{
#'   \item{data}{Data de referência.}
#'   \item{turno}{Turno de operação (1 a 4).}
#'   \item{id_equipamento}{Identificador anonimizado (ESC-XX ou PA-XX).}
#'   \item{periodo_climatico}{Classificação do turno (Chuvoso/Seco).}
#'   \item{produtividade_ht}{Produtividade baseada nas horas trabalhadas (t/HT).}
#'   \item{massa_carregada}{Massa total movimentada no turno (ton).}
#'   \item{carga_media}{Carga média por caçambada/ciclo (ton).}
#'   \item{num_ciclos}{Número de ciclos de carga realizados.}
#'   \item{tmc}{Tempo Médio de Carregamento (ciclo).}
#'   \item{HT}{Horas Trabalhadas Totais (Soma de HTP e HTNP).}
#'   \item{HTP}{Horas Trabalhadas Produtivas (Soma de HEF e HAO).}
#'   \item{HTNP}{Horas Trabalhadas Não Produtivas (Soma de HTD e HTI).}
#'   \item{HEF}{Horas Efetivas (Tempo real produzindo).}
#'   \item{HAO}{Horas de Atraso Operacional (Perdas de processo).}
#' }
#' @source Dados internos anonimizados (2021), processados com engenharia reversa de tempos.
"load_daily_cep_br"

#' Histórico de Performance: Transporte (Padrão GPV-M)
#'
#' Dados diários de caminhões fora de estrada (Brucutu). Este dataset é rico pois reconstrói
#' o Tempo de Ciclo Total (TTC) e a Árvore de Horas (HT, HEF) a partir de variáveis
#' isoladas, permitindo exercícios de engenharia reversa e análise de variabilidade.
#'
#' @format Tibble diária:
#' \describe{
#'   \item{produtividade_ht}{Indicador de gestão: Produção / Horas Trabalhadas (t/h).}
#'   \item{tkph}{Tonelada-Quilômetro por Hora (Indicador de Pneus).}
#'   \item{dmt}{Distância Média de Transporte (km).}
#'   \item{vel_global}{Velocidade média global (km/h).}
#'   \item{vel_cheio}{Velocidade média carregado (km/h).}
#'   \item{vel_vazio}{Velocidade média vazio (km/h).}
#'   \item{tempo_ciclo_total}{Soma de Tempos Fixos + Viagens (estimado via velocidade).}
#'   \item{tempo_fixo}{Soma de filas, manobras e operações de carga/descarga.}
#'   \item{tempo_viagem_cheio}{Tempo de viagem carregado calculado (min).}
#'   \item{tempo_viagem_vazio}{Tempo de viagem vazio calculado (min).}
#'   \item{HT}{Horas Trabalhadas (HEF + HAO + HTNP).}
#'   \item{HEF}{Horas Efetivas (recalculado via UF e Atrasos).}
#' }
"haul_daily_cep_br"

# ==============================================================================
# METADADOS E TABELAS DE REFERÊNCIA
# ==============================================================================

#' Tabela de Classificação de Eventos (Padrão PNR)
#'
#' Tabela de referência que define como cada tipo de evento deve ser classificado
#' na árvore de horas (Disponibilidade vs. Utilização). Baseada na revisão 09 da tabela de apropriação.
#'
#' @format Tibble com regras de negócio:
#' \describe{
#'   \item{evento}{Nome genérico do evento (ex: Falta de Energia).}
#'   \item{origem_causa}{Contexto específico (ex: Falha interna vs. Concessionária).}
#'   \item{impacta_disponibilidade}{Booleano: Se TRUE, penaliza a Disponibilidade (DF).}
#'   \item{impacta_utilizacao}{Booleano: Se TRUE, penaliza a Utilização (UF).}
#'   \item{classificacao_hora}{Sigla da hora resultante (HOE, HOI, HMP, HMNP, HTNP).}
#' }
#' @details
#' Use esta tabela para ensinar a diferença entre uma parada que afeta a manutenção
#' (HMNP/HMP) e uma parada que é responsabilidade da operação (HOI/HTNP).
#'
#' * **HMNP:** Hora de Manutenção Não Planejada (Corretiva).
#' * **HMP:** Hora de Manutenção Planejada (Preventiva).
#' * **HOI:** Hora Ociosa Interna (Perda Operacional).
#' * **HOE:** Hora Ociosa Externa (Fatores exógenos).
#' * **HTNP:** Hora Trabalhada Não Produtiva (Apoio).
#'
#' @source Tabela de apropriação de eventos_rev.09.
"meta_event_classification"

# ==============================================================================
# DADOS DE INFRAESTRUTURA E APOIO
# ==============================================================================

#' Histórico de Manutenção: Tratores de Esteira (Serra Norte)
#'
#' Log detalhado de ordens de serviço e intervenções em tratores de esteira (Infraestrutura).
#' Contém a descrição textual do problema e solução, permitindo análise de falhas
#' em equipamentos de apoio.
#'
#' @format Tibble de eventos:
#' \describe{
#'   \item{id_equipamento}{Identificador anonimizado (TRAT-XXX).}
#'   \item{inicio}{Timestamp de início da manutenção.}
#'   \item{duracao_h}{Duração da intervenção em horas.}
#'   \item{categoria}{Tipo de hora (HMC, MPNS, HAC...).}
#'   \item{sistema}{Sistema afetado (Motor, Material Rodante, Lâmina...).}
#'   \item{problema}{Descrição do defeito relatado.}
#'   \item{solucao}{Descrição da atividade realizada.}
#' }
#' @source Dados internos de manutenção de infraestrutura (Carajás).
"maint_track_dozer_sn"

# ==============================================================================
# DADOS DE ITABIRITO (CASE: OTIMIZAÇÃO DE PREVENTIVA)
# ==============================================================================

#' Histórico de Manutenção: Caminhões Itabirito (Case Preventiva)
#'
#' Log de eventos de manutenção focado em um estudo de otimização de periodicidade
#' (Preventiva de 250h/500h). Contém flag indicando revisões sistemáticas.
#'
#' @format Tibble de eventos:
#' \describe{
#'   \item{id_equipamento}{Identificador anonimizado (TR-IT-XX).}
#'   \item{duracao_h}{Duração da parada.}
#'   \item{categoria}{HMC (Corretiva) ou MPS (Preventiva).}
#'   \item{horimetro_evento}{Leitura do horímetro no momento da ordem.}
#'   \item{is_preventiva}{Booleano indicando se foi uma revisão programada.}
#' }
"maint_truck_events_it"

#' Histórico de Horímetro: Caminhões Itabirito
#'
#' Leitura diária dos horímetros para cálculo de idade operacional (Weibull/NHPP).
#' @rdname maint_truck_events_it
"maint_truck_hourmeter_it"

#' Histórico de Pautas: Caminhões Itabirito
#'
#' Registro das revisões programadas (ex: 500h, 1000h) realizadas.
#' @rdname maint_truck_events_it
"maint_truck_pautas_it"

# ==============================================================================
# DADOS DE INFRAESTRUTURA (CAMINHÃO PIPA / IRRIGAÇÃO)
# ==============================================================================

#' Histórico de Eventos: Caminhão Pipa (Brucutu)
#'
#' Log de operações e manutenções da frota de irrigação (Infraestrutura).
#' Focado no estudo de otimização de periodicidade de preventiva.
#'
#' @format Tibble de eventos:
#' \describe{
#'   \item{id_equipamento}{Identificador anonimizado (PIPA-XX).}
#'   \item{duracao_h}{Duração do evento.}
#'   \item{categoria}{HMC, MPS, etc.}
#' }
"infra_water_truck_events_br"

#' Plano de Custos de Preventiva (Caminhão Pipa)
#'
#' Lista de peças e custos associados a cada tipo de revisão (300h, 600h...).
#' Permite calcular o custo total de cada estratégia de manutenção.
#' @format Tibble.
"infra_water_truck_cost_plan"

#' Lista de Tarefas de Manutenção (Caminhão Pipa)
#'
#' Detalhamento das atividades executadas em cada revisão (check-list).
#' @format Tibble.
"infra_water_truck_task_list"

#' Horímetro Diário: Caminhão Pipa
#'
#' Leitura de horímetro para cálculo de idade operacional.
#' @format Tibble.
"infra_water_truck_hourmeter_br"

# ==============================================================================
# DADOS DE ITABIRA (PLANEJAMENTO E KPI)
# ==============================================================================

#' Histórico Diário de Transporte (Itabira)
#'
#' Dados consolidados diários da frota de transporte (Mina C).
#' Contém KPIs de disponibilidade, utilização e produção recalculados com lógica GPV-M.
#'
#' @format Tibble diária:
#' \describe{
#'   \item{data}{Data de referência.}
#'   \item{id_equipamento}{Identificador anonimizado (TR-IT-XX).}
#'   \item{DF}{Disponibilidade Física (%).}
#'   \item{produtividade_ht}{Produtividade (t/HT).}
#'   \item{producao_total}{Massa transportada (ton).}
#'   \item{HEF}{Horas Efetivas.}
#'   \item{HAO}{Horas de Atraso Operacional.}
#' }
"haul_daily_summary_it"

#' Metas Diárias de Transporte (Itabira)
#'
#' Orçamento (Budget) diário para a frota de transporte.
#' Deve ser cruzado com `haul_daily_summary_it` para análise de aderência (Real x Meta).
#'
#' @format Tibble diária:
#' \describe{
#'   \item{data}{Data da meta.}
#'   \item{DF_plan}{Meta de Disponibilidade (%).}
#'   \item{producao_plan}{Meta de Produção (ton).}
#'   \item{num_caminhoes_plan}{Dimensionamento de frota previsto.}
#' }
"plan_daily_budget_it"

#' Metas Detalhadas de Transporte 2021 (Itabira)
#'
#' Conjunto de dados de planejamento (Budget) com granularidade de tempos de ciclo.
#' Ideal para comparar não apenas se a meta de produção foi batida, mas *por que*
#' (ex: a meta de fila era 2min e o realizado foi 5min).
#'
#' @format Tibble diária:
#' \describe{
#'   \item{data}{Dia de referência da meta.}
#'   \item{meta_tempo_carregamento}{Meta de tempo de carregamento (min).}
#'   \item{meta_tempo_fila_carga}{Meta de tempo de fila (min).}
#'   \item{meta_vel_global}{Meta de velocidade média (km/h).}
#'   \item{DF_plan}{Meta de Disponibilidade Física.}
#' }
#' @source Dados internos de planejamento de lavra (2021).
"plan_daily_detailed_2021_it"

#' Ciclo de Transporte Detalhado (Serra Norte)
#'
#' Dados "Micro" (evento a evento) de cada viagem realizada pelos caminhões.
#' Contém a decomposição completa dos tempos (Vazio, Fila, Carga, Cheio, Bascula),
#' permitindo análises granulares de gargalos e histogramas de carga.
#'
#' @format Tibble com registros de viagens:
#' \describe{
#'   \item{id_ciclo}{Identificador sequencial da viagem.}
#'   \item{TVV}{Tempo de Viagem Vazio (min).}
#'   \item{TFC}{Tempo de Fila na Carga (min).}
#'   \item{TMC}{Tempo de Manobra na Carga (min).}
#'   \item{TC}{Tempo de Carregamento (min).}
#'   \item{TVC}{Tempo de Viagem Cheio (min).}
#'   \item{TFB}{Tempo de Fila no Basculamento (min).}
#'   \item{TMB}{Tempo de Manobra no Basculamento (min).}
#'   \item{TB}{Tempo de Basculamento (min).}
#'   \item{massa_transportada}{Carga útil (Payload) em toneladas.}
#'   \item{tkph_viagem}{TKPH realizado nesta viagem específica.}
#' }
#' @source Sistema de Despacho Eletrônico (Modular/Jigsaw), anonimizado.
"haul_cycle_sn"
