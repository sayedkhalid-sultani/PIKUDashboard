using System.Security.Claims;
using GenericMinimalApi.Helpers;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using GenericMinimalApi.Services;
using System.Text.Json;
using GenericMinimalApi.Models; // Ensure this is the correct namespace for IErrorLogger

namespace GenericMinimalApi.Extensions
{
    public static class ServiceCollectionExtensions
    {
        public static IServiceCollection AddJwtAuthentication(this IServiceCollection services, IConfiguration configuration)
        {
            var signingKey = JwtKeyHelper.BuildSigningKey(configuration);

            services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
                .AddJwtBearer(options =>
                {
                    options.TokenValidationParameters = new TokenValidationParameters
                    {
                        ValidateIssuer = true,
                        ValidateAudience = true,
                        ValidateLifetime = true,
                        ClockSkew = TimeSpan.Zero,
                        ValidateIssuerSigningKey = true,
                        ValidIssuer = configuration["Jwt:Issuer"],
                        ValidAudience = configuration["Jwt:Audience"],
                        IssuerSigningKey = signingKey,
                        NameClaimType = ClaimTypes.Name,
                        RoleClaimType = ClaimTypes.Role,
                    };

                    options.Events = new JwtBearerEvents
                    {
                        OnAuthenticationFailed = async ctx =>
                        {
                            var log = ctx.HttpContext.RequestServices.GetRequiredService<IErrorLogger>();
                            await log.LogDbErrorAsync("Auth", "OnAuthenticationFailed", null, ctx.Exception);

                            ctx.NoResult();
                            ctx.Response.StatusCode = StatusCodes.Status401Unauthorized;
                            ctx.Response.ContentType = "application/json";
                            var msg = ctx.Exception is SecurityTokenExpiredException
                                ? "Unauthorized: token expired."
                                : "Unauthorized: authentication failed.";
                            await ctx.Response.WriteAsync(JsonSerializer.Serialize(ApiResponse<object>.FailSingle(msg)));
                        },
                        OnChallenge = ctx =>
                        {
                            ctx.HandleResponse();
                            ctx.Response.StatusCode = StatusCodes.Status401Unauthorized;
                            ctx.Response.ContentType = "application/json";
                            return ctx.Response.WriteAsync(JsonSerializer.Serialize(
                                ApiResponse<object>.FailSingle("Unauthorized: missing or invalid access token.")));
                        },
                        OnForbidden = async ctx =>
                        {
                            var log = ctx.HttpContext.RequestServices.GetRequiredService<IErrorLogger>();
                            await log.LogDbErrorAsync("Auth", "OnForbidden", null, new Exception("Forbidden"));

                            ctx.Response.StatusCode = StatusCodes.Status403Forbidden;
                            ctx.Response.ContentType = "application/json";
                            await ctx.Response.WriteAsync(JsonSerializer.Serialize(
                                ApiResponse<object>.FailSingle("Forbidden: you do not have permission to access this resource.")));
                        }
                    };
                });

            return services;
        }
    }
}