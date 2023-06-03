
SELECT *
FROM CovidProject..CovidVaccinations
ORDER BY 3,4

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM CovidProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Total cases v/s Total deaths
-- Likelihood of death if COVID contracted in India

SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM CovidProject..CovidDeaths
WHERE location LIKE '%INDIA%'
	  AND continent IS NOT NULL
ORDER BY 1,2

-- Total cases v/s Population
-- Percentage of people that contracted COVID

SELECT location,date,population,total_cases,(total_cases/population)*100 as COVIDPercentage
FROM CovidProject..CovidDeaths
--WHERE location LIKE '%INDIA%'
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Countries with Highest Infection Rate compared to Population

SELECT location,population, max(total_cases) as HighestInfectionCount,max((total_cases/population))*100 as COVIDPercentage
FROM CovidProject..CovidDeaths
--WHERE location LIKE '%INDIA%'
WHERE continent IS NOT NULL
GROUP BY location,population
ORDER BY COVIDPercentage DESC

-- Countries with Highest Death Count per Population

--SELECT location,max(cast(total_deaths as int)) as TotalDeathCount
--FROM CovidProject..CovidDeaths
----WHERE location LIKE '%INDIA%'
--WHERE continent IS NOT NULL
--GROUP BY location
--ORDER BY TotalDeathCount DESC


SELECT location,max(total_deaths) as TotalDeathCount
FROM CovidProject..CovidDeaths
--WHERE location LIKE '%INDIA%'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


--BRESKING THINGS BASED ON CONTINENT


SELECT location,max(total_deaths) as TotalDeathCount
FROM CovidProject..CovidDeaths
--WHERE location LIKE '%INDIA%'
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


SELECT continent,max(total_deaths) as TotalDeathCount
FROM CovidProject..CovidDeaths
--WHERE location LIKE '%INDIA%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


SELECT continent,max(total_deaths) as TotalDeathCount
FROM CovidProject..CovidDeaths
--WHERE location LIKE '%INDIA%'
--WHERE continent IS NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- GLOBAL NUMBERS

SELECT location,date,population,total_cases,(total_cases/population)*100 as COVIDPercentage
FROM CovidProject..CovidDeaths
--WHERE location LIKE '%INDIA%'
WHERE continent IS NOT NULL
ORDER BY 1,2

SELECT SUM(total_deaths)
FROM CovidProject..CovidDeaths

--SELECT total_deaths
--FROM CovidProject..CovidDeaths

SELECT SUM(NEW_CASES)
FROM CovidProject..CovidDeaths


-- NEW CASES AND NEW DEATHS

SELECT SUM(new_cases) as SUM_NEW_CASES,SUM(CAST(new_deaths AS INT)) AS SUM_NEW_DEATHS,
	   SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM CovidProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- TOTAL POPULATION V/S VACCINATIONS

SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
		SUM(CAST(vac.new_vaccinations as int)) 
		OVER 
		(PARTITION BY dea.location,dea.date) AS RollingPeopleVaccinated
		
FROM CovidProject..CovidDeaths as dea
JOIN CovidProject..CovidVaccinations as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


-- USE CTE

WITH PopvsVac (continent, location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
		SUM(CAST(vac.new_vaccinations as int)) 
		OVER 
		(PARTITION BY dea.location,dea.date) AS RollingPeopleVaccinated
		
FROM CovidProject..CovidDeaths as dea
JOIN CovidProject..CovidVaccinations as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)


SELECT *,(RollingPeopleVaccinated/population)*100 as RollingVaccinated_per_popln
FROM PopvsVac


--TEMP TABLE


DROP TABLE IF EXISTS #PERCENTPOPULATIONVACCINATED
CREATE TABLE #PERCENTPOPULATIONVACCINATED
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PERCENTPOPULATIONVACCINATED
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
		SUM(CAST(vac.new_vaccinations as int)) 
		OVER 
		(PARTITION BY dea.location,dea.date) AS RollingPeopleVaccinated
		
FROM CovidProject..CovidDeaths as dea
JOIN CovidProject..CovidVaccinations as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *,(RollingPeopleVaccinated/population)*100 as RollingVaccinated_per_popln
FROM #PERCENTPOPULATIONVACCINATED

-- CREATING VIEW TO STORE DAT FOR VISUALISATIONS

CREATE VIEW PERCENTPOPULATIONVACCINATED AS
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
		SUM(CAST(vac.new_vaccinations as int)) 
		OVER 
		(PARTITION BY dea.location,dea.date) AS RollingPeopleVaccinated
		
FROM CovidProject..CovidDeaths as dea
JOIN CovidProject..CovidVaccinations as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *
FROM PERCENTPOPULATIONVACCINATED



--Select COLUMN_NAME,DATA_TYPE
--From INFORMATION_SCHEMA.COLUMNS
--Where TABLE_NAME = 'CovidDeaths'

--ALTER TABLE CovidDeaths
--ALTER COLUMN total_cases float

--ALTER TABLE CovidDeaths
--ALTER COLUMN total_deaths float