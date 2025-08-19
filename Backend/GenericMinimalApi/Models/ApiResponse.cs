// Models/ApiResponse.cs
namespace GenericMinimalApi.Models
{
    public record ApiResponse<T>(bool Success, T? Data, string? Message, IEnumerable<string>? Errors)
    {
        public static ApiResponse<T> Ok(T? data = default, string? message = null) =>
            new(true, data, message, null);

        public static ApiResponse<T> Fail(IEnumerable<string> errors) =>
            new(false, default, null, errors);

        public static ApiResponse<T> FailSingle(string message) =>
            new(false, default, message, null);
    }
}
