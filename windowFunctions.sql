-- Queries written in completion of Udacity's SQL for Data Analysis course

-- *** OVER & PARTITION BY ***
/* 
Q1. Create a running total of standard_amt_usd (in the orders table) over order time with no date truncation. 
Your final table should have two columns: one with the amount being added for each new row, and a second with the running total.
 */

SELECT standard_amt_usd,
        SUM(standard_amt_usd) OVER (ORDER BY occurred_at) AS running_total
FROM orders;

/* 
Q2. Now, modify your query from the previous quiz to include partitions. 
Still create a running total of standard_amt_usd (in the orders table) over order time,
but this time, date truncate occurred_at by year and partition by that same year-truncated occurred_at variable.
Your final table should have three columns: One with the amount being added for each row, 
one for the truncated date, and a final column with the running total within each year.
 */

SELECT standard_amt_usd,
        DATE_TRUNC('year', occurred_at) AS year,
        SUM(standard_amt_usd) OVER (PARTITION BY DATE_TRUNC('year', occurred_at) ORDER BY occurred_at) AS running_total
FROM orders;

-- *** ROW_NUMBER & RANK ***
/* 
Select the id, account_id, and total variable from the orders table,
then create a column called total_rank that ranks this total amount of paper ordered (from highest to lowest) for each account using a partition. 
Your final table should have these four columns.
*/
SELECT id, 
        account_id, 
        total,
        RANK() OVER (PARTITION BY account_id ORDER BY total DESC) AS total_rank
FROM orders;

SELECT id,
       account_id,
       standard_qty,
       DATE_TRUNC('month', occurred_at) AS month,
       DENSE_RANK() OVER (PARTITION BY account_id ) AS dense_rank,
       SUM(standard_qty) OVER (PARTITION BY account_id) AS sum_std_qty,
       COUNT(standard_qty) OVER (PARTITION BY account_id) AS count_std_qty,
       AVG(standard_qty) OVER (PARTITION BY account_id) AS avg_std_qty,
       MIN(standard_qty) OVER (PARTITION BY account_id) AS min_std_qty,
       MAX(standard_qty) OVER (PARTITION BY account_id) AS max_std_qty
FROM orders


--  *** ALIASES AND WINDOW FUNCTIONS ***
/* 
Create and use an alias to shorten the following query (which is different than the one in Derek's previous video) that has multiple window functions.
SELECT id,
    account_id,
    DATE_TRUNC('year',occurred_at) AS year,
    DENSE_RANK() OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('year',occurred_at)) AS dense_rank,
    total_amt_usd,
    SUM(total_amt_usd) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('year',occurred_at)) AS sum_total_amt_usd,
    COUNT(total_amt_usd) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('year',occurred_at)) AS count_total_amt_usd,
    AVG(total_amt_usd) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('year',occurred_at)) AS avg_total_amt_usd,
    MIN(total_amt_usd) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('year',occurred_at)) AS min_total_amt_usd,
    MAX(total_amt_usd) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('year',occurred_at)) AS max_total_amt_usd
FROM orders

Name the alias account_year_window, which is more descriptive than main_window in the example above.
*/

SELECT id,
        account_id,
        DATE_TRUNC('year',occurred_at) AS year,
        DENSE_RANK() OVER acccount_year_window AS dense_rank,
        total_amt_usd,
        SUM(total_amt_usd) OVER acccount_year_window AS sum_total_amt_usd,
        COUNT(total_amt_usd) OVER acccount_year_window AS count_total_amt_usd,
        AVG(total_amt_usd) OVER acccount_year_window avg_total_amt_usd,
        MIN(total_amt_usd) OVER acccount_year_window AS min_total_amt_usd,
        MAX(total_amt_usd) OVER acccount_year_window AS max_total_amt_usd
FROM orders
WINDOW acccount_year_window AS (PARTITION BY account_id ORDER BY DATE_TRUNC('year',occurred_at));


-- *** COMPARING ROWS TO PREVIOUS ROWS ***
/* 
Imagine you're an analyst at Parch & Posey and you want to determine how the current order's total revenue 
("total" meaning from sales of all types of paper) compares to the next order's total revenue.
Modify Derek's query from the previous video in the SQL Explorer below to perform this analysis. 
You'll need to use occurred_at and total_amt_usd in the orders table along with LEAD to do so. 
In your query results, there should be four columns: occurred_at, total_amt_usd, lead, and lead_difference.
SELECT account_id,
       standard_sum,
       LAG(standard_sum) OVER (ORDER BY standard_sum) AS lag,
       LEAD(standard_sum) OVER (ORDER BY standard_sum) AS lead,
       standard_sum - LAG(standard_sum) OVER (ORDER BY standard_sum) AS lag_difference,
       LEAD(standard_sum) OVER (ORDER BY standard_sum) - standard_sum AS lead_difference
FROM (
    SELECT account_id,
        SUM(standard_qty) AS standard_sum
    FROM orders 
    GROUP BY 1
    ) sub
*/

SELECT occurred_at,
       total_amt_usd,
       LEAD(total_amt_usd) OVER (ORDER BY total_amt_usd) AS lead,
       LEAD(total_amt_usd) OVER (ORDER BY total_amt_usd) - total_amt_usd AS lead_difference
FROM (
    SELECT occurred_at,
        SUM(total_amt_usd) AS total_amt_usd
    FROM orders 
    GROUP BY 1
    ) sub;



--  *** PERCENTILES ***
/* 
Q1. Use the NTILE functionality to divide the accounts into 4 levels in terms of the amount of standard_qty for their orders. 
Your resulting table should have the account_id, the occurred_at time for each order, the total amount of standard_qty paper purchased, 
and one of four levels in a standard_quartile column.
*/

SELECT account_id,
        occurred_at,
        standard_qty,
        NTILE(4) OVER (PARTITION BY account_id ORDER BY standard_qty) AS standard_quartile
FROM orders
ORDER BY account_id DESC;

/* 
Q2. Use the NTILE functionality to divide the accounts into two levels in terms of the amount of gloss_qty for their orders. 
Your resulting table should have the account_id, the occurred_at time for each order, the total amount of gloss_qty paper purchased, 
and one of two levels in a gloss_half column.
*/
SELECT account_id,
        occurred_at,
        gloss_qty,
        NTILE(2) OVER (PARTITION BY account_id ORDER BY gloss_qty) AS standard_half
FROM orders
ORDER BY account_id DESC;


/* 
Q3. Use the NTILE functionality to divide the orders for each account into 100 levels in terms of the amount of total_amt_usd for their orders. 
Your resulting table should have the account_id, the occurred_at time for each order, the total amount of total_amt_usd paper purchased, 
and one of 100 levels in a total_percentile column.
*/
SELECT account_id,
        occurred_at,
        total_amt_usd,
        NTILE(100) OVER (PARTITION BY account_id ORDER BY total_amt_usd) AS total_percentile
FROM orders
ORDER BY account_id DESC;