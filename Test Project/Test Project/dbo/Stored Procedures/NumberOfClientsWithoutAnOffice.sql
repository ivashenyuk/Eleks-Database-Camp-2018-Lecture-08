create procedure NumberOfClientsWithoutAnOffice 
	@TypeAddress nvarchar(50) = null,
	@Contry nvarchar(50) = null
as 
	set nocount on;

	select count(*) as 'Number of clients without an office in Canada' from SalesLT.CustomerAddress as cusAddre
	outer apply (
		select * from SalesLT.Address as addr where addr.AddressID = cusAddre.AddressID 
	) as app
	where AddressType = isnull(@TypeAddress, AddressType) and not app.CountryRegion = isnull(@Contry, '')
