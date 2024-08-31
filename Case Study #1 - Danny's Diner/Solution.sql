-- 1. What is the total amount each customer spent at the restaurant?

select s.customer_id , sum(mu.price) as amount_spent 
from sales as s
join menu as mu
on mu.product_id = s.product_id
group by  s.customer_id;

-- 2. How many days has each customer visited the restaurant?

select customer_id , count(distinct order_date) as days_vistited
from sales
group by customer_id;

-- 3. What was the first item from the menu purchased by each customer?
select customer_id , product_name from (
select s.customer_id,p.product_name,
row_number() over(partition by s.customer_id order by s.order_date) as rn
from sales as s
join menu as p
on s.product_id = p.product_id) as a
where rn = 1;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
select top 1 p.product_name , count(s.product_id) as times_purchased
from menu as p
join sales as s
on p.product_id = s.product_id
group by p.product_name
order by times_purchased desc;

-- 5. Which item was the most popular for each customer?
with cte1 as (
select s.customer_id , p.product_name ,count(p.product_name)  as times_purschased
from sales as s
join menu as p
on s.product_id = p.product_id
group by s.customer_id , p.product_name)
, cte2 as (
select *,ROW_NUMBER() over(partition by customer_id order by times_purschased desc) as rn
from cte1
)
select customer_id,product_name,times_purschased
from cte2
where rn =1;

-- 6. Which item was purchased first by the customer after they became a member?

with cte1 as (
select s.customer_id , p.product_name , s.order_date ,m.join_date
from sales as s
join members as m on s.customer_id = m.customer_id
join menu as p on s.product_id = p.product_id
where s.order_date > m.join_date),
cte2 as (
select customer_id,product_name,order_date,join_date,
ROW_NUMBER() over(partition by customer_id order by order_date) as rn
from cte1)
select customer_id,product_name,order_date,join_date
from cte2
where rn = 1;

-- 7. Which item was purchased just before the customer became a member?
with cte1 as (
select s.customer_id , p.product_name , s.order_date ,m.join_date
from sales as s
join members as m on s.customer_id = m.customer_id
join menu as p on s.product_id = p.product_id
where s.order_date < m.join_date),
cte2 as (
select customer_id,product_name,order_date,join_date,
ROW_NUMBER() over(partition by customer_id order by order_date desc) as rn
from cte1)
select customer_id,product_name,order_date,join_date
from cte2
where rn=1;

-- 8. What is the total items and amount spent for each member before they became a member?
with cte1 as (
select s.customer_id , p.product_name , s.order_date ,m.join_date , p.price
from sales as s
join members as m on s.customer_id = m.customer_id
join menu as p on s.product_id = p.product_id
where s.order_date < m.join_date),
cte2 as (
select customer_id,count(product_name) as total_items,sum(price) as amount_spent
from cte1
group by customer_id)
select customer_id, total_items,amount_spent
from cte2;

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier 
-- how many points would each customer have?
with cte1 as (
select s.customer_id,p.product_name,p.price
from sales as s
join menu as p
on s.product_id = p.product_id),
cte2 as (
select customer_id, product_name , 
case when product_name = 'sushi' then 20 
else 10 end as reward_points,price
from cte1)
select customer_id,sum(reward_points*price) as total_points
from cte2
group by customer_id;

-- 10. In the first week after a customer joins the program (including their join date) 
-- they earn 2x points on all items, not just sushi 
-- how many points do customer A and B have at the end of January?

WITH programDates AS (
    SELECT 
        m.customer_id, 
        m.join_date,
        DATEADD(d, 7, m.join_date) AS valid_date, 
        EOMONTH('2021-01-01') AS last_date
    FROM 
        members m
)

SELECT 
    s.customer_id,
    SUM(CASE 
            WHEN s.order_date BETWEEN p.join_date AND p.valid_date THEN mn.price * 20
            WHEN mn.product_name = 'sushi' THEN mn.price * 20
            ELSE mn.price * 10 
        END) AS total_points
FROM 
    sales s
JOIN 
    programDates p 
    ON s.customer_id = p.customer_id
JOIN 
    menu mn 
    ON s.product_id = mn.product_id
WHERE 
    s.order_date <= p.last_date
GROUP BY 
    s.customer_id;


-- Bonus Questions 
--Q1
select s.customer_id , s.order_date , p.product_name , p.price,
case when s.order_date >= m.join_date then 'Y' else 'N' end as member
from sales as s
join menu as p
on s.product_id = p.product_id
join members as m
on s.customer_id = m.customer_id;

--Q2
with cte1 as (
select s.customer_id , s.order_date , p.product_name , p.price,
case when s.order_date >= m.join_date then 'Y' else 'N' end as member,
rank() over(partition by s.customer_id order by order_date) as rn
from sales as s
join menu as p
on s.product_id = p.product_id
join members as m
on s.customer_id = m.customer_id)
select * , 
case
when member = 'Y' then
rank() over(partition by customer_id,member order by order_date)
else null
end as ranking
from cte1
