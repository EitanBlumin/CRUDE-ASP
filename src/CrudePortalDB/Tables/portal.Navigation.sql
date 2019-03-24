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

GO

CREATE TRIGGER [portal].[TR_Navigation_RecursiveStop]
    ON [portal].[Navigation]
    FOR INSERT, UPDATE
    AS
    BEGIN
        SET NoCount ON;
		DECLARE @RecursiveLoop BIT;
		SET @RecursiveLoop = 0;
		WITH cte
		AS
		(
			SELECT NavId AS StartID, NavParentId
			FROM inserted
			WHERE UPDATE(NavParentId) 
			AND NavParentId IS NOT NULL
			UNION ALL
			SELECT cte.StartID, n.NavParentId
			FROM portal.Navigation AS n
			INNER JOIN cte
			ON n.NavId = cte.NavParentId
			WHERE cte.StartID <> cte.NavParentId
		)
		SELECT @RecursiveLoop = 1 FROM cte WHERE StartID = NavParentId
		OPTION (MAXRECURSION 0);

		IF @RecursiveLoop = 1
		BEGIN
			ROLLBACK;
			RAISERROR(N'Recursive loop detected! Please select a different navigation parent.', 16, 1);
		END
    END