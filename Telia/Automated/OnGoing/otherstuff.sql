/* @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	CREATED: 2014-04-28
	CREATED BY: Marlen Norling @ Teliasonera
	Version 1.0 
	
	USAGE:  	
	
	@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ */
	
DECLARE @dbname VARCHAR(50) -- database name 
DECLARE @alterathorization varchar(2000) -- variable for alter database to [SA]
DECLARE @alterDBchecksum varchar(2000) -- Set page verify checksum 
DECLARE @recoverymodel varchar(2000) -- Set recovery model
DECLARE @compatibilitylvl varchar(2000) -- Set compatibility level
--DECLARE @filegrowth varchar(2000) -- 
DECLARE @updatestats varchar(2000) -- 
DECLARE @updateusage varchar(2000) -- 
DECLARE @checkdb varchar(2000) -- 

DECLARE db_cursor CURSOR FOR  
SELECT name FROM master.dbo.sysdatabases WHERE name IN ('prisma_test', 'prisma')  -- EDIT HERE!! *** SPECIFY DATABASES ***

-- ================== DO NOT EDIT AFTER THIS LINE ===============================
OPEN db_cursor   
FETCH NEXT FROM db_cursor INTO @dbname   

WHILE @@FETCH_STATUS = 0   
BEGIN   
	SET @alterathorization=('ALTER AUTHORIZATION ON DATABASE::[' + @dbname + '] TO [SA]') 
	SET @alterDBchecksum=('ALTER DATABASE [' + @dbname + '] SET PAGE_VERIFY CHECKSUM  WITH NO_WAIT')
	SET @recoverymodel=('ALTER DATABASE [' + @dbname + '] SET RECOVERY FULL')
	SET @compatibilitylvl=('ALTER DATABASE [' + @dbname + '] SET COMPATIBILITY_LEVEL = 100')
	--SET @filegrowth=('ALTER DATABASE [' + @dbname + '] ')
	--SET @updatestats= 'USE [' + @dbname +']' + CHAR(13) + 'EXEC sp_updatestats' + CHAR(13) 
	SET @updateusage=('DBCC UPDATEUSAGE([' + @dbname + '])')
	SET @checkdb=('DBCC CHECKDB ([' + @dbname + '])')
	
	FETCH NEXT FROM db_cursor INTO @dbname
	
	print(@alterathorization)
	print(@alterDBchecksum)
	print(@recoverymodel)
	print(@compatibilitylvl)
	--print(@filegrowth)
	--print(@updatestats)
	print(@updateusage)
	print(@checkdb)

	
	/*EXEC(@alterathorization)
	EXEC (@alterDBchecksum)
	EXEC(@recoverymodel)
	EXEC(@compatibilitylvl)
		--print(@filegrowth)
		--EXEC(@updatestats)
	EXEC(@updateusage)
	EXEC(@checkdb)*/
END
CLOSE db_cursor   
DEALLOCATE db_cursor
	


/*SET @alterathorization = substring(@alterathorization,1,len(@alterathorization)-5)
print(@alterathorization)


--File growth and logical name
ALTER DATABASE [Datasynch] MODIFY FILE (NAME = N'Datasynch', FILEGROWTH = 512000KB, MAXSIZE = UNLIMITED)
GO
ALTER DATABASE [Datasynch] MODIFY FILE (NAME = N'Datasynch_log', FILEGROWTH = 256000KB, MAXSIZE = UNLIMITED)
GO

--Take ordinary full backup using Maintenance Solution	
use master
go
EXECUTE [dbo].[DatabaseBackup] @Databases = 'Datasynch', @Directory = N'\\MSSQLBCK5187\root', @BackupType = 'FULL', @Verify = 'Y', @CleanupTime = 673, @CheckSum = 'Y', @LogToTable = 'Y'*/