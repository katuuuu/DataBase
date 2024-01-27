use lab6;
go

-- представление на основе таблицы Hospitals из лабы 6 --
if OBJECT_ID(N'HospitalsView', N'V') is not null
	drop view HospitalsView;
go

create view HospitalsView as
	select *
	from Hospitals
	where Rating between 8 and 10;
go

select * from HospitalsView
go

--представление на основе связанных таблиц Test1 и Test2 из лабы 6 --
if OBJECT_ID(N'Test1Test2View', N'V') is not null
	drop view Test1Test2View;
go

create view Test1Test2View as
	select t1.First_value, t2.Test2_value, t2.Test2_name
	from Test1 as t1 inner join Test2 as t2 on t1.Test1_id = t2.Test1_id
go 

select * from Test1Test2View
go

-- индекс --

drop index if exists Hospitals.HospitalsIndex;
go

create index HospitalsIndex on Hospitals(Rating) include(HospitalName);
go

select HospitalName, Rating from Hospitals where Rating > 9
go

--индексированное представление--
if OBJECT_ID(N'HospitalsIndexView',N'V') is not null
	drop view HospitalsIndexView;
go

create view dbo.HospitalsIndexView
with schemabinding
as
	select HospitalID, HospitalName, Email, Phone, Rating
	from dbo.Hospitals;
go


create unique clustered index INX_Hospitals_ID
	on dbo.HospitalsIndexView(HospitalID);
go


select * from dbo.HospitalsIndexView
go