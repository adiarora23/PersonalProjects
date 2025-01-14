-- Infrastructure Data Cleaning Project

-- Hello! Today I am going to be cleaning a dataset found on the Government of Ontario website! (link: https://data.ontario.ca/dataset/ontario-builds-key-infrastructure-projects/resource/35dc5416-2b86-4a79-b3e6-acbfe004c81a)
-- This data consists of planned, ongoing, and completed infrastructure projects happening across Ontario, as well as the estimated budget.
-- To start this cleaning project, I will first call all the data from the table I made earlier (I made this table earlier by importing the csv file into MySQL!):

SELECT *
FROM infrastructure;

-- As we can see, there are 18 columns. We can also see the row count by the following query:

SELECT COUNT(*)
FROM infrastructure;

-- Based on this, we have 5412 total rows. Now that we know this information, I will layout the Data Cleaning steps I am going to take to make sure this data is ready for further analysis:

-- Steps to clean:
-- 1. Remove Duplicates 
-- 2. Standardize the Data (Fixing structural errors, type conversion)
-- 3. NULL Values or Blank Values (to handle missing data)
-- 4. Remove Any Columns (irrelevant data)

-- Now that I have these steps laid out, I will first begin by creating a staging file to work with, as it is best practice to not work with the RAW data directly:
CREATE TABLE infrastructure_staging
LIKE infrastructure;

SELECT *
from infrastructure_staging;

INSERT infrastructure_staging
SELECT *
FROM infrastructure;

-- Now that we have our staging file, I will begin cleaning the data!
-- Step 1. Remove Duplicates

SELECT *
FROM infrastructure_staging;

-- Note that the very first column when imported is not correctly formatted, so I will fix this first before removing duplicates:
# ALTER TABLE infrastructure_staging
# RENAME COLUMN ï»¿Category TO Category;

SELECT *
FROM infrastructure_staging;

-- Now that the column is fixed with the correct name, I will create a CTE to select the ROW_NUMBER() and PARTITION BY all columns. This PARTITION BY statment will help me create a column of distinct count. 
-- Then, I will SELECT everything where that ROW_NUMBER() is greater than 1:

WITH duplicate_cte AS (
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY Category, `Supporting Ministry`, Community, Project, `Status`, `Target Completion Date`, 
`Area`, Region, Address, `Postal Code`, `Highway / Transit Line`, `Estimated Total Budget`, `Municipal Funding`,
`Provincial Funding`, `Federal Funding`, `Other Funding`, Latitude, Longitude) AS row_num
FROM infrastructure_staging
)
SELECT *
FROM duplicate_cte
where row_num > 1;

-- From this CTE we found that there are three duplicates within our dataset. Just to check, I will query one of them to see what I find:

SELECT *
FROM infrastructure_staging
WHERE Project = 'Rainy River Drainage Project' AND `Target Completion Date` = '2024-12-23'; 

-- The CTE worked as intended! However, because CTEs cannot be updated, I will create ANOTHER table which removes the duplicates!

CREATE TABLE `infrastructure_staging2` (
  `Category` text,
  `Supporting Ministry` text,
  `Community` text,
  `Project` text,
  `Status` text,
  `Target Completion Date` text,
  `Area` text,
  `Region` text,
  `Address` text,
  `Postal Code` text,
  `Highway / Transit Line` text,
  `Estimated Total Budget` bigint DEFAULT NULL,
  `Municipal Funding` text,
  `Provincial Funding` text,
  `Federal Funding` text,
  `Other Funding` text,
  `Latitude` text,
  `Longitude` text,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM infrastructure_staging2;

INSERT INTO infrastructure_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY Category, `Supporting Ministry`, Community, Project, `Status`, `Target Completion Date`, 
`Area`, Region, Address, `Postal Code`, `Highway / Transit Line`, `Estimated Total Budget`, `Municipal Funding`,
`Provincial Funding`, `Federal Funding`, `Other Funding`, Latitude, Longitude) AS row_num
FROM infrastructure_staging;

-- Now that we have created the new staging table for all infrastrucutures, I will be able to update the table by removing duplicates:

SELECT *
FROM infrastructure_staging2
WHERE row_num > 1;

DELETE FROM infrastructure_staging2
WHERE row_num > 1; -- Duplicates have been removed!

SELECT *
FROM infrastructure_staging2; -- Step 1 is complete!

-- Now, we move onto step 2:
-- Step 2: Standardize the Data (Fixing structural errors, type conversion) 

SELECT Category, COUNT(Category) cat_count
FROM infrastructure_staging2
GROUP BY Category
ORDER BY cat_count DESC;

SELECT `Supporting Ministry`, COUNT(`Supporting Ministry`) sup_count
FROM infrastructure_staging2
GROUP BY `Supporting Ministry`
ORDER BY sup_count DESC;

SELECT Community
FROM infrastructure_staging2
WHERE Community LIKE 'Mattice-Val%'; -- note that the characters aren't properly shown, so we will fix this

UPDATE infrastructure_staging2
SET Community = 'Mattice-Val Côté'
WHERE Community LIKE 'Mattice-Val%';

SELECT Community, COUNT(Community) comm_count
FROM infrastructure_staging2
GROUP BY Community
ORDER BY comm_count DESC;

SELECT Community
FROM infrastructure_staging2
WHERE Community LIKE 'Animbiigoo%'; -- formatting is wrong, we will fix it!

UPDATE infrastructure_staging2
SET Community = "Animbiigoo Zaagi'igan Anishinaabek (Lake Nipigon Ojibway) First Nation"
WHERE Community LIKE 'Animbiigoo%';

SELECT Project, COUNT(Project) proj_count
FROM infrastructure_staging2
GROUP BY Project
ORDER BY proj_count DESC; -- These are OK

SELECT `Status`, COUNT(`Status`) stat_count
FROM infrastructure_staging2
GROUP BY `Status`
ORDER BY stat_count; -- These are OK

SELECT `Target Completion Date`,
STR_TO_DATE(`Target Completion Date`, '%Y-%m-%d')
FROM infrastructure_staging2; -- We want to convert the text datatype into a datetime datatype! (Will handle this once step 3 is finished!)

SELECT `Area`, COUNT(`Area`) ar_cnt
FROM infrastructure_staging2
GROUP BY `Area`
ORDER BY ar_cnt DESC;

SELECT Region, COUNT(Region) reg_cnt
FROM infrastructure_staging2
GROUP BY Region
ORDER BY reg_cnt DESC;

UPDATE infrastructure_staging2
SET Address = UPPER(Address);

SELECT Address
FROM infrastructure_staging2;

SELECT *
FROM infrastructure_staging2; -- Step #2 is complete!

-- Now, moving onto step 3!
-- Step 3: NULL Values or Blank Values (to handle missing data)

UPDATE infrastructure_staging2
SET `Target Completion Date` = NULL
WHERE `Target Completion Date` = '';

UPDATE infrastructure_staging2
SET Category = NULL
WHERE Category = '';

UPDATE infrastructure_staging2
SET `Supporting Ministry` = NULL
WHERE `Supporting Ministry` = '';

UPDATE infrastructure_staging2
SET Community = NULL
WHERE Community = '';

UPDATE infrastructure_staging2
SET Project = NULL
WHERE Project = '';

UPDATE infrastructure_staging2
SET `Status` = NULL
WHERE `Status` = '';

UPDATE infrastructure_staging2
SET `Other Funding` = NULL
WHERE `Other Funding` = '';

UPDATE infrastructure_staging2
SET Latitude = NULL
WHERE Latitude = '';

UPDATE infrastructure_staging2
SET Longitude = NULL
WHERE Longitude = ''; -- Since there is no other table to compare to and see if we had missing values, step 3 is complete!

-- Finally, we move onto the last step
-- Step 4: Remove Any Columns (irrelevant data)

SELECT *
FROM infrastructure_staging2
WHERE `Estimated Total Budget` IS NULL; -- Note that everything here is NULL as well.

DELETE FROM infrastructure_staging2
WHERE `Estimated Total Budget` IS NULL;

SELECT *
FROM infrastructure_staging2;

ALTER TABLE infrastructure_staging2
DROP COLUMN row_num;

ALTER TABLE infrastructure_staging2
DROP COLUMN `Postal Code`;

SELECT *
FROM infrastructure_staging2; -- This is our data after it has been cleaned! Ready for Exploratory Data Analysis! :)

-- Of course, there is much more we could clean but given that I am working with a real-world dataset that could be updated regularly, I will be keeping some columns with the assumption that I would need to ask further questions before cleaning any more!


