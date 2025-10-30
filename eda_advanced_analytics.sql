/*
==========================================================
Project: Retail Sales EDA & Advanced Analytics in SQL
Author: Kalandhar
Description:
  End-to-end SQL project covering data cleaning,
  exploratory data analysis (EDA), advanced analytics,
  segmentation, and customer-level reporting.
Database: MySQL
Notes:
  - This script is organized into sections with clear
    comments. Run sections independently as needed.
==========================================================
*/

-- =========================
-- DATABASE SETUP / CLEANING
-- =========================

-- Create / use EDA database
CREATE DATABASE IF NOT EXISTS EDA;
USE EDA;

-- Example: inspect raw table
SELECT * FROM orders_dataset;

-- Fix date format (example): convert d-m-Y to Y-m-d
SELECT STR_TO_DATE(order_date, '%d-%m-%Y') AS order_date_fixed
FROM orders_dataset
LIMIT 10;

UPDATE orders_dataset
SET order_date = DATE_FORMAT(STR_TO_DATE(order_date, '%d-%m-%Y'), '%Y-%m-%d')
WHERE order_date IS NOT NULL AND STR_TO_DATE(order_date, '%d-%m-%Y') IS NOT NULL;

-- Rename tables to standardized names (run when safe)
RENAME TABLE customers_dataset TO customers;
RENAME TABLE products_dataset TO products;
RENAME TABLE orders_dataset TO orders;

-- -------------------------
-- Basic Database Exploration
-- -------------------------

-- How many tables exist?
SHOW TABLES;

-- Describe table structures
DESCRIBE customers;
DESCRIBE orders;
DESCRIBE products;

-- Data types and nullability for a table
SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'orders' AND TABLE_SCHEMA = DATABASE();

SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'products' AND TABLE_SCHEMA = DATABASE();

SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'customers' AND TABLE_SCHEMA = DATABASE();

-- Count NULLs per column example (order_date)
SELECT COUNT(*) AS null_order_date
FROM orders
WHERE order_date IS NULL;

-- Check duplicate rows based on logical key (customer_id, order_id)
SELECT customer_id, order_id, COUNT(*) AS cnt
FROM orders
GROUP BY customer_id, order_id
HAVING cnt > 1;

-- Show duplicate rows
SELECT *
FROM orders
WHERE (customer_id, order_id) IN (
    SELECT customer_id, order_id
    FROM orders
    GROUP BY customer_id, order_id
    HAVING COUNT(*) > 1
)
ORDER BY order_id;

-- Show create table statements (to inspect primary/foreign keys)
SHOW CREATE TABLE orders;
SHOW CREATE TABLE customers;
SHOW CREATE TABLE products;

-- ---------------------------------------------
-- Dimensions Exploration (Categorical Columns)
-- ---------------------------------------------

-- Unique categories / regions / product ids
SELECT DISTINCT category FROM products;
SELECT DISTINCT region FROM customers;
SELECT DISTINCT product_id FROM orders;

-- Frequency of categories (most/least frequent)
SELECT category, COUNT(*) AS total_sales
FROM orders
NATURAL JOIN products
GROUP BY category
ORDER BY total_sales DESC;

-- ------------------
-- Date Exploration
-- ------------------

-- First and last order date, range in years/months
SELECT
  MIN(order_date) AS first_order,
  MAX(order_date) AS last_order,
  TIMESTAMPDIFF(YEAR, MIN(order_date), MAX(order_date)) AS order_range_years,
  TIMESTAMPDIFF(MONTH, MIN(order_date), MAX(order_date)) AS order_range_months
FROM orders;

-- Highest sales month with year
SELECT YEAR(order_date) AS year, MONTH(order_date) AS month, SUM(total_amount) AS total_sales
FROM orders
GROUP BY year, month
ORDER BY total_sales DESC
LIMIT 1;

-- Lowest sales month with year
SELECT YEAR(order_date) AS year, MONTH(order_date) AS month, SUM(total_amount) AS total_sales
FROM orders
GROUP BY year, month
ORDER BY total_sales
LIMIT 1;

-- -------------------------
-- Measures / KPI Exploration
-- -------------------------

-- Total sales
SELECT ROUND(SUM(total_amount)) AS total_sales FROM orders;

-- Total items sold
SELECT SUM(quantity) AS total_quantity FROM orders;

-- Average product price (from products table)
SELECT ROUND(AVG(price),2) AS avg_price FROM products;

-- Total number of orders (two variants)
SELECT COUNT(order_id) AS total_orders FROM orders;
SELECT COUNT(DISTINCT order_id) AS total_distinct_orders FROM orders;

-- Total number of products
SELECT COUNT(product_name) AS total_products FROM products;
SELECT COUNT(DISTINCT product_name) AS total_distinct_products FROM products;

-- Total number of customers
SELECT COUNT(customer_id) AS total_customers FROM customers;

-- Total number of customers who placed orders
SELECT COUNT(DISTINCT customer_id) AS customers_with_orders FROM orders;

-- Consolidated KPI report
SELECT 'total_sales' AS measure_name, ROUND(SUM(total_amount)) AS value FROM orders
UNION ALL
SELECT 'total_quantity', SUM(quantity) FROM orders
UNION ALL
SELECT 'avg_price', ROUND(AVG(price),2) FROM products
UNION ALL
SELECT 'total_distinct_orders', COUNT(DISTINCT order_id) FROM orders
UNION ALL
SELECT 'total_distinct_products', COUNT(DISTINCT product_name) FROM products
UNION ALL
SELECT 'total_customers', COUNT(customer_id) FROM customers
UNION ALL
SELECT 'customers_with_orders', COUNT(DISTINCT customer_id) FROM orders;

-- ------------------------
-- Magnitude / Comparison
-- ------------------------

-- Total customers by region
SELECT region, COUNT(customer_id) AS total_customers
FROM customers
GROUP BY region
ORDER BY total_customers DESC;

-- Total products by category
SELECT category, COUNT(product_id) AS total_products
FROM products
GROUP BY category
ORDER BY total_products DESC;

-- Average cost (price) by category
SELECT category, ROUND(AVG(price),2) AS avg_cost
FROM products
GROUP BY category
ORDER BY avg_cost DESC;

-- Total revenue by category
SELECT category, ROUND(SUM(total_amount),2) AS total_revenue
FROM orders
NATURAL JOIN products
GROUP BY category
ORDER BY total_revenue DESC;

-- Total revenue by customer
SELECT customer_id, customer_name, ROUND(SUM(total_amount),2) AS total_revenue
FROM customers
NATURAL JOIN orders
GROUP BY customer_id, customer_name
ORDER BY total_revenue DESC;

-- Distribution of items sold across regions
SELECT region, SUM(quantity) AS total_sold_items
FROM customers
NATURAL JOIN orders
GROUP BY region
ORDER BY total_sold_items DESC;

-- ----------------
-- Ranking Analysis
-- ----------------

-- Top 5 products by revenue
SELECT product_name, SUM(total_amount) AS total_revenue,
  DENSE_RANK() OVER (ORDER BY SUM(total_amount) DESC) AS rank_products
FROM products
NATURAL JOIN orders
GROUP BY product_name
ORDER BY total_revenue DESC
LIMIT 5;

-- Bottom 5 products by revenue
SELECT product_id, SUM(total_amount) AS total_revenue,
  DENSE_RANK() OVER (ORDER BY SUM(total_amount) ASC) AS rank_products
FROM products
NATURAL JOIN orders
GROUP BY product_id
ORDER BY total_revenue ASC
LIMIT 5;

-- Top 10 customers by revenue
SELECT c.customer_id, c.customer_name, SUM(o.total_amount) AS revenue,
  RANK() OVER (ORDER BY SUM(o.total_amount) DESC) AS ranks
FROM customers AS c
JOIN orders AS o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
ORDER BY revenue DESC
LIMIT 10;

-- Bottom 3 customers by number of orders
SELECT customer_name, COUNT(order_id) AS total_orders,
  ROW_NUMBER() OVER (ORDER BY COUNT(order_id)) AS ranks
FROM customers
NATURAL JOIN orders
GROUP BY customer_name
ORDER BY total_orders ASC
LIMIT 3;

-- =====================
-- ADVANCED ANALYTICS DB
-- =====================

CREATE DATABASE IF NOT EXISTS advanced_analytics;
USE advanced_analytics;

-- Example conversions and renames for advanced dataset (gold schema)
SELECT STR_TO_DATE(order_date, '%d-%m-%Y') AS order_date_fixed
FROM `gold.fact_sales`
LIMIT 10;

UPDATE `gold.fact_sales`
SET order_date = DATE_FORMAT(STR_TO_DATE(order_date, '%d-%m-%Y'), '%Y-%m-%d')
WHERE order_date IS NOT NULL AND STR_TO_DATE(order_date, '%d-%m-%Y') IS NOT NULL;

ALTER TABLE `gold.fact_sales`
MODIFY COLUMN order_date DATE;

UPDATE `gold.fact_sales`
SET order_date = NULL
WHERE order_date = '' OR order_date = '0000-00-00';

-- Rename gold schema tables to standardized names (run as needed)
RENAME TABLE `gold.dim_products` TO products;
RENAME TABLE `gold.fact_sales` TO sales;
RENAME TABLE `gold.dim_customers` TO customers;

-- -------------------------
-- Changes Over Time (Trends)
-- -------------------------

-- Sales performance over years
SELECT
  YEAR(order_date) AS order_year,
  COUNT(DISTINCT customer_key) AS total_customer,
  SUM(quantity) AS total_quantity,
  SUM(sales_amount) AS total_revenue
FROM sales
WHERE YEAR(order_date) IS NOT NULL
GROUP BY YEAR(order_date)
ORDER BY YEAR(order_date);

-- Seasonality: month-level
SELECT
  YEAR(order_date) AS order_year,
  MONTH(order_date) AS order_month,
  COUNT(DISTINCT customer_key) AS total_customer,
  SUM(quantity) AS total_quantity,
  SUM(sales_amount) AS total_revenue
FROM sales
WHERE YEAR(order_date) IS NOT NULL
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY YEAR(order_date), MONTH(order_date);

-- --------------------
-- Cumulative Analysis
-- --------------------

-- Monthly total sales and running total
SELECT order_month, total_sales,
  SUM(total_sales) OVER (ORDER BY order_month) AS running_total
FROM (
  SELECT DATE_FORMAT(order_date, '%Y-%m') AS order_month, SUM(sales_amount) AS total_sales
  FROM sales
  WHERE YEAR(order_date) IS NOT NULL
  GROUP BY DATE_FORMAT(order_date, '%Y-%m')
) t
ORDER BY order_month;

-- --------------------
-- Performance Analysis
-- --------------------

WITH monthly_product_sales AS (
  SELECT
    DATE_FORMAT(order_date, '%Y-%m') AS order_month,
    p.product_name,
    SUM(s.sales_amount) AS current_sales
  FROM sales AS s
  LEFT JOIN products AS p ON s.product_key = p.product_key
  WHERE p.product_name IS NOT NULL
  GROUP BY DATE_FORMAT(order_date, '%Y-%m'), p.product_name
)
SELECT
  order_month,
  product_name,
  current_sales,
  AVG(current_sales) OVER (PARTITION BY product_name) AS avg_sales,
  current_sales - AVG(current_sales) OVER (PARTITION BY product_name) AS avg_diff,
  CASE 
    WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) > 0 THEN 'above avg'
    WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) < 0 THEN 'below avg'
    ELSE 'avg'
  END AS avg_change,
  LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_month) AS pm_sales,
  CASE 
    WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_month) > 0 THEN 'increasing'
    WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_month) < 0 THEN 'decreasing'
    ELSE 'no change'
  END AS pm_change
FROM monthly_product_sales
ORDER BY product_name, order_month;

-- ---------------------------------
-- Part-to-Whole Analysis (Proportions)
-- ---------------------------------

WITH category_sales AS (
  SELECT p.category, SUM(s.sales_amount) AS total_sales
  FROM products AS p
  JOIN sales AS s ON p.product_key = s.product_key
  GROUP BY p.category
)
SELECT
  category,
  total_sales,
  SUM(total_sales) OVER () AS overall_sales,
  ROUND((total_sales / SUM(total_sales) OVER ()) * 100, 2) AS percentage_of_total
FROM category_sales
ORDER BY total_sales DESC;

-- ------------------
-- Data Segmentation
-- ------------------

-- Segment products into cost ranges
WITH product_segment AS (
  SELECT product_key, product_name, cost,
    CASE
      WHEN cost < 100 THEN 'below 100'
      WHEN cost BETWEEN 100 AND 500 THEN '100-500'
      WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
      ELSE 'above 1000'
    END AS cost_segment
  FROM products
)
SELECT cost_segment, COUNT(product_name) AS count_products
FROM product_segment
GROUP BY cost_segment
ORDER BY cost_segment DESC;

-- Customer segmentation based on spending & lifespan
WITH customer_spends AS (
  SELECT c.customer_key,
    SUM(s.sales_amount) AS total_spending,
    MIN(order_date) AS first_order,
    MAX(order_date) AS last_order,
    TIMESTAMPDIFF(MONTH, MIN(order_date), MAX(order_date)) AS life_span
  FROM customers AS c
  JOIN sales AS s ON c.customer_key = s.customer_key
  GROUP BY c.customer_key
)
SELECT cus_seg, COUNT(customer_key) AS total_customer
FROM (
  SELECT customer_key,
    CASE
      WHEN life_span >= 12 AND total_spending >= 5000 THEN 'VIP'
      WHEN life_span >= 12 AND total_spending <= 4000 THEN 'REGULAR'
      ELSE 'NEW'
    END AS cus_seg
  FROM customer_spends
) t
GROUP BY cus_seg
ORDER BY total_customer DESC;

-- ------------
-- Reporting
-- ------------

/*
Customer Report
Purpose:
 - Consolidates key customer metrics and behaviors
Highlights:
 1. Essential fields: name, lifespan, transactions
 2. Segments customers into VIP / REGULAR / NEW
 3. Aggregates metrics: total orders, total sales, total quantity, total products, lifespan
 4. KPIs: recency, average order value, average monthly spend
*/

WITH base_query AS (
  SELECT
    o.order_number,
    o.customer_key,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.customer_number,
    o.product_key,
    o.order_date,
    o.sales_amount,
    o.quantity
  FROM sales o
  JOIN customers c ON o.customer_key = c.customer_key
  JOIN products p ON o.product_key = p.product_key
),
customer_segmentation AS (
  SELECT
    customer_key,
    customer_number,
    customer_name,
    COUNT(DISTINCT order_number) AS total_orders,
    SUM(sales_amount) AS total_sales,
    SUM(quantity) AS total_quantity,
    COUNT(DISTINCT product_key) AS total_products,
    MAX(order_date) AS last_order_date,
    TIMESTAMPDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan
  FROM base_query
  GROUP BY customer_key, customer_number, customer_name
)
SELECT
  customer_key,
  customer_number,
  customer_name,
  CASE
    WHEN lifespan >= 12 AND total_sales >= 5000 THEN 'VIP'
    WHEN lifespan >= 12 AND total_sales <= 4000 THEN 'REGULAR'
    ELSE 'NEW'
  END AS cus_seg,
  last_order_date,
  TIMESTAMPDIFF(MONTH, last_order_date, CURDATE()) AS recency,
  total_orders,
  total_sales,
  total_quantity,
  total_products,
  lifespan,
  CASE WHEN total_orders = 0 THEN 0 ELSE total_sales / total_orders END AS avg_order_value,
  CASE WHEN lifespan = 0 THEN total_sales ELSE total_sales / lifespan END AS avg_monthly_spend
FROM customer_segmentation
ORDER BY total_sales DESC;

-- Example: create a view for the report (optional)
-- CREATE VIEW report_customers AS <above SELECT statement>;

-- To preview report view
-- SELECT * FROM report_customers LIMIT 100;

/* End of script */
