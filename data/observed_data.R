# For 13 refs
#' @akter_agroforestry_2022
#' @haglund_dry_2011
#' @craswell_agroforestry_1997
#' @verchot_climate_2007
#' @bogale_sustainability_2023
#' @amare_agroforestry_2019
#' @quandt_agroforestry_2021
#' @ngango_does_2024
#' @bishaw_farmers_2013
#' @do_adapting_2024
#' @hughes_assessing_2020
#' @johansson_mapping_2013
#' @awazi_agroforestry_2020

observed_data <- data.frame(
  TreeDiversity = c(
    "High",  # @akter_agroforestry_2022: Highlights rich species diversity in agroforestry systems.
    "Low",   # @haglund_dry_2011: Focuses on natural regeneration with less emphasis on diversity.
    "Low",   # @craswell_agroforestry_1997: Discusses soil conservation systems with limited diversity.
    "High",  # @verchot_climate_2007: Emphasizes biodiversity contributions in agroforestry.
    "High",  # @bogale_sustainability_2023: Highlights high diversity in agroforestry systems for resilience.
    "Low",   # @amare_agroforestry_2019: Discusses indigenous tree retention with limited diversity.
    "Low",   # @quandt_agroforestry_2021: Moderate diversity in food-security-focused agroforestry.
    "High",  # @ngango_does_2024: Agroforestry systems with diverse species contributing to food security.
    "Low",   # @bishaw_farmers_2013: Shows moderate diversity, leaning towards lower species variation.
    "High",  # @do_adapting_2024: Rich fruit-tree-based agroforestry systems in Vietnam.
    "Low",   # @hughes_assessing_2020: Reports moderate diversity in Kenyan agroforestry systems.
    "High",  # @johansson_mapping_2013: Inter-village variation includes diversity impacts.
    "High"   # @awazi_agroforestry_2020: Explores conflict mitigation with diverse agroforestry systems.
  ),
  Timber = c("Yes", "Yes", "No", "Yes", "Yes", "Yes", "No", "Yes", "Yes", "Yes", "Yes", "No", "Yes"),# "No" = not reported
  Firewood = c("Yes", "No", "Yes", "Yes", "No", "Yes", "Yes", "No", "Yes", "Yes", "Yes", "Yes", "Yes"),# "No" = not reported
  Fruit = c("Yes", "No", "No", "Yes", "No", "Yes", "No", "Yes", NA, "Yes", NA, "No", "Yes"),
  Market = c("High", NA, "High", "Low", "High", "High", "Low", "High", "High", "Low", "High", "High", "High"),
  Shade = c("Yes", NA, "Yes", "Yes", "Yes", "Yes", "No", "Yes", NA, "Yes", "Yes", "Yes", "Yes"),
  Habitat = c("Yes", "Yes", "No", "Yes", "No", "Yes", "Yes", "Yes", "Yes", "No", "Yes", "Yes", "Yes"), # "No" = not reported
  ExternalRisks = c("High", "Low", "High", "Low", "High", "High", "Low", "Low", "High", "High", "Low", "High", "Low"),
  Costs = c("High", "Low", "High", "High", NA, "Low", "High", "Low", "High", "Low", "High", "High", "High"),
  Benefits = c("High", "Low", "High", "High", "High", "High", "Low", "High", "Low", "High", "Low", "High", "Low"),
  Livelihoods = c("Improved", "Improved", "Not Improved", "Improved", "Improved", "Not Improved", "Improved", "Not Improved", "Improved", "Not Improved", "Improved", "Improved", "Improved")
)
