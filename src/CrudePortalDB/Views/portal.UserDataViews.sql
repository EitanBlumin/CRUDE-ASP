CREATE VIEW [portal].[UserDataViews]
WITH SCHEMABINDING
AS
SELECT [ViewID], [Title], [DataSource], [MainTable], [Primarykey], [ModificationProcedure], [ViewProcedure], [DeleteProcedure], [ViewDescription], [OrderBy], [Flags], [DataTableModifierButtonStyle], [DataTableFlags], [DataTableDefaultPageSize], [DataTablePagingStyle], [Published], [RowReorderColumn], [IsSystemObject], [CSSTable]
FROM [portal].[DataView]
WHERE [ViewID] > 0
