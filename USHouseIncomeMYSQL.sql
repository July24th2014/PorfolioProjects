SELECT * FROM us_housing.us_household_income;
SELECT * FROM us_household_income_statistics;

alter table us_household_income_statistics rename column `ï»¿id` to `id`;

-- remove duplicates
SELECT id, count(id) 
FROM us_housing.us_household_income
group by id
having count(id) > 1;

select *
from(
select row_id,
id,
row_number()over(partition by id order by id) as row_num
FROM us_housing.us_household_income) as duplicates
where row_num > 1
;

delete from us_household_income
where row_id in (select row_id
from(
select row_id,
id,
row_number()over(partition by id order by id) as row_num
FROM us_housing.us_household_income) as duplicates
where row_num > 1)
;

-- statename wrong
select distinct(state_name)
from us_household_income
group by State_Name
order by 1;

update us_household_income
set state_name = 'Alabama'
where state_name = 'alabama'
;

-- missing data in county
select *
from us_household_income
where place = '';

select *
from us_household_income
where County = 'Autauga County'
order by 1;

update us_household_income
set place = 'Autaugaville'
where county = 'Autauga County'
and city = 'Vinemont';

-- combine similiar type
select type, count(type)
from us_household_income
group by type;

update us_household_income
set type = 'Borough'
where type = 'Boroughs';

-- check for the 0

select awater
from us_household_income
where AWater = 0 or awater = '' or awater is null;

select distinct(awater)
from us_household_income
where AWater = 0 or awater = '' or awater is null;

select aland
from us_household_income
where aland = 0 or aland = '' or aland is null;

select aland,awater
from us_household_income
where (aland = 0 or aland = '' or aland is null);

-- exploratory

-- top 10 state that has largest water and land
select state_name, sum(aland), sum(awater)
from us_household_income
group by state_name
order by 2 desc
limit 10;



-- average income househould by state
SELECT u.state_name, round(avg(mean),1), round(avg(median),1)
FROM us_housing.us_household_income u
join us_household_income_statistics us on u.id = us.id
where mean <>0
group by u.state_name
order by 2 desc
limit 10;

-- type (filter out the outliers)
SELECT type, count(type), round(avg(mean),1), round(avg(median),1)
FROM us_housing.us_household_income u
join us_household_income_statistics us on u.id = us.id
where mean <> 0
group by Type
having count(type) > 100
order by 2 desc;

select *
 from us_household_income 
 where type = 'community';
 
 -- income based on city
 SELECT u.State_Name, city, round(avg(mean),1) as avg_income
FROM us_housing.us_household_income u
join us_household_income_statistics us on u.id = us.id
group by city, u.State_Name
order by avg_income desc;