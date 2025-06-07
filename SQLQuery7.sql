-- BACKUP THE DATABASE
BACKUP DATABASE AdventureWorks2022
TO DISK = 'C:\Backups\DBYedek.bak'
WITH FORMAT,
     MEDIANAME = 'DBYedekMedya',
     NAME = 'DB Tam Yedek';
GO

-- VIEW HEADER INFO FROM THE BACKUP FILE
RESTORE HEADERONLY
FROM DISK = 'C:\Backups\DBYedek.bak';
GO

-- DROP DATABASE IF EXISTS
IF EXISTS (SELECT name FROM sys.databases WHERE name = 'DBYedek')
BEGIN
    ALTER DATABASE DBYedek SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DBYedek;
END
GO

-- RESTORE THE DATABASE FROM BACKUP FILE
RESTORE DATABASE DBYedek
FROM DISK = 'C:\Backups\DBYedek.bak'
WITH
    MOVE 'AdventureWorks2022' TO 'C:\Backups\DBYedek.mdf',
    MOVE 'AdventureWorks2022_log' TO 'C:\Backups\DBYedek_log.ldf',
    REPLACE;
GO

RESTORE FILELISTONLY
FROM DISK = 'C:\Backups\DBYedek.bak';
GO

RESTORE FILELISTONLY FROM DISK = 'C:\Backups\DBYedek.bak';
