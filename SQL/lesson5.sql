-- Lesson 5:
-- SQL Data Cleaning


-- 3. Quiz: LEFT & RIGHT
-- 3.1 In the accounts table, there is a column holding the website for each
-- company. Pull these extensions and provide how many of each website type
-- exist in the accounts table
SELECT RIGHT(a.website, 3) AS type, COUNT(*) AS events
FROM accounts AS a
GROUP BY 1
ORDER BY 2 DESC;

-- 3.2 There is much debate about how much the name (or event the first letter
-- of a company name) matters. Use the accounts table to pull the first letter
-- of each company name to see the distribution of company names that being
-- with each letter (or number).
SELECT LEFT(UPPER(name), 1) letter, COUNT(*) events
FROM accounts
GROUP BY 1
ORDER BY 2 DESC;

-- 3.3 Use the accounts table and a CASE statement to create two groups: one
-- group of company names that start with a number and a second group of those
-- company names that start with a letter. What a proportion of company names
-- start with a letter?
SELECT SUM(num) nums, SUM(letter) letters
FROM (
SELECT name, CASE WHEN LEFT(UPPER(name), 1) IN ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9')
             THEN 1 ELSE 0 END AS num,
	     CASE WHEN LEFT(UPPER(name), 1) IN ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9')
             THEN 0 ELSE 1 END AS letter
FROM accounts) t1;

-- 3.4 Consider vowels as (a,e,i,o,u). What proportion of company names start
-- whit a vowel, and what percent start with anything else?
SELECT SUM(vowel) vowels, SUM(other) others
FROM (SELECT name, CASE WHEN LEFT(UPPER(name), 1) IN ('A', 'E', 'I', 'O', 'U')
             THEN 1 ELSE 0 END AS vowel,
	     CASE WHEN LEFT(UPPER(name), 1) IN ('A', 'E', 'I', 'O', 'U')
	     THEN 0 ELSE 1 END AS other
FROM accounts) t1;

-- Quiz 6: POSITION, STRPOS & SUBSTR

-- 6.1 Use the accounts table to create first and last name columns that hold
-- the first and last names for the primary_poc (Mi solucion)
SELECT LEFT(primary_poc, STRPOS(primary_poc, ' ')-1) AS name
       RIGHT(primary_poc, LENGTH(primary_poc)-STRPOS(primary_poc, ' ') AS last_name
FROM accounts;

-- 6.2 Now see if you can do the same thing for every rep name in the sales_reps
-- table. Again provide first and last name columns (Mi solucion)
SELECT LEFT(name, STRPOS(name, ' ')-1) AS name,
       RIGHT(name, LENGTH(name)-STRPOS(name, ' ')) AS last_name
FROM sales_reps;

-- Quiz 9: CONCAT

-- 9.1 Each company in the accounts table wants to create email address for
-- each primary_poc. The email address should be the first name of the
-- primary_poc . last name primary_poc @ company name .com. (Mi solucion)
WITH table1 AS (
SELECT  LEFT(primary_poc, STRPOS(primary_poc, ' ')-1) AS poc_name,
	RIGHT(primary_poc, LENGTH(primary_poc)-STRPOS(primary_poc, ' ')) AS poc_last,
	name AS company
FROM accounts
)

SELECT CONCAT(poc_name,'.',poc_last,'@',company,'.com') AS email
FROM table1;

-- 9.2 You may have noticed that in the previous solution some of the company
-- names include spaces, which will certainly not work in an email address.
-- See if you can create an email address that will work by removing all of
-- the spaces in the account name, but otherwise your solution should be just
-- as in question 1.
WITH table1 AS (
SELECT LEFT(primary_poc, STRPOS(primary_poc, ' ')-1) AS poc_name,
       RIGHT(primary_poc, LENGTH(primary_poc)-STRPOS(primary_poc, ' ')) AS poc_last,
       REPLACE(name, ' ', '') AS company
       FROM accounts
)

SELECT CONCAT(poc_name,'.',poc_last,'@',company,'.com') AS email
FROM table1;

-- 9.3 We would also like to create an initial password, which they will change
-- after their first log in. The first password will be the first letter of the
-- primary_poc's first name (lowercase), then the last letter of their first
-- name (lowercase), the first letter of their last name (lowercase), the last
-- letter of their last name (lowercase), the number of letters in their first
-- name, the number of letters in their last name, and then the name of the
-- company they are working with, all capitalized with no spaces
WITH table1 AS (
SELECT LEFT(primary_poc, STRPOS(primary_poc, ' ')-1) AS poc_name,
       RIGHT(primary_poc, LENGTH(primary_poc)-STRPOS(primary_poc, ' ')) AS poc_last,
       UPPER(REPLACE(name, ' ', '')) AS company
FROM accounts),
table2 AS (
SELECT LOWER(LEFT(poc_name, 1)) AS one,
       LOWER(RIGHT(poc_name, 1)) AS two,
       LOWER(LEFT(poc_last, 1)) AS three,
       LOWER(RIGHT(poc_last, 1)) AS four,
       LENGTH(poc_name) AS five,
       LENGTH(poc_last) AS six,
       company AS seven
FROM table1)

SELECT CONCAT(one,two,three,four,five,six,seven) AS pdw
FROM table2;

-- Quiz 12: CAST
-- For this set of quiz questions, you are going to be working with a single
-- table in the environment below. This is a different dataset than Parch
-- & Posey, as all of the data in that particular dataset were already clean.
SELECT *,
       CONCAT(SUBSTR(date,7,4),'-',SUBSTR(date,1,2),'-',SUBSTR(date,4,2)) AS new_date,
       CAST(CONCAT(SUBSTR(date,7,4),'-',SUBSTR(date,1,2),'-',SUBSTR(date,4,2)) AS date) AS formated_date
FROM sf_crime_data;

-- Quiz 15: COALESCE
-- In this quiz, we will walk through the previous example using the following
-- task list. We will use the COALESCE function to complete the orders record
-- for the row in the table output
SELECT COALESCE(a.id, o.id) AS filled_id,
a.name, a.website, a.lat, a.long,
a.primary_poc, a.sales_rep_id,
COALESCE(o.account_id, a.id) AS new_account_id,
COALESCE(o.standard_qty, 0) AS standard_qty,
COALESCE(o.poster_qty, 0) AS poster_qty,
COALESCE(o.gloss_qty, 0) AS gloss_qty,
COALESCE(o.total, 0) AS total,
o.occurred_at,
COALESCE(o.standard_amt_usd, 0) AS standard_amt_usd,
COALESCE(o.gloss_amt_usd, 0) AS gloss_amt_usd,
COALESCE(o.poster_amt_usd, 0) AS poster_amt_usd,
COALESCE(o.total_amt_usd, 0) AS total_amt_usd
FROM accounts a
LEFT JOIN orders o
ON a.id = o.account_id;
--WHERE o.total IS NULL;




