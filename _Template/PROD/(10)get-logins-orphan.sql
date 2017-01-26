/* @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	CREATED: 2014-05-07
	CREATED BY: Marlen Norling @ TeliaSonera
	Version 1.0 
	Description: Script that get all users and Dbo in specific database(s). 
	USAGE: 
	(01)	Specify databases on linte 24.
	(02) 	The script get all users and dbos of ALL databases in the instance and 
			checks for orphan logins in ALL databases in the instance.
	(03) 	The script prints out logins for specified databases
	(04)	The scripts check the specified databases for orphan accounts.
	
	TIP: run the result as text. 
	@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ */

-- Create temporary table	
CREATE TABLE #tmplogins (LoginName nvarchar(128), DBname nvarchar(64), Username nvarchar(128), AliasName nvarchar(64))

-- Get all users and logins for all databases in the instance
INSERT INTO #tmplogins 
EXEC master..sp_msloginmappings

-- Display results, filtered on specific databases
SELECT DBname, username FROM #tmplogins WHERE DBname NOT IN ('master', 'model', 'msdb', 'tempdb')  /* <-- Specify databases here*/
ORDER BY dbname, username

--Check orpghans in ALL databases
EXEC sp_msforeachdb 'use [?]; Select ''?''; EXEC sp_change_users_login ''report'';' /* <-- This line lists orphans in ALL databases */

-- Cleanup
DROP TABLE #tmplogins

--SELECT * FROM sys.database_principals where (type='S' or type = 'U')