/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/
select *
from CovidDeaths$

-- Select Data that we are going to be starting with
select *
from CovidVaccinations$
order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths$

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, (total_Deaths/total_cases) *100 as deathpercentage
from CovidDeaths$
where location like '%United states%'
order by 1,2

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

select location, date, population, total_cases, (total_cases/population) *100 as percentpopulationinfected
from CovidDeaths$
where location like '%United states%'
order by 1,2

-- Countries with Highest Infection Rate compared to Population

select location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population) *100 as percentpopulationinfected
from CovidDeaths$
group by location, population
order by populationpercentage desc

-- Countries with Highest Death Count per Population

select location, max(cast(total_deaths as int)) as totaldeathcount
from CovidDeaths$
where continent is not null
group by location
order by totaldeathcount desc

select location, max(cast(total_deaths as int)) as totaldeathcount
from CovidDeaths$
where continent is null
group by location
order by totaldeathcount desc

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

select continent, max(cast(total_deaths as int)) as totaldeathcount
from CovidDeaths$
where continent is not null
group by continent
order by totaldeathcount desc



--Global numbers
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_death, sum(cast(new_deaths as int))/ sum(new_cases)*100 as totaldeathcount
from CovidDeaths$
where continent is not null
order by 1,2


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine


select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location
order by dea.location, dea.date) as rollingpeoplevaccinated
from CovidDeaths$ dea
join CovidVaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

with popvsvac (continent, location, date, population, new_vaccinations, rolllingpeoplevaccinated)
as
(
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location
order by dea.location, dea.date) as rollingpeoplevaccinated
from CovidDeaths$ dea
join CovidVaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select *, (rolllingpeoplevaccinated/population)*100 percentage
from popvsvac


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists percentpopulationvaccinated
Create Table percentpopulationvaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into percentpopulationvaccinated
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location
order by dea.location, dea.date) as rollingpeoplevaccinated
from CovidDeaths$ dea
join CovidVaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date

select *, (percentpopulationvaccinated/population)*100
from percentpopulationvaccinated



-- Creating View to store data for later visualizations

create view percentpopulationvaccinated as
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location
order by dea.location, dea.date) as rollingpeoplevaccinated
from CovidDeaths$ dea
join CovidVaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null

select *
from percentpopulationvaccinated






