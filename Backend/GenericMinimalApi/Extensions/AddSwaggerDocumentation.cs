public static class SwaggerServiceCollectionExtensions
{
    public static IServiceCollection AddSwaggerDocumentation(this IServiceCollection services)
    {
        services.AddEndpointsApiExplorer();
        services.AddSwaggerGen(c =>
        {
            c.SwaggerDoc("v1", new Microsoft.OpenApi.Models.OpenApiInfo
            {
                Title = "PIKUDashboard API",
                Version = "v1",
                Description = "Minimal API for PIKUDashboard: authentication, user management, indicators, and more.",
                Contact = new Microsoft.OpenApi.Models.OpenApiContact
                {
                    Name = "PIKUDashboard Team",
                    Email = "support@pikudashboard.com"
                },
                License = new Microsoft.OpenApi.Models.OpenApiLicense
                {
                    Name = "MIT License",
                    Url = new Uri("https://opensource.org/licenses/MIT")
                }
            });

            // ✅ Ensure minimal APIs are not excluded
            c.DocInclusionPredicate((_, __) => true);

            // Optional: nicer grouping — respect GroupName (from .WithGroupName/.WithTags)
            c.TagActionsBy(api =>
            {
                if (!string.IsNullOrEmpty(api.GroupName))
                    return new[] { api.GroupName };

                // Fallback: first path segment
                var path = api.RelativePath ?? "Endpoints";
                var first = path.Split('/', StringSplitOptions.RemoveEmptyEntries).FirstOrDefault() ?? "Endpoints";
                return new[] { first };
            });

            // Optional: avoid schema id collisions for same class names in different namespaces
            c.CustomSchemaIds(t => t.FullName);

            // JWT bearer
            c.AddSecurityDefinition("Bearer", new Microsoft.OpenApi.Models.OpenApiSecurityScheme
            {
                Type = Microsoft.OpenApi.Models.SecuritySchemeType.Http,
                Scheme = "bearer",
                BearerFormat = "JWT",
                In = Microsoft.OpenApi.Models.ParameterLocation.Header,
                Description = "Paste the JWT here (no need to prefix with 'Bearer ')"
            });

            c.AddSecurityRequirement(new Microsoft.OpenApi.Models.OpenApiSecurityRequirement
            {
                {
                    new Microsoft.OpenApi.Models.OpenApiSecurityScheme
                    {
                        Reference = new Microsoft.OpenApi.Models.OpenApiReference
                        {
                            Type = Microsoft.OpenApi.Models.ReferenceType.SecurityScheme,
                            Id = "Bearer"
                        }
                    },
                    Array.Empty<string>()
                }
            });

            var xmlFile = $"{System.Reflection.Assembly.GetExecutingAssembly().GetName().Name}.xml";
            var xmlPath = Path.Combine(AppContext.BaseDirectory, xmlFile);
            c.IncludeXmlComments(xmlPath, includeControllerXmlComments: true);
        });
        return services;
    }
}
