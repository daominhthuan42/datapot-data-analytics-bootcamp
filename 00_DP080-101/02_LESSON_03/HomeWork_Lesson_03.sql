/*
Ex1 (CASE WHEN)
From DimProduct, retrieve ProductKey, ListPrice and generate a new column named
ProductSegmentation based on the following rules: if ListPrice is greater than 2000 then
assign value “Premium”, ListPrice from 1000 to 2000 then assign value “Normal”, ListPrice is
lower than 1000 then assign value “Cheap”, in case ListPrice is NULL, assign value “Undefined”
*/
USE [AdventureWorksDW2019]
GO

SELECT
	DP.ProductKey
	, DP.ListPrice
	, CASE
		WHEN DP.ListPrice > 2000 THEN 'Premium'
		WHEN DP.ListPrice BETWEEN 1000 AND 2000 THEN 'Normal'
		WHEN DP.ListPrice < 1000 THEN 'Cheap'
		ELSE 'Undefined'
	  END AS ProductSegmentation
FROM 
	[dbo].[DimProduct] AS DP


--Ex2 (JOIN)
--From DimCustomer, DimGeography
--Retrieve CustomerKey, CustomerFullName (based on FirstName, MiddleName, LastName)
--and their EnglishCountryRegionName, StateProvinceName

SELECT
	CU.CustomerKey
	, CONCAT_WS(' ', CU.FirstName, CU.MiddleName, CU.LastName)
	, GEO.EnglishCountryRegionName
	, GEO.StateProvinceName
FROM 
	[dbo].[DimCustomer] AS CU
	JOIN [dbo].[DimGeography] AS GEO ON GEO.GeographyKey = CU.GeographyKey

/*Ex 1: Từ bảng dbo.FactInternetSales và dbo.DimSalesTerritory, lấy ra thông tin SalesOrderNumber, SalesOrderLineNumber, ProductKey, SalesTerritoryCountry  của các bản ghi có SalesAmount trên 1000 */
SELECT
	FIS.SalesOrderNumber
	, FIS.SalesOrderLineNumber
	, FIS.ProductKey
	, DST.SalesTerritoryCountry
FROM 
	[dbo].[FactInternetSales] AS FIS
	INNER JOIN [dbo].[DimSalesTerritory] AS DST ON DST.SalesTerritoryKey = FIS.SalesTerritoryKey
WHERE
	FIS.SalesAmount > 1000;

/*Ex 2: Từ bảng dbo.DimProduct và dbo.DimProductSubcategory. Lấy ra ProductKey, EnglishProductName và Color của các sản phẩm thoả mãn EnglishProductSubCategoryName 
chứa chữ 'Bikes' và ListPrice có phần nguyên là 3399 */
SELECT
	DP.ProductKey
	, DP.EnglishProductName
	, DP.Color
	, DP.ListPrice
	, DPS.EnglishProductSubcategoryName
FROM 
	[dbo].[DimProduct] AS DP
	JOIN [dbo].[DimProductSubcategory] AS DPS ON DPS.ProductSubcategoryKey = DP.ProductSubcategoryKey
WHERE
	DPS.EnglishProductSubcategoryName LIKE '%Bikes%'
	AND DP.ListPrice >= 3399 AND DP.ListPrice < 3400;
	-- AND CAST(DP.ListPrice AS VARCHAR(10)) LIKE '3399%'

SELECT 
    CAST(3399.99 AS MONEY) AS Original, -- 3399.99
    CAST(CAST(3399.99 AS MONEY) AS INT) AS AsInt, -- 3400
    FLOOR(CAST(3399.99 AS MONEY)) AS AsFloor, -- OK
    CAST(3399.99 AS INT) AS DirectCast -- cũng trả về 3400

/* Ex 3: Từ bảng dbo.DimPromotion, dbo.FactInternetSales, lấy ra ProductKey, SalesOrderNumber, SalesAmount từ các bản ghi thoả mãn DiscountPct >= 20% */
SELECT
	FIS.ProductKey
	, FIS.SalesOrderNumber
	, FIS.SalesAmount
	, DP.DiscountPct
FROM 
	[dbo].[DimPromotion] AS DP
	JOIN [dbo].[FactInternetSales] AS FIS ON FIS.PromotionKey = DP.PromotionKey
WHERE
	DP.DiscountPct >= 0.2;

/* Ex 4: Từ bảng dbo.DimCustomer, dbo.DimGeography, lấy ra cột Phone, FullName (kết hợp FirstName, MiddleName, LastName kèm khoảng cách ở giữa)
và City của các khách hàng có YearlyInCome > 150000 và CommuteDistance nhỏ hơn 5 Miles*/
SELECT
	DC.Phone
	, CONCAT_WS(' ', DC.FirstName, DC.MiddleName, DC.LastName)
	, DG.City
	, DC.CommuteDistance
FROM
	[dbo].[DimCustomer] AS DC
	JOIN [dbo].[DimGeography] AS DG ON DG.GeographyKey = DC.GeographyKey
WHERE
	DC.YearlyIncome > 150000
	AND (
			DC.CommuteDistance LIKE '[0-4]-%'
			--OR DC.CommuteDistance LIKE '1-%'
			--OR DC.CommuteDistance LIKE '2-%'
			--OR DC.CommuteDistance LIKE '3-%'
			--OR DC.CommuteDistance LIKE '4-%'
        );

/* Ex 5: Từ bảng dbo.DimCustomer, lấy ra CustomerKey và thực hiện các yêu cầu sau: 
a. Tạo cột mới đặt tên là YearlyInComeRange từ các điều kiện sau:
- Nếu YearlyIncome từ 0 đến 50000 thì gán giá trị "Low Income"
- Nếu YearlyIncome từ 50001 đến 90000 thì gán giá trị "Middle Income"
- Nếu YearlyIncome từ  90001 trở lên thì gán giá trị "High Income"
b. Tạo cột mới đặt tên là AgeRange từ các điều kiện sau:
- Nếu tuổi của Khách hàng tính đến 31/12/2019 đến 39 tuổi thì gán giá trị "Young Adults"
- Nếu tuổi của Khách hàng tính đến 31/12/2019 từ 40 đến 59 tuổi thì gán giá trị "Middle-Aged Adults"
- Nếu tuổi của Khách hàng tính đến 31/12/2019 lớn hơn 60 tuổi thì gán giá trị "Old Adults" 
 */  

SELECT
	DC.CustomerKey
	, CASE
		WHEN DC.YearlyIncome BETWEEN 0 AND 5000 THEN 'Low Income'
		WHEN DC.YearlyIncome BETWEEN 5001 AND 90000 THEN 'Middle Income'
		ELSE 'High Income'
	  END AS YearlyInComeRange
	, CASE
		WHEN DATEDIFF(YEAR, DC.BirthDate, CAST('2019-12-31' AS DATE)) <= 39 THEN 'Young Adults'
		WHEN DATEDIFF(YEAR, DC.BirthDate, CAST('2019-12-31' AS DATE)) BETWEEN 40 AND 59 THEN 'Middle-Aged Adults'
		ELSE 'Old Adults'
	  END AS AgeRange
FROM 
	[dbo].[DimCustomer] AS DC;

/* Ex 6: Từ bảng FactInternetSales, FactResellerSale và DimProduct. Tìm tất cả SalesOrderNumber có EnglishProductName chứa từ 'Road' và có màu vàng (Yellow) */
SELECT
	FIS.SalesOrderNumber
FROM
	[dbo].[FactInternetSales] AS FIS
	JOIN [dbo].[DimProduct] AS DP ON DP.ProductKey = FIS.ProductKey
WHERE
	DP.EnglishProductName LIKE '%Road%'
	AND DP.Color = 'Yellow'
UNION ALL
SELECT
	FRS.SalesOrderNumber
FROM 
	[dbo].[FactResellerSales] AS FRS;