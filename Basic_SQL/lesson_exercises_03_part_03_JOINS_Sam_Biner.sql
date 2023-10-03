-- SalesOrders Database
USE SalesOrders;
-- INNER JOINS


-- 01 - List customers and the dates they placed an order
SELECT CustFirstName,
	CustLastName,
	OrderDate
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID;


-- 02 - Show me customers and employees who share the same last name
SELECT CustFirstName,
	CustLastName,
	EmpFirstName,
	EmpLastName
FROM Customers c
JOIN Employees e ON CustLastName = EmpLastName;


-- 03 - Show me customers and employees who live in the same city
SELECT c.CustFirstName,
	c.CustLastName,
	e.EmpFirstName,
	e.EmpLastName,
	CustCity
FROM Customers c
JOIN Employees e ON CustCity = EmpCity;


-- 04 - Generate a list of employees and the customers for whom they booked an order
SELECT e.EmployeeID, c.CustomerID
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID 
JOIN Employees e ON o.EmployeeID = e.EmployeeID
GROUP BY e.EmployeeID, c.CustomerID;


-- 05 - Display all orders with the order date, the products in each order, and the amount owed for each product, in order number sequence
SELECT o.OrderNumber,
	o.OrderDate,
	p.ProductName,
	(od.QuotedPrice * od.QuantityOrdered) AS AmountOwed
FROM Products p 
JOIN Order_Details od ON p.ProductNumber = od.ProductNumber 
JOIN Orders o ON od.OrderNumber = o.OrderNumber 
ORDER BY o.OrderNumber;


-- 06 - Show me the vendors and the products they supply to us for products that have a wholesale price under $100. Sort by the vendor name then the wholesale price.
SELECT v.VendName, p.ProductName, pv.WholesalePrice
FROM Vendors v 
JOIN Product_Vendors pv ON v.VendorID = pv.VendorID 
JOIN Products p ON pv.ProductNumber = p.ProductNumber
WHERE WholesalePrice < 100
ORDER BY v.VendName, pv.WholesalePrice;


-- 07 - Display customer names who have a sales rep (employees) in the same ZIP Code. Include the employee name.
SELECT CustFirstName,
	CustLastName,
	EmpFirstName,
	EmpLastName,
	EmpZipCode
FROM Customers c
JOIN Employees e ON CustZipCode = EmpZipCode;


-- LEFT JOINS

-- 08 - Display customers who do NOT have a sales rep (employees) in the same ZIP Code
SELECT CustFirstName,
	CustLastName,
	EmpFirstName,
	EmpLastName,
	EmpZipCode
FROM Customers c
LEFT JOIN Employees e ON c.CustZipCode = e.EmpZipCode
WHERE e.EmpZipCode IS NULL;


-- 09 - Are there any products that have never been ordered?
SELECT p.ProductNumber, 
	p.ProductName,
	od.OrderNumber
FROM Products p 
LEFT JOIN Order_Details od ON p.ProductNumber = od.ProductNumber
WHERE od.OrderNumber IS NULL;



-- sakila Database
CREATE DATABASE sakila;
SHOW DATABASES;
USE sakila;
-- INNER JOINS

-- 10 - What country is the city based in?
SELECT city,
	country
FROM city c 
JOIN country c2 ON c.country_id  = c2.country_id;


-- 11 - What language is spoken in each film?
-- Try this on your own before watching the video solution.
SELECT film_id,
	title,
	name
FROM film f
JOIN language l ON f.language_id = l.language_id;


-- 12 - List all film titles and their category (genre)
SELECT title AS FilmTitle,
	name AS CategoryName
FROM film f 
JOIN film_category fc ON f.film_id = fc.film_id
JOIN category c ON fc.category_id = c.category_id;


-- 13 - Create an email list of Canadian customers
SELECT c.email, 
	c3.country
FROM customer c 
	JOIN address a ON c.address_id = a.address_id
	JOIN city c2 ON a.city_id = c2.city_id
	JOIN country c3 ON c2.country_id = c3.country_id
WHERE c3.country = "Canada";


-- 14 - How much rental revenue has each customer generated? In other words, what is the SUM rental payment amount for each customer ordered by the SUM amount from high to low?
SELECT c.first_name,
	c.last_name,
	SUM(amount) AS RentalRevenuePerCustomer
FROM customer c
JOIN payment p ON c.customer_id = p.customer_id
GROUP BY c.customer_id
ORDER BY SUM(amount) DESC;


-- 15 - How many cities are associated to each country? Filter the results to countries with at least 10 cities.
SELECT c1.country,
	COUNT(c.city_id) AS CityCount
FROM city c 
	JOIN country c1 ON c.country_id = c1.country_id
GROUP BY c1.country_id 
HAVING COUNT(c.city_id) >= 10
ORDER BY COUNT(c.city_id) DESC;



-- LEFT JOINS

-- 16 - Which films do not have an actor?
-- Try this on your own before watching the video solution.
SELECT title,
	actor_id
FROM film f 
LEFT JOIN film_actor fa ON f.film_id = fa.film_id
WHERE fa.actor_id IS NULL;

-- 17 - Which comedies are not in inventory?
SELECT f.title,
	c.name,
	i.inventory_id
FROM film f 
LEFT JOIN inventory i ON f.film_id = i.film_id
LEFT JOIN film_category fc ON f.film_id = fc.film_id
LEFT JOIN category c ON fc.category_id = c.category_id
WHERE c.name = "Comedy" AND i.inventory_id IS NULL;

-- 18 - Generate a list of never been rented films
SELECT f.title,
	i.inventory_id,
	r.rental_id
FROM film f 
JOIN inventory i ON f.film_id = i.film_id
LEFT JOIN rental r ON i.inventory_id = r.inventory_id
WHERE r.rental_id IS NULL;

