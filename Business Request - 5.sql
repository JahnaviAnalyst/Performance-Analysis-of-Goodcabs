/*Business Request - 5: Identify Month with Highest Revenue for Each City 
Generate a report that identifies the month with the highest revenue for each city. 
For each city, display the month_name, the revenue amount for that month, 
and the percentage contribution of that month’s revenue to the city’s total revenue.
Fields:city_name,highest_revenue_month,revenuepercentage_contribution (%)*/

WITH t1 AS (
    SELECT 
        city_name, 
        SUM(fare_amount) AS whole_amount
    FROM 
        fact_trips 
    JOIN 
        dim_city 
    ON 
        dim_city.city_id = fact_trips.city_id 
    GROUP BY 
        1
),

cte AS (
    SELECT 
        dc.city_name,
        dd.month_name AS month,
        SUM(fare_amount) AS total_fare_amount,
        ROUND((SUM(fare_amount) * 100 / whole_amount), 2) AS contribution
    FROM 
        fact_trips ft
    JOIN 
        dim_city dc 
    ON 
        ft.city_id = dc.city_id
    JOIN 
        dim_date dd 
    ON 
        ft.date = dd.date
    JOIN 
        t1 
    ON 
        t1.city_name = dc.city_name 
    GROUP BY 
        1, 2
),

cte1 AS (
    SELECT 
        city_name,
        cte.month,
        total_fare_amount,
        contribution,
        ROW_NUMBER() OVER (
            PARTITION BY cte.city_name 
            ORDER BY total_fare_amount DESC
        ) AS rn
    FROM 
        cte  
)

SELECT
    city_name,
    cte1.month,
    total_fare_amount,
    contribution
FROM 
    cte1 
WHERE 
    rn = 1;
