
select * 
from profolioproject.nashvillehousing;

-- Data Cleaning SQL
-- Standardize Data Format

rename table profolioproject.nashvillehousingdatafordatacleaning to nashvillehousing;

ALTER TABLE nashvillehousing
CHANGE SaleDate Date char(50);

ALTER TABLE nashvillehousing
Add Datesale char(50);

UPDATE nashvillehousing
SET DATEsale = DATE;

-- Populate Property Address DATA

select *
from profolioproject.nashvillehousing
where PropertyAddress is null 
order by ParcelID;

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
from profolioproject.nashvillehousing a 
JOIN profolioproject.nashvillehousing b
on a.ParcelID = b.ParcelID
and a.ï»¿UniqueID <> b. ï»¿UniqueID
where a.PropertyAddress is null;

-- Breaking out Adrress into Individuals Column (Address, City, State)

select PropertyAddress
from profolioproject.nashvillehousing;
-- where PropertyAddress is null 
-- order by ParcelID;

select 
substring(PropertyAddress, 1, LOCATE(',', PropertyAddress) -1) as Address
, substring(PropertyAddress, LOCATE(',', PropertyAddress) +1, LENGTH(PropertyAddress)) as Address
from profolioproject.nashvillehousing;

ALTER TABLE nashvillehousing
Add PropertySplitAddress char(255);

UPDATE nashvillehousing
SET PropertySplitAddress = substring(PropertyAddress, 1, LOCATE(',', PropertyAddress) -1) ;

ALTER TABLE nashvillehousing
Add PropertySplitCITY char(255);

UPDATE nashvillehousing
SET PropertySplitCITY = substring(PropertyAddress, LOCATE(',', PropertyAddress) +1, LENGTH(PropertyAddress));

select *
from profolioproject.nashvillehousing;


select OwnerAddress
from profolioproject.nashvillehousing;


SELECT
    SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', 3), '.', -1) AS ownerstate,
    SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', 2), '.', -1) AS ownercity,
    SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', 1), '.', -1) AS owneraddressnew
FROM profolioproject.nashvillehousing;

ALTER TABLE nashvillehousing
Add ownerstate char(255);

UPDATE nashvillehousing
SET ownerstate =   SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', 3), '.', -1);

ALTER TABLE nashvillehousing
Add ownercity char(255);

UPDATE nashvillehousing
SET ownercity = SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', 2), '.', -1) ;

ALTER TABLE nashvillehousing
Add owneraddressnew char(255);

UPDATE nashvillehousing
SET owneraddressnew = SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', 1), '.', -1);

select *
from profolioproject.nashvillehousing;

-- Change Y and N to Yes and No in "Sold as Vacant" field

select distinct(SoldAsVacant), count(SoldAsVacant)
from profolioproject.nashvillehousing
group by SoldAsVacant
order by 2;

select SoldAsVacant
, case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
    else SoldAsVacant end as SoldAsVacant
from profolioproject.nashvillehousing;

update nashvillehousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
    else SoldAsVacant end ;
    
 -- Remove Duplicates

SELECT *
FROM (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY ParcelID,
                            PropertyAddress,
                            SalePrice,
                            Datesale,
                            LegalReference
               ORDER BY
                   ï»¿UniqueID
           ) AS row_num
    FROM profolioproject.nashvillehousing
    -- ORDER BY ParcelID
) AS RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress;

-- Perform DELETE operation for identified duplicate rows
DELETE FROM profolioproject.nashvillehousing
WHERE ï»¿UniqueID IN (
    SELECT ï»¿UniqueID
    FROM (
        SELECT ï»¿UniqueID,
               ROW_NUMBER() OVER (
                   PARTITION BY ParcelID,
                                PropertyAddress,
                                SalePrice,
                                Datesale,
                                LegalReference
                   ORDER BY ï»¿UniqueID
               ) AS row_num
         FROM profolioproject.nashvillehousing
    ) AS RowNumCTE
    WHERE row_num > 1
);

select *
from profolioproject.nashvillehousing;
 
 -- Delete Unused Columns
 
 select *
from profolioproject.nashvillehousing;

Alter table profolioproject.nashvillehousing
drop column OwnerAddress, 
drop column PropertyAddress,
drop column TaxDistrict; 

Alter table profolioproject.nashvillehousing
drop column DateSale; 