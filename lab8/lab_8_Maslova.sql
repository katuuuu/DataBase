use master;
go

if DB_ID (N'lab8') is not null
drop database lab8;
go

create database lab8 on (
	NAME = lab8dat,
	FILENAME = 'C:\sql\lab8\lab8.mdf',
	SIZE = 10,
	MAXSIZE = UNLIMITED,
	FILEGROWTH = 5
)
log on (
	NAME = lab8log,
	FILENAME = 'C:\sql\lab8\lab8log.ldf',
	SIZE = 5MB,
	MAXSIZE = 25MB,
	FILEGROWTH = 5MB
);
go

use lab8;
go

if OBJECT_ID(N'Hospitals', N'U') is not null
	drop table Hospitals;
go


create table Hospitals (
	HospitalID int identity(1,1) primary key,
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
		('Litfonda vzroslaya filial 3', 'Arbatskaya street, 15', null , '9099346895', 8.5),
		('Litfonda detskaya filial 5', 'Chasovaya street, 10', 'litfondd5@mail.ru', '9099506578', 8.7)
go

select * from Hospitals
go
--1
if OBJECT_ID(N'dbo.select_hospitals', N'P') is not null
	drop procedure dbo.select_hospitals
go

create procedure dbo.select_hospitals
	@cursor cursor varying output 
as 
	set @cursor = cursor for
	select Address, HospitalName
	from Hospitals 
	open @cursor;
	--fetch next
go

declare @hospital_cursor cursor;
execute dbo.select_hospitals @cursor = @hospital_cursor output;

declare @address nvarchar(200)
declare @HospitalName nvarchar(300)

--open
fetch next from @hospital_cursor into @address, @HospitalName

while (@@FETCH_STATUS = 0)
begin
	print 'Hospital address: ' + @address
	fetch next from @hospital_cursor into @address, @HospitalName
end

close @hospital_cursor;
deallocate @hospital_cursor;
go
--2

if OBJECT_ID(N'get_rating',N'FN') is not null
	drop function get_rating
go


create function dbo.get_rating(@rating float)
	returns float
	as 
		begin
			declare @result float;
			set @result = @rating;
			return @result;
		end;
go

if OBJECT_ID(N'dbo.select_hospitals_with_func', N'P') is not null
	drop procedure dbo.select_hospitals_with_func
go

create procedure dbo.select_hospitals_with_func
	@cursor cursor varying output 
as 
	set @cursor = cursor for
	select Address, Rating
	from Hospitals
	open @cursor;
go

declare @hospital_cursor cursor;
execute dbo.select_hospitals_with_func @cursor = @hospital_cursor output;



fetch next from @hospital_cursor;
while (@@FETCH_STATUS = 0)
begin 
	fetch next from @hospital_cursor
end

close @hospital_cursor;
deallocate @hospital_cursor;
go

--3
drop function if exists dbo.isName;
go

create function dbo.isName(@Hospitals_HospitalName nvarchar(300))
returns bit
as 
begin 
	if @Hospitals_HospitalName = 'Litfonda detskaya filial 1'
		return 1
	return 0
end;
go

drop procedure if exists dbo.procedure3;
go

create procedure dbo.procedure3
as 
	declare @mycursor cursor
	declare @Address nvarchar(200)
	declare @HospitalName nvarchar(300)

	exec dbo.select_hospitals @cursor = @mycursor output;

	fetch next from @mycursor into @Address, @HospitalName;
	while @@FETCH_STATUS = 0
		begin 
			if dbo.isName(@HospitalName) = 1
				print formatmessage(N'%s находится по адресу %s', @HospitalName, @Address)
			fetch next from @mycursor into @Address, @HospitalName;
		end
	close @mycursor
	deallocate @mycursor
go

exec dbo.procedure3;
go

--4
drop function if exists dbo.tablefunc;
go

create function dbo.tablefunc()
returns table
as
return(
	select HospitalName, Address, dbo.get_rating(Rating) as rating
	from Hospitals
	where rating > 9
);
go

create function dbo.tablefunc()
returns table
as
return(
	select HospitalName, Address, dbo.get_rating(Rating) as rating
	from Hospitals
	where rating > 9
);
go

drop procedure if exists dbo.procedure4;
go

create procedure dbo.procedure4
	@cursor cursor varying output
as
	set @cursor = cursor
		forward_only static for
		select * from dbo.tablefunc()
	open @cursor;
go

declare @mycursor cursor;
exec dbo.procedure4 @cursor = @mycursor output;

fetch next from @mycursor;
while @@FETCH_STATUS = 0
	begin 
		fetch next from @mycursor;
	end
close @mycursor;
deallocate @mycursor;
go




