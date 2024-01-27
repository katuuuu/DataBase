use master;
go

if DB_ID (N'lab15_1') is not null
drop database lab15_1;
go

create database lab15_1 on (
	NAME = lab151dat,
	FILENAME = 'C:\sql\lab15\lab151.mdf',
	SIZE = 10,
	MAXSIZE = UNLIMITED,
	FILEGROWTH = 5
)
log on (
	NAME = lab151log,
	FILENAME = 'C:\sql\lab15\lab151log.ldf',
	SIZE = 5MB,
	MAXSIZE = 25MB,
	FILEGROWTH = 5MB
);
go

use master;
go

if DB_ID (N'lab15_2') is not null
	drop database lab15_2;
go

create database lab15_2 on (
	NAME = lab152dat,
	FILENAME = 'C:\sql\lab15\lab152.mdf',
	SIZE = 10,
	MAXSIZE = UNLIMITED,
	FILEGROWTH = 5
)
log on (
	NAME = lab152log,
	FILENAME = 'C:\sql\lab15\lab152log.ldf',
	SIZE = 5MB,
	MAXSIZE = 25MB,
	FILEGROWTH = 5MB
);
go

use lab15_1;
go

if OBJECT_ID(N'Workers', N'U') is not null
	drop table Workers;
go

create table Workers(
	WorkerID int not null primary key,
	NameWorker nvarchar(25) not null,
	SurnameWorker nvarchar(25) not null,
	PatronymicWorker nvarchar(25) not null,
	Position nvarchar(25) not null,
	HospitalID int not null
);
go

use lab15_2;
go

if OBJECT_ID(N'Hospitals', N'U') is not null
	drop table Hospitals;
go

create table Hospitals (
	HospitalID int not null primary key,
	HospitalName nvarchar(300) not null,
	Address nvarchar(200) not null,
	Email nvarchar(254) null,
	Phone char(10) not null
	);
go

if OBJECT_ID(N'HospitalWorkerView', N'V') is not null
	drop view HospitalWorkerView;
go

create view HospitalWorkerView as
	select A.WorkerID as WorkerID, A.NameWorker as Name, A.SurnameWorker as Surname, A.PatronymicWorker as Patronymic, A.Position as position, B.*
	from lab15_1.dbo.Workers as A, lab15_2.dbo.Hospitals B
	where A.HospitalID = B.HospitalID
go

if OBJECT_ID(N'InsertHospitals', N'TR') is not null
	drop trigger InsertHospitals
go

create trigger InsertHospitals
	on Hospitals
	instead of insert
as
	begin
		if exists (select * from Hospitals, inserted where Hospitals.HospitalID = inserted.HospitalID)
			begin
				exec sp_addmessage 50007, 17, 'Adding duplicate of hospital', @lang= 'us_english', @replace = 'REPLACE';
				raiserror(50007, 17, -1)
			end
		else
			insert into lab15_2.dbo.Hospitals(HospitalID, HospitalName, Address, Email, Phone)
			select HospitalID, HospitalName, Address, Email, Phone from inserted
			print 'New Hospital was added'
	end
go

if OBJECT_ID(N'DeleteHospitals', N'TR') is not null
	drop trigger DeleteHospitals
go

create trigger DeleteHospitals
	on Hospitals
	instead of delete
as
	begin
		delete B from lab15_1.dbo.Workers as B inner join deleted as D on B.HospitalID = D.HospitalID
		delete A from lab15_2.dbo.Hospitals as A inner join deleted as D on A.HospitalID = D.HospitalID
		print 'Hospital was deleted'
	end
go

if OBJECT_ID(N'UpdateHospitals', N'TR') is not null
	drop trigger UpdateHospitals
go

create trigger UpdateHospitals
	on Hospitals
	instead of update
as
	begin
		if (update(HospitalID))
			begin
				exec sp_addmessage 50009, 17, 'You cannot change data of Hospital if its already exists', @lang= 'us_english', @replace = 'REPLACE';
				raiserror(50009, 17, -1)
			end
		else
			begin
				update lab15_2.dbo.Hospitals set Phone = inserted.Phone from inserted where Hospitals.HospitalID = inserted.HospitalID
				update lab15_2.dbo.Hospitals set Address = inserted.Address from inserted where Hospitals.HospitalID = inserted.HospitalID
				update lab15_2.dbo.Hospitals set Email = inserted.Email from inserted where Hospitals.HospitalID = inserted.HospitalID
			end
	end
go

use lab15_1;
go

if OBJECT_ID(N'InsertWorkers', N'TR') is not null
	drop trigger InsertWorkers
go

create trigger InsertWorkers
	on Workers
	instead of insert
as
	begin
		if exists( select * from Workers, inserted where Workers.WorkerID = inserted.WorkerID)
			begin
				exec sp_addmessage 50010,17, 'Trying to add duplicate', @lang='us_english', @replace = 'REPLACE';
				raiserror(50010,17,-1)
			end
		else
			if exists (select HospitalID from inserted where HospitalID not in 
						(select HospitalID from lab15_2.dbo.Hospitals))
				begin
					exec sp_addmessage 50012,17, 'Trying to add worker to not existing hospital', @lang='us_english', @replace='REPLACE';
					raiserror(50012,17,-1)
				end
			else
				insert into Workers(WorkerID, NameWorker, SurnameWorker, PatronymicWorker, Position, HospitalID)
				select WorkerID, NameWorker, SurnameWorker, PatronymicWorker, Position, HospitalID from inserted
				print 'New worker was added'
	end
go


if OBJECT_ID(N'DeleteWorkers', N'TR') is not null
	drop trigger DeleteWorkers
go

create trigger DeleteWorkers
	on Workers
	instead of delete
as
	begin
		delete B from lab15_1.dbo.Workers as B inner join deleted as D on B.WorkerID = D.WorkerID
		print 'Worker was deleted'
	end
go


if OBJECT_ID(N'UpdateWorkers', N'TR') is not null
	drop trigger UpdateWorkers
go

create trigger UpdateWorkers
	on Workers
	instead of update
as
	begin
		if (update(WorkerID) or update(NameWorker) or update(PatronymicWorker) or update (HospitalID))
			begin
				exec sp_addmessage 50014, 17, 'You cannot change main data of worker', @lang= 'us_english', @replace = 'REPLACE';
				raiserror(50014, 17, -1)
			end
		else
			if (update(SurnameWorker))
				begin
					update lab15_1.dbo.Workers set SurnameWorker = inserted.SurnameWorker from inserted where Workers.WorkerID = inserted.WorkerID
					print 'Surname was changed'
				end
			else
				begin
					update lab15_1.dbo.Workers set Position = inserted.Position from inserted where Workers.WorkerID = inserted.WorkerID
					print 'Position was changed'
				end
	end
go

insert into lab15_2.dbo.Hospitals(HospitalID,HospitalName, Address, Email, Phone)
values  (1,'Litfonda vzroslaya filial 1', 'Krasnoarmeyskaya street, 3', 'litfondv1@mail.ru', '9099346755'),
		(2,'Litfonda detskaya filial 1', 'Krasnoarmeyskaya street, 6', 'litfondd1@mail.ru', '9099348955'),
		(3,'Litfonda vzroslaya filial 3', 'Arbatskaya street, 15', null , '9099346895'),
		(4,'Litfonda detskaya filial 5', 'Chasovaya street, 10', 'litfondd5@mail.ru', '9099506578')
go

update lab15_2.dbo.Hospitals set Phone = '8005355535' where Address = 'Arbatskaya street, 15'
go



--update lab15_2.dbo.Hospitals set HospitalID = 3 where HospitalID = 1
--go




insert into lab15_1.dbo.Workers(WorkerID, NameWorker, SurnameWorker, PatronymicWorker, Position, HospitalID)
values (1, 'Aleksandr', 'Durov', 'Viktorovich', 'Kardiolog', 1),
		(2, 'Boris', 'Bulkin', 'Alekseevich', 'Nevrolog', 2),
		(3, 'Pavel', 'Durov', 'Sergeevich', 'Pediatr', 4),
		(4, 'Andrey', 'Egorov', 'Viktorovich', 'Ortoped', 1),
		(5, 'Roman', 'Kiselev', 'Sergeevich', 'Terapevt', 3)
go

--update lab15_1.dbo.Workers set PatronymicWorker = 'Andreevich' where NameWorker = 'Pavel'
--go

insert into lab15_1.dbo.Workers(WorkerID,NameWorker,SurnameWorker,PatronymicWorker,Position,HospitalID)
values (6, 'Maria', 'Sivaeva', 'Alekseevna', 'Ginekolog', 1)
go

update lab15_1.dbo.Workers set SurnameWorker = 'Durova' where NameWorker = 'Maria'
go

--update lab15_1.dbo.Workers set NameWorker = 'Leonid' where NameWorker = 'Pavel'
--go

delete from lab15_1.dbo.Workers where WorkerID = 1
go


select * from lab15_2.dbo.Hospitals;
select * from lab15_1.dbo.Workers;
go
