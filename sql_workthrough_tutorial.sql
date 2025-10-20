-- Initialize the database to be used
DROP DATABASE IF EXISTS `Parks_and_Recreation_new`;
CREATE DATABASE `Parks_and_Recreation_new`;
USE `Parks_and_Recreation_new`;

-- ==============================================================

-- Create Tables and Populate Them (Note the order)

CREATE TABLE employee_demographics (
  employee_id INT AUTO_INCREMENT NOT NULL,
  first_name VARCHAR(50),
  last_name VARCHAR(50),
  age INT,
  gender VARCHAR(10),
  birth_date DATE,
  PRIMARY KEY (employee_id)
);

INSERT INTO employee_demographics (first_name, last_name, age, gender, birth_date)
VALUES
('Leslie', 'Knope', 46, 'Female','1979-09-25'),
('Ron', 'Swanson', 48, 'Male','1977-05-05'),
('Tom', 'Haverford', 38, 'Male', '1987-03-04'),
('April', 'Ludgate', 31, 'Female', '1994-03-27'),
('Jerry', 'Gergich', 63, 'Male', '1962-08-28'),
('Donna', 'Meagle', 48, 'Female', '1977-07-30'),
('Ann', 'Perkins', 37, 'Female', '1988-12-01'),
('Chris', 'Traeger', 45, 'Male', '1980-11-11'),
('Ben', 'Wyatt', 40, 'Male', '1985-07-26'),
('Andy', 'Dwyer', 36, 'Male', '1989-03-25'),
('Mark', 'Brendanawicz', 42, 'Male', '1983-06-14'),
('Craig', 'Middlebrooks', 39, 'Male', '1986-07-27');

-- SELECT *
-- FROM employee_demographics;


CREATE TABLE parks_departments (
  department_id INT AUTO_INCREMENT PRIMARY KEY,
  department_name varchar(50) NOT NULL
);

INSERT INTO parks_departments (department_name)
VALUES
('Parks and Recreation'),
('Animal Control'),
('Public Works'),
('Healthcare'),
('Library'),
('Finance');

-- SELECT *
-- FROM parks_departments;


CREATE TABLE employee_salary (
  employee_id INT NOT NULL,
  occupation VARCHAR(50),
  salary INT,
  dept_id INT,
  FOREIGN KEY (employee_id) REFERENCES employee_demographics (employee_id),
  FOREIGN KEY (dept_id) REFERENCES parks_departments (department_id)
);

INSERT INTO employee_salary (employee_id, occupation, salary, dept_id)
VALUES
(1, 'Deputy Director of Parks and Recreation', 75000,1),
(2, 'Director of Parks and Recreation', 70000,1),
(3, 'Entrepreneur', 50000,1),
(4, 'Assistant to the Director of Parks and Recreation', 25000,1),
(5, 'Office Manager', 50000,1),
(6, 'Office Manager', 60000,1),
(7, 'Nurse', 55000,4),
(8, 'City Manager', 90000,3),
(9, 'State Auditor', 70000,6),
(10, 'Shoe Shiner and Musician', 20000, NULL),
(11, 'City Planner', 57000, 3),
(12, 'Parks Director', 65000,1);

-- SELECT *
-- FROM employee_salary;

-- ==============================================================

-- Views

-- Views are query results that are saved for easy usage
-- Views allow you to save a query result you would like to use frequently as if it
-- is a table in the database though it does not take additional storage space

SELECT *
FROM employee_demographics;

SELECT *
FROM employee_salary;

SELECT *
FROM parks_departments;

DROP VIEW IF EXISTS employee_full_data;
CREATE VIEW employee_full_data AS
SELECT ed.first_name, ed.last_name, ed.age, ed.gender, ed.birth_date, es.occupation, es.salary, pd.department_name
FROM employee_demographics ed
JOIN employee_salary es
	ON ed.employee_id = es.employee_id
JOIN parks_departments pd
	ON es.dept_id = pd.department_id
ORDER BY ed.first_name, ed.last_name;
    
-- SELECT *
-- FROM employee_full_data;

DROP VIEW IF EXISTS dept_avg_salary;
CREATE VIEW dept_avg_salary AS
SELECT pd.department_name, ROUND(AVG(es.salary), 2) AS avg_salary
FROM employee_salary es
JOIN parks_departments pd
	ON es.dept_id = pd.department_id
GROUP BY pd.department_name
ORDER BY AVG(es.salary) DESC;

-- SELECT *
-- FROM dept_avg_salary;

-- Practice Exercise

-- Try creating a view which shows the number of people
-- in each type of occupation

-- ==============================================================

-- File Export

-- Tables can be exported using the GUI or using query
-- The GUI method would be explained in the video while 
-- the queries below explains using query to export tables

-- MySQL only allows you to export or import files from a
-- folder when using the query method

-- To view the folder run the query below
SHOW VARIABLES LIKE "secure_file_priv";

-- The query below shows how to save full employee data in a
-- CSV file called employee_info
-- (remember to change the backward slash to a forward slash)

SELECT *
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/employee_info.csv'
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
FROM employee_full_data;

-- Try opening the file in the folder below to ensure it works
-- correctly

-- ==============================================================

-- Exploratory Data Analysis (EDA)

-- EDA are the analysis done when working with new databases or
-- tables in order to study and understand the database or tables
-- This will aid us in making informed decision while doing
-- further analysis on the databse or table

-- Some of the most important steps in EDA are explained below

-- Show the tables in the database (note that views are also included)
SHOW TABLES;

-- View the first few records in a table
SELECT *
FROM employee_demographics
LIMIT 5;

-- Check the column names and datatypes in the navigation pane

-- Get rows with missing values in a field (column)
SELECT *
FROM employee_salary
WHERE dept_id IS NULL;

-- Count number of missing values in a field
SELECT COUNT(*) AS num_miss_dept
FROM employee_salary
WHERE dept_id IS NULL;

-- Do Summary statistics for each column
-- Get the min, 25th percentile, median, mode,
-- 75th percentile, max etc for numeric columns
-- Get the unique values and the count of each
-- value for categorical columns

-- An example of showing unique values in a column
SELECT DISTINCT occupation
FROM employee_salary;

-- Let's view the distinctive years in the date of
-- birth
SELECT DISTINCT YEAR(birth_date) As Years
FROM employee_demographics
ORDER BY YEAR(birth_date);

-- ==============================================================

-- Events

-- Events are used to run a set of queries at a specified interval

-- Before we go further with events there are some changes we need
-- make to our database. These are:

-- We will add 2 columns 'retirement_time' and 'employment_status' to
-- the employee_demographics table

-- Retirement time is the time an employee is expected to retire while
-- employment_status will be 'Active' for those not yet retired and
-- 'To be retired' for those whose retirement time has passed

-- We will create a new table 'to_be_retired' which will contain details
-- of all employees whose retirement time has passed

SELECT *
FROM employee_demographics;

ALTER TABLE employee_demographics
ADD COLUMN retirement_time DATETIME DEFAULT (NOW() + INTERVAL 5 MINUTE);

ALTER TABLE employee_demographics
ADD COLUMN employment_status VARCHAR(20) DEFAULT 'Active';

SELECT *
FROM employee_demographics;

DROP TABLE IF EXISTS to_be_retired;
CREATE TABLE to_be_retired (
	retirement_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT NOT NULL,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    age INT,
    gender VARCHAR(20),
    birth_date DATE,
    retirement_time DATETIME
);

SELECT *
FROM to_be_retired;

-- NOTE: When creating an event, it is essential to test your query and
-- ensure that no error occurs because when error occurs from the
-- operation of an event no error will be raised, the query will just
-- not work

-- Now we want to check every 30 seconds and ensure that for anyone whose
-- retirement time has passed, the employment status in the
-- employee_demographics table should change to 'To be retired' for
-- such persons

-- Now, we test the queries first ensuring no error occurs before we proceed
-- with creating the event

-- INSERT INTO to_be_retired(employee_id, first_name, last_name, age, gender, birth_date, retirement_time)
-- SELECT employee_id, first_name, last_name, age, gender, birth_date, retirement_time
-- FROM employee_demographics
-- WHERE retirement_time <= NOW()
-- 	AND employee_id NOT IN (SELECT employee_id FROM to_be_retired);

-- UPDATE employee_demographics
-- SET employment_status = 'To be retired'
-- WHERE retirement_time <= NOW()
-- 	AND employment_status != 'To be retired';
    
-- The second query above raises an error because MySQL by default does not allow
-- modifications to tables in databases
-- The query would be modified as below to allow us modify our table

INSERT INTO to_be_retired(employee_id, first_name, last_name, age, gender, birth_date, retirement_time)
SELECT employee_id, first_name, last_name, age, gender, birth_date, retirement_time
FROM employee_demographics
WHERE retirement_time <= NOW()
	AND employee_id NOT IN (SELECT employee_id FROM to_be_retired);

SET SQL_SAFE_UPDATES = 0;
UPDATE employee_demographics
SET employment_status = 'To be retired'
WHERE retirement_time <= NOW()
	AND employment_status != 'To be retired';
SET SQL_SAFE_UPDATES = 1;

SELECT *
FROM employee_demographics;

SELECT *
FROM to_be_retired;

-- Now, one more thing before we create our event - we need to enable
-- the event scheduler

SHOW VARIABLES LIKE 'Event%';

SET GLOBAL event_scheduler = ON;

SHOW VARIABLES LIKE 'Event%';

-- Finally, we create our event

DROP EVENT IF EXISTS check_to_be_retired;

DELIMITER $$
CREATE EVENT check_to_be_retired
ON SCHEDULE EVERY 30 SECOND
DO BEGIN
	INSERT INTO to_be_retired(employee_id, first_name, last_name, age, gender, birth_date, retirement_time)
	SELECT employee_id, first_name, last_name, age, gender, birth_date, retirement_time
	FROM employee_demographics
	WHERE retirement_time <= NOW()
		AND employee_id NOT IN (SELECT employee_id FROM to_be_retired);

	SET SQL_SAFE_UPDATES = 0;
	UPDATE employee_demographics
	SET employment_status = 'To be retired'
	WHERE retirement_time <= NOW()
		AND employment_status != 'To be retired';
	SET SQL_SAFE_UPDATES = 1;
END $$

DELIMITER ;

SHOW EVENTS;

SELECT *
FROM employee_demographics;

SELECT *
FROM to_be_retired;

INSERT INTO employee_demographics (first_name, last_name, age, gender, birth_date, retirement_time)
VALUES
('Chigozie', 'Dantata', 36, 'Male', '1989-03-24', '2025-09-30 14:06:00'),
('Halimah', 'Balogun', 38, 'Female', '1987-06-17', NOW() + INTERVAL 3 MINUTE),
('Damilare', 'Okoro', 40, 'Male', '1985-01-31', '2025-09-30 14:07:00');

SHOW EVENTS;

-- ==============================================================
-- THANK YOU FOR FOLLOWING MY WALKTHROUGH 


