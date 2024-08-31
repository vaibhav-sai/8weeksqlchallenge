/*
D. Pricing and Ratings
If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?
What if there was an additional $1 charge for any pizza extras?
Add cheese is $1 extra
The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.
Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
customer_id
order_id
runner_id
rating
order_time
pickup_time
Time between order and pickup
Delivery duration
Average speed
Total number of pizzas
If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?
*/

-- 1) If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - 
--    how much money has Pizza Runner made so far if there are no delivery fees?
select r.runner_id , 
concat("$",sum(case when o.pizza_id = 1 then 12 else 10 end)) as total_revenue
from customer_orders as o
join runner_orders as r
on o.order_id = r.order_id
WHERE r.cancellation IS NULL
group by r.runner_id;

-- 2) What if there was an additional $1 charge for any pizza extras? Add cheese is $1 extra.
with cte1 as (
select r.runner_id , 
sum(case when o.pizza_id = 1 then 12 else 10 end) as total_revenue,
length(o.extras) - length(replace(o.extras,",",""))+1*1 as extras_cost
from customer_orders as o
join runner_orders as r
on o.order_id = r.order_id
WHERE r.cancellation IS NULL
group by r.runner_id)
select runner_id,(total_revenue+COALESCE(extras_cost,0)) as total_revenue_with_extras
from cte1;

-- 3)
/*
The Pizza Runner team now wants to add an additional ratings system that allows customers to 
rate their runner, how would you design an additional table for this new dataset - 
generate a schema for this new table and insert your own data for ratings for 
each successful customer order between 1 to 5.
*/

drop table if exists runner_ratings;

create table runner_ratings(order_id int,rating int,review varchar(100));

INSERT INTO runner_ratings
VALUES ('1', '1', 'Really bad service'),
       ('2', '1', NULL),
       ('3', '4', 'Took too long...'),
       ('4', '1', 'Runner was lost, delivered it AFTER an hour. Pizza arrived cold'),
       ('5', '2', 'Good service'),
       ('7', '5', 'It was great, good service and fast'),
       ('8', '2', 'He tossed it on the doorstep, poor service'),
       ('10', '5', 'Delicious! He delivered it sooner than expected too!');
       
select * from runner_ratings;

/*
Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
customer_id
order_id
runner_id
rating
order_time
pickup_time
Time between order and pickup
Delivery duration
Average speed
Total number of pizzas
*/

select o.customer_id,o.order_id,r.runner_id,
rt.rating , o.order_time,
r.pickup_time, r.duration as delivery_duration,
round(r.distance*60/r.duration, 2) AS average_speed, 
count(o.pizza_id) as total_number_of_pizzas
from customer_orders as o
join runner_orders as r
using (order_id)
join runner_ratings as rt 
using (order_id)
group by o.order_id;

-- 5) 
/*
If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for 
extras and each runner is paid $0.30 per kilometre traveled - 
how much money does Pizza Runner have left over after these deliveries?
*/
with cte1 as (
select r.runner_id , 
sum(case when o.pizza_id = 1 then 12 else 10 end) as total_revenue,
round((0.30*r.distance),2) as delivery_cost
from customer_orders as o
join runner_orders as r
on o.order_id = r.order_id
WHERE r.cancellation IS NULL
group by r.runner_id)
select runner_id , concat("$",(total_revenue-delivery_cost)) as total_revenue_left
from cte1;

