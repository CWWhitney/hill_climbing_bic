# Expert Model Validation with Hill Climbing and BIC in R

<!-- README.md is generated from README.Rmd. Please edit that file -->

<!-- badges: start -->

<!-- badges: end -->

This project aims to validate expert knowledge-based models using hill climbing optimization and the Bayesian Information Criterion (BIC). The objective is to compare models derived from expert knowledge against those optimized using hill climbing in R. It contains the
following folders: [analysis](./analysis), [data](./data),
[experiments](./experiments), [other](./other),
[preprocessing](./preprocessing). 

## Project Structure

- **src/**
  - `model_expert/`: Contains R scripts for expert-based model implementations.
  - `model_optimized/`: Contains scripts for models optimized with hill climbing.
  - `optimization/`: Implementation of the hill climbing algorithm in R.
  - `validation/`: R scripts for model validation using BIC.

- **data/**: Datasets required for model training and validation.

- **notebooks/**: RMarkdown files for data analysis and visualization.

- **tests/**: Unit tests to ensure accuracy and reliability of models.

- **results/**: Output results and figures generated from analyses.

- **requirements.txt**: Lists R packages used in this project (use a format if using `renv` or similar for package management).

## Getting Started

### Prerequisites

Ensure you have R and RStudio installed. Use the following command to install required packages:
