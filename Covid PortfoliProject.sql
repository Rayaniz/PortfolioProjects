SELECT * FROM PortfolioProject..covidDeath
ORDER BY 3,4

SELECT * FROM PortfolioProject..covidVaccine
ORDER BY 3,4


--SELECTED COLUMNS TO ANALYSE FROM COVID DEATH TABLE 
SELECT iso_code,location,date,total_cases,new_cases,total_deaths,population
FROM CovidDeath
ORDER BY 2,3


--LOOKING AT TOTAL_CASES VS TOTAL_DEATHS
--Shows the likelihood for dying when you contract covid in the UK

SELECT location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage_UK
FROM CovidDeath
WHERE location like '%united kingdom%'
ORDER BY 1,2

--Shows the likelihood for dying when you contract covid in the world 
SELECT location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage_UK
FROM CovidDeath
--WHERE location like '%united kingdom%'
ORDER BY 1,2


--Shows total_case_percentage over population per countries
SELECT location,date,population,total_cases, (total_cases/population)*100 AS TotalCase_Percentage_World
FROM CovidDeath
--WHERE location like '%united kingdom%'
ORDER BY 1,2



--Shows countries with highest total_cases with its percentage
SELECT location,population,max(total_cases) AS HighestCasesCount, max(total_cases/population)*100 AS TotalCase_Percentage_World
FROM CovidDeath
WHERE continent is not null		--removes the surplus data that are not countries in the location column, eg. Africa,World etc.
GROUP BY location,population
ORDER BY TotalCase_Percentage_World DESC



--Shows countries with highest death_cases
SELECT location,population,max(convert(int,total_deaths)) AS HighesDeathCount_Countries
FROM CovidDeath
WHERE continent is not null		--removes the surplus data that are not countries in the location column, eg. Africa,World etc.
GROUP BY location,population
ORDER BY HighesDeathCount_Countries DESC




--BREAKING DOWN INTO CONTINENTS

--Shows continent with highest death_cases
SELECT location,max(convert(int,total_deaths)) AS HighesDeathCount_Continent
FROM CovidDeath
WHERE continent is null		--removes the surplus data that are not countries in the location column, eg. Africa,World etc.
GROUP BY location
ORDER BY HighesDeathCount_Continent DESC


--Shows global covid total_new_cases and new_deaths per day with death_percentage
SELECT date,SUM(new_cases) AS Total_WorldCases, SUM(CAST(new_deaths AS INT)) AS Total_WorldDeaths,
SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS PercentageDeath_per_Day
FROM covidDeath
WHERE continent is not null
GROUP BY date
ORDER BY 1,2



--DEATHS AND VACCINATIONS TABLE

SELECT * FROM covidDeath
SELECT * FROM covidVaccine

--Shows the total vaccine so far per day
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS DailyTotalVaccine_PerCountry
FROM covidDeath as dea
JOIN covidVaccine as vac
ON dea.date = vac.date 
AND dea.location = vac.location
WHERE dea.continent is not null
--GROUP BY dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
ORDER BY 2,3




--Shows the percentage of vaccine over pouplation so far per day

WITH Pop_Vac as 
(
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS DailyTotalVaccine_PerCountry
--( DailyTotalVaccine_PerCountry/dea.population) as DailyPercentage_Vaccine_PerCountry
FROM covidDeath as dea
JOIN covidVaccine as vac
ON dea.date = vac.date 
AND dea.location = vac.location
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, ( DailyTotalVaccine_PerCountry/population)*100 as DailyPercentage_Vaccine_PerCountry
FROM Pop_Vac


--Using Temp Table for the percentage of vaccine over pouplation so far per day
CREATE TABLE #Pop_Vac 
(
continent varchar(255),
location varchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
DailyTotalVaccine_PerCountry numeric
)

INSERT INTO #Pop_Vac
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS DailyTotalVaccine_PerCountry
--( DailyTotalVaccine_PerCountry/dea.population) as DailyPercentage_Vaccine_PerCountry
FROM covidDeath as dea
JOIN covidVaccine as vac
ON dea.date = vac.date 
AND dea.location = vac.location
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, ( DailyTotalVaccine_PerCountry/population)*100 as DailyPercentage_Vaccine_PerCountry
FROM #Pop_Vac



--CREATING VIEW FOR REPORT

CREATE VIEW Pop_Vac AS
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS DailyTotalVaccine_PerCountry
--( DailyTotalVaccine_PerCountry/dea.population) as DailyPercentage_Vaccine_PerCountry
FROM covidDeath as dea
JOIN covidVaccine as vac
ON dea.date = vac.date 
AND dea.location = vac.location
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT * FROM Pop_Vac