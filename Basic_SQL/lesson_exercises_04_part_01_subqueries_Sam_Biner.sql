-- 01 - How many orders were booked by employees from the 425 area code?
SELECT COUNT(*) AS OrdersForEmployee
FROM Orders o
WHERE EmployeeID IN (
	SELECT EmployeeID 
	FROM Employees e
	WHERE EmpAreaCode = 425
);



-- 02 - How many orders were booked by employees from the 425 area code? 
-- Use a JOIN instead of a subquery.
SELECT COUNT(OrderNumber) AS Orders_For_425_Area_Code
FROM Orders o
JOIN Employees e ON o.EmployeeID = e.EmployeeID
WHERE e.EmpAreaCode = 425;



-- 03 - List the categories with a product count greater than the average.
-- Average based on grouped results and not just a column's value.


-- 03.01 - Select the product counts per category
SELECT CategoryDescription,
	COUNT(*) AS ProductCount
FROM Categories c
JOIN Products p ON c.CategoryID = p.CategoryID
GROUP BY c.CategoryID;


-- 03.02 - Get average # of products per category
-- Can AVG RetailPrice and QuantityOnHand but not a row count
SELECT AVG(ProductCount) AS AverageProductCount
FROM (
	SELECT COUNT(*) AS ProductCount
	FROM Categories c
	JOIN Products p ON c.CategoryID = p.CategoryID
	GROUP BY c.CategoryID
) AS ProdCountByCategory;


-- 03.03 - Add the average # of products per category as a subquery to the right-hand side of the HAVING comparison operator 
SELECT CategoryDescription,
	COUNT(*) AS ProductCount
FROM Categories c
JOIN Products p ON c.CategoryID = p.CategoryID
GROUP BY c.CategoryID
HAVING COUNT(*) > (
	SELECT AVG(ProductCount) AS AverageProductCount
	FROM (
		SELECT COUNT(*) AS ProductCount
		FROM Categories c
		JOIN Products p ON c.CategoryID = p.CategoryID
		GROUP BY c.CategoryID
	) AS ProdCountByCategory
);


-- 03.04 - Display the average product count alongside the category product count
SELECT CategoryDescription,
	COUNT(*) AS ProductCount,
	(	SELECT AVG(ProductCount)
		FROM (
			SELECT COUNT(*) AS ProductCount 
			FROM Categories c
			JOIN Products p ON c.CategoryID = p.CategoryID
			GROUP BY c.CategoryID
		) AS ProdCountByCategory
	) AS AvgProductCount
FROM Categories c
JOIN Products p ON c.CategoryID = p.CategoryID
GROUP BY c.CategoryID
HAVING COUNT(*) > AvgProductCount


-- 04 - How many categories have more products than the average product count per category?
-- Return a single row with the count
SELECT COUNT(*) AS CategoryCount
FROM (
	SELECT CategoryDescription,
		COUNT(*) AS ProductCount,
		(	SELECT AVG(ProductCount)
			FROM (
				SELECT COUNT(*) AS ProductCount 
				FROM Categories c
				JOIN Products p ON c.CategoryID = p.CategoryID
				GROUP BY c.CategoryID
			) AS ProdCountByCategory
		) AS AvgProductCount
	FROM Categories c
	JOIN Products p ON c.CategoryID = p.CategoryID
	GROUP BY c.CategoryID
	HAVING COUNT(*) > AvgProductCount
) AS CategoriesAboveAvg;










