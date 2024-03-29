library(DBI)
get_b20005_female_other_ruca_aggregate_earnings <- function(state) {
  census_app_db <- dbConnect(RSQLite::SQLite(), "census_app_db.sqlite")
  rs <- dbGetQuery(
    census_app_db, 
    "SELECT 
      ruca.DESCRIPTION,
      SUM(b20005.B20005_076E) AS B20005_076E, 
      SUM(b20005.B20005_077E) AS B20005_077E,
      SUM(b20005.B20005_078E) AS B20005_078E,
      SUM(b20005.B20005_079E) AS B20005_079E,
      SUM(b20005.B20005_080E) AS B20005_080E,
      SUM(b20005.B20005_081E) AS B20005_081E,
      SUM(b20005.B20005_082E) AS B20005_082E,
      SUM(b20005.B20005_083E) AS B20005_083E,
      SUM(b20005.B20005_084E) AS B20005_084E,
      SUM(b20005.B20005_085E) AS B20005_085E,
      SUM(b20005.B20005_086E) AS B20005_086E,
      SUM(b20005.B20005_087E) AS B20005_087E,
      SUM(b20005.B20005_088E) AS B20005_088E,
      SUM(b20005.B20005_089E) AS B20005_089E,
      SUM(b20005.B20005_090E) AS B20005_090E,
      SUM(b20005.B20005_091E) AS B20005_091E,
      SUM(b20005.B20005_092E) AS B20005_092E,
      SUM(b20005.B20005_093E) AS B20005_093E,
      SUM(b20005.B20005_094E) AS B20005_094E,
      SUM(b20005.B20005_095E) AS B20005_095E
    FROM 'b20005' 
    INNER JOIN ruca 
    ON b20005.FIPS = ruca.TRACTFIPS
    WHERE 
      b20005.STATE = $state
    GROUP BY ruca.DESCRIPTION",
    params = list(state=state))
  
  dbDisconnect(census_app_db)
  return(rs)
}