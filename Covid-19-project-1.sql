SELECT *
FROM PortfolioProject1..coviddeath$
WHERE continent IS NOT NULL
ORDER BY 3,4;

--SELECT *
--FROM PortfolioProject1..covidvaccination$
--ORDER BY 3,4;


SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject1..coviddeath$
ORDER BY 1, 2;

--Looking at the total cases v total deaths
--Shows the likelihood of dying out of COVID in USA
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPerentage
FROM PortfolioProject1..coviddeath$
WHERE location LIKE '%states%'
ORDER BY 1, 2;

--Shows what percentage has gotten covid in Canada
SELECT location, date, total_cases, population, (total_cases/population)*100 AS infected_people
FROM PortfolioProject1..coviddeath$
WHERE location LIKE '%Canada%'
ORDER BY 1, 2;

--Sorts countries based on the highest percentage infected
SELECT location, population, MAX(total_cases) AS highest_infection_count, population, MAX((total_cases/population))*100 AS infected_people_percentage
FROM PortfolioProject1..coviddeath$
GROUP BY location, population
ORDER BY infected_people_percentage DESC;

--Sorts countries with highest death per count
SELECT location, MAX(CAST(total_deaths AS INT)) AS total_death_count
FROM PortfolioProject1..coviddeath$
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_death_count DESC;

--Break down by Continent
SELECT location, MAX(CAST(total_deaths AS INT)) AS total_death_count
FROM PortfolioProject1..coviddeath$
WHERE continent IS NULL
GROUP BY location
ORDER BY total_death_count DESC;


--Showing the Continents with the highest death count per population
SELECT continent, MAX(CAST(total_deaths AS INT)) AS total_death_count
FROM PortfolioProject1..coviddeath$
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_death_count DESC;

--GLOBAL FIGURES
--Shows what percentage has gotten covid in Canada
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases) * 100 AS death_percentage
FROM PortfolioProject1..coviddeath$
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1, 2;



--Let's look at the vaccination data

SELECT *
FROM PortfolioProject1..covidvaccination$;

SELECT *
FROM PortfolioProject1..covidvaccination$ AS vac
LEFT JOIN PortfolioProject1..coviddeath$ AS dea
	ON vac.location = dea.location
	AND vac.date = dea.date;

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CONVERT(int, vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM PortfolioProject1..covidvaccination$ AS vac
LEFT JOIN PortfolioProject1..coviddeath$ AS dea
	ON vac.location = dea.location
	AND vac.date = dea.date
	WHERE dea.continent IS NOT NULL
ORDER BY 2,3;


--USING A CTE

WITH pop_vs_vacc (continent, location, date, population, new_vaccinations, rolling_people_vaccinated) AS  (

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CONVERT(int, vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM PortfolioProject1..covidvaccination$ AS vac
LEFT JOIN PortfolioProject1..coviddeath$ AS dea
	ON vac.location = dea.location
	AND vac.date = dea.date
	WHERE dea.continent IS NOT NULL
--ORDER BY 2,3;
)

SELECT *, rolling_people_vaccinated/population *100 AS cumulative_perc_of_population
FROM pop_vs_vacc;


----Create a temp table

--DROP TABLE IF EXISTS #Percent_population_vaccinated
--CREATE TABLE #Percent_population_vaccinated
--(
--continent nvarchar(255),
--location nvarchar(255),
--date datetime,
--population numeric,
--new_vaccinations numeric,
--rolling_people_vaccinated numeric
--)


--INSERT INTO #Percent_population_vaccinated
--SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
--	SUM(CONVERT(int, vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
--FROM PortfolioProject1..covidvaccination$ AS vac
--JOIN PortfolioProject1..coviddeath$ AS dea
--	ON vac.location = dea.location
--	AND vac.date = dea.date
----	WHERE dea.continent IS NOT NULL
----ORDER BY 2,3;

--SELECT *, (rolling_people_vaccinated/population) *100
--FROM #Percent_population_vaccinated



--Creating veiw for visualizing data later

CREATE VIEW Percent_population_vaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CONVERT(int, vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM PortfolioProject1..covidvaccination$ AS vac
LEFT JOIN PortfolioProject1..coviddeath$ AS dea
	ON vac.location = dea.location
	AND vac.date = dea.date
	WHERE dea.continent IS NOT NULL
--ORDER BY 2,3;


SELECT *
FROM Percent_population_vaccinated;