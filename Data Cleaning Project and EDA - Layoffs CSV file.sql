-- Data Loading and Cleaning
-- Alan Gaugler
-- 25/05/24

-- In this project, I will demonstrate the important process of data cleaning using SQL, working on a dataset related to global layoffs. 
-- Data cleaning is a fundamental step in data analysis and involves preparing raw data to ensure it is accurate, consistent, clean and usable. 
-- This project will involve removing duplicates, standardizing data, handling null or blank values, and removing unnecessary columns.

-- This project is a data loading and cleaning exercise in SQL
-- The following steps will be implemented:

-- 1. Remove Duplicates: Identify and eliminate duplicate rows to ensure each record is unique.
-- 2. Standardize the Data: Ensure consistency in data formats and values across the dataset.
-- 3. Handle Null or Blank Values: Address missing values appropriately, whether through imputation or exclusion.
-- 4. Remove Unnecessary Columns: Eliminate columns that do not contribute to the analysis to streamline the dataset.

-- The following SQL script demonstrates these steps in detail, including the cautious approach of 
-- not disabling SAFE UPDATES to prevent accidental data loss.
-- Where there are updates to the table's values, 
-- SET SQL_SAFE_UPDATES = 0; -- Disable Safe updates
-- and
-- SELECT * FROM world_layoffs.layoffs;
-- commands are entered before and after, to ensure that all alterations are carefully managed.


-- Drop the layoffs_staging table if it exists
DROP TABLE IF EXISTS layoffs_staging;
-- Create a staging table (a new temporary table)
CREATE TABLE layoffs_staging
LIKE layoffs;


-- Observe that layoffs_staging is empty
SELECT *
FROM layoffs_staging;


-- Fill layoffs_staging (a new temporary table) with all the data from layoffs
INSERT layoffs_staging
SELECT *
FROM layoffs;

-- How many rows?
SELECT COUNT(*)
FROM layoffs_staging;

-- There are 2361 rows or items.

-------- 1. Remove Duplicate Rows -----------

-- First identify which rows are duplicates.alter 
-- Company should be the unique identifier

SELECT company, count(*) AS NumEntries
FROM layoffs_staging
GROUP BY company
HAVING count(*) > 1
ORDER BY count(*) DESC;

-- Several companies have more than one entry. Loft has the most with 6 entries.
-- However we want to find true duplicates where all columns have the same value.
-- A smarter way of doing this is as follows:
WITH duplicates_table AS
(
SELECT *, 
	COUNT(*) OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS NumRows,
    ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions ORDER BY `date` DESC) AS RowNum
FROM layoffs_staging
)
SELECT *
FROM duplicates_table
WHERE NumRows > 1
ORDER BY `date`;

-- Observing these rows, the layoffs by the same company happen in different locations or different dates. 
-- They are likely all valid layoffs and these rows should not be deleted.

-- However there are 5 pairs where all rows are exactly the same. These with RowNum >= 2 are duplicates and need to be removed.

DROP TABLE IF EXISTS layoffs_staging2;

-- Create a new table
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- And fill it
INSERT INTO layoffs_staging2
SELECT *, 
    ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

-- Observe the duplicate rows
SELECT *
FROM layoffs_staging2
WHERE row_num > 1;

-- Let's delete where RowNum is > 1 or all duplicates

SET SQL_SAFE_UPDATES = 0; -- Disable Safe updates

DELETE FROM layoffs_staging2 WHERE row_num > 1;

SET SQL_SAFE_UPDATES = 1;  -- Re-enable safe updates 

SELECT COUNT(*) AS Count
FROM layoffs_staging2;

-- Observe the table
SELECT *
FROM layoffs_staging2;

-- It can now be obeserved that there are now no duplicate rows as they have been removed.

------------------------------------------------------
-------- 2. Standardization (Consistency) of the Data -----------------

-- First it can be observed that there are some unecessary spaces in the company names as can be seen below:
SELECT company, TRIM(company)
FROM layoffs_staging2;

-- Observing carefully above, E Inc and Included Health have a space at the start. These need to be removed. 
-- To be consistent. I will do the same for all text based columns
SET SQL_SAFE_UPDATES = 0; -- Disable Safe updates

UPDATE layoffs_staging2
SET company = TRIM(company),
	location = TRIM(location),
	industry = TRIM(industry),
    stage = TRIM(stage),
	country = TRIM(country);
    
-- The company column is now trimmed as well as others.

-- Check for similar values in the text columns that may be typos.

SELECT DISTINCT company
FROM layoffs_staging2
ORDER BY company;
-- Many names here, this will be a long check

SELECT DISTINCT location
FROM layoffs_staging2
ORDER BY location;

-- Dusseldorf is incorrectly entered due to the umlaut. Florianopolis is also incorrect

-- Change the bad characters
SET SQL_SAFE_UPDATES = 0; -- Disable Safe updates

UPDATE layoffs_staging2
SET location = 'Düsseldorf'
WHERE location = 'DÃ¼sseldorf'
		OR location = 'Dusseldorf';
        
UPDATE layoffs_staging2
SET location = 'Florianópolis'
WHERE location = 'FlorianÃ³polis';

UPDATE layoffs_staging2
SET location = 'Malmö'
WHERE location = 'MalmÃ¶'
	OR location = 'Malmo';
    
SET SQL_SAFE_UPDATES = 1;  -- Re-enable safe updates

-- Display the Industry column and examine for issues.
SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY industry;

-- Observing above, there are three similar industries for Crypto currency.

-- Display all distinct names containing 'crypto'
SELECT DISTINCT *
FROM layoffs_staging2
WHERE industry LIKE '%crypto%';

-- The name 'Crypto' is by far the most common. They will all be set to 'Crypto'
SET SQL_SAFE_UPDATES = 0; -- Disable Safe updates

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE '%Crypto%';

SET SQL_SAFE_UPDATES = 1;  -- Re-enable safe updates

-- View Distinct value of stage
SELECT DISTINCT stage
FROM layoffs_staging2
ORDER BY stage;
-- 'Stage' looks good apart from the unknown values

SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY country;

-- There is 'United States' and 'United States.
-- The 2nd entry will be renamed.

SET SQL_SAFE_UPDATES = 0; -- Disable Safe updates

-- The types in the text columns have been corrected.

UPDATE layoffs_staging2
SET country = 'United States' 
WHERE country = 'United States.' ;

SET SQL_SAFE_UPDATES = 1;  -- Re-enable safe updates
-- 4 rows were changed

-- The 'date' column was deliberately loaded as a text column. It will be changed into a DATE format

SET SQL_SAFE_UPDATES = 0; -- Disable Safe updates

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y')
WHERE `date` IS NOT NULL;

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

SET SQL_SAFE_UPDATES = 1;  -- Re-enable safe updates


-- The 'percentage_laid_off' column is not expressed in percent.
-- To make it into a percentage, it will be multiplied by 100, making the values more interpretable.
SET SQL_SAFE_UPDATES = 0; -- Disable Safe updates

UPDATE layoffs_staging2
SET percentage_laid_off = ROUND(100 * percentage_laid_off, 2) ;

SET SQL_SAFE_UPDATES = 1;  -- Re-enable safe updates

-- Display the updated table
SELECT *
FROM layoffs_staging2;

-- Observing the table, the changes have been successfully updated.

-------- 3. Handling Null or Blank Values -------

-- Observe the table
SELECT *
FROM layoffs_staging2;

-- There are several fields that are either NULL or missing values (blanks)

-- Let's start with 'company'
SELECT *
FROM layoffs_staging2
WHERE company IS NULL
OR company = '';
-- No nulls or blanks

-- location
SELECT *
FROM layoffs_staging2
WHERE location IS NULL
OR location = '';
-- No nulls or blanks

-- industry
SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = '';
-- There is 1 null and 3 blanks.

-- These missing values should be imputed if possible
-- using CTE (Common Table Expressions) to impute missing values

SET SQL_SAFE_UPDATES = 0; -- Disable Safe updates

WITH ImputedIndustries AS (
    SELECT
        company,
        industry,
        MAX(industry) OVER (PARTITION BY company) AS imputed_industry
    FROM
        layoffs_staging2
)

UPDATE layoffs_staging2 ls2
JOIN ImputedIndustries i
    ON ls2.company = i.company
    AND ls2.industry IS NULL
    OR ls2.industry = ''
SET
    ls2.industry = i.imputed_industry
WHERE
    ls2.industry IS NULL
    OR ls2.industry = '';
    
SET SQL_SAFE_UPDATES = 1;  -- Re-enable safe updates

-- check industry for nulls or blanks
-- industry
SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = '';

-- Bally's Interactive still has a null for industry

SELECT *
FROM layoffs_staging2
WHERE company LIKE '%Bally%';

-- This is the only value for Bally's Interactive.
-- A search in Google finds that Bally's is an online casino.
 
SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY industry;

-- None of the existing listed industries appear to have a category similar to gaming or entertainment.
-- I will impute it as 'Gaming'
SET SQL_SAFE_UPDATES = 0; -- Disable Safe updates

UPDATE layoffs_staging2
SET industry = 'Gaming'
WHERE company LIKE 'Bally%';

SET SQL_SAFE_UPDATES = 1;  -- Re-enable safe updates

-- Recheck to see if the update was successful.
SELECT *
FROM layoffs_staging2
WHERE company LIKE '%Bally%';
-- The update was successful

-- check 'stage' for nulls or blanks
SELECT *
FROM layoffs_staging2
WHERE stage IS NULL
OR stage = '';
-- There are 6 NULLs in stage, however it is not possible to determine what stage the layoffs were at.
-- They will have to remain as NULL values

-- check 'country' for nulls or blanks
SELECT *
FROM layoffs_staging2
WHERE country IS NULL
OR country = '';
-- There are no NULLs or missing values in 'country'.

-- NULLs and missing values are also observed in the integer fields. 
-- These values cannot be imputed based on other information available in this table. 

-- Let's observe where total_laid_off and percetnage_laid_off are both null or blank
SELECT COUNT(*) AS Count_Nulls
FROM layoffs_staging2
WHERE total_laid_off IS NULL
OR percentage_laid_off IS NULL;
-- There are 1162 rows where either total_laid_off or percentage_laid_off is NULL.
-- We still have some useful information if one of those two columns is not blank.alter

-- Let's observe where they are both blank
SELECT COUNT(*) AS CountNulls
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;
-- There are 361 rows where they are both blank. This is a lot.

-- Let's observe these
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- Where both are NULL, these rows will be removed as no information of the layoff numbers is present.
SET SQL_SAFE_UPDATES = 0; -- Disable Safe updates

DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SET SQL_SAFE_UPDATES = 1;  -- Re-enable safe updates

-- Observe the table after the updates
SELECT *
FROM layoffs_staging2;

-- Many null or blank values have been removed and the dataset is looking a lot tidier.
-- It was not possible to remove all as the information in the rest of the rows are still important.
-- Imputing is not advised for this project as these numbers are very difficult to estimate and could 
-- range significantly.

-------- 4. Remove Unnecessary Columns: ---------

-- Column 'row_num' is no longer needed. It will be dropped.
-- All of the original columns will be kept
ALTER TABLE layoffs_staging2 
DROP COLUMN row_num;

SELECT *
FROM layoffs_staging2;

-- The data has been cleaned as best as possible for this dataset.

-------- Conclusion --------
/* 
Data cleaning is a very important process that ensures data accuracy and reliability. 
By removing duplicates, standardizing the data, handling missing values, and eliminating unnecessary columns, 
we can clean and improve the quality of the dataset and thereby improve the outcomes of our data analysis. 
This project demonstrates the detailed steps involved in data cleaning through SQL and highlights the importance
in maintaining the integrity of data for insightful and actionable analysis.
*/


-------- Exploratory Data Analysis --------
-- After cleaning, let's continue to have a look and reveal some of the insights in this dataset.

-- First, let's see what time period this dataset covers.
SELECT MIN(date) AS `Earliest Date`
		,MAX(date) AS `Latest Date`
FROM layoffs_staging2;
-- This dataset covers layoffs during and after the Covid 19 Pandemic
-- spanning three years from the 11th of March 2020 to the 6th of March 2023.


-- Total Number of Layoffs in the data set and the total sum of funds raised.
SELECT SUM(total_laid_off) AS Total_Layoffs
		,SUM(funds_raised_millions) AS `Funds Raised ($Millions)`
FROM layoffs_staging2;

-- For values where there are no NULLs or blanks, there were a total of:
-- 383,659 layoffs 
-- and $1.601450 billion raised in funds.

-- Where percentage laid off is 100%, this entails that the company folded and went bankrupt.
-- Let's see how many companies folded.
SELECT COUNT(total_laid_off) AS NumberOfInsolventCompanies
FROM layoffs_staging2
WHERE percentage_laid_off = 100;

-- A total of 43 companies went into insolvency.

-- Many companies had layoffs in different stages or regions.
-- Let's see the total number of layoffs by each company, sorted in descending order.
SELECT company, SUM(total_laid_off) AS `Total Laid Off By Company`
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

-- Amazon, Google and Meta had the largest number of layoffs
-- The least amount of total layoffs in this dataset were only 35.

-- Let's observe which industries had the largest number of layoffs.
SELECT industry, SUM(total_laid_off) AS `Total Laid Off By Company`
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

-- The Consumer and Retail industries had the largest number of layoffs with
-- 44,782 and 43,613 layoffs respectfully.
-- Manufacturing was least affect with only 20 layoffs
-- Gaming is the new industry we identified earlier.
-- As ementioned, we did not have figures for Ballys.

-- Let's observe which countries were had the largest number of layoffs.
SELECT country, SUM(total_laid_off) AS `Total Laid Off By Country`
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

-- The USA and India had the largest number of layoffs with
-- 256,559 and 35,993 layoffs respectfully. These countries also have the largest populations.


-- Let's see how layoffs were affected over time, say per month.
-- Ensure the date column is in DATE format (This was already done)
-- ALTER TABLE your_table_name
-- MODIFY date DATE;

-- Extract year and month, and aggregate the data. 
-- A Common Table Expression will be used to help create a rolling total.

WITH monthly_layoffs AS (
    SELECT 
        DATE_FORMAT(date, '%Y-%m') AS `Year and Month`,
        SUM(total_laid_off) AS `Monthly Layoffs`
    FROM layoffs_staging2
	WHERE DATE_FORMAT(date, '%Y-%m') IS NOT NULL
    GROUP BY DATE_FORMAT(date, '%Y-%m')
)
SELECT 
    `Year and Month`,
    `Monthly Layoffs`,
    SUM(`Monthly Layoffs`) OVER (ORDER BY `Year and Month`) AS `Accumulated Layoffs`
FROM 
    monthly_layoffs
ORDER BY 
    `Year and Month`;
    
-- The code above produces a table which is a time-series of total layoffs per month and the accumulation of layoffs by month
-- from the companies in this dataset.
-- April and May of 2020 had heavy layoffs of 26,710 and 25,804 respectfully. This is just after lockdowns started appearing worldwide.
-- Layoffs have also increased considerably towards the end of the timeframe in this dataset.
-- There were 53,451 layoffs in November 2022 and the largest number per month was January 2023 with 84,714. 
-- February 2023 was also large with 36493 layoffs.
-- This table could be exported to perform time-series analysis and plots.


-- Let's see layoffs by year and industry using the rank() function.
-- The RANK() function ranks companies within each industry and year based on total layoffs in descending order. 
-- Equal values receive the same rank, and the next rank is skipped to account for the tie.
SELECT
	company, 
	YEAR(`date`) AS `Year`, 
	industry, 
	location,
	total_laid_off, 
	-- funds_raised_millions,
	SUM(total_laid_off) OVER(PARTITION BY YEAR(`date`), industry) AS `Total Laid Off by Year And Industry`,
	RANK() OVER(PARTITION BY industry, YEAR(`date`) ORDER BY total_laid_off DESC) AS `Rank By Year And Industry`
FROM layoffs_staging2
WHERE 
	YEAR(`date`) IS NOT NULL
	AND industry IS NOT NULL
ORDER BY `Year`, industry, `Rank By Year And Industry`;


-- This query identifies the top 5 companies with the highest layoffs for each year using Common Table Expressions (CTEs).
-- 
-- Step 1: The first CTE (CTE1) groups the data by company and year, summing up the total number of layoffs per company per year.
-- Step 2: The second CTE (CTE2) ranks companies within each year based on the total layoffs in descending order.
-- Step 3: The final query filters the ranked data to include only the top 5 companies per year and sorts it by year and rank.
-- This approach demonstrates a common method for producing rankings using CTEs.

WITH CTE1 AS (
    SELECT 	
        company,
        YEAR(date) AS `Year`,
        SUM(total_laid_off) AS `Total Laid Off`
    FROM 
        layoffs_staging2
    WHERE 
        YEAR(date) IS NOT NULL
    GROUP BY 
        company, 
        YEAR(date)
),
CTE2 AS (
    SELECT	
        company,
        `Year`,
        `Total Laid Off`,
        RANK() OVER(PARTITION BY `Year` ORDER BY `Total Laid Off` DESC) AS `Ranking`
    FROM 
        CTE1
)
SELECT *
FROM
    CTE2
WHERE 
    `Ranking` <= 5 -- Filters for the top 5 companies with the highest layoffs per year.
ORDER BY 
    `Year`,
    `Ranking`; -- Orders the results by year and ranking.

-- Output Explanation:
-- The output lists the top 5 companies with the highest layoffs for each year, sorted by year and rank. 
-- For example:
-- In 2020, Uber ranks #1 with 7,525 layoffs, followed by Booking.com with 4,375 layoffs.
-- In 2022, Meta ranks #1 with 11,000 layoffs, while Philips and Carvana tie at rank #5 with 4,000 layoffs each.
-- Tied rankings (e.g., rank #5 in 2022) indicate multiple companies had the same number of layoffs, and the next rank is skipped.


/*
Conclusion
This is a project that highlights the importance of data cleaning as a foundational step in any analysis. Datasets are often
not perfectly clean, so there are many important steps to ensure that they have been prepared optimally and as accurately as possible.
By searching for irregularities and errors in the dataset, I transformed the raw data into a structured format suitable for analysis and possible modelling.

The explorartory data analysis revealed important trends in global layoffs during the COVID-19 pandemic. 
In this project I learned and demonstrated essential data preparation and analysis skills utilising SQL. 
Future work will be to expand on the EDA and possible make a Power BI dashboard.
*/