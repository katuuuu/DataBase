USE master;
go

IF DB_ID (N'lab5') IS NOT NULL
DROP DATABASE lab5;
go

CREATE DATABASE lab5 on
(
	NAME = lab5dat,
	FILENAME = 'C:\sql\lab5\lab5.mdf',
	SIZE = 10,
	MAXSIZE = UNLIMITED,
	FILEGROWTH = 5
)

log on 
(
	NAME = lab5log,
	FILENAME = 'C:\sql\lab5\lab5log.ldf',
	SIZE = 5MB,
	MAXSIZE = 25MB,
	FILEGROWTH = 5MB
);
go

USE lab5;
go

DROP TABLE IF EXISTS Hospitals


CREATE TABLE Hospitals
(
	HospitalID INT PRIMARY KEY NOT NULL,
	HospitalName NVARCHAR(300) NOT NULL,
	Address NVARCHAR(200) NOT NULL,
	Email NVARCHAR(254) NULL,
	Phone CHAR(10) NOT NULL
);
go

INSERT INTO HOSPITALS(HospitalID, HospitalName, Address, Email, Phone)
VALUES (1543, 'Klinika doktora Maslovoy, filial 2', 'Mayakovskaya, 3', 'dmslv2@mail.ru', '9099506745')
go

SELECT * FROM HOSPITALS
go

ALTER DATABASE lab5
ADD FILEGROUP lab5_filegroup
go

ALTER DATABASE lab5
add file
(
	NAME = lab5dat1,
	FILENAME = 'C:\sql\lab5\lab5dat1.ndf',
	SIZE = 10MB,
	MAXSIZE = 100MB,
	FILEGROWTH = 5MB
)
to filegroup lab5_filegroup
go

ALTER DATABASE lab5
	modify filegroup lab5_filegroup default;
go


DROP TABLE IF EXISTS Workers

CREATE TABLE Workers
(
	WorkerID INT PRIMARY KEY NOT NULL,
	NameWorker NVARCHAR(25) NOT NULL,
	SurnameWorker NVARCHAR(25) NOT NULL,
	PatronymicWorker NVARCHAR(25) NOT NULL,
	HospitalID INT NOT NULL,
	Date_of_birth SMALLDATETIME NOT NULL,
	Position NVARCHAR(25) NOT NULL,
	Salary Money NOT NULL
);
go

ALTER DATABASE lab5 
 modify filegroup [primary] default;
go


DROP TABLE Workers
go

SELECT * INTO NewHospitals FROM Hospitals;
go

DROP TABLE Hospitals
go


ALTER DATABASE lab5
remove file lab5dat1
go

ALTER DATABASE lab5
remove filegroup lab5_filegroup;
go


CREATE SCHEMA Klinika_schema
go

ALTER SCHEMA Klinika_schema
    TRANSFER NewHospitals;
go

DROP TABLE Klinika_schema.NewHospitals;
go

DROP SCHEMA Klinika_schema;
go




