use master;
go

alter database lab10
set single_user
with rollback immediate;
drop database lab10
go

create database lab10 on (
	NAME = lab10dat,
	FILENAME = 'C:\sql\lab10\lab10.mdf',
	SIZE = 10,
	MAXSIZE = UNLIMITED,
	FILEGROWTH = 5
)
log on (
	NAME = lab10log,
	FILENAME = 'C:\sql\lab10\lab10log.ldf',
	SIZE = 5MB,
	MAXSIZE = 25MB,
	FILEGROWTH = 5MB
);
go

use lab10;
go

if OBJECT_ID(N'Hospitals', N'U') is not null
	drop table Hospitals;
go


create table Hospitals (
	HospitalID int primary key not null,
	HospitalName nvarchar(300) not null,
	Address nvarchar(200) not null,
	Email nvarchar(254) null,
	Phone char(10) not null
	);
go

insert into Hospitals(HospitalID,HospitalName, Address, Email, Phone)
values  (1,'Litfonda vzroslaya filial 1', 'Krasnoarmeyskaya street, 3', 'litfondv1@mail.ru', '9099346755'),
		(2,'Litfonda detskaya filial 1', 'Krasnoarmeyskaya street, 6', 'litfondd1@mail.ru', '9099348955'),
		(3,'Litfonda vzroslaya filial 3', 'Arbatskaya street, 15', null , '9099346895'),
		(4,'Litfonda detskaya filial 5', 'Chasovaya street, 10', 'litfondd5@mail.ru', '9099506578')
go

select * from Hospitals
go

