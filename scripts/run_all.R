if (!requireNamespace("renv", quietly = TRUE)) {
  install.packages("renv", repos = "https://cloud.r-project.org")
}

if (file.exists("renv.lock")) {
  renv::restore(prompt = FALSE)
}

if (!requireNamespace("rmarkdown", quietly = TRUE)) {
  stop("Package 'rmarkdown' is required but not installed. Run scripts/setup_renv.R first.")
}

rmarkdown::render("README.Rmd")

message("Run complete. README.Rmd rendered successfully.")
