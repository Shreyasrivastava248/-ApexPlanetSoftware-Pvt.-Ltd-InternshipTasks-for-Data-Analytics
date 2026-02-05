-- =====================================================
-- TABLE CREATION: Customer Shopping Data
-- =====================================================
-- This table stores customer purchase details including
-- demographics, transaction info, and payment details
-- =====================================================

CREATE TABLE customer_shopping_data (
    invoice_no VARCHAR(50),        -- Unique invoice number for each transaction
    customer_id VARCHAR(50),        -- Unique identifier for each customer
    gender VARCHAR(50),             -- Customer gender
    age INT,                        -- Customer age
    category VARCHAR(50),           -- Product category
    quantity VARCHAR(50),           -- Quantity purchased (initially stored as text)
    price VARCHAR(50),              -- Price of product (initially stored as text)
    payment_method VARCHAR(50),     -- Mode of payment
    invoice_date VARCHAR(50),       -- Date of invoice (stored as text)
    shopping_mall VARCHAR(50)       -- Shopping mall name
);

-- View all records from the table
SELECT
    *
FROM
    customer_shopping_data;

-- =====================================================
-- DATA TYPE CONVERSION
-- =====================================================
-- Convert incorrect data types to appropriate formats
-- =====================================================

ALTER TABLE
    customer_shopping_data
ALTER COLUMN
    quantity TYPE INT USING quantity :: INT,                 -- Convert quantity to INT
ALTER COLUMN
    PRICE TYPE numeric(10, 2) USING PRICE :: numeric,         -- Convert price to numeric
ALTER COLUMN
    invoice_date TYPE DATE USING TO_DATE(invoice_date, 'DD/MM/YYYY'); -- Convert date format

-- =====================================================
-- DATA QUALITY ASSESSMENT (DQA)
-- =====================================================

-- -----------------------------------------------------
-- CHECK FOR MISSING (NULL) VALUES
-- -----------------------------------------------------
SELECT
    *
FROM
    customer_shopping_data
WHERE
    invoice_no IS NULL
    OR customer_id IS NULL
    OR quantity IS NULL
    OR price IS NULL
    OR invoice_date IS NULL;

-- -----------------------------------------------------
-- CHECK FOR DUPLICATE INVOICE NUMBERS
-- -----------------------------------------------------
SELECT
    invoice_no,
    COUNT(*)
FROM
    customer_shopping_data
GROUP BY
    invoice_no
HAVING
    COUNT(*) > 1;

-- -----------------------------------------------------
-- DATE FORMAT & FUTURE DATE CHECK
-- -----------------------------------------------------
-- View unique invoice dates
SELECT
    DISTINCT invoice_date
FROM
    customer_shopping_data;

-- Check for future invoice dates
SELECT
    invoice_date
FROM
    customer_shopping_data
WHERE
    invoice_date > CURRENT_DATE;

-- -----------------------------------------------------
-- GENDER FORMATTING CHECK
-- -----------------------------------------------------
SELECT
    DISTINCT UPPER(TRIM(gender))
FROM
    customer_shopping_data;

-- -----------------------------------------------------
-- CATEGORY STANDARDIZATION CHECK
-- -----------------------------------------------------
SELECT
    DISTINCT UPPER(TRIM(category))
FROM
    customer_shopping_data;

-- -----------------------------------------------------
-- PAYMENT METHOD STANDARDIZATION CHECK
-- -----------------------------------------------------
SELECT
    DISTINCT UPPER(TRIM(payment_method))
FROM
    customer_shopping_data;

-- -----------------------------------------------------
-- CHECK FOR NEGATIVE VALUES (PRICE / QUANTITY)
-- -----------------------------------------------------
SELECT
    *
FROM
    customer_shopping_data
WHERE
    price < 0
    OR quantity < 0;

-- -----------------------------------------------------
-- CHECK FOR INVALID AGE RANGE
-- -----------------------------------------------------
SELECT
    *
FROM
    customer_shopping_data
WHERE 
    age < 0
    OR age > 100;

-- -----------------------------------------------------
-- OUTLIER DETECTION (PRICE)
-- -----------------------------------------------------
-- Identifies extreme values using 3*Standard Deviation
SELECT
    *
FROM
    customer_shopping_data
WHERE
    price > (
        SELECT
            AVG(price) + 3 * STDDEV(price)
        FROM
            customer_shopping_data
    );

-- =====================================================
-- DATA CLEANING & TRANSFORMATION
-- =====================================================

-- -----------------------------------------------------
-- DELETE RECORDS WITH NULL VALUES
-- -----------------------------------------------------
DELETE FROM
    customer_shopping_data
WHERE
    invoice_no IS NULL
    OR customer_id IS NULL
    OR quantity IS NULL
    OR price IS NULL
    OR invoice_date IS NULL;

-- -----------------------------------------------------
-- DELETE DUPLICATE INVOICE RECORDS
-- -----------------------------------------------------
DELETE FROM
    customer_shopping_data
WHERE
    invoice_no IN (
        SELECT
            invoice_no
        FROM
            customer_shopping_data
        GROUP BY
            invoice_no
        HAVING
            COUNT(*) > 1
    );

-- -----------------------------------------------------
-- STANDARDIZE TEXT FORMATTING
-- -----------------------------------------------------
UPDATE
    customer_shopping_data
SET
    GENDER = UPPER(TRIM(GENDER)),
    CATEGORY = UPPER(TRIM(CATEGORY)),
    payment_method = UPPER(TRIM(payment_method));

-- Normalize gender values (Male)
UPDATE
    customer_shopping_data
SET
    GENDER = 'MALE'
WHERE
    LOWER(GENDER) IN ('m', 'male');

-- Normalize gender values (Female)
UPDATE
    customer_shopping_data
SET
    gender = 'FEMALE'
WHERE
    LOWER(GENDER) IN ('f', 'female');

-- -----------------------------------------------------
-- DELETE INVALID AGE VALUES
-- -----------------------------------------------------
DELETE FROM
    customer_shopping_data
WHERE
    AGE < 0
    OR AGE > 100;

-- -----------------------------------------------------
-- DELETE NEGATIVE PRICE / QUANTITY VALUES
-- -----------------------------------------------------
DELETE FROM
    customer_shopping_data
WHERE
    price < 0
    OR quantity < 0;

-- -----------------------------------------------------
-- DELETE FUTURE DATED INVOICES
-- -----------------------------------------------------
DELETE FROM
    customer_shopping_data
WHERE
    invoice_date > CURRENT_DATE;

-- -----------------------------------------------------
-- DELETE PRICE OUTLIERS
-- -----------------------------------------------------
DELETE FROM
    customer_shopping_data
WHERE
    PRICE > (
        SELECT
            AVG(PRICE) + 3 * STDDEV(PRICE)
        FROM
            customer_shopping_data
    );

-- =====================================================
-- AGE TO DATE OF BIRTH (DOB) CONVERSION
-- =====================================================

-- Preview DOB calculation from age
SELECT
    AGE,
    CURRENT_DATE - (AGE || 'years') :: interval AS DOB
FROM
    customer_shopping_data;

-- Add DOB column
ALTER TABLE
    customer_shopping_data
ADD
    COLUMN DOB DATE;

-- Populate DOB column based on age
UPDATE
    customer_shopping_data
SET
    DOB = CURRENT_DATE - (AGE || 'years') :: interval;

-- Final cleaned dataset
SELECT
    *
FROM
    customer_shopping_data;


-- =====================================================
-- EXPORT CLEANED CUSTOMER SHOPPING DATA TO CSV FILE
-- =====================================================
-- This command exports the data from the
-- customer_shopping_data table into a CSV file
-- on the D: drive using comma as a delimiter
-- =====================================================

COPY customer_shopping_data
TO 'D:\\Clean_customer_shopping_data.csv'   -- Destination file path (CSV output file)
DELIMITER ','                           -- Use comma as column separator
CSV HEADER;                             -- Include column names in the first row

-- =====================================================
-- COMMIT TRANSACTION
-- =====================================================
-- Saves all changes permanently to the database
-- =====================================================

COMMIT;
