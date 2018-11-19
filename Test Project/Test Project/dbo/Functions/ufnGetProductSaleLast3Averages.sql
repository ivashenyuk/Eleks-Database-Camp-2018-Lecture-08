
create function dbo.ufnGetProductSaleLast3Averages(@ProductID int = -1)
returns @Results table (
	IDResult int not null identity(1,1)
	, ProductID int null
	, OrderDate datetime null
	, SalesOrderID int null
	, LineTotal float null
	, Last3AvgProductSalesTotal float null
)
as 
begin 
	insert @Results
	select rs.ProductID, rs.OrderDate, rs.SalesOrderID, rs.LineTotal, Last3AvgProductSalesTotal.Last3AvgProductSalesTotal from (
			select det.ProductID, hed.OrderDate,hed.SalesOrderID, det.LineTotal,
					rank() over (partition by det.ProductID order by hed.SalesOrderID desc) as RankResult from SalesLT.SalesOrderDetail as det
				inner join SalesLT.SalesOrderHeader as hed on hed.SalesOrderID = det.SalesOrderID
			where det.ProductID = isnull(nullif(@ProductID, -1), det.ProductID)
			group by  det.ProductID, hed.OrderDate,hed.SalesOrderID, det.LineTotal
		) as rs
		inner join (
					select rs.ProductID, avg(rs.LineTotal) as Last3AvgProductSalesTotal from (
						select det.ProductID, hed.OrderDate,hed.SalesOrderID, det.LineTotal,
								rank() over (partition by det.ProductID order by hed.SalesOrderID desc) as RankResult from SalesLT.SalesOrderDetail as det
							inner join SalesLT.SalesOrderHeader as hed on hed.SalesOrderID = det.SalesOrderID
						where det.ProductID = isnull(nullif(@ProductID, -1), det.ProductID)
						group by  det.ProductID, hed.OrderDate,hed.SalesOrderID, det.LineTotal
					) as rs where rs.RankResult <= 3
					group by rs.ProductID
				) as Last3AvgProductSalesTotal on (Last3AvgProductSalesTotal.ProductID = rs.ProductID)
		 where rs.RankResult <= 3
	return;
end;
