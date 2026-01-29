# Databricks Layer

## Overview
Databricks is used for the **Silver and Gold layers** of this project.  
It handles data standardisation, enrichment, consolidation, and business logic using **batch and incremental Spark processing**.

This layer is designed to be:
- Re-runnable (idempotent)
- Source-aware (per-bank logic isolated)
- Business-safe (manual corrections applied in controlled steps)

---

## Folder Structure
```
databricks/
├─ notebooks/
│  ├─ silver_anz/                 # Silver transformations specific to ANZ transactions
│  ├─ silver_westpac/             # Silver transformations specific to Westpac transactions
│  └─ silver_commbank/            # Silver transformations specific to CommBank transactions
│
├─ jobs & pipelines/
│  ├─ 01_manual_transactions_upsert.ipynb    # Apply manual (non-bank) transaction inserts
│  ├─ 02_gold_master_stg_build.ipynb         # Build consolidated Gold staging table from Silver
│  └─ 03_gold_master_cdc_apply.py            # Apply CDC logic to update Gold master (idempotent)
│                                              , packaged as a pipeline and run via Databricks jobs
├─ utils/
│  ├─ lookup_tables.py             # Category, location, and note lookup logic (sample)
│  ├─ manual_inserts.py            # Central definition for manual transaction records (sample)
│  └─ manual_upds_and_dels_anz.py  # Manual updates/deletes for ANZ (reference pattern for others)
│
└─ README.md           

```
