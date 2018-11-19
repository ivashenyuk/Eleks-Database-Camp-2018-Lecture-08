CREATE TABLE [dbo].[DBVersion]
(
	DBVersion nchar(5) primary key not null
	, StartDate datetime not null
	, EndData	datetime null
)