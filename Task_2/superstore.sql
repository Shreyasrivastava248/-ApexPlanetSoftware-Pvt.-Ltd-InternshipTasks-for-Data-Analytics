/* =====================================================
   STEP 1 — Create Table Structure
   All columns initially imported as VARCHAR
   ===================================================== */

CREATE TABLE superstore(
    Row_ID VARCHAR(50),
    Order_ID VARCHAR(50),
    Order_Date VARCHAR(50),
    Ship_Date VARCHAR(50),
    Ship_Mode VARCHAR(50),
    Customer_ID VARCHAR(50),
    Customer_Name VARCHAR(50),
    Segment VARCHAR(50),
    Country VARCHAR(50),
    City VARCHAR(50),
    States VARCHAR(50),
    Postal_Code VARCHAR(50),
    Region VARCHAR(50),
    Product_ID VARCHAR(50),
    Category VARCHAR(50),
    Sub_Category VARCHAR(50),
    Product_Name VARCHAR(250),
    Sales VARCHAR(50),
    Quantity VARCHAR(50),
    Discount VARCHAR(50),
    Profit VARCHAR(50)
);




/* =====================================================
   STEP 2 — Import CSV Data
   ===================================================== */

COPY superstore
FROM 'D:\Github Repositories\-ApexPlanetSoftware-Pvt.-Ltd-InternshipTasks-for-Data-Analytics\Task_2\superstore.csv'
WITH (
    FORMAT csv,
    HEADER true,
    QUOTE '"',
    ESCAPE '"',
    ENCODING 'UTF8'
);

SELECT * FROM superstore;


/* =====================================================
   STEP 3 — Data Type Conversion
   Convert text fields into appropriate data types
   ===================================================== */

ALTER TABLE superstore
ALTER COLUMN Order_Date TYPE DATE USING TO_DATE(Order_Date,'mm/dd/YYYY'),
ALTER COLUMN Ship_Date TYPE DATE USING TO_DATE(Ship_Date,'mm/dd/YYYY'),
ALTER COLUMN Customer_Name TYPE TEXT USING Customer_Name::TEXT,
ALTER COLUMN Sales TYPE NUMERIC(10,2) USING Sales::NUMERIC,
ALTER COLUMN Quantity TYPE INT USING Quantity::INT,
ALTER COLUMN Discount TYPE NUMERIC(10,2) USING Discount::NUMERIC,
ALTER COLUMN Profit TYPE NUMERIC(10,2) USING Profit::NUMERIC;
/* =====================================================
   STEP 4 — Remove Missing (NULL) Values
   ===================================================== */

DELETE FROM superstore
WHERE Row_ID IS NULL
   OR Order_ID IS NULL
   OR Customer_ID IS NULL
   OR Postal_Code IS NULL
   OR Product_ID IS NULL
   OR Profit IS NULL
   OR Discount IS NULL
   OR Quantity IS NULL
   OR Sales IS NULL;



/* =====================================================
   STEP 5 — Remove Duplicate Records 
   ===================================================== */

DELETE FROM superstore
WHERE ctid NOT IN (
    SELECT MIN(ctid)
    FROM superstore
    GROUP BY Row_ID
);


/* =====================================================
   STEP 6 — Remove Future Dates
   ===================================================== */

DELETE FROM superstore
WHERE Order_Date > CURRENT_DATE;

DELETE FROM superstore
WHERE Ship_Date > CURRENT_DATE;

/* =====================================================
   STEP 7 — Text Cleaning
   ===================================================== */

UPDATE superstore
SET product_name = INITCAP(TRIM(product_name)),
    city = INITCAP(TRIM(city)),
    states = INITCAP(TRIM(states)),
    segment = INITCAP(TRIM(segment)),
    category = INITCAP(TRIM(category)),
    sub_category = INITCAP(TRIM(sub_category)),
    region = INITCAP(TRIM(region));

-- QUESTION NO 1------------------------------------
/* =====================================================
   STEP 8 — Descriptive Statistics (Numerical Fields)
   ===================================================== */

-- Sales Summary
SELECT 
    SUM(Sales) AS total_sales,
    AVG(Sales) AS average_sales,
    MAX(Sales) AS maximum_sales,
    MIN(Sales) AS minimum_sales,
    ROUND(STDDEV(sales),2) AS sales_stddev,
   PERCENTILE_CONT(0.5) 
   WITHIN GROUP (ORDER BY sales),
   MODE ()WITHIN GROUP(ORDER BY SALES)
FROM superstore;


-- Quantity Summary
SELECT
    SUM(Quantity) AS total_quantity,
    AVG(Quantity) AS average_quantity,
    MAX(Quantity) AS maximum_quantity,
    MIN(Quantity) AS minimum_quantity,
    PERCENTILE_CONT(0.5)within Group(order by quantity),
    mode()within Group (Order by quantity)
FROM superstore;

-- Discount Summary
SELECT
    SUM(Discount) AS total_discount,
    AVG(Discount) AS average_discount,
    MAX(Discount) AS maximum_discount,
    MIN(Discount) AS minimum_discount,
    PERCENTILE_CONT (0.5) within GROUP(order by discount),
    mode()within group(order by discount)
FROM superstore;

-- Profit Summary
SELECT 
    SUM(Profit) AS total_profit,
    AVG(Profit) AS average_profit,
    MIN(Profit) AS minimum_profit,
    MAX(Profit) AS maximum_profit,
    PERCENTILE_CONT (0.5) within group(order by profit),
    mode () within group(order by profit)
FROM superstore;

-- YEAR-WISE SALES & PROFIT ANALYSIS
SELECT 
    EXTRACT(YEAR FROM order_date) AS year,
    ROUND(SUM(sales),2) AS total_sales,
    ROUND(SUM(profit),2) AS total_profit,
    PERCENTILE_CONT (0.5) within group(order by sales),
    PERCENTILE_CONT (0.5) within group(order by profit),
    mode() within group(order by sales),
    mode()within group (order by profit)
FROM superstore
GROUP BY year
ORDER BY year;



/* =====================================================
   STEP 9 — Descriptive Statistics (Categorical Fields)
   ===================================================== */

-- Category Distribution
SELECT Category, COUNT(*) AS frequency
FROM superstore
GROUP BY Category
ORDER BY frequency DESC;

SELECT COUNT(DISTINCT Category) AS distinct_categories
FROM superstore;

-- Sub-Category Distribution
SELECT Sub_Category, COUNT(*) AS frequency
FROM superstore
GROUP BY Sub_Category
ORDER BY frequency DESC;

SELECT COUNT(DISTINCT Sub_Category) AS distinct_subcategories
FROM superstore;

-- Segment Distribution
SELECT Segment, COUNT(*) AS frequency
FROM superstore
GROUP BY Segment
ORDER BY frequency DESC;

SELECT COUNT(DISTINCT Segment) AS distinct_segments
FROM superstore;

-- Region Distribution
SELECT Region, COUNT(*) AS frequency
FROM superstore
GROUP BY Region
ORDER BY frequency DESC;

SELECT COUNT(DISTINCT Region) AS distinct_regions
FROM superstore;  ALTER

-- Category Frequency

SELECT 
    category,
    COUNT(*) AS frequency
FROM superstore
GROUP BY category
ORDER BY frequency DESC;
 -- Segment Frequency

SELECT 
    segment,
    COUNT(*) AS frequency
FROM superstore
GROUP BY segment
ORDER BY frequency DESC;

/* =====================================================
   STEP 10 — Export Cleaned Dataset
   ===================================================== */

COPY superstore
TO 'D:\CLEAN_SUPERSTORE.CSV'
DELIMITER ','
CSV HEADER;

/* ============================================================
   BUSINESS QUESTION 1
   Top 10 Best-Selling Products by Quantity Sold in 2017
   ============================================================ */

-- Extract orders from year 2017
-- Group by product to calculate total quantity sold
-- Sort in descending order to get highest selling products
-- Limit result to top 10

SELECT Product_ID, Product_Name , SUM(Quantity) AS TOTAL_SOLD_QUANTITY
FROM superstore
WHERE EXTRACT(YEAR FROM ORDER_DATE)=2017
GROUP BY product_id,product_name
ORDER BY SUM(Quantity) DESC
LIMIT 10;



/* ============================================================
   BUSINESS QUESTION 2
   Top 5 Products Generating Highest Revenue in Last 6 Months
   ============================================================ */

-- Identify last 6 months using max order date
-- Calculate total revenue per product
-- Sort in descending order to get top revenue products

SELECT Product_Name,
       ROUND(SUM(Sales),2) AS total_revenue
FROM superstore
WHERE order_date >= (
    SELECT MAX(order_date) FROM superstore
) - INTERVAL '6 months'
GROUP BY product_name
ORDER BY total_revenue DESC
LIMIT 5;




/* ============================================================
   BUSINESS QUESTION 3
   Identify Repeat Customers
   ============================================================ */

-- Count total orders placed by each customer
-- Filter customers who placed more than one order
-- Sort by highest order count

SELECT Customer_ID,Customer_Name ,COUNT(ORDER_ID) AS COUNT_ORDER,SUM(SALES) AS total_sales
FROM superstore
GROUP BY Customer_ID,Customer_Name
HAVING COUNT(ORDER_ID)>1
ORDER BY COUNT(ORDER_ID)DESC;



/* ============================================================
   BUSINESS QUESTION 4
   Top 5 Cities with Highest Number of Orders
   ============================================================ */

-- Count total orders per city
-- Sort by highest order volume
-- Display top 5 cities

SELECT CITY,COUNT(ORDER_ID) AS COUNT_ORDER
FROM superstore
GROUP BY city
HAVING COUNT(ORDER_ID)>1
ORDER BY COUNT(ORDER_ID)DESC
LIMIT 5;



/* ============================================================
   BUSINESS QUESTION 5
   Top 5 Countries with Highest Number of Orders
   ============================================================ */

SELECT Country , COUNT(ORDER_ID) AS total_orders
FROM superstore
GROUP BY country
HAVING COUNT(ORDER_ID)>1
ORDER BY COUNT(ORDER_ID) DESC
LIMIT 5;



/* ============================================================
   BUSINESS QUESTION 6
   Bottom 5 Cities with Lowest Number of Orders
   ============================================================ */

SELECT CITY, COUNT(ORDER_ID) AS total_orders
FROM superstore
GROUP BY city
HAVING COUNT(ORDER_ID)>1
ORDER BY COUNT(ORDER_ID) ASC
LIMIT 5;



/* ============================================================
   BUSINESS QUESTION 7
   Bottom 5 Countries with Lowest Number of Orders
   ============================================================ */

SELECT 
    Country,
    COUNT(DISTINCT Order_ID) AS total_orders
FROM superstore
GROUP BY Country
ORDER BY total_orders ASC
LIMIT 5;



/* ============================================================
   BUSINESS QUESTION 8
   Top 5 States with Highest Number of Orders
   ============================================================ */

SELECT STATES, COUNT(DISTINCT ORDER_ID) AS total_orders
FROM superstore
GROUP BY states
ORDER BY COUNT(DISTINCT ORDER_ID) DESC
LIMIT 5;



/* ============================================================
   BUSINESS QUESTION 9
   Bottom 5 States with Lowest Number of Orders
   ============================================================ */

SELECT STATES ,COUNT(DISTINCT(ORDER_ID)) AS total_orders
FROM superstore
GROUP BY states
ORDER BY COUNT(DISTINCT(ORDER_ID)) ASC
LIMIT 5;



/* ============================================================
   BUSINESS QUESTION 10
   Identify Products with Highest Discount
   ============================================================ */

-- Sort products by highest discount offered
-- Display top 5 highest discounted entries

SELECT Product_Name,Discount 
FROM superstore
ORDER BY discount DESC
LIMIT 5;



/* ============================================================
   BUSINESS QUESTION 11
   Identify Products with Lowest Discount
   ============================================================ */

SELECT PRODUCT_NAME , Discount
FROM superstore
ORDER BY discount ASC
LIMIT 5;



/* ============================================================
   BUSINESS QUESTION 12
   Average Order Value (AOV) per Customer
   ============================================================ */

-- Calculate AOV using total sales divided by total distinct orders
-- Sort customers by highest AOV

SELECT Customer_Name ,
ROUND(SUM(SALES)/COUNT(DISTINCT(ORDER_ID)),2) AS AOV
FROM superstore
GROUP BY customer_name
ORDER BY AOV DESC;



/* ============================================================
   BUSINESS QUESTION 13
   Identify Repeat Customers (More Than One Order)
   ============================================================ */

SELECT 
    Customer_Name,COUNT(DISTINCT Order_ID) AS total_orders
FROM superstore
GROUP BY Customer_Name
HAVING COUNT(DISTINCT Order_ID) > 1
ORDER BY total_orders DESC;

-- QUESTION NO 2------------------------------------

/* ============================================================
   BUSINESS QUESTION 14
   Compare Order Volume: Weekdays vs Weekends
   ============================================================ */

-- Weekday Orders (Monday–Friday)

SELECT COUNT(DISTINCT(ORDER_ID)) AS total_orders
FROM superstore
WHERE EXTRACT(DOW FROM Order_Date) IN (1,2,3,4,5);


-- Weekend Orders (Saturday–Sunday)

SELECT COUNT(DISTINCT(ORDER_ID)) AS total_orders
FROM superstore
WHERE EXTRACT(DOW FROM Order_Date) IN (0,6);



-- Sales Summary (Min, Max, Outliers using IQR)

WITH sales_stats AS (
    SELECT
        MIN(sales) AS min_value,
        MAX(sales) AS max_value,
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY sales) AS q1,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY sales) AS q3
    FROM superstore
),
iqr_calc AS (
    SELECT *,
           (q3 - q1) AS iqr,
           (q1 - 1.5 * (q3 - q1)) AS lower_bound,
           (q3 + 1.5 * (q3 - q1)) AS upper_bound
    FROM sales_stats
)
SELECT 
    min_value,
    max_value,
    (
        SELECT COUNT(*)
        FROM superstore, iqr_calc
        WHERE sales < lower_bound OR sales > upper_bound
    ) AS outliers_detected
FROM iqr_calc;


-- Profit Summary (Min, Max, Outliers using IQR)

WITH profit_stats AS (
    SELECT
        MIN(profit) AS min_value,
        MAX(profit) AS max_value,
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY profit) AS q1,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY profit) AS q3
    FROM superstore
),
iqr_calc AS (
    SELECT *,
           (q3 - q1) AS iqr,
           (q1 - 1.5 * (q3 - q1)) AS lower_bound,
           (q3 + 1.5 * (q3 - q1)) AS upper_bound
    FROM profit_stats
)
SELECT 
    min_value,
    max_value,
    (
        SELECT COUNT(*)
        FROM superstore, iqr_calc
        WHERE profit < lower_bound OR profit > upper_bound
    ) AS outliers_detected
FROM iqr_calc;


SELECT 'row_id' AS column_name, COUNT(DISTINCT row_id) FROM superstore
UNION ALL
SELECT 'order_id', COUNT(DISTINCT order_id) FROM superstore
UNION ALL
SELECT 'customer_id', COUNT(DISTINCT customer_id) FROM superstore
UNION ALL
SELECT 'customer_name', COUNT(DISTINCT customer_name) FROM superstore
UNION ALL
SELECT 'product_id', COUNT(DISTINCT product_id) FROM superstore
UNION ALL
SELECT 'product_name', COUNT(DISTINCT product_name) FROM superstore
UNION ALL
SELECT 'city', COUNT(DISTINCT city) FROM superstore
UNION ALL
SELECT 'states', COUNT(DISTINCT states) FROM superstore
UNION ALL
SELECT 'category', COUNT(DISTINCT category) FROM superstore
UNION ALL
SELECT 'sub_category', COUNT(DISTINCT sub_category) FROM superstore
UNION ALL
SELECT 'segment', COUNT(DISTINCT segment) FROM superstore
UNION ALL
SELECT 'ship_mode', COUNT(DISTINCT ship_mode) FROM superstore
UNION ALL
SELECT 'region', COUNT(DISTINCT region) FROM superstore;






WITH stats AS (
    SELECT
        -- Mean
        AVG(sales) AS mean_sales,
        AVG(profit) AS mean_profit,
        AVG(discount) AS mean_discount,
        AVG(quantity) AS mean_quantity,

        -- Standard Deviation
        STDDEV(sales) AS std_sales,
        STDDEV(profit) AS std_profit,
        STDDEV(discount) AS std_discount,
        STDDEV(quantity) AS std_quantity,

        -- Minimum
        MIN(sales) AS min_sales,
        MIN(profit) AS min_profit,
        MIN(discount) AS min_discount,
        MIN(quantity) AS min_quantity,

        -- Maximum
        MAX(sales) AS max_sales,
        MAX(profit) AS max_profit,
        MAX(discount) AS max_discount,
        MAX(quantity) AS max_quantity,

        -- Quartiles
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY sales) AS q1_sales,
        PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY sales) AS median_sales,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY sales) AS q3_sales,

        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY profit) AS q1_profit,
        PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY profit) AS median_profit,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY profit) AS q3_profit,

        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY discount) AS q1_discount,
        PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY discount) AS median_discount,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY discount) AS q3_discount,

        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY quantity) AS q1_quantity,
        PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY quantity) AS median_quantity,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY quantity) AS q3_quantity

    FROM superstore
)

SELECT * FROM states;

SELECT 
    category,
    SUM(sales) AS total_sales,
    ROUND(
        (SUM(sales) * 100.0 / SUM(SUM(sales)) OVER()), 
        1
    ) AS percentage_of_total_sales
FROM superstore
GROUP BY category

UNION ALL

SELECT 
    'Grand Total',
    SUM(sales),
    100
FROM superstore;

SELECT 
    segment,
    SUM(sales) AS total_sales,
    ROUND(
        (SUM(sales) * 100.0 / SUM(SUM(sales)) OVER()), 
        1
    ) AS percentage_of_total_sales
FROM superstore
GROUP BY segment

UNION ALL

SELECT 
    'Grand Total',
    SUM(sales),
    100
FROM superstore;

WITH order_level AS (
    SELECT
        order_id,
        category,
        SUM(sales) AS order_sales,
        SUM(profit) AS order_profit
    FROM superstore
    GROUP BY order_id, category
)

SELECT
    category,
    ROUND(AVG(order_sales), 2) AS avg_sales_per_order,
    ROUND(AVG(order_profit), 2) AS avg_profit_per_order
FROM order_level
GROUP BY category
ORDER BY avg_sales_per_order DESC;