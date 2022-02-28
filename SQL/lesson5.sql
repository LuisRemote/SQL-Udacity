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
