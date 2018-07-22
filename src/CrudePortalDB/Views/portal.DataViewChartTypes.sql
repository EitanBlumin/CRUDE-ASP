CREATE VIEW portal.DataViewChartTypes
AS
SELECT *
FROM (VALUES
 (1, 'Line', 'line')
,(2, 'Area', 'area')
,(3, 'Donut', 'Donut')
,(4, 'Bar', 'Bar')
) AS V(TypeValue, TypeLabel, TypeCode)
