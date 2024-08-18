select *
from [Personal Portfolio]..CovidDeaths$
order by 3,4
----select *
------from [Personal Portfolio]..CovidVaccinations$
------order by 3,4

--select data that we are going to be using
select location,date,total_cases,new_cases,total_deaths,population
from [Personal Portfolio]..CovidDeaths$
order by 1,2

-- looking at total cases vs total deaths
--shows likelihood of dying if you contract covid in your country
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as deathpercentage
from [Personal Portfolio]..CovidDeaths$
where location like '%states%'
order by 1,2

--looking at total_cases vs population
select location,date,total_cases,population,(total_cases/population)*100 as Covidpercentage
from [Personal Portfolio]..CovidDeaths$
where location like '%states%'
order by 1,2

--looking at countries with highest infection rate compared to population
select location,population,max(total_cases)as HighestInfectionCount,max((total_cases/population))*100 
as MaxPercentageInfected
from [Personal Portfolio]..CovidDeaths$
--where location like '%states%'
group by location,population
order by MaxPercentageInfected desc

--showing countries with highest death count per population
select location,max(cast(total_deaths as int))as TotalDeathCount
from [Personal Portfolio]..CovidDeaths$
where continent is not null
group by location
order by TotalDeathCount desc

--let's break things down by continent(as a whole)
select continent,max(cast(total_deaths as int))as TotalDeathCount
from [Personal Portfolio]..CovidDeaths$
where continent is not null
group by continent
order by TotalDeathCount desc

--showing continents with highests death count
select continent,max(cast(total_deaths as int))as TotalDeathCount
from [Personal Portfolio]..CovidDeaths$
where continent is not null
group by continent
order by TotalDeathCount desc

-- global numbers
select sum(new_cases)as total_cases,sum(CAST(new_deaths as int))as total_deaths,sum(CAST(new_deaths as int))/sum(new_cases)*100 as deathpercentage
from [Personal Portfolio]..CovidDeaths$
--where location like '%states%'
where continent is not null
--group by date
order by 1,2

--looking at total population vs vaccinations
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date)
as rollingpeopleVaccinated
from [Personal Portfolio]..CovidDeaths$ dea
join [Personal Portfolio]..CovidVaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3

--use CTE
With POPvsVAC(Continent,Location,Date,Population,New_vaccinations,RollingPeopleVaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date)
as RollingPeopleVaccinated
from [Personal Portfolio]..CovidDeaths$ dea
join [Personal Portfolio]..CovidVaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select *,(RollingPeopleVaccinated/Population)*100 as percentVaccinated
from POPvsVAC

--temp table
drop table if exists #percentPopulationVaccinated
create table #percentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #percentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date)
as RollingPeopleVaccinated
from [Personal Portfolio]..CovidDeaths$ dea
join [Personal Portfolio]..CovidVaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null

select *,(RollingPeopleVaccinated/Population)*100 as percentVaccinated
from #percentPopulationVaccinated

--creating view to store data for later visualization
create view PercentPopulationVaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date)
as RollingPeopleVaccinated
from [Personal Portfolio]..CovidDeaths$ dea
join [Personal Portfolio]..CovidVaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
