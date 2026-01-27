/* ============================================================================
   Purpose: Configure Azure SQL DB to read files from Azure Blob Storage via SAS
   Notes:
     - Run in the TARGET database (not master).
     - Master key is required to store secrets for scoped credentials.
     - Create one credential + external data source per storage container/bank.
   ============================================================================ */

-- Check current database context
SELECT DB_NAME() AS current_database;
GO

/* ---------------------------------------------------------------------------
   1) Create Database Master Key (one-time per database)
   --------------------------------------------------------------------------- */
  
IF NOT EXISTS (
    SELECT 1 FROM sys.symmetric_keys
    WHERE name = '##MS_DatabaseMasterKey##'
)
BEGIN
    CREATE MASTER KEY ENCRYPTION BY PASSWORD = '<<STRONG_PASSWORD_HERE>>';
END;
GO

/*---------------------------------------------------------------------------
   2) Create a Database Scoped Credential using SAS token (one per container)
   ---------------------------------------------------------------------------
   SAS token: Azure Portal → Storage Account → Containers → <container> → Shared access tokens
   IMPORTANT:
     - SECRET should be the SAS token string (often starts with '?sv=...')*/
  
IF NOT EXISTS (
    SELECT 1 FROM sys.database_scoped_credentials
    WHERE name = 'BudgetANZBlobCred'
)
BEGIN
    CREATE DATABASE SCOPED CREDENTIAL BudgetANZBlobCred
    WITH IDENTITY = 'SHARED ACCESS SIGNATURE',
         SECRET   = '<<SAS_TOKEN_HERE>>';
END;
GO

/* ---------------------------------------------------------------------------
   3) Register External Data Source (points to the container)
   ---------------------------------------------------------------------------*/
  
IF NOT EXISTS (
    SELECT 1 FROM sys.external_data_sources
    WHERE name = 'BudgetANZBlob'
)
BEGIN
    CREATE EXTERNAL DATA SOURCE BudgetANZBlob
    WITH (
        TYPE = BLOB_STORAGE,
        LOCATION = 'https://storagebudgetproject.blob.core.windows.net/source-anz',
        CREDENTIAL = BudgetANZBlobCred
    );
END;
GO

-- Repeat steps (2) and (3) per bank/container:
--   - BudgetWestpacBlobCred + BudgetWestpacBlob
--   - BudgetCommbankBlobCred + BudgetCommbankBlob
