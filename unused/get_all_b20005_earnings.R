get_all_b20005_earnings <- function(){
  census_app_db <- dbConnect(RSQLite::SQLite(), "census_app_db.sqlite")
  
  # Get variable names (B20005_001E, B20005_001M, ...)
  vars <- dbGetQuery(
    census_app_db, 
    "SELECT name 
    FROM b20005_vars")
  
  # Prepend "b20005." to each variable name and collapse into a single string
  query_string <- paste0("b20005.", vars$name, collapse=",")
  
  # Construct query string to get ruca and b20005 table values
  query_string <- paste(
    "SELECT ruca.DESCRIPTION,", 
    "b20005.state || b20005.county || b20005.tract AS TRACTFIPS,",
    query_string,
    "FROM b20005 INNER JOIN ruca",
    "ON b20005.state || b20005.county || b20005.tract = ruca.TRACTFIPS"
  )
  
  rs <- dbGetQuery(
    census_app_db,
    query_string)
  dbDisconnect(census_app_db)
  return(rs)
}