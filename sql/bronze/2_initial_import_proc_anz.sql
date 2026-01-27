/* Load ANZ CSV from Blob Storage into bronze tables */
CREATE OR ALTER PROCEDURE load_anz_from_blob
    @file nvarchar(4000)  
AS
BEGIN
    SET NOCOUNT ON;

    ---------------------------------------------------------------------
    -- Step 1: BULK INSERT raw lines into stg_anz_lines
    ---------------------------------------------------------------------
    TRUNCATE TABLE stg_anz_lines;

    DECLARE @sql nvarchar(max) = N'
    BULK INSERT stg_anz_lines
    FROM ' + QUOTENAME(@file,'''') + N'
    WITH (
        DATA_SOURCE      = ''BudgetANZBlob'',
        FIRSTROW         = 1,          
        FIELDTERMINATOR  = ''0x1F'',   
        ROWTERMINATOR    = ''0x0A'',
        CODEPAGE         = ''65001''
    );';

    EXEC sys.sp_executesql @sql;

    ---------------------------------------------------------------------
    -- Step 2: Parse lines into anz and stamp updated_at
    ---------------------------------------------------------------------
    TRUNCATE TABLE anz;

	INSERT INTO anz
		([Date], [Amount], [Description], updated_at)
	SELECT
		-- Date: first token before first comma
    LEFT(l, CHARINDEX(',', l) - 1) AS [Date],

    -- Amount: first quoted value (between first pair of quotes)
    SUBSTRING(
			l,
			CHARINDEX('"', l) + 1,
			CHARINDEX('"', l, CHARINDEX('"', l) + 1) - (CHARINDEX('"', l) + 1)
		) AS [Amount],

    -- Description: everything after '",'
    LTRIM(SUBSTRING(l, CHARINDEX('",', l) + 2, 4000)) AS [Description],
		
    -- Ingestion timestamp (UTC is usually safer for pipelines
    SYSUTCDATETIME()   
	FROM (
		SELECT REPLACE(line, CHAR(13), '') AS l
		FROM stg_anz_lines
	) x
	WHERE x.l IS NOT NULL
	  AND LTRIM(RTRIM(x.l)) <> '';

END
GO

/* Example execution (upload file to the blob container first) */
-- EXEC load_anz_from_blob @file = N'2025_Sept.csv';
