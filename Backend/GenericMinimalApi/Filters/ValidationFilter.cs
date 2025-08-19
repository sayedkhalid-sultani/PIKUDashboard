// Filters/ValidationFilter.cs
using FluentValidation;
using GenericMinimalApi.Models;
using GenericMinimalApi.Services;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Http.HttpResults;
using System.Linq;

namespace GenericMinimalApi.Filters
{
    public class ValidationFilter<T> : IEndpointFilter
    {
        public async ValueTask<object?> InvokeAsync(EndpointFilterInvocationContext ctx, EndpointFilterDelegate next)
        {
            var validator = ctx.HttpContext.RequestServices.GetService<IValidator<T>>();
            if (validator is null) return await next(ctx);

            var dto = ctx.Arguments.OfType<T>().FirstOrDefault();
            if (dto is null)
                return TypedResults.BadRequest(ApiResponse<object>.FailSingle("Request body is missing or malformed."));

            var result = await validator.ValidateAsync(dto);
            if (!result.IsValid)
            {
                var errors = result.Errors
                    .Where(e => !string.IsNullOrWhiteSpace(e.ErrorMessage))
                    .Select(e => e.ErrorMessage)
                    .ToArray();

                // optional: log
                var logger = ctx.HttpContext.RequestServices.GetRequiredService<IErrorLogger>();
                await logger.LogDbErrorAsync("ValidationFailed", ctx.HttpContext.Request.Path, dto,
                    new Exception(string.Join("; ", errors)));
                return Results.BadRequest(ApiResponse<object>.Fail(errors));

            }

            return await next(ctx);
        }
    }
}
