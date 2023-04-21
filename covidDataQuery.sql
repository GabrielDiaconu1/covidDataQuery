/*Looking at data involving Covid-19 infections*/
/*Used the following to sort this data: data types, views, aggregate functions, windows functions, temp tables, CTE's and joins*/

--A look at all the data from CovidDeaths
Select *
FROM PortfolioProject2..CovidDeaths
WHERE continent is not NULL
order by 3,4

--A look at data sorted by column
Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject2..CovidDeaths
Where continent is not null 
order by 1,2

--To compare the cases and deaths
--If you have covid what are the chances of dying?
Select Location, date, Population, total_cases,(total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject2..CovidDeaths
WHERE LOCATION like '%states%'
and continent is not NULL
order by 1,2

--To compare the population and cases
--If you look at a population what percentage is infected?
Select Location, date, Population, total_cases,(total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject2..CovidDeaths
WHERE continent is not NULL
order by 1,2




--When looking at a countries population what is the highest infection rate?

Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject2..CovidDeaths
WHERE continent is not NULL
GROUP BY Location, Population
order by PercentPopulationInfected desc


--Showing Countries with Highest Death Count per Population
Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject2..CovidDeaths
WHERE continent is not NULL
GROUP BY location
order by TotalDeathCount desc

--Showing continents with the highest death count per population
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject2..CovidDeaths
WHERE continent is not NULL
GROUP BY continent
order by TotalDeathCount desc



--When looking at the whole world

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject2..CovidDeaths
WHERE continent is not NULL
order by 1,2

-- When looking at vaccinations and total population
-- What is the percentage of indivuals who received 1 or more vaccine's

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject2..CovidDeaths dea
Join PortfolioProject2..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


--Here we are using a common table expression to do a calculation

With PopvsVac (Continent, Location, Date, Population,New_Vaccinations, RollingPeopleVaccinated)
as (
SELECT dea.continent, dea.location, dea.date , dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated

From PortfolioProject2..CovidVaccinations vac
JOIN PortfolioProject2..CovidDeaths dea
	ON dea.location = vac.location
	and dea.date= vac.date

WHERE dea.continent is not NULL
order by 2,3

)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- We can use a temp table for the Partition by

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated

From PortfolioProject2..CovidDeaths dea
Join PortfolioProject2..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Here we are creating a View

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated

From PortfolioProject2..CovidDeaths dea
Join PortfolioProject2..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 