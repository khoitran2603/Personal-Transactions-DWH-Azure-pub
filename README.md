# Personal Transaction Data Warehouse & Analytics Project (Azure + Databricks)

A personal data warehouse built to ingest, clean, standardize, and analyze multi-bank transaction data using a Bronze → Silver → Gold architecture.
The project focuses on traceability, repeatability, and analytical readiness, rather than real-time processing.

---
## 🏗️ Data Architecture

The data architecture for this project follows Medallion Architecture **Bronze**, **Silver**, and **Gold** layers:

1. **Bronze Layer**: Stores raw CSV data exactly as received from bank exports. Data is ingested from Azure Container into SQL Server Database, and transfer to Data Lake via ADF.
2. **Silver Layer**: This layer includes data cleansing, standardization, and normalization processes to prepare data for analysis.
3. **Gold Layer**: Consolidate transactions across all banks into a single fact table, applies final business rules and overrides. Become a single source of truth for dashboard and reporting,

---
## 📖 Project Overview
This project simulates a production-style data warehouse using personal financial data.
It emphasizes:
- Clear data lineage
- Controlled refresh behavior
- Separation of raw data, business logic, and analytics output

The warehouse is designed for monthly monitoring, acknowledging that bank exports are not real-time and may be subject to short delays.

## 🚀 Project Requirements


## 📂 Repository Structure
```
Personal-Transactions-DWH-Azure/
│
├─ databricks/
│  ├─ notebooks/                 # Silver transformation notebooks
│  ├─ jobs_pipelines/            # Databricks Jobs & Pipelines 
│  ├─ utils/                     # Shared PySpark utilities and helper logic
│  └─ README.md                  # Databricks layer documentation
│
├─ datafactory/
│  ├─ dataset/                   # ADF dataset definitions (Blob, SQL, ADLS)
│  ├─ factory/                   # Azure Data Factory definition
│  ├─ LinkedService/             # Linked services (Storage, SQL DB, ADLS2)
│  ├─ pipeline/                  # Copy & orchestration pipelines
│  ├─ cdc.json                   # CDC configuration (if applicable)
│  ├─ empty.json                 # Template/placeholder config
│  └─ loop_input.txt             # Loop input for parameterised pipelines
│
├─ docs/
│  ├─ data_architecture.drawio   # Draw.io file shows the project's architecture
│  ├─ data_flow.drawio           # Draw.io file for the data flow diagram
│  └─ data_catalog.md            # Gold layer data catalog, including field descriptions and metadata
│
├─ source/
│  ├─ bank_anz/                  # Reference structure / sanitised sample files
│  ├─ bank_commbank/             # Reference structure / sanitised sample files
│  ├─ bank_westpac/              # Reference structure / sanitised sample files
│
├─ sql/
│  ├─ bronze/                    # Bronze layer DDL & stored procedures
│  └─ README.md                  # SQL execution order & design notes
│
└─ README.md                     # Project overview & usage guide
```
---
## 🗝️ Key Outputs
- Unified transaction fact table across multiple banks
- Categorized income and expense records
- Monthly and historical spending trends
- Clean inputs for dashboards and forecasting models
- A reusable personal analytics framework that scales over time

---
## 🛡️ License

This project is licensed under the [MIT License](LICENSE). You are free to use, modify, and share this project with proper attribution.
