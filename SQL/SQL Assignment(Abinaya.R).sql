-- Q1. SELECT clause with WHERE, AND, DISTINCT, Wild Card (LIKE)
-- (a)
SELECT employeenumber, firstname, lastname
FROM employees
WHERE jobtitle = 'Sales Rep'
  AND reportsto = 1102;

-- (b)
SELECT DISTINCT productline
FROM products
WHERE productline LIKE '%cars';

-- Q2. CASE STATEMENTS for Segmentation
-- a. Using a CASE statement, segment customers into three categories based on their country

SELECT 
  customerNumber, 
  customerName,
  CASE 
    WHEN country IN ('USA', 'Canada') THEN 'North America'
    WHEN country IN ('UK', 'France', 'Germany') THEN 'Europe'
    ELSE 'Other'
  END AS CustomerSegment
FROM customers;

-- Q3. Group By with Aggregation functions and Having clause, Date and Time functions
-- (a) Using the OrderDetails table, identify the top 10 products (by productCode) with the highest total order quantity across all orders.
SELECT 
  productCode, 
  SUM(quantityOrdered) AS totalQuantity
FROM OrderDetails
GROUP BY productCode
ORDER BY totalQuantity DESC
LIMIT 10;

-- (b).Company wants to analyse payment frequency by month. Extract the month name from the payment date to count the total number of payments for each month and include only those months with a payment count exceeding 20.
--  Sort the results by total number of payments in descending order.  

SELECT 
  MONTHNAME(paymentDate) AS Month,
  COUNT(*) AS totalPayments
FROM Payments
GROUP BY MONTH(paymentDate), MONTHNAME(paymentDate)
HAVING COUNT(*) > 20
ORDER BY totalPayments DESC;


-- Q4. CONSTRAINTS: Primary, key, foreign key, Unique, check, not null, default
-- Create a new database named and Customers_Orders and add the following tables as per the description
-- a.	Create a table named Customers to store customer information. Include the following columns:

CREATE DATABASE Customers_Orders;
USE Customers_Orders;
CREATE TABLE Customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(255) UNIQUE,
    phone_number VARCHAR(20)
);

-- b.	Create a table named Orders to store information about customer orders. Include the following columns:

CREATE TABLE Orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    total_amount DECIMAL(10, 2),
    CONSTRAINT fk_customer
        FOREIGN KEY (customer_id)
        REFERENCES Customers(customer_id),
    CONSTRAINT chk_total_amount
        CHECK (total_amount > 0)
);

-- Q5. JOINS
-- a. List the top 5 countries (by order count) that Classic Models ships to. (Use the Customers and Orders tables)

SELECT 
  c.country,
  COUNT(o.orderNumber) AS order_count
FROM Customers c
JOIN Orders o ON c.customerNumber = o.customerNumber
GROUP BY c.country
ORDER BY order_count DESC
LIMIT 5;

-- Q6. SELF JOIN
-- a. Create a table project with below fields.

CREATE TABLE project (
    EmployeeID INT AUTO_INCREMENT PRIMARY KEY,
    FullName VARCHAR(50) NOT NULL,
    Gender ENUM('Male', 'Female') NOT NULL,
    ManagerID INT,
    FOREIGN KEY (ManagerID) REFERENCES project(EmployeeID)
);

INSERT INTO project (FullName, Gender, ManagerID) VALUES
('Preety', 'Female', NULL);
INSERT INTO project (FullName, Gender, ManagerID) VALUES
('Pranaya', 'Male', 1); 
INSERT INTO project (FullName, Gender, ManagerID) VALUES
('Priyanka', 'Female', 2),
('Anurag', 'Male', 2),
('Sambit', 'Male', 2); 
INSERT INTO project (FullName, Gender, ManagerID) VALUES
('Rajesh', 'Male', 1),
('Hina', 'Female', 1);

SELECT 
    m.FullName AS "Manager Name",
    e.FullName AS "Emp Name"
FROM 
    project e
JOIN 
    project m ON e.ManagerID = m.EmployeeID;

CREATE TABLE facility (
    Facility_ID INT,
    Name VARCHAR(100),
    State VARCHAR(100),
    Country VARCHAR(100)
);

-- Q7. DDL Commands: Create, Alter, Rename

ALTER TABLE facility
MODIFY Facility_ID INT AUTO_INCREMENT PRIMARY KEY;

ALTER TABLE facility
ADD COLUMN City VARCHAR(100) NOT NULL AFTER Name;

select * from facility;
desc facility;

-- Q8. Views in SQL
CREATE VIEW product_category_sales AS
SELECT
    pl.productLine,
    SUM(od.quantityOrdered * od.priceEach) AS total_sales,
    COUNT(DISTINCT od.orderNumber) AS number_of_orders
FROM
    productlines pl
JOIN
    products p ON pl.productLine = p.productLine
JOIN
    orderdetails od ON p.productCode = od.productCode
GROUP BY
    pl.productLine;
SELECT * FROM product_category_sales;

-- Q9. Stored Procedures in SQL with parameters

call classicmodels.Get_country_payments(2003, 'France');

-- Q10. Window functions - Rank, dense_rank, lead and lag

SELECT 
    c.customerName,
    COUNT(o.orderNumber) AS order_count,
    RANK() OVER (ORDER BY COUNT(o.orderNumber) DESC) AS order_frequency_rank
FROM 
    customers c
JOIN 
    orders o ON c.customerNumber = o.customerNumber
GROUP BY 
    c.customerNumber, c.customerName
ORDER BY 
    order_frequency_rank;
    
-- B.Calculate year wise, month name wise count of orders and year over year (YoY) percentage change. Format the YoY values in no decimals and show in % sign.

SELECT
    YEAR(orderDate) AS order_year,
    MONTHNAME(orderDate) AS order_month,
    COUNT(orderNumber) AS order_count,
    CONCAT(
        ROUND(
            (COUNT(orderNumber) - LAG(COUNT(orderNumber)) OVER (
                ORDER BY YEAR(orderDate), MONTH(orderDate)
            )) * 100.0 /
            LAG(COUNT(orderNumber)) OVER (
                ORDER BY YEAR(orderDate), MONTH(orderDate)
            ), 0
        ), '%'
    ) AS YoY_change
FROM
    orders
GROUP BY
    YEAR(orderDate), MONTH(orderDate)
ORDER BY
    YEAR(orderDate), MONTH(orderDate);

-- Subqueries and their applications

SELECT 
    productLine, 
    COUNT(*) AS product_count
FROM 
    products
WHERE 
    buyPrice > (SELECT AVG(buyPrice) FROM products)
GROUP BY 
    productLine;

-- Q12. ERROR HANDLING in SQL

CREATE TABLE Emp_EH (
    EmpID INT PRIMARY KEY,
    EmpName VARCHAR(100),
    EmailAddress VARCHAR(100)
);

call classicmodels.InsertIntoEmp_EH(1076, 'Firrelli', 'jfirrelli@classicmodelcars.com');
call classicmodels.InsertIntoEmp_EH(1000, 'harry', 'harry@classicmoodelcars.com');
select * from Emp_EH;

CREATE TABLE Emp_BIT (
    Name VARCHAR(50),
    Occupation VARCHAR(50),
    Working_date DATE,
    Working_hours INT
);

INSERT INTO Emp_BIT VALUES
('Robin', 'Scientist', '2020-10-04', 12),  
('Warner', 'Engineer', '2020-10-04', 10),  
('Peter', 'Actor', '2020-10-04', 13),  
('Marco', 'Doctor', '2020-10-04', 14),  
('Brayden', 'Teacher', '2020-10-04', 12),  
('Antonio', 'Business', '2020-10-04', 11);

SELECT * FROM classicmodels.emp_bit;

-- Test with Negative Values
INSERT INTO Emp_BIT VALUES ('TestUser', 'Tester', '2020-10-04', -8);
