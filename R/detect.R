#' How much data does it take to detect a missing arc?
#'
#' For each arc of the expert diagram, builds a rival diagram that leaves the
#' arc out. Data are simulated from the expert model, and both diagrams are
#' scored with BIC. The arc counts as detected in a replicate when the full
#' expert diagram scores higher than the rival. The share of replicates in
#' which that happens is the power to contradict a diagram that omits the arc.
#'
#' An arc whose expert probability table has no effect (for example
#' `TreeDiversity -> Shade` in v1, whose table is 0.5 in every cell) cannot be
#' detected at any sample size, because the expert model itself says it does
#' nothing.
#'
#' @inheritParams recovery_study
#' @return A data frame with one row per sample size and arc: `n`, `from`,
#'   `to`, `power` (share of replicates in which the arc is detected) and
#'   `median_delta_bic`.
#' @export
arc_detectability <- function(n_grid = c(13, 50, 100, 250, 500, 1000, 5000),
                              reps = 100, seed = 1, truth_fit = expert_fit()) {
  truth <- bnlearn::bn.net(truth_fit)
  a <- bnlearn::arcs(truth)
  set.seed(seed)
  out <- list()
  for (n in n_grid) {
    delta <- matrix(NA_real_, nrow = reps, ncol = nrow(a))
    for (r in seq_len(reps)) {
      d <- bnlearn::rbn(truth_fit, n)
      s_true <- suppressWarnings(bnlearn::score(truth, d, type = "bic"))
      for (i in seq_len(nrow(a))) {
        rival <- bnlearn::drop.arc(truth, a[i, 1], a[i, 2])
        delta[r, i] <- s_true - suppressWarnings(bnlearn::score(rival, d, type = "bic"))
      }
    }
    out[[length(out) + 1]] <- data.frame(
      n = n, from = a[, 1], to = a[, 2],
      power = colMeans(delta > 0),
      median_delta_bic = apply(delta, 2, stats::median)
    )
  }
  do.call(rbind, out)
}

#' Does the same test reject an arrow that is not real?
#'
#' For each arc, builds a world in which the arc does not exist: the diagram
#' without it, with probability tables fitted to a very large sample from the
#' expert model. Data are simulated from that world, and the diagrams with and
#' without the arc are scored with BIC. This is the companion of
#' [arc_detectability()], which simulates from the world where the arc is real.
#'
#' @inheritParams recovery_study
#' @param fit_n Size of the sample used to fit each world's tables.
#' @return A data frame with `n`, `from`, `to` and `rejected` (share of
#'   replicates in which the diagram without the arc has the higher BIC).
#' @export
arc_rejection <- function(n_grid = c(13, 50, 100, 250, 500, 1000, 5000),
                          reps = 100, seed = 1, truth_fit = expert_fit(),
                          fit_n = 2e5) {
  truth <- bnlearn::bn.net(truth_fit)
  a <- bnlearn::arcs(truth)
  set.seed(seed)
  big <- bnlearn::rbn(truth_fit, fit_n)
  out <- list()
  for (i in seq_len(nrow(a))) {
    without <- bnlearn::drop.arc(truth, a[i, 1], a[i, 2])
    # A prior worth one record avoids blank probabilities for combinations of
    # causes that never occur in the fitting sample.
    world <- bnlearn::bn.fit(without, big, method = "bayes", iss = 1)
    for (n in n_grid) {
      rejected <- vapply(seq_len(reps), function(r) {
        d <- bnlearn::rbn(world, n)
        suppressWarnings(bnlearn::score(without, d, type = "bic") >
                           bnlearn::score(truth, d, type = "bic"))
      }, logical(1))
      out[[length(out) + 1]] <- data.frame(n = n, from = a[i, 1], to = a[i, 2],
                                           rejected = mean(rejected))
    }
  }
  do.call(rbind, out)
}
