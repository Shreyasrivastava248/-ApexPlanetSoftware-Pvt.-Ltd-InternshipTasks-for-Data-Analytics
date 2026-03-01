CREATE TABLE ecommerce_sales_data(
Order_id VARCHAR(50),
Order_Dates	VARCHAR(50),
Product_Name VARCHAR(50),
Category VARCHAR(50),
Region	VARCHAR(50),
Quantity VARCHAR(50),
Sales VARCHAR(50),
Profit	VARCHAR(50),
Country	VARCHAR(50),
Customer_Name VARCHAR(50),
State VARCHAR(50),
sub_category VARCHAR(50),
discount VARCHAR(50),
segment VARCHAR(50)
);

COPY ecommerce_sales_data
FROM 'D:\Github Repositories\-ApexPlanetSoftware-Pvt.-Ltd-InternshipTasks-for-Data-Analytics\Task_3\ecommerce_sales_data.csv'
WITH (
    FORMAT csv,
    HEADER true,
    QUOTE '"',
    ESCAPE '"',
    ENCODING 'UTF8'
);

-----------------------------Data cleanning-------------------------
-------------------ALTER DATA TYPE----------------------------
ALTER TABLE ecommerce_sales_data
ALTER COLUMN Order_Dates  type date using TO_DATE(order_dates,'dd/mm/YYYY'),
ALTER  COLUMN Quantity TYPE INT  USING Quantity::INT,
ALTER COLUMN Sales TYPE  DECIMAL(10,2) USING sales::DECIMAL,
ALTER COLUMN Profit TYPE DECIMAL(10,2)USING Profit::DECIMAL,
ALTER COLUMN Discount  TYPE  DECIMAL(5,2)USING Discount::DECIMAL;

-----------------------CHECKING NULL--------------------------
SELECT * from ecommerce_sales_data
where order_id is null or
order_dates is null or
product_name is null or
Category is null or
quantity is null or
sales is null or
profit is null;

----------------------- checking duplicate-------------------
SELECT order_id from ecommerce_sales_data
where ctid not in (
    SELECT min(ctid)
    FROM ecommerce_sales_data
    GROUP BY order_id
);

------------------checking future date-----------
SELECT order_dates FROM ecommerce_sales_data
where order_dates > CURRENT_DATE;

-----------checking negative value--------------
SELECT quantity, sales, profit, discount from ecommerce_sales_data
where quantity < 0 or
sales < 0 or
profit < 0 or
discount < 0 ;
------------------checking outlier------------------------
SELECT * FROM ecommerce_sales_data 
WHERE sales > (
    SELECT AVG(sales) + 3 * STDDEV(sales)
    FROM ecommerce_sales_data
) AND Quantity > (
    SELECT AVG(quantity) + 3 * STDDEV(quantity)
    FROM ecommerce_sales_data
);

-------------- remove duplicate--------------
DELETE  from ecommerce_sales_data
where ctid not in(
    SELECT min(ctid)
    from ecommerce_sales_data
    GROUP BY order_id
);

-------------text- cleaning----------------
update ecommerce_sales_data
SET
product_name=INITCAP(TRIM(product_name)),
category=INITCAP(TRIM(category)),
region=INITCAP(TRIM(region)),
country=INITCAP(TRIM(country)),
customer_name=INITCAP(TRIM(customer_name)),
state=INITCAP(TRIM(state)),
sub_category=INITCAP(TRIM(sub_category)),
segment=INITCAP(TRIM(segment));

----------------------------BUSSINESS QUESTION-----------------------------

-- How much total money did we earn from selling our products?
SELECT sum(sales)as total_sales
from ecommerce_sales_data;

-- After removing all costs, how much money did we actually earn?
SELECT sum(profit)as total_profit
from ecommerce_sales_data;
-- Out of the total sales, how much percentage is profit?
SELECT (SUM(Profit)/SUM(SALES)*100) AS PROFIT_MARGIN
FROM ecommerce_sales_data;

-- On average, how much money does one customer spend in one order?
SELECT AVG(SALES)/COUNT(Order_id)AS AVGER_ORDER_VALUE
FROM ecommerce_sales_data;

-- How many customers come back and buy from us again?
SELECT Customer_Name,COUNT(ORDER_ID)AS total_orders
FROM ecommerce_sales_data
GROUP BY customer_name
HAVING COUNT(ORDER_ID) >1;
-- Out of all the people who visited, how many actually purchased?
SELECT COUNT(ORDER_ID)AS total_orders
FROM ecommerce_sales_data;
-- How many customers stopped buying from us?
SELECT Customer_Name, MAX(Order_Dates) AS Last_Order_Date
FROM ecommerce_sales_data
GROUP BY Customer_Name
HAVING MAX(Order_Dates) < (
    SELECT MAX(Order_Dates)
    FROM ecommerce_sales_data
);
-- In which month do most customers start buying from us?
SELECT 
    EXTRACT(MONTH FROM first_order_date) AS month,
    COUNT(order_id) AS new_customers
FROM (
    SELECT 
        order_id,
        MIN(Order_Dates) AS first_order_date
    FROM ecommerce_sales_data
    GROUP BY order_id
) AS first_orders
GROUP BY EXTRACT(MONTH FROM first_order_date)
ORDER BY new_customers DESC;
-- For how many months do customers continue buying from us?
SELECT 
    customer_name,
    MIN(Order_Dates) AS first_order,
    MAX(Order_Dates) AS last_order,
    DATE_PART('month', AGE(MAX(Order_Dates), MIN(Order_Dates))) 
    + 12 * DATE_PART('year', AGE(MAX(Order_Dates), MIN(Order_Dates))) 
    AS active_months
FROM ecommerce_sales_data
GROUP BY customer_name;
-- How many customers spend more than 5000 with us?
SELECT 
Customer_Name, SUM(SALES)AS total_sales
FROM ecommerce_sales_data
GROUP BY customer_name
HAVING SUM(SALES)>5000;

-- How many customers spend between 1000 and 5000?
SELECT 
COUNT(*) AS Customers
FROM (
    SELECT Customer_Name
    FROM ecommerce_sales_data
    GROUP BY customer_name
    HAVING SUM(sales) between 1000 AND 5000
)AS Filtered;

-- How many customers spend less than 1000?
SELECT count(*)as customer
from ( 
    SELECT customer_name
    from ecommerce_sales_data
    GROUP BY customer_name
    HAVING sum(sales) <1000
)AS filtered;
-- Which customer group (High, Medium, or Low) gives us the highest profit?
SELECT 
    customer_group,
    SUM(profit) AS total_profit
FROM (
    SELECT 
        customer_name,
        SUM(sales) AS total_sales,
        SUM(profit) AS profit,
        CASE
            WHEN SUM(sales) <= 56089 THEN 'low_group'
            WHEN SUM(sales) <= 112178 THEN 'medium_group'
            ELSE 'high_group'
        END AS customer_group
    FROM ecommerce_sales_data
    GROUP BY customer_name
) AS t
GROUP BY customer_group
ORDER BY total_profit DESC;



-- Which region has the most high-spending customers?

SELECT region, COUNT(*) AS high_spending_customers
FROM (
    SELECT customer_name, region, SUM(Sales) AS total_spend
    FROM ecommerce_sales_data
    GROUP BY customer_name, region
) t
WHERE total_spend > 5300
GROUP BY region
ORDER BY high_spending_customers DESC
LIMIT 1;




-- Which region generates the highest total sales?
SELECT  region, sum(sales)as total_sales
from ecommerce_sales_data
GROUP BY region
order BY total_sales DESC
LIMIT 1;

-- Which product category sells the most?
SELECT category, SUM(sales) AS total_sales
FROM ecommerce_sales_data
GROUP BY category
ORDER BY total_sales DESC
LIMIT 1;

-- Which product category gives us the highest profit?
SELECT category, sum(profit)as highest_profit
from ecommerce_sales_data
GROUP BY category
order BY highest_profit
LIMIT 1;
-- In which months do we earn more sales and in which months do sales drop?
SELECT EXTRACT(MONTH FROM CAST(order_dates AS DATE)) AS month,
sum(sales)as total_sales
FROM ecommerce_sales_data
GROUP BY month
order by total_sales DESC
limit 1;
SELECT EXTRACT(MONTH FROM CAST(order_dates AS DATE)) AS month,
sum(sales)as total_sales
FROM ecommerce_sales_data
GROUP BY month
order by total_sales ASC
limit 1;
-- What percentage of customers belong to High, Medium, and Low segments?
WITH customer_segments AS (
    SELECT customer_name, 
           SUM(sales) AS total_sales,
           CASE
               WHEN SUM(sales) > 50000 THEN 'High'
               WHEN SUM(sales) BETWEEN 20000 AND 50000 THEN 'Medium'
               ELSE 'Low'
           END AS segment_group
    FROM ecommerce_sales_data
    GROUP BY customer_name
)
SELECT 
    segment_group,
    COUNT(*) AS customer_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM customer_segments), 2) AS percentage
FROM customer_segments
GROUP BY segment_group;
-- Which customers buy recently, buy frequently, and spend more money?
select customer_name , max(order_dates)as recent_dates
from ecommerce_sales_data
GROUP BY customer_name
order by recent_dates DESC
limit 1;

SELECT customer_name, COUNT(*) AS order_count
FROM ecommerce_sales_data
GROUP BY customer_name
ORDER BY order_count DESC
LIMIT 1;

SELECT customer_name, SUM(sales) AS total_spent
FROM ecommerce_sales_data
GROUP BY customer_name
ORDER BY total_spent DESC
LIMIT 1;

COPY ecommerce_sales_data
TO 'D:\Github Repositories\-ApexPlanetSoftware-Pvt.-Ltd-InternshipTasks-for-Data-Analytics\Task_3\clean_data.csv'
WITH (
    FORMAT csv,
    HEADER true,
    QUOTE '"',
    ESCAPE '"',
    ENCODING 'UTF8'
);