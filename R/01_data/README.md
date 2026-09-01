# Chapter 1: DATA scripts

Run scripts in numerical order from the RStudio project.

## Implemented

1. `01_import_validate_task1.R`
   - verifies the raw workbook checksum;
   - checks the required Task I fields;
   - applies the Resolution 19-01 taxon key;
   - distinguishes positive records, zero-valued records, and absent records;
   - writes the standardized Task I dataset and validation diagnostics.

2. `02_taxonomic_resolution.R`
   - calculates annual catch weight by species, genus aggregate, and family aggregate;
   - produces absolute and proportional taxonomic-resolution outputs;
   - includes a blue-shark sensitivity dataset;
   - saves tables and publication-ready PNG figures.

## Next modules

3. `03_nominal_catches.R`: trends by taxon, family, data source, and gear.
4. `04_flag_and_party_reporting.R`: flag and reporting-party representation, with explicit denominators where possible.
5. `05_catch_type_reporting.R`: generic catch (`C`), landings (`L`), and dead discards (`DD`).
6. `06_import_validate_live_discards.R`: live releases from the separate ICCAT extraction.
7. `07_import_validate_task2.R`: Task II catch-and-effort data.
8. `08_task2_availability.R`: temporal availability and resolution of Task II.
9. `09_generate_outputs.R`: regenerate final tables and figures.

## Rules

Each script must:

- use project-relative paths;
- state its inputs and outputs;
- avoid modifying raw data;
- include validation checks;
- distinguish a zero-valued record from an absent record;
- distinguish flag representation from denominator-based reporting coverage;
- retain reported and estimated records as separate fields;
- produce deterministic results;
- record important assumptions in `docs/01_data/`.

Do not install packages inside analysis scripts. Package versions will be managed with `renv`.
