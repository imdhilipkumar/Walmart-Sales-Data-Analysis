-- Step 1: Create Database (if not exists)
IF NOT EXISTS (
    SELECT name 
    FROM sys.databases 
    WHERE name = N'Walmart'
)
BEGIN
    CREATE DATABASE Walmart;
END
GO

-- Step 2: Use the Database
USE Walmart;
GO

-- Step 3: Create Table (if not exists)
IF NOT EXISTS (
    SELECT * 
    FROM sysobjects 
    WHERE name='sales' AND xtype='U'
)
BEGIN
    CREATE TABLE sales (
        invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
        branch VARCHAR(5) NOT NULL,
        city VARCHAR(30) NOT NULL,
        customer_type VARCHAR(30) NOT NULL,
        gender VARCHAR(10) NOT NULL,
        product_line VARCHAR(100) NOT NULL,
        unit_price DECIMAL(10,2) NOT NULL,
        quantity INT NOT NULL,
        VAT FLOAT NOT NULL,  -- SQL Server doesn't support (6,4) precision for FLOAT
        total DECIMAL(12,4) NOT NULL,
        [date] DATETIME NOT NULL,  -- 'date' is a reserved keyword; use [date]
        [time] TIME NOT NULL,
        payment_method VARCHAR(15) NOT NULL,
        cogs DECIMAL(10,2) NOT NULL,
        gross_margin_pct FLOAT,
        gross_income DECIMAL(12,4) NOT NULL,
        rating FLOAT
    );
END
GO


SELECT TOP 10 * FROM [Walmart].[dbo].[Walmart];

--Checking NULLs in columns

-- Checking for NULL values per column
SELECT COUNT(*) - COUNT([Branch]) AS null_branch FROM [Walmart].[dbo].[Walmart];
SELECT COUNT(*) - COUNT([City]) AS null_city FROM [Walmart].[dbo].[Walmart];
SELECT COUNT(*) - COUNT([Product_line]) AS null_product_line FROM [Walmart].[dbo].[Walmart];
SELECT COUNT(*) - COUNT([Unit_price]) AS null_unit_price FROM [Walmart].[dbo].[Walmart];
SELECT COUNT(*) - COUNT([Quantity]) AS null_quantity FROM [Walmart].[dbo].[Walmart];
SELECT COUNT(*) - COUNT([Date]) AS null_date FROM [Walmart].[dbo].[Walmart];

--Count of rows per category (product line)

SELECT [Product_line] AS category, COUNT(*) AS total_rows
FROM [Walmart].[dbo].[Walmart]
GROUP BY [Product_line];

-- Max and Min quantity sold
SELECT MAX([Quantity]) AS max_quantity FROM [Walmart].[dbo].[Walmart];
SELECT MIN([Quantity]) AS min_quantity FROM [Walmart].[dbo].[Walmart];

-- Number of transactions per payment method
SELECT [Payment] AS payment_method, COUNT(*) AS total_transactions
FROM [Walmart].[dbo].[Walmart]
GROUP BY [Payment];

-- Count of unique branches
SELECT COUNT(DISTINCT [Branch]) AS unique_branches
FROM [Walmart].[dbo].[Walmart];

-- To view All Data

SELECT * INTO [Walmart].[dbo].[sales]
FROM [Walmart].[dbo].[Walmart];

SELECT 
    [time],
    CASE
        WHEN [time] BETWEEN '00:00:00' AND '12:00:00' THEN 'Morning'
        WHEN [time] BETWEEN '12:01:00' AND '16:00:00' THEN 'Afternoon'
        ELSE 'Evening'
    END AS time_of_day
FROM [Walmart].[dbo].[Walmart];

--  Add the new column
ALTER TABLE [Walmart].[dbo].[Walmart]
ADD time_of_day VARCHAR(20);
GO

-- Update the new column based on the [time] column
UPDATE [Walmart].[dbo].[Walmart]
SET time_of_day = 
    CASE
        WHEN [time] BETWEEN '00:00:00' AND '12:00:00' THEN 'Morning'
        WHEN [time] BETWEEN '12:01:00' AND '16:00:00' THEN 'Afternoon'
        ELSE 'Evening'
    END;
GO

SELECT [time], time_of_day 
FROM [Walmart].[dbo].[Walmart]
ORDER BY [time];


SELECT 
    [date],
    DATENAME(WEEKDAY, [date]) AS day_name
FROM [Walmart].[dbo].[Walmart];

ALTER TABLE [Walmart].[dbo].[Walmart]
ADD day_name VARCHAR(15);
GO

UPDATE [Walmart].[dbo].[Walmart]
SET day_name = DATENAME(WEEKDAY, [date]);
GO

SELECT 
    [date],
    DATENAME(MONTH, [date]) AS month_name
FROM [Walmart].[dbo].[Walmart];


ALTER TABLE [Walmart].[dbo].[Walmart]
ADD month_name VARCHAR(15);
GO

UPDATE [Walmart].[dbo].[Walmart]
SET month_name = DATENAME(MONTH, [date]);
GO

SELECT [date], day_name, month_name 
FROM [Walmart].[dbo].[Walmart]
ORDER BY [date];

IF NOT EXISTS (
    SELECT * 
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'Walmart'
    AND COLUMN_NAME = 'day_name'
)
BEGIN
    ALTER TABLE [Walmart].[dbo].[Walmart]
    ADD day_name VARCHAR(10);
END
GO

UPDATE [Walmart].[dbo].[Walmart]
SET day_name = DATENAME(WEEKDAY, [date]);
GO

SELECT 
    [date],
    DATENAME(MONTH, [date]) AS month_name
FROM [Walmart].[dbo].[Walmart];
GO

-- Add the column if it doesn't exist
IF NOT EXISTS (
    SELECT * 
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'Walmart'
    AND COLUMN_NAME = 'month_name'
)
BEGIN
    ALTER TABLE [Walmart].[dbo].[Walmart]
    ADD month_name VARCHAR(15);
END
GO

-- Update the column with month names
UPDATE [Walmart].[dbo].[Walmart]
SET month_name = DATENAME(MONTH, [date]);
GO

-- How many unique cities does the data have ?

SELECT COUNT(DISTINCT city) AS unique_cities
FROM [Walmart].[dbo].[Walmart];


-- In which city is each branch ?
SELECT DISTINCT branch, city
FROM [Walmart].[dbo].[Walmart]
ORDER BY branch;

SELECT DISTINCT city, branch
FROM [Walmart].[dbo].[Walmart]
ORDER BY city, branch;

-- How many unique product lines does the data have ?

SELECT COUNT(DISTINCT product_line) AS unique_product_lines
FROM [Walmart].[dbo].[Walmart];

-- What is Most Common payment method ?

SELECT TOP 1 
    [Payment] AS payment_method,
    COUNT(*) AS cnt
FROM [Walmart].[dbo].[Walmart]
GROUP BY [Payment]
ORDER BY cnt DESC;

-- What is most selling product line ?
SELECT TOP 1
    [Product_line] AS product_line,
    COUNT(*) AS cnt
FROM [Walmart].[dbo].[Walmart]
GROUP BY [Product_line]
ORDER BY cnt DESC;

SELECT 
    [Product_line] AS product_line,
    COUNT(*) AS cnt
FROM [Walmart].[dbo].[Walmart]
GROUP BY [Product_line]
ORDER BY cnt DESC;

-- What is total revenue by month ?

SELECT 
    [month_name] AS month,
    SUM([Total]) AS total_revenue
FROM [Walmart].[dbo].[Walmart]
GROUP BY [month_name]
ORDER BY total_revenue DESC;

-- What month had the largest COGS ?
SELECT 
    [month_name] AS month,
    SUM([cogs]) AS total_cogs
FROM [Walmart].[dbo].[Walmart]
GROUP BY [month_name]
ORDER BY total_cogs DESC;

-- What product line had the largest revenue ?

SELECT 
    [Product_line] AS product_line,
    SUM([Total]) AS total_revenue
FROM [Walmart].[dbo].[Walmart]
GROUP BY [Product_line]
ORDER BY total_revenue DESC;

-- What is the city with the largest revenue ?
SELECT 
    [City] AS city,
    SUM([Total]) AS total_revenue
FROM [Walmart].[dbo].[Walmart]
GROUP BY [City]
ORDER BY total_revenue DESC;

-- What product line had the largest VAT ?

SELECT 
    [Product_line] AS product_line,
    AVG([Tax_5]) AS avg_tax
FROM [Walmart].[dbo].[Walmart]
GROUP BY [Product_line]
ORDER BY avg_tax DESC;
-- Which branch sold more products than average product sold ?
WITH BranchTotals AS (
    SELECT 
        [Branch],
        SUM([Quantity]) AS total_qty
    FROM [Walmart].[dbo].[Walmart]
    GROUP BY [Branch]
)
SELECT 
    [Branch],
    total_qty
FROM BranchTotals
WHERE total_qty > (SELECT AVG(total_qty) FROM BranchTotals);

-- What is the most common product line by gender ?

WITH GenderProductRank AS (
    SELECT 
        [Gender],
        [Product_line],
        COUNT(*) AS total_cnt,
        ROW_NUMBER() OVER (PARTITION BY [Gender] ORDER BY COUNT(*) DESC) AS rn
    FROM [Walmart].[dbo].[Walmart]
    GROUP BY [Gender], [Product_line]
)
SELECT 
    [Gender],
    [Product_line],
    total_cnt
FROM GenderProductRank
WHERE rn = 1;

-- What is the average rating of each product line ?

SELECT 
    [Product_line] AS product_line,
    ROUND(AVG([Rating]), 2) AS avg_rating
FROM [Walmart].[dbo].[Walmart]
GROUP BY [Product_line]
ORDER BY avg_rating DESC;

-- Which of the customer types brings the most revenue?

SELECT 
    [Customer_type] AS customer_type,
    SUM([Total]) AS total_rev
FROM [Walmart].[dbo].[Walmart]
GROUP BY [Customer_type]
ORDER BY total_rev DESC;

-- Which city has the largest tax percent/ VAT (Value Added Tax)?
SELECT 
    [City] AS city,
    AVG([Tax_5]) AS avg_vat
FROM [Walmart].[dbo].[Walmart]
GROUP BY [City]
ORDER BY avg_vat DESC;

-- Which customer type pays the most in VAT?

SELECT 
    [Customer_type] AS customer_type,
    SUM([Tax_5]) AS total_vat
FROM [Walmart].[dbo].[Walmart]
GROUP BY [Customer_type]
ORDER BY total_vat DESC;


-- How many unique customer types does the data have?
SELECT COUNT(DISTINCT [Customer_type]) AS unique_customer_types
FROM [Walmart].[dbo].[Walmart];
-- How many unique payment methods does the data have?
SELECT COUNT(DISTINCT [Payment]) AS unique_payment_methods
FROM [Walmart].[dbo].[Walmart];

SELECT DISTINCT [Payment]
FROM [Walmart].[dbo].[Walmart];

-- Which customer type buys the most?
SELECT 
    [Customer_type] AS customer_type, 
    COUNT(*) AS cstm_cnt
FROM [Walmart].[dbo].[Walmart]
GROUP BY [Customer_type]
ORDER BY cstm_cnt DESC;

SELECT TOP 1
    [Customer_type] AS customer_type, 
    COUNT(*) AS cstm_cnt
FROM [Walmart].[dbo].[Walmart]
GROUP BY [Customer_type]
ORDER BY cstm_cnt DESC;

-- What is the gender of most of the customers?
SELECT TOP 1
    [Gender] AS gender,
    COUNT(*) AS gender_cnt
FROM [Walmart].[dbo].[Walmart]
GROUP BY [Gender]
ORDER BY gender_cnt DESC;

-- What is the gender distribution per branch?
SELECT 
    [Branch],
    [Gender],
    COUNT(*) AS gender_cnt
FROM [Walmart].[dbo].[Walmart]
GROUP BY [Branch], [Gender]
ORDER BY [Branch], gender_cnt DESC;

-- Which day fo the week has the best avg ratings?
SELECT 
    [Day_name] AS day_name,
    AVG([Rating]) AS avg_rating
FROM [Walmart].[dbo].[Walmart]
GROUP BY [Day_name]
ORDER BY avg_rating DESC;

-- Which day of the week has the best average ratings per branch?

SELECT 
    [Branch],
    [Day_name] AS day_name,
    AVG([Rating]) AS avg_rating
FROM [Walmart].[dbo].[Walmart]
GROUP BY [Branch], [Day_name]
ORDER BY [Branch], avg_rating DESC;

-- What are the different payment methods, and how many transactions and items were sold with each method?

SELECT 
    [Payment] AS payment_method,
    COUNT(*) AS no_of_transaction,
    SUM([Quantity]) AS sum_of_quantity
FROM [Walmart].[dbo].[Walmart]
GROUP BY [Payment];

-- Identify the highest-rated category in each branch, displaying the branch, category and average rating ?
WITH CategoryRank AS (
    SELECT 
        [Branch],
        [Product_line] AS category,
        AVG([Rating]) AS average_rating,
        RANK() OVER(PARTITION BY [Branch] ORDER BY AVG([Rating]) DESC) AS ranking
    FROM [Walmart].[dbo].[Walmart]
    GROUP BY [Branch], [Product_line]
)
SELECT 
    [Branch],
    category,
    average_rating
FROM CategoryRank
WHERE ranking = 1;

-- Identify the busiest day for each branch based on the number of transactions?

WITH DayRank AS (
    SELECT 
        [Branch],
        [Day_name] AS day_of_week,
        COUNT(*) AS transaction_count,
        RANK() OVER(PARTITION BY [Branch] ORDER BY COUNT(*) DESC) AS ranking
    FROM [Walmart].[dbo].[Walmart]
    GROUP BY [Branch], [Day_name]
)
SELECT 
    [Branch],
    day_of_week,
    transaction_count
FROM DayRank
WHERE ranking = 1;

-- Calculate the total quantity of items sold per payment method. List payment_method and total_quantity?
SELECT 
    [Payment] AS payment_method,
    SUM([Quantity]) AS total_quantity
FROM [Walmart].[dbo].[Walmart]
GROUP BY [Payment];

-- Determine the average, minimum, and maximum rating of category for each city. 
-- List the city, average_rating, min_rating, and max_rating.

SELECT 
    [City],
    [Product_line] AS category,
    ROUND(AVG([Rating]), 2) AS avg_rating,
    MIN([Rating]) AS min_rating,
    MAX([Rating]) AS max_rating
FROM [Walmart].[dbo].[Walmart]
GROUP BY [City], [Product_line]
ORDER BY [City];

-- Calculate the total profit for each category by considering total_profit as (unit_price * quantity * profit_margin). 
-- List category and total_profit, ordered from highest to lowest profit.

SELECT 
    [Product_line] AS category,
    SUM([Unit_price] * [Quantity] * [gross_margin_percentage]) AS total_profit
FROM [Walmart].[dbo].[Walmart]
GROUP BY [Product_line]
ORDER BY total_profit DESC;

--  Determine the most common payment method for each Branch. 
-- Display Branch and the preferred_payment_method.

WITH PaymentRank AS (
    SELECT 
        [Branch],
        [Payment] AS payment_method,
        COUNT(*) AS count_payment,
        RANK() OVER(PARTITION BY [Branch] ORDER BY COUNT(*) DESC) AS ranking
    FROM [Walmart].[dbo].[Walmart]
    GROUP BY [Branch], [Payment]
)
SELECT 
    [Branch],
    payment_method,
    count_payment
FROM PaymentRank
WHERE ranking = 1;

--- Categorize sales into 3 group MORNING, AFTERNOON, EVENING 
-- Find out each of the shift and number of invoices

SELECT
    CASE 
        WHEN DATEPART(HOUR, [Time]) < 12 THEN 'Morning'
        WHEN DATEPART(HOUR, [Time]) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END AS shift,
    COUNT(*) AS total_invoices
FROM [Walmart].[dbo].[Walmart]
GROUP BY 
    CASE 
        WHEN DATEPART(HOUR, [Time]) < 12 THEN 'Morning'
        WHEN DATEPART(HOUR, [Time]) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END;


-- Identify the 5 branches with the highest revenue decrease ratio from last year to current year (e.g., 2022 to 2023)


WITH LastYear AS (
    SELECT 
        [Branch],
        SUM([Total]) AS revenue
    FROM [Walmart].[dbo].[Walmart]
    WHERE YEAR([Date]) = 2022
    GROUP BY [Branch]
),
CurrentYear AS (
    SELECT 
        [Branch],
        SUM([Total]) AS revenue
    FROM [Walmart].[dbo].[Walmart]
    WHERE YEAR([Date]) = 2023
    GROUP BY [Branch]
)
SELECT 
    ly.[Branch],
    ((ly.revenue - cy.revenue) * 100.0) / ly.revenue AS decrease_ratio
FROM LastYear ly
JOIN CurrentYear cy ON ly.[Branch] = cy.[Branch]
ORDER BY decrease_ratio DESC
OFFSET 0 ROWS FETCH NEXT 5 ROWS ONLY;


-- Updated: Top 5 stores with highest sales decrease (2011 vs. 2012)
WITH LastYear AS (
    SELECT Store, SUM(Weekly_Sales) AS revenue
    FROM sales  -- Assuming table renamed/updated to match dataset
    WHERE YEAR(Date) = 2011
    GROUP BY Store
),
CurrentYear AS (
    SELECT Store, SUM(Weekly_Sales) AS revenue
    FROM sales
    WHERE YEAR(Date) = 2012
    GROUP BY Store
)
SELECT 
    ly.Store,
    ((ly.revenue - cy.revenue) * 100.0 / ly.revenue) AS decrease_ratio
FROM LastYear ly
JOIN CurrentYear cy ON ly.Store = cy.Store
ORDER BY decrease_ratio DESC
OFFSET 0 ROWS FETCH NEXT 5 ROWS ONLY;

-----Thank You-----------























