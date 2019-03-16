CREATE TABLE [portal].[DataViewAction] (
    [ActionID]            INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_DataViewAction PRIMARY KEY NONCLUSTERED,
    [ViewID]              INT             NOT NULL CONSTRAINT FK_DataViewAction_DataView FOREIGN KEY REFERENCES portal.DataView (ViewID) ON DELETE CASCADE,
    [ActionLabel]         NVARCHAR (100)  NOT NULL,
    [ParentActionID]	  INT		      NULL, 
    [ActionTooltip]       NVARCHAR (300)  NULL,
    [ActionDescription]   NVARCHAR (1000) NULL,
    [ActionOrder]         INT             CONSTRAINT [DF_DataViewAction_ActionOrder] DEFAULT ((1)) NOT NULL,
    [RequireConfirmation] BIT             CONSTRAINT [DF_DataViewAction_RequireConfirmation] DEFAULT ((1)) NOT NULL,
    [OpenURLInNewWindow]	  BIT NULL DEFAULT 1,
    [ActionExpression]             NVARCHAR (MAX) NULL,
    [GlyphIcon] NVARCHAR(50) NULL, 
    [IsPerRow] BIT NOT NULL DEFAULT 0, 
    [CSSButton] NVARCHAR(50) NULL DEFAULT 'btn btn-primary btn-sm', 
    [ActionType] VARCHAR(20) NOT NULL DEFAULT 'javascript', 
    [DataViewTitle] AS [dbo].[GetDataViewLabel]([ViewID])
);
GO
CREATE CLUSTERED INDEX [IX_DataViewAction_ViewID_ActionID] ON [portal].[DataViewAction] ([ViewID] ASC, [ActionID] ASC)