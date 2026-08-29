-- Data Cleaning
select *from layoffs;
-- 1.Removing Duplicates
-- 2. Standardize the Data
-- 3. Null Values or Blank values
-- 4 . Remove Any Columns



-- Creating the Staging Table
Create Table layoffs_staging 
Like layoffs;
insert layoffs_staging
select *from layoffs;
select *from layoffs_staging;


-- 1.Removing Duplicates
select *
, Row_Number() over (partition by stage,company , location, funds_raised_millions,  industry , total_laid_off , country, percentage_laid_off , `date`) as "row_num"
from layoffs_staging;
with duplicate_cte as 
(
select *
, Row_Number() over (partition by stage ,company ,  industry , total_laid_off , country, percentage_laid_off , `date`) as "row_num"
from layoffs_staging
)
select * from duplicate_cte 
where row_num >= 2 ;
-- Creating another Table for deleting dups because of MySQL limmitiations 
CREATE TABLE layoffs_staging2 (
    company TEXT,
    location TEXT,
    industry TEXT,
    total_laid_off INT DEFAULT NULL,
    percentage_laid_off TEXT,
    `date` TEXT,
    stage TEXT,
    country TEXT,
    funds_raised_millions INT DEFAULT NULL,
    row_num INT
);
insert layoffs_staging2 
select *
, Row_Number() over (partition by stage ,company ,  industry , total_laid_off , country, percentage_laid_off , `date`) as "row_num"
from layoffs_staging;
SET SQL_SAFE_UPDATES = 0;
delete from layoffs_staging2
where row_num >= 2 ;
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;
with duplicate_check as 
(
select *
, Row_Number() over (partition by stage ,company ,  industry , total_laid_off , country, percentage_laid_off , `date`) as "row_num"
from layoffs_staging2
)
select * from duplicate_check
where row_num >= 2;

-- 2. Standardize the Data
-- Removing Extra Spaces by Trim by Updating them (Removing white spaces)
select company , trim(company) As removedSpaces from layoffs_staging2;
update layoffs_staging2
set company = trim(company);
select company from layoffs_staging2;

-- Making all the crypto% be Crypto
select * from layoffs_staging2
where industry like "Crypto%";
update layoffs_staging2
set industry = "Crypto"
where industry like "Crypto%";
select distinct industry from layoffs_staging2;
 -- Checking also other values
 select distinct country from layoffs_staging2 order by 1;
 -- united states has 2 values must be fixed
 update layoffs_staging2
 set country= "United States"
 where country like "United States%";
 select distinct country from layoffs_staging2 order by 1;
 
 
 -- changing from string : date to date : date  and also adding right mysql format
 select `date`, str_to_date(`date`, '%m/%d/%Y') from layoffs_staging2;
 Update layoffs_staging2
 set date = str_to_date(`date`, '%m/%d/%Y');
 select `date` from layoffs_staging2;
 -- changing the data type pf date from to text to Actuall Date data type
 alter table layoffs_staging2
 modify column `date` Date; 
 select *from layoffs_staging2;
 
 
 
 
 
 -- 3. Null Values or Blank values
select *from layoffs_staging2 where total_laid_off is null and percentage_laid_off is null;
select *from layoffs_staging2 where industry is null or industry='';
update layoffs_staging2 
set industry=null
where industry='';
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL 
AND t2. industry IS NOT NULL;



-- calculating how many rows will be deleted
select total_laid_off , percentage_laid_off , count(*) As Missingdata from layoffs_staging2  -- count(*) counts all the rows from the output
where total_laid_off is null and percentage_laid_off is null
group by total_laid_off , percentage_laid_off;

Delete from layoffs_staging2
where total_laid_off is null and percentage_laid_off is null;

-- 4 . Remove Any Columns
-- we used this command above
-- ALTER TABLE layoffs_staging2
-- DROP COLUMN row_num;




 
 





