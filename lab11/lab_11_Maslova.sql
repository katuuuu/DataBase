use master;
go

if DB_ID (N'lab11') is not null
drop database lab11;
go

create database lab11 on (
	NAME = lab11dat,
	FILENAME = 'C:\sql\lab11\lab11.mdf',
	SIZE = 10,
	MAXSIZE = UNLIMITED,
	FILEGROWTH = 5
)
log on (
	NAME = lab11log,
	FILENAME = 'C:\sql\lab11\lab11log.ldf',
	SIZE = 5MB,
	MAXSIZE = 25MB,
	FILEGROWTH = 5MB
);
go

use lab11;
go

--Hospitals table
if OBJECT_ID(N'Hospitals', N'U') is not null
	drop table Hospitals;
go

create table Hospitals (
	HospitalID int identity(1,1) primary key,
	HospitalName nvarchar(300) not null,
	Address nvarchar(200) not null,
	Email nvarchar(254) null,
	Phone char(10) not null
	);
go


if OBJECT_ID(N'InsertHospitals', N'TR') is not null
	drop trigger InsertHospitals
go

create trigger InsertHospitals 
	on Hospitals
	for insert
as
	begin
		if exists (select * from inserted where len(inserted.HospitalName) <= 0 or len(inserted.Address) <= 0 or len(inserted.Email) <= 0 or len(Phone) != 10)
			begin 
				exec sp_addmessage 50007, 17, 'Incorrect data', @lang= 'us_english', @replace = 'REPLACE';
				raiserror(50007, 17, 1)
			end
	end
go



insert into Hospitals(HospitalName, Address, Email, Phone)
values  ('Litfonda vzroslaya filial 1', 'Krasnoarmeyskaya street, 3', 'litfondv1@mail.ru', '9099346755'),
		('Litfonda detskaya filial 1', 'Krasnoarmeyskaya street, 6', 'litfondd1@mail.ru', '9099348955'),
		('Litfonda vzroslaya filial 3', 'Arbatskaya street, 15', null , '9099346895'),
		('Litfonda detskaya filial 5', 'Chasovaya street, 10', 'litfondd5@mail.ru', '9099506578')
go

--insert into Hospitals(HospitalName, Address, Email, Phone)
--values  ('', 'Krasnoarmeyskaya street, 3', 'litfondv1@mail.ru', '567')
--go

select * from Hospitals


--Workers table
if OBJECT_ID(N'Workers', N'U') is not null
	drop table Workers;
go

create table Workers(
	WorkerID int identity(1,1) primary key,
	NameWorker nvarchar(25) not null,
	SurnameWorker nvarchar(25) not null,
	PatronymicWorker nvarchar(25) not null,
	Position nvarchar(25) not null,
	Salary money not null,
	HospitalID int not null,
	constraint HospitalID_FK foreign key (HospitalID) references Hospitals(HospitalID) on delete cascade
);
go

if OBJECT_ID(N'InsertWorkers', N'TR') is not null
	drop trigger InsertWorkers
go

create trigger InsertWorkers 
	on Workers
	for insert
as
	begin
		if exists (select * from inserted where len(inserted.NameWorker) <= 0 or len(inserted.SurnameWorker) <= 0 or len(inserted.PatronymicWorker) <= 0 or len(Position) <= 0 or Salary <= 0)
			begin 
				exec sp_addmessage 50008, 17, 'Incorrect data', @lang= 'us_english', @replace = 'REPLACE';
				raiserror(50008, 17, 1)
			end
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
		if (update(NameWorker) or update(PatronymicWorker) or update (HospitalID))
			begin
				exec sp_addmessage 50014, 17, 'You cannot change main data of worker', @lang= 'us_english', @replace = 'REPLACE';
				raiserror(50014, 17, 1)
			end
		else
			if (update(SurnameWorker) or update(Salary) or update(Position))
				begin
					update Workers set SurnameWorker = inserted.SurnameWorker from inserted where Workers.WorkerID = inserted.WorkerID
					update Workers set Salary = inserted.Salary from inserted where Workers.WorkerID = inserted.WorkerID
					update Workers set Position = inserted.Position from inserted where Workers.WorkerID = inserted.WorkerID
				end
	end
go

insert into Workers(NameWorker, SurnameWorker, PatronymicWorker, Position,Salary, HospitalID)
values ('Aleksandr', 'Pavlov', 'Viktorovich', 'Kardiolog',50000, 1),
		('Boris', 'Bulkin', 'Alekseevich', 'Nevrolog',40000, 2),
		('Pavel', 'Durov', 'Sergeevich', 'Pediatr', 45000, 4),
		('Andrey', 'Egorov', 'Dmitreevich', 'Ortoped',63000, 1),
		('Roman', 'Kiselev', 'Andreevich', 'Terapevt', 20000,3)
go


select * from Workers
go

--hospital and its workers

if object_id(N'Hospital_Workers', N'V') is not null
	drop view Hospital_Workers
go

create view Hospital_Workers as 
	select 
		h.HospitalID as h_id,
		w.WorkerID as w_id,
		h.HospitalName as h_name,
		h.Address as h_address,
		w.NameWorker as name,
		w.PatronymicWorker as patronymic,
		w.SurnameWorker as surname
	from Hospitals h
	inner join Workers w on h.HospitalID = w.HospitalID;
go


select * from Hospital_Workers

--Patients
if object_id(N'Patients', N'U') is not null
	drop table Patients
go

create table Patients(
	PatientID int identity(1,1) primary key,
	CardNumber int unique not null,
	FirstName nvarchar(25) not null,
	Surname nvarchar(25) not null,
	Patronymic nvarchar(25) not null,
	Date_of_birth smalldatetime not null,
	PassportNumber nvarchar(11) not null,
	Phone char(10) not null
);
go

if OBJECT_ID(N'InsertPatients', N'TR') is not null
	drop trigger InsertPatients
go

create trigger InsertPatients 
	on Patients
	for insert
as
	begin
		if exists (select * from inserted where len(inserted.FirstName) <= 0 or len(inserted.Surname) <= 0 or len(inserted.Patronymic) <= 0 or len(Phone) != 10)
			begin 
				exec sp_addmessage 50007, 17, 'Incorrect data', @lang= 'us_english', @replace = 'REPLACE';
				raiserror(50007, 17, 1)
			end
	end
go

if OBJECT_ID(N'UpdatePatients', N'TR') is not null
	drop trigger UpdatePatients
go

create trigger UpdatePatients 
	on Patients
	for update
as
	begin
		if (update(FirstName) or update(Patronymic) or update(Surname) or update(PassportNumber) or update(CardNumber) or update(Date_of_birth))
			begin
				exec sp_addmessage 50009, 17, 'You cannot change main data of Patient', @lang= 'us_english', @replace = 'REPLACE';
				raiserror(50009, 17, 1)
			end
		else
			begin
				update Patients set Phone = inserted.Phone from inserted where Patients.PatientID = inserted.PatientID
				print 'Phone number was changed'
			end
	end
go

insert into Patients(CardNumber, FirstName, Patronymic, Surname, Date_of_birth, PassportNumber, Phone)
values  (35273, 'Vasiliy', 'Ivanov', 'Sergeevich', '10/05/1998', '4523 126875', '9099507895'),
		(18593, 'Elizaveta', 'Tihonova', 'Alekseevna', '15/03/1976', '4525 726875', '9099508537'),
		(37573, 'Aleksandr', 'Sidorov', 'Pavlovich', '10/10/1990', '4523 189975', '8005557895')
go

update Patients set Phone = '9099503499' where PatientID = 1

--update Patients set FirstName = 'Olga' where PatientID = 2

select * from Patients
go

--Visits

if object_id(N'Visits', N'U') is not null
	drop table Visits
go

create table Visits(
	Date_of_visit smalldatetime not null,
	Price_of_the_visit money not null,
	Reason_of_the_visit nvarchar(200) null,
	PatientID int not null check(len(PatientID) > 0),
	WorkerID int not null check(len(WorkerID) > 0),
		constraint PatientID_FK foreign key (PatientID) references Patients(PatientID) on delete cascade,
		constraint WorkerID_FK foreign key (WorkerID) references Workers(WorkerID) on delete cascade
);
go

insert into Visits(PatientID, WorkerID, Date_of_visit, Price_of_the_visit, Reason_of_the_visit)
values (1,1, '10/10/2025', 1000, 'boli v serdce'),
		(2,2,'10/11/2022',1500,'chastaya trevoga')
go

--delete Patients where PatientID = 1

select * from Visits

--workers without visits

drop procedure if exists Workers_without_visits
go

create procedure Workers_without_visits as
select * from Workers where WorkerID not in (select WorkerID from Visits)
go

--execute Workers_without_visits
--go

--distinct (вывод без повторений)
select distinct Price_of_the_visit from Visits order by Price_of_the_visit desc

--left join (сначала прогрузились работники, а к ним приписались визиты)
select * from Workers left join Visits on Visits.WorkerID = Workers.WorkerID order by Workers.WorkerID asc

--right join (сначала прогрузились визиты, а к ним приписались работники)
select * from Workers right join Visits on Visits.WorkerID = Workers.WorkerID 

--outer join (прогружаются обе таблицы, если есть совпадения по условию)
select * from Workers full outer join Visits on Visits.WorkerID = Workers.WorkerID

--between
select * from Workers where WorkerID between 2 and 3

--group by + having
insert into Visits(PatientID, WorkerID, Date_of_visit, Price_of_the_visit, Reason_of_the_visit)
values (3,1, '10/10/2025', 2000, 'boli v serdce'),
		(2,2,'10/11/2022',3500,'chastaya trevoga')
go

select WorkerID, sum(Price_of_the_visit) as sum_price from Visits group by WorkerID having sum(Price_of_the_visit) > 0

select sum(Salary) as sum_salary from Workers
select avg(Salary) as avg_salary from Workers
select min(Salary) as min_salary from Workers
select max(Salary) as max_salary from Workers
select count(*) as count_workers from Workers

--union, like
insert into Visits(Price_of_the_visit, WorkerID, PatientID, Date_of_visit) values (1000, 1, 2, '10/10/2021')
select * from Visits where Visits.Date_of_visit like '%2025%'
union
select * from Visits where Visits.Date_of_visit like '%2021%'

--intersect
select * from Visits where Visits.Date_of_visit like '%2025%'
intersect
select * from Visits where Visits.Price_of_the_visit > 100

--except
select * from Visits where Visits.Date_of_visit like '%2025%'
except
select * from Visits where Visits.Price_of_the_visit > 1000

--union all
select * from Visits where Visits.Date_of_visit like '%2025%'
union all
select * from Visits where Visits.Price_of_the_visit >= 1000


