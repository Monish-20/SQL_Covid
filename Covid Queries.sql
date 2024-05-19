SELECT *
  FROM [PortfolioProjectSQL].[dbo].[CovidDeaths]
  order by 3,4
--SELECT *
--  FROM [PortfolioProjectSQL].[dbo].[CovidVaccinations]
--  order by 3,4

--Select Data that we are using
SELECT location, date, total_cases, new_cases, total_deaths, population
  FROM [PortfolioProjectSQL].[dbo].[CovidDeaths]
  order by 1,2


--Total cases vs Total Deaths
--% of people who died out of the total cases reported
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
  FROM [PortfolioProjectSQL].[dbo].[CovidDeaths]
  WHERE location = 'United States'
  order by 1,2

--Total cases vs Population
--% of population who are affected by Covid
SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
  FROM [PortfolioProjectSQL].[dbo].[CovidDeaths]
  --WHERE location = 'United States'
  order by 1,2


--Countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
  FROM [PortfolioProjectSQL].[dbo].[CovidDeaths]
  --WHERE location = 'United States'
  GROUP BY Location, population
  order by PercentPopulationInfected desc


--Countries with Highest death count compared to population
SELECT location, population, MAX(cast(total_deaths as int)) AS HighestDeathCount, MAX((total_deaths/population))*100 AS PercentPopulationDied
  FROM [PortfolioProjectSQL].[dbo].[CovidDeaths]
  --WHERE location = 'United States'
  WHERE continent is not NULL
  GROUP BY Location, population
  order by HighestDeathCount desc


--Showing continents with highest death count compared to population
SELECT continent,MAX(cast(total_deaths as int)) as TotalDeathCount 
from [PortfolioProjectSQL].[dbo].[CovidDeaths]
where continent is not null
GROUP BY continent
order by TotalDeathCount DESC


--GLOBAL NUMBERS

SELECT date, SUM(new_cases) as total_cases ,SUM(cast(new_deaths as int)) as totao_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
  FROM [PortfolioProjectSQL].[dbo].[CovidDeaths]
  --WHERE location = 'United States'
  where continent is not null
  group by date
  order by 1,2

  SELECT SUM(new_cases) as total_cases ,SUM(cast(new_deaths as int)) as totao_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
  FROM [PortfolioProjectSQL].[dbo].[CovidDeaths]
  --WHERE location = 'United States'
  where continent is not null

  --Total population vs Vaccinations
  select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
   from PortfolioProjectSQL.dbo.CovidDeaths as dea
  join PortfolioProjectSQL.dbo.CovidVaccinations as vac
  on dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null
  order by 1,2,3

  select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
  SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location , dea.date) AS RollingPeopleVaccinated
   from PortfolioProjectSQL.dbo.CovidDeaths as dea
  join PortfolioProjectSQL.dbo.CovidVaccinations as vac
  on dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null
  order by 2,3

  select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
  SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location , dea.date) AS RollingPeopleVaccinated
   from PortfolioProjectSQL.dbo.CovidDeaths as dea
  join PortfolioProjectSQL.dbo.CovidVaccinations as vac
  on dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null
  order by 2,3
  
  --USE CTE
  WITH PopvsVac(Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
  as
 ( 
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
  SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location , dea.date) AS RollingPeopleVaccinated
   from PortfolioProjectSQL.dbo.CovidDeaths as dea
  join PortfolioProjectSQL.dbo.CovidVaccinations as vac
  on dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null
  --order by 2,3
  )
  Select *,(RollingPeopleVaccinated/Population)*100
  from PopvsVac


--USE TEMP TABLE
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
  SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location , dea.date) AS RollingPeopleVaccinated
   from PortfolioProjectSQL.dbo.CovidDeaths as dea
  join PortfolioProjectSQL.dbo.CovidVaccinations as vac
  on dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null
  --order by 2,3

  Select *,(RollingPeopleVaccinated/Population)*100
  from #PercentPopulationVaccinated


--Creating VIEW
Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
  SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location , dea.date) AS RollingPeopleVaccinated
   from PortfolioProjectSQL.dbo.CovidDeaths as dea
  join PortfolioProjectSQL.dbo.CovidVaccinations as vac
  on dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null
  --order by 2,3

select * from PercentPopulationVaccinated