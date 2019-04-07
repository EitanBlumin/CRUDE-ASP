ALTER ROLE [db_datawriter] ADD MEMBER [CrudeLogin];

GO
ALTER ROLE [db_datareader] ADD MEMBER [CrudeLogin];

GO
GRANT VIEW SERVER STATE TO [CrudeLogin];

GO
GRANT EXECUTE TO [CrudeLogin];

GO