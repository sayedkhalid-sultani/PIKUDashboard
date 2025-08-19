namespace GenericMinimalApi.Middleware
{
    using System.IO;
    using System.Threading.Tasks;
    using Microsoft.AspNetCore.Http;
    using Microsoft.Extensions.DependencyInjection;
    using GenericMinimalApi.Models; // Ensure this is the correct namespace for IErrorLogger
    using GenericMinimalApi.Services;

    /// <summary>
    /// Middleware to handle BadHttpRequestException and log the error.
    /// </summary>

    public class BadHttpRequestMiddleware
    {
        private readonly RequestDelegate _next;

        public BadHttpRequestMiddleware(RequestDelegate next)
        {
            _next = next;
        }

        public async Task InvokeAsync(HttpContext ctx)
        {
            try
            {
                await _next(ctx);
            }
            catch (BadHttpRequestException ex)
            {
                string? raw = null;
                try
                {
                    ctx.Request.EnableBuffering();
                    ctx.Request.Body.Position = 0;
                    using var reader = new StreamReader(ctx.Request.Body, leaveOpen: true);
                    raw = await reader.ReadToEndAsync();
                    ctx.Request.Body.Position = 0;
                }
                catch { /* ignore */ }

                var log = ctx.RequestServices.GetRequiredService<IErrorLogger>();
                await log.LogDbErrorAsync("HttpBadRequest", "BodyBinding", new { RawBody = raw, Path = ctx.Request.Path.Value }, ex);

                ctx.Response.StatusCode = StatusCodes.Status400BadRequest;
                ctx.Response.ContentType = "application/json";
                await ctx.Response.WriteAsJsonAsync(ApiResponse<object>.FailSingle("Bad request: invalid JSON payload."));
            }
        }
    }
}