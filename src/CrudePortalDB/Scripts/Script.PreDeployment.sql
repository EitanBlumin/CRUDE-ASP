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
IF OBJECT_ID('portal.GetNavigationRecursive') IS NULL
BEGIN
	PRINT 'Creating stub for portal.GetNavigationRecursive...'
	EXEC (N'CREATE FUNCTION [portal].[GetNavigationRecursive](@ParentNavId INT)
RETURNS NVARCHAR(MAX)
AS
BEGIN
	RETURN N''''
END');

END