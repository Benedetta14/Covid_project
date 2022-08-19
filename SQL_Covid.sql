

Select *
From PortfolioProject..CovidDeaths$
order by 3, 4

Alter table CovidDeaths$ alter column new_cases float
-- nb. prev line works only if strumenti>

--Select *
--From PortfolioProject..CovidVaccinations$
--order by 3, 4

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$
order by 1, 2


-- Looking at total_cases vs total_deaths

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
From PortfolioProject..CovidDeaths$
Where location like '%italy%'
order by 1, 2

-- Looking at total_cases vs population
Select Location, date, total_deaths, population, (total_deaths/population)*100 as death_percentage
From PortfolioProject..CovidDeaths$
Where location like '%italy%'
order by 1, 2

-- Looking at countries with highest infection rate compared to population

Select location, population, MAX(total_cases) as highest_infection_count, MAX((total_cases/population))*100 as pop_infected_percentage
From PortfolioProject..CovidDeaths$
Group by location, population
Order by pop_infected_percentage desc

-- Showing countries with highest death count per population

Select Location, MAX(cast(total_deaths as int)) as total_deaths_count
From PortfolioProject..CovidDeaths$
Where continent is not NULL
Group by location
Order by total_deaths_count desc

-- same but breaking locations in continents

Select continent, MAX(cast(total_deaths as int)) as total_deaths_count
From PortfolioProject..CovidDeaths$
Where continent is not NULL
Group by continent
Order by total_deaths_count desc

-- global numbers

Select date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, (SUM(new_deaths)/SUM(new_cases))*100 as death_percentage
From PortfolioProject..CovidDeaths$
Where continent is not null
Group by date
order by 1, 2

-- Looking at total population vs vaccinations

With populationVSvaccinations (continent, location, date, population, new_vaccinations, people_vaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations, 
 SUM(convert(float, vax.new_people_vaccinated_smoothed)) OVER (partition by dea.location order by dea.location, dea.date)
 as people_vaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vax
    On dea.location = vax.location
	and dea.date = vax.date
where dea.continent is not null
)

Select*, (people_vaccinated/population)*100
From populationVSvaccinations

-- table creation

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
people_vaccinated numeric
)

Insert Into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations, 
 SUM(convert(float, vax.new_people_vaccinated_smoothed)) OVER (partition by dea.location order by dea.location, dea.date)
 as people_vaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vax
    On dea.location = vax.location
	and dea.date = vax.date
where dea.continent is not null

-- view to store data

Create View #PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations, 
 SUM(convert(float, vax.new_people_vaccinated_smoothed)) OVER (partition by dea.location order by dea.location, dea.date)
 as people_vaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vax
    On dea.location = vax.location
	and dea.date = vax.date
where dea.continent is not null









