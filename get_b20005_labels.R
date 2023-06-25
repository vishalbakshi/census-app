library(DBI)
get_b20005_labels <- function() {
  census_app_db <- dbConnect(RSQLite::SQLite(), "census_app_db.sqlite")
  rs <- dbGetQuery(
    census_app_db, 
    "SELECT 
      name, label
    FROM 'b20005_vars' 
    WHERE 
      label LIKE '%$%'
    ORDER BY name"
    )
  dbDisconnect(census_app_db)
  return(rs)
}

get_b20005_ALL_labels <- function() {
  census_app_db <- dbConnect(RSQLite::SQLite(), "census_app_db.sqlite")
  rs <- dbGetQuery(
    census_app_db, 
    "SELECT 
      name, label
    FROM 'b20005_vars' 
    ORDER BY name"
  )
  dbDisconnect(census_app_db)
  return(rs)
}