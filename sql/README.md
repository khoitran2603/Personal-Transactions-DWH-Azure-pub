# SQL Layer – Bronze

## Overview
This folder contains all SQL scripts related to the **Bronze layer**, implemented on Azure SQL Server.

The Bronze layer acts as a **raw landing zone** for bank transaction data.  
Data is ingested from CSV files stored in Azure Blob Storage and loaded into Bronze tables **without business transformation**.

### Key Principles
- Preserve source data as-is  
- Minimal schema enforcement  
- Truncation-based reloads for simplicity and traceability  

---

## Folder Structure

```
sql/
├─ bronze/
│  ├─ 0.initial_setup.sql
│  ├─ 1_ddl_bronze.sql
│  ├─ 2_initial_import_proc_anz.sql
│  ├─ 2_initial_import_proc_westpac.sql
│  └─ 2_initial_import_proc_commbank.sql
│
└─ README.md
```
## Execution Notes

### 1. Exact Source File Naming
When executing a load procedure, the source file name must exactly match the file name as stored in the Azure Blob container.
This includes:
- File name
- Extension
- Any naming convention or prefix used in storage

If the file name does not match, the load will fail.

### 2. Truncation Behavior
Each execution of a load procedure performs a **TRUNCATE + INSERT** operation.
Implications:
- Existing data in the Bronze table will be removed when new data is loaded
- The load process is not incremental

⚠️ Before running a new load, ensure that Azure Data Factory has already copied the existing Bronze data into the Data Lake (Silver landing)

## Recommended Execution Order
1. Run ***0.initial_setup.sql*** (one-time setup)
2. Run ***1_ddl_bronze.sql***
3. Upload CSV files to Azure Blob Storage
4. Execute the appropriate ***2_initial_import_proc_*.sql***
5. Trigger Azure Data Factory to copy Bronze data into the Data Lake
6. Repeat steps 3–5 for new files

