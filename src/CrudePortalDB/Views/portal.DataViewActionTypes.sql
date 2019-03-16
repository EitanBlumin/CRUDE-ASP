CREATE VIEW [portal].[DataViewActionTypes]
AS
SELECT *
FROM (VALUES
 ('javascript', 'DataTable Javascript Function', CONVERT(bit, 1))
,('db_command', 'Database SQL Command', CONVERT(bit, 0))
,('db_procedure', 'Database SQL Stored Procedure', CONVERT(bit, 0))
,('url', 'HTTP Link', CONVERT(bit, 0))
) AS V(TypeValue, TypeLabel, TypeDefault)