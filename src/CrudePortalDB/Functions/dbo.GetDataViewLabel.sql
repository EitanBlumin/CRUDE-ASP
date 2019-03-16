CREATE FUNCTION [dbo].[GetDataViewLabel]
(
	@ViewID int
)
RETURNS NVARCHAR(100)
AS
BEGIN
	DECLARE @Title NVARCHAR(100)

	SELECT @Title = Title
	FROM portal.DataView
	WHERE ViewID = @ViewID

	RETURN @Title
END
