get_acs5_vars <- function(vintage = "2015") {
  # Get all variable names for ACS 5-year estimates
  acs5_vars <- listCensusMetadata(
    name = 'acs/acs5',
    type = 'variables',
    vintage = vintage,
  )
  return(acs5_vars)
}