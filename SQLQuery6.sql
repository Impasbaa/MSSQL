CREATE LOGIN ogrenciLogin WITH PASSWORD = 'GucluParola123!';
CREATE USER ogrenciUser FOR LOGIN ogrenciLogin;
EXEC sp_addrolemember 'db_datareader', 'ogrenciUser';

EXEC sp_droprolemember 'db_datareader', 'ogrenciUser';

USE master;
GO
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'MasterKeySifresi123!';

CREATE CERTIFICATE TDESertifika
WITH SUBJECT = 'Veritabanı Şifreleme Sertifikası';

CREATE TABLE PersonelSifreli (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    AdSoyad NVARCHAR(100),
    SifreliTC VARBINARY(MAX)
);
GO
INSERT INTO PersonelSifreli (AdSoyad, SifreliTC)
VALUES 
('Ahmet Yılmaz', EncryptByPassPhrase('GizliAnahtar123', '12345678901')),
('Elif Kaya', EncryptByPassPhrase('GizliAnahtar123', '98765432100'));
GO
SELECT 
    AdSoyad,
    CONVERT(VARCHAR, DecryptByPassPhrase('GizliAnahtar123', SifreliTC)) AS CozulmusTC
FROM 
    PersonelSifreli;
GO

USE AdventureWorks2022;
GO
CREATE DATABASE ENCRYPTION KEY
WITH ALGORITHM = AES_256
ENCRYPTION BY SERVER CERTIFICATE TDESertifika; -- Desteklenmiyor (Not: TDE yalnızca Enterprise/Developer Edition’da çalışır.)

ALTER DATABASE AdventureWorks2022 SET ENCRYPTION ON;

DECLARE @sorgu NVARCHAR(MAX)
SET @sorgu = 'SELECT * FROM Users WHERE Username = ''' + @username + ''''
EXEC sp_executesql @sorgu

CREATE TABLE Users (
    UserID INT PRIMARY KEY IDENTITY(1,1),
    Username NVARCHAR(50),
    Password NVARCHAR(50),
    Role NVARCHAR(50)
);
GO
INSERT INTO Users (Username, Password, Role)
VALUES 
('admin', 'admin123', 'Admin'),
('perizat', 'p123456', 'User'),
('mehmet', 'mehmetpass', 'Manager');
GO

EXEC sp_executesql N'SELECT * FROM Users WHERE Username = @kullaniciAdi',
                   N'@kullaniciAdi NVARCHAR(50)',
                   @kullaniciAdi = 'admin';

USE master;
GO
CREATE SERVER AUDIT GUVENLIK_AUDIT
TO FILE (FILEPATH = 'C:\AuditLogs\');
ALTER SERVER AUDIT GUVENLIK_AUDIT WITH (STATE = ON);

USE AdventureWorks2022;
GO
CREATE DATABASE AUDIT SPECIFICATION GUVENLIK_DB_AUDIT
FOR SERVER AUDIT GUVENLIK_AUDIT
ADD (SELECT ON OBJECT::Users BY ogrenciUser),
ADD (INSERT ON OBJECT::Users BY ogrenciUser)
WITH (STATE = ON);