CREATE VIEW portal.DataViewModifierButtonStyles
AS
SELECT *
FROM (VALUES
 (1, 'Buttons - Icon and Text', 'btn btn-primary btn-sm', CONVERT(bit, 1), CONVERT(bit, 1), CONVERT(bit, 1))
,(2, 'Buttons - Icon Only', 'btn btn-primary btn-sm', CONVERT(bit, 0), CONVERT(bit, 1), CONVERT(bit, 0))
,(3, 'Buttons - Text Only', 'btn btn-primary btn-sm', CONVERT(bit, 1), CONVERT(bit, 0), CONVERT(bit, 0))
,(4, 'Hyperlink - Icon and Text', NULL, CONVERT(bit, 1), CONVERT(bit, 1), CONVERT(bit, 0))
,(5, 'Hyperlink - Icon Only', NULL, CONVERT(bit, 0), CONVERT(bit, 1), CONVERT(bit, 0))
,(6, 'Hyperlink - Text Only', NULL, CONVERT(bit, 1), CONVERT(bit, 0), CONVERT(bit, 0))
) AS V(StyleValue, StyleLabel, StyleClass, ShowText, ShowGlyph, StyleDefault)