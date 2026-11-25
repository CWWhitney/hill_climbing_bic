
<!-- more_results.md is generated from more_results.Rmd. Please edit that file -->

# More results

These results use other methods than the one-arrow test on the [main
page](../README.md).

## Searching for the whole DAG

Hill climbing starts with no arrows. It adds, removes or reverses one
arrow at a time and keeps each change that raises the BIC. We ran it on
500 simulated farm records, 100 times in each setting.

| Setting                        | Expert arrows found (of 19) | Wrong arrows per 100 drawn |
|:-------------------------------|----------------------------:|---------------------------:|
| No other information           |                           8 |                         26 |
| Order of causes given          |                          10 |                          1 |
| 5% of states recorded wrongly  |                           6 |                         34 |
| 10% of states recorded wrongly |                           5 |                         40 |

An arrow counts as found only if it points the right way. “Order of
causes given” means the search was barred from drawing arrows backwards,
for example from `Livelihoods` to `TreeDiversity`. The order given was
correct.

## Thirteen published studies

Each study was treated as one farm record, with a state chosen by hand
for each variable. Only 9 records were complete, and BIC needs complete
records. On those, a hill-climbing search drew 25 arrows, more than the
expert’s 19. A study is not a farm, and a sample this small cannot test
the DAG.
