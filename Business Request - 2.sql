/*Business Request - 2: 
Monthly City-Level Trips Target Performance Report
Generate a report that evaluates the target performance for trips at the monthly and city level. 
For each city and month, compare the actual total trips with the target trips and 
categorise the performance as follows: 
if actual trips are greater than target trips, mark it as "Above Target". 
If actual trips are less than or equal to target trips, mark it as "Below Target". 
Additionally, calculate the % difference between actual and target trips to quantify the performance gap.
Fields:City_name,month_name,actual_trips,target_trips,performance_status,Percentage_difference(%)*/

WITH cte AS (
    SELECT 
        dc.city_id,
        dc.city_name,
        MONTHNAME(ft.date) AS month,
        COUNT(ft.trip_id) AS actual_trips
    FROM dim_city AS dc
    JOIN fact_trips AS ft USING (city_id)
    GROUP BY 1, 2, 3
),

cte1 AS (
    SELECT 
        dc.city_id,
        dc.city_name,
        MONTHNAME(t1.month) AS month,
        SUM(t1.total_target_trips) AS target_trips
    FROM dim_city AS dc
    JOIN targets_db.monthly_target_trips t1 USING (city_id)
    GROUP BY 1, 2, 3
),

cte2 AS (
    SELECT 
        cte.city_id,
        cte.city_name,
        cte.month, 
        actual_trips,
        target_trips,
        ROUND(((actual_trips - target_trips) * 100 / target_trips), 2) AS difference_perct
    FROM cte 
    JOIN cte1 USING (city_name, month)
),

cte3 AS (
    SELECT 
        cte2.city_name,
        cte2.month, 
        actual_trips,
        target_trips,
        difference_perct,
        CASE 
            WHEN difference_perct > 0 THEN "Above Target"
            WHEN difference_perct < 0 THEN "Below Target"
            ELSE "Met Target" 
        END AS Performance_status,
        ROW_NUMBER() OVER (
            PARTITION BY city_name 
            ORDER BY FIELD(
                month, 
                'January', 'February', 'March', 'April', 
                'May', 'June'
            )
        ) AS rank_by_month
    FROM cte2
)

SELECT
    CASE 
        WHEN rank_by_month = 1 THEN city_name 
        ELSE "" 
    END AS city_name,
    cte3.month, 
    actual_trips,
    target_trips,
    difference_perct,
    CASE 
        WHEN difference_perct > 0 THEN "Above Target"
        WHEN difference_perct < 0 THEN "Below Target"
        ELSE "Met Target" 
    END AS Performance_status
FROM cte3;
