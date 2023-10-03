/*
hostname: lmu-dev-01.isba.co
username: lmu_dba
password: go_lions
database: tahoe_fuzzy_factory
port: 3306
*/

/*
Key Tables:
1. website_sessions
2. website_pageviews
3. orders
*/
SELECT *
FROM website_sessions
WHERE website_session_id = 1059;

SELECT *
FROM website_pageviews
WHERE website_session_id = 1059;

SELECT *
FROM orders
WHERE website_session_id = 1059;


/*
UTM Tracking Parameters
*/
SELECT DISTINCT utm_source, utm_campaign
FROM website_sessions
ORDER BY utm_source;


/*
1 - Traffic Source Analytics & Optimization
*/

/*
1.1 - Top Traffic Sources
From: Kara (CEO)
Subject: Site Traffic Breakdown
Date: April 12, 2012

We've been live for almost a month and starting to generate sales. Can you help me understand where the bulk of our website 
sessions are coming from through yesterday (April 12, 2012). 
I'd like to see a breakdown by UTM source, campaign, and referring domain.

Expected results header:
utm_source|utm_campaign|http_referer           |sessions|
----------+------------+-----------------------+--------+
*/
SELECT 
	utm_source,
	utm_campaign,
	http_referer,
	COUNT(website_session_id) AS sessions
FROM website_sessions ws
WHERE created_at < '2012-04-12'
GROUP BY 
	utm_source, 
	utm_campaign, 
	http_referer
ORDER BY sessions DESC;
	




/*
1.1 - Insight
 - Our biggest traffic source is from google as a nonbranded search, meaning the customers are searching for a generic stuffed animal and then clicking
 		on our website.  We should dig deeper into the gsearch nonbranded searches so we can see if these are converting to sales or if people are
 		just checking our website out.
*/


/*
1.2 - Traffic Source Conversion Rates
From: Robert (Marketing Director)
Subject: gsearch conversion rate
Date: April 14, 2012
Looks like gsearch nonbrand is our major traffic source, but we need to understand if those sessions are driving sales.
Please calculate the conversion rate (CVR) from session to order. 
Based on what we're paying for clicks, we'll need a 4% minimum CVR to make the numbers work. 
If we're much lower, we'll reduce bids. If we're higher, we can increase bids to drive more volume.

Expected results header:
sessions|orders|session_to_order_cvr|
--------+------+--------------------+
*/
SELECT COUNT(DISTINCT ws.website_session_id) AS sessions,
	COUNT(DISTINCT CASE
		WHEN o.order_id IS NOT NULL THEN ws.website_session_id
	END) AS orders,
	COUNT(DISTINCT CASE
		WHEN o.order_id IS NOT NULL THEN ws.website_session_id 
	END) / COUNT(DISTINCT ws.website_session_id) * 100 AS session_to_order_csv
FROM website_sessions ws 
LEFT JOIN orders o 
	ON ws.website_session_id = o.website_session_id
WHERE ws.utm_source = 'gsearch' AND ws.utm_campaign = 'nonbrand'
	AND ws.created_at < '2012-04-12';
	

/*
1.2 - Insight
 - The conversion rate is 2.89%, which is lower than the minimum of 4%.
 	We should reduce bids on google search nonbranded searches since it is not giving us a high enough conversion rate
*/







/*
1.3 - Traffic Source Trends
From: Robert (Marketing Director)
Subject: gsearch volume trends
Date: May 10, 2012
Based on your conversion rate analysis, we bid down gsearch nonbrand on April 15, 2012. 
Can you pull gsearch nonbranded trended session volume by week? We want to see if the bid changes caused volume to drop.

Expected results header:
week_start_date|sessions|
---------------+--------+
*/

SELECT 
	MIN(DATE(created_at)) AS week_start_date,
	COUNT(website_session_id) AS sessions,
FROM website_sessions ws
WHERE created_at < '2012-05-10'
	AND utm_source = 'gsearch'
	AND utm_campaign = 'nonbrand'
GROUP BY WEEK(created_at);

/*
1.3 - Insight
 - The bidding down did affect the gsearch nonbranded session volume, with the volume dropping by approximately 30%
 - Next time, calculate the week-over-week percentage change with the LAG window function, and adding the conversion rate
 	to see if it made any difference with bidding down
*/








/*
1.4 - Traffic Source Bid Optimization
From: Robert (Marketing Director)
Subject: gsearch device-level performance
Date: May 11, 2012
I was trying our site on my mobile device, and the UX wasn't great. 
Can you please pull conversion rates from session to order by device type? 
If desktop performance is better than mobile, we can bid up for desktop to get more volume.

Expected results header:
device_type|sessions|orders|cvr   |
-----------+--------+------+------+
*/
SELECT device_type,
	COUNT(ws.website_session_id) AS sessions,
	COUNT(o.order_id) AS orders,
	ROUND((COUNT(order_id) / COUNT(ws.website_session_id)) * 100, 2) AS cvr
FROM website_sessions ws 
LEFT JOIN orders o 	
	ON ws.website_session_id = o.website_session_id 
WHERE ws.created_at < '2012-05-11'
	AND utm_source = 'gsearch'
GROUP BY device_type;



/*
1.4 - Insight
Mobile conversion is much less than desktop, so we should increase bids for the desktop
*/








/*
1.5 - Granular Segment Trends
From: Robert (Marketing Director)
Subject: gsearch device-level trends
Date: June 09, 2012
After your device-level conversion rate analysis, we realized desktop was doing well so we bid up our 
gsearch nonbrand desktop campaigns up on May 19, 2012. 
Please generate a weekly trend report for desktop and mobile so we can see the impact on volume. 
Use April 14, 2012 until the bid change as a baseline.

Expected results header:
week_start_date|desktop_sessions|mobile_sessions|
---------------+----------------+---------------+
*/

SELECT 
	DATE(MIN(created_at)) AS week_start_date,
	COUNT(
		CASE
			WHEN device_type = 'desktop' THEN website_session_id
		END
	) AS desktop_sessions,
	COUNT(
		CASE
			WHEN device_type = 'mobile' THEN website_session_id
		END
	) AS mobile_sessions
FROM website_sessions ws
WHERE created_at BETWEEN '2012-04-14' AND '2012-06-09'
	AND utm_source = 'gsearch'
	AND utm_campaign = 'nonbrand'
GROUP BY WEEK(created_at);


/*
1.5 - Insight
 - Mobile sessions are lagging behind desktop sessions, even before the bid of changing the baseline.  The result of this change
 	was that it increased the desktop sessions per week by a wide margin and further reduced the mobile sessions. 
*/


