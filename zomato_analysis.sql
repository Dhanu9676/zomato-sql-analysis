
-- Booking availability vs rating
SELECT book_table, ROUND(AVG(rate), 2) AS avg_rating, COUNT(*) AS total
FROM zomato_data
GROUP BY book_table;


-- Cost impact on rating
SELECT
    CASE
        WHEN `approx_cost(for two people)` <= 300 THEN 'Low'
        WHEN `approx_cost(for two people)` BETWEEN 301 AND 800 THEN 'Medium'
        ELSE 'High'
    END AS cost_range,
    ROUND(AVG(CAST(SUBSTRING_INDEX(rate, '/', 1) AS DECIMAL(3,1))), 2) AS avg_rating,
    COUNT(*) AS total
FROM zomato_data
WHERE `approx_cost(for two people)` REGEXP '^[0-9]+$'
GROUP BY cost_range
LIMIT 0, 50000;


-- Top 10 Most Voted Restaurants
SELECT name, votes, rate, `approx_cost(for two people)`
FROM zomato_data
ORDER BY votes DESC
LIMIT 10;



--  Average Rating by Booking Availability
SELECT book_table, 
       ROUND(AVG(CAST(SUBSTRING_INDEX(rate, '/', 1) AS DECIMAL(3,1))), 2) AS avg_rating,
       COUNT(*) AS total_restaurants
FROM zomato_data
GROUP BY book_table;


-- Online Order Impact on Rating
SELECT online_order,
       ROUND(AVG(CAST(SUBSTRING_INDEX(rate, '/', 1) AS DECIMAL(3,1))), 2) AS avg_rating,
       COUNT(*) AS total_restaurants
FROM zomato_data
GROUP BY online_order;


 -- Best Restaurants with Table Booking
SELECT name, rate, votes, `approx_cost(for two people)`
FROM zomato_data
WHERE book_table = 'Yes'
ORDER BY CAST(SUBSTRING_INDEX(rate, '/', 1) AS DECIMAL(3,1)) DESC, votes DESC
LIMIT 10;



-- 🎯 Rank Restaurants by Rating Within Cost Ranges


WITH cost_categorized AS (
    SELECT *,
        CASE
            WHEN `approx_cost(for two people)` <= 300 THEN 'Low'
            WHEN `approx_cost(for two people)` BETWEEN 301 AND 800 THEN 'Medium'
            ELSE 'High'
        END AS cost_range
    FROM zomato_data
)

SELECT name,cost_range,rate,votes,RANK() OVER (PARTITION BY cost_range ORDER BY rate DESC, votes DESC) AS rank_within_cost
FROM cost_categorized
WHERE rate IS NOT NULL
LIMIT 50;





