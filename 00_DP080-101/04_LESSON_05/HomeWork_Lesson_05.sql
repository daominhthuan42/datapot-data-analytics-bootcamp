USE [AdventureWorksDW2019]
GO

-- P-Ví dụ 3
-- Từ bảng DimProduct
-- Tìm giá trị lớn nhất của cột ListPrice, giá trị lớn nhất của cột StandardCost
SELECT
	MAX(p.ListPrice) AS MaxListPrice
	, MAX(p.StandardCost) AS MaxStandCost
FROM [dbo].[DimProduct] p

-- P-Ví dụ 5
-- Từ bảng DimProduct
-- Tính tổng giá trị sản phẩm: SUM(ListPrice) theo Color
SELECT
	p.Color
	, SUM(p.ListPrice) AS TotalListPrice
FROM 
	[dbo].[DimProduct] p
GROUP BY
	p.Color
ORDER BY TotalListPrice DESC

/*
Exercise 1: Write a query using the DimProduct table that displays the minimum, maximum,
and average ListPrice of all Product
*/
SELECT
	MAX(p.ListPrice) AS MaxListPrice
	, MIN(p.ListPrice) AS MinListPrice
	, AVG(p.ListPrice) AS AvgListPrice
FROM
	[dbo].[DimProduct] p
 
/*
The company is about to run a loyalty scheme to retain customers having total
value of orders greater than 5000 USD per year. From FactInternetSales table, retrieve the
list of qualified customers and the corresponding year.
*/
SELECT 
    fis.CustomerKey,
    YEAR(fis.OrderDate) AS OrderYear,
    SUM(fis.SalesAmount) AS TotalSales
FROM
	FactInternetSales AS fis
GROUP BY 
    fis.CustomerKey,
    YEAR(fis.OrderDate)
HAVING
	SUM(fis.SalesAmount) > 5000
ORDER BY
	OrderYear, CustomerKey;

-- CACH 2
SELECT
	TEMP.CustomerKey
	, TEMP.OrderYear
	, TEMP.TotalSales
FROM
(
	SELECT 
		CustomerKey,
		YEAR(OrderDate) AS OrderYear,
		SUM(SalesAmount) AS TotalSales
	FROM
		FactInternetSales
	GROUP BY 
		CustomerKey,
		YEAR(OrderDate)
) AS TEMP
WHERE TEMP.TotalSales > 5000
ORDER BY
	TEMP.OrderYear, TEMP.TotalSales;

/* Ex1: Từ bảng DimEmployee, tính BaseRate trung bình của từng Title có trong công ty */  
SELECT
	e.Title
	, AVG(e.BaseRate) AS AvgBaseRate
FROM
	[dbo].[DimEmployee] AS e
GROUP BY
	e.Title
ORDER BY
	AvgBaseRate;

/* Ex 2: Từ bảng FactInternetSales, lấy ra cột TotalOrderQuantity,
sử dụng cột OrderQuantity tính tổng số lượng bán ra với từng ProductKey và từng ngày OrderDate*/
SELECT
	fis.ProductKey
	, DAY(OrderDate) AS [DayOrder]
	, SUM(fis.OrderQuantity) AS TotalOrderQuantity
FROM
	[dbo].[FactInternetSales] fis
GROUP BY
	fis.ProductKey
	, DAY(OrderDate)
ORDER BY
	[DayOrder];

/* Ex3: Từ bảng DimProduct, FactInternetSales, DimProductCategory và các bảng liên quan nếu cần thiết
Lấy ra thông tin ngành hàng gồm: CategoryKey, EnglishCategoryName của các dòng thoả mãn điều kiện OrderDate trong năm 2012 và tính toán các cột sau đối với từng ngành hàng: 
- TotalRevenue sử dụng cột SalesAmount
- TotalCost sử dụng côt TotalProductCost
- TotalProfit được tính từ (TotalRevenue - TotalCost)
Chỉ hiển thị ra những bản ghi có TotalRevenue > 5000 */
--CÁCH 1
WITH cteCategorySales2012 AS(
	SELECT
		pc.ProductCategoryKey
		, pc.EnglishProductCategoryName
		, SUM(fis.SalesAmount) AS TotalRevenue
		, SUM(fis.TotalProductCost) AS TotalCost
	FROM
		[dbo].[FactInternetSales] fis
		JOIN [dbo].[DimProduct] p ON p.ProductKey = fis.ProductKey
		JOIN [dbo].[DimProductSubcategory] ps ON ps.ProductSubcategoryKey = p.ProductSubcategoryKey
		JOIN [dbo].[DimProductCategory] pc ON pc.ProductCategoryKey = ps.ProductCategoryKey
	WHERE
		YEAR(fis.OrderDate) = 2012
	GROUP BY
		pc.ProductCategoryKey
		, pc.EnglishProductCategoryName
)
SELECT
	TEMP.ProductCategoryKey
	, TEMP.EnglishProductCategoryName
	, TEMP.TotalRevenue
	, TEMP.TotalCost
	, (TEMP.TotalRevenue - TEMP.TotalCost) AS TotalProfit
FROM cteCategorySales2012 AS TEMP
WHERE TEMP.TotalRevenue > 5000;

--CÁCH 2
SELECT
	pc.ProductCategoryKey
	, pc.EnglishProductCategoryName
	, SUM(fis.SalesAmount) AS TotalRevenue
	, SUM(fis.TotalProductCost) AS TotalCost
	, (SUM(fis.SalesAmount) - SUM(fis.TotalProductCost)) AS TotalProfit
FROM
	[dbo].[FactInternetSales] fis
	JOIN [dbo].[DimProduct] p ON p.ProductKey = fis.ProductKey
	JOIN [dbo].[DimProductSubcategory] ps ON ps.ProductSubcategoryKey = p.ProductSubcategoryKey
	JOIN [dbo].[DimProductCategory] pc ON pc.ProductCategoryKey = ps.ProductCategoryKey
WHERE
	YEAR(fis.OrderDate) = 2012
GROUP BY
	pc.ProductCategoryKey
	, pc.EnglishProductCategoryName
HAVING
	SUM(fis.SalesAmount) > 5000;

/* Ex 4: Từ bảng FactInternetSale, DimProduct,
- Tạo ra cột Color_group từ cột Color, nếu Color là 'Black' hoặc 'Silver' gán giá trị 'Basic' cho cột Color_group, nếu không lấy nguyên giá trị cột Color sang
- Sau đó tính toán cột TotalRevenue từ cột SalesAmount đối với từng Color_group mới này */ 
SELECT
	CASE
		WHEN p.Color IN ('Silver', 'Black') THEN 'Basic'
		ELSE p.Color
	END AS Color_group
	, SUM(fis.SalesAmount) AS TotalRevenue
FROM
	[dbo].[FactInternetSales] fis
	JOIN [dbo].[DimProduct] p ON p.ProductKey = fis.ProductKey
GROUP BY
	CASE
		WHEN p.Color IN ('Silver', 'Black') THEN 'Basic'
		ELSE p.Color
	END
ORDER BY
	TotalRevenue;

/* Ex 5 (nâng cao) Từ bảng FactInternetSales, FactResellerSales và các bảng liên quan nếu cần,
sử dụng cột SalesAmount tính toán doanh thu ứng với từng tháng của 2 kênh bán Internet và Reseller
Kết quả trả ra sẽ gồm các cột sau: Year, Month, InternSales, Reseller_Sales 
Gợi ý: Tính doanh thu theo từng tháng ở mỗi bảng độc lập FactInternetSales và FactResllerSales bằng sử dụng CTE  
Lưu ý khi có nhiều hơn 1 CTE trong mệnh đề thì viết syntax như sau:  */
WITH cteInternetSales AS (
	SELECT
		MONTH(fis.OrderDate) AS MonthOrder
		, YEAR(fis.OrderDate) AS YearOrder
		, SUM(fis.SalesAmount) AS TotalRevenue
	FROM
		[dbo].[FactInternetSales] fis
	GROUP BY
		MONTH(fis.OrderDate)
		, YEAR(fis.OrderDate)
)
, cteResellerSales AS (
	SELECT
		MONTH(frs.OrderDate) AS MonthOrder
		, YEAR(frs.OrderDate) AS YearOrder
		, SUM(frs.SalesAmount) AS TotalRevenue
	FROM
		[dbo].[FactResellerSales] frs
	GROUP BY
		MONTH(frs.OrderDate)
		, YEAR(frs.OrderDate)
)
SELECT
	ISNULL(cis.MonthOrder, crs.MonthOrder) AS [MONTH]
	, ISNULL(cis.YearOrder, crs.YearOrder) AS [YEAR]
	, cis.TotalRevenue AS [TotalRevenue_InternetSales]
	, crs.TotalRevenue AS [TotalRevenue_ResellerSales]
FROM 
	cteInternetSales cis
	LEFT JOIN cteResellerSales crs ON crs.MonthOrder = cis.MonthOrder AND crs.YearOrder = cis.YearOrder
ORDER BY [MONTH], [YEAR];
