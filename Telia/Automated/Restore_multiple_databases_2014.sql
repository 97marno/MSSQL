/* @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	CREATED: 2016-01-27
	CREATED BY: Marlen Norling @ RTS
	Version 1.0 
	
	USAGE:  	
	
	@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ */
	
DECLARE @dbname VARCHAR(50) -- database name 
DECLARE @alterathorization varchar(2000) -- variable for alter database to [SA]
DECLARE @alterDBchecksum varchar(2000) -- Set page verify checksum 
DECLARE @recoverymodel varchar(2000) -- Set recovery model
DECLARE @compatibilitylvl varchar(2000) -- Set compatibility level
DECLARE @updatestats varchar(2000) -- 
DECLARE @updateusage varchar(2000) -- 
DECLARE @checkdb varchar(2000) -- 

DECLARE db_cursor CURSOR FOR  
SELECT name FROM master.dbo.sysdatabases WHERE dbid > 4 

-- ================== DO NOT EDIT AFTER THIS LINE ===============================
OPEN db_cursor   
FETCH NEXT FROM db_cursor INTO @dbname   

WHILE @@FETCH_STATUS = 0   
BEGIN   

	SET @alterathorization=('ALTER AUTHORIZATION ON DATABASE::[' + @dbname + '] TO [SA]') 
	SET @alterDBchecksum=('ALTER DATABASE [' + @dbname + '] SET PAGE_VERIFY CHECKSUM  WITH NO_WAIT')
	SET @recoverymodel=('ALTER DATABASE [' + @dbname + '] SET RECOVERY FULL')
	SET @compatibilitylvl=('ALTER DATABASE [' + @dbname + '] SET COMPATIBILITY_LEVEL = 110')
	SET @checkdb=('DBCC CHECKDB ([' + @dbname + '])')
	SET @updateusage=('DBCC UPDATEUSAGE([' + @dbname + '])')
	SET @updatestats= 'USE [' + @dbname +']' + ';' + CHAR(13) + 'EXEC sp_updatestats' + ';' + CHAR(13) 
	
	FETCH NEXT FROM db_cursor INTO @dbname
	
	print(@alterathorization)
	print(@alterDBchecksum)
	print(@recoverymodel)
	print(@compatibilitylvl)
	print(@checkdb)
	print(@updateusage)
	print(@updatestats)
	
--	select name, physical_name from master.sys.master_files where database_id > 4
/*
	EXEC(@alterathorization)
	EXEC (@alterDBchecksum)
	EXEC(@recoverymodel)
	EXEC(@compatibilitylvl)
	EXEC(@checkdb)
	EXEC(@updateusage)
	print(@updatestats)
*/
 
END
CLOSE db_cursor   
DEALLOCATE db_cursor