
CREATE VIEW [portal].[DataViewFlags]
AS
SELECT *
FROM (VALUES
 (1, 'Allow Edit', 'fa fa-edit', CONVERT(bit, 1))
,(2, 'Allow Add', 'fa fa-plus-square-o', CONVERT(bit, 1))
,(4, 'Allow Delete', 'fa fa-trash-o', CONVERT(bit, 1))
,(8, 'Allow Clone', 'fa fa-clone', CONVERT(bit, 1))
,(16, 'Enable Form', 'fa fa-th-list', CONVERT(bit, 1))
,(32, 'Enable Items List', 'fa fa-table', CONVERT(bit, 1))
,(64, 'Enable Search', 'fa fa-search', CONVERT(bit, 0))
,(128, 'Enable RTE', 'fa fa-font', CONVERT(bit, 0))
,(256, 'Enable Charts', 'fa fa-pie-chart', CONVERT(bit, 0))
) AS V(FlagValue, FlagLabel, FlagGlyph, FlagDefault)
