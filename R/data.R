# ==============================================================================
# GRUPO 1: CARGA E PERFURAÇÃO (OPERAÇÃO DE MINA)
# ==============================================================================

#' Log de Turno: Perfuração (Mina A)
#'
#' Dados de apontamento de perfuratrizes, segmentados por turno de trabalho.
#' Focados em KPIs de gestão diária (Disponibilidade, Utilização).
#'
#' @family "Carga e Perfuração"
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
#'
#' Dados de apontamento de escavadeiras (Shovels/Excavators).
#' Estrutura idêntica ao log de perfuração.
#'
#' @family "Carga e Perfuração"
#' @rdname drill_event_mine_a
"load_event_mine_a"

#' Histórico de Performance: Carga (Mina B)
#'
#' Dados diários de escavadeiras seguindo a árvore de tempos padrão (GPV-M).
#'
#' @family "Carga e Perfuração"
#' @format Tibble diária:
#' \describe{
#'   \item{produtividade_ht}{Produtividade (t/HT).}
#'   \item{HT}{Horas Trabalhadas Totais.}
#'   \item{HEF}{Horas Efetivas.}
#'   \item{HAO}{Horas de Atraso Operacional.}
#' }
"load_daily_cep_mine_b"

#' Drilling Events from Mine D
#' @format A tibble
"drill_event_mine_d"

#' Loading Fleet Specification
#' @format A tibble
"frota_carga"

#' Monthly Haulage Consolidation for Mine A
#' @format A tibble
"haul_monthly_consolidated_mine_a"

# ==============================================================================
# GRUPO 2: TRANSPORTE E CICLO (MOVIMENTAÇÃO)
# ==============================================================================

#' Detailed Loading Cycle: Shovel Perspective (Mine A)
#'
#' Micro-level data (cycle-by-cycle) focused on the performance of the loading unit.
#' This dataset allows the reconstruction of the GPV-M time tree and the calculation
#' of rhythm (TBC) and efficiency (LCT) indicators.
#'
#' @family "Loading and Drilling"
#' @format A tibble with loading cycle records:
#' \describe{
#'   \item{exit_time}{Timestamp of the completion of the loading event (t_i).}
#'   \item{load_id}{Anonymized Loading Unit ID (LOAD-XXXX).}
#'   \item{haul_id}{Anonymized Haulage Unit ID (HAUL-XXXX).}
#'   \item{origin}{Material source location (e.g., Bench or Stockpile).}
#'   \item{material}{Type of material loaded (Ore 1-3, Waste 1-3).}
#'   \item{payload}{Net mass transported in the cycle (p_i), in tonnes.}
#'   \item{load_status}{Qualitative classification of the truck filling status.}
#'   \item{lct}{Loading Cycle Time in minutes (d_i / LCT).}
#'   \item{mct}{Maneuver Cycle Time of the loading unit (min).}
#'   \item{oct}{Operational Cycle Time / Idle time waiting for trucks (min).}
#' }
#' @source Derived from processed operational events in `load_event_mine_a.Rdata`.
"load_cycle_mine_a"

#' Log de Turno: Transporte (Mina A)
#'
#' Dados de apontamento de caminhões fora de estrada, segmentados por turno.
#' Ideal para cálculo de OEE e KPIs operacionais diários.
#'
#' @family "Transporte e Ciclo"
#' @rdname drill_event_mine_a
"haul_shift_log_mine_a"

#' Ciclo de Transporte Detalhado (Mina A)
#'
#' Dados "Micro" (ciclo a ciclo) contendo a decomposição de tempos e produção.
#' Essencial para análise de tempos de fila e tempos fixos.
#'
#' @family "Transporte e Ciclo"
#' @format Tibble de viagens:
#' \describe{
#'   \item{id_ciclo}{Identificador sequencial.}
#'   \item{TVV}{Tempo de Viagem Vazio (min).}
#'   \item{TFC}{Tempo de Fila Carga (min).}
#'   \item{TC}{Tempo de Carregamento (min).}
#'   \item{massa_transportada}{Payload (ton).}
#' }
"haul_cycle_mine_a"

#' Histórico de Performance: Transporte (Mina B)
#'
#' Dados diários de caminhões com engenharia reversa de tempos.
#'
#' @family "Transporte e Ciclo"
#' @format Tibble diária:
#' \describe{
#'   \item{tkph}{Tonelada-Quilômetro por Hora.}
#'   \item{tempo_ciclo_total}{TTC estimado.}
#' }
"haul_daily_cep_mine_b"

#' Histórico Diário de Transporte (Mina C)
#'
#' Dados consolidados diários da frota de transporte.
#'
#' @family "Transporte e Ciclo"
#' @format Tibble diária.
"haul_daily_summary_mine_c"


# ==============================================================================
# GRUPO 3: CONFIABILIDADE E MANUTENÇÃO (RELIABILITY)
# ==============================================================================

#' Log de Falhas: Transporte (Mina A)
#'
#' Dados de eventos de falha contínuos para caminhões fora de estrada.
#' Diferente do log de turno, aqui os eventos **NÃO** são quebrados na virada do dia.
#' Fundamental para cálculos precisos de MTBF, MTTR e análises de sobrevivência.
#'
#' @family "Confiabilidade e Manutenção"
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

#' Histórico de Ordens de Serviço: Transporte (Mina A)
#'
#' Registro detalhado de intervenções com taxonomia (Sistema/Conjunto) e texto.
#' Útil para mineração de texto e análise de Pareto de falhas.
#'
#' @family "Confiabilidade e Manutenção"
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
#'
#' @family "Confiabilidade e Manutenção"
#' @format Tibble mensal:
#' \describe{
#'   \item{data}{Mês de competência.}
#'   \item{custo_total}{Soma dos custos do equipamento.}
#'   \item{custo_pecas}{Valor gasto em materiais.}
#' }
"haul_maint_costs_mine_a"

#' Ordens de Serviço: Manutenção (Mina B)
#'
#' Histórico textual de falhas (2021-2022).
#' @family "Confiabilidade e Manutenção"
#' @format Tibble de eventos.
"maint_orders_mine_b"

#' Log Completo de Paradas (Mina B)
#'
#' Dataset que diferencia Manutenção (HMC) de Ociosidade (HOI).
#' @family "Confiabilidade e Manutenção"
#' @format Tibble de eventos.
"maint_stops_mine_b"

#' Histórico de Manutenção Preventiva (Mina C)
#'
#' Case de Otimização de Periodicidade.
#' @family "Confiabilidade e Manutenção"
#' @format Tibble de eventos.
"maint_truck_events_mine_c"

#' Histórico de Horímetro (Mina C)
#' @family "Confiabilidade e Manutenção"
#' @format Tibble.
"maint_truck_hourmeter_mine_c"

#' Histórico de Pautas (Mina C)
#' @family "Confiabilidade e Manutenção"
#' @format Tibble.
"maint_truck_pautas_mine_c"


# ==============================================================================
# GRUPO 4: INFRAESTRUTURA E APOIO
# ==============================================================================

#' Log de Turno: Infraestrutura (Mina A)
#'
#' Apontamento de equipamentos de apoio (Tratores, Motoniveladoras).
#'
#' @family "Infraestrutura e Apoio"
#' @rdname drill_event_mine_a
"infra_event_mine_a"

#' Histórico de Manutenção: Tratores (Mina A)
#'
#' Log detalhado de OS de tratores de esteira (Infraestrutura).
#' @family "Infraestrutura e Apoio"
#' @format Tibble de eventos.
"maint_track_dozer_mine_a"

#' Histórico de Eventos: Caminhão Pipa (Mina B)
#'
#' Log de operações da frota de irrigação.
#' @family "Infraestrutura e Apoio"
#' @format Tibble de eventos.
"infra_water_truck_events_mine_b"

#' Plano de Custos: Caminhão Pipa (Mina B)
#' @family "Infraestrutura e Apoio"
#' @format Tibble.
"infra_water_truck_cost_plan"

#' Lista de Tarefas: Caminhão Pipa (Mina B)
#' @family "Infraestrutura e Apoio"
#' @format Tibble.
"infra_water_truck_task_list"

#' Horímetro: Caminhão Pipa (Mina B)
#' @family "Infraestrutura e Apoio"
#' @format Tibble.
"infra_water_truck_hourmeter_mine_b"


# ==============================================================================
# GRUPO 5: GESTÃO E ESTRATÉGIA (METAS E KPIs)
# ==============================================================================

#' Indicadores Mensais Consolidados (Mina A)
#'
#' KPIs mensais oficiais (Requipam) para diversas frotas.
#'
#' @family "Gestão e Estratégia"
#' @format Tibble mensal.
"haul_kpi_monthly_mine_a"

#' @rdname haul_kpi_monthly_mine_a
#' @family "Gestão e Estratégia"
"drill_kpi_monthly_mine_a"

#' @rdname haul_kpi_monthly_mine_a
#' @family "Gestão e Estratégia"
"load_kpi_monthly_mine_a"

#' @rdname haul_kpi_monthly_mine_a
#' @family "Gestão e Estratégia"
"infra_kpi_monthly_mine_a"

#' Premissas Orçamentárias Anuais (Mina A)
#'
#' Dados consolidados do orçamento (Budget) anual.
#'
#' @family "Gestão e Estratégia"
#' @format Tibble mensal:
#' \describe{
#'   \item{DF_plan}{Meta de Disponibilidade Física.}
#'   \item{producao_plan}{Meta de produção.}
#' }
"plan_budget_assumptions_mine_a"

#' Metas Diárias de Transporte (Mina C)
#'
#' Orçamento (Budget) diário para aderência.
#' @family "Gestão e Estratégia"
#' @format Tibble diária.
"plan_daily_budget_mine_c"

#' Metas Detalhadas de Transporte 2021 (Mina C)
#'
#' Budget com granularidade de tempos de ciclo.
#' @family "Gestão e Estratégia"
#' @format Tibble diária.
"plan_daily_detailed_2021_mine_c"

#' Tabela de Classificação de Eventos (Padrão PNR)
#'
#' Regras de negócio para classificação de horas (HOI, HMC...).
#' @family "Gestão e Estratégia"
#' @format Tibble.
"meta_event_classification"

#' Dicionário de Termos (PT/EN/ES)
#'
#' Glossário técnico trilíngue.
#' @family "Gestão e Estratégia"
#' @format Tibble.
"meta_dictionary"

# ==============================================================================
# GRUPO 6: DADOS DA MINA D (COBRE - SOSSEGO)
# ==============================================================================

#' Log de Eventos 2023: Perfuratrizes Detalhado (Mina D)
#'
#' Dados da aba "apontamentos 2023". Contém telemetria rica (GPS, Horímetro).
#' @family "Case Mina D"
#' @format Tibble de eventos com colunas de GPS e Região.
"drill_event_2023_mine_d"

#' Log de Eventos Recentes: Perfuratrizes (Mina D)
#'
#' Dados da aba "apontamentos". Log padrão de turno.
#' @family "Case Mina D"
#' @format Tibble de eventos padrão.
"drill_event_log_mine_d"

#' Histórico Diário Real: Equipamentos (Mina D)
#'
#' Dados da aba "requipam". Performance realizada (HC, HT, HM, HO).
#' @family "Case Mina D"
#' @format Tibble diária.
"equipment_daily_act_mine_d"

#' Planejamento Diário e Metas (Mina D)
#'
#' Dados da aba "programados". Budget de disponibilidade e produção.
#' @family "Case Mina D"
#' @format Tibble diária.
"equipment_daily_plan_mine_d"

#' Produção Diária e Qualidade (Mina D)
#'
#' Dados da aba "D+30 infra". Balanço de massa, teor de Cobre e REM.
#' @family "Case Mina D"
#' @format Tibble diária.
"production_daily_mine_d"

# ==============================================================================
# GRUPO 7: SISTEMA IPCC (MINA E - SERRA SUL)
# ==============================================================================

#' Log de Eventos: IPCC / Truckless (Mina E)
#'
#' Dataset de alta frequência de uma mina operada via IPCC (In-Pit Crushing and Conveying).
#'
#' Diferente das minas tradicionais (Caminhão/Escavadeira), este sistema é contínuo.
#' As falhas em um equipamento (ex: Britador Móvel) propagam-se imediatamente para as correias (Sistemas em Série).
#'
#' @family "Case Mina E"
#' @family "Beneficiamento e Processamento"
#'
#' @format Tibble com histórico de eventos:
#' \describe{
#'   \item{metodo_lavra}{Identifica o método (IPCC Truckless).}
#'   \item{tipo_ativo}{Classificação do equipamento (Correia, Britador Móvel, Alimentador).}
#'   \item{id_equipamento}{Tag anonimizada (CNV=Conveyor, CRH=Crusher).}
#'   \item{sistema}{Parte do circuito (Estéril ou Minério).}
#'   \item{categoria_kpi}{Classificação de horas (HOI, HMC, HEF).}
#'   \item{impacta_indicador}{Se o evento parou a produção (Loss).}
#' }
#' @source Dados anonimizados de operação em Serra Sul (S11D).
"ipcc_event_log_mine_e"

# ==============================================================================
# GRUPO 8: BENEFICIAMENTO E PÁTIO (MINA E - S11D)
# ==============================================================================

#' Log de Eventos: Pátio e Usina (Mina E)
#'
#' Dataset de grande volumetria cobrindo o Beneficiamento e Pátio de Regularização da Mina E.
#' Contém dados de Empilhadeiras, Recuperadoras e circuitos de peneiramento.
#'
#' @family "Case Mina E"
#' @family "Beneficiamento e Processamento"
#'
#' @format Tibble com histórico de eventos:
#' \describe{
#'   \item{tipo_ativo}{Tipo de máquina (Empilhadeira, Recuperadora, Correia).}
#'   \item{id_equipamento}{Tag anonimizada (STK=Stacker, RCL=Reclaimer).}
#'   \item{sistema}{Sistema produtivo (ex: Circuito Pen. Primário).}
#'   \item{categoria_kpi}{Classificação de horas (HOI, HMC, HEF).}
#'   \item{causa_basica}{Causa primária da parada.}
#' }
#' @source Dados anonimizados de operação em Serra Sul (S11D).
"plant_event_log_mine_e"

# ==============================================================================
# MINA F: COMPLEXO SALOBO (COBRE) - FLUXO DE BENEFICIAMENTO
# ==============================================================================

#' Log Detalhado de Eventos da Usina (Mina F)
#'
#' Base de dados consolidada de eventos operacionais. Contém o histórico de
#' categorias de horas (HEF, HMC, HOI, etc.) e o status (Funcionando/Parado)
#' de todos os ativos, desde a Britagem Primária até a Filtragem.
#'
#' @family "Case Mina F"
#' @family "Beneficiamento"
#'
#' @format Tibble com 64.046 registos e colunas essenciais:
#' \describe{
#'   \item{mina_id}{Identificador da unidade (Mina F).}
#'   \item{sistema_produtivo}{Grandes áreas (ex: Britagem 1/2, Salobo 1/2).}
#'   \item{subprocesso}{Etapa do processo (ex: Moagem, Flotação, Peneiramento).}
#'   \item{linha}{Identificação da linha de produção (Linha 1 a 4).}
#'   \item{id_equipamento}{Tag anonimizada do ativo.}
#'   \item{inicio, fim}{Timestamps de início e fim do evento.}
#'   \item{duracao_h}{Duração do evento calculada em horas.}
#'   \item{categoria_kpi}{Classificação de horas (HMC, HOI, HEF).}
#' }
#' @source L:/Meu Drive/Dados_Confidenciais/data_subprocess_for_event_cleaner.Rdata
"plant_detailed_mine_f"

#' Produção Horária e Taxas de Alimentação (Mina F)
#'
#' Registos horários de tonelagem e taxa (t/h). Cobre a Britagem Primária,
#' o Circuito Singelo e as 4 Linhas de Peneiramento/Moagem. Essencial para
#' cálculos de performance e OEE.
#'
#' @family "Case Mina F"
#' @family "Performance"
#'
#' @format Tibble com 41.769 registos:
#' \describe{
#'   \item{inicio, fim}{Janelas temporais, tipicamente de 1 hora.}
#'   \item{id_equipamento}{Tag do equipamento de alimentação/britagem.}
#'   \item{tonelagem}{Quantidade de minério processada no intervalo (ton).}
#'   \item{origem, destino}{Pontos de transferência no fluxo da usina.}
#' }
#' @source L:/Meu Drive/Dados_Confidenciais/data_salobo_taxa.Rdata
"plant_production_mine_f"

#' Nível da Pilha Pulmão - Circuito Singelo (Mina F)
#'
#' Dados brutos (originais) do monitoramento de nível da pilha pulmão.
#' Localizada após a britagem secundária, é responsável por alimentar
#' as 4 linhas de peneiramento e moagem.
#'
#' @details
#' A pilha possui uma capacidade nominal de **171.000 toneladas**.
#' O valor de `nivel_percentual` (0-100%) deve ser multiplicado por esta
#' constante para estimativa de estoque físico.
#'
#' @family "Case Mina F"
#' @family "Inventário"
#'
#' @format Tibble com dados brutos extraídos da Sheet 2:
#' \describe{
#'   \item{timestamp}{Data e hora da leitura do sensor (subday).}
#'   \item{nivel_percentual}{Nível de preenchimento da pilha (%).}
#'   \item{localizacao}{Identificação do ativo (Pilha Pulmão).}
#' }
#' @source L:/Meu Drive/Dados_Confidenciais/data_salobo_taxa.xlsx (Sheet 2)
"inventory_raw_mine_f"
