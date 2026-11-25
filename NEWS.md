# hcbic 2.0.0

A rebuild of version 1.0.0 (see `docs/v1_critique.md` for the review that motivated it).

* New question: how much data does it take to recover or contradict an expert
  causal diagram? `recovery_study()` and `arc_detectability()` answer it by
  simulation from the expert model.
* The repository is now an R package with tests.
* Both versions of the expert diagram that v1 mixed up are kept as named
  variants, `"bnlearn_v1"` and `"dagitty_v1"`. The expert probability tables are
  unchanged.
* `compare_structures()` scores diagrams with BIC and reports structural
  distance. `edge_stability()` reports bootstrap arc strength.
* The 13 literature observations are a CSV with a `source` column.
* The country-year experiment moved to `data-raw/` and is marked experimental.
* Generated files, the 13.7 MB raw download and a dead copy of `hc()` left git.
* Every analysis sets a random seed.
* `arc_rejection()` runs the one-arrow test in worlds where the arrow is not real.
* `causal_order_blacklist()` and `misrecord()`, with a third analysis, show what
  knowing the order of causes gains and what recording errors cost.

# hcbic 1.0.0

Commit `7b8215e`: hill climbing on 13 literature observations compared with a
hand-built expert diagram.
