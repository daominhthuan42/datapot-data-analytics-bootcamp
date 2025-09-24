USE AdventureWorksDW2019
GO

-- Ex1: Từ bộ AdventureworksDW2019, bảng DimEmployee,
-- Lấy ra EmployeeKey, FirstName, LastName, BaseRate, VacationHours, SickLeaveHours
-- Sau đó lấy ra thêm các cột như sau:
-- a. Cột FullName  được lấy ra từ: FirstName + '  ' + LastName 
-- b. Cột VacationLeavePay được lấy ra từ: BaseRate * VacationHours 
-- c. Cột SickLeavePay được lấy ra từ: BaseRate * SickLeaveHours  
-- d.  Cột TotalLeavePay được lấy ra từ VacationLeavePay + SickLeavePay 

SELECT 
    DE.EmployeeKey,
    DE.FirstName,
    DE.BaseRate,
    DE.VacationHours,
    DE.SickLeaveHours,
    -- a. Cột FullName  được lấy ra từ: FirstName + '  ' + LastName 
    DE.FirstName + ' ' + DE.LastName AS FullName,
    -- b. Cột VacationLeavePay được lấy ra từ: BaseRate * VacationHours
    DE. BaseRate * DE.VacationHours AS VacationLeavePay,
    -- c. Cột SickLeavePay được lấy ra từ: BaseRate * SickLeaveHours
    DE. BaseRate * DE.SickLeaveHours AS SickLeavePay,
    -- d.  Cột TotalLeavePay được lấy ra từ VacationLeavePay + SickLeavePay
    (DE. BaseRate * DE.VacationHours) + (DE. BaseRate * DE.SickLeaveHours) AS TotalLeavePay
FROM [dbo].[DimEmployee] AS DE;

-- Ex2: Từ bộ AdventureworksDW2019, bảng FactInternetSales,
-- Lấy ra SalesOrderNumber, ProductKey, OrderDate
-- Sau đó lấy ra thêm các cột như sau:
-- a. Cột TotalRevenue được lấy ra từ: OrderQuantity * UnitPrice
-- B. Cột TotalCost được lấy ra từ: ProductStandardCost + DiscountAmount
-- c. Cột Profit được lấy ra từ: TotalRevenue - TotalCost
-- d. Cột Profit Margin được lấy ra từ: (TotalRevenue - TotalCost)/TotalRevenue * 100

SELECT
    FI.SalesOrderNumber,
    FI.ProductKey,
    FI.OrderDate,
    -- a. Cột TotalRevenue được lấy ra từ: OrderQuantity * UnitPrice
    (FI.OrderQuantity * FI.UnitPrice) AS TotalRevenue,
    -- B. Cột TotalCost được lấy ra từ: ProductStandardCost + DiscountAmount
    (FI.ProductStandardCost + FI.DiscountAmount) AS TotalCost,
    -- c. Cột Profit được lấy ra từ: TotalRevenue - TotalCost
    (FI.OrderQuantity * FI.UnitPrice) - (FI.ProductStandardCost + FI.DiscountAmount) AS Profit,
    -- d. Cột Profit Margin được lấy ra từ: (TotalRevenue - TotalCost)/TotalRevenue * 100
    ((FI.OrderQuantity * FI.UnitPrice) - (FI.ProductStandardCost + FI.DiscountAmount)) / (FI.OrderQuantity * FI.UnitPrice) * 100 AS [Profit Margin]
FROM [dbo].[FactInternetSales] AS FI;

-- Ex3: Từ bộ AdventureworksDW2019, bảng FactProductInventory,
-- Lấy ra các cột như sau:
-- MovementDate
-- , ProductKey Và
-- A. Cột NoProductEOD lấy ra từ UnitsBalance + UnitsIn - UnitsOut
-- b. Cột TotalCost lấy ra từ: NoProductEOD * UnitCost 

SELECT
    FPI.MovementDate,
    FPI.ProductKey,
    -- A. Cột NoProductEOD lấy ra từ UnitsBalance + UnitsIn - UnitsOut
    (FPI.UnitsBalance + FPI.UnitsIn - FPI.UnitsOut) AS NoProductEOD,
    -- b. Cột TotalCost lấy ra từ: NoProductEOD * UnitCost
    (FPI.UnitsBalance + FPI.UnitsIn - FPI.UnitsOut) * FPI.UnitCost AS TotalCost
FROM [dbo].[FactProductInventory] AS FPI; 

-- Ex4: Từ bộ AdventureworksDW2019, bảng DimGeography, lấy ra EnglishCountryRegionName,
-- City, StateProvinceName. Loại bỏ các dòng trùng lặp và sắp xếp bảng kết quả theo thứ tự
-- tăng dần của EnglishCountryRegionName và những dòng có cùng giá trị Country thì sắp xếp thêm theo thứ tự giảm dần của City

SELECT DISTINCT
    DG.EnglishCountryRegionName,
    DG.City,
    DG.StateProvinceName
FROM [dbo].[DimGeography] AS DG
ORDER BY DG.EnglishCountryRegionName ASC, DG.City DESC; 

-- Ex5: Từ bộ AdventureworksDW2019, bảng DimProduct,
-- lấy ra EnglishProductName của top 10% các sản phẩm có mức ListPrice cao nhất

SELECT
    TOP 10 PERCENT DP.EnglishProductName,
    DP.ListPrice
FROM [dbo].[DimProduct] AS DP
ORDER BY DP.ListPrice DESC;
