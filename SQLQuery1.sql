SELECT * 
FROM CovidDeaths
order by 3,4

SELECT Location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
order by 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract COVID
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
WHERE location like '%states%'
order by 1, 2

-- Looking at total cases vs population

SELECT Location, date, total_cases, population,  (total_cases/population)*100 as Percent_of_Population_with_a_case
from dbo.CovidDeaths
WHERE location like '%states%'
order by 1, 2

--Looking at counrties with highest infection rate compared to population

SELECT Location, population, MAX(total_cases) as HighestInfectionCount, (MAX(total_cases)/population)*100 as Infection_Rate_of_Population
from dbo.CovidDeaths
GROUP BY Location, population
order by Infection_Rate_of_Population desc

-- Showing countries with highest death count per population

SELECT Location, max(cast(total_deaths as int)) as MaxDeathCount, (max(total_deaths)/population)*100 as DeathPercentage
FROM CovidDeaths
Where continent is not null
GROUP BY Location, population
ORDER BY MaxDeathCount desc

-- Showing Continent grouping

SELECT location, max(cast(total_deaths as int)) as MaxDeathCount
FROM CovidDeaths
Where continent is null
GROUP BY location
ORDER BY MaxDeathCount desc

--Showing continent with highest death counts per population
SELECT continent, max(cast(total_deaths as int)) as MaxDeathCount
FROM CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY MaxDeathCount desc

-- Global numbers

SELECT date, SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths,  SUM(cast(new_deaths as int)) / SUM(new_cases) * 100 as Death_Percentage
FROM dbo.CovidDeaths
WHERE continent is not null
GROUP BY date
order by 1, 2

SELECT SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths,  SUM(cast(new_deaths as int)) / SUM(new_cases) * 100 as Death_Percentage
FROM dbo.CovidDeaths
WHERE continent is not null
order by 1, 2

-- Join vaccination and deaths tables

SELECT *
FROM dbo.CovidDeaths dea
 Join dbo.CovidVaccinations vac
	ON	dea.location = vac.location
	and dea.date = vac.date

-- Looking at total population vs vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM dbo.CovidDeaths dea
 Join dbo.CovidVaccinations vac
	ON	dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
order by 2,3

-- USE CTE

WITH PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated--, (RollingPeopleVaccinated/population)*100
FROM dbo.CovidDeaths dea
 Join dbo.CovidVaccinations vac
	ON	dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac

-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255),
date datetime,
population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric,
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated--, (RollingPeopleVaccinated/population)*100
FROM dbo.CovidDeaths dea
 Join dbo.CovidVaccinations vac
	ON	dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated

-- CREATING VIEW TO STORE DATA FOR LATER VIZ

CREATE View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated--, (RollingPeopleVaccinated/population)*100
FROM dbo.CovidDeaths dea
 Join dbo.CovidVaccinations vac
	ON	dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null

SELECT * 
FROM PercentPopulationVaccinated 
