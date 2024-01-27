use master;
go

if DB_ID (N'lab13_1') is not null
drop database lab13_1;
go

create database lab13_1 on (
	NAME = lab131dat,
	FILENAME = 'C:\sql\lab13\lab131.mdf',
	SIZE = 10,
	MAXSIZE = UNLIMITED,
	FILEGROWTH = 5
)
log on (
	NAME = lab131log,
	FILENAME = 'C:\sql\lab13\lab131log.ldf',
	SIZE = 5MB,
	MAXSIZE = 25MB,
	FILEGROWTH = 5MB
);
go

use master;
go

if DB_ID (N'lab13_2') is not null
	drop database lab13_2;
go

create database lab13_2 on (
	NAME = lab132dat,
	FILENAME = 'C:\sql\lab13\lab132.mdf',
	SIZE = 10,
	MAXSIZE = UNLIMITED,
	FILEGROWTH = 5
)
log on (
	NAME = lab132log,
	FILENAME = 'C:\sql\lab13\lab132log.ldf',
	SIZE = 5MB,
	MAXSIZE = 25MB,
	FILEGROWTH = 5MB
);
go

use lab13_1;
go

if OBJECT_ID(N'Hospitals', N'U') is not null
	drop table Hospitals;
go


create table Hospitals (
	HospitalID int primary key,
	HospitalName nvarchar(300) not null,
	Address nvarchar(200) not null,
	Email nvarchar(254) null,
	Phone char(10) not null,
	Rating float not null,
	constraint Seq_Hospitals check (HospitalID < 3)
	);
go

use lab13_2;
go

if OBJECT_ID(N'Hospitals', N'U') is not null
	drop table Hospitals;
go


create table Hospitals (
	HospitalID int primary key,
	HospitalName nvarchar(300) not null,
	Address nvarchar(200) not null,
	Email nvarchar(254) null,
	Phone char(10) not null,
	Rating float not null, 
	constraint Seq_Hospitals check (HospitalID >= 3)
	);
go

use lab13_1;
go 

if OBJECT_ID(N'HospitalsView', N'V') is not null
	drop view HospitalsView;
go

create view HospitalsView as
	select * from lab13_1.dbo.Hospitals
	union all 
	select * from lab13_2.dbo.Hospitals
go

insert into HospitalsView values
	(1,'Litfonda vzroslaya filial 1', 'Krasnoarmeyskaya street, 3', 'litfondv1@mail.ru', '9099346755', 9.8),
	(2,'Litfonda detskaya filial 1', 'Krasnoarmeyskaya street, 6', 'litfondd1@mail.ru', '9099348955', 7.9),
	(3,'Litfonda vzroslaya filial 3', 'Arbatskaya street, 15', null , '9099346895', 8.5),
	(4,'Litfonda detskaya filial 5', 'Chasovaya street, 10', 'litfondd5@mail.ru', '9099506578', 8.5)
go

select * from HospitalsView;

select * from lab13_1.dbo.Hospitals;
select * from lab13_2.dbo.Hospitals;

delete from HospitalsView where Address = 'Krasnoarmeyskaya street, 3'

select * from lab13_1.dbo.Hospitals;
select * from lab13_2.dbo.Hospitals;

update HospitalsView set Phone = '9099503498' where Rating = 8.5

insert into HospitalsView values (5,'Litfonda detskaya filial 1', 'Krasnoarmeyskaya street, 6', 'litfondd1@mail.ru', '9099348955', 7.9)
go

select * from lab13_1.dbo.Hospitals;
select * from lab13_2.dbo.Hospitals;

