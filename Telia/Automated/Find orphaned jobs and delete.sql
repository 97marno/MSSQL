/* @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	CREATED: 2014-05-07
	CREATED BY: Marlen Norling @ TeliaSonera
	Version 1.0 
	Description: Script that get all users and Dbo in specific database(s). 
	USAGE: 
	(01) 	Execute step 1 to find orphaned jobs.
	(02) 	The script get all jorphan jobs in ALL databases in the instance.
	(03) 	Execute step 2 to create delete statement(s) for all orphaned jobs.
	(04)	Run result from step 2 to delete orphaned jobs.
	
	TIP: run the result as text. 
	@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ */



-- 1) Show all orphaned jobs
SELECT sj.name
FROM
msdb..sysjobs sj WITH (READPAST)
LEFT JOIN sys.databases db WITH (NOLOCK)
ON sj.name LIKE '%' + db.name
WHERE db.name IS NULL
ORDER BY sj.name

/*
-- 2) Delete all orphaned jobs
SELECT
'EXEC msdb.dbo.sp_delete_job @job_id=''' + CAST(sj.job_id AS NVARCHAR(128))
+ ''', @delete_unused_schedule=1; – ' + sj.name + CHAR(13) + CHAR(10),
sj.name
FROM
msdb..sysjobs sj WITH (READPAST)
LEFT JOIN sys.databases db
ON sj.name LIKE '%' + db.name
WHERE db.name IS NULL
ORDER BY sj.name
*/