/*#########################
		Test migration
###########################
Daisy order: 
Database Role: Prod

Old DNS-alias: tholbox.db.han.telia.se
DNS-alias ODP 1.5: tholbox.db.teliasonera.net
==============================================================================================================================================================
*/


DECLARE @name VARCHAR(50) -- database name 
DECLARE @backupname VARCHAR(50) -- database backupname
DECLARE @path VARCHAR(256) -- path for backup files  
DECLARE @fileName VARCHAR(256) -- filename for backup
DECLARE @fileDate VARCHAR(20) -- used for file name
DECLARE @fileMigration VARCHAR(20) -- used for 

-- specify database backup directory
SET @path = 'E:\MSSQL10.SQL1\MSSQL\DATA2\macull\Tholbox\prod\'  -- EDIT HERE!! *** SPECIFY THE BACKUP DIRECTORY ***
SET @fileMigration = 'Prod_Testmigration' -- EDIT HERE!! *** SPECIFY THE MIGRATION METHOD ***

-- specify filename format
SELECT @fileDate = CONVERT(VARCHAR(20),GETDATE(),112) 
DECLARE db_cursor CURSOR FOR  
SELECT name 
FROM master.dbo.sysdatabases 
WHERE name IN ('Tholbox', 'Tholbox6')  -- EDIT HERE!! *** SPECIFY DATABASES ***

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
		FETCH NEXT FROM db_cursor INTO @name   
END   

CLOSE db_cursor   
DEALLOCATE db_cursor