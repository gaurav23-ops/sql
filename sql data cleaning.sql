-- 🔹 Step 1: Create a staging table with the same structure as 'layoffs'
CREATE TABLE layoffs_staging LIKE layoffs;

-- 🔹 Step 2: Copy all data from 'layoffs' into the staging table
INSERT INTO layoffs_staging
SELECT * FROM layoffs;

-- 🔹 Step 3: Create a second staging table with an additional 'row_num' column for deduplication
CREATE TABLE layoffs_staging2 (
  company TEXT,
  location TEXT,
  industry TEXT,
  total_laid_off INT DEFAULT NULL,
  percentage_laid_off TEXT,
  date TEXT,
  stage TEXT,
  country TEXT,
  funds_raised_millions INT DEFAULT NULL,
  row_num INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 🔹 Step 4: Insert data into 'layoffs_staging2' with ROW_NUMBER to identify duplicates
INSERT INTO layoffs_staging2 (
  company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions, row_num
)
SELECT 
  company, location, industry, total_laid_off, percentage_laid_off,
  STR_TO_DATE(TRIM(`date`), '%m/%d/%Y'), stage, country, funds_raised_millions,
  ROW_NUMBER() OVER (
    PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, 
                 STR_TO_DATE(TRIM(`date`), '%m/%d/%Y'), stage, country, funds_raised_millions
  ) AS row_num
FROM layoffs_staging
WHERE STR_TO_DATE(TRIM(`date`), '%m/%d/%Y') IS NOT NULL;

-- 🔹 Step 5: Disable safe updates to allow bulk deletion
SET SQL_SAFE_UPDATES = 0;

-- 🔹 Step 6: Delete duplicate rows (keep only row_num = 1)
DELETE FROM layoffs_staging2
WHERE row_num > 1;

-- 🔹 Step 7: Verify that duplicates are removed
SELECT * FROM layoffs_staging2
WHERE row_num > 1;

-- 🔹 Step 8: View cleaned data
SELECT * FROM layoffs_staging2;

-- 🔹 Step 9: Standardize company names by trimming whitespace
SELECT company, TRIM(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);

-- 🔹 Step 10: Review distinct industry values
SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1;

-- 🔹 Step 11: Identify rows with inconsistent 'crypto' industry labels
SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'crypto%';

-- 🔹 Step 12: Standardize 'crypto%' entries to 'Crypto'
UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'crypto%';

-- 🔹 Step 13: Review country names with trailing dots
SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
ORDER BY 1;

-- 🔹 Step 14: Remove trailing dots from country names
UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country);

-- 🔹 Step 15: Preview date values before conversion
SELECT `date`
FROM layoffs_staging2;

-- 🔹 Step 16: Convert date format from 'MM/DD/YYYY' to MySQL DATE
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y')
WHERE `date` LIKE '%/%/%';

-- 🔹 Step 17: Alter column type to DATE for proper formatting
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- 🔹 Step 18: View cleaned table
SELECT * FROM layoffs_staging2;

-- 🔹 Step 19: Identify rows missing both layoff metrics
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
  AND percentage_laid_off IS NULL;

-- 🔹 Step 20: Delete rows with no layoff data
DELETE FROM layoffs_staging2
WHERE total_laid_off IS NULL
  AND percentage_laid_off IS NULL;

-- 🔹 Step 21: Convert empty string industries to NULL
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

-- 🔹 Step 22: Identify rows with missing or empty industry
SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
   OR industry = ''
ORDER BY company;

-- 🔹 Step 23: View full table
SELECT * FROM layoffs_staging2;

-- 🔹 Step 24: Compare missing industry rows with known values from same company
SELECT t1.industry AS missing_industry, t2.industry AS known_industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2 ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
  AND t2.industry IS NOT NULL;

-- 🔹 Step 25: Fill missing industry values using known values from same company
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2 ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
  AND t2.industry IS NOT NULL;

-- 🔹 Step 26: Final preview of cleaned table
SELECT * FROM layoffs_staging2;

-- 🔹 Step 27: Drop 'row_num' column if no longer needed
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;




