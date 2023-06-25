get_female_ft_b20005_earnings <- function(state){
  census_app_db <- dbConnect(RSQLite::SQLite(), "census_app_db.sqlite")
  rs <- dbGetQuery(
    census_app_db,
    "SELECT 
      ruca.DESCRIPTION,
      b20005.FIPS,
      b20005.B20005_050E,
      b20005.B20005_051E,
      b20005.B20005_052E,
      b20005.B20005_053E,
      b20005.B20005_054E,
      b20005.B20005_055E,
      b20005.B20005_056E,
      b20005.B20005_057E,
      b20005.B20005_058E,
      b20005.B20005_059E,
      b20005.B20005_060E,
      b20005.B20005_061E,
      b20005.B20005_062E,
      b20005.B20005_063E,
      b20005.B20005_064E,
      b20005.B20005_065E,
      b20005.B20005_066E,
      b20005.B20005_067E,
      b20005.B20005_068E,
      b20005.B20005_069E,
      b20005.B20005_070E,
      b20005.B20005_071E,
      b20005.B20005_072E
    FROM b20005
    INNER JOIN ruca 
      ON b20005.FIPS = ruca.TRACTFIPS
    WHERE b20005.STATE = $state",
    param=list(state=state))
  dbDisconnect(census_app_db)
  return(rs)
}