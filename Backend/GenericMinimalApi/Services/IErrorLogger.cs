namespace GenericMinimalApi.Services
{
    public interface IErrorLogger
    {
        Task LogDbErrorAsync(string operation, string procedure, object? param, Exception ex);
    }
}
