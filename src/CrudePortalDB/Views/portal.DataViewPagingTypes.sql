CREATE VIEW [portal].[DataViewPagingTypes]
AS
SELECT *
FROM (VALUES
 ('full_numbers', 'First, Previous, Next and Last buttons, plus page numbers', CONVERT(bit, 1))
,('simple_numbers', 'Previous and Next buttons, plus page numbers', CONVERT(bit, 0))
,('simple', 'Previous and Next buttons only', CONVERT(bit, 0))
,('numbers', 'Page number buttons only', CONVERT(bit, 0))
,('full', 'First, Previous, Next and Last buttons', CONVERT(bit, 0))
,('first_last_numbers', 'First and Last buttons, plus page numbers', CONVERT(bit, 0))
) AS V(StyleValue, StyleLabel, StyleDefault)