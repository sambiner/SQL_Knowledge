-- 01 - How many employees are from Washington?
SELECT COUNT(*) AS EmployeesFromWA
FROM Employees e 
WHERE EmpState = 'WA';


-- 02 - How many vendors provided a web page?
SELECT COUNT(*) AS VendorsWithWebsite
FROM Vendors v
WHERE VendWebPage IS NOT NULL;


-- 03 - What is the total quantity ordered for the product, Eagle FS-3 Mountain Bike?
SELECT *
FROM Products p;

SELECT SUM(QuantityOnHand) AS BikesOnHand
FROM Products p
WHERE ProductNumber = 2;


-- 04 - How much is the current inventory worth?
SELECT *
FROM Products p 
LIMIT 10;

SELECT SUM(RetailPrice * QuantityOnHand)
FROM Products p;


-- 05 - What is the average quoted price for the Dog Ear Aero-Flow Floor Pump (ProductNumber 21)?
SELECT AVG(RetailPrice)
FROM Products p
WHERE ProductNumber = 21;


-- 06 - Count the unique number of quoted prices for the Dog Ear Aero-Flow Floor Pump (ProductNumber 21).
SELECT COUNT(DISTINCT RetailPrice)
FROM Products p
WHERE ProductNumber = 21;


-- 07 - What is lowest, highest, and average retail price charged for a product?
SELECT ProductNumber,
	MIN(RetailPrice) AS MinPrice,
	MAX(RetailPrice) AS MaxPrice,
	AVG(RetailPrice) AS AvgPrice
FROM Products p
GROUP BY ProductNumber;


-- 08 - Show me each vendor ID and the average by vendor  ID of the number of days to deliver products
SELECT *
FROM Vendors v
LIMIT 10;

SELECT *
FROM Product_Vendors pv 
LIMIT 10;

SELECT 
	VendorID, AVG(DaysToDeliver)
FROM Product_Vendors pv
GROUP BY VendorID;


-- 09 - Display for each product the product number and the total sales sorted by the product number
SELECT p.ProductNumber, 
	SUM(od.QuotedPrice * od.QuantityOrdered) AS TotalSales
FROM Products p
INNER JOIN Order_Details od USING (ProductNumber)
GROUP BY p.ProductNumber 
ORDER BY p.ProductNumber;


-- 10 - List all vendors IDs and the count of products sold by each. Sort the results by the count of products sold in descending order.
SELECT v.VendorID, COUNT(p.ProductNumber) AS TotalProductsSold
FROM Products p
JOIN Product_Vendors pv USING (ProductNumber)
JOIN Vendors v USING (VendorID)
GROUP BY v.VendorID
ORDER BY TotalProductsSold DESC;


-- 11 - Display the customer ID and their most recent order date.
SELECT CustomerID, 
	MAX(OrderDate) AS MostRecentOrderDate
FROM Customers c
JOIN Orders o USING (CustomerID)
GROUP BY c.CustomerID;


-- 12 - Show me each vendor ID and the average by vendor ID of the number of days to deliver products. 
-- Filter the results to only show vendors where the average number of days to deliver is greater than 5.
SELECT 
	VendorID, AVG(DaysToDeliver)
FROM Product_Vendors pv
GROUP BY VendorID
HAVING AVG(DaysToDeliver) > 5;


-- 13 - Show me each vendor and the average by vendor of the number of days to deliver products that are greater than the average delivery days for all vendors
SELECT 
	VendorID, AVG(DaysToDeliver)
FROM Product_Vendors pv
GROUP BY VendorID
HAVING AVG(DaysToDeliver) > 
	(
		SELECT AVG(DaysToDeliver)
		FROM Product_Vendors
	);


-- 14 - Return just the number of vendors where their number of days to deliver products 
-- is greater than the average days to deliver across all vendors
SELECT COUNT(VendorID) AS VendorCount
FROM (
	SELECT 
		VendorID, AVG(DaysToDeliver)
	FROM Product_Vendors pv
	GROUP BY VendorID
	HAVING AVG(DaysToDeliver) > 
		(
			SELECT AVG(DaysToDeliver)
			FROM Product_Vendors
		)
	) AS DaysToDeliverGreaterThanAVG ;


-- 15 - How many orders are for only one product?
SELECT COUNT(DISTINCT OrderNumber) AS 'Count of Orders with one Product'
FROM (
  SELECT OrderNumber, COUNT(ProductNumber) AS ProductCount
  FROM Order_Details
  GROUP BY OrderNumber
  HAVING ProductCount = 1
) AS OrdersWithOneProduct;


-- 16 - Show all product names in a comma delimited list
SELECT GROUP_CONCAT(ProductName SEPARATOR ', ')
FROM Products p;


-- 17 - Show all product names in a comma delimited list per category ID
SELECT 
  c.CategoryID, 
  GROUP_CONCAT(p.ProductName ORDER BY p.ProductName SEPARATOR ', ') AS ProductList
FROM 
  Categories c
  INNER JOIN Products p USING (CategoryID)
GROUP BY 
  c.CategoryID;
 

-- 18 - Show all product names in a comma delimited list per category ID sorted by product name
SELECT c.CategoryID,
	GROUP_CONCAT(p.ProductName ORDER BY p.ProductName SEPARATOR ', ') AS ProductNames
FROM Categories c
LEFT JOIN Products p ON c.CategoryID = p.CategoryID 
GROUP BY c.CategoryID
ORDER BY ProductNames;

-- Summarizing and Grouping Data Practice
-- Use the SalesOrders database

-- 19 - How many products do we carry?
SELECT Count(*)
FROM Products p;


-- 20 - What are the unique product categories?
SELECT DISTINCT CategoryDescription
FROM Categories c;


-- 21 - How many unique product categories exist?
SELECT COUNT(DISTINCT CategoryID)
FROM Categories c;


-- 22 - How many products are associated with each category?
-- Sort the product counts from high to low.
SELECT c.CategoryDescription,
	COUNT(ProductNumber) AS ProductCount
FROM Products p 
JOIN Categories c ON p.CategoryID = c.CategoryID 
GROUP BY CategoryDescription
ORDER BY ProductCount DESC;


-- 23 - List the categories with more than 3 products.
SELECT c.CategoryDescription,
	COUNT(ProductNumber) AS ProductCount
FROM Products p 
JOIN Categories c ON p.CategoryID = c.CategoryID 
GROUP BY CategoryDescription
HAVING COUNT(ProductNumber) >= 3
ORDER BY ProductCount DESC;
 
 
 
-- 24
/*
List the categories with a product count greater than the average.
Show the category's product count and the average product count across all categories in the results. 
Expected columns: CategoryID | ProductCount | AvgProductCount

Structure a multi-step approach.
*/
-- Step 1: Calculate the average product count
SELECT AVG(ProductCount) AS avg_product_count
FROM (
  SELECT CategoryID, COUNT(*) AS ProductCount
  FROM Products
  GROUP BY CategoryID
) AS t;

-- Step 2: Get the categories with a product count greater than average
SELECT CategoryID, 
	COUNT(*) AS ProductCount, 
	AvgProductCount
FROM (
	SELECT CategoryID, 
		ProductName
	FROM Products
) AS p
JOIN (
	SELECT AVG(ProductCount) AS AvgProductCount
	FROM (
  		SELECT CategoryID, COUNT(*) AS ProductCount
  		FROM Products
  		GROUP BY CategoryID
	) AS t
) AS avg_table ON 1 = 1
GROUP BY CategoryID 
HAVING ProductCount > AvgProductCount;


-- 25 - How many categories have more products than the average product count per CategoryID? Return a single row.
SELECT COUNT(*) AS 'Count of Categories Over Avg Product Count'
FROM (
  SELECT CategoryID, COUNT(ProductNumber) AS ProductCount
  FROM Products
  GROUP BY CategoryID
  HAVING COUNT(ProductNumber) > (
  		SELECT AVG(pc) 
  		FROM (
  			SELECT COUNT(ProductNumber) AS pc 
  			FROM Products 
  			GROUP BY CategoryID
  		) AS avgcount
  	)
) AS CountCategories

-- 26
/*
The inventory coordinator wants to reduce the inventory holding cost by comparing the wholesale pricing for products 
supplied by 3 or more vendors. The inventory coordinator will renegotiate or sever ties with the most expensive vendor.
Generate a report to help the inventory coordinator.
*/
SELECT p.ProductNumber, ProductName, SUM(WholesalePrice) AS SumOfPrice
FROM Products p
JOIN Product_Vendors pv ON p.ProductNumber = pv.ProductNumber
WHERE (
	SELECT COUNT(DISTINCT VendorID)
	FROM Vendors v
) >= 3
GROUP BY ProductNumber, ProductName
ORDER BY SumOfPrice DESC




