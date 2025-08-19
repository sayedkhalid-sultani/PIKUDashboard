using System.Text.Json;
using Dapper;
using Microsoft.AspNetCore.Http;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;

namespace GenericMinimalApi.Services
{
    public class SqlErrorLogger : IErrorLogger
    {
        private readonly string _cs;
        private readonly IHttpContextAccessor _http;

        private static readonly JsonSerializerOptions JsonOpts = new()
        {
            DefaultIgnoreCondition = System.Text.Json.Serialization.JsonIgnoreCondition.WhenWritingNull
        };

        private static readonly HashSet<string> SecretNames =
            new(StringComparer.OrdinalIgnoreCase) { "password", "pwd", "secret", "token", "Authorization" };

        public SqlErrorLogger(IConfiguration cfg, IHttpContextAccessor http)
        {
            _cs = cfg.GetConnectionString("DefaultConnection")!;
            _http = http;
        }

        public async Task LogDbErrorAsync(string operation, string procedure, object? param, Exception ex)
        {
            try
            {
                var parametersJson = SerializeParams(param);
                var userName = _http.HttpContext?.User?.Identity?.Name;
                var path = _http.HttpContext?.Request?.Path.Value;

                using var conn = new SqlConnection(_cs);
                await conn.ExecuteAsync(
                    "InsertErrorLog",
                    new
                    {
                        Operation = operation,
                        ProcedureName = procedure,
                        Parameters = parametersJson,
                        Message = ex.Message,
                        StackTrace = ex.ToString(),
                        UserName = userName,
                        RequestPath = path
                    },
                    commandType: System.Data.CommandType.StoredProcedure
                );
            }
            catch
            {
                // never throw from the logger
            }
        }

        private static string? SerializeParams(object? param)
        {
            if (param is null) return null;

            if (param is Dapper.DynamicParameters dp)
            {
                var dict = new Dictionary<string, object?>(StringComparer.OrdinalIgnoreCase);
                foreach (var name in dp.ParameterNames)
                {
                    try
                    {
                        object? value = "<unavailable>";
                        try { value = dp.Get<object?>(name); } catch { /* output-only */ }
                        if (SecretNames.Contains(name)) value = "***";
                        dict[name] = value;
                    }
                    catch { dict[name] = "<error-reading>"; }
                }
                return JsonSerializer.Serialize(dict, JsonOpts);
            }

            // Plain object -> anonymize known secrets by name (best effort)
            var objDict = new Dictionary<string, object?>();
            foreach (var p in param.GetType().GetProperties())
            {
                var val = p.GetValue(param);
                objDict[p.Name] = SecretNames.Contains(p.Name) ? "***" : val;
            }
            return JsonSerializer.Serialize(objDict, JsonOpts);
        }
    }
}
