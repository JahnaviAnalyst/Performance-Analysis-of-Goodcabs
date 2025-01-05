/*Business Request - 3: 
City-Level Repeat Passenger Trip Frequency Report
Generate a report that shows the percentage distribution of repeat passengers by the number of trips they have taken in each city. 
Calculate the percentage of repeat passengers who took 2 trips, 3 trips, and so on, up to 10 trips. 
Each column should represent a trip count category, 
displaying the percentage of repeat passengers who fall into that category out of the total repeat passengers for that city. 
Fields: city_name, 2-Trips, 3-Trips, 4-Trips, 5-Trips, 6-Trips, 7-Trips, 8-Trips, 9-Trips,10-Trips*/

WITH cte AS (
    SELECT 
        city_id,
        city_name,
        SUM(repeat_passenger_count) AS total_passengers
    FROM 
        dim_city 
    JOIN 
        dim_repeat_trip_distribution AS drtd USING (city_id)
    GROUP BY 
        1, 2
),

cte1 AS (
    SELECT 
        city_name,
        trip_count,
        ROUND(
            (SUM(repeat_passenger_count) * 100 / cte.total_passengers), 
            2
        ) AS repeat_passenger_rate_perc 
    FROM 
        cte
    JOIN 
        dim_repeat_trip_distribution AS drtd USING (city_id)
    GROUP BY 
        1, 2, cte.total_passengers
    ORDER BY 
        1, CAST(SUBSTRING_INDEX(trip_count, '-', 1) AS UNSIGNED)
)

SELECT 
    dc.city_name,
    MAX(CASE WHEN trip_count = "2-Trips" THEN repeat_passenger_rate_perc ELSE "" END) AS "2-Trips",
    MAX(CASE WHEN trip_count = "3-Trips" THEN repeat_passenger_rate_perc ELSE "" END) AS "3-Trips",
    MAX(CASE WHEN trip_count = "4-Trips" THEN repeat_passenger_rate_perc ELSE "" END) AS "4-Trips",
    MAX(CASE WHEN trip_count = "5-Trips" THEN repeat_passenger_rate_perc ELSE "" END) AS "5-Trips",
    MAX(CASE WHEN trip_count = "6-Trips" THEN repeat_passenger_rate_perc ELSE "" END) AS "6-Trips",
    MAX(CASE WHEN trip_count = "7-Trips" THEN repeat_passenger_rate_perc ELSE "" END) AS "7-Trips",
    MAX(CASE WHEN trip_count = "8-Trips" THEN repeat_passenger_rate_perc ELSE "" END) AS "8-Trips",
    MAX(CASE WHEN trip_count = "9-Trips" THEN repeat_passenger_rate_perc ELSE "" END) AS "9-Trips",
    MAX(CASE WHEN trip_count = "10-Trips" THEN repeat_passenger_rate_perc ELSE "" END) AS "10-Trips"
FROM 
    dim_city AS dc 
JOIN 
    cte1 USING (city_name)
GROUP BY 
    1;
