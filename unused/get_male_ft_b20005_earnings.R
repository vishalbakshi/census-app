get_male_ft_b20005_earnings <- function(state){
  census_app_db <- dbConnect(RSQLite::SQLite(), "census_app_db.sqlite")
  rs <- dbGetQuery(
    census_app_db,
    "SELECT 
      ruca.DESCRIPTION,
      b20005.FIPS,
      b20005.B20005_003E,
      b20005.B20005_004E,
      b20005.B20005_005E,
      b20005.B20005_006E,
      b20005.B20005_007E,
      b20005.B20005_008E,
      b20005.B20005_009E,
      b20005.B20005_010E,
      b20005.B20005_011E,
      b20005.B20005_012E,
      b20005.B20005_013E,
      b20005.B20005_014E,
      b20005.B20005_015E,
      b20005.B20005_016E,
      b20005.B20005_017E,
      b20005.B20005_018E,
      b20005.B20005_019E,
      b20005.B20005_020E,
      b20005.B20005_021E,
      b20005.B20005_022E,
      b20005.B20005_023E,
      b20005.B20005_024E,
      b20005.B20005_025E
    FROM b20005
    INNER JOIN ruca 
      ON b20005.FIPS = ruca.TRACTFIPS
    WHERE b20005.STATE = $state",
    param=list(state=state))
  dbDisconnect(census_app_db)
  return(rs)
}