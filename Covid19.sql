
Select * From dbo.CovidDeaths


Select location,date,new_cases,new_cases From dbo.CovidDeaths
where date = '2020-03-24 00:00:00.000'
-- Change column type from nvarchar to float

EXEC sp_help 'CovidDeaths';

Alter Table CovidDeaths
Alter Column total_deaths float

-- Select Data that we are going to be using

Select location, continent, date, total_cases, new_cases, total_deaths, population
From CovidDeaths
Order By 1,2 

-- Looking at Total Cases vs Total Deaths

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as NoOfDeathPerCaseinPercentage
From CovidDeaths
Order By 1,2 

--Shows likelihood of dying if you contract covid in your countryqoooooqqoo01
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as NoOfDeathPerCaseinPercentage
From CovidDeaths
Where location like '%hanis%'
Order By 1,2 

 --Looking at Total cases vs population  

Select location, date, total_cases, population, (total_deaths/total_cases)*100 as NoOfDeathPerCaseinPercentage
From CovidDeaths
Where location like '%hanis%'
Order By 1,2 


--Shows percentage of population that got covid
Select location, date, total_cases, population, (total_cases/population)*100
From CovidDeaths
Where location like 'Malay%'
Order By 1,2  

-- Looking at country with highest infection rate compared population

Select location, population, MAX(total_cases) as HighestCase, MAX((total_cases/population))*100 as PercentageOfPopulationInfected
From CovidDeaths
Group By location, population
Order By PercentageOfPopulationInfected desc

--Showing Countries with highest death count per population
Select location, population, MAX(total_deaths) as TotalDeathCount
From CovidDeaths
Where continent is not NULL
Group By location, population
Order By TotalDeathCount desc

--Showing continent with hhighest death count
Select location, MAX(total_deaths) as TotalDeathCount
From CovidDeaths
Where continent is NULL
Group By location
Order By TotalDeathCount desc

--Global Numbers
Select date, sum(new_cases) as totalcase,sum(new_deaths)--,sum(new_deaths)/sum(new_cases)*100 as DeathPercentage --MAX(total_deaths) as TotalDeathCount
From CovidDeaths
Where continent is not NULL
Group By date
Order By 1,2


--Amount of people that have been vaccinated 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location Order by dea.date) AS TotalVaccinations
From CovidVaccination vac
Join CovidDeaths dea
On vac.location = dea.location and vac.date = dea.date
Where dea.continent is not NUll
Order By 2,3

--Use CTE
With PopVsVac(continent, Location, Date, Population, new_vaccinations,TotalVaccinations)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGINT,vac.new_vaccinations, 0)) OVER (PARTITION BY dea.location Order by dea.date) AS TotalVaccinations
From CovidVaccination vac
Join CovidDeaths dea
On vac.location = dea.location and vac.date = dea.date
Where dea.continent is not NUll
--Order By 2,3
)
Select * , (TotalVaccinations/Population)*100 as PercentageOfPeopleVaccinated
From PopVsVac
Order By 2,3

--Temp Table
DROP TABLE #PercentageOfPeopleVaccinated;

Create Table #PercentageOfPeopleVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
TotalVaccinations numeric
)

Insert Into #PercentageOfPeopleVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (PARTITION BY dea.location Order by dea.date) AS TotalVaccinations
From CovidVaccination vac
Join CovidDeaths dea
On vac.location = dea.location and vac.date = dea.date
Where dea.continent is not NUll

Select * , (TotalVaccinations/Population)*100 as PercentageOfPeopleVaccinated
From #PercentageOfPeopleVaccinated
Order By 2,3

--View
Create View PercentageOfPeopleVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (PARTITION BY dea.location Order by dea.date) AS TotalVaccinations
From CovidVaccination vac
Join CovidDeaths dea
On vac.location = dea.location and vac.date = dea.date
Where dea.continent is not NUll

Select * From PercentageOfPeopleVaccinated