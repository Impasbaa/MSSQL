-- Distributor
EXEC sp_adddistributor @distributor = N'MAIN-SERVER';
-- Publisher
EXEC sp_addpublication @publication = N'OrnekYayin', @status = N'active';
-- Subscriber
EXEC sp_addsubscription 
    @publication = N'OrnekYayin',
    @subscriber = N'SUBE-SERVER',
    @destination_db = N'OrnekDB_Kopya',
    @subscription_type = N'Push';

SELECT SERVERPROPERTY('Edition');

CREATE AVAILABILITY GROUP [OrnekAG]
WITH (
    AUTOMATED_BACKUP_PREFERENCE = SECONDARY
)
FOR DATABASE [OrnekDB]
REPLICA ON 
    N'SERVERA' WITH (
        ENDPOINT_URL = 'TCP://SERVERA:5022',
        AVAILABILITY_MODE = SYNCHRONOUS_COMMIT,
        FAILOVER_MODE = AUTOMATIC,
        SECONDARY_ROLE (ALLOW_CONNECTIONS = READ_ONLY)
    ),
    N'SERVERB' WITH (
        ENDPOINT_URL = 'TCP://SERVERB:5022',
        AVAILABILITY_MODE = SYNCHRONOUS_COMMIT,
        FAILOVER_MODE = AUTOMATIC,
        SECONDARY_ROLE (ALLOW_CONNECTIONS = READ_ONLY)
    );

CREATE ENDPOINT [Mirroring]
STATE = STARTED
AS TCP (LISTENER_PORT = 5022)
FOR DATABASE_MIRRORING (
    ROLE = PARTNER
);
-- Veritabanı restore edilmesi (NORECOVERY ile)
-- Mirroring
ALTER DATABASE AdventureWorks2022
SET PARTNER = 'TCP://SERVERB:5022';
