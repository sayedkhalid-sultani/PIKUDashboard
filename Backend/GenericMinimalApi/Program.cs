using GenericMinimalApi.Extensions;
using GenericMinimalApi.Services;
using FluentValidation;
using GenericMinimalApi.Validators;
using GenericMinimalApi.Workers;
using GenericMinimalApi.Endpoints;
using GenericMinimalApi.Models;

var builder = WebApplication.CreateBuilder(args);

// Configuration


// Service Registrations
builder.Services
    .AddScoped<IDapperService, DapperService>()
    .AddScoped<IUnitOfWork, UnitOfWork>()
    .AddValidatorsFromAssemblyContaining<ProductDtoValidator>()
    .AddHttpContextAccessor()
    .AddScoped<IErrorLogger, SqlErrorLogger>();

builder.Services.Configure<MaintenanceOptions>(builder.Configuration.GetSection("Maintenance"));
builder.Services.AddHostedService<ErrorLogCleanupWorker>();
builder.Services.AddHostedService<RefreshTokenCleanupWorker>();

// API & Swagger
builder.Services.AddControllers()
    .AddJsonOptions(options =>
    {
        options.JsonSerializerOptions.PropertyNamingPolicy = null;
    });
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerDocumentation();

// Auth & CORS
builder.Services.AddJwtAuthentication(builder.Configuration);
builder.Services.AddAuthorizationBuilder()
    .AddPolicy("AdminOnly", policy => policy.RequireRole("Admin"));
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", builder =>
        builder.AllowAnyOrigin().AllowAnyMethod().AllowAnyHeader());
});

var app = builder.Build();

// Swagger (Development Only)
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI(c =>
    {
        c.SwaggerEndpoint("/swagger/v1/swagger.json", "PIKUDashboard API v1");
        c.DisplayRequestDuration();
        c.DefaultModelsExpandDepth(-1);
        c.EnableTryItOutByDefault();
        c.DocumentTitle = "PIKUDashboard API Documentation";
    });
}

// Middleware
app.UseCors("AllowAll");
app.UseAuthentication();
app.UseAuthorization();
app.UseBadHttpRequestMiddleware();
app.UseGlobalExceptionMiddleware();

// Endpoints
app.MapAuth();
app.MapIndicators();
app.MapUserEndpoints();

//Dto Generators
app.MapDtoGeneratorEndpoint();

app.Run();
