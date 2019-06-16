CREATE VIEW [portal].[DataViewDataTableFlags]
AS
SELECT *
FROM (VALUES
 (1, 'Show Info', 'an info bar indicating how many rows out of what total are currently being showed', 'fas fa-info-circle', CONVERT(bit, 1))
,(POWER(2,1), 'Column Footers', 'show column headers at the bottom of the table as well', 'fas fa-arrow-down', CONVERT(bit, 0))
,(POWER(2,2), 'Enable Quick-Search', 'allow quick free-text search on the table', 'fas fa-search', CONVERT(bit, 1))
,(POWER(2,3), 'Sortable Columns', 'columns can be dynamically sorted', 'fas fa-sort-amount-down', CONVERT(bit, 1))
,(POWER(2,4), 'Pagination', 'split rows into pages based on page size', 'fas fa-ellipsis-h', CONVERT(bit, 1))
,(POWER(2,5), 'Page Size Selection', 'allow users to select how many rows per page', 'fas fa-ellipsis-v', CONVERT(bit, 1))
,(POWER(2,6), 'Client-Side State Save', 'save a cookie in the client browser with the quick-search and paging info, which would be restored upon next visit to page', 'far fa-save', CONVERT(bit, 0))
,(POWER(2,7), 'Enable Advanced Search', 'allow advanced column-specific filters', 'fas fa-search', CONVERT(bit, 1))
,(POWER(2,8), 'Enable Columns Visibility Toggle', 'allow toggling columns to be hidden or visible in the table', 'fas fa-eye-slash', CONVERT(bit, 1))
,(POWER(2,9), 'Enable Row Details', 'allow expanding each table row to see the rest of the record details', 'fas fa-plus-circle', CONVERT(bit, 1))
,(POWER(2,10), 'Enable Row Selection', 'allows selection of multiple rows (for batch operations such as multiple delete)', 'fas fa-tasks', CONVERT(bit, 1))
,(POWER(2,11), 'Export to Clipboard', 'allow copying table contents to clipboard', 'fas fa-paste', CONVERT(bit, 1))
,(POWER(2,12), 'Export to CSV', 'allow exporting table contents to a CSV file', 'fas fa-file-alt', CONVERT(bit, 1))
,(POWER(2,13), 'Export to Excel', 'allow exporting table contents to an Excel file', 'fas fa-file-excel', CONVERT(bit, 1))
,(POWER(2,14), 'Export to PDF', 'allow exporting table contents to a PDF file', 'fas fa-file-pdf', CONVERT(bit, 1))
,(POWER(2,15), 'Export to Print', 'allow printing the table contents', 'fas fa-print', CONVERT(bit, 1))
,(POWER(2,16), 'Fixed Table Headers', 'makes the table headers fixed in their place while scrolling', 'fas fa-thumbtack', CONVERT(bit, 0))
) AS V(FlagValue, FlagLabel, FlagTooltip, FlagGlyph, FlagDefault)
