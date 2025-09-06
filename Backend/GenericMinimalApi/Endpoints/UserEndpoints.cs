using GenericMinimalApi.Extensions;
using GenericMinimalApi.Helpers;
using GenericMinimalApi.Models;
using GenericMinimalApi.Models.Auth;
using GenericMinimalApi.Models.Filters;   // CommonFilterDto, LookupFilterDto

namespace GenericMinimalApi.Services
{
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
                // DeleteRoles = new[] { "Admin" },
            })
            .WithGroupName("Users")
            .WithTags("Users");

            // 🔄 LIST/SEARCH (POST because CommonFilterDto includes *Ids collections)
            // POST /api/users/search  { ...CommonFilterDto... }
            r.MapStoredProcedureMultiResult<CommonFilterDto>(
                route: "/search",
                procedure: "GetUsers",
                ("Items", typeof(UserReadDto))
            // If your SP returns total count, add:
            // ,("Total", typeof(int))
            )
            .WithName("Users_Search")
            .WithTags("Users")
            .WithSummary("Search/list users")
            .WithDescription("Returns users using CommonFilterDto; supports complex filters and TVPs.");

            // ➕ CREATE
            // POST /api/users
            r.MapStoredProcedureInsert<CreateUserDto>("", "Users_Insert")
             .WithName("Users_Create")
             .WithTags("Users")
             .WithSummary("Create a new user")
             .WithDescription("Creates a new user. Admin role required.");

            // 🧰 LOOKUP OPTIONS (POST because LookupFilterDto often has ParentIds collections)
            // POST /api/users/options  { Dropdown, ParentIds, ... }
            r.MapStoredProcedureMultiResult<LookupFilterDto>(
                route: "/options",
                procedure: "GetDropDownOptions",
                ("Options", typeof(LookupOptionDto))
            )
            .WithName("Users_Options")
            .WithTags("Users", "Lookups")
            .WithSummary("Dropdown options for Users screens")
            .WithDescription("Returns options for dropdowns like Departments, SubDepartments, and Roles.");

            // 🔎 DETAILS (POST to allow binding Id along with other optional filters if needed)
            // POST /api/users/detail  { Id: 123 }
            r.MapStoredProcedureMultiResult<CommonFilterDto>(
                route: "/detail",
                procedure: "Users_GetById",
                ("Item", typeof(UserReadDto))
            )
            .WithName("Users_Detail")
            .WithTags("Users")
            .WithSummary("Get a single user by Id")
            .WithDescription("Binds Id from CommonFilterDto and returns a single user result set.");

            // ✏️ UPDATE
            // PUT /api/users/{id}
            r.MapStoredProcedureUpdate<UpdateUserDto>("/{id:int}", "Users_Update", (id, dto) => new
            {
                Id = id,
                dto.Username,
                dto.Role,
                dto.Departments,
                Password = string.IsNullOrWhiteSpace(dto.Password)
                    ? null
                    : PasswordHasher.Hash(dto.Password),
                dto.IsLocked
            })
            .WithName("Users_Update")
            .WithTags("Users")
            .WithSummary("Update a user");

            // 🗑️ DELETE
            // DELETE /api/users/{id}
            r.MapStoredProcedureDelete("/{id:int}", "Users_Delete")
             .WithName("Users_Delete")
             .WithTags("Users")
             .WithSummary("Delete a user");

            // 📊 DASHBOARD (multi-result) — stays POST
            r.MapStoredProcedureMultiResult<CommonFilterDto>(
                route: "/dashboard",
                procedure: "GetProductsAndDepartments",
                ("Products", typeof(ProductDto)),
                ("Departments", typeof(DepartmentDto))
            )
            .WithName("Users_Dashboard_MultiResult")
            .WithTags("Users", "MultiResult")
            .WithSummary("Returns multiple result sets in one response")
            .WithDescription("Calls a stored procedure that returns multiple SELECT result sets and wraps them into one object keyed by the provided names.");

            // 📈 Indicator Results — POST
            r.MapStoredProcedureMultiResult<CommonFilterDto>(
                route: "/IndicatorResults",
                procedure: "GetCriteriaHierarchyWithCharts",
                ("IndicatorResult", typeof(IndicatorResultDto))
            )
            .WithName("Indicators_Details")
            .WithTags("IndicatorsDetails", "MultiResult")
            .WithSummary("Returns indicators")
            .WithDescription("Returns indicators with result sets.");
        }
    }
}
