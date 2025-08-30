#' UK map at Westminster Parliamentary Constituency (WPC) level
#' @description Merges boundaries to WPC level from the Ward-level boundaries dataset.
#' @importFrom rlang sym
#' @importFrom dplyr group_by summarise
#' @importFrom sf st_union
#' @return A tibble with multipolygon geometry for each LAD/LGD.
#' @examples
#' wpcs()
#' @export
wpcs <- function() {
  ukmaps::boundaries %>%
    group_by(!!sym("wpc_code"), !!sym("wpc_name")) %>%
    summarise(geometry = st_union(!!sym("geometry")), .groups = "drop")
}

#' UK map at Local Authority Districts (LAD) (Local Government District (LGD) in Northern Ireland) level
#' @description Merges boundaries to LAD/LGD level from the Ward-level boundaries dataset.
#' @return A tibble with multipolygon geometry for each LAD/LGD.
#' @examples
#' lads()
#' @export
lads <- function() {
  ukmaps::boundaries %>%
    group_by(!!sym("lad_code"), !!sym("lad_name")) %>%
    summarise(geometry = st_union(!!sym("geometry")), .groups = "drop")
}

#' UK map at County/Unitary Authority level
#' @description Merges boundaries to County/Unitary Authority level from the unified dataset.
#' @return A tibble with multipolygon geometry for each County/Unitary Authority.
#' @examples
#' counties()
#' @export
counties <- function() {
  ukmaps::boundaries %>%
    group_by(!!sym("county_code"), !!sym("county_name")) %>%
    summarise(geometry = st_union(!!sym("geometry")), .groups = "drop")
}

#' UK map at country level
#' @description Merges boundaries to country level from the unified dataset.
#' @examples
#' country()
#' @export
country <- function() {
  ukmaps::boundaries %>%
    group_by(!!sym("country_code"), !!sym("country_name")) %>%
    summarise(geometry = st_union(!!sym("geometry")), .groups = "drop")
}
