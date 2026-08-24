-- Exploratory Data Analysis (EDA)

-- Finding fully laid off companies 
select max(total_laid_off) , max(percentage_laid_off) from layoffs_staging2;
select * from layoffs_staging2
where percentage_laid_off=1
order by total_laid_off desc;	

-- Finding total laid offs for each parameter

select company , sum(total_laid_off) from layoffs_staging2 
group by company
order by 2 desc;

select industry , sum(total_laid_off) from layoffs_staging2 
group by industry
order by 2 desc;


select country , sum(total_laid_off) from layoffs_staging2 
group by country
order by 2 desc;

select year(`date`) , sum(total_laid_off) 
from layoffs_staging2
group by YEAR(`date`)
order by 1;

select stage , sum(total_laid_off) from layoffs_staging2 
group by stage
order by 2 desc;

select substring(`date` , 1 , 7) As "MONTH" , sum(total_laid_off) from layoffs_staging2
group by month 
order by 2;

with rolling_total AS
(
select substring(`date` , 1 , 7) As "MONTH" , sum(total_laid_off) as total_off from layoffs_staging2 
group by month
order by 1 asc
)
select month ,total_off , sum(total_off) over(order by month) AS rolling_total 
from rolling_total;

select company , Year(`date`) as year , sum(total_laid_off) as total_off
from layoffs_staging2
group by company ,Year(`date`);

with maximum_laidoff AS
(
select company , Year(`date`) as year , sum(total_laid_off) as total_off
from layoffs_staging2
group by company ,Year(`date`)

)
select company , year , total_off , dense_rank() over(partition by year order by total_off desc) as "Lay Off rankings in a year"
from maximum_laidoff;

with maximum_laidoff AS
(
select company , Year(`date`) as year , sum(total_laid_off) as total_off
from layoffs_staging2
group by company ,Year(`date`)

)
select company , year , total_off , row_number () over(order by total_off desc) as "Lay Off rankings in a year"
from maximum_laidoff;

with maximum_laidoff AS
(
select company , Year(`date`) as year , sum(total_laid_off) as total_off
from layoffs_staging2
group by company ,Year(`date`)

)
,
rankings as 
(
select company , year , total_off , dense_rank() over(partition by year order by total_off desc) as "Rankings"
from maximum_laidoff
)
select company , year , total_off , Rankings from rankings
where Rankings <=5;
