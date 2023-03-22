/*

Cleaning Data in SQL Queries

*/

SELECT * FROM NashvilleData 
--where PropertyAddress is null


-----------------------------------------------------------------------------------------------------------------------

--Standardize Date Format

SELECT SaleDate, CONVERT(date,SaleDate),SaleDateConverted
FROM NashvilleData 

ALTER TABLE NashvilleData
ADD SaleDateConverted date

UPDATE NashvilleData
SET SaleDateConverted = CONVERT(date,SaleDate)





-----------------------------------------------------------------------------------------------------------------------

--Populate Property Address Data/ Fill the null values

SELECT a.[UniqueID ],a.ParcelID,a.PropertyAddress,b.[UniqueID ],b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleData a
JOIN NashvilleData b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleData a
JOIN NashvilleData b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null




-----------------------------------------------------------------------------------------------------------------------

--Breaking out Address into Individual Columns (Address, city, State)

SELECT 
PropertyAddress, 
SUBSTRING( PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1) AS  PropertySplitAddress,
SUBSTRING( PropertyAddress,CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress)) AS  PropertySplitCity
FROM NashvilleData 


ALTER TABLE NashvilleData 
ADD  PropertySplitAddress nvarchar(255)

ALTER TABLE NashvilleData 
ADD  PropertySplitCity nvarchar(255)

UPDATE NashvilleData
SET PropertySplitAddress = SUBSTRING( PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1)

UPDATE NashvilleData
SET PropertySplitCity = SUBSTRING( PropertyAddress,CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress))




--	alternative 1 way for splitting on ownersaddress
/*
ALTER TABLE NashvilleData 
add ownerSplitaddress nvarchar(255)
ALTER TABLE NashvilleData 
add ownerSplitcity nvarchar(255)
--ALTER TABLE NashvilleData 
--add ownerSplitcity nvarchar(255)
ALTER TABLE NashvilleData 
add ownerSplitstate nvarchar(255);


with split as (
SELECT OwnerAddress, SUBSTRING(OwnerAddress,1,CHARINDEX(',',OwnerAddress)-1) as Address1,
SUBSTRING(OwnerAddress,CHARINDEX(',',OwnerAddress)+1,LEN(OwnerAddress)) as Address2
--SUBSTRING(Address2,1,4)
FROM NashvilleData 
)
update NashvilleData
set ownerSplitaddress = SUBSTRING(OwnerAddress,1,CHARINDEX(',',OwnerAddress)-1),
	ownerSplitcity = SUBSTRING(OwnerAddress,CHARINDEX(',',OwnerAddress)+1,LEN(OwnerAddress))

--run the update below separately
update NashvilleData
set --ownerSplitstate =SUBSTRING(ownerSplitcity,CHARINDEX(',',ownerSplitcity)+1,LEN(ownerSplitcity)),
	ownerSplitcity2 =SUBSTRING(ownerSplitcity,1,CHARINDEX(',',ownerSplitcity)-1) from NashvilleData

ALTER TABLE NashvilleData 
drop column ownerSplitcity */



--	alternative 2 way for splitting on ownersaddress
ALTER TABLE NashvilleData 
add ownerSplitaddress nvarchar(255)
ALTER TABLE NashvilleData 
add ownerSplitcity nvarchar(255)
ALTER TABLE NashvilleData 
add ownerSplitstate nvarchar(255)

SELECT ownerAddress,
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM NashvilleData

UPDATE NashvilleData
SET ownerSplitaddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3),
	ownerSplitcity = PARSENAME(REPLACE(OwnerAddress,',','.'),2),
	ownerSplitstate = PARSENAME(REPLACE(OwnerAddress,',','.'),1)




-----------------------------------------------------------------------------------------------------------

--Changing Y and N to Yes and No at 'Sold as Vacant' Field

SELECT 
CASE
	WHEN SoldAsVacant = 'N' THEN 'No'
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	ELSE SoldAsVacant
	END
FROM NashvilleData

UPDATE NashvilleData
SET SoldAsVacant = 
CASE
	WHEN SoldAsVacant = 'N' THEN 'No'
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	ELSE SoldAsVacant
	END
FROM NashvilleData



-----------------------------------------------------------------------------------------------------------

--Removing Duplicates

with dup as 
(
SELECT *,
ROW_NUMBER() OVER 
(PARTITION BY 
			ParcelID,
			SaleDate,
			PropertyAddress,
			LegalReference,
			SalePrice
            ORDER BY uniqueid) AS Duplicates
FROM NashvilleData 
)
DELETE
--Select * 
FROM dup
WHERE Duplicates > 1


-----------------------------------------------------------------------------------------------------------

--Delete Unused Columns
ALTER TABLE NashvilleData
DROP COLUMN SaleDate,OwnerAddress,PropertyAddress,TaxDistrict

--SELECT * FROM NashvilleData 
