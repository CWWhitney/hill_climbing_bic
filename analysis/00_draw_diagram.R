# Step 0 of 4. Output: results/diagram.png (shown in the README).
# Box positions are chosen by hand so that no arrow passes behind a box.

# Draw the expert diagram for the README.
# Run from the repository root:  Rscript analysis/00_draw_diagram.R

edges <- read.csv("inst/extdata/expert_dag_edges.csv")
edges <- edges[edges$variant == "bnlearn_v1", ]

# name = c(x, y, label)
pos <- list(
  TreeDiversity = list(0.8, 5.0, "Tree\ndiversity"),
  Timber        = list(3.4, 8.2, "Timber"),
  Firewood      = list(3.4, 6.6, "Firewood"),
  Fruit         = list(3.4, 5.0, "Fruit"),
  Shade         = list(3.4, 3.4, "Shade"),
  Habitat       = list(3.4, 1.8, "Habitat"),
  Market        = list(6.0, 4.9, "Market"),
  Costs         = list(8.4, 8.2, "Costs"),
  Benefits      = list(8.4, 3.4, "Benefits"),
  Livelihoods   = list(11.0, 5.0, "Livelihoods"),
  ExternalRisks = list(11.0, 1.6, "External\nrisks")
)
w <- 0.8; h <- 0.55  # half width and half height of a box

# point where a line leaving a box centre crosses the box edge
edge_point <- function(x0, y0, x1, y1) {
  t <- min(w / abs(x1 - x0), h / abs(y1 - y0))
  c(x0 + t * (x1 - x0), y0 + t * (y1 - y0))
}

# Draw the arrows first, then the boxes on top of them.
png("results/diagram.png", width = 2000, height = 1350, res = 200)
par(mar = c(0, 0, 0, 0))
plot(NA, xlim = c(-0.2, 12), ylim = c(0.9, 9.9), axes = FALSE, xlab = "", ylab = "")
for (i in seq_len(nrow(edges))) {
  a <- pos[[edges$from[i]]]; b <- pos[[edges$to[i]]]
  # the long arrow from tree diversity to costs goes round the top
  if (edges$from[i] == "TreeDiversity" && edges$to[i] == "Costs") {
    lines(c(a[[1]], a[[1]], b[[1]]), c(a[[2]] + h, 9.6, 9.6), col = "grey35", lwd = 1.4)
    arrows(b[[1]], 9.6, b[[1]], b[[2]] + h, length = 0.08, col = "grey35", lwd = 1.4)
    next
  }
  s <- edge_point(a[[1]], a[[2]], b[[1]], b[[2]])
  e <- edge_point(b[[1]], b[[2]], a[[1]], a[[2]])
  arrows(s[1], s[2], e[1], e[2], length = 0.08, col = "grey35", lwd = 1.4)
}
for (p in pos) {
  rect(p[[1]] - w, p[[2]] - h, p[[1]] + w, p[[2]] + h, col = "white", border = "black")
  text(p[[1]], p[[2]], p[[3]], cex = 0.85)
}
invisible(dev.off())
