-- Vending Machine Coffee Sales Analysis Project

-- Hello! Today I am going to be looking at this coffee sales dataset and providing key insights found from it
-- Special thanks to the Yaroslav Isaienkov for providing the data via Kaggle (https://www.kaggle.com/datasets/ihelon/coffee-sales)

SELECT *
FROM coffee_sales;

SELECT COUNT(*)
FROM coffee_sales;

-- So, we have 6 columns to work with, and 2623 total rows.
-- Lets start with data cleaning to make sure data is good to explore!

-- Steps to clean:
-- 1. Remove Duplicates 
-- 2. Standardize the Data (Fixing structural errors, type conversion)
-- 3. NULL Values or Blank Values (to handle missing data)
-- 4. Remove Any Columns (irrelevant data)

-- Before we begin checking these steps, it is best practice to not work with the raw dataset if we are making changes! Hence, we will first create a staging table:

CREATE TABLE coffee_sales_staging
LIKE coffee_sales;

SELECT *
FROM coffee_sales_staging;

INSERT coffee_sales_staging
SELECT *
FROM coffee_sales;

-- Now that we have our staging data to work with and manipulate, it is time to begin!
-- Step 1: Remove Duplicates

SELECT *
FROM coffee_sales_staging;

-- First, we will make a CTE to check if there are any duplicates in our data:

WITH duplicate_cte AS (
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY `date`, `datetime`, cash_type, card, money, coffee_name) AS row_num
FROM coffee_sales_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

-- Based on our CTE to locate duplicates, there are no duplicates found within this dataset, which means we won't need to create another staging dataset to work on. This means we can move onto Step 2.

-- Step 2: Standardize data (Fixing structural errors, type conversion)
-- Note that the date column was listed as a text datatype. We are going to change this to a date datatype:
SELECT `date`, STR_TO_DATE(`date`, '%Y-%m-%d') AS new_date
FROM coffee_sales_staging;

UPDATE coffee_sales_staging
SET `date` = STR_TO_DATE(`date`, '%Y-%m-%d');

ALTER TABLE coffee_sales_staging
MODIFY COLUMN `date` DATE;

SELECT `date`
FROM coffee_sales_staging;

-- Now we have fixed the datatype for date! Let's move onto the next column:

SELECT `datetime`, DATE_FORMAT(`datetime`, '%H:%i:%s') AS new_datetime
FROM coffee_sales_staging;

-- From this column, we only need the time of purchase for each coffee sale, hence we will format it to showcase only the times, and update accordingly!

UPDATE coffee_sales_staging
SET `datetime` = DATE_FORMAT(`datetime`, '%H:%i:%s');

ALTER TABLE coffee_sales_staging
MODIFY COLUMN `datetime` TIME;

-- Fixed. Now, onto the next column!

SELECT cash_type, COUNT(cash_type)
FROM coffee_sales_staging
GROUP BY cash_type;

-- This seems to be fine, so we will move onto the next column:

SELECT cash_type, card
FROM coffee_sales_staging;

-- Although there are blanks within this data, this is normal as a blank means the payment was in cash

SELECT money
FROM coffee_sales_staging;

-- This column is fine, moving onto the next one:

SELECT coffee_name
FROM coffee_sales_staging;

-- This column is also fine, which means step 2 is complete! Onto step 3:

-- Step 3: NULL values or Blank Values (handling missing data)
-- Since there have been no NULL data, we will focus on blank values.
-- Specifically, the "card" column:

SELECT card, COUNT(card) AS card_count
FROM coffee_sales_staging
GROUP BY card
ORDER BY card_count DESC;

UPDATE coffee_sales_staging
SET card = NULL
WHERE card = '';

SELECT card
FROM coffee_sales_staging;

-- Now that we have updated that, it is time to move onto the final step!

-- Step 4: remove any unnecessary columns

SELECT *
FROM coffee_sales_staging;

-- Since all the columns listed are needed for further analysis, we can skip step 4 in its entirety!
-- This concludes cleaning the data. Now, onwards to EDA!

# -- EDA ANALYSIS --

-- Before this, let me create a simple procedure that will let me look at all columns in the cleaned dataset without having to rewrite most of the query:

CREATE PROCEDURE all_columns()
SELECT *
FROM coffee_sales_staging;

-- Now we can test it:

CALL all_columns();

-- Excellent! it works!
-- Now that we know what columns we are working with, let's look at the total number of coffee sales first:

SELECT ROUND(SUM(money), 2) total_sales
FROM coffee_sales_staging;

-- So far, we already know that there are 2623 sales, of which 89 of them are paid in cash. To date according to this dataset, the coffee machine sales have made a total of ~$83,646.10. Quite the profit!
-- Now, what if we look at something more interesting, like the total sales by day/month/year?

SELECT `date`, ROUND(SUM(money), 2) total_sales
FROM coffee_sales_staging
GROUP BY `date`
ORDER BY `date`;

-- Based on this query, we notice that some days have higher sales than others, but cannot tell which day name they are. Maybe we can investigate this further and see the AVERAGE coffee machine sales by the day (monday, tuesday, etc.)

SELECT DAYNAME(`date`) weekday, ROUND(AVG(money), 2) avg_sales
FROM coffee_sales_staging
GROUP BY weekday
ORDER BY avg_sales DESC;

-- From this query, we can see a much more clear view: Tuesdays usually have the highest average sale rate, followed by Sundays
-- Let's look at a bigger picture and see the sales on a weekly basis:

SELECT YEAR(`date`) `year`, WEEK(`date`) `week`, ROUND(AVG(money), 2) avg_sales
FROM coffee_sales_staging
GROUP BY `year`, `week`
ORDER BY avg_sales DESC;

-- Based on this, we can see that week 12 had the highest average sales, while week 34 had the lowest average sales. Seems like summer time has a lower profit for the coffee machine!
-- Now let's broaden the spectrum a little more:

SELECT YEAR(`date`) `year`, MONTH(`date`) `month`, ROUND(AVG(money), 2) avg_sales
FROM coffee_sales_staging
GROUP BY `year`, `month`
ORDER BY avg_sales DESC;

-- This shows that the highest average coffee machine sales were found in the month of April. It seems that the Spring/early Summer months see the highest profit for the coffee machine, while August had the lowest average sales.
-- Now that we have covered some of this, let's move on!

-- Let's look at the best-selling coffee product from this dataset:

SELECT coffee_name, ROUND(SUM(money), 2) total_sales
FROM coffee_sales_staging
GROUP BY coffee_name
ORDER BY total_sales DESC;

-- As we can see, the Lattes are the best selling product from the coffee machine, followed by Americano with Milk!

-- What about the most popular hour of the time for sales in a day?

CALL all_columns();

SELECT HOUR(`datetime`) `hour`, ROUND(SUM(money), 2) total_sales
FROM coffee_sales_staging
GROUP BY `hour`;

-- It seems that 10 am has the most popular time for sales, which is a 33.67% difference compared to 12 pm and the rest of the hours of the day
-- This makes sense as most consumers like to take their coffee in the morning to get a jump start of energy for work!

-- What about if there are repeat customers?

SELECT card, COUNT(coffee_name) AS cnt
FROM coffee_sales_staging
GROUP BY card
HAVING cnt > 1
ORDER BY cnt DESC;

-- Based on this, there are 406 customers who were repeat customers, of which 230 of them only came back a second time.
-- However, some of these repeat customers could be paying by cash, hence we cannot tell if there are repeat customers mixed in with first-time buyers for that metric.

-- This concludes some of the EDA! Onto the visualization part of the project!