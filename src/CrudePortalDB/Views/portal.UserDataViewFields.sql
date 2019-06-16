CREATE VIEW [portal].[UserDataViewFields]
WITH SCHEMABINDING
AS
SELECT [ViewID], [FieldID], [FieldLabel], [FieldSource], [FieldType], [FieldFlags], [FieldOrder], [DefaultValue], [MaxLength], [UriPath], [UriStyle], [LinkedTable], [LinkedTableValueField], [LinkedTableTitleField], [LinkedTableGroupField], [LinkedTableGlyphField], [LinkedTableTooltipField], [LinkedTableAddition], [Width], [Height], [FieldDescription], [FormatPattern], [FieldTooltip], [FieldIdentifier]
FROM [portal].[DataViewField] WHERE [ViewID] > 0
