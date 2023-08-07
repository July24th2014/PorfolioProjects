select *
from profolioproject.coviddeaths
where continent is not null
order by 3,4
;

select *
from profolioproject.covidvaccinations
order by 3,4


/* Select data using */

select location, date, total_cases, new_cases, total_deaths, MyUnknownColumn as population
from profolioproject.coviddeaths
order by 1 
;

/*Total cases vs Total Deaths*/

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as CasesResultDeaths
from profolioproject.coviddeaths
where location like '%nam'
order by 1 
;

/*Total cases vs population*/

select location, date, total_cases, MyUnknownColumn as Population, (total_cases/MyUnknownColumn)*100 as PopulationInfected
from profolioproject.coviddeaths
where location like '%states'
order by 1 
;

/*Countries with Highest Infection Rate compared to Population*/

select location, max(total_cases) as HighestInfectionCount, MyUnknownColumn as Population,  max((total_cases/MyUnknownColumn))*100 as PopulationInfected
from profolioproject.coviddeaths
 -- where location like '%nam'
group by location, Population
order by PopulationInfected desc
;

/*Countries with Highest Death Count per Population*/

-- Continent 

select continent, max(cast(total_deaths as double)) as TotalDeathsCount
from profolioproject.coviddeaths
where continent is not null
group by continent 
order by TotalDeathsCount desc
;

-- GLOBAL NUMBERS

select SUM(new_cases) as totalcases, SUM(cast(new_deaths as double)) as totaldeaths, SUM(cast(new_deaths as double))/SUM(new_cases)*100 as DeathPercentage
from profolioproject.coviddeaths
 where continent is not null
-- group by date
order by 1, 2
;

-- JOIN Looking at total population vs vaccination
-- SUM(CONVERT(int, vac.new_vaccinations))


With PopvsVac (continent , location , date, MyUnknownColumn, new_vaccinations, totalvaci)
as 
(
select dea.continent, dea.location, dea.date, dea.MyUnknownColumn as population, vac.new_vaccinations 
, SUM(cast(vac.new_vaccinations as double)) OVER (partition by dea.location order by dea.location, dea.date) as totalvaci
-- ,(totalvaci/MyUnknownColumn)*100 as 
from profolioproject.coviddeaths dea
Join profolioproject.covidvaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
-- order by 2
)

select *, (totalvaci/MyUnknownColumn)*100 as popvsvac
from PopvsVac;
-- USE CTE because we cannot use the name totalvaci after we just created so we going to use the temp table

-- TEMP TABLE

DROP TABLE IF exists percentpopulationvaccinated;
CREATE TEMPORARY TABLE percentpopulationvaccinated 
(continent nvarchar(255), 
location nvarchar(255), 
date datetime, 
MyUnknownColumn numeric,  
new_vaccinations numeric, 
totalvaci numeric);

insert into percentpopulationvaccinated
select dea.continent, dea.location, dea.date, dea.MyUnknownColumn as population, vac.new_vaccinations 
, SUM(cast(vac.new_vaccinations as double)) OVER (partition by dea.location order by dea.location, dea.date) as totalvaci
-- ,(totalvaci/MyUnknownColumn)*100 as 
from profolioproject.coviddeaths dea
Join profolioproject.covidvaccinations vac
On  dea.date = vac.date
and dea.location = vac.location;
-- where dea.continent is not null
-- order by 2;

select *, (totalvaci/MyUnknownColumn)*100 as percentpopulationvaccinated
from percentpopulationvaccinated;

-- Creating view to store data for later visualization

CREATE VIEW percentpopulationvaccinated as 
select dea.continent, dea.location, dea.date, dea.MyUnknownColumn as population, vac.new_vaccinations 
, SUM(cast(vac.new_vaccinations as double)) OVER (partition by dea.location order by dea.location, dea.date) as percentpopulationvaccinated
-- ,(totalvaci/MyUnknownColumn)*100 as 
from profolioproject.coviddeaths dea
Join profolioproject.covidvaccinations vac
On  dea.date = vac.date
and dea.location = vac.locationpercentpopulationvaccinated
where dea.continent is not null;
 -- order by 2;

SELECT * FROM profolioproject.percentpopulationvaccinated;



