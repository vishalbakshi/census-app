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

# Get input choices for state dropdown
state_df <- get_b20005_states()
state_choices <- state_df[["CODE"]]
names(state_choices) <- state_df[["DESCRIPTION"]]
# UI ----------------------------------------------------------------------
 ui <- fluidPage(
   verticalLayout(
   markdown("# Census ACS 5-Year (2015 - 2019) Data Tool"),
   markdown('#### By Vishal Bakshi'),
   markdown('---'),
   column(8,
   markdown('## What is this app?'),
   markdown("A R Shiny web app which calculates and visualizes U.S. Census American Community Survey (ACS) 2015-2019 5-Year median earnings estimates and population estimates for different earning levels for Rural-Urban Commuting Areas, which are U.S. Census Tract classifications based on population density. RUCA codes are [published by the U.S. Department of Agriculture Economic Research Service](https://www.ers.usda.gov/data-products/rural-urban-commuting-area-codes.aspx)."),
   markdown("The data used for this app is from table B20005 (Sex By Work Experience In The Past 12 Months By Earnings In The Past 12 Months), and the calculations are based on Case Study #1 in [this ACS handbook](https://www.census.gov/content/dam/Census/library/publications/2020/acs/acs_state_local_handbook_2020.pdf), with references to the [PUMS Accuracy of the Data documentation](https://www2.census.gov/programs-surveys/acs/tech_docs/pums/accuracy/2015_2019AccuracyPUMS.pdf)."),
   markdown("## How do I use this app?"),
   markdown("Select a *state*, *sex* and *work status* in the dropdowns below to view a plot and tables of Earnings Estimates and Margins of Error for each RUCA level. You can download the tables, full dataset and plot by clicking the download button under each section."),
   markdown("## Where can I learn more?"),
   markdown("Read [the documentation](https://vishalbakshi.github.io/blog/markdown/2021/09/21/shiny-census-app.html) for this app or get in touch with me at vdbakshi@gmail.com.")
   ),
   markdown('---'),
   selectInput(
     inputId = "state",
     label = "Select state",
     choices = state_choices
     ),
   selectInput(
     inputId = "sex",
     label = "Select sex",
     choices = list("SEX" = c("Female" = "F", "Male" = "M"))
     ),
   selectInput(
     inputId = "work_status",
     label = "Select work status",
     choices = list(
       "WORK STATUS" = c(
         "Full Time Employed" = "FT",
         "Other Employed" = "OTHER"))
     ),
   markdown('<br>'),
   downloadButton(
     outputId = "download_selected_b20005_data",
     label = "Download Selected Tract-Level Data"
   ),
   markdown('<br>'),
   downloadButton(
     outputId = "download_all_b20005_data",
     label = "Download All Tract-Level Data (~20MB)"
   ),
   markdown('---'),
   markdown('### Median Earnings Estimate (USD)'),
   tableOutput(outputId = 'median_data'),
   downloadButton(
     outputId = "download_median_summary", 
     label = "Download Median Earnings Summary"),
   markdown('---'),
   markdown('### Distribution of Earnings Estimates'),
   selectInput(
     inputId = "ruca_level",
     label = "Select RUCA Level",
     choices = list(
       "RUCA LEVEL" = c(
       "Urban" = "Urban", 
       "Large Town" = "Large_Town", 
       "Small Town" = "Small_Town", 
       "Rural" = "Rural"))
     ),
   plotOutput(outputId = 'earnings_histogram'),
   downloadButton(
     outputId = "download_earnings_plot", 
     label = "Download Plot"),
   markdown('---'),
   markdown('### Population Estimates for Earnings by RUCA Level'),
   tableOutput(outputId = "earnings_data"),
   downloadButton(
     outputId = "download_ruca_earnings", 
     label = "Download RUCA Level Earnings"),
   markdown('---')
 ))

# Server ----------------------------------------------------------------------
server <- function(input, output, session) {

  # Get B20005 earnings data based on the Sex, Work Status and State selected
  # format the earnings data to show descriptive row names
  earnings_data <- reactive(
    format_earnings(
      get_b20005_ruca_aggregate_earnings(
        input$state,
        input$sex,
        input$work_status)))
  
  # Get the Design Factor used in median earnings estimate calculations
  design_factor <- reactive(get_design_factor(input$state))
  
  # Calculate the median earnings estimate given population estimates
  # for earning levels by RUCA code
  median_data <- reactive(calculate_median(earnings_data(), design_factor()))

  # Table Outputs
  output$median_data <- renderTable(
    expr = median_data(),
    rownames = TRUE)

  output$earnings_data <- renderTable(
    expr = earnings_data(),
    rownames = TRUE)
  
  # Prettify text values
  get_pretty_text <- function(raw_text){
    text_map <- c("M" = "Male",
    "F" = "Female",
    "FT" = "Full Time",
    "OTHER" = "Other",
    "Urban" = "Urban",
    "Large_Town" = "Large Town",
    "Small_Town" = "Small Town",
    "Rural" = "Rural")
    return(text_map[raw_text])
  }

  earnings_plot_title <- function(){
    return(paste(
      state_df[state_df$CODE == input$state,"DESCRIPTION"],
      get_pretty_text(input$sex),
      get_pretty_text(input$work_status),
      get_pretty_text(input$ruca_level),
      "Workers",
      sep=" "
    ))
    }

  # Plot Output
  # Adjust ruca_level dropdown based on available ruca_levels in the data
  available_ruca_levels <- reactive({
    names(earnings_data())[!grepl("_MOE", names(earnings_data()))]
  })
  
  observe({
    updateSelectInput(session, "ruca_level", choices = available_ruca_levels()
  )})
  
  output$earnings_histogram <- renderPlot(
    expr = make_plot(
      data=earnings_data(),
      ruca_level=input$ruca_level,
      plot_title=earnings_plot_title())
  )

  # Setfilename strings
  b20005_filename <- function(){
    return(paste(
      state_df[state_df$CODE == input$state,"DESCRIPTION"],
      get_pretty_text(input$sex),
      input$work_status,
      "earnings.csv",
      sep="_"
    ))
  }

  median_summary_filename <- function() {
    paste(
      state_df[state_df$CODE == input$state,"DESCRIPTION"],
      get_pretty_text(input$sex),
      input$work_status,
      'estimated_median_earnings_summary.csv',
      sep="_")
  }

  ruca_earnings_filename <- function() {
    paste(
      state_df[state_df$CODE == input$state,"DESCRIPTION"],
      get_pretty_text(input$sex),
      input$work_status,
      'estimated_median_earnings_by_ruca_level.csv',
      sep="_")
  }

  earnings_plot_filename <- function(){
    return(paste(
      state_df[state_df$CODE == input$state,"DESCRIPTION"],
      get_pretty_text(input$sex),
      input$work_status,
      input$ruca_level,
      "Workers.png",
      sep="_"
    ))
  }

  # Download Handlers
  output$download_selected_b20005_data <- downloadHandler(
    filename = "b20005_data.zip",
    content = function(fname) {
      # Create a temporary directory to prevent local storage of new files
      temp_dir <- tempdir()

      # Create two filepath character objects and store them in a list
      # which will later on be passed to the `zip` function
      path1 <- paste0(temp_dir, '/', b20005_filename())
      path2 <- paste0(temp_dir, '/', 'b20005_variables.csv')
      fs <- c(path1, path2)

      # Create a CSV with person-selection input values and do not add a column
      # with row names
      write.csv(
        get_b20005_tract_earnings(input$state, input$sex, input$work_status,FALSE),
        path1,
        row.names = FALSE)

      # Create a CSV for table B20005 variable names and labels for reference
      write.csv(
        get_b20005_ALL_labels(),
        path2,
        row.names = FALSE)

      # Zip together the files and add flags to maximize compression
      zip(zipfile = fname, files=fs, flags = "-r9Xj")
    },
    contentType = "application/zip"
  )

  output$download_all_b20005_data <- downloadHandler(
    filename = "ALL_B20005_data.zip",
    content = function(fname){
      # Create a temporary directory to prevent local storage of new files
      temp_dir <- tempdir()
      path1 <- paste0(temp_dir,'/','ALL_B20005_data.csv')
      path2 <- paste0(temp_dir,'/','b20005_variables.csv')
      fs <- c(path1, path2)

      write.csv(
        get_b20005_tract_earnings(get_all=TRUE),
        path1,
        row.names = FALSE)

      write.csv(
        get_b20005_ALL_labels(),
        path2,
        row.names = FALSE)

      zip(zipfile = fname, files=fs, flags = "-r9Xj")
    },
    contentType = "application/zip"
  )

  output$download_median_summary <- downloadHandler(
    filename = median_summary_filename(),
    content = function(file) {
      write.csv(median_data(), file)
    }
  )

  output$download_earnings_plot <- downloadHandler(
    filename = earnings_plot_filename(),
    content = function(file) {
      ggsave(
        file,
        plot = make_plot(
          data=earnings_data(),
          ruca_level=input$ruca_level,
          plot_title=earnings_plot_title()),
        device = "png")
    }
  )

  output$download_ruca_earnings <- downloadHandler(
    filename = ruca_earnings_filename(),
    content = function(file) {
      write.csv(earnings_data(), file)
    }
  )
  
}

shinyApp(ui, server)
