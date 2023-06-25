calculate_statistical_significance <- function(estimate_1, estimate_2, critical_score){
  # estimate_# is a data.frame with 'label', 'se' and 'moe' columns
  root_sum_se_squared <- sqrt(sum(estimate_1[,"se"]^2 + estimate_2[,"se"]^2))
  score <- abs((estimate_1[,"estimate"] - estimate_2[,"estimate"])/root_sum_se_squared)
  
  if (score <= critical_score) { significance <- FALSE}
  if (score > critical_score) { significance <- TRUE}
  return(significance)
}