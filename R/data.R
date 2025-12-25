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

#' Mine D Drilling Events / Eventos de Perfuração - Mina D
#'
#' English: Processed dataset containing the detailed event history of each drill rig.
#'
#' Português: Dataset processado contendo o histórico detalhado de eventos de cada perfuratriz.
#'
#' @format A tibble with 17 columns / Um tibble com 17 colunas:
#' \describe{
#'   \item{drill_id}{Unique drill identifier / Identificador único da perfuratriz.}
#'   \item{borehole_uid}{Unique borehole identifier / Identificador único do furo (borehole).}
#'   \item{drill_fleet}{Drill fleet category / Frota à qual a perfuratriz pertence.}
#'   \item{origin}{Data origin (e.g., Dispatch System) / Origem da informação (ex: Sistema de Despacho).}
#'   \item{first_time}{Event start timestamp / Data e hora de início do evento.}
#'   \item{exit_time}{Event end timestamp / Data e hora de término do evento.}
#'   \item{duration_min}{Total event duration in minutes / Duração total do evento em minutos.}
#'   \item{event_type}{Type of registered event (Drilling, Maneuver, Delay, etc.) / Tipo do evento registrado (Perfuração, Manobra, Atraso, etc.).}
#'   \item{category}{Operational category (Operational, Standby, Maintenance) / Categoria operacional do evento (Operacional, Standby, Manutenção).}
#'   \item{engine_hours}{Engine hour meter at time of record / Horímetro do motor no momento do registro.}
#'   \item{data_source}{Primary raw data source / Fonte primária dos dados brutos.}
#'   \item{original_ids_raw}{Original IDs from the source system / IDs originais provenientes do sistema fonte.}
#'   \item{original_tag}{Original event tag in the source system / Tag ou etiqueta original do evento no sistema de origem.}
#'   \item{date}{Calendar date / Data civil do registro.}
#'   \item{total_min_efh}{Total effective hours in minutes / Total de minutos efetivos (Effective Hours).}
#'   \item{prod_day}{Production day (operational shift) / Dia de produção (considerando o turno operacional).}
#'   \item{allocated_meters}{Drilled meters allocated to this event / Metros perfurados alocados a este evento.}
#' }
#' @source Integration via data-raw in miningKPI package / Integração via diretório data-raw do pacote miningKPI.
"drill_events_mine_d"

#' Mine D Drilling Cycles (Aggregated) / Ciclos de Perfuração - Mina D
#'
#' English: Consolidated dataset with performance indicators (KPIs) per drilling cycle or period.
#'
#' Português: Dataset consolidado com indicadores de performance (KPIs) por ciclo ou período de perfuração.
#'
#' @format A tibble with 18 columns / Um tibble com 18 colunas:
#' \describe{
#'   \item{drill_id}{Unique drill identifier / Identificador único da perfuratriz.}
#'   \item{drill_fleet}{Drill fleet category / Frota à qual a perfuratriz pertence.}
#'   \item{origin}{Data origin / Origem da informação.}
#'   \item{date}{Calendar date / Data civil do registro.}
#'   \item{p_time}{Productive Time / Tempo Produtivo.}
#'   \item{d_time}{Delay Time / Tempo de Atraso.}
#'   \item{h_time}{Hammer or Effective Drilling Time / Tempo de Percussão ou Perfuração Efetiva.}
#'   \item{m_time}{Maintenance Time / Tempo de Manutenção.}
#'   \item{xi_min}{Auxiliary activity time in minutes / Tempo de atividades auxiliares em minutos.}
#'   \item{allocated_meters}{Total meters drilled in the cycle / Total de metros perfurados no ciclo.}
#'   \item{boreholes_count}{Number of boreholes completed in the cycle / Quantidade de furos realizados no ciclo.}
#'   \item{ho_off}{Operational hour meter offset / Offset de horímetro operacional.}
#'   \item{hm_off}{Hammer hour meter offset / Offset de horímetro de percussão.}
#'   \item{ht_off}{Total time offset / Offset de tempo total.}
#'   \item{hc_off}{Cycle control offset / Offset de controle de ciclo.}
#'   \item{prod_day}{Production day (operational shift) / Dia de produção (considerando o turno operacional).}
#'   \item{delta_ho}{Operational hour meter variation / Variação do horímetro operacional no ciclo.}
#'   \item{avg_rop}{Average Rate of Penetration / Taxa de Penetração Média.}
#' }
#' @source Processed from drilling event data / Processado a partir dos dados de eventos de perfuração.
"drill_cycles_mine_d"
