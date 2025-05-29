BACKUP DATABASE AdventureWorks2022
TO DISK = 'C:\Belgeler(Yurt, Üniversite, ...)\University(Ankara)\TERM6\BLM4522\AdventureWorks2022.bak'
WITH FORMAT, INIT, NAME = 'Tam Yedekleme';

RESTORE DATABASE AdventureWorks2022
FROM DISK = 'C:\Belgeler(Yurt, Üniversite, ...)\University(Ankara)\TERM6\BLM4522\AdventureWorks2022.bak'
WITH NORECOVERY;
RESTORE LOG AdventureWorks2022
FROM DISK = 'veritabani_log.trn'
WITH STOPAT = '2025-05-29 10:15:00', RECOVERY;

RESTORE VERIFYONLY 
FROM DISK = 'C:\Belgeler(Yurt, Üniversite, ...)\University(Ankara)\TERM6\BLM4522\AdventureWorks2022.bak';

-- Principal sunucuda
ALTER DATABASE [AdventureWorks2022] 
SET PARTNER = 'TCP://MirrorServer:5022';
-- Mirror sunucuda
ALTER DATABASE [AdventureWorks2022] 
SET PARTNER = 'TCP://PrincipalServer:5022';

USE msdb;
GO
EXEC sp_add_job  
    @job_name = N'OrnekDB_TamYedekJob';  
GO
EXEC sp_add_jobstep  
    @job_name = N'OrnekDB_TamYedekJob',  
    @step_name = N'Tam Yedek Al',  
    @subsystem = N'TSQL',  
    @command = N'
        BACKUP DATABASE [OrnekDB]
        TO DISK = ''D:\Yedekler\OrnekDB_TamYedek.bak''
        WITH FORMAT, INIT, NAME = ''OrnekDB - Tam Yedek''
    ',
    @retry_attempts = 5,
    @retry_interval = 5;
GO
EXEC sp_add_schedule  
    @schedule_name = N'Her Gece 02:00',  
    @freq_type = 4,  -- günlük
    @freq_interval = 1,  
    @active_start_time = 020000;  
GO
EXEC sp_attach_schedule  
   @job_name = N'OrnekDB_TamYedekJob',  
   @schedule_name = N'Her Gece 02:00';  
GO
EXEC sp_add_jobserver  
    @job_name = N'OrnekDB_TamYedekJob';  
GO