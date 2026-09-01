# Review of `TRENDS_REPORT.R`

Review date: 2026-09-01

Source SHA-256: `3d5e37baaa39077237066eabf9b88bbc887d3dd9a8487f6f55df79b9c801009a`

## What is retained

The exploratory script contains useful analyses for:

- nominal catch trends by family and taxon;
- taxonomic resolution at species, genus, and family levels;
- representation of flags through time;
- reported versus estimated records;
- blue shark sensitivity analyses;
- catch-type reporting (`C`, `L`, and `DD`);
- detailed exploration of silky shark landings by flag and gear.

These analyses will be migrated into separate numbered scripts after the input
data and taxon scope have been validated.

## Issues requiring correction

1. The script installs a package during execution. Package installation must be
   managed separately with `renv`.
2. The input path is absolute and points to an older directory. Project-relative
   paths are required.
3. Several large blocks and objects are duplicated or overwritten, including
   `reporting_df`, `p_resolution`, `catchtype_data`, and
   `ghana_fal_details`.
4. The script contains an incomplete pipe near the silky-shark annual table and
   therefore cannot run from beginning to end.
5. `taxonomic_plot_data`, `p_total`, and `flags_by_taxon` are used without being
   created in the preceding workflow.
6. The original taxon key omitted three Resolution 19-01 species:
   `Manta alfredi`, `Mobula hypostoma`, and `Mobula japonica`.
7. The original taxon key omitted the Task I family aggregate `Sphyrnidae`
   (`SPY`), which affects the taxonomic-resolution analysis.
8. A figure subtitle states “reported records only” although reported and
   estimated records are both retained.
9. Flags with positive catches are not a denominator-based measure of reporting
   coverage. This indicator must be described as flag representation unless an
   appropriate set of active/expected flags is constructed.
10. Zero-valued rows and absence of a row are not equivalent. Both must be
    retained and summarized separately.
11. The supplied workbook excludes live discards. Live releases cannot be
    evaluated with this file.
12. Catch type `C` is a generic catch category. Analyses must not assume that it
    is always independent of `L` and `DD` without checking the relevant strata.

## Refactoring sequence

1. `01_import_validate_task1.R`: provenance, taxon scope, validation, and a
   standardized analysis dataset.
2. `02_taxonomic_resolution.R`: absolute and proportional taxonomic-resolution
   outputs.
3. `03_nominal_catches.R`: annual trends by taxon, family, source, and gear.
4. `04_flag_and_party_reporting.R`: flag and reporting-party representation,
   with explicit denominators where possible.
5. `05_catch_type_reporting.R`: `C`, `L`, and `DD`, with live discards analyzed
   separately when the corresponding extraction is available.

## Official references

- Resolution 19-01: https://www.iccat.int/Documents/Recs/compendiopdf-e/2019-01-e.pdf
- ICCAT data access: https://www.iccat.int/en/accesingdb.html
- ICCAT statistics manual: https://www.iccat.int/Documents/SCRS/Manual/Chapter1.htm
