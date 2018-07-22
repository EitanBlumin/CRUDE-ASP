
CREATE VIEW [portal].[DataViewFieldFlags]
AS
SELECT *
FROM (VALUES
 (1, 'Show in Form', 'fa fa-th-list', CONVERT(bit, 1))
,(2, 'Required', 'fa fa-asterisk', CONVERT(bit, 0))
,(4, 'Read Only', 'fa fa-eye', CONVERT(bit, 0))
,(8, 'Show in Items List', 'fa fa-table', CONVERT(bit, 0))
,(16, 'Show in Search', 'fa fa-search', CONVERT(bit, 0))
) AS V(FlagValue, FlagLabel, FlagGlyph, FlagDefault)
