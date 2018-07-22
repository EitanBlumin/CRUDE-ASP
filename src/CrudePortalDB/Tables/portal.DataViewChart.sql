CREATE TABLE [portal].[DataViewChart] (
    [ViewID]          INT             NOT NULL,
    [ChartID]         INT             IDENTITY (1, 1) NOT NULL,
    [ChartType]       INT             NOT NULL,
    [ChartOrder]      INT             CONSTRAINT [DF_DataViewChart_ChartOrder] DEFAULT ((1)) NULL,
    [ChartGridWidth]  INT             CONSTRAINT [DF_Table_1_ChartWidth] DEFAULT ((12)) NOT NULL,
    [ChartProperties] NVARCHAR (4000) NULL,
    [XField]          NVARCHAR (300)  NULL,
    [YField]          NVARCHAR (300)  NULL,
    [ZField]          NVARCHAR (300)  NULL,
    CONSTRAINT [PK_DataViewChart] PRIMARY KEY CLUSTERED ([ViewID] ASC, [ChartID] ASC),
    CONSTRAINT [FK_DataViewChart_DataView] FOREIGN KEY ([ViewID]) REFERENCES [portal].[DataView] ([ViewID]) ON DELETE CASCADE
);

