# miningKPI

The `miningKPI` package provides datasets and functions for calculating
Key Performance Indicators (KPIs) in the mining industry, based on
stochastic processes and point process theory.

## Installation

You can install the development version of **miningKPI** from GitHub
with:

    # install.packages("remotes")
    remotes::install_github("rafasfer2/miningKPI")

## Loading Indicators (PDCA Framework)

The package implements the following indicators for loading operations:

-   TPL (Total Production Load): ∑*P*<sub>*i*</sub>

-   HT (Worked Hours): $\frac{1}{60} \sum X\_i$

-   MLCT (Mean Loading Cycle Time): *D̄*

-   LP (Loading Productivity): *T**P**L*/*H**T*

## Example

This example shows how to calculate loading performance grouped by
fleet:

    library(miningKPI)

    # Summarizing performance for Mine A
    load_summarize_performance(load_cycle_mine_a, per = fleet_id)
