# Country-year experiment (experimental, not used by the analyses)

This folder holds an attempt to build a larger test data set for the expert
diagram from open country-level data (FAOSTAT and World Bank indicators, 1960
to 2025). It is not used by `analysis/` and it cannot support a test yet.

## What is here

| File | Role |
|---|---|
| `indicator_catalog.csv` | Which indicator stands in for which diagram variable, its direction, and notes |
| `ingest_faostat_worldbank_starter.R` | Downloads the indicators listed in the catalog (needs a network) |
| `transform_model_testing_data.R` | Turns raw values into two-level states by a median split within each variable |
| `report_model_testing_coverage.R` | Counts non-missing values per variable |
| `model_testing_processed.csv` | The result: 16,317 country-year rows |
| `model_testing_coverage_report.csv` | Share of rows observed per variable |

`model_testing_raw.csv` (13.7 MB, retrieved 2026-07-07) and
`model_testing_coverage_by_row.csv` are not tracked in git. Regenerate them with
the ingest and report scripts. Values from the source APIs can change between
retrievals.

## Why it cannot support a test yet

* **Known bug.** `Costs` and `ExternalRisks` are coded the wrong way round: their
  `High` means low cost and low risk. Fix the transform script before use.
* Five of the 11 variables (`Timber`, `Firewood`, `Fruit`, `Shade`, `Habitat`)
  have no data. `Livelihoods` is observed for 17% of rows.
* Several proxies are weak. Overweight prevalence stands in for `Costs` and
  cooling degree days for `ExternalRisks`.
* A median split discards information.
* Consecutive years within a country are not independent, which breaks the
  assumption behind the BIC score. A panel method is needed.
