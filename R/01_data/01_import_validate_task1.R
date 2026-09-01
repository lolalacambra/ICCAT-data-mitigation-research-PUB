# Purpose -----------------------------------------------------------------
# Import and validate the ICCAT Task I nominal catch workbook used for the
# Chapter 1 DATA analysis. This script never modifies the raw workbook.

required_packages <- c(
  "digest",
  "dplyr",
  "here",
  "readr",
  "readxl",
  "stringr",
  "tibble",
  "tidyr"
)

missing_packages <- required_packages[
  !vapply(required_packages, requireNamespace, logical(1), quietly = TRUE)
]

if (length(missing_packages) > 0) {
  stop(
    "Missing packages: ",
    paste(missing_packages, collapse = ", "),
    ". Install them once, then record the environment with renv::snapshot()."
  )
}

suppressPackageStartupMessages({
  library(dplyr)
  library(here)
  library(readr)
  library(readxl)
  library(stringr)
  library(tibble)
  library(tidyr)
})

# Paths -------------------------------------------------------------------
raw_file <- here("data", "raw", "task1", "t1nc-20250131_ALL.xlsx")
taxon_file <- here("docs", "01_data", "resolution_19_01_taxa.csv")
inventory_file <- here("docs", "01_data", "data_inventory.csv")
processed_dir <- here("data", "processed")
diagnostic_dir <- here("outputs", "01_data", "diagnostics")

dir.create(processed_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(diagnostic_dir, recursive = TRUE, showWarnings = FALSE)

if (!file.exists(raw_file)) {
  stop(
    "Task I workbook not found at: ", raw_file,
    "\nPlace the unchanged ICCAT file in data/raw/task1/."
  )
}

if (!file.exists(taxon_file) || !file.exists(inventory_file)) {
  stop("Required documentation files are missing from docs/01_data/.")
}

# Provenance check --------------------------------------------------------
inventory <- read_csv(inventory_file, show_col_types = FALSE)
inventory_row <- inventory %>%
  filter(dataset_id == "task1_nominal_catch")

if (nrow(inventory_row) != 1) {
  stop("The data inventory must contain one Task I nominal catch entry.")
}

actual_sha256 <- digest::digest(
  file = raw_file,
  algo = "sha256",
  serialize = FALSE
)

if (!identical(tolower(actual_sha256), tolower(inventory_row$sha256[[1]]))) {
  stop(
    "The Task I workbook checksum differs from the documented source. ",
    "Do not continue until the file version is identified."
  )
}

# Import ------------------------------------------------------------------
t1_raw <- read_excel(raw_file, sheet = "Data", .name_repair = "check_unique")
taxon_key <- read_csv(
  taxon_file,
  show_col_types = FALSE,
  na = c("", "NA")
)

required_columns <- c(
  "RecID", "Species", "ScieName", "SpeciesGrp", "YearC",
  "PartyName", "FlagName", "FleetCode", "Stock", "SampAreaCode",
  "Area", "SpcGearGrp", "GearGrp", "GearCode", "CatchTypeCode",
  "FishZoneCode", "QualInfoCode", "Qty_t", "CatchSource"
)

missing_columns <- setdiff(required_columns, names(t1_raw))

if (length(missing_columns) > 0) {
  stop("Missing required Task I columns: ", paste(missing_columns, collapse = ", "))
}

# Validate the Resolution 19-01 scope ------------------------------------
resolution_species <- taxon_key %>%
  filter(res19_01_species)

if (nrow(resolution_species) != 24 ||
    n_distinct(resolution_species$resolution_name) != 24) {
  stop("The taxon key must contain exactly 24 Resolution 19-01 species.")
}

analysis_key <- taxon_key %>%
  filter(include_taxonomic_analysis) %>%
  select(
    task1_scie_name,
    task1_code,
    Family = family,
    Reporting_level = reporting_level,
    Record_scope = record_scope,
    Res19_01_species = res19_01_species,
    Resolution_name = resolution_name
  )

duplicated_names <- analysis_key %>%
  count(task1_scie_name) %>%
  filter(n > 1)

if (nrow(duplicated_names) > 0) {
  stop("Duplicated Task I scientific names found in the taxon key.")
}

taxon_presence <- resolution_species %>%
  select(
    resolution_order,
    Family = family,
    Resolution_name = resolution_name,
    Task1_name = task1_scie_name,
    Task1_code = task1_code
  ) %>%
  left_join(
    t1_raw %>%
      group_by(ScieName) %>%
      summarise(
        Number_records = n(),
        Positive_records = sum(Qty_t > 0, na.rm = TRUE),
        Catch_t = sum(Qty_t, na.rm = TRUE),
        First_year = min(YearC, na.rm = TRUE),
        Last_year = max(YearC, na.rm = TRUE),
        Number_flags = n_distinct(FlagName),
        .groups = "drop"
      ),
    by = c("Task1_name" = "ScieName")
  ) %>%
  mutate(
    Records_present = !is.na(Number_records),
    across(
      c(Number_records, Positive_records, Catch_t, Number_flags),
      ~ replace_na(.x, 0)
    ),
    across(c(First_year, Last_year), as.integer)
  ) %>%
  arrange(resolution_order)

# Standardized selected dataset ------------------------------------------
task1_selected <- t1_raw %>%
  inner_join(analysis_key, by = c("ScieName" = "task1_scie_name")) %>%
  transmute(
    Record_id = as.integer(RecID),
    Year = as.integer(YearC),
    Species_code = as.character(Species),
    Scientific_name = as.character(ScieName),
    Resolution_name = as.character(Resolution_name),
    Family = as.character(Family),
    Reporting_level = as.character(Reporting_level),
    Record_scope = as.character(Record_scope),
    Res19_01_species = as.logical(Res19_01_species),
    Species_group = as.character(SpeciesGrp),
    Party_status = as.character(PartyStatus),
    Reporting_party = str_squish(as.character(PartyName)),
    Flag = str_squish(as.character(FlagName)),
    Fleet_code = as.character(FleetCode),
    Stock = as.character(Stock),
    Sampling_area = as.character(SampAreaCode),
    Task1_area = as.character(Area),
    Specific_gear_group = as.character(SpcGearGrp),
    Gear_group = as.character(GearGrp),
    Gear_code = as.character(GearCode),
    Catch_type = as.character(CatchTypeCode),
    Fishing_zone = as.character(FishZoneCode),
    Quality_code = as.character(QualInfoCode),
    Catch_source = as.character(CatchSource),
    Catch_t = as.numeric(Qty_t),
    Positive_record = Catch_t > 0,
    Zero_record = Catch_t == 0
  ) %>%
  filter(between(Year, 1950L, 2023L))

# Validation --------------------------------------------------------------
if (nrow(task1_selected) == 0) {
  stop("No Task I records matched the documented taxon key.")
}

if (anyNA(task1_selected$Year) || anyNA(task1_selected$Catch_t)) {
  stop("Missing year or catch weight found in the selected Task I data.")
}

if (any(task1_selected$Catch_t < 0)) {
  stop("Negative catch quantities found in the selected Task I data.")
}

unexpected_sources <- setdiff(
  unique(task1_selected$Catch_source),
  c("Reported", "Estimated")
)

if (length(unexpected_sources) > 0) {
  warning("Unexpected catch-source categories: ", paste(unexpected_sources, collapse = ", "))
}

if (any(task1_selected$Catch_type %in% c("DL", "LD"))) {
  warning("Live-discard records were found although the workbook metadata says they are excluded.")
}

# Diagnostic outputs ------------------------------------------------------
audit_summary <- tribble(
  ~Metric, ~Value,
  "Raw rows", nrow(t1_raw),
  "Raw columns", ncol(t1_raw),
  "Selected rows", nrow(task1_selected),
  "Selected positive rows", sum(task1_selected$Positive_record),
  "Selected zero rows", sum(task1_selected$Zero_record),
  "Selected catch tonnes", sum(task1_selected$Catch_t),
  "Resolution 19-01 species", nrow(resolution_species),
  "Resolution species with Task I records", sum(taxon_presence$Records_present),
  "Resolution species without Task I records", sum(!taxon_presence$Records_present),
  "Selected flags", n_distinct(task1_selected$Flag),
  "Selected reporting parties", n_distinct(task1_selected$Reporting_party),
  "First year", min(task1_selected$Year),
  "Last year", max(task1_selected$Year),
  "Live discards included", FALSE,
  "Raw SHA-256", actual_sha256
)

catch_type_summary <- task1_selected %>%
  group_by(Catch_type, Catch_source) %>%
  summarise(
    Number_records = n(),
    Positive_records = sum(Positive_record),
    Zero_records = sum(Zero_record),
    Catch_t = sum(Catch_t),
    First_year = min(Year),
    Last_year = max(Year),
    Number_flags = n_distinct(Flag),
    .groups = "drop"
  ) %>%
  arrange(Catch_type, Catch_source)

saveRDS(
  task1_selected,
  file = file.path(processed_dir, "task1_selected_res19_01.rds"),
  version = 3
)

write_csv(
  task1_selected,
  file.path(processed_dir, "task1_selected_res19_01.csv"),
  na = ""
)

write_csv(
  audit_summary,
  file.path(diagnostic_dir, "task1_audit_summary.csv"),
  na = ""
)

write_csv(
  taxon_presence,
  file.path(diagnostic_dir, "resolution_19_01_taxon_presence.csv"),
  na = ""
)

write_csv(
  catch_type_summary,
  file.path(diagnostic_dir, "task1_catch_type_summary.csv"),
  na = ""
)

message("Task I import and validation completed successfully.")
print(audit_summary, n = Inf)
