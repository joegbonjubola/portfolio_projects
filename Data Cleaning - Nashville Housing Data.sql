SELECT *
FROM `Nashville Housing`.nashville_housing;

SELECT * 
FROM `Nashville Housing`.nashville_housing
WHERE PropertyAddress IS NULL;

-- Where PropertyAddress is NULL 
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, IFNULL(a.PropertyAddress,b.PropertyAddress) 
FROM nashville_housing a
JOIN nashville_housing b 
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID != b.UniqueID
WHERE a.PropertyAddress IS NULL;

UPDATE nashville_housing a
JOIN nashville_housing b 
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID != b.UniqueID
SET a.PropertyAddress = IFNULL(a.PropertyAddress,b.PropertyAddress)
WHERE a.PropertyAddress IS NULL;

-- Split Column PropertyAddress into Address and City

SELECT PropertyAddress  
FROM nashville_housing;

SELECT 
SUBSTRING(PropertyAddress, 1, POSITION(',' IN PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress, POSITION(',' IN PropertyAddress) +1, LENGTH(PropertyAddress)) AS City
FROM nashville_housing;

ALTER TABLE nashville_housing 
ADD PropertySplitAddress VARCHAR(50);

UPDATE nashville_housing 
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, POSITION(',' IN PropertyAddress) -1);

ALTER TABLE nashville_housing 
ADD PropertySplitCity VARCHAR(50);

UPDATE nashville_housing 
SET PropertySplitCity = SUBSTRING(PropertyAddress, POSITION(',' IN PropertyAddress) +1, LENGTH(PropertyAddress));

SELECT *
FROM nashville_housing;

-- Split Column OwnerAddress into Address and City

SELECT OwnerAddress  
FROM nashville_housing;

SELECT
OwnerAddress,
SUBSTRING_INDEX(OwnerAddress, ',', 1),
SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1),
SUBSTRING_INDEX(OwnerAddress, ',', -1)
FROM nashville_housing;

ALTER TABLE nashville_housing 
ADD OwnerSplitAddress VARCHAR(50);

UPDATE nashville_housing 
SET OwnerSplitAddress = SUBSTRING_INDEX(OwnerAddress, ',', 1);

ALTER TABLE nashville_housing 
ADD OwnerSplitCity VARCHAR(50);

UPDATE nashville_housing 
SET OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1);

ALTER TABLE nashville_housing 
ADD OwnerSplitState VARCHAR(50);

UPDATE nashville_housing 
SET OwnerSplitState = SUBSTRING_INDEX(OwnerAddress, ',', -1);

SELECT *
FROM nashville_housing;

-- Replace Y & N with Yes and No in the SoldAsVacant column

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant) 
FROM nashville_housing
GROUP BY SoldAsVacant 
ORDER BY COUNT(SoldAsVacant);

SELECT DISTINCT(SoldAsVacant),
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant 
		 END
FROM nashville_housing;

UPDATE nashville_housing 
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 		   WHEN SoldAsVacant = 'N' THEN 'No'
		   		   ELSE SoldAsVacant 
		 		   END;

		 		  
-- Delete unused Columns

SELECT *
FROM nashville_housing;

ALTER TABLE nashville_housing
DROP COLUMN PropertyAddress, 
DROP COLUMN OwnerAddress,
DROP COLUMN TaxDistrict;


