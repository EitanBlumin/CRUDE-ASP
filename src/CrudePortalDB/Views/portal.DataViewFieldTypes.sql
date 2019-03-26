﻿CREATE VIEW [portal].[DataViewFieldTypes]
AS
SELECT *
FROM (VALUES
 (1, 'Text', '''', 'text', 'Text')
,(2, 'Text Area', '''', 'textarea', 'Text')
,(3, 'Integer', '', 'numeric', 'Numeric')
,(4, 'Decimal', '', 'numeric', 'Numeric')
,(5, 'Selection Dropdown Box', '', 'select', 'Single-Value Lookup')
,(6, 'Multi-Selection Dropdown Box', '''', 'csv', 'Multi-Value Lookup')
,(7, 'Date', '''', 'date', 'Date and Time')
,(8, 'Date and Time', '''', 'datetime', 'Date and Time')
,(9, 'Boolean Switch', '', 'boolean_switch', 'Boolean')
,(10, 'Link', '''', 'link', 'External Resource')
,(11, 'Image Source', '''', 'image', 'External Resource')
,(12, 'Password', '''', 'password', 'Text')
,(13, 'Time', '''', 'time', 'Date and Time')
,(14, 'Rich Text', '''', 'rte', 'Text')
,(15, 'E-Mail', '''', 'email', 'Text')
,(16, 'Phone', '''', 'phone', 'Text')
,(17, 'Multi-Selection Checkboxes', '''', 'csv_checkboxes', 'Multi-Value Lookup')
,(18, 'Multi-Selection Switches', '''', 'csv_switches', 'Multi-Value Lookup')
,(19, 'Multi-Selection Buttons', '''', 'csv_buttons', 'Multi-Value Lookup')
,(20, 'Selection Buttons', '', 'select_buttons', 'Single-Value Lookup')
,(21, 'Selection Switches', '', 'select_switches', 'Single-Value Lookup')
,(22, 'Boolean Checkbox', '', 'boolean_checkbox', 'Boolean')
,(23, 'Boolean Radios', '', 'boolean_radios', 'Boolean')
,(24, 'Computed Expression', '''', 'formula', 'Miscellaneous')
,(25, 'Document Download', '''', 'document', 'External Resource')
,(26, 'Boolean Button', '', 'boolean_button', 'Boolean')
,(27, 'Bitwise Checkboxes', '', 'bitwise_checkboxes', 'Bitwise')
,(28, 'Bitwise Switches', '', 'bitwise_switches', 'Bitwise')
,(29, 'Bitwise Buttons', '', 'bitwise_buttons', 'Bitwise')
) AS V(TypeValue, TypeLabel, TypeWrappers, TypeIdentifier, TypeGroup)
