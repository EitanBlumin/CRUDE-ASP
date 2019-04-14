/*
 Pre-Deployment Script Template							
--------------------------------------------------------------------------------------
 This file contains SQL statements that will be executed before the build script.	
 Use SQLCMD syntax to include a file in the pre-deployment script.			
 Example:      :r .\myfile.sql								
 Use SQLCMD syntax to reference a variable in the pre-deployment script.		
 Example:      :setvar TableName MyTable							
               SELECT * FROM [$(TableName)]					
--------------------------------------------------------------------------------------
*/
IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('portal.DataViewField') AND name = 'FieldIdentifier')
	EXEC (N'UPDATE portal.DataViewField SET FieldIdentifier = ''Field_'' + CONVERT(nvarchar, FieldID) WHERE FieldIdentifier IS NULL');