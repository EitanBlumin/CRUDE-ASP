CREATE TABLE [portal].[DataViewAction] (
    [ActionID]            INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_DataViewAction PRIMARY KEY NONCLUSTERED,
    [ViewID]              INT             NOT NULL,
    [ActionLabel]         NVARCHAR (100)  NOT NULL,
    [ParentActionID]	  INT		      NULL, 
    [ActionTooltip]       NVARCHAR (300)  NULL,
    [ActionDescription]   NVARCHAR (1000) NULL,
    [ActionOrder]         INT             CONSTRAINT [DF_DataViewAction_ActionOrder] DEFAULT ((1)) NOT NULL,
    [RequireConfirmation] BIT             CONSTRAINT [DF_DataViewAction_RequireConfirmation] DEFAULT ((1)) NOT NULL,
    [ActionUri]           NVARCHAR (1000) NULL, 
    [UriTargetWindow]	  VARCHAR(25) NOT NULL DEFAULT '_blank',
    [NgClickJSCode]             NVARCHAR (1000) NULL,
    [GlyphIcon] NVARCHAR(50) NULL, 
    [DatabaseCommand] NVARCHAR(4000) NULL, 
    [IsPerRow] BIT NOT NULL DEFAULT 0 
);
GO
CREATE CLUSTERED INDEX [IX_DataViewAction_ViewID_ActionID] ON [portal].[DataViewAction] ([ViewID] ASC, [ActionID] ASC)