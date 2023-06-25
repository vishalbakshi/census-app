library(DBI)
get_b20005_ruca_aggregate_earnings <- function(state, sex, work_status) {
  census_app_db <- dbConnect(RSQLite::SQLite(), "census_app_db.sqlite")
  
  # Prepare wildcard for query parameter `label_wildcard`
  if (sex == 'M') {
    if (work_status == 'FT') { label_wildcard <- "%!!Male!!Worked%" }
    if (work_status == 'OTHER') { label_wildcard <- "%!!Male!!Other%" }
  }
  
  if (sex == 'F') {
    if (work_status == 'FT') { label_wildcard <- "%!!Female!!Worked%" }
    if (work_status == 'OTHER') { label_wildcard <- "%!!Female!!Other%" }
  }
  
  
  # MOE -----------------------------------------------------------------------
  # Get b20005 variable names for Full Time Female worker margins of error
  vars <- dbGetQuery(
    census_app_db, 
    "SELECT name FROM b20005_vars 
    WHERE label LIKE $label_wildcard 
    AND name LIKE '%M'",
    params=list(label_wildcard=label_wildcard))
  
  # Construct query string to square root of the sum of margins of error squared
  # grouped by ruca level
  
    query_string <- paste0(
      "SQRT(SUM(POWER(b20005.", vars$name, ", 2))) AS ", vars$name, collapse=",")
  
  query_string <- paste(
    "SELECT ruca.DESCRIPTION,",
    query_string,
    "FROM 'b20005' 
    INNER JOIN ruca 
    ON b20005.state || b20005.county || b20005.tract = ruca.TRACTFIPS
    WHERE 
    b20005.state = $state
    GROUP BY ruca.DESCRIPTION"
  )
  
  # Get query results from database using a parametric query
  moe_rs <- dbGetQuery(
    census_app_db, 
    query_string,
    params = list(state=state))
  
  # ESTIMATE ------------------------------------------------------------------
  # Get b20005 variable names for Full Time Female worker estimates
  vars <- dbGetQuery(
    census_app_db, 
    "SELECT name FROM b20005_vars 
    WHERE label LIKE $label_wildcard
    AND name LIKE '%E'",
    params=list(label_wildcard=label_wildcard))
  
  # Construct a query to sum estimates grouped by ruca level
  query_string <- paste0(
    "SUM(b20005.",vars$name, ") AS ", vars$name, collapse=",")
  
  query_string <- paste(
    "SELECT ruca.DESCRIPTION,",
    query_string,
    "FROM 'b20005' 
    INNER JOIN ruca 
    ON b20005.state || b20005.county || b20005.tract = ruca.TRACTFIPS
    WHERE 
    b20005.state = $state
    GROUP BY ruca.DESCRIPTION",
    sep=" "
  )
  
  estimate_rs <- dbGetQuery(
    census_app_db, 
    query_string,
    params = list(state=state))
  
  dbDisconnect(census_app_db)
  return(list("estimate" = estimate_rs, "moe" = moe_rs))
}