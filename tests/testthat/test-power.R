test_that("effect size is zero for independence and known for a copy", {
  expect_equal(arrow_information(matrix(0.25, 1, 4)), 0)
  expect_equal(arrow_information(matrix(c(0.5, 0, 0, 0.5), 1)), log(2))
})

test_that("family tables are distributions", {
  fam <- arrow_families(expert_fit())
  expect_length(fam, 19)
  for (f in fam) expect_equal(sum(f$prob), 1)
})

test_that("simulating cell counts agrees with scoring whole records", {
  set.seed(1)
  fit <- expert_fit()
  f <- Filter(function(f) f$from == "Market" && f$to == "Benefits",
              arrow_families(fit))[[1]]
  full <- bnlearn::bn.net(fit)
  rival <- bnlearn::drop.arc(full, "Market", "Benefits")
  records <- mean(replicate(400, {
    d <- bnlearn::rbn(fit, 250)
    bnlearn::score(full, d, type = "bic") > bnlearn::score(rival, d, type = "bic")
  }))
  expect_equal(simulate_power(f$prob, 250, 4000), records, tolerance = 0.1)
})

test_that("more effect needs fewer records, more causes need more", {
  expect_lt(records_needed(0.05, 3), records_needed(0.01, 3))
  expect_lt(records_needed(0.01, 1), records_needed(0.01, 5))
  expect_equal(records_needed(0, 2), Inf)
})
