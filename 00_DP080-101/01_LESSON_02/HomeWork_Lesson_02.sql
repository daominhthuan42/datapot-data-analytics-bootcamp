USE AdventureWorksDW2020
GO

SELECT
	 DE.EmployeeKey 
	 , DE.LoginID
	 , DE.Title 
FROM 
	[dbo].[DimEmployee] AS DE
WHERE 
	DE.Title = 'Research and Development Engineer';

--	Từ bảng DimProduct,
--Lấy ra thông tin những sản phẩm có Color = 'Red'
SELECT
	*
FROM 
	[dbo].[DimProduct] AS DP
WHERE 
	DP.Color = 'Red'; -- Nó không biệt ký tự hoa thường thì red hay Red đều ra kết quả.

/*
Từ bảng DimProduct, lấy ra các sản phẩm có ListPrice trong khoảng từ 100 đến 400
-- Cách 1: Gợi ý: dùng >= , <= , AND
*/
SELECT
	*
FROM 
	[dbo].[DimProduct] AS DP
WHERE 
	DP.ListPrice > 100 AND DP.ListPrice < 400;

-- CÁCH 2:
SELECT
	*
FROM 
	[dbo].[DimProduct] AS DP
WHERE 
	DP.ListPrice BETWEEN 100 AND 400

/* Từ bảng DimProduct, lấy ra các sản phẩm có Color = 'Red' HOẶC Color = 'Silver'
-- Cách 1: Gợi ý: dùng OR */
SELECT
	*
FROM 
	[dbo].[DimProduct] AS DP
WHERE 
	DP.Color = 'Red' OR DP.Color = 'Silver';

-- Cách 2: Gợi ý: dùng IN 
SELECT
	*
FROM 
	[dbo].[DimProduct] AS DP
WHERE 
	DP.Color IN ('Red', 'Silver')

/*
Exercise: Use AdventureWorksDW2019 
From table “DimEmployee” select all records that satisfy one of the following conditions:
• DepartmentName is equal to “Tool Design”
• Status does NOT include the value NULL
• StartDate in the period from ‘2009-01-01’ to ‘2009-12-31’
And must have VacationHours >10
*/
USE AdventureWorksDW2019
GO

SELECT
	*
FROM 
	[dbo].[DimEmployee] AS DE
WHERE 
	(
		DE.DepartmentName = 'Tool Design'
		OR DE.[Status] IS NOT NULL
		OR DE.StartDate BETWEEN '2009-01-01' AND '2009-12-31'
	)
	AND DE.VacationHours > 10;

SELECT
	FIS.OrderDate
	, DATEDIFF(MONTH, 0, FIS.OrderDate)
	, DATEADD(MONTH, DATEDIFF(MONTH, 0, FIS.OrderDate) - 1, 0) AS FirstDayOfPreviousMonth
FROM 
	[dbo].[FactInternetSales] AS FIS

-----------------------------------------------------------------------------------------------------
/* Ex1: Từ bộ AdventureWorksDW2019, bảng FactInternetSales, 
lấy tất cả các bản ghi có OrderDate từ ngày '2011-01-01' về sau và ShipDate trong năm 2011
*/ 
USE AdventureWorksDW2019
GO

SELECT
	*
FROM 
	[dbo].[FactInternetSales] AS FIS
WHERE
	FIS.OrderDate >= '2011-01-01'
	AND FIS.ShipDate >= '2011-01-01' AND FIS.ShipDate < '2012-01-01';

/*Ex2: Từ bộ AdventureWorksDW2019, bảng DimProduct,
Lấy ra thông tin ProductKey, ProductAlternateKey và EnglishProductName của các sản phẩm.
Lọc các sản phẩn có ProductAlternateKey bắt đầu bằng chữ 'BK-' theo sau đó là 1 ký tự bất kỳ khác chữ T và kết thúc bằng 2 con số bất kỳ 
Đồng thời, thoả mãn điều kiện Color là Black hoặc Red hoặc White
*/
SELECT
	DP.ProductKey
	, DP.ProductAlternateKey
	, DP.EnglishProductName
FROM 
	[dbo].[DimProduct] AS DP
WHERE 
	DP.ProductAlternateKey LIKE 'BK-[^T]%[0-9][0-9]'
	 AND DP.Color IN ('Black', 'Red', 'White');

/* Ex3: Từ bộ AdventureWorksDW2019, bảng DimProduct, lấy ra tất cả các sản phẩm có cột Color là Red */
SELECT
	DP.ProductKey
	, DP.EnglishProductName
	, DP.Color
FROM 
	[dbo].[DimProduct] AS DP
WHERE 
	DP.Color = 'Red';

/* Ex4: Từ bộ AdventureWorksDW2019, bảng FactInternetSales chứa thông tin bán hàng,
lấy ra tất cả các bản ghi bán các sản phẩm có màu là Red */
SELECT 
	*
FROM
	[dbo].[FactInternetSales] AS FIS
WHERE 
	FIS.ProductKey IN (
						SELECT 
							DP.ProductKey
						FROM 
							[dbo].[DimProduct] AS DP
						WHERE 
							DP.Color = 'Red'
					 );

/* Ex5: Từ bộ AdventureWorksDW2019, bảng DimEmployee, lấy ra EmployeeKey, FirstName, LastName, MiddleName 
của những nhân viên có MiddleName không bị Null và cột Phone có độ dài 12 ký tự */
SELECT
	DE.EmployeeKey
	, DE.FirstName
	, DE.LastName
	, DE.MiddleName
FROM 
	[dbo].[DimEmployee] AS DE
WHERE 
	DE.MiddleName IS NOT NULL 
	AND LEN(DE.Phone) = 12;

/* Ex6: Từ bộ AdventureWorksDW2019, bảng DimEmployee, lấy ra danh sách các EmployeeKey
Sau đó lấy ra thêm các cột sau:
a. Cột FullName được lấy ra từ kết hợp 3 trường FirstName, MiddleName và LastName, với dấu cách ngăn cách giữa các trường 
(sử dụng 2 cách: toán tử '+' và hàm, sau đó so sánh sự khác biệt)
b. Cột AgeHired tính tuổi nhân viên tại thời điểm được tuyển, sử dụng cột HireDate và BirthDate 
c. Cột AgeNow tính tuổi nhân viên đến thời điểm hiện tại, sử dụng cột BirthDate
d. Cột UserName được lấy ra từ phần đằng sau dấu "\" của cột LoginID
(Ví dụ: LoginID = adventure-works\jun0, vậy Username tương ứng cần được lấy ra là jun0)
*/
SELECT
	DE.EmployeeKey
	, DE.FirstName
	, DE.MiddleName
	, DE.LastName
	, ISNULL(DE.FirstName + ' ', '') + ISNULL(DE.MiddleName + ' ', '') + ISNULL(DE.LastName, '') AS FullName
	, DATEDIFF(YEAR, DE.BirthDate, DE.HireDate) AS AgeHired
	, DATEDIFF(YEAR, DE.BirthDate, GETDATE()) AS AgeNow
	, SUBSTRING(DE.LoginID, CHARINDEX('\', DE.LoginID) + 1, LEN(DE.LoginID) - (CHARINDEX('\', DE.LoginID) + 1)) AS UserName
FROM
	[dbo].[DimEmployee] AS DE;
