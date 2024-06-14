--**********************************************************************************************--
-- Title: ITFnd130Final
-- Author: ChristieGlancy
-- Desc: This file demonstrates how to design and create; 
--       tables, views, and stored procedures
-- Change Log: When,Who,What
-- 2024-06-05,ChristieGlancy,Created File
--***********************************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'ITFnd130FinalDB_ChristieGlancy')
	 Begin 
	  Alter Database [ITFnd130FinalDB_ChristieGlancy] set Single_user With Rollback Immediate;
	  Drop Database ITFnd130FinalDB_ChristieGlancy;
	 End
	Create Database ITFnd130FinalDB_ChristieGlancy;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use ITFnd130FinalDB_ChristieGlancy;

-- Create Tables (Review Module 01)-- 
-- TODO: Create table for Students 
CREATE TABLE dbo.Students(
    StudentID int NOT NULL IDENTITY
    ,StudentNum nvarchar(25) NOT NULL
	,StudentFirstName nvarchar(50) NOT NULL
	,StudentLastName nvarchar(50) NOT NULL
	,StudentEmail nvarchar(50) NOT NULL
	,StudentPhone nvarchar(12) NOT NULL
	,StudentAddress1 nvarchar(50) NOT NULL
	,StudentAddress2 nvarchar(50) NULL
	,StudentCity nvarchar(50) NOT NULL
	,StudentState nchar(2) NOT NULL
	,StudentZip nchar(10) NOT NULL
);

-- TODO: Create table for Courses
 CREATE TABLE dbo.Courses(
    CourseID int NOT NULL IDENTITY
    ,CourseName nvarchar(100) NOT NULL
    ,CourseStartDate date NULL
    ,CourseEndDate date NULL
	,CourseStartTime time NULL
	,CourseEndTime time NULL
	,CourseDaysOfWeek nvarchar(10) NULL
	,CourseCurrentPrice money NULL
 );

-- TODO: Create table for Enrollments
CREATE TABLE dbo.Enrollments(
    EnrollID int NOT NULL IDENTITY
    ,CourseID int NOT NULL
    ,StudentID int NOT NULL
	,EnrollDateTime datetime NOT NULL
	,EnrollPrice money NOT NULL
);

-- Add Constraints (Review Module 02) -- 
-- Constraints for Students Table --
ALTER TABLE dbo.Students
    ADD CONSTRAINT pkStudentID PRIMARY KEY (StudentID);
ALTER TABLE dbo.Students
    ADD CONSTRAINT uqStudentNum UNIQUE (StudentNum);
ALTER TABLE dbo.Students
    ADD CONSTRAINT uqStudentEmail UNIQUE (StudentEmail);
ALTER TABLE dbo.Students
    ADD CONSTRAINT ckStudentEmail CHECK (StudentEmail like '%_@__%.__%');
ALTER TABLE dbo.Students
	ADD CONSTRAINT ckStudentPhone CHECK (StudentPhone like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]');
ALTER TABLE dbo.Students
	ADD CONSTRAINT ckStudentZip CHECK (StudentZip like '[0-9][0-9][0-9][0-9][0-9]%'
		OR StudentZip like '[0-9][0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]');
go


-- Constraints for Courses Table --
ALTER TABLE dbo.Courses
    ADD CONSTRAINT pkCourseID PRIMARY KEY (CourseID);
ALTER TABLE dbo.Courses
    ADD CONSTRAINT uqCourseName UNIQUE (CourseName);
ALTER TABLE dbo.Courses
	ADD CONSTRAINT ckCourseStartDateLessThanCourseEndDate CHECK (CourseStartDate < CourseEndDate);
ALTER TABLE dbo.Courses
	ADD CONSTRAINT ckCourseEndDateMoreThanCourseStartDate CHECK (CourseEndDate > CourseStartDate);
ALTER TABLE dbo.Courses
	ADD CONSTRAINT ckCourseEndTimeMoreThanCourseStartTime CHECK (CourseEndTime > CourseStartTime);
go

-- Constraints for Enrollments Table --
ALTER TABLE dbo.Enrollments
	ADD CONSTRAINT pkEnrollID PRIMARY KEY (EnrollID);
ALTER TABLE dbo.Enrollments
    ADD CONSTRAINT fkCourseID FOREIGN KEY (CourseID) references dbo.Courses(CourseID);
ALTER TABLE dbo.Enrollments
    ADD CONSTRAINT fkStudentID FOREIGN KEY (StudentID) references dbo.Students(StudentID);
ALTER TABLE dbo.Enrollments
	ADD CONSTRAINT dfEnrollDateTime DEFAULT  GetDate() for EnrollDateTime;
ALTER TABLE dbo.Enrollments
	ADD CONSTRAINT ckEnrollPriceGreaterThanOrEqualToZero CHECK ([EnrollPrice] >= 0);
go

-- Add Views (Review Module 03 and 06) -- 
-- View for Students Table --
CREATE OR ALTER VIEW vStudents WITH SchemaBinding
AS 
  SELECT StudentID
  ,StudentNum
  ,StudentFirstName
  ,StudentLastName
  ,StudentEmail
  ,StudentPhone
  ,StudentAddress1
  ,StudentAddress2
  ,StudentCity
  ,StudentState
  ,StudentZip
  FROM dbo.Students
;
go

-- View for Courses Table --
CREATE OR ALTER VIEW vCourses WITH SchemaBinding
AS
  SELECT CourseID
  ,CourseName
  ,CourseStartDate
  ,CourseEndDate
  ,CourseStartTime
  ,CourseEndTime
  ,CourseDaysOfWeek
  ,CourseCurrentPrice
  FROM dbo.Courses
;
go

-- View for Enrollments Table --
CREATE OR ALTER VIEW vEnrollments WITH SchemaBinding
AS
  SELECT EnrollID
  ,StudentID
  ,EnrollDateTime
  ,EnrollPrice
  FROM dbo.Enrollments
;
go

-- View for ALL Data Tables --
CREATE OR ALTER VIEW vStudentsCoursesEnrollments WITH SchemaBinding
AS
  SELECT e.EnrollID
  ,e.EnrollDateTime
  ,e.EnrollPrice
  ,s.StudentID
  ,s.StudentNum
  ,s.StudentFirstName
  ,s.StudentLastName
  ,s.StudentEmail
  ,s.StudentPhone
  ,s.StudentAddress1
  ,s.StudentAddress2
  ,s.StudentCity
  ,s.StudentState
  ,s.StudentZip
  ,c.CourseID
  ,c.CourseName
  ,c.CourseStartDate
  ,c.CourseEndDate
  ,c.CourseStartTime
  ,c.CourseEndTime
  ,c.CourseDaysOfWeek
  ,c.CourseCurrentPrice
FROM dbo.Enrollments AS e
JOIN dbo.Students AS s
  ON e.StudentID = s.StudentID
JOIN dbo.Courses AS c
  ON e.CourseID = c.CourseID
;
go

-- Add Validating Functions --
CREATE OR ALTER FUNCTION dbo.fGetCourseStartDate (@CourseID int)
	RETURNS datetime
	AS
	 Begin
	  RETURN (SELECT CourseStartDate FROM Courses
	  WHERE Courses.CourseID = @CourseID)
	 End
go

CREATE OR ALTER FUNCTION dbo.fGetCourseEndDate (@CourseID int)
	RETURNS datetime
	AS
	 Begin
	  RETURN (SELECT CourseEndDate FROM Courses
	  WHERE Courses.CourseID = @CourseID)
	 End
go

-- Allows students to enroll after the class started --
ALTER TABLE dbo.Enrollments
	ADD CONSTRAINT ckEnrollDateTimeBeforeEndDate CHECK (EnrollDateTime <= dbo.fGetCourseEndDate(CourseID));
go

--< Test Tables by adding Sample Data >--  

INSERT INTO dbo.Courses
(CourseName, CourseStartDate, CourseEndDate, CourseStartTime, CourseEndTime, CourseDaysOfWeek, CourseCurrentPrice)
VALUES
('SQL1 - Winter 2017', '01/10/2017', '01/24/2017', '18:00', '20:50', 'T', 399.00)
,('SQL2 - Winter 2017', '01/31/2017', '02/14/2017', '18:00', '20:50', 'T', 399.00)
;
go

INSERT INTO dbo.Students
(StudentNum, StudentFirstName, StudentLastName, StudentEmail, StudentPhone, StudentAddress1, StudentAddress2, StudentCity, StudentState, StudentZip)
VALUES
('B-Smith-071', 'Bob', 'Smith', 'Bsmith@HipMail.com', '2061112222', '123 Main St.', '', 'Seattle', 'WA', '98001')
,('S-Jones-003', 'Sue', 'Jones', 'SueJones@YaYou.com', '2062314321', '333 1st Ave.', '', 'Seattle', 'WA', '98001')
;
go

INSERT INTO dbo.Enrollments
(StudentID, CourseID, EnrollDateTime, EnrollPrice)
VALUES
(2,1,'12/14/2016',349)
,(2,2,'12/14/2016',349)
,(1,1,'01/12/2017',399)
,(1,2,'01/12/2017',399)
;
go

-- Add Stored Procedures (Review Module 04 and 08) --
-- Create Procedures for Courses --
-- Create Procedure to Insert Courses --
CREATE OR ALTER PROCEDURE pInsCourses
( @CourseID int
, @CourseName nvarchar(100)
, @CourseStartDate date
, @CourseEndDate date
, @CourseStartTime time
, @CourseEndTime time
, @CourseDaysOfWeek nvarchar(10)
, @CourseCurrentPrice money
)
AS
  BEGIN
    DECLARE @RC int = 0;
	BEGIN Try
		BEGIN Transaction
		 INSERT INTO dbo.Courses
		 (CourseName, CourseStartDate, CourseEndDate, CourseStartTime, CourseEndTime, CourseDaysOfWeek, CourseCurrentPrice)
		 VALUES
		 (@CourseName, @CourseStartDate, @CourseEndDate, @CourseStartTime, @CourseEndTime, @CourseDaysOfWeek, @CourseCurrentPrice)
		;
		COMMIT Transaction
		SET @RC = +1
	END Try
	BEGIN Catch
		IF @@TranCount > 0 Rollback Transaction
		PRINT Error_Message()
		SET @RC = -1
	END Catch
	RETURN @RC;
  END
go

-- Create Procedure to Update Courses --

CREATE OR ALTER PROCEDURE pUpdCourses
( @CourseID int
, @CourseName nvarchar(100)
, @CourseStartDate date
, @CourseEndDate date
, @CourseStartTime time
, @CourseEndTime time
, @CourseDaysOfWeek nvarchar(10)
, @CourseCurrentPrice money
)
AS
  BEGIN
    DECLARE @RC int = 0;
	BEGIN Try
		BEGIN Transaction
		 UPDATE dbo.Courses
		 SET CourseName = @CourseName
		  ,CourseStartDate = @CourseStartDate
		  ,CourseEndDate = @CourseEndDate
		  ,CourseStartTime = @CourseStartTime
		  ,CourseEndTime = @CourseEndTime
		  ,CourseCurrentPrice = @CourseCurrentPrice
		  WHERE CourseID = @CourseID;
		COMMIT Transaction
		SET @RC = +1
	END Try
	BEGIN Catch
		IF @@TranCount > 0 Rollback Transaction
		PRINT Error_Message()
		SET @RC = -1
	END Catch
	RETURN @RC;
  END
go

-- Create Procedure to Delete Courses --
CREATE OR ALTER PROCEDURE pDelCourses
( @CourseID int
)
AS
  BEGIN
    DECLARE @RC int = 0;
	BEGIN Try
		BEGIN Transaction
		 DELETE FROM dbo.Courses
		 WHERE CourseID = @CourseID;
		COMMIT Transaction
		SET @RC = +1
	END Try
	BEGIN Catch
		IF @@TranCount > 0 Rollback Transaction
		PRINT Error_Message()
		SET @RC = -1
	END Catch
	RETURN @RC;
  END
go

-- Create Procedures for Students --
-- Create Procedure to Insert Students --
CREATE OR ALTER PROCEDURE pInsStudents
( @StudentID int
, @StudentNum nvarchar(25)
, @StudentFirstName nvarchar(50)
, @StudentLastName nvarchar(50)
, @StudentEmail nvarchar(50)
, @StudentPhone nvarchar(12)
, @StudentAddress1 nvarchar(50)
, @StudentAddress2 nvarchar(50)
, @StudentCity nvarchar(50)
, @StudentState nchar(2)
, @StudentZip nchar(10)
)
AS
  BEGIN
    DECLARE @RC int = 0;
	BEGIN Try
		BEGIN Transaction
		 INSERT INTO dbo.Students
		 (StudentNum, StudentFirstName, StudentLastName, StudentEmail, StudentPhone, StudentAddress1, StudentAddress2, StudentCity, StudentState, StudentZip)
		 VALUES
		 (@StudentNum, @StudentFirstName, @StudentLastName, @StudentEmail, @StudentPhone, @StudentAddress1, @StudentAddress2, @StudentCity, @StudentState, @StudentZip)
		;
		COMMIT Transaction
		SET @RC = +1
	END Try
	BEGIN Catch
		IF @@TranCount > 0 Rollback Transaction
		PRINT Error_Message()
		SET @RC = -1
	END Catch
	RETURN @RC;
  END
go

-- Create Procedure to Update Students --

CREATE OR ALTER PROCEDURE pUpdStudents
( @StudentID int
, @StudentNum nvarchar(25)
, @StudentFirstName nvarchar(50)
, @StudentLastName nvarchar(50)
, @StudentEmail nvarchar(50)
, @StudentPhone nvarchar(12)
, @StudentAddress1 nvarchar(50)
, @StudentAddress2 nvarchar(50)
, @StudentCity nvarchar(50)
, @StudentState nchar(2)
, @StudentZip nchar(10)
)
AS
  BEGIN
    DECLARE @RC int = 0;
	BEGIN Try
		BEGIN Transaction
		 UPDATE dbo.Students
		 SET StudentNum = @StudentNum
		  ,StudentFirstName = @StudentFirstName
		  ,StudentLastName = @StudentLastName
		  ,StudentEmail = @StudentEmail
		  ,StudentPhone = @StudentPhone
		  ,StudentAddress1 = @StudentAddress1
		  ,StudentAddress2 = @StudentAddress2
		  ,StudentCity = @StudentCity
		  ,StudentState = @StudentState
		  ,StudentZip = @StudentZip
		  WHERE StudentID = @StudentID;
		COMMIT Transaction
		SET @RC = +1
	END Try
	BEGIN Catch
		IF @@TranCount > 0 Rollback Transaction
		PRINT Error_Message()
		SET @RC = -1
	END Catch
	RETURN @RC;
  END
go

-- Create Procedure to Delete Students --
CREATE OR ALTER PROCEDURE pDelStudents
( @StudentID int
)
AS
  BEGIN
    DECLARE @RC int = 0;
	BEGIN Try
		BEGIN Transaction
		 DELETE FROM dbo.Students
		 WHERE StudentID = @StudentID;
		COMMIT Transaction
		SET @RC = +1
	END Try
	BEGIN Catch
		IF @@TranCount > 0 Rollback Transaction
		PRINT Error_Message()
		SET @RC = -1
	END Catch
	RETURN @RC;
  END
go

-- Create Procedures for Enrollments --
-- Create Procedure to Insert Enrollments --
CREATE OR ALTER PROCEDURE pInsEnrollments
( @EnrollID int
, @CourseID int
, @StudentID int
, @EnrollDateTime datetime
, @EnrollPrice money
)
AS
  BEGIN
    DECLARE @RC int = 0;
	BEGIN Try
		BEGIN Transaction
		 INSERT INTO dbo.Enrollments
		 (EnrollDateTime, EnrollPrice)
		 VALUES
		 (@EnrollDateTime, @EnrollPrice)
		;
		COMMIT Transaction
		SET @RC = +1
	END Try
	BEGIN Catch
		IF @@TranCount > 0 Rollback Transaction
		PRINT Error_Message()
		SET @RC = -1
	END Catch
	RETURN @RC;
  END
go

-- Create Procedure to Update Enrollments --

CREATE OR ALTER PROCEDURE pUpdEnrollments
( @EnrollID int
, @CourseID int
, @StudentID int
, @EnrollDateTime datetime
, @EnrollPrice money
)
AS
  BEGIN
    DECLARE @RC int = 0;
	BEGIN Try
		BEGIN Transaction
		 UPDATE dbo.Enrollments
		 SET EnrollDateTime = @EnrollDateTime
		  ,EnrollPrice = @EnrollPrice
		  WHERE EnrollID = @EnrollID;
		COMMIT Transaction
		SET @RC = +1
	END Try
	BEGIN Catch
		IF @@TranCount > 0 Rollback Transaction
		PRINT Error_Message()
		SET @RC = -1
	END Catch
	RETURN @RC;
  END
go

-- Create Procedure to Delete Enrollments --
CREATE OR ALTER PROCEDURE pDelEnrollments
( @EnrollID int
)
AS
  BEGIN
    DECLARE @RC int = 0;
	BEGIN Try
		BEGIN Transaction
		 DELETE FROM dbo.Enrollments
		 WHERE EnrollID = @EnrollID;
		COMMIT Transaction
		SET @RC = +1
	END Try
	BEGIN Catch
		IF @@TranCount > 0 Rollback Transaction
		PRINT Error_Message()
		SET @RC = -1
	END Catch
	RETURN @RC;
  END
go
-- Set Permissions --
-- for dbo.Courses --
Use ITFnd130FinalDB_ChristieGlancy;
DENY SELECT, INSERT, UPDATE, DELETE ON dbo.Courses to Public;
GRANT SELECT ON dbo.vCourses to Public;
GRANT EXECUTE ON dbo.pInsEnrollments to Public;
GRANT EXECUTE ON dbo.pUpdEnrollments to Public;
GRANT EXECUTE ON dbo.pDelEnrollments to Public;
go
-- for dbo.Students --
Use ITFnd130FinalDB_ChristieGlancy;
DENY SELECT, INSERT, UPDATE, DELETE ON dbo.Students to Public;
GRANT SELECT ON dbo.vStudents to Public;
GRANT EXECUTE ON dbo.pInsStudents to Public;
GRANT EXECUTE ON dbo.pUpdStudents to Public;
GRANT EXECUTE ON dbo.pDelStudents to Public;
go
-- for dbo.Enrollments --
Use ITFnd130FinalDB_ChristieGlancy;
DENY SELECT, INSERT, UPDATE, DELETE ON dbo.Enrollments to Public;
GRANT SELECT ON dbo.vEnrollments to Public;
GRANT EXECUTE ON dbo.pInsEnrollments to Public;
GRANT EXECUTE ON dbo.pUpdEnrollments to Public;
GRANT EXECUTE ON dbo.pDelEnrollments to Public;
go

--< Test Sprocs >-- 
DECLARE @Status int -- holds return code data
	,@NewCourseID int -- holds AutoNumber CourseID data
	,@NewStudentID int -- holds AutoNumber StudentID data
	,@NewEnrollID int -- holds AutoNumber EnrollID data
-- Testing Insert Sprocs--
-- Insert Test for dbo.Courses --
Exec @Status = pInsCourses
    @CourseID = @NewCourseID
	,@CourseName = 'TestCourse'
	,@CourseStartDate = '20170111'
	,@CourseEndDate = '20170525'
	,@CourseStartTime = '18:00:00'
	,@CourseEndTime = '20:50:00'
	,@CourseDaysOfWeek = 'W'
	,@CourseCurrentPrice = $399;
SELECT CASE @Status
	WHEN +1 THEN 'Insert to Courses was successful!'
	WHEN -1 THEN 'Insert to Courses failed! Common issues: Duplicate data'
	END AS [Status];
SET @NewCourseID = @@IDENTITY;
SELECT * FROM vCourses WHERE CourseID = @NewCourseID;

--Insert Test for dbo.Students --
Exec @Status = pInsStudents
	@StudentID = @NewStudentID
	,@StudentNum = 'E-Test-123'
	,@StudentFirstName = 'Edna'
	,@StudentLastName = 'Test'
	,@StudentEmail = 'EdnaTest@FakeMail.com'
	,@StudentPhone = '1234567890'
	,@StudentAddress1 = '123 Fake St.'
	,@StudentAddress2 = NULL
	,@StudentCity = 'Charleston'
	,@StudentState = 'SC'
	,@StudentZip = '12345';
SELECT Case @Status
	WHEN +1 THEN 'Insert to Students was successful!'
	WHEN -1 THEN 'Insert to Students failed! Common issues: Duplicate data'
	END AS [Status];
SET @NewStudentID = @@IDENTITY;
SELECT * FROM vStudents WHERE StudentID = @NewStudentID;

-- Insert Test for dbo.Enrollments --
Exec @Status = pInsEnrollments
    @EnrollID = @NewEnrollID
	,@CourseID = 3
	,@StudentID = 3
	,@EnrollDateTime = '20170103'
	,@EnrollPrice = '$399'
SELECT Case @Status
	WHEN +1 THEN 'Insert to Enrollments was successful!'
	WHEN -1 THEN 'Insert to Enrollments failed! Common issues: Duplicate data'
	END AS [Status];
SET @NewEnrollID = @@IDENTITY;
SELECT * FROM vEnrollments WHERE EnrollID = @NewEnrollID;

-- Testing Update Sprocs--
-- Update Test for dbo.Courses --
Exec @Status = pUpdCourses
    @CourseID = @NewCourseID
	,@CourseName = 'TestCourseUpdate'
	,@CourseStartDate = '20170112'
	,@CourseEndDate = '20170526'
	,@CourseStartTime = '18:00:00'
	,@CourseEndTime = '20:50:00'
	,@CourseDaysOfWeek = 'Th'
	,@CourseCurrentPrice = $499;
SELECT Case @Status
	WHEN +1 THEN 'Update to Courses was successful!'
	WHEN -1 THEN 'Update to Courses failed! Common issues: Duplicate data'
	END AS [Status];
SELECT * FROM vCourses WHERE CourseID = @NewCourseID;

--Update Test for dbo.Students --
Exec @Status = pUpdStudents
	@StudentID = 3
	,@StudentNum = 'E-Test-123 Update'
	,@StudentFirstName = 'Edna'
	,@StudentLastName = 'Test'
	,@StudentEmail = 'EdnaTest@FakeMail.com'
	,@StudentPhone = '1112223333' -- new phone number
	,@StudentAddress1 = '123 New Fake St.' -- new address
	,@StudentAddress2 = NULL
	,@StudentCity = 'Charleston'
	,@StudentState = 'SC'
	,@StudentZip = '12345';
SELECT Case @Status
	WHEN +1 THEN 'Update to Students was successful!'
	WHEN -1 THEN 'Update to Students failed! Common issues: Duplicate data'
	END AS [Status];
SELECT * FROM vStudents WHERE StudentID = @NewCourseID;

--Update Test for dbo.Enrollments --
Exec @Status = pUpdEnrollments
	@EnrollID = @NewEnrollID
	,@CourseID = 3
	,@StudentID = 3
	,@EnrollDateTime = '01/03/2017'
	,@EnrollPrice = $599 -- price change
SELECT Case @Status
	WHEN +1 THEN 'Update to Enrollments was successful!'
	WHEN -1 THEN 'Update to Enrollments failed! Common issues: Duplicate data'
	END AS [Status];
SELECT * FROM vEnrollments WHERE EnrollID = @NewEnrollID;

--Show data before Delete--
SELECT * FROM vStudentsCoursesEnrollments;

-- Testing Delete Sprocs--
-- Delete Test for dbo.Enrollments --
Exec @Status = pDelEnrollments
	@EnrollID = @NewEnrollID;
SELECT Case @Status
	WHEN +1 THEN 'Delete was successful!'
	WHEN -1 THEN 'Delete failed! Common Issues: Foreign Key Violation'
	END AS [Status];
SELECT * FROM vEnrollments;

-- Delete Test for dbo.Courses --
Exec @Status = pDelCourses
	@CourseID = @NewCourseID;
SELECT Case @Status
	WHEN +1 THEN 'Delete was successful!'
	WHEN -1 THEN 'Delete failed! Common Issues: Foreign Key Violation'
	END AS [Status];
SELECT * FROM vCourses;

-- Delete Test for dbo.Students --
Exec @Status = pDelStudents
	@StudentID = @NewStudentID;
SELECT Case @Status
	WHEN +1 THEN 'Delete was successful!'
	WHEN -1 THEN 'Delete failed! Common Issues: Foreign Key Violation'
	END AS [Status];
SELECT * FROM vStudents;

--{ IMPORTANT!!! }--
-- To get full credit, your script must run without having to highlight individual statements!!!  
/**************************************************************************************************/