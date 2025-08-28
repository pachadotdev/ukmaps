
<!-- README.md is generated from README.Rmd. Please edit that file -->

# ukmaps

<!-- badges: start -->

[![BuyMeACoffee](https://raw.githubusercontent.com/pachadotdev/buymeacoffee-badges/main/bmc-yellow.svg)](https://www.buymeacoffee.com/pacha)
<!-- badges: end -->

Ukmaps provides simplified maps of the United Kingdom administrative and
electoral boundaries. Includes maps for England, Scotland, Wales, and
Northern Ireland.

This is a very early version of the package. More features and
boundaries will be added soon.

## Installation

You can install the development version of ukmaps like so:

``` r
remotes::install_github("pachadotdev/ukmaps")
```

## Example

``` r
library(ukmaps)
library(dplyr)
library(ggplot2)

london_areas <- c(
  "City of London", "Barking and Dagenham", "Barnet", "Bexley", "Brent", "Bromley",
  "Camden", "Croydon", "Ealing", "Enfield", "Greenwich", "Hackney", "Hammersmith and Fulham",
  "Haringey", "Harrow", "Havering", "Hillingdon", "Hounslow", "Islington",
  "Kensington and Chelsea", "Kingston upon Thames", "Lambeth", "Lewisham", "Merton",
  "Newham", "Redbridge", "Richmond upon Thames", "Southwark", "Sutton",
  "Tower Hamlets", "Waltham Forest", "Wandsworth", "Westminster"
)

d <- administrative %>%
  filter(country == "England") %>%
  mutate(is_london = if_else(area_name %in% london_areas, "Yes", "No"))

pal <- c("#165976", "#d04e66")

ggplot(d) + 
  geom_sf(aes(fill = is_london, geometry = geometry), color = "white") +
  scale_fill_manual(values = pal, name = "Is this an administrative area of London?") +
  labs(title = "Map of England with Administrative Boundaries") +
  theme_minimal(base_size = 13)
```

<img src="man/figures/README-example-1.png" width="100%" />
