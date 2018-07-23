/*
Sample usage:
	EXEC usp_Generate_Merge_For_Table 'tbl_forms', 'dbo'
*/
CREATE PROCEDURE [dbo].[usp_Generate_Merge_For_Table]
	@CurrTable		SYSNAME,			-- table name
	@CurrSchema		SYSNAME	= 'dbo',	-- table schema name
	
	@delete_unmatched_rows	BIT = 1,	-- enable/disable DELETION of rows
	@update_existing_rows	BIT = 1,	-- enable/disable UPDATE of rows
	@insert_new_rows		BIT = 1,	-- enable/disable INSERT of rows
	@debug_mode				BIT = 0,	-- enable/disable debug mode
	@include_timestamp		BIT = 0,	-- include timestamp columns or not
	@ommit_computed_cols	BIT = 1,	-- ommit computed columns or not (in case target table doesn't have computed columns)
	@top_clause				NVARCHAR(4000)	= N'TOP 100 PERCENT' -- you can use this to limit number of generate rows (e.g. TOP 200)
AS

SET NOCOUNT ON;

-- Variable declaration
DECLARE
	@MergeStmnt		NVARCHAR(MAX),
	
	@CurrColumnId	INT,
	@CurrColumnName	SYSNAME,
	@CurrColumnType	VARCHAR(1000),
	@ColumnList		NVARCHAR(MAX),
	@UpdateSet		NVARCHAR(MAX),
	@PKJoinClause	NVARCHAR(MAX),
	@HasIdentity	BIT,
	@GetValues		NVARCHAR(MAX),
	@Values			NVARCHAR(MAX)

-- Init variables
SELECT
	@CurrColumnId	= NULL,
	@CurrColumnName = NULL,
	@CurrColumnType = NULL,
	@MergeStmnt		= NULL,
	@ColumnList		= NULL,
	@UpdateSet		= NULL,
	@PKJoinClause	= NULL,
	@GetValues		= NULL,
	@Values			= NULL,
	@HasIdentity	= 0

-- Make sure table exists
IF OBJECT_ID(QUOTENAME(@CurrSchema) + '.' + QUOTENAME(@CurrTable)) IS NULL
BEGIN
	RAISERROR(N'ERROR: Table [%s].[%s] not found.', 16, 1, @CurrSchema, @CurrTable) WITH NOWAIT;
	GOTO Quit;
END

-- find the table's Primary Key column(s) to build a JOIN clause
SELECT 
	@PKJoinClause = ISNULL(@PKJoinClause + N'
AND ',N'') + 'trgt.' + QUOTENAME(col.name) + N' = src.' + QUOTENAME(col.name)
FROM
	sys.indexes AS ind
INNER JOIN 
	sys.index_columns AS indcol
ON
	ind.object_id = indcol.object_id
AND ind.index_id = indcol.index_id
INNER JOIN
	sys.columns AS col
ON
	ind.object_id = col.object_id
AND indcol.column_id = col.column_id
WHERE 
	ind.is_primary_key = 1
AND ind.object_id = OBJECT_ID(QUOTENAME(@CurrSchema) + '.' + QUOTENAME(@CurrTable))

IF @debug_mode = 1
	PRINT 'PK Join Clause:
' + @PKJoinClause

-- If nothing found, abort (table is not supported)
IF @PKJoinClause IS NULL
BEGIN
	RAISERROR(N'ERROR: Table %s is not supported because it''s missing a Primary Key.', 16, 1, @CurrTable) WITH NOWAIT;
	GOTO Quit;
END

-- start with the first column
SELECT
	@CurrColumnId = MIN(ORDINAL_POSITION) 	
FROM
	INFORMATION_SCHEMA.COLUMNS (NOLOCK) 
WHERE
	TABLE_NAME = @CurrTable
AND TABLE_SCHEMA = @CurrSchema


-- loop through all the table columns, to get the column names and their data types
WHILE @CurrColumnId IS NOT NULL
BEGIN
	SELECT
		@CurrColumnName = QUOTENAME(COLUMN_NAME), 
		@CurrColumnType = DATA_TYPE 
	FROM
		INFORMATION_SCHEMA.COLUMNS (NOLOCK) 
	WHERE
		ORDINAL_POSITION = @CurrColumnId
	AND TABLE_NAME = @CurrTable
	AND TABLE_SCHEMA = @CurrSchema

	IF @debug_mode = 1
		PRINT 'Processing column ' + @CurrColumnName
	
	-- Choosing whether to output computed columns or not
	IF @ommit_computed_cols = 1
	BEGIN
		IF (SELECT COLUMNPROPERTY( OBJECT_ID(QUOTENAME(@CurrSchema) + '.' + @CurrTable),SUBSTRING(@CurrColumnName,2,LEN(@CurrColumnName) - 2),'IsComputed')) = 1 
		BEGIN
			GOTO SKIP_COLUMN					
		END
	END
	
	-- Concatenate column value selection to the values list
	SET @GetValues = ISNULL( @GetValues + ' + '',''' , '''(''' ) + ' + ' +
	CASE
		-- Format column value retrieval based on its data type
		WHEN @CurrColumnType IN ('text','char','varchar') 
			THEN 
				'COALESCE('''''''' + REPLACE(CONVERT(nvarchar(max),' + @CurrColumnName + '),'''''''','''''''''''')+'''''''',''NULL'')'					
		WHEN @CurrColumnType IN ('ntext','nchar','nvarchar','xml') 
			THEN  
				'COALESCE(''N'''''' + REPLACE(CONVERT(nvarchar(max),' + @CurrColumnName + '),'''''''','''''''''''')+'''''''',''NULL'')'					
		WHEN @CurrColumnType LIKE '%date%'
			THEN 
				'COALESCE('''''''' + RTRIM(CONVERT(varchar(max),' + @CurrColumnName + ',109))+'''''''',''NULL'')'
		WHEN @CurrColumnType IN ('uniqueidentifier') 
			THEN  
				'COALESCE('''''''' + REPLACE(CONVERT(varchar(255),RTRIM(' + @CurrColumnName + ')),'''''''','''''''''''')+'''''''',''NULL'')'
		WHEN @CurrColumnType IN ('binary','varbinary','image') 
			THEN  
				'COALESCE(RTRIM(CONVERT(nvarchar(max),' + @CurrColumnName + ',1)),''NULL'')'  
		WHEN @CurrColumnType IN ('timestamp','rowversion') 
			THEN  
				CASE 
					WHEN @include_timestamp = 0 
						THEN 
							'''DEFAULT''' 
						ELSE 
							'COALESCE(RTRIM(CONVERT(varchar(max),' + 'CONVERT(int,' + @CurrColumnName + '))),''NULL'')'  
				END
		WHEN @CurrColumnType IN ('float','real','money','smallmoney')
			THEN
				'COALESCE(LTRIM(RTRIM(' + 'CONVERT(varchar(max), ' +  @CurrColumnName  + ',2)' + ')),''NULL'')' 
		ELSE 
			'COALESCE(LTRIM(RTRIM(' + 'CONVERT(varchar(max), ' +  @CurrColumnName  + ')' + ')),''NULL'')' 
	END
	
	-- Concatenate column name to column list
	SET @ColumnList = ISNULL(@ColumnList + N',',N'') + @CurrColumnName
	
	-- Make sure to output SET IDENTITY_INSERT ON/OFF in case the table has an IDENTITY column
	IF (SELECT COLUMNPROPERTY( OBJECT_ID(QUOTENAME(@CurrSchema) + '.' + @CurrTable),SUBSTRING(@CurrColumnName,2,LEN(@CurrColumnName) - 2),'IsIdentity')) = 1 
	BEGIN
		SET @HasIdentity = 1		
	END
	ELSE
	BEGIN
		-- If column is not IDENTITY, concatenate it to UPDATE SET clause
		SET @UpdateSet = ISNULL(@UpdateSet + N'
		, ', N'') + @CurrColumnName + N' = src.' + @CurrColumnName
	END
	
	SKIP_COLUMN: -- The label used in GOTO to skip column

	-- Get next column in order
	SELECT
		@CurrColumnId = MIN(ORDINAL_POSITION) 
	FROM
		INFORMATION_SCHEMA.COLUMNS (NOLOCK) 
	WHERE 	
		ORDINAL_POSITION > @CurrColumnId
	AND TABLE_NAME = @CurrTable
	AND TABLE_SCHEMA = @CurrSchema


-- Column loop ends here
END

-- Finalize VALUES constructor
SET @GetValues = @GetValues + ' + '')'' ';

IF @debug_mode = 1
	PRINT 'Values Retrieval:
' + @GetValues + '

';

-- Using everything we found above, save all the table records as a values constructor (using dynamic SQL)
DECLARE @Params NVARCHAR(MAX)
DECLARE @CMD NVARCHAR(MAX);

SET @Params = N'@Result NVARCHAR(MAX) OUTPUT'
SET @CMD = 'SELECT ' + @top_clause + N'
	@Result = ISNULL(@Result + '',
		'','''') + ' + @GetValues + ' FROM ' + QUOTENAME(@CurrSchema) + '.' + QUOTENAME(@CurrTable)

IF @debug_mode = 1
	SELECT @CMD;

-- Execute command and get the @Values parameter as output
EXECUTE sp_executesql @CMD, @Params, @Values OUTPUT

-- If table returned no rows, then there's nothing to output other than deletion command
IF @@ROWCOUNT = 0 OR @Values IS NULL
BEGIN
	-- If deletion is enabled
	IF @delete_unmatched_rows = 1
		-- Generate a simple DELETE statement
		SET @MergeStmnt = N'DELETE FROM ' + QUOTENAME(@CurrSchema) + N'.' + QUOTENAME(@CurrTable)
	ELSE
		-- Otherwise, generate an empty script
		SET @MergeStmnt = N''
END
ELSE
-- Otherwise, build the MERGE statement
BEGIN
	
	-- Use IDENTITY_INSERT if table has an identity column
	IF @HasIdentity = 1
		SET @MergeStmnt = 'SET IDENTITY_INSERT ' + QUOTENAME(@CurrSchema) + '.' + QUOTENAME(@CurrTable) + ' ON;'
	ELSE
		SET @MergeStmnt = N''

	-- Build the MERGE statement using all the parts we found
	SET @MergeStmnt = @MergeStmnt + N'

MERGE INTO ' + QUOTENAME(@CurrSchema) + N'.' + QUOTENAME(@CurrTable) + N' AS trgt
USING	(VALUES
		' + @Values + N'
		) AS src(' + @ColumnList + N')
ON
	' + @PKJoinClause
+ CASE WHEN @update_existing_rows = 1 THEN N'
WHEN MATCHED THEN
	UPDATE SET
		' + @UpdateSet
	ELSE N'' END
+ CASE WHEN @insert_new_rows = 1 THEN N'
WHEN NOT MATCHED BY TARGET THEN
	INSERT (' + @ColumnList + N')
	VALUES (' + @ColumnList + N')'
	ELSE N'' END
+ CASE WHEN @delete_unmatched_rows = 1 THEN N'
WHEN NOT MATCHED BY SOURCE THEN
	DELETE'
	ELSE N'' END + N'
;
';
	
	-- Use IDENTITY_INSERT if table has an identity column
	IF @HasIdentity = 1
		SET @MergeStmnt = @MergeStmnt + 'SET IDENTITY_INSERT ' + QUOTENAME(@CurrSchema) + '.' + QUOTENAME(@CurrTable) + ' OFF;'

END

Quit:

-- Output the final statement

-- Print long text
DECLARE 
	@CurrStart int,
	@TotalLen int,
	@CurrID int,
	@CurrMsg nvarchar(max)

SELECT
	@CurrStart = 1,
	@TotalLen = LEN(@MergeStmnt);

WHILE @CurrStart < @TotalLen
BEGIN
	-- Find next linebreak
	SET @CurrID = CHARINDEX(CHAR(10),@MergeStmnt,@CurrStart)
	
	-- If linebreak found
	IF @CurrID > 0
	BEGIN
		-- Trim line from message, print it and increase index
		SET @CurrMsg = SUBSTRING(@MergeStmnt,@CurrStart,@CurrID-@CurrStart-1)
		PRINT @CurrMsg
		SET @CurrStart = @CurrID + 1
	END
	ELSE
	BEGIN
		-- Print last line
		SET @CurrMsg = SUBSTRING(@MergeStmnt,@CurrStart,@TotalLen)
		PRINT @CurrMsg
		SET @CurrStart = @TotalLen
	END
END

SELECT @MergeStmnt AS Command;