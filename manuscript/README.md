# Literature review

| File | Role |
|---|---|
| `literature_review.qmd` | The text. Edit this. |
| `references.bib` | References, exported from Zotero |
| `_quarto.yml` | Output settings (HTML, Word, PDF) |
| `check_references.R` | Checks each reference against Crossref |

## Set up once

1. Install Quarto from <https://quarto.org/docs/get-started/> (tested with 1.11.9).
2. In Zotero, install the Better BibTeX plugin.
3. Make a Zotero collection for this review and add the four entries now in
   `references.bib`, or the first export will drop them.
4. Right-click the collection, choose *Export Collection*, pick *Better BibTeX*,
   tick *Keep updated*, and save over `manuscript/references.bib`.
5. In Better BibTeX, set the citation keys to match the ones in the text
   (`Heckerman_1995`, `Schwarz_1978`, `Scutari_2010`, `Whitney_2018`), or change
   the keys in the text.

## While writing

Run these from the repository root.

```bash
Rscript manuscript/check_references.R
```

```bash
quarto render manuscript
```

The outputs appear in `manuscript/_output/`. The LaTeX source for arXiv is
`manuscript/literature_review.tex`; git ignores it.

## Publishing the web page

`quarto publish gh-pages manuscript` puts the review on a public web page from a
separate `gh-pages` branch. Run it only when the text may be public. Do not point
GitHub Pages at the `docs/` folder, which holds other files.
