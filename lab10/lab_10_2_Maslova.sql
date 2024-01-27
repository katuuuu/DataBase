use lab10


--������� ������

begin transaction
	update Hospitals set HospitalName = 'TestName' where Email = NULL
	waitfor delay '00:00:05'
	select resource_type, resource_subtype, request_mode from sys.dm_tran_locks
rollback transaction

--����������������� ������

begin transaction
	update Hospitals set Phone = '8005355555' where Phone = '9099506578'
	select resource_type, resource_subtype, request_mode from sys.dm_tran_locks
commit transaction

--��������� ������

begin transaction
	insert into Hospitals(HospitalID, HospitalName, Address, Email, Phone)
	values(5, 'Litfonda vzroslaya filial 4', 'Peschanaya street,10', 'litfondv4@mail.ru', '9099502985')
	select resource_type, resource_subtype, request_mode from sys.dm_tran_locks
commit transaction
go

select * from Hospitals
go