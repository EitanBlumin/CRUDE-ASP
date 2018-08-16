-- Since this function is recursive, it must first be created as a stub
-- and then it would be altered in post-deployment with actual content
CREATE FUNCTION [portal].[GetNavigationRecursive](@ParentNavId INT)
RETURNS NVARCHAR(MAX)
AS
BEGIN

RETURN N'[ ]'

END