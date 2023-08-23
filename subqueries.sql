-- Queries written in completion of Udacity's SQL for Data Analysis course

-- Q1. Find the number of events that occur for each day for each channel.
SELECT DATE_TRUNC('day', occurred_at) AS day, 
		channel,
        COUNT(*) num_events
FROM web_events
GROUP BY day, channel
ORDER BY num_events DESC; 

-- Q2. Create a subquery that simply provides all of the data from your first query.
SELECT *
FROM (SELECT DATE_TRUNC('day', occurred_at) AS day, 
			channel,
        	COUNT(*) num_events
	    FROM web_events
	    GROUP BY day, channel
        ORDER BY num_events DESC) AS sub;

-- Q3. Find the average number of events for each channel. Since you broke out by day earlier,
-- this is giving you average per day.
SELECT channel,
		AVG(num_events) AS avg_num_events
FROM (SELECT DATE_TRUNC('day', occurred_at) AS day, 
			channel,
        	COUNT(*) num_events
	    FROM web_events
	    GROUP BY day, channel) AS sub
GROUP BY channel
ORDER BY avg_num_events DESC;



-- Q1. Use DATE_TRUNC to pull month level information about the first order ever placed in the orders table
SELECT DATE_TRUNC('month', MIN(occurred_at)) AS first_month 
FROM orders;

-- Q2. Use the above query to find only the orders that took place in the same month and year as the first order,
-- and then pull the average for each type of paper qty in this month
SELECT AVG(standard_qty) AS avg_standard_qty,
		AVG(gloss_qty) AS avg_gloss_qty,
        AVG(poster_qty) AS avg_poster_qty
FROM orders
WHERE DATE_TRUNC('month', occurred_at) = 
		(SELECT DATE_TRUNC('month', MIN(occurred_at)) AS first_month 
		 FROM orders);

-- Q3. Find the total amount spent on all orders in the first month that any order was placed in the orders table
SELECT SUM(total_amt_usd)
FROM orders
WHERE DATE_TRUNC('month', occurred_at) = 
		(SELECT DATE_TRUNC('month', MIN(occurred_at)) AS first_month 
		 FROM orders);


-- ***SUBQUERY MANIA***
-- Q1. Provide the name of the sales_rep in each region with the largest amount of total_amt_usd sales.
-- first select wanted data
SELECT s.name AS sales_rep,
		r.name AS region,
        SUM(o.total_amt_usd) AS total_sales_usd
FROM orders o
JOIN accounts a 
ON o.account_id = a.id
JOIN sales_reps s
ON a.sales_rep_id = s.id
JOIN region r
ON s.region_id = r.id
GROUP BY sales_rep, region
ORDER BY total_sales_usd DESC;

-- now find the max sales made by region
SELECT region AS region, 
		MAX(total_sales_usd) AS max_total_sales_usd
FROM (SELECT s.name AS sales_rep,
		r.name AS region,
        SUM(o.total_amt_usd) AS total_sales_usd
	FROM orders o
	JOIN accounts a 
	ON o.account_id = a.id
	JOIN sales_reps s
	ON a.sales_rep_id = s.id
	JOIN region r
	ON s.region_id = r.id
	GROUP BY sales_rep, region) AS t1
GROUP BY region
ORDER BY max_total_sales_usd;

-- now we want to find the rep that has their info matching with this table (JOIN the two tables)
SELECT t3.sales_rep, t2.region, t2.max_total_sales_usd
FROM (
    SELECT region AS region, 
		    MAX(total_sales_usd) AS max_total_sales_usd
    FROM (
        SELECT s.name AS sales_rep, r.name AS region,
                SUM(o.total_amt_usd) AS total_sales_usd
        FROM orders o
        JOIN accounts a 
        ON o.account_id = a.id
        JOIN sales_reps s
        ON a.sales_rep_id = s.id
        JOIN region r
        ON s.region_id = r.id
        GROUP BY sales_rep, region) AS t1
    GROUP BY region
    ORDER BY max_total_sales_usd) AS t2
JOIN (
    SELECT s.name AS sales_rep, r.name AS region,
            SUM(o.total_amt_usd) AS total_sales_usd
    FROM orders o
    JOIN accounts a 
    ON o.account_id = a.id
    JOIN sales_reps s
    ON a.sales_rep_id = s.id
    JOIN region r
    ON s.region_id = r.id
    GROUP BY sales_rep, region) AS t3
ON t2.region = t3.region AND t2.max_total_sales_usd = t3.total_sales_usd

-- Q2. For the region with the largest (sum) of sales total_amt_usd, how many total (count) orders were placed?

-- first find region with max total sales
SELECT r.name AS region,
        SUM(o.total_amt_usd) AS total_sales
FROM orders o
JOIN accounts a 
ON o.account_id = a.id
JOIN sales_reps s
ON a.sales_rep_id = s.id
JOIN region r
ON s.region_id = r.id
GROUP BY region
ORDER BY total_sales DESC
LIMIT 1;

SELECT MAX(total_sales)
FROM (
    SELECT r.name AS region,
            SUM(o.total_amt_usd) AS total_sales
    FROM orders o
    JOIN accounts a 
    ON o.account_id = a.id
    JOIN sales_reps s
    ON a.sales_rep_id = s.id
    JOIN region r
    ON s.region_id = r.id
    GROUP BY region) AS t1;


-- now find how many orders were placed 
SELECT r.name AS region,
        COUNT(o.total) AS total_orders
FROM orders o 
JOIN accounts a 
ON o.account_id = a.id
JOIN sales_reps s
ON a.sales_rep_id = s.id
JOIN region r
ON s.region_id = r.id
GROUP BY region
HAVING SUM(o.total_amt_usd) =  
        (
        SELECT MAX(total_sales)
        FROM (
            SELECT r.name AS region,
                    SUM(o.total_amt_usd) AS total_sales
            FROM orders o
            JOIN accounts a 
            ON o.account_id = a.id
            JOIN sales_reps s
            ON a.sales_rep_id = s.id
            JOIN region r
            ON s.region_id = r.id
            GROUP BY region) AS t1
        );

-- Q3. How many accounts had more total purchases than the account name which has bought the most standard_qty paper 
-- throughout their lifetime as a customer?
-- first need to find most standard_qty paper purchased
SELECT a.name AS account_name,
        SUM(o.standard_qty) AS total_standard_qty,
        SUM(o.total) AS total
FROM orders o 
JOIN accounts a 
ON o.account_id = a.id
GROUP BY account_name
ORDER BY total_standard_qty DESC
LIMIT 1;

-- next find all the accounts that have had more total purchases 
SELECT a.name
FROM orders o 
JOIN accounts a 
ON o.account_id = a.id
GROUP BY a.name
HAVING SUM(o.total) > (SELECT total
                        FROM (SELECT a.name AS account_name,
                                    SUM(o.standard_qty) AS total_standard_qty,
                                    SUM(o.total) AS total
                            FROM orders o 
                            JOIN accounts a 
                            ON o.account_id = a.id
                            GROUP BY account_name
                            ORDER BY total_standard_qty DESC
                            LIMIT 1) AS t1 );

-- now return the count 
SELECT COUNT(*)
FROM (SELECT a.name
        FROM orders o 
        JOIN accounts a 
        ON o.account_id = a.id
        GROUP BY a.name
        HAVING SUM(o.total) > (SELECT total
                                FROM (SELECT a.name AS account_name,
                                            SUM(o.standard_qty) AS total_standard_qty,
                                            SUM(o.total) AS total
                                    FROM orders o 
                                    JOIN accounts a 
                                    ON o.account_id = a.id
                                    GROUP BY account_name
                                    ORDER BY total_standard_qty DESC
                                    LIMIT 1) AS inner_tab)
        ) AS count_tab;


-- Q4. For the customer that spent the most (in total over their lifetime as a customer) total_amt_usd, 
-- how many web_events did they have for each channel?

-- first find the customer that spent the most 
SELECT a.id AS account_id,
        a.name AS account_name, 
        SUM(o.total_amt_usd) AS total
FROM orders o
JOIN accounts a 
ON o.account_id = a.id
GROUP BY 1,2
ORDER BY total DESC
LIMIT 1;

-- now look at the number of web_events for each channel
SELECT a.name,
        w.channel,
        COUNT(*)
FROM accounts a 
JOIN web_events w
ON w.account_id = a.id AND a.id = (SELECT account_id
                                    FROM (
                                            SELECT a.id AS account_id,
                                                    a.name AS account_name, 
                                                    SUM(o.total_amt_usd) AS total
                                            FROM orders o
                                            JOIN accounts a 
                                            ON o.account_id = a.id
                                            GROUP BY 1,2
                                            ORDER BY total DESC
                                            LIMIT 1) AS inner_tab
                                    )
GROUP BY a.name, w.channel
ORDER BY 3 DESC;


-- Q5. What is the lifetime average amount spent in terms of total_amt_usd for the top 10 total spending accounts?
-- first want to find the top 10 spending accounts
SELECT a.id AS account_id,
        a.name AS account_name, 
        SUM(total_amt_usd) AS total_spent
FROM orders o
JOIN accounts a 
ON o.account_id = a.id
GROUP BY 1, 2
ORDER BY total_spent DESC
LIMIT 10;

-- now find the average of these accounts
SELECT AVG(total_spent)
FROM (SELECT a.id AS account_id,
             a.name AS account_name, 
             SUM(total_amt_usd) AS total_spent
        FROM orders o
        JOIN accounts a 
        ON o.account_id = a.id
        GROUP BY 1, 2
        ORDER BY total_spent DESC
        LIMIT 10) AS top_accounts ;
        

-- Q6. What is the lifetime average amount spent in terms of total_amt_usd, 
-- including only the companies that spent more per order, on average, than the average of all orders.

-- first find the average of all orders
SELECT AVG(total_amt_usd)
FROM orders 

-- now find the companies who spent more per order on average than the average of all orders
SELECT o.account_id,
        AVG(o.total_amt_usd) AS average_total_amt
FROM orders o 
GROUP BY 1
HAVING AVG(o.total_amt_usd) > (SELECT AVG(total_amt_usd) FROM orders);

-- now average these values
SELECT AVG(average_total_amt)
FROM (SELECT o.account_id,
            AVG(o.total_amt_usd) AS average_total_amt
        FROM orders o 
        GROUP BY 1
        HAVING AVG(o.total_amt_usd) > (SELECT AVG(total_amt_usd) FROM orders )) t1; 


-- **** WITH STATEMENTS ****
-- Q1. Provide the name of the sales_rep in each region with the largest amount of total_amt_usd sales.
WITH t1 AS (SELECT r.name region, s.name sales_rep,
                    SUM(o.total_amt_usd) AS total_sales
            FROM orders o 
            JOIN accounts a
            ON o.account_id = a.id
            JOIN sales_reps s
            ON a.sales_rep_id = s.id
            JOIN region r 
            ON s.region_id = r.id 
            GROUP BY r.name, s.name
            ORDER BY total_sales DESC),

    t2 AS (SELECT region,
                    MAX(total_sales) AS max_sales
            FROM t1
            GROUP BY region)

SELECT t1.sales_rep, t2.region, t2.max_sales
FROM t1
JOIN t2
ON t1.region = t2.region AND t1.total_sales = t2.max_sales;


-- Q2. For the region with the largest sales total_amt_usd, how many total orders were placed?
WITH t1 AS (SELECT r.name region, SUM(o.total_amt_usd) AS total_sales
            FROM orders o 
            JOIN accounts a
            ON o.account_id = a.id
            JOIN sales_reps s
            ON a.sales_rep_id = s.id
            JOIN region r 
            ON s.region_id = r.id 
            GROUP BY region
            ORDER BY total_sales DESC),

    t2 AS  (SELECT MAX(total_sales)
            FROM t1)

SELECT r.name, COUNT(o.total) AS total_orders
FROM orders o 
JOIN accounts a
ON o.account_id = a.id
JOIN sales_reps s
ON a.sales_rep_id = s.id
JOIN region r 
ON s.region_id = r.id 
GROUP BY r.name
HAVING SUM(o.total_amt_usd) = (SELECT * FROM t2);

-- Q3. How many accounts had more total purchases than the account name which has 
-- bought the most standard_qty paper throughout their lifetime as a customer?

--acct who bought the most standard_qty
WITH t1 AS (SELECT a.name, 
                    SUM(o.standard_qty) AS total_standard_qty,
                    SUM(o.total) AS total
            FROM orders o 
            JOIN accounts a
            ON o.account_id = a.id
            GROUP BY a.name
            ORDER BY total_standard_qty DESC
            LIMIT 1),

    t2 AS (SELECT a.name, SUM(o.total) AS total_purchases 
            FROM orders o
            JOIN accounts a
            ON o.account_id = a.id
            GROUP BY a.name
            HAVING SUM(o.total) > (SELECT total
                                    FROM t1))

SELECT COUNT(*)
FROM t2;


-- Q4. For the customer that spent the most (in total over their lifetime as a customer) 
-- total_amt_usd, how many web_events did they have for each channel?
WITH t1 AS (SELECT o.account_id customer, SUM(o.total_amt_usd)
            FROM orders o
            GROUP BY 1
            ORDER BY 2 DESC
            LIMIT 1)

SELECT w.account_id, 
        w. channel,
        COUNT(*) num_events
FROM web_events w
JOIN t1
ON w.account_id = t1.customer
GROUP BY w.account_id, w.channel
ORDER BY num_events DESC;


-- Q5. What is the lifetime average amount spent in terms of total_amt_usd for the top 10 total spending accounts?
WITH t1 AS (SELECT o.account_id,
                    SUM(total_amt_usd) total_spent
            FROM orders o
            GROUP BY o.account_id
            ORDER BY total_spent DESC
            LIMIT 10)

SELECT AVG(total_spent)
FROM t1;

-- Q6. What is the lifetime average amount spent in terms of total_amt_usd, 
-- including only the companies that spent more per order, on average, than the average of all orders.
WITH t1 AS (SELECT AVG(total_amt_usd)
            FROM orders),

    t2 AS (SELECT account_id,
                    AVG(total_amt_usd) avg_total
            FROM orders
            GROUP BY account_id
            HAVING AVG(total_amt_usd) > (SELECT *
                                        FROM t1))

SELECT AVG(avg_total)
FROM t2;

