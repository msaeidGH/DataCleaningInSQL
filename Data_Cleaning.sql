/*
Cleaning Data using SQL
*/

Select *
From PortfolioProject.dbo.nashvilleHousing

--------------------------------------------------------------------------------------------------------------------------------------
-- Standardize Data Format

Select saleDate,CONVERT(date,saleDate)
From PortfolioProject.dbo.nashvilleHousing


update nashvilleHousing
set saleDate = CONVERT(date,saleDate)

Alter Table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
set SaleDateConverted = Convert(Date,SaleDate)

Select saleDate, SaleDateConverted
From PortfolioProject.dbo.nashvilleHousing


--------------------------------------------------------------------------------------------------------------------------------------
-- Populate Property Address

Select *
From PortfolioProject.dbo.nashvilleHousing
--where propertyaddress is null
order by parcelID


-- if the address is NULL but there is parcelID exists multiple time,s, we can use it to populate.
select a.uniqueID, a.parcelID, a.propertyaddress,b.uniqueID, b.parcelID, b.propertyaddress, isnull(a.propertyaddress, b.propertyaddress)
from PortfolioProject.dbo.nashvilleHousing a
join PortfolioProject.dbo.nashvilleHousing b
	on a.parcelID = b.parcelID
	and a.uniqueID <> b.uniqueID
where a.propertyaddress is null --or b.propertyaddress is null


update a
set propertyaddress = isnull(a.propertyaddress, b.propertyaddress)
from PortfolioProject.dbo.nashvilleHousing a
join PortfolioProject.dbo.nashvilleHousing b
	on a.parcelID = b.parcelID
	and a.uniqueID <> b.uniqueID
where a.propertyaddress is null


--------------------------------------------------------------------------------------------------------------------------------------
-- Breaking Address into Address, City, State

Select propertyaddress
From PortfolioProject.dbo.nashvilleHousing

-- comma is the delimiter
select 
propertyaddress,
substring(propertyaddress, 1, CHARINDEX(',',propertyaddress)-1) as address
, CHARINDEX(',',propertyaddress)
, SUBSTRING(propertyaddress, CHARINDEX(',',propertyaddress)+1,Len(propertyaddress)) as new_address
From PortfolioProject.dbo.nashvilleHousing



Alter Table PortfolioProject.dbo.nashvilleHousing
Add propertySplitAddress nvarchar(255);

Update PortfolioProject.dbo.nashvilleHousing
set propertySplitAddress = substring(propertyaddress, 1, CHARINDEX(',',propertyaddress)-1)


Alter Table PortfolioProject.dbo.nashvilleHousing
Add propertySplitCity nvarchar(255);

Update PortfolioProject.dbo.nashvilleHousing
set propertySplitCity = SUBSTRING(propertyaddress, CHARINDEX(',',propertyaddress)+1,Len(propertyaddress))

select 
propertyaddress,
propertysplitaddress,
propertysplitcity
From PortfolioProject.dbo.nashvilleHousing

--------------------------------------------------------------------------------------------------------------------------------------

select owneraddress
From PortfolioProject.dbo.nashvilleHousing

select
owneraddress,
PARSENAME(replace(owneraddress,',','.'),3),
PARSENAME(replace(owneraddress,',','.'),2),
PARSENAME(replace(owneraddress,',','.'),1)
from PortfolioProject.dbo.nashvilleHousing


Alter Table PortfolioProject.dbo.nashvilleHousing
Add OwnerSplitAddress nvarchar(255);

Update PortfolioProject.dbo.nashvilleHousing
set OwnerSplitAddress = PARSENAME(replace(owneraddress,',','.'),3)



Alter Table PortfolioProject.dbo.nashvilleHousing
Add OwnerSplitCity nvarchar(255);

Update PortfolioProject.dbo.nashvilleHousing
set OwnerSplitCity = PARSENAME(replace(owneraddress,',','.'),2)



Alter Table PortfolioProject.dbo.nashvilleHousing
Add OwnerSplitState nvarchar(255);

Update PortfolioProject.dbo.nashvilleHousing
set OwnerSplitState = PARSENAME(replace(owneraddress,',','.'),1)


select owneraddress, ownersplitaddress, ownersplitcity,ownersplitstate
from PortfolioProject.dbo.nashvilleHousing

--------------------------------------------------------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in 'Sold as vacant' field

Select Distinct(soldasvacant),count(soldasvacant)
From PortfolioProject.dbo.nashvilleHousing
group by soldasvacant
order by 2


Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From PortfolioProject.dbo.NashvilleHousing


update nashvillehousing
set SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

--------------------------------------------------------------------------------------------------------------------------------------
-- Remove Duplicates and unused columns

Select *
From PortfolioProject.dbo.nashvilleHousingskate 



with RowNumCTE as (
select *,
    ROW_NUMBER() over ( partition by parcelID, propertyaddress,SalePrice, LegalReference order by uniqueID desc) row_num
from PortfolioProject.dbo.nashvilleHousing
--order by parcelID
) 

select * from RowNumCTE
where row_num >1

delete from RowNumCTE
where row_num >1

--------------------------------------------------------------------------------------------------------------------------------------
-- Delete unsed Columns

Select *
From PortfolioProject.dbo.nashvilleHousing

Alter table PortfolioProject.dbo.nashvilleHousing
drop column ownerAddress, Taxdistrict, propertyaddress,SaleDate
--------------------------------------------------------------------------------------------------------------------------------------