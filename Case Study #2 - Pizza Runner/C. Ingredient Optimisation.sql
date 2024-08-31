/*
C. Ingredient Optimisation
What are the standard ingredients for each pizza?
What was the most commonly added extra?
What was the most common exclusion?
Generate an order item for each record in the customers_orders table in the format of one of the following:
Meat Lovers
Meat Lovers - Exclude Beef
Meat Lovers - Extra Bacon
Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers
Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"
What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?
*/

use pizza_runner;
-- 1) What are the standard ingredients for each pizza? 

with cte1 as (
select pn.pizza_id,pn.pizza_name,pt.topping_name
from pizza_names as pn
join pizza_recipes as pr
on pn.pizza_id = pr.pizza_id
join pizza_toppings as pt
on pt.topping_id = pr.toppings)
select pizza_id,pizza_name,GROUP_CONCAT(distinct topping_name order by pizza_id) as ingredients
from cte1
group by pizza_id,pizza_name;

-- 2) What was the most commonly added extra?
with extras_cte as (
SELECT 
    order_id,
    customer_id,
    pizza_id,
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(extras, ',', numbers.n), ',', -1)) AS extra,
    order_time
FROM customer_orders
JOIN numbers 
ON CHAR_LENGTH(extras) - CHAR_LENGTH(REPLACE(extras, ',', '')) >= numbers.n - 1)
select  pt.topping_name , count(cte.extra) as extra_added
from extras_cte as cte
join pizza_toppings as pt 
on cte.extra = pt.topping_id
group by pt.topping_name;

-- 3) What was the most common exclusion?
with exclusions_cte as (
SELECT 
    order_id,
    customer_id,
    pizza_id,
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(exclusions, ',', numbers.n), ',', -1)) AS exclusions,
    order_time
FROM customer_orders
JOIN numbers 
ON CHAR_LENGTH(extras) - CHAR_LENGTH(REPLACE(extras, ',', '')) >= numbers.n - 1)
select  pt.topping_name , count(cte.exclusions) as exclusions_added
from exclusions_cte as cte
join pizza_toppings as pt 
on cte.exclusions = pt.topping_id
group by pt.topping_name;
