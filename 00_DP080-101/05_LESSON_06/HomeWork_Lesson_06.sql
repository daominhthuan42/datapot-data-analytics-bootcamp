USE [AdventureWorksDW2019]
GO

-- Câu 1: Dựa và bảng FactInternetSales
-- Tính tổng số lượng sản phẩm (OrderQuantity) đã được bán cho mỗi khách hàng (CustomerKey). Hiển thị kết quả theo thứ tự giảm dần của tổng số lượng. 
SELECT
	FIS.CustomerKey
	, COUNT(FIS.OrderQuantity) AS TotalQuantity
FROM
	[dbo].[FactInternetSales] FIS
GROUP BY
	FIS.CustomerKey
ORDER BY
	TotalQuantity DESC; 

-- Câu 2: Dựa vào bảng FactInternetSales và DimProduct
-- Thống kê tổng số lượng sản phẩm được bán (TotalOrderQuantity) cho mỗi sản phẩm (EnglishProductName). Hiển thị kết quả theo thứ tự giảm dần của TotalOrderQuantity. 
SELECT
	P.EnglishProductName
	, COUNT(FIS.OrderQuantity) AS TotalQuantity
FROM
	[dbo].[FactInternetSales] FIS
	JOIN [dbo].[DimProduct] P ON P.ProductKey = FIS.ProductKey
GROUP BY
	P.EnglishProductName
ORDER BY
	TotalQuantity DESC; 

-- Câu 3: Dựa vào bảng FactInternetSales, DimCustomer, tạo ra trường FullName từ (FirstName, MiddleName, LastName và sử dụng dấu cách ' ' để ghép nối)
-- và thống kê số lượng đơn đặt hàng (OrderCount) mà họ đã thực hiện trong năm 2014. Và chỉ lấy những khách hàng có ít nhất 2 đơn đặt hàng.  
SELECT
	CONCAT_WS(' ', C.FirstName, C.MiddleName, C.LastName) AS FullName
	, COUNT(FIS.OrderQuantity) AS TotalQuantity
FROM
	[dbo].[FactInternetSales] FIS
	JOIN [dbo].[DimCustomer] C ON C.CustomerKey = FIS.CustomerKey
WHERE
	YEAR(FIS.OrderDate) = 2014
GROUP BY
	CONCAT_WS(' ', C.FirstName, C.MiddleName, C.LastName)
HAVING
	COUNT(FIS.OrderQuantity) >= 2
ORDER BY
	TotalQuantity DESC; 

-- Câu 4:
-- Từ bảng DimProduct, DimProductSubCategory, DimProductCategory và FactInternetSales
-- Viết truy vấn lấy ra EnglishProductCategoryName, TotalAmount (tính theo SaleAmount) của 2 danh mục có doanh thu cao nhất trong năm 2014 
SELECT TOP 2
	DPC.EnglishProductCategoryName
	, SUM(FIS.SalesAmount) AS TotalAmount
FROM
	[dbo].[DimProduct] P
	JOIN [dbo].[DimProductSubcategory] DPS ON DPS.ProductSubcategoryKey = P.ProductSubcategoryKey
	JOIN [dbo].[DimProductCategory] DPC ON DPC.ProductCategoryKey = DPS.ProductCategoryKey
	JOIN [dbo].[FactInternetSales] FIS ON FIS.ProductKey = P.ProductKey
WHERE
	YEAR(FIS.OrderDate) = 2014
GROUP BY
	DPC.EnglishProductCategoryName
ORDER BY
	TotalAmount DESC; 

-- Câu 5: Từ bảng FactInternetSale và bảng FactResellerSale,
-- thực hiện từ 2 nguồn bán là Internet và Reseller đưa ra tất cả tất cả các SaleOrderNumber và doanh thu của mỗi SaleOrderNumber
SELECT
	CombinedSale.SalesOrderNumber
	, SUM(CombinedSale.SalesAmount) AS TotalAmount
	, CombinedSale.Source
FROM
(
	SELECT FIS.SalesOrderNumber, FIS.SalesAmount, 'Internet' AS Source
	FROM [dbo].[FactInternetSales] FIS
	UNION ALL
	SELECT FRS.SalesOrderNumber, FRS.SalesAmount, 'Reseller' AS Source
	FROM [dbo].[FactResellerSales] FRS
) AS CombinedSale
GROUP BY
	CombinedSale.SalesOrderNumber, CombinedSale.Source
ORDER BY
	TotalAmount DESC;

-- Câu 6: Dựa vào 2 bảng DimDepartmentGroup và bảng FactFinace, thực hiện lấy ra TotalAmount (dựa vào Amount) của DepartmentGroupName và ParentDepartmentGroupName
SELECT
	PARENT.DepartmentGroupName AS ParentDepartmentGroupName,
	DDG.DepartmentGroupName
	, SUM(FF.Amount) AS TotalAmount
FROM
	[dbo].[DimDepartmentGroup] DDG
	LEFT JOIN [dbo].[DimDepartmentGroup] PARENT ON PARENT.DepartmentGroupKey = DDG.ParentDepartmentGroupKey
	JOIN [dbo].[FactFinance] FF ON FF.DepartmentGroupKey = DDG.DepartmentGroupKey
GROUP BY
	PARENT.DepartmentGroupName, DDG.DepartmentGroupName
ORDER BY
	TotalAmount;