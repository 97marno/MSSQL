EXEC msdb.dbo.sp_grant_proxy_to_subsystem
@proxy_name=N'TUPP',
@subsystem_id=11 --subsystem 11 is for SSIS as you can see in the above image
GO
--View all the proxies granted to all the subsystems
EXEC dbo.sp_enum_proxy_for_subsystem 


USE msdb ;
GO

EXEC dbo.sp_grant_login_to_proxy
    @login_name = N'tupp_admin',
    @proxy_name = N'TUPP' ;
GO