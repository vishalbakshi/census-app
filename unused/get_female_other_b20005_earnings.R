get_female_other_b20005_earnings <- function(state){
  census_app_db <- dbConnect(RSQLite::SQLite(), "census_app_db.sqlite")
  rs <- dbGetQuery(
    census_app_db,
    "SELECT 
      ruca.DESCRIPTION,
      b20005.FIPS,
      b20005.B20005_073E,
      b20005.B20005_074E,
      b20005.B20005_075E,
      b20005.B20005_076E,
      b20005.B20005_077E,
      b20005.B20005_078E,
      b20005.B20005_079E,
      b20005.B20005_080E,
      b20005.B20005_081E,
      b20005.B20005_082E,
      b20005.B20005_083E,
      b20005.B20005_084E,
      b20005.B20005_085E,
      b20005.B20005_086E,
      b20005.B20005_087E,
      b20005.B20005_088E,
      b20005.B20005_089E,
      b20005.B20005_090E,
      b20005.B20005_091E,
      b20005.B20005_092E,
      b20005.B20005_093E,
      b20005.B20005_094E,
      b20005.B20005_095E
    FROM b20005
    INNER JOIN ruca 
      ON b20005.FIPS = ruca.TRACTFIPS
    WHERE b20005.STATE = $state",
    param=list(state=state))
  dbDisconnect(census_app_db)
  return(rs)
}