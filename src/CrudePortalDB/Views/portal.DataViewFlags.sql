
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
,(POWER(2,6), 'Enable Charts', 'fas fa-chart-pie', CONVERT(bit, 0))
,(POWER(2,7), 'Enable Custom Actions', 'fas fa-bolt', CONVERT(bit, 0))
) AS V(FlagValue, FlagLabel, FlagGlyph, FlagDefault)
