-- A. Customer Nodes Exploration

use data_bank;
-- 1) How many unique nodes are there on the Data Bank system?

select count (distinct node_id) as unique_nodes 
from [customer_nodes];

-- 2) What is the number of nodes per region?
select cn.region_id,r.region_name,count(node_id) as node_count from [customer_nodes] as cn
join [regions] as r
on cn.region_id = r.region_id
group by cn.region_id,r.region_name
order by cn.region_id;

-- 3) How many customers are allocated to each region?

select cn.region_id,r.region_name,count(distinct customer_id) as customer_count from [customer_nodes] as cn
join [regions] as r
on cn.region_id = r.region_id
group by cn.region_id,r.region_name
order by cn.region_id;

-- 4) How many days on average are customers reallocated to a different node?

-- checking the unique start_date in the customer nodes table
select distinct [start_date] from [customer_nodes]
order by [start_date] desc;

-- checking the unique end_date in the customer nodes table
select distinct [end_date] from [customer_nodes]
order by [end_date] desc;

-- the result shows there is an abnormal date which is '9999-12-31'
-- the date is incorrect and might be a typo error and therefore needs to be excluded from the query

select avg(DATEDIFF(day,[start_date],[end_date])) as avg_number_of_day
from [customer_nodes]
where [end_date] <> '9999-12-31';

-- 5) What is the median, 80th and 95th percentile for this same reallocation days metric for each region?

--Use a CTE to find the difference between start_date and end_date

with cte_date_diff as (
select r.region_name,cn.region_id,cn.customer_id,DATEDIFF(day,[start_date],[end_date]) as reallocation_days_Diff
from [customer_nodes] as cn
join regions as r
on cn.region_id = r.region_id
where [end_date] <> '9999-12-31')
select distinct region_id,region_name,
PERCENTILE_CONT(0.5) within group (order by reallocation_days_Diff) over(partition by region_name) as median,
PERCENTILE_CONT(0.8) WITHIN GROUP(ORDER BY reallocation_days_Diff) OVER(PARTITION BY region_name) AS percentile_80,
PERCENTILE_CONT(0.95) WITHIN GROUP(ORDER BY reallocation_days_Diff) OVER(PARTITION BY region_name) AS percentile_95
from cte_date_diff
order by region_id;