--Cleaning Data in SQL Queries
Select *
From [SQLPortfolio  Project].dbo.NashvilleHousing


-- Standardize Date Format


Select saleDateConverted, CONVERT(Date,SaleDate)
From [SQLPortfolio  Project].dbo.NashvilleHousing

Update [SQLPortfolio  Project].dbo.NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

-- If it doesn't Update properly

ALTER TABLE [SQLPortfolio  Project].dbo.NashvilleHousing
Add SaleDateConverted Date;

Update [SQLPortfolio  Project].dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

-- Populate Property Address data

Select *
From [SQLPortfolio  Project].dbo.NashvilleHousing
Where PropertyAddress is null
order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From [SQLPortfolio  Project].dbo.NashvilleHousing a
JOIN[SQLPortfolio  Project].dbo.NashvilleHousing  b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From[SQLPortfolio  Project].dbo.NashvilleHousing  a
JOIN [SQLPortfolio  Project].dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-- Breaking out Address into Individual Columns (Address, City, State)


Select PropertyAddress
From [SQLPortfolio  Project].dbo.NashvilleHousing
--Where PropertyAddress is null
--order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address

From [SQLPortfolio  Project].dbo.NashvilleHousing


ALTER TABLE [SQLPortfolio  Project].dbo.NashvilleHousing
Add Address_Line1 Nvarchar(255);

Update [SQLPortfolio  Project].dbo.NashvilleHousing
SET Address_Line1 = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE [SQLPortfolio  Project].dbo.NashvilleHousing
Add Address_City Nvarchar(255);

Update [SQLPortfolio  Project].dbo.NashvilleHousing
SET Address_City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))



Select OwnerAddress
From [SQLPortfolio  Project].dbo.NashvilleHousing


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From [SQLPortfolio  Project].dbo.NashvilleHousing

ALTER TABLE [SQLPortfolio  Project].dbo.NashvilleHousing
Add Owner_Address_Line Nvarchar(255);

Update [SQLPortfolio  Project].dbo.NashvilleHousing
SET Owner_Address_Line = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE [SQLPortfolio  Project].dbo.NashvilleHousing
Add Owner_Address_Town Nvarchar(255);

Update [SQLPortfolio  Project].dbo.NashvilleHousing
SET OwnerAddress_Town = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)


ALTER TABLE [SQLPortfolio  Project].dbo.NashvilleHousing
Add Owner_Address_City Nvarchar(255);

Update [SQLPortfolio  Project].dbo.NashvilleHousing
SET OwnerAddress_City = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)


-- Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From [SQLPortfolio  Project].dbo.NashvilleHousing
Group by SoldAsVacant
order by 2


Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From [SQLPortfolio  Project].dbo.NashvilleHousing


Update [SQLPortfolio  Project].dbo.NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

--Remove Duplicate 


WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
FROM [SQLPortfolio  Project].dbo.NashvilleHousing
--order by ParcelID
)
select *
From RowNumCTE
where row_num > 1
order by PropertyAddress

Delete *
From RowNumCTE
where row_num > 1

--Delete Unused Columns


Select *
From [SQLPortfolio  Project].dbo.NashvilleHousing


ALTER TABLE [SQLPortfolio  Project].dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate


