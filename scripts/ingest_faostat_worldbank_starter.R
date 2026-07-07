# Starter ingestion script for Issue 1 data assembly.
# Pulls World Bank indicators and scaffolds FAOSTAT ingestion.

suppressPackageStartupMessages({
  library(httr)
  library(jsonlite)
  library(readr)
  library(dplyr)
})

dir.create("data", showWarnings = FALSE, recursive = TRUE)

raw_target <- file.path("data", "model_testing_raw.csv")
processed_target <- file.path("data", "model_testing_processed.csv")

# World Bank indicators chosen as starter proxies.
# You can adjust or expand this list as needed.
wb_indicators <- c(
  external_risks_proxy = "EN.CLC.CDDY.XD", # Cooling degree days (example climate stress proxy)
  livelihoods_proxy = "SI.POV.DDAY",       # Poverty headcount ratio at $2.15/day
  market_proxy = "NV.AGR.TOTL.ZS"          # Agriculture, forestry, and fishing value added (% of GDP)
)

fetch_world_bank_indicator <- function(indicator) {
  url <- sprintf(
    "https://api.worldbank.org/v2/country/all/indicator/%s?format=json&per_page=20000",
    indicator
  )

  resp <- GET(url, timeout(60))
  stop_for_status(resp)
  parsed <- fromJSON(content(resp, as = "text", encoding = "UTF-8"), flatten = TRUE)

  if (length(parsed) < 2 || nrow(parsed[[2]]) == 0) {
    return(tibble())
  }

  as_tibble(parsed[[2]]) %>%
    transmute(
      country = countryiso3code,
      year = as.integer(date),
      indicator = indicator.id,
      indicator_name = indicator.value,
      value = as.numeric(value),
      source = "WorldBank"
    ) %>%
    filter(!is.na(country), !is.na(year))
}

message("Fetching starter World Bank indicators...")
wb_raw <- bind_rows(lapply(unname(wb_indicators), fetch_world_bank_indicator))

# FAOSTAT scaffold:
# Set FAOSTAT_CSV_URL to a direct CSV endpoint or download location.
# If not provided, we write an empty FAOSTAT frame as a placeholder.
faostat_csv_url <- Sys.getenv("FAOSTAT_CSV_URL", unset = "")
faostat_raw <- tibble(
  country = character(),
  year = integer(),
  indicator = character(),
  indicator_name = character(),
  value = numeric(),
  source = character()
)

if (nzchar(faostat_csv_url)) {
  message("Attempting FAOSTAT pull from FAOSTAT_CSV_URL...")
  try({
    fao <- read_csv(faostat_csv_url, show_col_types = FALSE)

    # Minimal generic mapping. Update once your selected FAOSTAT table is fixed.
    needed <- c("Area", "Year", "Item", "Value")
    if (all(needed %in% names(fao))) {
      faostat_raw <- fao %>%
        transmute(
          country = Area,
          year = as.integer(Year),
          indicator = Item,
          indicator_name = Item,
          value = as.numeric(Value),
          source = "FAOSTAT"
        ) %>%
        filter(!is.na(country), !is.na(year))
    } else {
      message("FAOSTAT_CSV_URL loaded, but expected columns were not found: Area, Year, Item, Value")
    }
  }, silent = TRUE)
} else {
  message("FAOSTAT_CSV_URL not set; writing placeholder FAOSTAT data only.")
}

raw_data <- bind_rows(wb_raw, faostat_raw) %>%
  arrange(country, year, source, indicator)

write_csv(raw_data, raw_target)

# Starter processed frame with model columns only.
processed_template <- tibble(
  country = character(),
  year = integer(),
  TreeDiversity = character(),
  Timber = character(),
  Firewood = character(),
  Fruit = character(),
  Market = character(),
  Shade = character(),
  Habitat = character(),
  ExternalRisks = character(),
  Costs = character(),
  Benefits = character(),
  Livelihoods = character(),
  data_quality_flag = character(),
  notes = character()
)

write_csv(processed_template, processed_target)

message("Wrote: ", raw_target)
message("Wrote: ", processed_target)
message("Starter ingestion complete.")
