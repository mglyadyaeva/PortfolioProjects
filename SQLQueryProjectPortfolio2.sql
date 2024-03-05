SELECT *
FROM PortfolioProject.dbo.CovidDeaths$
Where continent is not null
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject.dbo.CovidVaccinations$
--ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths$
ORDER BY 1,2

--Total Cases VS Total Deaths
--Likelihood of  dying of covid in the country

SELECT location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths$
WHERE location = 'ukraine'
ORDER BY 1,2

--Total Cases VS Population

SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths$
--WHERE location = 'ukraine'
ORDER BY 1,2

--Looking at Countries with Highest Infection Rate to Population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths$
--WHERE location = 'ukraine'
GROUP BY location, population
ORDER BY PercentPopulationInfected desc

--Countried with Highest Death Count per Population
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths$
--WHERE location = 'ukraine'
Where continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc

-- Same by continent
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths$
--WHERE location = 'ukraine'
Where continent is null
GROUP BY location
ORDER BY TotalDeathCount desc

--GLOBAL NUMBERS
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths$
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

-- Total Population VS Vaccinations
With PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as  RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths$ dea
Join PortfolioProject.dbo.CovidVaccinations$ vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is not null
--Order by 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopVsVac

--Creating view to store data for later visualizations

Create view PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as  RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths$ dea
Join PortfolioProject.dbo.CovidVaccinations$ vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is not null
--Order by 2,3

Select*
FROM PercentPopulationVaccinated