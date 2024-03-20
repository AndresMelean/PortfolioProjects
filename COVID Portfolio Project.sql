SELECT *
FROM PorfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY location, date


--SELECT *
--FROM PorfolioProject.dbo.CovidVaccinations
--ORDER BY location, date


SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PorfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY location, date


-- Total Cases vs Total Deaths
SELECT location, date, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 AS DeathPercentage
FROM PorfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY location, date

-- Total Cases vs Population
SELECT location, date, total_cases, population, (total_cases/population)*100 AS PercentPopulationInfected
FROM PorfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY location, date


-- Countries with Highest Infection Rate Compared to Population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PorfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC


-- Countries with Highest Death Count Per Population
SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PorfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


-- Continents with Highest Death Count
SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PorfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- Global Numbers
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/Sum(new_cases)*100 AS DeathPercentage
FROM PorfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


-- Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, 
  dea.date) AS RollingPeopleVaccinated
--, (RollingPepleVaccinated/population)*100
FROM PorfolioProject.dbo.CovidDeaths dea
JOIN PorfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3


-- Using CTE
WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, 
  dea.date) AS RollingPeopleVaccinated
--, (RollingPepleVaccinated/population)*100
FROM PorfolioProject.dbo.CovidDeaths dea
JOIN PorfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac


-- Using Temp Table
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, 
  dea.date) AS RollingPeopleVaccinated
--, (RollingPepleVaccinated/population)*100
FROM PorfolioProject.dbo.CovidDeaths dea
JOIN PorfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
-- ORDER BY 2, 3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated

-- Creating View to Store Data for Later Visualizations
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, 
  dea.date) AS RollingPeopleVaccinated
--, (RollingPepleVaccinated/population)*100
FROM PorfolioProject.dbo.CovidDeaths dea
JOIN PorfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3

SELECT *
FROM PercentPopulationVaccinated