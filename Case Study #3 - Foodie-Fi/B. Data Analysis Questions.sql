-- 1) How many customers has Foodie-Fi ever had?

select count(distinct customer_id) as total_customers from subscriptions;

-- 2) What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value

select MONTH(start_date) as month_no,DATENAME(MONTH,start_date) as month_name, count(customer_id) as total_customers
from subscriptions
where plan_id = 0
group by MONTH(start_date),DATENAME(MONTH,start_date)
order by month_no;

-- 3)What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name

select s.plan_id , p.plan_name , count(customer_id) as total_customers 
from subscriptions as s
join plans as p
on s.plan_id = p.plan_id
where year(start_date) > 2020
group by s.plan_id , p.plan_name
order by s.plan_id;

-- 4) What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
with total_churned_customers as (
select '1' as rn,count(distinct customer_id) as total_customers_churned 
from subscriptions 
where plan_id = 4),
total_customers as (
select '1' as rn,count(distinct customer_id) as total_customers
from subscriptions 
)
select total_customers_churned,round((total_customers_churned*1.0/total_customers)*100,2) as percentage_churned
from total_churned_customers as ttc
join total_customers as tc 
on ttc.rn = tc.rn

-- 5) How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?
select * from subscriptions;
select * from plans;

with cte1 as (
select customer_id , plan_id, lead(plan_id,1,plan_id) over(partition by customer_id order by start_date) as next_plan_id
from subscriptions),
cte2 as (
select distinct customer_id 
from cte1
where plan_id = 0 and next_plan_id = 4),
total_customers as (
select '1' as rn ,count(distinct customer_id) as total_customers from subscriptions),
immediate_chrun as (
select '1'as rn, count(customer_id) as immediate_chrun_customers from cte2)
select immediate_chrun_customers , round((immediate_chrun_customers*1.0/total_customers)*100,2) as percentage_churned
from immediate_chrun as ic
join total_customers as tc 
on ic.rn = tc.rn;

-- 6) What is the number and percentage of customer plans after their initial free trial?


with previous_plan as (
select * , lag(plan_id,1) over(partition by customer_id order by start_date) as previous_plan
from subscriptions)
select p.plan_name , count(pp.customer_id) as customer_count,
round(count(pp.customer_id)*1.0/(select count(distinct customer_id) from subscriptions)*100,2) as percentage_customers
from previous_plan as pp
join plans as p 
on p.plan_id = pp.plan_id
where previous_plan=0
group by p.plan_name;


-- 7) What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?


with latest_plan as (
select s.*,p.plan_name , ROW_NUMBER() over(partition by customer_id order by start_date desc) as lates_plan
from subscriptions as s
join plans as p
on p.plan_id = s.plan_id
where start_date <= '2020-12-31')
select plan_id,plan_name,count(customer_id) as customer_count,
round((count(customer_id)*1.0/(select count(distinct customer_id) from subscriptions))*100,2) 
as percentage_breakdown
from latest_plan
where lates_plan = 1
group by plan_id,plan_name
order by plan_id;

--8) How many customers have upgraded to an annual plan in 2020?

with cte1 as (
select *,lag(plan_id) over(partition by customer_id order by start_date) as prev_plan 
from subscriptions), cte2 as (
select count(distinct customer_id) as total_customers from cte1
where year(start_date) = 2020 and prev_plan < 3 and plan_id = 3)
select * from cte2

-- 9) How many days on average does it take for a customer to an 
--    annual plan from the day they join Foodie-Fi?

with trail_plan_date as (
select customer_id,plan_id,start_date as trail_plan_Start from subscriptions
where plan_id = 0), 
annual_plan_start as (
select customer_id,plan_id,start_date as annual_plan_Start from subscriptions
where plan_id = 3),
date_diff as (
select a.customer_id , DATEDIFF(day,trail_plan_Start,annual_plan_Start) as days_diif
from trail_plan_date as a
join annual_plan_start as b
on a.customer_id = b.customer_id)
select avg(days_diif) as average from date_diff;

--10) Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)


with trail_plan_date as (
select customer_id,plan_id,start_date as trail_plan_Start from subscriptions
where plan_id = 0), 
annual_plan_start as (
select customer_id,plan_id,start_date as annual_plan_Start from subscriptions
where plan_id = 3),
date_diff as (
select a.customer_id , DATEDIFF(day,trail_plan_Start,annual_plan_Start) as days_diif,
DATEDIFF(day,trail_plan_Start,annual_plan_Start)/30 as window_30_days
from trail_plan_date as a
join annual_plan_start as b
on a.customer_id = b.customer_id)
select window_30_days*30 , count(*) as customer_count
from date_diff
group by window_30_days
order by window_30_days;

-- other way

with trail_plan_date as (
select customer_id,plan_id,start_date as trail_plan_Start from subscriptions
where plan_id = 0), 
annual_plan_start as (
select customer_id,plan_id,start_date as annual_plan_Start from subscriptions
where plan_id = 3),
date_diff as (
select a.customer_id , DATEDIFF(day,trail_plan_Start,annual_plan_Start) as days_diif
from trail_plan_date as a
join annual_plan_start as b
on a.customer_id = b.customer_id),
days_rec as (
select 0 as startpoint , 30 as endpoint
union all 
select endpoint+1 as startpoint , endpoint+30 as endpoint 
from days_rec
where endpoint <360)
select startpoint,endpoint,count(*) as customer_count from days_rec as dr
left join date_diff as dd
on (dd.days_diif>= dr.startpoint and dd.days_diif <=dr.endpoint)
group by startpoint,endpoint

-- 11) How many customers downgraded from a pro monthly to a basic monthly plan in 2020?


with next_plan as (
select customer_id, plan_id as current_plan , start_date , 
lead(plan_id,1) over(partition by customer_id order by start_date) as next_plan
from subscriptions) , customers as (
select customer_id , current_plan , next_plan 
from next_plan
where next_plan = 1 and current_plan = 2 and year(start_date) = 2020)
select count(distinct customer_id) as customer_count 
from customers
