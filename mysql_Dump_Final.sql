-- MySQL dump 10.14  Distrib 5.5.68-MariaDB, for Linux (x86_64)
--
-- Host: studdb.csc.liv.ac.uk    Database: sgrlampr
-- ------------------------------------------------------
-- Server version	8.0.13

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `DaysThisWeek`
--

DROP TABLE IF EXISTS `DaysThisWeek`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `DaysThisWeek` (
  `dayName` char(10) NOT NULL,
  `dayOrder` int(11) NOT NULL,
  PRIMARY KEY (`dayOrder`),
  UNIQUE KEY `dayName` (`dayName`),
  UNIQUE KEY `dayOrder` (`dayOrder`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `DaysThisWeek`
--

LOCK TABLES `DaysThisWeek` WRITE;
/*!40000 ALTER TABLE `DaysThisWeek` DISABLE KEYS */;
INSERT INTO `DaysThisWeek` VALUES ('FRIDAY',7),('MONDAY',3),('SATURDAY',1),('SUNDAY',2),('THURSDAY',6),('TUESDAY',4),('WEDNESDAY',5);
/*!40000 ALTER TABLE `DaysThisWeek` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Enrollments`
--

DROP TABLE IF EXISTS `Enrollments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Enrollments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `email` char(100) NOT NULL,
  `tutorialId` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id` (`id`),
  KEY `fk_tutorialId_enrolls` (`tutorialId`),
  KEY `fk_email_enrolls` (`email`),
  CONSTRAINT `fk_email_enrolls` FOREIGN KEY (`email`) REFERENCES `Students` (`email`),
  CONSTRAINT `fk_tutorialId_enrolls` FOREIGN KEY (`tutorialId`) REFERENCES `Tutorials` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Enrollments`
--

LOCK TABLES `Enrollments` WRITE;
/*!40000 ALTER TABLE `Enrollments` DISABLE KEYS */;
/*!40000 ALTER TABLE `Enrollments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Labs`
--

DROP TABLE IF EXISTS `Labs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Labs` (
  `labName` char(20) NOT NULL,
  `capacity` int(11) NOT NULL,
  PRIMARY KEY (`labName`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Labs`
--

LOCK TABLES `Labs` WRITE;
/*!40000 ALTER TABLE `Labs` DISABLE KEYS */;
INSERT INTO `Labs` VALUES ('Lab 1',2),('Lab 2',4),('Lab 3',3);
/*!40000 ALTER TABLE `Labs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Modules`
--

DROP TABLE IF EXISTS `Modules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Modules` (
  `moduleName` char(30) NOT NULL,
  PRIMARY KEY (`moduleName`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Modules`
--

LOCK TABLES `Modules` WRITE;
/*!40000 ALTER TABLE `Modules` DISABLE KEYS */;
INSERT INTO `Modules` VALUES ('COMP517'),('COMP518'),('COMP519');
/*!40000 ALTER TABLE `Modules` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Students`
--

DROP TABLE IF EXISTS `Students`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Students` (
  `email` char(100) NOT NULL,
  `fullName` char(50) NOT NULL,
  PRIMARY KEY (`email`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Students`
--

LOCK TABLES `Students` WRITE;
/*!40000 ALTER TABLE `Students` DISABLE KEYS */;
/*!40000 ALTER TABLE `Students` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Tutorials`
--

DROP TABLE IF EXISTS `Tutorials`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Tutorials` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `moduleDay` char(10) NOT NULL,
  `moduleTime` time NOT NULL,
  `labName` char(20) NOT NULL,
  `moduleName` char(30) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id` (`id`),
  KEY `fk_labName_Tutorials` (`labName`),
  KEY `fk_modName_Tutorials` (`moduleName`),
  KEY `fk_modDay_Tutorials` (`moduleDay`),
  CONSTRAINT `fk_labName_Tutorials` FOREIGN KEY (`labName`) REFERENCES `Labs` (`labname`),
  CONSTRAINT `fk_modDay_Tutorials` FOREIGN KEY (`moduleDay`) REFERENCES `DaysThisWeek` (`dayname`),
  CONSTRAINT `fk_modName_Tutorials` FOREIGN KEY (`moduleName`) REFERENCES `Modules` (`modulename`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Tutorials`
--

LOCK TABLES `Tutorials` WRITE;
/*!40000 ALTER TABLE `Tutorials` DISABLE KEYS */;
INSERT INTO `Tutorials` VALUES (1,'Thursday','11:00:00','Lab 2','COMP517'),(2,'Thursday','16:00:00','Lab 2','COMP517'),(3,'Thursday','11:00:00','Lab 3','COMP518'),(4,'Friday','11:00:00','Lab 3','COMP518'),(5,'Tuesday','09:00:00','Lab 1','COMP519'),(6,'Thursday','13:00:00','Lab 1','COMP519');
/*!40000 ALTER TABLE `Tutorials` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary table structure for view `vw_Student_Enrollment`
--

DROP TABLE IF EXISTS `vw_Student_Enrollment`;
/*!50001 DROP VIEW IF EXISTS `vw_Student_Enrollment`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `vw_Student_Enrollment` (
  `id` tinyint NOT NULL,
  `fullName` tinyint NOT NULL,
  `email` tinyint NOT NULL,
  `labName` tinyint NOT NULL,
  `moduleName` tinyint NOT NULL,
  `moduleDay` tinyint NOT NULL,
  `moduleTime` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Dumping events for database 'sgrlampr'
--

--
-- Dumping routines for database 'sgrlampr'
--
/*!50003 DROP PROCEDURE IF EXISTS `clear_Tables` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`sgrlampr`@`%` PROCEDURE `clear_Tables`()
BEGIN
	
	ALTER TABLE Enrollments
		DROP FOREIGN KEY fk_tutorialId_enrolls,
		DROP FOREIGN KEY fk_email_enrolls;
		
	ALTER TABLE Tutorials
		DROP FOREIGN KEY fk_labName_Tutorials,
		DROP FOREIGN KEY fk_modName_Tutorials,
		DROP FOREIGN KEY fk_modDay_Tutorials;

	
		TRUNCATE Enrollments;
		TRUNCATE Tutorials;
		TRUNCATE Students;
		TRUNCATE Labs;
		TRUNCATE Modules;
		TRUNCATE DaysThisWeek;

	
	ALTER TABLE Enrollments
		ADD CONSTRAINT fk_tutorialId_enrolls 	FOREIGN KEY (tutorialId) 	REFERENCES Tutorials(id),
		ADD CONSTRAINT fk_email_enrolls 		FOREIGN KEY (email) 		REFERENCES Students(email);
		
	ALTER TABLE Tutorials
		ADD CONSTRAINT fk_labName_Tutorials 	FOREIGN KEY (labName) 		REFERENCES Labs(labName),  
		ADD CONSTRAINT fk_modName_Tutorials 	FOREIGN KEY (moduleName) 	REFERENCES Modules(moduleName),
		ADD CONSTRAINT fk_modDay_Tutorials		FOREIGN KEY (moduleDAY)		REFERENCES DaysThisWeek(dayName);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_All_Available_Seats` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`sgrlampr`@`%` PROCEDURE `get_All_Available_Seats`()
BEGIN
	
	CREATE TEMPORARY TABLE tmp_taken_seats
	SELECT 
		tutorialId,
		COUNT(id) as taken_seats
	FROM 	 Enrollments
	GROUP BY tutorialId;

	
	SELECT 
		sum(capacity) - IFNULL(sum(taken_seats), 0) as Available
	FROM Tutorials
		INNER JOIN 	Labs 					on Labs.labName 	= Tutorials.labName
		LEFT JOIN 	tmp_taken_seats seats 	on seats.tutorialid = Tutorials.id;
        
	
    DROP TEMPORARY TABLE IF EXISTS tmp_taken_seats;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_Modules` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`sgrlampr`@`%` PROCEDURE `get_Modules`()
BEGIN
	
	CREATE TEMPORARY TABLE tmp_taken_seats
	SELECT 
		tutorialId,
		COUNT(id) as taken_seats
	FROM 	 Enrollments
	GROUP BY tutorialId;

	
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
	
    
    DROP TEMPORARY TABLE IF EXISTS tmp_taken_seats;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_Module_Times` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`sgrlampr`@`%` PROCEDURE `get_Module_Times`(

	IN moduleInput CHAR(10)
)
BEGIN
	
	CREATE TEMPORARY TABLE tmp_taken_seats
	SELECT 
		tutorialId,
		COUNT(id) as taken_seats
	FROM 	 Enrollments
	GROUP BY tutorialId;
    
    
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
        
    
    DROP TEMPORARY TABLE IF EXISTS tmp_taken_seats;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_Tutorial_Availability` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`sgrlampr`@`%` PROCEDURE `get_Tutorial_Availability`(

    IN tutId   INT
)
BEGIN
    
    CREATE TEMPORARY TABLE tmp_taken_seats
    SELECT 
		tutorialId,
		COUNT(id) as taken_seats
    FROM 	 Enrollments
    WHERE 	 tutorialId = tutId
    GROUP BY tutorialId;
    
	
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
    
	
    DROP TEMPORARY TABLE IF EXISTS tmp_taken_seats;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `insert_Baseline_Info` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`sgrlampr`@`%` PROCEDURE `insert_Baseline_Info`()
BEGIN
	
	INSERT INTO Modules VALUES
		('COMP517'),
		('COMP518'),
		('COMP519');
	
    
	INSERT INTO Labs VALUES
		('Lab 1', '2'),
		('Lab 2', '4'),
		('Lab 3', '3');
	
    
	INSERT INTO DaysThisWeek VALUES
		('SATURDAY', 	1),
		('SUNDAY', 		2),
		('MONDAY', 		3),
		('TUESDAY', 	4),
		('WEDNESDAY',	5),
		('THURSDAY', 	6),
		('FRIDAY', 		7);
	
    
	INSERT INTO Tutorials VALUES
		(NULL, 'Thursday',  '11:00:00', 'Lab 2', 'COMP517'),
		(NULL, 'Thursday', 	'16:00:00', 'Lab 2', 'COMP517'),
		(NULL, 'Thursday', 	'11:00:00', 'Lab 3', 'COMP518'),
		(NULL, 'Friday', 	'11:00:00', 'Lab 3', 'COMP518'),
		(NULL, 'Tuesday', 	'09:00:00', 'Lab 1', 'COMP519'),
		(NULL, 'Thursday', 	'13:00:00', 'Lab 1', 'COMP519');
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `is_Signed_Up_For` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`sgrlampr`@`%` PROCEDURE `is_Signed_Up_For`(

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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `reserve_Seat` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`sgrlampr`@`%` PROCEDURE `reserve_Seat`(
	
    IN tutId 		INT,
    IN studentEmail CHAR(100),
    IN studentName	CHAR(50)
)
BEGIN
	
    START TRANSACTION;
    
    
    
    INSERT IGNORE INTO Students VALUES
		(studentEmail, studentName);
    
    
	INSERT INTO Enrollments VALUES
		(NULL, studentEmail, tutId);
        
	COMMIT;
    
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Final view structure for view `vw_Student_Enrollment`
--

/*!50001 DROP TABLE IF EXISTS `vw_Student_Enrollment`*/;
/*!50001 DROP VIEW IF EXISTS `vw_Student_Enrollment`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`sgrlampr`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_Student_Enrollment` AS select `Enrollments`.`id` AS `id`,`Students`.`fullName` AS `fullName`,`Students`.`email` AS `email`,`Tutorials`.`labName` AS `labName`,`Tutorials`.`moduleName` AS `moduleName`,`Tutorials`.`moduleDay` AS `moduleDay`,`Tutorials`.`moduleTime` AS `moduleTime` from ((`Enrollments` left join `Tutorials` on((`Tutorials`.`id` = `Enrollments`.`tutorialId`))) left join `Students` on((`Students`.`email` = `Enrollments`.`email`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2020-12-17 12:04:05
