-- Project 3: Aircraft Movements based on Aviation Data collected from Statistics Canada
-- This project involves EDA on aircraft movements in Canada from 2019-2024, followed by a data visualization that will be conducted via Tableau
-- Today, we are going to explore the Aviation data to see what types of aircrafts take off, land, and simulate approaches to Canadian airports, as well as how many we see on a Year-over-Year basis!

-- Below, we have imported 4 tables to explore through:

SELECT *
FROM class_of_operations;

SELECT *
FROM type_of_operation;

SELECT *
FROM domestic_and_international_movements;

SELECT *
FROM by_geography;

-- Now that we have the necessary tables, let us explore what we can find!

-- Lets look at the highest amount of aircraft movements based on class of operation

SELECT REF_DATE, Airports, `Class of operation`, `VALUE`
FROM class_of_operations
WHERE Airports <> 'Total all airports' AND Airports <> 'Total NAV CANADA towers and flight service stations' AND `Class of operation` <> 'Total itinerant and local movements'
ORDER BY `VALUE` DESC;

-- Now, we can look at the largest types of movements for itinerant movements:

SELECT Airports, `Domestic and international itinerant movements`, `Type of operation`, `VALUE`
FROM domestic_and_international_movements
WHERE Airports <> 'Total all airports' AND Airports <> 'Total NAV CANADA towers and flight service stations' AND `Type of operation` <> 'Total itinerant and local movements'
ORDER BY `VALUE` DESC;