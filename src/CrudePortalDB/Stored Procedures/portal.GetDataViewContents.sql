CREATE PROCEDURE [portal].[GetDataViewContents]
	@ViewID INT
AS
SET NOCOUNT ON;
DECLARE @TableName NVARCHAR(300), @PK NVARCHAR(300), @Flags INT
DECLARE @CMD NVARCHAR(MAX)

SELECT @TableName = MainTable, @PK = Primarykey, @Flags = Flags
FROM portal.DataView
WHERE ViewID = @ViewID

SET @CMD = N'SELECT @Json = ISNULL(@Json + N'', '', N''[ '') + ISNULL(N''{ "_ItemID": "'' + portal.FormatValueForJson(CONVERT(nvarchar(100),' + @PK + N')) + N''"'

SELECT @CMD = @CMD + N', "' + FieldLabel + N'": "'' + portal.FormatValueForJson(' + FieldSource + N') + N''"'
FROM portal.DataViewField
WHERE ViewID = @ViewID
ORDER BY FieldOrder ASC

SET @CMD = @CMD + N', "_Actions": "'''
+ CASE WHEN @Flags & 1 > 0 THEN N'+ portal.FormatValueForJson(N''&nbsp;<a class="btn btn-primary btn-sm" role="button" href="dataview.asp?ViewID=' + CONVERT(nvarchar(max), @VIewID) + N'&mode=edit&ItemID='' + CONVERT(nvarchar(max), ' + @PK + N') + N''" title="Edit"><i class="fas fa-edit"></i></a>'')' ELSE N'' END
+ CASE WHEN @Flags & 8 > 0 THEN N'+ portal.FormatValueForJson(N''&nbsp;<a class="btn btn-primary btn-sm" role="button" href="dataview.asp?ViewID=' + CONVERT(nvarchar(max), @VIewID) + N'&mode=clone&ItemID='' + CONVERT(nvarchar(max), ' + @PK + N') + N''" title="Clone"><i class="far fa-clone"></i></a>'')' ELSE N'' END
+ CASE WHEN @Flags & 4 > 0 THEN N'+ portal.FormatValueForJson(N''&nbsp;<a class="btn btn-primary btn-sm" role="button" href="dataview.asp?ViewID=' + CONVERT(nvarchar(max), @VIewID) + N'&mode=delete&ItemID='' + CONVERT(nvarchar(max), ' + @PK + N') + N''" title="Delete"><i class="far fa-trash-alt"></i></a>'')' ELSE N'' END
+ N'+ N''" }'', N'''') FROM ' + @TableName

DECLARE @Json NVARCHAR(MAX)
PRINT @CMD

EXEC sp_executesql @CMD, N'@Json NVARCHAR(MAX) OUTPUT', @Json OUTPUT;

SELECT [Json] = ISNULL(@Json + N' ]', N'[ ]')
