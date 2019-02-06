CREATE PROCEDURE [portal].[GetDataViewContentsCommand]
	@ViewID INT
AS
SET NOCOUNT ON;
DECLARE @DataSource NVARCHAR(100), @TableName NVARCHAR(300), @PK NVARCHAR(300), @Flags INT
DECLARE @CMD NVARCHAR(MAX)

SELECT @DataSource = DataSource, @TableName = MainTable, @PK = Primarykey, @Flags = Flags
FROM portal.DataView
WHERE ViewID = @ViewID

SET @CMD = N'SELECT [Json] = ISNULL((SELECT "_ItemID" = ' + @PK

SELECT @CMD = @CMD + N', "' + FieldLabel + N'" = ' + CASE WHEN FieldType = 12 THEN N'''''' WHEN LinkedTable <> '' AND LinkedTableValueField <> '' THEN N'CONVERT(nvarchar(max), ' + FieldSource + N')' ELSE FieldSource END
	+ CASE WHEN LinkedTable <> '' AND LinkedTableValueField <> '' THEN N',
	 "_resolved_' + FieldLabel + N'" = + STUFF((SELECT N'', '' + labelfield FROM
		(SELECT labelfield = ' + ISNULL(NULLIF(LinkedTableTitleField, N''), LinkedTableValueField) + N', valuefield = CONVERT(nvarchar(max), ' + LinkedTableValueField + N')
		 FROM ' + LinkedTable + N' ' + ISNULL(LinkedTableAddition,N'') + N') AS t
			WHERE (t.valuefield = ' + FieldSource + N') OR (t.valuefield IS NULL AND ' + FieldSource + N' IS NULL)
		 FOR XML PATH('''')
		 ), 1, 2, N'''')' ELSE N'' END
FROM portal.DataViewField
WHERE ViewID = @ViewID
ORDER BY FieldOrder ASC

SET @CMD = @CMD 
+ N' FROM ' + @TableName + N' FOR JSON AUTO), N''[ ]'')'

SELECT ISNULL(@DataSource, 'Default') AS DataSource, @CMD AS Command