get_male_other_b20005_earnings <- function(state){
  census_app_db <- dbConnect(RSQLite::SQLite(), "census_app_db.sqlite")
  rs <- dbGetQuery(
    census_app_db,
    "SELECT 
      ruca.DESCRIPTION,
      b20005.FIPS,
      b20005.B20005_026E,
      b20005.B20005_027E,
      b20005.B20005_028E,
      b20005.B20005_029E,
      b20005.B20005_030E,
      b20005.B20005_031E,
      b20005.B20005_032E,
      b20005.B20005_033E,
      b20005.B20005_034E,
      b20005.B20005_035E,
      b20005.B20005_036E,
      b20005.B20005_037E,
      b20005.B20005_038E,
      b20005.B20005_039E,
      b20005.B20005_040E,
      b20005.B20005_041E,
      b20005.B20005_042E,
      b20005.B20005_043E,
      b20005.B20005_044E,
      b20005.B20005_045E,
      b20005.B20005_046E,
      b20005.B20005_047E,
      b20005.B20005_048E
    FROM b20005
    INNER JOIN ruca 
      ON b20005.FIPS = ruca.TRACTFIPS
    WHERE b20005.STATE = $state",
    param=list(state=state))
  dbDisconnect(census_app_db)
  return(rs)
}