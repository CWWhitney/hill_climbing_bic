# How much data does it take to test the expert diagram?
# Run from the repository root:  Rscript analysis/01_power_of_the_test.R
# Writes results/recovery.csv, results/detectability.csv and two figures.

devtools::load_all(quiet = TRUE)

n_grid <- c(13, 50, 100, 250, 500, 1000, 5000)

rec <- recovery_study(n_grid = n_grid, reps = 100, seed = 20261124)
write.csv(rec, "results/recovery.csv", row.names = FALSE)

det <- arc_detectability(n_grid = n_grid, reps = 100, seed = 20261124)
write.csv(det, "results/detectability.csv", row.names = FALSE)

# Figure 1: recovery of the expert diagram by sample size
summ <- aggregate(cbind(recall, precision, skeleton_recall, arcs_learned, shd) ~ n,
                  data = rec, FUN = mean)
png("results/recovery.png", width = 1400, height = 900, res = 180)
par(mar = c(4.5, 4.5, 2, 1))
plot(summ$n, summ$recall, type = "b", log = "x", ylim = c(0, 1), pch = 16,
     xlab = "Rows of data (log scale)", ylab = "Share of the 19 expert arcs recovered",
     main = "Recovering the expert diagram from data it generated")
lines(summ$n, summ$skeleton_recall, type = "b", pch = 1, lty = 2)
lines(summ$n, summ$precision, type = "b", pch = 17, lty = 3)
legend("bottomright", bty = "n", pch = c(16, 1, 17), lty = c(1, 2, 3),
       legend = c("Arcs with correct direction", "Arcs, direction ignored",
                  "Share of learned arcs that are real"))
dev.off()

# Figure 2: power to detect each missing arc
png("results/detectability.png", width = 1400, height = 1000, res = 180)
par(mar = c(4.5, 4.5, 2, 1))
arcs_u <- unique(det[, c("from", "to")])
cols <- grDevices::hcl.colors(nrow(arcs_u), "Dark 3")
plot(NA, xlim = range(n_grid), ylim = c(0, 1), log = "x",
     xlab = "Rows of data (log scale)",
     ylab = "Power to detect a diagram that omits the arc",
     main = "One line per expert arc")
for (i in seq_len(nrow(arcs_u))) {
  d <- det[det$from == arcs_u$from[i] & det$to == arcs_u$to[i], ]
  lines(d$n, d$power, col = cols[i], lwd = 1.5)
}
abline(h = 0.8, lty = 3)
dev.off()
