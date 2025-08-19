public static class ServiceCollectionExtensions
{
    public static IServiceCollection AddFrontendCors(this IServiceCollection services)
    {
        services.AddCors(options =>
        {
            options.AddPolicy("AllowFrontend", policy =>
            {
                policy
                    .WithOrigins(
                        "http://localhost:5173",   // Vite
                        "http://localhost:3000"    // CRA
                    )
                    .AllowAnyHeader()
                    .AllowAnyMethod();
            });
        });
        return services;
    }
}