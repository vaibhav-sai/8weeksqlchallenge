-- C. Data Allocation Challenge

/*
To test out a few different hypotheses - the Data Bank team wants to run an experiment where different groups of customers would be allocated data using 3 different options:

Option 1: data is allocated based off the amount of money at the end of the previous month
Option 2: data is allocated on the average amount of money kept in the account in the previous 30 days
Option 3: data is updated real-time
For this multi-part challenge question - you have been requested to generate the following data elements to help the Data Bank team estimate how much data will need to be provisioned for each option:

running customer balance column that includes the impact each transaction
customer balance at the end of each month
minimum, average and maximum values of the running balance for each customer
Using all of the data available - how much data would have been required for each option on a monthly basis?
*/

-- 1) running customer balance column that includes impact of each transaction

select customer_id,txn_date,txn_type,txn_amount,
sum(
case when txn_type ='deposit' then txn_amount
when txn_type = 'withdrawal' then -1*txn_amount
when txn_type = 'purchase' then -1*txn_amount
end) over (partition by customer_id order by txn_date) as running_balance
from customer_transactions;

-- 2) customer balance at the end of each month
select customer_id,MONTH(txn_date) as month_no,DATENAME(month, txn_date) as month_name,
sum(
case when txn_type ='deposit' then txn_amount
when txn_type = 'withdrawal' then -1*txn_amount
when txn_type = 'purchase' then -1*txn_amount
end) as closing_balance
from customer_transactions
group by customer_id,MONTH(txn_date),DATENAME(month, txn_date);

-- 3) minimum, average and maximum values of the running balance for each customer

with running_balance as (
select customer_id,
txn_date,txn_type,txn_amount,
sum(case when txn_type = 'deposit' then txn_amount
when txn_type = 'withdrawal' then -1*txn_amount
when txn_type = 'purchase' then -1*txn_amount end) over(partition by customer_id order by txn_date) as running_balance
from customer_transactions
)
select customer_id,avg(running_balance) as avg_running_balance,
min(running_balance) as min_running_balanec, max(running_balance) as max_running_balance
from running_balance
group by customer_id;

-- For option 1: data is allocated based off the amount of money at the end of the previous month.

with transaction_amt_cte as (
select customer_id , txn_date,month(txn_date) as month_no,txn_type,
case when txn_type = 'deposit' then txn_amount else -1*txn_amount end as net_transaction_amt
from customer_transactions), 
running_customer_balance_cte as (
select customer_id,month_no,txn_date,txn_type,net_transaction_amt,
sum(net_transaction_amt) over(partition by customer_id order by txn_date) as running_balance
from transaction_amt_cte),
customer_end_month_balance_cte as (
select *, lag(running_balance,1) over(partition by customer_id  order by customer_id ,month_no) as monthly_allocation
from running_customer_balance_cte
)
SELECT
   month_no,
   SUM(
   	CASE WHEN monthly_allocation < 0 THEN 0 ELSE monthly_allocation END) AS total_allocation
FROM customer_end_month_balance_cte
GROUP BY month_no
ORDER BY month_no;

-- For Option 2: data is allocated on the average amount of money kept in the account in the previous 30 days.

with transaction_amt_cte as (
select customer_id , txn_date,month(txn_date) as month_no,txn_type,
case when txn_type = 'deposit' then txn_amount else -1*txn_amount end as net_transaction_amt
from customer_transactions), 
running_customer_balance_cte as (
select customer_id,month_no,txn_date,txn_type,net_transaction_amt,
sum(net_transaction_amt) over(partition by customer_id order by txn_date) as running_balance
from transaction_amt_cte),
customer_end_month_balance_cte as (
select *, avg(running_balance) over(partition by customer_id order by txn_date) as avg_running_balance
from running_customer_balance_cte
)
SELECT
   month_no,
   sum(
   	CASE WHEN avg_running_balance < 0 THEN 0 ELSE avg_running_balance END) AS total_allocation
FROM customer_end_month_balance_cte
GROUP BY month_no
ORDER BY month_no;

-- For option 3: data is updated real-time.
WITH transaction_amt_cte AS
(
	SELECT customer_id,
	       txn_date,
	       txn_month = MONTH(txn_date),
	       txn_type,
	       txn_amount,
	       net_transaction_amt = CASE WHEN txn_type = 'deposit' THEN txn_amount ELSE -txn_amount END
	FROM customer_transactions
),

running_customer_balance_cte AS
(
	SELECT customer_id,
	       txn_month,
	       running_customer_balance = SUM(net_transaction_amt) OVER (PARTITION BY customer_id ORDER BY txn_month)
	FROM transaction_amt_cte
)

SELECT txn_month,
       SUM(running_customer_balance) AS data_required_per_month
FROM running_customer_balance_cte
GROUP BY txn_month
ORDER BY data_required_per_month;