-- Problem.1  Identified Issues in the Data
 -- Missing values in the "Email" and "Discount (%)" columns.
 -- Duplicate records (John Doe appears twice).
 -- Inconsistent date formats (MM/DD/YYYY, DD-MM-YYYY,
 -- YYYY/MM/DD).
 -- Phone numbers missing for some customers
 SHOW DATABASES;
 -- Select the Database
 USE victoria_solution_intern;
 --  Check the Available Tables
 SHOW TABLES;
 -- Describe Table Structure
 DESC raw_sales_data;
-- Explore the Data
-- View Sample Data
SELECT * FROM raw_sales_data LIMIT 10;
--  Count Total Rows
-- Check the total number of records:
SELECT COUNT(*) FROM raw_sales_data;
--  Identify Missing Values
-- Find records with missing Email, Phone, or Discount (%):
SELECT * FROM raw_sales_data 
WHERE Email IS NULL OR Email = ''
   OR Phone IS NULL OR Phone = ''
   OR `Discount (%)` IS NULL OR `Discount (%)` = '';
-- Data Cleaning (Solution as per Rubrics)
-- Fill Missing Values
-- Fill Missing Emails with 'not_provided@email.com'
-- Update missing Email values (set to 'Unknown' or NULL as per your choice)
-- Disable safe update mode for this session
SET SQL_SAFE_UPDATES = 0;

-- Now you can run your UPDATE query
-- Check for rows with NULL or empty Email
-- Check for rows with NULL or empty Email
SELECT * 
FROM raw_sales_data 
WHERE Email IS NULL OR Email = '';
-- Check if emails have been updated to 'Unknown'
SELECT * 
FROM raw_sales_data 
WHERE Email = 'Unknown';

-- Step 2: Remove Duplicate Records
-- Delete duplicate records (keeping the first occurrence)
-- Delete duplicate records (keeping the first occurrence)
-- Delete duplicate records (keeping the first occurrence) using a JOIN
-- Disable safe update mode temporarily
SET SQL_SAFE_UPDATES = 0;

-- Now you can run your DELETE query
DELETE rs
FROM raw_sales_data rs
JOIN (
    SELECT MIN(Order_ID) AS MinOrderID, Customer_Name, Email, Phone, Product_Category, Order_Date, Revenue, `Discount (%)`
    FROM raw_sales_data
    GROUP BY Customer_Name, Email, Phone, Product_Category, Order_Date, Revenue, `Discount (%)`
) AS subquery
ON rs.Order_ID != subquery.MinOrderID
AND rs.Customer_Name = subquery.Customer_Name
AND rs.Email = subquery.Email
AND rs.Phone = subquery.Phone
AND rs.Product_Category = subquery.Product_Category
AND rs.Order_Date = subquery.Order_Date
AND rs.Revenue = subquery.Revenue
AND rs.`Discount (%)` = subquery.`Discount (%)`;

-- Re-enable safe update mode (optional, if you want to keep it on)
SET SQL_SAFE_UPDATES = 1;
SET SQL_SAFE_UPDATES = 0;

-- Run the DELETE query to remove duplicates:
DELETE rs
FROM raw_sales_data rs
JOIN (
    SELECT MIN(Order_ID) AS MinOrderID, Customer_Name, Email, Phone, Product_Category, Order_Date, Revenue, `Discount (%)`
    FROM raw_sales_data
    GROUP BY Customer_Name, Email, Phone, Product_Category, Order_Date, Revenue, `Discount (%)`
) AS subquery
ON rs.Order_ID != subquery.MinOrderID
AND rs.Customer_Name = subquery.Customer_Name
AND rs.Email = subquery.Email
AND rs.Phone = subquery.Phone
AND rs.Product_Category = subquery.Product_Category
AND rs.Order_Date = subquery.Order_Date
AND rs.Revenue = subquery.Revenue
AND rs.`Discount (%)` = subquery.`Discount (%)`;

-- No Duplicate Data
SELECT Customer_Name, Email, Phone, Product_Category, Order_Date, Revenue, `Discount (%)`, COUNT(*)
FROM raw_sales_data
GROUP BY Customer_Name, Email, Phone, Product_Category, Order_Date, Revenue, `Discount (%)`
HAVING COUNT(*) > 1;

-- Step 3: Standardize the Date Format
-- Update dates in different formats to YYYY-MM-DD
-- First, handle MM/DD/YYYY and convert to YYYY-MM-DD
-- First, handle MM/DD/YYYY and convert to YYYY-MM-DD
UPDATE raw_sales_data
SET Order_Date = REPLACE(Order_Date, '/', '-')
WHERE Order_Date LIKE '%/%' AND Order_Date NOT LIKE '%-%';
-- Convert MM/DD/YYYY to YYYY-MM-DD format:
UPDATE raw_sales_data
SET Order_Date = STR_TO_DATE(Order_Date, '%m/%d/%Y')
WHERE Order_Date LIKE '%/%' AND Order_Date LIKE '%-%' AND Order_Date NOT LIKE '%-%-%';

-- Convert DD-MM-YYYY to YYYY-MM-DD format:
-- Identify Invalid Date Formats
-- Convert DD-MM-YYYY to YYYY-MM-DD format:
SELECT Order_Date
FROM raw_sales_data
WHERE STR_TO_DATE(Order_Date, '%d-%m-%Y') IS NULL
  AND Order_Date LIKE '%-%';
  
  UPDATE raw_sales_data
SET Order_Date = STR_TO_DATE(Order_Date, '%m-%d-%Y')
WHERE Order_Date LIKE '__-__-____' AND STR_TO_DATE(Order_Date, '%m-%d-%Y') IS NOT NULL;

-- Step 4: Fill Missing Phone Numbers
-- Identify Missing Phone Numbers
SELECT COUNT(*) AS missing_phone_count
FROM raw_sales_data
WHERE Phone IS NULL OR Phone = '';

-- Identify Potential Matches for Missing Phone Numbers
SELECT Customer_Name, Email, Phone
FROM raw_sales_data
WHERE Customer_Name IN (
    SELECT Customer_Name 
    FROM raw_sales_data 
    WHERE Phone IS NULL OR Phone = ''
)
AND Phone IS NOT NULL AND Phone != '';

-- Step 3: Fill Missing Phone Numbers Using Existing Data
UPDATE raw_sales_data rs1  
JOIN raw_sales_data rs2  
ON rs1.Customer_Name = rs2.Customer_Name  
AND rs1.Email = rs2.Email  
AND rs2.Phone IS NOT NULL  
AND rs2.Phone != ''  
SET rs1.Phone = rs2.Phone  
WHERE (rs1.Phone IS NULL OR rs1.Phone = '')  
AND rs1.Order_ID != rs2.Order_ID;  -- Avoids self-join issue

-- Step 4: Verify the Fix
SELECT COUNT(*) AS remaining_missing_phones  
FROM raw_sales_data  
WHERE Phone IS NULL OR Phone = '';  

SELECT rs1.Customer_Name, rs1.Email, rs1.Phone, rs2.Phone AS Matching_Phone  
FROM raw_sales_data rs1  
JOIN raw_sales_data rs2  
ON rs1.Customer_Name = rs2.Customer_Name  
AND rs1.Email = rs2.Email  
AND rs2.Phone IS NOT NULL  
AND rs2.Phone != ''  
WHERE (rs1.Phone IS NULL OR rs1.Phone = '');  

-- Problem 2. How can we summarize sales data to identify trends?
 -- Steps to Follow:
 -- 1. Calculate total revenue per product category to determine the most
 -- profitable segments. 
 -- 2. Find the average discount applied across different customer segments to
 -- analyze discount effectiveness. 
 -- 3. Analyze monthly sales trends to identify peak sales periods.
 
 -- 1. Calculate Total Revenue per Product Category:
 SELECT Product_Category, SUM(Revenue) AS Total_Revenue
FROM raw_sales_data
GROUP BY Product_Category
ORDER BY Total_Revenue DESC;

-- 2. Find the Average Discount Applied Across Different Customer Segments:
SELECT Product_Category, AVG(`Discount (%)`) AS Average_Discount
FROM raw_sales_data
GROUP BY Product_Category
ORDER BY Average_Discount DESC;

-- 3. Analyze Monthly Sales Trends:
SELECT YEAR(Order_Date) AS Year, MONTH(Order_Date) AS Month, SUM(Revenue) AS Monthly_Revenue
FROM raw_sales_data
GROUP BY YEAR(Order_Date), MONTH(Order_Date)
ORDER BY Year, Month;

-- Problem 3. How can we visualize the cleaned and summarized data for better understanding? Steps to Follow: 
-- Use a Heatmap to show revenue performance across different months and product categories. 
-- Create a Scatter Plot to examine the relationship between discount percentage and revenue.
-- Build a Histogram to show the distribution of order sizes












