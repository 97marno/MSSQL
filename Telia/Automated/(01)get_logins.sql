/* @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	CREATED: 2014-05-07
	CREATED BY: Marlen Norling @ TeliaSonera
	Version 1.0 
	Description: Script that get all users and Dbo in specific database(s). 
	USAGE: 
	(01) Change the ('symphony') to the correct databases you want the logins for.
			OBS!!! The Database name is case sensitive in versions older than 2008 R2.
	(02) Run the script. 
	(03) The script get all users and dbos of ALL database(s) in the instance. 
	(04) The script shows the users for the selected databases.
	(05) The script clean up after it self.
	@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ */

-- Create temporary table	
CREATE TABLE #tmplogins (LoginName nvarchar(max), DBname nvarchar(max), Username nvarchar(max), AliasName nvarchar(max))

-- Get all users and logins for all databases in the instance
INSERT INTO #tmplogins 
EXEC master..sp_msloginmappings

-- Display results, filtered on specific databases
SELECT * FROM   #tmplogins WHERE DBname in ('symphony')  /* <-- EDIT HERE!! *** SPECIFY DATABASES *** */
ORDER BY dbname, username



-- Cleanup
DROP TABLE #tmplogins