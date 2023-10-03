/*
https://r.isba.co/sql-assignment-03-spring23
Assignment 03: Business Analytics SQL - Crafting a Growth Story: Analyzing Traffic and Website Performance Data
Due: Monday, April 24, 9:55 AM
Overall Grade %: 8
Total Points: 100
1 point for the correct filename and 1 point for SQL formatting.

This is a group assignment with 2-3 members per group. Let me know if you need help finding a group.

Database Connection Details:
hostname: lmu-dev-01.isba.co
username: lmu_dba
password: go_lions
database: tahoe_fuzzy_factory
port: 3306

Situation:
For this assignment, you will be supporting Kara, the CEO, in creating a compelling narrative for Tahoe Fuzzy Factory's 
upcoming funding round. Your task is to gather and analyze relevant data to showcase the company's impressive 
growth as a data-driven organization then you will present your findings. With your assistance, Kara will be able to tell
a convincing story to potential investors.

Objective:
The objective of this project is to extract and analyze traffic and website performance data to craft a compelling growth 
story that can be presented by the CEO to potential investors. By delving into marketing channel activities and website 
improvements that have contributed to the company's success thus far, this analysis will showcase the company's data-driven 
approach and highlight its impressive growth. Effective communication of the story to stakeholders is crucial, requiring 
both analytical skills and strong presentation abilities. You will be presenting to potential investors, who are non-technical.

Provide 2+ sentences of insight for each task. Keep in mind the optimizations made by the business leading up to this point.
Refer to the previous business analytics SQL exercises and Assignment 02 to explain the story behind the results.

Deliverables:
1. SQL queries to produce the expected results (submit 1 file per group)
2. Insight for each result set
3. 8-10 minute presentation with slides (40 points)

Grading Criteria:
SQL: Queries accurately reflect the intended analysis and return the expected results.
Insight: The insight is relevant, valuable, and actionable.
Presentation: https://r.isba.co/aacu-oral-communication-rubric
*/


/*
1.0
From: Kara (CEO)
Subject: Assistance Required to Secure Large Venture Capital Funding
Date: March 21, 2015
Our company has been in the market for three years and has experienced substantial growth, positioning us to raise a larger 
round of venture capital funding. We are currently in discussions with a leading private equity firm and I am seeking your 
analytical skills to assist me in conveying our data-driven performance optimization and potential for continued high growth. 

Would you be able to help me in this task?

Objectives:
- Demonstrate company growth through trended performance data
- Showcase growth through a SQL analysis of marketing channels and website optimizations
- Highlight analytical capabilities to demonstrate our commitment to being a data-driven organization to potential VCs

Hints:
- Not all website sessions result in an order
- Use your judgement on how to best format the SQL given the heavy use of CASE statements.

*/


/*
1.1 - SQL (4 points)
The first request is to pull data on session and order volume, segmented by quarter, for the entire lifespan of the business
to calculate the conversion rate trend. 

Expected results:
session_year|session_quarter|sessions|orders|conversion_rate|
------------+---------------+--------+------+---------------+
        2012|              1|    1862|    59|         3.1686|
        2012|              2|   11433|   347|         3.0351|
        2012|              3|   16874|   682|         4.0417|
        2012|              4|   32264|  1497|         4.6398|
        2013|              1|   19834|  1274|         6.4233|
        2013|              2|   24737|  1713|         6.9248|
        2013|              3|   27635|  1844|         6.6727|
        2013|              4|   40522|  2610|         6.4409|
        2014|              1|   46759|  3073|         6.5720|
        2014|              2|   53093|  3841|         7.2345|
        2014|              3|   57134|  4036|         7.0641|
        2014|              4|   76369|  5912|         7.7414|
        2015|              1|   64355|  5425|         8.4298|
*/


SELECT YEAR(ws.created_at) AS session_year,
	QUARTER(ws.created_at) AS session_quarter,
	COUNT(ws.website_session_id) AS sessions,
	COUNT(order_id) AS orders,
	(COUNT(order_id) / COUNT(ws.website_session_id))*100 AS conversion_rate
FROM website_sessions ws 
LEFT JOIN orders o 
	ON ws.website_session_id = o.website_session_id
GROUP BY session_quarter, session_year;

/*
1.1 - Insight (3 points)

*/


/*
1.2 - SQL (4 points)
The next step is to showcase efficiency improvements, with a focus on quarterly figures since our launch. Specifically, we
aim to present data on session-to-order conversion rate, revenue per order, and revenue per session.

Expected results:
session_year|session_quarter|session_to_order_conv_rate|revenue_per_order|revenue_per_session|
------------+---------------+--------------------------+-----------------+-------------------+
        2012|              1|3.17                      |49.99            |1.58               |
        2012|              2|3.04                      |49.99            |1.52               |
        2012|              3|4.04                      |49.99            |2.02               |
        2012|              4|4.64                      |49.99            |2.32               |
        2013|              1|6.42                      |52.14            |3.35               |
        2013|              2|6.92                      |51.53            |3.57               |
        2013|              3|6.67                      |51.74            |3.45               |
        2013|              4|6.44                      |54.70            |3.52               |
        2014|              1|6.57                      |62.15            |4.08               |
        2014|              2|7.23                      |64.38            |4.66               |
        2014|              3|7.06                      |64.48            |4.56               |
        2014|              4|7.74                      |63.81            |4.94               |
        2015|              1|8.43                      |62.80            |5.29               |
*/

WITH session_quarter_cvr AS (
	SELECT 
		YEAR(ws.created_at) AS session_year,
		QUARTER(ws.created_at) AS session_quarter,
		COUNT(ws.website_session_id) AS sessions,
		COUNT(o.order_id) AS orders,
		(COUNT(o.order_id) / COUNT(ws.website_session_id))*100 AS session_to_order_cvr,
		SUM(o.price_usd) AS revenue
	FROM website_sessions ws 
	LEFT JOIN orders o 
		ON ws.website_session_id = o.website_session_id
	GROUP BY session_year, session_quarter
)
SELECT 
	session_year,
	session_quarter,
	FORMAT(session_to_order_cvr, 2) AS session_to_order_conv_rate,
	FORMAT(revenue / orders, 2) AS revenue_per_order,
	FORMAT(revenue / sessions, 2) AS revenue_per_session
FROM session_quarter_cvr;

/*
1.2 - Insight (3 points)
???
*/


/*
1.3 - SQL (8 points)
Can you pull a quarterly view of orders for Gsearch nonbrand, Bsearch nonbrand, brand search overall, organic search, and
direct type-in to show how we've grown these specific channels?

Expected results:
session_year|session_quarter|gsearch_nonbrand_orders|bsearch_nonbrand_orders|brand_search_orders|organic_search_orders|direct_type_in_orders|
------------+---------------+-----------------------+-----------------------+-------------------+---------------------+---------------------+
        2012|              1|                     59|                      0|                  0|                    0|                    0|
        2012|              2|                    292|                      0|                 19|                   15|                   21|
        2012|              3|                    479|                     82|                 49|                   40|                   32|
        2012|              4|                    916|                    311|                 87|                   94|                   89|
        2013|              1|                    766|                    183|                109|                  125|                   91|
        2013|              2|                   1110|                    237|                113|                  134|                  119|
        2013|              3|                   1135|                    245|                154|                  167|                  143|
        2013|              4|                   1654|                    291|                247|                  222|                  196|
        2014|              1|                   1668|                    344|                355|                  339|                  312|
        2014|              2|                   2206|                    425|                409|                  435|                  366|
        2014|              3|                   2260|                    434|                431|                  446|                  402|
        2014|              4|                   3249|                    685|                617|                  604|                  532|
        2015|              1|                   3028|                    581|                622|                  641|                  553|
*/

WITH quarterly_sessions AS (
    SELECT 
       	YEAR(created_at) AS session_year,
        QUARTER(created_at) AS session_quarter,
        website_session_id,
        utm_source,
        utm_campaign,
        http_referer
    FROM website_sessions
),
orders_with_quarter AS (
    SELECT
    	q.website_session_id,
        o.order_id,
        q.session_year,
        q.session_quarter,
        q.utm_source,
        q.utm_campaign,
        q.http_referer
    FROM orders o
    LEFT JOIN quarterly_sessions q 
    	ON o.website_session_id = q.website_session_id
),
channel_orders AS (
    SELECT
        session_year,
        session_quarter,
        COUNT(CASE 
	        	WHEN utm_source = 'gsearch' 
	        	AND utm_campaign = 'nonbrand' THEN website_session_id 
	        END) AS gsearch_nonbrand_orders,
        COUNT(CASE 
	        	WHEN utm_source = 'bsearch' 
	        	AND utm_campaign = 'nonbrand' THEN website_session_id 
	        END) AS bsearch_nonbrand_orders,
        COUNT(CASE 
	        	WHEN utm_source = 'gsearch' 
	        	AND utm_campaign = 'brand' THEN website_session_id 
	        END) 
	    + COUNT(CASE 
		    		WHEN utm_source = 'bsearch' 
		    		AND utm_campaign = 'brand' THEN website_session_id 
		    	END) AS brand_search_orders,
        COUNT(CASE 
	        	WHEN utm_source IS NULL 
	        	AND utm_campaign IS NULL 
	        	AND http_referer = 'https://www.gsearch.com' THEN website_session_id 
	        END)
		+ COUNT(CASE 
					WHEN utm_source IS NULL 
					AND utm_campaign IS NULL 
					AND http_referer = 'https://www.bsearch.com' THEN website_session_id 
				END)AS organic_search_orders,
        COUNT(CASE 
	        	WHEN utm_source IS NULL 
	        	AND utm_campaign IS NULL 
	        	AND http_referer IS NULL THEN website_session_id
	        END) AS direct_type_in_orders
    FROM orders_with_quarter
    GROUP BY session_year, session_quarter
)
SELECT session_year,
    session_quarter,
    gsearch_nonbrand_orders,
    bsearch_nonbrand_orders,
    brand_search_orders,
    organic_search_orders,
    direct_type_in_orders
FROM channel_orders
ORDER BY session_year, session_quarter;

/*
1.3 - Insight (3 points)
???
*/


/*
1.4 - SQL (8 points)
For the next request, show the overall session-to-order conversion rate trends for the same channels, segmented by quarter. 

Expected results:
session_year|session_quarter|gsearch_nonbrand_cvr|bsearch_nonbrand_cvr|brand_search_cvr|organic_search_cvr|direct_type_in_cvr|
------------+---------------+--------------------+--------------------+----------------+------------------+------------------+
        2012|              1|3.22                |                    |0.00            |0.00              |0.00              |
        2012|              2|2.85                |                    |5.01            |3.59              |5.38              |
        2012|              3|3.82                |4.10                |6.15            |4.98              |4.43              |
        2012|              4|4.37                |4.96                |5.27            |5.40              |5.38              |
        2013|              1|6.12                |6.94                |7.08            |7.53              |6.12              |
        2013|              2|6.83                |6.90                |6.73            |7.61              |7.37              |
        2013|              3|6.42                |6.97                |7.08            |7.36              |7.18              |
        2013|              4|6.28                |6.01                |7.98            |6.90              |6.45              |
        2014|              1|6.94                |7.05                |8.43            |7.59              |7.67              |
        2014|              2|7.02                |6.92                |8.02            |7.96              |7.36              |
        2014|              3|7.03                |6.98                |7.54            |7.34              |7.04              |
        2014|              4|7.83                |8.43                |8.15            |7.83              |7.48              |
        2015|              1|8.59                |8.48                |8.49            |8.21              |7.74              |
*/

WITH quarterly_sessions AS (
    SELECT 
        YEAR(created_at) AS session_year,
        QUARTER(created_at) AS session_quarter,
        website_session_id,
        utm_source,
        utm_campaign,
        http_referer
    FROM website_sessions
),
orders_with_quarter AS (
    SELECT
        o.order_id,
        q.website_session_id,
        q.session_year,
        q.session_quarter,
        q.utm_source,
        q.utm_campaign,
        q.http_referer
    FROM orders o
    RIGHT JOIN quarterly_sessions q 
        ON o.website_session_id = q.website_session_id
),
channel_summary AS (
    SELECT
        session_year,
        session_quarter,
        utm_source,
        utm_campaign,
        http_referer,
        COUNT(DISTINCT website_session_id) AS total_sessions,
        COUNT(DISTINCT order_id) AS total_orders
    FROM orders_with_quarter
    GROUP BY session_year, session_quarter, utm_source, utm_campaign, http_referer
)
SELECT 
    session_year,
    session_quarter,
    ROUND(100 * SUM(CASE 
            WHEN utm_source = 'gsearch' 
            AND utm_campaign = 'nonbrand' THEN total_orders
        END) / SUM(CASE 
            WHEN utm_source = 'gsearch' 
            AND utm_campaign = 'nonbrand' THEN total_sessions
        END), 2) AS gsearch_nonbrand_cvr,
    ROUND(100 * SUM(CASE 
            WHEN utm_source = 'bsearch' 
            AND utm_campaign = 'nonbrand' THEN total_orders
        END) / SUM(CASE 
            WHEN utm_source = 'bsearch' 
            AND utm_campaign = 'nonbrand' THEN total_sessions
        END), 2) AS bsearch_nonbrand_cvr,
    ROUND(100 * SUM(CASE 
            WHEN (utm_source = 'gsearch' 
            	AND utm_campaign = 'brand') 
            OR (utm_source = 'bsearch' 
                AND utm_campaign = 'brand') THEN total_orders
        END) / SUM(CASE 
            WHEN (utm_source = 'gsearch' 
            	AND utm_campaign = 'brand') 
            OR (utm_source = 'bsearch' 
            	AND utm_campaign = 'brand') THEN total_sessions
        END), 2) AS brand_search_cvr,
    ROUND(100 * SUM(CASE 
            WHEN (utm_source IS NULL 
            	AND utm_campaign IS NULL 
            	AND http_referer = 'https://www.gsearch.com') 
            OR (utm_source IS NULL 
                 AND utm_campaign IS NULL 
                 AND http_referer = 'https://www.bsearch.com') THEN total_orders
        END) / SUM(CASE 
            WHEN (utm_source IS NULL 
            	AND utm_campaign IS NULL 
            	AND http_referer = 'https://www.gsearch.com')
            OR (utm_source IS NULL 
            	AND utm_campaign IS NULL 
            	AND http_referer = 'https://www.bsearch.com') THEN total_sessions
        END), 2) AS organic_search_cvr,
    ROUND(100 * SUM(CASE 
            WHEN utm_source IS NULL 
            AND utm_campaign IS NULL 
            AND http_referer IS NULL THEN total_orders
        END) / SUM(CASE WHEN utm_source IS NULL 
        	AND utm_campaign IS NULL 
        	AND http_referer IS NULL THEN total_sessions
    END), 2) AS direct_type_in_cvr
FROM channel_summary
GROUP BY session_year, session_quarter
ORDER BY session_year, session_quarter;

/*
1.4 - Insight (3 points)
???
*/


/*
1.5 - SQL (8 points)
We've made significant progress since our early days of selling a single product. To showcase our growth, we would like to
pull monthly trends for revenue and margin by product, as well as total revenue and margin. In your insight, please make note
of any seasonality patterns you observe.

Expected results:
order_year|order_month|mrfuzzy_revenue|mrfuzzy_margin|lovebear_revenue|lovebear_margin|birthdaybear_revenue|birthdaybear_margin|minibear_revenue|minibear_margin|total_revenue|total_margin|
----------+-----------+---------------+--------------+----------------+---------------+--------------------+-------------------+----------------+---------------+-------------+------------+
      2012|Mar        |        2949.41|       1799.50|                |               |                    |                   |                |               |      2949.41|     1799.50|
      2012|Apr        |        4999.00|       3050.00|                |               |                    |                   |                |               |      4999.00|     3050.00|
      2012|May        |        5348.93|       3263.50|                |               |                    |                   |                |               |      5348.93|     3263.50|
      2012|Jun        |        6998.60|       4270.00|                |               |                    |                   |                |               |      6998.60|     4270.00|
      2012|Jul        |        8448.31|       5154.50|                |               |                    |                   |                |               |      8448.31|     5154.50|
      2012|Aug        |       11397.72|       6954.00|                |               |                    |                   |                |               |     11397.72|     6954.00|
      2012|Sep        |       14247.15|       8692.50|                |               |                    |                   |                |               |     14247.15|     8692.50|
      2012|Oct        |       18346.33|      11193.50|                |               |                    |                   |                |               |     18346.33|    11193.50|
      2012|Nov        |       31043.79|      18940.50|                |               |                    |                   |                |               |     31043.79|    18940.50|
      2012|Dec        |       25444.91|      15524.50|                |               |                    |                   |                |               |     25444.91|    15524.50|
      2013|Jan        |       17096.58|      10431.00|         2819.53|        1762.50|                    |                   |                |               |     19916.11|    12193.50|
      2013|Feb        |       16646.67|      10156.50|         9658.39|        6037.50|                    |                   |                |               |     26305.06|    16194.00|
      2013|Mar        |       16196.76|       9882.00|         3959.34|        2475.00|                    |                   |                |               |     20156.10|    12357.00|
      2013|Apr        |       22795.44|      13908.00|         5579.07|        3487.50|                    |                   |                |               |     28374.51|    17395.50|
      2013|May        |       24595.08|      15006.00|         4919.18|        3075.00|                    |                   |                |               |     29514.26|    18081.00|
      2013|Jun        |       25094.98|      15311.00|         5339.11|        3337.50|                    |                   |                |               |     30434.09|    18648.50|
      2013|Jul        |       25394.92|      15494.00|         5819.03|        3637.50|                    |                   |                |               |     31213.95|    19131.50|
      2013|Aug        |       25544.89|      15585.50|         5879.02|        3675.00|                    |                   |                |               |     31423.91|    19260.50|
      2013|Sep        |       26944.61|      16439.50|         5819.03|        3637.50|                    |                   |                |               |     32763.64|    20077.00|
      2013|Oct        |       29944.01|      18269.50|         7978.67|        4987.50|                    |                   |                |               |     37922.68|    23257.00|
      2013|Nov        |       36342.73|      22173.50|        10618.23|        6637.50|                    |                   |                |               |     46960.96|    28811.00|
      2013|Dec        |       40741.85|      24857.50|        10738.21|        6712.50|             6392.61|            4378.50|                |               |     57872.67|    35948.50|
      2014|Jan        |       36442.71|      22234.50|        11218.13|        7012.50|             9106.02|            6237.00|                |               |     56766.86|    35484.00|
      2014|Feb        |       29044.19|      17720.50|        21056.49|       13162.50|             9749.88|            6678.00|         5998.00|        4100.00|     65848.56|    41661.00|
      2014|Mar        |       39492.10|      24095.00|        11458.09|        7162.50|            11221.56|            7686.00|         6207.93|        4243.50|     68379.68|    43187.00|
      2014|Apr        |       45640.87|      27846.50|        12957.84|        8100.00|            12187.35|            8347.50|         7767.41|        5309.50|     78553.47|    49603.50|
      2014|May        |       51639.67|      31506.50|        14757.54|        9225.00|            13842.99|            9481.50|         8877.04|        6068.00|     89117.24|    56281.00|
      2014|Jun        |       44341.13|      27053.50|        14697.55|        9187.50|            13061.16|            8946.00|         7407.53|        5063.50|     79507.37|    50250.50|
      2014|Jul        |       48090.38|      29341.00|        14457.59|        9037.50|            12831.21|            8788.50|         7857.38|        5371.00|     83236.56|    52538.00|
      2014|Aug        |       47940.41|      29249.50|        14397.60|        9000.00|            13567.05|            9292.50|         9206.93|        6293.50|     85111.99|    53835.50|
      2014|Sep        |       52739.45|      32177.50|        14817.53|        9262.50|            14578.83|            9985.50|         9866.71|        6744.50|     92002.52|    58170.00|
      2014|Oct        |       58688.26|      35807.00|        17097.15|       10687.50|            16924.32|           11592.00|        11216.26|        7667.00|    103925.99|    65753.50|
      2014|Nov        |       72485.50|      44225.00|        22676.22|       14175.00|            19499.76|           13356.00|        13435.52|        9184.00|    128097.00|    80940.00|
      2014|Dec        |       79234.15|      48342.50|        23336.11|       14587.50|            24742.62|           16947.00|        17724.09|       12115.50|    145036.97|    91992.50|
      2015|Jan        |       69736.05|      42547.50|        23516.08|       14700.00|            20833.47|           14269.50|        18263.91|       12484.50|    132349.51|    84001.50|
      2015|Feb        |       55438.91|      33824.50|        38753.54|       24225.00|            18533.97|           12694.50|        16284.57|       11131.50|    129010.99|    81875.50|
      2015|Mar        |       43541.29|      26565.50|        13377.77|        8362.50|            12187.35|            8347.50|        10376.54|        7093.00|     79482.95|    50368.50|
*/

WITH combined_data AS (
    SELECT
    	oi.created_at,
    	YEAR(oi.created_at) AS order_year,
    	DATE_FORMAT(oi.created_at, '%M') AS order_month,
    	MONTH(oi.created_at) AS months,
        product_name,
        oi.product_id,
        SUM(oi.price_usd) AS revenue,
        SUM(oi.price_usd - oi.cogs_usd) AS margin
    FROM order_items oi
    JOIN products p ON oi.product_id = p.product_id
    GROUP BY order_year, months, oi.product_id
),
pivoted_data AS (
    SELECT
		order_year,
        order_month,
        MAX(CASE 
	        	WHEN product_id = 1 THEN revenue 
        		ELSE 0 
        	END) AS mrfuzzy_revenue,
        MAX(CASE 
	        	WHEN product_id = 1 THEN margin 
	        	ELSE 0 
	        END) AS mrfuzzy_margin,
        MAX(CASE 
	        	WHEN product_id = 2 THEN revenue 
	        	ELSE 0 
	        END) AS lovebear_revenue,
        MAX(CASE 
	        	WHEN product_id = 2 THEN margin 
        		ELSE 0 
        	END) AS lovebear_margin,
        MAX(CASE 
	        	WHEN product_id = 3 THEN revenue 
	        	ELSE 0 
	        END) AS birthdaybear_revenue,
        MAX(CASE 
	        	WHEN product_id = 3 THEN margin 
	        	ELSE 0
	        END) AS birthdaybear_margin,
        MAX(CASE 
	        	WHEN product_id = 4 THEN revenue 
	        	ELSE 0 
	        END) AS minibear_revenue,
        MAX(CASE 
	        	WHEN product_id = 4 THEN margin 
	        	ELSE 0 
	        END) AS minibear_margin
    FROM combined_data cd
    GROUP BY order_year, order_month
)
SELECT
    order_year,
    order_month,
    mrfuzzy_revenue,
    mrfuzzy_margin,
    lovebear_revenue,
    lovebear_margin,
    birthdaybear_revenue,
    birthdaybear_margin,
    minibear_revenue,
    minibear_margin,
    mrfuzzy_revenue + lovebear_revenue + birthdaybear_revenue + minibear_revenue AS total_revenue,
    mrfuzzy_margin + lovebear_margin + birthdaybear_margin + minibear_margin AS total_margin
FROM pivoted_data
ORDER BY order_year, MONTH(STR_TO_DATE(order_month, '%M'));


/*
1.5 - Insight (3 points)
???
*/


/*
1.6 - SQL (8 points)
Custom Data Request: This is an exercise in asking high-value questions about data. Create 1 custom data request on the 
tahoe_fuzzy_factory database that demonstrates the value of the business and its growth potential. The data request 
requires a window function, at least one JOIN, and at least one CTE. Examples  areas to explore include, but are not limited to: 
sales performance, customer acquisition, product performance, and operational efficiency. In your insight, speak to
the needs and interests of the investors but also state any assumptions, limitations, or caveats to your findings.
*/

WITH user_revenue AS (
  SELECT
    u.user_id,
    p.product_name,
    ws.utm_source,
    SUM(o.price_usd) AS total_revenue
  FROM orders o
  JOIN products p 
  	ON o.primary_product_id = p.product_id
  JOIN website_sessions ws
  	ON o.website_session_id = ws.website_session_id
  JOIN (SELECT 
  			DISTINCT user_id 
  		FROM website_sessions) u 
  	ON ws.user_id = u.user_id
  GROUP BY 
  	u.user_id, 
  	p.product_name, 
  	ws.utm_source
),
monthly_revenue AS (
  SELECT
    DATE_FORMAT(ws.created_at, '%Y-%m') AS year_and_month,
    p.product_name,
    ws.utm_source,
    COUNT(DISTINCT ws.user_id) AS new_users,
    SUM(ur.total_revenue) AS total_revenue
  FROM website_sessions ws
  JOIN user_revenue ur 
  	ON ws.user_id = ur.user_id 
  	AND ws.utm_source = ur.utm_source
  JOIN products p 
  	ON p.product_name = ur.product_name
  GROUP BY 
  	year_and_month, 
  	p.product_name, 
  	ws.utm_source
),
cumulative_revenue AS (
  SELECT *,
    SUM(total_revenue) OVER (
    	PARTITION BY 
    		product_name, 
    		utm_source 
    	ORDER BY year_and_month
    ) AS cumulative_revenue,
    SUM(new_users) OVER (
    	PARTITION BY 
    		product_name, 
    		utm_source 
    	ORDER BY year_and_month
    ) AS cumulative_users
  FROM monthly_revenue
)
SELECT
  year_and_month,
  product_name,
  utm_source,
  cumulative_revenue / cumulative_users AS arpu
FROM cumulative_revenue
ORDER BY 
	year_and_month DESC, 
	cumulative_revenue / cumulative_users DESC;

/*
1.6 - Insight (3 points)

Assumptions:
 - We are considering the total revenue by a user across every order they've placed
 - We are mainly focusing on the primary product of each order
 - We are assuming that user acquisition channels remain constant and do not fluctuate through the analysis period
 
Insight: We are noticing that, for the most recent month, The Forever Love Bear product is generating the most revenue in both google and bing searches.  
	We would recommend that the company should increase the bid size for this product to maximize the revenue gained from sales.
	
Limitations / Caveats:
 - This analysis primarily focuses on the primary product in each user's order, which might not account for the complete revenue
 	potential of secondary products
 - The user acquisition channels are assumed to be constant, meaning that if they change over time it could affect our average revenue trends
 - Seasonality in sales or customer behavior affects average revenue, so it is essential to analyze data over a wide period of time for more accruate conclusions

*/


SELECT DISTINCT product_name,
	price_usd,
	cogs_usd,
	(price_usd - cogs_usd)/price_usd AS profit_percentage
FROM order_items oi 
JOIN products p 
	ON oi.product_id = p.product_id 
GROUP BY oi.product_id;



