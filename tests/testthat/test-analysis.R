test_that("compare_structures drops incomplete rows and reports how many remain", {
  d <- literature_observations()
  res <- compare_structures(d, list(expert = expert_network(),
                                    other = expert_network("dagitty_v1")))
  expect_equal(res$n_complete[1], sum(stats::complete.cases(d)))
  expect_equal(res$shd_to_first[1], 0)
  expect_equal(res$shd_to_first[2], 3)
  expect_equal(max(res$delta_bic), 0)
})

test_that("recovery_study is reproducible and returns valid shares", {
  a <- recovery_study(n_grid = c(50, 200), reps = 3, seed = 3)
  b <- recovery_study(n_grid = c(50, 200), reps = 3, seed = 3)
  expect_identical(a, b)
  expect_equal(nrow(a), 6)
  expect_true(all(a$recall >= 0 & a$recall <= 1))
  expect_true(all(a$skeleton_recall >= a$recall))
})

test_that("an arc with an inert probability table is never reliably detected", {
  res <- arc_detectability(n_grid = 2000, reps = 20, seed = 5)
  shade <- res[res$from == "TreeDiversity" & res$to == "Shade", "power"]
  habitat <- res[res$from == "TreeDiversity" & res$to == "Habitat", "power"]
  expect_lt(shade, 0.5)
  expect_gt(habitat, 0.9)
})

test_that("edge_stability returns strengths between 0 and 1 and flags expert arcs", {
  d <- simulate_expert(300, seed = 11)
  s <- edge_stability(d, R = 10, seed = 2)
  expect_true(all(s$strength >= 0 & s$strength <= 1))
  expect_true(any(s$in_expert))
})

test_that("the causal order forbids backward arrows but no expert arrow", {
  bl <- causal_order_blacklist()
  forbidden <- paste(bl[, 1], bl[, 2], sep = "->")
  expect_true("Livelihoods->TreeDiversity" %in% forbidden)
  expect_length(intersect(forbidden, arc_keys(expert_network())), 0)
})

test_that("misrecord changes about the requested share of values", {
  d <- simulate_expert(2000, seed = 4)
  expect_identical(misrecord(d, 0), d)
  set.seed(1)
  m <- misrecord(d, 0.1)
  expect_lt(abs(mean(as.matrix(m) != as.matrix(d)) - 0.1), 0.01)
})

test_that("an arrow that is not real is usually rejected", {
  r <- arc_rejection(n_grid = 500, reps = 10, seed = 6, fit_n = 2e4)
  expect_equal(nrow(r), 19)
  expect_gt(median(r$rejected), 0.9)
})
