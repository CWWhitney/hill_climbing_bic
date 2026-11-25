#' Simulate farm records from the expert model
#'
#' Draws `n` rows from the expert network with its expert probability tables.
#' The data are exactly as informative as the expert model says they are.
#'
#' @param n Number of rows.
#' @param seed Optional random seed.
#' @param fit A `bn.fit` object. Defaults to [expert_fit()].
#' @return A data frame of factors with one column per node.
#' @export
simulate_expert <- function(n, seed = NULL, fit = expert_fit()) {
  if (!is.null(seed)) set.seed(seed)
  bnlearn::rbn(fit, n)
}
