CREATE TABLE [portal].[DataView] (
    [ViewID]                INT             IDENTITY (1, 1) NOT NULL,
    [Title]                 NVARCHAR (100)  NOT NULL,
    [DataSource]			NVARCHAR(200) NULL, 
    [MainTable]             NVARCHAR (300)  NULL,
    [Primarykey]            NVARCHAR (300)  NULL,
    [ModificationProcedure] NVARCHAR (300)  NULL,
    [ViewProcedure]         NVARCHAR (300)  NULL,
    [DeleteProcedure]       NVARCHAR (300)  NULL,
    [ViewDescription]       NVARCHAR (4000) NULL,
    [OrderBy]               NVARCHAR (300)  NULL,
    [Flags]                 INT             CONSTRAINT [DF_DataView_Flags] DEFAULT ((63)) NOT NULL,
    [DataTableModifierButtonStyle] SMALLINT NOT NULL DEFAULT 1, 
    [DataTableFlags] INT NOT NULL DEFAULT 61, 
    [DataTableDefaultPageSize] INT NOT NULL DEFAULT 25, 
    [DataTablePagingStyle] VARCHAR(20) NOT NULL DEFAULT 'full_numbers', 
    [Published] BIT NOT NULL DEFAULT (1), 
    [RowReorderColumn] NVARCHAR(200) NULL, 
    [IsSystemObject] BIT NOT NULL DEFAULT 0, 
    [CSSTable] NVARCHAR(100) NOT NULL DEFAULT 'table table-hover table-bordered table-striped', 
    CONSTRAINT [PK_DataView] PRIMARY KEY CLUSTERED ([ViewID] ASC)
);

