# Load required libraries
library(bnlearn)

### Step 1: Define the model structure ####
# Define the Bayesian Network structure manually for the DAG
# (11 nodes, 19 arcs)
model_string <- "
 [TreesOnFarm]
 [ExternalRisks]
 [Timber | TreesOnFarm]
 [Fruit | TreesOnFarm]
 [Firewood | TreesOnFarm]
 [Market | Timber:Firewood:Fruit]
 [Shade | TreesOnFarm]
 [Habitat | TreesOnFarm]
 [Costs | Timber:Firewood:Fruit:TreesOnFarm]
 [Benefits | Market:Shade:Habitat:ExternalRisks]
 [Livelihoods | Costs:Benefits:ExternalRisks]
"

# Remove all spaces from the model_string using gsub()
model_string_no_spaces <- gsub("\\s", "", model_string)
# must be a single line without spaces (very inflexible)

# Create the Bayesian Network using bnlearn's model2network function
network_structure <- model2network(model_string_no_spaces)

# plot(network_structure)

### Step 2: Conditional Probability Tables (CPTs) ####
# Define the CPTs for each node based on expert knowledge
# Assuming the variables have two states: Yes/No for binary variables, and Low/High for costs and benefits

# 1. TreesOnFarm has no parents (Yes/No) ####
cpt_TreesOnFarm <- matrix(c(0.5, # TreesOnFarm = Yes
                            0.5), # TreesOnFarm = No
                          ncol = 2, dimnames = list(NULL, c("Yes", "No")))

# 2. Timber depends on TreesOnFarm (Yes/No) ####
# Define CPT for Timber with 2 states for TreesOnFarm and 2 states for Timber
cpt_Timber <- matrix(c(0.8, # TreesOnFarm = Yes & Timber:Yes,
                       0.2, #TreesOnFarm = Yes & Timber: No
                       # hard to imagine timber without trees
                       0.99, # TreesOnFarm = No & Timber: Yes
                       0.01), # TreesOnFarm = No, Timber: No
                     ncol = 2)

# Set the dimension to have 2 rows (for Timber) and 2 columns (for TreesOnFarm)
dim(cpt_Timber) <- c(2, 2)

# Define dimnames for the matrix
dimnames(cpt_Timber) <- list(
  "Timber" = c("Yes", "No"), # States for the Timber node
  "TreesOnFarm" = c("Yes", "No")   # States for the TreesOnFarm node
)

# 3. Fruit depends on TreesOnFarm (Yes/No) ####
# Define CPT for Fruit with 2 states for TreesOnFarm and 2 states for Fruit
cpt_Fruit <- matrix(c(0.7, # TreesOnFarm = Yes, Fruit: Yes
                      0.3, # TreesOnFarm = Yes, Fruit: No
                      # can still grow fruit without trees
                      0.2, # TreesOnFarm = No, Fruit: Yes
                      0.8), # TreesOnFarm = No, Fruit: No
                    ncol = 2)

# Set the dimension to have 2 rows (for Yes/No) and 2 columns (for TreesOnFarm)
dim(cpt_Fruit) <- c(2, 2)

# Define dimnames for the matrix
dimnames(cpt_Fruit) <- list(
  "Fruit" = c("Yes", "No"), # States for the Fruit node
  "TreesOnFarm" = c("Yes", "No")   # States for the TreesOnFarm node
)

# 4. Firewood depends on TreesOnFarm (Yes/No) ####
# Define CPT for Firewood with 2 states for TreesOnFarm and 2 states for Firewood
cpt_Firewood <- matrix(c(0.7, # TreesOnFarm = Yes, Firewood: Yes
                         0.3, # TreesOnFarm = Yes, Firewood: No
                         # hard to imagine firewood without trees
                         0.01, # TreesOnFarm = No, Firewood: Yes
                         0.99), # TreesOnFarm = No, Firewood: No
                       ncol = 2)

# Set the dimension to have 2 rows (for Firewood) and 2 columns (for TreesOnFarm)
dim(cpt_Firewood) <- c(2, 2)

# Define dimnames for the matrix
dimnames(cpt_Firewood) <- list(
  "Firewood" = c("Yes", "No"), # States for the Firewood node
  "TreesOnFarm" = c("Yes", "No") # States for the TreesOnFarm node
)

# 5. Market depends on Timber, Firewood, and Fruit ####
# Define the CPT for Market with combinations of Timber, Firewood, and Fruit (in c() format)
cpt_Market <- c(
  # Firewood = Yes, Fruit = Yes
  0.95, # Market High if Timber: Yes
  0.05, # Market Low if Timber: Yes
  0.8, # Market High if Timber: No
  0.2, # Market Low if Timber: No
  # Firewood = No, Fruit = Yes
  0.8, # Market High if Timber: Yes
  0.2, # Market Low if Timber: Yes
  0.6, # Market High if Timber: No
  0.4, # Market Low if Timber: No
  # Firewood = Yes, Fruit = No
  0.6, # Market High if Timber: Yes
  0.4, # Market Low if Timber: Yes
  0.4, # Market High if Timber: No
  0.6, # Market Low if Timber: No
  # Firewood = No, Fruit = No
  0.55, # Market High if Timber: Yes
  0.45, # Market Low if Timber: Yes
  0.3, # Market High if Timber: No
  0.7  # Market Low if Timber: No
)

# Set the dimensions of the matrix (8 combinations of Timber, Firewood, and Fruit, and 2 outcomes: High, Low)
dim(cpt_Market) <- c(2, 2, 2, 2)

# Assign the correct dimnames (8 combinations of parent nodes, 2 outcomes for Market)
# [Market | Timber:Firewood:Fruit]
dimnames(cpt_Market) <- list(
  "Market" = c("High", "Low"),
  "Timber" = c("Yes", "No"),
  "Firewood" = c("Yes", "No"),
  "Fruit" = c("Yes", "No")
)

# 6. Shade depends on TreesOnFarm (Yes/No) ####
# Define CPT for Shade with 2 states for TreesOnFarm and 2 states for Shade
cpt_Shade <- matrix(c(0.5, 0.5, # TreesOnFarm = Yes, Shade: Yes/No
                      0.5, 0.5), # TreesOnFarm = No, Shade: Yes/No
                    ncol = 2)

# Set the dimension to have 2 rows (for Shade) and 2 columns (for TreesOnFarm)
dim(cpt_Shade) <- c(2, 2)

# Define dimnames for the matrix
dimnames(cpt_Shade) <- list(
  "Shade" = c("Yes", "No"),  # States for the Shade node
  "TreesOnFarm" = c("Yes", "No")   # States for the TreesOnFarm node
)

# 7. Habitat depends on TreesOnFarm (Yes/No) ####
# Define CPT for Habitat with 2 states for TreesOnFarm and 2 states for Habitat
cpt_Habitat <- matrix(c(0.95, # habitat yes when trees on farm
                        0.05, # habitat no when trees on farm
                        0.2, # habitat yes when no trees on farm
                        0.8), # habitat no when no trees on farm
                      ncol = 2)

# Set the dimension to have 2 rows (for Habitat) and 2 columns (for TreesOnFarm)
dim(cpt_Habitat) <- c(2, 2)

# Define dimnames for the matrix
dimnames(cpt_Habitat) <- list(
  "Habitat" = c("Yes", "No"),  # States for the Habitat node
  "TreesOnFarm" = c("Yes", "No") # States for the TreesOnFarm node
)

# 8. Costs depend on TreesOnFarm, Timber, Firewood, and Fruit ####
# Define the CPT for Costs with combinations of TreesOnFarm, Timber, Firewood, and Fruit (in c() format)
cpt_Costs <- c(
  # Firewood = Yes, Fruit = Yes, TreesOnFarm = Yes
  0.65, # costs high when Timber: Yes
  0.35, # costs low when Timber: Yes
  0.35, # costs high when Timber: No
  0.65, # costs low when Timber: No
  # Firewood = No, Fruit = Yes, TreesOnFarm = Yes
  0.6, # costs high when Timber: Yes
  0.4, # costs low when Timber: Yes
  0.4, # costs high when Timber: No
  0.6, # costs low when Timber: No
  # Firewood = Yes, Fruit = No, TreesOnFarm = Yes
  0.65, # costs high when Timber: Yes
  0.35, # costs low when Timber: Yes
  0.35, # costs high when Timber: No
  0.65, # costs low when Timber: No
  # Firewood = No, Fruit = No, TreesOnFarm = Yes
  0.65, # costs high when Timber: Yes
  0.35, # costs low when Timber: Yes
  0.35, # costs high when Timber: No
  0.65, # costs low when Timber: No
  # Firewood = Yes, Fruit = Yes, TreesOnFarm = No
  # with no trees the rest of these cost estimates are hard to guage
  0.7, # costs high when Timber: Yes
  0.3, # costs low when Timber: Yes
  0.3, # costs high when Timber: No
  0.7, # costs low when Timber: No
  # Firewood = No, Fruit = Yes, TreesOnFarm = No
  0.7, # costs high when Timber: Yes
  0.3, # costs low when Timber: Yes
  0.3, # costs high when Timber: No
  0.7, # costs low when Timber: No
  # Firewood = Yes, Fruit = No, TreesOnFarm = No
  0.7, # costs high when Timber: Yes
  0.3, # costs low when Timber: Yes
  0.3, # costs high when Timber: No
  0.7, # costs low when Timber: No
  # Firewood = No, Fruit = No, TreesOnFarm = No
  0.7, # costs high when Timber: Yes
  0.3, # costs low when Timber: Yes
  0.3, # costs high when Timber: No
  0.7 # costs low when Timber: No
)

# Set the dimensions of the matrix (16 combinations of TreesOnFarm, Timber, Firewood, and Fruit, and 2 outcomes: High, Low)
dim(cpt_Costs) <- c(2, 2, 2, 2, 2)

# Assign the correct dimnames (16 combinations of parent nodes, 2 outcomes for Costs)
# [Costs | Timber:Firewood:Fruit:TreesOnFarm]
dimnames(cpt_Costs) <- list(
  "Costs" = c("High", "Low"),
  "Timber" = c("Yes", "No"),
  "Firewood" = c("Yes", "No"),
  "Fruit" = c("Yes", "No"),
  "TreesOnFarm" = c("Yes", "No")
)

# 9. ExternalRisks has no parents, simple distribution (Yes/No) ####
cpt_ExternalRisks <- matrix(c(0.6, #ExternalRisks = Yes
                              0.4), #ExternalRisks = No
                            ncol = 2, dimnames = list(NULL, c("High", "Low")))

# 10. Benefits depends on Market, Shade, Habitat, and ExternalRisks (16 combinations)
# Define the CPT for Benefits manually (16 combinations)
# Define the CPT for Benefits with combinations of Market, Shade, Habitat, and ExternalRisks
cpt_Benefits <- c(
  # Shade = Yes, Habitat = Yes, ExternalRisks = High
  0.7, # benefits high when market high
  0.3, # benefits low when market high
  0.3, # benefits high when market low
  0.7, # benefits low when market low
  # Shade = No, Habitat = Yes, ExternalRisks = High
  0.7, # benefits high when market high
  0.3, # benefits low when market high
  0.3, # benefits high when market low
  0.7, # benefits low when market low
  # Shade = Yes, Habitat = No, ExternalRisks = High
  0.7, # benefits high when market high
  0.3, # benefits low when market high
  0.3, # benefits high when market low
  0.7, # benefits low when market low
  # Shade = No, Habitat = No, ExternalRisks = High
  0.7, # benefits high when market high
  0.3, # benefits low when market high
  0.3, # benefits high when market low
  0.7, # benefits low when market low
  # Shade = Yes, Habitat = Yes, ExternalRisks = Low
  0.95, # benefits high when market high
  0.05, # benefits low when market high
  0.3, # benefits high when market low
  0.7, # benefits low when market low
  # Shade = No, Habitat = Yes, ExternalRisks = Low
  0.7, # benefits high when market high
  0.3, # benefits low when market high
  0.3, # benefits high when market low
  0.7, # benefits low when market low
  # Shade = Yes, Habitat = No, ExternalRisks = Low
  0.7, # benefits high when market high
  0.3, # benefits low when market high
  0.3, # benefits high when market low
  0.7, # benefits low when market low
  # Shade = No, Habitat = No, ExternalRisks = Low
  0.7, # benefits high when market high
  0.3, # benefits low when market high
  0.3, # benefits high when market low
  0.7 # benefits low when market low
)

# Set the dimensions of the matrix (16 combinations of Market, Shade, Habitat, ExternalRisks, and 2 outcomes: High, Low)
dim(cpt_Benefits) <- c(2, 2, 2, 2, 2)

# Assign the correct dimnames (16 combinations of parent nodes, 2 outcomes for Benefits)
# [Benefits | Market:Shade:Habitat:ExternalRisks]
dimnames(cpt_Benefits) <- list(
  "Benefits" = c("High", "Low"),
  "Market" = c("High", "Low"),
  "Shade" = c("Yes", "No"),
  "Habitat" = c("Yes", "No"),
  "ExternalRisks" = c("High", "Low")
)

# 11. Define the CPT for Livelihoods (depends on Costs, Benefits, and ExternalRisks) ####
# There are 8 combinations for Costs, Benefits, and ExternalRisks
# Define the CPT for Livelihoods with combinations of Costs, Benefits, and ExternalRisks
# [Livelihoods | Costs:Benefits:ExternalRisks]
cpt_Livelihoods <- c(
  # Benefits = High, ExternalRisks = High
  0.6, # Livelihoods:Improved when Costs:High
  0.4, # Livelihoods:Not Improved when Costs:High
  0.8, # Livelihoods:Improved when Costs:Low
  0.2, # Livelihoods:NotnImproved & Costs:Low
  # Benefits = Low, ExternalRisks = High
  0.55, # Livelihoods:Improved when Costs:High
  0.45, # Livelihoods:Not Improved when Costs:High
  0.6, # Livelihoods:Improved when Costs:Low
  0.4, # Livelihoods:NotnImproved & Costs:Low
  # Benefits = High, ExternalRisks = Low
  0.7, # Livelihoods:Improved when Costs:High
  0.3, # Livelihoods:Not Improved when Costs:High
  0.99, # Livelihoods:Improved when Costs:Low
  0.01, # Livelihoods:NotnImproved & Costs:Low
  # Benefits = Low, ExternalRisks = Low
  0.65, # Livelihoods:Improved when Costs:High
  0.35, # Livelihoods:Not Improved when Costs:High
  0.75, # Livelihoods:Improved when Costs:Low
  0.25 # Livelihoods:NotnImproved & Costs:Low
)

# Set the dimensions of the matrix (8 combinations of Costs, Benefits, ExternalRisks, and 2 outcomes: Improved, Not Improved)
dim(cpt_Livelihoods) <- c(2, 2, 2, 2)

# Assign the correct dimnames (8 combinations of parent nodes, 2 outcomes for Livelihoods)
# [Livelihoods | Costs:Benefits:ExternalRisks]
dimnames(cpt_Livelihoods) <- list(
  "Livelihoods" = c("Improved", "Not Improved"),
  "Costs" = c("High", "Low"),
  "Benefits" = c("High", "Low"),
  "ExternalRisks" = c("High", "Low")
)

# Combine the CPTs into a list
# Fit the Bayesian Network with the CPTs using custom.fit()
bn_fitted <- custom.fit(network_structure,
                        dist = list(
                          TreesOnFarm = cpt_TreesOnFarm,
                          Timber = cpt_Timber,
                          Fruit = cpt_Fruit,
                          Firewood = cpt_Firewood,
                          Market = cpt_Market,
                          Habitat = cpt_Habitat,
                          Shade = cpt_Shade,
                          ExternalRisks = cpt_ExternalRisks,
                          Costs = cpt_Costs,
                          Benefits = cpt_Benefits,
                          Livelihoods = cpt_Livelihoods))

# Check the fitted network
bn_fitted

# Perform inference (e.g., calculate the probability of "Livelihoods" being "Improved" given "Trees on Farm")
inference_result <- cpquery(bn_fitted, event = (Livelihoods == "Improved"), evidence = (TreesOnFarm == "Yes"))
cat("Probability of improved livelihoods given trees on farm: ", inference_result, "\n")
