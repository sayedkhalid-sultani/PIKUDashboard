using GenericMinimalApi.Extensions;
using GenericMinimalApi.Helpers;
using GenericMinimalApi.Models;
using GenericMinimalApi.Models.Auth;
using Microsoft.AspNetCore.Routing;
using Microsoft.AspNetCore.OpenApi;

// Keep this here or move to your Models folder if you prefer


namespace GenericMinimalApi.Services {
public static class UsersEndpoints
{
        public static void MapUserEndpoints(this IEndpointRouteBuilder app)
        {
            var r = app.MapSpGroup(new StoredProcedureEndpointExtensions.StoredProcedureEndpointOptions
            {
                RoutePrefix = "/api/users",
                RequiresAuthorization = true,
                RequiresTransaction = true,
                AllowedRoles = new[] { "Admin" },
                ReadRoles = new[] { "Admin" },
                CreateRoles = new[] { "Admin" },
                UpdateRoles = new[] { "Admin" },
                // DeleteRoles  = new[] { "Admin" },
            })
            .WithGroupName("Users")
            .WithTags("Users");

            // GET /api/users  → list users
            r.MapSpSelectGetB<UserReadDto>("", "GetUsers")
             .WithName("Users_List")
             .WithTags("Users")
             .WithSummary("List users")
             .WithDescription("Returns the list of users with role and department info.");

            // POST /api/users → create user
            r.MapSpInsertB<CreateUserDto>("", "Users_Insert")
             .WithName("Users_Create")
             .WithTags("Users")
             .WithSummary("Create a new user")
             .WithDescription("Creates a new user. Admin role required.");

            // GET /api/users/options?Dropdown=Departments
            // GET /api/users/options?Dropdown=SubDepartments&ParentIds=1,2
            r.MapSpSelectGetB<LookupOptionDto, LookupFilterDto>("/options", "GetDropDownOptions")
             .WithName("Users_Options")
             .WithTags("Users", "Lookups")
             .WithSummary("Dropdown options for Users screens")
             .WithDescription("Returns options for dropdowns like Departments, SubDepartments, and Roles.");

            // GET /api/users/{id} → single user
            r.MapSpGetByIdB<UserReadDto>("/{id:int}", "Users_GetById")
             .WithName("Users_GetById")
             .WithTags("Users")
             .WithSummary("Get a user by id");

            // PUT /api/users/{id} → update user
            r.MapSpUpdateB<UpdateUserDto>("/{id:int}", "Users_Update", (id, dto) =>
            {
                return new
                {
                    Id = id,
                    dto.Username,
                    dto.Role,
                    dto.Departments,
                    Password = string.IsNullOrWhiteSpace(dto.Password)
                        ? null
                        : PasswordHasher.Hash(dto.Password)
                };
            })
            .WithName("Users_Update")
            .WithTags("Users")
            .WithSummary("Update a user");

            // DELETE /api/users/{id} → delete user
            r.MapSpDeleteB("/{id:int}", "Users_Delete")
             .WithName("Users_Delete")
             .WithTags("Users")
             .WithSummary("Delete a user");
           
    }
}
}