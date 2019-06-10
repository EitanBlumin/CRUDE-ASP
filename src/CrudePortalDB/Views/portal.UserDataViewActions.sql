CREATE VIEW [portal].[UserDataViewActions]
WITH SCHEMABINDING
AS
SELECT [ActionID], [ViewID], [ActionLabel], [ParentActionID], [ActionTooltip], [ActionDescription], [ActionOrder], [RequireConfirmation], [OpenURLInNewWindow], [ActionExpression], [GlyphIcon], [IsPerRow], [CSSButton], [ActionType], [DataViewTitle]
FROM [portal].[DataViewAction]
WHERE [ViewID] > 0
