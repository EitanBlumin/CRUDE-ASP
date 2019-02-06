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
		(1,N'Navigation',N'portal.Navigation',N'NavId',N'',N'',N'',N'<p>Add, update, or remove the portal''s navigation links.</p>',N'',63)
		) AS src([ViewID],[Title],[MainTable],[Primarykey],[ModificationProcedure],[ViewProcedure],[DeleteProcedure],[ViewDescription],[OrderBy],[Flags])
ON
	trgt.[ViewID] = src.[ViewID]
WHEN MATCHED THEN
	UPDATE SET
		[Title] = src.[Title]
		, [MainTable] = src.[MainTable]
		, [Primarykey] = src.[Primarykey]
		, [ModificationProcedure] = src.[ModificationProcedure]
		, [ViewProcedure] = src.[ViewProcedure]
		, [DeleteProcedure] = src.[DeleteProcedure]
		, [ViewDescription] = src.[ViewDescription]
		, [OrderBy] = src.[OrderBy]
		, [Flags] = src.[Flags]
WHEN NOT MATCHED BY TARGET THEN
	INSERT ([ViewID],[Title],[MainTable],[Primarykey],[ModificationProcedure],[ViewProcedure],[DeleteProcedure],[ViewDescription],[OrderBy],[Flags])
	VALUES ([ViewID],[Title],[MainTable],[Primarykey],[ModificationProcedure],[ViewProcedure],[DeleteProcedure],[ViewDescription],[OrderBy],[Flags])
WHEN NOT MATCHED BY SOURCE THEN
	DELETE
;
SET IDENTITY_INSERT [portal].[DataView] OFF;
GO

PRINT 'Populating portal.DataViewField...'

SET IDENTITY_INSERT [portal].[DataViewField] ON;
 
MERGE INTO [portal].[DataViewField] AS trgt
USING	(VALUES
		(1,1,N'Label',N'NavLabel',N'1',11,4,N'',600,N'',1,N'',N'',N'',N'',N'',NULL,NULL),
		(1,2,N'Parent Item',N'NavParentId',N'5',9,1,N'',4,N'',1,N'portal.Navigation',N'',N'NavLabel',N'NavId',N' UNION ALL SELECT ''-- Root --'',NULL',0,0),
		(1,3,N'Sort Order',N'NavOrder',N'3',11,2,N'',4,N'',1,N'',N'',N'',N'',N'',NULL,NULL),
		(1,4,N'Link URI',N'NavUri',N'1',1,6,N'',2000,N'',1,N'',N'',N'',N'',N'',NULL,NULL),
		(1,5,N'Glyph Icon',N'NavGlyph',N'1',1,3,N'',200,N'',1,N'',N'',N'',N'',N'',NULL,NULL),
		(1,6,N'Tooltip',N'NavTooltip',N'1',1,5,N'',600,N'',1,N'',N'',N'',N'',N'',NULL,NULL),
		(1,7,N'Data View',N'ViewID',N'5',1,8,N'',4,N'',1,N'portal.DataView',N'',N'Title',N'ViewId',N' UNION ALL SELECT ''-- None --'',NULL',0,0),
		(1,8,N'Open URI in IFRAME',N'OpenUriInIFRAME',N'9',11,7,N'false',5,N'',1,N'',N'',N'',N'',N'',NULL,NULL)
		) AS src([ViewID],[FieldID],[FieldLabel],[FieldSource],[FieldType],[FieldFlags],[FieldOrder],[DefaultValue],[MaxLength],[UriPath],[UriStyle],[LinkedTable],[LinkedTableGroupField],[LinkedTableTitleField],[LinkedTableValueField],[LinkedTableAddition],[Width],[Height])
ON
	trgt.[ViewID] = src.[ViewID]
AND trgt.[FieldID] = src.[FieldID]
WHEN MATCHED THEN
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
		, [LinkedTableGroupField] = src.[LinkedTableGroupField]
		, [LinkedTableTitleField] = src.[LinkedTableTitleField]
		, [LinkedTableValueField] = src.[LinkedTableValueField]
		, [LinkedTableAddition] = src.[LinkedTableAddition]
		, [Width] = src.[Width]
		, [Height] = src.[Height]
WHEN NOT MATCHED BY TARGET THEN
	INSERT ([ViewID],[FieldID],[FieldLabel],[FieldSource],[FieldType],[FieldFlags],[FieldOrder],[DefaultValue],[MaxLength],[UriPath],[UriStyle],[LinkedTable],[LinkedTableGroupField],[LinkedTableTitleField],[LinkedTableValueField],[LinkedTableAddition],[Width],[Height])
	VALUES ([ViewID],[FieldID],[FieldLabel],[FieldSource],[FieldType],[FieldFlags],[FieldOrder],[DefaultValue],[MaxLength],[UriPath],[UriStyle],[LinkedTable],[LinkedTableGroupField],[LinkedTableTitleField],[LinkedTableValueField],[LinkedTableAddition],[Width],[Height])
WHEN NOT MATCHED BY SOURCE THEN
	DELETE
;
SET IDENTITY_INSERT [portal].[DataViewField] OFF;
GO
:r .\RecursiveFunctions.PostDeployment.sql	
GO