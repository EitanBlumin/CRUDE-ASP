CREATE PROCEDURE [portal].[GetDataViewInfo]
	@ViewID INT = 1
AS
DECLARE @Json NVARCHAR(MAX)

SET @Json =
(
SELECT
[ViewID], [Title], [MainTable], [Primarykey], [ModificationProcedure], [ViewProcedure], [DeleteProcedure], [ViewDescription], [OrderBy]
, [Flags] = (SELECT * FROM portal.DataViewFlags AS s WHERE (dv.Flags & s.FlagValue) > 0 FOR JSON AUTO)
, [DataTableModifierButtonStyle] = (SELECT * FROM portal.DataViewModifierButtonStyles AS s WHERE dv.DataTableModifierButtonStyle = s.StyleValue FOR JSON AUTO)
, [DataTableFlags] = (SELECT * FROM portal.DataViewDataTableFlags AS s WHERE (dv.DataTableFlags & s.FlagValue) > 0 FOR JSON AUTO)
, [DataTableDefaultPageSize]
, [DataTablePagingStyle] = (SELECT * FROM portal.DataViewPagingTypes AS s WHERE dv.DataTablePagingStyle = s.StyleValue FOR JSON AUTO)
, DataViewFields = (
		SELECT [FieldID], [FieldLabel], [FieldSource]
		, [FieldType] = (SELECT * FROM portal.DataViewFieldTypes AS s WHERE dvf.FieldType = s.TypeValue FOR JSON AUTO)
		, [FieldFlags] = (SELECT * FROM portal.DataViewFieldFlags AS s WHERE (dvf.FieldFlags & s.FlagValue) > 0 FOR JSON AUTO)
		, [FieldOrder], [DefaultValue], [MaxLength], [UriPath], [UriStyle]
		, [LinkedTable], [LinkedTableGroupField], [LinkedTableTitleField], [LinkedTableValueField], [LinkedTableAddition]
		, [Width], [Height], [FieldDescription] 
		FROM portal.DataViewField AS dvf 
		WHERE dvf.ViewID = dv.ViewID 
		ORDER BY [FieldOrder] ASC
		FOR JSON AUTO)
, DataViewActions = (
		SELECT [ActionID], [ViewID], [ActionLabel]
		, [ParentActionID] -- TODO: Build recursively using CTE
		, [ActionTooltip], [ActionDescription], [ActionOrder], [RequireConfirmation]
		, [ActionUri], [UriTargetWindow], [NgClickJSCode], [GlyphIcon], [DatabaseCommand]
		, [IsPerRow]
		, DataViewActionParameters = (
				SELECT [ActionParameterId], [ParamSystemName], [ParamLabel], [ParamOrder]
				, [ParamIsRequired], [ParamDefaultValue], [ParamTooltip], [ParamDescription]
				, [ParamDataType] = (SELECT * FROM portal.DataViewFieldTypes AS s WHERE dvap.ParamDataType = s.TypeValue FOR JSON AUTO)
				, [ParamLinkedTable], [ParamLinkedTableTitleField], [ParamLinkedTableValueField], [ParamLinkedTableGroupField], [ParamLinkedTableAddition]
				FROM [portal].[DataViewActionParameters] AS dvap
				WHERE dvap.ActionID = dva.ActionID
				ORDER BY [ParamOrder] ASC
				FOR JSON AUTO)
		FROM [portal].[DataViewAction] AS dva
		WHERE dva.ViewID = dv.ViewID 
		ORDER BY [ActionOrder] ASC
		FOR JSON AUTO)
, DataViewCharts = (
		SELECT [ChartID]
		, [ChartType]
		, [ChartOrder], [ChartGridWidth]
		, [ChartProperties]
		, [XField], [YField], [ZField]
		FROM portal.DataViewChart AS dvc
		WHERE dvc.ViewID = dv.ViewID 
		ORDER BY ChartOrder ASC
		FOR JSON AUTO)
FROM portal.DataView AS dv
WHERE ViewID = @ViewID
FOR JSON AUTO
)

SELECT @Json AS [Json]
