# Processed data

This directory contains analysis-ready datasets generated from files in `data/raw/`.

Rules:

- Do not edit processed files manually.
- Every file must be reproducible from a script in `R/01_data/`.
- Use stable names and document the script that created each file.
- Prefer interoperable formats such as CSV; use RDS only when R-specific objects are required.
