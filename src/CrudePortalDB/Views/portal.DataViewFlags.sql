
CREATE VIEW [portal].[DataViewFlags]
AS
SELECT *
FROM (VALUES
 (1, 'Allow Edit', 'fas fa-edit', CONVERT(bit, 1))
,(2, 'Allow Add', 'fas fa-plus', CONVERT(bit, 1))
,(4, 'Allow Delete', 'fas fa-trash-alt', CONVERT(bit, 1))
,(8, 'Allow Clone', 'fas fa-clone', CONVERT(bit, 1))
,(16, 'Enable Form', 'fas fa-th-list', CONVERT(bit, 1))
,(32, 'Enable Items List', 'fas fa-table', CONVERT(bit, 1))
,(64, 'Enable Server-Side Search', 'fas fa-search', CONVERT(bit, 0))
,(128, 'Enable Rich Text Editor', 'fas fa-font', CONVERT(bit, 0))
,(256, 'Enable Charts', 'fas fa-chart-pie', CONVERT(bit, 0))
) AS V(FlagValue, FlagLabel, FlagGlyph, FlagDefault)
