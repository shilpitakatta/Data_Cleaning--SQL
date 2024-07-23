create database world_layoffs;
use world_layoffs;

SELECT * FROM layoffs;

-- 1 Remove Duplicate values
-- 2 Standardize the data
-- 3 NULL values or Blank values
-- 4 Remove Any columns 

-- Creating another table to make a copy  
CREATE table layoffs_demo LIKE layoffs;
SELECT * FROM layoffs_demo;

-- Copying all data FROM main table
INSERT layoffs_demo 
SELECT *
FROM layoffs;

-- 1 Remove Duplicate values

SELECT *,
row_number() over(partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised) as duplicate_count
FROM layoffs_demo;

with duplicate_cte as
(
SELECT *,
row_number() over(partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised) as duplicate_count
FROM layoffs_demo
)
SELECT * 
FROM duplicate_cte
WHERE duplicate_count > 1;

SELECT * FROM layoffs_demo WHERE company= 'Beyond Meat';

CREATE TABLE `layoffs_demo2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` text,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised` int DEFAULT NULL,
  `duplicate_count` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Table is created with all columns
SELECT * FROM layoffs_demo2;

-- Inserting all the data
insert into layoffs_demo2
SELECT *,
row_number() over(partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised) as duplicate_count
FROM layoffs_demo;

-- To show all duplicate values
SELECT * FROM layoffs_demo2 WHERE duplicate_count > 1;

-- Error Code: 1175. You are using safe UPDATE mode and you tried to UPDATE a table without a WHERE that uses a KEY column.  
-- To disable safe mode, toggle the option in Preferences -> SQL Editor and reconnect.	0.000 sec
SET SQL_SAFE_UPDATES = 0;

-- To DELETE the duplicates
DELETE FROM layoffs_demo2 WHERE duplicate_count > 1;

-- 2 Standardizing data
-- To remove extra spaces
SELECT company, TRIM(company) FROM layoffs_demo2;
UPDATE layoffs_demo2 SET company = TRIM(company);

SELECT DISTINCT(industry) FROM layoffs_demo2 order by 1;

-- To UPDATE the industry name which has 'Crypto'/'Cryptocurrency'/'Crypto currency'
SELECT * FROM layoffs_demo2 WHERE industry LIKE 'crypto%';
UPDATE layoffs_demo2 SET industry = 'Crypto' WHERE industry LIKE 'Crypto%';

-- IF any extra character LIKE(%,'.',$,&) eg: United States. then use TRIM(TRAILING '.' FROM column)

-- Records are changed to date format
SELECT `date`, str_to_date(`date`, '%d-%m-%Y') as new_date FROM layoffs_demo2;
UPDATE layoffs_demo2 SET `date` = str_to_date(`date`, '%d-%m-%Y');

-- The datatype of column is changed to date
ALTER table layoffs_demo2 modify column `date` date;

-- 3 NULL values or Blank values 	
SELECT * FROM layoffs_demo2 WHERE industry IS NULL;

SELECT * FROM layoffs_demo2 WHERE company = 'Appsmith';

-- NOTE: SET all blanks NULL within the table
UPDATE layoffs_demo2
SET industry = NULL WHERE industry = '';

-- Performing JOIN on same table to fill in NULL values
SELECT * FROM layoffs_demo2 t1 
JOIN layoffs_demo2 t2 
	on t1.company = t2.company
	and t1.location = t2.location
WHERE t1.industry IS NULL 
and t2.industry IS NOT NULL;

-- Updating table where we have NULL values
UPDATE layoffs_demo2 t1
JOIN layoffs_demo2 t2 
	on t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL 
and t2.industry IS NOT NULL;

SELECT * FROM layoffs_demo2 WHERE total_laid_off IS NULL and percentage_laid_off IS NULL;

DELETE FROM layoffs_demo2 WHERE total_laid_off IS NULL and percentage_laid_off IS NULL;

-- Remove any columns 
ALTER table layoffs_demo2 drop column duplicate_count;

SELECT * FROM layoffs_demo2;




