get_b20005_tract_earnings <- function(state='27', sex='M', work_status='FT', get_all=FALSE) {
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
  
  # If get_all flag is true, set wildcards accordingly
  if (get_all) {
    label_wildcard <- "%%"
    state <- '%%'
  }
  
  # Get b20005 variable names (estimates and moe)
  vars <- dbGetQuery(
    census_app_db, 
    "SELECT name FROM b20005_vars 
    WHERE label LIKE $label_wildcard",
    params=list(label_wildcard=label_wildcard)
    )
  
  # Construct query to get tract-level earnings data
  query_string <- paste(
    "SELECT ruca.DESCRIPTION,
    b20005.state || b20005.county || b20005.tract AS TRACTFIPS,",
    paste0(vars$name, collapse=","),
    "FROM b20005 
    LEFT JOIN ruca 
    ON b20005.state || b20005.county || b20005.tract = ruca.TRACTFIPS
    WHERE 
    b20005.state LIKE $state")
  
  # Get tract-level earnings data
  rs <- dbGetQuery(
    census_app_db, 
    query_string,
    params = list(state=state)
    )
  
  dbDisconnect(census_app_db)
  return(rs)
}