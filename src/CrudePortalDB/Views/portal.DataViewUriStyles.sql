CREATE VIEW portal.DataViewUriStyles
AS
SELECT *
FROM (VALUES
 (1, 'Link', 'fa fa-link', CONVERT(bit, 1))
,(2, 'Button', 'fa fa-square', CONVERT(bit, 0))
) AS V(StyleValue, StyleLabel, StyleGlyph, StyleDefault)