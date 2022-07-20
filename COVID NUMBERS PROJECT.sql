SELECT * 
FROM [portfolio M.H.]..CovidDeaths$
WHERE continent is not null
ORDER BY 3,4

SELECT * 
FROM [portfolio M.H.]..vaccinations
ORDER BY 3,4

SElECT location, date, total_cases, new_cases, total_deaths, population 
FROM [portfolio M.H.] ..CovidDeaths$
ORDER BY 1,2


--DEATH PERCENTAGE 

SElECT location, date, total_cases, total_deaths, (total_deaths/total_cases) *100 AS deathpercentage
FROM [portfolio M.H.] ..CovidDeaths$
ORDER BY 1,2


--%CASES BY POPULATION

SElECT location, date, total_cases, Population, (total_cases/population) *100 AS CASESpercentage
FROM [portfolio M.H.] ..CovidDeaths$
--WHERE location like '%states%'
ORDER BY 1,2

--UNITED STATES

SElECT location, date, total_cases, Population, (total_cases/population) *100 AS CASESpercentage
FROM [portfolio M.H.] ..CovidDeaths$
WHERE location like '%states%'
ORDER BY 1,2


--COUNTRIES WITH HIGHEST PERCENTAGE OF CASES

SELECT Location, Population, date, MAX(total_cases) AS HighestCasesCount, MAX ((total_cases/Population)) *100 AS 
PercentagePopulationInfected
FROM [portfolio M.H.]..CovidDeaths$
GROUP BY Location, Population,date
ORDER BY PercentagePopulationInfected DESC


--COUNTRIES WITH HIGHEST DEATH COUNT

SELECT Location, MAX(cast (total_deaths as int)) AS totaldeathscount
FROM [portfolio M.H.]..CovidDeaths$
WHERE continent is not null
GROUP BY Location
ORDER BY totaldeathscount DESC


--COUNTRIES WITH HIGHEST DEATH PERCENTAGE

SELECT Location, MAX(cast (total_deaths as int)) AS totaldeathscount, MAX ((total_deaths/Population)) *100 AS percentagedeaths
FROM [portfolio M.H.]..CovidDeaths$
WHERE continent is not null
GROUP BY Location
ORDER BY percentagedeaths DESC


--CONTINENTS WITH HIGHEST DEATH COUNT

SELECT location, MAX(cast (total_deaths as int)) AS totaldeathscount
FROM [portfolio M.H.]..CovidDeaths$
WHERE continent is null
and location not in ('World', 'european union', 'international')
GROUP BY location
ORDER BY totaldeathscount DESC


--CONTINENTS WITH HIGHEST DEATH COUNT (tableau)

SELECT continent, MAX(cast (total_deaths as int)) AS totaldeathscount
FROM [portfolio M.H.]..CovidDeaths$
WHERE continent is not null
GROUP BY continent
ORDER BY totaldeathscount DESC


--GLOBAL NUMBERS

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, (SUM(CAST(new_deaths AS int))/SUM (new_cases))*100 AS deathpercentage
FROM [portfolio M.H.] ..CovidDeaths$
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2









--VACCINATIONS

--vaccination percentage

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast (new_vaccinations as int)) OVER (partition by dea.location ORDER BY dea.location, dea.date) AS rollingpeoplevaccinated,
--(rollingpeoplevaccinated/population) *100
FROM [portfolio M.H.]..CovidDeaths$ dea
JOIN [portfolio M.H.]..vaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3




DROP TABLE if exists #Percentpopulationvaccinated
CREATE TABLE #Percentpopulationvaccinated
(continent nvarchar(255), 
location nvarchar(255), 
date datetime, 
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated  numeric
)

INSERT INTO #Percentpopulationvaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast (new_vaccinations as int)) OVER (partition by dea.location ORDER BY dea.location, dea.date) AS rollingpeoplevaccinated
--(rollingpeoplevaccinated/population) *100
FROM [portfolio M.H.]..CovidDeaths$ dea
JOIN [portfolio M.H.]..vaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

SELECT *, (rollingpeoplevaccinated/population)*100
FROM #Percentpopulationvaccinated


--Visualization

CREATE view percentpopulationvaccinated  
as SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast (new_vaccinations as int)) OVER (partition by dea.location ORDER BY dea.location, dea.date) AS rollingpeoplevaccinated
--(rollingpeoplevaccinated/population) *100
FROM [portfolio M.H.]..CovidDeaths$ dea
JOIN [portfolio M.H.]..vaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3


SELECT * 
FROM percentpopulationvaccinated