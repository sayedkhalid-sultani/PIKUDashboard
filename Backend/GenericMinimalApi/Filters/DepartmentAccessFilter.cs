// DepartmentAccessFilter.cs content placeholder
using GenericMinimalApi.Helpers;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Http.HttpResults;

namespace GenericMinimalApi.Filters
{
    public class DepartmentAccessFilter : IEndpointFilter
    {
        private readonly string[] _allowedDepartments;

        public DepartmentAccessFilter(string[] allowedDepartments)
        {
            _allowedDepartments = allowedDepartments;
        }

        public async ValueTask<object?> InvokeAsync(EndpointFilterInvocationContext context, EndpointFilterDelegate next)
        {
            var httpContext = context.HttpContext;
            var userDepartments = UserContextHelper.GetUserDepartments(httpContext.User);

            if (!_allowedDepartments.Any(d => userDepartments.Contains(d)))
            {
                return TypedResults.Forbid();
            }

            return await next(context);
        }
    }
}
