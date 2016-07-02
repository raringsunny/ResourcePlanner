USE [ResourceForecast]
GO

/****** Object:  UserDefinedFunction [dbo].[ExplodeDates]    Script Date: 7/2/2016 6:52:34 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[ExplodeDates](@startdate datetime, @enddate datetime)
returns table as
return (
with DateGen(AllocatedDate)
as
(
SELECT  DATEADD(DAY, nbr - 1, @StartDate)
FROM    ( SELECT    ROW_NUMBER() OVER ( ORDER BY c.object_id ) AS Nbr
          FROM      sys.columns c
        ) nbrs
WHERE   nbr - 1 <= DATEDIFF(DAY, @StartDate, @EndDate)
) select * from dategen
);
GO


