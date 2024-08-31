/*
A. Pizza Metrics
How many pizzas were ordered?
How many unique customer orders were made?
How many successful orders were delivered by each runner?
How many of each type of pizza was delivered?
How many Vegetarian and Meatlovers were ordered by each customer?
What was the maximum number of pizzas delivered in a single order?
For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
How many pizzas were delivered that had both exclusions and extras?
What was the total volume of pizzas ordered for each hour of the day?
What was the volume of orders for each day of the week?
*/

use pizza_runner;
-- 1) How many pizzas were ordered?
select count(order_id) as pizzas_orderd from customer_orders;

-- 2) How many unique customer orders were made?
select count(distinct order_id) as unique_orders from customer_orders;

-- 3) How many successful orders were delivered by each runner?
select runner_id,count(order_id ) as successful_orders from runner_orders
where cancellation is null
group by runner_id;

-- 4) How many of each type of pizza was delivered?

select p.pizza_name , count(r.order_id) as orders_delivered
from pizza_names as p 
join customer_orders as c
on p.pizza_id = c.pizza_id
join runner_orders as r
on r.order_id = c.order_id
where r.cancellation is null
group by p.pizza_name;

-- 5) How many Vegetarian and Meatlovers were ordered by each customer?
select customer_id , 
sum(case when pizza_id = 1 then 1 else 0 end) as Meatlovers,
sum(case when pizza_id = 2 then 1 else 0 end) as Vegetarian
from customer_orders
group by customer_id;

-- 6) What was the maximum number of pizzas delivered in a single order?
select c.order_id, count(c.pizza_id) as pizzas_delivered 
from customer_orders as c
join runner_orders as r
on c.order_id = r.order_id
where r.cancellation is null
group by c.order_id
order by pizzas_delivered desc;

-- 7) For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
select c.customer_id , 
sum(case when exclusions is null or extras is null then 1 else 0 end ) as no_change,
sum(case when exclusions is not null or extras is not null then 1 else 0 end ) as has_change
from customer_orders as c
join runner_orders as r
on c.order_id = r.order_id
where r.cancellation is null
group by c.customer_id;


-- 8) How many pizzas were delivered that had both exclusions and extras?
select c.customer_id , 
sum(case when exclusions is not null and extras is not null then 1 else 0 end ) as has_change
from customer_orders as c
join runner_orders as r
on c.order_id = r.order_id
where r.cancellation is null
group by c.customer_id
order by has_change desc;

-- 9) What was the total volume of pizzas ordered for each hour of the day?
select hour(order_time) as hour_ordered,count(order_id) as orders
from customer_orders
group by hour(order_time)
order by hour_ordered;

-- 10) What was the volume of orders for each day of the week?
select DATE_FORMAT(order_time, '%W') as day_name , count(order_id) as orders
from customer_orders
group by DATE_FORMAT(order_time, '%W')
order by day_name;