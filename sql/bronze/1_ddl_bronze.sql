-- IMPORTANT: The landing table must match the raw export column count.
-- Keep landing columns as NVARCHAR; cast/clean later in Silver.
-- Repeat the process for each bank/container.

-- ============================================================================
-- ANZ
-- ============================================================================

/* Raw file landing: one row per line (pre-parse / debugging) */
IF OBJECT_ID('stg_anz_lines', 'U') IS NULL
BEGIN
    CREATE TABLE stg_anz_lines (
        line nvarchar(4000) NULL
    );
END;
GO

/* Raw parsed landing: columns as text to avoid truncation / type issues */
IF OBJECT_ID('anz', 'U') IS NULL
BEGIN
    CREATE TABLE anz (
        [Date]        nvarchar(50)    NULL,
        [Amount]      nvarchar(50)    NULL,
        [Description] nvarchar(4000)  NULL,

        -- Ingestion metadata
        updated_at    datetime2(0)    NOT NULL
            CONSTRAINT DF_anz_updated_at DEFAULT (sysdatetime())
    );
END;
GO




