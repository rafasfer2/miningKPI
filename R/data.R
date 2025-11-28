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
