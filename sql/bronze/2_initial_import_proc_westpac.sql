/* Load Westpac CSV from Blob Storage into bronze tables */
CREATE OR ALTER PROCEDURE load_westpac_from_blob
    @file nvarchar(4000)
AS
BEGIN
    SET NOCOUNT ON;

    ---------------------------------------------------------------------
    -- Step 1: land raw lines
    ---------------------------------------------------------------------
    TRUNCATE TABLE stg_westpac_lines;

    DECLARE @sql nvarchar(max) = N'
    BULK INSERT stg_westpac_lines
    FROM ' + QUOTENAME(@file,'''') + N'
    WITH (
        DATA_SOURCE      = ''BudgetWestpacBlob'',
        FIRSTROW         = 2,
        FIELDTERMINATOR  = ''0x1F'',
        ROWTERMINATOR    = ''0x0A'',
        CODEPAGE         = ''65001''
    );';

    EXEC sys.sp_executesql @sql;

    ---------------------------------------------------------------------
    -- Step 2: parse CSV
    ---------------------------------------------------------------------
    TRUNCATE TABLE westpac;

    INSERT INTO westpac
        ([Bank_Account], [Date], [Narrative],
         [Debit_Amount], [Credit_Amount],[Balance], 
		 [Categories], [Serial], updated_at)
    SELECT
        -- Bank account column (empty if present in raw)
        CASE 
            WHEN LEFT(l, p.c1 - 1) IS NOT NULL THEN ''
            ELSE NULL
        END                                               AS [Bank_Account],
    
        -- Date = value between first and second comma
        SUBSTRING(l, p.c1 + 1, p.c2 - p.c1 - 1)           AS [Date],
    
        -- Narrative = quoted text
        SUBSTRING(l, p.q1 + 1, p.q2 - p.q1 - 1)           AS [Narrative],
    
        -- Debit amount (null if 'n/a')
        NULLIF(LEFT(r.rem, k.r1 - 1), 'n/a')              AS [Debit_Amount],
    
        -- Credit amount (null if 'n/a')
        NULLIF(SUBSTRING(r.rem, k.r1 + 1, k.r2 - k.r1 - 1), 'n/a')
                                                           AS [Credit_Amount],
    
        -- Balance (safe numeric conversion)
        TRY_CONVERT(decimal(18,2),
            SUBSTRING(r.rem, k.r2 + 1, k.r3 - k.r2 - 1))  AS [Balance],
    
        -- Categories (null if 'n/a')
        NULLIF(SUBSTRING(r.rem, k.r3 + 1, k.r4 - k.r3 - 1), 'n/a')
                                                           AS [Categories],
    
        -- Serial = remainder after last comma
        NULLIF(SUBSTRING(r.rem, k.r4 + 1, 4000), 'n/a')   AS [Serial],
    
        -- Ingestion timestamp
        SYSUTCDATETIME()                                  AS updated_at
    FROM (
        -- Clean raw line (remove CR/LF)
        SELECT REPLACE(REPLACE([line], CHAR(13), ''), CHAR(10), '') AS l
        FROM stg_westpac_lines
    ) x
    CROSS APPLY (
        SELECT
            -- First two commas (Bank_Account, Date)
            CHARINDEX(',', x.l)                                              AS c1,
            CHARINDEX(',', x.l, CHARINDEX(',', x.l) + 1)                     AS c2,
    
            -- Quote positions for Narrative
            CHARINDEX('"', x.l, CHARINDEX(',', x.l, CHARINDEX(',', x.l) + 1) + 1) AS q1,
            CHARINDEX('"', x.l, CHARINDEX('"', x.l,
                CHARINDEX(',', x.l, CHARINDEX(',', x.l) + 1) + 1) + 1)       AS q2
    ) p
    CROSS APPLY (
        -- Remaining comma-separated fields after Narrative
        SELECT SUBSTRING(x.l, p.q2 + 2, 4000) AS rem
    ) r
    CROSS APPLY (
        SELECT
            -- Comma positions inside remainder
            CHARINDEX(',', r.rem)                                            AS r1,
            CHARINDEX(',', r.rem, CHARINDEX(',', r.rem) + 1)                 AS r2,
            CHARINDEX(',', r.rem, CHARINDEX(',', r.rem,
                CHARINDEX(',', r.rem) + 1) + 1)                              AS r3,
            CHARINDEX(',', r.rem, CHARINDEX(',', r.rem,
                CHARINDEX(',', r.rem,
                    CHARINDEX(',', r.rem) + 1) + 1) + 1)                    AS r4
    ) k
    WHERE
        -- Ignore blank or malformed lines
        x.l IS NOT NULL
        AND LTRIM(RTRIM(x.l)) <> ''
        AND p.q1 > 0 AND p.q2 > 0
        AND k.r1 > 0 AND k.r2 > 0 AND k.r3 > 0 AND k.r4 > 0;
END
GO

/* Example execution (upload file to the blob container first) */
-- EXEC load_westpac_from_blob @file = N'2025_01-08';
