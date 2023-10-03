
/*
hostname: lmu-dev-01.isba.co
username: lmu_dba
password: go_lions
database: tahoe_fuzzy_factory
port: 3306
*/

/*
2 - Website Performance Analytics
*/

/*
2.1 - Top Website Pages
From: Cheryl (Website Manager)
Subject: Top Website Pages
Date: June 09, 2012
Could you help me get my head around the site by pulling the most-viewed website pages ranked by session volume?

Expected results header:
pageview_url             |sessions|
-------------------------+--------+
*/
SELECT 
	pageview_url, 
	COUNT(website_session_id) as sessions
FROM website_pageviews
WHERE created_at < '2012-06-09'
GROUP BY pageview_url
ORDER BY sessions DESC;
/*
2.1 - Insight
 - It appears that the home page is the most visited page on our company website.  I would suggest that we optimize the home page
 	since it is the most visited page on the website, so we can turn those vists into orders/sales
*/










/*
2.2 - Top Entry Pages
From: Cheryl (Website Manager)
Subject: Top Entry Pages
Date: June 12, 2012
Would you be able to pull a list of the top entry pages? I want to confirm where our users are hitting the site. 
If you could pull all entry pages and rank them on entry volume, that would be great.

Master CTEs for multi-step queries.
Steps:
1. Find the first pageview for each session id, get the entry pageview id

Expected results header:
landing_page|sessions|
------------+--------+
*/
WITH first_pageviews AS (
    SELECT 
        website_session_id, 
        MIN(website_pageview_id) AS pageview_id,
        COUNT(website_pageview_id) AS pages_viewed
    FROM website_pageviews 
    WHERE created_at < '2012-06-12'
    GROUP BY website_session_id
)
SELECT wpv.pageview_url AS landing_page,
	COUNT(fpv.website_session_id) AS sessions
FROM first_pageviews fpv
JOIN website_pageviews wpv 
	ON fpv.pageview_id = wpv.website_pageview_id
GROUP BY landing_page
ORDER BY sessions DESC;

/*
2.2 - Insight
 - The home page is the only landing page that is currently being provided to customers.  I would suggest that we create other landing pages
 	so that we can compare them to the original home page to see if any can increase the conversion rate of customers on our site.
*/








/*
2.3 - Bounce Rates
From: Cheryl (Website Manager)
Subject: Bounce Rate Analysis
Date: June 14, 2012
All of our traffic is landing on the homepage. Let's check how that landing page is performing. 
Can you pull bounce rates for traffic landing on the homepage? I would like to see three #'s:
Sessions, Bounced Sessions, and Bounce Rate (%of Sessions which Bounced).

STEP 1: find the first (MIN) website_pageview_id for relevant sessions
STEP 2: identify the landing page of each session
STEP 3: count pageviews for each session to identify bounces
STEP 4: summarize total sessions and bounced sessions by landing page

Expected results header:
landing_page|sessions|bounced_sessions|bounce_rate|
------------+--------+----------------+-----------+
*/
-- Step 1: find the first (MIN) website_pageview_id for relevant sessions
WITH first_pageview AS (
	SELECT website_session_id, 
	       MIN(website_pageview_id) AS pageview_id,
	       COUNT(website_pageview_id) AS page_views
	FROM website_pageviews 
	WHERE created_at < '2012-06-14'
	GROUP BY website_session_id
),
-- Step 2: identify the landing page of each session
session_landing_pages AS (
	SELECT 	fpv.website_session_id,
		wpv.pageview_url AS landing_page,
		fpv.page_views
	FROM first_pageview fpv
	JOIN website_pageviews wpv 
		ON fpv.pageview_id = wpv.website_pageview_id
),
-- Step 3: count pageviews for each session to identify bounces
bounced_sessions AS (
	SELECT slp.website_session_id,
		slp.landing_page
	FROM session_landing_pages slp
	WHERE slp.page_views = 1
)
SELECT slp.landing_page,
	COUNT(slp.website_session_id) AS sessions,
	COUNT(bs.website_session_id) AS bounced_sessions,
	(COUNT(bs.website_session_id) / COUNT(slp.website_session_id)) * 100 AS bounce_rate
FROM session_landing_pages slp
LEFT JOIN bounced_sessions bs 
	ON slp.website_session_id = bs.website_session_id
GROUP BY landing_page;

/*
2.3 - Insight
 - The home page is producing nearly a 60% bounce rate, which is hgih for paid search traffic.  This landing page should have a higher quality of
 	bounce rates.  I would suggest setting up an A/B test of a new landing page to see if the bounce rate improves or stays similar.
*/








/*
2.4 - Landing Page Test
From: Cheryl (Website Manager)
Subject: Help Analyzing Landing Page Test
Date: July 28, 2012

Based on your bounce rate analysis, we ran a new custom landing page (/lander-1) in a 50/50 A/B test against 
the homepage (/home) for our gsearch nonbrand traffic. 
Please pull bounce rates for the two groups so we can evaluate the new page. 
Make sure to just look at the time period where /lander-1 was getting traffic so that it's a fair comparison.

STEP 1: find out when the new page, /lander-1, launched
STEP 2: find the first (MIN) website_pageview_id for relevant sessions
STEP 3: identify the landing page of each session
STEP 4: count pageviews for each session to identify bounces
STEP 5: summarize total sessions and bounced sessions by landing page

Expected results header:
landing_page|sessions|bounced_sessions|bounce_rate|
------------+--------+----------------+-----------+
*/


/*
2.4 - Insight
???
*/


/*
2.5 - Landing Page Trend
From: Cheryl (Website Manager)
Subject: Landing Page Trend Analysis
Date: August 31, 2012
Could you pull the volume of paid gsearch nonbrand traffic landing on /home and /lander-1 trended weekly since June 1, 2012? I want to confirm the traffic is correctly routed.
Could you also pull our overall paid gsearch bounce rate trended weekly? 
I want to make sure the lander change has improved the overall picture.

STEP 1: find the first (MIN) website_pageview_id and pageviews count for relevant sessions
STEP 2: identify the landing page of each session
STEP 3: count total sessions and sessions per landing page by week
STEP 4: summarize overall bounce rate per landing page by week

Expected results header:
week_start_date|total_sessions|bounced_sessions|bounce_rate|bounce_rate_percentage_change|home_sessions|lander_sessions|
---------------+--------------+----------------+-----------+-----------------------------+-------------+---------------+
*/


/*
2.5 - Insight
???
*/

