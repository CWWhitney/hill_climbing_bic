# Load the required package
library(dagitty)

# Define the causal model as a DAG
dag <- dagitty(" {
  TreesOnFarm -> Timber
  TreesOnFarm -> Firewood
  TreesOnFarm -> Shade
  TreesOnFarm -> Fruit
  TreesOnFarm -> Habitat

  Timber -> Costs
  Firewood -> Costs
  Fruit -> Costs

  Timber -> Market
  Firewood -> Market
  Fruit -> Market

  Market -> Benefits

  Shade -> Benefits
  Habitat -> Benefits

  Costs -> Livelihoods
  Benefits -> Livelihoods

  ExternalFactors -> Costs
  ExternalFactors -> Benefits
}
")

# Define the coordinates for node placement, including the new 'Market' node and updated positions
coordinates(dag) <- list(
  x = c(
    TreesOnFarm = 0,
    Costs = 3,
    Benefits = 3,
    Livelihoods = 4,
    Timber = 1.3,
    Firewood = 1.3,
    Fruit = 1.3,
    Shade = 1.3,
    Habitat = 1.3,
    ExternalFactors = 1.5,
    Market = 2.5
  ),
  y = c(
    TreesOnFarm = 0,
    Costs = 0.3,
    Benefits = -0.3,
    Livelihoods = 0,
    Timber = -.6,
    Firewood = -1,
    Fruit = -0.3,
    Shade = 0.3,
    Habitat = 0.7,
    ExternalFactors = 1.5,
    Market = -0.6
  )
)

# Plot the DAG to visualize the updated graph
plot(dag)

