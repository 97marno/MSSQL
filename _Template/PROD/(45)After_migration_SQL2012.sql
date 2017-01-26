--check logical and physical name 
select name, physical_name from master.sys.master_files where database_id > 4

--Database owner
ALTER AUTHORIZATION ON DATABASE::[<dbname,,>] TO [sa]
GO
--Set page verify to CHECKSUM
ALTER DATABASE [<dbname,,>] SET PAGE_VERIFY CHECKSUM  WITH NO_WAIT
GO
--Recovery model
ALTER DATABASE [<dbname,,>] SET RECOVERY FULL
GO
--Compatibility level
ALTER DATABASE [<dbname,,>] SET COMPATIBILITY_LEVEL = 110
GO
--File growth and logical name
ALTER DATABASE [<dbname,,>] MODIFY FILE (NAME = N'<logical,,>_data', FILEGROWTH = 512000KB, MAXSIZE = UNLIMITED)
GO
ALTER DATABASE [<dbname,,>] MODIFY FILE (NAME = N'<logical,,>_log', FILEGROWTH = 256000KB, MAXSIZE = UNLIMITED)
GO
--Update statistics, usage and run checkdb
USE [<dbname,,>]
GO
EXEC sp_updatestats			
DBCC UPDATEUSAGE([<dbname,,>])
DBCC CHECKDB([<dbname,,>])