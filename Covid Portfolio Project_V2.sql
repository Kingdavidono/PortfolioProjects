SELECT * FROM CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--SELECT * FROM CovidVaccinations
--ORDER BY 3,4

-- Select Data that we are going to be using

SELECT location,date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
WHERE continent is not null
ORDER BY 1,2

-- Alter total cases and total deaths to FLOAT
ALTER TABLE CovidDeaths
Alter Column total_cases FLOAT
ALTER TABLE CovidDeaths
Alter Column total_deaths FLOAT

-- Looking at Total Cases vs Total Deaths
-- Shows Likeliood of dying if you contract Covid
SELECT location,date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE continent is not null and
location LIKE '%nigeria%'
ORDER BY 1,2

-- Looking at Total Cases vs Population
SELECT location,date, population, total_cases,  (total_cases/population)*100 as InfectedPopulationPercentage
FROM CovidDeaths
WHERE continent is not null
--WHERE location LIKE '%nigeria%'
ORDER BY 1,2

-- Looking at Countries with Highest Infection Rate compared to population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_deaths/population))*100 as InfectedPopulationPercentage
FROM CovidDeaths
WHERE continent is not null
--WHERE location LIKE '%nigeria%'
GROUP BY location, population
ORDER BY location DESC, InfectedPopulationPercentage DESC

-- Looking at Continents with Highest Death compared to population
SELECT date, continent, MAX(cast(total_deaths as int)) as HighestDeathCount
FROM CovidDeaths
WHERE continent is not null
--and location LIKE '%africa%'
GROUP BY date, continent
ORDER BY date DESC, continent DESC, HighestDeathCount DESC


-- Looking at Countries with Highest Death compared to population
SELECT location, MAX(cast(total_deaths as int)) as HighestDeathCount
FROM CovidDeaths
WHERE continent is not null
--and location LIKE '%nigeria%'
GROUP BY location
ORDER BY HighestDeathCount DESC

-- Global numbers
SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
FROM CovidDeaths
--and location LIKE '%nigeria%'
WHERE continent is not null
--GROUP BY date
ORDER BY  1, 2

-- Total Population vs Total Vaccinations
-- USE CTE
With POPvsVAC (continent, location, date, population, new_vaccinations, RollingWave_Vaccinated)
AS (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as float)) OVER (partition by dea.location ORDER BY dea.location, dea.date) as RollingWave_Vaccinated
-- (RollingWave_Vaccinated/Population)*100
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 1,2,3
)
SELECT *, (RollingWave_Vaccinated/population)*100 
FROM POPvsVAC
-- WHERE location like '%nigeria%'


-- TEMP TABLE

DROP TABLE if exists #PercentagePopulationVaccinated
Create Table #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingWave_Vaccinated numeric
)
Insert into #PercentagePopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as float)) OVER (partition by dea.location ORDER BY dea.location, dea.date) as RollingWave_Vaccinated
-- (RollingWave_Vaccinated/Population)*100
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 1,2,3

SELECT *, (RollingWave_Vaccinated/population)*100 
FROM #PercentagePopulationVaccinated


-- Creating View to store data for visualization

CREATE View PercentagePopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as float)) OVER (partition by dea.location ORDER BY dea.location, dea.date) as RollingWave_Vaccinated
-- (RollingWave_Vaccinated/Population)*100
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 1,2,3

SELECT * FROM PercentagePopulationVaccinated