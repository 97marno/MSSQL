/* Instance Inventory for SQL Server 2005
--Server properties
--Listening port
--Non-default configuration options
--User defined sysmessages
--Linked servers
--Database options
	--Ansi_null
	--Trustworthy
	--Cross DB Ownership Chaining 
	--Full text search
	--Replication
	--Page verify option (should be CHECKSUM)
--Database growth
--Databases with FULL recovery model but no transaction log backup 
--Transaction log size and space used
--System databases
	--Non-default tables in master database
	--Non-default SP in master database
	--Tables in model database
	--SP in model database
--Database users, logins and aliases
--Logins with server roles
--Jobs
--SSIS packages
--Space used for each database

*/

SET NOCOUNT ON

--Server properties
SELECT SERVERPROPERTY ('SERVERNAME') AS 'SERVERNAME', SERVERPROPERTY ('ComputerNamePhysicalNetBIOS') AS 'NODE', SERVERPROPERTY ('MACHINENAME') AS 'MACHINENAME', SERVERPROPERTY ('INSTANCENAME') AS 'INSTANCENAME'
SELECT SERVERPROPERTY ('EDITION') AS 'EDITION', SERVERPROPERTY ('PRODUCTVERSION') AS 'PRODUCTVERSION', SERVERPROPERTY ('PRODUCTLEVEL') AS 'PRODUCTLEVEL', SERVERPROPERTY('RESOURCEVERSION') AS 'RESOURCEVERSION'
SELECT SERVERPROPERTY ('COLLATION') AS 'COLLATION', SERVERPROPERTY ('SQLCHARSETNAME') AS 'SQLCHARSETNAME', SERVERPROPERTY ('SQLSORTORDERNAME') AS 'SORTORDER'
SELECT SERVERPROPERTY ('ISCLUSTERED') AS 'ISCLUSTERED', SERVERPROPERTY ('ISFULLTEXTINSTALLED') AS 'ISFULLTEXTINSTALLED', SERVERPROPERTY ('ISINTEGRATEDSECURITYONLY') AS 'ISINTEGRATEDSECURITYONLY', SERVERPROPERTY ('ISSINGLEUSER') AS 'ISSINGLEUSER'

--Listening port
EXEC sp_readerrorlog 0, 1, 'Listening'	--Search current SQL Server errorlog for string 'Listening'

--Non-default configuration options
--Source code from SSMS Standard  reports - Server Dashboard
--Adjusted to TS standard value for recovery interval to 1
	SELECT 'Non-default configuration options'
	EXEC sp_executesql @stmt=N'begin try
	declare @configurations_option_table table (
			name nvarchar(128)
	,       run_value bigint
	,       default_value bigint 
	);
	declare @sp_configure_table table (
			name nvarchar(128)
	,       minimum bigint
	,       maximum bigint
	,       config_value bigint
	,       run_value bigint 
	);
	declare @tracestatus table(
			TraceFlag nvarchar(40)
	,       Status tinyint
	,       Global tinyint
	,       Session tinyint
	);

	insert into @sp_configure_table 
	select name
	,       convert(bigint,minimum)
	,       convert(bigint,maximum)
	,       convert(bigint,value)
	,       convert(bigint,value_in_use) 
	from sys.configurations  

	insert into @configurations_option_table values(''Ad Hoc Distributed Queries'',0,0)
	insert into @configurations_option_table values(''affinity I/O mask'',0,0)
	insert into @configurations_option_table values(''affinity mask'',0,0)
	insert into @configurations_option_table values(''Agent XPs'',0,0)
	insert into @configurations_option_table values(''allow updates'',0,0)
	insert into @configurations_option_table values(''awe enabled'',0,0)
	insert into @configurations_option_table values(''blocked process threshold'',0,0)
	insert into @configurations_option_table values(''c2 audit mode'',0,0)
	insert into @configurations_option_table values(''clr enabled'',0,0)
	insert into @configurations_option_table values(''cost threshold for parallelism'',5,5)
	insert into @configurations_option_table values(''cross db ownership chaining'',0,0)
	insert into @configurations_option_table values(''cursor threshold'',-1,-1)
	insert into @configurations_option_table values(''Database Mail XPs'',0,0)
	insert into @configurations_option_table values(''default full-text language'',1033,1033)
	insert into @configurations_option_table values(''default language'',0,0)
	insert into @configurations_option_table values(''default trace enabled'',1,1)
	insert into @configurations_option_table values(''disallow results from triggers'',0,0)
	insert into @configurations_option_table values(''fill factor (%)'',0,0)
	insert into @configurations_option_table values(''ft crawl bandwidth (max)'',100,100)
	insert into @configurations_option_table values(''ft crawl bandwidth (min)'',0,0)
	insert into @configurations_option_table values(''ft notify bandwidth (max)'',100,100)
	insert into @configurations_option_table values(''ft notify bandwidth (min)'',0,0)
	insert into @configurations_option_table values(''index create memory (KB)'',0,0)
	insert into @configurations_option_table values(''in-doubt xact resolution'',0,0)
	insert into @configurations_option_table values(''lightweight pooling'',0,0)
	insert into @configurations_option_table values(''locks'',0,0)
	insert into @configurations_option_table values(''max degree of parallelism'',0,0)
	insert into @configurations_option_table values(''max full-text crawl range'',4,4)
	insert into @configurations_option_table values(''max server memory (MB)'',2147483647,2147483647)
	insert into @configurations_option_table values(''max text repl size (B)'',65536,65536)
	insert into @configurations_option_table values(''max worker threads'',0,0)
	insert into @configurations_option_table values(''media retention'',0,0)
	insert into @configurations_option_table values(''min memory per query (KB)'',1024,1024)
	insert into @configurations_option_table values(''min server memory (MB)'',0,0)
	insert into @configurations_option_table values(''nested triggers'',1,1)
	insert into @configurations_option_table values(''network packet size (B)'',4096,4096)
	insert into @configurations_option_table values(''Ole Automation Procedures'',0,0)
	insert into @configurations_option_table values(''open objects'',0,0)
	insert into @configurations_option_table values(''PH timeout (s)'',60,60)
	insert into @configurations_option_table values(''precompute rank'',0,0)
	insert into @configurations_option_table values(''priority boost'',0,0)
	insert into @configurations_option_table values(''query governor cost limit'',0,0)
	insert into @configurations_option_table values(''query wait (s)'',-1,-1)
	insert into @configurations_option_table values(''recovery interval (min)'',1,1)
	insert into @configurations_option_table values(''remote access'',1,1)
	insert into @configurations_option_table values(''remote admin connections'',0,0)
	insert into @configurations_option_table values(''remote login timeout (s)'',20,20)
	insert into @configurations_option_table values(''remote proc trans'',0,0)
	insert into @configurations_option_table values(''remote query timeout (s)'',600,600)
	insert into @configurations_option_table values(''Replication XPs'',0,0)
	insert into @configurations_option_table values(''RPC parameter data validation'',0,0)
	insert into @configurations_option_table values(''scan for startup procs'',0,0)
	insert into @configurations_option_table values(''server trigger recursion'',1,1)
	insert into @configurations_option_table values(''set working set size'',0,0)
	insert into @configurations_option_table values(''show advanced options'',0,0)
	insert into @configurations_option_table values(''SMO and DMO XPs'',1,1)
	insert into @configurations_option_table values(''SQL Mail XPs'',0,0)
	insert into @configurations_option_table values(''transform noise words'',0,0)
	insert into @configurations_option_table values(''two digit year cutoff'',2049,2049)
	insert into @configurations_option_table values(''user connections'',0,0)
	insert into @configurations_option_table values(''user options'',0,0)
	insert into @configurations_option_table values(''Web Assistant Procedures'',0,0)
	insert into @configurations_option_table values(''xp_cmdshell'',0,0)

	insert into @tracestatus exec(''dbcc tracestatus with no_infomsgs'')
	update @tracestatus set TraceFlag = ''Traceflag (''+TraceFlag+'')''

	select 1 as l1
	,       st.name as name 
	,       convert(nvarchar(15),st.run_value) as run_value
	,       convert(nvarchar(15),ct.default_value) as default_value
	,       1 as msg  
	from @configurations_option_table ct 
	inner join  @sp_configure_table st on (ct.name = st.name  and ct.default_value != st.run_value)
	union
	select 1 as l1
	,       TraceFlag as name
	,       convert(nvarchar(15), Status) as run_value
	,       ''0'' as default_value
	,       1 as msg  
	from @tracestatus where Global=1 order by name
	end try
	begin catch
	select -100 as l1
	,       ERROR_NUMBER() as name
	,       ERROR_SEVERITY() as run_value
	,       ERROR_STATE() as default_value
	,       ERROR_MESSAGE() as msg
	end catch',@params=N''
--End: Non-default configuration options

--User defined sysmessages
SELECT 'User defined sysmessages'
SELECT * FROM master.sys.messages WHERE message_id > 49999

--Linked servers
SELECT srvid, srvname AS 'Linked Server', srvnetname, srvproduct, providername, datasource FROM master.sys.sysservers ORDER BY srvid

--Database options
--SELECT TOP 1 * FROM master.sys.databases
SELECT sd.database_id AS 'Id', sd.name AS 'Database', sl.name AS 'Owner', sd.compatibility_level AS 'Comp.lvl', sd.collation_name AS 'Collation', state_desc AS 'Status' FROM  master.sys.databases  sd LEFT JOIN master.sys.syslogins sl ON sd.owner_sid = sl.sid
SELECT database_id AS 'Id', name AS 'Readonly Database' FROM master.sys.databases WHERE is_read_only = 1
SELECT database_id AS 'Id', name AS 'Autoclose Database' FROM master.sys.databases WHERE is_auto_close_on = 1
SELECT database_id AS 'Id', name AS 'Autosghrink Database' FROM master.sys.databases WHERE is_auto_shrink_on = 1
SELECT database_id AS 'Id', name AS 'Missing (sync) auto statistics Database', 
is_auto_create_stats_on AS 'Auto Create', is_auto_update_stats_on AS 'Auto Update', is_auto_update_stats_async_on AS 'Async Auto Update' FROM master.sys.databases 
WHERE (is_auto_create_stats_on = 0 OR is_auto_update_stats_on = 0)
--WHERE (is_auto_create_stats_on = 0 OR (is_auto_update_stats_on = 0 AND is_auto_update_stats_async_on = 0) -- if ok with async update stats
SELECT database_id AS 'Id', name AS 'Quoted Identifier Database', is_quoted_identifier_on FROM master.sys.databases WHERE is_quoted_identifier_on = 1

--Recovery model
SELECT database_id AS 'Id', name AS 'Database', recovery_model_desc AS 'Recovery model' FROM master.sys.databases ORDER BY recovery_model DESC
--SELECT database_id AS 'Id', name AS 'Full Recovery model Database', recovery_model_desc AS 'Recovery model' FROM master.sys.databases WHERE recovery_model = 1
--SELECT database_id AS 'Id', name AS 'Bulk Recovery model Database', recovery_model_desc AS 'Recovery model' FROM master.sys.databases WHERE recovery_model = 2
--SELECT database_id AS 'Id', name AS 'Simple Recovery model Database', recovery_model_desc AS 'Recovery model' FROM master.sys.databases WHERE recovery_model = 3

--Ansi_null
SELECT database_id AS 'Id', name AS 'Ansi null Database', is_ansi_null_default_on AS 'Def', is_ansi_nulls_on AS 'On', is_ansi_padding_on AS 'Padd', is_ansi_warnings_on AS 'Warn' FROM master.sys.databases WHERE (is_ansi_null_default_on = 1 OR is_ansi_nulls_on = 1 OR is_ansi_padding_on = 1 OR is_ansi_warnings_on = 1)

--Trustworthy
SELECT database_id AS 'Id', name AS 'Trustworthy Database' FROM master.sys.databases WHERE is_trustworthy_on = 1

--Cross DB Ownership Chaining 
SELECT database_id AS 'Id', name AS 'Cross ownership Database' FROM master.sys.databases WHERE is_db_chaining_on = 1

--Full text search
SELECT database_id AS 'Id', name AS 'Full text search enabled Database' FROM master.sys.databases WHERE is_fulltext_enabled = 1

--Replication
SELECT database_id AS 'Id', name AS 'Replication Database', is_published AS 'P', is_subscribed AS 'S', is_merge_published AS 'MP', is_distributor AS 'D' FROM master.sys.databases WHERE (is_published = 1 OR is_subscribed = 1 OR is_merge_published = 1 OR is_distributor = 1)

--Page verify option (should be CHECKSUM)
SELECT database_id AS 'Id', name AS 'Not checksum Database', page_verify_option_desc AS 'Page verify option', page_verify_option FROM master.sys.databases WHERE page_verify_option != 2

--Database growth
--dbid > 4	=> excludes master, tempdb, model, msdb
--growth = 0	=> no growth
--growth 1-100	=> growth in percentage
--growth > 127	=> growth in pages (128 8K pages = 1 MB)
SELECT 'Growth'=saf.growth,
	'Growth(MB)'=saf.growth/128, -- Utökning beräknat till MB (OBS, ger 0 för procent-utökningar)
	'Size(MB)'=saf.size/128,
	'Database' = sdb.name,
	'Logical name' = saf.name,
	'Physical file' = saf.filename
 FROM master.sys.sysdatabases AS sdb, master.sys.sysaltfiles AS saf
 WHERE saf.dbid = sdb.dbid
--	 and sdb.dbid > 4
--	 and saf.growth > 101
 ORDER BY saf.name

--Databases with FULL recovery model but no transaction log backup 
SELECT d.name AS 'Database missing transaction log backup', d.recovery_model, d.recovery_model_desc
FROM master.sys.databases d
LEFT OUTER JOIN msdb.dbo.backupset b ON d.name = b.database_name AND b.type = 'L'
WHERE d.recovery_model IN (1, 2) AND b.type IS NULL AND d.database_id NOT IN (2, 3)

--Transaction log size and space used
DBCC SQLPERF(LOGSPACE) WITH NO_INFOMSGS

--System databases
--Non-default tables in master database
SELECT name AS 'Non-default tables in master' FROM master.sys.tables WHERE name NOT IN ('spt_fallback_db', 'spt_fallback_dev', 'spt_fallback_usg', 'spt_monitor', 'spt_values', 'MSreplication_options')

--Non-default SP in master database
SELECT name AS 'SP in master' FROM master.sys.procedures WHERE name NOT IN ('sp_MSrepl_startup', 'sp_MScleanupmergepublisher')

--Tables in model database
SELECT name AS 'Tables in model' FROM model.sys.tables

--SP in model database
SELECT name AS 'SP in model' FROM model.sys.procedures

--Database users, logins and aliases
CREATE TABLE #tempww (LoginName nvarchar(max), DbName nvarchar(max), UserName nvarchar(max), AliasName nvarchar(max)) INSERT INTO #tempww
EXEC master..sp_msloginmappings
SELECT DbName AS 'Database', UserName AS 'User', LoginName AS 'Login', AliasName AS 'Alias' FROM #tempww ORDER BY DBname, UserName
DROP TABLE #tempww

--Logins with server roles
SELECT l.name AS 'Login with server role(s)', l.denylogin, l.sysadmin, l.securityadmin, l.serveradmin, l.setupadmin, l.processadmin, l.diskadmin, l.dbcreator, l.bulkadmin, l.isntname, l.isntgroup, l.isntuser, l.hasaccess, l.isntgroup, l.isntuser
FROM master.sys.syslogins l 
WHERE l.sysadmin = 1 OR l.securityadmin = 1 OR l.serveradmin = 1 OR l.setupadmin = 1 OR l.processadmin = 1 OR l.diskadmin = 1 OR l.dbcreator = 1 OR l.bulkadmin = 1
ORDER BY l.isntgroup, l.isntname, l.isntuser


--Jobs
	SET  NOCOUNT ON
	DECLARE @MaxLength   INT
	SET @MaxLength   = 50
	 
	DECLARE @xp_results TABLE (
						   job_id uniqueidentifier NOT NULL,
						   last_run_date nvarchar (20) NOT NULL,
						   last_run_time nvarchar (20) NOT NULL,
						   next_run_date nvarchar (20) NOT NULL,
						   next_run_time nvarchar (20) NOT NULL,
						   next_run_schedule_id INT NOT NULL,
						   requested_to_run INT NOT NULL,
						   request_source INT NOT NULL,
						   request_source_id sysname
								 COLLATE database_default NULL,
						   running INT NOT NULL,
						   current_step INT NOT NULL,
						   current_retry_attempt INT NOT NULL,
						   job_state INT NOT NULL
						)
	 
	DECLARE @job_owner   sysname
	 
	DECLARE @is_sysadmin   INT
	SET @is_sysadmin   = isnull (is_srvrolemember ('sysadmin'), 0)
	SET @job_owner   = suser_sname ()
	 
	INSERT INTO @xp_results
	   EXECUTE sys.xp_sqlagent_enum_jobs @is_sysadmin, @job_owner
	 
	UPDATE @xp_results
	   SET last_run_time    = right ('000000' + last_run_time, 6),
		   next_run_time    = right ('000000' + next_run_time, 6)
	 
	SELECT j.name AS JobName,
		   j.enabled AS Enabled,
		   sl.name AS OwnerName,
		   CASE x.running
			  WHEN 1
			  THEN
				 'Running'
			  ELSE
				 CASE h.run_status
					WHEN 2 THEN 'Inactive'
					WHEN 4 THEN 'Inactive'
					ELSE 'Completed'
				 END
		   END
			  AS CurrentStatus,
		   coalesce (x.current_step, 0) AS CurrentStepNbr,
		   CASE
			  WHEN x.last_run_date > 0
			  THEN
				 convert (datetime,
							substring (x.last_run_date, 1, 4)
						  + '-'
						  + substring (x.last_run_date, 5, 2)
						  + '-'
						  + substring (x.last_run_date, 7, 2)
						  + ' '
						  + substring (x.last_run_date, 1, 2)
						  + ':'
						  + substring (x.last_run_date, 3, 2)
						  + ':'
						  + substring (x.last_run_date, 5, 2)
						  + '.000',
						  121
				 )
			  ELSE
				 NULL
		   END
			  AS LastRunTime,
		   CASE
			  WHEN x.next_run_date > 0
			  THEN
				 convert (datetime,
							substring (x.next_run_date, 1, 4)
						  + '-'
						  + substring (x.next_run_date, 5, 2)
						  + '-'
						  + substring (x.next_run_date, 7, 2)
						  + ' '
						  + substring (x.next_run_date, 1, 2)
						  + ':'
						  + substring (x.next_run_date, 3, 2)
						  + ':'
						  + substring (x.next_run_date, 5, 2)
						  + '.000',
						  121
				 )
			  ELSE
				 NULL
		   END
			  AS NextRunTime,
		   CASE h.run_status
			  WHEN 0 THEN 'Fail'
			  WHEN 1 THEN 'Success'
			  WHEN 2 THEN 'Retry'
			  WHEN 3 THEN 'Cancel'
			  WHEN 4 THEN 'In progress'
		   END
			  AS LastRunOutcome,
		   CASE
			  WHEN h.run_duration > 0
			  THEN
				   (h.run_duration / 1000000) * (3600 * 24)
				 + (h.run_duration / 10000 % 100) * 3600
				 + (h.run_duration / 100 % 100) * 60
				 + (h.run_duration % 100)
			  ELSE
				 NULL
		   END
			  AS 'LastRunDuration (sec)'
	  FROM          @xp_results x
				 LEFT JOIN
					msdb.dbo.sysjobs j
				 ON x.job_id = j.job_id
			  LEFT OUTER JOIN
				 msdb.dbo.syscategories c
			  ON j.category_id = c.category_id
		   LEFT OUTER JOIN
			  msdb.dbo.sysjobhistory h
		   ON     x.job_id = h.job_id
			  AND x.last_run_date = h.run_date
			  AND x.last_run_time = h.run_time
			  AND h.step_id = 0
			LEFT OUTER JOIN sys.syslogins sl ON j.owner_sid = sl.sid
	 ORDER BY 3
--End: Jobs

--SSIS packages (check for SQL Server 2005, otherwise SQL 2008)
IF (SELECT PARSENAME(CONVERT(VARCHAR,SERVERPROPERTY ('PRODUCTVERSION')),4)) = 9
BEGIN--SQL Server 2005
	SELECT p.name AS 'SSIS Package', 
	p.packagetype AS 'Type',
	CASE p.packagetype
			  WHEN 0 THEN 'Default client'
			  WHEN 1 THEN 'SQL Server Import and Export Wizard'
			  WHEN 2 THEN 'DTS Designer in SQL Server 2000'
			  WHEN 3 THEN 'SQL Server Replication'
			  WHEN 5 THEN 'SSIS Desinger'
			  WHEN 6 THEN 'Maintenance Plan Designer'
			  ELSE '?'
	END AS 'Package type desc',
	sl.loginname AS 'Package owner sid login name'
	FROM msdb.dbo.sysdtspackages90 p LEFT JOIN master.sys.syslogins sl ON p.ownersid = sl.sid
END
ELSE
BEGIN--SQL Server 2008
	SELECT p.name AS 'SSIS Package', 
	p.packagetype AS 'Type',
	CASE p.packagetype
			  WHEN 0 THEN 'Default client'
			  WHEN 1 THEN 'SQL Server Import and Export Wizard'
			  WHEN 2 THEN 'DTS Designer in SQL Server 2000'
			  WHEN 3 THEN 'SQL Server Replication'
			  WHEN 5 THEN 'SSIS Desinger'
			  WHEN 6 THEN 'Maintenance Plan Designer'
			  ELSE '?'
	END AS 'Package type desc',
	sl.loginname AS 'Package owner sid login name'
	FROM msdb.dbo.sysssispackages p LEFT JOIN master.sys.syslogins sl ON p.ownersid = sl.sid
END

--Space used for each database
EXEC master.sys.sp_MSforeachdb 'USE [?]; select @@servername AS ''Servername'', DB_NAME() AS ''Database'', [FileID], [File_Size_MB] = convert(decimal(12,2),round([size]/128.000,2)),
[Space_Used_MB] = convert(decimal(12,2),round(fileproperty([name],''SpaceUsed'')/128.000,2)),
[Free_Space_MB] = convert(decimal(12,2),round(([size]-fileproperty([name],''SpaceUsed''))/128.000,2)) ,
[Name], [FileName], convert(datetime,Getdate(),112) as DateInserted
from dbo.sysfiles'
