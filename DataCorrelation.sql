--cleaning data in SQL queries

select SaleDate
From portfolioProject.dbo.HousingData




---------------------------------------------------------------------

--Standardize date format
select SaleDateConverted, CONVERT(Date, SaleDate)
From portfolioProject.dbo.HousingData

Update HousingData 
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE HousingData
Add SaleDateConverted Date;

Update HousingData 
SET SaleDateConverted  = CONVERT(Date, SaleDate)

-------------------------------------------------------------------

--populate property address data
select PropertyAddress
From portfolioProject.dbo.HousingData
--where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.HousingData a
JOIN PortfolioProject.dbo.HousingData b
   on a.ParcelID = b.ParcelID
   AND a.[UniqueID] <> b.[UniqueID ]
where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.HousingData a
JOIN PortfolioProject.dbo.HousingData b
   on a.ParcelID = b.ParcelID
   AND a.[UniqueID] <> b.[UniqueID ]
where a.PropertyAddress is null
--------------------------------------------------------------------

--Breaking out address into individual columns(Address, city state)
select PropertyAddress
From portfolioProject.dbo.HousingData
--where PropertyAddress is null
--order by ParcelID

SELECT
SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address,
 SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address

From PortfolioProject.dbo.HousingData


ALTER TABLE HousingData
Add PropertySplitAddress Nvarchar(255);

Update HousingData 
SET PropertySplitAddress  = SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)


ALTER TABLE HousingData
Add PropertySplitCity Nvarchar(255);

Update HousingData 
SET PropertySplitCity = SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

select *
From portfolioProject.dbo.HousingData


select OwnerAddress
From PortfolioProject.dbo.HousingData

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From PortfolioProject.dbo.HousingData


ALTER TABLE HousingData
Add OwnerSplitAddress Nvarchar(255);

Update HousingData 
SET OwnerSplitAddress  = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE HousingData
Add OwnerSplitCity Nvarchar(255);

Update HousingData 
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)


ALTER TABLE HousingData
Add OwnerSplitState Nvarchar(255);

Update HousingData 
SET OwnerSplitState  = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

Select *
From PortfolioProject.dbo.HousingData



--------------------------------------------------------------------

--Change Y and N to 'Yes' and 'No' in 'sold as vacant' field
Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.HousingData
Group by SoldAsVacant
order by 2  

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'YES'
       When SoldAsVacant = 'N' THEN 'NO'
	   ELSE SoldAsVacant
	   END
From PortfolioProject.dbo.HousingData

Update HousingData
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' THEN 'YES'
             When SoldAsVacant = 'N' THEN 'No'
			 ELSE SoldAsVacant
			 END

-------------------------------------------------------------------------

--Remove duplicates
WITH RowNumCTE AS(
select *,
       ROW_NUMBER() OVER (
	   PARTITION BY ParcelID,
	                        PropertyAddress,
							SalePrice,
							SaleDate,
							LegalReference
							ORDER BY
							       UniqueID
	                               ) row_num
From PortfolioProject.dbo.HousingData
)
Select *
From  RowNumCTE
Where row_num > 1
Order by PropertyAddress

Select *
From PortfolioProject.dbo.HousingData


-------------------------------------------------------------------------
--Delete Unused Columns

Select *
From PortfolioProject.dbo.HousingData

ALTER TABLE PortfolioProject.dbo.HousingData
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject.dbo.HousingData
DROP COLUMN SaleDate