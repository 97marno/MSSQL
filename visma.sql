--select * from ProgramUser where Firstname ='Per'

select TimeCodeId, TimeCodeName from TimeCode

select * from project where datepart(yy, Datestart) = 2016

select CustomerId, CustomerName from customer 
order by CustomerID
 
select * from project where projectid ='89961'

select * from activity

SELECT DateOfReport, CustomerId, ActivityId, TimeCodeId, HourOfReport FROM [SPCS_Tid_Ftg4].[dbo].[TimeReport] 
where ProgramUserId = '89989' and datepart(yy, DateOfReport) = 2017 and datepart(mm, dateofreport) = 01
/****** 
SELECT * FROM record 
WHERE  (DATEPART(yy, register_date) = 2009
AND    DATEPART(mm, register_date) = 10
AND    DATEPART(dd, register_date) = 10)
89989
******/


