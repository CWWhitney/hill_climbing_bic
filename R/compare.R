#' Compare candidate structures on the same data
#'
#' Scores each candidate diagram with the Bayesian information criterion
#' (BIC), where a higher (less negative) BIC is better, and reports the
#' structural Hamming distance (SHD) to the first candidate. bnlearn cannot
#' score incomplete data, so rows with a missing value are dropped, and the
#' number of rows kept is reported.
#'
#' @param data A data frame of factors.
#' @param candidates A named list of `bn` objects.
#' @return A data frame with one row per candidate: `arcs`, `n_complete`,
#'   `bic`, `delta_bic` (difference from the best candidate) and `shd_to_first`.
#' @export
compare_structures <- function(data, candidates) {
  stopifnot(is.list(candidates), !is.null(names(candidates)))
  cc <- data[stats::complete.cases(data), , drop = FALSE]
  cc[] <- lapply(cc, droplevels)
  bic <- vapply(candidates, function(g) {
    suppressWarnings(bnlearn::score(g, cc, type = "bic"))
  }, numeric(1))
  data.frame(
    structure = names(candidates),
    arcs = vapply(candidates, bnlearn::narcs, numeric(1)),
    n_complete = nrow(cc),
    bic = unname(bic),
    delta_bic = unname(bic - max(bic)),
    shd_to_first = vapply(candidates, function(g) {
      bnlearn::shd(g, candidates[[1]])
    }, numeric(1)),
    row.names = NULL
  )
}
