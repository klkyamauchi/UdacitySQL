-- Queries written in completion of Udacity's SQL for Data Analysis course

-- Find the total amount of poster_qty paper ordered in the orders table.
SELECT SUM(poster_qty) AS total_poster_sales
FROM orders;

-- Find the total amount of standard_qty paper ordered in the orders table.
SELECT SUM(standard_qty) AS total_standard_sales
FROM orders;

-- Find the total dollar amount of sales using the total_amt_usd in the orders table.
SELECT SUM(total_amt_usd) AS total_dollar_sales
FROM orders;

-- Find the total amount spent on standard_amt_usd and gloss_amt_usd paper for each order in the orders table. 
-- This should give a dollar amount for each order in the table.
SELECT id,
	standard_amt_usd + gloss_amt_usd AS total_standard_gloss
FROM orders;

-- Find the standard_amt_usd per unit of standard_qty paper. Your solution should use both an aggregation and a mathematical operator.
SELECT SUM(standard_amt_usd) / SUM(standard_qty) AS standard_per_unit
FROM orders;


-- Questions: MIN, MAX, & AVERAGE
-- When was the earliest order ever placed? You only need to return the date.
SELECT MIN(occurred_at) AS earliest_order
FROM orders;

-- Try performing the same query as in question 1 without using an aggregation function.
SELECT occurred_at AS earliest_order
FROM orders
ORDER BY occurred_at
LIMIT 1; 

-- When did the most recent (latest) web_event occur?
SELECT MAX(occurred_at) AS latest_event
FROM web_events;

-- Try to perform the result of the previous query without using an aggregation function.
SELECT occurred_at AS latest_event
FROM web_events
ORDER BY occurred_at DESC
LIMIT 1; 

-- Find the mean (AVERAGE) amount spent per order on each paper type, as well as the mean amount of each paper type purchased per order. 
-- Your final answer should have 6 values - one for each paper type for the average number of sales, as well as the average amount.
SELECT AVG(standard_qty) AS mean_standard_qty,
		AVG(poster_qty) AS mean_poster_qty,
        AVG(gloss_qty) AS mean_gloss_qty,
        AVG(standard_amt_usd) AS mean_standard_spent,
        AVG(poster_amt_usd) AS mean_poster_spent,
        AVG(gloss_amt_usd) AS mean_gloss_spent
FROM orders;


-- Via the video, you might be interested in how to calculate the MEDIAN. 
-- Though this is more advanced than what we have covered so far try finding - what is the MEDIAN total_usd spent on all orders?
SELECT * 
FROM (SELECT total_amt_usd
        FROM orders
        ORDER BY total_amt_usd
        LIMIT 3457) AS Table1      -- there are 6912 orders, we take the avg of orders 3457 and 3456
ORDER BY total_amt_usd DESC
LIMIT 2; 


-- Questions: GROUP BY
-- Which account (by name) placed the earliest order? 
-- Your solution should have the account name and the date of the order.
SELECT a.name, 
        o.occurred_at
FROM orders o
JOIN accounts a
ON o.account_id = a.id
ORDER BY o.occurred_at
LIMIT 1;

-- Find the total sales in usd for each account. 
-- You should include two columns - the total sales for each company's orders in usd and the company name.
SELECT a.name, 
	SUM(o.total_amt_usd) AS total_sales
FROM orders o
JOIN accounts a
ON o.account_id = a.id
GROUP BY a.name;

/* 
Via what channel did the most recent (latest) web_event occur, 
which account was associated with this web_event? Y
our query should return only three values - the date, channel, and account name.
 */
SELECT w.occurred_at,
        w.channel, 
        a.name
FROM web_events w
JOIN accounts a
ON w.account_id = a.id 
ORDER BY w.occurred_at DESC
LIMIT 1;

-- Find the total number of times each type of channel from the web_events was used. 
-- Your final table should have two columns - the channel and the number of times the channel was used.
SELECT channel, COUNT(*)
FROM web_events
GROUP BY channel;

-- Who was the primary contact associated with the earliest web_event?
SELECT a.primary_poc
FROM web_events w
JOIN accounts a
ON w.account_id = a.id
ORDER BY w.occurred_at
LIMIT 1;

/* 
What was the smallest order placed by each account in terms of total usd.
Provide only two columns - the account name and the total usd.
Order from smallest dollar amounts to largest.
*/
SELECT a.name AS name,
	MIN(o.total_amt_usd) AS smallest_order
FROM orders o
JOIN accounts a
ON o.account_id = a.id
GROUP BY a.name
ORDER BY smallest_order;

/* 
Find the number of sales reps in each region. 
Your final table should have two columns - the region and the number of sales_reps. 
Order from fewest reps to most reps.
*/
SELECT r.name AS region,
	COUNT(*) AS sales_reps
FROM region r
JOIN sales_reps s
ON s.region_id = r.id
GROUP BY region
ORDER BY sales_reps;

-- Questions: GROUP BY Part II
/* For each account, determine the average amount of each type of paper they 
purchased across their orders. Your result should have four columns - 
one for the account name and one for the average quantity purchased for 
each of the paper types for each account.
 */
 SELECT a.name AS account,
	AVG(o.standard_qty) AS avg_standard,
        AVG(o.gloss_qty) AS avg_gloss,
        AVG(o.poster_qty) AS avg_poster
FROM orders o
JOIN accounts a
ON o.account_id = a.id
GROUP BY a.name;

/* For each account, determine the average amount spent per order on each paper type. 
Your result should have four columns - 
one for the account name and one for the average amount spent on each paper type. */
SELECT a.name AS account,
	AVG(o.standard_amt_usd) AS avg_standard_spent,
        AVG(o.gloss_amt_usd) AS avg_gloss_spent,
        AVG(o.poster_amt_usd) AS avg_poster_spent
FROM orders o
JOIN accounts a
ON o.account_id = a.id
GROUP BY a.name;

/* Determine the number of times a particular channel was used in the web_events table for each sales rep.
 Your final table should have three columns - the name of the sales rep, 
 the channel, and the number of occurrences.
 Order your table with the highest number of occurrences first. */
SELECT s.name AS sales_rep,
	w.channel,
        COUNT(*) AS occurrences
FROM web_events w
JOIN accounts a
ON w.account_id = a.id
JOIN sales_reps s
ON a.sales_rep_id = s.id
GROUP BY s.name, w.channel
ORDER BY occurrences DESC;


/* Determine the number of times a particular channel was used in the web_events table for each region. 
Your final table should have three columns - the region name, the channel, and the number of occurrences. 
Order your table with the highest number of occurrences first. */
SELECT r.name, 
	w.channel,
        COUNT(*) AS occurrences
FROM web_events w
JOIN accounts a
ON w.account_id = a.id
JOIN sales_reps s
ON a.sales_rep_id = s.id
JOIN region r
ON s.region_id = r.id
GROUP BY r.name, w.channel
ORDER BY occurrences DESC;


-- Questions: DISTINCT
-- Use DISTINCT to test if there are any accounts associated with more than one region.

SELECT a.id AS account_id,
	r.id AS region_id, 
	a.name AS account_name,
        r.name AS region_name
FROM accounts a
JOIN sales_reps s
ON s.id = a.sales_rep_id
JOIN region r
ON r.id = s.region_id;   -- results in 351 rows

SELECT DISTINCT id, name
FROM accounts            -- also results in 351 rows


-- Have any sales reps worked on more than one account?
SELECT s.id,
	s.name, 
        COUNT(*) AS num_accounts
FROM accounts a
JOIN sales_reps s
ON a.sales_rep_id = s.id
GROUP BY s.id, s.name
ORDER BY num_accounts;  -- results in 50 rows

SELECT DISTINCT id, name
FROM sales_reps;        -- also results in 50 rows, every sale rep has worked on more than one acct

-- Questions: HAVING
-- How many of the sales reps have more than 5 accounts that they manage?
SELECT s.id,
	s.name,
        COUNT(*) AS accounts
FROM accounts a
JOIN sales_reps s
ON a.sales_rep_id = s.id
GROUP BY s.id, s.name
HAVING COUNT(*) > 5
ORDER BY accounts;

-- How many accounts have more than 20 orders?
SELECT a.id,
	a.name,
        COUNT(*) orders
FROM orders o
JOIN accounts a
ON o.account_id = a.id
GROUP BY a.id, a.name
HAVING COUNT(*) > 20
ORDER BY orders;

-- Which account has the most orders?
SELECT a.id,
	a.name,
        COUNT(*) num_orders
FROM orders o
JOIN accounts a
ON o.account_id = a.id
GROUP BY a.id, a.name
ORDER BY num_orders DESC
LIMIT 1;


-- Which accounts spent more than 30,000 usd total across all orders?
SELECT a.id,
	a.name,
        SUM(o.total_amt_usd) total_spent
FROM orders o
JOIN accounts a
ON o.account_id = a.id
GROUP BY a.id, a.name
HAVING SUM(o.total_amt_usd) > 30000
ORDER BY total_spent;

-- Which accounts spent less than 1,000 usd total across all orders?
SELECT a.id,
	a.name,
        SUM(o.total_amt_usd) total_spent
FROM orders o
JOIN accounts a
ON o.account_id = a.id
GROUP BY a.id, a.name
HAVING SUM(o.total_amt_usd) < 1000
ORDER BY total_spent;

-- Which account has spent the most with us?
SELECT a.id,
	a.name,
        SUM(o.total_amt_usd) total_spent
FROM orders o
JOIN accounts a
ON o.account_id = a.id
GROUP BY a.id, a.name
ORDER BY total_spent DESC
LIMIT 1;


-- Which account has spent the least with us?
SELECT a.id,
	a.name,
        SUM(o.total_amt_usd) total_spent
FROM orders o
JOIN accounts a
ON o.account_id = a.id
GROUP BY a.id, a.name
ORDER BY total_spent
LIMIT 1;


-- Which accounts used facebook as a channel to contact customers more than 6 times?
SELECT a.id,
	a.name,
        w.channel,
        COUNT(*) num_contacts
FROM web_events w
JOIN accounts a
ON w.account_id = a.id
GROUP BY a.id, a.name, w.channel
HAVING COUNT(*) > 6 AND w.channel = 'facebook' 
ORDER BY num_contacts;


-- Which account used facebook most as a channel?
SELECT a.id,
	a.name,
        w.channel,
        COUNT(*) num_contacts
FROM web_events w
JOIN accounts a
ON w.account_id = a.id
WHERE w.channel = 'facebook'
GROUP BY a.id, a.name, w.channel
ORDER BY num_contacts DESC
LIMIT 1; 

-- Which channel was most frequently used by most accounts?
SELECT a.id,
	a.name,
        w.channel,
        COUNT(*) num_contacts
FROM web_events w
JOIN accounts a
ON w.account_id = a.id
GROUP BY a.id, a.name, w.channel
ORDER BY num_contacts DESC
LIMIT 10; 


-- Questions: Working With DATEs
-- Find the sales in terms of total dollars for all orders in each year, ordered from greatest to least. Do you notice any trends in the yearly sales totals?
SELECT DATE_PART('year', occurred_at) AS date,
	SUM(total_amt_usd) AS total_sales
FROM orders
GROUP BY date
ORDER BY total_sales DESC;

-- Which month did Parch & Posey have the greatest sales in terms of total dollars? Are all months evenly represented by the dataset?
SELECT DATE_PART('month', occurred_at) AS month,
	SUM(total_amt_usd) AS total_sales
FROM orders
WHERE occurred_at BETWEEN '2014-01-01' AND '2017-01-01' -- we exclude 2013 and 2017 as their sales for these years are not evenly distributed
GROUP BY month
ORDER BY total_sales DESC;


-- Which year did Parch & Posey have the greatest sales in terms of total number of orders? Are all years evenly represented by the dataset?
SELECT DATE_PART('year', occurred_at) AS order_date,
	COUNT(*) AS total_orders
FROM orders
GROUP BY order_date
ORDER BY total_orders;

-- Which month did Parch & Posey have the greatest sales in terms of total number of orders? Are all months evenly represented by the dataset?
SELECT DATE_PART('month', occurred_at) AS order_month,
		COUNT(*) AS total_orders
FROM orders
WHERE occurred_at BETWEEN '2014-01-01' AND '2017-01-01' --we exclude 2013 and 2017 as their sales for these years are not evenly distributed
GROUP BY order_month
ORDER BY total_orders DESC;

-- In which month of which year did Walmart spend the most on gloss paper in terms of dollars?
SELECT DATE_TRUNC('month', o.occurred_at) AS date,
	a.name as company,
	SUM(o.gloss_amt_usd) AS gloss_total
FROM orders o
JOIN accounts a
ON o.account_id = a.id
WHERE a.name = 'Walmart'
GROUP BY date, company
ORDER BY gloss_total DESC
LIMIT 1;


-- Questions: CASE

-- Write a query to display for each order, the account ID, total amount of the order, 
-- and the level of the order - ‘Large’ or ’Small’ - depending on if the order is $3000 or more, or smaller than $3000.
SELECT account_id, 
	total_amt_usd,
        CASE WHEN total_amt_usd >= 3000 THEN 'Large'
        ELSE 'Small' END AS order_level
FROM orders;

-- Write a query to display the number of orders in each of three categories, based on the total number of items in each order.
--  The three categories are: 'At Least 2000', 'Between 1000 and 2000' and 'Less than 1000'.
SELECT  CASE WHEN total >= 2000 THEN 'At Least 2000'
        WHEN total >= 1000 AND total < 2000 THEN 'Between 1000 and 2000'
        ELSE 'Less than 1000' END AS order_total,
        COUNT(*) order_count
FROM orders
GROUP BY order_total;

/* 
We would like to understand 3 different levels of customers based on the amount associated with their purchases.
 The top level includes anyone with a Lifetime Value (total sales of all orders) greater than 200,000 usd. 
 The second level is between 200,000 and 100,000 usd. The lowest level is anyone under 100,000 usd.
 Provide a table that includes the level associated with each account. You should provide the account name, 
 the total sales of all orders for the customer, and the level. Order with the top spending customers listed first.
*/
SELECT a.name, 
	SUM(o.total_amt_usd) AS total_sales,
        CASE WHEN SUM(o.total_amt_usd) >= 200000 THEN 'top'
        WHEN SUM(o.total_amt_usd) >= 100000 THEN 'middle'
        ELSE 'low' END AS customer_level
FROM orders o
JOIN accounts a
ON o.account_id = a.id
GROUP BY a.name
ORDER BY total_sales;

-- We would now like to perform a similar calculation to the first, but we want to obtain the total amount spent by 
-- customers only in 2016 and 2017. Keep the same levels as in the previous question. Order with the top spending customers listed first.
SELECT a.name, 
	SUM(o.total_amt_usd) AS total_sales,
        CASE WHEN SUM(o.total_amt_usd) >= 200000 THEN 'top'
        WHEN SUM(o.total_amt_usd) >= 100000 THEN 'middle'
        ELSE 'low' END AS customer_level
FROM orders o
JOIN accounts a
ON o.account_id = a.id
WHERE occurred_at BETWEEN '2016-01-01' AND '2017-12-31'
GROUP BY a.name
ORDER BY total_sales DESC;


/*
We would like to identify top performing sales reps, which are sales reps associated with more than 200 orders. 
Create a table with the sales rep name, the total number of orders, and a column with top or not depending on if 
they have more than 200 orders. Place the top sales people first in your final table.
*/
SELECT s.name, 
	COUNT(*) total_orders,
        CASE WHEN COUNT(*) > 200 THEN 'top'
        ELSE 'not' END AS performance_level
FROM orders o
JOIN accounts a
ON o.account_id = a.id
JOIN sales_reps s
ON a.sales_rep_id = s.id
GROUP BY s.name
ORDER BY total_orders DESC;

/*
The previous didn't account for the middle, nor the dollar amount associated with the sales.
 Management decides they want to see these characteristics represented as well. We would like to identify 
 top performing sales reps, which are sales reps associated with more than 200 orders or more than 750000 in total sales. 
 The middle group has any rep with more than 150 orders or 500000 in sales. Create a table with the sales rep name, 
 the total number of orders, total sales across all orders, and a column with top, middle, or low depending on this criteria. 
 Place the top sales people based on dollar amount of sales first in your final table. 
 You might see a few upset sales people by this criteria!
*/
SELECT s.name,
	COUNT(*) num_orders,
        SUM(o.total_amt_usd) total_sales_usd,
        CASE WHEN COUNT(*) > 200 AND SUM(o.total_amt_usd) > 750000 THEN 'top'
        WHEN COUNT(*) > 150 AND SUM(o.total_amt_usd) > 500000 THEN 'middle'
        ELSE 'low' END AS sales_rep_performance
FROM orders o
JOIN accounts a
ON o.account_id = a.id
JOIN sales_reps s
ON a.sales_rep_id = s.id
GROUP BY s.name
ORDER BY total_sales_usd DESC;
