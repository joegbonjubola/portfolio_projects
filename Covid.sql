-- SELECT *
-- FROM covid_deaths
-- ORDER BY 3,4;

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM covid_deaths
ORDER BY location,date;

-- Total Cases vs Total Deaths
-- Shows likelihood of dying from Covid in each country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
FROM covid_deaths
WHERE location LIKE '%nigeria%'
ORDER BY location,date;

-- Total Cases vs Population
-- Shows the number of people that have got Covid
SELECT location, date, population, total_cases, (total_cases/population)*100 as perc_pop_infected
FROM covid_deaths
WHERE location LIKE '%nigeria%'
ORDER BY location,date;

-- Countries with the Highest Infection rate vs their Population
SELECT location, population, MAX(total_cases) as highest_infection_count, MAX((total_cases/population)*100) as perc_pop_infected
FROM covid_deaths
GROUP BY location, population 
ORDER BY perc_pop_infected DESC;
-- From this query, Nigeria is ranked #174 in percentage of population infected with only 0.08% of the population infected.

-- Highest Death Count per Country
SELECT location, MAX(total_deaths) as highest_death_count
FROM covid_deaths
WHERE continent IS NOT NULL 
GROUP BY location
ORDER BY highest_death_count DESC;
-- Nigeria ranks 84th in highest death counts out of 210 countries.

-- Highest Death Count per Population
SELECT location, population, MAX(total_deaths) as highest_death_count, MAX((total_deaths/population)*100) as perc_pop_deaths
FROM covid_deaths
WHERE continent IS NOT NULL 
GROUP BY location, population 
ORDER BY perc_pop_deaths DESC;

-- CONTINENTAL EXPLORATION

-- Highest Death Count per Continent
SELECT continent, SUM(new_deaths) as highest_death_count
FROM covid_deaths
WHERE continent IS NOT NULL 
GROUP BY continent
ORDER BY highest_death_count DESC;

-- GLOBAL NUMBERS per date
SELECT date, SUM(new_cases) as total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as death_perc 
FROM covid_deaths
WHERE continent IS NOT NULL 
GROUP BY date
ORDER BY date, total_cases;

SELECT SUM(new_cases) as total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as death_perc 
FROM covid_deaths
WHERE continent IS NOT NULL 
-- GROUP BY date
ORDER BY date, total_cases;

-- JOINED WITH VACCINATION TABLE

-- Total Population vs Vaccinations
WITH popvsvacc (continent, location, date, population, new_vaccinations, people_vaccinated)
AS
(
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location
								ORDER BY cd.location, cd.date) as people_vaccinated
FROM covid_deaths cd 
JOIN covid_vaccinations cv 
	ON cd.location = cv.location 
	AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
-- ORDER BY cd.location, cd.date
)

SELECT *, (people_vaccinated/population)*100 as perc_vacc
FROM popvsvacc;

-- CREATING VIEWS FOR VISUALISATIONS

CREATE VIEW perc_vacc AS
WITH popvsvacc (continent, location, date, population, new_vaccinations, people_vaccinated)
AS
(
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location
								ORDER BY cd.location, cd.date) as people_vaccinated
FROM covid_deaths cd 
JOIN covid_vaccinations cv 
	ON cd.location = cv.location 
	AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
-- ORDER BY cd.location, cd.date
)

SELECT *, (people_vaccinated/population)*100 as perc_vacc
FROM popvsvacc;

CREATE VIEW highest_death_count AS
SELECT continent, SUM(new_deaths) as highest_death_count
FROM covid_deaths
WHERE continent IS NOT NULL 
GROUP BY continent
ORDER BY highest_death_count DESC;
