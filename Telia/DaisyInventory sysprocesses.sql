
--Create database DaisyInventory
--Create table sysprocesses
--Add job Daisy-SysProcessSelect, scheduled to run every minute

/*
EXEC msdb.dbo.sp_update_job @job_name=N'Daisy-SysProcessSelect', @enabled = 0 -- 1) enabled, 0)disabled
EXEC msdb.dbo.sp_delete_job @job_name=N'Daisy-SysProcessSelect'

USE [DaisyInventory]
GO

-- List data file(s)
--EXEC sp_helpfile
--EXEC sp_helpfile 'DaisyInventory'

-- List logged sessions
--SELECT DISTINCT spid, nt_domain, nt_username, loginame, login_time, last_batch, DatabaseName, status, hostname, program_name, cmd FROM [DaisyInventory].[dbo].[DaisySysProcesses]
SELECT * FROM [DaisyInventory].[dbo].[DaisySysProcesses]

-- List user databases never accessed
SELECT name AS 'NotAccessedDB' FROM [master].[dbo].[sysdatabases]
WHERE dbid > 4 AND name != 'DaisyInventory' AND name NOT IN (SELECT DISTINCT DatabaseName FROM [DaisyInventory].[dbo].[DaisySysProcesses])
ORDER BY 1

-- List number of rows
SELECT COUNT(*) AS '# of rows' FROM [DaisyInventory].[dbo].[DaisySysProcesses]

-- List time of oldest and latest select
SELECT MIN(TimeOfSelect) AS 'Start of Range', MAX(TimeOfSelect) AS 'End of Range' FROM [DaisyInventory].[dbo].[DaisySysProcesses]

-- Truncate table
TRUNCATE TABLE [DaisySysProcesses]
GO


-- List sessions to specified database(s)
SELECT DISTINCT spid, nt_domain, nt_username, loginame, login_time, last_batch, DatabaseName, status, hostname, program_name, cmd FROM [DaisyInventory].[dbo].[DaisySysProcesses]
WHERE DatabaseName = ''

*/

USE [master]
GO

CREATE DATABASE [DaisyInventory]
GO
ALTER DATABASE [DaisyInventory] MODIFY FILE (NAME = 'DaisyInventory', SIZE = 20480KB , FILEGROWTH = 102400KB)
GO
ALTER DATABASE [DaisyInventory] MODIFY FILE (NAME = 'DaisyInventory_log', SIZE = 20480KB , FILEGROWTH = 102400KB)
GO
ALTER DATABASE [DaisyInventory] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [DaisyInventory] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [DaisyInventory] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [DaisyInventory] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [DaisyInventory] SET ARITHABORT OFF 
GO
ALTER DATABASE [DaisyInventory] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [DaisyInventory] SET AUTO_CREATE_STATISTICS ON 
GO
ALTER DATABASE [DaisyInventory] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [DaisyInventory] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [DaisyInventory] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [DaisyInventory] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [DaisyInventory] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [DaisyInventory] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [DaisyInventory] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [DaisyInventory] SET RECURSIVE_TRIGGERS OFF 
GO
--ALTER DATABASE [DaisyInventory] SET  DISABLE_BROKER 
--GO
--ALTER DATABASE [DaisyInventory] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
--GO
--ALTER DATABASE [DaisyInventory] SET DATE_CORRELATION_OPTIMIZATION OFF 
--GO
--ALTER DATABASE [DaisyInventory] SET PARAMETERIZATION SIMPLE 
--GO
ALTER DATABASE [DaisyInventory] SET  READ_WRITE 
GO
ALTER DATABASE [DaisyInventory] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [DaisyInventory] SET  MULTI_USER 
GO
--ALTER DATABASE [DaisyInventory] SET PAGE_VERIFY CHECKSUM  
--GO
USE [DaisyInventory]
GO
--IF NOT EXISTS (SELECT name FROM sys.filegroups WHERE is_default=1 AND name = N'PRIMARY') ALTER DATABASE [DaisyInventory] MODIFY FILEGROUP [PRIMARY] DEFAULT
--GO

--Create table sysprocesses
USE [DaisyInventory]
GO
CREATE TABLE [dbo].[DaisySysProcesses] (
	 TimeOfSelect datetime
	, spid smallint
	, nt_domain nchar(128)
	, nt_username nchar(128)
	, loginame nchar(128)
	, login_time datetime
	, last_batch datetime
	, DatabaseName sysname
	, status nchar(30)
	, hostname nchar(128)
	, program_name nchar(128)
	, cmd nchar(16)
)
CREATE INDEX IX_DatabaseName ON DaisySysProcesses(DatabaseName)
GO
CREATE INDEX IX_LoginName ON DaisySysProcesses(loginame)
GO
CREATE INDEX IX_TimeOfSelect ON DaisySysProcesses(TimeOfSelect)
GO

-- Add job Daisy-SysProcessSelect
-- Inserts output from sysprocesses into seperate table.
-- Sceduled to run every minute
USE [msdb]
GO

BEGIN TRANSACTION
DECLARE @ReturnCode INT
DECLARE @jobId BINARY(16)

-- Job
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Daisy-SysProcessSelect', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Select from sysprocesses into seperate table', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

-- Job step
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'SysProcessSelect', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE [DaisyInventory]
GO
INSERT INTO [dbo].[DaisySysProcesses]
	SELECT GETDATE(), spid, nt_domain, nt_username, loginame, login_time, last_batch, DB_NAME(dbid), status, hostname, program_name, cmd FROM master.dbo.sysprocesses 
	WHERE spid > 50 AND DB_NAME(dbid) != ''DaisyInventory''
GO', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Daisy-SysProcessSelect', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
-- End: Add job Daisy-SysProcessSelect

USE [master]
GO
