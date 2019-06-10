/*
Post-Deployment Script Template							
--------------------------------------------------------------------------------------
 This file contains SQL statements that will be appended to the build script.		
 Use SQLCMD syntax to include a file in the post-deployment script.			
 Example:      :r .\myfile.sql								
 Use SQLCMD syntax to reference a variable in the post-deployment script.		
 Example:      :setvar TableName MyTable							
               SELECT * FROM [$(TableName)]					
--------------------------------------------------------------------------------------
*/

PRINT 'Populating portal.DataView...'

SET IDENTITY_INSERT [portal].[DataView] ON;
 
MERGE INTO [portal].[DataView] AS trgt
USING	(VALUES
		(-4,N'Navigation',N'CrudeDefault',N'portal.Navigation',N'NavId',N'',N'',N'',N'<p>Add, update, or remove the portal''s navigation links.</p>',N'',63,1,701,50,'full_numbers',1,N'NavOrder',1),
		(-3,N'Data View Actions',N'CrudeDefault',N'portal.DataViewAction',N'ActionID',N'',N'',N'',N'',N'',191,1,1213,50,'first_last_numbers',1,N'ActionOrder',1),
		(-2,N'Data View Fields',N'CrudeDefault',N'portal.DataViewField',N'FieldID',N'',N'',N'',N'',N'',191,1,9661,50,'first_last_numbers',1,N'FieldOrder',1),
		(-1,N'Manage Data Views',N'CrudeDefault',N'portal.DataView',N'ViewID',N'',N'',N'',N'',N'',191,5,21,50,'first_last_numbers',1,NULL,1)
		) AS src([ViewID],[Title],[DataSource],[MainTable],[Primarykey],[ModificationProcedure],[ViewProcedure],[DeleteProcedure],[ViewDescription],[OrderBy],[Flags],[DataTableModifierButtonStyle],[DataTableFlags],[DataTableDefaultPageSize],[DataTablePagingStyle],[Published],[RowReorderColumn],[IsSystemObject])
ON
	trgt.[ViewID] = src.[ViewID]
WHEN MATCHED AND src.[IsSystemObject] = 1 THEN
	UPDATE SET
		[Title] = src.[Title]
		, [DataSource] = src.[DataSource]
		, [MainTable] = src.[MainTable]
		, [Primarykey] = src.[Primarykey]
		, [ModificationProcedure] = src.[ModificationProcedure]
		, [ViewProcedure] = src.[ViewProcedure]
		, [DeleteProcedure] = src.[DeleteProcedure]
		, [ViewDescription] = src.[ViewDescription]
		, [OrderBy] = src.[OrderBy]
		, [Flags] = src.[Flags]
		, [DataTableModifierButtonStyle] = src.[DataTableModifierButtonStyle]
		, [DataTableFlags] = src.[DataTableFlags]
		, [DataTableDefaultPageSize] = src.[DataTableDefaultPageSize]
		, [DataTablePagingStyle] = src.[DataTablePagingStyle]
		, [Published] = src.[Published]
		, [RowReorderColumn] = src.[RowReorderColumn]
		, [IsSystemObject] = src.[IsSystemObject]
WHEN NOT MATCHED BY TARGET THEN
	INSERT ([ViewID],[Title],[DataSource],[MainTable],[Primarykey],[ModificationProcedure],[ViewProcedure],[DeleteProcedure],[ViewDescription],[OrderBy],[Flags],[DataTableModifierButtonStyle],[DataTableFlags],[DataTableDefaultPageSize],[DataTablePagingStyle],[Published],[RowReorderColumn],[IsSystemObject])
	VALUES ([ViewID],[Title],[DataSource],[MainTable],[Primarykey],[ModificationProcedure],[ViewProcedure],[DeleteProcedure],[ViewDescription],[OrderBy],[Flags],[DataTableModifierButtonStyle],[DataTableFlags],[DataTableDefaultPageSize],[DataTablePagingStyle],[Published],[RowReorderColumn],[IsSystemObject])
WHEN NOT MATCHED BY SOURCE AND [IsSystemObject] = 1 THEN
	DELETE
;
SET IDENTITY_INSERT [portal].[DataView] OFF;

GO

PRINT 'Populating portal.DataViewField...'

SET IDENTITY_INSERT [portal].[DataViewField] ON;
 
MERGE INTO [portal].[DataViewField] AS trgt
USING	(VALUES
		(-4,1,N'Label',N'NavLabel',N'1',27,4,N'',600,N'',1,N'',N'',N'',N'',N'',N'',N'',0,0,N'The textual label displayed to users',NULL,NULL,N'Field_1'),
		(-4,2,N'Parent Item',N'NavParentId',N'5',25,1,N'',4,N'',1,N'portal.Navigation',N'NavId',N'NavLabel',N'',N'',N'',N'',0,0,N'The parent navigation link',NULL,NULL,N'Field_2'),
		(-4,3,N'Sort Order',N'NavOrder',N'3',11,2,N'',4,N'',1,N'',N'',N'',N'',NULL,NULL,N'',NULL,NULL,N'Specifies the order in which the link will be displayed',NULL,NULL,N'Field_3'),
		(-4,4,N'Link URI',N'NavUri',N'1',1,6,N'',2000,N'',1,N'',N'',N'',N'',NULL,NULL,N'',NULL,NULL,N'Link Path (can use AngularJS placeholders)',NULL,NULL,N'Field_4'),
		(-4,5,N'Glyph Icon',N'NavGlyph',N'1',1,3,N'',200,N'',1,N'',N'',N'',N'',NULL,NULL,N'',NULL,NULL,N'Class string for Fontawesome icons',NULL,NULL,N'Field_5'),
		(-4,6,N'Tooltip',N'NavTooltip',N'1',1,5,N'',600,N'',1,N'',N'',N'',N'',NULL,NULL,N'',NULL,NULL,N'The tooltip that would be displayed upon mouse-over',NULL,NULL,N'Field_6'),
		(-4,7,N'Data View',N'ViewID',N'5',17,8,N'',4,N'',1,N'portal.DataView',N'ViewId',N'Title',N'',N'',N'',N'',0,0,N'Link to a specific DataView (link will be active when that dataview is opened)',NULL,NULL,N'Field_7'),
		(-4,8,N'Open URI in IFRAME',N'OpenUriInIFRAME',N'9',9,7,N'false',5,N'',1,N'',N'',N'',N'',N'',N'',N'',0,0,N'',NULL,NULL,N'Field_8'),
		(-3,9,N'Data View',N'ViewID',N'5',27,1,N'',4,N'',1,N'[portal].[DataView]',N'ViewID',N'Title',N'',N'',N'',N'',NULL,NULL,N'','',N'',N'dataview'),
		(-3,10,N'Action Label',N'ActionLabel',N'1',27,6,N'',100,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,N'Field_111'),
		(-3,11,N'Parent Action',N'ParentActionID',N'5',25,3,N'',4,N'',1,N'portal.DataViewAction',N'ActionID',N'ActionLabel',N'DataViewTitle',N'',N'',N'',0,0,N'',NULL,NULL,N'Field_112'),
		(-3,12,N'Action Tooltip',N'ActionTooltip',N'2',17,10,N'',300,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,N'Field_113'),
		(-3,13,N'Action Description',N'ActionDescription',N'2',17,11,N'',1000,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,10,NULL,NULL,NULL,N'Field_114'),
		(-3,14,N'Action Order',N'ActionOrder',N'3',11,4,N'',4,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,N'Field_115'),
		(-3,15,N'Require Confirmation',N'RequireConfirmation',N'9',1,8,N'',1,N'',1,N'',N'',N'',N'',NULL,NULL,N'',0,0,N'',NULL,NULL,N'Field_116'),
		(-3,16,N'Open URL In New Window',N'OpenURLInNewWindow',N'9',1,9,N'',1,N'',1,N'',N'',N'',N'',NULL,NULL,N'',0,0,N'',NULL,NULL,N'Field_117'),
		(-3,17,N'Action Expression',N'ActionExpression',N'2',17,7,N'',NULL,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,10,NULL,NULL,NULL,N'Field_118'),
		(-3,18,N'Glyph Icon',N'GlyphIcon',N'1',1,12,N'',50,N'',1,N'',N'',N'',N'',NULL,NULL,N'',0,0,N'',NULL,NULL,N'Field_119'),
		(-3,19,N'Is Per Row',N'IsPerRow',N'9',25,2,N'',1,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,N'Field_120'),
		(-3,20,N'CSS Button',N'CSSButton',N'1',1,13,N'btn btn-primary btn-sm',50,N'',1,N'',N'',N'',N'',N'',N'',N'',0,0,N'','',N'',N'Field_121'),
		(-3,21,N'Action Type',N'ActionType',N'5',27,5,N'url',20,N'',1,N'portal.DataViewActionTypes',N'TypeValue',N'TypeLabel',N'',N'',N'',N'',0,0,N'Choose the type of action behavior',NULL,NULL,N'Field_122'),
		(-3,22,N'Data View Title',N'DataViewTitle',N'1',5,14,N'',100,N'',1,N'',N'',N'',N'',N'',N'',N'',NULL,NULL,N'','',N'',N'Field_123'),
		(-2,23,N'Data View',N'ViewID',N'5',19,1,N'',4,N'dataview.asp?ViewId={{this}}',1,N'[portal].[DataView]',N'ViewID',N'Title',N'',N'',N'',N'',0,0,N'','',N'',N'dataview'),
		(-2,24,N'Label',N'FieldLabel',N'1',27,3,N'',300,N'',1,N'',N'',N'',N'',N'',N'',N'',0,0,N'The field label displayed to the user','',N'',N'Field_141'),
		(-2,25,N'Field Source',N'FieldSource',N'1',9,4,N'',300,N'',1,N'',N'',N'',N'',N'',N'',N'',0,0,N'The actual column name from the database',NULL,NULL,N'Field_142'),
		(-2,26,N'Field Type',N'FieldType',N'5',27,6,N'1',50,N'',1,N'portal.DataViewFieldTypes',N'TypeValue',N'TypeLabel',N'TypeGroup',N'',N'',N'',0,0,N'','',N'The data type for this field',N'Field_143'),
		(-2,27,N'Properties',N'FieldFlags',N'28',9,7,N'1',4,N'',1,N'portal.DataViewFieldFlags',N'FlagValue',N'FlagLabel',N'',N'FlagGlyph',N'',N'',0,0,N'',NULL,NULL,N'Field_144'),
		(-2,28,N'Field Order',N'FieldOrder',N'3',11,2,N'1',4,N'',1,N'',N'',N'',N'',N'',N'',N'',0,0,N'','',N'The display order of this field',N'Field_145'),
		(-2,29,N'Default Value',N'DefaultValue',N'1',1,9,N'',1000,N'',1,N'',N'',N'',N'',N'',N'',N'',0,0,N'The default value automatically filled out when adding a new item',NULL,NULL,N'Field_146'),
		(-2,30,N'Max Length',N'MaxLength',N'3',1,10,N'',4,N'',1,N'',N'',N'',N'',N'',N'',N'',0,0,N'Relevant to textual field types such as Text, Password, Email, Phone, etc.',NULL,NULL,N'Field_147'),
		(-2,31,N'Link URL',N'UriPath',N'1',1,11,N'',1000,N'',1,N'',N'',N'',N'',N'',N'',N'',0,0,N'Provide a URL expression to make the field clickable in the items list. You can use placeholders here.',NULL,NULL,N'Field_148'),
		(-2,32,N'Link Style',N'UriStyle',N'5',1,12,N'1',4,N'',1,N'portal.DataViewUriStyles',N'StyleValue',N'StyleLabel',N'',N'StyleGlyph',N'',N'',0,0,N'Choose how the link would look like, if URL Path was specified',NULL,NULL,N'Field_149'),
		(-2,33,N'Linked Table',N'LinkedTable',N'1',1,13,N'',300,N'',1,N'',N'',N'',N'',N'',N'',N'',0,0,N'Used for Lookup field types',NULL,NULL,N'Field_150'),
		(-2,34,N'Linked Table Value Field',N'LinkedTableValueField',N'1',1,14,N'',300,N'',1,N'',N'',N'',N'',N'',N'',N'',0,0,N'Used for Lookup field types',NULL,NULL,N'Field_151'),
		(-2,35,N'Linked Table Title Field',N'LinkedTableTitleField',N'1',1,15,N'',300,N'',1,N'',N'',N'',N'',N'',N'',N'',0,0,N'Used for Lookup field types',NULL,NULL,N'Field_152'),
		(-2,36,N'Linked Table Group Field',N'LinkedTableGroupField',N'1',1,16,N'',300,N'',1,N'',N'',N'',N'',N'',N'',N'',0,0,N'Used for Lookup field types',NULL,NULL,N'Field_153'),
		(-2,37,N'Linked Table Glyph Field',N'LinkedTableGlyphField',N'1',1,17,N'',300,N'',1,N'',N'',N'',N'',N'',N'',N'',0,0,N'',NULL,NULL,N'Field_154'),
		(-2,38,N'Linked Table Tooltip Field',N'LinkedTableTooltipField',N'1',1,18,N'',300,N'',1,N'',N'',N'',N'',N'',N'',N'',0,0,N'Used for Lookup field types',NULL,NULL,N'Field_155'),
		(-2,39,N'Linked Table Addition',N'LinkedTableAddition',N'2',1,19,N'',1000,N'',1,N'',N'',N'',N'',N'',N'',N'',0,5,N'Used for Lookup field types. Unrestricted SQL expression added after the table name.',NULL,NULL,N'Field_156'),
		(-2,40,N'Width',N'Width',N'3',1,20,N'',4,N'',1,N'',N'',N'',N'',N'',N'',N'',0,0,N'Horizontal width of the input field',NULL,NULL,N'Field_157'),
		(-2,41,N'Height',N'Height',N'3',1,21,N'',4,N'',1,N'',N'',N'',N'',N'',N'',N'',0,0,N'Vertical height of the input (for Text Area and Multi-Selection box)',NULL,NULL,N'Field_158'),
		(-2,42,N'Field Description',N'FieldDescription',N'14',1,22,N'',4000,N'',1,N'',N'',N'',N'',N'',N'',N'',100,30,N'A rich text formatted description to be used as the "help" text for the field','',NULL,N'Field_159'),
		(-2,43,N'Format Pattern',N'FormatPattern',N'1',1,23,N'',100,N'',1,N'',N'',N'',N'',N'',N'',N'',0,0,N'Used for enforcing a pattern in textual fields, using a regular expression',NULL,NULL,N'Field_160'),
		(-2,44,N'Field Tooltip',N'FieldTooltip',N'1',1,8,N'',NULL,N'',1,N'',N'',N'',N'',N'',N'',N'',NULL,NULL,N'','',NULL,N'Field_161'),
		(-2,45,N'Field Identifier',N'FieldIdentifier',N'1',3,5,N'',100,N'',1,N'',N'',N'',N'',N'',N'',N'',100,0,N'Write here a unique identifying name for the field, which can later be used in placeholders, URL parameters, and custom actions',NULL,NULL,N'Field_890337931'),
		(-1,46,N'Title',N'Title',N'1',27,1,N'',100,N'',1,N'',N'',N'',N'',N'',N'',N'',NULL,NULL,N'','',N'The title will be displayed at the top of the page',N'title'),
		(-1,47,N'Data Source',N'DataSource',N'1',19,4,N'CrudeDefault',200,N'',1,N'',N'',N'',N'',N'',N'',N'',NULL,NULL,N'','',N'Choose the connection string to use (from web.config)',N'datasource'),
		(-1,48,N'Main Table Name',N'MainTable',N'1',19,5,N'',300,N'',1,N'',N'',N'',N'',N'',N'',N'',NULL,NULL,N'','',N'This is the main database table from which data will be queried and modified (unless you specified replacement stored procedures)',N'maintable'),
		(-1,49,N'Primary Key',N'Primarykey',N'1',17,6,N'',300,N'',1,N'',N'',N'',N'',N'',N'',N'',NULL,NULL,N'','',N'Database column name which will serve as a primary key in the aforementioned table',N'primarykey'),
		(-1,50,N'Modification Procedure',N'ModificationProcedure',N'1',1,10,N'',300,N'',1,N'',N'',N'',N'',N'',N'',N'',NULL,NULL,N'','',N'Execute this stored procedure instead of modifying the main table directly',N'modificationproc'),
		(-1,51,N'Source Procedure',N'ViewProcedure',N'1',1,9,N'',300,N'',1,N'',N'',N'',N'',N'',N'',N'',NULL,NULL,N'','',N'Execute this stored procedure instead of querying directly from the main table',N'sourceproc'),
		(-1,52,N'Delete Procedure',N'DeleteProcedure',N'1',1,11,N'',300,N'',1,N'',N'',N'',N'',N'',N'',N'',NULL,NULL,N'','',N'Execute this stored procedure instead of deleting from the main table directly',N'deleteproc'),
		(-1,53,N'Description',N'ViewDescription',N'14',17,3,N'',4000,N'',1,N'',N'',N'',N'',N'',N'',N'',100,10,N'','',N'This rich text will be displayed below the dataview title, above the data table',N'description'),
		(-1,54,N'Order By',N'OrderBy',N'1',1,7,N'',300,N'',1,N'',N'',N'',N'',N'',N'',N'',NULL,NULL,N'','',N'Default sorting expression when querying from the database table',N'orderby'),
		(-1,55,N'Properties',N'Flags',N'28',9,12,N'63',4,N'',1,N'portal.DataViewFlags',N'FlagValue',N'FlagLabel',N'',N'FlagGlyph',N'FlagLabel',N'',NULL,NULL,N'','',N'',N'properties'),
		(-1,56,N'Data Table Row Buttons Styles',N'DataTableModifierButtonStyle',N'5',3,14,N'1',2,N'',1,N'portal.DataViewModifierButtonStyles',N'StyleValue',N'StyleLabel',N'',N'',N'StyleLabel',N'',NULL,NULL,N'','',N'Choose how the edit/clone/delete buttons would look like',N'rowbuttonstyle'),
		(-1,57,N'DataTable Options',N'DataTableFlags',N'28',9,13,N'65469',4,N'',1,N'portal.DataViewDataTableFlags',N'FlagValue',N'FlagLabel',N'',N'FlagGlyph',N'FlagTooltip',N'',NULL,NULL,N'','',N'',N'dt_options'),
		(-1,58,N'Data Table Default Page Size',N'DataTableDefaultPageSize',N'3',3,15,N'25',4,N'',1,N'',N'',N'',N'',N'',N'',N'',NULL,NULL,N'','',N'Choose the default number of rows per page',N'dt_defaultpagesize'),
		(-1,59,N'Data Table Paging Style',N'DataTablePagingStyle',N'5',3,16,N'first_last_numbers',20,N'',1,N'portal.DataViewPagingTypes',N'StyleValue',N'StyleLabel',N'',N'',N'StyleLabel',N'',NULL,NULL,N'','',N'Choose how the pagination buttons would look like',N'dt_pagingtype'),
		(-1,60,N'Published',N'Published',N'9',25,2,N'1',1,N'',1,N'',N'',N'',N'',N'',N'',N'',NULL,NULL,N'','',N'Sets whether this dataview is visible to end-users',N'published'),
		(-1,61,N'Row Reorder Column',N'RowReorderColumn',N'1',1,8,N'',200,N'',1,N'',N'',N'',N'',N'',N'',N'',NULL,NULL,N'','',N'If specified, this column will be used for sorting and re-ordering items in the data table',N'rowreordercol'),
		(-1,62,N'DataTable Style',N'CSSTable',N'1',3,17,N'table table-hover table-bordered table-striped',100,N'',1,N'',N'',N'',N'',N'',N'',N'',100,NULL,N'','',N'Choose the CSS class name',N'dt_style')
		) AS src([ViewID],[FieldID],[FieldLabel],[FieldSource],[FieldType],[FieldFlags],[FieldOrder],[DefaultValue],[MaxLength],[UriPath],[UriStyle],[LinkedTable],[LinkedTableValueField],[LinkedTableTitleField],[LinkedTableGroupField],[LinkedTableGlyphField],[LinkedTableTooltipField],[LinkedTableAddition],[Width],[Height],[FieldDescription],[FormatPattern],[FieldTooltip],[FieldIdentifier])
ON
	trgt.[ViewID] = src.[ViewID]
AND trgt.[FieldID] = src.[FieldID]
WHEN MATCHED AND src.[ViewID] < 0 THEN
	UPDATE SET
		[ViewID] = src.[ViewID]
		, [FieldLabel] = src.[FieldLabel]
		, [FieldSource] = src.[FieldSource]
		, [FieldType] = src.[FieldType]
		, [FieldFlags] = src.[FieldFlags]
		, [FieldOrder] = src.[FieldOrder]
		, [DefaultValue] = src.[DefaultValue]
		, [MaxLength] = src.[MaxLength]
		, [UriPath] = src.[UriPath]
		, [UriStyle] = src.[UriStyle]
		, [LinkedTable] = src.[LinkedTable]
		, [LinkedTableValueField] = src.[LinkedTableValueField]
		, [LinkedTableTitleField] = src.[LinkedTableTitleField]
		, [LinkedTableGroupField] = src.[LinkedTableGroupField]
		, [LinkedTableGlyphField] = src.[LinkedTableGlyphField]
		, [LinkedTableTooltipField] = src.[LinkedTableTooltipField]
		, [LinkedTableAddition] = src.[LinkedTableAddition]
		, [Width] = src.[Width]
		, [Height] = src.[Height]
		, [FieldDescription] = src.[FieldDescription]
		, [FormatPattern] = src.[FormatPattern]
		, [FieldTooltip] = src.[FieldTooltip]
		, [FieldIdentifier] = src.[FieldIdentifier]
WHEN NOT MATCHED BY TARGET THEN
	INSERT ([ViewID],[FieldID],[FieldLabel],[FieldSource],[FieldType],[FieldFlags],[FieldOrder],[DefaultValue],[MaxLength],[UriPath],[UriStyle],[LinkedTable],[LinkedTableValueField],[LinkedTableTitleField],[LinkedTableGroupField],[LinkedTableGlyphField],[LinkedTableTooltipField],[LinkedTableAddition],[Width],[Height],[FieldDescription],[FormatPattern],[FieldTooltip],[FieldIdentifier])
	VALUES ([ViewID],[FieldID],[FieldLabel],[FieldSource],[FieldType],[FieldFlags],[FieldOrder],[DefaultValue],[MaxLength],[UriPath],[UriStyle],[LinkedTable],[LinkedTableValueField],[LinkedTableTitleField],[LinkedTableGroupField],[LinkedTableGlyphField],[LinkedTableTooltipField],[LinkedTableAddition],[Width],[Height],[FieldDescription],[FormatPattern],[FieldTooltip],[FieldIdentifier])
WHEN NOT MATCHED BY SOURCE AND [ViewID] < 0 THEN
	DELETE
;
SET IDENTITY_INSERT [portal].[DataViewField] OFF;

GO

PRINT 'Populating portal.DataViewAction...'

SET IDENTITY_INSERT [portal].[DataViewAction] ON;
 
MERGE INTO [portal].[DataViewAction] AS trgt
USING	(VALUES
		(1,-4,N'Custom Action',NULL,N'This is a custom inline action button',N'',1,1,1,N'alert("You''ve activated a custom inline button. Check the console.")
console.log(tr)
console.log(r);',N'fa fa-magic',1,N'btn btn-info btn-sm','javascript'),
		(2,-4,N'Inspect Selected',NULL,N'',N'',2,0,1,N'var r = dt.rows({ selected: true }).data()
alert("Inspecting " + r.length + " rows (check the console)")
console.log(r);',N'fas fa-info-circle',0,N'btn btn-info btn-sm','javascript'),
		(3,-4,N'Custom Inline Action',NULL,N'This is a custom inline row action button',N'',2,1,1,N'alert("You''ve activated a custom inline button. Check the console.")
console.log(tr)
console.log(r);',N'fa fa-magic',1,N'btn btn-info btn-sm','javascript'),
		(4,-4,N'Inspect Selected Rows',NULL,N'',N'',1,0,1,N'var r = dt.rows({ selected: true }).data()
alert("Inspecting " + r.length + " rows (check the console)")
console.log(r);',N'fas fa-info-circle',0,N'btn btn-info btn-sm','javascript'),
		(5,-3,N'Open Data View',NULL,N'View this dataview live',N'',2,0,0,N'dataview.asp?ViewID={{urlparam[dataview[search]]}}',N'fas fa-eye',0,N'btn btn-primary btn-sm','url'),
		(6,-3,N'Data View Fields',NULL,N'Manage this dataview''s fields',N'',3,0,0,N'dataview.asp?ViewID=-2&dataview[search]={{urlparam[dataview[search]]}}',N'fas fa-bars',0,N'btn btn-primary btn-sm','url'),
		(7,-3,N'Manage Data Views',NULL,N'Return to Data View Management',N'',1,0,0,N'dataview.asp?ViewID=-1',N'fas fa-cogs',0,N'btn btn-primary btn-sm','url'),
		(8,-2,N'Open Data View',NULL,N'View this dataview live',N'',2,0,0,N'dataview.asp?ViewID={{urlparam[dataview[search]]}}',N'fas fa-eye',0,N'btn btn-primary btn-sm','url'),
		(9,-2,N'Data View Actions',NULL,N'Manage Custom Actions for this DataView',N'',3,0,0,N'dataview.asp?ViewID=-3&dataview[search]={{urlparam[dataview[search]]}}',N'fas fa-bolt',0,N'btn btn-primary btn-sm','url'),
		(10,-2,N'Manage Data Views',NULL,N'Return to Data View Management',N'',1,0,0,N'dataview.asp?ViewID=-1',N'fas fa-cogs',0,N'btn btn-primary btn-sm','url'),
		(14,-2,N'Auto-Init Fields',NULL,N'Use underlying DB schema to automatically create any missing fields',N'',4,1,1,N'ajax_dataview.asp?ViewID={{urlparam[dataview[search]]}}&mode=autoinit',N'fas fa-database',0,N'btn btn-primary btn-sm','url'),
		(11,-1,N'Open',NULL,N'Open Data View',N'',1,0,0,N'dataview.asp?ViewID={{row[DT_RowId]}}',N'fas fa-eye',1,N'btn btn-primary btn-sm','url'),
		(12,-1,N'Fields',NULL,N'Data View Fields',N'',2,0,0,N'dataview.asp?ViewID=-2&dataview[search]={{row[DT_RowId]}}',N'fas fa-bars',1,N'btn btn-primary btn-sm','url'),
		(13,-1,N'Actions',NULL,N'Data View Actions',N'',3,0,0,N'dataview.asp?ViewID=-3&dataview[search]={{row[DT_RowId]}}',N'fas fa-bolt',1,N'btn btn-primary btn-sm','url')
		) AS src([ActionID],[ViewID],[ActionLabel],[ParentActionID],[ActionTooltip],[ActionDescription],[ActionOrder],[RequireConfirmation],[OpenURLInNewWindow],[ActionExpression],[GlyphIcon],[IsPerRow],[CSSButton],[ActionType])
ON
	trgt.[ActionID] = src.[ActionID]
WHEN MATCHED AND src.[ViewID] < 0 THEN
	UPDATE SET
		[ViewID] = src.[ViewID]
		, [ActionLabel] = src.[ActionLabel]
		, [ParentActionID] = src.[ParentActionID]
		, [ActionTooltip] = src.[ActionTooltip]
		, [ActionDescription] = src.[ActionDescription]
		, [ActionOrder] = src.[ActionOrder]
		, [RequireConfirmation] = src.[RequireConfirmation]
		, [OpenURLInNewWindow] = src.[OpenURLInNewWindow]
		, [ActionExpression] = src.[ActionExpression]
		, [GlyphIcon] = src.[GlyphIcon]
		, [IsPerRow] = src.[IsPerRow]
		, [CSSButton] = src.[CSSButton]
		, [ActionType] = src.[ActionType]
WHEN NOT MATCHED BY TARGET THEN
	INSERT ([ActionID],[ViewID],[ActionLabel],[ParentActionID],[ActionTooltip],[ActionDescription],[ActionOrder],[RequireConfirmation],[OpenURLInNewWindow],[ActionExpression],[GlyphIcon],[IsPerRow],[CSSButton],[ActionType])
	VALUES ([ActionID],[ViewID],[ActionLabel],[ParentActionID],[ActionTooltip],[ActionDescription],[ActionOrder],[RequireConfirmation],[OpenURLInNewWindow],[ActionExpression],[GlyphIcon],[IsPerRow],[CSSButton],[ActionType])
WHEN NOT MATCHED BY SOURCE AND [ViewID] < 0 THEN
	DELETE
;
SET IDENTITY_INSERT [portal].[DataViewAction] OFF;

GO

IF NOT EXISTS (SELECT NULL FROM [portal].[Navigation])
BEGIN
	PRINT 'Populating portal.Navigation...'
	SET IDENTITY_INSERT [portal].[Navigation] ON;

	INSERT INTO [portal].[Navigation] ([NavId],[NavLabel],[NavParentId],[NavOrder],[NavUri],[NavGlyph],[NavTooltip],[ViewID],[OpenUriInIFRAME])
	VALUES 
	(1,N'Manage Data Views',NULL,1,N'',N'fas fa-cogs',N'Click here to start creating content',-1,0),
	(2,N'Manage Navigation',NULL,2,N'',N'fas fa-link',N'Click to manage this navigation menu',-4,0)

	SET IDENTITY_INSERT [portal].[Navigation] OFF;
END

GO
:r .\RecursiveFunctions.PostDeployment.sql	
GO