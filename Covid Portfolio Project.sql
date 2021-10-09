SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3, 4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3, 4



SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1, 2



--Looking At Total Cases vs Total Deaths



--Likelyhood of dying if you contract covid in your country
--What percentage of the population got covid
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1, 2



--Total Cases vs Population
SELECT Location, date, Population, total_cases, (total_cases/population)*100 as PercentofPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1, 2



--Which Countries Have The Highest Infection Rate Compared To Population
SELECT Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentofPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
GROUP BY Location, Population
ORDER BY PercentofPopulationInfected desc



--Which Countries Have The Highest Death Count Compared To Population
SELECT Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount desc



--By Continent
SELECT continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc


--Global Numbers
SELECT date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY date
ORDER BY 1, 2


--Looking at Total Population vs Vaccination

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 1,2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

--Temp Table
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVacinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 1,2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PercentPopulationVaccinated


--Creating View to Store Data For Later Visualizations

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3