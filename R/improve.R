#' Forbid arrows that run against the order of causes
#'
#' Experts often know which variables come before which, even when they are
#' unsure which arrows exist. This encodes only that order for the agroforestry
#' example: tree diversity and external risks first, then tree products and
#' services, then market, then costs and benefits, then livelihoods. Arrows
#' from a later group to an earlier one are forbidden. Arrows within a group
#' stay allowed.
#'
#' @return A two-column matrix of forbidden arcs, for `bnlearn::hc()`.
#' @export
causal_order_blacklist <- function() {
  bnlearn::tiers2blacklist(list(
    c("TreeDiversity", "ExternalRisks"),
    c("Timber", "Firewood", "Fruit", "Shade", "Habitat"),
    "Market",
    c("Costs", "Benefits"),
    "Livelihoods"
  ))
}

#' Add recording errors to simulated records
#'
#' Switches each value of a two-level variable to the other level with
#' probability `p`. The expert probability tables describe how uncertain one
#' variable is given its causes. They do not describe a value that was written
#' down wrongly, which this function adds.
#'
#' @param data A data frame of two-level factors.
#' @param p Probability that a recorded value is wrong.
#' @return The data frame with errors added.
#' @export
misrecord <- function(data, p) {
  data[] <- lapply(data, function(x) {
    # Choose which values to corrupt, each with probability p.
    flip <- stats::runif(length(x)) < p
    code <- as.integer(x)
    # Two-level factors are coded 1 and 2, so 3 - code swaps them.
    code[flip] <- 3L - code[flip]
    factor(levels(x)[code], levels = levels(x))
  })
  data
}
