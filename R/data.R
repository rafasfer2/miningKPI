#' Mine A Loading Events (Base Notation) / Eventos de Carregamento - Mina A
#'
#' English: A tidy, long-format dataset representing the stochastic loading process.
#' It contains the three fundamental states for each composition served by the loading unit.
#'
#' Português: Um conjunto de dados tidy, em formato longo, representando o processo
#' estocástico de carregamento. Contém os três estados fundamentais para cada
#' composição atendida pela unidade de carga.
#'
#' @format A tibble with 11 columns / Um tibble com 11 colunas:
#' \describe{
#'   \item{cycle_id}{Unique identifier for the loading cycle / Identificador único do ciclo de carregamento.}
#'   \item{first_time}{Start timestamp of the event / Timestamp de início do evento específico.}
#'   \item{exit_time}{End timestamp of the event ($T_i$) / Timestamp de término do evento específico.}
#'   \item{load_fleet}{Technical equipment class / Classificação técnica internacional do equipamento de carga.}
#'   \item{load_id}{Anonymized loading unit ID / Identificador anonimizado da unidade de carregamento.}
#'   \item{haul_id}{Anonymized hauling unit ID / Identificador anonimizado da unidade de transporte atendida.}
#'   \item{origin}{Loading location / Localização da frente de lavra (Bench, Stockpile ou Rehandling).}
#'   \item{material}{Type of material: Ore or Waste / Tipo de material movimentado: Minério ou Estéril.}
#'   \item{payload}{Loaded mass ($L_i$) in tons / Massa carregada em toneladas.}
#'   \item{event_type}{Operational state: maneuver, loading, or idle / Estado operacional: manobra, carga ou ocioso.}
#'   \item{duration_min}{Event duration in decimal minutes / Duração do evento em minutos decimais.}
#' }
"load_events_mine_a"

#' Mine A Loading Cycles (Aggregated) / Ciclos de Carregamento - Mina A
#'
#' English: Aggregated dataset where each row represents a complete loading cycle ($X_i$).
#'
#' Português: Um conjunto de dados em formato largo onde cada linha representa um
#' ciclo completo de carregamento.
#'
#' @format A tibble with 15 columns / Um tibble com 15 colunas:
#' \describe{
#'   \item{cycle_id}{Unique sequential cycle identifier / Identificador sequencial único do ciclo por escavadeira.}
#'   \item{first_time}{Cycle start timestamp (maneuver start) / Timestamp de início do ciclo (início da manobra).}
#'   \item{exit_time}{Cycle end timestamp (truck departure) / Timestamp de término do ciclo (partida do caminhão).}
#'   \item{duration_min}{Total cycle time ($X_i$) / Tempo total do ciclo em minutos (soma de Mi, Di e Oi).}
#'   \item{load_fleet}{Loading fleet category / Categoria da frota de carga.}
#'   \item{haul_fleet}{Hauling fleet category / Categoria da frota de transporte atendida.}
#'   \item{load_id}{Anonymized loading unit ID / ID anonimizado da unidade de carga.}
#'   \item{haul_id}{Anonymized hauling unit ID / ID anonimizado do caminhão atendido.}
#'   \item{origin}{Material origin location / Local de origem do material.}
#'   \item{material}{Material type (Ore/Waste) / Tipo de material (Minério/Estéril).}
#'   \item{payload}{Total cycle tonnage / Total de toneladas carregadas no ciclo.}
#'   \item{load_status}{Qualitative load status / Status qualitativo da carga (Target Met, Underload, etc.).}
#'   \item{m_time}{Specific maneuver duration ($M_i$) / Duração específica da manobra de posicionamento.}
#'   \item{l_time}{Effective loading duration ($D_i$) / Duração do carregamento efetivo.}
#'   \item{i_time}{Operational idle duration ($O_i$) / Duração da ociosidade operacional.}
#' }
"load_cycles_mine_a"

#' Mine A Hauling Events (Full Journey) / Eventos de Transporte - Mina A
#'
#' English: Detailed dataset containing the 7-event journey of the hauling cycle.
#'
#' Português: Conjunto de dados detalhado contendo a jornada de 7 eventos do ciclo
#' de transporte.
#'
#' @format A tibble in long format / Um tibble em formato longo:
#' \describe{
#'   \item{cycle_id}{Reference ID for the hauling cycle / ID de referência para o ciclo de transporte.}
#'   \item{load_id}{ID of the serving loading unit / ID da unidade de carga que realizou o atendimento.}
#'   \item{haul_id}{Truck identifier / ID do caminhão que realiza o transporte.}
#'   \item{haul_fleet}{Technical hauling fleet class / Classificação técnica da frota de transporte.}
#'   \item{origin}{Extraction point / Ponto de extração/origem.}
#'   \item{destination}{Dump point / Ponto de descarga (Crusher, Waste Dump, etc.).}
#'   \item{event_type}{The 7 operational states / Um dos 7 estados: queue_at_load, maneuver_at_load, loading, travel_full, queue_at_dump, maneuver_at_dump, dumping.}
#'   \item{duration_min}{Duration of each individual state / Tempo despendido em cada estado individual em minutos.}
#'   \item{payload}{Transported mass in tons / Massa transportada em toneladas.}
#' }
"haul_events_mine_a"

#' Mine A Hauling Cycles (Performance & Scale) / Ciclos de Transporte - Mina A
#'
#' English: Consolidated dataset of haul trips including DMT and scale compliance.
#'
#' Português: Dataset consolidado onde cada linha representa uma viagem completa,
#' incluindo variáveis de distância (DMT) e balança.
#'
#' @format A tibble with performance metrics / Um tibble com 18 colunas:
#' \describe{
#'   \item{cycle_id}{Unique journey identifier / Identificador único do ciclo de transporte.}
#'   \item{first_time}{Start of journey (load queue entry) / Início da jornada (entrada na fila de carga).}
#'   \item{exit_time}{End of journey (dump completion) / Término da jornada (conclusão da descarga).}
#'   \item{duration_min}{Total journey duration ($X_j$) / Duração total da viagem.}
#'   \item{load_fleet}{Fleet that performed the loading / Frota que realizou o carregamento.}
#'   \item{haul_fleet}{Fleet that performed the hauling / Frota que realizou o transporte.}
#'   \item{payload}{Truck sensor registered mass / Massa carregada registrada pelo sensor do caminhão.}
#'   \item{scale_weight}{Stationary scale registered mass / Massa real registrada pela balança fixa.}
#'   \item{scale_ok}{Logical scale validation / Variável lógica indicando se a pesagem foi validada.}
#'   \item{load_status}{Load compliance classification / Classificação de conformidade da carga.}
#'   \item{load_factor}{Bucket fill factor / Fator de preenchimento da caçamba.}
#'   \item{dmt_full}{Average full haul distance / Distância média de transporte carregado (km).}
#'   \item{dmt_empty}{Average empty haul distance / Distância média de transporte vazio (km).}
#'   \item{dmt_total}{Total cycle distance / Soma das distâncias de ida e volta (km).}
#'   \item{m_time}{Consolidated maneuver time / Tempo consolidado de manobras (Carga + Descarga).}
#'   \item{l_time}{Effective loading time / Tempo de carregamento efetivo.}
#'   \item{d_time}{Effective dumping time / Tempo de descarga efetiva.}
#'   \item{q_time}{Total queue time / Tempo total em fila (Carga + Descarga).}
#' }
"haul_cycles_mine_a"

#' Drilling Micro-Events (Sossego 2023) / Eventos Micro de Perfuração
#'
#' English: Treated and anonymized drill rig telemetry with production allocation.
#'
#' Português: Dataset contendo a telemetria tratada e anonimizada das perfuratrizes
#' com rateio proporcional de produção.
#'
#' @format A tibble with 9 columns / Um tibble com 9 colunas:
#' \describe{
#'   \item{drill_id}{Anonymized equipment ID / ID anonimizado do equipamento.}
#'   \item{drill_fleet}{Technical fleet class / Classificação técnica da frota.}
#'   \item{origin}{Standardized pit region / Região da mina padronizada.}
#'   \item{event_type}{Fundamental event type / Tipo de evento (drilling, setup, tramming, rods, inoperable).}
#'   \item{category}{Operational category / Categoria operacional (HEF = Efetivas, HOI = Inoperante).}
#'   \item{duration_min}{Calculated duration / Duração do evento em minutos (via dhours).}
#'   \item{allocated_meters}{Allocated production / Produção estimada do evento (Rateio Proporcional).}
#'   \item{first_time}{Event start timestamp / Timestamp inicial do evento.}
#'   \item{exit_time}{Corrected end timestamp / Timestamp final corrigido.}
#' }
"drill_events_mine_d"

#' Drilling Cycles (Reconciled) / Ciclos de Perfuração Reconciliados
#'
#' English: Daily consolidated data crossing Micro Cycle ($X_i$) vs Macro Closing.
#'
#' Português: Dataset diário por equipamento que cruza a Identidade Fundamental do
#' Ciclo ($X_i$) com o fechamento oficial (Requipam).
#'
#' @format A tibble with 10 columns / Um tibble com 10 colunas:
#' \describe{
#'   \item{drill_id}{Anonymized equipment ID / ID anonimizado do equipamento.}
#'   \item{date}{Operational reference date / Data de referência operacional.}
#'   \item{xi_min}{Sum of cycle times ($P+D+H+M$) / Soma dos tempos do ciclo em minutos.}
#'   \item{p_time}{Total daily setup time / Tempo total de Setup no dia.}
#'   \item{d_time}{Total daily drilling time / Tempo total de Perfuração Efetiva no dia.}
#'   \item{allocated_meters}{Sum of allocated production / Soma da produção alocada.}
#'   \item{ho_off}{Official Operating Hours / Horas Operativas Oficiais (Macro).}
#'   \item{hm_off}{Official Maintenance Hours / Horas de Manutenção Oficiais.}
#'   \item{prod_day}{Official total daily meters / Produção total do dia em metros (Oficial).}
#'   \item{delta_ho}{Gap between Xi and official HO / Diferença entre o ciclo (Xi) e o oficial.}
#' }
"drill_cycles_mine_d"
