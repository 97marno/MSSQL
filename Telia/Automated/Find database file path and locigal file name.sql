/* 	@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	CREATED: 2014-06-10
	CREATED BY: Thomas Roswall @ TeliaSonera
	Version 1.0 
	Description: Script that get all datafile paths and locigal names for all databases. 
	USAGE: 
	(01) 	Execute step 1 to find all datafile paths and locigal names for all databases.
	
	@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ */


-- 1) physical files
SELECT 
	DB_NAME(database_id) AS [database]
,	MAX(CASE WHEN [type] = 0 AND [file_id] = 1 THEN name END) AS [mdf]
,	MAX(CASE WHEN [type] = 0 AND [file_id] = 1 THEN physical_name END) AS [mdf_path]
,	MAX(CASE WHEN [type] = 0 AND [file_id] != 1 THEN name END) AS [ndf]
,	MAX(CASE WHEN [type] = 0 AND [file_id] != 1 THEN physical_name END) AS [ndf_path]
,	MAX(CASE WHEN [type] = 1 THEN name END) AS [ldf]
,	MAX(CASE WHEN [type] = 1 THEN physical_name END) AS [ldf_path]
FROM master.sys.master_files
GROUP BY database_id
