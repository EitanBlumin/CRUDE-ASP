
CREATE VIEW [portal].[DataViewFlags]
AS
SELECT *
FROM (VALUES
 (1, 'Allow Edit', 'fas fa-edit', CONVERT(bit, 1))
,(POWER(2,1), 'Allow Add', 'fas fa-plus', CONVERT(bit, 1))
,(POWER(2,2), 'Allow Delete', 'fas fa-trash-alt', CONVERT(bit, 1))
,(POWER(2,3), 'Allow Clone', 'fas fa-clone', CONVERT(bit, 1))
,(POWER(2,4), 'Enable Form', 'fas fa-th-list', CONVERT(bit, 1))
,(POWER(2,5), 'Enable Items List', 'fas fa-table', CONVERT(bit, 1))
,(POWER(2,6), 'Enable Advanced Search', 'fas fa-search', CONVERT(bit, 1))
,(POWER(2,7), 'Enable Quick Search', 'fas fa-bolt', CONVERT(bit, 1))
,(POWER(2,8), 'Enable Columns Visibility Toggle', 'fas fa-eye-slash', CONVERT(bit, 1))
,(POWER(2,9), 'Enable Row Details', 'fas fa-align-left', CONVERT(bit, 1))
,(POWER(2,10), 'Enable Row Selection', 'fas fa-tasks', CONVERT(bit, 1))
,(POWER(2,11), 'Export to Clipboard', 'fas fa-paste', CONVERT(bit, 1))
,(POWER(2,12), 'Export to CSV', 'fas fa-file-csv', CONVERT(bit, 1))
,(POWER(2,13), 'Export to Excel', 'fas fa-file-excel', CONVERT(bit, 1))
,(POWER(2,14), 'Export to PDF', 'fas fa-file-pdf', CONVERT(bit, 1))
,(POWER(2,15), 'Export to Print', 'fas fa-print', CONVERT(bit, 1))
,(POWER(2,16), 'Fixed Table Headers', 'fas fa-thumbtack', CONVERT(bit, 0))
) AS V(FlagValue, FlagLabel, FlagGlyph, FlagDefault)
