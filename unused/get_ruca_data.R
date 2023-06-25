# Get RUCA codes for Minnesota
ruca <- read.csv("minnesota_ruca_codes.csv")

get_ruca_data <- function(acs5_data, all_vars, group_vars) {
  # Create a column for FIPS code to merge with RUCA codes
  acs5_data$FIPS <- substr(acs5_data$GEO_ID, 10,20)
  
  # Add RUCA table columns to ACS 5-year data
  acs5_data <- merge(acs5_data, ruca, by.x = 'FIPS', by.y='State.County.Tract.FIPS.Code')
  
  # Assign RUCA labels to match case study
  ruca_levels <- c(
    "Urban", "Urban", "Urban", 
    "Large Town", "Large Town", "Large Town", 
    "Small Town", "Small Town", "Small Town", 
    "Rural")
  
  acs5_data$RUCA_LEVEL <- sapply(acs5_data$Primary.RUCA.Code.2010, FUN=function(x) { return(ruca_levels[x]) })
  
  # Aggregate worker counts by RUCA Level
  agg_by_ruca <- aggregate(acs5_data[,group_vars$name], by=list(acs5_data$RUCA_LEVEL), FUN=sum)
  
  # Tranpose the dataframe
  col_names <- colnames(agg_by_ruca)
  row_names <- agg_by_ruca$Group.1
  agg_by_ruca <- t(agg_by_ruca[,-1])
  agg_by_ruca <- agg_by_ruca[order(row.names(agg_by_ruca)),]
  
  # Replace row names with long-form descriptions
  rownames(agg_by_ruca) <- sapply(sort(col_names[-1]), FUN=function(x) { return(group_vars$label[match(x, group_vars$name)]) })
  colnames(agg_by_ruca) <- row_names
  return(agg_by_ruca)
}
