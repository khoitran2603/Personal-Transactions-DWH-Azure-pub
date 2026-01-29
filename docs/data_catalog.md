# Data Catalog for Gold Layer

## Overview
The Gold layer contains **business-ready, consolidated transaction data** used for reporting and analysis.  
It integrates curated data from multiple banks, applies deduplication and business logic, and provides a **single, trusted view** of personal financial activity.

---

### **1. gold.master**

### Purpose
- **Purpose:** Final transaction table used for BI dashboards and analytics. All records are standardized, deduplicated, and safe for repeated pipeline runs.
- **Columns:**

| Column Name | Data Type | Description |
|------------|-----------|-------------|
| transaction_date | DATE | Date the transaction occurred, normalized across all sources. |
| transaction_type | VARCHAR(50) | Indicates `Income` or `Expenses`. |
| category | VARCHAR(50) | Business category assigned via rules or manual overrides. |
| note | VARCHAR(255) | Optional contextual note describing transaction intent. |
| transaction_amount | DECIMAL(10,2) | Signed transaction value (positive = income, negative = expense). |
| transaction_details | VARCHAR(255) | Cleaned, user-friendly transaction description. |
| transaction_details_raw | VARCHAR(5000) | Original raw bank description for traceability. |
| location | VARCHAR(100) | Inferred physical or online transaction location. |
| bank | VARCHAR(50) | Source bank identifier (e.g. ANZ, CommBank, Westpac). |
| payment | VARCHAR(50) | Derived payment channel (On-site, Online, Cash, Personal). |
| transaction_id | BIGINT | Unique transaction identifier for deduplication. |
| updated_at | DATETIME | Timestamp of the last update in the Gold layer. |
