source('get_b20005_ruca_aggregate_earnings.R', local=TRUE)

query_router <- function(sex, work_status, state, agg_by_ruca) {
  if (!(work_status %in% c('FT', 'OTHER'))) { return(NULL) }
  if (!(sex %in% c('M', 'F'))) { return(NULL) }
  
  

  if (agg_by_ruca) { 
    return(get_b20005_ruca_aggregate_earnings(state, label_wildcard))
  } else {
    return(get_b20005_earnings(state, label_wildcard))
  }
  
}