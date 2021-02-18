PRAGMA foreign_keys = off;
BEGIN TRANSACTION;

/*
Drop the tables if they exist
*/

DROP TABLE IF EXISTS Event;
DROP TABLE IF EXISTS Reservation;
DROP TABLE IF EXISTS ExamEnrollment;
DROP TABLE IF EXISTS ExerciseGroupEnrollment;
DROP TABLE IF EXISTS Lecture;
DROP TABLE IF EXISTS ExerciseSession;
DROP TABLE IF EXISTS ExerciseGroup;
DROP TABLE IF EXISTS CourseInstance;
DROP TABLE IF EXISTS Room;
DROP TABLE IF EXISTS Equipment;
DROP TABLE IF EXISTS Exam;
DROP TABLE IF EXISTS Course;
DROP TABLE IF EXISTS Student;
DROP TABLE IF EXISTS Building;

/*
Create all the table here
*/
CREATE TABLE Event (
    Type varchar(255),
    Date date,
    StartTime time(0),
    EndTime time(0),
    ForeignID INTEGER,
    ReservationID INTEGER,
    CONSTRAINT Unique_foreign_key UNIQUE (ForeignID,Type),
    CONSTRAINT FK_Reservation FOREIGN KEY (ReservationID) REFERENCES Reservation(ReservationID),
    CONSTRAINT Type_list CHECK (Type in ('Lecture', 'ExerciseSession', 'Exam')),    
    CONSTRAINT CK_Start_Time_before_End_Time CHECK (StartTime is null OR EndTime is null OR StartTime < EndTime)
);

DROP INDEX IF EXISTS Event_Type;
CREATE INDEX Event_Type ON Event (Type);

CREATE TABLE Course (
    CourseCode varchar(255) PRIMARY KEY,
    Name varchar(255),
    Credits float
);

DROP INDEX IF EXISTS Course_Name;
CREATE UNIQUE INDEX Course_Name ON Course (Name);

CREATE TABLE CourseInstance (
    CourseInstanceID INTEGER PRIMARY KEY AUTOINCREMENT,
    CourseCode varchar(255),
    StartDate date,
    EndDate date,    
    CONSTRAINT FK_Course FOREIGN KEY (CourseCode) REFERENCES Course(CourseCode),
    CONSTRAINT CK_Start_Date_before_End_Date   
    CHECK (StartDate is null OR EndDate is null OR StartDate < EndDate)
);

CREATE TABLE Lecture (
    LectureID INTEGER PRIMARY KEY AUTOINCREMENT,
    CourseInstanceID INTEGER,
    CONSTRAINT FK_CourseInstance FOREIGN KEY (CourseInstanceID) REFERENCES CourseInstance(CourseInstanceID)
);

CREATE TABLE ExerciseGroup (
    ExerciseGroupID INTEGER PRIMARY KEY AUTOINCREMENT,
    CourseInstanceID INTEGER,
    Limitation INTEGER,
    CONSTRAINT FK_CourseInstance FOREIGN KEY (CourseInstanceID) REFERENCES CourseInstance(CourseInstanceID)
);

CREATE TABLE ExerciseSession (
    ExerciseSessionID INTEGER PRIMARY KEY AUTOINCREMENT,
    ExerciseGroupID INTEGER,
    CONSTRAINT FK_ExerciseGroup FOREIGN KEY (ExerciseGroupID) REFERENCES ExerciseGroup(ExerciseGroupID)
);

CREATE TABLE Exam (
    ExamID INTEGER PRIMARY KEY AUTOINCREMENT,
    CourseCode varchar(255),
    CONSTRAINT FK_Course FOREIGN KEY (CourseCode) REFERENCES Course(CourseCode)
);

CREATE TABLE Student (
    StudentID INTEGER PRIMARY KEY AUTOINCREMENT,
    Name varchar(255),
    DateOfBirth date,
    DegreeProgram varchar(255),
    StartYear INTEGER,
    ExpirationDate date
);

DROP INDEX IF EXISTS Student_Name;
CREATE UNIQUE INDEX Student_Name ON Student (Name);

CREATE TABLE ExamEnrollment (
    ExamID int not null,
    StudentID int not null,
    CONSTRAINT PK_ExamEnrollment PRIMARY KEY (ExamID,StudentID),
    CONSTRAINT FK_Exam FOREIGN KEY (ExamID) REFERENCES Exam(ExamID),
    CONSTRAINT FK_Student FOREIGN KEY (StudentID) REFERENCES Student(StudentID)
);

CREATE TABLE ExerciseGroupEnrollment (
    ExerciseGroupID INTEGER not null,
    StudentID INTEGER not null,
    CONSTRAINT PK_ExerciseGroupEnrollment PRIMARY KEY (ExerciseGroupID,StudentID),
    CONSTRAINT FK_ExGroup FOREIGN KEY (ExerciseGroupID) REFERENCES ExerciseGroup(ExerciseGroupID),
    CONSTRAINT FK_Student FOREIGN KEY (StudentID) REFERENCES Student(StudentID)
);

CREATE TABLE Building (
    BuildingID INTEGER PRIMARY KEY AUTOINCREMENT,
    Name varchar(255),
    StreetAddress varchar(255)
);

DROP INDEX IF EXISTS Building_name;
CREATE UNIQUE INDEX Building_name ON Building (Name);

CREATE TABLE Room (
    RoomID INTEGER PRIMARY KEY AUTOINCREMENT,
    BuildingID INTEGER,
    NumberOfSeats INTEGER,
    NumberOfExamSeats INTEGER,
    CONSTRAINT FK_Building FOREIGN KEY (BuildingID) REFERENCES Building(BuildingID)
);

DROP INDEX IF EXISTS Room_buildingID;
CREATE INDEX Room_buildingID ON Room (buildingID);

CREATE TABLE Equipment (
    EquipmentID INTEGER PRIMARY KEY AUTOINCREMENT,
    Name varchar(255),
    Type varchar(255),
    AssessiblyBy varchar(255)
);

DROP INDEX IF EXISTS Equipment_Name;
CREATE INDEX Equipment_Name ON Equipment (Name);

CREATE TABLE Reservation (
    ReservationID INTEGER PRIMARY KEY AUTOINCREMENT,
    RoomID INTEGER,
    StartTime time(0),
    EndTime time(0),
    Date date,
    CONSTRAINT FK_ROOM FOREIGN KEY (RoomID) REFERENCES Room(RoomID),
    CONSTRAINT CK_Start_Time_before_End_Time  
    CHECK (StartTime is null OR EndTime is null OR StartTime < EndTime)
);

DROP INDEX IF EXISTS Reservation_RoomID_Date;
CREATE INDEX Reservation_RoomID_Date ON Reservation (RoomID, Date);

/*
Add records to Student table
*/

INSERT INTO Student
VALUES(112233, 'Teemu Teekkari','1995-12-25', 'TIK', 2017, '2021-05-30');
INSERT INTO Student
VALUES(123456, 'Tiina Teekkari','1991-11-26', 'TUO', 2019, '2023-05-30');
INSERT INTO Student
VALUES(224411, 'Van Anh Do','1998-03-27', 'AUT', 2021, '2025-12-31');
INSERT INTO Student
VALUES(224412, 'Khoa Lai','1998-03-27', 'TIK', 2018, '2021-12-31');
INSERT INTO Student
VALUES(224413, 'Jeheon Kim','1989-03-27', 'TIK', 2018, '2021-12-31');

/*
Add records to Course table
*/

INSERT INTO Course
VALUES('CS-A1111', 'Basic Course in Programming Y1', 5.0);
INSERT INTO Course
VALUES('CS-A1120', 'Programming 2', 4.0);
INSERT INTO Course
VALUES('CS-A1130', 'Superhuman Analysis', 6.0);
INSERT INTO Course
VALUES('CS-A1140', 'Fus Ro Dah', 3.0);
INSERT INTO Course
VALUES('CS-A1150', 'Test-Course', 3.0);

/*
Add records to Building table
*/

INSERT INTO Building (Name, StreetAddress)
VALUES('Maarintalo', 'Espoo');
INSERT INTO Building (Name, StreetAddress)
VALUES('TUAS', 'Helsinki');
INSERT INTO Building (Name, StreetAddress)
VALUES('Main Building', 'Vantaa');
INSERT INTO Building (Name, StreetAddress)
VALUES('CS Building', 'Espoo');
INSERT INTO Building (Name, StreetAddress)
VALUES('Innovation House', 'Helsinki');
INSERT INTO Building (Name, StreetAddress)
VALUES('Vare', 'Vantaa');

/*
Add records to Room  table
*/

INSERT INTO Room (BuildingID,NumberOfSeats,NumberOfExamSeats)
VALUES (1,50,30);
INSERT INTO Room (BuildingID,NumberOfSeats,NumberOfExamSeats)
VALUES (1,40,30);
INSERT INTO Room (BuildingID,NumberOfSeats,NumberOfExamSeats)
VALUES (1,50,20);
INSERT INTO Room (BuildingID,NumberOfSeats,NumberOfExamSeats)
VALUES (1,10,5);
INSERT INTO Room (BuildingID,NumberOfSeats,NumberOfExamSeats)
VALUES (2,10,5);
INSERT INTO Room (BuildingID,NumberOfSeats,NumberOfExamSeats)
VALUES (2,10,5);
INSERT INTO Room (BuildingID,NumberOfSeats,NumberOfExamSeats)
VALUES (3,10,5);
INSERT INTO Room (BuildingID,NumberOfSeats,NumberOfExamSeats)
VALUES (3,10,5);
INSERT INTO Room (BuildingID,NumberOfSeats,NumberOfExamSeats)
VALUES (4,10,5);

/*
Add records to Reservation table
*/

INSERT INTO Reservation (RoomID, Date, StartTime, EndTime)
VALUES (1, '2020-05-01', '08:00:00','13:00:00');

INSERT INTO Reservation (RoomID, Date, StartTime, EndTime)
VALUES (2, '2020-03-01', '08:00:00','13:00:00');

INSERT INTO Reservation (RoomID, Date, StartTime, EndTime)
VALUES (3, '2020-03-01', '08:00:00','13:00:00');

INSERT INTO Reservation (RoomID, Date, StartTime, EndTime)
VALUES (4, '2020-09-01', '12:00:00','17:00:00');

INSERT INTO Reservation (RoomID, Date, StartTime, EndTime)
VALUES (4, '2020-09-01', '12:00:00','17:00:00');

INSERT INTO Reservation (RoomID, Date, StartTime, EndTime)
VALUES (4, '2020-11-01', '12:00:00','17:00:00');

INSERT INTO Reservation (RoomID, Date, StartTime, EndTime)
VALUES (5, '2020-01-31', '12:00:00','17:00:00');

INSERT INTO Reservation (RoomID, Date, StartTime, EndTime)
VALUES (6, '2020-09-01', '12:00:00','17:00:00');

INSERT INTO Reservation (RoomID, Date, StartTime, EndTime)
VALUES (6, '2020-01-01', '09:00:00','10:00:00');
INSERT INTO Reservation (RoomID, Date, StartTime, EndTime)
VALUES (5, '2020-01-02', '09:00:00','10:00:00');
INSERT INTO Reservation (RoomID, Date, StartTime, EndTime)
VALUES (5, '2020-01-03', '09:00:00','10:00:00');
INSERT INTO Reservation (RoomID, Date, StartTime, EndTime)
VALUES (5, '2020-01-04', '09:00:00','10:00:00');
INSERT INTO Reservation (RoomID, Date, StartTime, EndTime)
VALUES (5, '2020-01-05', '09:00:00','10:00:00');

/*
Add records to CourseInstance table
*/

INSERT INTO CourseInstance (CourseCode, StartDate, EndDate)
VALUES('CS-A1111', '2020-01-01','2020-03-01');
INSERT INTO CourseInstance (CourseCode, StartDate, EndDate)
VALUES('CS-A1111', '2020-04-01','2020-06-01');
INSERT INTO CourseInstance (CourseCode, StartDate, EndDate)
VALUES('CS-A1120', '2021-01-01','2021-03-01');
INSERT INTO CourseInstance (CourseCode, StartDate, EndDate)
VALUES('CS-A1130', '2021-04-01','2021-06-01');
INSERT INTO CourseInstance (CourseCode, StartDate, EndDate)
VALUES('CS-A1140', '2021-01-01','2021-03-01');

/* 
Add records to Exam table
*/

INSERT INTO Exam (ExamID, CourseCode)
VALUES(1,'CS-A1111');
INSERT INTO Event(ForeignID, Type , StartTime, EndTime, Date, ReservationID) 
VALUES(1, 'Exam', '09:00:00','12:00:00','2020-03-01', NULL);

INSERT INTO Exam (ExamID, CourseCode)
VALUES(2,'CS-A1111');
INSERT INTO Event(ForeignID, Type , StartTime, EndTime, Date, ReservationID) 
VALUES(2, 'Exam', '09:00:00','12:00:00','2020-05-01',1);

INSERT INTO Exam (ExamID, CourseCode)
VALUES(3,'CS-A1120');
INSERT INTO Event(ForeignID, Type , StartTime, EndTime, Date, ReservationID) 
VALUES(3, 'Exam', '09:00:00','12:00:00','2020-05-01',1);

INSERT INTO Exam (ExamID, CourseCode)
VALUES(4,'CS-A1120');
INSERT INTO Event(ForeignID, Type , StartTime, EndTime, Date, ReservationID) 
VALUES(4, 'Exam', '13:00:00','16:00:00','2020-07-01',NULL);

INSERT INTO Exam (ExamID, CourseCode)
VALUES(5,'CS-A1130');
INSERT INTO Event(ForeignID, Type , StartTime, EndTime, Date, ReservationID) 
VALUES(5, 'Exam', '13:00:00','16:00:00','2020-09-01',NULL);

INSERT INTO Exam (ExamID, CourseCode)
VALUES(6,'CS-A1140');
INSERT INTO Event(ForeignID, Type , StartTime, EndTime, Date, ReservationID) 
VALUES(6, 'Exam', '13:00:00','16:00:00','2020-11-01',NULL);

/* 
Add records to ExamEnrollment table
*/
INSERT INTO ExamEnrollment (StudentID, ExamID)
VALUES(112233,1);
INSERT INTO ExamEnrollment (StudentID, ExamID)
VALUES(112233,2);
INSERT INTO ExamEnrollment (StudentID, ExamID)
VALUES(112233,3);
INSERT INTO ExamEnrollment (StudentID, ExamID)
VALUES(123456,1);
INSERT INTO ExamEnrollment (StudentID, ExamID)
VALUES(224411,1);
INSERT INTO ExamEnrollment (StudentID, ExamID)
VALUES(224412,4);
INSERT INTO ExamEnrollment (StudentID, ExamID)
VALUES(224412,1);
INSERT INTO ExamEnrollment (StudentID, ExamID)
VALUES(224413,1);
INSERT INTO ExamEnrollment (StudentID, ExamID)
VALUES(224411,4);

/* 
Add records to ExerciseGroup table
*/
INSERT INTO ExerciseGroup (CourseInstanceID, Limitation)
VALUES (1,10);
INSERT INTO ExerciseGroup (CourseInstanceID, Limitation)
VALUES (1,20);
INSERT INTO ExerciseGroup (CourseInstanceID, Limitation)
VALUES (2,20);
INSERT INTO ExerciseGroup (CourseInstanceID, Limitation)
VALUES (2,20);
INSERT INTO ExerciseGroup (CourseInstanceID, Limitation)
VALUES (3,20);
INSERT INTO ExerciseGroup (CourseInstanceID, Limitation)
VALUES (4,20);
INSERT INTO ExerciseGroup (CourseInstanceID, Limitation)
VALUES (5,50);

/*
Add records to ExerciseSession
*/
INSERT INTO ExerciseSession (ExerciseSessionID, ExerciseGroupID)
VALUES (1,1);
INSERT INTO Event(ForeignID, Type , StartTime, EndTime, Date, ReservationID) 
VALUES(1, 'ExerciseSession', '13:00:00','16:00:00','2020-09-01',NULL);

INSERT INTO ExerciseSession (ExerciseSessionID, ExerciseGroupID)
VALUES (2,1);
INSERT INTO Event(ForeignID, Type , StartTime, EndTime, Date, ReservationID) 
VALUES(2, 'ExerciseSession', '13:00:00','16:00:00','2020-10-01',NULL);

INSERT INTO ExerciseSession (ExerciseSessionID, ExerciseGroupID)
VALUES (3,1);
INSERT INTO Event(ForeignID, Type , StartTime, EndTime, Date, ReservationID) 
VALUES(3, 'ExerciseSession', '11:00:00','18:00:00','2020-01-01',NULL);

INSERT INTO ExerciseSession (ExerciseSessionID, ExerciseGroupID)
VALUES (4,1);
INSERT INTO Event(ForeignID, Type , StartTime, EndTime, Date, ReservationID) 
VALUES(4, 'ExerciseSession', '08:00:00','16:00:00','2020-01-31',NULL);

INSERT INTO ExerciseSession (ExerciseSessionID, ExerciseGroupID)
VALUES (5,2);
INSERT INTO Event(ForeignID, Type , StartTime, EndTime, Date, ReservationID) 
VALUES(5, 'ExerciseSession', '13:00:00','16:00:00','2019-09-01',NULL);

INSERT INTO ExerciseSession (ExerciseSessionID, ExerciseGroupID)
VALUES (6,2);
INSERT INTO Event(ForeignID, Type , StartTime, EndTime, Date, ReservationID) 
VALUES(6, 'ExerciseSession', '01:00:00','06:00:00','2020-08-01',NULL);

INSERT INTO ExerciseSession (ExerciseSessionID, ExerciseGroupID)
VALUES (7,3);
INSERT INTO Event(ForeignID, Type , StartTime, EndTime, Date, ReservationID) 
VALUES(7, 'ExerciseSession', '13:00:00','16:00:00','2020-09-01',8);

INSERT INTO ExerciseSession (ExerciseSessionID, ExerciseGroupID)
VALUES (8,4);
INSERT INTO Event(ForeignID, Type , StartTime, EndTime, Date, ReservationID) 
VALUES(8, 'ExerciseSession', '13:00:00','16:00:00','2020-02-01',NULL);

INSERT INTO ExerciseSession (ExerciseSessionID, ExerciseGroupID)
VALUES (9,4);
INSERT INTO Event(ForeignID, Type , StartTime, EndTime, Date, ReservationID) 
VALUES(9, 'ExerciseSession', '13:00:00','16:00:00','2020-09-01',NULL);

INSERT INTO ExerciseSession (ExerciseSessionID, ExerciseGroupID)
VALUES (10,2);
INSERT INTO Event(ForeignID, Type , StartTime, EndTime, Date, ReservationID) 
VALUES(10, 'ExerciseSession', '13:00:00','16:00:00','2020-07-01',NULL);


/* 
Add records to ExamEnrollment table
*/
INSERT INTO ExerciseGroupEnrollment (StudentID, ExerciseGroupID)
VALUES(112233,1);
INSERT INTO ExerciseGroupEnrollment (StudentID, ExerciseGroupID)
VALUES(112233,2);
INSERT INTO ExerciseGroupEnrollment (StudentID, ExerciseGroupID)
VALUES(112233,3);
INSERT INTO ExerciseGroupEnrollment (StudentID, ExerciseGroupID)
VALUES(123456,1);
INSERT INTO ExerciseGroupEnrollment (StudentID, ExerciseGroupID)
VALUES(224411,1);
INSERT INTO ExerciseGroupEnrollment (StudentID, ExerciseGroupID)
VALUES(224412,4);
INSERT INTO ExerciseGroupEnrollment (StudentID, ExerciseGroupID)
VALUES(224412,1);
INSERT INTO ExerciseGroupEnrollment (StudentID, ExerciseGroupID)
VALUES(224413,1);
INSERT INTO ExerciseGroupEnrollment (StudentID, ExerciseGroupID)
VALUES(224411,4);

/*
Add records to Lecture table
*/
INSERT INTO Lecture (LectureID, CourseInstanceID)
VALUES (1,1);
INSERT INTO Event(ForeignID, Type , Date, StartTime, EndTime, ReservationID) 
VALUES(1, 'Lecture','2020-01-01','09:00:00','10:00:00',9);

INSERT INTO Lecture (LectureID, CourseInstanceID)
VALUES (2,1);
INSERT INTO Event(ForeignID, Type , Date, StartTime, EndTime, ReservationID) 
VALUES(2, 'Lecture','2020-01-02','09:00:00','10:00:00',10);

INSERT INTO Lecture (LectureID, CourseInstanceID)
VALUES (3,1);
INSERT INTO Event(ForeignID, Type , Date, StartTime, EndTime, ReservationID) 
VALUES(3, 'Lecture','2020-01-03','09:00:00','10:00:00',11);

INSERT INTO Lecture (LectureID, CourseInstanceID)
VALUES (4,1);
INSERT INTO Event(ForeignID, Type , Date, StartTime, EndTime, ReservationID) 
VALUES(4, 'Lecture','2020-01-04','09:00:00','10:00:00',12);

INSERT INTO Lecture (LectureID, CourseInstanceID)
VALUES (5,1);
INSERT INTO Event(ForeignID, Type , Date, StartTime, EndTime, ReservationID) 
VALUES(5, 'Lecture','2020-01-05','09:00:00','10:00:00',13);

INSERT INTO Lecture (LectureID, CourseInstanceID)
VALUES (6,2);
INSERT INTO Event(ForeignID, Type , Date, StartTime, EndTime, ReservationID) 
VALUES(6, 'Lecture','2020-01-01','09:00:00','10:00:00',NULL);

INSERT INTO Lecture (LectureID, CourseInstanceID)
VALUES (7,3);
INSERT INTO Event(ForeignID, Type , Date, StartTime, EndTime, ReservationID) 
VALUES(7, 'Lecture','2020-02-27','09:00:00','10:00:00',NULL);

INSERT INTO Lecture (LectureID, CourseInstanceID)
VALUES (8,4);
INSERT INTO Event(ForeignID, Type , Date, StartTime, EndTime, ReservationID) 
VALUES(8, 'Lecture','2020-03-03','09:00:00','10:00:00',NULL);

INSERT INTO Lecture (LectureID, CourseInstanceID)
VALUES (9,5);
INSERT INTO Event(ForeignID, Type , Date, StartTime, EndTime, ReservationID) 
VALUES(9, 'Lecture','2020-03-04','09:00:00','10:00:00',NULL);

INSERT INTO Lecture (LectureID, CourseInstanceID)
VALUES (10,2);
INSERT INTO Event(ForeignID, Type , Date, StartTime, EndTime, ReservationID) 
VALUES(10, 'Lecture','2020-02-05','09:00:00','10:00:00',NULL);

INSERT INTO Lecture (LectureID, CourseInstanceID)
VALUES (11,2);
INSERT INTO Event(ForeignID, Type , Date, StartTime, EndTime, ReservationID) 
VALUES(11, 'Lecture','2020-02-05','09:00:00','10:00:00',NULL);

INSERT INTO Lecture (LectureID, CourseInstanceID)
VALUES (12,2);
INSERT INTO Event(ForeignID, Type , Date, StartTime, EndTime, ReservationID) 
VALUES(12, 'Lecture','2020-03-05','09:00:00','10:00:00',NULL);

INSERT INTO Lecture (LectureID, CourseInstanceID)
VALUES (13, 3);
INSERT INTO Event(ForeignID, Type , Date, StartTime, EndTime, ReservationID) 
VALUES(13, 'Lecture','2020-04-05','09:00:00','10:00:00',NULL);

COMMIT TRANSACTION;
PRAGMA foreign_keys = on;
