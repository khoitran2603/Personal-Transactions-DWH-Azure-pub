/* Load Commbank CSV from Blob Storage into bronze tables */
CREATE OR ALTER PROCEDURE load_commbank_from_blob
    @file nvarchar(4000)   
AS
BEGIN
    SET NOCOUNT ON;

    ---------------------------------------------------------------------
    -- Step 1: BULK INSERT raw lines into stg_commbank_lines
    ---------------------------------------------------------------------
    TRUNCATE TABLE stg_commbank_lines;

    DECLARE @sql nvarchar(max) = N'
    BULK INSERT stg_commbank_lines
    FROM ' + QUOTENAME(@file,'''') + N'
    WITH (
        DATA_SOURCE      = ''BudgetCommbankBlob'',
        FIRSTROW         = 1,          
        FIELDTERMINATOR  = ''0x1F'',   
        ROWTERMINATOR    = ''0x0A'',
        CODEPAGE         = ''65001''
    );';

    EXEC sys.sp_executesql @sql;

    ---------------------------------------------------------------------
    -- Step 2: Parse lines into anz and stamp updated_at
    ---------------------------------------------------------------------
    TRUNCATE TABLE commbank;

    INSERT INTO commbank
        ([Date], [Amount], [Description], [Balance], updated_at)
    SELECT
        -- Date = text before first comma
        LTRIM(RTRIM(LEFT(l, p.c1 - 1))) AS [Date],
    
        -- Amount = first quoted value
        SUBSTRING(l, p.q1 + 1, p.q2 - p.q1 - 1) AS [Amount],
    
        -- Description = second quoted value
        SUBSTRING(l, p.q3 + 1, p.q4 - p.q3 - 1) AS [Description],
    
        -- Balance = third quoted value
        SUBSTRING(l, p.q5 + 1, p.q6 - p.q5 - 1) AS [Balance],
    
        -- Ingestion timestamp
        SYSUTCDATETIME() AS updated_at
    FROM (
        -- Remove CR/LF from raw line
        SELECT REPLACE(REPLACE([line], CHAR(13), ''), CHAR(10), '') AS l
        FROM stg_commbank_lines
    ) x
    CROSS APPLY (
        SELECT
            -- First comma (end of Date)
            CHARINDEX(',', x.l) AS c1,
    
            -- Quote positions for Amount
            CHARINDEX('"', x.l, CHARINDEX(',', x.l) + 1) AS q1,
            CHARINDEX('"', x.l, CHARINDEX('"', x.l, CHARINDEX(',', x.l) + 1) + 1) AS q2,
    
            -- Quote positions for Description
            CHARINDEX('"', x.l, CHARINDEX('"', x.l, CHARINDEX('"', x.l, CHARINDEX(',', x.l) + 1) + 1) + 1) AS q3,
            CHARINDEX('"', x.l, CHARINDEX('"', x.l, CHARINDEX('"', x.l, CHARINDEX('"', x.l, CHARINDEX(',', x.l) + 1) + 1) + 1) + 1) AS q4,
    
            -- Quote positions for Balance
            CHARINDEX('"', x.l, CHARINDEX('"', x.l, CHARINDEX('"', x.l, CHARINDEX('"', x.l, CHARINDEX('"', x.l, CHARINDEX(',', x.l) + 1) + 1) + 1) + 1) + 1) AS q5,
            CHARINDEX('"', x.l, CHARINDEX('"', x.l, CHARINDEX('"', x.l, CHARINDEX('"', x.l, CHARINDEX('"', x.l, CHARINDEX('"', x.l, CHARINDEX(',', x.l) + 1) + 1) + 1) + 1) + 1) + 1) AS q6
    ) p
    WHERE
        -- Ignore blank lines
        x.l IS NOT NULL
        AND LTRIM(RTRIM(x.l)) <> ''
    
        -- Ensure all delimiters exist before parsing
        AND p.c1 > 0
        AND p.q1 > 0 AND p.q2 > 0
        AND p.q3 > 0 AND p.q4 > 0
        AND p.q5 > 0 AND p.q6 > 0;
END
GO

/* Example execution (upload file to the blob container first) */
-- EXEC load_commbank_from_blob @file = N'2025_01-08';
