/* COVID-19 data exploration using two tables: COVID-19 Deaths and COVID-19 Vaccinations

Skills used below: Aggregate functions, Subqueries, CTE's, , Window functions, Joins

*/

-- WORLD COVID-19 DEATH DATA

-- Getting familiar with CovidDeath data

SELECT 
    location, date, population, total_cases, total_deaths
FROM
    coviddata.coviddeaths


-- Positive cases per capita*
-- Cases per capita refers to the percentage of a location's population who have tested positive

SELECT 
    location,
    date,
    (total_cases / population)*100 AS percent_infected
FROM
    coviddata.coviddeaths


-- Countries with highest positive cases per capita

SELECT 
    location,
    population,
    MAX(total_cases) AS highest_case_count,
    MAX(total_cases / population) * 100 AS percent_infected
FROM
    coviddata.coviddeaths
GROUP BY location , population
ORDER BY percent_infected DESC


-- Countries with highest positive cases per capita that have populations > 100,000,000

SELECT 
    location,
    population,
    MAX(total_cases) AS highest_case_count,
    MAX((total_cases / population)) * 100 AS percent_infected
FROM
    coviddata.coviddeaths
WHERE
    population > 100000000
GROUP BY location , population
ORDER BY percent_infected DESC	


-- Mortality rate* in each country
-- Mortality rate refers to the poportion of population that has died from a specific disease

SELECT 
	location, 
	population, 
	MAX(total_deaths) AS max_total_deaths, 
	MAX(total_deaths/population)*100 AS mortality_rate
FROM coviddata.coviddeaths
GROUP BY location, population
ORDER BY mortality_rate desc

    
-- Case fatality rate* in each country
-- Case fatality rate refers to the percentage of confirmed postive cases that have resulted in death
    
SELECT location, max_total_deaths, max_total_cases, (max_total_deaths/max_total_cases)*100 AS case_fatality_rate
FROM(  
    WITH CTE_sums AS
		(SELECT
        location,
		new_deaths,
		SUM(new_deaths) OVER (Partition by location Order by location, date) AS sum_total_deaths,
		new_cases,
		SUM(new_cases) OVER (Partition by location Order by location, date) AS sum_total_cases
		FROM coviddata.coviddeaths) 
   SELECT location, 
		MAX(sum_total_deaths) AS max_total_deaths, 
		MAX(sum_total_cases) AS max_total_cases
    FROM CTE_sums
    GROUP BY location 
	) sub
GROUP BY location, max_total_deaths, max_total_cases
ORDER BY case_fatality_rate DESC

    
-- Global count of total new cases per day

SELECT 
    date,
    SUM(new_cases) AS total_new_cases,
    SUM(new_deaths) AS total_new_deaths
FROM
    coviddata.coviddeaths
GROUP BY date
ORDER BY 1 , 2
    
    
******************************************************

-- US COVID DEATH DATA

-- Most recent data on total cases and deaths in United States

SELECT 
    location, date, population, total_cases, total_deaths
FROM
    coviddata.coviddeaths
WHERE
    location LIKE '%states%'
ORDER BY date DESC


-- Percentage of United States population who have died of Covid-19

SELECT 
    location,
    date,
    (total_deaths / population)*100 AS percent_dead
FROM
    coviddata.coviddeaths
WHERE
    location LIKE '%states%'
ORDER BY date DESC


-- Calculate 1 out of how many Americans have died of Covid-19

SELECT 
    location,
    date,
    100/((total_deaths / population)*100) AS one_out_of_x_dead
FROM
    coviddata.deaths
WHERE
    location LIKE '%states%'
ORDER BY date DESC


******************************************************

-- WORLD VACCINATION DATA

-- What percentage of each country is fully vaccinated?

SELECT 
    location,
    MAX(people_fully_vaccinated / population) * 100 AS perc_vaccinated
FROM
    coviddata.vaccinations
GROUP BY location
ORDER BY perc_vaccinated DESC


-- Mortality rate per country versus percentage of population aged 70+
    
SELECT 
    dea.location,
    MAX(dea.total_deaths) AS max_total_deaths,
    MAX(dea.total_deaths / dea.population) * 100 AS mortality_rate,
    vac.aged_70_older
FROM
    coviddata.coviddeaths dea
        JOIN
    coviddata.vaccinations vac ON dea.location = vac.location
        AND dea.date = vac.date
GROUP BY dea.location , vac.aged_70_older
ORDER BY mortality_rate DESC , vac.aged_70_older DESC


-- Mortality rate per country versus national GDP per capita
    
SELECT 
    dea.location,
    MAX(dea.total_deaths) AS max_total_deaths,
    MAX(dea.total_deaths / dea.population) * 100 AS mortality_rate,
    vac.gdp_per_capita
FROM
    coviddata.coviddeaths dea
        JOIN
    coviddata.vaccinations vac ON dea.location = vac.location
        AND dea.date = vac.date
GROUP BY dea.location , vac.gdp_per_capita
ORDER BY mortality_rate DESC , vac.gdp_per_capita DESC








