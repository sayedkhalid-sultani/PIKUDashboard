// Models/Auth/UserDtos.cs
namespace GenericMinimalApi.Models.Auth
{
    public record UserRegisterDto(string Username, string Password, string Role, int Departments);
    public record UserLoginDto(string Username, string Password);
    public record RefreshRequestDto(string RefreshToken);

    // DB result for Users table (raw)
    public class UserRecord
    {
        public int Id { get; set; }
        public string Username { get; set; } = string.Empty;
        public string PasswordHash { get; set; } = string.Empty;
        public string Role { get; set; } = "Viewer"; // Admin | Manager | Viewer
        public string? Departments { get; set; }     // e.g. "1,2"
    }

    // DB result for RefreshTokens table
    public class RefreshTokenRecord
    {
        public Guid Id { get; set; }
        public int UserId { get; set; }
        public string TokenHash { get; set; } = string.Empty;
        public Guid JwtId { get; set; }
        public DateTime ExpiresAt { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? RevokedAt { get; set; }
        public Guid? ReplacedByTokenId { get; set; }
    }

    public sealed class LoginResultDto
    {
        public required string Token { get; init; }
        public required string[] Roles { get; init; }
        public required string[] Departments { get; init; }
        public required UserMiniDto User { get; init; }
    }

    public sealed class UserMiniDto
    {
        public int Id { get; init; }
        public string Username { get; init; } = "";
        public string? DisplayName { get; init; }
        public string? Email { get; init; }
    }

    // ---------- App DTOs for CRUD ----------

    // CREATE: multi-selects → TVP handled automatically by your mapper
    public record CreateUserDto(
        string Username,
        string Password,
        string Role,
        int Department
    );

    // UPDATE: same shape (Password could be nullable if you want optional)
public record UpdateUserDto(string Username, string Password, string Role, int Departments);

    // READ: what your GET returns (adjust to your columns)
    public class UserReadDto
    {
        public int Id { get; set; }
        public string Username { get; set; } = "";
        public string Role { get; set; } = "";

        public string Departments { get; set; } = "";

    }

    // FILTER for GET /users/search
    // NOTE: Properties named "Departments"/"SubDepartments" and any "*Ids" IEnumerable<int>
    // are auto-sent as TVP (dbo.IntList) by your extension.
    public class UserFilterDto
    {
        public string? Search { get; set; }
        public IEnumerable<int>? Departments { get; set; }
        
    }
}
