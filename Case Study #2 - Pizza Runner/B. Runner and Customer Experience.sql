/*
B. Runner and Customer Experience
How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
Is there any relationship between the number of pizzas and how long the order takes to prepare?
What was the average distance travelled for each customer?
What was the difference between the longest and shortest delivery times for all orders?
What was the average speed for each runner for each delivery and do you notice any trend for these values?
What is the successful delivery percentage for each runner?
*/

use pizza_runner;
-- 1) How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01) ? 
select FLOOR(DATEDIFF(registration_date, '2021-01-01') / 7) + 1 as week_period , count(*) as runners_count
from runners
group by FLOOR(DATEDIFF(registration_date, '2021-01-01') / 7) + 1;

-- 2) What was the average time in minutes it took for each runner to 
--    arrive at the Pizza Runner HQ to pickup the order?

with cte1 as (
select r.runner_id,c.order_id,c.order_time,r.pickup_time,
TIMESTAMPDIFF(minute,c.order_time,r.pickup_time) as pickup_minutes
from runner_orders as r
join customer_orders as c
on r.order_id = c.order_id 
where r.cancellation is null
group by r.runner_id,c.order_id,c.order_time,r.pickup_time)
select runner_id,round(avg(pickup_minutes),0) as AVG_PICKUP_MINUTES
from cte1
group by runner_id;

-- 3) Is there any relationship between the number of pizzas and how long the order takes to prepare?
with cte1 as (
select c.order_id,count(c.pizza_id) as no_of_pizzas,c.order_time,r.pickup_time,
TIMESTAMPDIFF(minute,c.order_time,r.pickup_time) as prepare_minutes  from 
customer_orders as c
join runner_orders as r
on c.order_id = r.order_id
where  r.cancellation is null
group by c.order_id,c.order_time,r.pickup_time)
select no_of_pizzas as pizza_count,round(avg(prepare_minutes),0) as avg_prep_time
from cte1
group by no_of_pizzas;

-- More pizzas, longer time to prepare.

-- 4) What was the average distance travelled for each customer?

select c.customer_id,round(avg(r.distance),1) as avg_distance
from runner_orders as r
join customer_orders as c
on c.order_id = r.order_id
where r.cancellation is null
group by c.customer_id;

-- 5) What was the difference between the longest and shortest delivery times for all orders?

select (max(duration) - min(duration) ) time_difference_between_orders from runner_orders;

-- 6) What was the average speed for each runner for each delivery and do you notice any trend for these values?
select * from runner_orders;

-- speed formula is distance/time

select r.runner_id,c.order_id, r.distance,r.duration,
count(c.order_id) as pizza_count,
round(avg(r.distance/r.duration*60),1) as avg_speed
from runner_orders as r
join customer_orders as c
on r.order_id = c.order_id
where r.cancellation is null
group by r.runner_id,c.order_id, r.distance,r.duration
order by r.runner_id;

/*
Runner 1 had the average speed from 37.5 km/h to 60 km/h
Runner 2 had the average speed from 35.1 km/h to 93.6 km/h. With the same distance (23.4 km), order 4 was delivered at 35.1 km/h, while order 8 was delivered at 93.6 km/h. There must be something wrong here!
Runner 3 had the average speed at 40 km/h
*/

-- 7) What is the successful delivery percentage for each runner?


select 
runner_id,
count(distance) as delevired,
count(order_id) as total,
round((count(distance)/count(order_id))*100,0) as successful_pct
from runner_orders
group by runner_id;