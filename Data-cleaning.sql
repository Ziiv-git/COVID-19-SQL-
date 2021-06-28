-- Cleaning data in housing data

SELECT *
FROM Housing



-- Standardizing date format

SELECT SaleDate, CONVERT(Date, SaleDate)
FROM Housing

UPDATE Housing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE Housing
ADD SaleDateConverted Date

Update Housing
SET SaleDateConverted = Convert(Date, SaleDate)

SELECT SaleDateConverted, CONVERT(Date, SaleDate)
FROM Housing




---- Populating property address data with parcelid as both the data are same


SELECT PropertyAddress
FROM Housing

SELECT PropertyAddress, ParcelID
FROM Housing
WHERE PropertyAddress is null

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM Housing a
JOIN Housing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Housing a
JOIN Housing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a 
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Housing a
JOIN Housing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null





---Breaking out address into individual columns (address, city, state)

SELECT PropertyAddress
FROM Housing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City
FROM Housing

ALTER TABLE Housing
ADD Address nvarchar(255)

Update Housing
SET Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE Housing
ADD City nvarchar(255)

Update Housing
SET City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

SELECT *
FROM Housing



------Breaking down OwnerAddress

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM Housing

ALTER TABLE Housing
ADD OwnerAdd nvarchar(255)

Update Housing
SET OwnerAdd = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE Housing
ADD OwnerCity nvarchar(255)

Update Housing
SET OwnerCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

ALTER TABLE Housing
ADD OwnerState nvarchar(255)

Update Housing
SET OwnerState = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

SELECT *
FROM Housing



------Change Y and N to yes and no in sold as vacant field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM Housing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' Then 'No'
	ELSE SoldAsVacant
	END
FROM Housing

UPDATE Housing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' Then 'No'
	ELSE SoldAsVacant
	END



----Removing duplicates

WITH Row_num_cte as(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, PropertyAddress, SaleDate, LegalReference
		ORDER BY UniqueID) row_num
FROM Housing
--ORDER BY ParcelID
)
SELECT * 
FROM Row_num_cte
WHERE row_num > 1
ORDER BY PropertyAddress



WITH Row_num_cte as(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, PropertyAddress, SaleDate, LegalReference
		ORDER BY UniqueID) row_num
FROM Housing
--ORDER BY ParcelID
)
DELETE
FROM Row_num_cte
WHERE row_num > 1



------Delete unused columns

ALTER TABLE Housing
DROP COLUMN OwnerAddress, TaxDistrict, PropertAddress

SELECT *
FROM Housing
