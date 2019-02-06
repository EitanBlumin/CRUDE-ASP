CREATE TABLE [portal].[Navigation]
(
	[NavId] INT NOT NULL CONSTRAINT PK_Navigation PRIMARY KEY IDENTITY(1,1), 
    [NavLabel] NVARCHAR(300) NOT NULL, 
    [NavParentId] INT NULL,
    [NavOrder] INT NOT NULL DEFAULT 1, 
    [NavUri] NVARCHAR(1000) NULL, 
    [NavGlyph] NVARCHAR(100) NULL, 
    [NavTooltip] NVARCHAR(300) NULL, 
    [ViewID] INT NULL, 
    [OpenUriInIFRAME] BIT NOT NULL DEFAULT 0
)
