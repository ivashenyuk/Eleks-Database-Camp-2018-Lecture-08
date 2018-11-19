
-- task 6b
create function dbo.ufnGetProductSaleMarks(@ProductID int = -1)
returns  @Results table (
		ID int not null identity(1,1) primary key
		, lineTotalCurrent float null
		, dateOrder datetime null
		, orderId int null
		, productIDCurrent int null
		, LocalMark varchar(50) null
		, TotalMark varchar(50) null
	)
with execute as caller
as
begin
	declare cursorProducts cursor fast_forward for
		select 	pp.SalesOrderDetailID
				, currentValue.SalesOrderDetailID
				, pp.LineTotal
				, currentValue.LineTotal
				, pp.ModifiedDate
				, currentValue.ModifiedDate
				, pp.ProductID
				, currentValue.ProductID
				, (select top 1 OrderDate from SalesLT.SalesOrderHeader as sl where sl.SalesOrderID = currentValue.SalesOrderID) as ProductSalesOrderDateCurrent
				, res.SalesOrderID as SalesOrderID
			from SalesLT.SalesOrderDetail as currentValue
		cross apply  (select * from SalesLT.SalesOrderDetail where SalesOrderDetailID = currentValue.SalesOrderDetailID-1) as pp
		cross apply (select * from SalesLT.SalesOrderDetail as sales where sales.ProductID = pp.ProductID) as res

	open cursorProducts 

	declare @idPrev int
		, @idCurrent int
		, @lineTotalPrev float
		, @lineTotalCurrent float
		, @datePrev datetime
		, @dateCurrent datetime
		, @productIDPrev int
		, @productIDCurrent int
		, @dateOrder datetime
		, @orderId int
		, @localMark varchar(50)
		, @totalMark varchar(50)

	fetch next from cursorProducts 
		into @idPrev
			, @idCurrent
			, @lineTotalPrev
			, @lineTotalCurrent
			, @datePrev
			, @dateCurrent
			, @productIDPrev
			, @productIDCurrent
			, @dateOrder
			, @orderId

	declare @ResultsTable table (
		idPrev int null
		, idCurrent int null
		, lineTotalPrev float null
		, lineTotalCurrent float null
		, datePrev datetime null
		, dateCurrent datetime null
		, dateOrder datetime null
		, orderId int null
		, productIDCurrent int null
		, LocalMark varchar(50) null
		, TotalMark varchar(50) null
	)

	while @@FETCH_STATUS = 0
	begin 
		if ( DATEDIFF(second, @dateCurrent, @datePrev) <= 0)
			begin
				if(DATEDIFF(second, @dateCurrent, @datePrev) = 0 and @idCurrent < @idPrev)
					set @localMark = '«Go Up!»';
				else
					set @localMark = '«Go Down!:(»';
			end;
		else 
				set @localMark = '«Go Up!»';

		if(@lineTotalCurrent > @lineTotalPrev)
			set @totalMark = '«Total Go Up!»'
		else 
			set @totalMark = '«Total Go Down!:(»'

		insert into @ResultsTable(
			  idPrev
			, idCurrent
			, lineTotalPrev
			, lineTotalCurrent
			, datePrev
			, dateCurrent
			, dateOrder
			, orderId
			, productIDCurrent
			, LocalMark
			, TotalMark) 
			values (
				@idPrev
				, @idCurrent
				, @lineTotalPrev
				, @lineTotalCurrent
				, @datePrev
				, @dateCurrent
				, @dateOrder
				, @orderId
				, @productIDCurrent
				, @localMark
				, @totalMark)
		fetch next from cursorProducts 
		into @idPrev
			, @idCurrent
			, @lineTotalPrev
			, @lineTotalCurrent
			, @datePrev
			, @dateCurrent
			, @productIDPrev
			, @productIDCurrent
			, @dateOrder
			, @orderId
	end;

	close cursorProducts;
	deallocate cursorProducts;

	insert into @Results (
		 lineTotalCurrent
		, dateOrder
		, orderId
		, productIDCurrent
		, LocalMark 
		, TotalMark
	)
		select lineTotalCurrent as ProductSalesLineTotal
				, dateOrder as ProductSalesOrderDate
				, orderId as SalesOrderID
				, productIDCurrent as ProductID			
				, LocalMark
				, TotalMark from @ResultsTable where productIDCurrent = isnull(nullif(@ProductID, (-1)), productIDCurrent);
	return
end;
