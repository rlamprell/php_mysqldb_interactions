/* 	This is the file used to build the db stucture for the assignment. It should contain the same queries as the 
	additional dump file, mysql_Dump_Final.sql which was generating using:
		mysqldump -h studdb.csc.liv.ac.uk -u sgrlampr -p sgrlampr --tables --routines --events > mysql_Dump_Final.sql
	on the bash terminal.
*/

USE sgrlampr;

/* Initial Setup */
/* Remove any tables */
DROP TABLE IF EXISTS Enrollments;
DROP TABLE IF EXISTS Tutorials;
DROP TABLE IF EXISTS Students;
DROP TABLE IF EXISTS Labs;
DROP TABLE IF EXISTS Modules;
DROP TABLE IF EXISTS DaysThisWeek;
DROP TEMPORARY TABLE IF EXISTS tmp_taken_seats;

/* Remove any views */
DROP VIEW IF EXISTS vw_Student_Enrollment;

/* Remove any procedures */
DROP PROCEDURE IF EXISTS get_Modules;
DROP PROCEDURE IF EXISTS get_Module_Times;
DROP PROCEDURE IF EXISTS get_Tutorial_Availability;
DROP PROCEDURE IF EXISTS clear_Tables;
DROP PROCEDURE IF EXISTS insert_Baseline_Info;
DROP PROCEDURE IF EXISTS is_Signed_Up_For;
DROP PROCEDURE IF EXISTS reserve_Seat;
DROP PROCEDURE IF EXISTS get_All_Available_Seats;

/* Remove any Events */
DROP EVENT IF EXISTS clear_Database;


/* The names of Labs and the number of Students they can hold */
CREATE TABLE Labs ( 
    labName 	CHAR(20) NOT NULL,
    capacity 	INT 	 NOT NULL,
    
    PRIMARY KEY (labname)
);

/* The Modules available */
CREATE TABLE Modules ( 
    moduleName CHAR(30) NOT NULL,
    
    PRIMARY KEY (modulename)
);

/* The dates for next week's days */
CREATE TABLE DaysThisWeek (
    dayName 	CHAR(10) NOT NULL UNIQUE,
    dayOrder	INT	 	 NOT NULL UNIQUE,
    
    PRIMARY KEY (dayOrder)
);

/* All the available tutorial times, which Modules are taught in which lab(s) at which time */
CREATE TABLE Tutorials (   
	id 			INT  		NOT NULL AUTO_INCREMENT UNIQUE,
    moduleDay 	CHAR(10) 	NOT NULL,  
    moduleTime	TIME		NOT NULL,
    labName 	CHAR(20) 	NOT NULL,  
    moduleName 	CHAR(30) 	NOT NULL,
    
    PRIMARY KEY (id),
    CONSTRAINT fk_labName_Tutorials 	FOREIGN KEY (labName) 		REFERENCES Labs(labName),  
    CONSTRAINT fk_modName_Tutorials 	FOREIGN KEY (moduleName) 	REFERENCES Modules(moduleName),
    CONSTRAINT fk_modDay_Tutorials		FOREIGN KEY (moduleDAY)		REFERENCES DaysThisWeek(dayName)
);

/* Any Students who enroll on any of the Tutorials */
CREATE TABLE Students ( 
	email 		CHAR(100) NOT NULL UNIQUE,
    fullName 	CHAR(50)  NOT NULL,

    PRIMARY KEY (email)
) ;

/* A listing of Students doing which Modules at which time */
CREATE TABLE Enrollments (
    id 			INT 		NOT NULL AUTO_INCREMENT UNIQUE,
    email 		CHAR(100) 	NOT NULL,
    tutorialId 	INT 		NOT NULL,
	
    PRIMARY KEY (id),
    CONSTRAINT fk_tutorialId_enrolls 	FOREIGN KEY (tutorialId) 	REFERENCES Tutorials(id),
    CONSTRAINT fk_email_enrolls 		FOREIGN KEY (email) 		REFERENCES Students(email)
);

/* A more human friendly listing of student enrollment across the Tutorials */
CREATE VIEW vw_Student_Enrollment AS
	SELECT 
		Enrollments.id,
		Students.fullName,
		Students.email,
		labName,
		Tutorials.moduleName,
		moduleDay,
		moduleTime
	FROM Enrollments
		LEFT JOIN Tutorials ON Tutorials.id = Enrollments.tutorialId
		LEFT JOIN Students ON Students.email = Enrollments.email
;


/* 	Use of delimiter for stored procedure creation
	https://stackoverflow.com/questions/2520310/stored-procedure-with-alter-table */
DELIMITER //
/* Remove data in all tables */
CREATE PROCEDURE clear_Tables()

BEGIN
	/* 	Remove the constraints so we can truncate all tables
		These must be dropped in order to truncate the tables with fk references */
	ALTER TABLE Enrollments
		DROP FOREIGN KEY fk_tutorialId_enrolls,
		DROP FOREIGN KEY fk_email_enrolls;
		
	ALTER TABLE Tutorials
		DROP FOREIGN KEY fk_labName_Tutorials,
		DROP FOREIGN KEY fk_modName_Tutorials,
		DROP FOREIGN KEY fk_modDay_Tutorials;

	/* Remove all data from the db */
		TRUNCATE Enrollments;
		TRUNCATE Tutorials;
		TRUNCATE Students;
		TRUNCATE Labs;
		TRUNCATE Modules;
		TRUNCATE DaysThisWeek;

	/* Recreate the foreign key constraints */
	ALTER TABLE Enrollments
		ADD CONSTRAINT fk_tutorialId_enrolls 	FOREIGN KEY (tutorialId) 	REFERENCES Tutorials(id),
		ADD CONSTRAINT fk_email_enrolls 		FOREIGN KEY (email) 		REFERENCES Students(email);
		
	ALTER TABLE Tutorials
		ADD CONSTRAINT fk_labName_Tutorials 	FOREIGN KEY (labName) 		REFERENCES Labs(labName),  
		ADD CONSTRAINT fk_modName_Tutorials 	FOREIGN KEY (moduleName) 	REFERENCES Modules(moduleName),
		ADD CONSTRAINT fk_modDay_Tutorials		FOREIGN KEY (moduleDAY)		REFERENCES DaysThisWeek(dayName);
END //
DELIMITER ;


DELIMITER //
/* Insert all the  baseline info required for the student reservation system to function */
CREATE PROCEDURE insert_Baseline_Info() 
/* Repeating these inserts should make it somewhat flexible if something changes week to week */
BEGIN
	/* all the Modules */
	INSERT INTO Modules VALUES
		('COMP517'),
		('COMP518'),
		('COMP519');
	
    /* All the Labs and capacities */
	INSERT INTO Labs VALUES
		('Lab 1', '2'),
		('Lab 2', '4'),
		('Lab 3', '3');
	
    /* 	Since this is only going to run on fridays it could much simplier.
		However, this gives flexibility to update on any day */
	INSERT INTO DaysThisWeek VALUES
		('SATURDAY', 	1),
		('SUNDAY', 		2),
		('MONDAY', 		3),
		('TUESDAY', 	4),
		('WEDNESDAY',	5),
		('THURSDAY', 	6),
		('FRIDAY', 		7);
	
    /* all the Tutorials - where and when they take place */
	INSERT INTO Tutorials VALUES
		(NULL, 'Thursday',  '11:00:00', 'Lab 2', 'COMP517'),
		(NULL, 'Thursday', 	'16:00:00', 'Lab 2', 'COMP517'),
		(NULL, 'Thursday', 	'11:00:00', 'Lab 3', 'COMP518'),
		(NULL, 'Friday', 	'11:00:00', 'Lab 3', 'COMP518'),
		(NULL, 'Tuesday', 	'09:00:00', 'Lab 1', 'COMP519'),
		(NULL, 'Thursday', 	'13:00:00', 'Lab 1', 'COMP519');
END //
DELIMITER ;


DELIMITER //
/* get all available seats */
CREATE PROCEDURE get_All_Available_Seats()
BEGIN
	/* tmp table to avoid subquery 'messyness' */
	CREATE TEMPORARY TABLE tmp_taken_seats
	SELECT 
		tutorialId,
		COUNT(id) as taken_seats
	FROM 	 Enrollments
	GROUP BY tutorialId;

	/* Get the total number of places available across all Tutorials */
	SELECT 
		sum(capacity) - IFNULL(sum(taken_seats), 0) as Available
	FROM Tutorials
		INNER JOIN 	Labs 					on Labs.labName 	= Tutorials.labName
		LEFT JOIN 	tmp_taken_seats seats 	on seats.tutorialid = Tutorials.id;
        
	/* clean up the temp table */
    DROP TEMPORARY TABLE IF EXISTS tmp_taken_seats;
END //
DELIMITER ;



DELIMITER //
/* Get a listing of all the available Modules */
CREATE PROCEDURE get_Modules()
BEGIN
	/* tmp table to avoid subquery 'messyness' */
	CREATE TEMPORARY TABLE tmp_taken_seats
	SELECT 
		tutorialId,
		COUNT(id) as taken_seats
	FROM 	 Enrollments
	GROUP BY tutorialId;

	/* Get all the module Names which have not reached capacity */
	SELECT 
		moduleName,
		sum(capacity) as cap,
		sum(taken_seats) as taken,
		sum(capacity) - IFNULL(sum(taken_seats), 0) as Available
	FROM 		Tutorials
		INNER JOIN 	Labs 					on Labs.labName 	= Tutorials.labName
		LEFT JOIN 	tmp_taken_seats seats 	on seats.tutorialid = Tutorials.id
	GROUP BY 	
		moduleName
	HAVING 		
		sum(capacity) - IFNULL(sum(taken_seats), 0) >= 1;
	
    /* clean up the temp table */
    DROP TEMPORARY TABLE IF EXISTS tmp_taken_seats;
END //
DELIMITER ;


DELIMITER //
/* Get a listing of all the times associated with the Modules */
CREATE PROCEDURE get_Module_Times(

	IN moduleInput CHAR(10)
)
BEGIN
	/* tmp table to avoid subquery 'messyness' */
	CREATE TEMPORARY TABLE tmp_taken_seats
	SELECT 
		tutorialId,
		COUNT(id) as taken_seats
	FROM 	 Enrollments
	GROUP BY tutorialId;
    
    /* Get only the times which still still have free spaces */
	SELECT
		id,
		sum(capacity) - IFNULL(sum(taken_seats), 0),
		CONCAT(moduleDay, ', ', Moduletime) AS Availability
	FROM 		Tutorials
		INNER JOIN 	DaysThisWeek days 		ON days.dayName 	= Tutorials.moduleDay
		INNER JOIN 	Labs 					ON Labs.labName 	= Tutorials.labName
		LEFT JOIN 	tmp_taken_seats seats 	ON seats.tutorialid = Tutorials.id
	WHERE 		
		moduleName = moduleInput
	GROUP BY	
		id
	HAVING 		
		sum(capacity) - IFNULL(sum(taken_seats), 0) >= 1
	ORDER BY
		days.dayOrder;
        
    /* clean up the temp table */
    DROP TEMPORARY TABLE IF EXISTS tmp_taken_seats;
END //
DELIMITER ;


DELIMITER //
/* Check which Tutorials still have capacity available */
CREATE PROCEDURE get_Tutorial_Availability(

    IN tutId   INT
)
BEGIN
    /* tmp table to avoid subquery 'messyness' */
    CREATE TEMPORARY TABLE tmp_taken_seats
    SELECT 
		tutorialId,
		COUNT(id) as taken_seats
    FROM 	 Enrollments
    WHERE 	 tutorialId = tutId
    GROUP BY tutorialId;
    
	/* main - get the number of free seats */
	SELECT
        Tutorials.id,
		Labs.capacity,
        taken_seats,
		Labs.capacity - IFNULL(taken_seats, 0) freeSeats
	FROM Tutorials
		LEFT JOIN Labs 				ON Tutorials.labname 	= Labs.labname
		LEFT JOIN Enrollments 		ON Tutorials.id 		= Enrollments.tutorialId
        LEFT JOIN tmp_taken_seats	ON Tutorials.id			= tmp_taken_seats.tutorialId
	WHERE 
        Tutorials.id = tutId
	GROUP BY
		Tutorials.id,
		Labs.capacity,
        taken_seats;
    
	/* clean up the temp table */
    DROP TEMPORARY TABLE IF EXISTS tmp_taken_seats;
END //
DELIMITER ;


DELIMITER //
/* Check if this user is already signed up to this tutorial */
CREATE PROCEDURE is_Signed_Up_For(

	IN tutId		INT,
	IN studentEmail CHAR(100)
)
BEGIN
	SELECT
        Tutorials.id,
		email
	FROM Tutorials
	LEFT JOIN Enrollments ON Tutorials.id = Enrollments.tutorialId
    WHERE 	
		email 			= studentEmail AND 
		Tutorials.id 	= tutId
	LIMIT 1;
END //
DELIMITER ;

    
DELIMITER //
/* Reserve a seat for the student */
CREATE PROCEDURE reserve_Seat(
	
    IN tutId 		INT,
    IN studentEmail CHAR(100),
    IN studentName	CHAR(50)
)
BEGIN
	
    START TRANSACTION;
    
    /* create an entry for the student */
    /* IGNORE will move passed the error in case a student email (primary key) already exists
		taken from: https://stackoverflow.com/questions/6353098/
        how-to-check-to-see-if-a-key-exists-before-trying-to-insert-it-into-a-database/6353228 */
    INSERT IGNORE INTO Students VALUES
		(studentEmail, studentName);
    
    /* reserve a seat for the student */
	INSERT INTO Enrollments VALUES
		(NULL, studentEmail, tutId);
        
	COMMIT;
    
END //
DELIMITER ;


/* Remove all data from the tables */
CALL clear_Tables();
/* Insert base info - Modules, Labs and availability */
CALL insert_Baseline_Info();