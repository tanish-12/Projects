use sql_portfolio_project;
show tables;
select * from credit_card_transactions;

select * from credit_card_transactions where card_type = "Gold";

select * from credit_card_transactions where amount>100000;

select card_type, count(index_no) from credit_card_transactions group by card_type;

select * from credit_card_transactions where amount = (select max(amount) from credit_card_transactions);

-- QUESTIONS --

-- Q1 write a query to print top 5 cities with highest spends and their percentage contribution of total credit card spends --
WITH CTE AS (
SELECT CITY, SUM(AMOUNT) AS TOTAL_SPEND, ROW_NUMBER() OVER (ORDER BY SUM(AMOUNT) DESC) AS RNK
FROM CREDIT_CARD_TRANSACTIONS
GROUP BY CITY)
SELECT CITY, TOTAL_SPEND, ROUND(TOTAL_SPEND/(SELECT SUM(AMOUNT) FROM CREDIT_CARD_TRANSACTIONS)*100,2) AS CONTRIBUTION_IN_PERCENT FROM CTE WHERE RNK <=5;

-- Q2 write a query to print highest spend month and amount spent in that month for each card type --
select month(date) as month_, card_type, sum(amount)
from credit_card_transactions
group by month(date), card_type
having month_ = (with cte as (
select month(date) as month_, sum(amount) as total_sum, row_number() over (order by sum(amount) desc) as rnk
from credit_card_transactions
group by month(date)
)
select month_ from cte where rnk = 1);

-- Q3 write a query to print the transaction details(all columns from the table) for each card type when
	-- it reaches a cumulative of 1000000 total spends(We should have 4 rows in the o/p one for each card type) --


-- Q4 write a query to find city which had lowest percentage spend for gold card type--
WITH CTE AS (
SELECT CITY, SUM(AMOUNT) AS TOTAL_SPEND, ROW_NUMBER() OVER (ORDER BY SUM(AMOUNT)) AS RNK FROM CREDIT_CARD_TRANSACTIONS WHERE CARD_TYPE = 'GOLD' 
GROUP BY CITY
)
SELECT CITY, TOTAL_SPEND/(SELECT SUM(AMOUNT) FROM CREDIT_CARD_TRANSACTIONS WHERE CARD_TYPE = 'GOLD')*100 AS TOTAL_CONTRIBUTION_IN_PERCENT FROM CTE WHERE RNK = 1;

-- Q5 write a query to print 3 columns:  city, highest_expense_type , lowest_expense_type (example format : Delhi , bills, Fuel)--
WITH CTE AS (
SELECT CITY, EXP_TYPE, SUM(AMOUNT) AS TOTAL_SPEND
FROM CREDIT_CARD_TRANSACTIONS
GROUP BY CITY, EXP_TYPE
ORDER BY CITY
),
CTE2 AS (
SELECT *, RANK() OVER (PARTITION BY CITY ORDER BY TOTAL_SPEND DESC) AS RNK, RANK() OVER (PARTITION BY CITY ORDER BY TOTAL_SPEND) AS RNK2 FROM CTE
),
CTE3 AS (
SELECT CITY, CASE WHEN RNK2 = 1 THEN EXP_TYPE END AS LOWEST_EXP_TYPE, CASE WHEN RNK = 1 THEN EXP_TYPE END AS HIGH
FROM CTE2),
CTE4 AS (
SELECT *, LEAD(HIGH,1) OVER(PARTITION BY CITY) AS HIGHEST_EXP_TYPE FROM CTE3 WHERE HIGH IS NOT NULL OR LOWEST_EXP_TYPE IS NOT NULL
)
SELECT CITY, HIGHEST_EXP_TYPE, LOWEST_EXP_TYPE
FROM CTE4
WHERE HIGHEST_EXP_TYPE IS NOT NULL AND LOWEST_EXP_TYPE IS NOT NULL;

-- Q6 write a query to find percentage contribution of spends by females for each expense type --
WITH CTE AS (
SELECT EXP_TYPE, SUM(AMOUNT) AS TOTAL_SPEND FROM CREDIT_CARD_TRANSACTIONS
GROUP BY EXP_TYPE
),
CTE2 AS (
SELECT EXP_TYPE, SUM(AMOUNT) AS TOTAL_SPEND_F FROM CREDIT_CARD_TRANSACTIONS 
WHERE GENDER = 'F'
GROUP BY EXP_TYPE
)
SELECT CTE2.EXP_TYPE, ROUND((CTE2.TOTAL_SPEND_F/CTE.TOTAL_SPEND)*100,2) AS FEMALE_SPEND_IN_PERCENT
FROM CTE
JOIN CTE2
ON CTE.EXP_TYPE = CTE2.EXP_TYPE;

-- Q8 during weekends which city has highest total spend to total no of transcations ratio --
WITH CTE AS (
SELECT CITY, SUM(AMOUNT)/COUNT(*) AS RATIO, RANK() OVER (ORDER BY SUM(AMOUNT)/COUNT(*) DESC) AS RNK FROM CREDIT_CARD_TRANSACTIONS
WHERE WEEKDAY(DATE) IN (0,6)
GROUP BY CITY
)
SELECT * FROM CTE WHERE RNK = 1;

-- Q9 which city took least number of days to reach its 500th transaction after the first transaction in that city --
SELECT * FROM CREDIT_CARD_TRANSACTIONS;






