#' UK map at country level
#' @description Dissolves administrative boundaries to country level.
#' @importFrom rmapshaper ms_dissolve
#' @importFrom sf st_as_sf
#' @importFrom dplyr as_tibble select arrange
#' @return A tibble with multipolygon geometry for each country.
#' @examples
#' country()
#' @export
country <- function() {
  mapa %>%
    st_as_sf() %>%
    ms_dissolve(field = "country") %>%
    as_tibble() %>%
    select(country, geometry) %>%
    arrange(country)
}
