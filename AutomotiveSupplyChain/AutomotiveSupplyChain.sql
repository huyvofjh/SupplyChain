USE portfolio

--- Create shipments table for creating Dashboard in Power BI  
SELECT ProductID, 
	   CarMaker, 
	   CarModel, 
	   CarModelYear,
	   SupplierName,
	   CustomerName, 
	   Gender, 
	   JobTitle, 
	   CustomerFeedback,
	   City, 
	   state, 
	   Country,
	   CONVERT(DATE, OrderDate) AS OrderDate , 
	   CONVERT(DATE, ShipDate) AS ShipDate, 
	   CarPrice,
	   Quantity,
	   (CarPrice * Quantity) AS TotalSales, 
	   ShipMode, 
	   Shipping, 
	   CreditCardType
FROM portfolio..CarSupplyChain

--- Calculate the total days between order date and ship date 
SELECT OrderDate, 
	   ShipDate, 
	   DATEDIFF(DAY, OrderDate, ShipDate) AS TotalDays
FROM portfolio..CarSupplyChain

--- Because total days are negative in some rows, so we replace order date and ship date with each other 
UPDATE CarSupplyChain 
SET OrderDate = ShipDate, 
ShipDate = OrderDate 
WHERE DATEDIFF(DAY, OrderDate, ShipDate) < 0 

--- Show top car marker which has total sales most 
SELECT CarMaker, 
	   SUM(CarPrice * Quantity) AS TotalSales,
	   ROW_NUMBER() OVER(ORDER BY SUM(CarPrice * Quantity) DESC) AS Ranking 
FROM portfolio..CarSupplyChain
GROUP BY CarMaker 

--- Show top state which has total sales most 
SELECT State, 
	   COUNT(State) StateCount, 
	   SUM(CarPrice * Quantity) AS TotalSales, 
	   ROW_NUMBER() OVER(ORDER BY SUM(CarPrice * Quantity) DESC) AS Ranking 
FROM portfolio..CarSupplyChain
GROUP BY State 

--- Show which shipping method is a priority based on total sales 
SELECT Shipping, 
	   COUNT(Shipping) AS ShipModeCount, 
	   SUM(CarPrice * Quantity) AS TotalSales 
FROM portfolio..CarSupplyChain
GROUP BY Shipping

--- Show ship mode based on total sales 
SELECT ShipMode, 
	   COUNT(ShipMode) AS ShipModeCount, 
	   SUM(CarPrice * Quantity) AS TotalSales 
FROM portfolio..CarSupplyChain
GROUP BY ShipMode 

--- Show credit card type based on total sales 
SELECT CreditCardType, 
	   COUNT(CreditCardType) AS CreditCardCount, 
	   SUM(CarPrice * Quantity) AS TotalSales 
FROM portfolio..CarSupplyChain
GROUP BY CreditCardType 
ORDER BY 3 DESC 

--- Show the relationship between customer feedback and total delivery days
SELECT CustomerFeedback, 
	   AVG(DATEDIFF(DAY, OrderDate, ShipDate)) AS TotalDays, 
	   COUNT(CustomerFeedback) AS CustomerFeedBackCount, 
	   AVG(CarPrice * Quantity) AS TotalSales 
FROM portfolio..CarSupplyChain
GROUP BY CustomerFeedback 
ORDER BY 4 DESC 

--- Because customer feedback is devided into 5 group (Very Good, Good, Okay, Very Bad and Bad) and the results were quite similar 
--- So I grouped it into 3 group (Satisfied, Netural and Unsatisfied)
SELECT CASE WHEN CustomerFeedback = 'Very Good' THEN 'Satisfied' 
	        WHEN CustomerFeedback = 'Good' THEN 'Satisfied'
			WHEN CustomerFeedback = 'Okay' THEN 'Netural'
			WHEN CustomerFeedback = 'Very Bad' THEN 'Unsatisfied'
			WHEN CustomerFeedback = 'Bad' THEN 'Unsatisfied'
		END FeedBack, 
		OrderDate, 
		ShipDate, 
		CarPrice, 
		Quantity
INTO NewFeedback 
FROM portfolio..CarSupplyChain

--- Identify the impact of customer feedback to total sales
SELECT FeedBack, 
	   AVG(DATEDIFF(DAY, OrderDate, ShipDate)) AS TotalDays, 
	   COUNT(FeedBack) AS CustomerFeedBackCount, 
	   AVG(CarPrice * Quantity) AS TotalSales 
FROM master..NewFeedback
GROUP BY FeedBack
ORDER BY 4 DESC 