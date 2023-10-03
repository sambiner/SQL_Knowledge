/*
https://r.isba.co/sql-assignment-02-spring23
Assignment 02: Business Analytics SQL - Board Meeting Presentation
Due: Monday, April 3, 11:59 PM
Overall Grade %: 8
Total Points: 100
1 point for SQL formatting and the correct filename

Database Connection Details:
hostname: lmu-dev-01.isba.co
username: lmu_dba
password: go_lions
database: tahoe_fuzzy_factory
port: 3306

Situation:
Tahoe Fuzzy Factory has been live for about 8 months. Your CEO is due to present company performance metrics to the board next week.
You'll be the one tasked with preparing relevant metrics to show the company's promising growth.

Objective:
Extract and analyze website traffic and performance data from the Tahoe Fuzzy Factory database to quantify the company's growth and
to tell the story of how you have been able to generate that growth.

As an analyst, the first part of your job is extracting and analyzing the requested data. The next part of your job is effectively 
communicating the story to your stakeholders.

Restrict to data before November 27, 2012, when the CEO made the email request.

Provide 2+ sentences of insight for each task. Keep in mind the tests ran and the changes made by the business leading up to this point.
Refer to the previous business analytics SQL exercises to explain the story behind the results.
*/


/*
4.0 - Board Meeting Presentation Project
From: Kara (CEO)
Subject: Board Meeting Next Week
Date: November 27, 2012
I need help preparing a presentation for the board meeting next week.
The board would like to have a better understanding of our growth story over our first 8 months.

Objectives:
- Tell the story of the company's growth using trended performance data
- Use the database to explain some of the details around the growth story and quantify the revenue impact of some of the wins
- Analyze current performance and use that data to assess upcoming opportunities
*/



/*
4.1 - SQL (5 points)
Gsearch seems to be the biggest driver of our business. Could you pull monthly trends for the # of gsearch sessions and orders
so that we can showcase the growth there? Include the conversion rate.

Expected results:
session_year|session_month|sessions|orders|conversion_rate|
------------+-------------+--------+------+---------------+
        2012|            3|    1843|    59|           3.20|
        2012|            4|    3569|    93|           2.61|
        2012|            5|    3405|    96|           2.82|
        2012|            6|    3590|   121|           3.37|
        2012|            7|    3797|   145|           3.82|
        2012|            8|    4887|   184|           3.77|
        2012|            9|    4487|   186|           4.15|
        2012|           10|    5519|   237|           4.29|
        2012|           11|    8586|   360|           4.19|
*/

WITH gsearch_sessions AS (
	SELECT YEAR(ws.created_at) AS session_year,
		MONTH(ws.created_at) AS session_month,
		ws.website_session_id,
		o.order_id
	FROM website_sessions ws
	LEFT JOIN orders o ON ws.website_session_id = o.website_session_id
	WHERE utm_source = 'gsearch'
		AND ws.created_at < '2012-11-27'
),
monthly_summary AS (
	SELECT session_year,
		session_month,
		COUNT(DISTINCT website_session_id) AS sessions,
		COUNT(DISTINCT order_id) AS orders
	FROM gsearch_sessions
	GROUP BY session_month
)
SELECT session_year,
	session_month,
	sessions,
	orders,
	ROUND((orders * 100.00) / sessions, 2) AS conversion_rate
FROM monthly_summary
ORDER BY session_month;

/*
4.1 - Insight (3 points)
 - The conversion rate is increasing over time, as the company grows in sessions, it grows in orders from customers. This means that we
 	should, if we continue the company, increasing our gsearch paid sessions, since it is giving the highest amount of traffic for our
 	website. Additionally, we should look into the specific sources within these paid sessions to see what is driving the most traffic
 	and boost those with more resources.
*/






/*
4.2 - SQL (10 points)
It would be great to see a similar monthly trend for gsearch but this time splitting out nonbrand and brand campaigns separately.
I wonder if brand is picking up at all. If so, this is a good story to tell.

Expected results:
session_year|session_month|nonbrand_sessions|nonbrand_orders|brand_sessions|brand_orders|
------------+-------------+-----------------+---------------+--------------+------------+
        2012|            3|             1835|             59|             8|           0|
        2012|            4|             3505|             87|            64|           6|
        2012|            5|             3292|             90|           113|           6|
        2012|            6|             3449|            115|           141|           6|
        2012|            7|             3647|            135|           150|          10|
        2012|            8|             4683|            174|           204|          10|
        2012|            9|             4222|            170|           265|          16|
        2012|           10|             5186|            222|           333|          15|
        2012|           11|             8208|            343|           378|          17|
*/

WITH gsearch_sessions AS (
    SELECT YEAR(ws.created_at) AS session_year,
        MONTH(ws.created_at) AS session_month,
        ws.website_session_id,
        o.order_id,
        IF(ws.utm_campaign LIKE 'brand', 'brand', 'nonbrand') AS campaign_type
    FROM website_sessions ws
    LEFT JOIN orders o 
    	ON ws.website_session_id = o.website_session_id
    WHERE ws.utm_source = 'gsearch'
        AND ws.created_at < '2012-11-27'
),
monthly_summary AS (
    SELECT session_year,
        session_month,
        campaign_type,
        COUNT(DISTINCT website_session_id) AS sessions,
        COUNT(DISTINCT order_id) AS orders
    FROM gsearch_sessions
    GROUP BY session_month, 
    	campaign_type
)
SELECT session_year,
    session_month,
    SUM(IF(campaign_type = 'nonbrand', sessions, 0)) AS nonbrand_sessions,
    SUM(IF(campaign_type = 'nonbrand', orders, 0)) AS nonbrand_orders,
    SUM(IF(campaign_type = 'brand', sessions, 0)) AS brand_sessions,
    SUM(IF(campaign_type = 'brand', orders, 0)) AS brand_orders
FROM monthly_summary
GROUP BY session_month
ORDER BY session_month;

/*
4.2 - Insight (3 points)
 - Actually, the brand sessions and brand orders are picking up significantly leading into 2015.  Even though nonbrand sessions and orders trump the 
	brand sessions and orders by a very wide margin, it is noticable how much traction the brand sessions and orders have gotten. If we are able to
	continue what we have been doing and marketing towards the brand campaigns, the sessions along with orders could still increase drastically.
*/

   
   
   
   
   

/*
4.3 - SQL (10 points)
While we're on gsearch, could you dive into nonbrand and pull monthly sessions and orders split by device type?
I want to show the board we really know our traffic sources.

Expected results:
session_year|session_month|desktop_sessions|desktop_orders|mobile_sessions|mobile_orders|
------------+-------------+----------------+--------------+---------------+-------------+
        2012|            3|            1119|            49|            716|           10|
        2012|            4|            2135|            76|           1370|           11|
        2012|            5|            2271|            82|           1021|            8|
        2012|            6|            2678|           107|            771|            8|
        2012|            7|            2768|           121|            879|           14|
        2012|            8|            3519|           165|           1164|            9|
        2012|            9|            3169|           154|           1053|           16|
        2012|           10|            3929|           203|           1257|           19|
        2012|           11|            6233|           311|           1975|           32|
        
*/

SELECT YEAR(ws.created_at) AS session_year,
    MONTH(ws.created_at) AS session_month,
    SUM(IF(device_type = 'desktop', 1, 0)) AS desktop_sessions,
    SUM(IF(device_type = 'desktop' AND o.order_id IS NOT NULL, 1, 0)) AS desktop_orders,
    SUM(IF(device_type = 'mobile', 1, 0)) AS mobile_sessions,
    SUM(IF(device_type = 'mobile' AND o.order_id IS NOT NULL, 1, 0)) AS mobile_orders
FROM website_sessions ws
LEFT JOIN orders o 
	ON ws.website_session_id = o.website_session_id
WHERE ws.utm_source = 'gsearch'
    AND ws.utm_campaign = 'nonbrand'
    AND ws.created_at < '2012-11-27'
GROUP BY session_month
ORDER BY session_month;

/*
4.3 - Insight (3 points)
 - The mobile site is underperforming relative to the desktop in both sessions, meaning we should prioritize optimizing the mobile site. The CVR for
 	mobile orders is lower than with desktop, which means we should investigate what is causing this drop in conversion. I would suggest A/B testing,
 	as implementing that could help determine if changes made to mobile would increase its CVR.
*/

   
   
   
   

   
/*
4.4 - SQL (10 points)
I'm worried that one of our more pessimistic board members may be concerned about the large % of traffic from gsearch.
Can you pull monthly trends for gsearch, alongside monthly trends for each of our other channels?

Hint: CASE can have an AND operator to check against multiple conditions

Expected results:
session_year|session_month|gsearch_paid_sessions|bsearch_paid_sessions|organic_search_sessions|direct_type_in_sessions|
------------+-------------+---------------------+---------------------+-----------------------+-----------------------+
        2012|            3|                 1843|                    2|                      8|                      9|
        2012|            4|                 3569|                   11|                     76|                     71|
        2012|            5|                 3405|                   25|                    148|                    150|
        2012|            6|                 3590|                   25|                    194|                    169|
        2012|            7|                 3797|                   44|                    206|                    188|
        2012|            8|                 4887|                  696|                    265|                    250|
        2012|            9|                 4487|                 1438|                    332|                    284|
        2012|           10|                 5519|                 1770|                    427|                    442|
        2012|           11|                 8586|                 2752|                    525|                    475|
*/

-- find the various utm sources and referers to see the traffic we're getting
SELECT 
	DISTINCT
		utm_source,
		utm_campaign,
		http_referer
FROM website_sessions ws 
WHERE created_at < '2012-11-27';
/*
utm_source|utm_campaign|http_referer           |
----------+------------+-----------------------+
gsearch   |nonbrand    |https://www.gsearch.com| gsearch_paid_session
NULL      |NULL        |NULL                   | direct_type_in_session
gsearch   |brand       |https://www.gsearch.com| gsearch_paid_session
NULL      |NULL        |https://www.gsearch.com| organic_search_session
bsearch   |brand       |https://www.bsearch.com| bsearch_paid_session
NULL      |NULL        |https://www.bsearch.com| organic_search_session
bsearch   |nonbrand    |https://www.bsearch.com| bsearch_paid_session
 */

SELECT
    YEAR(ws.created_at) AS session_year,
    MONTH(ws.created_at) AS session_month,
    SUM(CASE
        	WHEN ws.utm_source = 'gsearch' THEN 1
    	END) AS gsearch_paid_sessions,
    SUM(CASE
        	WHEN ws.utm_source = 'bsearch' THEN 1
    	END) AS bsearch_paid_sessions,
    SUM(CASE
        	WHEN ws.utm_source IS NULL AND ws.http_referer LIKE 'https://www.gsearch.com' THEN 1
        	WHEN ws.utm_source IS NULL AND ws.http_referer LIKE 'https://www.bsearch.com' THEN 1
    	END) AS organic_search_sessions,
    SUM(CASE
        	WHEN ws.utm_source IS NULL AND ws.http_referer IS NULL THEN 1
    	END) AS direct_type_in_sessions
FROM website_sessions ws
WHERE ws.created_at < '2012-11-27'
GROUP BY session_month
ORDER BY session_month;

/*
4.4 - Insight (3 points)
 - First, I am noticing that the # of sessions driven by paid searches has been steadily increasing over these past few years, with gsearch
 	being the major contributor.  Additionally, direct type in sessions have stayed relatively stable through this period, which suggests that
 	the brand remains consistently recognized. Finally, I would suggest that we need to investigate why the organic searches have not been showing
 	similar growth and should assess if optimization efforts are needed to improve our ranking.
*/


   
   
   
   
   
   
/*
4.5 - SQL (10 points)
I'd like to tell the story of our website performance over the course of the first 8 months. 
Could you pull session to order conversion rates by month?


Expected results:
session_year|session_month|sessions|orders|conversion_rate|
------------+-------------+--------+------+---------------+
        2012|            3|    1862|    59|           3.17|
        2012|            4|    3727|   100|           2.68|
        2012|            5|    3728|   107|           2.87|
        2012|            6|    3978|   140|           3.52|
        2012|            7|    4235|   169|           3.99|
        2012|            8|    6098|   228|           3.74|
        2012|            9|    6541|   285|           4.36|
        2012|           10|    8158|   368|           4.51|
        2012|           11|   12338|   547|           4.43|
*/
   
WITH monthly_data AS (
    SELECT YEAR(ws.created_at) AS session_year,
        MONTH(ws.created_at) AS session_month,
        ws.website_session_id,
        o.order_id
    FROM website_sessions ws
    LEFT JOIN orders o 
    	ON ws.website_session_id = o.website_session_id
    WHERE ws.created_at < '2012-11-27'
)
SELECT session_year,
    session_month,
    COUNT(website_session_id) AS sessions,
    COUNT(order_id) AS orders,
    ROUND(100 * (COUNT(order_id) / COUNT(website_session_id)), 2) AS conversion_rate
FROM monthly_data
GROUP BY session_month
ORDER BY session_month;
   

/*
4.5 - Insight (3 points)
 - For this story, we start with a steady increase of session volume and conversion rates leading up to today. I would suggest additional
 	queries to find which traffic sources are responsible for this growth.  I believe that in order to drive conversions to be higher, our
 	company needs to focus on optimizing the landing pages of these high traffic sources.
*/






/*
4.6 - SQL (15 points)
For the landing page test, it would be great to show a full conversion funnel from each of the two landing pages 
(/home, /lander-1) to orders. Use the time period when the test was running (Jun 19 - Jul 28).

Expected results:
landing_page_version_seen|lander_ctr|products_ctr|mrfuzzy_ctr|cart_ctr|shipping_ctr|billing_ctr|
-------------------------+----------+------------+-----------+--------+------------+-----------+
homepage                 |     46.82|       71.00|      42.84|   67.29|       85.76|      46.56|
custom_lander            |     46.79|       71.34|      44.99|   66.47|       85.22|      47.96|
*/

WITH landing_page_sessions AS (
    SELECT wpv.website_session_id,
        CASE
            WHEN pageview_url = '/lander-1' THEN 'custom_lander'
            WHEN pageview_url = '/home' THEN 'homepage'
        END AS landing_page_version_seen
    FROM website_pageviews wpv
    WHERE pageview_url IN ('/home', '/lander-1')
        AND created_at BETWEEN '2012-06-19' AND '2012-07-28'
),
funnel_steps AS (
    SELECT landing_page_version_seen,
        COUNT(DISTINCT wpv.website_session_id) AS sessions,
        COUNT(DISTINCT 
        	CASE 
	        	WHEN pageview_url = '/products' THEN wpv.website_session_id 
	        END) AS products_ctr,
        COUNT(DISTINCT 
        	CASE 
	        	WHEN pageview_url = '/the-original-mr-fuzzy' THEN wpv.website_session_id 
	        END) AS mrfuzzy_ctr,
        COUNT(DISTINCT 
        	CASE 
	        	WHEN pageview_url = '/cart' THEN wpv.website_session_id 
	        END) AS cart_ctr,
        COUNT(DISTINCT 
        	CASE 
	        	WHEN pageview_url = '/shipping' THEN wpv.website_session_id 
	        END) AS shipping_ctr,
        COUNT(DISTINCT 
        	CASE 
	        	WHEN pageview_url = '/billing' THEN wpv.website_session_id 
	        END) AS billing_ctr,
        COUNT(DISTINCT 
        	CASE 
	        	WHEN pageview_url = '/thank-you-for-your-order' THEN wpv.website_session_id 
	        END) AS confirmation_ctr
    FROM landing_page_sessions lps
    JOIN website_pageviews wpv 
    	ON lps.website_session_id = wpv.website_session_id
    GROUP BY landing_page_version_seen
),
conversion_rates AS (
    SELECT landing_page_version_seen,
    	ROUND(100 * products_ctr / sessions, 2) AS lander_ctr,
        ROUND(100 * mrfuzzy_ctr / products_ctr, 2) AS products_ctr,
        ROUND(100 * cart_ctr / mrfuzzy_ctr, 2) AS mrfuzzy_ctr,
        ROUND(100 * shipping_ctr / cart_ctr, 2) AS cart_ctr,
        ROUND(100 * billing_ctr / shipping_ctr, 2) AS shipping_ctr,
        ROUND(100 * confirmation_ctr / billing_ctr , 2) AS billing_ctr
    FROM funnel_steps
)
SELECT * 
FROM conversion_rates
ORDER BY landing_page_version_seen DESC;x

/*
4.6 - Insight (3 points)
 - The data that is outputted shows that the click-through rate for each landing page is similar.  However, there may be an
 	opportunity to optimize the checkout funnel, which has conversions rates slightly higher for the customer lander than
 	the home page, especially within the billing stage. I suggest diving deeper as to identify potential issues,
 	or improvements, in the checkout funnel, so our company can improve the conversion rate on both the custom lander
 	and the original home page. 
*/







/*
4.7 - SQL (10 points)
I'd love for you to quantify the impact of our billing page A/B test. Please analyze the lift generated from the test
(Sep 10 - Nov 10) in terms of revenue per billing page session. Manually calculate the revenue per billing page session
difference between the old and new billing page versions. 

Expected results:
billing_version_seen|sessions|revenue_per_billing_page_seen|
--------------------+--------+-----------------------------+
/billing            |     657|                        22.90|
/billing-2          |     653|                        31.39|
*/

WITH billing_pageviews AS (
    SELECT wpv.website_session_id,
        CASE
            WHEN wpv.pageview_url = '/billing' THEN '/billing'
            ELSE '/billing-2'
        END AS billing_version_seen,
        o.price_usd
    FROM website_pageviews wpv
    LEFT JOIN orders o 
    	ON wpv.website_session_id = o.website_session_id
    WHERE wpv.pageview_url REGEXP '/billing|/billing-2'
    	AND wpv.created_at BETWEEN '2012-09-10' AND '2012-11-10'
)
SELECT  billing_version_seen,
    COUNT(website_session_id) AS sessions,
    ROUND(SUM(price_usd) / COUNT(website_session_id), 2) AS revenue_per_billing_page_seen
FROM billing_pageviews
GROUP BY billing_version_seen;

/*
4.7 - Insight (3 points)
 - It appears that the second iteration of the billing page generates more revenue than the original billing page layout.
 	I suggest that we further optimize the second billing page and look into the differences in design between these two
 	pages to figure out why it is better than the original. Additionally, our company can create multiple other billing
 	page variation to see if any other improvements can be made.
 */








/*
4.8 - SQL (5 points)
Pull the number of billing page sessions (sessions that saw '/billing' or '/billing-2') for the past month and multiply that value
by the lift generated from the test (Sep 10 - Nov 10) to understand the monthly impact. 
You manually calculated the lift by taking the revenue per billing page session difference between /billing and /billing-2. 
You can hard code the revenue lift per billing session into the query.


Expected results:
past_month_billing_sessions|billing_test_value|
---------------------------+------------------+
                       1161|           9856.89|
*/
SELECT 
	COUNT(wpv.pageview_url) AS past_month_billing_sessions,
    8.49 * COUNT(wpv.pageview_url) AS billing_test_value
FROM website_pageviews wpv
WHERE wpv.created_at BETWEEN '2012-10-27' AND '2012-11-27'
	AND wpv.pageview_url REGEXP '/billing|/billing-2';


/*
4.8 - Insight (3 points)
 - These is a significant number of billing sessions in the last month and the company is bleeding revenue and profits by
 	not strictly running the second billing page iteration.  I would recommend running solely the second billing page
 	edition, along with trying new A/B tests with different billing page variations.  This tactic could definitely help to
 	improve the billing test value and increase revenue growth.
 */



