Select *
From [COVID Portfolio Project]..CovidDeaths
order by 3,4

--Select *
--From [COVID Portfolio Project]..CovidDeaths
--order by 3,4 

-- Select data that will be used 

Select location, date, total_cases, new_cases, total_deaths, population
From [COVID Portfolio Project]..CovidDeaths
order by 1,2 

-- Total Cases vs Total Deaths
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathRate
From [COVID Portfolio Project]..CovidDeaths
Where location like '%Indonesia%' 
OR location like '%states%'
order by 1,2 

-- Total Cases vs Population
Select location, date, total_cases, population, (total_cases/population)*100 as InfectionRate
From [COVID Portfolio Project]..CovidDeaths
Where location like '%Indonesia%' 
OR location like '%states%'
order by 1,2 

-- Countries with highest infection rate 
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100) as MaxInfectionRate 
From [COVID Portfolio Project]..CovidDeaths
Group by location, population
order by MaxInfectionRate desc

-- Highest Death Count
Select location, MAX(cast(total_deaths as int)) as TotalDeaths
From [COVID Portfolio Project]..CovidDeaths
Where continent is not null 
Group by location
order by TotalDeaths desc

-- Highest Death Count per Population (Continents) 
Select location, MAX(cast(total_deaths as int)) as TotalDeaths
From [COVID Portfolio Project]..CovidDeaths
Where continent is null 
Group by location
order by TotalDeaths desc

-- Global Death Percent
Select date, SUM(new_cases) as totalcases, SUM(cast(new_deaths as int)) as totaldeaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as DeathPercent
From [COVID Portfolio Project]..CovidDeaths
Where continent is not null
Group by date
order by 1,2

With PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) 
as
(
-- Join Covid Deaths and Covid Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingVac  
From [COVID Portfolio Project]..CovidDeaths dea
Join [COVID Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/population) *100
From PopvsVac

-- Create a temp table
DROP Table if exists #PercentPopVac
create table #PercentPopVac 
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVac numeric
)

Insert into #PercentPopVac 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingVac  
From [COVID Portfolio Project]..CovidDeaths dea
Join [COVID Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *, (RollingPeopleVac/Population)*100
From #PercentPopVac 