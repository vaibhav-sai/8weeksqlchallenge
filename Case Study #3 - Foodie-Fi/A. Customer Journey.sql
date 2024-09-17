/*
Based off the 8 sample customers provided in the sample subscriptions table below, 
write a brief description about each customer’s onboarding journey.
*/

-- 8 Customers query 
select s.*,p.plan_name from subscriptions as s
join plans as p
on p.plan_id = s.plan_id
where s.customer_id in ('1','2','11','13','15','16','18','19');

/*
Based on the results above, 
I have selected three customers to focus on and will now share their onboarding journey.
*/

/*
Customer 1: This customer initiated their journey by starting the free trial on 1 Aug 2020.
After the trial period ended, on 8 Aug 2020, they subscribed to the basic monthly plan.
*/
select s.*,p.plan_name from subscriptions as s
join plans as p
on p.plan_id = s.plan_id
where s.customer_id =1;

/*
Customer 13: The onboarding journey for this customer began with a free trial on 15 Dec 2020. Following the trial period, on 22 Dec 2020, they subscribed to the basic monthly plan. 
After three months, on 29 Mar 2021, they upgraded to the pro monthly plan.
*/
select s.*,p.plan_name from subscriptions as s
join plans as p
on p.plan_id = s.plan_id
where s.customer_id =13;

/*
Customer 15: Initially, this customer commenced their onboarding journey with a free trial 
on 17 Mar 2020. Once the trial ended, on 24 Mar 2020, they upgraded to the pro monthly plan.
However, the following month, on 29 Apr 2020, the customer decided to 
terminate their subscription and subsequently churned until the paid subscription ends.
*/
select s.*,p.plan_name from subscriptions as s
join plans as p
on p.plan_id = s.plan_id
where s.customer_id =15;