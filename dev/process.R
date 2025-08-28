# this is similar to the chilemapas approach for UK boundaries

# administrative: Local Authority Districts (LAD) (Local Government District (LGD) in Northern Ireland)
# dev/json/administrative/gb/lad.json

# electoral: areas broken down into European Electoral Regions (EER), Westminster Parliamentary Constituencies (WPC),
# and Electoral Wards. Also contains data files for Wards and Westminster Parliamentary Constituencies collected by
# Local Authority District. Contains Scottish Parliamentary Constituencies and Scottish Parliamentary Regions for
# Scotland and Welsh Assembly Constituencies and Welsh Assembly Regions for Wales. Contains Northern Ireland District
# Electoral Areas (DEA), also collected by Local Government District. Northern Ireland Assembly Area boundaries are
# analogous with NI Westminster Parliamentary Constituencies
# dev/json/electoral/gb/wpc.json
# dev/json/electoral/gb/wards.json

library(sf)
library(dplyr)
library(purrr)
library(rmapshaper)
library(janitor)
library(stringr)

# Configure GDAL to handle large files
Sys.setenv(OGR_GEOJSON_MAX_OBJ_SIZE = "0")


# Function to classify region based on LAD code (English regions)
classify_region <- function(lad_code) {
  # Create a simple lookup for now - this should be expanded with complete mappings
  case_when(
    # London boroughs (E09)
    str_starts(lad_code, "E09") ~ "London",
    
    # For now, use a simplified approach for other English regions
    # This should be expanded with complete LAD code mappings
    str_starts(lad_code, "E") ~ "England", # Will be refined based on actual data
    str_starts(lad_code, "S") ~ "Scotland",
    str_starts(lad_code, "W") ~ "Wales", 
    str_starts(lad_code, "N") ~ "Northern Ireland",
    TRUE ~ "Other"
  )
}

# Function to classify country based on LAD code
classify_country <- function(lad_code) {
  case_when(
    str_starts(lad_code, "E") ~ "England",
    str_starts(lad_code, "S") ~ "Scotland", 
    str_starts(lad_code, "W") ~ "Wales",
    str_starts(lad_code, "N") ~ "Northern Ireland",
    TRUE ~ "Other"
  )
}

# Function to process administrative map
process_administrative <- function() {
  file <- "dev/json/administrative/gb/lad.json"
  cat("Processing administrative boundaries from:", file, "\n")
  sf_data <- st_read(file, quiet = TRUE)
  
  # Standardize columns - use actual column names from the data
  sf_data <- sf_data %>%
    rename(area_code = LAD13CD, area_name = LAD13NM) %>%
    # Add region and country columns based on LAD code classification
    mutate(
      region = classify_region(area_code),
      country = classify_country(area_code)
    ) %>%
    select(area_code, area_name, region, country, geometry)
  
  # Set CRS to British National Grid
  if (is.na(st_crs(sf_data)) || st_crs(sf_data)$input != "EPSG:27700") {
    sf_data <- st_transform(sf_data, crs = 27700)
  }
  
  # Simplify geometries and convert to sf tibble
  sf_data <- rmapshaper::ms_simplify(sf_data, keep = 0.3)
  sf_data <- sf_data %>% 
    st_as_sf() %>% 
    as_tibble() %>%
    # Convert text columns to factors
    mutate(
      area_code = as.factor(area_code),
      area_name = as.factor(area_name),
      region = as.factor(region),
      country = as.factor(country)
    )
  
  cat("Processed", nrow(sf_data), "administrative areas\n")
  return(sf_data)
}

# Function to get all LAD files for electoral boundaries
get_electoral_files_by_lad <- function() {
  # Define the directories to search
  directories <- c(
    "dev/json/electoral/eng/wpc_by_lad",
    "dev/json/electoral/eng/wards_by_lad", 
    "dev/json/electoral/sco/wpc_by_lad",
    "dev/json/electoral/sco/wards_by_lad",
    "dev/json/electoral/wal/wpc_by_lad", 
    "dev/json/electoral/wal/wards_by_lad",
    "dev/json/electoral/ni/wards_by_lgd",
    "dev/json/electoral/ni/deas_by_lgd"
  )
  
  all_files <- list()
  
  for (dir in directories) {
    if (dir.exists(dir)) {
      # Get all JSON files (not TopJSON)
      files <- list.files(dir, pattern = "^[^topo_].*\\.json$", full.names = TRUE)
      files <- files[!grepl("^topo_", basename(files))]
      
      if (length(files) > 0) {
        # Extract boundary type and region from directory
        boundary_type <- if (grepl("wpc", dir)) "wpc" else if (grepl("dea", dir)) "dea" else "ward"
        region <- str_extract(dir, "(eng|sco|wal|ni)")
        
        all_files[[paste(region, boundary_type, sep = "_")]] <- list(
          files = files,
          region = region,
          boundary_type = boundary_type
        )
      }
    }
  }
  
  return(all_files)
}

# Function to process electoral data using LAD-organized files
process_electoral_hierarchical <- function() {
  cat("Processing electoral boundaries using LAD-organized files\n")
  
  # First, get the administrative data to have LAD information
  admin_data <- st_read("dev/json/administrative/gb/lad.json", quiet = TRUE)
  lad_lookup <- admin_data %>%
    select(LAD13CD, LAD13NM) %>%
    st_drop_geometry() %>%
    mutate(region = classify_region(LAD13CD))
  
  # Get all electoral files organized by LAD
  electoral_files <- get_electoral_files_by_lad()
  
  all_electoral_data <- list()
  
  for (file_group_name in names(electoral_files)) {
    file_group <- electoral_files[[file_group_name]]
    region <- file_group$region
    boundary_type <- file_group$boundary_type
    
    cat("Processing", boundary_type, "boundaries for region:", region, "\n")
    
    group_data <- map_dfr(file_group$files, function(file_path) {
      # Extract LAD code from filename
      lad_code <- str_extract(basename(file_path), "^[^.]+")
      
      # Skip if we can't find this LAD in our lookup
      if (!lad_code %in% lad_lookup$LAD13CD) {
        return(NULL)
      }
      
      # Get LAD information
      lad_info <- lad_lookup[lad_lookup$LAD13CD == lad_code, ]
      
      tryCatch({
        # Read the electoral data
        electoral_data <- st_read(file_path, quiet = TRUE)
        
        if (nrow(electoral_data) == 0) {
          return(NULL)
        }
        
        # Standardize column names based on boundary type
        if (boundary_type == "wpc") {
          electoral_data <- electoral_data %>%
            rename(area_code = PCON13CD, area_name = PCON13NM)
        } else if (boundary_type == "dea") {
          # Northern Ireland District Electoral Areas
          electoral_data <- electoral_data %>%
            rename(area_code = DEA13CD, area_name = DEA13NM)
        } else { # ward
          electoral_data <- electoral_data %>%
            rename(area_code = WD13CD, area_name = WD13NM)
        }
        
        # Add hierarchical information
        electoral_data <- electoral_data %>%
          mutate(
            lad_code = lad_code,
            lad_name = lad_info$LAD13NM,
            region = lad_info$region,
            boundary_type = boundary_type,
            country = classify_country(lad_code)
          ) %>%
          select(area_code, area_name, lad_code, lad_name, region, boundary_type, country, geometry)
        
        return(electoral_data)
        
      }, error = function(e) {
        cat("Error processing file", file_path, ":", e$message, "\n")
        return(NULL)
      })
    })
    
    if (!is.null(group_data) && nrow(group_data) > 0) {
      all_electoral_data[[file_group_name]] <- group_data
      cat("  Processed", nrow(group_data), boundary_type, "areas\n")
    }
  }
  
  # Combine all electoral data
  if (length(all_electoral_data) > 0) {
    combined_electoral <- bind_rows(all_electoral_data)
    
    # Set CRS to British National Grid
    if (is.na(st_crs(combined_electoral)) || st_crs(combined_electoral)$input != "EPSG:27700") {
      combined_electoral <- st_transform(combined_electoral, crs = 27700)
    }
    
    # Simplify geometries
    combined_electoral <- rmapshaper::ms_simplify(combined_electoral, keep = 0.3)
    combined_electoral <- combined_electoral %>% 
      st_as_sf() %>% 
      as_tibble() %>%
      # Convert text columns to factors
      mutate(
        area_code = as.factor(area_code),
        area_name = as.factor(area_name),
        lad_code = as.factor(lad_code),
        lad_name = as.factor(lad_name),
        region = as.factor(region),
        boundary_type = as.factor(boundary_type),
        country = as.factor(country)
      )
    
    # Split into WPC and ward datasets
    # wpc_data <- combined_electoral %>% filter(boundary_type %in% c("wpc"))
    # ward_data <- combined_electoral %>% filter(boundary_type %in% c("ward", "dea"))
    
    cat("Total processed:\n")
    # cat("  WPC areas:", nrow(wpc_data), "\n")
    # cat("  Ward/DEA areas:", nrow(ward_data), "\n")
    cat("  Combined:", nrow(combined_electoral), "areas\n")
    
    # return(list(
    #   wpc = wpc_data,
    #   ward = ward_data,
    #   combined = combined_electoral
    # ))
    return(combined_electoral)
  } else {
    cat("No electoral data processed\n")
    return(NULL)
  }
}

# Main processing function using hierarchical approach
process_uk_boundaries <- function() {
  cat("=== UK Boundaries Processing - Hierarchical Approach ===\n")
  cat("Processing electoral boundaries using LAD-organized files from:\n")
  cat("  - dev/json/electoral/*/wpc_by_lad/\n")
  cat("  - dev/json/electoral/*/wards_by_lad/\n")
  cat("  - dev/json/electoral/*/deas_by_lgd/\n\n")
  
  # Ensure data directory exists
  if (!dir.exists("data")) dir.create("data")
  
  # Check existing files
  existing_files <- list.files("data", pattern = "\\.rda$")
  cat("Existing datasets:", ifelse(length(existing_files) > 0, paste(existing_files, collapse = ", "), "none"), "\n\n")

  # Process Administrative boundaries
  admin_file <- "administrative.rda" 
  cat("=== Processing Administrative Boundaries ===\n")
  administrative <- process_administrative()
  save(administrative, file = file.path("data", admin_file), compress = "xz")
  cat("Saved", admin_file, "with", nrow(administrative), "areas\n\n")

  # Process Electoral boundaries using hierarchical approach
  electoral_file <- "electoral.rda"
  cat("=== Processing Electoral Boundaries (Hierarchical) ===\n") 
  electoral <- process_electoral_hierarchical()
  
  if (!is.null(electoral)) {
    save(electoral, file = file.path("data", electoral_file), compress = "xz")
    cat("Saved", electoral_file, "with:\n")
    # cat("  - WPC:", nrow(electoral$wpc), "areas\n")
    # cat("  - Ward/DEA:", nrow(electoral$ward), "areas\n") 
    # cat("  - Combined:", nrow(electoral$combined), "total areas\n\n")
    cat("  - Combined:", nrow(electoral), "total areas\n\n")
  } else {
    cat("No electoral data processed!\n\n")
  }

  # Summary
  cat("=== Processing Complete ===\n")
  final_files <- list.files("data", pattern = "\\.rda$")
  cat("Final datasets created:\n")
  for (file in final_files) {
    size <- file.size(file.path("data", file))
    cat("  ", file, " (", round(size/1024/1024, 1), " MB)\n")
  }
  
  cat("\nDataset structure with hierarchical relationships:\n")
  cat("  administrative: area_code, area_name, region, country, geometry\n")
  # cat("  electoral$wpc: area_code, area_name, lad_code, lad_name, region, boundary_type, country, geometry\n")
  # cat("  electoral$ward: area_code, area_name, lad_code, lad_name, region, boundary_type, country, geometry\n")
  # cat("  electoral$combined: unified dataset preserving LAD hierarchical relationships\n")
  cat("  \n")
  cat("  Country column: England, Scotland, Wales, Northern Ireland\n")
  cat("  Region column: London, North East, North West, Yorkshire and the Humber, etc.\n")
}

# Run the processing
process_uk_boundaries()
