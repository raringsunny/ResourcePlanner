use ResourceForecast
go

Declare @WeekStartDate varchar(10) = '07/01/2016'
Declare @WeekEndDate varchar(10) = '07/31/2016';

WITH 
ResourceSkills(Skills) AS
(
	SELECT DISTINCT Skills FROM [ResourceAllocation-2]
), --select * from ResourceSkills

WeekEndingCTE(Skills, WeekDate) AS
(
	SELECT Skills, AllocatedDate FROM ResourceSkills a CROSS APPLY dbo.ExplodeDates(@WeekStartDate, @WeekEndDate)  b 
), --SELECT * FROM WeekEndingCTE
ResourceMaster(AssociateName, Project, Skills, AllocationStartDate, AllocationEndDate, FulFilled) as
(
	SELECT AssociateName, Project, Skills, AllocationStartDate, AllocationEndDate, FulFilled 
	FROM [ResourceAllocation-2] a
),
RequireCnt(Skills, WeekDate, ReqCnt) as
( 
	SELECT Skills, WeekDate, SUM(RequireCnt)
	FROM (SELECT b.Skills, WeekDate, 
		CASE WHEN b.WeekDate BETWEEN a.AllocationStartDate AND a.AllocationEndDate
			THEN 
				COUNT(*)
			ELSE
				0
			END AS RequireCnt
		
		FROM ResourceMaster a RIGHT OUTER JOIN WeekEndingCTE b
		on a.skills = b.skills
		and b.WeekDate between a.AllocationStartDate and a.AllocationEndDate
		AND Fulfilled = 'U' 
		
		GROUP BY b.Skills, WeekDate, AllocationStartDate, AllocationEndDate
	) a GROUP BY Skills, WeekDate
), --SELECT * FROM RequireCnt WHERE Skills = '.Net'

ReleaseCnt(Skills, WeekDate, ReleaseCnt) as
(
	SELECT Skills, WeekDate, SUM(ReleaseCnt)
	FROM (SELECT b.Skills, WeekDate, 
		CASE WHEN b.WeekDate = a.AllocationEndDate
			THEN 
				COUNT(*)
			ELSE
				0
			END AS ReleaseCnt
		
		FROM ResourceMaster a RIGHT OUTER JOIN WeekEndingCTE b
		on a.Skills = b.Skills
		and b.WeekDate between a.AllocationStartDate and a.AllocationEndDate

		AND Fulfilled = 'A' 
		--AND a.Skills = '.Net'
		GROUP BY b.Skills, WeekDate, AllocationStartDate, AllocationEndDate
	) b GROUP BY Skills, WeekDate
), -- SELECT Skills, WeekDate, ReleaseCnt FROM ReleaseCnt 

BenchCnt(Skills, WeekDate, BenchCnt) as
(
	SELECT Skills, WeekDate, SUM(BenchCnt)
	FROM (SELECT b.Skills, WeekDate, 
		CASE WHEN b.WeekDate BETWEEN a.AllocationStartDate AND a.AllocationEndDate
			THEN
				COUNT(*)
			ELSE
				0
			END AS BenchCnt
		
		FROM ResourceAllocation a RIGHT OUTER JOIN WeekEndingCTE b
		on b.Skills = a.Skills
		AND Fulfilled = 'B' 
		--AND a.Skills = '.Net'
		AND a.Project = 'Bench'
		GROUP BY b.Skills, WeekDate, AllocationStartDate, AllocationEndDate
	) a GROUP BY Skills, WeekDate
) --SELECT Skills, WeekDate, BenchCnt FROM BenchCnt

SELECT b.Skills, b.WeekDate, b.ReqCnt, c.ReleaseCnt, d.BenchCnt, (d.BenchCnt - b.ReqCnt) Available
	--FROM ResourceMaster a 
	--FULL OUTER JOIN 
	FROM RequireCnt b INNER JOIN ReleaseCnt c  
		--ON a.Skills = b.Skills
		--AND a.AllocationStartDate = b.WeekDate
		ON b.WeekDate = c.WeekDate
		and b.Skills = c.Skills
	INNER JOIN BenchCnt d 
		on c.WeekDate = d.WeekDate
		and c.Skills = d.Skills
		--where b.skills = '.Net'
