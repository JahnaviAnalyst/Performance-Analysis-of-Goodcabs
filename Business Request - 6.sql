/*Business Request - 6: Repeat Passenger Rate Analysis
Generate a report that calculates two metrics:
1. Monthly Repeat Passenger Rate: Calculate the repeat passenger rate for each city and month by comparing the number of repeat passengers to the total passengers.
2. City-wide Repeat Passenger Rate: Calculate the overall repeat passenger rate for each city, considering all passengers across months. 
Fields:city_name,month,total_passengers,repeat_passengers,
monthly_repeat_passenger_rate (%): Repeat passenger rate at the city and month level,
city_repeat_passenger_rate (%): Overall repeat passenger rate for each city, aggregated across months*/

WITH cte AS (
    SELECT 
        city_id,
        city_name,
        SUM(fps.repeat_passengers) AS repeat_passengers,
        ROUND((SUM(repeat_passengers) * 100 / SUM(total_passengers)), 2) AS city_level_RPR_pct
    FROM 
        dim_city 
    JOIN 
        fact_passenger_summary AS fps USING (city_id)
    GROUP BY 
        1, 2
),

cte1 AS (
    SELECT 
        city_name,
        MONTHNAME(fps.month) AS month,
        SUM(fps.total_passengers) AS total_passengers,
        SUM(fps.repeat_passengers) AS repeat_passengers
    FROM 
        dim_city 
    JOIN 
        fact_passenger_summary AS fps USING (city_id)
    GROUP BY 
        1, 2
),

cte2 AS (
    SELECT 
        city_name,
        cte1.month,
        cte1.total_passengers,
        cte1.repeat_passengers,
        city_level_RPR_pct,
        ROUND(((cte1.repeat_passengers * 100) / cte.repeat_passengers), 2) AS monthly_RPR_pct,
        ROW_NUMBER() OVER (
            PARTITION BY city_name 
            ORDER BY FIELD(
                cte1.month, 
                'January', 'February', 'March', 'April', 
                'May', 'June'
            )
        ) AS rank_by_month
    FROM 
        cte
    JOIN 
        fact_passenger_summary AS fps USING (city_id)
    JOIN 
        cte1 USING (city_name)
    GROUP BY 
        1, 2, 3, 4, 5, cte.repeat_passengers
)

SELECT 
    CASE 
        WHEN rank_by_month = 1 THEN city_name 
        ELSE "" 
    END AS city_name,
    cte2.month,
    cte2.total_passengers,
    cte2.repeat_passengers,
    city_level_RPR_pct,
    monthly_RPR_pct
FROM 
    cte2;
