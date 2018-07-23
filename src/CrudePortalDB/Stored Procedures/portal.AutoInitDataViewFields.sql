CREATE PROCEDURE portal.AutoInitDataViewFields
	@ViewID INT
AS
SET NOCOUNT ON;
DECLARE @TableName NVARCHAR(300), @PK NVARCHAR(300)
SELECT @TableName = MainTable, @PK = Primarykey
FROM portal.DataView
WHERE ViewID = @ViewID

INSERT INTO portal.DataViewField
(ViewID, FieldLabel, FieldSource, FieldType, FieldFlags, FieldOrder, DefaultValue, MaxLength)
SELECT @ViewID, c.name, c.name,
	CASE WHEN t.name LIKE '%char' THEN 1
		WHEN t.name LIKE '%text' THEN 2
		WHEN t.name LIKE '%int' THEN 3
		WHEN t.name IN ('real', 'decimal', 'numeric', 'float', 'double') THEN 4
		WHEN t.name = 'date' THEN 7
		WHEN t.name LIKE '%datetime%' THEN 8
		WHEN t.name = 'bit' THEN 9
		WHEN t.name = 'time' THEN 13
		ELSE 1
	END AS fieldtype,
	9 + CASE WHEN c.is_nullable = 1 THEN 0 ELSE 2 END AS fieldflags,
	fieldorder = ROW_NUMBER() OVER (ORDER BY c.column_id ASC),
	'' AS fielddefault, c.max_length
FROM sys.columns c
INNER JOIN sys.types t
ON c.user_type_id = t.user_type_id
AND c.system_type_id = t.system_type_id
WHERE object_id = OBJECT_ID(@TableName)
AND c.name <> @PK
AND NOT EXISTS (SELECT * FROM portal.DataViewField AS existing WHERE existing.ViewID = @ViewID AND existing.FieldSource = c.name)