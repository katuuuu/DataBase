use lab10;
go

set transaction isolation level read uncommitted 
begin transaction
	select * from Hospitals
	select resource_type, resource_subtype, request_mode from sys.dm_tran_locks
commit transaction
go

--set transaction isolation level read committed
--set transaction isolation level repeatable read
set transaction isolation level serializable

begin transaction
	select * from Hospitals
	waitfor delay '00:00:05'
	select * from Hospitals
	select resource_type, resource_subtype, request_mode from sys.dm_tran_locks
commit transaction
go