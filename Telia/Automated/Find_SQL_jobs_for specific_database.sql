/* @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	CREATED: 2014-06-10
	CREATED BY: Thomas Roswall @ TeliaSonera
	Version 1.0 
	Description: Script that get all sql agent jobs in specific database. 
	USAGE: 
	(01) Change the ('%<dbname,,>%') to the correct databases you want the sql agent jobs for.
			OBS!!! The Database name is case sensitive in versions older than 2008 R2.
	(02) Run the script. 
	(03) The script get all sql agent jobs for a specific database in the instance. 
	@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ */



SELECT TOP 1000 db.database_id, 
db.name as 'databasename', 
j.name as 'jobname'
FROM sys.databases db with (nolock)
INNER JOIN msdb..sysjobsteps js with (nolock)
ON DB_NAME(db.database_id)=js.database_name
INNER JOIN msdb..sysjobs j with (nolock)
ON js.job_id = j.job_id
WHERE db.name LIKE '%<dbname,,>%'
OR j.name LIKE '%<dbname,,>%'
group by db.database_id, db.name, j.name