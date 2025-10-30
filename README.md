# 📊 EDA & Analytics Project

## 🧾 Overview
This project presents a **comprehensive collection of SQL scripts** for data exploration, analytics, and reporting.  
The analyses include **database exploration, measure evaluation, time-based trends, cumulative analytics, segmentation**, and more.

The repository is designed to help **Data Analysts** and **BI Professionals** efficiently explore, segment, and analyze data within a relational database.

Each SQL script focuses on a specific analytical theme and demonstrates **best practices** for query design and optimization.

---

## 🧩 Dataset

This project uses three primary tables:

### 1. `Customers`
| Column | Description |
|---------|-------------|
| customer_key | Unique key for each customer |
| customer_id | Internal customer ID |
| customer_number | External customer reference |
| first_name | Customer’s first name |
| last_name | Customer’s last name |
| country | Country of residence |
| marital_status | Marital status of the customer |
| gender | Gender of the customer |
| birthdate | Date of birth |
| create_date | Account creation date |

---

### 2. `Sales`
| Column | Description |
|---------|-------------|
| order_number | Unique order number |
| product_key | Foreign key to product table |
| customer_key | Foreign key to customer table |
| order_date | Date when the order was placed |
| shipping_date | Date when the order was shipped |
| due_date | Expected delivery date |
| sales_amount | Total order value |
| quantity | Quantity ordered |
| price | Unit price of the product |

---

### 3. `Products`
| Column | Description |
|---------|-------------|
| product_key | Unique product key |
| product_id | Internal product ID |
| product_number | Product code/number |
| product_name | Name of the product |
| category_id | Category identifier |
| category | Product category |
| subcategory | Product subcategory |
| maintenance_cost | Cost of maintaining the product |
| product_line | Product line classification |
| start_date | Date when the product was introduced |

---

## 🔄 Project Flow: Data Analytics Process

This project follows a **structured Data Analytics Workflow**, divided into two key phases:  
**Exploratory Data Analysis (EDA)** and **Advanced Analytics**.

### **1. Exploratory Data Analysis (EDA)**
Focuses on understanding the dataset, identifying patterns, and uncovering key data characteristics.

Includes the following steps:
- Database Exploration  
- Dimensions Exploration  
- Date Exploration  
- Measures Exploration  
- Magnitude Analysis  
- Ranking (**Top N / Bottom N**)

---

### **2. Advanced Analytics**
Derives deeper insights and evaluates performance through analytical methods.

Covers:
- Change-Over-Time (**Trends**)  
- Cumulative Analysis  
- Performance Analysis  
- Part-to-Whole (**Proportional**) Analysis  
- Data Segmentation  
- Reporting  

---

## 🛠️ Tools and Skills Used

### **Tools**
- **Microsoft Excel** – used for initial data cleaning, validation, and exploratory data analysis.  
- **SQL** – extensively used for data extraction, transformation, and advanced analytical queries.

### **Skills & Techniques**
- Data validation and quality checks  
- SQL fundamentals and advanced concepts, including:
  - `SELECT`, `WHERE`, `GROUP BY`, `ORDER BY`  
  - `JOINS` and `VIEWS`  
  - Subqueries and `CASE WHEN` statements  
  - Common Table Expressions (**CTEs**)  
  - Window functions  
  - Proportional and performance analysis  

---

## 📁 Additional Information
For detailed queries and execution results, please refer to the **Queries and Answers** file located in the project folder.

---

### 👨‍💻 Author
**Kalandhar**

---

### 🧱 Repository Tags
`#SQL` `#EDA` `#DataAnalytics` `#BI` `#DataExploration` `#SQLProjects`

