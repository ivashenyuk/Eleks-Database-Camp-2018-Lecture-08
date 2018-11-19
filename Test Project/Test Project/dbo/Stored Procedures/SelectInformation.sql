
-- stored procedure
create procedure SelectInformation (
	@ListCountries varchar(max) = '',
	@TypeAddress varchar(50) = null,
	@City varchar(65) = null,
	@MinCountOffice int = 0
)
 as 
 begin
		
		select distinct(City), StateProvince, countOffice, CountryRegion from SalesLT.CustomerAddress as cusAddr
		outer apply (
			select  City, StateProvince, CountryRegion from SalesLT.Address as addr where addr.AddressID = cusAddr.AddressID
		) as app
		outer apply (
			select count(*) as countOffice from SalesLT.Address as countOff 
				where countOff.City = isnull(@City, app.City) or countOff.City = isnull(nullif(@City, ''), app.City)
				group by City
				having count(City) > @MinCountOffice
		) as app1
		where AddressType = isnull(nullif(@TypeAddress, ''), AddressType)
		and countOffice is not null
		and (isnull(@ListCountries,  app.CountryRegion) like '%'+ app.CountryRegion+'%' or 
		isnull(nullif(@ListCountries, ''),  app.CountryRegion) like '%'+ app.CountryRegion+'%')
		order by StateProvince, City
end;
