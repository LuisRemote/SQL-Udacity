--=== Quiz 1: Full Outer Join ===--
-- Say you're an analyst at Parch & Posey and you want to see:
-- Each account who has a sales rep that has an account (all of the
-- columns in these returned rows will be full)
-- But also each account that does not have a sales rep and each
-- sales rep that does not have an account (some of the columns
-- in these returned rows will be empty)
SELECT a.name account, s.name
FROM accounts a
FULL OUTER JOIN sales_reps s ON a.sales_rep_id=s.id;

SELECT *
FROM accounts a
FULL OUTER JOIN sales_rep_id ON a.sales_rep_id = s.id
WHERE a.sales_rep_id IS NULL OR s.id IS NULL;

--=== Quiz 2: JOINs with Comparison Operators ===--
-- Write a query that left joins the accounts table and the sales_reps
-- tables on each sale rep's ID number and joins it using the < comparison
-- operator on accounts.primary_poc and sales_reps.name
SELECT a.name, a.primary_poc, s.name rep
FROM accounts a
LEFT JOIN sales_reps s ON a.sales_rep_id = s.id
AND a.primary_poc < s.name

--=== Quiz 3: Self JOINs ===--
-- One of the most common use cases for self JOINs is in cases where
-- two events occurred, one after another.
SELECT w1.id AS w1_id,
       w1.account_id AS w1_acc_id,
       w1.occurred_at AS w1_occ_at,
       w1.channel AS w1_channel,
       w2.id AS w2_id,
       w2.account_id AS w2_acc_id,
       w2.occurred_at AS w2_occ_at,
       w2.channel AS w2_channel
FROM web_events AS w1
LEFT JOIN web_events AS w2
ON w1.account_id = w2.account_id
AND w2.occurred_at > w1.occurred_at
AND w2.occurred_at <= w1.occurred_at + INTERVAL '1 day'
ORDER BY w1.account_id, w2.occurred_at

--== Quiz 4: Union ===--
-- Write a query that uses UNION ALL on two instances (and selecting all columns) of
-- the accounts table. Then inspect the results and answer the subsequent quiz
SELECT *
FROM accounts
UNION ALL
SELECT *
FROM accounts

-- Add a WHERE clause to each of the tablese that you unioned in the query above, filtering
-- the first table where name equals 'Walmart' and filtering the second table where name
-- equals 'Disney'. Inspect the results then answer the subsequent quiz
SELECT *
FROM accounts
WHERE name = 'Walmart'
UNION ALL
SELECT *
FROM accounts
WHERE name = 'Disney'

-- Perform the union in your first query, in a CTE, your result should have a count of 2
-- for each name
WITH double_accounts AS (
SELECT *
FROM accounts
UNION ALL
SELECT *
FROM accounts)

SELECT name, COUNT(name) AS events
FROM double_accounts
GROUP BY name

-- Joining Subqueries
SELECT COALESCE(orders.date, web_events.date) AS date,
orders.active_sales_reps,
orders.orders,
web_events.web_visits
FROM (
  SELECT DATE_TRUNC('day', o.occurred_at) AS date,
  COUNT(a.sales_rep_id) AS active_sales_reps,
  COUNT(o.id) AS orders
  FROM   accounts a
  JOIN   orders o
  ON     o.account_id = a.id
  GROUP BY 1
) orders
FULL JOIN
(
  SELECT DATE_TRUNC('day', we.occurred_at) AS date,
  COUNT(we.id) AS web_visits
  FROM   web_events we
  GROUP BY 1
) web_events
ON web_events.date = orders.date
ORDER BY 1 DESC
