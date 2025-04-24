SELECT name, compatibility_level
FROM sys.databases
WHERE name = 'AdventureWorks2022';

BACKUP DATABASE AdventureWorks2022
TO DISK = 'C:\Belgeler(Yurt, Üniversite, ...)\University(Ankara)\TERM6\BLM4522\AdventureWorks2022.bak'
WITH FORMAT, MEDIANAME = 'AdventureWorksBackup', NAME = 'Full Backup';

USE master;
GO
ALTER DATABASE AdventureWorks2022 SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO
RESTORE DATABASE AdventureWorks2022
FROM DISK = 'C:\Belgeler(Yurt, Üniversite, ...)\University(Ankara)\TERM6\BLM4522\AdventureWorks2022.bak'
WITH 
    MOVE 'AdventureWorks2022' TO 'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\AdventureWorks2022.mdf',
    MOVE 'AdventureWorks2022_log' TO 'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\AdventureWorks2022_log.ldf',
    REPLACE;
GO
ALTER DATABASE AdventureWorks2022 SET MULTI_USER;
GO

RESTORE FILELISTONLY
FROM DISK = 'C:\Belgeler(Yurt, Üniversite, ...)\University(Ankara)\TERM6\BLM4522\AdventureWorks2022.bak';

ALTER DATABASE AdventureWorks2022 
SET COMPATIBILITY_LEVEL = 160;

CREATE TABLE AuditSchemaChanges (
    EventTime DATETIME,
    LoginName NVARCHAR(100),
    EventType NVARCHAR(100),
    ObjectName NVARCHAR(100),
    CommandText NVARCHAR(MAX)
);
GO
CREATE TRIGGER trg_SchemaAudit
ON DATABASE
FOR DDL_DATABASE_LEVEL_EVENTS
AS
BEGIN
    INSERT INTO AuditSchemaChanges
    SELECT 
        GETDATE(),
        SYSTEM_USER,
        EVENTDATA().value('(/EVENT_INSTANCE/EventType)[1]', 'NVARCHAR(100)'),
        EVENTDATA().value('(/EVENT_INSTANCE/ObjectName)[1]', 'NVARCHAR(100)'),
        EVENTDATA().value('(/EVENT_INSTANCE/TSQLCommand/CommandText)[1]', 'NVARCHAR(MAX)');
END;

ALTER TABLE Person.ContactType ADD Description NVARCHAR(100);

SELECT TOP 10 * FROM Person.ContactType;

RESTORE DATABASE AdventureWorks2022
FROM DISK = 'C:\Belgeler(Yurt, Üniversite, ...)\University(Ankara)\TERM6\BLM4522\AdventureWorks2022.bak' WITH REPLACE;
