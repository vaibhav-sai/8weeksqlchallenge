/*
E. Bonus Questions
If Danny wants to expand his range of pizzas - how would this impact the existing data design? 
Write an INSERT statement to demonstrate what would happen
if a new Supreme pizza with all the toppings was added to the Pizza Runner menu?
*/

INSERT INTO pizza_names VALUES(3, 'Supreme');
SELECT * FROM pizza_names;

INSERT INTO pizza_recipes
VALUES(3, (SELECT GROUP_CONCAT(topping_id SEPARATOR ', ') FROM pizza_toppings));

SELECT * FROM pizza_recipes;

SELECT *
FROM pizza_names
INNER JOIN pizza_recipes USING(pizza_id);