using GenericMinimalApi.Extensions;
using GenericMinimalApi.Models;
using GenericMinimalApi.Services;
using GenericMinimalApi.Filters;     // 👈 add this for TransactionFilter
using System.Security.Claims;

namespace GenericMinimalApi.Endpoints
{
    public static class IndicatorEndpoints
    {
        public static void MapIndicators(this IEndpointRouteBuilder app)
        {
            app.MapPost("/api/indicators/bulk", async (
                List<IndicatorCreateDto> items,
                IDapperService dapper,
                HttpContext http,
                IUnitOfWork? uow) =>
            {
                var userId = int.TryParse(http.User.FindFirstValue(ClaimTypes.NameIdentifier), out var id) ? id : 0;

                if (items is null || items.Count == 0)
                    return Results.BadRequest(ApiResponse<object>.FailSingle("No items provided."));

                var (success, message, affected) = await dapper.ExecuteBulkTvpAsync(
                    "InsertIndicatorsBulk",
                    "dbo.IndicatorTableType",
                    "Items",
                    items,
                    x => new
                    {
                        x.Name,
                        x.DepartmentId,
                        x.Value,
                        x.EffectiveDate,
                        CreatedBy = userId == 0 ? (int?)null : userId
                    },
                    uow
                );

                return success
                    ? Results.Ok(ApiResponse<object>.Ok(new { inserted = affected }, message))
                    : Results.BadRequest(ApiResponse<object>.FailSingle(message));
            })
            .RequireAuthorization()
            .WithTags("Indicators")
            .AddEndpointFilter<TransactionFilter>();   // 👈 replace .WithTransaction()
        }
    }
}
