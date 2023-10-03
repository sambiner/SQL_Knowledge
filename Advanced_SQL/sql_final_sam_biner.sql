/*
Filename format: sql_final_fname_lname.sql where fname is your first name and lname is your last name. - 1 point

Submit your completed exam to Brightspace -> Assessment -> Assignments -> Exams -> Final by 10 AM. 
For each minute you submit the exam past the 10 AM deadline, you'll lose 2% of your score. 
Submissions after 10:10 AM won't receive credit. Let me know immediately when you run into issues 
that can delay your exam submission.

Regularly save your work! I recommend saving your work after each task.
*/

/*
01 - 34 points
We are trying to analyze the sales and refund trends of our new product launches to identify 
any patterns that might be useful in optimizing future product offerings and existing refund policies. 

Can you please provide a report that shows order and refund data for the 2 most popular products 
outside of the Original Mr. Fuzzy: The Birthday Sugar Panda and The Hudson River Mini Bear?
Only include orders placed between April 2014 to December 2014. It doesn't matter when
the refund took place.

We will also use the data to help us understand the financial impact of the refunds and spot supplier quality issues.

Expected results header:
order_month|birthday_orders|birthday_refunds|running_birthday_refunds_total|birthday_refund_rate|mini_orders|mini_refunds|running_mini_refunds_total|mini_refund_rate|
-----------+---------------+----------------+------------------------------+--------------------+-----------+------------+--------------------------+----------------+

Assumptions:
	You say "to December 2014" instead of "through December 2014", so I am assuming you mean "right before" so I am putting November 30 23:59:59 as the date
	limit.
	
	I am confused because the minimum create_at date for the Hudson Mini Bear is December 6th, 2014 but you are saying "to December 2014".
*/

SELECT *
FROM orders o 
WHERE primary_product_id IN (3,4)
	AND created_at BETWEEN '2014-04-01' AND '2014-11-30 23:59:59';

SELECT MIN(created_at)
FROM orders o 
WHERE primary_product_id = 4;

SELECT *
FROM order_item_refunds oir 
JOIN orders o 
	ON oir.order_id = o.order_id 
WHERE primary_product_id IN (3, 4)
	AND oir.created_at BETWEEN '2014-04-01' AND '2014-11-30 23:59:59';

-- Main Query:
WITH filtered_orders AS (
	SELECT o.order_id,
		primary_product_id,
		price_usd,
		cogs_usd,
		LEFT(created_at, 7) AS order_month
        FROM orders o
        WHERE created_at BETWEEN '2014-04-01' AND '2014-11-30 23:59:59'
            AND (primary_product_id = 3 OR primary_product_id = 4)
),
refund_data AS (
	SELECT o.order_id,
		oi.product_id,
		COUNT(oir.order_item_refund_id) AS refund_count,
		SUM(oir.refund_amount_usd) AS refund_amount
        FROM order_items oi
        JOIN orders o 
        	ON oi.order_id = o.order_id
        LEFT JOIN order_item_refunds  oir 
            ON oi.order_item_id = oir.order_item_id
            AND oir.created_at BETWEEN '2014-04-01' AND '2014-11-30 23:59:59'
        WHERE oi.product_id IN (3, 4)
            AND o.created_at BETWEEN '2014-04-01' AND '2014-11-30 23:59:59'
        GROUP BY o.order_id, 
        	oi.product_id
)
SELECT fo.order_month,
    SUM(CASE WHEN fo.primary_product_id = 3 THEN 1 ELSE 0 END) AS birthday_orders,
    SUM(CASE WHEN rd.product_id = 3 THEN rd.refund_count ELSE 0 END) AS birthday_refunds,
    SUM(CASE WHEN fo.primary_product_id = 3 THEN fo.price_usd - fo.cogs_usd - COALESCE(rd.refund_amount, 0) ELSE 0 END) AS running_birthday_refunds_total,
    ROUND(100.0 * SUM(CASE WHEN rd.product_id = 3 THEN rd.refund_count ELSE 0 END) 
    	/ SUM(CASE WHEN fo.primary_product_id = 3 THEN 1 ELSE 0 END), 2) AS birthday_refund_rate,
    SUM(CASE WHEN fo.primary_product_id = 4 THEN 1 ELSE 0 END) AS mini_orders,
    SUM(CASE WHEN rd.product_id = 4 THEN rd.refund_count ELSE 0 END) AS mini_refunds,
    SUM(CASE WHEN fo.primary_product_id = 4 THEN fo.price_usd - fo.cogs_usd - COALESCE(rd.refund_amount, 0) ELSE 0 END) AS running_mini_refunds_total,
    ROUND(100.0 * SUM(CASE WHEN rd.product_id = 4 THEN rd.refund_count ELSE 0 END) 
    	/ SUM(CASE WHEN fo.primary_product_id = 4 THEN 1 ELSE 0 END), 2) AS mini_refund_rate
FROM filtered_orders fo
LEFT JOIN refund_data rd 
	ON fo.order_id = rd.order_id
GROUP BY fo.order_month
ORDER BY fo.order_month;


/*
02 - SQL Insight and Recommendation - 8 points
Provide an actionable insight and recommendation based on the results of task 01. Include your prediction if the decision makers
follow your recommendation.

Based on the data that I am retrieving from the above query, it is clear to see that customers are refunding the Birthday Sugar Panda less and less
as the product gets more established.  I recommend conducting a more thorough analysis on any changes made to this product, the customer support that we
provide, or the refund policies between April 2014 and December 2014.  If you accept my recommendation, I could expect further improveemnts in customer 
satisfaction with the Birthday Sugar Panda and increased revenue and margin due to fewer refunds.

*/







/* 
03 - 34 points
Since deploying our first custom landing page, /lander-1, on June 19, 2012, I
want to evaluate the performance of our various landing pages and marketing campaigns
up until June 19, 2014.
 
This analysis will enable us to enhance the effectiveness of our marketing campaigns 
and website performance. Additionally, I wish to track repeat sessions to identify 
opportunities for customer retention. 

Please return the number of sessions per landing page and UTM campaign and how many 
of those sessions are repeat sessions. Rank the landing page and UTM 
campaign combination by the total number of sessions from highest to lowest. 

Expected results header:
sessions_rank|landing_page|utm_campaign|total_sessions|repeat_sessions|
-------------+------------+------------+--------------+---------------+

Assumptions:
	Because you said "since deploying our first custom landing page", I am not considering the original /home
	landing page.  Additionally, I am capping the date time at June 18th, 2014 23:59:59 because you say
	"up until" and not "through June 19".
*/

-- Checking how many landers were created
SELECT DISTINCT pageview_url
FROM website_pageviews wp;


-- Main query:
WITH landing_page_sessions AS (
    SELECT ws.website_session_id,
        ws.user_id,
        ws.utm_campaign,
        wp.pageview_url as landing_page
    FROM website_sessions ws
    JOIN (
        SELECT *,
            ROW_NUMBER() OVER (
            	PARTITION BY website_session_id 
            	ORDER BY created_at
            ) as rn
        FROM website_pageviews
    ) wp ON ws.website_session_id = wp.website_session_id AND wp.rn = 1
    WHERE ws.created_at BETWEEN '2012-06-19' AND '2014-06-18 23:59:59'
        AND wp.pageview_url IN ('/lander-1','/lander-2','/lander-3','/lander-4','/lander-5')
),
sessions_data AS (
    SELECT landing_page,
        ws1.utm_campaign,
        COUNT(ws1.website_session_id) AS total_sessions,
        COUNT(CASE 
	        	WHEN ws2.website_session_id IS NOT NULL 
	        	THEN 1 
	        END) AS repeat_sessions
    FROM landing_page_sessions lps
    JOIN website_sessions ws1 
        ON lps.website_session_id = ws1.website_session_id
    LEFT JOIN website_sessions ws2
        ON ws1.user_id = ws2.user_id
        AND ws1.website_session_id != ws2.website_session_id
    GROUP BY landing_page,
        ws1.utm_campaign
)
SELECT 
	RANK() OVER (ORDER BY total_sessions DESC) AS sessions_rank,
    landing_page,
    utm_campaign,
    total_sessions,
    repeat_sessions
FROM sessions_data
ORDER BY total_sessions DESC;



/*
04 - SQL Insight and Recommendation - 8 points
Provide an actionable insight and recommendation based on the results of task 02. Include your prediction if the decision makers
follow your recommendation.

This output shows that the lander-2 with a nonbrand campaign is the most effective in driving user traffic, while the lander-3
with the nonbrand campaign has a significantly higher repeat session ratio, at 20.1%, than lander-2's ratio, which is 18.75%.
I recommend conducting an in-depth analysis of lander-3's content design to identify the factors that are contributing to the higher
repeat session rate so that the company can apply those design choices to lander-2.  If my recommendation is implemented, the company
can expect an increase in repeat sessions and visitor engagement across all landing pages, specifically lander-2 with the nonbrand campaign.

*/





/*
05 - 5 points
Explain the difference between a data warehouse and a data lake, and provide an example of when you would use one over the other.
What is your experience with both?

I believe that the difference between a data warehouse and a data lake is the structure of the data. A data warehouse, such as 
Amazon Redshift, in which I have some in-class experience, uses a much more structured approach, defining a specific schema. This 
makes it more suitable for OLAP, which is Online Analytical Processing, tasks such as aggregating historical data for SELECT queries.  
A data lake, on the other hand, stores data in its raw form, whether it be structured, semi-structured, or unstructured. I have 
experience with Amazon S3, creating a bucket and loading data in Amazon CloudShell, and querying that data in Amazon Athena. Data 
lakes provide both a flexible and scalable solution to data storage, used in a wide variety of applications from Machine Learning
to regular data analysis.

*/





/*
06 - 5 points
What is your approach to optimizing a SQL query's performance for big data? 
Describe a time when you had to optimize a query that was running slowly.

With my experience in larger datasets, I have found it takes upwards of minutes to perform a simple aggregate query such as MAX or SUM 
if you want to find products that have the highest MAX or highest SUM of revenue in an organization.  I used both columnar storage in 
Amazon Athena and indexes in MySQL to greatly improve query times on a larger dataset with over 700 thousand columns.  With our dataset, 
we could index into the City and State columns, to be able to obtain specific information on a specific city within a specific state.  This
is opposed to not creating an index and having the query check each individual state and city value in a WHERE statement, which could take an
exceptionally long time.

*/





/*
07 - 5 points
From your IT manager: "I've heard about SQL injection. What is it? Have you ever seen it in action? Describe your experience
with SQL injection."

A SQL injection attack is mainly used by black-hat hackers trying to exploit database vulnerabilities, often by  injecting malicious or harmful
SQL code into user input areas. In class, I was exposed and taught various SQL injection techniques, all for purely educational and cybersecurity 
purposes, such as UNIONs used to reveal and manipulate sensitive database information.  I was also shown many types of blinds that can be used, 
such as Boolean, Time-based, Error-based, and UNION query blinds.  In response to this lesson, my Professor went on to teach the class how to 
sanitize our database inputs by escaping non-alphanumeric characters and how important good password practices is for added database security.

*/
