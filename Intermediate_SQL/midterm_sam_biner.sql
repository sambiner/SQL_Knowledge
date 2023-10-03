/*
https://r.isba.co/sql-midterm-s23

Database Connection Details:
Host: isba-dev-01.c3kn1jfcngu9.us-east-1.rds.amazonaws.com
Username: analyst
Password: LMULions
Database: SpecialtyFood
Port: 3306

Attempt all tasks to receive partial credit.

You can whiteboard your notes inside the comment block containing the data request.

Assumptions:
- An order can contain multiple product IDs
- To calculate the discounted price, multiply the original price by the difference of 1 and the discount rate.
- When asked, "What is the next query you would run based on the results?" you don't have to write the SQL to answer the question but identify the data points needed and why they are important. 
- The "next query" can be related to your business recommendation.
- State any unlisted assumptions

After executing the SQL, answer the questions below for each task by writing your answer in complete sentences and placing it directly below the corresponding question.
What are the insights?
What is your business recommendation?
What is the next query you would run based on the results?
*/


/*
1.
The company has received complaints from customers about delayed shipments for the order date 
	period between June 5, 2015 and November 8, 2015. 
The fulfillment manager is asking you to identify the shippers who are responsible for orders shipped after the required date. 
Limit the results only to shippers who had more than 2 delayed orders. 
The company has a policy to credit the customer's account for the full order amount if their shipment arrives late, 
	which means lost revenue for every delayed shipment. 
Your query should return the following per shipper: shipper name, the number of delayed orders, 
	the average shipping delay in days for the delayed orders, and the lost revenue. 
You do not have to factor in the discount towards the revenue. Sort the results according to the insight generated.

What are the insights?
	United Package shiper has both the highest number of delayed orders and the highest amount of lost revenue
	
What is your business recommendation?
	Have your product manager or supervisor talk to the shipper to find out why they are delaying so many orders
	
What is the next query you would run based on the results?
	Query United Package to figure out what specific products they offer and which products they are delaying

Expected header results:
ShipperName     |DelayedOrders|AvgShippingDelay|LostRevenue|
----------------+-------------+----------------+-----------+
*/

SELECT 
	s.CompanyName AS ShipperName, 
	COUNT(o.OrderID) AS DelayedOrders, 
	AVG(DATEDIFF(ShippedDate, RequiredDate)) AS AvgShippingDelay, 
	SUM(od.UnitPrice * od.Quantity) AS LostRevenue
FROM Orders o
JOIN OrderDetails od ON o.OrderID = od.OrderID
JOIN Shippers s ON o.ShipperID = s.ShipperID
WHERE ShippedDate > RequiredDate
GROUP BY s.CompanyName
HAVING COUNT(o.OrderID) > 2
ORDER BY LostRevenue DESC;



/*
2.
The sales director wants to analyze the sales data to identify the salesperson who has given out the most discounts. 
Return the salesperson's ID, their full name in ALL CAPS, the # orders with a discount given by the salesperson, 
and a binary flag (1: yes, 0: no)  to indicate if the salesperson is discount oriented. 
A salesperson is considered discount oriented if they have given discounts to more than 50 orders. 
Sort the results according to the insight generated.

What are the insights?
	Margaret Peacock has given out nearly 30 more discounts than the second highest discounter
	
What is your business recommendation?
	Talk to Margaret about not giving out so many discounts as it is losing the company money
	
What is the next query you would run based on the results?
	Query Margaret Peacock, Employee 4, and see who they are giving discounts out to and on which products, to see
	if there is a pattern or if they are just looking out for customers

Expected header results:
EmployeeID|FullName        |Title                   |Orders|DiscountOriented|
----------+----------------+------------------------+------+----------------+

*/

SELECT e.EmployeeID, 
	CONCAT(e.FirstName, ' ', e.LastName) AS FullName, 
	e.Title, 
	COUNT(o.OrderID) AS Orders, 
	CASE 
		WHEN COUNT(o.OrderID) > 50 THEN 1 
		ELSE 0 
	END AS DiscountOriented
FROM Employees e
JOIN Orders o ON e.EmployeeID = o.EmployeeID
GROUP BY e.EmployeeID, FullName
ORDER BY Orders DESC;



/*
3.
Identify the customers who have never placed an order. 
Write the query with and without a subquery. 
Return the customer's ID, name, and phone number.

What are the insights?
	There are two customers that have never placed an order with this business
	
What is your business recommendation?
	Contact them and attempt to ask if they would like to place an order, and if not we could drop them since they aren't technically
	customers, since they have never placed an order
	
What is the next query you would run based on the results?
	Query the customers who have placed less than 5 or 3 orders to know who the less-loyal cusotmers to our business are


Expected header results:
CustomerID|CompanyName                         |Phone          |
----------+------------------------------------+---------------+

*/

-- Query 1:

SELECT CustomerID, 
	CompanyName, 
	Phone
FROM Customers
WHERE CustomerID NOT IN 
(
	SELECT CustomerID 
	FROM Orders
);


-- Query 2:

SELECT c.CustomerID, 
	c.CompanyName, 
	c.Phone
FROM Customers c
LEFT JOIN Orders o
	ON c.CustomerID = o.CustomerID
WHERE o.CustomerID IS NULL;



/*
4.
The sales director wants to analyze the sales data for the year 2015 to forecast revenue for the following year 
to determine the staffing, inventory, and supply chain resources required to meet demand. 
Generate a report that shows the category, quarter, number of orders, discounted revenue, non-discounted revenue, and average order value for each product category for the quarters in 2015. 
The DiscountedRevenue column should be the total revenue after applying all discounts, 
and the NonDiscountedRevenue column should be the total revenue before any discounts were applied. 
Sort the results according to the insight generated.

What are the insights?
	The "Produce" category has the least amount of orders in quarters 1-3 but slightly more in Quarter 4
	
What is your business recommendation?
	Figure out what specific products "Produce" is offering and why they are not selling as well as Beverages or Dairy Products
	
What is the next query you would run based on the results?
	Query Produce and figure out why the produce is selling better in Quarter 4, if people are buying more for theholidays or directly 
	after New Year's Day

Expected header results:
CategoryName  |SalesQuarter|Orders|DiscountedRevenue|NonDiscountedRevenue|AvgOrderValue|
--------------+------------+------+-----------------+--------------------+-------------+

*/

SELECT c.CategoryName,
    QUARTER(o.OrderDate)  AS SalesQuarter,
    COUNT(DISTINCT o.OrderID) AS Orders,
    SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS DiscountedRevenue,
    SUM(od.UnitPrice * od.Quantity) AS NonDiscountedRevenue,
    SUM(od.UnitPrice * od.Quantity) / COUNT(DISTINCT o.OrderID) AS AvgOrderValue
FROM Categories c
JOIN Products p 
	ON c.CategoryID = p.CategoryID
JOIN OrderDetails od 
	ON p.ProductID = od.ProductID
JOIN Orders o 
	ON od.OrderID = o.OrderID
WHERE YEAR(o.OrderDate) = 2015
GROUP BY c.CategoryName , QUARTER(o.OrderDate)
ORDER BY COUNT(DISTINCT o.OrderID);






