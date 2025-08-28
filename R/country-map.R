#' UK map at country level
#' @description Dissolves administrative boundaries to country level.
#' @importFrom sf st_as_sf
#' @importFrom rmapshaper ms_dissolve
#' @importFrom dplyr as_tibble
#' @return A tibble with multipolygon geometry for each country.
#' @examples
#' country()
#' @export
country <- function() {
  administrative %>%
    st_as_sf() %>%
    ms_dissolve(field = "country") %>%
    as_tibble()
}
