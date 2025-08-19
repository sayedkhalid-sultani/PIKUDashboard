// UserContextHelper.cs content placeholder
using System.Security.Claims;

namespace GenericMinimalApi.Helpers
{
    public static class UserContextHelper
    {
        public static string GetUserRole(ClaimsPrincipal user)
        {
            return user.Claims.FirstOrDefault(c => c.Type == ClaimTypes.Role)?.Value ?? "Viewer";
        }

        public static List<string> GetUserDepartments(ClaimsPrincipal user)
        {
            var deptClaim = user.Claims.FirstOrDefault(c => c.Type == "Departments")?.Value;
            return string.IsNullOrWhiteSpace(deptClaim)
                ? new List<string>()
                : deptClaim.Split(',').ToList();
        }

        public static int? GetUserId(ClaimsPrincipal user)
        {
            var idClaim = user.Claims.FirstOrDefault(c => c.Type == ClaimTypes.NameIdentifier)?.Value;
            return int.TryParse(idClaim, out int userId) ? userId : null;
        }
    }
}
