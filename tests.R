library(censusapi)
library(shiny)
library(DBI)
library(ggplot2)

source('get_design_factor.R', local=TRUE)
source('get_b20005_states.R', local=TRUE)
source('get_b20005_ruca_aggregate_earnings.R', local=TRUE)
source('get_b20005_tract_earnings.R', local=TRUE)
source('format_query_result.R', local=TRUE)
source("calculate_median.R", local=TRUE)
source('make_plot.R', local=TRUE)
#------------------------------------------------------------------------------
# Get input choices for state dropdown
state_df <- get_b20005_states()
state_choices <- state_df[["CODE"]]
names(state_choices) <- state_df[["DESCRIPTION"]]
sex_choices <- c("Female" = "F", "Male" = "M")

work_status_choices <- c(
  "Full Time Employed" = "FT",
  "Other Employed" = "OTHER")

test_get_b20005_ruca_aggregate_earnings <- function() {
  for (state in state_choices) {
    for (sex in sex_choices) {
      for (work_status in work_status_choices) {
        output <- tryCatch(
          {
            get_b20005_ruca_aggregate_earnings(state, sex, work_status)
          },
          error=function(cond) {
            message(cond)
          },
          warning=function(cond) {
            message(cond)
          },
          finally=function(cond){
            print("finally")
          }
        )
      }
    }
  }
}


test_format_earnings <- function() {
  for (state in state_choices) {
    for (sex in sex_choices) {
      for (work_status in work_status_choices) {
        output <- tryCatch(
          {
            format_earnings(get_b20005_ruca_aggregate_earnings(state, sex, work_status))
          },
          error=function(cond) {
            message(cond)
          },
          warning=function(cond) {
            message(cond)
          },
          finally=function(cond){
            print("finally")
          }
        )
      }
    }
  }
}

test_calculate_median <- function() {
  error_results <- c()
  warning_results <- c()
  
  for (state in state_choices) {
    for (sex in sex_choices) {
      for (work_status in work_status_choices) {
        output <- tryCatch(
          {
            calculate_median(
              format_earnings(
                get_b20005_ruca_aggregate_earnings(state, sex, work_status)),
              get_design_factor(state))
          },
          error=function(cond) {
            print(paste("Error for:", state, sex, work_status))
            result <- c(state, sex, work_status, cond)
            error_results <- c(error_results, result)
            if (state == "11") { print(error_results)}
          },
          warning=function(cond) {
            print(paste("Warning for:", state, sex, work_status))
            result <- c(state, sex, work_status, cond)
            warning_results <- c(warning_results, result)
            if (state == "10" & sex == 'M' & work_status == 'FT') { print(warning_results)}
          },
          finally=function(cond){
            print("finally")
          }
        )
      }
    }
  }
  return(c("errors" = error_results, "warnings" = warning_results))
}

