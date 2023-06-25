# Start the clock!
#ptm <- proc.time()

library(DBI)
library(censusapi)

census_app_db <- dbConnect(RSQLite::SQLite(), "census_app_db.sqlite")

if (dbExistsTable(census_app_db, "b20005")) {
  dbRemoveTable(census_app_db, "b20005")
}

if (dbExistsTable(census_app_db, "b20005_vars")) {
  dbRemoveTable(census_app_db, "b20005_vars")
}

if (dbExistsTable(census_app_db, "ruca")) {
  dbRemoveTable(census_app_db, "ruca")
}

if (dbExistsTable(census_app_db, "design_factors")) {
  dbRemoveTable(census_app_db, "design_factors")
}

if (dbExistsTable(census_app_db, "codes")) {
  dbRemoveTable(census_app_db, "codes")
}

# CODES -----------------------------------------------------------------------
state_codes <- read.csv(
  "data/state_codes.csv",
  colClasses = c(
    "character", 
    "character", 
    "character")
)

ruca_levels <- read.csv(
  "data/ruca_levels.csv",
  colClasses = c(
    "character",
    "character",
    "character")
)

create_codes_table <- "CREATE TABLE codes (
  CATEGORY TEXT,
  CODE TEXT,
  DESCRIPTION TEXT,
  PRIMARY KEY (DESCRIPTION, CODE))"

rows_affected <- dbExecute(census_app_db, create_codes_table)
dbWriteTable(census_app_db, 'codes', state_codes, append = TRUE)
dbWriteTable(census_app_db, 'codes', ruca_levels, append = TRUE)

# Table b20005_var ------------------------------------------------------------
b20005_vars <- listCensusMetadata(
  name = 'acs/acs5',
  vintage = 2015,
  type = 'variables',
  group = 'B20005')

b20005_vars <- b20005_vars[,c("name", "label")]

# Remove rows with annotation variables (ending with "MA" or "EA")
mask <- !grepl("A", b20005_vars$name)
b20005_vars <- b20005_vars[mask,]

# Order data.frame by ascending name
b20005_vars <- b20005_vars[order(b20005_vars$name),]

create_b20005_vars_table <- "CREATE TABLE b20005_vars (
  name TEXT PRIMARY KEY,
  label TEXT)"

rows_affected <- dbExecute(census_app_db, create_b20005_vars_table)
dbWriteTable(census_app_db, "b20005_vars", b20005_vars, append = TRUE)

# Table b20005 ----------------------------------------------------------------------
# Construct character object to assign the `regionin` parameter in `getCensus`
regionin_value <- paste(
  'state:',
  paste(
    state_codes[-1, "CODE"], 
    collapse = ","), 
  collapse="", sep="")

# Get ACS5 detailed table B20005 for estimate and margin of error variables
# for all tracts in all states
b20005 <- getCensus(
  name = 'acs/acs5',
  region = "tract:*",
  regionin = regionin_value,
  vintage = 2015,
  vars = b20005_vars$name,
  key="ae6f9efbeeec83ae928bac5cbce2e4b3961aa4e9"
  )

create_b20005_table <- paste(
  "CREATE TABLE b20005 (
  state TEXT, county TEXT, tract TEXT, ",
  paste(paste(b20005_vars$name, 'INT'), collapse = ","),
  ", PRIMARY KEY (state, county, tract))",
  sep=""
)

rows_affected <- dbExecute(census_app_db, create_b20005_table)
dbWriteTable(census_app_db, "b20005", b20005, append = TRUE)

# RUCA Codes ------------------------------------------------------------------
ruca <- read.csv(
  file = "data/ruca_codes.csv",
  colClasses = c(
    "character", 
    "character", 
    "character", 
    "character", 
    "integer",
    "character",
    "character",
    "character",
    "character"))

# Convert character numbers with commas to numeric values
ruca$TRACTPOPULATION <- as.numeric(gsub(",", "", ruca$TRACTPOPULATION))
ruca$POPULATIONDENSITY <- as.numeric(gsub(",", "", ruca$POPULATIONDENSITY))
ruca$LANDAREA <- as.numeric(gsub(",", "", ruca$LANDAREA))

# Merge ruca levels ("Urban", "Small Town", ...) to ruca codes table
ruca <- merge(ruca, ruca_levels[c("CODE", "DESCRIPTION")], by.x = 'PRIMARYRUCA', by.y = 'CODE')

create_ruca_table <- "CREATE TABLE ruca (
  COUNTYFIPS TEXT,
  STATE TEXT,
  COUNTY TEXT,
  TRACTFIPS TEXT PRIMARY KEY,
  PRIMARYRUCA INT,
  SECONDARYRUCA DOUBLE,
  TRACTPOPULATION INT,
  LANDAREA DOUBLE,
  POPULATIONDENSITY DOUBLE,
  DESCRIPTION TEXT)"

rows_affected <- dbExecute(census_app_db, create_ruca_table)
dbWriteTable(census_app_db, 'ruca', ruca, append = TRUE)

# DESIGN FACTORS --------------------------------------------------------------
design_factors <- read.csv(
  file = "data/2019_PUMS_5yr_Design_Factors.csv",
  colClasses = c(
    "character",
    "character",
    "character",
    "character",
    "character",
    "character",
    "numeric")
)

create_design_factors_table <- "CREATE TABLE design_factors(
  YEAR TEXT,
  PERIOD TEXT,
  STATE TEXT,
  ST TEXT,
  CHARTYP TEXT,
  CHARACTERISTIC TEXT,
  DESIGN_FACTOR DOUBLE,
  PRIMARY KEY (ST, CHARACTERISTIC))"

rows_affected <- dbExecute(census_app_db, create_design_factors_table)
dbWriteTable(census_app_db, 'design_factors', design_factors, append = TRUE)

dbListTables(census_app_db)
dbDisconnect(census_app_db)
# Stop the clock
#proc.time() - ptm
