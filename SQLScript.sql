select * 
from MedicalPoject..CovidDeaths
order by 3,4


--select * 
--from MedicalPoject..CovidVaccinations
--order by 3,4


--Select data that we are going to be use 

select location, date,total_cases,population,new_cases,total_cases
from MedicalPoject..CovidDeaths
where continent is not null
order by 1,2

-- looking at Total Cases vs Total Deaths
-- show likelihood of dyaing if your contract covid in your country 
select location, date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from MedicalPoject..CovidDeaths
where location like '%Egypt%'
and continent is not null
order by 1,2

-- looking at Total Cases vs population
-- shows what percentage of population got covid
select location, date,total_cases,population,(total_cases/population)*100 as PercentPopulationInfection
from MedicalPoject..CovidDeaths
--where location like '%Egypt%'
order by 1,2

-- looking at Countries with Highest Infection Rate compared to population

select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfection
from MedicalPoject..CovidDeaths
--where location like '%Egypt%'
where continent is not null
Group by location, population
order by PercentPopulationInfection desc

--showing countries with Highest Deaths Count per Population

select location, max(cast(total_cases as int)) as TotalDeathCount
from MedicalPoject..CovidDeaths
--where location like '%Egypt%'
where continent is not null
Group by location
order by TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT 

-- Showing continents with the Highest death cont per Popultion

select continent, max(cast(total_cases as int)) as TotalDeathCount
from MedicalPoject..CovidDeaths
--where location like '%Egypt%'
where continent is not null
Group by continent
order by TotalDeathCount desc



-- Global Numbers

select sum(total_cases) as TotalCases, sum(cast(new_deaths as int))as TotalDeaths,
(sum(cast(new_deaths as bigint))/sum(new_cases))*100 as DeathPercentage
from MedicalPoject..CovidDeaths
--where location like '%Egypt%'
where continent is not null
--group by date 
order by 1,2



-- looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 sum(CONVERT(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date ) as RollingPeopleVaccinated
 --,(RollingPeoplevaccinated/Population) 
from MedicalPoject..CovidDeaths dea
join MedicalPoject..CovidVaccinations vac
	On dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null 
order by  2, 3

-- USE CTE

WITH PopvsVas (continent, location, date, population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 sum(CONVERT(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date ) as RollingPeopleVaccinated
from MedicalPoject..CovidDeaths dea
join MedicalPoject..CovidVaccinations vac
	On dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null 
--order by  2, 3
)

select *, (RollingPeoplevaccinated/Population)*100 
from PopvsVas


-- TEMP TABLE

Drop table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated

(
Contintent nvarchar(255),
location nvarchar(255),
date datetime,
Population numeric,
New_Vaccination numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 sum(Cast( vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date ) as RollingPeopleVaccinated
from MedicalPoject..CovidDeaths dea
join MedicalPoject..CovidVaccinations vac
	On dea.location=vac.location
	and dea.date=vac.date
--where dea.continent is not null 
--order by  2, 3


select *, (RollingPeoplevaccinated/Population)*100 
from #PercentPopulationVaccinated


--Creating view to sore date for later Visualizations

Create View vw_PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 sum(Cast( vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date ) as RollingPeopleVaccinated
from MedicalPoject..CovidDeaths dea
join MedicalPoject..CovidVaccinations vac
	On dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null 
--order by  2, 3

