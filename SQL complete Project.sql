select * from [SQL Practise].dbo.CovidDeaths$
where continent is not null
order by  3,4

select * from [SQL Practise].dbo.CovidVaccinations$
order by  3,4

-- select the data we are going to using
select location,date,total_cases,new_cases,total_deaths,population
from [SQL Practise].dbo.CovidDeaths$
where continent is not null
order by 1,2

--looking at the total cases vs total deaths 
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as deathpercentage
from [SQL Practise].dbo.CovidDeaths$
where location like '%Nep%'and continent is not null
order by deathpercentage desc

--looking at total cases vs population
--shows what percentage of population got covid
select location,date,population,total_cases,(total_cases/population)*100 as Casepercentage
from 
[SQL Practise].dbo.CovidDeaths$
where location like '%Nep%'
order by 1,2

--looking at the countries with highest infection rate
select location,population,Max(total_cases) as highest_infectioncount ,Max(total_cases/population)*100 as Highestinfectionrate
from 
[SQL Practise].dbo.CovidDeaths$
--where location like '%Nep%'
Group by location,population
order by Highestinfectionrate desc

--showing countries with the highest death count per population
select location,Max(cast(Total_deaths as int)) as TotalDeathcount
from 
[SQL Practise].dbo.CovidDeaths$
where continent is not null
Group by location
order by TotalDeathcount desc

--Lets break things down by continent
select location,Max(cast(Total_deaths as int)) as TotalDeathcount
from 
[SQL Practise].dbo.CovidDeaths$
where continent is null
Group by location
order by TotalDeathcount desc

--showing continent with highest deathcount per population
select continent,Max(cast(Total_deaths as int)) as TotalDeathcount
from 
[SQL Practise].dbo.CovidDeaths$
where continent is not null
Group by continent
order by TotalDeathcount desc

--Global numbers
select date,sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int))/sum(new_cases)* 100 as Death_Percentage
from 
[SQL Practise].dbo.CovidDeaths$
where continent is not null
Group by date
order by 1,2 desc

select sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int))/sum(new_cases)* 100 as Death_Percentage
from 
[SQL Practise].dbo.CovidDeaths$
where continent is not null
--Group by date
order by 1,2 desc

--Looking at total population vs vaccinations
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(cast(vac.new_vaccinations as int))  over (partition by dea.location order by dea.location,dea.date) as RollingPeoplevaccinated 
--,(RollingPeoplevaccinated/population) 
from [SQL Practise].dbo.CovidDeaths$ dea
join [SQL Practise].dbo.CovidVaccinations$ vac
on  dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 1,2,3

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [SQL Practise].dbo.CovidDeaths$ dea
Join [SQL Practise].dbo.CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)



Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [SQL Practise].dbo.CovidDeaths$ dea
Join [SQL Practise].dbo.CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3


Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [SQL Practise].dbo.CovidDeaths$ dea
Join [SQL Practise].dbo.CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

select * 
from PercentPopulationVaccinated
