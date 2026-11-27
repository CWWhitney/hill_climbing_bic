# How do the records needed depend on effect size and number of causes?
# Run from the repository root:  Rscript analysis/05_many_diagrams.R

devtools::load_all(quiet = TRUE)
set.seed(20261124)

describe <- function(fam, diagram) {
  do.call(rbind, lapply(fam, function(f) {
    info <- arrow_information(f$prob)
    data.frame(diagram = diagram, from = f$from, to = f$to, causes = f$causes,
               information = info, change = f$change,
               needed = records_needed(info, f$causes))
  }))
}

# 1. Every arrow of 1,000 random diagrams.
families <- lapply(1:1000, function(i) arrow_families(random_diagram()))
arrows <- do.call(rbind, Map(describe, families, seq_along(families)))
write.csv(arrows, "results/random_arrows.csv", row.names = FALSE)

# 2. The expert diagram, on the same measures.
expert <- arrow_families(expert_fit())
write.csv(describe(expert, 0), "results/expert_arrows.csv", row.names = FALSE)

# 3. Check the approximation: simulate at the predicted number of records,
#    for up to 300 arrows at each number of causes.
all_families <- unlist(families, recursive = FALSE)
usable <- which(arrows$needed <= 1e5)
pick <- unlist(lapply(split(usable, arrows$causes[usable]),
                      function(i) i[sample.int(length(i), min(300, length(i)))]))
check <- arrows[pick, c("causes", "information", "needed")]
check$power <- mapply(function(i, n) simulate_power(all_families[[i]]$prob, n, 1000),
                      pick, check$needed)
write.csv(check, "results/approximation_check.csv", row.names = FALSE)

# 4. Records needed for chosen effect sizes and numbers of causes.
grid <- expand.grid(information = c(0.001, 0.003, 0.01, 0.03, 0.1), causes = 1:5)
grid$needed <- mapply(records_needed, grid$information, grid$causes)
write.csv(grid, "results/records_by_effect_and_causes.csv", row.names = FALSE)

cat("arrows:", nrow(arrows), "\n")
print(xtabs(needed ~ information + causes, grid))
print(aggregate(power ~ causes, check, quantile, c(0.05, 0.5, 0.95)))
print(aggregate(cbind(information, needed) ~ causes, arrows, median))
print(describe(expert, 0)[, c("from", "to", "causes", "information", "needed")])
