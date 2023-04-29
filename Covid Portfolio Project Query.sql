select *
from [Portfolio Project ]..CovidDeaths
order by 3,4

select *
from [Portfolio Project ]..CovidVaccinations
order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from [Portfolio Project ]..CovidDeaths
order by 1,2

--Looking at Total Cases vs. Total Deaths
select location, date, total_cases, total_deaths, (cast(total_deaths as float)/(cast(total_cases as float)))*100 as DeathPercentage
from [Portfolio Project ]..CovidDeaths
order by 1,2

--Looking at Total Cases vs. Population
select location, date, total_cases, population, (total_cases/population)*100 as CasePercentage
from [Portfolio Project ]..CovidDeaths
--where location like '%states%'
order by 1,2

--Looking at Countries with highest Rate of Infection vs. Population
select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as InfectionRate
from [Portfolio Project ]..CovidDeaths
--where location like '%states%'
group by location, population
order by InfectionRate desc

--Showing Countries with highest death count per population
select location, max(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio Project ]..CovidDeaths
where continent is not null
--where location like '%states%'
group by location
order by TotalDeathCount desc

--Show Continents with highest death count per population
select location, max(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio Project ]..CovidDeaths
where continent is null
--where location like '%states%'
group by location
order by TotalDeathCount desc
 
 --Global Totals
select sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast
	(new_deaths as int))/sum(new_cases)*100 as DeathPercentages
from [Portfolio Project ]..CovidDeaths
--where location like '%states%'
where continent is not null
--group by date
order by 1,2

--Total Population vs. Vaccinations
--CTE
with PopvsVac (continent, location, date, population, new_vaccinations, TotalPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location,
	dea.date) as TotalPeopleVaccinated
from [Portfolio Project ]..CovidDeaths dea
join [Portfolio Project ]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date 
where dea.location is not null
)
select*, (TotalPeopleVaccinated/population)*100
from PopvsVac

--Temp Table
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_vaccinations numeric,
TotalPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint, vac.new_vaccinations, 0)) over (partition by dea.location order by 
	dea.date rows between unbounded preceding and current row) as TotalPeopleVaccinated
from [Portfolio Project ]..CovidDeaths dea
join [Portfolio Project ]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date 
--where dea.location is not null

select*, (TotalPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

--Creating view to store data for later visualizations
create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location,
	dea.date) as TotalPeopleVaccinated
from [Portfolio Project ]..CovidDeaths dea
join [Portfolio Project ]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date 
where dea.location is not null

create view TotalCasesvsTotalDeaths as
select location, date, total_cases, total_deaths, (cast(total_deaths as float)/(cast(total_cases as float)))*100 as DeathPercentage
from [Portfolio Project ]..CovidDeaths

create view TotalCasesbyPopulation as
select location, date, total_cases, population, (total_cases/population)*100 as CasePercentage
from [Portfolio Project ]..CovidDeaths

create view InfectionRate as 
select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as InfectionRate
from [Portfolio Project ]..CovidDeaths
group by location, population

create view ContinentDeathCount as
select location, max(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio Project ]..CovidDeaths
where continent is null
group by location


create view GlobalTotals as
select sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast
	(new_deaths as int))/sum(new_cases)*100 as DeathPercentages
from [Portfolio Project ]..CovidDeaths
where continent is not null

select *
from GlobalTotals
