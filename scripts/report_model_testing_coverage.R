# Coverage report for processed model testing dataset.

suppressPackageStartupMessages({
  library(readr)
  library(dplyr)
  library(tidyr)
})

processed_path <- file.path("data", "model_testing_processed.csv")
coverage_summary_path <- file.path("data", "model_testing_coverage_report.csv")
coverage_rows_path <- file.path("data", "model_testing_coverage_by_row.csv")

if (!file.exists(processed_path)) {
  stop("Missing processed data file at data/model_testing_processed.csv")
}

df <- read_csv(processed_path, show_col_types = FALSE)

state_cols <- c(
  "TreeDiversity", "Timber", "Firewood", "Fruit", "Market", "Shade",
  "Habitat", "ExternalRisks", "Costs", "Benefits", "Livelihoods"
)

missing_cols <- setdiff(state_cols, names(df))
if (length(missing_cols) > 0) {
  stop("Processed data is missing expected state columns: ", paste(missing_cols, collapse = ", "))
}

summary_report <- tibble(variable = state_cols) %>%
  rowwise() %>%
  mutate(
    non_missing_n = sum(!is.na(df[[variable]]) & df[[variable]] != ""),
    total_rows = nrow(df),
    coverage_pct = if_else(total_rows > 0, round(100 * non_missing_n / total_rows, 2), 0)
  ) %>%
  ungroup() %>%
  arrange(desc(coverage_pct), variable)

row_report <- df %>%
  mutate(
    non_missing_states = rowSums(!is.na(across(all_of(state_cols))) & across(all_of(state_cols)) != ""),
    total_states = length(state_cols),
    row_coverage_pct = round(100 * non_missing_states / total_states, 2)
  ) %>%
  select(country, year, non_missing_states, total_states, row_coverage_pct, data_quality_flag)

write_csv(summary_report, coverage_summary_path)
write_csv(row_report, coverage_rows_path)

message("Wrote: ", coverage_summary_path)
message("Wrote: ", coverage_rows_path)
message("Coverage report complete.")
