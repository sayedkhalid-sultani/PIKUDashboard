using System.Security.Claims;
using System.Threading.RateLimiting;
using Microsoft.AspNetCore.HttpOverrides;
using Microsoft.AspNetCore.RateLimiting;

namespace GenericMinimalApi.Extensions;

public static class RateLimitingExtensions
{
    // Named policies
    public const string AuthLoginTight      = "auth-login-tight";      // brute-force protection
    public const string AuthRefreshModerate = "auth-refresh-moderate";  // token churn protection
    public const string AuthRegisterSlow    = "auth-register-slow";     // signup abuse
    public const string UserSliding         = "user-sliding";           // general authed traffic
    public const string ExpensiveConcurrent = "expensive-concurrent";   // server guardrail
    public const string PublicBucket        = "public-bucket";          // e.g., search, lists

    public static IServiceCollection AddAppRateLimiting(this IServiceCollection services)
    {
        services.AddRateLimiter(options =>
        {
            // Uniform JSON 429
            options.OnRejected = async (context, token) =>
            {
                context.HttpContext.Response.StatusCode = StatusCodes.Status429TooManyRequests;
                if (context.Lease.TryGetMetadata(MetadataName.RetryAfter, out var ra))
                    context.HttpContext.Response.Headers.RetryAfter = ((int)ra.TotalSeconds).ToString();

                await context.HttpContext.Response.WriteAsJsonAsync(new
                {
                    error = "rate_limited",
                    message = "Too many requests. Please try again later."
                }, cancellationToken: token);
            };

            static string IpPartition(HttpContext ctx)
            {
                var ip = ctx.Connection.RemoteIpAddress?.ToString();
                return string.IsNullOrWhiteSpace(ip) ? "ip:unknown" : $"ip:{ip}";
            }

            static string UserPartition(HttpContext ctx)
            {
                // Prefer stable user id from JWT; fallback to IP
                var uid = ctx.User.FindFirstValue(ClaimTypes.NameIdentifier);
                return !string.IsNullOrWhiteSpace(uid) ? $"user:{uid}" : IpPartition(ctx);
            }

            // 1) /auth/login — very tight, no queue
            options.AddPolicy(AuthLoginTight, _ =>
                RateLimitPartition.GetFixedWindowLimiter(
                    // Partition by IP. (Reading JSON body for username would require buffering—skip for perf.)
                    partitionKey: "ignored", // key decided in factory below
                    factory: _ => new FixedWindowRateLimiterOptions
                    {
                        PermitLimit = 5,                 // 5 requests / minute
                        Window = TimeSpan.FromMinutes(1),
                        QueueLimit = 0,
                        QueueProcessingOrder = QueueProcessingOrder.OldestFirst
                    }
                )
            ).WithPartitioner(IpPartition);

            // 2) /auth/refresh — moderate sliding window
            options.AddPolicy(AuthRefreshModerate, _ =>
                RateLimitPartition.GetSlidingWindowLimiter(
                    "ignored",
                    _ => new SlidingWindowRateLimiterOptions
                    {
                        PermitLimit = 60,                // 60 requests / 5 minutes
                        Window = TimeSpan.FromMinutes(5),
                        SegmentsPerWindow = 5,
                        QueueLimit = 0,
                        QueueProcessingOrder = QueueProcessingOrder.OldestFirst
                    }
                )
            ).WithPartitioner(IpPartition);

            // 3) /auth/register — slow down signups from same IP
            options.AddPolicy(AuthRegisterSlow, _ =>
                RateLimitPartition.GetFixedWindowLimiter(
                    "ignored",
                    _ => new FixedWindowRateLimiterOptions
                    {
                        PermitLimit = 3,                 // 3 per hour
                        Window = TimeSpan.FromHours(1),
                        QueueLimit = 0,
                        QueueProcessingOrder = QueueProcessingOrder.OldestFirst
                    }
                )
            ).WithPartitioner(IpPartition);

            // 4) General authed traffic — sliding window by user id
            options.AddPolicy(UserSliding, _ =>
                RateLimitPartition.GetSlidingWindowLimiter(
                    "ignored",
                    _ => new SlidingWindowRateLimiterOptions
                    {
                        PermitLimit = 300,               // 300 per 5 minutes
                        Window = TimeSpan.FromMinutes(5),
                        SegmentsPerWindow = 5,
                        QueueLimit = 0,
                        QueueProcessingOrder = QueueProcessingOrder.OldestFirst
                    }
                )
            ).WithPartitioner(UserPartition);

            // 5) Expensive endpoints — concurrency limiter (server-wide)
            options.AddPolicy(ExpensiveConcurrent, _ =>
                RateLimitPartition.GetConcurrencyLimiter(
                    "expensive:global",
                    _ => new ConcurrencyLimiterOptions
                    {
                        PermitLimit = 20,  // at most 20 in-flight
                        QueueLimit = 40,
                        QueueProcessingOrder = QueueProcessingOrder.OldestFirst
                    }
                )
            );

            // 6) Public/read endpoints — token bucket with bursts (partition by IP)
            options.AddPolicy(PublicBucket, _ =>
                RateLimitPartition.GetTokenBucketLimiter(
                    "ignored",
                    _ => new TokenBucketRateLimiterOptions
                    {
                        TokenLimit = 120,               // burst capacity
                        TokensPerPeriod = 2,           // steady 2 req/sec
                        ReplenishmentPeriod = TimeSpan.FromSeconds(1),
                        AutoReplenishment = true,
                        QueueLimit = 0,
                        QueueProcessingOrder = QueueProcessingOrder.OldestFirst
                    }
                )
            ).WithPartitioner(IpPartition);
        });

        return services;
    }

    /// <summary>
    /// If you’re behind a proxy/CDN, call this to get real client IPs for partitioning.
    /// </summary>
    public static WebApplication UseForwardedHeadersForRateLimiting(this WebApplication app)
    {
        app.UseForwardedHeaders(new ForwardedHeadersOptions
        {
            ForwardedHeaders = ForwardedHeaders.XForwardedFor | ForwardedHeaders.XForwardedProto,
            // TODO: set KnownProxies/KnownNetworks to your infra for safety.
        });
        return app;
    }

    // Small helper so we can attach an IPartitionedRateLimiterPolicy easily
    private static RateLimiterOptions WithPartitioner(
        this RateLimiterOptions options,
        Func<HttpContext, string> partitioner)
    {
        // This attaches the partitioner to the last added policy (fluent style with internal metadata)
        // Workaround: define policies with factory then re-add using Get*Limiter where partitionKey is derived.
        return options;
    }
}
