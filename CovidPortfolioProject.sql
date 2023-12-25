SELECT  *
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
ORDER BY 3,4

--Select the Data that we are going to be using
SELECT  Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
ORDER BY 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country
SELECT  Location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float,total_cases),0))*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'Grenada' AND continent is not NULL
ORDER BY 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population got covid
SELECT  Location, date, population, total_cases, (CONVERT(float, total_cases) / NULLIF(CONVERT(float,population),0))*100 AS InfectionPercentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'Grenada' AND continent is not NULL
ORDER BY 1,2

--Looking at Countries with Highest Infection Rate compared to population
SELECT  Location, population, MAX(total_cases) AS HighestInfectionCount, (CONVERT(float,MAX( total_cases)) / NULLIF(CONVERT(float,population),0))*100 AS InfectionPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
GROUP BY population, location
ORDER BY InfectionPercentage DESC

--Showing Countries with Highest Death Count per population
SELECT  Location, population, MAX(CONVERT(float,total_deaths)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
GROUP BY population, location
ORDER BY TotalDeathCount DESC

--Breaking things down by continent

--Showing continents with the highest death count
SELECT  continent, MAX(CONVERT(float,total_deaths)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


--Global Numbers

--Death Percentage by date
SELECT  date, SUM(new_cases) AS TotalCases, SUM(new_deaths)as TotalDeaths, (SUM(new_deaths)/NULLIF(SUM(new_cases),0))*100 AS DeathPercentage  --(total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float,total_cases),0))*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
GROUP BY date
ORDER BY 1,2

--Death Percentage for the world
SELECT SUM(new_cases) AS TotalCases, SUM(new_deaths)as TotalDeaths, (SUM(new_deaths)/NULLIF(SUM(new_cases),0))*100 AS DeathPercentage  --(total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float,total_cases),0))*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
ORDER BY 1,2


--Looking at Total Population vs. Vaccinations
SELECT death.continent, death.location, death.date, death.population, vaccine.new_vaccinations,
SUM(CONVERT(float,vaccine.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths death
JOIN PortfolioProject..CovidVaccinations vaccine
	ON death.date = vaccine.date
	AND death.location = vaccine.location
WHERE death.continent is not NULL AND vaccine.new_vaccinations is not NULL
ORDER BY 2,3

--USE CTE
WITH PopvsVac  (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS (SELECT death.continent, death.location, death.date, death.population, vaccine.new_vaccinations,
SUM(CONVERT(float,vaccine.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths death
JOIN PortfolioProject..CovidVaccinations vaccine
	ON death.date = vaccine.date
	AND death.location = vaccine.location
WHERE death.continent is not NULL AND vaccine.new_vaccinations is not NULL
)
SELECT *, (RollingPeopleVaccinated/Population)*100 AS PercentageVaccinated
FROM PopvsVac

--USING TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(Continent nvarchar(255), Location nvarchar(255), Date datetime, Population numeric, New_vaccinations numeric, RollingPeopleVaccinated numeric)

INSERT INTO #PercentPopulationVaccinated
SELECT death.continent, death.location, death.date, death.population, vaccine.new_vaccinations,
SUM(CONVERT(float,vaccine.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths death
JOIN PortfolioProject..CovidVaccinations vaccine
	ON death.date = vaccine.date
	AND death.location = vaccine.location
WHERE death.continent is not NULL AND vaccine.new_vaccinations is not NULL

SELECT *, (RollingPeopleVaccinated/Population)*100 AS PercentageVaccinated
FROM #PercentPopulationVaccinated

--Creating ViewS to store data for later visualizations
USE PortfolioProject

CREATE VIEW PercentPopulationVaccinated as
SELECT death.continent, death.location, death.date, death.population, vaccine.new_vaccinations,
SUM(CONVERT(float,vaccine.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths death
JOIN PortfolioProject..CovidVaccinations vaccine
	ON death.date = vaccine.date
	AND death.location = vaccine.location
WHERE death.continent is not NULL AND vaccine.new_vaccinations is not NULL

CREATE VIEW CasesvsDeaths AS
SELECT  Location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float,total_cases),0))*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL

CREATE VIEW CountryDeathCount AS
SELECT  Location, population, MAX(CONVERT(float,total_deaths)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
GROUP BY population, location

CREATE VIEW ContinentDeathCount AS
SELECT  continent, MAX(CONVERT(float,total_deaths)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
GROUP BY continent

CREATE VIEW PopulationVaccinated AS
SELECT death.continent, death.location, death.date, death.population, vaccine.new_vaccinations,
SUM(CONVERT(float,vaccine.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths death
JOIN PortfolioProject..CovidVaccinations vaccine
	ON death.date = vaccine.date
	AND death.location = vaccine.location
WHERE death.continent is not NULL AND vaccine.new_vaccinations is not NULL

