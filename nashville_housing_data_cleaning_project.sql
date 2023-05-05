/*
Cleaning Data in SQL Queries
*/

-- Select all data
SELECT *
FROM DataCleaningProject..NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

SELECT SaleDateConverted
FROM DataCleaningProject..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

 --------------------------------------------------------------------------------------------------------------------------

-- Populate PropertyAddress column

-- Looking for PropertyAddress IS NULL 
SELECT t1.ParcelID, t1.PropertyAddress, t2.ParcelID, t2.PropertyAddress, 
		ISNULL(t1.PropertyAddress, t2.PropertyAddress)
FROM DataCleaningProject..NashvilleHousing t1
INNER JOIN DataCleaningProject..NashvilleHousing t2
ON t1.ParcelID = t2.ParcelID AND t1.[UniqueID ]<> t2.[UniqueID ]
WHERE t1.PropertyAddress IS NULL

-- Update PropertyAddress
UPDATE t1
SET PropertyAddress = ISNULL(t1.PropertyAddress, t2.PropertyAddress)
FROM DataCleaningProject..NashvilleHousing t1
INNER JOIN DataCleaningProject..NashvilleHousing t2
ON t1.ParcelID = t2.ParcelID AND t1.[UniqueID ]<> t2.[UniqueID ]
WHERE t1.PropertyAddress IS NULL
--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT SUBSTRING(PropertyAddress, 0, CHARINDEX(',', PropertyAddress, 0)) AS Address, 
	   RIGHT(PropertyAddress, CHARINDEX(',', REVERSE(PropertyAddress)) - 2) AS City 
	   --,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS City
FROM DataCleaningProject..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD SplitPropertyAddress Nvarchar(255);

UPDATE NashvilleHousing
SET SplitPropertyAddress = SUBSTRING(PropertyAddress, 0, CHARINDEX(',', PropertyAddress, 0))

ALTER TABLE NashvilleHousing
ADD SplitPropertyCity Nvarchar(255);

UPDATE NashvilleHousing
SET SplitPropertyCity = RIGHT(PropertyAddress, CHARINDEX(',', REVERSE(PropertyAddress)) - 2)


SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS Address,
	   PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS City,
	   PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS State
FROM DataCleaningProject..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD SplitOwnerAddress Nvarchar(255);

UPDATE NashvilleHousing
SET SplitOwnerAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
ADD SplitOwnerCity Nvarchar(255);

UPDATE NashvilleHousing
SET SplitOwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
ADD SplitOwnerState Nvarchar(255);

UPDATE NashvilleHousing
SET SplitOwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
--------------------------------------------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in "Sold as Vacant" field

--SELECT SoldAsVacant, REPLACE(REPLACE(SoldAsVacant, 'Y', 'Yes'), 'N', 'No')
--FROM DataCleaningProject..NashvilleHousing
--It's useful when string that we want to change does not contain same character 

SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
FROM DataCleaningProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
	CASE
		WHEN SoldAsVacant='Y' THEN 'Yes'
		WHEN SoldAsVacant='N' THEN 'No'
		ELSE SoldAsVacant
	END
FROM DataCleaningProject..NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant='Y' THEN 'Yes'
						WHEN SoldAsVacant='N' THEN 'No'
						ELSE SoldAsVacant
				   END

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS (
	SELECT *, ROW_NUMBER() OVER (
							PARTITION BY ParcelID,
							PropertyAddress,
							SalePrice,
							SaleDate,
							LegalReference
							ORDER BY UniqueID
							) row_num
	FROM DataCleaningProject..NashvilleHousing
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1

---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

SELECT *
FROM DataCleaningProject..NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict;

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate;

-----------------------------------------------------------------------------------------------
