# EXPERIMENTAL, not used by the analyses. Step 1 of 3.
# Downloads the indicators listed in indicator_catalog.csv into
# model_testing_raw.csv. Run from the repository root. Needs a network.
# World Bank requests fetch one page of up to 20,000 rows per indicator.

# Catalog-driven ingestion script for model testing data.
# World Bank indicators are pulled via API.
# FAOSTAT indicators are read from a local CSV file path in FAOSTAT_INPUT_CSV.

suppressPackageStartupMessages({
  library(httr)
  library(jsonlite)
  library(readr)
  library(dplyr)
  library(tidyr)
  library(tibble)
})

dir.create(file.path("data-raw", "country_year_experiment"), showWarnings = FALSE, recursive = TRUE)

catalog_path <- file.path("data-raw", "country_year_experiment", "indicator_catalog.csv")
raw_target <- file.path("data-raw", "country_year_experiment", "model_testing_raw.csv")

if (!file.exists(catalog_path)) {
  stop("Missing indicator catalog at data-raw/country_year_experiment/indicator_catalog.csv")
}

catalog <- read_csv(catalog_path, show_col_types = FALSE) %>%
  mutate(source = trimws(source))

required_catalog_cols <- c(
  "source", "indicator_id", "indicator_name", "bn_variable",
  "direction", "state_type", "active"
)

missing_cols <- setdiff(required_catalog_cols, names(catalog))
if (length(missing_cols) > 0) {
  stop("Catalog is missing columns: ", paste(missing_cols, collapse = ", "))
}

catalog <- catalog %>%
  filter(active %in% c(1, "1", TRUE, "TRUE", "true")) %>%
  mutate(indicator_id = as.character(indicator_id))

fetch_world_bank_indicator <- function(indicator_id, indicator_name, bn_variable, direction, state_type) {
  url <- sprintf(
    "https://api.worldbank.org/v2/country/all/indicator/%s?format=json&per_page=20000",
    URLencode(indicator_id, reserved = TRUE)
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
      year = suppressWarnings(as.integer(date)),
      source = "WorldBank",
      indicator_id = indicator.id,
      indicator_name = indicator.value,
      bn_variable = bn_variable,
      direction = direction,
      state_type = state_type,
      value = suppressWarnings(as.numeric(value)),
      retrieval_date = as.character(Sys.Date())
    ) %>%
    filter(!is.na(country), nchar(country) == 3, !is.na(year))
}

fetch_faostat_from_csv <- function(catalog_subset, faostat_path) {
  if (!file.exists(faostat_path)) {
    warning("FAOSTAT_INPUT_CSV path does not exist: ", faostat_path)
    return(tibble())
  }

  fao <- read_csv(faostat_path, show_col_types = FALSE)

  country_col <- c("Area Code (ISO3)", "Area", "Country", "country")
  year_col <- c("Year", "year")
  item_col <- c("Item", "item")
  value_col <- c("Value", "value")

  pick_col <- function(candidates) {
    hits <- candidates[candidates %in% names(fao)]
    if (length(hits) == 0) return(NA_character_)
    hits[[1]]
  }

  c_col <- pick_col(country_col)
  y_col <- pick_col(year_col)
  i_col <- pick_col(item_col)
  v_col <- pick_col(value_col)

  if (any(is.na(c(c_col, y_col, i_col, v_col)))) {
    warning("FAOSTAT CSV must include country/year/item/value columns.")
    return(tibble())
  }

  fao_std <- fao %>%
    transmute(
      country = as.character(.data[[c_col]]),
      year = suppressWarnings(as.integer(.data[[y_col]])),
      item = as.character(.data[[i_col]]),
      value = suppressWarnings(as.numeric(.data[[v_col]]))
    )

  out <- fao_std %>%
    inner_join(
      catalog_subset %>%
        transmute(indicator_id, indicator_name, bn_variable, direction, state_type),
      by = c("item" = "indicator_id")
    ) %>%
    transmute(
      country,
      year,
      source = "FAOSTAT",
      # the join keeps the key under its left-hand name, 'item'
      indicator_id = item,
      indicator_name,
      bn_variable,
      direction,
      state_type,
      value,
      retrieval_date = as.character(Sys.Date())
    ) %>%
    filter(!is.na(country), !is.na(year))

  out
}

wb_catalog <- catalog %>% filter(source == "WorldBank")
fao_catalog <- catalog %>% filter(source == "FAOSTAT")

message("Pulling World Bank indicators from catalog...")
wb_raw <- bind_rows(lapply(seq_len(nrow(wb_catalog)), function(i) {
  row <- wb_catalog[i, ]
  fetch_world_bank_indicator(
    indicator_id = row$indicator_id,
    indicator_name = row$indicator_name,
    bn_variable = row$bn_variable,
    direction = row$direction,
    state_type = row$state_type
  )
}))

faostat_input_csv <- Sys.getenv("FAOSTAT_INPUT_CSV", unset = "")
if (nzchar(faostat_input_csv)) {
  message("Reading FAOSTAT rows from FAOSTAT_INPUT_CSV...")
  faostat_raw <- fetch_faostat_from_csv(fao_catalog, faostat_input_csv)
} else {
  message("FAOSTAT_INPUT_CSV not set. Skipping FAOSTAT ingestion this run.")
  faostat_raw <- tibble()
}

raw_data <- bind_rows(wb_raw, faostat_raw) %>%
  mutate(
    value = suppressWarnings(as.numeric(value)),
    country = as.character(country)
  ) %>%
  arrange(country, year, source, indicator_id)

write_csv(raw_data, raw_target)

message("Wrote: ", raw_target)
message("Rows written: ", nrow(raw_data))
message("Ingestion complete.")
