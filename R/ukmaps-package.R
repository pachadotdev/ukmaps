#' UK Boundaries - Ward-level Hierarchical Dataset
#'
#' @description
#' Complete UK territorial boundaries dataset at the electoral ward level, with each Ward linked to its
#' Local Authority District (LAD), County/Unitary Authority, and country. All boundaries are provided as simplified
#' MULTIPOLYGON geometries.
#'
#' @format A tibble (sf object) with 8,396 rows and 11 columns:
#' \describe{
#'   \item{ward_code}{Official ward code (e.g., E05000932)}
#'   \item{ward_name}{Ward name (e.g., Ainsdale)}
#'   \item{lad_code}{Local Authority District code (e.g., E08000014)}
#'   \item{lad_name}{Local Authority District name (e.g., Sefton)}
#'   \item{county_code}{County/Unitary Authority code (e.g., E10000017)}
#'   \item{county_name}{County/Unitary Authority name (e.g., Lancashire)}
#'   \item{country_code}{Country code (ENG, SCT, WLS, NIR)}
#'   \item{region_code}{Region code (e.g., E12000001)}
#'   \item{region_name}{Region name (e.g., North East)}
#'   \item{country}{Country name (England, Scotland, Wales, Northern Ireland)}
#'   \item{geometry}{Ward boundary geometry (MULTIPOLYGON, sf)}
#' }
#'
#' @details
#' Each row represents a single UK electoral ward, with hierarchical links to its Local Authority District,
#' County/Unitary Authority, region, and country. Only England has non-blank values for the region columns,
#'
#' @source Open Geograpy Portal (Office for National Statistics)
#'
#' @docType data
#' @name boundaries
"boundaries"

#' UK Local Authority Districts Election Results (England and Wales)
#'
#' @description
#' Local election results for England and Wales local authority districts, covering elections from 2021 to May 2025.
#' Each row represents a district-year result, including top and next party, vote shares, and notes.
#'
#' @format A tibble with 346 rows and 9 columns:
#' \describe{
#'   \item{election_year}{Year of the election}
#'   \item{lad_name}{Local authority district name}
#'   \item{county_name}{County or unitary authority name}
#'   \item{country_name}{Country (England or Wales)}
#'   \item{top_party}{Party with the highest vote share}
#'   \item{top_party_pct}{Vote percentage for top party}
#'   \item{next_party}{Second party by vote share}
#'   \item{next_party_pct}{Vote percentage for next party}
#'   \item{notes}{Relative position details based on results (if any)}
#' }
#'
#' @details
#' Data compiled from UK local authority election results. Covers all districts in England and Wales for the years
#' 2021–2025. Vote shares are percentages. Notes include relative position details based on results.
#'
#' @source Dr. Catherine Moez (https://github.com/catmoez/UK-Local-Authority-districts/tree/main)
#'
#' @docType data
#' @name election_results
"election_results"
