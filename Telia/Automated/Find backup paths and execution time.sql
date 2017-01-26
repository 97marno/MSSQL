/* 	@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	CREATED: 2014-06-10
	CREATED BY: Thomas Roswall @ TeliaSonera
	Version 1.0 
	Description: Script that get all backups paths and execution time for all databases. 
	USAGE: 
	(01) 	Execute step 1 to find backups paths and execution time for all databases.
	
	@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ */


-- 1) backup dirs (excluding sysdbs)
SELECT
	@@SERVERNAME AS [server_name]
,	s1.database_name
,	s1.[type] AS [backup_type]
,	MAX(s1.backup_start_date) AS [backup_start_date]
,	MAX(s1.backup_finish_date) AS [backup_end_date]
,	CONVERT(VARCHAR,((DATEDIFF(SECOND,MAX(s1.backup_start_date),MAX(s1.backup_finish_date)))/3600)) + ' hour(s), '
		+ CONVERT(VARCHAR,(DATEDIFF(SECOND,MAX(s1.backup_start_date),MAX(s1.backup_finish_date))%3600)/60) + ' min, '
		+ CONVERT(VARCHAR,(DATEDIFF(SECOND,MAX(s1.backup_start_date),MAX(s1.backup_finish_date))%60)) + ' sec' 
	AS [time_taken]
,	DATEDIFF(SECOND,MAX(s1.backup_start_date),MAX(s1.backup_finish_date))/60 AS [min_taken]
,	MAX(s2.physical_device_name) AS [backup_path]
FROM msdb..backupset s1 
	INNER JOIN msdb..backupmediafamily s2 ON s1.media_set_id = s2.media_set_id 
			AND s1.[type] IN ('D')
WHERE s1.database_name IN (SELECT name FROM sys.databases WHERE name NOT IN ('master','tempdb','model','msdb'))
GROUP BY s1.database_name, s1.[type]
ORDER BY MAX(s1.backup_start_date) DESC
