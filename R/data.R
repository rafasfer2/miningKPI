#' @importFrom tibble tibble
NULL

################################################################################
# --- MINA A: LOADING & HAULING (CARREGAMENTO E TRANSPORTE) ---
################################################################################

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


################################################################################
# --- MINA D: DRILLING & PRODUCTION (PERFURAÇÃO E PRODUÇÃO) ---
################################################################################

#' Mine D Drilling Events / Eventos de Perfuração - Mina D
#'
#' English: Processed dataset containing the detailed event history of each drill rig,
#' including cycle identification, productive phases (1-5), anonymized local coordinates,
#' and 101 translated telemetry comments.
#'
#' Português: Dataset processado contendo o histórico detalhado de eventos de cada perfuratriz,
#' incluindo a identificação de ciclo, fases produtivas (1-5), coordenadas locais anonimizadas
#' e 101 comentários de telemetria traduzidos.
#'
#' @format A tibble with 18 columns / Um tibble com 18 colunas:
#' \describe{
#'   \item{drill_id}{Unique drill identifier (anonymized) / Identificador único da perfuratriz (anonimizado).}
#'   \item{drill_fleet}{Drill fleet category / Frota à qual a perfuratriz pertence.}
#'   \item{borehole_uid}{Unique borehole identifier / Identificador único do furo.}
#'   \item{cycle}{Sequential cycle ID per drill / ID sequencial do ciclo por perfuratriz.}
#'   \item{code}{Operational code from telemetry / Código operacional da telemetria.}
#'   \item{phase}{Productive phase (1: Positioning, 2: Collaring, 3: Drilling, 4: Rods, 5: Tramming) / Fase produtiva (1-5).}
#'   \item{origin}{Data origin (Mine Area) / Origem da informação (Área da mina).}
#'   \item{event_type}{Type of registered event / Tipo do evento registrado.}
#'   \item{category}{Operational category (International Standards) / Categoria operacional:
#'     \itemize{
#'       \item EFH: Effective Hours / Horas efetivas.
#'       \item ODH: Operational Delay Hours / Horas de atraso operacional.
#'       \item DWH: Different Worked Hours / Horas trabalhadas diversas.
#'       \item IWH: Infrastructure Worked Hours / Horas trabalhadas de infraestrutura.
#'       \item IIH: Internal Idle Hours / Horas ociosas internas.
#'       \item EIH: External Idle Hours / Horas ociosas externas.
#'       \item CMH: Corrective Maintenance Hours / Horas de manutenção corretiva.
#'       \item ACH: Accident Hours / Horas de acidente.
#'       \item SPH: Systematic Preventive Hours / Horas preventivas sistemáticas.
#'       \item NSPH: Non-Systematic Programmed Hours / Horas preventivas não sistemáticas.
#'     }}
#'   \item{description}{Operational description in English / Descrição operacional em inglês.}
#'   \item{comment}{Translated telemetry comments (101 relationships) / Comentários da telemetria traduzidos.}
#'   \item{local_x}{Anonymized local Easting coordinate (meters) / Coordenada local de Leste anonimizada (metros).}
#'   \item{local_y}{Anonymized local Northing coordinate (meters) / Coordenada local de Norte anonimizada (metros).}
#'   \item{first_time}{Event start timestamp / Data e hora de início do evento.}
#'   \item{exit_time}{Event end timestamp / Data e hora de término do evento.}
#'   \item{duration_min}{Total event duration in minutes / Duração total do evento em minutos.}
#'   \item{allocated_meters}{Drilled meters proportionally allocated to the event / Metros perfurados alocados proporcionalmente.}
#'   \item{data_source}{Data source (Telemetry or Manual/Legacy) / Fonte dos dados.}
#' }
"drill_events_mine_d"

#' Mine D Drilling Cycles (Aggregated) / Ciclos de Perfuração - Mina D
#'
#' English: Consolidated dataset with performance indicators (KPIs) aggregated by cycle and day,
#' including anonymized spatial centroids for each borehole.
#'
#' Português: Dataset consolidado com indicadores de performance (KPIs) agregados por ciclo e dia,
#' incluindo os centroides espaciais anonimizados de cada furo.
#'
#' @format A tibble with 16 columns / Um tibble com 16 colunas:
#' \describe{
#'   \item{drill_id}{Unique drill identifier / Identificador único da perfuratriz.}
#'   \item{drill_fleet}{Drill fleet category / Frota à qual a perfuratriz pertence.}
#'   \item{origin}{Data origin / Origem da informação.}
#'   \item{date}{Calendar date / Data civil do registro.}
#'   \item{cycle}{Sequential cycle ID / ID sequencial do ciclo.}
#'   \item{borehole_uid}{Unique borehole identifier / Identificador único do furo.}
#'   \item{local_x}{Anonymized Easting centroid of the borehole / Centroide local de Leste do furo.}
#'   \item{local_y}{Anonymized Northing centroid of the borehole / Centroide local de Norte do furo.}
#'   \item{xi_min}{Total Operational Cycle Time (Xi) in minutes / Tempo total do Ciclo Operacional (Xi).}
#'   \item{allocated_meters}{Total meters drilled in this cycle / Total de metros perfurados neste ciclo.}
#'   \item{n_phases}{Number of unique productive phases recorded / Quantidade de fases produtivas registradas.}
#'   \item{ho_off}{Official Operational hours (Macro) / Horas operacionais oficiais (Macro).}
#'   \item{hm_off}{Official Engine hours (Macro) / Horas de motor oficiais (Macro).}
#'   \item{ht_off}{Official Total hours (Macro) / Horas totais oficiais (Macro).}
#'   \item{hc_off}{Official Calendar hours (Macro) / Horas calendário oficiais (Macro).}
#'   \item{avg_rop}{Average Rate of Penetration (m/h) / Taxa de Penetração Média (m/h).}
#' }
"drill_cycles_mine_d"

#' Mine D Drilling Maintenance Log / Log de Manutenção de Perfuração - Mina D
#'
#' English: Processed dataset containing the detailed maintenance history of the drill fleet,
#' with translated taxonomy (System, Assembly, Component) and categorized failure modes.
#' Includes standardized KPI categories (CMH, ACH) and cleaned work descriptions.
#'
#' Português: Dataset processado contendo o histórico detalhado de manutenção da frota de perfuração,
#' com taxonomia traduzida (Sistema, Conjunto, Componente) e modos de falha categorizados.
#' Inclui categorias padronizadas de KPI (CMH, ACH) e descrições de trabalho limpas.
#'
#' @format A tibble with 14 columns / Um tibble com 14 colunas:
#' \describe{
#'   \item{drill_id}{Unique drill identifier (anonymized) / Identificador único da perfuratriz (anonimizado).}
#'   \item{start_time}{Maintenance event start timestamp / Data e hora de início do evento de manutenção.}
#'   \item{end_time}{Maintenance event end timestamp / Data e hora de término do evento de manutenção.}
#'   \item{duration_h}{Total duration in hours / Duração total em horas.}
#'   \item{category}{Maintenance KPI Category (International Standards) / Categoria de KPI de Manutenção:
#'     \itemize{
#'       \item CMH: Corrective Maintenance Hours / Horas de manutenção corretiva.
#'       \item ACH: Accident Hours / Horas de acidente.
#'     }}
#'   \item{maintenance_team}{Responsible maintenance team (e.g., Mechanical, Electrical) / Equipe de manutenção responsável.}
#'   \item{action_group}{Grouped failure action type (e.g., Leakage, High Temperature) / Tipo de ação de falha agrupada.}
#'   \item{system}{Affected machine system (e.g., Hydraulic, Engine) / Sistema da máquina afetado.}
#'   \item{assembly}{Affected assembly within the system / Conjunto afetado dentro do sistema.}
#'   \item{component}{Specific component causing the failure / Componente específico causador da falha.}
#'   \item{failure_mode}{Detected failure mode (e.g., Rupture, Wear) / Modo de falha detectado.}
#'   \item{action_taken}{Action taken to resolve the issue (e.g., Replace, Repair) / Ação tomada para resolver o problema.}
#'   \item{comment}{Translated and standardized technician comments / Comentários do técnico traduzidos e padronizados via Regex.}
#'   \item{type}{Original maintenance type classification / Classificação original do tipo de manutenção (ex: Preventiva, Corretiva).}
#' }
"drill_maintenance_log_mine_d"

#' Mine D Daily Production Forecast (D+30) / Previsão Diária de Produção (D+30) - Mina D
#'
#' English: Tactical look-ahead forecast dataset (D+30) containing daily production targets,
#' waste removal, and plant feeding premises. Used as the Tactical Planning baseline.
#'
#' Português: Dataset de previsão tática look-ahead (D+30) contendo as metas de produção diária,
#' remoção de estéril e premissas de alimentação da planta. Utilizado como linha de base tática.
#'
#' @format A tibble with 12 columns / Um tibble com 12 colunas:
#' \describe{
#'   \item{date}{Operational date / Data da operação.}
#'   \item{total_movement_t}{Forecasted total mass movement (Ore + Waste + Rehandling) / Movimentação total prevista (Minério + Estéril + Remanejo).}
#'   \item{ore_mined_t}{Forecasted ore production (ROM) in wet tonnes (TBN) / Produção de minério (ROM) prevista em toneladas brutas húmidas (TBN).}
#'   \item{waste_mined_t}{Forecasted waste removal / Massa de estéril prevista para lavra.}
#'   \item{crusher_feed_t}{Forecasted crusher feed / Massa prevista para alimentação do britador primário.}
#'   \item{rehandling_t}{Forecasted rehandling from stockpiles / Massa prevista para remanejo de estoques.}
#'   \item{grade_cu_percent}{Forecasted Copper (Cu) grade / Teor de Cobre (Cu) previsto.}
#'   \item{grade_au_gpt}{Forecasted Gold (Au) grade / Teor de Ouro (Au) previsto.}
#'   \item{contained_cu_t}{Forecasted contained Copper / Cobre contido previsto.}
#'   \item{contained_au_oz}{Forecasted contained Gold / Ouro contido previsto.}
#' }
"production_forecast_mine_d"

#' Mine D Drilling Planning (Budget) / Planeamento de Perfuração (Budget) - Mina D
#'
#' English: Strategic annual planning premises (Budget) for the drill rig fleet.
#' Serves as the Strategic Quality Planning baseline for Juran's Trilogy examples.
#'
#' Português: Premissas de planeamento anual estratégico (Budget) para a frota de perfuratrizes.
#' Serve como linha de base para o Planeamento da Qualidade na Trilogia de Juran.
#'
#' @format A tibble with 10 columns / Um tibble com 10 colunas:
#' \describe{
#'   \item{date}{Reference date for the planned value / Data de referência do valor planeado.}
#'   \item{drill_id}{Anonymized drill identifier / Identificador anonimizado da perfuratriz.}
#'   \item{equipment_model}{Translated equipment model name / Nome traduzido do modelo do equipamento.}
#'   \item{mining_method}{Drilling diameter classification (Large/Small) / Classificação do diâmetro de perfuração.}
#'   \item{planned_calendar_h}{Planned calendar hours / Horas de calendário planeadas.}
#'   \item{planned_maint_h}{Planned maintenance hours (Budget) / Horas de manutenção planeadas.}
#'   \item{planned_worked_h}{Planned worked hours (Target) / Horas trabalhadas planeadas (Target).}
#'   \item{target_availability}{Planned Physical Availability (0-1) / Disponibilidade Física (DF) planeada.}
#'   \item{target_utilization}{Planned Physical Utilization (0-1) / Utilização Física (UF) planeada.}
#'   \item{target_productivity}{Planned productivity in meters per hour (m/h) / Produtividade planeada em metros por hora (m/h).}
#' }
"drill_planning_mine_d"


################################################################################
# --- MINA E: IPCC SYSTEM (SISTEMA IPCC) ---
################################################################################

#' IPCC System Event Log - Mine E (S11D) / Registo de Eventos do Sistema IPCC - Mina E
#'
#' English: A comprehensive dataset containing the operational and maintenance event history
#' of an IPCC (In-Pit Crushing and Conveying) system at the Serra Sul unit.
#'
#' Português: Um conjunto de dados contendo o histórico de eventos operacionais e de manutenção
#' de um sistema IPCC (In-Pit Crushing and Conveying) na unidade Serra Sul.
#'
#' @details
#' English: Explanation of the hour categories (KPIs) based on the Fundamental Identity:
#' Português: Explicação das categorias de horas (KPIs) baseadas na Identidade Fundamental:
#' \itemize{
#'   \item EFH: Effective Hours / Horas efetivas.
#'   \item ODH: Operational Delay Hours / Horas de atraso operacional.
#'   \item DWH: Different Worked Hours / Horas trabalhadas diversas.
#'   \item IWH: Infrastructure Worked Hours / Horas trabalhadas de infraestrutura.
#'   \item IIH: Internal Idle Hours / Horas ociosas internas.
#'   \item EIH: External Idle Hours / Horas ociosas externas.
#'   \item CMH: Corrective Maintenance Hours / Horas de manutenção corretiva.
#'   \item ACH: Accident Hours / Horas de acidente.
#'   \item SPH: Systematic Preventive Hours / Horas preventivas sistemáticas.
#'   \item NSPH: Non-Systematic Programmed Hours / Horas preventivas não sistemáticas.
#' }
#'
#' @format A tibble with 29 columns / Um tibble com 29 colunas:
#' \describe{
#'   \item{mining_method}{Mining method (IPCC / Truckless) / Método de lavra utilizado.}
#'   \item{validated}{Audit status: Locked, Validated, or Not Validated / Estado de auditoria: Trancado, Validado ou Não Validado.}
#'   \item{phase}{Operation phase: Mining or Development / Fase da operação: Lavra ou Desenvolvimento.}
#'   \item{production_system}{Production circuit (e.g., Ore Circuit) / Circuito produtivo.}
#'   \item{subprocess}{Specific operational subprocess / Subprocesso operacional específico.}
#'   \item{line}{Physical line identification / Identificação física da linha.}
#'   \item{equipment}{Anonymized main equipment ID / ID anonimizado do equipamento principal.}
#'   \item{event_code}{Technical status code (e.g., FIX1, FIX3) / Código técnico do estado.}
#'   \item{event_description}{Translated status description / Descrição traduzida do estado.}
#'   \item{activity_code}{Specific activity code / Código da atividade específica.}
#'   \item{activity_description}{Technical activity description / Descrição técnica da atividade.}
#'   \item{start_time}{Event start timestamp / Data e hora de início do evento (POSIXct).}
#'   \item{end_time}{Event end timestamp / Data e hora de término do evento (POSIXct).}
#'   \item{duration_h}{Duration in decimal hours / Duração do evento em horas decimais.}
#'   \item{egp}{Anonymized ID of the Downtime Generator Equipment / ID anonimizado do Equipamento Gerador de Parada (EGP).}
#'   \item{asset_family}{Asset technical family (e.g., Conveyors) / Família técnica do ativo causador.}
#'   \item{asset_class}{Detailed asset class / Classe técnica detalhada do ativo.}
#'   \item{sector}{Responsible sector / Setor responsável (ex: Mechanical, Operations).}
#'   \item{cause}{Translated root cause / Causa raiz do evento traduzida.}
#'   \item{failure}{Translated failure mode / Modo de falha detalhado traduzido.}
#'   \item{hour_category}{KPI category (see Details) / Categoria de KPI (ver Detalhes).}
#'   \item{hour_category_phase}{KPI category by Phase / Categoria de KPI por Fase Produtiva.}
#'   \item{hour_category_system}{KPI category by System / Categoria de KPI por Sistema Produtivo.}
#'   \item{hour_category_sub}{KPI category by Subprocess / Categoria de KPI por Subprocesso.}
#'   \item{hour_category_line}{KPI category by Line / Categoria de KPI por Linha Física.}
#'   \item{shift}{Team/Shift identification (A, B, C, D, Y) / Identificação da equipa/turno.}
#'   \item{auto_manual}{Record origin: Automatic or Manual / Origem do registo: Automático ou Manual.}
#'   \item{maint_order}{Anonymized Maintenance Order / Ordem de Manutenção anonimizada.}
#'   \item{virtual_equipment}{Indicates if asset is logical (Yes) or physical (No) / Ativo é elo lógico ou físico.}
#' }
"ipcc_event_log_mine_e"
