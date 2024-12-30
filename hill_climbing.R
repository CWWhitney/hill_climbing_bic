# Example with hill climbing (using bnlearn)
library(bnlearn)
# Score-based structure learning algorithms
# Learn the structure of a Bayesian network using a hill-climbing algorithm

# Example of observed data with some missing values (NA) for unobserved nodes
observed_data <- data.frame(
  TreesOnFarm = c("Yes", "No", "Yes", "Yes", "Yes"),
  Timber = c("Yes", "No", "Yes", "No", "Yes"),
  Firewood = c("Yes", NA, "No", "Yes", NA),
  Fruit = c("No", "Yes", NA, "No", "Yes"),
  Market = c(NA, "Low", "High", "Low", "High"),
  Shade = c("Yes", "No", "Yes", NA, "No"),
  Habitat = c("Yes", NA, "No", "Yes", "No"),
  ExternalRisks = c("Low", "High", "High", "Low", "Low"),
  Costs = c("High", "Low", "Low", NA, "High"),
  Benefits = c("Low", "High", "Low", "High", NA),
  Livelihoods = c(NA, "Improved", "Improved", "Not Improved", "Improved")
)

# These 'observations' are based on reports from 5 publications

# "Agroforestry for Sustainable Development: Evidence from Smallholder Farms in
# Sub-Saharan Africa" (FAO Report): data about tree planting systems, timber,
# firewood, fruit, and market access in Sub-Saharan Africa. insight into whether
# these systems are beneficial and whether they are contributing to improved
# livelihoods.

# "Impact of Agroforestry Systems on Livelihoods: A Case Study in Central
# India":  data on how agroforestry affects the livelihoods of smallholder
# farmers, including income from timber, firewood, and fruit production.

# "The Role of Agroforestry in Climate Change Adaptation and Mitigation" (IPCC
# Report):  data on external risks such as climate change, and how different
# agroforestry systems mitigate these risks, which could help fill the
# "ExternalRisks" column

# "Socioeconomic Impacts of Agroforestry on Farmers: A Longitudinal Study":
# detailed information on market access, income sources (such as timber,
# firewood, and fruit), and how these affect costs and benefits

# "Agroforestry and Sustainable Land Management: A Study in Southeast Asia":
# insight into the habitat services provided by agroforestry, such as
# biodiversity, as well as its economic impacts,

# Convert character columns to factors
observed_data$TreesOnFarm <- as.factor(observed_data$TreesOnFarm)
observed_data$Timber <- as.factor(observed_data$Timber)
observed_data$Firewood <- as.factor(observed_data$Firewood)
observed_data$Fruit <- as.factor(observed_data$Fruit)
observed_data$Market <- as.factor(observed_data$Market)
observed_data$Shade <- as.factor(observed_data$Shade)
observed_data$Habitat <- as.factor(observed_data$Habitat)
observed_data$ExternalRisks <- as.factor(observed_data$ExternalRisks)
observed_data$Costs <- as.factor(observed_data$Costs)
observed_data$Benefits <- as.factor(observed_data$Benefits)
observed_data$Livelihoods <- as.factor(observed_data$Livelihoods)

source("model_in_bnlearn.R")
# plot when we use the observations alone
fitted_model <- hc(observed_data)
plot(fitted_model)

# when we use the original network structure as a start
hill_climbing_model <- hc(x= observed_data, start = network_structure)
plot(fitted_model)
