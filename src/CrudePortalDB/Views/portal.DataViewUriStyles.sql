CREATE VIEW portal.DataViewUriStyles
AS
SELECT *
FROM (VALUES
 (1, 'Link', 'fas fa-link', CONVERT(bit, 1))
,(2, 'Button', 'fas fa-square', CONVERT(bit, 0))
) AS V(StyleValue, StyleLabel, StyleGlyph, StyleDefault)