#' UK Administrative Boundaries
#' 
#' @description Administrative boundaries for the United Kingdom including
#' Local Authority Districts (LAD) for England, Scotland, and Wales, and
#' Local Government Districts (LGD) for Northern Ireland.
#' 
#' @format A data frame with administrative areas and 5 variables:
#' \describe{
#'   \item{area_code}{Official government area code (e.g., E06000001, S12000005)}
#'   \item{area_name}{Official area name}
#'   \item{region}{Regional classification - London for London boroughs, 
#'                 England for other English areas, Scotland, Wales, Northern Ireland}
#'   \item{country}{Country classification: England, Scotland, Wales, Northern Ireland}
#'   \item{geometry}{Simplified boundary geometries (sf)}
#' }
#' 
#' @source Office for National Statistics, National Records of Scotland, NISRA
#' 
#' @docType data
#' @name administrative
"administrative"

#' UK Electoral Boundaries
#' 
#' @description Electoral boundaries for the United Kingdom including
#' Westminster Parliamentary Constituencies (WPC), Electoral Wards, and
#' District Electoral Areas (DEA) for Northern Ireland. Each electoral boundary
#' is hierarchically linked to its parent Local Authority District.
#' 
#' @format A data frame with electoral areas and 8 variables:
#' \describe{
#'   \item{area_code}{Official electoral area code (e.g., E14000703 for WPC, E05000053 for Ward)}
#'   \item{area_name}{Official area name}
#'   \item{lad_code}{Parent Local Authority District code (hierarchical link)}
#'   \item{lad_name}{Parent Local Authority District name}
#'   \item{region}{Regional classification - London for London areas, 
#'                 England for other English areas, Scotland, Wales, Northern Ireland}
#'   \item{boundary_type}{Type of electoral boundary: wpc (Westminster Parliamentary Constituency), 
#'                        ward (Electoral Ward), or dea (District Electoral Area)}
#'   \item{country}{Country classification: England, Scotland, Wales, Northern Ireland}
#'   \item{geometry}{Simplified boundary geometries (sf)}
#' }
#' 
#' @details The electoral dataset preserves hierarchical relationships where each
#' electoral boundary (WPC or Ward) is properly linked to its parent Local Authority
#' District through the lad_code field. For example, "Finchley and Golders Green" WPC
#' and "Golders Green" Ward both belong to Barnet LAD (E09000003).
#' 
#' @source Office for National Statistics, Electoral Commission
#' 
#' @docType data
#' @name electoral
"electoral"
