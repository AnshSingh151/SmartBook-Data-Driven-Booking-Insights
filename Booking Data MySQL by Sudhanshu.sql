## Creating the assessment database.
CREATE DATABASE booking

USE booking

## Creating the booking_data schema with all required columns.
CREATE TABLE booking_data(
Booking_ID VARCHAR(100) PRIMARY KEY,
Customer_ID	VARCHAR(100),
Customer_Name VARCHAR(50),
Booking_Type TEXT,
Booking_Date VARCHAR(100),
Status TEXT,
Class_Type TEXT,
Instructor TEXT,
Time_Slot TIME,
Duration_in_mins INT,
Price FLOAT,
Facility TEXT,
Theme TEXT,
Subscription_Type TEXT,
Service_Name TEXT,
Service_Type TEXT,
Customer_Email VARCHAR(100),
Customer_Phone VARCHAR(50)
);

## Loading CSV Data into MySQL using LOAD DATA INFILE and handling missing values in 'Duration_In_Mins' column.
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Assessment_Data.csv'
INTO TABLE booking_data
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(Booking_ID, Customer_ID, Customer_Name, Booking_Type, Booking_Date, Status, Class_Type, Instructor, Time_Slot, @Duration_In_Mins, Price, Facility, Theme, Subscription_Type, Service_Name, Service_Type, Customer_Email, Customer_Phone)
SET Duration_In_Mins = IFNULL(NULLIF(@Duration_In_Mins,''),'0');

## Adding a new column 'Date_Of_Booking' to populate data from 'booking_date' in proper date format cause it was causing errors.
ALTER TABLE booking_data ADD Date_Of_Booking DATE;

## Converting Booking_Date column to a proper DATE format (Date_Of_Booking).
UPDATE booking_data 
SET Date_Of_Booking = STR_TO_DATE(booking_date, '%m/%d/%Y');

## Deleting the original Booking_date column after retrieving it's data.
ALTER TABLE booking_data DROP COLUMN booking_date;

## Deleting 'Subscription_Type' column as it contains no values.
ALTER TABLE booking_data DROP COLUMN Subscription_Type;

## Inspecting duplicate Booking_ID entries.
SELECT Booking_ID, COUNT(*)
FROM booking_data
GROUP BY Booking_ID
HAVING COUNT(*) > 1;

## Replacing missing values in Class Type, Instructor, Facility, Theme columns.
UPDATE booking_data SET Class_Type = 'Not Specified' WHERE Class_Type IS NULL OR Class_Type = '';
UPDATE booking_data SET Instructor = 'Not Assigned' WHERE Instructor IS NULL OR Instructor = '';
UPDATE booking_data SET Facility = 'Unknown' WHERE Facility IS NULL OR Facility = '';
UPDATE booking_data SET Theme = 'None' WHERE Theme IS NULL OR Theme = '';

## Finding the average duration of each services.
SELECT Service_Type, AVG(Duration_in_mins) AS avg_duration
FROM booking_data
GROUP BY Service_Type;

## Finding Total YoY Revenue
SELECT year(Date_Of_Booking) as Booking_Year,Round(SUM(Price),2) AS Total_Revenue
FROM booking_data
GROUP BY year(Date_Of_Booking);

## Total Booking types
SELECT Booking_Type,COUNT(Booking_Type) as Count
FROM booking_data
GROUP BY Booking_Type;

## Finding the top 5 most booked services and their total revenue.
SELECT Service_Type, COUNT(*) AS Total_Bookings, SUM(Price) AS Total_Revenue
FROM booking_data
GROUP BY Service_Type
ORDER BY Total_Bookings DESC
LIMIT 5;

##  Analysing booking trends per month and identifing high-revenue months.
SELECT MONTH(Date_Of_Booking) AS Booking_Month,
COUNT(*) AS Total_Bookings,
SUM(Price) AS Total_Revenue
FROM booking_data
GROUP BY Booking_Month
ORDER BY Total_Revenue DESC;

## Finding the top 10 highest-paying customers.
SELECT Customer_ID, Customer_Name, COUNT(*) AS Total_Bookings, SUM(Price) AS Total_Spent
FROM booking_data
WHERE Customer_ID IS NOT NULL
GROUP BY Customer_ID, Customer_Name
ORDER BY Total_Spent DESC
LIMIT 10;

## Comparing Pending vs. Confirmed bookings to track service reliability.
SELECT Service_Type, 
       COUNT(CASE WHEN Status = 'Pending' THEN 1 END) AS Pending_Bookings,
       COUNT(CASE WHEN Status = 'Confirmed' THEN 1 END) AS Confirmed_Bookings,
       COUNT(*) AS Total_Bookings
FROM booking_data
GROUP BY Service_Type
ORDER BY Confirmed_Bookings DESC;

## Finding the popular time slots.
SELECT Time_Slot, COUNT(*) AS Total_Bookings
FROM booking_data
GROUP BY Time_Slot
ORDER BY Total_Bookings DESC;

##  Finding the most used facilities and their percentage share of total bookings.
SELECT Facility, COUNT(*) AS Total_Bookings, 
       CONCAT(ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM booking_data), 2),'%') AS Booking_Percentage
FROM booking_data
GROUP BY Facility
ORDER BY Total_Bookings DESC;

## Retrieving all data to use export results option from query to export data into csv file.
SELECT * FROM booking_data;