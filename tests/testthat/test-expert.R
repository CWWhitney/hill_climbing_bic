test_that("expert structures are acyclic with the documented arc counts", {
  expect_true(bnlearn::acyclic(expert_network("bnlearn_v1")))
  expect_true(bnlearn::acyclic(expert_network("dagitty_v1")))
  expect_equal(bnlearn::narcs(expert_network("bnlearn_v1")), 19)
  expect_equal(bnlearn::narcs(expert_network("dagitty_v1")), 18)
})

test_that("the two v1 structures differ in exactly the documented arcs", {
  a <- arc_keys(expert_network("bnlearn_v1"))
  b <- arc_keys(expert_network("dagitty_v1"))
  expect_setequal(setdiff(a, b),
    c("TreeDiversity->Costs", "ExternalRisks->Livelihoods"))
  expect_setequal(setdiff(b, a), c("ExternalRisks->Costs"))
})

test_that("every expert probability table sums to one", {
  fit <- expert_fit()
  for (nm in names(fit)) {
    p <- fit[[nm]]$prob
    d <- length(dim(p))
    s <- if (d == 1) sum(p) else apply(p, 2:d, sum)
    expect_equal(as.numeric(s), rep(1, length(s)), tolerance = 1e-8, info = nm)
  }
})

test_that("simulated data have the right shape, levels and seed behavior", {
  d1 <- simulate_expert(200, seed = 7)
  d2 <- simulate_expert(200, seed = 7)
  expect_equal(dim(d1), c(200, 11))
  expect_identical(d1, d2)
  expect_equal(levels(d1$Livelihoods), c("Improved", "Not Improved"))
})

test_that("literature observations load as 13 rows of factors", {
  d <- literature_observations()
  expect_equal(nrow(d), 13)
  expect_true(all(vapply(d, is.factor, logical(1))))
  expect_equal(sum(is.na(d)), 6)
})
