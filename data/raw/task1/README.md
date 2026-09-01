# ICCAT Task I raw data

Place the original workbook at:

`data/raw/task1/t1nc-20250131_ALL.xlsx`

The supplied file has the following characteristics:

- ICCAT version: `2025-01-30`
- coverage: 1950–2023
- data sheet: `Data`
- rows: 104,805
- columns: 23
- SHA-256: `c93da30f6f57e864208ace5e25a75b5e658ce2aadfc12fe7880897522410674f`
- live discards/releases: excluded from this extraction

Rules:

- Do not modify or resave the raw workbook.
- Preserve the original filename.
- Run `R/01_data/01_import_validate_task1.R` before any analysis.
- Record a new inventory entry whenever a newer ICCAT version is used.

The workbook is 7.7 MB and can be versioned in Git, but it must be added from
the local repository because the current remote integration only writes text
files.
