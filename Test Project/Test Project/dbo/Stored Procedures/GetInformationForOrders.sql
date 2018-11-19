--procedure
create procedure GetInformationForOrders (
	@ListOfContries nvarchar(max) = null,
	@ListOfCategories nvarchar(max) = null,
	@TypeLocation nvarchar(100) = null,
	@MinCountOfProductsSale int = null
)
as 
begin
	select addr.CountryRegion, category.Name, addr.StateProvince, addr.City, count(ordersDetails.SalesOrderID) as CountProducts from SalesLT.Customer as customer
		inner join SalesLT.CustomerAddress as cusAddr on cusAddr.CustomerID = customer.CustomerID
		inner join SalesLT.Address as addr on addr.AddressID = cusAddr.AddressID 
			and isnull(nullif(@ListOfContries, ''), addr.CountryRegion) like '%'+addr.CountryRegion+'%'
			and (isnull(nullif(@TypeLocation, ''), addr.City) like '%'+addr.City+'%' 
				or isnull(nullif(@TypeLocation, ''), addr.StateProvince) like '%'+addr.StateProvince+'%')

			outer apply ( --inner join SalesLT.SalesOrderHeader as ordersHeaders on ordersHeaders.CustomerID = cusAddr.CustomerID 
				select * from SalesLT.SalesOrderHeader where CustomerID = cusAddr.CustomerID
			) as ordersHeaders
			outer apply ( --inner join SalesLT.SalesOrderDetail as ordersDetails on ordersDetails.SalesOrderID = ordersHeaders.SalesOrderID
				select * from SalesLT.SalesOrderDetail
					where SalesOrderID = ordersHeaders.SalesOrderID 
					group by SalesOrderID, SalesOrderDetailID, OrderQty, ProductID, UnitPrice, UnitPriceDiscount, LineTotal, rowguid, ModifiedDate
			) as ordersDetails

			inner join SalesLT.Product as product on product.ProductID = ordersDetails.ProductID
			inner join SalesLT.ProductCategory as category on category.ProductCategoryID = product.ProductCategoryID 
				and isnull(nullif(@ListOfCategories, ''), category.Name) like '%'+category.Name+'%'

	group by ordersHeaders.CustomerID, addr.CountryRegion, category.Name, ordersDetails.SalesOrderID, addr.StateProvince, addr.City
	having COUNT(ordersHeaders.CustomerID) = isnull(@MinCountOfProductsSale, COUNT(ordersHeaders.CustomerID))
end;
