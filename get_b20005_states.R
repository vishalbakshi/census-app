library(DBI)
get_b20005_states <- function(){
  census_app_db <- dbConnect(RSQLite::SQLite(), "census_app_db.sqlite")
  states <- dbGetQuery(
    census_app_db, 
    "SELECT DESCRIPTION, CODE
    FROM codes 
    WHERE CATEGORY = 'state'
    AND CODE <> '00'
    ORDER BY DESCRIPTION")
  dbDisconnect(census_app_db)
  return(states)
}