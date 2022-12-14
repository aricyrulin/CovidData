SELECT *
FROM PortfolioProject..CovidDeath
WHERE continent IS NOT NULL
ORDER BY 3, 4;

SELECT *
FROM PortfolioProject..CovidVaccination
WHERE continent IS NOT NULL
ORDER BY 3, 4;

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeath
WHERE continent IS NOT NULL
ORDER BY 1, 2;

-- Likelihood of dying if you contract Covid in Brazil
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
FROM PortfolioProject..CovidDeath
WHERE location = 'Brazil'
AND continent IS NOT NULL
ORDER BY 1, 2;

-- Percentage of population that got Covid in Brazil
SELECT location, date, population, total_cases, (total_cases/population)*100 AS percent_people_infected
FROM PortfolioProject..CovidDeath
WHERE location = 'Brazil'
AND continent IS NOT NULL
ORDER BY 1, 2;

-- Countries with higher infection rate
SELECT location, population, MAX(total_cases) AS highest_infection_count, MAX((total_cases/population))*100 AS highest_infection_percentage
FROM PortfolioProject..CovidDeath
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY highest_infection_percentage DESC;

-- Countries with highest death count
SELECT location, MAX(CAST(total_deaths AS int)) AS death_count
FROM PortfolioProject..CovidDeath
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY death_count DESC;

-- Continents with highest death count
SELECT continent, MAX(CAST(total_deaths AS int)) AS death_count
FROM PortfolioProject..CovidDeath
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY death_count DESC;

-- Global cases and deaths per day
SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS 'death_percentage'
FROM PortfolioProject..CovidDeath
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2;

-- Percentage of people vaccinated in the World
WITH PopvsVac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM PortfolioProject..CovidDeath dea
JOIN PortfolioProject..CovidVaccination vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (rolling_people_vaccinated/population)*100 AS people_vaccinated_percent
FROM PopvsVac


-- TEMP TABLE
DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM PortfolioProject..CovidDeath dea
JOIN PortfolioProject..CovidVaccination vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (rolling_people_vaccinated/population)*100 AS people_vaccinated_percent
FROM #PercentPopulationVaccinated

-- Store for data visualization

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM PortfolioProject..CovidDeath dea
JOIN PortfolioProject..CovidVaccination vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *
FROM PercentPopulationVaccinated;