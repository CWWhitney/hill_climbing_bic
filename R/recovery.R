# Helper: write each arrow of a diagram as text, so two diagrams can be
# compared. With directed = FALSE, A->B and B->A become the same entry.
arc_keys <- function(g, directed = TRUE) {
  a <- bnlearn::arcs(g)
  if (nrow(a) == 0) return(character(0))
  if (directed) paste(a[, 1], a[, 2], sep = "->")
  else unique(paste(pmin(a[, 1], a[, 2]), pmax(a[, 1], a[, 2]), sep = "--"))
}

#' How well does hill climbing recover the expert diagram?
#'
#' Simulates `reps` data sets of each size in `n_grid` from the expert model,
#' learns a structure from scratch with `bnlearn::hc()` (BIC score), and
#' compares it with the diagram that generated the data. The expert diagram is
#' the truth here by construction, so the study measures the best case: data
#' that match the expert model exactly.
#'
#' @param n_grid Sample sizes.
#' @param reps Replicate data sets per sample size.
#' @param seed Random seed, set once at the start.
#' @param truth_fit A `bn.fit` object. Defaults to [expert_fit()].
#' @param blacklist Arcs the search may not draw, for example from
#'   [causal_order_blacklist()]. `NULL` (default) lets the search draw any arc.
#' @param error Probability that a recorded value is wrong. See [misrecord()].
#' @return A data frame with one row per replicate: `n`, `rep`,
#'   `arcs_learned`, `recall` (share of true arcs found with the right
#'   direction), `precision` (share of learned arcs that are true),
#'   `skeleton_recall` (arcs found, ignoring direction) and `shd`.
#' @export
recovery_study <- function(n_grid = c(13, 50, 100, 250, 500, 1000, 5000),
                           reps = 50, seed = 1, truth_fit = expert_fit(),
                           blacklist = NULL, error = 0) {
  # The expert diagram is the 'truth' that generates the data.
  truth <- bnlearn::bn.net(truth_fit)
  true_dir <- arc_keys(truth)
  true_skel <- arc_keys(truth, directed = FALSE)
  # One seed for the whole study, so a rerun gives identical numbers.
  set.seed(seed)
  rows <- vector("list", length(n_grid) * reps)
  k <- 0
  for (n in n_grid) {
    for (r in seq_len(reps)) {
      # 1. Draw n artificial farm records from the expert model.
      d <- bnlearn::rbn(truth_fit, n)
      # 2. Optionally write some values down wrongly.
      if (error > 0) d <- misrecord(d, error)
      # 3. Search for a diagram, starting with no arrows. Warnings about states
      #    that never occur in a small sample are expected and silenced.
      h <- suppressWarnings(bnlearn::hc(d, blacklist = blacklist))
      learned <- arc_keys(h)
      k <- k + 1
      # 4. Score the search against the truth. precision is undefined (NA) when
      #    the search draws no arrow; check for NA before averaging.
      rows[[k]] <- data.frame(
        n = n, rep = r, arcs_learned = length(learned),
        recall = mean(true_dir %in% learned),
        precision = if (length(learned)) mean(learned %in% true_dir) else NA_real_,
        skeleton_recall = mean(true_skel %in% arc_keys(h, directed = FALSE)),
        shd = bnlearn::shd(h, truth)
      )
    }
  }
  do.call(rbind, rows)
}
