CREATE VIEW [portal].[DataViewFieldTypes]
AS
SELECT *
FROM (VALUES
 (1, 'Text', '''')
,(2, 'Text Area', '''')
,(3, 'Integer', '')
,(4, 'Decimal', '')
,(5, 'Dropdown Box', '')
,(6, 'Multi-Selection Box', '''')
,(7, 'Date', '''')
,(8, 'Date and Time', '''')
,(9, 'Boolean', '')
,(10, 'Link', '''')
,(11, 'Image Source', '''')
,(12, 'Password', '''')
,(13, 'Time', '''')
,(14, 'Rich Text', '''')
,(15, 'E-Mail', '''')
,(16, 'Phone', '''')
) AS V(TypeValue, TypeLabel, TypeWrappers)
