using GenericMinimalApi.Extensions;
using Microsoft.AspNetCore.Routing;

namespace GenericMinimalApi.Endpoints
{
    public static class AuthEndpoints
    {
        public static void MapAuth(this IEndpointRouteBuilder app)
        {
            app.MapAuthEndpoints(); // reuse your existing method
        }
        
    }
}