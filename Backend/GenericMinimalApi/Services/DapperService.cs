// Services/DapperService.cs
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Linq;
using System.Threading.Tasks;
using Dapper;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;

namespace GenericMinimalApi.Services
{
    public class DapperService : IDapperService
    {
        private readonly string _connectionString;
        private readonly IErrorLogger _logger;

        public DapperService(IConfiguration configuration, IErrorLogger logger)
        {
            _connectionString = configuration.GetConnectionString("DefaultConnection")!;
            Console.WriteLine("Connection string: " + _connectionString);
            _logger = logger;
        }

        private IDbConnection GetConnection() => new SqlConnection(_connectionString);

        /// <summary>
        /// Builds DynamicParameters from an anonymous/object/DynamicParameters and appends @UserId if provided.
        /// </summary>
        private static DynamicParameters ToParamsWithUserId(object? param, int? userId)
        {
            var dp = param as DynamicParameters ?? new DynamicParameters(param);
            if (userId.HasValue) dp.Add("UserId", userId.Value);
            return dp;
        }

        public async Task<IEnumerable<T>> QueryAsync<T>(
            string procedure,
            object? param = null,
            IUnitOfWork? uow = null,
            int? userId = null)
        {
            var conn = uow?.Connection ?? GetConnection();
            var dp = ToParamsWithUserId(param, userId);

            try
            {
                return await conn.QueryAsync<T>(procedure, dp, uow?.Transaction, commandType: CommandType.StoredProcedure);
            }
            catch (Exception ex)
            {
                await _logger.LogDbErrorAsync(nameof(QueryAsync), procedure, dp, ex);
                throw;
            }
        }

        public async Task<T?> QuerySingleAsync<T>(
            string procedure,
            object? param = null,
            IUnitOfWork? uow = null,
            int? userId = null)
        {
            var conn = uow?.Connection ?? GetConnection();
            var dp = ToParamsWithUserId(param, userId);

            try
            {
                return await conn.QuerySingleOrDefaultAsync<T>(procedure, dp, uow?.Transaction, commandType: CommandType.StoredProcedure);
            }
            catch (Exception ex)
            {
                await _logger.LogDbErrorAsync(nameof(QuerySingleAsync), procedure, dp, ex);
                throw;
            }
        }

        public async Task<(bool Success, string Message)> ExecuteWithOutputAsync(
            string procedure,
            object param,
            IUnitOfWork? uow = null,
            int? userId = null)
        {
            var conn = uow?.Connection ?? GetConnection();
            var dp = ToParamsWithUserId(param, userId);

            try
            {
                dp.Add("OutputMessage", dbType: DbType.String, size: 4000, direction: ParameterDirection.Output);

                await conn.ExecuteAsync(procedure, dp, uow?.Transaction, commandType: CommandType.StoredProcedure);

                var message = dp.Get<string>("OutputMessage") ?? string.Empty;
                var success = !message.Contains("Error", StringComparison.OrdinalIgnoreCase);

                if (!success)
                    await _logger.LogDbErrorAsync(nameof(ExecuteWithOutputAsync), procedure, dp, new Exception(message));

                return (success, message);
            }
            catch (Exception ex)
            {
                await _logger.LogDbErrorAsync(nameof(ExecuteWithOutputAsync), procedure, dp, ex);
                throw;
            }
        }

        public async Task<Dictionary<string, IEnumerable<object>>> QueryMultipleAsDictionaryAsync(
            string procedure,
            object? param,
            IReadOnlyList<KeyValuePair<string, Type>> resultSets,
            IUnitOfWork? uow = null,
            int? userId = null)
        {
            var conn = uow?.Connection ?? GetConnection();
            var dp = ToParamsWithUserId(param, userId);

            try
            {
                var result = new Dictionary<string, IEnumerable<object>>(StringComparer.OrdinalIgnoreCase);

                using var grid = await conn.QueryMultipleAsync(procedure, dp, uow?.Transaction, commandType: CommandType.StoredProcedure);

                foreach (var kv in resultSets)
                {
                    if (kv.Value == typeof(object) || kv.Value == typeof(System.Dynamic.ExpandoObject))
                        result[kv.Key] = grid.Read().Cast<object>().ToArray();
                    else
                        result[kv.Key] = grid.Read(kv.Value).ToArray();
                }

                return result;
            }
            catch (Exception ex)
            {
                await _logger.LogDbErrorAsync(nameof(QueryMultipleAsDictionaryAsync), procedure, dp, ex);
                throw;
            }
        }

        public Task<Dictionary<string, IEnumerable<object>>> QueryMultipleAsDictionaryAsync(
            string procedure,
            object? param,
            IUnitOfWork? uow = null,
            int? userId = null,
            params (string key, Type type)[] resultSets)
        {
            var list = resultSets.Select(t => new KeyValuePair<string, Type>(t.key, t.type)).ToList();
            return QueryMultipleAsDictionaryAsync(procedure, param, list, uow, userId);
        }

        public async Task<(bool success, string message, int affected)> ExecuteBulkTvpAsync<T>(
            string procedure,
            string udttName,
            string tvpParamName,
            IEnumerable<T> items,
            Func<T, object> projector,
            IUnitOfWork? uow = null,
            int? commandTimeout = null,
            int? userId = null)
        {
            // Build a DataTable from the projected anonymous objects
            var dt = ToDataTable(items.Select(projector));

            var dp = new DynamicParameters();
            dp.Add(tvpParamName, dt.AsTableValuedParameter(udttName));
            dp.Add("OutputMessage", dbType: DbType.String, size: 4000, direction: ParameterDirection.Output);
            if (userId.HasValue) dp.Add("UserId", userId.Value);

            SqlConnection? owned = null;
            var conn = uow?.Connection as SqlConnection;

            try
            {
                if (conn is null)
                {
                    owned = new SqlConnection(_connectionString);
                    conn = owned;
                    await conn.OpenAsync();
                }

                var affected = await conn.ExecuteAsync(
                    procedure,
                    dp,
                    transaction: uow?.Transaction,
                    commandType: CommandType.StoredProcedure,
                    commandTimeout: commandTimeout ?? 60);

                var message = dp.Get<string>("OutputMessage") ?? "OK";
                var success = !message.StartsWith("Error", StringComparison.OrdinalIgnoreCase);
                return (success, message, affected);
            }
            catch (Exception ex)
            {
                await _logger.LogDbErrorAsync("ExecuteBulkTvpAsync", procedure, new { tvpParamName, udttName, userId }, ex);
                throw;
            }
            finally
            {
                if (owned is not null)
                    await owned.DisposeAsync();
            }
        }

        /// <summary>
        /// REQUIRED by IDapperService. Executes a stored procedure and returns the affected row count (boxed).
        /// Keep this minimal to satisfy the interface.
        /// </summary>
        public async Task<object?> ExecuteAsync(string procedure, object param)
        {
            var conn = GetConnection();
            var dp = ToParamsWithUserId(param, userId: null);

            try
            {
                var affected = await conn.ExecuteAsync(procedure, dp, commandType: CommandType.StoredProcedure);
                return affected; // boxed int to object?
            }
            catch (Exception ex)
            {
                await _logger.LogDbErrorAsync(nameof(ExecuteAsync), procedure, dp, ex);
                throw;
            }
        }

        /// <summary>
        /// Optional richer overload (not in the interface) for internal use.
        /// </summary>
        public async Task<int> ExecuteAsync(
            string procedure,
            object param,
            IUnitOfWork? uow = null,
            int? userId = null,
            int? commandTimeout = null)
        {
            var conn = uow?.Connection ?? GetConnection();
            var dp = ToParamsWithUserId(param, userId);

            try
            {
                return await conn.ExecuteAsync(
                    procedure,
                    dp,
                    uow?.Transaction,
                    commandType: CommandType.StoredProcedure,
                    commandTimeout: commandTimeout);
            }
            catch (Exception ex)
            {
                await _logger.LogDbErrorAsync($"{nameof(ExecuteAsync)}(overload)", procedure, dp, ex);
                throw;
            }
        }

        private static DataTable ToDataTable(IEnumerable<object> rows)
        {
            var dt = new DataTable();
            bool columnsAdded = false;

            foreach (var row in rows)
            {
                if (row is null) continue;
                var props = TypeDescriptor.GetProperties(row);

                if (!columnsAdded)
                {
                    foreach (PropertyDescriptor p in props)
                    {
                        var type = Nullable.GetUnderlyingType(p.PropertyType) ?? p.PropertyType;
                        dt.Columns.Add(p.Name, type);
                    }
                    columnsAdded = true;
                }

                var values = new object[props.Count];
                for (int i = 0; i < props.Count; i++)
                    values[i] = props[i].GetValue(row) ?? DBNull.Value;

                dt.Rows.Add(values);
            }

            return dt;
        }
    }
}
