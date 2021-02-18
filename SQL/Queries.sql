/*  This sql file covers some use cases for the database that are derived from real-life situations  */


/*  1. The student wants to search the courses that are arranged during the certain time interval
    
    The query should return: CourseName, CourseInstanceID, StartDate, EndDate 
   
    Here is an example query with following values
    : StartDate = '2020-01-02', EndDate = '2025-01-01' */
    
    SELECT Name, CourseInstanceID, StartDate, EndDate
    FROM (SELECT *
          FROM Course JOIN CourseInstance
          ON Course.CourseCode = CourseInstance.CourseCode
          )
    WHERE StartDate >= '2020-01-02' AND EndDate <= '2025-01-01';

/*  The result table should contain all courses except for one 'Basic Course in Programming Y1'
    which starts at 2020-01-01 and ends at 2020-03-01 (Its start date is one day late than input startDate) */



/*  2. The professor wants to check if there is any reservation for a room on the certain date and time interval
    
    The query should return: ReservationID, RoomID, StartTime, EndTime, Date

    Here is an example query with following values
    : RoomID = 6, Date = 2020-01-01, StartTime = '06:00:00', EndTime = '16:00:00' */
    
    SELECT *
    FROM Reservation
    WHERE RoomID = 6 AND StartTime >= '06:00:00' AND EndTime <= '16:00:00'
          AND Date = '2020-01-01'; 
    
/*  The result table should contain only one tuple with an reserationID 9 on 2020-01-01 which starts at 09:00:00 
    and ends at 10:00:00. The time interval from 09:00:00 to 10:00:00 is in between from 06:00:00 to 16:00:00 */
    


/*  3. The student wants to know which exams a certain course has during the certain time interval
    
    The query should return: CourseCode, CourseName, Date, StartTime, ExamDate, StartTime, EndTime
    
    Here is an example query with following values
    : Name = 'Basic Course in Programming Y1', StartTime = '08:00:00', EndTime = '13:00:00' */
    
    SELECT CourseCode, Name AS CourseName, Date AS ExamDate, StartTime, EndTime
    FROM (SELECT *
          FROM Course, Exam
          WHERE Course.CourseCode = Exam.CourseCode), Event
    WHERE ExamID = ForeignID AND Type = 'Exam'
          AND Name = 'Basic Course in Programming Y1'
          AND StartTime >= '08:00:00' AND EndTime <= '13:00:00';
          
/*  The result table should contain two exams of the course 'Basic Course in Programming Y1'
    that are held in different date (2020-03-01 and 2020-05-01) but same StartTime and Endtime 
    Because the query is designed to specify only the time interval (without the date), 
    it is possible that the result contains several exams on different dates */



/*  4. The student wants to find out when a certain course has been arranged or will be arranged.
    
    The query should return: CourseCode, CourseName, CourseStartDate, CourseEndDate

    Here is an example query with following values
    : CourseName = 'Basic Course in Programming Y1' or CourseCode = 'CS-A9999' */
    
    DROP VIEW IF EXISTS [COURSE ARRANGEMENT];
    CREATE VIEW[COURSE ARRANGEMENT] AS
    SELECT CourseCode, Name, StartDate, EndDate
    FROM (SELECT *
          FROM Course, CourseInstance
          WHERE Course.CourseCode = CourseInstance.CourseCode)
    WHERE Name = 'Basic Course in Programming Y1' OR CourseCode = 'CS-A9999';
          
/*  The result table should contain two tuples of the same course that are arranged in different date interval.
    Although the right CourseCode for 'Basic Course in Programming Y1' was CS-A1111, it returned the right results
    because the CourseName was correct (Either CourseCode or CourseName is enough for the search) */
    

/*  5. Find the lectures belonging to a certain course instance.

    The query should return: LectureID, Date, StartTime, EndTime

    Here is an example query with the following value
    : CourseInstanceID = 2 */
    
    DROP VIEW IF EXISTS [LECTURES];
    CREATE VIEW[LECTURES] AS
    SELECT LectureID, Date, StartTime, EndTime
    FROM (SELECT *
          FROM Lecture JOIN Event
              ON Lecture.LectureID = Event.ForeignID
          )   
    WHERE Type = 'Lecture' AND CourseInstanceID = 2;
          
/* The result table should contain 4 lectures that belongs to the same CourseInstanceID 2 */


/*  6. The student wants to find the exercise groups belonging to the certain course instance
       along with the information on its limitation number and how many students have enrolled for the course

    The query should return: ExerciseGroupID, CurrentlyEnrolledNumber, Limitation

    Here is an example query with the following value
    : CourseInstanceID = 1 */

    SELECT ExerciseGroupID, Limitation, COUNT(StudentID) AS EnrolledNumber
    FROM (SELECT *
          FROM ExerciseGroup LEFT OUTER JOIN ExerciseGroupEnrollment
          ON ExerciseGroup.ExerciseGroupID = ExerciseGroupEnrollment.ExerciseGroupID
          )
    WHERE CourseInstanceID = 1
    GROUP BY ExerciseGroupID;
    
/*  The result table should contain two exercise groups that are belonging to the courseInstanceID 1
    For the simplicity, the result table doesn't include the available number attribute 
    as one can simply calculate it by given information such as 'Limitation - EnrolledNumber' */
    


/*  7. The student wants to find out when and where a certain exercise group meets.

    The query should return: ExerciseGroupID, ReservationID, RoomID, Date, StartTime, EndTime

    Here are two example query with different following values:
    1) ExerciseGroupID = 7 (which has a reservation on the certain room) */
    
    DROP VIEW IF EXISTS [EXERCISE GROUP SCHEDULE];
    CREATE VIEW[EXERCISE GROUP SCHEDULE] AS
    SELECT ForeignID AS ExGroupID, ReservationID, RoomID, Date, StartTime, EndTime
    FROM (SELECT *
          FROM Event
          WHERE Type = 'ExerciseSession') AS NewEvent LEFT JOIN Reservation
       ON NewEvent.ReservationID = Reservation.ReservationID
    WHERE ExGroupID= 7;
    
/*  The result table should contain exerciseGroup 7 with the reservationID 8 on the roomID 6 

    2) ExerciseGroupID = 6 (Which has no reservation yet) */
     
    SELECT ForeignID AS ExGroupID, ReservationID, RoomID, Date, StartTime, EndTime
    FROM (SELECT *
          FROM Event
          WHERE Type = 'ExerciseSession') AS NewEvent LEFT JOIN Reservation
       ON NewEvent.ReservationID = Reservation.ReservationID
    WHERE ExGroupID= 6;
    
/*  The result table should contain exerciseGroup 6. However, its reservationID and RoomID values should be NULL.
    This means the exerciseGroup has a plan (Date, StartTime, EndTime) but hasn't reserved a certain room yet */ 
    


/*  8. The professor wants to find a room which has at least a certain number of seats
       and is free for a reservation on the certain date and during the certain time interval

    The query should return: RoomID, BuildingID, NumberOfSeats 

    Here is an example query with following values
    : NumberOfSeats >= 5, Date = '2020-09-01', StartTime = '10:00:00', Endtime = '13:00:00' */
    
    Select DISTINCT RoomID, BuildingID, NumberOfSeats
    FROM Room, Reservation
    WHERE NumberOfSeats >= 5 AND Room.RoomID NOT IN
        (SELECT RoomID
         FROM Reservation
         WHERE Date = '2020-09-01'
             AND (('10:00:00' > StartTime AND '10:00:00' < EndTime) 
                 OR ('13:00:00' > StartTime AND '13:00:00' < EndTime))
     );

/*  The result table should includes all rooms except for 4 and 6 whose pre-reservation
    overlaps with the chosen time interval (10:00:00 ~ 13:00:00) on the same date (2020-09-01) */
    


/*  9. Find out for what reservations a certain room has and their purpose of use.

    The query should return: ReservationID, Purpose, Date, StartTime, Endtime

    Here is an example with the following value    
    : RoomID = 6 */
    
    DROP VIEW IF EXISTS [RESERVATION AND PURPOSE OF USE];
    CREATE VIEW[RESERVATION AND PURPOSE OF USE] AS
    SELECT Event.ReservationID, Type AS PurposeOfUse, Reservation.Date, StartTime, EndTime
    FROM Reservation LEFT JOIN Event
        ON Reservation.ReservationID = Event.ReservationID
    WHERE Reservation.RoomID = 6;
    
/*  The result table should contain two reservations on RoomID 6 whose purpose of use is
    Lecture and Exercise Session respectively on different date and time interval */



/*  10. Enroll (Register) the certain student for the certain exam.

    The query does not return any table but add the new student to the certain exam.
    The result can be confirmed at the ExamEnrollent table on the left.

    Here is an example query with following values
    : StudentID = 112233, ExamID = 5 */

    INSERT INTO ExamEnrollment(StudentID, ExamID)
    VALUES(112233, 5);
    
/*  The query should add the student with StudentID 112233 to the exam with ExamID 5.



/*  11. Enroll (Register) the certain student for the certain exercise group.

    The query does not return any table but add the new student to the certain exercise group.
    The result can be confirmed at the ExerciseGroupEnrollment table on the left.

    Here is an example query with following values
    : StudentID = 112233, ExerciseGroupID = 5 */

    INSERT INTO ExamEnrollment(StudentID, ExerciseGroupID)
    VALUES(112233, 5);
    
/*  The query should add the student with StudentID 112233 to the exercise group with EexrciseGroupID 5. */



/*  12.The student wants to know which exercise groups with a certain course instance are not full yet.

    The query should return: ExerciseGroupID, EnrolledNumber, Limitaton, AvailableNumber

    Here is an example query with the following value
    : CourseInstanceID = 2 */
    
    SELECT ExerciseGroupID, COUNT(StudentID) AS EnrolledNumber, Limitation, Limitation - COUNT(StudentID) AS AvailableNumber
    FROM ExerciseGroup, ExerciseGroupEnrollment
    WHERE ExerciseGroup.ExerciseGroupID = ExerciseGroupEnrollment.ExerciseGroupID 
        AND CourseInstanceID = 2
    GROUP BY ExerciseGroup.ExerciseGroupID
    HAVING AvailableNumber > 0
    
/*  The result table should contain two exercise groups which belongs to the same CourseInstanceID 2. 
    One has 19 available places (out of 20), and another one has 18 places left (out of 20). */
    


/*  13. List all students who have enrolled for the certain exercise group or exam.

    The query should return: StudentName, StudentID

    Here is an example query with following values
    : ExerciseGroupID = 4, ExamID = 2 */
    
    DROP VIEW IF EXISTS [ENROLLED STUDENTS IN EXERCISE GROUP OR EXAM];
    CREATE VIEW[ENROLLED STUDENTS IN EXERCISE GROUP OR EXAM] AS
    SELECT DISTINCT Name, StudentID
    FROM Student
    WHERE StudentID IN
        (SELECT StudentID
         FROM ExerciseGroupEnrollment 
         WHERE ExerciseGroupID  = 4
         ) 
         OR StudentID IN
             (SELECT StudentID
              FROM ExamEnrollment 
              WHERE ExamID = 2
              );
      
/*  The result table should return 3 students who are enrolled for either ExerciseGroupID 4 or ExamID 2 */ 



/*  14. The professor wants to know the list of students who have enrolled for the certain exam

    The query should return: StudentName, StudentID

    Here is an example query with the following value
    : ExamID = 1 */
    
    SELECT DISTINCT Name, StudentID
    FROM Student	
    WHERE StudentID IN
        (SELECT StudentID
         FROM ExamEnrollment 
         WHERE ExamID = 1
         );
         
/*  The result table should return 5 students who are enrolled for the exam with examID 1 */ 



/*  15. The supervisor of the exam wants to know the name of students who have enrolled for the certain course,
        and which student is taking which exam of the course (One course can have more than one exam) 

    The query should return: ExamID, StudentID, StudentName

    Here is an example query with the following value
    : CourseCode = 'CS-A1111'; */

    SELECT ExamID, StudentID, Name
    FROM (SELECT *
          FROM Exam, ExamEnrollment
          WHERE Exam.ExamID = ExamEnrollment.ExamID) AS ExamCourse JOIN Student 
              ON ExamCourse.StudentID = Student.StudentID
    WHERE CourseCode = 'CS-A1111';
    
/*  The result table should contain 6 students with their StudentID, Name
    and which exam (Differentiated by ExamID) they are enrolled for */



/*  16. Check all exams that are planned to be arrnaged on the certain date.

    The query should return: CourseCode, ExamID, StartTime, EndTime

    Here is an example query with the following value
    : Date = '2020-05-01' */
    
    SELECT CourseCode, ExamID, Date, StartTime, EndTime
    FROM Exam LEFT JOIN (SELECT *
                         FROM Event
                         WHERE Type = 'Exam') AS EventExam
                 ON Exam.ExamID = EventExam.ForeignID
    WHERE date = '2020-05-01';
     
/*  The result table should contain 2 exams that belongs to the different courses,
    with information on their courseCode, examID, Date, StartTime, and Endtime */


/* The End */









    
