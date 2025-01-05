/*Business Request - 4: Identify Cities with Highest and Lowest Total New Passengers
Generate a report that calculates the total new passengers for each city and ranks them based on this value. 
Identify the top 3 cities with the highest number of new passengers 
as well as the bottom 3 cities with the lowest number of new passengers, 
categorizing them as "Top 3" or "Bottom 3" accordingly. 
Fields:city_name,total_new_passengers,city_category ("Top 3" or "Bottom 3")*/

WITH cte AS (
    SELECT
        city_id,
        city_name,
        SUM(new_passengers) AS total_new_passengers,
        ROW_NUMBER() OVER (ORDER BY SUM(new_passengers) DESC) AS rank_by_new_passengers,
        ROW_NUMBER() OVER (ORDER BY SUM(new_passengers) ASC) AS rank_by_new_passengers_asc
    FROM 
        dim_city
    JOIN 
        fact_passenger_summary USING (city_id)
    GROUP BY 
        1, 2
)

SELECT 
    city_name,
    total_new_passengers,
    CASE
        WHEN rank_by_new_passengers <= 3 THEN "Top 3"
        WHEN rank_by_new_passengers_asc <= 3 THEN "Bottom 3"
        ELSE "" 
    END AS city_category
FROM 
    cte
WHERE 
    rank_by_new_passengers <= 3 
    OR rank_by_new_passengers_asc <= 3
ORDER BY 
    rank_by_new_passengers;
