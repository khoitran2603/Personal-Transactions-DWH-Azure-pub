# Personal-Transactions-DWH-Azure-pub

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
│  ├─ data_architecture.png      # High-level architecture diagram
│  ├─ data_flow.png              # Detailed data flow diagram
│  └─ data_catalog.md            # Gold layer data catalog
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
