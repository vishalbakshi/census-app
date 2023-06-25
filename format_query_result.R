source('get_b20005_labels.R', local=TRUE)
format_earnings <- function(rs) {
  # Get long-form earnings level labels to display as row names in UI
  census_app_db <- dbConnect(RSQLite::SQLite(), "census_app_db.sqlite")
  labels <- get_b20005_labels()
  dbDisconnect(census_app_db)
  
  # Pull out query result data.frames from the list
  estimate <- rs[["estimate"]]
  moe <- rs[["moe"]]

  # Transpose the query results
  col_names <- estimate[,"DESCRIPTION"]
  estimate <- t(estimate[-1])
  colnames(estimate) <- col_names
  
  col_names <- moe[,"DESCRIPTION"]
  moe <- t(moe[-1])
  colnames(moe) <- col_names
  
  # Create a mapping to make column names more computer-readable
  format_ruca_level <- c(
    "Urban" = "Urban", 
    "Large Town" = "Large_Town", 
    "Small Town" = "Small_Town", 
    "Rural" = "Rural",
    "Zero Population" = "Zero_Population")
  
  # bind together estimate and corresponding moe columns
  # some states do not have all RUCA levels
  # for example, Connecticut does not have "Small Town" tracts

  # Create empty objects
  output_table <- data.frame(temp = matrix(NA, nrow = nrow(estimate), ncol = 0))
  col_names <- c()
  
  for (ruca_level in c("Urban", "Large Town", "Small Town", "Rural")) {
    if (ruca_level %in% colnames(estimate)) {
      output_table <- cbind(output_table, estimate[,ruca_level], moe[,ruca_level])
      
      # paste "_MOE" suffix for MOE columns
      col_names <- c(
        col_names,
        format_ruca_level[[ruca_level]],
        paste0(format_ruca_level[[ruca_level]], "_MOE"))
    }
  }

  # Replace old names with more computer-readable names
  colnames(output_table) <- col_names

  # name rows as long-form labels, by splitting them by '!!' and 
  # grabbing the last chunk which has dollar ranges e.g. 
  # $30000 to $34999
  output_table <- merge(output_table, labels, by.x = 0, by.y = "name")
  split_label <- data.frame(
    do.call(
      'rbind', 
      strsplit(as.character(output_table$label),'!!',fixed=TRUE)))

  rownames(output_table) <- split_label$X6
  
  # Drop Row.names and label columns
  output_table <- subset(output_table, select = -c(Row.names, label))

  return(output_table)
}