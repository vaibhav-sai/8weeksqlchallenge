
select * from plans;
select * from subscriptions;
select *,lead(start_date) over(partition by customer_id order by start_date),
DATEDIFF(month,start_date,lead(start_date) over(partition by customer_id order by start_date)),
DATEADD(month,
DATEDIFF(month,start_date,lead(start_date) over(partition by customer_id order by start_date))
,start_date)
from subscriptions
where customer_id = 6;

with recursive_cte as (
select s.customer_id , s.plan_id , p.plan_name , s.start_date as payment_date,

case when 
lead(s.start_date) over(partition by s.customer_id order by s.start_date) is null then '2020-12-31'
else 
dateadd(month,
DATEDIFF(month,s.start_date,lead(s.start_date) over(partition by s.customer_id order by s.start_date))
,start_date)
end as last_date,
p.price as amount
from subscriptions as s
join plans as p 
on s.plan_id = p.plan_id
where p.plan_id <> 0
and year(s.start_date) = 2020

union all 
select customer_id,plan_id,plan_name,DATEADD(month,1,payment_date) as payment_date,
last_date,amount
from recursive_cte
where DATEADD(month,1,payment_date) <= last_date
and plan_name <> 'pro annual'
)
SELECT 
  customer_id,
  plan_id,
  plan_name,
  payment_date,
  amount,
  ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY payment_date) AS payment_order
INTO payments
FROM recursive_cte
--exclude churns
WHERE amount IS NOT NULL
ORDER BY customer_id
OPTION (MAXRECURSION 365);

select * from payments;