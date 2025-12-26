# miningKPI

The `miningKPI` package provides datasets and functions for calculating Key Performance Indicators (KPIs) in the mining industry, based on stochastic processes and point process theory.

## Installation

You can install the development version of **miningKPI** from GitHub with:

``` r
# install.packages("remotes")
remotes::install_github("rafasfer2/miningKPI")
```

## Loading Indicators (PDCA Framework)

The package implements the following indicators for loading operations:

-   TPL (Total Production Load): $\sum P_i$

-   HT (Worked Hours): $\frac{1}{60} \sum X_i$

-   MLCT (Mean Loading Cycle Time): $\bar{D}$

-   LP (Loading Productivity): $TPL / HT$

## Example

This example shows how to calculate loading performance grouped by fleet:

``` r
library(miningKPI)

# Summarizing performance for Mine A
load_summarize_performance(load_cycle_mine_a, per = fleet_id)
```

## Instalação e atualização

Se você atualizou os dados no repositório e precisa que outros projetos recebam a versão mais recente, use uma das opções abaixo:

- Instalar direto do branch/commit no GitHub:

```r
remotes::install_github("rafasfer2/miningKPI@chore/add-changelog-feat-data", dependencies = TRUE)
```

- Instalar localmente (útil para desenvolvimento):

```r
remotes::install_local(".")
# ou
devtools::install(".")
```

- Se o projeto consumidor utiliza `renv`:

```r
renv::install("rafasfer2/miningKPI@chore/add-changelog-feat-data")
renv::snapshot()
```

Observação: se você distribui pacotes via CRAN/drat ou binaries, incremente `Version` em `DESCRIPTION`, gere o build e publique o pacote adequado.
