CREATE PROCEDURE [portal].[GetDataViewContents]
	@ViewID INT
AS
SET NOCOUNT ON;
DECLARE @TableName NVARCHAR(300), @PK NVARCHAR(300)
DECLARE @CMD NVARCHAR(MAX)

SELECT @TableName = MainTable, @PK = Primarykey
FROM portal.DataView
WHERE ViewID = @ViewID

SET @CMD = N'ItemID = ' + @PK
SELECT @CMD = @CMD + N', ' + QUOTENAME(FieldLabel) + N' = ' + FieldSource
FROM portal.DataViewField
WHERE ViewID = @ViewID

SET @CMD = N'SELECT [Json] = ( SELECT ' + @CMD + CHAR(13) + CHAR(10) + N' FROM ' + @TableName + N' AS Result FOR JSON AUTO )'

EXEC (@CMD);
