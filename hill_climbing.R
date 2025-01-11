hc <- function (x, start = NULL, whitelist = NULL, blacklist = NULL,
                score = NULL, ..., debug = FALSE, restart = 0, perturb = 1,
                max.iter = Inf, maxp = Inf, optimized = TRUE)
{
  greedy.search(x = x, start = start, whitelist = whitelist,
                blacklist = blacklist, score = score, heuristic = "hc",
                debug = debug, ..., restart = restart, perturb = perturb,
                max.iter = max.iter, maxp = maxp, optimized = optimized)
}
