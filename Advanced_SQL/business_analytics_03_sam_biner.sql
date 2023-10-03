/*
Key Table for Conversion Funnels: website_pageviews

In conversion funnel analysis, we inspect each step in the conversion flow to see how many users drop off 
and how many continue on to the next step.
*/
SELECT *
FROM website_pageviews
WHERE website_session_id = 1059;

/*
Conversion Funnel SQL Analytics Approach
1. Identify the sessions in question.
2. Pull in the relevant pageviews.
3. Flag each session as having made it to certain funnel steps.
4. Perform a summary analysis.
*/

/*
3.1 - Building Conversion Funnels
From: Cheryl (Website Manager)
Subject: Help Analyzing Conversion Funnels
Date: September 05, 2012
I'd like to understand where we lose our gsearch visitors between the new /lander-1 page and placing an order.
Can you build us a full conversion funnel, analyzing how many customers make it to each step?
Start with /lander-1 and build the funnel all the way to our thank you page. Please use data since August 5th.


STEP 1: select all pageviews for relevant sessions
STEP 2: flag each page as the specific funnel step
STEP 3: create the session-level conversion funnel view
STEP 4: aggregate the data to assess funnel performance

Expected results header:
lander_ctr|products_ctr|mrfuzzy_ctr|cart_ctr|shipping_ctr|billing_ctr|
----------+------------+-----------+--------+------------+-----------+
*/
-- ChatGPT ANSWER *FOR MY PERSONAL RECORDS*
-- STEP 1: Selecting all relevant pageviews during the relevant time for gsearch sources
WITH relevant_sessions_and_pageviews AS (
    SELECT
        ws.website_session_id,
        ws.created_at,
        wp.pageview_url
    FROM website_sessions ws
    LEFT JOIN website_pageviews wp
		ON ws.website_session_id = wp.website_session_id
    WHERE ws.created_at BETWEEN '2012-08-05' AND '2012-09-04 23:59:59' 
    	AND ws.utm_source = 'gsearch'
    ORDER BY website_session_id,
		created_at
),
-- STEP 2: 
flagged_pageviews AS (
    SELECT
        website_session_id,
        pageview_url,
        CASE
	        WHEN pageview_url LIKE '/lander-1' THEN 'lander'
            WHEN pageview_url LIKE '/products' THEN 'products'
            WHEN pageview_url LIKE '/the-original-mr-fuzzy' THEN 'mrfuzzy'
            WHEN pageview_url LIKE '/cart' THEN 'cart'
            WHEN pageview_url LIKE '/shipping' THEN 'shipping'
            WHEN pageview_url LIKE '/billing' THEN 'billing'
            WHEN pageview_url LIKE '/thank-you-for-your-order' THEN 'thankyou'
            ELSE NULL
        END AS funnel_step
    FROM relevant_sessions_and_pageviews
),
-- STEP 3: 
session_funnel AS (
    SELECT
        website_session_id,
        MAX(CASE WHEN funnel_step = 'lander' THEN 1 ELSE 0 END) AS lander,
        MAX(CASE WHEN funnel_step = 'products' THEN 1 ELSE 0 END) AS products,
        MAX(CASE WHEN funnel_step = 'mrfuzzy' THEN 1 ELSE 0 END) AS mrfuzzy,
        MAX(CASE WHEN funnel_step = 'cart' THEN 1 ELSE 0 END) AS cart,
        MAX(CASE WHEN funnel_step = 'shipping' THEN 1 ELSE 0 END) AS shipping,
        MAX(CASE WHEN funnel_step = 'billing' THEN 1 ELSE 0 END) AS billing,
        MAX(CASE WHEN funnel_step = 'thankyou' THEN 1 ELSE 0 END) AS thankyou
    FROM flagged_pageviews
    GROUP BY website_session_id
)
-- STEP 4:
SELECT
    ROUND(SUM(products) * 100 / COUNT(website_session_id), 2) AS lander_ctr,
    ROUND(SUM(mrfuzzy) * 100.0 / SUM(products), 2) AS products_ctr,
    ROUND(SUM(cart) * 100.0 / SUM(mrfuzzy), 2) AS mrfuzzy_ctr,
    ROUND(SUM(shipping) * 100.0 / SUM(cart), 2) AS cart_ctr,
    ROUND(SUM(billing) * 100.0 / SUM(shipping), 2) AS shipping_ctr,
    ROUND(SUM(thankyou) * 100.0 / SUM(billing), 2) AS billing_ctr
FROM session_funnel;







WITH conversion_funnel AS (
-- STEP 1
	SELECT
	    ws.website_session_id,
	    ws.created_at,
	    wp.pageview_url,
	    -- STEP 2
	    CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END AS products_page,
	    CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_page,
	    CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page,
	    CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END AS ship_page,
	    CASE WHEN pageview_url = '/billing' THEN 1 ELSE 0 END AS bill_page,
	    CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thankyou_page
	FROM website_sessions ws
	LEFT JOIN website_pageviews wp
		ON ws.website_session_id = wp.website_session_id
	WHERE ws.created_at BETWEEN '2012-08-05' AND '2012-09-04 23:59:59' 
		AND ws.utm_source = 'gsearch'
	ORDER BY website_session_id,
		created_at
),
session_made_it_flags AS (
-- STEP 3
	SELECT website_session_id,
		MAX(products_page) AS product_made_it,
		MAX(mrfuzzy_page) AS mrfuzzy_made_it,
		MAX(cart_page) AS cart_made_it,
		MAX(ship_page) AS ship_made_it,
		MAX(bill_page) AS bill_made_it,
		MAX(thankyou_page) AS thankyou_made_it
	FROM conversion_funnel
	GROUP BY website_session_id
)
SELECT 
	ROUND(SUM(product_made_it) * 100 / COUNT(website_session_id),2) AS lander_ctr,
	ROUND(SUM(mrfuzzy_made_it) * 100 / SUM(product_made_it), 2) AS product_ctr,
	ROUND(SUM(cart_made_it) * 100 / SUM(mrfuzzy_made_it), 2) AS mrfuzzy_ctr,
	ROUND(SUM(ship_made_it) * 100 / SUM(cart_made_it), 2) AS cart_ctr,
	ROUND(SUM(bill_made_it) * 100/ SUM(ship_made_it), 2) AS shipping_ctr,
	ROUND(SUM(thankyou_made_it) * 100 / SUM(bill_made_it), 2) AS billing_ctr
FROM session_made_it_flags;


/*SELECT 
	COUNT(website_session_id) AS total_sessions,
	COUNT(CASE WHEN product_made_it = 1 THEN website_session_id ELSE NULL END) AS to_products,
	COUNT(CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END) AS to_mrfuzzy,
	COUNT(CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END) AS to_cart,
	COUNT(CASE WHEN ship_made_it = 1 THEN website_session_id ELSE NULL END) AS to_ship,
	COUNT(CASE WHEN bill_made_it = 1 THEN website_session_id ELSE NULL END) AS to_bill,
	COUNT(CASE WHEN thankyou_made_it = 1 THEN website_session_id ELSE NULL END) AS to_thankyou
FROM session_made_it_flags;*/



/*
3.1 - Insight
We should mainly focus on the billing page click through rate, since it is the lowest of the 6.  Next, we should definitely optimize mrfuzzy
and the landing page next.  We want to figure out what it happening in the billing page to make customers click off and not purchase our
products.
*/




/*
3.2 - Analyzing Conversion Funnel Tests
From: Cheryl (Website Manager)
Subject: Conversion Funnel Test Results
Date: November 10, 2012
We tested an updated billing page based on your funnel analysis. Can you take a look and see whether
/billing-2 is doing any better than the original /billing page?
We're wondering what % of sessions on those pages end up placing an order. We ran this test on all traffic,
not just for our search visitors.

STEP 1: identify when /billing-2 went live for a fair analysis
STEP 2: find billing page version seen for each session
STEP 3: select the order id to indicate if an order was placed in the session
STEP 4: summarize # of sessions, orders, and conversion rate per billing page version

Expected results header:
billing_version|sessions|orders|billing_to_order_cvr|
---------------+--------+------+--------------------+
*/
-- Step 1: Identify when /billing-2 went live for a fair analysis
-- Billing-2 created on Sept. 10th 2012 at 5:13:05am; pageivew_id = 53550
SELECT 
	MIN(website_pageview_id) AS first_pageview_id
FROM website_pageviews wp 
WHERE pageview_url LIKE '/billing-2';

-- Step 2: Find billing page version seen for each session
WITH billing_sessions AS (
	SELECT wp.website_session_id,
		pageview_url AS billing_version,
		o.order_id
	FROM website_pageviews wp
	LEFT JOIN orders o 
		ON wp.website_session_id = o.website_session_id
	WHERE website_pageview_id >= 53550
		AND wp.created_at < '2012-11-10'
		AND pageview_url IN ('/billing','/billing-2')
)
SELECT 
	billing_version,
	COUNT(website_session_id) AS sessions,
	COUNT(order_id) AS orders,
	ROUND(COUNT(order_id) * 100 / COUNT(website_session_id), 2) AS billing_to_order_cvr
FROM billing_sessions
GROUP BY billing_version;



/*
3.2 - Insight
Billing-2 is doing much better than the original billing page.  This means that we should roll out billing-2 
to all customers and monitor the cvr continuously to make sure it is continuing to do well
*/





