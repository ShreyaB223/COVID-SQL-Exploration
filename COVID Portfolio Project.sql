SELECT *
FROM ProjectPortfolio..CovidDeaths
ORDER BY 1,2

SELECT *
FROM ProjectPortfolio..CovidDeaths
WHERE location = ''
ORDER BY 2,3

DELETE FROM ProjectPortfolio..CovidDeaths
WHERE TRIM(location) = ''


--SELECT *
--FROM ProjectPortfolio..CovidVaccinations
--ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM ProjectPortfolio..CovidDeaths
ORDER BY 1,2


-- Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in a certain country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Rate
FROM ProjectPortfolio..CovidDeaths 
ORDER BY 1,2



-- Total Cases vs Population

SELECT location, date, population, total_cases, (total_cases/population)*100 as Infection_Rate
FROM ProjectPortfolio..CovidDeaths
ORDER BY 1,2


-- Countries with highest Infection Rate

SELECT location, population, MAX(total_cases) AS Highest_Infection_Count, MAX((total_cases/population))*100 AS Percent_Population_Infected
FROM ProjectPortfolio..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY Percent_Population_Infected DESC


--Countries with Highest Death Count per Population

SELECT location, population, MAX((total_cases)) AS Highest_Infection_Count, MAX(cast(total_deaths as int)) AS Death_Count
FROM ProjectPortfolio..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY Death_Count DESC

-- Continents with the Highest Death Count

SELECT continent, SUM(population) AS Total_popukation, MAX((total_cases)) AS Highest_Infection_Count, MAX(cast(total_deaths as int)) AS Death_Count
FROM ProjectPortfolio..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Death_Count DESC

SELECT continent, location, population, total_cases, total_deaths
FROM ProjectPortfolio..CovidDeaths
ORDER BY 1,2

--SELECT continent, SUM(total_deaths) AS Continent_deaths
--FROM ProjectPortfolio..CovidDeaths
--GROUP BY continent
--ORDER BY 1

--SELECT *
--FROM ProjectPortfolio..CovidDeaths
--WHERE location = 'Asia'
--ORDER BY 1,2

SELECT continent, MAX(cast(total_deaths AS INT)) AS Total_deathcount
FROM ProjectPortfolio..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Total_deathcount DESC


-- Global numbers
 
SELECT date, SUM(new_cases) AS Total_cases, SUM(cast(new_deaths AS INT)) AS Total_deaths, ( SUM(cast(new_deaths AS INT))/SUM(new_cases))*100 AS Death_Percentage
FROM ProjectPortfolio..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

SELECT SUM(new_cases) AS Total_cases, SUM(cast(new_deaths AS INT)) AS Total_deaths, ( SUM(cast(new_deaths AS INT))/SUM(new_cases))*100 AS Death_Percentage
FROM ProjectPortfolio..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2



--Total population vs Vaccinations

SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations
FROM ProjectPortfolio..CovidDeaths DEA
JOIN ProjectPortfolio..CovidVaccinations VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL
ORDER BY 2,3




SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations,
	SUM(CONVERT(INT, VAC.new_vaccinations)) OVER (PARTITION BY DEA.location ORDER BY DEA.location, DEA.date) 
	AS Count_of_doses
FROM ProjectPortfolio..CovidDeaths DEA
JOIN ProjectPortfolio..CovidVaccinations VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL
ORDER BY 2,3

--Population Vaccinated (using CTE)

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, Count_of_doses)
AS 
(
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations,
	SUM(CONVERT(INT, VAC.new_vaccinations)) OVER (PARTITION BY DEA.location ORDER BY DEA.location, DEA.date) 
	AS Count_of_doses
FROM ProjectPortfolio..CovidDeaths DEA
JOIN ProjectPortfolio..CovidVaccinations VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL
)
SELECT *, (Count_of_doses/Population)*100 AS Population_Vaccinated
FROM PopvsVac


--Population Vaccinated (using Temp Table)

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_vaccinations numeric,
	Count_of_doses numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations,
	SUM(CONVERT(INT, VAC.new_vaccinations)) OVER (PARTITION BY DEA.location ORDER BY DEA.location, DEA.date) 
	AS Count_of_doses
FROM ProjectPortfolio..CovidDeaths DEA
JOIN ProjectPortfolio..CovidVaccinations VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (Count_of_doses/Population)*100 AS Population_Vaccinated
FROM #PercentPopulationVaccinated




--Creating views

DROP VIEW IF EXISTS PercentPopulationVaccinated
CREATE VIEW PercentPopulationVaccinated AS
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations,
	SUM(CONVERT(INT, VAC.new_vaccinations)) OVER (PARTITION BY DEA.location ORDER BY DEA.location, DEA.date) 
	AS Count_of_doses
FROM ProjectPortfolio..CovidDeaths DEA
JOIN ProjectPortfolio..CovidVaccinations VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL





