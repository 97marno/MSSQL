/* Instance Inventory for SQL Server 2000
--Server properties
--Listening port
--Non-default configuration options
--User defined sysmessages
--Linked servers
--Database options
	--Recovery model
	--Ansi_null
	--Trustworthy (not in SQL 2000)
	--Cross DB Ownership Chaining Server configuration
	--Cross DB Ownership Chaining per database
	--Full text search
	--Replication
	--Page verify option (convert to CHECKSUM)
--Database growth
--Transaction log size and space used
--System databases
	--User tables in master database
	--Non-default SP in master database
	--Objects in model database
--Database users, logins and aliases
--Logins with server roles
--DTS packages in msdb
--Jobs
--SSIS packages
--Linked servers
--Space used for each database

*/

SET NOCOUNT ON

--Server properties
SELECT SERVERPROPERTY ('SERVERNAME') AS 'SERVERNAME', SERVERPROPERTY ('ComputerNamePhysicalNetBIOS') AS 'NODE', SERVERPROPERTY ('MACHINENAME') AS 'MACHINENAME', SERVERPROPERTY ('INSTANCENAME') AS 'INSTANCENAME'
SELECT SERVERPROPERTY ('EDITION') AS 'EDITION', SERVERPROPERTY ('PRODUCTVERSION') AS 'PRODUCTVERSION', SERVERPROPERTY ('PRODUCTLEVEL') AS 'PRODUCTLEVEL', SERVERPROPERTY('RESOURCEVERSION') AS 'RESOURCEVERSION'
SELECT SERVERPROPERTY ('COLLATION') AS 'COLLATION', SERVERPROPERTY ('SQLCHARSETNAME') AS 'SQLCHARSETNAME', SERVERPROPERTY ('SQLSORTORDERNAME') AS 'SORTORDER'
SELECT SERVERPROPERTY ('ISCLUSTERED') AS 'ISCLUSTERED', SERVERPROPERTY ('ISFULLTEXTINSTALLED') AS 'ISFULLTEXTINSTALLED', SERVERPROPERTY ('ISINTEGRATEDSECURITYONLY') AS 'ISINTEGRATEDSECURITYONLY', SERVERPROPERTY ('ISSINGLEUSER') AS 'ISSINGLEUSER'

--Listening port
CREATE TABLE #ErrorLog (ErrorlogEntry nvarchar(256), ContinuationRow bigint) INSERT INTO #ErrorLog EXEC sp_readerrorlog 0, 1
SELECT ErrorlogEntry AS 'Server Listening on ' FROM #ErrorLog WHERE ErrorlogEntry LIKE '%listening%'
DROP TABLE #ErrorLog

--Non-default configuration options
--Source code from SSMS Standard  reports - Server Dashboard
--Configuration values from new SQL 2000 installation
DECLARE @SqlCmd nvarchar(256)
SELECT @SqlCmd = 'CREATE TABLE ##configurations_option_table (name nvarchar(128), minimum bigint, maximum bigint, default_value bigint, run_value bigint) INSERT INTO ##configurations_option_table EXEC master.dbo.sp_configure'
IF (SELECT value FROM master.dbo.sysconfigures WHERE comment = 'show advanced options') = 0
	BEGIN
		EXEC sp_configure 'show advanced options', 1
		RECONFIGURE
		EXEC (@SqlCmd)
		EXEC sp_configure 'show advanced options', 0
		RECONFIGURE
	END
ELSE
	EXEC (@SqlCmd)
UPDATE ##configurations_option_table SET default_value = '0' WHERE name = 'affinity mask'
UPDATE ##configurations_option_table SET default_value = '0' WHERE name = 'affinity64 mask'
UPDATE ##configurations_option_table SET default_value = '1' WHERE name = 'Allow remote access'
UPDATE ##configurations_option_table SET default_value = '1' WHERE name = 'Allow triggers to be invoked within triggers'
UPDATE ##configurations_option_table SET default_value = '0' WHERE name = 'Allow updates to system tables'
UPDATE ##configurations_option_table SET default_value = '0' WHERE name = 'AWE enabled in the server'
UPDATE ##configurations_option_table SET default_value = '0' WHERE name = 'c2 audit mode'
UPDATE ##configurations_option_table SET default_value = '5' WHERE name = 'cost threshold for parallelism'
UPDATE ##configurations_option_table SET default_value = '0' WHERE name = 'Create DTC transaction for remote procedures'
UPDATE ##configurations_option_table SET default_value = '0' WHERE name = 'Cross DB Ownership Chaining'
UPDATE ##configurations_option_table SET default_value = '-1' WHERE name = 'cursor threshold'
UPDATE ##configurations_option_table SET default_value = '0' WHERE name = 'Default fill factor percentage'
UPDATE ##configurations_option_table SET default_value = '1033' WHERE name = 'default full-text language'
UPDATE ##configurations_option_table SET default_value = '0' WHERE name = 'default language'
UPDATE ##configurations_option_table SET default_value = '0' WHERE name = 'maximum degree of parallelism'
UPDATE ##configurations_option_table SET default_value = '0' WHERE name = 'Maximum estimated cost allowed by query governor'
UPDATE ##configurations_option_table SET default_value = '0' WHERE name = 'Maximum recovery interval in minutes'
UPDATE ##configurations_option_table SET default_value = '65536' WHERE name = 'Maximum size of a text field in replication.'
UPDATE ##configurations_option_table SET default_value = '2147483647' WHERE name = 'Maximum size of server memory (MB)'
UPDATE ##configurations_option_table SET default_value = '-1' WHERE name = 'maximum time to wait for query memory (s)'
UPDATE ##configurations_option_table SET default_value = '255' WHERE name = 'Maximum worker threads'
UPDATE ##configurations_option_table SET default_value = '0' WHERE name = 'Memory for index create sorts (kBytes)'
UPDATE ##configurations_option_table SET default_value = '1024' WHERE name = 'minimum memory per query (kBytes)'
UPDATE ##configurations_option_table SET default_value = '0' WHERE name = 'Minimum size of server memory (MB)'
UPDATE ##configurations_option_table SET default_value = '4096' WHERE name = 'Network packet size'
UPDATE ##configurations_option_table SET default_value = '0' WHERE name = 'Number of locks for all users'
UPDATE ##configurations_option_table SET default_value = '0' WHERE name = 'Number of open database objects'
UPDATE ##configurations_option_table SET default_value = '0' WHERE name = 'Number of user connections allowed'
UPDATE ##configurations_option_table SET default_value = '0' WHERE name = 'Priority boost'
UPDATE ##configurations_option_table SET default_value = '20' WHERE name = 'remote login timeout'
UPDATE ##configurations_option_table SET default_value = '600' WHERE name = 'remote query timeout'
UPDATE ##configurations_option_table SET default_value = '0' WHERE name = 'scan for startup stored procedures'
UPDATE ##configurations_option_table SET default_value = '0' WHERE name = 'set working set size'
UPDATE ##configurations_option_table SET default_value = '0' WHERE name = 'show advanced options'
UPDATE ##configurations_option_table SET default_value = '0' WHERE name = 'Tape retention period in days'
UPDATE ##configurations_option_table SET default_value = '2049' WHERE name = 'two digit year cutoff'
UPDATE ##configurations_option_table SET default_value = '0' WHERE name = 'User mode scheduler uses lightweight pooling'
UPDATE ##configurations_option_table SET default_value = '0' WHERE name = 'user options'
SELECT name AS 'Non-default configuration option', default_value AS 'Default', run_value AS 'Run' FROM ##configurations_option_table WHERE default_value != run_value AND name != 'show advanced options'
DROP TABLE ##configurations_option_table
--End: Non-default configuration options

--User defined sysmessages
SELECT 'User defined sysmessages'
SELECT * FROM master.dbo.sysmessages WHERE error > 49999

--Linked servers
SELECT srvid, srvname AS 'Linked Server', srvnetname, srvproduct, providername, datasource FROM master.dbo.sysservers ORDER BY srvid

--Database options
SELECT dbid AS 'Id', name AS 'Database', SUSER_SNAME(sid) AS 'Owner', cmptlevel AS 'Comp.lvl', DATABASEPROPERTYEX(name, 'Collation') AS 'Collation', DATABASEPROPERTYEX(name, 'Status') AS 'Status' FROM master.dbo.sysdatabases
SELECT dbid AS 'Id', name AS 'Readonly/Standby Database', DATABASEPROPERTYEX(name, 'Updateability') AS 'Updateability', DATABASEPROPERTYEX(name, 'IsInStandBy') AS 'IsInStandBy' FROM master.dbo.sysdatabases WHERE (DATABASEPROPERTYEX(name, 'Updateability') = 'READ_ONLY' OR DATABASEPROPERTYEX(name, 'IsInStandBy') = 1)
SELECT dbid AS 'Id', name AS 'Autoclose Database', DATABASEPROPERTYEX(name, 'IsAutoClose') AS 'IsAutoClose' FROM master.dbo.sysdatabases WHERE DATABASEPROPERTYEX(name, 'IsAutoClose') = 1
SELECT dbid AS 'Id', name AS 'Autoshrink Database', DATABASEPROPERTYEX(name, 'IsAutoShrink') AS 'IsAutoShrink' FROM master.dbo.sysdatabases WHERE DATABASEPROPERTYEX(name, 'IsAutoShrink') = 1
SELECT dbid AS 'Id', name AS 'Missing auto statistics Database', DATABASEPROPERTYEX(name, 'IsAutoCreateStatistics') AS 'IsAutoCreateStatistics', DATABASEPROPERTYEX(name, 'IsAutoUpdateStatistics') AS 'IsAutoUpdateStatistics' FROM master.dbo.sysdatabases WHERE (DATABASEPROPERTYEX(name, 'IsAutoCreateStatistics') = 0 OR DATABASEPROPERTYEX(name, 'IsAutoUpdateStatistics') = 0)
SELECT dbid AS 'Id', name AS 'Quoted Identifier Database', DATABASEPROPERTYEX(name, 'IsQuotedIdentifiersEnabled') AS 'IsQuotedIdentifiersEnabled' FROM master.dbo.sysdatabases WHERE DATABASEPROPERTYEX(name, 'IsQuotedIdentifiersEnabled') = 1

--Recovery model
SELECT dbid AS 'Id', name AS 'Database', DATABASEPROPERTYEX(name, 'Recovery') AS 'Recovery model' FROM master.dbo.sysdatabases ORDER BY 'Recovery model' DESC
--SELECT dbid AS 'Id', name AS 'Full Recovery model Database', DATABASEPROPERTYEX(name, 'Recovery') AS 'Recovery model' FROM master.dbo.sysdatabases WHERE DATABASEPROPERTYEX(name, 'Recovery') = 'FULL'
--SELECT dbid AS 'Id', name AS 'Bulk Recovery model Database', DATABASEPROPERTYEX(name, 'Recovery') AS 'Recovery model' FROM master.dbo.sysdatabases WHERE DATABASEPROPERTYEX(name, 'Recovery') = 'BULK_LOGGED'
--SELECT dbid AS 'Id', name AS 'Simple Recovery model Database', DATABASEPROPERTYEX(name, 'Recovery') AS 'Recovery model' FROM master.dbo.sysdatabases WHERE DATABASEPROPERTYEX(name, 'Recovery') = 'SIMPLE'

--Ansi_null
SELECT dbid AS 'Id', name AS 'Ansi null Database',  
       DATABASEPROPERTYEX(name, 'IsAnsiNullDefault') AS 'Def', 
       DATABASEPROPERTYEX(name, 'IsAnsiNullsEnabled') AS 'On', 
       DATABASEPROPERTYEX(name, 'IsAnsiPaddingEnabled') AS 'Padd', 
       DATABASEPROPERTYEX(name, 'IsAnsiWarningsEnabled') AS 'Warn' 
FROM   master.dbo.sysdatabases 
WHERE ('Def' = '0' OR 'On' = '1' OR 'Padd' = '1' OR 'Warn' = '1')

--Trustworthy (not in SQL Server 2000)

--Cross DB Ownership Chaining Server configuration
SELECT comment AS 'Server Configuration option', value AS 'Run value' FROM master.dbo.sysconfigures WHERE comment = 'Cross DB Ownership Chaining'
--Cross DB Ownership Chaining per database
DECLARE @databasename nvarchar(256)
DECLARE DBs CURSOR FOR SELECT name from master.dbo.sysdatabases
CREATE TABLE ##tempchaindb (DbName nvarchar(256), CurrentSetting nvarchar(256))
OPEN DBs
FETCH NEXT FROM DBs INTO @databasename
WHILE @@FETCH_STATUS = 0
BEGIN
	CREATE TABLE #dbtempww(OptionName nvarchar(256), CurrentSetting nvarchar(256)) INSERT INTO #dbtempww EXEC sp_dboption @databasename, 'db chaining'
	INSERT INTO ##tempchaindb (DbName, CurrentSetting) SELECT @databasename, CurrentSetting FROM #dbtempww
	DROP TABLE #dbtempww
	FETCH NEXT FROM DBs INTO @databasename
END
SELECT DbName AS 'Database', CurrentSetting AS 'Cross DB Ownership Chaining' FROM ##tempchaindb WHERE CurrentSetting = 'ON' AND DbName != 'msdb'
CLOSE DBs
DEALLOCATE DBs
DROP TABLE ##tempchaindb

--Full text search
SELECT name AS 'Full text search enabled Database' FROM master.dbo.sysdatabases WHERE DATABASEPROPERTYEX(name, 'IsFulltextEnabled') = 1

--Replication
SELECT dbid AS 'Id', name AS 'Replication Database',  
       DATABASEPROPERTYEX(name, 'IsPublished') AS 'P', 
       DATABASEPROPERTYEX(name, 'IsSubscribed') AS 'S', 
       DATABASEPROPERTYEX(name, 'IsMergePublished') AS 'MP' 
FROM   master.dbo.sysdatabases 
WHERE (DATABASEPROPERTYEX(name, 'IsPublished') = 1 OR DATABASEPROPERTYEX(name, 'IsSubscribed') = 1 OR DATABASEPROPERTYEX(name, 'IsMergePublished') = 1)

--Page verify option (convert to CHECKSUM)
SELECT name AS 'Database', DATABASEPROPERTYEX(name, 'IsTornPageDetectionEnabled') AS 'Torn Page Detection Enabled' FROM master.dbo.sysdatabases ORDER BY 2

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
 FROM master.dbo.sysdatabases AS sdb, master.dbo.sysaltfiles AS saf
 WHERE saf.dbid = sdb.dbid
--	 and sdb.dbid > 4
--	 and saf.growth > 101
 ORDER BY saf.name

--Databases with FULL recovery model but no transaction log backup 
SELECT d.name AS 'Database missing transaction log backup', DATABASEPROPERTYEX(d.name, 'Recovery') AS 'Recovery model'
FROM master.dbo.sysdatabases d
LEFT OUTER JOIN msdb.dbo.backupset b ON d.name = b.database_name AND b.type = 'L'
WHERE DATABASEPROPERTYEX(d.name, 'Recovery') = 'FULL' AND b.type IS NULL AND d.dbid NOT IN (2, 3)

--Transaction log size and space used
DBCC SQLPERF(LOGSPACE) WITH NO_INFOMSGS

--System databases
--User tables in master database
SELECT so.name AS 'User table in master', su.name AS 'Owner user' FROM master.dbo.sysobjects so LEFT OUTER JOIN master.dbo.sysusers su ON so.uid = su.uid WHERE type = 'U' AND so.name NOT IN ('spt_monitor', 'spt_values', 'spt_fallback_db', 'spt_fallback_dev', 'spt_fallback_usg', 'spt_provider_types', 'spt_datatype_info_ext', 'MSreplication_options', 'spt_datatype_info', 'spt_server_info')

--Non-default SP in master database
SELECT so.name AS 'SP in master', su.name AS 'Owner user' FROM master.dbo.sysobjects so LEFT OUTER JOIN master.dbo.sysusers su ON so.uid = su.uid WHERE type = 'P' AND so.name NOT IN ('sp_populateqtraninfo', 'sp_helpsql', 'sp_MShelpalterbeforetable', 'sp_MSunmarkschemaobject', 'sp_MSquiescecheck', 'sp_scriptpkwhereclause', 'sp_MSrepl_dbrole', 'sp_datatype_info', 'sp_MScreate_sub_tables', 'sp_MSgetbeforetableinsert', 'sp_MSmarkschemaobject', 'sp_MS_upd_sysobj_category', 'sp_mergepreparecleanup', 'sp_MSscript_missing_row_check', 'sp_changedistributor_password', 'sp_MSupdate_mqserver_subdb', 'sp_MSfixupbeforeimagetables', 'sp_MSaddanonymousreplica', 'sp_db_upgrade', 'sp_MSpreparecleanup', 'sp_scriptupdateparams', 'sp_oledbinfo', 'sp_MS_replication_installed', 'sp_recompile', 'sp_MSreplcheck_permission', 'sp_MSgetreplicainfo', 'sp_MSquiescetriggerson', 'sp_scriptreconwhereclause', 'sp_readerrorlog', 'sp_MSget_oledbinfo', 'sp_MSunc_to_drive', 'sp_remoteoption', 'sp_MSinserterrorlineage', 'sp_MSadd_repl_job', 'sp_MSquiescetriggersoff', 'sp_script_reconciliation_insproc', 'sp_grant_publication_access', 'sp_fkeys', 'sp_MSretrieve_publication_attributes', 'sp_invalidate_textptr', 'sp_MSevalsubscriberinfo', 'sp_MScheck_subscription', 'sp_MSquiesceforcleanup', 'sp_script_reconciliation_delproc', 'sp_enumerrorlogs', 'sp_revoke_publication_access', 'sp_MScleanup_publication_ADinfo', 'sp_tableoption', 'sp_MSsetsubscriberinfo', 'sp_MSgettools_path', 'sp_mergecompletecleanup', 'sp_script_reconciliation_xdelproc', 'sp_help_publication_access', 'sp_MSrepl_linkedservers_rowset', 'sp_procoption', 'sp_MSgetsubscriberinfo', 'sp_replicationoption', 'sp_MScompletecleanup', 'sp_scriptinsproc', 'sp_check_publication_access', 'sp_pkeys', 'sp_MSregistersubscription', 'sp_renamedb', 'sp_MSmakectsview', 'sp_helpreplicationoption', 'sp_MSpropagateschematorepubs', 'sp_scriptdelproc', 'sp_MSget_agent_names', 'sp_server_info', 'sp_MSunregistersubscription', 'sp_remove_tempdb_file', 'sp_MSinsertgenerationschemachanges', 'sp_MSgetreplnick', 'sp_mergecleanupmetadata', 'sp_scriptxdelproc', 'sp_MSinit_replication_perfmon', 'sp_MSsubscription_enabled_for_syncmgr', 'sp_rename', 'sp_MSalreadyhavegeneration', 'sp_MSreplcheck_publish', 'sp_dropextendedproc', 'sp_MScleanup_conflict_table', 'sp_scriptupdproc', 'sp_MSrepl_startup', 'sp_MSget_jobstate', 'sp_resetstatus', 'sp_MSgettablecontents', 'sp_MSlocktable', 'sp_addextendedproc', 'sp_validatemergesubscription', 'sp_scriptmappedupdproc', 'sp_eventlog', 'sp_MSflush_access_cache', 'sp_MSscript_pkvar_assignment', 'sp_add_file_recover_suspect_db', 'sp_MSdelgenzero', 'sp_MSenumcolumns', 'sp_helpextendedproc', 'sp_validatemergepublication', 'sp_scriptdynamicupdproc', 'sp_MSreinit_failed_subscriptions', 'sp_special_columns', 'sp_MSget_publication_from_taskname', 'sp_add_data_file_recover_suspect_db', 'sp_MSmakedynsnapshotvws', 'sp_MSsetaccesslist', 'sp_MScleanup_conflict', 'sp_scriptxupdproc', 'sp_add_datatype_mapping', 'sp_MSacquireHeadofQueueLock', 'sp_add_log_file_recover_suspect_db', 'sp_MSmakedynsnapshotvws_longdef', 'sp_MSreplcheck_pull', 'sp_generatefilters', 'sp_MSscriptmvastablenci', 'sp_MSrepl_gettype_mappings', 'sp_MSacquireSlotLock', 'sp_spaceused', 'sp_MSdropdynsnapshotvws', 'sp_MSreplcheck_connection', 'sp_MShelpmergeconflictcounts', 'sp_MSscriptmvastablepkc', 'sp_help_datatype_mapping', 'sp_MSreleaseSlotLock', 'sp_sqlexec', 'sp_MSchunkgeneration', 'sp_MSrepl_PAL_rolecheck', 'sp_MShelpmergeconflictpublications', 'sp_MSscriptmvastableidx', 'sp_MSfix_6x_tasks', 'sp_sproc_columns', 'sp_MSrepl_check_server', 'sp_unbindefault', 'sp_MSreplcheck_qv', 'sp_MSclearcolumnbit', 'sp_MSscriptmvastable', 'sp_MShelpconflictpublications', 'sp_MSreset_synctran_bit', 'sp_unbindrule', 'sp_reinitmergepullsubscription', 'sp_helpmergearticleconflicts', 'sp_fetchshowcmdsinput', 'sp_MSenum_replsqlqueues', 'sp_who', 'sp_clean_db_file_free_space', 'sp_MSreplcheck_subscribe', 'sp_droplogin', 'sp_helpmergeconflictrows', 'sp_replshowcmds', 'sp_replproberemoteserver', 'sp_statistics', 'sp_MSenum_replqueues', 'sp_who2', 'sp_clean_db_free_space', 'sp_MSreplicationcompatlevel', 'sp_addsrvrolemember', 'sp_helpmergedeleteconflictrows', 'sp_article_validation', 'sp_MScleanupmergepublisher', 'sp_browsemergesnapshotfolder', 'sp_check_removable', 'sp_msupg_dosystabcatalogupgrades', 'sp_MShelp_identity_property', 'sp_dropsrvrolemember', 'sp_deletemergeconflictrow', 'sp_publication_validation', 'sp_MScleanupdynsnapshotvws', 'sp_browsesnapshotfolder', 'sp_certify_removable', 'sp_msupg_recreatecatalogfaketables', 'sp_MSgenreplnickname', 'sp_grantdbaccess', 'sp_getmergedeletetype', 'sp_marksubscriptionvalidation', 'sp_MScleanupmergepublisherdb', 'sp_stored_procedures', 'sp_MScopysnapshot', 'MS_sqlctrs_users', 'sp_monitor', 'sp_MSmergesubscribedb', 'sp_mergedummyupdate', 'sp_dropanonymousagent', 'sp_MShelp_replication_table', 'sp_copymergesnapshot', 'sp_autostats', 'sp_addlogin', 'sp_MSenumallsubscriptions', 'sp_addrole', 'sp_addtabletocontents', 'sp_replrestart', 'sp_MScopyscriptfile', 'sp_copysnapshot', 'sp_updatestats', 'sp_change_users_login', 'sp_MSenumsubscriptions', 'sp_addapprole', 'sp_MSaddpubtocontents', 'sp_MSpub_adjust_identity', 'sp_replsetoriginator', 'sp_table_privileges', 'sp_MSrepl_validate_dts_package', 'sp_createstats', 'sp_addalias', 'sp_MSenumallpublications', 'sp_MSget_subtypedatasrc', 'sp_helparticledts', 'sp_replsetoriginator_pal', 'sp_MSget_load_hint', 'sp_cycle_errorlog', 'sp_dropalias', 'sp_MSenumtranpublications', 'sp_fulltext_table', 'sp_addmergealternatepublisher', 'sp_changesubscriptiondtsinfo', 'sp_replincrementlsn', 'sp_tables', 'sp_getsubscriptiondtspackagename', 'sp_helptrigger', 'sp_configure', 'sp_MSenummergepublications', 'sp_fulltext_column', 'sp_helpmergealternatepublisher', 'sp_MSdrop_6x_replication_agent', 'sp_replpostsyncstatus', 'sp_MSverifytranfilter', 'sp_fixindex', 'sp_databases', 'sp_MSenum3rdpartypublications', 'sp_helptext', 'sp_dropmergealternatepublisher', 'sp_MSreinit_article', 'sp_catalogs', 'sp_repldropcolumn', 'sp_settriggerorder', 'sp_tables_ex', 'sp_MSenumthirdpartypublicationvendornames', 'sp_tableswc', 'sp_MScomputemergearticlescreationorder', 'sp_MScomputearticlescreationorder', 'sp_repladdcolumn', 'sp_catalogs_rowset', 'sp_reinitpullsubscription', 'sp_MScomputemergeunresolvedrefs', 'sp_MScomputeunresolvedrefs', 'sp_enum_oledb_providers', 'sp_MSagent_access_check', 'sp_validatepropertyinputs', 'sp_primary_keys_rowset', 'sp_addpullsubscription', 'sp_MSCheckmergereplication', 'sp_MShelptranconflictpublications', 'sp_columns_ex', 'sp_enableagentoffload', 'sp_addextendedproperty', 'sp_linkedservers_rowset', 'sp_MSupdatesharedagentproperties', 'sp_MSgetpubinfo', 'sp_MShelptranconflictcounts', 'sp_prop_oledb_provider', 'sp_table_privileges_ex', 'sp_disableagentoffload', 'sp_updateextendedproperty', 'sp_MSobjectprivs', 'sp_replicationdboption', 'sp_MSaddmergedynamicsnapshotjob', 'sp_MSgettranconflictrow', 'sp_column_privileges_ex', 'sp_getagentoffloadinfo', 'sp_dropextendedproperty', 'sp_MSloginmappings', 'sp_MSfixupdistributorinfo', 'sp_MSdropmergedynamicsnapshotjob', 'sp_MSgettrancftsrcrow', 'sp_indexes', 'sp_copysubscription', 'sp_resolve_logins', 'sp_MSfixupdistributorsecurity', 'sp_processmail', 'sp_MShelpmergedynamicsnapshotjob', 'sp_MSdeletetranconflictrow', 'sp_foreignkeys', 'sp_attachsubscription', 'sp_password', 'sp_MStablekeys', 'sp_MSfixupftpinfo', 'sp_MSremove_userscript', 'sp_MSexternalfkreferences', 'sp_primarykeys', 'sp_MSrestore_sub_merge', 'sp_ActiveDirectory_SCP', 'sp_MSfixupaltsnapshotfolder', 'sp_fulltext_catalog', 'sp_MSdrop_rlrecon', 'sp_MSgetarticlereinitvalue', 'sp_MSrestore_sub_tran', 'sp_MSaddlogin_implicit_ntlogin', 'sp_ActiveDirectory_Obj', 'sp_MSfixupworkingdirectory', 'sp_MSfetchidentityrange', 'sp_MSispkupdateinconflict', 'sp_MSrestore_sub', 'sp_grantlogin', 'sp_makewebtask', 'sp_MSfixupuseftp', 'sp_changedbowner', 'sp_MScheckidentityrange', 'sp_MSisnonpkukupdateinconflict', 'sp_ddopen', 'sp_validatemergepullsubscription', 'sp_validatelogins', 'sp_MSfixupagentoffloadinfo', 'sp_dboption', 'sp_MShelpmergeidentity', 'sp_ivindexhasnullcols', 'sp_MSprepare_sub_for_detach', 'xp_grantlogin', 'sp_MSfixupsharedagentproperties', 'sp_MS_marksystemobject', 'sp_MShelpmergearticles', 'sp_MSsub_check_identity', 'sp_denylogin', 'sp_addpullsubscription_agent', 'sp_MShelpmergeschemaarticles', 'sp_replqueuemonitor', 'sp_MSsub_cleanup_orphans', 'sp_revokelogin', 'sp_helpsubscription_properties', 'sp_linkedservers', 'sp_MScreateretry', 'sp_replsqlqgetrows', 'sp_add_server_sortinfo', 'sp_MSsub_cleanup_prop_table', 'xp_revokelogin', 'sp_change_subscription_properties', 'sp_MSdropretry', 'sp_repldeletequeuedtran', 'sp_add_server_sortinfo75', 'sp_MSreseed', 'sp_defaultdb', 'sp_MSget_pullsubsagent_owner', 'sp_MSdroptemptable', 'sp_MSpost_auto_proc', 'sp_MSsub_set_identity', 'sp_defaultlanguage', 'sp_droppullsubscription', 'sp_MSchangearticleresolver', 'sp_MSrepl_schema', 'sp_ActiveDirectory_Start', 'sp_MSinstance_qv', 'sp_helppullsubscription', 'sp_MSenumretries', 'sp_MSreplupdateschema', 'sp_instdist', 'sp_MSget_shared_agent', 'sp_MStable_has_unique_index', 'sp_MSdeleteretry', 'sp_MSdefer_check', 'sp_MSdrop_repltran', 'sp_column_privileges_rowset', 'sp_MSrepl_backup_start', 'sp_MSadduser_implicit_ntlogin', 'sp_MSchange_retention', 'sp_MSdeletepushagent', 'sp_MSreenable_check', 'sp_MSget_current_activity', 'sp_MSdrop_pub_tables', 'sp_MSrepl_backup_complete', 'sp_MScheck_uid_owns_anything', 'sp_MSchange_priority', 'sp_MSgetonerow', 'sp_getqueuedrows', 'sp_MSset_current_activity', 'sp_MShelpsubscriptionjobname', 'sp_MSadd_compensating_cmd', 'sp_expired_subscription_cleanup', 'sp_MSuplineageversion', 'sp_MSprep_exclusive', 'sp_MSobjsearch', 'sp_helpsubscriptionjobname', 'sp_columns_rowset', 'sp_adduser', 'sp_addmergepullsubscription', 'sp_MSSetServerProperties', 'sp_MSgetlastrecgen', 'sp_verify_publication', 'sp_MShasdbaccess', 'sp_MSarticlecolstatus', 'sp_revokedbaccess', 'sp_changemergepullsubscription', 'sp_MSsetalertinfo', 'sp_MSgetlastsentgen', 'sp_scriptpublicationcustomprocs', 'sp_MSarticlecol', 'sp_check_constraints_rowset', 'sp_dropuser', 'sp_helpmergepullsubscription', 'sp_MSgetlastsentrecgens', 'sp_repltablehasnonpkuniquekey', 'sp_MShelpcolumns', 'sp_MScreate_pub_tables', 'sp_MSget_setup_paths', 'sp_addmergepullsubscription_agent', 'sp_MSdummyupdate', 'sp_replscriptuniquekeywhereclause', 'sp_MShelpindex', 'sp_MSsetfilterparent', 'sp_check_constbytable_rowset', 'sp_MSremoveoffloadparameter', 'sp_MSget_mergepullsubsagent_owner', 'sp_MSsetlastrecgen', 'sp_getqueuedarticlesynctraninfo', 'sp_MShelptype', 'sp_MSdoesfilterhaveparent', 'sp_MSaddoffloadparameter', 'sp_dropmergepullsubscription', 'sp_MSsetlastsentgen', 'sp_getsqlqueueversion', 'sp_MSdependencies', 'sp_MSsetfilteredstatus', 'sp_foreign_keys_rowset', 'sp_addgroup', 'sp_MSreplraiserror', 'sp_MSenumgenerations', 'sp_MSdrop_rlcore', 'sp_MStablespace', 'sp_MSretrieve_publication', 'sp_MSUpgradeConflictTable', 'sp_droprole', 'sp_check_sync_trigger', 'sp_MScheckexistsgeneration', 'sp_MSguidtostr', 'sp_MSindexspace', 'sp_MSreplsup_table_has_pk', 'sp_MSsendtosqlqueue', 'sp_dropgroup', 'sp_check_for_sync_trigger', 'sp_MSchecksnapshotstatus', 'sp_MSgetconflicttablename', 'sp_MStablerefs', 'sp_replsync', 'sp_indexes_rowset', 'sp_adjustpublisheridentityrange', 'sp_MSpad_command', 'sp_MSenumreplicas', 'sp_MSuniqueobjectname', 'sp_enumfullsubscribers', 'sp_MSestimatemergesnapshotworkload', 'sp_approlepassword', 'sp_MSflush_command', 'sp_MSenumdeletesmetadata', 'sp_MSuniquetempname', 'sp_MStablechecks', 'sp_addpublication', 'sp_MSestimatesnapshotworkload', 'sp_setapprole', 'sp_MSget_colinfo', 'sp_MSenumpartialdeletes', 'sp_MSuniquecolname', 'sp_MSsettopology', 'sp_changepublication', 'sp_dropapprole', 'sp_MSget_col_position', 'sp_user_counter1', 'sp_MSenumchanges', 'sp_MSaddguidcolumn', 'sp_MSmatchkey', 'sp_changesubscription', 'sp_provider_types_rowset', 'sp_MSdropfkreferencingarticle', 'sp_addrolemember', 'sp_MSget_map_position', 'sp_user_counter2', 'sp_MSenumchanges_pal', 'sp_MSprepare_mergearticle', 'sp_MSforeach_worker', 'sp_helparticle', 'sp_addscriptexec', 'sp_droprolemember', 'sp_MSget_type', 'sp_user_counter3', 'sp_MSenumchanges_direct', 'sp_MSgetcolumnlist', 'sp_MSforeachdb', 'sp_MSis_col_replicated', 'sp_MSmergeupdatelastsyncinfo', 'sp_changegroup', 'sp_MSscript_where_clause', 'sp_user_counter4', 'sp_MSenumpartialchanges', 'sp_MSaddguidindex', 'sp_MSforeachtable', 'sp_articlecolumn', 'sp_procedure_params_rowset', 'sp_MSrepl_FixPALRole', 'sp_MSscript_params', 'sp_user_counter5', 'sp_MSenumpartialchanges_pal', 'sp_MSrefcnt', 'sp_helparticlecolumns', 'sp_createmergepalrole', 'sp_MSscript_procbodystart', 'sp_user_counter6', 'sp_MSenumpartialchanges_direct', 'sp_MScleanuptask', 'sp_MSgentablenickname', 'sp_MSuniquename', 'sp_helppublication', 'sp_MSsetcontext_replagent', 'sp_check_removable_sysusers', 'sp_MSscript_begintrig1', 'sp_user_counter7', 'sp_MSinitdynamicsubscriber', 'sp_MStablenickname', 'sp_MSkilldb', 'sp_helpsubscription', 'sp_procedures_rowset', 'sp_changeobjectowner', 'sp_MSscript_begintrig2', 'sp_user_counter8', 'sp_MSgetrowmetadata', 'sp_MStablenamefromnick', 'sp_articlefilter', 'sp_MSdrop_replcom', 'sp_helpsrvrole', 'sp_MSscript_endtrig', 'sp_user_counter9', 'sp_MSgetmetadatabatch', 'sp_MSgetmakegenerationapplock', 'sp_MSSQLDMO80_version', 'sp_MSscript_article_view', 'sp_schemata_rowset', 'sp_MScreate_distributor_tables', 'sp_srvrolepermission', 'sp_MSscript_trigger_variables', 'sp_user_counter10', 'sp_MSsetrowmetadata', 'sp_MSreleasemakegenerationapplock', 'sp_MSSQLDMO70_version', 'sp_articleview', 'sp_helpsrvrolemember', 'sp_MSscript_trigger_assignment', 'sp_blockcnt', 'sp_MSinsertgenhistory', 'sp_MSmakegeneration', 'sp_MSSQLOLE65_version', 'sp_MSaddexecarticle', 'sp_statistics_rowset', 'sp_MSIfExistsRemoteLogin', 'sp_helpdbfixedrole', 'sp_MSscript_trigger_fetch_statement', 'sp_tempdbspace', 'sp_MSupdategenhistory', 'sp_MSfixlineageversions', 'sp_MSSQLOLE_version', 'sp_MSaddschemaarticle', 'sp_helppublicationsync', 'sp_dbfixedrolepermission', 'sp_MSscript_trigger_exec_rpc', 'sp_MSlocalizeinterruptedgenerations', 'sp_MSaddupdatetrigger', 'sp_MSscriptdatabase', 'sp_addarticle', 'sp_tables_rowset', 'sp_MSreplrole', 'sp_helprolemember', 'sp_MSscript_trigger_update_checks', 'sp_dbcmptlevel', 'sp_MSenumschemachange', 'sp_MSaddmergetriggers', 'sp_MSscriptdb_worker', 'sp_MSgettranconflictname', 'sp_addpublication_snapshot', 'sp_helprole', 'sp_MSscript_trigger_updates', 'sp_fallback_MS_sel_fb_svr', 'sp_MSenumschemachange_70', 'sp_MSchangeobjectowner', 'sp_MSdbuseraccess', 'sp_MSmaketrancftproc', 'sp_MShelpobjectpublications', 'sp_helpntgroup', 'sp_MSscript_trigger_version_updates', 'sp_validname', 'sp_MSenumschemachange_80', 'sp_MShelpdestowner', 'sp_MSdbuserpriv', 'sp_changesubstatus', 'sp_tables_info_rowset', 'sp_helpreplicationdb', 'xp_logininfo', 'sp_MSscript_singlerow_trigger', 'sp_validlang', 'sp_MSenumschemachange_80sp3', 'sp_MSfillupmissingcols', 'sp_MShelpfulltextindex', 'sp_addsubscription', 'sp_helpdistributor', 'sp_addlinkedserver', 'sp_MSscript_multirow_trigger', 'sp_addmessage', 'sp_MSupdateschemachange', 'sp_MSmaptype', 'sp_MShelpfulltextscript', 'sp_MSchangeschemaarticle', 'sp_table_constraints_rowset', 'sp_enumdsn', 'sp_dropserver', 'sp_MSscript_sync_ins_trig', 'sp_addumpdevice', 'sp_MSremove_mergereplcommand', 'sp_MSquerysubtype', 'sp_changearticle', 'sp_enumoledbdatasources', 'sp_serveroption', 'sp_MSscript_sync_upd_trig', 'sp_addremotelogin', 'sp_MSadd_mergereplcommand', 'xp_execresultset', 'sp_showrowreplicainfo', 'sp_MSGetServerProperties', 'sp_droparticle', 'sp_table_privileges_rowset', 'sp_helpsubscriberinfo', 'sp_addserver', 'sp_MSscript_sync_del_trig', 'sp_addtype', 'sp_MSsetreplicainfo', 'sp_execresultset', 'sp_MSsethighestversion', 'sp_droppublication', 'sp_replica', 'sp_setnetname', 'sp_MSget_synctran_column', 'sp_altermessage', 'sp_MSsetreplicastatus', 'sp_MSispulldistributionjobnamegenerated', 'sp_mergemetadataretentioncleanup', 'sp_MSSharedFixedDisk', 'sp_dropsubscription', 'sp_table_statistics_rowset', 'sp_addpublisher', 'sp_helpserver', 'sp_addqueued_artinfo', 'sp_attach_db', 'sp_MScreateglobalreplica', 'sp_MSispullmergejobnamegenerated', 'sp_MSpurgecontentsorphans', 'sp_MSfilterclause', 'sp_subscribe', 'sp_addsubscriber', 'sp_helplinkedsrvlogin', 'sp_addsynctriggers', 'sp_attach_single_file_db', 'sp_MSsetconflictscript', 'sp_MScleanup_zeroartnick_genhistory', 'sp_MSgetalertinfo', 'sp_unsubscribe', 'sp_addsubscriber_schedule', 'sp_addlinkedsrvlogin', 'sp_setreplfailovermode', 'sp_helplanguage', 'sp_MSsetconflicttable', 'sp_MSdelete_specifiedcontents', 'sp_refreshsubscriptions', 'sp_oledb_column_constraints', 'sp_changesubscriber', 'sp_droplinkedsrvlogin', 'sp_helpreplfailovermode', 'sp_bindefault', 'sp_MSmakeconflictinsertproc', 'sp_MSdrop_rladmin', 'sp_MSpublishdb', 'sp_changesubscriber_schedule', 'sp_helpreplicationdboption', 'sp_bindrule', 'sp_MSmaketempinsertproc', 'sp_MSaddmergepub_snapshot', 'sp_MSactivate_auto_sub', 'sp_oledb_indexinfo', 'sp_distcounters', 'sp_fulltext_service', 'sp_MScheck_agent_instance', 'sp_checknames', 'sp_MSgetconflictinsertproc', 'sp_MSdropmergepub_snapshot', 'sp_MSget_synctran_commands', 'sp_oledb_ro_usrname', 'sp_droppublisher', 'sp_fulltext_database', 'sp_MSBumpupCompLevel', 'sp_MSinsertdeleteconflict', 'sp_MScheckatpublisher', 'sp_script_synctran_commands', 'sp_oledb_deflang', 'sp_dropsubscriber', 'sp_MSCleanupForPullReinit', 'sp_dbremove', 'sp_MScheckmetadatamatch', 'sp_MSaddmergeschemaarticle', 'sp_MSaddpub_snapshot', 'sp_oledb_defdb', 'sp_dsninfo', 'sp_MSpublicationcleanup', 'sp_create_removable', 'sp_MSdelrow', 'sp_addmergearticle', 'sp_MSis_pk_col', 'sp_oledb_database', 'sp_publishdb', 'sp_cleanupdbreplication', 'sp_depends', 'sp_MSsetartprocs', 'sp_MSdroparticleconstraints', 'sp_MSchangemergeschemaarticle', 'sp_MSmark_proc_norepl', 'sp_oledb_language', 'sp_MScreate_dist_tables', 'sp_help_fulltext_catalogs', 'sp_MSarticlecleanup', 'sp_detach_db', 'sp_MSmakesystableviews', 'sp_MSacquireserverresourcefordynamicsnapshot', 'sp_changemergearticle', 'sp_MSdrop_expired_subscription', 'sp_tablecollations', 'sp_MSupdate_mqserver_distdb', 'sp_help_fulltext_catalogs_cursor', 'sp_MSdroparticleprocs', 'sp_diskdefault', 'sp_MSgetchangecount', 'sp_MSchange_mergearticle', 'sp_MSscript_validate_subscription', 'sp_bcp_dbcmptlevel', 'sp_MSadd_distributor_alerts_and_responses', 'sp_help_fulltext_tables', 'sp_MSdroparticletriggers', 'sp_dropdevice', 'sp_MSbelongs', 'sp_MSadjustmergeidentity', 'sp_MSvalidate_subscription', 'sp_MSdrop_distributor_alerts_and_responses', 'sp_help_fulltext_tables_cursor', 'sp_mergesubscription_cleanup', 'sp_dropmessage', 'sp_MSexpandbelongs', 'sp_helpallowmerge_publication', 'sp_MSscript_insert_statement', 'sp_adddistributor', 'sp_help_fulltext_columns', 'sp_subscription_cleanup', 'sp_droptype', 'sp_MSexpandnotbelongs', 'sp_MSgettranlastupdatedtime', 'sp_helpmergearticle', 'sp_script_insertforcftresolution', 'sp_changedistributor_property', 'sp_help_fulltext_columns_cursor', 'sp_get_distributor', 'sp_dropremotelogin', 'sp_MSsetupbelongs_withoutviewproc', 'sp_MSgetmergelastupdatedtime', 'sp_dropmergearticle', 'sp_MSscript_insert_subwins', 'sp_helpdistributor_properties', 'sp_trace_getdata', 'sp_MSrepl_addrolemember', 'sp_helpconstraint', 'sp_MSsetupnotbelongs', 'sp_MSgetlastupdatedtime', 'sp_addmergepublication', 'sp_MSis_identity_insert', 'sp_dropdistributor', 'sp_describe_cursor', 'sp_MSrepl_droprolemember', 'sp_MSsetupworktables', 'sp_changemergepublication', 'sp_MSscript_compensating_send', 'sp_helpdistributiondb', 'sp_describe_cursor_columns', 'sp_table_validation', 'sp_MSsetupbelongs', 'sp_helpmergepublication', 'sp_MSscriptinsertconflictfinder', 'sp_changedistributiondb', 'sp_describe_cursor_tables', 'sp_dropwebtask', 'sp_removedbreplication', 'sp_MSaddinitialarticle', 'sp_dropmergepublication', 'sp_MSscript_insert_pubwins', 'sp_dropdistributiondb', 'sp_cursor_list', 'sp_runwebtask', 'sp_MScleandbobjectsforreplication', 'sp_MSaddinitialschemaarticle', 'sp_mergearticlecolumn', 'sp_MSscript_update_statement', 'sp_adddistributiondb', 'sp_cleanupwebtask', 'sp_removesrvreplication', 'sp_MSaddinitialpublication', 'sp_helpmergearticlecolumn', 'sp_scriptpubwinsrefreshcursorvars', 'sp_dropdistpublisher', 'sp_enumcodepages', 'sp_MSremovedbreplication', 'sp_MSaddinitialsubscription', 'sp_MSreinitmergepublication', 'sp_MSscript_update_subwins', 'sp_adddistpublisher', 'sp_convertwebtasks', 'sp_vupgrade_subscription_databases', 'sp_MSmakearticleprocs', 'sp_MSreinit_hub', 'sp_MSscriptupdateconflictfinder', 'sp_changedistpublisher', 'sp_readwebtask', 'sp_MScopyregvalue', 'sp_MSupdatesysmergearticles', 'sp_MSreplcheckoffloadserver', 'sp_reinitmergesubscription', 'sp_MSscript_update_pubwins', 'sp_helpdistpublisher', 'sp_vupgrade_registry', 'sp_MSexclause', 'sp_MSpublicationview', 'sp_MSscript_delete_statement', 'sp_add_agent_profile', 'sp_vupgrade_subscription_tables', 'sp_helpdb', 'sp_MSgetcolordinalfromcolname', 'sp_MSget_file_existence', 'sp_addmergesubscription', 'sp_MSscript_delete_subwins', 'sp_drop_agent_parameter', 'sp_vupgrade_mergetables', 'sp_helpdevice', 'sp_MSinsertbeforeimageclause', 'sp_MSrepl_isdbowner', 'sp_MSretrieve_mergepublication', 'sp_MSscriptdelconflictfinder', 'sp_drop_agent_profile', 'sp_vupgrade_subpass', 'sp_helpfile', 'sp_MScreatedupkeyupdatequery', 'sp_resyncmergesubscription', 'sp_changemergesubscription', 'sp_MSscript_compensating_insert', 'sp_help_agent_profile', 'sp_vupgrade_MSsubscription_properties', 'sp_helpfilegroup', 'sp_MSmakeinsertproc', 'sp_MSget_qualified_name', 'sp_helpmergesubscription', 'sp_MSscript_delete_pubwins', 'sp_help_agent_default', 'sp_vupgrade_replication', 'sp_helpgroup', 'sp_MSmakeupdateproc', 'sp_MSdrop_object', 'sp_dropmergesubscription', 'sp_MSscript_beginproc', 'sp_MSupdate_agenttype_default', 'sp_vupgrade_distdb', 'sp_helplog', 'sp_MSmakeselectproc', 'sp_isarticlecolbitset', 'sp_MShelpvalidationdate', 'sp_MSscript_security', 'sp_generate_agent_parameter', 'sp_vupgrade_publisher', 'sp_helplogins', 'sp_MSdropconstraints', 'sp_getarticlepkcolbitmap', 'sp_MSmergepublishdb', 'sp_MSscript_endproc', 'sp_MSvalidate_agent_parameter', 'sp_vupgrade_syscol_status', 'sp_helpindex', 'sp_MSinsertschemachange', 'sp_MSsubst_filter_name', 'sp_enumcustomresolvers', 'sp_MStable_not_modifiable', 'sp_add_agent_parameter', 'sp_vupgrade_publisherdb', 'sp_helpstats', 'sp_MSgetviewcolumnlist', 'sp_MSsubst_filter_names', 'sp_msupg_removesystemcomputedcolumns', 'sp_changemergefilter', 'sp_MSscript_ExecutionMode_stmt', 'sp_change_agent_parameter', 'sp_vupgrade_replmsdb', 'sp_objectfilegroup', 'sp_MSvalidatearticle', 'sp_MSreplcheck_name', 'sp_addmergefilter', 'sp_MSscript_sync_ins_proc', 'sp_change_agent_profile', 'sp_restoredbreplication', 'sp_help', 'sp_MSsubscriptionvalidated', 'sp_MScheckvalidsystables', 'sp_dropmergefilter', 'sp_MSscript_sync_upd_proc', 'sp_help_agent_parameter', 'sp_MSget_publisher_rpc', 'sp_helprotect', 'sp_MSdroparticletombstones', 'sp_MSdrop_mergesystables', 'sp_helpmergefilter', 'sp_MSscript_sync_del_proc', 'sp_MShelp_distdb', 'sp_column_privileges', 'sp_link_publication', 'sp_MSproxiedmetadata', 'sp_MScreate_mergesystables', 'sp_MSscript_dri', 'sp_MSscript_pub_upd_trig', 'sp_MSupdate_replication_status', 'sp_MSreset_queue', 'sp_helpuser', 'sp_MScontractsubsnb', 'sp_MStestbit', 'sp_MSenumpubreferences', 'sp_MSmakeconflicttable', 'sp_MSenum_misc_agents', 'sp_MSreset_queued_reinit', 'sp_indexoption', 'sp_MSexpandsubsnb', 'sp_MSsetbit', 'sp_MSsubsetpublication', 'sp_scriptsubconflicttable', 'sp_MSload_replication_status', 'sp_MSinit_subscription_agent', 'sp_lock', 'sp_MSdelsubrows', 'sp_MSinsertcontents', 'sp_msupg_dropcatalogcomputedcols', 'sp_MSindexcolfrombin', 'sp_MSgen_sync_tran_procs', 'sp_MScreate_replication_status_table', 'sp_columns', 'sp_MSupdatelastsyncinfo', 'sp_getapplock', 'sp_MSdelsubrowsbatch', 'sp_MSupdatecontents', 'sp_msupg_createcatalogcomputedcols', 'sp_MSmakejoinfilter', 'sp_articlesynctranprocs', 'sp_MShelp_replication_status', 'sp_MSget_attach_state', 'sp_releaseapplock', 'sp_MSscriptviewproc', 'sp_MSdeletecontents', 'sp_msupg_recreatesystemviews', 'sp_MSmakeexpandproc', 'sp_reinitsubscription', 'sp_MSenum_replication_agents', 'sp_MSreset_attach_state', 'sp_logdevice', 'sp_MSmakeviewproc', 'sp_MSunmarkifneeded', 'sp_msupg_upgradecatalog', 'sp_MSdrop_expired_mergesubscription', 'sp_MSareallcolumnscomputed', 'sp_replication_agent_checkup', 'sp_MSset_subscription_properties', 'sp_helpremotelogin', 'sp_MScreatebeforetable', 'sp_MSunmarkreplinfo', 'sp_MScleanup_metadata', 'sp_MSgettypestringudt', 'sp_MScreate_replication_checkup_agent', 'sp_MSset_sub_guid', 'sp_helpsort', 'sp_MShelpcreatebeforetable', 'sp_MSmarkreplinfo', 'sp_helpmergecleanupwait', 'sp_gettypestring', 'sp_MSenum_replication_job')

--Objects in model database
SELECT so.name AS 'Object in model', su.name AS 'Owner user' FROM model.dbo.sysobjects so LEFT OUTER JOIN master.dbo.sysusers su ON so.uid = su.uid WHERE type != 'S' AND  so.name NOT IN ('syssegments', 'sysconstraints')

--Database users, logins and aliases
CREATE TABLE #tempusers (LoginName nvarchar(256), DbName nvarchar(256), UserName nvarchar(256), AliasName nvarchar(256)) INSERT INTO #tempusers
EXEC master..sp_msloginmappings
SELECT DbName AS 'Database', UserName AS 'User', LoginName AS 'Login', AliasName AS 'Alias' FROM #tempusers ORDER BY DBname, UserName
DROP TABLE #tempusers

--Logins with server roles
SELECT l.name AS 'Login with server role(s)', l.denylogin, l.sysadmin, l.securityadmin, l.serveradmin, l.setupadmin, l.processadmin, l.diskadmin, l.dbcreator, l.bulkadmin, l.isntname, l.isntgroup, l.isntuser, l.hasaccess, l.isntgroup, l.isntuser
FROM master.dbo.syslogins l 
WHERE l.sysadmin = 1 OR l.securityadmin = 1 OR l.serveradmin = 1 OR l.setupadmin = 1 OR l.processadmin = 1 OR l.diskadmin = 1 OR l.dbcreator = 1 OR l.bulkadmin = 1
ORDER BY l.isntgroup, l.isntname, l.isntuser

--DTS packages in msdb
CREATE TABLE #tempdts (name nvarchar(256), id nvarchar(256), versionid nvarchar(256), description nvarchar(256), createdate nvarchar(256), owner nvarchar(256), size bigint, packagedata image, isowner int, packagetype int) INSERT INTO #tempdts EXEC msdb..sp_enum_dtspackages
SELECT name AS 'DTS package in msdb', owner AS 'Owner', description AS 'Description' FROM #tempdts
DROP TABLE #tempdts

--Jobs
SELECT --job_id AS 'Id', 
sjv.name AS 'Job in msdb', 
sl.name AS 'Owner', 
sjv.enabled AS 'Enabled', 
sjv.description AS 'Description'
FROM msdb.dbo.sysjobs_view sjv
LEFT OUTER JOIN dbo.syslogins sl ON sjv.owner_sid = sl.sid

--Space used for each database
EXEC master.dbo.sp_MSforeachdb 'USE [?]; select @@servername AS ''Servername'', DB_NAME() AS ''Database'', [FileID], [File_Size_MB] = convert(decimal(12,2),round([size]/128.000,2)),
[Space_Used_MB] = convert(decimal(12,2),round(fileproperty([name],''SpaceUsed'')/128.000,2)),
[Free_Space_MB] = convert(decimal(12,2),round(([size]-fileproperty([name],''SpaceUsed''))/128.000,2)) ,
[Name], [FileName], convert(datetime,Getdate(),112) as DateInserted
from dbo.sysfiles'
