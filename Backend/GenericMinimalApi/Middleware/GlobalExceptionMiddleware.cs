using GenericMinimalApi.Models;
using GenericMinimalApi.Services;



namespace GenericMinimalApi.Middleware
{
    // Middleware to handle global exceptions and log them
    // This middleware should be registered in the Startup.cs or Program.cs file
    // to ensure it catches exceptions from all requests.
    public class GlobalExceptionMiddleware
    {
        private readonly RequestDelegate _next;

        public GlobalExceptionMiddleware(RequestDelegate next)
        {
            _next = next;
        }

        public async Task InvokeAsync(HttpContext context, IErrorLogger errorLogger)
        {
            try
            {
                await _next(context);
            }
            catch (Exception ex)
            {
                await errorLogger.LogDbErrorAsync("Global", "UnhandledException", null, ex);

                context.Response.StatusCode = StatusCodes.Status500InternalServerError;
                context.Response.ContentType = "application/json";
                var response = ApiResponse<object>.FailSingle("An unexpected error occurred.");
                await context.Response.WriteAsJsonAsync(response);
            }
        }
    }
}