use master;
go

if DB_ID (N'lab6') is not null
drop database lab6;
go

create database lab6 on (
	NAME = lab6dat,
	FILENAME = 'C:\sql\lab6\lab6.mdf',
	SIZE = 10,
	MAXSIZE = UNLIMITED,
	FILEGROWTH = 5
)
log on (
	NAME = lab6log,
	FILENAME = 'C:\sql\lab6\lab6log.ldf',
	SIZE = 5MB,
	MAXSIZE = 25MB,
	FILEGROWTH = 5MB
);
go

use lab6;
go

if OBJECT_ID(N'Patients',N'U') is not null
	drop table Patients;
go

create table Patients (
	PatientID int identity(1,1) primary key,
	CardNumber int not null,
	First_name nvarchar(25) not null,
	Surname nvarchar(25) not null,
	Patronymic nvarchar(25) not null,
	Date_of_birth smalldatetime not null,
	Passport_number nvarchar(11) not null,
	Phone char(10) not null
);
go

insert into Patients(CardNumber, First_name, Surname, Patronymic, Date_of_birth, Passport_number, Phone)
values  (35273, 'Vasiliy', 'Ivanov', 'Sergeevich', '10/05/1998', '4523 126875', '9099507895'),
		(18593, 'Elizaveta', 'Tihonova', 'Alekseevna', '15/03/1976', '4525 726875', '9099508537'),
		(37573, 'Aleksandr', 'Sidorov', 'Pavlovich', '10/10/1990', '4523 189975', '8005557895')
go

select * from Patients
go

select IDENT_CURRENT('dbo.Patients') as last_id -- ïîñëåäíé ID â òàáëèöå --
go 
select SCOPE_IDENTITY() AS [SCOPE_IDENTITY];  -- ïîñëåäíé ID â îáëàñòè --
go  
select @@IDENTITY AS [@@IDENTITY];  -- ëþáîé ïîñëåäíèé ñîçäàííûé ID --
go 

if OBJECT_ID(N'Hospitals', N'U') is not null
	drop table Hospitals;
go

create table Hospitals (
	HospitalID uniqueidentifier primary key default (newid()),
	HospitalName nvarchar(300) not null,
	Address nvarchar(200) not null,
	Email nvarchar(254) null,
	Phone char(10) not null,
	Rating float not null check (Rating > 0 and Rating <= 10)
	);
go

insert into Hospitals(HospitalName, Address, Email, Phone, Rating)
values  ('Litfonda vzroslaya filial 1', 'Krasnoarmeyskaya street, 3', 'litfondv1@mail.ru', '9099346755', 9.8),
		('Litfonda detskaya filial 1', 'Krasnoarmeyskaya street, 6', 'litfondd1@mail.ru', '9099348955', 7.9),
		('Litfonda vzroslaya filial 3', 'Arbatskaya street, 15', null , '9099346895', 8.5)
go

select * from Hospitals
go

drop sequence if exists TestSequence

create sequence TestSequence 
	start with 0
	increment by 1
	maxvalue 10;
go

if object_id(N'List', N'U') is not null
	drop table List;
go

create table List(
	position_id int primary key not null,
	worker char(100) default ('Position name')
	);
go

insert into List(position_id, worker)
values  (next value for DBO.TestSequence, 'Kardiolog'),
		(next value for DBO.TestSequence, 'Hirurg'),
		(next value for DBO.TestSequence, 'Terapevt'),
		(next value for DBO.TestSequence, 'Administrator'),
		(next value for DBO.TestSequence, 'Ohrannik'),
		(next value for DBO.TestSequence, 'Nevrolog'),
		(next value for DBO.TestSequence, 'Okylist'),
		(next value for DBO.TestSequence, 'Virusolog')
go

select * from List
go

if OBJECT_ID(N'FK_Test1', N'U') is not null
	alter table Test2 drop constraint FK_Test1
go

if OBJECT_ID(N'Test1', N'U') is not null
	drop table Test1;
go

create table Test1 (
	Test1_id int primary key not null,
	First_value int null,
	Second_value int not null
	);
go

insert into Test1(Test1_id, First_value, Second_value)
values  (1, null, 533),
		(2, 53, 654),
		(3, null, 77422)
go

select * from Test1
go

if OBJECT_ID(N'Test2', N'U') is not null
	drop table Test2;
go

create table Test2 (
	Test2_id int identity(1,1) primary key,
	Test2_Test1 int null,
	Test2_value int default (0),
	Test2_name nvarchar(25) not null,
	constraint FK_Test1 foreign key (Test2_Test1) references Test1 (Test1_id)
	on delete set default
	);
go

insert into Test2(Test2_Test1, Test2_value, Test2_name)
values  (1, 23, 'Test_1'),
		(2, 462, 'Test_2'),
		(3, 445, 'Test_3'),
		(3, 22, 'Test_4')
go

select * from Test2
go
