#' Mine A Loading Events (Base Notation)
#'
#' Um conjunto de dados tidy, em formato longo, representando o processo estocástico de carregamento.
#' Contém os três estados fundamentais para cada composição atendida pela unidade de carga.
#'
#' @format Um tibble com 9 colunas:
#' \describe{
#'   \item{cycle_id}{Identificador único do ciclo de carregamento, permitindo a conexão com o banco de ciclos.}
#'   \item{first_time}{Timestamp de início do evento específico (maneuver, loading ou idle).}
#'   \item{exit_time}{Timestamp de término do evento específico (Exit Time - Ti).}
#'   \item{load_fleet}{Classificação técnica internacional do equipamento de carga (ex: Electric Shovel).}
#'   \item{load_id}{Identificador anonimizado da unidade de carregamento.}
#'   \item{haul_id}{Identificador anonimizado da unidade de transporte atendida (NA para estados idle).}
#'   \item{origin}{Localização da frente de lavra (Bench, Stockpile ou Rehandling).}
#'   \item{material}{Tipo de material movimentado: Ore (Minério) ou Waste (Estéril).}
#'   \item{payload}{Massa carregada (Li) em toneladas. Registrada apenas durante o evento 'loading'.}
#'   \item{event_type}{O estado operacional atual: maneuver (manobra), loading (carga) ou idle (ocioso).}
#'   \item{duration_min}{Duração do evento em minutos decimais.}
#' }
"load_events_mine_a"

#' Mine A Loading Cycles (Aggregated)
#'
#' Um conjunto de dados em formato largo onde cada linha representa um ciclo completo de carregamento.
#'
#' @format Um tibble com 15 colunas:
#' \describe{
#'   \item{cycle_id}{Identificador sequencial único do ciclo por escavadeira.}
#'   \item{first_time}{Timestamp de início do ciclo (início da manobra).}
#'   \item{exit_time}{Timestamp de término do ciclo (partida do caminhão).}
#'   \item{duration_min}{Tempo total do ciclo (Xi) em minutos, calculado pela soma de Mi, Di e Oi.}
#'   \item{load_fleet}{Categoria da frota de carga (ex: Hydraulic Excavator - Large Class).}
#'   \item{haul_fleet}{Categoria da frota de transporte atendida (ex: 240t Class A).}
#'   \item{load_id}{ID anonimizado da unidade de carga.}
#'   \item{haul_id}{ID anonimizado do caminhão atendido.}
#'   \item{origin}{Local de origem do material.}
#'   \item{material}{Tipo de material (Ore/Waste).}
#'   \item{payload}{Total de toneladas carregadas no ciclo.}
#'   \item{load_status}{Status qualitativo da carga (Target Met, Acceptable, Underload, etc.).}
#'   \item{m_time}{Duração específica da manobra de posicionamento (Mi).}
#'   \item{l_time}{Duração específica do carregamento efetivo (Di).}
#'   \item{i_time}{Duração da ociosidade operacional aguardando transporte (Oi).}
#' }
"load_cycles_mine_a"

#' Mine A Hauling Events (Full Journey)
#'
#' Conjunto de dados detalhado contendo a jornada de 7 eventos do ciclo de transporte.
#' Abrange desde a fila no carregamento até a conclusão da viagem de retorno.
#'
#' @format Um tibble em formato longo:
#' \describe{
#'   \item{cycle_id}{ID de referência para o ciclo de transporte correspondente.}
#'   \item{load_id}{ID da unidade de carga que realizou o atendimento.}
#'   \item{haul_id}{ID do caminhão que realiza o transporte.}
#'   \item{haul_fleet}{Classificação técnica da frota de transporte (ex: 320t Class B).}
#'   \item{origin}{Ponto de extração/origem.}
#'   \item{destination}{Ponto de descarga (Crusher, Waste Dump, Stockpile, etc.).}
#'   \item{event_type}{Um dos 7 estados: queue_at_load, maneuver_at_load, loading, travel_full, queue_at_dump, maneuver_at_dump, dumping.}
#'   \item{duration_min}{Tempo despendido em cada estado individual em minutos.}
#'   \item{payload}{Massa transportada em toneladas.}
#' }
"haul_events_mine_a"

#' Mine A Hauling Cycles (Performance & Scale)
#'
#' Dataset consolidado onde cada linha representa uma viagem completa, incluindo variáveis
#' de distância (DMT), conformidade de balança e fatores de carga.
#'
#' @format Um tibble em formato largo com as métricas de performance:
#' \describe{
#'   \item{cycle_id}{Identificador único do ciclo de transporte.}
#'   \item{first_time}{Início da jornada (entrada na fila de carga).}
#'   \item{exit_time}{Término da jornada (conclusão da descarga).}
#'   \item{duration_min}{Duração total da viagem (Xj).}
#'   \item{load_fleet}{Frota que realizou o carregamento.}
#'   \item{haul_fleet}{Frota que realizou o transporte (segregada por fabricante/classe).}
#'   \item{payload}{Massa carregada registrada pelo sensor do caminhão (Tons).}
#'   \item{scale_weight}{Massa real registrada pela balança fixa de conferência.}
#'   \item{scale_ok}{Variável lógica indicando se a pesagem da balança foi validada.}
#'   \item{load_status}{Classificação de conformidade da carga.}
#'   \item{load_factor}{Fator de preenchimento/enchimento da caçamba.}
#'   \item{dmt_full}{Distância média de transporte carregado (km).}
#'   \item{dmt_empty}{Distância média de transporte vazio (km).}
#'   \item{dmt_total}{Soma das distâncias de ida e volta (km).}
#'   \item{m_time}{Tempo consolidado de manobras (Carga + Descarga).}
#'   \item{l_time}{Tempo de carregamento efetivo.}
#'   \item{d_time}{Tempo de descarga efetiva.}
#'   \item{q_time}{Tempo total em fila (Carga + Descarga).}
#' }
"haul_cycles_mine_a"
