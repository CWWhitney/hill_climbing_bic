#' Expert causal structures of the agroforestry example
#'
#' v1.0.0 held two versions of the expert diagram that were described as the
#' same graph but differ. Both are kept here as named variants so that the
#' difference is explicit.
#'
#' * `"bnlearn_v1"` (19 arcs) is the structure that v1 analyzed and that the
#'   expert probability tables in [expert_cpts()] belong to.
#' * `"dagitty_v1"` (18 arcs) is the structure that v1 plotted. It has no arc
#'   from `TreeDiversity` to `Costs` and sends `ExternalRisks` (called
#'   `ExternalFactors` in v1) to `Costs` and `Benefits`, not to `Livelihoods`.
#'
#' @param variant One of `"bnlearn_v1"` (default) or `"dagitty_v1"`.
#' @return `expert_edges()` returns a data frame with columns `from` and `to`.
#'   `expert_network()` returns a `bn` object from the bnlearn package.
#' @examples
#' expert_edges()
#' bnlearn::narcs(expert_network())
#' @export
expert_edges <- function(variant = c("bnlearn_v1", "dagitty_v1")) {
  variant <- match.arg(variant)
  path <- system.file("extdata", "expert_dag_edges.csv", package = "hcbic")
  e <- utils::read.csv(path, stringsAsFactors = FALSE)
  e <- e[e$variant == variant, c("from", "to")]
  rownames(e) <- NULL
  e
}

#' @rdname expert_edges
#' @export
expert_network <- function(variant = c("bnlearn_v1", "dagitty_v1")) {
  e <- expert_edges(match.arg(variant))
  net <- bnlearn::empty.graph(sort(unique(c(e$from, e$to))))
  bnlearn::arcs(net) <- as.matrix(e)
  net
}

#' Expert network with its expert probability tables
#'
#' @return A `bn.fit` object built from [expert_network()] and [expert_cpts()].
#' @export
expert_fit <- function() {
  bnlearn::custom.fit(expert_network("bnlearn_v1"), dist = expert_cpts())
}

#' Literature observations used in v1
#'
#' Thirteen papers, each coded by hand into binary or two-level states. Cells
#' that the paper does not report are `NA`, except `Timber`, `Firewood` and
#' `Habitat`, where v1 coded "not reported" as `"No"`. That coding cannot tell
#' an absent product from an unreported one.
#'
#' @param with_source Keep the `source` column (the bibliography key)?
#' @return A data frame of factors, one row per paper.
#' @export
literature_observations <- function(with_source = FALSE) {
  path <- system.file("extdata", "literature_observations.csv", package = "hcbic")
  d <- utils::read.csv(path, stringsAsFactors = FALSE, na.strings = "")
  src <- d$source
  d$source <- NULL
  d[] <- lapply(d, as.factor)
  if (with_source) cbind(source = src, d) else d
}
