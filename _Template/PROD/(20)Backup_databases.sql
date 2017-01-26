/* @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	Version 1.0 
	CREATED:	2014-04-28
	CREATED BY: Marlen Norling @ Real Time Services
				marlen.norling@rtsab.com
	USAGE:  	Specify the backup directory, where you want your backups
				Specify what kind of backup, prod or test migration.
	
	@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ */

DECLARE @name VARCHAR(50) -- database name 
DECLARE @backupname VARCHAR(50) -- database backupname
DECLARE @path VARCHAR(256) -- path for backup files  
DECLARE @fileName VARCHAR(256) -- filename for backup
DECLARE @fileDate VARCHAR(20) -- used for file name
DECLARE @fileMigration VARCHAR(20) -- used for 
DECLARE @rw VARCHAR(256) -- used to set DB offline

-- specify database backup directory
SET @path = 'F:\Backup\'  -- EDIT HERE!! *** SPECIFY THE BACKUP DIRECTORY ***
SET @fileMigration = 'Prod' -- EDIT HERE!! *** SPECIFY THE MIGRATION METHOD ***

-- specify filename format
SELECT @fileDate = CONVERT(VARCHAR(20),GETDATE(),112) 
DECLARE db_cursor CURSOR FOR  
SELECT name 
FROM master.dbo.sysdatabases 
WHERE dbid > 4

-- ================== DO NOT EDIT AFTER THIS LINE ===============================
OPEN db_cursor   
FETCH NEXT FROM db_cursor INTO @name   

WHILE @@FETCH_STATUS = 0   
BEGIN   
		SET @fileName = @path + @fileDate + '-' + @name + '-' + @fileMigration + '.bak'  
		SET @backupname = @name + '-Full Database Backup'
		
				BACKUP DATABASE @name TO  DISK = @filename WITH COPY_ONLY, NOFORMAT, NOINIT, NAME = @backupname , SKIP, NOREWIND, NOUNLOAD,  STATS = 10
					declare @backupSetId as int
					select @backupSetId = position from msdb..backupset where database_name= @name and backup_set_id=(select max(backup_set_id) from msdb..backupset where database_name= @name)
					if @backupSetId is null begin raiserror(N'Verify failed. Backup information for database ''@name'' not found.', 16, 1) end
				RESTORE VERIFYONLY FROM  DISK = @filename WITH  FILE = @backupSetId,  NOUNLOAD,  NOREWIND
				--SET @rw = N'ALTER DATABASE [' + @name + N'] SET OFFLINE WITH ROLLBACK IMMEDIATE'
				
		FETCH NEXT FROM db_cursor INTO @name   
		print(@rw)
END   

CLOSE db_cursor   
DEALLOCATE db_cursor