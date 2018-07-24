CREATE FUNCTION [portal].[FormatValueForJson]
(@value nvarchar(max))
RETURNS nvarchar(max)
AS
BEGIN
	RETURN ISNULL(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@value, N'\', N'\\'), N'"', N'\"'), CHAR(10), N'\n'), CHAR(13), N'\r'), CHAR(9), N'\t'), N'')
END
