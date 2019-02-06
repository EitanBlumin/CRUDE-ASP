-- Since this function is recursive, it must first be created as a stub
-- and then it would be altered in post-deployment with actual content
ALTER FUNCTION [portal].[GetNavigationRecursive](@ParentNavId INT)
RETURNS NVARCHAR(MAX)
AS
BEGIN
DECLARE @Json NVARCHAR(MAX);
;WITH Nav AS 
(
	SELECT * FROM portal.Navigation
	WHERE NavParentId = @ParentNavId
	OR (@ParentNavId IS NULL AND NavParentId IS NULL) 
)
SELECT @Json =
(SELECT NavId, NavLabel, NavOrder, NavUri, NavGlyph, NavTooltip, ViewID
,OpenUriInIFRAME
,ChildItems = JSON_QUERY (portal.GetNavigationRecursive(NavId))
FROM Nav
WHERE NavParentId = @ParentNavId
OR (@ParentNavId IS NULL AND NavParentId IS NULL)
ORDER BY NavOrder ASC
FOR JSON AUTO)

SET @Json = ISNULL(@Json, N'[ ]')
RETURN @Json

END