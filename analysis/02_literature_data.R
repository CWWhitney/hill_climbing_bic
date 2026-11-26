# Apply the same tools to the 13 literature observations used in v1.
# Run from the repository root:  Rscript analysis/02_literature_data.R

devtools::load_all(quiet = TRUE)

# 13 rows, one per published study, hand-coded. A study is not a farm.
obs <- literature_observations()

# 1. Score the two expert structures and the structure learned from the data.
#    bnlearn cannot score incomplete data, so only complete rows are used.
learned <- suppressWarnings(bnlearn::hc(obs))
learned_from_expert <- suppressWarnings(bnlearn::hc(obs, start = expert_network()))
cmp <- compare_structures(obs, list(
  expert_bnlearn_v1 = expert_network("bnlearn_v1"),
  expert_dagitty_v1 = expert_network("dagitty_v1"),
  learned_from_scratch = learned,
  learned_from_expert_start = learned_from_expert
))
write.csv(cmp, "results/literature_structures.csv", row.names = FALSE)

# 2. Stability of each learned arc under resampling of the 13 papers.
stab <- edge_stability(obs, R = 500, seed = 20261124)
write.csv(stab, "results/literature_edge_stability.csv", row.names = FALSE)

# 3. Power at this sample size, for comparison (from analysis 01).
det <- read.csv("results/detectability.csv")
at13 <- det[det$n == 13, c("from", "to", "power")]
write.csv(at13, "results/detectability_at_n13.csv", row.names = FALSE)

print(cmp)
# bnlearn lists each pair in both directions, so count each pair once.
cat("\nArc pairs present in at least half of the resamples:",
    sum(stab$strength >= 0.5 & stab$direction >= 0.5), "\n")
cat("Median power to detect an omitted arc at n = 13:", median(at13$power), "\n")
