using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using GenericMinimalApi.Helpers;
using GenericMinimalApi.Models;
using GenericMinimalApi.Models.Auth;
using GenericMinimalApi.Services;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;
using Microsoft.IdentityModel.Tokens;
using System.Linq;

namespace GenericMinimalApi.Extensions
{
    public static class AuthEndpointExtensions
    {
        public static void MapAuthEndpoints(this IEndpointRouteBuilder app)
        {
            var group = app.MapGroup("/auth");

            // POST /auth/register
            group.MapPost("/register", async (UserRegisterDto dto, IDapperService dapper) =>
            {
                var existing = await dapper.QuerySingleAsync<UserRecord>("GetUserByUsername", new { dto.Username });
                if (existing is not null)
                    return Results.BadRequest(ApiResponse<object>.FailSingle("Username already exists."));

                var hash = PasswordHasher.Hash(dto.Password);

                var (success, message) = await dapper.ExecuteWithOutputAsync("CreateUser", new
                {
                    dto.Username,
                    PasswordHash = hash,
                    dto.Role,
                    dto.Departments,
                    dto.IsLocked

                });

                return success
                    ? Results.Ok(ApiResponse<object>.Ok(new { dto.Username, dto.Role, dto.Departments, dto.IsLocked }, message))
                    : Results.BadRequest(ApiResponse<object>.FailSingle(message));
            })
            .WithValidation<UserRegisterDto>();

            // POST /auth/login  -> returns access & refresh + roles + departments
            group.MapPost("/login", async (UserLoginDto dto, IDapperService dapper, IConfiguration cfg) =>
            {
                var user = await dapper.QuerySingleAsync<UserRecord>("GetUserByUsername", new { dto.Username });
                if (user is null || !PasswordHasher.Verify(dto.Password, user.PasswordHash))
                {
                    return Results.Json(ApiResponse<object>.FailSingle("Invalid username or password."),
                        statusCode: StatusCodes.Status401Unauthorized);
                }
                // Check if user is locked
                if (user.IsLocked)
                {
                    return Results.Json(ApiResponse<object>.FailSingle("User account is locked."),
                        statusCode: StatusCodes.Status403Forbidden);
                }

                // normalize roles (single role in model, but allow CSV just in case)
                var roles = (user.Role ?? string.Empty)
                    .Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries)
                    .ToArray();

                // normalize departments as array (from CSV)
                var departments = (user.Departments ?? string.Empty)
                    .Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries)
                    .ToArray();

                // Create access token (with jti)
                var accessMinutes = int.TryParse(cfg["Tokens:AccessMinutes"], out var m) ? m : 60;
                var jti = Guid.NewGuid();
                var accessToken = IssueJwt(user, cfg, jti, DateTime.UtcNow.AddMinutes(accessMinutes));

                // Create refresh token (opaque) + store hash
                var refreshDays = int.TryParse(cfg["Tokens:RefreshDays"], out var d) ? d : 7;
                var refreshToken = RefreshTokenHelper.GenerateToken();
                var refreshHash = RefreshTokenHelper.Sha256(refreshToken);
                var refreshExpires = DateTime.UtcNow.AddDays(refreshDays);

                var (ok, msg) = await dapper.ExecuteWithOutputAsync("CreateRefreshToken", new
                {
                    Id = Guid.NewGuid(),
                    UserId = user.Id,
                    TokenHash = refreshHash,
                    JwtId = jti,
                    ExpiresAt = refreshExpires
                });

                if (!ok)
                    return Results.BadRequest(ApiResponse<object>.FailSingle(msg));

                // include roles & departments in response (and token alias for compatibility)
                return Results.Ok(ApiResponse<object>.Ok(new
                {
                    token = accessToken,           // alias for clients expecting "token"
                    accessToken,
                    accessExpires = DateTime.UtcNow.AddMinutes(accessMinutes),
                    refreshToken,
                    refreshExpires,
                    roles,
                    departments,
                    user = new
                    {
                        id = user.Id,
                        username = user.Username
                        // add displayName/email if you add those columns later
                    }
                }, "Login successful."));
            })
            .WithValidation<UserLoginDto>()
            .RequireRateLimiting(RateLimitingExtensions.AuthLoginTight);

            // POST /auth/refresh  -> accepts refreshToken, rotates, returns new pair (same shape + roles/departments)
            group.MapPost("/refresh", async (RefreshRequestDto dto, IDapperService dapper, IConfiguration cfg) =>
            {
                var hash = RefreshTokenHelper.Sha256(dto.RefreshToken);

                var token = await dapper.QuerySingleAsync<RefreshTokenRecord>("GetRefreshTokenByHash", new { TokenHash = hash });
                if (token is null)
                    return Results.Json(ApiResponse<object>.FailSingle("Invalid refresh token."),
                        statusCode: StatusCodes.Status401Unauthorized);

                if (token.RevokedAt is not null)
                    return Results.Json(ApiResponse<object>.FailSingle("Refresh token has been revoked."),
                        statusCode: StatusCodes.Status401Unauthorized);

                if (token.ExpiresAt <= DateTime.UtcNow)
                    return Results.Json(ApiResponse<object>.FailSingle("Refresh token has expired."),
                        statusCode: StatusCodes.Status401Unauthorized);

                // Load user
                var user = await dapper.QuerySingleAsync<UserRecord>("GetUserById", new { UserId = token.UserId });
                if (user is null)
                    return Results.Json(ApiResponse<object>.FailSingle("User not found."),
                        statusCode: StatusCodes.Status401Unauthorized);

                var roles = (user.Role ?? string.Empty)
                    .Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries)
                    .ToArray();

                var departments = (user.Departments ?? string.Empty)
                    .Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries)
                    .ToArray();

                // Rotate: revoke old, insert new
                var accessMinutes = int.TryParse(cfg["Tokens:AccessMinutes"], out var m) ? m : 60;
                var newJti = Guid.NewGuid();
                var newAccess = IssueJwt(user, cfg, newJti, DateTime.UtcNow.AddMinutes(accessMinutes));

                var refreshDays = int.TryParse(cfg["Tokens:RefreshDays"], out var d) ? d : 7;
                var newRefresh = RefreshTokenHelper.GenerateToken();
                var newHash = RefreshTokenHelper.Sha256(newRefresh);
                var newExpires = DateTime.UtcNow.AddDays(refreshDays);
                var newId = Guid.NewGuid();

                // Insert new refresh row
                var (okNew, msgNew) = await dapper.ExecuteWithOutputAsync("CreateRefreshToken", new
                {
                    Id = newId,
                    UserId = user.Id,
                    TokenHash = newHash,
                    JwtId = newJti,
                    ExpiresAt = newExpires
                });
                if (!okNew)
                    return Results.BadRequest(ApiResponse<object>.FailSingle(msgNew));

                // Revoke old (link to replacement)
                var (okOld, msgOld) = await dapper.ExecuteWithOutputAsync("RevokeRefreshToken", new
                {
                    Id = token.Id,
                    ReplacedByTokenId = newId
                });
                if (!okOld)
                    return Results.BadRequest(ApiResponse<object>.FailSingle(msgOld));

                return Results.Ok(ApiResponse<object>.Ok(new
                {
                    token = newAccess,             // alias
                    accessToken = newAccess,
                    accessExpires = DateTime.UtcNow.AddMinutes(accessMinutes),
                    refreshToken = newRefresh,
                    refreshExpires = newExpires,
                    roles,
                    departments,
                    user = new
                    {
                        id = user.Id,
                        username = user.Username
                    }
                }, "Token refreshed."));
            })
            .WithValidation<RefreshRequestDto>()
             .RequireRateLimiting(RateLimitingExtensions.AuthRefreshModerate);

            // POST /auth/logout -> revoke current refresh token
            group.MapPost("/logout", async (RefreshRequestDto dto, IDapperService dapper) =>
            {
                var hash = RefreshTokenHelper.Sha256(dto.RefreshToken);
                var token = await dapper.QuerySingleAsync<RefreshTokenRecord>("GetRefreshTokenByHash", new { TokenHash = hash });
                if (token is null)
                    return Results.Ok(ApiResponse<object>.Ok(null, "Already logged out."));

                var (ok, msg) = await dapper.ExecuteWithOutputAsync("RevokeRefreshToken", new
                {
                    Id = token.Id,
                    ReplacedByTokenId = (Guid?)null
                });

                return ok
                    ? Results.Ok(ApiResponse<object>.Ok(null, "Logged out."))
                    : Results.BadRequest(ApiResponse<object>.FailSingle(msg));
            })
            .WithValidation<RefreshRequestDto>()
            .RequireRateLimiting(RateLimitingExtensions.PublicBucket);

            // POST /auth/change-password
            // POST /auth/change-password  (no current password check)
            group.MapPost("/change-password", async (
                    ChangePasswordDto dto,
                    IDapperService dapper,
                    HttpContext http) =>
            {
                var userIdStr = http.User.FindFirstValue(ClaimTypes.NameIdentifier);
                if (string.IsNullOrWhiteSpace(userIdStr) || !int.TryParse(userIdStr, out var userId))
                    return Results.Json(ApiResponse<object>.FailSingle("Unauthorized."), statusCode: StatusCodes.Status401Unauthorized);

                var newHash = PasswordHasher.Hash(dto.NewPassword);

                var (ok, msg) = await dapper.ExecuteWithOutputAsync(
                    "UpdateUserPassword",
                    new { Id = userId, PasswordHash = newHash },
                    userId: userId);

                if (!ok)
                    return Results.BadRequest(ApiResponse<object>.FailSingle(msg));


                return Results.Ok(ApiResponse<object>.Ok(null, "Password changed."));
            })
            // If you add a validator for UpdatePasswordDto, swap the generic here:
            .WithValidation<ChangePasswordDto>()
            .RequireAuthorization()
            .WithTags("Auth");


        }

        // Emits:
        // - ClaimTypes.NameIdentifier
        // - ClaimTypes.Name
        // - ClaimTypes.Role (one per role; supports CSV in Role column)
        // - "dept" (one per department id)
        // - "Departments" (legacy CSV for backward compatibility)
        // - JTI
        private static string IssueJwt(UserRecord user, IConfiguration cfg, Guid jti, DateTime expiresUtc)
        {
            var claims = new List<Claim>
            {
                new(ClaimTypes.NameIdentifier, user.Id.ToString()),
                new(ClaimTypes.Name, user.Username),
                new(JwtRegisteredClaimNames.Jti, jti.ToString())
            };

            // roles (model has single Role, but support CSV just in case)
            var roleParts = (user.Role ?? string.Empty)
                .Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries);

            foreach (var r in roleParts)
                claims.Add(new(ClaimTypes.Role, r));

            // departments: one "dept" claim per entry; also keep legacy CSV claim
            var deptParts = (user.Departments ?? string.Empty)
                .Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries);

            foreach (var d in deptParts)
                claims.Add(new("dept", d));

            if (!string.IsNullOrWhiteSpace(user.Departments))
                claims.Add(new("Departments", user.Departments)); // legacy/back-compat

            var signingKey = JwtKeyHelper.BuildSigningKey(cfg);
            var creds = new SigningCredentials(signingKey, SecurityAlgorithms.HmacSha256);

            var token = new JwtSecurityToken(
                issuer: cfg["Jwt:Issuer"],
                audience: cfg["Jwt:Audience"],
                claims: claims,
                expires: expiresUtc,
                signingCredentials: creds
            );

            return new JwtSecurityTokenHandler().WriteToken(token);
        }
    }
}
