-- Create a new database called 'Company'
-- Connect to the 'master' database to run this snippet
USE master
GO
-- Create the new database if it does not exist already
IF NOT EXISTS (
  SELECT [name]
    FROM sys.databases
    WHERE [name] = N'Company'
)
CREATE DATABASE Company
GO
USE Company;
-- Create a new table called '[Employee]' in schema '[dbo]'
-- Drop the table if it already exists
IF OBJECT_ID('[dbo].[Employee]', 'U') IS NOT NULL
DROP TABLE [dbo].[Employee]
GO
-- Create the table in the specified schema
CREATE TABLE [dbo].[Employee](
  [Id] [int] IDENTITY(1,1) NOT NULL,
  [TCKN] [nvarchar](11) NULL,
  [Name] [nvarchar](50) NULL,
  [Surname] [nvarchar](50) NULL,
  [Startdate] [datetime] NOT NULL,
  [TypeId] [int] NOT NULL
);
GO
-- Create a new table called '[EmployeeOvertime]' in schema '[dbo]'
-- Drop the table if it already exists
IF OBJECT_ID('[dbo].[EmployeeOvertime]', 'U') IS NOT NULL
DROP TABLE [dbo].[EmployeeOvertime]
GO
-- Create the table in the specified schema
CREATE TABLE [dbo].[EmployeeOvertime](
  [OvertimeId] [int] IDENTITY(1,1) NOT NULL,
  [EmployeeId] [int] NOT NULL,
  [Overtime] [int] NULL,
  [CreateDate] [datetime] NOT NULL,
  [IsActive] [bit] NOT NULL
);
GO
-- Create a new table called '[Salary]' in schema '[dbo]'
-- Drop the table if it already exists
IF OBJECT_ID('[dbo].[Salary]', 'U') IS NOT NULL
DROP TABLE [dbo].[Salary]
GO
-- Create the table in the specified schema
CREATE TABLE [dbo].[Salary](
  [SalaryId] [int] IDENTITY(1,1) NOT NULL,
  [EmployeeId] [int] NOT NULL,
  [Salary] [float] NULL
);
GO

USE Company;
GO
-- Create the StoredProcedure spGetEmployeeId
IF OBJECT_ID('dbo.spGetEmployeeId', 'p') IS NULL
    EXEC ('CREATE PROCEDURE spGetEmployeeId AS SELECT 1')
GO
ALTER PROCEDURE spGetEmployeeId AS
SET NOCOUNT ON
       BEGIN
            SET NOCOUNT ON;
            SELECT * FROM [Company].[dbo].[Employee] 
        END
GO
-- Create the StoredProcedure spGetEmployee
IF OBJECT_ID('dbo.spGetEmployee', 'p') IS NULL
    EXEC ('CREATE PROCEDURE spGetEmployee AS SELECT 1')
GO
ALTER PROCEDURE spGetEmployee AS
SET NOCOUNT ON
       BEGIN
            SET NOCOUNT ON;
            SELECT * FROM [Company].[dbo].[Employee] E
			INNER JOIN [Company].[dbo].[Salary] S
			ON E.Id = S.EmployeeId
        END
GO
-- Create the StoredProcedure spGetEmployeeById
IF OBJECT_ID('dbo.spGetEmployeeById', 'p') IS NULL
    EXEC ('CREATE PROCEDURE spGetEmployeeById AS SELECT 1')
GO
ALTER PROCEDURE spGetEmployeeById
@Id int
AS
SET NOCOUNT ON
       BEGIN
            SET NOCOUNT ON;
            SELECT * FROM [Company].[dbo].[Employee] E
			INNER JOIN [Company].[dbo].[Salary] S
			ON E.Id = S.EmployeeId
			WHERE E.Id = @Id
        END
GO
-- Create the StoredProcedure spCalculateEmployeeSalary
IF OBJECT_ID('dbo.spCalculateEmployeeSalary', 'p') IS NULL
    EXEC ('CREATE PROCEDURE dbo.spCalculateEmployeeSalary AS SELECT 1')
GO
ALTER PROCEDURE dbo.spCalculateEmployeeSalary 
@Id int
AS
SET NOCOUNT ON
   DECLARE @OvertimePrice float;
	SET @OvertimePrice = 12;

	DECLARE @DayPrice float;
	SET @DayPrice = 50;

	DECLARE @DayCount int;
	DECLARE @Overtime int;
	DECLARE @Salary float;
	DECLARE @TypeId int;
	DECLARE @StartDate datetime;
	DECLARE @Count int;

BEGIN

SELECT @TypeId = TypeId, @Startdate = StartDate FROM [Company].[dbo].[Employee]
WHERE Id=@Id

IF	@TypeId = 2
  BEGIN
    SET @DayCount = DATEDIFF(DAY,CONVERT(VARCHAR(10),DATEADD(dd,-(DAY(GETDATE())-1),GETDATE()),112),GETDATE())
    SET @Salary = @DayCount * @DayPrice

	SELECT @Count = COUNT(EmployeeId) FROM [Company].[dbo].[Salary] 
	WHERE EmployeeId=@Id

	IF @Count <1
	   BEGIN
	   INSERT INTO [Company].[dbo].[Salary]
	   (EmployeeId,Salary)
	   Values(@Id,@Salary)
	   END
	ELSE
	   BEGIN
	   UPDATE [Company].[dbo].[Salary]
	   SET Salary=@Salary
	   WHERE EmployeeId=@Id
	   END
  END
IF	@TypeId = 3
   BEGIN 
     SELECT @Overtime = SUM(O.Overtime) FROM [Company].[dbo].[EmployeeOvertime] O
     INNER JOIN [Company].[dbo].[Employee] E
     ON E.Id=O.EmployeeId
	 WHERE O.IsActive=0 AND E.Id=O.EmployeeId
     GROUP BY MONTH(O.CreateDate)
    
    SET @Overtime = (@OvertimePrice * @Overtime)

    UPDATE S SET S.Salary=S.Salary+@Overtime FROM [Company].[dbo].[Salary] S
	INNER JOIN [Company].[dbo].[EmployeeOvertime] O
	ON S.EmployeeId=O.EmployeeId
	WHERE S.EmployeeId=@Id 
	AND O.IsActive=0

	UPDATE [Company].[dbo].[EmployeeOvertime]
    SET IsActive=1
    WHERE EmployeeId=@Id AND IsActive=0

  END
END
GO

USE Company;
-- Create the StoredProcedure InsertEmployee
IF OBJECT_ID('dbo.InsertEmployee', 'p') IS NULL
    EXEC ('CREATE PROCEDURE dbo.InsertEmployee AS SELECT 1')
GO
ALTER PROCEDURE dbo.InsertEmployee  (
  @TCKN nvarchar(11),
  @Name nvarchar(50),
  @Surname nvarchar(50),
  @Startdate datetime,
  @TypeId int 
) AS
BEGIN
DECLARE @COUNT int;
SELECT @COUNT = COUNT(TCKN) FROM Employee E
WHERE E.TCKN=@TCKN
IF @COUNT<1
   BEGIN
       INSERT INTO Employee (TCKN, Name, Surname, Startdate, TypeId)
       VALUES (@TCKN, @Name, @Surname, @StartDate, @TypeId);
   END
ELSE
   BEGIN
   UPDATE Employee SET
   Name=@Name,Surname=@Surname,Startdate=@Startdate,TypeId=@TypeId
   WHERE TCKN=@TCKN
   END
END
GO
-- Execute the StoredProcedure InsertEmployee
Exec dbo.InsertEmployee @TCKN='12345678912',
                        @Name='Test',
						@Surname='Test',
						@StartDate='20190101',
						@TypeId = 1
Exec dbo.InsertEmployee @TCKN='12345678913',
                        @Name='Test2',
						@Surname='Test2',
						@StartDate='20200101',
						@TypeId = 2
Exec dbo.InsertEmployee @TCKN='12345678914',
                        @Name='Test3',
						@Surname='Test3',
						@StartDate='20200101',
						@TypeId = 3

-- Create the StoredProcedure InsertOvertime
IF OBJECT_ID('dbo.InsertOvertime', 'p') IS NULL
    EXEC ('CREATE PROCEDURE InsertOvertime AS SELECT 1')
GO
ALTER PROCEDURE InsertOvertime  (
  @EmployeeId int,
  @Overtime int,
  @Createdate datetime,
  @IsActive bit 
) AS
BEGIN

    INSERT INTO EmployeeOvertime (EmployeeId, Overtime, Createdate, IsActive)
    VALUES (@EmployeeId, @Overtime, @Createdate, @IsActive);
	END

GO
-- Execute the StoredProcedure InsertOvertime
Exec dbo.InsertOvertime @EmployeeId=3,
                        @Overtime=5,
						@CreateDate='20201001',
						@IsActive=0
Exec dbo.InsertOvertime @EmployeeId=3,
                        @Overtime=2,
						@CreateDate='20201005',
						@IsActive=0
Exec dbo.InsertOvertime @EmployeeId=3,
                        @Overtime=3,
						@CreateDate='20201105',
						@IsActive=0
Exec dbo.InsertOvertime @EmployeeId=3,
                        @Overtime=2,
						@CreateDate='20201004',
						@IsActive=0
Exec dbo.InsertOvertime @EmployeeId=3,
                        @Overtime=5,
						@CreateDate='20201008',
						@IsActive=0
-- Create the StoredProcedure InsertSalary
IF OBJECT_ID('dbo.InsertSalary', 'p') IS NULL
    EXEC ('CREATE PROCEDURE dbo.InsertSalary AS SELECT 1')
GO
ALTER PROCEDURE dbo.InsertSalary  (
  @EmployeeId int,
  @Salary float 
) AS
BEGIN
    INSERT INTO Salary (EmployeeId, Salary)
    VALUES (@EmployeeId, @Salary);
	END
GO
-- Execute the StoredProcedure InsertSalary
Exec dbo.InsertSalary @EmployeeId=1,
                        @Salary=3000
Exec dbo.InsertSalary @EmployeeId=3,
                       @Salary=2500