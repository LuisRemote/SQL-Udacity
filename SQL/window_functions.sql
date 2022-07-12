-- Example 1
SELECT standard_qty,
       DATE_TRUNC('month', occurred_at) AS month,
       SUM(standard_qty) OVER (PARTITION BY DATE_TRUNC('month', occurred_at) ORDER BY occurred_at) AS running_total
FROM orders

--=== Quiz 1: Window Functions 1 ===---
SELECT standard_amt_usd,
       SUM(standard_amt_usd) OVER(ORDER BY occurred_at) AS running_total
FROM orders


--=== Quiz 2: Window Functions 2== ---
SELECT standard_amt_usd,
       DATE_TRUNC('year', occurred_at) AS year,
       SUM(standard_usd) OVER (PARTITION BY DATE_TRUNC('year',occurred_at)
			       ORDER BY occurred_at) AS running_total
FROM orders


--=== Quiz 3: Row_number & Rank() ===--
-- Ranking Total Paper Ordered by Account
-- Select the id, account_id, and total variable from the orders table, then create
-- a column called total_rank that ranks this total amount of paper ordered (from
-- highest to lowest) for each account using a partition.
-- Your final table should have these four columns
SELECT id, account_id, total,
       RANK() OVER(PARTITION BY account_id ORDER BY total DESC) AS total_rank
FROM orders


--=== Quiz 4: Aggregates in Window Functions ===--
SELECT id,
       account_id,
       standard_qty,
       DATE_TRUNC('month', occurred_at) AS month,
       DENSE_RANK() OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month',occurred_at)) AS dense_rank,
       SUM(standard_qty) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month',occurred_at)) AS sum_std_qty,
       COUNT(standard_qty) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month',occurred_at)) AS count_std_qty,
       AVG(standard_qty) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month',occurred_at)) AS avg_std_qty,
       MIN(standard_qty) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month',occurred_at)) AS min_std_qty,
       MAX(standard_qty) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month',occurred_at)) AS max_std_qty
FROM orders
--
--
SELECT id,
       account_id,
       standard_qty,
       DATE_TRUNC('month', occurred_at) AS month,
       DENSE_RANK() OVER (PARTITION BY account_id) AS dense_rank,
       SUM(standard_qty) OVER (PARTITION BY account_id) AS sum_std_qty,
       COUNT(standard_qty) OVER (PARTITION BY account_id) AS count_std_qty,
       AVG(standard_qty) OVER (PARTITION BY account_id) AS avg_std_qty,
       MIN(standard_qty) OVER (PARTITION BY account_id) AS min_std_qty,
       MAX(standard_qty) OVER (PARTITION BY account_id) AS max_std_qty
FROM orders


--=== Quiz 5: Aliases for Multiple Window Functions===--
-- Now, create and use an alias to shorten the following query (which is different
-- than the one in Derek's previous video) that has multiple window functions.
-- Name the alias account_year_window, which is more
-- descriptive than main_window in the example above.
SELECT id,
       account_id,
       DATE_TRUNC('year',occurred_at) AS year,
       DENSE_RANK() OVER account_year_window AS dense_rank,
       total_amt_usd,
       SUM(total_amt_usd) OVER account_year_window AS sum_total_amt_usd,
       COUNT(total_amt_usd) OVER account_year_window AS count_total_amt_usd,
       AVG(total_amt_usd) OVER account_year_window AS avg_total_amt_usd,
       MIN(total_amt_usd) OVER account_year_window AS min_total_amt_usd,
       MAX(total_amt_usd) OVER account_year_window AS max_total_amt_usd
FROM orders
WINDOW account_year_window AS (PARTITION BY account_id ORDER BY DATE_TRUNC('year',occurred_at))



--=== Quiz 6: Comparing a Row to Previous Row ===--
-- In the previous video, Derek outlines how to compare a row to a previous or subsequent row.
-- This technique can be useful when analyzing time-based events. Imagine you're an analyst at
-- Parch & Posey and you want to determine how the current order's total revenue ("total"
-- meaning from sales of all types of paper) compares to the next order's total revenue.

-- Modify Derek's query from the previous video in the SQL Explorer below to perform this
-- analysis. You'll need to use occurred_at and total_amt_usd in the orders table along with
-- LEAD to do so. In your query results, there should be four columns: occurred_at,
-- total_amt_usd, lead and lead_difference
-- Mi solucion es diferente a la de Udacity, pero el resultado el mismo
SELECT occurred_at, total_amt_usd,
       LEAD(total_amt_usd) OVER (ORDER BY occurred_at) AS lead,
       LEAD(total_amt_usd) OVER (ORDER BY occurred_at) - total_amt_usd AS lead_difference
FROM orders

--=== Quiz 7: Percentiles ===--

--7.1 Use the NTILE functionality to divide the accounts into 4 levels in terms of the amout of
-- standard_qty for their orders. Your resulting table should have the account_id, the
-- occurred_at time for each order, the total amount of standard_qty paper purchased, and
-- one of four levels in a standard_quartile column.
SELECT account_id, occurred_at, standard_qty,
       NTILE(4) OVER (ORDER BY standard_qty) AS standard_quartile
FROM orders
ORDER BY account_id

--7.2 Use the NTILE functionality to divide the accounts into two levels in terms of the amount
-- of gloss_qty for theirs orders. Your resulting table should have the account_id, the
-- occurred_at time for each order, the total amount of gloss_qty paper purchased, and one
-- of two levels in a gloss_half column
SELECT account_id, occurred_at, gloss_qty,
       NTILE(2) OVER (ORDER BY gloss_qty) AS gloss_half
FROM orders
ORDER BY account_id

--7.3 Use the NTILE functionality to divide the orders for each account into 100 levels in terms
-- of the amount of total_amt_usd for their orders. Your resulting table should have the
-- account_id, the occurred_at time for each order, the total amount of total_amt_usd paper
-- purchased, and one of 100 levels in a total_percentile column.
SELECT account_id, occurred_at, total_amt_usd,
       NTILE(100) OVER (ORDER BY total_amt_usd) AS total_percentile
FROM orders
ORDER BY account_id















