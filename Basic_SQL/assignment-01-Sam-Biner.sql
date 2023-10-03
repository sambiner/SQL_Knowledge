-- 1. How many articles were published between December 1, 2022, and December 25, 2022, in the nyt_article table?

SELECT COUNT(main_headline)
FROM nyt_article na
WHERE pub_date BETWEEN '2022-12-01' AND '2022-12-31';

-- 2. What is the average word count per article for articles published on and after November 2, 2022, in the nyt_article table?

SELECT AVG(word_count)
FROM nyt_article na
WHERE pub_date >= '2022-11-02';

-- 3. What is the minimum and maximum pub_date for articles published between October 1, 2022, and October 31, 2022, in the nyt_article table?

SELECT MIN(pub_date) AS MinDate,
	MAX(pub_date) AS MaxDate
FROM nyt_article na
WHERE pub_date BETWEEN '2022-10-01' AND '2022-10-31';

-- 4. How many total words were published for articles published in November 2022 in the nyt_article table?

SELECT SUM(word_count)
FROM nyt_article na
WHERE pub_date BETWEEN '2022-11-01' AND '2022-11-31';