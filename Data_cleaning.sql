CREATE DATABASE Data_cleaning;
USE Data_cleaning;
SELECT * FROM nashville_housing;

-- Standardize Date Format

SET SQL_SAFE_UPDATES = 0;

UPDATE nashville_housing
SET SaleDate = DATE_FORMAT(STR_TO_DATE(SaleDate, '%M %d, %Y'), '%Y-%m-%d');

-- Breaking out the Propertyaddress into the individual column (Address,city)

ALTER TABLE nashville_housing
ADD COLUMN city VARCHAR(255); 

UPDATE nashville_housing
SET city = SUBSTRING_INDEX(PropertyAddress, ',', -1);

UPDATE nashville_housing
SET PropertyAddress = SUBSTRING_INDEX(PropertyAddress, ',', 1);

ALTER TABLE nashville_housing
MODIFY COLUMN city VARCHAR(255) AFTER PropertyAddress;

-- Breaking out the Owneraddress into the individual column (Address,city)

ALTER TABLE nashville_housing
ADD COLUMN Owner_city VARCHAR(255); 

UPDATE nashville_housing
SET Owner_city = SUBSTRING_INDEX(OwnerAddress, ',', -1);

UPDATE nashville_housing
SET OwnerAddress = SUBSTRING_INDEX(OwnerAddress, ',', 1);

ALTER TABLE nashville_housing
MODIFY COLUMN Owner_city VARCHAR(255) AFTER OwnerAddress;


-- Change Y and N to YES and NO in "Sold As Vacant" field

SELECT DISTINCT SoldAsVacant , count(SoldAsVacant)
FROM nashville_housing
group by SoldAsVacant;

UPDATE nashville_housing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
                   WHEN SoldAsVacant = 'N' THEN 'NO'
                   ELSE SoldAsVacant 
                   END;
                   
-- Remove Duplicates

DELETE n1
FROM nashville_housing n1
JOIN (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY ParcelID,
                         PropertyAddress,
                         SalePrice,
                         SaleDate,
                         LegalReference
            ORDER BY UniqueID
        ) AS row_num
    FROM nashville_housing
) n2 ON n1.UniqueID = n2.UniqueID
WHERE n2.row_num > 1;

-- Delete Unused Columns

ALTER TABLE nashville_housing
DROP COLUMN TaxDistrict;




