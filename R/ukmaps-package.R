#' UK Administrative Boundaries
#' 
#' @description Administrative boundaries for the United Kingdom including
#' Local Authority Districts (LAD) for England, Scotland, and Wales, and
#' Local Government Districts (LGD) for Northern Ireland.
#' 
#' @format A data frame with administrative areas and 6 variables:
#' \describe{
#'   \item{area_code}{Official government area code (e.g., E06000001, S12000005)}
#'   \item{area_name}{Official area name}
#'   \item{region}{Region identifier}
#'   \item{boundary_type}{Type of boundary (administrative)}
#'   \item{country}{Country identifier (england, scotland, wales, northern_ireland)}
#'   \item{geometry}{Simplified boundary geometries (sf)}
#' }
#' @source Office for National Statistics, National Records of Scotland, NISRA
"administrative"

#' UK Electoral Boundaries
#' 
#' @description Electoral boundaries for the United Kingdom including
#' European Electoral Regions (EER), Westminster Parliamentary Constituencies (WPC),
#' Electoral Wards, and devolved parliament/assembly constituencies.
#' 
#' @format A data frame with electoral areas and 6 variables:
#' \describe{
#'   \item{area_code}{Official electoral area code}
#'   \item{area_name}{Official area name}
#'   \item{region}{Region identifier}
#'   \item{boundary_type}{Type of boundary (electoral)}
#'   \item{country}{Country identifier (england, scotland, wales, northern_ireland)}
#'   \item{geometry}{Simplified boundary geometries (sf)}
#' }
#' @source Office for National Statistics, Electoral Commission
"electoral"
