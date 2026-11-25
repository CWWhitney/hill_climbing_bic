# Two checks on the limits of the test.
# Run from the repository root:  Rscript analysis/03_can_the_test_be_improved.R

devtools::load_all(quiet = TRUE)

# Same sizes and seed as analysis 01, so the first setting reproduces it exactly.
n_grid <- c(13, 50, 100, 250, 500, 1000, 5000)
seed <- 20261124

run <- function(label, ...) {
  r <- recovery_study(n_grid = n_grid, reps = 100, seed = seed, ...)
  m <- aggregate(cbind(recall, precision) ~ n, data = r, FUN = mean)
  cbind(setting = label, m)
}

out <- rbind(
  run("search with no help"),
  run("order of causes given", blacklist = causal_order_blacklist()),
  run("5% of values misrecorded", error = 0.05),
  run("10% of values misrecorded", error = 0.10)
)
write.csv(out, "results/improvements.csv", row.names = FALSE)
print(out)
