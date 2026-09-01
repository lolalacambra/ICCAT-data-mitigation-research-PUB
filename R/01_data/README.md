# Chapter 1: DATA scripts

Scripts will be numbered and run in order.

Planned workflow:

1. `01_import_task1.R`: import Task I nominal catches.
2. `02_validate_task1.R`: validate fields, units, codes, duplicates, and missing values.
3. `03_clean_task1.R`: standardize Task I and create the analysis-ready dataset.
4. `04_nominal_catch_trends.R`: analyze temporal trends and composition by gear.
5. `05_taxonomic_resolution.R`: quantify reporting at species, genus, family, and higher levels.
6. `06_reporting_components.R`: assess coverage of landings, dead discards, and live releases.
7. `07_import_validate_task2.R`: import and validate Task II.
8. `08_task2_availability.R`: assess the availability of catch-and-effort data.
9. `09_generate_outputs.R`: regenerate final tables and figures.

Each script must:

- use project-relative paths;
- state its inputs and outputs;
- avoid modifying raw data;
- include validation checks;
- produce deterministic results;
- record important assumptions in `docs/01_data/`.
