  --Query 1.1 Preferred Solution with CustomerID Grouping (NO CTE for aggregetion)
WITH
  Address_data AS (
  SELECT
    Customer_address.CustomerID CustomerID,
    Customer_address.AddressID AddressID,
    Address.AddressLine1,
    Address.AddressLine2,
    City,
    StateProvinceID
  FROM
    `tc-da-1.adwentureworks_db.customeraddress` Customer_address
  JOIN
    `tc-da-1.adwentureworks_db.address` Address
  ON
    Customer_address.AddressID = Address.AddressID
  WHERE
    Customer_address.AddressID = (
    SELECT
      MAX(AddressID)
    FROM
      `tc-da-1.adwentureworks_db.customeraddress`
    WHERE
      CustomerID = Customer_address.CustomerID )
  GROUP BY
    CustomerID,
    AddressID,
    AddressLine1,
    AddressLine2,
    City,
    StateProvinceID ),
  Customer_overview AS (
  SELECT
    Customer.CustomerId AS Customer_Id,
    Contact.FirstName AS First_name,
    Contact.LastName AS Last_name,
    CONCAT(Contact.FirstName, ' ', Contact.LastName) AS FullName,
    COALESCE(Contact.Title, 'Dear') || ' ' || Contact.LastName AS Title,
    Contact.EmailAddress,
    Contact.Phone,
    Customer.AccountNumber,
    Customer.CustomerType,
    Address_data.City,
    Address_data.AddressLine1 AS AddressLine_1,
    COALESCE (Address_data.AddressLine2, '') AS AddressLine_2,
    State_Province.Name AS State,
    Country_Region.name AS Country,
    Sales_order.Number_of_orders,
    Sales_order.Total_due,
    Sales_order.Last_order
  FROM
    `tc-da-1.adwentureworks_db.customer` AS Customer
  JOIN
    `tc-da-1.adwentureworks_db.individual` AS Individual
  ON
    (Customer.CustomerId = Individual.CustomerId
      AND customer.CustomerType = "I")
  JOIN
    `tc-da-1.adwentureworks_db.contact` AS Contact
  ON
    Individual.ContactId = Contact.ContactId
  JOIN
    Address_data
  ON
    Customer.CustomerId = Address_data.CustomerID
  JOIN
    `tc-da-1.adwentureworks_db.stateprovince` AS State_Province
  ON
    Address_data.StateProvinceID = State_Province.StateProvinceID
  JOIN
    `tc-da-1.adwentureworks_db.countryregion` AS Country_Region
  ON
    State_Province.CountryRegionCode = Country_Region.CountryRegionCode
  JOIN (
    SELECT
      CustomerID,
      COUNT(SalesOrderID) AS Number_of_orders,
      ROUND(SUM(TotalDue), 3) AS Total_due,
      MAX(OrderDate) AS Last_order
    FROM
      `tc-da-1.adwentureworks_db.salesorderheader`
    GROUP BY
      CustomerID ) AS Sales_order
  ON
    Sales_order.CustomerID = Customer.CustomerID)
SELECT
  *
FROM
  Customer_overview
ORDER BY
  Total_due DESC 
LIMIT 200;




--Query 1.1 Preferred Solution with CustomerID Grouping and CTE for aggregetion)

WITH
  Address_data AS (
    SELECT
      Customer_address.CustomerID CustomerID,
      Customer_address.AddressID AddressID,
      Address.AddressLine1,
      Address.AddressLine2,
      City,
      StateProvinceID
    FROM
      `tc-da-1.adwentureworks_db.customeraddress` Customer_address
    JOIN
      `tc-da-1.adwentureworks_db.address` Address
    ON
      Customer_address.AddressID = Address.AddressID
    WHERE
      Customer_address.AddressID = (
        SELECT
          MAX(AddressID)
        FROM
          `tc-da-1.adwentureworks_db.customeraddress`
        WHERE
          CustomerID = Customer_address.CustomerID
      )
    GROUP BY
      CustomerID,
      AddressID,
      AddressLine1,
      AddressLine2,
      City,
      StateProvinceID
  ),
  Sales_data AS (
    SELECT
      CustomerID,
      COUNT(SalesOrderID) AS Number_of_orders,
      ROUND(SUM(TotalDue), 3) AS Total_due,
      MAX(OrderDate) AS Last_order
    FROM
      `tc-da-1.adwentureworks_db.salesorderheader`
    GROUP BY
      CustomerID
  ),
  Customer_overview AS (
    SELECT
      Customer.CustomerId AS Customer_Id,
      Contact.FirstName AS First_name,
      Contact.LastName AS Last_name,
      CONCAT(Contact.FirstName, ' ', Contact.LastName) AS FullName,
      COALESCE(Contact.Title, 'Dear') || ' ' || Contact.LastName AS Title,
      Contact.EmailAddress,
      Contact.Phone,
      Customer.AccountNumber,
      Customer.CustomerType,
      Address_data.City,
      Address_data.AddressLine1 AS AddressLine_1,
      COALESCE(Address_data.AddressLine2, '') AS AddressLine_2,
      State_Province.Name AS State,
      Country_Region.name AS Country,
      Sales_data.Number_of_orders,
      Sales_data.Total_due,
      Sales_data.Last_order
    FROM
      `tc-da-1.adwentureworks_db.customer` AS Customer
    JOIN
      `tc-da-1.adwentureworks_db.individual` AS Individual
    ON
      (Customer.CustomerId = Individual.CustomerId
        AND Customer.CustomerType = "I")
    JOIN
      `tc-da-1.adwentureworks_db.contact` AS Contact
    ON
      Individual.ContactId = Contact.ContactId
    JOIN
      Address_data
    ON
      Customer.CustomerId = Address_data.CustomerID
    JOIN
      `tc-da-1.adwentureworks_db.stateprovince` AS State_Province
    ON
      Address_data.StateProvinceID = State_Province.StateProvinceID
    JOIN
      `tc-da-1.adwentureworks_db.countryregion` AS Country_Region
    ON
      State_Province.CountryRegionCode = Country_Region.CountryRegionCode
    JOIN
      Sales_data
    ON
      Sales_data.CustomerID = Customer.CustomerId
  )
SELECT
  *
FROM
  Customer_overview
ORDER BY
  Total_due DESC
LIMIT 200;





  --Query 1.2
WITH
  Address_data AS (
  SELECT
    Customer_address.CustomerID CustomerID,
    Customer_address.AddressID AddressID,
    Address.AddressLine1,
    Address.AddressLine2,
    City,
    StateProvinceID
  FROM
    `tc-da-1.adwentureworks_db.customeraddress` Customer_address
  JOIN
    `tc-da-1.adwentureworks_db.address` Address
  ON
    Customer_address.AddressID = Address.AddressID
  WHERE
    Customer_address.AddressID = (
    SELECT
      MAX(AddressID)
    FROM
      `tc-da-1.adwentureworks_db.customeraddress`
    WHERE
      CustomerID = Customer_address.CustomerID )
  GROUP BY
    CustomerID,
    AddressID,
    AddressLine1,
    AddressLine2,
    City,
    StateProvinceID )
SELECT
  Customer.CustomerId AS Customer_Id,
  Contact.FirstName AS First_name,
  Contact.LastName AS Last_name,
  CONCAT(Contact.FirstName, ' ', Contact.LastName) AS FullName,
  COALESCE(Contact.Title, 'Dear') || ' ' || Contact.LastName AS Title,
  Contact.EmailAddress,
  Contact.Phone,
  Sales_Order_Header.AccountNumber,
  Customer.CustomerType,
  Address_data.City,
  Address_data.AddressLine1 AS AddressLine_1,
  Address_data.AddressLine2 AS AddressLine_2,
  State_Province.Name AS State,
  Country_Region.name AS Country,
  COUNT(Sales_Order_Header.SalesOrderID) AS Number_of_orders,
  ROUND(SUM(Sales_Order_Header.TotalDue), 3) AS Total_due,
  MAX(Sales_Order_Header.OrderDate) AS Last_order
FROM
  `tc-da-1.adwentureworks_db.customer` AS Customer
JOIN
  `tc-da-1.adwentureworks_db.individual` AS Individual
ON
  (Customer.CustomerId = Individual.CustomerId
    AND customer.CustomerType = "I")
JOIN
  `tc-da-1.adwentureworks_db.contact` AS Contact
ON
  Individual.ContactId = Contact.ContactId
JOIN
  `tc-da-1.adwentureworks_db.salesorderheader` AS Sales_Order_Header
ON
  Customer.CustomerId = Sales_Order_Header.CustomerID
JOIN
  Address_data
ON
  Customer.CustomerId = Address_data.CustomerID
JOIN
  `tc-da-1.adwentureworks_db.stateprovince` AS State_Province
ON
  Address_data.StateProvinceID = State_Province.StateProvinceID
JOIN
  `tc-da-1.adwentureworks_db.countryregion` AS Country_Region
ON
  State_Province.CountryRegionCode = Country_Region.CountryRegionCode
GROUP BY
  Customer.CustomerId,
  Contact.FirstName,
  Contact.LastName,
  Contact.Title,
  Contact.EmailAddress,
  Contact.Phone,
  Sales_Order_Header.AccountNumber,
  Customer.CustomerType,
  Address_data.City,
  Address_data.AddressLine1,
  Address_data.AddressLine2,
  State_Province.Name,
  Country_Region.name
HAVING
  Last_order < (
  SELECT
    DATE_SUB(MAX(OrderDate), INTERVAL 365 DAY)
  FROM
    `tc-da-1.adwentureworks_db.salesorderheader` )
ORDER BY
  Total_due DESC
LIMIT
  200;





 --Query 1.3
WITH
  Address_data AS (
  SELECT
    Customer_address.CustomerID,
    MAX(Customer_address.AddressID) AS AddressID,
    Address.AddressLine1,
    Address.AddressLine2,
    Address.City,
    Address.StateProvinceID
  FROM
    `tc-da-1.adwentureworks_db.customeraddress` AS Customer_address
  JOIN
    `tc-da-1.adwentureworks_db.address` AS Address
  ON
    Customer_address.AddressID = Address.AddressID
  GROUP BY
    Customer_address.CustomerID,
    Address.AddressLine1,
    Address.AddressLine2,
    Address.City,
    Address.StateProvinceID),
  Sales AS (
  SELECT
    Customer.CustomerId AS Customer_Id,
    Contact.FirstName AS First_name,
    Contact.LastName AS Last_name,
    CONCAT(Contact.FirstName, ' ', Contact.LastName) AS FullName,
    COALESCE(Contact.Title, 'Dear') || ' ' || Contact.LastName AS Title,
    Contact.EmailAddress,
    Contact.Phone,
    Sales_Order_Header.AccountNumber,
    Customer.CustomerType,
    Address_data.City,
    Address_data.AddressLine1 AS AddressLine_1,
    Address_data.AddressLine2 AS AddressLine_2,
    State_Province.Name AS State,
    Country_Region.name AS Country,
    COUNT(Sales_Order_Header.SalesOrderID) AS Number_of_orders,
    ROUND(SUM(Sales_Order_Header.TotalDue), 3) AS Total_due,
    MAX(Sales_Order_Header.OrderDate) AS Last_order
  FROM
    `tc-da-1.adwentureworks_db.customer` AS Customer
  JOIN
    `tc-da-1.adwentureworks_db.individual` AS Individual
  ON
    Customer.CustomerId = Individual.CustomerId
  JOIN
    `tc-da-1.adwentureworks_db.contact` AS Contact
  ON
    Individual.ContactId = Contact.ContactId
  JOIN
    `tc-da-1.adwentureworks_db.salesorderheader` AS Sales_Order_Header
  ON
    Customer.CustomerId = Sales_Order_Header.CustomerID
  JOIN
    Address_data
  ON
    Customer.CustomerId = Address_data.CustomerID
  JOIN
    `tc-da-1.adwentureworks_db.stateprovince` AS State_Province
  ON
    Address_data.StateProvinceID = State_Province.StateProvinceID
  JOIN
    `tc-da-1.adwentureworks_db.countryregion` AS Country_Region
  ON
    State_Province.CountryRegionCode = Country_Region.CountryRegionCode
  GROUP BY
    Customer.CustomerId,
    Contact.FirstName,
    Contact.LastName,
    Contact.Title,
    Contact.EmailAddress,
    Contact.Phone,
    Sales_Order_Header.AccountNumber,
    Customer.CustomerType,
    Address_data.City,
    Address_data.AddressLine1,
    Address_data.AddressLine2,
    State_Province.Name,
    Country_Region.name),
  Latest_Order_Date AS (
  SELECT
    DATE_SUB(MAX(OrderDate), INTERVAL 365 DAY) AS Cutoff_Date
  FROM
    `tc-da-1.adwentureworks_db.salesorderheader` Sales_Order_Header)
SELECT
  Sales.*,
  CASE
    WHEN Sales.Last_order < Latest_Order_Date.Cutoff_Date THEN 'Inactive'
    ELSE 'Active'
END
  AS Status
FROM
  Sales,
  Latest_Order_Date
ORDER BY
  Sales.Customer_Id DESC
LIMIT
  500;





--Query 1.3 Alternative

WITH
  Address_data AS (
  SELECT
    Customer_address.CustomerID CustomerID,
    Customer_address.AddressID AddressID,
    Address.AddressLine1,
    Address.AddressLine2,
    City,
    StateProvinceID
  FROM
    `tc-da-1.adwentureworks_db.customeraddress` Customer_address
  JOIN
    `tc-da-1.adwentureworks_db.address` Address
  ON
    Customer_address.AddressID = Address.AddressID
  WHERE
    Customer_address.AddressID = (
    SELECT
      MAX(AddressID)
    FROM
      `tc-da-1.adwentureworks_db.customeraddress`
    WHERE
      CustomerID = Customer_address.CustomerID )
  GROUP BY
    CustomerID,
    AddressID,
    AddressLine1,
    AddressLine2,
    City,
    StateProvinceID ),
  Customer_overview AS (
  SELECT
    Customer.CustomerId AS Customer_Id,
    Contact.FirstName AS First_name,
    Contact.LastName AS Last_name,
    CONCAT(Contact.FirstName, ' ', Contact.LastName) AS FullName,
    COALESCE(Contact.Title, 'Dear') || ' ' || Contact.LastName AS Title,
    Contact.EmailAddress,
    Contact.Phone,
    Customer.AccountNumber,
    Customer.CustomerType,
    Address_data.City,
    Address_data.AddressLine1 AS AddressLine_1,
    COALESCE (Address_data.AddressLine2, '') AS AddressLine_2,
    State_Province.Name AS State,
    Country_Region.name AS Country,
    Sales_order.Number_of_orders,
    Sales_order.Total_due,
    Sales_order.Last_order
  FROM
    `tc-da-1.adwentureworks_db.customer` AS Customer
  JOIN
    `tc-da-1.adwentureworks_db.individual` AS Individual
  ON
    (Customer.CustomerId = Individual.CustomerId
      AND customer.CustomerType = "I")
  JOIN
    `tc-da-1.adwentureworks_db.contact` AS Contact
  ON
    Individual.ContactId = Contact.ContactId
  JOIN
    Address_data
  ON
    Customer.CustomerId = Address_data.CustomerID
  JOIN
    `tc-da-1.adwentureworks_db.stateprovince` AS State_Province
  ON
    Address_data.StateProvinceID = State_Province.StateProvinceID
  JOIN
    `tc-da-1.adwentureworks_db.countryregion` AS Country_Region
  ON
    State_Province.CountryRegionCode = Country_Region.CountryRegionCode
  JOIN (
    SELECT
      CustomerID,
      COUNT(SalesOrderID) AS Number_of_orders,
      ROUND(SUM(TotalDue), 3) AS Total_due,
      MAX(OrderDate) AS Last_order
    FROM
      `tc-da-1.adwentureworks_db.salesorderheader`
    GROUP BY
      CustomerID ) AS Sales_order
  ON
    Sales_order.CustomerID = Customer.CustomerID),
 Latest_Order_Date AS (
  SELECT
    DATE_SUB(MAX(OrderDate), INTERVAL 365 DAY) AS Cutoff_Date
  FROM
    `tc-da-1.adwentureworks_db.salesorderheader` Sales_Order_Header)
SELECT
  Customer_overview.*,
CASE
    WHEN Last_order < Latest_Order_Date.Cutoff_Date THEN 'Inactive'
    ELSE 'Active'
END
  AS Status
FROM
  Customer_overview,
  Latest_Order_Date
ORDER BY
  Customer_Id DESC
LIMIT
  500;





  --Query 1.4
WITH
  Address_data AS (
  SELECT
    Customer_address.CustomerID,
    MAX(Customer_address.AddressID) AS AddressID,
    Address.AddressLine1,
    Address.AddressLine2,
    Address.City,
    Address.StateProvinceID
  FROM
    `tc-da-1.adwentureworks_db.customeraddress` AS Customer_address
  JOIN
    `tc-da-1.adwentureworks_db.address` AS Address
  ON
    Customer_address.AddressID = Address.AddressID
  GROUP BY
    Customer_address.CustomerID,
    Address.AddressLine1,
    Address.AddressLine2,
    Address.City,
    Address.StateProvinceID),
  Sales AS (
  SELECT
    Customer.CustomerId AS Customer_Id,
    Contact.FirstName AS First_name,
    Contact.LastName AS Last_name,
    CONCAT(Contact.FirstName, ' ', Contact.LastName) AS FullName,
    COALESCE(Contact.Title, 'Dear') || ' ' || Contact.LastName AS Title,
    Contact.EmailAddress,
    Contact.Phone,
    Sales_Order_Header.AccountNumber,
    Customer.CustomerType,
    Address_data.City,
    Address_data.AddressLine1 AS AddressLine_1,
    REGEXP_EXTRACT(Address_data.AddressLine1, r'^\d+') Address_no,
    REGEXP_REPLACE(Address_data.AddressLine1, r'^\d+\s', '') Address_st,
    Address_data.AddressLine2 AS AddressLine_2,
    State_Province.Name AS State,
    Country_Region.name AS Country,
    COUNT(Sales_Order_Header.SalesOrderID) AS Number_of_orders,
    ROUND(SUM(Sales_Order_Header.TotalDue), 3) AS Total_due,
    MAX(Sales_Order_Header.OrderDate) AS Last_order
  FROM
    `tc-da-1.adwentureworks_db.customer` AS Customer
  JOIN
    `tc-da-1.adwentureworks_db.individual` AS Individual
  ON
    Customer.CustomerId = Individual.CustomerId
  JOIN
    `tc-da-1.adwentureworks_db.contact` AS Contact
  ON
    Individual.ContactId = Contact.ContactId
  JOIN
    `tc-da-1.adwentureworks_db.salesorderheader` AS Sales_Order_Header
  ON
    Customer.CustomerId = Sales_Order_Header.CustomerID
  JOIN
    Address_data
  ON
    Customer.CustomerId = Address_data.CustomerID
  JOIN
    `tc-da-1.adwentureworks_db.stateprovince` AS State_Province
  ON
    Address_data.StateProvinceID = State_Province.StateProvinceID
  JOIN
    `tc-da-1.adwentureworks_db.countryregion` AS Country_Region
  ON
    State_Province.CountryRegionCode = Country_Region.CountryRegionCode
  GROUP BY
    Customer.CustomerId,
    Contact.FirstName,
    Contact.LastName,
    Contact.Title,
    Contact.EmailAddress,
    Contact.Phone,
    Sales_Order_Header.AccountNumber,
    Customer.CustomerType,
    Address_data.City,
    Address_data.AddressLine1,
    Address_data.AddressLine2,
    State_Province.Name,
    Country_Region.name ),
  Latest_Order_Date AS (
  SELECT
    DATE_SUB(MAX(OrderDate), INTERVAL 365 DAY) AS Cutoff_Date
  FROM
    `tc-da-1.adwentureworks_db.salesorderheader` Sales_Order_Header)
SELECT
  Sales.*,
  CASE
    WHEN Sales.Last_order < Latest_Order_Date.Cutoff_Date THEN 'Inactive'
    ELSE 'Active'
END
  AS Status
FROM
  Sales,
  Latest_Order_Date
WHERE
  Sales.Country IN (
  SELECT
    Country_Region.Name Country
  FROM
    tc-da-1.adwentureworks_db.salesterritory Sales_Territory
  JOIN
    tc-da-1.adwentureworks_db.countryregion Country_Region
  ON
    Sales_Territory.CountryRegionCode = Country_Region.CountryRegionCode
  WHERE
    Sales_Territory.Group = 'North America' )  --countries in North America
GROUP BY
  ALL
HAVING
  Status = 'Active'
  AND (Total_due >= 2500
    OR Number_of_orders >5)
ORDER BY
  country,
  state,
  Last_order ;





  --Query 2.1
SELECT
  LAST_DAY(CAST(Sales_order_header.OrderDate AS DATE)) AS Order_date,
  Sales_territory.CountryRegionCode AS Country_region_code,
  Sales_territory.Name AS Region,
  COUNT(Sales_order_header.SalesOrderID) AS No_of_orders,
  COUNT(DISTINCT Sales_order_header.CustomerID) AS No_of_customers,
  COUNT(DISTINCT Sales_order_header.SalesPersonID) AS No_of_salespersons,
  CAST(ROUND(SUM(Sales_Order_Header.TotalDue)) AS DECIMAL) AS Total_w_tax
FROM
  `tc-da-1.adwentureworks_db.salesorderheader` AS Sales_order_header
JOIN
  `tc-da-1.adwentureworks_db.salesterritory` AS Sales_territory
ON
  Sales_order_header.TerritoryID = Sales_territory.TerritoryID
GROUP BY
  Order_date,
  Country_region_code,
  Region;




  --Query 2.2
WITH
  Monthly_Sales AS (
  SELECT
    LAST_DAY(CAST(Sales_order_header.OrderDate AS DATE)) AS Order_date,
    Sales_territory.CountryRegionCode AS Country_region_code,
    Sales_territory.Name AS Region,
    COUNT(Sales_order_header.SalesOrderID) AS No_of_orders,
    COUNT(DISTINCT Sales_order_header.CustomerID) AS No_of_customers,
    COUNT(DISTINCT Sales_order_header.SalesPersonID) AS No_of_salespersons,
    CAST(ROUND(SUM(Sales_Order_Header.TotalDue)) AS DECIMAL) AS Total_w_tax
  FROM
    `tc-da-1.adwentureworks_db.salesorderheader` AS Sales_order_header
  JOIN
    `tc-da-1.adwentureworks_db.salesterritory` AS Sales_territory
  ON
    Sales_order_header.TerritoryID = Sales_territory.TerritoryID
  GROUP BY
    Order_date,
    Country_region_code,
    Region)
SELECT
  Monthly_Sales.*,
  ROUND(SUM(Total_w_tax) OVER (PARTITION BY Country_region_code, Region ORDER BY Order_date)) AS Cumulative_total_w_tax
FROM
  Monthly_Sales
ORDER BY
  Country_region_code,
  Region,
  Order_date;




  --Query 2.3
WITH
  Monthly_Sales AS (
  SELECT
    LAST_DAY(CAST(Sales_order_header.OrderDate AS DATE)) AS Order_date,
    Sales_territory.CountryRegionCode AS Country_region_code,
    Sales_territory.Name AS Region,
    COUNT(Sales_order_header.SalesOrderID) AS No_of_orders,
    COUNT(DISTINCT Sales_order_header.CustomerID) AS No_of_customers,
    COUNT(DISTINCT Sales_order_header.SalesPersonID) AS No_of_salespersons,
    CAST(ROUND(SUM(Sales_Order_Header.TotalDue)) AS DECIMAL) AS Total_w_tax
  FROM
    `tc-da-1.adwentureworks_db.salesorderheader` AS Sales_order_header
  JOIN
    `tc-da-1.adwentureworks_db.salesterritory` AS Sales_territory
  ON
    Sales_order_header.TerritoryID = Sales_territory.TerritoryID
  GROUP BY
    Order_date,
    Country_region_code,
    Region)
SELECT
  Monthly_Sales.*,
  ROUND(SUM(Total_w_tax) OVER (PARTITION BY Region ORDER BY Order_date)) AS Cumulative_total_w_tax,
  RANK() OVER(PARTITION BY Region, Country_region_code ORDER BY Total_w_tax DESC) AS Sales_Rank
FROM
  Monthly_Sales ;






  --Query 2.4. Optimized (shorter) method
WITH
  Average_tax_rate AS (
  SELECT
    MAX(Sales_tax_rate.SalesTaxRateID) tax_rateID,
    ROUND(AVG(Sales_tax_rate.Taxrate),1) mean_tax_rate,
    State_province.CountryRegionCode,
    ROUND(COUNT(Sales_tax_rate.StateProvinceID) / COUNT (State_province.StateProvinceID),2) AS Perc_provinces_w_tax
  FROM
    `tc-da-1.adwentureworks_db.stateprovince` State_province
  LEFT JOIN
    `tc-da-1.adwentureworks_db.salestaxrate` Sales_tax_rate
  ON
    State_province.StateProvinceID = Sales_tax_rate.StateProvinceID
  GROUP BY
    CountryRegionCode),
  Monthly_Sales AS (
  SELECT
    LAST_DAY(CAST(Sales_order_header.OrderDate AS DATE)) AS Order_date,
    Sales_territory.CountryRegionCode AS Country_region_code,
    Sales_territory.Name AS Region,
    COUNT(Sales_order_header.SalesOrderID) AS No_of_orders,
    COUNT(DISTINCT Sales_order_header.CustomerID) AS No_of_customers,
    COUNT(DISTINCT Sales_order_header.SalesPersonID) AS No_of_salespersons,
    CAST (ROUND(SUM(Sales_order_header.TotalDue)) AS DECIMAL) AS Total_w_tax
  FROM
    `tc-da-1.adwentureworks_db.salesorderheader` AS Sales_order_header
  JOIN
    `tc-da-1.adwentureworks_db.salesterritory` AS Sales_territory
  ON
    Sales_order_header.TerritoryID = Sales_territory.TerritoryID
  GROUP BY
    Order_date,
    Country_region_code,
    Region)
SELECT
  Monthly_Sales.*,
  ROUND(SUM(Total_w_tax) OVER (PARTITION BY Country_region_code, Region ORDER BY Order_date)) AS Cumulative_total_w_tax,
  RANK() OVER(PARTITION BY Region, Country_region_code ORDER BY Total_w_tax DESC) AS Sales_Rank,
  Average_tax_rate.mean_tax_rate,
  Average_tax_rate.perc_provinces_w_tax
FROM
  Monthly_Sales
JOIN
  Average_tax_rate
ON
  Monthly_Sales.Country_region_code = Average_tax_rate.CountryRegionCode
ORDER BY
  Region DESC,
  Order_date; 






--Query 2.4 Method 2
WITH
  Tax_rate_by_province AS (
  SELECT
    
    MAX(Sales_tax_rate.SalesTaxRateID) Tax_rateID,
    Sales_tax_rate.Taxrate Tax_rate,
    Sales_tax_rate.Name Provinces,
    State_province.CountryRegionCode,
    State_province.StateProvinceCode
  FROM
    `tc-da-1.adwentureworks_db.salestaxrate` Sales_tax_rate
  JOIN
    `tc-da-1.adwentureworks_db.stateprovince` State_province
  ON
    Sales_tax_rate.StateProvinceID = State_province.StateProvinceID
  GROUP BY
    Tax_rate,
    Provinces,
    CountryRegionCode,
    StateProvinceCode),
  Average_tax_rate AS(
  SELECT
    CountryRegionCode,
    ROUND(AVG(Tax_rate),1) Mean_tax_rate,
    COUNT(DISTINCT StateProvinceCode) AS provinces_w_tax,
    (
    SELECT
      COUNT(DISTINCT StateProvinceCode)
    FROM
      `tc-da-1.adwentureworks_db.stateprovince` State_province
    WHERE
      CountryRegionCode = Tax_rate_by_province.CountryRegionCode) AS total_provinces
  FROM
    Tax_rate_by_province
  GROUP BY
    CountryRegionCode ),
  Monthly_Sales AS (
  SELECT
    LAST_DAY(CAST(Sales_order_header.OrderDate AS DATE)) AS Order_date,
    Sales_territory.CountryRegionCode AS Country_region_code,
    Sales_territory.Name AS Region,
    COUNT(Sales_order_header.SalesOrderID) AS No_of_orders,
    COUNT(DISTINCT Sales_order_header.CustomerID) AS No_of_customers,
    COUNT(DISTINCT Sales_order_header.SalesPersonID) AS No_of_salespersons,
    CAST (ROUND(SUM(Sales_order_header.TotalDue)) AS DECIMAL) AS Total_w_tax
  FROM
    `tc-da-1.adwentureworks_db.salesorderheader` AS Sales_order_header
  JOIN
    `tc-da-1.adwentureworks_db.salesterritory` AS Sales_territory
  ON
    Sales_order_header.TerritoryID = Sales_territory.TerritoryID
  GROUP BY
    Order_date,
    Country_region_code,
    Region)
SELECT
  Monthly_Sales.*,
  ROUND(SUM(Total_w_tax) OVER (PARTITION BY Country_region_code, Region ORDER BY Order_date)) AS Cumulative_total_w_tax,
  RANK() OVER(PARTITION BY Region, Country_region_code ORDER BY Total_w_tax DESC) AS Sales_Rank,
  Average_tax_rate.mean_tax_rate,
  ROUND(Average_tax_rate.provinces_w_tax / Average_tax_rate.total_provinces, 2) AS perc_provinces_w_tax
FROM
  Monthly_Sales
LEFT JOIN
  Average_tax_rate
ON
  Monthly_Sales.Country_region_code = Average_tax_rate.CountryRegionCode
ORDER BY
  Region DESC,
  Order_date;





