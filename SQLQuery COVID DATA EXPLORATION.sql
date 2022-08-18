SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3, 4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3, 4


SELECT Location, Date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Comparing total deaths against total cases and putting it into percentages in the United States
SELECT Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE Location LIKE '%states%'
ORDER BY 1,2

--Comparing the total cases against the population in Nigeria
SELECT Location, Date, population, total_cases, (total_cases/population)*100 AS InfectionPercentage
FROM PortfolioProject..CovidDeaths
WHERE Location LIKE '%nigeria%' and continent IS NOT NULL
ORDER BY 1,2


--Comparing the total cases against the population in the US
SELECT Location, Date, population, total_cases, (total_cases/population)*100 AS InfectionPercentage
FROM PortfolioProject..CovidDeaths
WHERE Location LIKE '%states%' and continent is not null
ORDER BY 1,2

--Countries with highest infection rates
SELECT Location, Population, MAX (total_cases) AS HighestInfectionCount,MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location, Population
ORDER BY 4 desc


--Contries with highest death count
SELECT Location, Population, MAX (cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location, Population
ORDER BY TotalDeathCount desc

--Continents with highest death count
SELECT continent, MAX (cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount desc


--GLOBAL NUMBERS
SELECT Date, SUM(new_cases) as NEWCASES, SUM(cast(new_deaths as int)) AS NEWDEATHS
FROM PortfolioProject..CovidDeaths
WHERE Continent IS NOT NULL 
GROUP BY date
ORDER BY 1,2


SELECT date, SUM(new_cases) as totalcases, SUM(cast(new_deaths as int)) as totaldeaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as percentagedeaths
FROM PortfolioProject..CovidDeaths
WHERE Continent IS NOT NULL 
GROUP BY date
ORDER BY 1,2


--Total population vs vaccination
SELECT *
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date


WITH PopvsVac (continent, location, date, population, new_vaccinnations, RollingPeopleVaccinated)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) 
OVER (Partition by dea.Location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac



-- TEMP TABLE 
DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) 
OVER (Partition by dea.Location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated





--Create view for visualizations

Create view PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) 
OVER (Partition by dea.Location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3


