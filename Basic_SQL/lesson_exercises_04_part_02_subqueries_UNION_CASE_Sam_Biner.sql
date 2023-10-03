-- SalesOrders database
USE SalesOrders;
-- Subqueries

/*
01 - Are there any products that have never been ordered? 
	 Only use a subquery and no JOINs.
*/
SELECT ProductNumber, 
	ProductName
FROM Products
WHERE ProductNumber NOT IN (
	SELECT ProductNumber 
	FROM Order_Details
);


/*
02 - Show me customers who have never ordered a helmet
*/
SELECT CustFirstName, CustLastName
FROM Customers
WHERE CustomerID NOT IN (
	SELECT CustomerID
    FROM Orders
    WHERE OrderNumber IN (
    	SELECT OrderNumber
        FROM Order_Details
        WHERE ProductNumber IN (
        	SELECT ProductNumber
            FROM Products
            WHERE CategoryID = 1
        )
    )
);

-- UNION

/*
03.01 - Build a single mailing list that consists of the full name,
		address, city, state, and ZIP Code for customers and employees
03.02 - Alias the columns in the first SELECT to standardize the column names
03.03 - Identify the type of user for each row by adding a string 
		in single quotes to the SELECT field list
*/
-- 3.01:
SELECT CustFirstName, 
	CustLastName, 
	CustStreetAddress, 
	CustCity, 
	CustState, 
	CustZipCode
FROM Customers
UNION
SELECT EmpFirstName, 
	EmpLastName, 
	EmpStreetAddress, 
	EmpCity, 
	EmpState, 
	EmpZipCode
FROM Employees;

-- 3.02:
SELECT CustFirstName AS FirstName, 
	CustLastName AS LastName, 
	CustStreetAddress AS StreetAddress, 
	CustCity AS City, 
	CustState AS State, 
	CustZipCode AS ZipCode 
FROM Customers
UNION
SELECT EmpFirstName, 
	EmpLastName, 
	EmpStreetAddress,
	EmpCity,
	EmpState,
	EmpZipCode
FROM Employees;

-- 3.03:
SELECT 'Customer' AS UserType, 
	CustFirstName, 
	CustLastName, 
	CustStreetAddress, 
	CustCity, 
	CustState, 
	CustZipCode
FROM Customers
UNION
SELECT 'Employee', 
	EmpFirstName, 
	EmpLastName, 
	EmpStreetAddress, 
	EmpCity,
	EmpState,
	EmpZipCode
FROM Employees;



/*
04.01 - Build a single mailing list that consists of the name, 
		address, city, state, and ZIP Code for customers, employees, and vendors
04.02 - Sort by the state
04.03 - Only include if they are from TX
*/

-- 4.01:
SELECT CustFirstName, 
	CustStreetAddress, 
	CustCity, 
	CustState, 
	CustZipCode
FROM Customers
UNION
SELECT EmpFirstName, 
	EmpStreetAddress, 
	EmpCity, 
	EmpState, 
	EmpZipCode
FROM Employees
UNION
SELECT VendName, 
	VendStreetAddress, 
	VendCity, 
	VendState, 
	VendZipCode
FROM Vendors;

-- 4.02: 
SELECT CustFirstName AS Name, 
	CustStreetAddress AS StreetAddress, 
	CustCity AS City, 
	CustState AS State, 
	CustZipCode AS ZipCode
FROM Customers
UNION
SELECT EmpFirstName, 
	EmpStreetAddress, 
	EmpCity, 
	EmpState, 
	EmpZipCode
FROM Employees
UNION
SELECT VendName, 
	VendStreetAddress, 
	VendCity, 
	VendState, 
	VendZipCode
FROM Vendors
ORDER BY State;

-- 4.03:
SELECT CustFirstName,
	CustStreetAddress, 
	CustCity, 
	CustState, 
	CustZipCode
FROM Customers
WHERE CustState = 'TX'
UNION
SELECT EmpFirstName, 
	EmpStreetAddress, 
	EmpCity, 
	EmpState, 
	EmpZipCode
FROM Employees
WHERE EmpState = 'TX'
UNION
SELECT VendName, 
	VendStreetAddress, 
	VendCity, 
	VendState, 
	VendZipCode
FROM Vendors
WHERE VendState = 'TX'
ORDER BY CustState;



/*
05.01 - List the customers who ordered a King Cobra Helmet 
		together with the vendors who provide the King Cobra Helmet
05.02 - Identify the user type
05.03 - Sort results to display vendors on top
*/
-- 5.01:
SELECT c.CustFirstName, 
	c.CustLastName, 
	v.VendName
FROM 
	Customers c, 
	Orders o,
	Order_Details od,
	Vendors v,
	Products p, 
	Product_Vendors pv
WHERE c.CustomerID = o.CustomerID
	AND o.OrderNumber = od.OrderNumber
	AND od.ProductNumber = p.ProductNumber
	AND p.ProductNumber = pv.ProductNumber
	AND p.ProductName = 'King Cobra Helmet';

-- 5.02:
SELECT 
	c.CustFirstName AS Name, 
	c.CustLastName AS LastName, 
	'Customer' AS UserType
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
JOIN Order_Details od ON o.OrderNumber = od.OrderNumber 
JOIN Products p ON od.ProductNumber = p.ProductNumber
JOIN Product_Vendors pv ON p.ProductNumber = pv.ProductNumber 
JOIN Vendors v ON pv.VendorID = v.VendorID
WHERE p.ProductName = 'King Cobra Helmet'
UNION
SELECT
	v.VendName, 
	'', 
	'Vendor'
FROM Vendors v
JOIN Product_Vendors pv2 ON v.VendorID = pv2.VendorID 
JOIN Products p2 ON pv2.ProductNumber = p2.ProductNumber 
WHERE p2.ProductName = 'King Cobra Helmet'
ORDER BY UserType DESC;





-- Switch to the sakila database
USE sakila;

-- CASE

/*
06 - List the customer_id, first_name, last_name, and email 
	 for all customers and denote if they are active or inactive 
 	 with a text expression instead of a 1 or 0 from the active column.
*/
SELECT customer_id, 
	first_name, 
	last_name, 
	email, 
	IF(active = 1, 'Active', 'Inactive') AS active
FROM customer;


/*
07 - Categorize films based on rental duration length. 
	 SELECT the title, rental_duration, and the duration label.
	 Duration labels:
		short: < 4 days
		medium: BETWEEN 4 AND 6 days
		long: > 6 days
 */
SELECT title, rental_duration,
	CASE
		WHEN rental_duration < 4 THEN 'short'
		WHEN rental_duration BETWEEN 4 AND 6 THEN 'medium'
		ELSE 'long'
	END AS duration_label
FROM film;



/*
08 - Display film titles, # of times a film was rented, 
	 and a rental ranking text label based on the number of rentals:
	 poor: < 10 rentals
	 average: 10 - 19 rentals
	 good: 20 - 30 rentals
	 excellent: > 30 rentals or everything ELSE
*/
SELECT title, 
	COUNT(rental_id) AS rentals, 
	CASE
		WHEN COUNT(rental_id) < 10 THEN 'poor'
		WHEN COUNT(rental_id) BETWEEN 10 AND 19 THEN 'average'
		WHEN COUNT(rental_id) BETWEEN 20 AND 30 THEN 'good'
		ELSE 'excellent'
	END AS rental_ranking
FROM film
JOIN inventory 
	ON film.film_id = inventory.film_id
JOIN rental 
	ON inventory.inventory_id = rental.inventory_id
GROUP BY title
ORDER BY rentals DESC;



/*
09 - What is the total replacement cost per rating and rental rate? 
Display the results in 3 ways:
1. rating | rental_rate | total_replacement_cost
2. rental_rate | rating | total_replacement_cost
3. rating | 0.99_replacement_cost | 2.99_replacement_cost | 4.99_replacement_cost
*/
-- 9.1:
SELECT rating,
	rental_rate,
	COUNT(*) AS CountOfFilms,
	SUM(replacement_cost) AS total_replacement_cost
FROM film f
JOIN inventory i ON f.film_id = i.film_id
GROUP BY rating, 
	rental_rate
WITH ROLLUP;


-- 9.2:
SELECT rental_rate,
	rating,
	COUNT(*) AS CountOfFilms,
	SUM(replacement_cost) AS total_replacement_cost
FROM film f
JOIN inventory i ON f.film_id = i.film_id
GROUP BY rating, 
	rental_rate
WITH ROLLUP;

-- 9.3:
SELECT 
	CASE 
		WHEN rating IS NULL THEN 'Total'
		ELSE rating
	END AS report_rating,
	SUM(
		CASE 
			WHEN rental_rate = 0.99 THEN replacement_cost
		END
	) AS '0.99_replacement_cost',
	SUM(
		CASE 
			WHEN rental_rate = 2.99 THEN replacement_cost
		END
	) AS '2.99_replacement_cost',
	SUM(
		CASE 
			WHEN rental_rate = 4.99 THEN replacement_cost
		END
	) AS '4.99_replacement_cost'
FROM film f 
JOIN inventory i ON f.film_id = i.film_id 
GROUP BY rating
WITH ROLLUP;



-- 10 - Label if a film at the $4.99 rental rate was rented in June 2005.
-- Initial Query
SELECT f.film_id,
	title,
	rental_rate,
	rental_date
FROM film f 
JOIN inventory i ON f.film_id = i.inventory_id 
JOIN rental r ON i.inventory_id = r.inventory_id
WHERE rental_rate = 4.99
	AND rental_date BETWEEN '2005-06-01' AND '2005-06-30 23:59:59';


-- Final Query
SELECT film_id,
	title,
	rental_rate,
	CASE 
		WHEN film_id IN (
			SELECT i.film_id
			FROM inventory i
			JOIN rental r ON i.inventory_id = r.inventory_id
			WHERE r.rental_date BETWEEN '2005-06-01' AND '2005-06-30 23:59:59'
		) THEN 'Rented'
		ELSE 'Not Rented'
	END AS rental_status
FROM film f 
WHERE rental_rate = 4.99;



-- 11 - Count the # of films rented vs not rented from the previous query.

SELECT rental_status,
	COUNT(*) AS TotalRentedInJune2005
FROM (
	SELECT film_id,
		title,
		rental_rate,
		CASE 
			WHEN film_id IN (
				SELECT i.film_id
				FROM inventory i
				JOIN rental r ON i.inventory_id = r.inventory_id
				WHERE r.rental_date BETWEEN '2005-06-01' AND '2005-06-30 23:59:59'
			) THEN 'Rented'
			ELSE 'Not Rented'
		END AS rental_status
	FROM film f 
	WHERE rental_rate = 4.99
) AS PremiumRentalStatus
GROUP BY rental_status;


/*
12 - Rewrite the query to count the # of films rented vs not rented 
but use an aggregate function with a CASE statement to return the 
results in this format: 
rented_films|not_rented_films|
------------|----------------|
 */

SELECT film_id
FROM film f
WHERE rental_rate = 4.99;

SELECT
	COUNT(
		CASE 
			WHEN june_rental.film_id IS NOT NULL THEN 1
		END) AS rented_films,
	COUNT(
		CASE 
			WHEN june_rental.film_id IS NULL THEN 1
		END) AS not_rented_films
FROM film f
LEFT JOIN 
	(
	SELECT film_id
	FROM inventory i
	JOIN rental r ON i.inventory_id = r.inventory_id
	WHERE rental_date BETWEEN '2005-06-01' AND '2005-06-30 23:59:59'
) AS june_rental ON f.film_id = june_rental.film_id
WHERE rental_rate = 4.99;



