# https://github.com/rOpenGov/eurostat/issues/99
get_acs5_data <- function(vintage, group_name, vars, region, regionin) {
  # Get variable names from a given group
  acs5_2015 <- getCensus(
    name = 'acs/acs5',
    region = region,
    regionin = regionin,
    vintage = vintage,
    vars = vars,
    key="ae6f9efbeeec83ae928bac5cbce2e4b3961aa4e9"
  )
  return(acs5_2015)
}