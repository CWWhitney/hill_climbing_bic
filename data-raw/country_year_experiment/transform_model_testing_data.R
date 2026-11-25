# Transform raw model testing data into BN-ready state variables.

suppressPackageStartupMessages({
  library(readr)
  library(dplyr)
  library(tidyr)
})

raw_path <- file.path("data-raw", "country_year_experiment", "model_testing_raw.csv")
processed_path <- file.path("data-raw", "country_year_experiment", "model_testing_processed.csv")

if (!file.exists(raw_path)) {
  stop("Missing raw data file at data-raw/country_year_experiment/model_testing_raw.csv")
}

raw <- read_csv(raw_path, show_col_types = FALSE)

required_raw_cols <- c("country", "year", "bn_variable", "direction", "state_type", "value")
missing_cols <- setdiff(required_raw_cols, names(raw))
if (length(missing_cols) > 0) {
  stop("Raw data is missing columns: ", paste(missing_cols, collapse = ", "))
}

# Normalize direction so larger adjusted_value always means better/more present.
raw_norm <- raw %>%
  mutate(
    value = suppressWarnings(as.numeric(value)),
    adjusted_value = if_else(direction == "higher_is_worse", -value, value)
  )

agg <- raw_norm %>%
  filter(!is.na(adjusted_value), !is.na(country), !is.na(year), !is.na(bn_variable), !is.na(state_type)) %>%
  group_by(country, year, bn_variable, state_type) %>%
  summarise(score = median(adjusted_value, na.rm = TRUE), .groups = "drop")

if (nrow(agg) == 0) {
  template <- tibble(
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
  write_csv(template, processed_path)
  message("No transformable rows found. Wrote empty processed template.")
  quit(save = "no", status = 0)
}

thresholds <- agg %>%
  group_by(bn_variable, state_type) %>%
  summarise(threshold = median(score, na.rm = TRUE), .groups = "drop")

classified <- agg %>%
  inner_join(thresholds, by = c("bn_variable", "state_type")) %>%
  mutate(
    state = case_when(
      state_type == "binary_high_low" & score >= threshold ~ "High",
      state_type == "binary_high_low" & score < threshold ~ "Low",
      state_type == "binary_yes_no" & score >= threshold ~ "Yes",
      state_type == "binary_yes_no" & score < threshold ~ "No",
      state_type == "binary_improved" & score >= threshold ~ "Improved",
      state_type == "binary_improved" & score < threshold ~ "Not Improved",
      TRUE ~ NA_character_
    )
  ) %>%
  select(country, year, bn_variable, state)

wide <- classified %>%
  tidyr::pivot_wider(
    names_from = bn_variable,
    values_from = state
  )

required_columns <- c(
  "TreeDiversity", "Timber", "Firewood", "Fruit", "Market", "Shade",
  "Habitat", "ExternalRisks", "Costs", "Benefits", "Livelihoods"
)

for (col in required_columns) {
  if (!col %in% names(wide)) {
    wide[[col]] <- NA_character_
  }
}

processed <- wide %>%
  mutate(
    non_missing_states = rowSums(!is.na(across(all_of(required_columns)))),
    data_quality_flag = case_when(
      non_missing_states >= 8 ~ "High",
      non_missing_states >= 5 ~ "Medium",
      TRUE ~ "Low"
    ),
    notes = "Threshold rule: median split by bn_variable using direction-adjusted score"
  ) %>%
  select(country, year, all_of(required_columns), data_quality_flag, notes) %>%
  arrange(country, year)

write_csv(processed, processed_path)

message("Wrote: ", processed_path)
message("Rows written: ", nrow(processed))
message("Transform complete.")
