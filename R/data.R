# --- DADOS DE SERRA NORTE (EVENTOS) ---

#' Log de Turno: Perfuração (Serra Norte)
#'
#' Dados de apontamento de perfuratrizes, segmentados por turno de trabalho.
#' Focados em KPIs de gestão diária (Disponibilidade, Utilização).
#'
#' @format Tibble com registros de eventos por turno:
#' \describe{
#'   \item{id_equipamento}{Identificador anonimizado (DRILL-XXXX).}
#'   \item{data}{Data de referência.}
#'   \item{turno}{Turno de operação.}
#'   \item{duracao_h}{Duração do evento em horas.}
#'   \item{status}{Estado macro (Apto, Parada, Manutenção).}
#'   \item{codigo}{Código numérico do apontamento.}
#' }
"drill_event_sn"

#' Log de Turno: Carga (Serra Norte)
#'
#' Dados de apontamento de escavadeiras e pás carregadeiras.
#' @rdname drill_event_sn
"load_event_sn"

#' Log de Turno: Infraestrutura (Serra Norte)
#'
#' Dados de apontamento de equipamentos de apoio (Tratores, Motoniveladoras, Pipa).
#' @rdname drill_event_sn
"infra_event_sn"

#' Log de Turno: Transporte (Serra Norte)
#'
#' Dados de apontamento de caminhões fora de estrada, segmentados por turno.
#' Ideal para cálculo de OEE e KPIs operacionais diários.
#' Nota: Eventos longos são "quebrados" na virada do turno/dia.
#'
#' @format Tibble com a mesma estrutura de `drill_event_sn`.
"haul_shift_log_sn"

#' Log de Falhas: Transporte (Serra Norte)
#'
#' Dados de eventos de falha contínuos para caminhões fora de estrada.
#' Diferente do log de turno, aqui os eventos **não** são quebrados na virada do dia.
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
#' }
"haul_failure_log_sn"

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
#'   \item{custo_insumos}{Valor gasto em óleo e lubrificantes (R$).}
#'   \item{custo_outros}{Outras despesas.}
#'   \item{custo_total}{Soma dos custos do equipamento naquele mês/tipo de ordem.}
#' }
#' @source Dados internos de ERP, filtrados para a Gerência de Transporte SN.
"haul_maint_costs_sn"
