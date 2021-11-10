/*
Data Exploration of Airbnb listings in the state of Hawai`i

Skills used below: Aggregate functions, CTE's, Window functions, Joins

*/

-- Cleaning the data in each table

SELECT *
FROM airbnb.listings

ALTER TABLE airbnb.listings
DROP COLUMN license

ALTER TABLE airbnb.listings
CHANGE COLUMN last_review last_review DATE NULL DEFAULT NULL ;

SELECT *
FROM airbnb.calendar

ALTER TABLE airbnb.calendar
CHANGE COLUMN date date DATE NULL DEFAULT NULL ;

--------------------------------------------------------------------------------------------------------------------------

-- AIRBNB LISTINGS IN HAWAII

-- Percentage breakdown of Airbnb listings by island

SELECT DISTINCT neighbourhood_group
FROM airbnb.listings

SELECT *
FROM airbnb.listings

WITH 
    CTE1 as (SELECT Count(neighbourhood_group) as kauai FROM airbnb.listings WHERE neighbourhood_group = 'Kauai'),
    CTE2 as (SELECT Count(neighbourhood_group) as maui FROM airbnb.listings WHERE neighbourhood_group = 'Maui'),
    CTE3 as (SELECT Count(neighbourhood_group) as honolulu FROM airbnb.listings WHERE neighbourhood_group = 'Honolulu'),
    CTE4 as (SELECT Count(neighbourhood_group) as hawaii FROM airbnb.listings WHERE neighbourhood_group = 'Hawaii')
SELECT 
	kauai / 22566 *100 as kauai_perc, 
	maui / 22566 *100 as maui_perc, 
	honolulu / 22566 *100 as honolulu_perc, 
	hawaii / 22566 *100 as hawaii_perc
FROM CTE1, CTE2, CTE3, CTE4


-- Number of Airbnbs by neighbourhood

SELECT distinct neighbourhood
FROM airbnb.listings
WHERE neighbourhood_group = 'Kauai'

SELECT distinct neighbourhood, COUNT(id) OVER (PARTITION BY neighbourhood) num_list
FROM airbnb.listings
WHERE neighbourhood_group = 'Kauai'
ORDER BY 1

SELECT distinct neighbourhood, COUNT(id) OVER (PARTITION BY neighbourhood) num_list
FROM airbnb.listings
WHERE neighbourhood_group = 'Maui'
ORDER BY 1

SELECT distinct neighbourhood, COUNT(id) OVER (PARTITION BY neighbourhood) num_list
FROM airbnb.listings
WHERE neighbourhood_group = 'Honolulu'
ORDER BY 1

SELECT distinct neighbourhood, COUNT(id) OVER (PARTITION BY neighbourhood) num_list
FROM airbnb.listings
WHERE neighbourhood_group = 'Hawaii'
ORDER BY 1


-- What is the average price of Airbnb listings on each island?

WITH 
    CTE1 as (SELECT AVG(price) as kauai_avg FROM airbnb.listings WHERE neighbourhood_group = 'Kauai'),
    CTE2 as (SELECT AVG(price) as maui_avg FROM airbnb.listings WHERE neighbourhood_group = 'Maui'),
    CTE3 as (SELECT AVG(price) as honolulu_avg FROM airbnb.listings WHERE neighbourhood_group = 'Honolulu'),
    CTE4 as (SELECT AVG(price) as hawaii_avg FROM airbnb.listings WHERE neighbourhood_group = 'Hawaii')
SELECT 
	kauai_avg,
	maui_avg, 
	honolulu_avg, 
	hawaii_avg
FROM CTE1, CTE2, CTE3, CTE4


-- Top 10 most reviewed Airbnb listings

SELECT name, price, latitude, longitude, number_of_reviews, neighbourhood, neighbourhood_group, number_of_reviews
FROM airbnb.listings
ORDER BY 5 desc
LIMIT 10


-- Average Airbnb price by island

SELECT neighbourhood_group, room_type, AVG(price)
FROM airbnb.listings
GROUP BY neighbourhood_group, room_type
ORDER BY 1, 2

--------------------------------------------------------------------------------------------------------------------------

-- CALENDAR OF RESERVATIONS 2021-22

-- Most highly booked Airbnb's in upcoming year
    
SELECT lis.id, lis.neighbourhood_group, lis.price, COUNT(cal.available) as available_days
FROM airbnb.listings lis
JOIN airbnb.calendar cal ON lis.id = cal.listing_id
WHERE cal.available = 'true'
GROUP BY lis.id, lis.neighbourhood_group, lis.price
ORDER BY 4 
LIMIT 100



