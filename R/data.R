# ==============================================================================
# DADOS DA MINA A (FERRO GRANDE PORTE - ANTIGA SERRA NORTE)
# ==============================================================================

#' Log de Turno: Perfuração (Mina A)
#'
#' Dados de apontamento de perfuratrizes, segmentados por turno de trabalho.
#' Focados em KPIs de gestão diária (Disponibilidade, Utilização).
#'
#' @format Tibble com registros de eventos por turno:
#' \describe{
#'   \item{id_equipamento}{Identificador anonimizado (DRILL-XXXX).}
#'   \item{data}{Data de referência do apontamento.}
#'   \item{turno}{Turno de operação.}
#'   \item{equipe}{Equipe responsável.}
#'   \item{duracao_h}{Duração do evento em horas.}
#'   \item{status}{Estado macro (Apto, Parada, Manutenção).}
#'   \item{codigo}{Código numérico do apontamento.}
#' }
"drill_event_mine_a"

#' Log de Turno: Carga (Mina A)
#' @rdname drill_event_mine_a
"load_event_mine_a"

#' Log de Turno: Infraestrutura (Mina A)
#' @rdname drill_event_mine_a
"infra_event_mine_a"

#' Log de Turno: Transporte (Mina A)
#'
#' Dados de apontamento de caminhões fora de estrada, segmentados por turno.
#' Ideal para cálculo de OEE e KPIs operacionais diários.
#' @rdname drill_event_mine_a
"haul_shift_log_mine_a"

#' Log de Falhas: Transporte (Mina A)
#'
#' Dados de eventos de falha contínuos para caminhões fora de estrada.
#' Diferente do log de turno, aqui os eventos **NÃO** são quebrados na virada do dia.
#' Fundamental para cálculos precisos de MTBF, MTTR e análises de Confiabilidade.
#'
#' @format Tibble com registros de falhas:
#' \describe{
#'   \item{id_equipamento}{Identificador anonimizado (HAUL-XXXX).}
#'   \item{data_inicio}{Data de início da falha.}
#'   \item{inicio}{Timestamp de início.}
#'   \item{fim}{Timestamp de fim.}
#'   \item{duracao_h}{Duração total real da falha (horas).}
#'   \item{causa}{Descrição da causa da falha.}
#'   \item{categoria}{Categoria da manutenção (HMC, MPNS...).}
#' }
"haul_failure_log_mine_a"

#' Ciclo de Transporte Detalhado (Mina A)
#'
#' Dados "Micro" (ciclo a ciclo) contendo a decomposição de tempos e produção.
#'
#' @format Tibble de viagens:
#' \describe{
#'   \item{id_ciclo}{Identificador sequencial.}
#'   \item{TVV}{Tempo de Viagem Vazio (min).}
#'   \item{TFC}{Tempo de Fila Carga (min).}
#'   \item{TC}{Tempo de Carregamento (min).}
#'   \item{massa_transportada}{Payload (ton).}
#' }
"haul_cycle_mine_a"

#' Histórico de Ordens de Serviço: Transporte (Mina A)
#'
#' Registro detalhado de intervenções com taxonomia (Sistema/Conjunto) e texto.
#'
#' @format Tibble de OS:
#' \describe{
#'   \item{num_ordem}{Número da OS.}
#'   \item{sistema}{Sistema veicular afetado (ex: Motor Diesel).}
#'   \item{problema}{Relato do defeito.}
#'   \item{solucao}{Ação corretiva.}
#' }
"haul_maint_history_mine_a"

#' Histórico de Custos Detalhados (Mina A)
#'
#' Dados financeiros mensais por equipamento individual.
#' @format Tibble mensal:
#' \describe{
#'   \item{data}{Mês de competência.}
#'   \item{custo_total}{Soma dos custos do equipamento.}
#'   \item{custo_pecas}{Valor gasto em materiais.}
#' }
"haul_maint_costs_mine_a"

#' Indicadores Mensais Consolidados (Mina A)
#'
#' KPIs mensais oficiais (Requipam) para diversas frotas.
#' @format Tibble mensal.
"haul_kpi_monthly_mine_a"

#' @rdname haul_kpi_monthly_mine_a
"drill_kpi_monthly_mine_a"

#' @rdname haul_kpi_monthly_mine_a
"load_kpi_monthly_mine_a"

#' @rdname haul_kpi_monthly_mine_a
"infra_kpi_monthly_mine_a"

#' Premissas Orçamentárias Anuais (Mina A)
#'
#' Dados consolidados do orçamento (Budget) anual.
#' @format Tibble mensal:
#' \describe{
#'   \item{DF_plan}{Meta de Disponibilidade Física.}
#'   \item{producao_plan}{Meta de produção.}
#' }
"plan_budget_assumptions_mine_a"

#' Histórico de Manutenção: Tratores (Mina A)
#'
#' Log detalhado de OS de tratores de esteira (Infraestrutura).
#' @format Tibble de eventos.
"maint_track_dozer_mine_a"


# ==============================================================================
# DADOS DA MINA B (FERRO TRADICIONAL - ANTIGA BRUCUTU)
# ==============================================================================

#' Histórico de Performance: Carga (Mina B)
#'
#' Dados diários de escavadeiras seguindo a árvore de tempos padrão (GPV-M).
#' @format Tibble diária:
#' \describe{
#'   \item{produtividade_ht}{Produtividade (t/HT).}
#'   \item{HT}{Horas Trabalhadas Totais.}
#'   \item{HEF}{Horas Efetivas.}
#'   \item{HAO}{Horas de Atraso Operacional.}
#' }
"load_daily_cep_mine_b"

#' Histórico de Performance: Transporte (Mina B)
#'
#' Dados diários de caminhões com engenharia reversa de tempos.
#' @format Tibble diária:
#' \describe{
#'   \item{tkph}{Tonelada-Quilômetro por Hora.}
#'   \item{tempo_ciclo_total}{TTC estimado.}
#' }
"haul_daily_cep_mine_b"

#' Ordens de Serviço: Manutenção (Mina B)
#'
#' Histórico textual de falhas (2021-2022).
#' @format Tibble de eventos.
"maint_orders_mine_b"

#' Log Completo de Paradas (Mina B)
#'
#' Dataset que diferencia Manutenção (HMC) de Ociosidade (HOI).
#' @format Tibble de eventos.
"maint_stops_mine_b"

#' Histórico de Eventos: Caminhão Pipa (Mina B)
#'
#' Log de operações da frota de irrigação.
#' @format Tibble de eventos.
"infra_water_truck_events_mine_b"

#' Plano de Custos: Caminhão Pipa (Mina B)
#' @format Tibble.
"infra_water_truck_cost_plan"

#' Lista de Tarefas: Caminhão Pipa (Mina B)
#' @format Tibble.
"infra_water_truck_task_list"

#' Horímetro: Caminhão Pipa (Mina B)
#' @format Tibble.
"infra_water_truck_hourmeter_mine_b"


# ==============================================================================
# DADOS DA MINA C (COMPLEXO SUDESTE - ANTIGA ITABIRA)
# ==============================================================================

#' Histórico Diário de Transporte (Mina C)
#'
#' Dados consolidados diários da frota de transporte.
#' @format Tibble diária.
"haul_daily_summary_mine_c"

#' Metas Diárias de Transporte (Mina C)
#'
#' Orçamento (Budget) diário para aderência.
#' @format Tibble diária.
"plan_daily_budget_mine_c"

#' Metas Detalhadas de Transporte 2021 (Mina C)
#'
#' Budget com granularidade de tempos de ciclo.
#' @format Tibble diária.
"plan_daily_detailed_2021_mine_c"

#' Histórico de Manutenção Preventiva (Mina C)
#' Case de Otimização de Periodicidade.
#' @format Tibble de eventos.
"maint_truck_events_mine_c"

#' Histórico de Horímetro (Mina C)
#' @format Tibble.
"maint_truck_hourmeter_mine_c"

#' Histórico de Pautas (Mina C)
#' @format Tibble.
"maint_truck_pautas_mine_c"


# ==============================================================================
# METADADOS E TABELAS DE REFERÊNCIA
# ==============================================================================

#' Tabela de Classificação de Eventos (Padrão PNR)
#'
#' Regras de negócio para classificação de horas (HOI, HMC...).
#' @format Tibble.
"meta_event_classification"

#' Dicionário de Termos (PT/EN/ES)
#'
#' Glossário técnico trilíngue.
#' @format Tibble.
"meta_dictionary"
