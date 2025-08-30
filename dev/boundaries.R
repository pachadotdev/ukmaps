## Simple Ward + LAD + County/Unitary + Region + Country Flat Dataset
## Each row = one Ward
## Columns: ward code/name, LAD code/name, county/unitary code/name, region code/name, country code/name, geometry

library(sf)
library(dplyr)
library(stringr)
library(readr)
library(usethis)

# Set CRS
crs <- 27700

boundaries <- lad_sf %>%

ward_file <- "dev/Wards_May_2024_Boundaries_UK_BSC_157007892265746986.geojson"
if (!file.exists(ward_file)) stop("Ward boundaries file not found: ", ward_file)

ward_sf <- st_read(ward_file, quiet = TRUE) %>%
  st_transform(crs) %>%
  st_make_valid() %>%
  select(WD24CD, geometry)

cat("Joining ward boundaries to lookup CSV for full hierarchy...\n")

lookup_file <- "dev/Ward_to_Local_Authority_District_to_CTYUA_to_RGN_to_CTRY_(May_2024)_Lookup_in_UK.csv"
if (!file.exists(lookup_file)) stop("Lookup file not found: ", lookup_file)

ward_lookup <- read_csv(lookup_file) %>%
  select(WD24CD, WD24NM, LAD24CD, LAD24NM, CTYUA24CD, CTYUA24NM, RGN24CD, RGN24NM, CTRY24CD, CTRY24NM) %>%
  distinct()

boundaries <- ward_sf %>%
  left_join(ward_lookup, by = "WD24CD") %>%
  as_tibble() %>%
  mutate(
    WD24CD = as.factor(WD24CD),
    WD24NM = as.factor(WD24NM),
    LAD24CD = as.factor(LAD24CD),
    LAD24NM = as.factor(LAD24NM),
    CTYUA24CD = as.factor(CTYUA24CD),
    CTYUA24NM = as.factor(CTYUA24NM),
    RGN24CD = as.factor(RGN24CD),
    RGN24NM = as.factor(RGN24NM),
    CTRY24CD = as.factor(CTRY24CD),
    CTRY24NM = as.factor(CTRY24NM)
  ) %>%
  select(ward_code = WD24CD, ward_name = WD24NM,
         lad_code = LAD24CD, lad_name = LAD24NM,
         county_code = CTYUA24CD, county_name = CTYUA24NM,
         region_code = RGN24CD, region_name = RGN24NM,
         country_code = CTRY24CD, country_name = CTRY24NM,
         geometry)

cat("Check for NAs in key columns:\n")
key_cols <- c("ward_code", "ward_name", "lad_code", "lad_name", "county_code", "county_name", "region_code", "region_name", "country_code", "country_name")
na_summary <- sapply(boundaries %>% st_drop_geometry(), function(col) sum(is.na(col)))
na_summary[na_summary > 0]

# Show all rows with any NA in key columns
na_rows <- boundaries %>% filter(if_any(all_of(key_cols), is.na))
na_rows
cat("Total rows with any NA in key columns:", nrow(na_rows), "\n")

na_rows %>%
    filter(is.na(lad_name))

na_rows %>%
    filter(is.na(county_name))

na_rows %>%
    distinct(country_name)

# Save dataset
use_data(boundaries, overwrite = TRUE, compress = "xz")
cat("Flat ward + LAD + county/unitary + region + country dataset saved as data/ward_flat.rda\n")
cat("Columns: ", paste(names(boundaries), collapse = ", "), "\n")
cat("Rows: ", nrow(boundaries), "\n")

boundaries
