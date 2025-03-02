-- B. Customer Transactions
use [data_bank]
-- 1) What is the unique count and total amount for each transaction type?

select txn_type, count (txn_type) as unique_count , sum(txn_amount) as total_amount
from customer_transactions
group by txn_type
order by txn_type;

-- 2) What is the average total historical deposit counts and amounts for all customers?

-- Create a CTE named deposit_summary that calculates the total deposit counts and amounts for each customer

with deposit_summary as (
select customer_id,count(customer_id) as deposite_count, sum(txn_amount) as amount
from customer_transactions
where txn_type = 'deposit'
group by customer_id)

-- Use the deposit_summary CTE in the outer query to calculate the average total deposit counts 
-- and amounts for all customers using the AVG function.
with deposit_summary as (
select customer_id,count(*) as deposite_count, sum(txn_amount) as amount
from customer_transactions
where txn_type = 'deposit'
group by customer_id)
select avg(deposite_count) as avg_depost_count, avg(amount) as avg_deposit_amount
from deposit_summary

-- The average deposit count for a customer is 5 and the average deposit amount for a customer is 2,718.

-- 3) For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase 
--    or 1 withdrawal in a single month?

-- Create a CTE named customer_activity that calculates the number of deposits, purchases and withdrawals for each customer for each month 
-- using the DATEPART and DATENAME functions to extract the month number and month name from the txn_date column.

with customer_activity as (
select customer_id,MONTH(txn_date) as month_no, DATENAME(month, txn_date) as month_name,
sum(case when txn_type = 'deposit' then 1 else 0 end) as dep_count,
sum(case when txn_type = 'purchase ' then 1 else 0 end) as purchase_count,
sum(case when txn_type = 'withdrawal' then 1 else 0 end) as withdrawal_count
from customer_transactions
group by customer_id,MONTH(txn_date),DATENAME(month, txn_date))
select month_no, month_name,count(distinct customer_id) as active_customer_count
from customer_activity
where dep_count > 1 and (purchase_count > 1 or  withdrawal_count > 1)
group by month_no , month_name
order by month_no;


-- 4) What is the closing balance for each customer at the end of the month?

with customer_balanace as (
select customer_id,MONTH(txn_date) as month_no, DATENAME(month, txn_date) as month_name,
sum(case when txn_type = 'deposit' then  txn_amount else 0 end) as dep_amount,
sum(case when txn_type = 'purchase ' then txn_amount else 0 end) as purchase_amount,
sum(case when txn_type = 'withdrawal' then txn_amount else 0 end) as withdrawal_amount
from customer_transactions
group by customer_id,MONTH(txn_date),DATENAME(month, txn_date))
select customer_id,month_no,month_name,(dep_amount - (purchase_amount + withdrawal_amount)) as total_amount
from customer_balanace
order by customer_id,month_no;

-- 5) What is the percentage of customers who increase their closing balance by more than 5%?

WITH monthly_transaction AS (
    SELECT 
        customer_id, 
        EOMONTH(txn_date) AS end_date, 
        SUM(CASE 
                WHEN txn_type IN ('purchase', 'withdrawal') THEN -1 * txn_amount 
                ELSE txn_amount 
            END) AS total_amount
    FROM customer_transactions
    GROUP BY customer_id, EOMONTH(txn_date)
),
closing_balances AS (
    SELECT 
        customer_id, 
        end_date,
        SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY end_date) AS closing_balance
    FROM monthly_transaction
),
pct_increase AS (
    SELECT 
        customer_id,
        end_date,
        closing_balance, 
        LAG(closing_balance) OVER (PARTITION BY customer_id ORDER BY end_date) AS prev_closing_balance,
        100 * (closing_balance - LAG(closing_balance) OVER (PARTITION BY customer_id ORDER BY end_date)) 
        / NULLIF(LAG(closing_balance) OVER (PARTITION BY customer_id ORDER BY end_date), 0) AS pct_increase
    FROM closing_balances
)
SELECT CAST(100.0 * COUNT(DISTINCT customer_id) / (SELECT COUNT(DISTINCT customer_id) FROM customer_transactions) AS FLOAT) AS pct_customers
FROM pct_increase
WHERE pct_increase > 5;

