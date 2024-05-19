--Cleaning the data
SELECT *
  FROM [PortfolioProjectSQL].[dbo].[NashvilleHousing]


--Standardize Date Format
SELECT SaleDate, SaleDateConverted, CONVERT(date,SaleDate)
  FROM [PortfolioProjectSQL].[dbo].[NashvilleHousing]


update [PortfolioProjectSQL].[dbo].[NashvilleHousing] 
SET SaleDate = CONVERT(date,saleDate)

ALTER TABLE [PortfolioProjectSQL].[dbo].[NashvilleHousing] 
Add SaleDateConverted Date;

Update [PortfolioProjectSQL].[dbo].[NashvilleHousing] 
SET SaleDateConverted = CONVERT(date,saleDate)


--Populate Property Address data
SELECT *
  FROM [PortfolioProjectSQL].[dbo].[NashvilleHousing]
  --where PropertyAddress is NULL
  order by ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.parcelid, b.propertyaddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
  FROM [PortfolioProjectSQL].[dbo].[NashvilleHousing] a
  JOIN [PortfolioProjectSQL].[dbo].[NashvilleHousing] b
  ON a.ParcelID = b.ParcelID
  AND a.uniqueID <> b.uniqueID
  where a.PropertyAddress is null

update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [PortfolioProjectSQL].[dbo].[NashvilleHousing] a
  JOIN [PortfolioProjectSQL].[dbo].[NashvilleHousing] b
  ON a.ParcelID = b.ParcelID
  AND a.uniqueID <> b.uniqueID
  where a.PropertyAddress is null



--Breaking down Address into Individual Columns (Address, City, State)
SELECT PropertyAddress
  FROM [PortfolioProjectSQL].[dbo].[NashvilleHousing]
  --where PropertyAddress is NULL
  --order by ParcelID

select
SUBSTRING(propertyAddress,1,CHARINDEX(',',propertyAddress)-1) AS Address,
SUBSTRING(propertyAddress,CHARINDEX(',',propertyAddress)+1,LEN(propertyAddress)) AS City
  FROM [PortfolioProjectSQL].[dbo].[NashvilleHousing]

ALTER TABLE [PortfolioProjectSQL].[dbo].[NashvilleHousing] 
Add PropertySplitAddress Nvarchar(255);

Update [PortfolioProjectSQL].[dbo].[NashvilleHousing] 
SET PropertySplitAddress = SUBSTRING(propertyAddress,1,CHARINDEX(',',propertyAddress)-1) 

ALTER TABLE [PortfolioProjectSQL].[dbo].[NashvilleHousing] 
Add PropertySplitCity Nvarchar(255);

Update [PortfolioProjectSQL].[dbo].[NashvilleHousing] 
SET PropertySplitCity = SUBSTRING(propertyAddress,CHARINDEX(',',propertyAddress)+1,LEN(propertyAddress))


select *
FROM [PortfolioProjectSQL].[dbo].[NashvilleHousing]


select OwnerAddress
FROM [PortfolioProjectSQL].[dbo].[NashvilleHousing]


select 
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM [PortfolioProjectSQL].[dbo].[NashvilleHousing]

ALTER TABLE [PortfolioProjectSQL].[dbo].[NashvilleHousing] 
Add OwnerSplitAddress Nvarchar(255);

Update [PortfolioProjectSQL].[dbo].[NashvilleHousing] 
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE [PortfolioProjectSQL].[dbo].[NashvilleHousing] 
Add OwnerSplitCity Nvarchar(255);

Update [PortfolioProjectSQL].[dbo].[NashvilleHousing] 
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE [PortfolioProjectSQL].[dbo].[NashvilleHousing] 
Add OwnerSplitState Nvarchar(255);

Update [PortfolioProjectSQL].[dbo].[NashvilleHousing] 
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

select *
FROM [PortfolioProjectSQL].[dbo].[NashvilleHousing]




--Change Y and N to Yes and No in "Sold as Vacant" field
select DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
FROM [PortfolioProjectSQL].[dbo].[NashvilleHousing] 
Group by SoldAsVacant
order by 2

Select SoldAsVacant,
CASE When SoldAsVacant = 'Y' Then 'Yes'
	 When SoldAsVacant = 'N' Then 'No'
ELSE SoldAsVacant
END
FROM [PortfolioProjectSQL].[dbo].[NashvilleHousing] 

update [PortfolioProjectSQL].[dbo].[NashvilleHousing] 
set SoldAsVacant = CASE When SoldAsVacant = 'Y' Then 'Yes'
	 When SoldAsVacant = 'N' Then 'No'
ELSE SoldAsVacant
END




--Remove Duplicates
WITH RowNumCTE AS (
select * , 
ROW_NUMBER() OVER(
PARTITION BY parcelID,
	PropertyAddress,
	SalePrice,
	SaleDate,
	LegalReference
	ORDER BY 
		UniqueID) row_num
FROM [PortfolioProjectSQL].[dbo].[NashvilleHousing] 
--order by ParcelID
)
--Select * 
DELETE 
From RowNumCTE
where row_num > 1
--order by PropertyAddress



--Delete Unused Columns
Select *
FROM [PortfolioProjectSQL].[dbo].[NashvilleHousing] 

ALTER TABLE [PortfolioProjectSQL].[dbo].[NashvilleHousing] 
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE [PortfolioProjectSQL].[dbo].[NashvilleHousing] 
DROP COLUMN SaleDate