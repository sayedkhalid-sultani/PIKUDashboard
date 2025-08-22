ALTER   PROC [dbo].[PurgeOldErrorLogs]
  @CutoffUtc DATETIME2,
  @OutputMessage   NVARCHAR(4000) OUTPUT
AS
BEGIN
  SET NOCOUNT ON;

  DECLARE @Deleted INT;

  -- Adjust table/column names to your schema
  DELETE FROM dbo.ErrorLogs
  WHERE LoggedAt < @CutoffUtc;

  SET @Deleted = @@ROWCOUNT;

  SET @OutputMessage = CONCAT(
      'Deleted ', @Deleted,
      ' old error log row(s) older than ',
      CONVERT(VARCHAR(33), @CutoffUtc, 126),
      ' UTC.'
  );
END

GO