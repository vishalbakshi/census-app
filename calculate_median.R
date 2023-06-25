calculate_median <- function(data, design_factor) {
  # `data` is a data.frame w/ population estimates and moe
  # `design_factor` is a numeric value
  
  ruca_levels_in_data <- colnames(data)[!grepl("_MOE", colnames(data))]
  data <- data[ruca_levels_in_data]

  # Create data.frame with min and max earning amount for each earnings level
  earnings <- data.frame(
    min_earnings = c(1, 2500, 5000, 7500, 10000, 12500, 15000, 17500, 20000, 22500, 25000, 30000, 35000, 40000, 45000, 50000, 55000, 65000, 75000, 100000),
    max_earnings = c(2500, 5000, 7500, 10000, 12500, 15000, 17500, 20000, 22500, 25000, 30000, 35000, 40000, 45000, 50000, 55000, 65000, 75000, 100000, 100000)
  )
  
  median_data_list <- lapply(ruca_levels_in_data, function(ruca_level) {
    # See page 17 of the "PUMS Accuracy of the Data (2015 - 2019)" PDF
    # https://www2.census.gov/programs-surveys/acs/tech_docs/pums/accuracy/2015_2019AccuracyPUMS.pdf
    
    # Calculate Cumulative Percentage distribution 
    cum_percent <- 100.0 * cumsum(data[ruca_level]) / sum(data[ruca_level])

    # Calculate Standard Error for a 50% proportion
    B <- colSums(data[ruca_level])
    se_50_percent <- design_factor * sqrt(87.5/(12.5*B) * 50^2)
    
    # Handle cases where population estimates are 0
    if (B == 0) {
      median_data <- data.frame("Estimate" = 0.0, "SE" = 0.0, "MOE" = 0.0)
      rownames(median_data) <- ruca_level
      return(median_data)
    }
    
    # Calculate the upper and lower bound of the 50% proportion
    p_lower <- 50 - se_50_percent
    p_upper <- 50 + se_50_percent
    
    # Determine the indexes of the cumulative percent data.frame corresponding 
    # to the upper and lower bounds of the 50% proportion estimate
    cum_percent_idx_lower <- min(which(cum_percent > p_lower))
    cum_percent_idx_upper <- min(which(cum_percent > p_upper))
    
    # The median estimation calculation is handled differently based on 
    # whether the upper and lower bound indexes are equal
    if (cum_percent_idx_lower == cum_percent_idx_upper) {
      # A1 is the minimum earnings value (e.g. 30000) of the earning range 
      # (e.g. 30000 to 34999) corresponding to the lower bound cumulative percent
      A1 <- earnings[cum_percent_idx_lower, "min_earnings"]
      
      # A2 is the minimum earnings value of the earning range above the 
      # earning range corresponding to the upper bound cumulative percent
      A2 <- earnings[cum_percent_idx_lower + 1, "min_earnings"]
      
      # C1 is the cumulative percentage of earnings one row below the 
      # lower bound cumulative percent
      C1 <- cum_percent[cum_percent_idx_lower - 1, ]
      
      # C2 is the cumulative percentage of the earnings below the 
      # lower bound cumulative percent
      C2 <- cum_percent[cum_percent_idx_lower, ]
      
      # the lower bound of the median 
      lower_bound <- (p_lower - C1) / (C2 - C1) * (A2 - A1) + A1
      
      # the upper bound of the median
      upper_bound <- (p_upper - C1) / (C2 - C1) * (A2 - A1) + A1
      
    } else {
      # If the cumulative percent corresponding to the upper and lower bounds
      # of the 50% proportion estimates are not equal, calculate the median upper
      # and lower bound separately
      
      # A1, A2, C1 and C2 are calculated using the lower bound cumulative percent
      # to calculate the lower bound of the median estimate
      A1 <- earnings[cum_percent_idx_lower, "min_earnings"]
      A2 <- earnings[cum_percent_idx_lower + 1, "min_earnings"]
      C1 <- cum_percent[cum_percent_idx_lower - 1, ]
      C2 <- cum_percent[cum_percent_idx_lower, ]
      lower_bound <- (p_lower - C1) / (C2 - C1) * (A2 - A1) + A1
      
      # A1, A2, C1 and C2 are calculated using the upper bound cumulative percent
      # to calculate the upper bound of the median estimate
      A1 <- earnings[cum_percent_idx_upper, "min_earnings"]
      A2 <- earnings[cum_percent_idx_upper + 1, "min_earnings"]
      C1 <- cum_percent[cum_percent_idx_upper - 1,]
      C2 <- cum_percent[cum_percent_idx_upper,]
      upper_bound <- (p_upper - C1) / (C2 - C1) * (A2 - A1) + A1
    }
    
    # The median earning estimate is the average of the upper and lower bounds
    # of the median estimates calculated above in the if-else block
    median_earnings <- 0.5 * (lower_bound + upper_bound)
    
    # The median SE is half the distance between the upper and lower bounds
    # of the median estimate
    median_se <- 0.5 * (upper_bound - lower_bound)
    
    # The 90% confidence interval critical z-score is used to calculate 
    # the margin of error
    median_90_moe <- 1.645 * median_se
    
    # A data.frame will be displayed in the UI
    median_data <- data.frame(
      "Estimate" = median_earnings,
      "SE" = median_se,
      "MOE" = median_90_moe
    )
    return(median_data)
    
  })
  
  median_data <- do.call('rbind', median_data_list)
  colnames(median_data) <- c("Estimate", "Standard_Error", "Margin_of_Error")
  return(median_data)
}