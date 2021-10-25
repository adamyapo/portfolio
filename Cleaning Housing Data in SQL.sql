/*
Cleaning Data using SQL Queries

Skills used below: SUBSTRINGS, CTE's, CASE statements, Partitions
*/


SELECT *
FROM nashvillehousing.datacleaning


--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

SELECT SaleDate
FROM nashvillehousing.datacleaning

ALTER TABLE nashvillehousing.datacleaning
ADD SaleDateConverted Date;

UPDATE nashvillehousing.datacleaning
SET SaleDateConverted = CONVERT(SaleDate,DATE)

SELECT SaleDateConverted
FROM nashvillehousing.datacleaning


 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

SELECT *
FROM nashvillehousing.datacleaning
-- WHERE PropertyAddress is null
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, IFNULL(a.PropertyAddress, b.PropertyAddress)
FROM nashvillehousing.datacleaning a
JOIN nashvillehousing.datacleaning b
    ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is null

UPDATE nashvillehousing.datacleaning a
JOIN nashvillehousing.datacleaning b
    ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
SET a.PropertyAddress = IFNULL(a.PropertyAddress,b.PropertyAddress)
WHERE a.PropertyAddress is null


--------------------------------------------------------------------------------------------------------------------------

-- Dividing "PropertyAddress" into Individual Columns (Address, City)

SELECT PropertyAddress
FROM nashvillehousing.datacleaning

SELECT
SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) -1) as StreetAddress
,SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) +1, LENGTH(PropertyAddress)) as PropertyCity
FROM nashvillehousing.datacleaning

ALTER TABLE nashvillehousing.datacleaning
ADD PropertyStreetAddress NVARCHAR(255);

UPDATE nashvillehousing.datacleaning
SET PropertyStreetAddress = SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) -1)

ALTER TABLE nashvillehousing.datacleaning
ADD PropertyCity NVARCHAR(255);

UPDATE nashvillehousing.datacleaning
SET PropertyCity = SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) +1, LENGTH(PropertyAddress));

SELECT *
FROM nashvillehousing.datacleaning


--------------------------------------------------------------------------------------------------------------------------

-- Dividing "OwnerAddress" into Individual Columns (Address, City, State)

SELECT
SUBSTRING_INDEX(OwnerAddress, ',', 1) as OwnerStreetAddress
,SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2),',', -1) as OwnerCity
,RIGHT(OwnerAddress, 2) as OwnerState
FROM nashvillehousing.datacleaning

ALTER TABLE nashvillehousing.datacleaning
ADD OwnerStreetAddress NVARCHAR(255);

UPDATE nashvillehousing.datacleaning
SET OwnerStreetAddress = SUBSTRING_INDEX(OwnerAddress, ',', 1)

ALTER TABLE nashvillehousing.datacleaning
ADD OwnerCity NVARCHAR(255);

UPDATE nashvillehousing.datacleaning
SET OwnerCity = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2),',', -1)

ALTER TABLE nashvillehousing.datacleaning
ADD OwnerState NVARCHAR(255);

UPDATE nashvillehousing.datacleaning
SET OwnerState = RIGHT(OwnerAddress, 2)

SELECT *
FROM nashvillehousing.datacleaning


---------------------------------------------------------------------------------------------------------

-- Delete "PropertyAddress" and "OwnerAddress" Columns

SELECT *
FROM nashvillehousing.datacleaning

ALTER TABLE nashvillehousing.datacleaning
DROP PropertyAddress, OwnerAddress


--------------------------------------------------------------------------------------------------------------------------

-- In 'SoldAsVacant' collumn, changed "Y" and "N" to "Yes" or "No"

SELECT Distinct(SoldAsVacant), Count(SoldAsVacant)
FROM nashvillehousing.datacleaning
GROUP BY SoldAsVacant
ORDER BY 2

SELECT 
    SoldAsVacant,
    CASE
        WHEN SoldAsVacant = 'Y' THEN 'YES'
        WHEN SoldAsVacant = 'N' THEN 'NO'
        ELSE SoldAsVacant
    END
FROM
    nashvillehousing.datacleaning

UPDATE nashvillehousing.datacleaning 
SET 
    SoldAsVacant = CASE
        WHEN SoldAsVacant = 'Y' THEN 'YES'
        WHEN SoldAsVacant = 'N' THEN 'NO'
        ELSE SoldAsVacant
    END


-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS
(SELECT *,
		ROW_NUMBER() OVER (
        PARTITION BY 
				ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
                ORDER BY
					UniqueID
                    ) row_num
FROM nashvillehousing.datacleaning
)
DELETE FROM RowNumCTE
WHERE row_num > 1

             
