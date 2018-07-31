CREATE VIEW [portal].[DataViewDataTableFlags]
AS
SELECT *
FROM (VALUES
 (1, 'Show Info', 'an info bar indicating how many rows out of what total are currently being showed', 'fas fa-info-circle', CONVERT(bit, 1))
,(2, 'Column Footers', 'show column headers at the bottom of the table as well', 'fas fa-arrow-down', CONVERT(bit, 0))
,(4, 'Enable Quick-Search', 'allow quick free-text search on the table', 'fas fa-search', CONVERT(bit, 1))
,(8, 'Sortable Columns', 'columns can be dynamically sorted', 'fas fa-sort-amount-down', CONVERT(bit, 1))
,(16, 'Pagination', 'split rows into pages based on page size', 'fas fa-ellipsis-h', CONVERT(bit, 1))
,(32, 'Page Size Selection', 'allow users to select how many rows per page', 'fas fa-ellipsis-v', CONVERT(bit, 1))
,(64, 'Client-Side State Save', 'save a cookie in the client browser with the quick-search and paging info, which would be restored upon next visit to page', 'far fa-save', CONVERT(bit, 0))
) AS V(FlagValue, FlagLabel, FlagTooltip, FlagGlyph, FlagDefault)
