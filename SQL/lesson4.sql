-- Your first subquery
SELECT channel, AVG(total) as avg_per_day
FROM
(SELECT DATE_TRUNC('day', occurred_at) AS day,
	channel,
    COUNT(*) as total
FROM web_events
GROUP BY 1, 2
) sub
GROUP BY 1
ORDER BY 1


-- 7. More On Subqueries
SELECT AVG(standard_qty) AS standard_avg,
       AVG(gloss_qty) AS gloss_avg,
       AVG(poster_qty) AS poster_avg,
       SUM(total_amt_usd) AS total_usd
FROM orders
WHERE DATE_TRUNC('month', occurred_at) =
  (SELECT DATE_TRUNC('month', MIN(occurred_at)) AS month
  FROM orders)


-- 8. Subquery Mania
-- 1.
SELECT s.name AS sal_name, r.name AS reg_name, SUM(o.total_amt_usd) AS total_usd
FROM sales_reps AS s
JOIN region AS r
ON s.region_id = r.id
JOIN accounts AS a
ON s.id=a.sales_rep_id
JOIN orders AS o
ON o.account_id=a.id
GROUP BY s.name, r.name
ORDER BY 3 DESC;
--8.1  de esa es la misma que t3, en la t2 solamente estoy usando para sacar region y el
-- maximo de usd de cada region, por lo tanto puedo hacer un join para sacar el nombre
SELECT t3.sal_name, t3.reg_name, t3.total_usd
FROM (SELECT reg_name, MAX(total_usd) as total_usd
     FROM (SELECT s.name AS sal_name, r.name AS reg_name, SUM(o.total_amt_usd) AS total_usd
           FROM sales_reps AS s
           JOIN region AS r
           ON s.region_id = r.id
           JOIN accounts AS a
           ON s.id=a.sales_rep_id
           JOIN orders AS o
           ON o.account_id=a.id
           GROUP BY s.name, r.name
      ORDER BY 3 DESC) t1
      GROUP BY 1
ORDER BY 2 DESC) t2
JOIN (SELECT s.name AS sal_name, r.name AS reg_name, SUM(o.total_amt_usd) AS total_usd
     FROM sales_reps AS s
     JOIN region AS r
     ON s.region_id = r.id
     JOIN accounts AS a
     ON s.id=a.sales_rep_id
     JOIN orders AS o
     ON o.account_id=a.id
     GROUP BY s.name, r.name
     ORDER BY 3 DESC) t3
ON t2.reg_name = t3.reg_name AND t2.total_usd = t3.total_usd


-- 8.2 for the region with the largest sum of sales (total_amt_usd), how many total (count)
-- orders where place?
SELECT r.name AS region, COUNT(*) AS orders
FROM region AS r
JOIN sales_reps AS s
ON r.id=s.region_id
JOIN accounts AS a
ON s.id=a.sales_rep_id
JOIN orders AS o
ON a.id=o.account_id
JOIN (SELECT r.name AS reg_name, SUM(o.total_amt_usd) AS total_amt_usd
FROM region AS r
JOIN sales_reps AS s
ON r.id=s.region_id
JOIN accounts AS a
ON s.id=a.sales_rep_id
JOIN orders AS o
ON a.id=o.account_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1) t1
ON t1.reg_name=r.name
GROUP BY 1



-- 8.3 How many accounts had more total purchases than the account name which
-- has bought the most standard_qty paper throughout their lifetime as a customer?
SELECT COUNT(*) AS total
FROM (SELECT a.name AS name, SUM(o.total) as orders
      FROM accounts AS a
      JOIN orders as o
      ON a.id=o.account_id
      GROUP BY 1
      HAVING SUM(o.total) > (SELECT orders
               FROM (SELECT a.name AS name, SUM(o.standard_qty) AS total_standard, SUM(o.total) AS orders
                    FROM accounts AS a
	  	    JOIN orders AS o
		    ON a.id=o.account_id
		    GROUP BY 1
		    ORDER BY 2 DESC
		    LIMIT 1) t1)
	       ORDER BY 2 DESC) t2


-- 8.4 For the customer that spent the most (in total over their lifetime as a customer) total_amt_usd,
-- how many web_events did they have for each channel?
SELECT a.name AS name, w.channel, COUNT(*) AS events
FROM web_events AS w
JOIN accounts AS a                                 
ON w.account_id=a.id
WHERE a.name = (SELECT t1.name
	FROM (SELECT a.name AS name, SUM(o.total_amt_usd) AS total_usd
		FROM accounts AS a
		JOIN orders AS o
		ON a.id=o.account_id
		GROUP BY 1
		ORDER BY 2 DESC
	LIMIT 1) t1)
GROUP BY 1, 2
ORDER BY 3 DESC

-- 8.5 What is the lifetime average amount spent in terms of total_amt_usd for the top 10
-- total spending accounts
SELECT AVG(t1.total_usd) AS avg_usd
FROM (SELECT a.name AS name, SUM(total_amt_usd) AS total_usd
	FROM accounts AS a
	JOIN orders AS o
	ON a.id=o.account_id
	GROUP BY 1
	ORDER BY 2 DESC
	LIMIT 10) t1

-- 8.6 What is the lifetime average amount spent in terms of total_amt_usd, including
-- only the companies that spent more per order, on average, than the average of all orders
SELECT AVG(t1.total_usd) AS life_avg_usd
FROM
(SELECT a.name AS name, AVG(o.total_amt_usd) AS total_usd
FROM accounts AS a
JOIN orders AS o
ON a.id=o.account_id
GROUP BY 1
HAVING AVG(o.total_amt_usd) > (SELECT AVG(o.total_amt_usd) AS avg_usd
	FROM accounts AS a
	JOIN orders AS o
	ON a.id=o.account_id) ) t1;

-- 13. Quiz: WITH
-- Essentially a WITH statement performs the same task as a Subquery.

-- 13.1 Provide the name of the sales_rep in each region with the largest amount of total_amt_usd sales
WITH table1 AS (SELECT s.name AS sales_name, r.name AS reg_name, SUM(o.total_amt_usd) AS total_usd
	FROM region AS r
	JOIN sales_reps AS s
	ON r.id=s.region_id
	JOIN accounts AS a
	ON s.id=a.sales_rep_id
	JOIN orders AS o
	ON o.account_id=a.id
	GROUP BY 1, 2
	ORDER BY 3 DESC),

     table2 AS (SELECT t1.reg_name, MAX(t1.total_usd) as max_usd
	FROM (
        SELECT s.name AS sales_name, r.name AS reg_name, SUM(o.total_amt_usd) AS total_usd
        FROM region AS r
        JOIN sales_reps AS s
        ON r.id=s.region_id
        JOIN accounts AS a
        ON s.id=a.sales_rep_id
        JOIN orders AS o
        ON o.account_id=a.id
        GROUP BY 1, 2
        ORDER BY 3 DESC
        ) t1
	GROUP BY 1
	ORDER BY 2 DESC)

SELECT tb1.sales_name, tb2.reg_name, tb2.max_usd
FROM table1 AS tb1
JOIN table2 AS tb2
ON t1.reg_name=t2.reg_name AND t1.total_usd=t2.max_usd
ORDER BY 3 DESC

-- 13.1 (Second version)
-- Provide the name of the sales_rep in each region with the largest amount of total_amt_usd sales.
WITH t1 AS (
	SELECT s.name AS sale_name, r.name AS region_name, SUM(o.total_amt_usd) AS total_usd
	FROM region AS r
	JOIN sales_reps AS s
	ON r.id=s.region_id
	JOIN accounts AS a
	ON s.id=a.sales_rep_id
	JOIN orders AS o
	ON a.id=o.account_id
	GROUP BY 1, 2
	ORDER BY 3 DESC),

     t2 AS (
	SELECT region_name, MAX(total_usd) AS total_usd
	FROM t1
	GROUP BY 1
)

SELECT t1.sale_name, t1.region_name, t1.total_usd
FROM t1
JOIN t2
ON t1.region_name=t2.region_name AND t1.total_usd=t2.total_usd

-- 13.2 For the region with the largest sales total_amt_usd, how many total orders were placed?
WITH table1 AS (
  SELECT r.name AS region_name, SUM(total_amt_usd) AS total_usd
  FROM region AS r
  JOIN sales_reps AS s
  ON r.id=s.region_id
  JOIN accounts AS a
  ON s.id=a.sales_rep_id
  JOIN orders AS o
  ON o.account_id=a.id
  GROUP BY 1
  ORDER BY 2 DESC
  LIMIT 1),

table2 AS (
  SELECT r.name AS region_name, COUNT(*) AS orders
  FROM region AS r
  JOIN sales_reps AS s
ON r.id=s.region_id
JOIN accounts AS a
ON s.id=a.sales_rep_id
JOIN orders AS o
ON a.id=o.account_id
GROUP BY 1
ORDER BY 2 DESC)

SELECT t2.region_name, t2.orders
FROM table1 AS t1
JOIN table2 AS t2
ON t1.region_name=t2.region_name

-- 13.2 Solucion propuesta por Udacity
WITH t1 AS (
   SELECT r.name region_name, SUM(o.total_amt_usd) total_amt
   FROM sales_reps s
   JOIN accounts a
   ON a.sales_rep_id = s.id
   JOIN orders o
   ON o.account_id = a.id
   JOIN region r
   ON r.id = s.region_id
   GROUP BY r.name),
t2 AS (
   SELECT MAX(total_amt)
   FROM t1)
SELECT r.name, COUNT(o.total) total_orders
FROM sales_reps s
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id
JOIN region r
ON r.id = s.region_id
GROUP BY r.name
HAVING SUM(o.total_amt_usd) = (SELECT * FROM t2);

-- 13.3 How many accounts had more total purchases than the account name which has bought
-- the most standard_qty paper throughout their lifetime as a customer?
WITH table1 AS (
SELECT a.id AS id, a.name AS name, SUM(o.standard_qty) AS total_standard, SUM(o.total) AS purchases
FROM accounts AS a
JOIN orders AS o
ON a.id=o.account_id
GROUP BY 1, 2
ORDER BY 3 DESC
LIMIT 1),

table2 AS (
	SELECT purchases
	from table1),

table3 AS (
	SELECT a.name, SUM(o.total) AS orders
	FROM accounts AS a
	JOIN orders AS o
	ON a.id=o.account_id
	GROUP BY 1)

SELECT COUNT(*) AS events
FROM table3 as t3
WHERE t3.orders > (SELECT * FROM table2)

-- 13.3 (Solucion propuesta por Udacity
WITH t1 AS (
  SELECT a.name account_name, SUM(o.standard_qty) total_std, SUM(o.total) total
  FROM accounts a
  JOIN orders o
  ON o.account_id = a.id
  GROUP BY 1
  ORDER BY 2 DESC
  LIMIT 1), 
t2 AS (
  SELECT a.name
  FROM orders o
  JOIN accounts a
  ON a.id = o.account_id
  GROUP BY 1
  HAVING SUM(o.total) > (SELECT total FROM t1))
SELECT COUNT(*)
FROM t2;

-- 13.4 For the customer that spent the most (in total over their lifetime as a customer) total_amt_usd,
-- how many web_events did they have for each channel?
...


























