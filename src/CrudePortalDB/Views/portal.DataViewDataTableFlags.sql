CREATE VIEW [portal].[DataViewDataTableFlags]
AS
SELECT *
FROM (VALUES
 (1, 'Show Info (e.g. showing x of y entries)', 'fas fa-info-circle', CONVERT(bit, 1))
,(2, 'Column Footers', 'fas fa-arrow-down', CONVERT(bit, 0))
,(4, 'Enable Quick-Search', 'fas fa-search', CONVERT(bit, 1))
,(8, 'Sortable Columns', 'fas fa-sort-amount-down', CONVERT(bit, 1))
,(16, 'Pagination', 'fas fa-ellipsis-h', CONVERT(bit, 1))
,(32, 'Page Length Selection', 'fas fa-ellipsis-v', CONVERT(bit, 1))
,(64, 'Client-Side State Save', 'far fa-save', CONVERT(bit, 0))
) AS V(FlagValue, FlagLabel, FlagGlyph, FlagDefault)
