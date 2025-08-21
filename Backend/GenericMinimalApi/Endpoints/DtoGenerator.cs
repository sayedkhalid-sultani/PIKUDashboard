using YourApp.Extensions;

namespace GenericMinimalApi.Endpoints
{
    public static class DtoGenerator
    {
        public static void MapDtoGeneratorEndpoint(this IEndpointRouteBuilder app)
        {
            app.MapDtoGenerator("/tools/generate-dtos", opts =>
                {
                    opts.Namespace = "YourApp.Contracts";
                });
        }
    }
}

  
