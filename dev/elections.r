# @catmoez:  For local authority lists and election results (currently covering England and Wales local elections from
# 2021 to May 2025), see my Github folder UK Local Authority Districts

library(readr)
library(dplyr)
library(tidyr)

election_results <- read_csv("dev/uk_local_auths_list_20212025.csv") %>%
    janitor::clean_names() %>%
    drop_na(district) %>%
    rename(election_year = elec_year)

lvls <- sort(unique(c(election_results$top_party, election_results$next_party)))

election_results <- election_results %>%
    select(election_year, lad_name = district, county_name = county, country_name = area,
           top_party, top_party_pct, next_party, next_party_pct, notes)

election_results <- election_results %>%
    mutate(
        lad_name = case_when(
            lad_name == "Stratford-upon-Avon" ~ "Stratford-on-Avon",
            lad_name == "Herefordshire" ~ "Herefordshire, County of",
            TRUE ~ lad_name
        )
    )

# https://en.wikipedia.org/wiki/Hull_City_Council_elections

election_results_2 <- tibble::tibble(
    election_year = 2024:2021,
    lad_name = rep("Kingston upon Hull, City of", 4),
    county_name = lad_name,
    country_name = "England",
    top_party = c(rep("Liberal Democrats", 3), "Labour"),
    top_party_pct = c(31 / (31+26), 32 / (32+25), 29 / (29+27), 30 / (26+30 + 1)),
    next_party = c(rep("Labour", 3), "Liberal Democrat"),
    next_party_pct = c(26 / (31+26), 25 / (32+25), 27 / (29+27), 26 / (26+30 + 1)),
    notes = NA
)

election_results <- bind_rows(election_results, election_results_2)
election_results$top_party <- factor(election_results$top_party, levels = lvls)
election_results$next_party <- factor(election_results$next_party, levels = lvls)

election_results <- election_results %>%
    mutate_if(is.character, as.factor) %>%
    mutate(
        notes = as.character(notes),
        election_year = as.integer(election_year)
    )

usethis::use_data(election_results, overwrite = TRUE, compress = "xz")

# test

load_all()

library(ggplot2)
library(sf)

boundaries %>%
 filter(lad_name == "Kingston upon Hull, City of") %>%
 select(lad_name, county_name)

l    <- boundaries %>%
    filter(country_name %in% c("England", "Wales")) %>%
    group_by(lad_code, lad_name) %>%
    summarise(geometry = st_union(geometry), .groups = "drop")

d <- l %>%
    left_join(election_results) %>%
    group_by(lad_name) %>%
    filter(election_year == max(election_year, na.rm = TRUE)) %>%
    ungroup() %>%
    mutate(top_party2 = sprintf("%s (%s)", top_party, election_year))


# Expand LADs to all years, so every LAD has a row for every year
all_years <- sort(unique(election_results$election_year))
all_lads <- l %>% select(lad_code, lad_name, geometry)
d_expanded <- tidyr::expand_grid(all_lads, election_year = all_years) %>%
    left_join(election_results, by = c("lad_name", "election_year"))

d <- d_expanded

d %>%
    filter(is.na(top_party)) %>%
    select(lad_name, election_year, top_party)

d %>%
    filter(is.na(election_year)) %>%
    distinct(lad_name)
    
ggplot(d) + 
  geom_sf(aes(fill = top_party, geometry = geometry), color = "white") +
  scale_fill_discrete(name = "Top Party") +
  labs(title = "UK Local Authority Districts - Top Party by Year",
      subtitle = "Data: Dr. Catherine Moez") +
  theme_minimal(base_size = 13) +
  facet_wrap(~ election_year)
