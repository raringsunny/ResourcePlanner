USE [ResourceForecast]
GO

/****** Object:  Table [dbo].[ResourceAllocation]    Script Date: 7/2/2016 6:50:58 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[ResourceAllocation](
	[AssociateId] [varchar](50) NULL,
	[AssociateName] [varchar](50) NULL,
	[Project] [varchar](50) NULL,
	[AllocationStartDate] [date] NULL,
	[AllocationEndDate] [date] NULL,
	[Skills] [varchar](20) NULL,
	[COE] [varchar](50) NULL,
	[Fulfilled] [char](1) NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


