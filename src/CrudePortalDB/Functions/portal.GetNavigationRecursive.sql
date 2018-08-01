-- Since this function is recursive, it must first be created as a stub in Pre-Deployment
-- and then deployment would fail with error that it already exists
-- so just run deployment again
CREATE FUNCTION [portal].[GetNavigationRecursive](@ParentNavId INT)
RETURNS NVARCHAR(MAX)
AS
BEGIN
DECLARE
	@Json NVARCHAR(MAX)

;WITH Nav AS (SELECT TOP 100 PERCENT * FROM portal.Navigation ORDER BY NavOrder ASC)
SELECT @Json = ISNULL(@Json + N', ', N'[ ') + N' { "NavId": ' + CONVERT(nvarchar(max), NavId) + N',
"NavLabel": "' + portal.FormatValueForJson(NavLabel) + N'",
"NavOrder": ' + CONVERT(nvarchar(max), NavOrder) + N',
"NavUri": "' + ISNULL(portal.FormatValueForJson(NavUri), N'') + N'",
"NavGlyph": "' + portal.FormatValueForJson(NavGlyph) + N'",
"NavTooltip": "' + portal.FormatValueForJson(NavTooltip) + N'",
"ViewID": "' + portal.FormatValueForJson(CONVERT(nvarchar(max), ViewID)) + N'",
"ChildItems":' + ISNULL(portal.GetNavigationRecursive(ISNULL(NavId, -1)), N'[ ]') + N' }'
FROM Nav
WHERE NavParentId = @ParentNavId
OR (@ParentNavId IS NULL AND NavParentId IS NULL)

SET @Json = ISNULL(@Json, N'[ ') + N']'
RETURN @Json

END