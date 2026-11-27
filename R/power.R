#' Family tables of every arrow in a binary network
#'
#' For each arrow, the exact joint distribution of the effect, the cause and the
#' effect's other causes, obtained by listing every state of the network.
#'
#' @param fit A `bn.fit` object in which every variable has two states.
#' @return A list with one element per arrow: `from`, `to`, `causes` (number of
#'   causes of the effect), `prob` (a matrix with one row per state of the other
#'   causes and four columns: cause and effect states 11, 21, 12, 22) and
#'   `change` (largest difference the cause makes to the effect's probability).
#' @export
arrow_families <- function(fit) {
  nodes <- names(fit)
  state <- as.matrix(expand.grid(rep(list(1:2), length(nodes))))
  colnames(state) <- nodes
  joint <- rep(1, nrow(state))
  for (v in nodes) {
    tab <- fit[[v]]$prob
    vars <- if (length(fit[[v]]$parents)) c(v, fit[[v]]$parents) else v
    joint <- joint * as.vector(tab[state[, vars, drop = FALSE]])
  }
  a <- bnlearn::arcs(fit)
  lapply(seq_len(nrow(a)), function(i) {
    from <- unname(a[i, 1])
    to <- unname(a[i, 2])
    other <- setdiff(fit[[to]]$parents, from)
    z <- if (length(other)) {
      drop((state[, other, drop = FALSE] - 1) %*% 2^(seq_along(other) - 1))
    } else rep(0, nrow(state))
    cell <- state[, from] + 2 * (state[, to] - 1)
    prob <- unclass(stats::xtabs(joint ~ factor(z, 0:(2^length(other) - 1)) +
                                   factor(cell, 1:4)))
    dimnames(prob) <- NULL
    attr(prob, "call") <- NULL
    p1 <- prob[, 1] / (prob[, 1] + prob[, 3])
    p2 <- prob[, 2] / (prob[, 2] + prob[, 4])
    list(from = from, to = to, causes = length(other) + 1, prob = prob,
         change = max(abs(p1 - p2), na.rm = TRUE))
  })
}

#' Effect size of an arrow
#'
#' The conditional mutual information of cause and effect given the other
#' causes, in natural units: the expected gain in log-likelihood per record
#' from keeping the arrow.
#'
#' @param prob A family table from [arrow_families()].
#' @return A single non-negative number.
#' @export
arrow_information <- function(prob) {
  prob <- matrix(prob, ncol = 4)
  total <- rowSums(prob)
  x1 <- prob[, 1] + prob[, 3]
  x2 <- prob[, 2] + prob[, 4]
  y1 <- prob[, 1] + prob[, 2]
  y2 <- prob[, 3] + prob[, 4]
  ratio <- prob * total / cbind(x1 * y1, x2 * y1, x1 * y2, x2 * y2)
  max(0, sum((prob * log(ratio))[prob > 0]))
}

#' Large-sample power of the one-arrow BIC test
#'
#' Twice the gain in log-likelihood is treated as noncentral chi-squared with
#' `d = 2^(causes - 1)` degrees of freedom and noncentrality `2 n information`.
#' The arrow is kept when it exceeds `d log(n)`.
#'
#' @param n Number of records.
#' @param information Effect size from [arrow_information()].
#' @param causes Number of causes of the effect, including the tested one.
#' @return `arrow_power()` returns the probability that the arrow is kept.
#'   `records_needed()` returns the smallest `n` (at least 10) from which power
#'   stays at or above `target`, to within about 2%, or `Inf`.
#' @export
arrow_power <- function(n, information, causes) {
  d <- 2^(causes - 1)
  stats::pchisq(d * log(n), df = d, ncp = 2 * n * information, lower.tail = FALSE)
}

#' @rdname arrow_power
#' @param target Required power.
#' @export
records_needed <- function(information, causes, target = 0.8) {
  n <- unique(round(10^seq(1, 7, by = 0.01)))
  below <- which(arrow_power(n, information, causes) < target)
  if (!length(below)) return(n[1])
  if (max(below) == length(n)) return(Inf)
  n[max(below) + 1]
}

#' Simulate the one-arrow test from a family table
#'
#' Draws the cell counts of `n` records directly, which is equivalent to
#' simulating whole records and much faster.
#'
#' @param prob A family table from [arrow_families()].
#' @param n Number of records.
#' @param reps Number of simulated samples.
#' @return The share of samples in which BIC keeps the arrow.
#' @export
simulate_power <- function(prob, n, reps = 1000) {
  prob <- matrix(prob, ncol = 4)
  d <- nrow(prob)
  counts <- stats::rmultinom(reps, n, as.vector(prob))
  nlogn <- function(x) ifelse(x > 0, x * log(x), 0)
  g2 <- vapply(seq_len(reps), function(r) {
    m <- matrix(counts[, r], ncol = 4)
    2 * (sum(nlogn(m)) + sum(nlogn(rowSums(m))) -
           sum(nlogn(m[, c(1, 2), drop = FALSE] + m[, c(3, 4), drop = FALSE])) -
           sum(nlogn(m[, c(1, 3), drop = FALSE]  + m[, c(2, 4), drop = FALSE])))
  }, numeric(1))
  mean(g2 > d * log(n))
}

#' A random binary diagram
#'
#' Variables are placed in a causal order. Each draws a number of causes
#' uniformly from none to `max_causes` (limited by the variables before it),
#' and each probability is uniform between `range[1]` and `range[2]`.
#'
#' @param nodes Number of variables.
#' @param max_causes Largest number of causes of one variable.
#' @param range Limits of the probabilities.
#' @return A `bn.fit` object.
#' @export
random_diagram <- function(nodes = 11, max_causes = 5, range = c(0.05, 0.95)) {
  v <- paste0("V", seq_len(nodes))
  parents <- lapply(seq_len(nodes), function(i) {
    k <- sample.int(min(i - 1, max_causes) + 1, 1) - 1
    v[sample.int(i - 1, k)]
  })
  net <- bnlearn::empty.graph(v)
  bnlearn::arcs(net) <- cbind(unlist(parents), rep(v, lengths(parents)))
  tables <- lapply(seq_len(nodes), function(i) {
    vars <- c(v[i], bnlearn::parents(net, v[i]))
    p <- stats::runif(2^(length(vars) - 1), range[1], range[2])
    array(as.vector(rbind(p, 1 - p)), dim = rep(2, length(vars)),
          dimnames = stats::setNames(rep(list(c("a", "b")), length(vars)), vars))
  })
  bnlearn::custom.fit(net, stats::setNames(tables, v))
}
