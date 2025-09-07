/****** Object:  StoredProcedure [dbo].[CreateRefreshToken]    Script Date: 9/7/2025 9:46:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Create
CREATE   PROCEDURE [dbo].[CreateRefreshToken]
    @Id UNIQUEIDENTIFIER,
    @UserId INT,
    @TokenHash NVARCHAR(256),
    @JwtId UNIQUEIDENTIFIER,
    @ExpiresAt DATETIME2,
    @OutputMessage NVARCHAR(4000) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        INSERT INTO RefreshTokens (Id, UserId, TokenHash, JwtId, ExpiresAt)
        VALUES (@Id, @UserId, @TokenHash, @JwtId, @ExpiresAt);
        SET @OutputMessage = 'Refresh token created.';
    END TRY
    BEGIN CATCH
        SET @OutputMessage = 'Error: ' + ERROR_MESSAGE();
    END CATCH
END
GO

/****** Object:  StoredProcedure [dbo].[CreateUser]    Script Date: 9/7/2025 9:46:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[CreateUser]
    @Username NVARCHAR(100),
    @PasswordHash NVARCHAR(255),
    @Role NVARCHAR(20),
    @Departments NVARCHAR(255) = NULL,
    @IsLocked BIT = 0,
    @OutputMessage NVARCHAR(4000) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM Users WHERE Username = @Username)
    BEGIN
        SET @OutputMessage = 'Error: Username already exists.';
        RETURN;
    END

    INSERT INTO Users (Username, PasswordHash, Role, Departments, IsLocked)
    VALUES (@Username, @PasswordHash, @Role, @Departments, @IsLocked);

    SET @OutputMessage = 'User created successfully.';
END
GO

/****** Object:  StoredProcedure [dbo].[GetDropDownOptions]    Script Date: 9/7/2025 9:46:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetDropDownOptions]
(
  @UserId    INT = NULL,
  @Dropdown  NVARCHAR(100) = NULL,
  @ParentIds dbo.IntList READONLY        -- ✅ no default
)
AS
BEGIN
  SET NOCOUNT ON;

  IF @Dropdown = N'Departments'
  BEGIN
      SELECT id AS Value, name AS Label
      FROM dbo.departments;
      RETURN;
  END;

  IF @Dropdown = N'SubDepartments'
  BEGIN
      IF EXISTS (SELECT 1 FROM @ParentIds)
      BEGIN
          SELECT id AS Value, name AS Label
          FROM dbo.departments
          WHERE parentid IN (SELECT Id FROM @ParentIds);
          RETURN;
      END;

      SELECT id AS Value, name AS Label
      FROM dbo.departments;
      RETURN;
  END;
END;
GO

/****** Object:  StoredProcedure [dbo].[GetProductsAndDepartments]    Script Date: 9/7/2025 9:46:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- NOTE: This procedure references a "Products" table which is not defined in the provided schema.
CREATE   PROCEDURE [dbo].[GetProductsAndDepartments]
  @DepartmentId INT = NULL,
  @UserId INT=Null
AS
BEGIN
  SET NOCOUNT ON;

  -- Result set 1
  SELECT Id, Name, Price, DepartmentId
  FROM Products
  WHERE (@DepartmentId IS NULL OR DepartmentId = @DepartmentId)

  -- Result set 2
  SELECT Id, Name FROM Departments
  WHERE (@DepartmentId IS NULL OR Id = @DepartmentId);
END
GO

/****** Object:  StoredProcedure [dbo].[GetRefreshTokenByHash]    Script Date: 9/7/2025 9:46:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Get by hash
CREATE   PROCEDURE [dbo].[GetRefreshTokenByHash]
    @TokenHash NVARCHAR(256)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT TOP 1 *
    FROM RefreshTokens
    WHERE TokenHash = @TokenHash;
END
GO

/****** Object:  StoredProcedure [dbo].[GetUserById]    Script Date: 9/7/2025 9:46:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetUserById]
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT Id, Username,  PasswordHash, Role
    FROM Users
    WHERE Id = @UserId;
END;
GO

/****** Object:  StoredProcedure [dbo].[GetUserByUsername]    Script Date: 9/7/2025 9:46:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetUserByUsername]
    @Username NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP (1)
        u.Id,
        u.Username,
        u.PasswordHash,
		U.Role AS Role,
		U.Departments,
        U.IsLocked AS IsLocked
    FROM dbo.Users u
    WHERE u.Username = @Username;
END
GO

/****** Object:  StoredProcedure [dbo].[GetUsers]    Script Date: 9/7/2025 9:46:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetUsers]
	@UserId INT=NULL
AS
BEGIN
	SELECT U.id AS Id,U.Username AS Username,U.role AS Role,D.name AS Departments, U.IsLocked as IsLocked FROM dbo.users u INNER JOIN 
	dbo.Departments d ON u.Departments=d.Id
END
GO

/****** Object:  StoredProcedure [dbo].[InsertErrorLog]    Script Date: 9/7/2025 9:46:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* ---------- Insert proc (used by logger) ---------- */
CREATE   PROCEDURE [dbo].[InsertErrorLog]
    @Operation     NVARCHAR(50)  = NULL,
    @ProcedureName NVARCHAR(255) = NULL,
    @Parameters    NVARCHAR(MAX) = NULL,
    @Message       NVARCHAR(MAX) = NULL,
    @StackTrace    NVARCHAR(MAX) = NULL,
    @UserName      NVARCHAR(256) = NULL,
    @RequestPath   NVARCHAR(512) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        INSERT dbo.ErrorLogs(Operation, ProcedureName, Parameters, Message, StackTrace, UserName, RequestPath)
        VALUES (@Operation, @ProcedureName, @Parameters, @Message, @StackTrace, @UserName, @RequestPath);
    END TRY
    BEGIN CATCH
        -- swallow to avoid recursive failure
        RETURN;
    END CATCH
END
GO

/****** Object:  StoredProcedure [dbo].[InsertIndicatorsBulk]    Script Date: 9/7/2025 9:46:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[InsertIndicatorsBulk]
    @Items dbo.IndicatorTableType READONLY,
	  @UserId INT=NULL,
    @OutputMessage NVARCHAR(4000) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        INSERT INTO dbo.Indicators (Name, DepartmentId, Value, EffectiveDate, CreatedBy)
        SELECT Name, DepartmentId, Value, EffectiveDate, CreatedBy
        FROM @Items;

        DECLARE @rows INT = @@ROWCOUNT;
        SET @OutputMessage = CONCAT('Inserted ', @rows, ' indicator(s).');
    END TRY
    BEGIN CATCH
        SET @OutputMessage = N'Error: ' + ERROR_MESSAGE();
    END CATCH
END
GO

/****** Object:  StoredProcedure [dbo].[InsertProduct]    Script Date: 9/7/2025 9:46:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- NOTE: This procedure references a "Products" table which is not defined in the provided schema.
CREATE   PROCEDURE [dbo].[InsertProduct]
    @Name          NVARCHAR(100),
    @Price         DECIMAL(18,2),
    @DepartmentId  INT,
    @OutputMessage NVARCHAR(4000) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF @DepartmentId IS NULL
    BEGIN
        SET @OutputMessage = N'Error: DepartmentId is required.';
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM dbo.Departments WHERE Id = @DepartmentId)
    BEGIN
        SET @OutputMessage = N'Error: Department not found.';
        RETURN;
    END

    BEGIN TRY
        INSERT dbo.Products (Name, Price, DepartmentId)
        VALUES (@Name, @Price, @DepartmentId);

        SET @OutputMessage = N'Product inserted successfully.';
    END TRY
    BEGIN CATCH
        SET @OutputMessage = N'Error: ' + ERROR_MESSAGE();
    END CATCH
END
GO

/****** Object:  StoredProcedure [dbo].[PurgeOldErrorLogs]    Script Date: 9/7/2025 9:46:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[PurgeOldErrorLogs]
AS
BEGIN
  -- Your logic here, e.g.:
  DELETE FROM ErrorLogs
  WHERE Loggedat < DATEADD(DAY, -30, GETDATE());
END;
GO

/****** Object:  StoredProcedure [dbo].[RevokeAllRefreshTokensForUser]    Script Date: 9/7/2025 9:46:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Revoke ALL refresh tokens for a user (optional but recommended)
CREATE   PROCEDURE [dbo].[RevokeAllRefreshTokensForUser]
    @UserId INT,
    @OutputMessage NVARCHAR(4000) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        UPDATE dbo.RefreshTokens
        SET RevokedAt = SYSUTCDATETIME()
        WHERE UserId = @UserId AND RevokedAt IS NULL;

        SET @OutputMessage = N'All refresh tokens revoked for user.';
    END TRY
    BEGIN CATCH
        SET @OutputMessage = N'Error: ' + ERROR_MESSAGE();
    END CATCH
END
GO

/****** Object:  StoredProcedure [dbo].[RevokeRefreshToken]    Script Date: 9/7/2025 9:46:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Revoke (optionally link replacement)
CREATE   PROCEDURE [dbo].[RevokeRefreshToken]
    @Id UNIQUEIDENTIFIER,
    @ReplacedByTokenId UNIQUEIDENTIFIER = NULL,
    @OutputMessage NVARCHAR(4000) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        UPDATE RefreshTokens
        SET RevokedAt = SYSUTCDATETIME(),
            ReplacedByTokenId = @ReplacedByTokenId
        WHERE Id = @Id;

        IF @@ROWCOUNT = 0
        BEGIN
            SET @OutputMessage = 'Error: refresh token not found.';
            RETURN;
        END

        SET @OutputMessage = 'Refresh token revoked.';
    END TRY
    BEGIN CATCH
        SET @OutputMessage = 'Error: ' + ERROR_MESSAGE();
    END CATCH
END
GO

/****** Object:  StoredProcedure [dbo].[UpdateUserPassword]    Script Date: 9/7/2025 9:46:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Update password hash for a user
CREATE   PROCEDURE [dbo].[UpdateUserPassword]
    @Id INT,
    @PasswordHash NVARCHAR(255),
    @OutputMessage NVARCHAR(4000) OUTPUT,
	@UserId INT=NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE Id = @Id)
        BEGIN
            SET @OutputMessage = N'Error: User not found.';
            RETURN;
        END

        UPDATE dbo.Users
        SET PasswordHash = @PasswordHash
        WHERE Id = @Id;

        SET @OutputMessage = N'Password changed successfully.';
    END TRY
    BEGIN CATCH
        SET @OutputMessage = N'Error: ' + ERROR_MESSAGE();
    END CATCH
END
GO

/****** Object:  StoredProcedure [dbo].[Users_GetById]    Script Date: 9/7/2025 9:46:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[Users_GetById]
@Id  INT,
@UserId INT
AS
BEGIN
SELECT u.id,username,role,u.Departments AS Departments, u.IsLocked  FROM dbo.Users u INNER JOIN dbo.Departments d ON U.Departments = d.Id 
WHERE u.id=@Id
end 
GO

/****** Object:  StoredProcedure [dbo].[Users_Insert]    Script Date: 9/7/2025 9:46:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Users_Insert]
    @Username NVARCHAR(50),
    @Password NVARCHAR(100),
    @Role NVARCHAR(50),
    @Department INT,
    @IsLocked BIT, 
    @UserId INT = NULL,
    @OutputMessage NVARCHAR(MAX) OUTPUT
AS
BEGIN
    -- Insert user
    -- Then insert multiple departments
    INSERT INTO users (username, PasswordHash, Role, Departments, IsLocked)
    VALUES (@Username, @Password, @Role, @Department, @IsLocked)

    SET @OutputMessage = 'record inserted successfully'
END
GO

/****** Object:  StoredProcedure [dbo].[Users_Update]    Script Date: 9/7/2025 9:46:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROC [dbo].[Users_Update]
  @Username NVARCHAR(50),
  @Password NVARCHAR(100)=NULL,
  @Role NVARCHAR(50),
  @Departments INT,
  @IsLocked BIT = 0,                -- new parameter
  @UserId INT = NULL,
  @OutputMessage NVARCHAR(MAX) OUTPUT,
  @Id INT
AS
BEGIN
  SET NOCOUNT ON;
  IF @Password IS NULL OR @Password='' 
  BEGIN 
    UPDATE dbo.Users
    SET Username     = @Username,
        Role         = @Role,
        Departments  = @Departments,
        IsLocked     = @IsLocked      -- update lock status
    WHERE Id = @Id;
  END
  ELSE
  BEGIN
    UPDATE dbo.Users
    SET Username     = @Username,
        PasswordHash = @Password,
        Role         = @Role,
        Departments  = @Departments,
        IsLocked     = @IsLocked      -- update lock status
    WHERE Id = @Id;
  END 

  SET @OutputMessage = 'record updated successfully';
END
GO