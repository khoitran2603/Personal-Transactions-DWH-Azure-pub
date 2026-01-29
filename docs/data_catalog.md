# Data Catalog for Gold Layer

## Overview
The Gold layer contains **business-ready, consolidated transaction data** used for reporting and analysis.  
It integrates curated data from multiple banks, applies deduplication and business logic, and provides a **single, trusted view** of personal financial activity.

---

## gold.master

### Purpose
Final transaction table used for BI dashboards and analytics.  
All records are standardized, deduplicated, and safe for repeated pipeline runs.

---

### Columns

| Column Name | Description |
|------------|-------------|
| transaction_date | Date the transaction occurred, normalized across all sources. |
| transaction_type | Indicates `Income` or `Expenses`. |
| category | Business category assigned via rules or manual overrides. |
| note | Optional contextual note describing transaction intent. |
| transaction_amount | Signed transaction value (positive = income, negative = expense). |
| transaction_details | Cleaned, user-friendly transaction description. |
| transaction_details_raw | Original raw bank description for traceability. |
| location | Inferred physical or online transaction location. |
| bank | Source bank identifier (e.g. ANZ, CommBank, Westpac). |
| payment | Derived payment channel (On-site, Online, Cash, Personal). |
| transaction_id | Unique transaction identifier for deduplication. |
| updated_at | Timestamp of the last update in the Gold layer. |
