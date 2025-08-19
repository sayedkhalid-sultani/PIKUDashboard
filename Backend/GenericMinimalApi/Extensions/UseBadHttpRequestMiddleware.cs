using GenericMinimalApi.Middleware;

public static class ApplicationBuilderExtensions
{
    public static IApplicationBuilder UseBadHttpRequestMiddleware(this IApplicationBuilder app)
    {
        return app.UseMiddleware<BadHttpRequestMiddleware>();
    }
}