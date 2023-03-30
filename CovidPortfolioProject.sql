
--Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$
Order by 1,2


--Looking at Total Cases vs Deaths

Select location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
Where location like '%states%'
Order by 1,2


-- Total Cases vs population

Select location, date, total_cases, population,(total_cases/population)*100 as InfectionPercentage
From PortfolioProject..CovidDeaths$
Where location like '%states%'
Order by 1,2


--Countries with highest infection rate 

Select location, MAX(total_cases) as HighestInfectionCount, population, MAX((total_cases/population))*100 as InfectionPercentage
From PortfolioProject..CovidDeaths$
group by population, location
Order by InfectionPercentage desc

--Countries with Highest Death Count

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
where continent is not null
group by  location
Order by TotalDeathCount desc


--Continents with the highest death count


Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
Where continent is null
Group by location
Order by TotalDeathCount desc


--Global Numbers

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPrecentage
From PortfolioProject..CovidDeaths$
Where continent is not null
Group By date
Order by 1,2

--total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by
dea.location, dea.date) as RollingTotalVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3

--use cte

With PopvsVacc (Continent, Location, Date, Population, New_Vaccinations, RollingTotalVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by
dea.location, dea.date) as RollingTotalVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
)
Select*, (RollingTotalVaccinated/Population)*100
From PopvsVacc

--Creating View to Store data for Visualizations

Create View RollingTotalVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by
dea.location, dea.date) as RollingTotalVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null