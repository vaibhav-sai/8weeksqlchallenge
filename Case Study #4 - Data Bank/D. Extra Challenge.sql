-- D. Extra Challenge

/*
Data Bank wants to try another option which is a bit more difficult to implement - they want to calculate data growth using an interest calculation, just like in a traditional savings account you might have with a bank.

If the annual interest rate is set at 6% and the Data Bank team wants to reward its customers by increasing their data allocation based off the interest calculated on a daily basis at the end of each day, how much data would be required for this option on a monthly basis?

Special notes:

Data Bank wants an initial calculation which does not allow for compounding interest, however they may also be interested in a daily compounding interest calculation so you can try to perform this calculation if you have the stamina!

*/

WITH cte AS
(
	SELECT customer_id,
	       txn_date,
	       SUM(txn_amount) AS total_data,
	       DATEFROMPARTS(YEAR(txn_date), MONTH(txn_date), 1) AS month_start_date,
	       DATEDIFF(DAY, DATEFROMPARTS(YEAR(txn_date), MONTH(txn_date), 1), txn_date) AS days_in_month,
	       CAST(SUM(txn_amount) AS DECIMAL(18, 2)) * POWER((1 + 0.06/365), DATEDIFF(DAY, '1900-01-01', txn_date)) AS daily_interest_data
	FROM customer_transactions
	GROUP BY customer_id, txn_date
	--ORDER BY customer_id
)

SELECT customer_id,
       DATEFROMPARTS(YEAR(month_start_date), MONTH(month_start_date), 1) AS txn_month,
       ROUND(SUM(daily_interest_data * days_in_month), 2) AS data_required
FROM cte
GROUP BY customer_id, DATEFROMPARTS(YEAR(month_start_date), MONTH(month_start_date), 1)
ORDER BY data_required DESC 