# The same one-arrow test, in worlds where the arrow does not exist.
# Run from the repository root:  Rscript analysis/04_arrows_that_are_not_real.R

devtools::load_all(quiet = TRUE)

rej <- arc_rejection(reps = 100, seed = 20261124)
write.csv(rej, "results/rejection_when_not_real.csv", row.names = FALSE)

# How much one real arrow improves the log-likelihood per record, from a very
# large sample, set beside the BIC penalty it must beat.
set.seed(20261124)
big <- simulate_expert(1e6)
with_arc <- expert_network()
without <- bnlearn::drop.arc(with_arc, "Market", "Benefits")
ll <- function(g) bnlearn::score(g, big, type = "loglik")
k <- function(g) bnlearn::nparams(bnlearn::bn.fit(g, big[1:1000, ]))
ex <- data.frame(gain_per_record = (ll(with_arc) - ll(without)) / nrow(big),
                 extra_numbers = k(with_arc) - k(without))
write.csv(ex, "results/worked_example.csv", row.names = FALSE)
print(ex)
print(aggregate(rejected ~ n, rej, function(x) c(min = min(x), median = median(x))))
