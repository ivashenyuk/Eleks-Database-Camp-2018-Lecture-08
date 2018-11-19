CREATE AGGREGATE [dbo].[StrSumEx](@glomalStringForFormat NVARCHAR (MAX) NULL, @stringForFormat NVARCHAR (MAX) NULL, @splitter NVARCHAR (MAX) NULL, @arrayWithData [dbo].[SqlArray] NULL, @nameType NVARCHAR (MAX) NULL)
    RETURNS NVARCHAR (MAX)
    EXTERNAL NAME [AggStringUtil2].[AggStringUtil2.SqlAggregateTwoStrings];

