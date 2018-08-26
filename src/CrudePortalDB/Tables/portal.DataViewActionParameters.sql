CREATE TABLE [portal].[DataViewActionParameters]
(
	[ActionParameterId] INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_DataViewActionParameters PRIMARY KEY NONCLUSTERED,
	[ActionID] INT NOT NULL CONSTRAINT FK_DataViewActionParameters_DataViewAction FOREIGN KEY REFERENCES portal.DataViewAction (ActionID) ON DELETE CASCADE, 
    [ParamSystemName] NVARCHAR(50) NOT NULL, 
    [ParamLabel] NVARCHAR(100) NOT NULL, 
    [ParamOrder] INT NOT NULL DEFAULT 1, 
    [ParamIsRequired] BIT NOT NULL DEFAULT 1, 
    [ParamDefaultValue] NVARCHAR(1000) NULL, 
    [ParamTooltip] NVARCHAR(255) NULL, 
    [ParamDescription] NVARCHAR(1000) NULL, 
    [ParamDataType] INT NOT NULL, 
    [ParamLinkedTable] NVARCHAR(1000) NULL, 
    [ParamLinkedTableTitleField] NVARCHAR(200) NULL, 
    [ParamLinkedTableValueField] NVARCHAR(200) NULL, 
    [ParamLinkedTableGroupField] NVARCHAR(200) NULL, 
    [ParamLinkedTableAddition] NVARCHAR(1000) NULL
)
GO
CREATE CLUSTERED INDEX IX_DataViewActionParameters ON [portal].[DataViewActionParameters] (ActionID, ActionParameterID);
