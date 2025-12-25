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

##' Mine D Drilling Events / Eventos de Perfuração - Mina D
#'
#' English: Processed dataset containing the detailed event history of each drill rig,
#' including cycle and phase identification (1-4).
#'
#' Português: Dataset processado contendo o histórico detalhado de eventos de cada perfuratriz,
#' incluindo a identificação de ciclo e fase (1-4).
#'
#' @format A tibble with 13 columns / Um tibble com 13 colunas:
#' \describe{
#'   \item{drill_id}{Unique drill identifier / Identificador único da perfuratriz.}
#'   \item{drill_fleet}{Drill fleet category / Frota à qual a perfuratriz pertence.}
#'   \item{borehole_uid}{Unique borehole identifier / Identificador único do furo (gerado via lógica).}
#'   \item{cycle}{Sequential cycle ID per drill (starts at setup) / ID sequencial do ciclo por perfuratriz (inicia no setup).}
#'   \item{phase}{Productive phase (1: Setup, 2: Drilling, 3: Rods, 4: Tramming) / Fase produtiva (1: Setup, 2: Perfuração, 3: Hastes, 4: Translação).}
#'   \item{origin}{Data origin (Pit area) / Origem da informação (Área da mina).}
#'   \item{event_type}{Type of registered event / Tipo do evento registrado.}
#'   \item{category}{Operational category (EFH, ODH, etc.) / Categoria operacional do evento.}
#'   \item{first_time}{Event start timestamp / Data e hora de início do evento.}
#'   \item{exit_time}{Event end timestamp / Data e hora de término do evento.}
#'   \item{duration_min}{Total event duration in minutes / Duração total do evento em minutos.}
#'   \item{allocated_meters}{Drilled meters proportionally allocated to the event / Metros perfurados alocados proporcionalmente ao evento.}
#'   \item{data_source}{Primary raw data source / Fonte primária dos dados brutos.}
#' }
#' @source Processed via data-raw/drilling_processing.R in miningKPI package.
"drill_events_mine_d"

#' Mine D Drilling Cycles (Aggregated) / Ciclos de Perfuração - Mina D
#'
#' English: Consolidated dataset with performance indicators (KPIs) aggregated by cycle or period.
#'
#' Português: Dataset consolidado com indicadores de performance (KPIs) agregados por ciclo ou período.
#'
#' @format A tibble with consolidated KPIs / Um tibble com indicadores de performance:
#' \describe{
#'   \item{drill_id}{Unique drill identifier / Identificador único da perfuratriz.}
#'   \item{drill_fleet}{Drill fleet category / Frota à qual a perfuratriz pertence.}
#'   \item{origin}{Data origin / Origem da informação.}
#'   \item{date}{Calendar date / Data civil do registro.}
#'   \item{xi_min}{Total Operational Cycle Time (Xi) in minutes / Tempo total do Ciclo Operacional (Xi) em minutos.}
#'   \item{allocated_meters_day}{Total meters drilled by the rig in the day / Total de metros perfurados pela perfuratriz no dia.}
#'   \item{boreholes_count}{Number of unique borehole UIDs identified / Quantidade de furos únicos (UIDs) identificados.}
#'   \item{cycle_count}{Number of complete operational cycles (phase 1 starts) / Quantidade de ciclos operacionais completos (início na fase 1).}
#'   \item{ho_off}{Official Operational hours (Macro) / Horas operacionais oficiais (Macro).}
#'   \item{hm_off}{Official Engine hours (Macro) / Horas de motor oficiais (Macro).}
#'   \item{ht_off}{Official Total hours (Macro) / Horas totais oficiais (Macro).}
#'   \item{hc_off}{Official Calendar hours (Macro) / Horas calendário oficiais (Macro).}
#'   \item{delta_ho}{Difference between telemetry Xi and official HO / Diferença entre Xi da telemetria e o HO oficial.}
#'   \item{avg_rop}{Average Rate of Penetration (m/h) based on Xi / Taxa de Penetração Média (m/h) baseada no Xi.}
#' }
#' @source Aggregated from drill_events_mine_d.
"drill_cycles_mine_d"
