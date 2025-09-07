ALTER TABLE [dbo].[Calendars]
ADD
    MonthShortLabel NVARCHAR(10) NOT NULL DEFAULT(''),
    QuarterShortLabel NVARCHAR(10) NOT NULL DEFAULT(''),
    YearQuarterLabel NVARCHAR(20) NOT NULL DEFAULT(''),
    MonthYearLabel NVARCHAR(20) NOT NULL DEFAULT('');

UPDATE Calendars
SET
    MonthShortLabel = LEFT(MonthName, 3),
    QuarterShortLabel = CONCAT('Q', Quarter),
    YearQuarterLabel = CONCAT('Q', Quarter, '/', Year),
    MonthYearLabel = CONCAT(LEFT(MonthName, 3), '/', Year);