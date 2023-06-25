source('get_acs5_vars.R', local=TRUE)
source('get_acs5_data.R', local=TRUE)
source('get_ruca_data.R', local=TRUE)
source('calculate_median.R', local=TRUE)

get_median <- function(){
  # Get ACS 5-year variables
  vintage <- "2015"
  acs5_vars <- get_acs5_vars(vintage=vintage)
  group_name <- "B20005"
  B20005_vars <- acs5_vars[acs5_vars$group == group_name,]
  all_vars <- c('GEO_ID', 'NAME', B20005_vars$name)
  
  # Get ACS 5-year data
  region <- "tract:*"
  regionin <- "state:27"
  acs5_data <- get_acs5_data(vintage, group_name, all_vars, region, regionin)
  
  # Get earning category population sums by RUCA level
  agg_by_ruca <- get_ruca_data(acs5_data,all_vars,B20005_vars)
  
  # Prepare idx for each earnings category
  male_full_time_idxs <- grep(
    "Estimate!!Total!!Male!!Worked full-time, year-round in the past 12 months!!With earnings", 
    rownames(agg_by_ruca), 
    fixed=TRUE)
  
  male_other_idxs <- grep(
    "Estimate!!Total!!Male!!Other!!With earnings", 
    rownames(agg_by_ruca),  
    fixed=TRUE)
  
  female_full_time_idxs <- grep(
    "Estimate!!Total!!Female!!Worked full-time, year-round in the past 12 months!!With earnings", 
    rownames(agg_by_ruca),  
    fixed=TRUE)
  
  female_other_idxs <- grep(
    "Estimate!!Total!!Female!!Other!!With earnings", 
    rownames(agg_by_ruca),  
    fixed=TRUE)
  
  
  # Calculate the Medians
  median <- calculate_median(agg_by_ruca[male_full_time_idxs,], 1.3, "Rural")
  return(median)
}