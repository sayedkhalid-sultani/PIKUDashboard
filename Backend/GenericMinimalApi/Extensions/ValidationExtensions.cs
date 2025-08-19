// ValidationExtensions.cs content placeholder
using GenericMinimalApi.Filters;
using Microsoft.AspNetCore.Routing;

namespace GenericMinimalApi.Extensions
{
    public static class ValidationExtensions
    {
        public static RouteHandlerBuilder WithValidation<T>(this RouteHandlerBuilder builder) where T : class
        {
            return builder.AddEndpointFilter<ValidationFilter<T>>();
        }
    }
}
