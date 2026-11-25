# A critical review of v1.0.0

This review covers version 1.0.0, the repository at commit `7b8215e`. Every
number below can be reproduced from the v2 code (`analysis/`, `tests/`), and the
commit keeps v1 intact (`git show 7b8215e:README.Rmd`).

## What v1 claimed

v1 described itself as a test of whether an expert-elicited causal diagram
"survives contact with data". It compared three structures: the expert diagram,
a diagram learned from 13 literature observations with `hc()`, and a diagram
learned from the same data with the expert diagram as the starting point.

## Problems that change the conclusions

**1. The data cannot test the diagram.** v1 uses 13 papers, 6 cells are missing,
and only 9 rows are complete. From those rows, `hc()` returns 25 arcs, which is
more than the 19 arcs the expert drew. A learned structure with more arcs than
rows is noise. v2 measures this directly. The power to detect an omitted arc at
n = 13 has a median of 0.01 (`results/detectability_at_n13.csv`). The data cannot
contradict the expert diagram, and they cannot support it either.

**2. Even ideal data recover little.** When v2 simulates data from the expert
model itself, the best case, hill climbing from scratch recovers 10% of the 19
arcs with correct direction at n = 13, 40% at n = 500 and 73% at n = 5,000
(`results/recovery.csv`). Learning a causal diagram from observational data of
this size is a weak test of any diagram.

**3. The README misdescribes the method.** v1 says the algorithm will "optimize
the model's parameters ... maximizing the model's predictive accuracy". `hc()`
does neither. It searches over structures (adding, deleting and reversing arcs)
to maximize a penalized likelihood score, and parameters are fitted afterwards.

**4. Two different diagrams were presented as one.** v1 plots a `dagitty`
diagram and analyzes a `bnlearn` diagram, and the README says "we build the same
graph". They differ: the analyzed diagram has the arcs `TreeDiversity -> Costs`
and `ExternalRisks -> Livelihoods`, and the plotted one instead has
`ExternalRisks -> Costs` (under the node name `ExternalFactors`). The plotted
diagram has 18 arcs and the analyzed one 19. On the 9 complete rows the plotted
diagram has the better BIC by 4.4 (`results/literature_structures.csv`), so the
choice between them changes the story. v2 keeps both as named variants and
tests the difference.

**5. The validation checks are circular.** The `cpquery()` checks ask the
network what the network's own probability tables imply. The "expected"
distribution for `Livelihoods` (0.7 Improved, 0.3 Not Improved) has no source.
None of these checks can fail on real data.

**6. No metric compares the three models.** v1 reads differences between the
three structures from plots. It reports no BIC, no structural distance and no
measure of uncertainty. It sets no random seed, so every knit changes the
Monte Carlo numbers, such as the probability of improved livelihoods.

**7. The coding of the observations cannot bear weight.** Each paper became one
row, but a paper is not a farm and papers differ in context. The coding
was done by hand, with no written protocol and no second coder, and a short
reason is recorded for one variable only.
"Moderate diversity" was coded `Low`. For `Timber`, `Firewood` and `Habitat`,
"not reported" was coded `No`, which cannot tell an absent product from an
unreported one.

**8. Some expert tables contradict their own comments or do nothing.**
`P(Timber = Yes | TreeDiversity = Low)` is 0.99 and `P(Timber = Yes |
TreeDiversity = High)` is 0.8, while the comment says timber without trees is
hard to imagine. The `Shade` table is 0.5 in every cell. In the `Costs` table,
varying `Firewood` or `Fruit` changes the probability by at most 0.05. The
power study confirms the consequence: four arcs in the diagram
(`TreeDiversity -> Shade`, `TreeDiversity -> Costs`, `Firewood -> Costs`,
`Fruit -> Costs`) have no detectable effect even at n = 5,000. Either those
arcs should go or the tables should change. This is an elicitation question, and
no amount of data can answer it. v2 keeps the probabilities unchanged so that
v2 describes the same expert model.

**9. The country-year experiment is not usable yet.** It built 16,317
country-year rows. Five of the 11 variables (`Timber`, `Firewood`, `Fruit`,
`Shade`, `Habitat`) have no data, and `Livelihoods` is observed for 17% of rows.
Several proxies are weak (overweight prevalence stands in for `Costs`, and
cooling degree days for `ExternalRisks`). Median splits discard information.
Consecutive years of one country are not independent, which breaks the
assumption of the BIC score. The README never used these data.

## Hygiene problems

- 16 MB of data in git, 13.7 MB of it a regenerable API download.
- Generated files in git: `README.html`, `Index.html`, figure folders.
- `functions/hill_climbing.R` copied `bnlearn::hc` and called an unexported
  internal (`greedy.search`), so sourcing it would fail. The README only pointed
  to it.
- `.Rprofile` activated `renv` on every start, so a plain `Rscript` failed
  without a restored library.
- Two similarly named summary CSVs (only one is used) and four overlapping bibliography files.
- `data/README.md` was an unedited template that described a different study
  ("urntask").
- No tests, no package structure, and no version in `CITATION.cff`.

## What v2 changes

| v1 problem | v2 response |
|---|---|
| 1, 2: unsupported claim | The repository now asks a question it can answer: how much data does it take to test this diagram? (`recovery_study()`, `arc_detectability()`) |
| 3: wrong method description | README rewritten; `compare_structures()` scores diagrams with BIC |
| 4: two diagrams | Both are named variants (`expert_network("bnlearn_v1")`, `("dagitty_v1")`), and a test pins their difference |
| 5, 6: circular checks, no metric, no seed | BIC, structural Hamming distance, bootstrap arc strength and an explicit seed in every analysis |
| 7: data coding | Observations moved to a CSV with a `source` column; coding limits documented in `?literature_observations` |
| 8: expert tables | Unchanged, flagged, and the power study shows their consequences |
| 9: country-year data | Moved to `data-raw/` and marked experimental |
| Hygiene | R package with a test suite, no generated files in git, `renv` kept but not auto-activated |

## What v2 still cannot do

- It has not tested the diagram against real data. The simulations use the
  expert's own probabilities, so they describe the best case.
- BIC power depends on how strong the expert tables make each arc. Different
  elicited numbers give different answers.
- The simulations assume independent records with no measurement error. Real
  farm surveys will do worse.
- The path to a real test is data on independent farms with all eleven variables
  measured on a written protocol. A few hundred records test only the stronger
  arcs: 7 of 19 are detectable at 500 records and 15 at 5,000
  (`results/detectability.csv`).
