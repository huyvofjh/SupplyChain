USE portfolio

--- Create view 
CREATE VIEW SupplyChain AS 
SELECT [Order Id] AS OrderId, 
	   [Product Name] AS ProductName, 
	   [Category Name] AS CategoryName, 
	   CAST([order date (DateOrders)] AS DATE)  AS OrderDate, 
	   CAST([shipping date (DateOrders)] AS DATE) AS ShippingDate, 
	   [Days for shipment (scheduled)] AS 'TotalShippingDays(scheduled)', 
	   [Days for shipping (real)] AS 'TotalShippingDays(actual)', 
	   Type, 
	   [Shipping Mode] AS ShippingMode, 
	   [Delivery Status] AS DeliveryStatus, 
	   CASE WHEN Late_delivery_risk = 1 THEN 'Yes'
			ELSE 'No'
	   END AS LateDeliveryRisk,
	   [Order City] AS OrderCity,
	   CASE WHEN [Order Country] = 'Estados Unidos' THEN 'United States'
		    WHEN [Order Country] = 'Francia' THEN 'France'
			WHEN [Order Country] = 'Alemania' THEN 'Germany'
			WHEN [Order Country] = 'Reino Unido' THEN 'United Kingdom'
	   ELSE [Order Country] 
	   END AS OrderCountry, 
	   [Order Region] AS OrderRegion, 
	   Market, 
	   [Customer Segment] AS CustomerSegment, 
	   [Department Name] AS DepartmentName, 
	   [Product Price] AS ProductPrice, 
	   [Order Item Quantity] AS Quantity, 
	   Sales, 
	   [Order Profit Per Order] AS Profit
FROM SupplyChainDataset

--- Compare average scheduled shipping days and average actual shipping days by delivery status 
SELECT DeliveryStatus, 
	   ROUND(AVG([TotalShippingDays(scheduled)]),2) AS Schedule, 
	   ROUND(AVG([TotalShippingDays(actual)]),2) AS Actual
FROM SupplyChain
GROUP BY DeliveryStatus

--- Show total sales, percentage sales per category and ranking.  
SELECT CategoryName, 
	   SUM(Sales) AS CategorySales, 
	   ROUND((SUM(Sales) / (SELECT SUM(Sales) FROM SupplyChain)) *100,2) AS Percentage, 
	   ROW_NUMBER() OVER(ORDER BY SUM(Sales) DESC) AS Rank
FROM SupplyChain
GROUP BY CategoryName

--- Show percentage total orders by type of payment 
SELECT DISTINCT Type, 
	   ROUND(CAST(COUNT(Type) OVER(PARTITION BY Type) AS FLOAT) / (SELECT COUNT(Type) FROM SupplyChain) * 100,2) '%Pct'
FROM SupplyChain
ORDER BY 2 DESC 

--- Show percentage total orders sold by shipping mode 
SELECT DISTINCT ShippingMode, 
	   ROUND(CAST(COUNT(ShippingMode) OVER(PARTITION BY ShippingMode) AS FLOAT) / (SELECT COUNT(ShippingMode) FROM SupplyChain ) *100,2) '%Pct'
FROM SupplyChain
ORDER BY 2 DESC 

--- Show percentage total orders sold by delivery status
SELECT DISTINCT DeliveryStatus, 
	   ROUND(CAST(COUNT(DeliveryStatus) OVER(PARTITION BY DeliveryStatus) AS FLOAT) / (SELECT COUNT(DeliveryStatus) FROM SupplyChain ) *100,2) '%Pct'
FROM SupplyChain
ORDER BY 2 DESC 

--- Show percentage late delivery risk 
SELECT DISTINCT LateDeliveryRisk, 
	   ROUND(CAST(COUNT(LateDeliveryRisk) OVER(PARTITION BY LateDeliveryRisk)AS FLOAT) / (SELECT COUNT(LateDeliveryrisk) FROM SupplyChain) *100,2) '%Pct'
FROM SupplyChain
ORDER BY 2 DESC 

--- Show percentage total orders sold by customer segment 
SELECT DISTINCT CustomerSegment, 
	   ROUND(CAST(COUNT(CustomerSegment) OVER(PARTITION BY CustomerSegment) AS FLOAT) / (SELECT COUNT(CustomerSegment) FROM SupplyChain ) *100,2) '%Pct'
FROM SupplyChain
ORDER BY 2 DESC 

--- Show total sales, percentage sales per country and ranking.  
SELECT OrderCountry, 
	   SUM(Sales) AS CountrySales, 
	   ROUND((SUM(Sales) / (SELECT SUM(Sales) FROM SupplyChain)) *100,2) AS Percentage, 
	   ROW_NUMBER() OVER(ORDER BY SUM(Sales) DESC) AS Rank
FROM SupplyChain
GROUP BY OrderCountry

--- Show total sales, percentage sales per region and ranking.  
SELECT OrderRegion, 
	   SUM(Sales) AS RegionSales, 
	   ROUND((SUM(Sales) / (SELECT SUM(Sales) FROM SupplyChain)) *100,2) AS Percentage, 
	   ROW_NUMBER() OVER(ORDER BY SUM(Sales) DESC) AS Rank
FROM SupplyChain
GROUP BY OrderRegion

--- Show total sales, percentage sales per market and ranking.  
SELECT Market, 
	   SUM(Sales) AS RegionSales, 
	   ROUND((SUM(Sales) / (SELECT SUM(Sales) FROM SupplyChain)) *100,2) AS Percentage, 
	   ROW_NUMBER() OVER(ORDER BY SUM(Sales) DESC) AS Rank
FROM SupplyChain
GROUP BY Market