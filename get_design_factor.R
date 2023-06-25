library(DBI)
get_design_factor <- function(state) {
  census_app_db <- dbConnect(RSQLite::SQLite(), "census_app_db.sqlite")
  rs <- dbGetQuery(
    census_app_db, 
    "SELECT DESIGN_FACTOR FROM design_factors
    WHERE ST = $state
    AND CHARACTERISTIC = 'Person Earnings/Income'",
    params = list(state=state))
  dbDisconnect(census_app_db)
  rs <- as.numeric(rs[1, "DESIGN_FACTOR"])
  return(rs)
}