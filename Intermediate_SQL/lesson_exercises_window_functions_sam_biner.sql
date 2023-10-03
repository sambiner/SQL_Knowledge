/*
Aggregate Function + Subquery

01 - Return a film's title, length, the average length for 
all films with a subquery, and if the film's length is less 
than the average
*/

SELECT title, 
	length, 
	(
		SELECT AVG(length) 
		FROM film
	) AS average_length, 
	length < (
			SELECT AVG(length) 
			FROM film
		) AS less_than_avg
FROM film;







-- AGGREGATE FUNCTIONS

/*
Aggregate Function + Window Function

02 - Return a film's title, length, the average length for 
all films with a window function, and if the film's length 
is less than the average
*/

SELECT title, 
	length, 
	AVG(length) OVER() AS avg_length,
	COUNT(length) OVER() AS count_of_films,
	CASE 
		WHEN length < AVG(length) OVER() THEN 'less than' 
		ELSE 'greater than'
	END AS length_compared_to_average
FROM film;






/*
Aggregate Function + Window Function + PARTITION BY

03 - Return the film title, length, and the average length per rating
*/

SELECT 
	title, 
	length,
	rating,
	AVG(length) OVER (
		PARTITION BY rating
	) AS avgerage_length_per_rating
FROM film;






/*
PARTITION BY Multiple Columns

04 - Return the film title, length, rating, rental_duration, 
and the average length per rating and rental_duration
*/

SELECT 
	title, 
	length, 
	rating, 
	rental_duration,
	AVG(length) OVER (
		PARTITION BY rating, 
			rental_duration
	) AS avg_length_per_rating_rental_duration
FROM film;






-- RANKING FUNCTIONS

/*
ROW_NUMBER() - Number of current row within its partition

05 - Return the row number, title, rating, length for all films sorted by length within a rating partition
	 Window: all rows
*/

SELECT 
	ROW_NUMBER() OVER (
		PARTITION BY rating 
		ORDER BY length DESC
	) AS `row_number`,
	title, 
	rating, 
	length
FROM film;






/*
06 - Rank G-rated Films Based on Length

ROW_NUMBER() doesn't have duplicates
1,2,3,4,5

RANK() has duplicates and sequence gaps
1,2,2,4,5

DENSE_RANK() has duplicates but NO sequence gaps
1,2,2,3,4

PERCENT_RANK() - row's percentile
- percentage of values < the current row
- values range from 0 to 1 

CUME_DIST() - cumulative distribution
- percentage of values <= to the current row
*/
SELECT 
	ROW_NUMBER() OVER (
		PARTITION BY rating 
		ORDER BY length DESC
	) AS `row_number`,
	RANK() OVER (
		ORDER BY length DESC
	) AS len_rank,
	DENSE_RANK() OVER (
		ORDER BY length DESC
	) AS len_dense_ranks,
	PERCENT_RANK() OVER (
		ORDER BY length DESC 
	) AS len_percent_rank,
	CUME_DIST() OVER (
		ORDER BY length DESC
	) AS len_cume_dist,
	title, 
	rating, 
	length
FROM film
WHERE rating = 'G';







/*
PARTITION BY + ORDER BY

07 - Return the row number, title, rating, and length for all films
	 Reset the row number when the rating changes (each rating will have its own set of row numbers)
	 Sort results within the window by the film's length
	 Window: by rating
*/

SELECT 
	ROW_NUMBER() OVER (
		PARTITION BY rating 
		ORDER BY length DESC
	) AS len_row_number, 
	title, 
	rating, 
	length
FROM film;






/*
Filter by window function output with a CTE

08 - Return the title, rating, and length for the films shortest in length per rating

	 1. Create a CTE to hold the ranked results
	 2. Query the CTE based on the rank number
*/
WITH ranked_films AS (
	SELECT 
		title, 
		rating, 
		length,
		DENSE_RANK() OVER (
			PARTITION BY rating 
			ORDER BY length
		) AS len_rank
	FROM film
)
SELECT *
FROM ranked_films
WHERE len_rank = 1;






/*
09 - Select a film's title, rating, length, and the following per rating
	 Order matters
	 	FIRST_VALUE()
	 	LAST_VALUE()
	 Order does NOT matter
		MIN()
		MAX()
 */

SELECT 
	title, 
	rating, 
	length,
    FIRST_VALUE(length) OVER (
    	PARTITION BY rating 
    	ORDER BY length
    ) AS shortest_length,
   	LAST_VALUE(length) OVER (
   		PARTITION BY rating 
   		ORDER BY length
   		RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
   	) AS longest_length,
   	MIN(length) OVER (
   		PARTITION BY rating
   	) AS min_length,
   	MAX(length) OVER (
   		PARTITION BY rating
   	) AS max_length
FROM film;






/*
Period-Over-Period Analysis with LAG()

10 - Calculate the month-over-month rental revenue % growth for 2005
	 1. Create GROUP BY to get per month revenue
	 2. Get previous month's revenue with the LAG() window function
	    LAG() accesses a previous row
	 3. Calculate revenue % growth
	    ((current revenue - previous month's revenue) / previous month's revenue) * 100
*/

SELECT rental_month,
	rental_revenue,
	LAG(rental_revenue) OVER (
		ORDER BY rental_month
	) AS prev_month_revenue,
	(
		(rental_revenue - LAG(rental_revenue) OVER (
			ORDER BY rental_month
			)
		) / LAG(rental_revenue) OVER (
			ORDER BY rental_month
			)
	) * 100 AS revenue_growth
FROM
	(
		SELECT
			DATE_FORMAT(payment_date, '%Y-%m') AS rental_month,
			SUM(amount) AS rental_revenue
		FROM payment p
		WHERE DATE_FORMAT(payment_date, '%Y') = '2005'
		GROUP BY
			rental_month
	) AS monthly_revenue
ORDER BY
	rental_month;

SELECT 
	DATE_FORMAT(p.payment_date, '%Y-%m') AS rental_month,
	SUM(p.amount) AS rental_revenue,
	LAG(SUM(amount), 1) OVER (
		ORDER BY DATE_FORMAT(p.payment_date, '%Y-%m')
	) AS previous_month,
	(
		(SUM(amount) - LAG(SUM(amount), 1) OVER (
				ORDER BY DATE_FORMAT(p.payment_date, '%Y-%m')
			)
		)/LAG(SUM(amount), 1) OVER (
			ORDER BY DATE_FORMAT(p.payment_date, '%Y-%m')
			)
	)*100 AS growth_percentage
FROM payment p
WHERE DATE_FORMAT(p.payment_date, '%Y') = '2005'
GROUP BY rental_month;




/*
Calculating Running Totals

11 - Calculate the running revenue total when selecting the payment_id, payment_date, amount for 2005-05-24

	 Order matters when calculating running totals
*/

SELECT 
	payment_id, 
	payment_date, 
	amount, 
	SUM(p.amount) OVER (
		ORDER BY payment_date
	) AS running_total
FROM payment p
WHERE payment_date BETWEEN '2005-05-24' AND '2005-05-24 23:59:59'
ORDER BY payment_date;






/*
Calculating Running Totals for GROUPed Data

12 - Calculate the running revenue total for revenue GROUPed BY the payment date day for 2005
	 Return the day, revenue for the day, and the running total up until the current day in the result
	
	 1. Create a CTE to hold the GROUPed BY payment date day results
	 2. Query the CTE and do a SUM() window function on the revenue to get the running total
	
	 Remember, order matters
*/
WITH rental_revenue_by_day AS (
	SELECT
		LEFT(payment_date, 10) AS payment_day,
		SUM(amount) AS revenue
	FROM payment
	WHERE payment_date BETWEEN '2005-01-01' AND '2005-12-31 23:59:59'
	GROUP BY LEFT(payment_date, 10)
	ORDER BY payment_day
)
SELECT 
	payment_day,
	revenue,
	SUM(revenue) OVER (
		ORDER BY payment_day
	) AS running_daily_revenue
FROM rental_revenue_by_day;





/*
Per Group Ranking

13 - Rank films within their genre based on their rental count
	 Use DENSE_RANK()

	 The rank should reset when moving onto the next genre
*/
SELECT f.title,
	c.name,
	COUNT(rental_id) AS rental_count,
	DENSE_RANK() OVER (
		PARTITION BY c.name
		ORDER BY COUNT(*) DESC
	) AS rental_rank
FROM film f 
JOIN film_category fc 
	ON f.film_id = fc.film_id 
JOIN category c 
	ON fc.category_id = c.category_id
JOIN inventory i 
	ON f.film_id = i.film_id 
JOIN rental r 
	ON i.inventory_id = r.inventory_id
GROUP BY title;







/*
Get the Top # Per Group

14 - Get the top 3 rented films per genre

	 1. Create a CTE with the previous query
	 2. Query the CTE and filter based on the rental rank
*/

WITH genre_rental_count_rank AS (
	SELECT f.title,
		c.name,
		COUNT(rental_id) AS rental_count,
		DENSE_RANK() OVER (
			PARTITION BY c.name
			ORDER BY COUNT(*) DESC
		) AS rental_rank
	FROM film f 
	JOIN film_category fc 
		ON f.film_id = fc.film_id 
	JOIN category c 
		ON fc.category_id = c.category_id
	JOIN inventory i 
		ON f.film_id = i.film_id 
	JOIN rental r 
		ON i.inventory_id = r.inventory_id
	GROUP BY title
)
SELECT *
FROM genre_rental_count_rank
WHERE rental_rank <= '3';






/*
15 - Compare a film's replacement cost against the average replacement cost for the films within a rating.
Indicate with a boolean if the replacement cost is greater than the average.

Expected headers:
title |rating|replacement_cost|avg_cost |is_overpriced|
------|------|----------------|---------|-------------|
*/

SELECT title,
	rating,
	replacement_cost,
	AVG(replacement_cost) OVER (
		PARTITION BY rating
	) AS avg_cost,
	IF(replacement_cost > AVG(replacement_cost) OVER (
			PARTITION BY rating
		), 1, 0
	) AS is_overpriced
FROM film f
GROUP BY title;
	







/*
16 - Who is the actor with the most films in each genre?
Ties are allowed.

Hint: You can use a CTE.

Expected headers:
genre|actor_id|first_name|last_name|film_count|film_count_rank|
-----|--------|----------|---------|----------|---------------|

Approach?
*/

WITH actors_ranks AS (
	SELECT
		c.name as genre,
		a.actor_id,
		first_name,
		last_name,
		COUNT(fa.film_id) AS film_count,
		DENSE_RANK() OVER(
			PARTITION BY c.name
			ORDER BY COUNT(fa.film_id) DESC
		) AS actor_rank
	FROM category c
	JOIN film_category fc 
		ON c.category_id  = fc.category_id
	JOIN film_actor fa 
		ON fc.film_id = fa.film_id
	JOIN actor a
		ON fa.actor_id = a.actor_id
	GROUP BY c.name, actor_id
)
SELECT *
FROM actors_ranks
WHERE actor_rank = 1;

	

-- Verify the film_count for the actor with the most films in the Comedy genre





