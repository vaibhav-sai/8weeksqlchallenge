-- Data Cleaning 

select * from runners;
select * from customer_orders;
select * from runner_orders;
select * from pizza_names;
select * from pizza_recipes;
select * from pizza_toppings;

-- We could see we have to do the data cleaning for the tables customer_orders,runner_orders,pizza_recipes.

-- create a temp table for customer_orders
create table customer_orders_temp as 
select * from customer_orders;

-- View the Temporary Table
select * from customer_orders_temp;

-- Data celeaning here i am replacing '','null' to NULL in exclusions,extras column

select order_id,customer_id,pizza_id,
case when exclusions = '' or exclusions = 'null' then NULL 
else exclusions end as exclusions,
case when extras = '' or extras = 'null' then NULL 
else extras end as extras,
order_time
from customer_orders_temp;

-- truncate the original table customer_orders
truncate customer_orders;

-- insert data from temp table to original table.
insert into customer_orders(order_id, customer_id, pizza_id, exclusions, extras,order_time)
select order_id,customer_id,pizza_id,
case when exclusions = '' or exclusions = 'null' then NULL 
else exclusions end as exclusions,
case when extras = '' or extras = 'null' then NULL 
else extras end as extras,
order_time
from customer_orders_temp;

-- view the original/existing table 
select * from CUSTOMER_ORDERS;

-- drop temp table and it is not manadatory to drop.

-- create a temp table for customer_orders
create table runner_orders_temp as 
select * from runner_orders;

select * from runner_orders_temp;

select order_id,runner_id,
case when pickup_time = 'null' then NULL
else cast(pickup_time as datetime) end as pickup_time,
case when distance = 'null' then NULL
else 
cast(replace(ltrim(rtrim(distance)),'Km','') as float)
end as distance,
case when duration = 'null' then null
else 
cast(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(duration)), 'minutes', ''), 'mins', ''),'minute','') as float)
end as duration,
case when cancellation = 'null' or cancellation = ''
then NULL
else cancellation end as cancellation 
from runner_orders_temp;

-- Truncate existing table 
truncate table runner_orders;

-- insert data from temp table to existing table
INSERT INTO runner_orders
  (order_id, runner_id, pickup_time, distance, duration, cancellation)
select order_id,runner_id,
(case when pickup_time='null' then NULL
else cast(pickup_time as DATETIME) end) as pickup_time,
(case when distance = 'null' then NULL
else cast(replace(LTRIM(RTRIM(distance)),'km','') as FLOAT)
end )as distance,
(case when duration = 'null' then NULL
else cast(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(duration)), 'minutes', ''), 'mins', ''),'minute','') as float)
end) as duration,
(case when cancellation ='' then NULL 
when cancellation = 'null' then NULL
else cancellation end) as cancellation
from runner_orders_temp;

-- drop temp table and it is not manadatory to drop.
-- view data from runner_orders
select * from runner_orders;
/*
-- create a temp table for pizza_recipes
create table pizza_recipes_temp as 
select * from pizza_recipes;

select pizza_id,value as toppings from pizza_recipes_Temp
cross apply STRING_SPLIT(cast(toppings as VARCHAR),',') as toppings_list
*/

truncate pizza_recipes;
-- Insert data for ID = 1
INSERT INTO pizza_recipes (pizza_id, toppings )
VALUES
(1, '1'),
(1, '2'),
(1, '3'),
(1, '4'),
(1, '5'),
(1, '6'),
(1, '8'),
(1, '10');

-- Insert data for ID = 2
INSERT INTO pizza_recipes (pizza_id, toppings )
VALUES
(2, '4'),
(2, '6'),
(2, '7'),
(2, '9'),
(2, '11'),
(2, '12');

-- View data of pizza_recipes
select * from pizza_recipes;

--create a numbers table for row slipt operations as a helper table
CREATE TABLE numbers (
    n INT PRIMARY KEY
);
INSERT INTO numbers (n) VALUES 
(1), (2), (3), (4), (5), 
(6), (7), (8), (9), (10), 
(11), (12), (13), (14), (15), 
(16), (17), (18), (19), (20);
