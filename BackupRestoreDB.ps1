# Set current date and time for logging
$Tarih = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$BackupDir = "C:\Backups"
$LogDosyasi = "$BackupDir\backup_log.txt"

# SQLCMD commands
$SQLKomut = @"
BACKUP DATABASE AdventureWorks2022
TO DISK = '$BackupDir\DBYedek.bak'
WITH FORMAT,
     MEDIANAME = 'DBYedekMedya',
     NAME = 'DB Tam Yedek';

IF EXISTS (SELECT name FROM sys.databases WHERE name = 'DBYedek')
BEGIN
    ALTER DATABASE DBYedek SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DBYedek;
END;

RESTORE DATABASE DBYedek
FROM DISK = '$BackupDir\DBYedek.bak'
WITH
    MOVE 'AdventureWorks2022' TO '$BackupDir\DBYedek.mdf',
    MOVE 'AdventureWorks2022_log' TO '$BackupDir\DBYedek_log.ldf',
    REPLACE;
"@

# SQL Server instance name (adjust if needed)
$Instance = "localhost"

try {
    # Run the SQLCMD using PowerShell
    sqlcmd -S $Instance -Q $SQLKomut
    Add-Content -Path $LogDosyasi -Value "$Tarih - Backup and restore completed successfully."
}
catch {
    Add-Content -Path $LogDosyasi -Value "$Tarih - ERROR: $($_.Exception.Message)"
}
