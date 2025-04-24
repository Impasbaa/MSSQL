SELECT * 
FROM Sales.SalesOrderHeader 
WHERE YEAR(OrderDate) = 2014

SELECT TOP 10 
    total_worker_time / execution_count AS Avg_CPU_Time,
    execution_count, 
    total_worker_time, 
    total_elapsed_time, 
    query_hash,
    SUBSTRING(st.text, 
        (qs.statement_start_offset/2)+1, 
        ((CASE qs.statement_end_offset 
            WHEN -1 THEN DATALENGTH(st.text) 
            ELSE qs.statement_end_offset END - qs.statement_start_offset)/2) + 1
    ) AS query_text
FROM sys.dm_exec_query_stats AS qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS st
ORDER BY Avg_CPU_Time DESC;

SELECT 
    OBJECT_NAME(i.object_id) AS TableName,
    i.name AS IndexName,
    i.index_id,
    dm_ius.user_seeks,
    dm_ius.user_scans,
    dm_ius.user_lookups,
    dm_ius.user_updates
FROM sys.indexes AS i
INNER JOIN sys.dm_db_index_usage_stats AS dm_ius 
    ON i.object_id = dm_ius.object_id 
    AND i.index_id = dm_ius.index_id
WHERE OBJECTPROPERTY(i.object_id, 'IsUserTable') = 1;

SELECT * 
FROM Sales.SalesOrderHeader 
WHERE OrderDate >= '2014-01-01' 
  AND OrderDate < '2015-01-01';

CREATE USER readonlyuser FOR LOGIN readonlylogin;
EXEC sp_addrolemember 'read_only_role', 'readonlyuser';

EXEC sp_spaceused;
