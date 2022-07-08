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

