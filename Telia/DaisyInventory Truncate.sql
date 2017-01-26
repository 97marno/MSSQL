
USE [DaisyInventory]
GO

-- List data file(s)
--EXEC sp_helpfile
EXEC sp_helpfile 'DaisyInventory'

-- List time of oldest and latest select
SELECT MIN(TimeOfSelect) AS 'Start of Range', MAX(TimeOfSelect) AS 'End of Range' FROM [DaisyInventory].[dbo].[DaisySysProcesses]

-- List number of rows
SELECT COUNT(*) AS '# of rows' FROM [DaisyInventory].[dbo].[DaisySysProcesses]

-- List logged sessions
--SELECT DISTINCT spid, nt_domain, nt_username, loginame, login_time, last_batch, DatabaseName, status, hostname, program_name, cmd FROM [DaisyInventory].[dbo].[DaisySysProcesses]
SELECT * FROM [DaisyInventory].[dbo].[DaisySysProcesses]

-- List sessions to specified database(s)
SELECT DISTINCT spid, nt_domain, nt_username, loginame, login_time, last_batch, DatabaseName, status, hostname, program_name, cmd FROM [DaisyInventory].[dbo].[DaisySysProcesses]
WHERE DatabaseName = ''

-- List user databases never accessed
SELECT name AS 'NotAccessedDB' FROM [master].[dbo].[sysdatabases]
WHERE dbid > 4 AND name != 'DaisyInventory' AND name NOT IN (SELECT DISTINCT DatabaseName FROM [DaisyInventory].[dbo].[DaisySysProcesses])
ORDER BY 1


USE [DaisyInventory]
GO
--SELECT * FROM [DaisyInventory].[dbo].[DaisySysProcesses] WHERE TimeOfSelect > '2012-11-30 08:16:00.810' --2104SQL
--SELECT * FROM [DaisyInventory].[dbo].[DaisySysProcesses] WHERE TimeOfSelect > '2012-11-30 08:16:00.670' --2105SQL
--SELECT * FROM [DaisyInventory].[dbo].[DaisySysProcesses] WHERE TimeOfSelect > '2012-11-30 08:26:00.253' --2106SQL
--SELECT * FROM [DaisyInventory].[dbo].[DaisySysProcesses] WHERE TimeOfSelect > '2012-11-30 08:20:00.213' --2107SQL
--SELECT * FROM [DaisyInventory].[dbo].[DaisySysProcesses] WHERE TimeOfSelect > '2012-11-30 08:47:00.320' --2108SQL
--SELECT * FROM [DaisyInventory].[dbo].[DaisySysProcesses] WHERE TimeOfSelect > '2012-11-30 10:06:00.583' --2302SQL
SELECT MIN(TimeOfSelect) AS 'Start of Range', MAX(TimeOfSelect) AS 'End of Range' FROM [DaisyInventory].[dbo].[DaisySysProcesses]
TRUNCATE TABLE [DaisyInventory].[dbo].[DaisySysProcesses]
GO
