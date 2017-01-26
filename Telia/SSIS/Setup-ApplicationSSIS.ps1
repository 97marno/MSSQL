# =====================================================================================================================
# 	This script creates users for SSIS and enable rights for the user in correct DB.
#	USAGE 
#	Find %PSModulePath via the command $env:PSModulePath
#	Copy the TS-MSQ module to %PSModulePath%
# 	Copy this script to local server (example %temp%)
#	Load the script:
#		PS C:\temp>. .\Setup-ApplicationSSIS.ps1
#	Run the script with correct variables
#		PS C:\temp> setup-applicationSSIS -S sehan5187clv007 -I SQL7 -Dbs "DIS2" -Env prod -App DIS -SqlUser -ActiveX -CmdExec -SSASCmd -SSASQuery -PowerShell 
#======================================================================================================================


Function Setup-ApplicationSSIS {

Param (
	[Parameter(Position=0, Mandatory=$true)] [Alias("S")] $Server #sehan5643clv001
	, [Parameter(Position=1, Mandatory=$true)] [Alias("I")] $Instance #SQL1
    , [Parameter(Position=2, Mandatory=$true)] [Alias("Dbs")] $Databases #"CRM_Prod1,CRM_Prod2"
    , [Parameter(Position=3, Mandatory=$true)] [Alias("Env")] $Environment #prod
    , [Parameter(Position=4, Mandatory=$true)] [Alias("App")] $Application #Crm
    , [Switch]$SqlUser
    , [Switch]$ActiveX
    , [Switch]$CmdExec
    , [Switch]$SSASCmd
    , [Switch]$SSASQuery
    , [Switch]$PowerShell)


#Variable settings    
$CluNo = $Server.Substring(5,4)
$InstanceGroup = 'ODP_SQL_SSIS_' + $CluNo + '_' + $Instance.ToUpper()
$Databases = $Databases -Replace " ","" #Remove blanks
$AppDb = $Databases.Split(',') #Convert to array
$ProxyGroup = 'ODP_SSIS_PROXY_ACCOUNTS_' + $CluNo
$AppGroup = 'ODP_SSIS_' + $Application.ToUpper() + '_' + $Environment.ToUpper()
$AppUser = 'adm_' + $Application.ToLower() + $Environment.ToLower()
$AppMsdbRole = 'ssis_' + $Application.ToLower()
$CredUser = 'sys' + $Environment.ToLower() + $Application.ToUpper()
If ($SqlUser) { $SqlLogin = $Application.ToLower() + $Environment.ToLower() + '_admin' }
$Credential = $Application.ToUpper()
$Proxy = $Credential
$UserAndPw = @{} #Hash table to display created users and pw

#Output file
$OutputFile = ".\" + $Server + "-" + $Instance + "-" + $Application + "-" + $Environment + "-" + (Get-Date -format "yyyyMMdd-HHmmss")
$QueryFile = $OutputFile + ".sql"
$OutputFile = $OutputFile + ".txt"
Write-Output "" | Out-File -Append $OutputFile
Write-Output "Server:`t`t$Server\$Instance" | Out-File -Append $OutputFile
Write-Output "Databases:`t$AppDb" | Out-File -Append $OutputFile
Write-Output "" | Out-File -Append $OutputFile
Write-Output "Instance AD Group:`tTCAD\$InstanceGroup" | Out-File -Append $OutputFile
Write-Output "Proxy AD Group:`t`tTCAD\$ProxyGroup" | Out-File -Append $OutputFile
Write-Output "" | Out-File -Append $OutputFile
Write-Output "Proxy:`t`t`t$Proxy" | Out-File -Append $OutputFile
Write-Output "Credential:`t`t$Credential" | Out-File -Append $OutputFile
Write-Output "Credential AD account:`tTCAD\$CredUser" | Out-File -Append $OutputFile
Write-Output "" | Out-File -Append $OutputFile
Write-Output "Proxy Active subsystems: " | Out-File -Append $OutputFile
Write-Output " SSIS package Execution" | Out-File -Append $OutputFile
If ($ActiveX) { Write-Output " ActiveX Script" | Out-File -Append $OutputFile }
If ($CmdExec) { Write-Output " Operating System (CmdExec)" | Out-File -Append $OutputFile }
If ($SSASCmd) { Write-Output " Analysis Services Command" | Out-File -Append $OutputFile }
If ($SSASQuery) { Write-Output " Analysis Services Query" | Out-File -Append $OutputFile }
If ($PowerShell) { Write-Output " PowerShell" | Out-File -Append $OutputFile }
Write-Output "" | Out-File -Append $OutputFile
Write-Output "Application AD Group:`t`tTCAD\$AppGroup" | Out-File -Append $OutputFile
Write-Output "Application AD User:`t`tTCAD\$AppUser" | Out-File -Append $OutputFile
Write-Output "Application Msdb Role:`t`t$AppMsdbRole" | Out-File -Append $OutputFile
Write-Output "Application Job category:`t$Application" | Out-File -Append $OutputFile
If ($SqlUser) { Write-Output "Application SQL login:`t`t$SqlLogin" | Out-File -Append $OutputFile }

#Variable example
    # $CluNo = 5643
    # $InstanceGroup = ODP_SQL_SSIS_5643_SQL1
    # $AppDb = array of database names
    # $ProxyGroup = ODP_SSIS_PROXY_ACCOUNTS_5643
    # $AppGroup = ODP_SSIS_CRM_PROD
    # $AppUser = adm_crmprod
    # $AppMsdbRole = ssis_crm
    # $Application = Crm (used as Job category)
    # $CredUser = sysprodCRM
    # $SqlLogin = crmprod_admin
    # $Credential = CRM
    # $Proxy = CRM

#Taskflow
    #Active Directory
        #Create AppGroup in Active Directory + membership
        #Create AppUser in Active Directory + membership
        #Create CredUser in Active Directory + memberships

	#SQL Server
		#Create login CredUser
		#Create login AppUser
		#Create Credential
		#Create Proxy
		#Grant additional subsystems
		#Create AppMsdbRole
		#Add AppGroup as login and user in msdb, assign ssis roles
		#Create Job Category
		#Make CredUser and AppUser alias dbo in user database(s)
		#Create SqlLogin (if), assign to all three msdb roles
		#Make alias dbo in user database(s)

#Start of tasks

#Import modules
Import-Module TS-MSSQL #Get-RandomString

#Load Snapins
If ((Get-PSSnapin -Name SqlServerCmdletSnapin100 -ErrorAction SilentlyContinue) -eq $null){
    Add-PSSnapin SqlServerCmdletSnapin100
}

#Active Directory

#Verify if module ActiveDirectory is available or not
If ((Get-WMIObject Win32_OperatingSystem).Version -ge '6.1'){ #Windows 2008 R2 or above, Check for module ActiceDirectory
    Import-Module ServerManager
    If ((Get-WindowsFeature RSAT-AD-PowerShell).Installed -eq $true) {
	    $AD = $true
    }
    Else  { $AD = $false }
}
Else { $AD = $false }

#Creating objects in AD
If ($AD){ #Windows 2008 R2 or above, Use module ActiceDirectory
    
    Import-Module ActiveDirectory

    #Create AppGroup in Active Directory + membership
    $AdPath = "OU=ODP-SSIS,OU=KCDB,OU=SystemAccounts,DC=tcad,DC=telia,DC=se"
    $Desc = "SSIS users for application " + $Application.ToUpper()
    New-ADGroup -Name $AppGroup -SamAccountName $AppGroup -GroupCategory Security -GroupScope Universal -DisplayName $AppGroup -Path $AdPath -Description $Desc
    Add-ADGroupMember $InstanceGroup $AppGroup

    #Create AppUser in Active Directory + membership
    $pwplain = Get-RandomString -Length 8 -UpperCase -Numbers -Symbols
    $pwsecure = $pwplain | ConvertTo-SecureString -AsPlainText -Force
    $UserAndPw.Add("TCAD\"+$AppUser,$pwplain)
    $Desc = "SSIS user for application " + $Application.ToUpper()
    $Principal = $AppUser + "@tcad.telia.se"
    New-ADUser -Name $AppUser -GivenName $AppUser -DisplayName $AppUser -SamAccountName $AppUser -UserPrincipalName $Principal -Enabled $true -AccountPassword $pwsecure -PasswordNeverExpires $true -CannotChangePassword $false -Path $AdPath -Description $Desc
    Add-ADGroupMember $AppGroup $AppUser

    #Create CredUser in Active Directory + memberships
    $pwplain = Get-RandomString -Length 16 -UpperCase -Numbers -Symbols
    $pwsecure = $pwplain | ConvertTo-SecureString -AsPlainText -Force
    $UserAndPw.Add("TCAD\"+$CredUser,$pwplain)
    $Desc = "SSIS proxy account for " + $Application
    $Principal = $CredUser + "@tcad.telia.se"
    $Surname = "System Account"
    $Name = $Surname + ", " + $CredUser
    New-ADUser -SamAccountName $CredUser -Name $Name -GivenName $CredUser -Surname $Surname -DisplayName $Name -UserPrincipalName $Principal -Enabled $true -AccountPassword $pwsecure -PasswordNeverExpires $true -CannotChangePassword $true -Path $AdPath -Description $Desc
    Add-ADGroupMember $ProxyGroup $CredUser
    Add-ADGroupMember $AppGroup $CredUser

    $Name | Write-Output
}
Else { #Windows version below 2008 R2 or module ActiveDirectory not available, Use dsadd

    #Create AppGroup in Active Directory + membership
    $AdPath = "OU=ODP-SSIS,OU=KCDB,OU=SystemAccounts,DC=tcad,DC=telia,DC=se"
    $Desc = "SSIS users for application " + $Application.ToUpper()
    $Cmd = "dsadd group cn=`"" + $AppGroup + "," + $AdPath + "`" -samid `"" + $AppGroup + "`" -memberof cn=`"" + $InstanceGroup + "," + $AdPath + "`" -secgrp yes -scope u -desc `"" + $Desc + "`" -q"
    CMD /C $Cmd

    #Create AppUser in Active Directory + membership
    $pwplain = Get-RandomString -Length 8 -UpperCase -Numbers -Symbols
    $pwsecure = $pwplain | ConvertTo-SecureString -AsPlainText -Force
    $UserAndPw.Add("TCAD\"+$AppUser,$pwplain)
    $Desc = "SSIS user for application " + $Application.ToUpper()
    $Principal = $AppUser + "@tcad.telia.se"
    $Cmd = "dsadd user cn=`"" + $AppUser + "," + $AdPath + "`" -samid `"" + $AppUser + "`" -display `"" + $AppUser + "`" -upn `"" + $Principal + "`" -fn `"" + $AppUser + "`" -pwd `"" + $pwplain + "`" -canchpwd yes -memberof cn=`"" + $AppGroup + "," + $AdPath + "`" -pwdneverexpires yes -disabled no -desc `"" + $Desc + "`" -q"
    CMD /C $Cmd

    #Create CredUser in Active Directory + memberships
    $pwplain = Get-RandomString -Length 16 -UpperCase -Numbers -Symbols
    $pwsecure = $pwplain | ConvertTo-SecureString -AsPlainText -Force
    $UserAndPw.Add("TCAD\"+$CredUser,$pwplain)
    $Desc = "SSIS proxy account for " + $Application
    $Principal = $CredUser + "@tcad.telia.se"
    $Surname = "System Account"
    $DisplayName = $Surname + ", " + $CredUser
    $Name = $Surname + "\, " + $CredUser
    $Cmd = "dsadd user cn=`"" + $Name + "," + $AdPath + "`" -samid `"" + $CredUser + "`" -display `"" + $DisplayName + "`" -upn `"" + $Principal + "`" -fn `"" + $CredUser + "`" -ln `"" + $SurName + "`" -pwd `"" + $pwplain + "`" -canchpwd yes -memberof cn=`"" + $AppGroup + "," + $AdPath + "`" cn=`"" + $ProxyGroup + "," + $AdPath + "`" -pwdneverexpires yes -disabled no -desc `"" + $Desc + "`" -q"
    CMD /C $Cmd
} #End creating objects in AD

Start-Sleep -Seconds 10 #Needed to find newly created AD user from within SQL Server

#SQL Server
$SqlServer = $Server + "\" + $Instance

#Create login CredUser
$Query = @"
--Create login TCAD\$CredUser and add as user in msdb with ssis roles
USE [master]
GO
CREATE LOGIN [TCAD\$CredUser] FROM WINDOWS WITH DEFAULT_DATABASE=[msdb]
GO
USE [msdb]
GO
CREATE USER [TCAD\$CredUser] FOR LOGIN [TCAD\$CredUser]
GO
EXEC sp_addrolemember N'db_ssisltduser', N'TCAD\$CredUser'
GO
EXEC sp_addrolemember N'SQLAgentUserRole', N'TCAD\$CredUser'
GO
"@
Invoke-Sqlcmd -ServerInstance $SqlServer -Query $Query
Write-Output "$Query" | Out-File -Append $QueryFile

#Create login AppUser
$Query = @"
--Create login TCAD\$AppUser
USE [master]
GO
CREATE LOGIN [TCAD\$AppUser] FROM WINDOWS WITH DEFAULT_DATABASE=[tempdb]
GO
"@
Invoke-Sqlcmd -ServerInstance $SqlServer -Query $Query
Write-Output "$Query" | Out-File -Append $QueryFile

#Create Credential
$pwplain = $UserAndPw.Item($CredUser)
$Query = @"
--Create credential $Credential
USE [master]
GO
CREATE CREDENTIAL $Credential WITH IDENTITY = 'TCAD\$CredUser', SECRET = N'$pwplain' 
GO
"@
Invoke-Sqlcmd -ServerInstance $SqlServer -Query $Query
Write-Output "$Query" | Out-File -Append $QueryFile

#Create Proxy
$Query = @"
--Create proxy $Proxy, with credential $Credential and add subsystem SSIS Package Execution
USE [msdb]
GO
EXEC msdb.dbo.sp_add_proxy @proxy_name=N'$Proxy',@credential_name=N'$Credential', @enabled=1
GO
EXEC msdb.dbo.sp_grant_proxy_to_subsystem @proxy_name=N'$Proxy', @subsystem_id=11
GO
"@
Invoke-Sqlcmd -ServerInstance $SqlServer -Query $Query
Write-Output "$Query" | Out-File -Append $QueryFile

#Grant additional subsystems
If ($ActiveX) {
    $Query = @"
    --Add proxy active subsystem ActiveX
    USE [msdb]
    GO
    EXEC msdb.dbo.sp_grant_proxy_to_subsystem @proxy_name=N'$Proxy', @subsystem_id=2
    GO
"@
    Invoke-Sqlcmd -ServerInstance $SqlServer -Query $Query
    Write-Output "$Query" | Out-File -Append $QueryFile

}
If ($CmdExec) {
    $Query = @"
    --Add proxy active subsystem CmdExec
    USE [msdb]
    GO
    EXEC msdb.dbo.sp_grant_proxy_to_subsystem @proxy_name=N'$Proxy', @subsystem_id=3
    GO
"@
    Invoke-Sqlcmd -ServerInstance $SqlServer -Query $Query
    Write-Output "$Query" | Out-File -Append $QueryFile
}
If ($SSASCmd) {
    $Query = @"
    --Add proxy active subsystem SSASCmd
    USE [msdb]
    GO
    EXEC msdb.dbo.sp_grant_proxy_to_subsystem @proxy_name=N'$Proxy', @subsystem_id=10
    GO
"@
Invoke-Sqlcmd -ServerInstance $SqlServer -Query $Query
Write-Output "$Query" | Out-File -Append $QueryFile
}
If ($SSASQuery) {
    $Query = @"
    --Add proxy active subsystem SSASQuery
    USE [msdb]
    GO
    EXEC msdb.dbo.sp_grant_proxy_to_subsystem @proxy_name=N'$Proxy', @subsystem_id=9
    GO
"@
Invoke-Sqlcmd -ServerInstance $SqlServer -Query $Query
Write-Output "$Query" | Out-File -Append $QueryFile
}
If ($PowerShell) {
    $Query = @"
    --Add proxy active subsystem PowerShell
    USE [msdb]
    GO
    EXEC msdb.dbo.sp_grant_proxy_to_subsystem @proxy_name=N'$Proxy', @subsystem_id=12
    GO
"@
Invoke-Sqlcmd -ServerInstance $SqlServer -Query $Query
Write-Output "$Query" | Out-File -Append $QueryFile
}

#Create AppMsdbRole
$Query = @"
--Create role $AppMsdbRole in msdb with TCAD\$CredUser as owner and member, make principle in Proxy
USE [msdb]
GO
CREATE ROLE [$AppMsdbRole] AUTHORIZATION [TCAD\$CredUser]
GO
EXEC msdb.dbo.sp_grant_login_to_proxy @proxy_name=N'$Proxy', @msdb_role=N'$AppMsdbRole'
GO
EXEC sp_addrolemember N'$AppMsdbRole', N'TCAD\$CredUser'
GO
"@
Invoke-Sqlcmd -ServerInstance $SqlServer -Query $Query
Write-Output "$Query" | Out-File -Append $QueryFile

#Add AppGroup as login and user in msdb, assign ssis roles
$Query = @"
--Create login TCAD\$AppGroup and user in msdb with ssis roles
USE [master]
GO
CREATE LOGIN [TCAD\$AppGroup] FROM WINDOWS WITH DEFAULT_DATABASE=[msdb]
GO
USE [msdb]
GO
CREATE USER [TCAD\$AppGroup] FOR LOGIN [TCAD\$AppGroup]
GO
EXEC sp_addrolemember N'db_ssisltduser', N'TCAD\$AppGroup'
GO
EXEC sp_addrolemember N'SQLAgentUserRole', N'TCAD\$AppGroup'
GO
EXEC sp_addrolemember N'$AppMsdbRole', N'TCAD\$AppGroup'
GO
"@
Invoke-Sqlcmd -ServerInstance $SqlServer -Query $Query
Write-Output "$Query" | Out-File -Append $QueryFile

#Create Job Category
$Query = @"
USE [msdb]
GO
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'$Application' AND category_class=1)
    BEGIN
       EXEC  msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'$Application'
    END
GO
"@
Invoke-Sqlcmd -ServerInstance $SqlServer -Query $Query
Write-Output "$Query" | Out-File -Append $QueryFile

#Make CredUser and AppUser alias dbo in user database(s)
Foreach ($Dbn in $AppDb) {
    $Query = @"
    --Add user TCAD\$CredUser and TCAD\$AppUser in database $Dbn, give dbo privileges
    USE [$Dbn]
    GO
    CREATE USER [TCAD\$CredUser] FOR LOGIN [TCAD\$CredUser] WITH DEFAULT_SCHEMA=[dbo]
    GO
    EXEC sp_addrolemember N'db_owner', N'TCAD\$CredUser'
    GO
    CREATE USER [TCAD\$AppUser] FOR LOGIN [TCAD\$AppUser] WITH DEFAULT_SCHEMA=[dbo]
    GO
    EXEC sp_addrolemember N'db_owner', N'TCAD\$AppUser'
    GO
"@
    Invoke-Sqlcmd -ServerInstance $SqlServer -Query $Query
    Write-Output "$Query" | Out-File -Append $QueryFile
}

#Create SqlLogin (if), assign to all three msdb roles
If ($SqlUser) {
    $pw = Get-RandomString -Length 8 -UpperCase -Numbers -Symbols
    $Query = @"
    --Create login $SqlLogin and as user in msdb, assign msdb roles
    USE [master]
    GO
    CREATE LOGIN [$SqlLogin] WITH PASSWORD=N'$pw', DEFAULT_DATABASE=[tempdb], CHECK_EXPIRATION=OFF, CHECK_POLICY=ON
    GO
    USE [msdb]
    GO
    CREATE USER [$SqlLogin] FOR LOGIN [$SqlLogin]
    GO
    EXEC sp_addrolemember N'$AppMsdbRole', N'$SqlLogin'
    GO
    EXEC sp_addrolemember N'db_ssisltduser', N'$SqlLogin'
    GO
    EXEC sp_addrolemember N'SQLAgentUserRole', N'$SqlLogin'
    GO
"@
    Invoke-Sqlcmd -ServerInstance $SqlServer -Query $Query
    Write-Output "$Query" | Out-File -Append $QueryFile
    #Put user and password in array for display and/or send to Phelper
    $UserAndPw.Add($SqlLogin,$pw)

    #Make alias dbo in user database(s)
    Foreach ($Dbn in $AppDb) {
        $Query = @"
        --Add user $SqlLogin in database $Dbn, give dbo privileges
        USE [$Dbn]
        GO
        CREATE USER [$SqlLogin] FOR LOGIN [$SqlLogin] WITH DEFAULT_SCHEMA=[dbo]
        GO
        EXEC sp_addrolemember N'db_owner', N'$SqlLogin'
        GO
"@
        Invoke-Sqlcmd -ServerInstance $SqlServer -Query $Query
        Write-Output "$Query" | Out-File -Append $QueryFile
    }
}


#Display created users and passwords
Write-Output $UserAndPw | Out-File -Append $OutputFile

#Display popup reminder
$Reminder = new-object -comobject wscript.shell
$Reminder.popup("Script executed. Note, remember to:`r`n`r`n  - Restart SSIS Service on all cluster nodes for remote access.`r`n  - Add TCAD\$CredUser in Phelper.`r`n  - Clear output files due to passwords.",0,"$ThisScript",0)

} #End Function Setup-ApplicationSSIS
