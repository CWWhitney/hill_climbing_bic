required_packages <- c(
  "rmarkdown",
  "knitr",
  "dagitty",
  "bnlearn",
  "ggplot2",
  "scales",
  "bib2df",
  "dplyr",
  "tidyr",
  "tidytext",
  "igraph",
  "ggraph",
  "readr",
  "stringr",
  "topicmodels",
  "tm",
  "tibble",
  "reshape2"
)

if (!requireNamespace("renv", quietly = TRUE)) {
  install.packages("renv", repos = "https://cloud.r-project.org")
}

if (!file.exists("renv.lock")) {
  renv::init(bare = TRUE)
}

missing_packages <- required_packages[!vapply(required_packages, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing_packages) > 0) {
  renv::install(missing_packages)
}

renv::snapshot(prompt = FALSE)

message("renv setup complete. Lockfile written to renv.lock")
