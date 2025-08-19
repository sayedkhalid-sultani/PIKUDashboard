// TransactionFilter.cs content placeholder
using GenericMinimalApi.Services;
using Microsoft.AspNetCore.Http;

namespace GenericMinimalApi.Filters
{
    public class TransactionFilter : IEndpointFilter
    {
        public async ValueTask<object?> InvokeAsync(EndpointFilterInvocationContext context, EndpointFilterDelegate next)
        {
            var uow = context.HttpContext.RequestServices.GetRequiredService<IUnitOfWork>();
            await uow.BeginTransactionAsync();

            try
            {
                var result = await next(context);
                await uow.CommitTransactionAsync();
                return result;
            }
            catch
            {
                await uow.RollbackTransactionAsync();
                throw;
            }
        }
    }
}
