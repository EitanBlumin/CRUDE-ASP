CREATE TABLE [portal].[DataViewAction] (
    [ViewID]              INT             NOT NULL,
    [ActionID]            INT             NOT NULL,
    [ActionLabel]         NVARCHAR (100)  NOT NULL,
    [ActionTooltip]       NVARCHAR (300)  NULL,
    [ActionDescription]   NVARCHAR (1000) NULL,
    [ActionOrder]         INT             CONSTRAINT [DF_DataViewAction_ActionOrder] DEFAULT ((1)) NOT NULL,
    [RequireConfirmation] BIT             CONSTRAINT [DF_DataViewAction_RequireConfirmation] DEFAULT ((1)) NOT NULL,
    [ActionUri]           NVARCHAR (1000) NULL,
    [NgClick]             NVARCHAR (1000) NULL,
    CONSTRAINT [PK_DataViewAction] PRIMARY KEY CLUSTERED ([ViewID] ASC, [ActionID] ASC)
);

