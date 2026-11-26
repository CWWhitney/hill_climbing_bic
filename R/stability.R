#' How stable is each learned arc?
#'
#' Resamples the rows with replacement `R` times, learns a structure from each
#' resample with `bnlearn::hc()`, and reports how often each arc appears.
#' Missing values are passed to bnlearn, which uses the available cases.
#'
#' @param data A data frame of factors.
#' @param R Number of resamples.
#' @param seed Random seed.
#' @param reference A `bn` object. Arcs in it are flagged `in_expert`.
#' @return A data frame with `from`, `to`, `strength` (share of resamples
#'   containing the arc in either direction), `direction` (share in this
#'   direction when the arc appears) and `in_expert`.
#' @export
edge_stability <- function(data, R = 200, seed = 1, reference = expert_network()) {
  set.seed(seed)
  # Resample the rows, search each resample, and count how often arrows appear.
  bs <- suppressWarnings(bnlearn::boot.strength(data, R = R, algorithm = "hc"))
  bs <- as.data.frame(bs)
  # Mark the arrows that the expert diagram also has (same direction).
  bs$in_expert <- paste(bs$from, bs$to) %in%
    paste(bnlearn::arcs(reference)[, 1], bnlearn::arcs(reference)[, 2])
  bs <- bs[order(-bs$strength), c("from", "to", "strength", "direction", "in_expert")]
  rownames(bs) <- NULL
  bs
}
