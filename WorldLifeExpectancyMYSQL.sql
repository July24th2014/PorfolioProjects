SELECT *
FROM world_life_expectancy;

-- Removing duplicates (identify duplicates)
-- Combine country&year to create a unique column since we do not have like an employee_id

SELECT country, year, concat(country,year), count(concat(country,year))
FROM world_life_expectancy
group by country, year, concat(country,year)
HAVING count(concat(country,year)) > 1;

-- Identify duplicates in row_id then remove them by row_id (subqueries)

select *
from(
select row_id, concat(country,year),
row_number()over(partition by concat(country,year) order by concat(country,year)) as row_num
FROM world_life_expectancy) as row_table
where row_num > 1;

-- When deleting something *always have a backup table*

delete from world_life_expectancy
where row_id in 
	(select row_id
	from(
	select row_id, concat(country,year),
	row_number()over(partition by concat(country,year) order by concat(country,			year)) as row_num
	FROM world_life_expectancy) as row_table
	where row_num > 1);

-- Missing data (populate data)
SELECT *
FROM world_life_expectancy
where Status = '';
#where Status is null;

SELECT distinct (status)
FROM world_life_expectancy
where Status <> '';

SELECT distinct (country)
FROM world_life_expectancy
where status = 'Developing';

-- updating the status of missing data within the listed countries

update world_life_expectancy
set status = 'Developing'
	where country in (SELECT distinct (country)
	FROM world_life_expectancy
	where status = 'Developing');

-- Join table to itself since subqueries is not working
update world_life_expectancy w1
join world_life_expectancy w2
on w1.country = w2.country
	set w1.status = 'Developing'
    #set w1.status = 'Developed'
	where w1.status = ''
	and w2.status != ''
    and w2.status = 'Developed';
	#and w2.status = 'Developed';
    
SELECT *
FROM world_life_expectancy
where country = 'United States of America';


-- Missing data (populate data)
SELECT `Life expectancy`
FROM world_life_expectancy
where `Life expectancy` = '';

SELECT country, year, `Life expectancy`
FROM world_life_expectancy
;

-- Calculate the average of the new year(-1) and last year(+1)
-- Join table by joining two tables 
SELECT w1.country, w1.year,w1.`Life expectancy`,
w2.country, w2.year,w2.`Life expectancy`,
w3.country, w3.year,w3.`Life expectancy`,
round((w2.`Life expectancy`  + w3.`Life expectancy`)/2,1)
FROM world_life_expectancy w1
join world_life_expectancy w2
	on w1.country = w2.country
	and w1.year = w2.year-1
join world_life_expectancy w3
	on w1.country = w3.country
	and w1.year = w3.year+1
where w1.`Life expectancy` = ''
;

-- Update the missing value in `Life expectancy`
UPDATE world_life_expectancy w1
join world_life_expectancy w2
	on w1.country = w2.country
	and w1.year = w2.year-1
join world_life_expectancy w3
	on w1.country = w3.country
	and w1.year = w3.year+1
Set w1.`Life expectancy` = round((w2.`Life expectancy`  + w3.`Life expectancy`)/2,1)
where w1.`Life expectancy` = '';

-- Exploratory (insights & trends)

-- Life expectancy of each country by using highest and lowest life expectancy

select country,
min(`Life expectancy`) as min, 
max(`Life expectancy`) as max,
round(max(`Life expectancy`) - min(`Life expectancy`),1) as life_increase
from world_life_expectancy
group by country 
having min(`Life expectancy`) and max(`Life expectancy`) != 0
order by life_increase desc;

-- explore on each year based on avarage of life expectancy
select year, round(avg(`Life expectancy`),2) as avg_life
from world_life_expectancy
where `Life expectancy` != 0
group by year
order by year;

-- explore on higher gdp correlation with life expectancy
-- visualize this on tableau to check the pos or neg correlation
select country, round(avg(`Life expectancy`)) as life, round(avg(gdp)) as gdpp
from world_life_expectancy
group by country
having life and gdpp != 0
order by gdpp desc;

-- comparing high_gdp and low_gdp with life expectancy
select 
sum(case when gdp >= 1500 then 1 else 0 end) high_gdp,
avg(case when gdp >= 1500 then `Life expectancy` else null end) high_gdp_life_expectancy,
sum(case when gdp <= 1500 then 1 else 0 end) low_gdp,
avg(case when gdp <= 1500 then `Life expectancy` else null end) low_gdp_life_expectancy
from world_life_expectancy;


select *
from world_life_expectancy;

select status, round(avg(`Life expectancy`),1)
from world_life_expectancy
group by status;

select status, count(distinct country), round(avg(`Life expectancy`),1)
from world_life_expectancy
group by status;

-- reususe (from life expectancy) to look at bmi (body mass index)
select country, round(avg(`Life expectancy`)) as life, round(avg(bmi)) as bmi
from world_life_expectancy
group by country
having life and bmi != 0
order by bmi desc;

-- look at adult mortality
select country,
year,
`Life expectancy`,
`Adult Mortality`,
sum(`Adult Mortality`) over(partition by country order by year) as rolling_total
from world_life_expectancy
where country like '%nam%';
