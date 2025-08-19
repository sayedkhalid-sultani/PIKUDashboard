// Services/IDapperService.cs
using System;
using System.Collections.Generic;
using System.Data;
using System.Threading.Tasks;

namespace GenericMinimalApi.Services
{
    public interface IDapperService
    {
        Task<IEnumerable<T>> QueryAsync<T>(string procedure, object? param = null, IUnitOfWork? uow = null, int? userId = null);

        Task<T?> QuerySingleAsync<T>(string procedure, object? param = null, IUnitOfWork? uow = null, int? userId = null);

        Task<(bool Success, string Message)> ExecuteWithOutputAsync(string procedure, object param, IUnitOfWork? uow = null, int? userId = null);

        Task<Dictionary<string, IEnumerable<object>>> QueryMultipleAsDictionaryAsync(
            string procedure,
            object? param,
            IReadOnlyList<KeyValuePair<string, Type>> resultSets,
            IUnitOfWork? uow = null,
            int? userId = null);

        Task<Dictionary<string, IEnumerable<object>>> QueryMultipleAsDictionaryAsync(
            string procedure,
            object? param,
            IUnitOfWork? uow = null,
            int? userId = null,
            params (string key, Type type)[] resultSets);

        Task<(bool success, string message, int affected)> ExecuteBulkTvpAsync<T>(
            string procedure,
            string udttName,
            string tvpParamName,
            IEnumerable<T> items,
            Func<T, object> projector,
            IUnitOfWork? uow = null,
            int? commandTimeout = null,
            int? userId = null);

        // The interface member your class was missing:
        Task<object?> ExecuteAsync(string procedure, object param);
    }
}
