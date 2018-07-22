
CREATE VIEW [portal].[DataViewFieldFlags]
AS
SELECT *
FROM (VALUES
 (1, 'Show in Form', 'fas fa-th-list', CONVERT(bit, 1))
,(2, 'Required', 'fas fa-asterisk', CONVERT(bit, 0))
,(4, 'Read Only', 'fas fa-glasses', CONVERT(bit, 0))
,(8, 'Show in Items List', 'fas fa-table', CONVERT(bit, 0))
,(16, 'Show in Search', 'fas fa-search', CONVERT(bit, 0))
) AS V(FlagValue, FlagLabel, FlagGlyph, FlagDefault)
