source('get_all_b20005_earnings.R', local=TRUE)
source('get_male_ft_b20005_earnings.R', local=TRUE)
source('get_male_other_b20005_earnings.R', local=TRUE)
source('get_female_ft_b20005_earnings.R', local=TRUE)
source('get_female_other_b20005_earnings.R', local=TRUE)

get_b20005_earnings <- function(state, sex, work_status){
  census_app_db <- dbConnect(RSQLite::SQLite(), "census_app_db.sqlite")
  
  if ( (state == 'ALL') & (sex == 'ALL') & (work_status == 'ALL')) {
    rs <- get_all_b20005_earnings()
  }
  
  if (sex == 'M') {
    if (work_status == 'FT'){
      rs <- get_male_ft_b20005_earnings(state)
    }
    if(work_status == 'OTHER'){
      rs <- get_male_other_b20005_earnings(state)
    }
  }
  
  if (sex == 'F') {
    if (work_status == 'FT'){
      rs <- get_female_ft_b20005_earnings(state)
    }
    if(work_status == 'OTHER'){
      rs <- get_female_other_b20005_earnings(state)
    }
  }
  dbDisconnect(census_app_db)
  return(rs)
  
}