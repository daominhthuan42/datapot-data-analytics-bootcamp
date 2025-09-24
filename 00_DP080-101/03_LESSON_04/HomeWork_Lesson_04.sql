USE [AdventureWorksDW2019]
GO

--Mở rộng Ex2 trong bài tập về nhà buổi 3
 
--Từ bảng dbo.DimProduct, dbo.DimProductSubcategory, dbo.DimProductCategrory
--Lấy ra ProductKey, EnglishProductName, Color
--của các sản phẩm thoả mãn EnglishProductCategoryName là 'Clothing'
SELECT 
	p.ProductKey
	, p.EnglishProductName
	, p.Color
	, pc.EnglishProductCategoryName
FROM 
	[dbo].[DimProduct] p
	JOIN [dbo].[DimProductSubcategory] ps ON ps.ProductSubcategoryKey = p.ProductSubcategoryKey
	JOIN [dbo].[DimProductCategory] pc ON pc.ProductCategoryKey = ps.ProductCategoryKey
WHERE
	pc.EnglishProductCategoryName LIKE '%Clothing%'

/*
Ex1:
From dbo.DimProduct, dbo.DimPromotion, dbo.FactInternetSales,
Write a query display EnglishProductName which has discount percentage >= 20%
*/
SELECT DP.EnglishProductName
FROM FactInternetSales AS FIS
LEFT JOIN dbo.DimProduct AS DP ON FIS.ProductKey = DP.ProductKey
LEFT JOIN dbo.DimPromotion AS DPR ON FIS.PromotionKey = DPR.PromotionKey
WHERE DPR.DiscountPct >= 0.2

 
/*
Từ bảng DimOrganization , tạo ra cột ParentOrganizationName của từng OrganizationName
*/
SELECT Child.OrganizationKey
    , Child.OrganizationName
    , Child.ParentOrganizationKey
    , Parent.OrganizationName ParentOrganizationName
FROM dbo.DimOrganization AS Child
LEFT JOIN dbo.DimOrganization AS Parent
ON Child.ParentOrganizationKey = Parent.OrganizationKey



/*Ex 1: Từ các bảng dbo.DimProduct, dbo.DimPromotion, dbo.FactInternetSales, lấy ra ProductKey, EnglishProductName của các dòng thoả mãn Discount Pct >= 20% */ 
SELECT
	dp.ProductKey
	, dp.EnglishProductName
FROM 
	[dbo].[DimProduct] dp
	JOIN [dbo].[FactInternetSales] fis ON fis.ProductKey = dp.ProductKey
	JOIN [dbo].[DimPromotion] dpr ON dpr.PromotionKey = fis.PromotionKey
WHERE
	dpr.DiscountPct >= 0.2;

/*Ex 2: Từ các bảng DimProduct, DimProductSubcategory, DimProductCategory, lấy ra các cột Product key, EnglishProductName, EnglishProductSubCategoryName,
EnglishProductCategoryName của sản phẩm thoả mãn điều kiện EnglishProductCategoryName là 'Clothing' */ 
SELECT 
	p.ProductKey
	, p.EnglishProductName
	, ps.EnglishProductSubcategoryName
FROM 
	[dbo].[DimProduct] p
	JOIN [dbo].[DimProductSubcategory] ps ON ps.ProductSubcategoryKey = p.ProductSubcategoryKey
	JOIN [dbo].[DimProductCategory] pc ON pc.ProductCategoryKey = ps.ProductCategoryKey
WHERE
	pc.EnglishProductCategoryName = 'Clothing';

/*Ex 3: Từ bảng FactInternetSales và DimProduct, lấy ra ProductKey, EnglishProductName, ListPrice của những sản phẩm chưa từng được bán. Sử dụng 2 cách: toán tử IN và phép JOIN */
-- CACH 1
SELECT
	DISTINCT dp.ProductKey
	, dp.EnglishProductName
	, dp.ListPrice
	, fis.ProductKey
FROM 
	[dbo].[DimProduct] dp
	LEFT JOIN [dbo].[FactInternetSales] fis ON fis.ProductKey = dp.ProductKey
WHERE
	fis.ProductKey IS NULL
ORDER BY
	dp.ProductKey;

-- CACH 2
SELECT
	DISTINCT dp.ProductKey
	, dp.EnglishProductName
	, dp.ListPrice
FROM 
	[dbo].[DimProduct] dp
WHERE	
	dp.ProductKey NOT IN (SELECT DISTINCT fis.ProductKey FROM [dbo].[FactInternetSales] fis)
ORDER BY
	dp.ProductKey;

-- CACH 3
SELECT
	DISTINCT dp.ProductKey
	, dp.EnglishProductName
	, dp.ListPrice
FROM 
	[dbo].[DimProduct] dp
WHERE
	NOT EXISTS (SELECT 1 FROM [dbo].[FactInternetSales] fis WHERE fis.ProductKey = dp.ProductKey)
ORDER BY
	dp.ProductKey;

/*Ex 4: Từ bảng DimDepartmentGroup, lấy ra thông tin DepartmentGroupKey, DepartmentGroupName, ParentDepartmentGroupKey và thực hiện self-join lấy ra ParentDepartmentGroupName */ 
SELECT 
	child.DepartmentGroupKey
	, child.DepartmentGroupName
	, parent.DepartmentGroupKey
	, parent.DepartmentGroupName AS ParentDepartmentGroupName
FROM 
	[dbo].[DimDepartmentGroup] child
	LEFT JOIN [dbo].[DimDepartmentGroup] parent ON child.ParentDepartmentGroupKey = parent.DepartmentGroupKey


/*Ex 5: Từ bảng FactFinance, DimOrganization, DimScenario, lấy ra OrganizationKey, OrganizationName, Parent OrganizationKey,
và thực hiện self-join lấy ra Parent OrganizationName, Amount thoả mãn điều kiện ScenarioName là 'Actual'. */ 
SELECT
	DO.OrganizationKey
	, DO.OrganizationName
	, PARENT.OrganizationKey
	, PARENT.OrganizationName AS ParentOrganizationName
	, FF.Amount
FROM 
	[dbo].[FactFinance] FF
	JOIN [dbo].[DimOrganization] DO ON DO.OrganizationKey = FF.OrganizationKey
	LEFT JOIN [dbo].[DimOrganization] PARENT ON PARENT.OrganizationKey = DO.ParentOrganizationKey
	JOIN [dbo].[DimScenario] DS ON DS.ScenarioKey = FF.ScenarioKey
WHERE
	DS.ScenarioName = 'Actual';
