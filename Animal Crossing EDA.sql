/*
Exploratory Data Analysis using Crafting Recipes from Nintendo's ANIMAL CROSSING

Skills used below: Aggregate functions, CTE's, Window functions

-- In the popular Nintendo Switch game Animal Crossing, players are able to craft items by using resources found on their island. The 'Name' column contains items that are craftable via the resources contained in the 'Material' columns.

*/

--------------------------------------------------------------------------------------------------------------------------

-- EXPLORING AND ANALYZING THE DATA

SELECT *
FROM ac.recipes

-- Breakdown of recipes that require 1 or more materials

WITH 
    CTE1 as (SELECT Count(name) as numrecipes1 FROM ac.recipes WHERE Material_2 is null),
    CTE2 as (SELECT Count(name) as numrecipes2 FROM ac.recipes WHERE Material_2 is not null AND Material_3 is null),
    CTE3 as (SELECT Count(name) as numrecipes3 FROM ac.recipes WHERE Material_3 is not null AND Material_4 is null),
    CTE4 as (SELECT Count(name) as numrecipes4 FROM ac.recipes WHERE Material_4 is not null AND Material_5 is null),
    CTE5 as (SELECT Count(name) as numrecipes5 FROM ac.recipes WHERE Material_5 is not null AND Material_6 is null),
    CTE6 as (SELECT Count(name) as numrecipes6 FROM ac.recipes WHERE Material_6 is not null)
SELECT 
	numrecipes1 / 595 *100 AS perc_1mat, 
    numrecipes2 / 595 *100 AS perc_2mat, 
	numrecipes3 / 595 *100 AS perc_3mat,
	numrecipes4 / 595 *100 AS perc_4mat,
    numrecipes5 / 595 *100 AS perc_5mat,
    numrecipes6 / 595 *100 AS perc_6mat
FROM CTE1, CTE2, CTE3, CTE4, CTE5, CTE6


-- Most popular categories of recipes

SELECT distinct(category)
FROM ac.recipes

SELECT name, category
FROM ac.recipes
ORDER BY 2


-- Most popular source of recipes

SELECT distinct(source)
FROM ac.recipes

SELECT name, source
FROM ac.recipes
ORDER BY 2


-- Most popular materials

SELECT distinct(Material_1)
FROM ac.recipes
ORDER BY 1

SELECT name, Material_1
FROM ac.recipes
ORDER BY 2

--------------------------------------------------------------------------------------------------------------------------

-- WHAT CAN I MAKE WITH THESE MATERIALS?

-- What can I make with only apples?

SELECT name, M1_amount AS apples_needed
FROM ac.recipes
WHERE Material_1 LIKE 'apple' AND Material_2 is null


-- What can I make with only iron nuggets and softwood?

SELECT name, Material_1, M1_amount AS matierial1_needed, Material_2, M2_amount AS material2_needed
FROM ac.recipes
WHERE Material_1 = 'iron nugget' AND Material_2 = 'softwood' AND Material_3 is null


-- How many recipes use iron nuggets as a crafting material

SELECT Count(name)
FROM ac.recipes
WHERE Material_1 = 'iron nugget' OR Material_2 = 'iron nugget' OR Material_3 = 'iron nugget' OR Material_4 = 'iron nugget'

