CREATE VIEW portal.DataViewUriStyles
AS
SELECT *
FROM (VALUES
 (1, 'Hyperlink', '', 'fa fa-link', CONVERT(bit, 1))
,(2, 'Button Default', 'btn btn-default btn-sm', 'fa fa-square', CONVERT(bit, 0))
,(3, 'Button Primary', 'btn btn-primary btn-sm', 'fa fa-square', CONVERT(bit, 0))
,(4, 'Button Success', 'btn btn-success btn-sm', 'fa fa-square', CONVERT(bit, 0))
,(5, 'Button Info', 'btn btn-info btn-sm', 'fa fa-square', CONVERT(bit, 0))
,(6, 'Button Warning', 'btn btn-warning btn-sm', 'fa fa-square', CONVERT(bit, 0))
,(7, 'Button Danger', 'btn btn-danger btn-sm', 'fa fa-square', CONVERT(bit, 0))
) AS V(StyleValue, StyleLabel, StyleClass, StyleGlyph, StyleDefault)