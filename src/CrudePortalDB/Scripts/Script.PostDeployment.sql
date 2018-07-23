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
		(1,1,N'NavLabel',N'NavLabel',N'1',11,1,N'',600,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
		(1,2,N'NavParentId',N'NavParentId',N'3',9,2,N'',4,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
		(1,3,N'NavOrder',N'NavOrder',N'3',11,3,N'',4,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
		(1,4,N'NavUri',N'NavUri',N'1',9,4,N'',2000,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
		(1,5,N'NavGlyph',N'NavGlyph',N'1',9,5,N'',200,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
		(1,6,N'NavTooltip',N'NavTooltip',N'1',9,6,N'',600,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
		(1,7,N'ViewID',N'ViewID',N'3',9,7,N'',4,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
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
