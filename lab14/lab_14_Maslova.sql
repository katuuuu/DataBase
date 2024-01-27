use master;
go

if DB_ID (N'lab14_1') is not null
drop database lab14_1;
go

create database lab14_1 on (
	NAME = lab141dat,
	FILENAME = 'C:\sql\lab14\lab141.mdf',
	SIZE = 10,
	MAXSIZE = UNLIMITED,
	FILEGROWTH = 5
)
log on (
	NAME = lab141log,
	FILENAME = 'C:\sql\lab14\lab141log.ldf',
	SIZE = 5MB,
	MAXSIZE = 25MB,
	FILEGROWTH = 5MB
);
go

use master;
go

if DB_ID (N'lab14_2') is not null
	drop database lab14_2;
go

create database lab14_2 on (
	NAME = lab142dat,
	FILENAME = 'C:\sql\lab14\lab142.mdf',
	SIZE = 10,
	MAXSIZE = UNLIMITED,
	FILEGROWTH = 5
)
log on (
	NAME = lab142log,
	FILENAME = 'C:\sql\lab14\lab142log.ldf',
	SIZE = 5MB,
	MAXSIZE = 25MB,
	FILEGROWTH = 5MB
);
go

use lab14_1;
go

if OBJECT_ID(N'Hospitals', N'U') is not null
	drop table Hospitals;
go


create table Hospitals (
	HospitalID int primary key not null,
	HospitalName nvarchar(300) not null,
	Address nvarchar(200) not null
	);
go

use lab14_2;
go

if OBJECT_ID(N'Hospitals', N'U') is not null
	drop table Hospitals;
go


create table Hospitals (
	HospitalID int primary key,
	Email nvarchar(254) null,
	Phone char(10) not null,
	Rating float not null
	);
go

if OBJECT_ID(N'HospitalsView', N'V') is not null
	drop view HospitalsView;
go

create view HospitalsView as
	select A.*, B.Email, B.Phone, B.Rating
	from lab14_1.dbo.Hospitals A, lab14_2.dbo.Hospitals B
	where A.HospitalID = B.HospitalID
go

select * from HospitalsView

if OBJECT_ID(N'InsertHospitalsView', N'TR') is not null
	drop trigger InsertHospitalsView;
go

create trigger InsertHospitalsView
	on HospitalsView
	instead of insert
as 

	begin
		if exists (select A.HospitalID
						from lab14_1.dbo.Hospitals as A,
							 lab14_2.dbo.Hospitals as B,
							 inserted as I
						where A.HospitalName = I.HospitalName and A.Address = I.Address and B.Email = I.Email and B.Phone = I.Phone)
			begin
				exec sp_addmessage 50003, 15, 'Error: not allowed to add duplicates', @lang= 'us_english', @replace = 'REPLACE';
				raiserror(50003, 15, 1)
			end
		else
			if exists (select A.HospitalID
							from lab14_1.dbo.Hospitals as A,
								  inserted as I
							where A.HospitalID = I.HospitalID)
				begin 
					exec sp_addmessage 50004, 15, 'Try another ID this one is taken', @lang= 'us_english', @replace = 'REPLACE';
					raiserror(50004, 15, 1)
				end
			else
				begin
					insert into lab14_1.dbo.Hospitals(HospitalID, HospitalName, Address)
					select HospitalID, HospitalName, Address from inserted

					insert into lab14_2.dbo.Hospitals(HospitalID, Email, Phone, Rating)
					select HospitalID, Email, Phone, Rating from inserted
				end
	end
go



insert into HospitalsView(HospitalID,HospitalName, Address, Email, Phone, Rating)
values  (1,'Litfonda vzroslaya filial 1', 'Krasnoarmeyskaya street, 3', 'litfondv1@mail.ru', '9099346755', 9.8),
		(2,'Litfonda detskaya filial 1', 'Krasnoarmeyskaya street, 6', 'litfondd1@mail.ru', '9099348955', 7.9),
		(3,'Litfonda vzroslaya filial 3', 'Arbatskaya street, 15', null , '9099346895', 8.5),
		(4,'Litfonda detskaya filial 5', 'Chasovaya street, 10', 'litfondd5@mail.ru', '9099506578', 8.7)
go

--insert into HospitalsView(HospitalID,HospitalName, Address, Email, Phone, Rating)
--values  (1,'Litfonda vzroslaya filial 1', 'Krasnoarmeyskaya street, 3', 'testlitfondv1@mail.ru', '9099346755', 9.8)
--go

--insert into HospitalsView(HospitalID,HospitalName, Address, Email, Phone, Rating)
--values  (5,'Litfonda vzroslaya filial 1', 'Krasnoarmeyskaya street, 3', 'litfondv1@mail.ru', '9099346755', 9.8)
--go

select * from HospitalsView
go

if OBJECT_ID(N'UpdateHospitalsView', N'TR') is not null
	drop trigger UpdateHospitalsView;
go

create trigger UpdateHospitalsView
	on HospitalsView
	instead of update
as
	begin
		if update(HospitalID)
			begin
				exec sp_addmessage 50005,15, 'Changing ID is forbidden', @lang= 'us_english', @replace = 'REPLACE';
				raiserror(50005, 15, 1)
			end
		if update(Address) or update(Phone) or update(Email)
			begin
				exec sp_addmessage 50006, 15, 'You are not allowed to change address or phone or email', @lang= 'us_english', @replace = 'REPLACE';
				raiserror(50006, 15, 1)
			end
		select A.HospitalID, A.Rating, B.Rating
		from inserted A
		inner join deleted B on A.HospitalID = B.HospitalID

		update lab14_2.dbo.Hospitals set Rating = inserted.Rating from inserted where inserted.HospitalID = lab14_2.dbo.Hospitals.HospitalID
	end
go

update HospitalsView set Rating = 5.0 where HospitalID >= 3
go

--update HospitalsView set Address = 'test address' where Rating > 7.0
--go

--update HospitalsView set Phone = '9099506899' where Rating > 7
--go

select * from HospitalsView

if OBJECT_ID(N'DeleteHospitalsView', N'TR') is not null
	drop trigger DeleteHospitalsView;
go

create trigger DeleteHospitalsView
	on HospitalsView
	instead of delete
as
	begin
		delete C from lab14_1.dbo.Hospitals as C inner join deleted as D on C.HospitalID = D.HospitalID
		delete C from lab14_2.dbo.Hospitals as C inner join deleted as D on C.HospitalID = D.HospitalID
	end
go

delete from HospitalsView where Rating = 7.9
go

--delete from HospitalsView where HospitalID = 1
--go

select * from HospitalsView
go

select * from lab14_1.dbo.Hospitals
go

select * from lab14_2.dbo.Hospitals
go