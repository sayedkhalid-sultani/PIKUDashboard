// StoredProcedureEndpointExtensions.cs
using System.Collections;
using System.Data;
using System.Reflection;
using System.Security.Claims;
using System.Text.Json;
using Dapper;
using GenericMinimalApi.Filters;     // TransactionFilter
using GenericMinimalApi.Models;      // ApiResponse<T>
using GenericMinimalApi.Services;    // IDapperService

namespace GenericMinimalApi.Extensions
{
    public static class StoredProcedureEndpointExtensions
    {
        private const string IntListTypeName = "dbo.IntList";

        // ------------------------- Auth helpers -------------------------
        internal static int? GetUserId(HttpContext ctx)
        {
            var s = ctx.User.FindFirstValue(ClaimTypes.NameIdentifier);
            return int.TryParse(s, out var id) ? id : (int?)null;
        }

        private static RouteHandlerBuilder ApplyAuth(this RouteHandlerBuilder b, bool requireAuth, string[]? roles, string[]? fallback = null)
        {
            if (!requireAuth) return b;
            var effective = (roles?.Length ?? 0) > 0 ? roles : fallback;
            return (effective is { Length: > 0 })
                ? b.RequireAuthorization(p => p.RequireRole(effective!))
                : b.RequireAuthorization();
        }

        private static RouteHandlerBuilder MaybeTx(this RouteHandlerBuilder b, bool wrap)
            => wrap ? b.AddEndpointFilter<TransactionFilter>() : b;

        // ------------------------- TVP helpers -------------------------
        private static IEnumerable<int>? TryToIntEnumerable(object? value)
        {
            if (value == null) return null;

            if (value is string s)
            {
                var parts = s.Split(new[] { ',', ';' }, StringSplitOptions.RemoveEmptyEntries);
                var list = new List<int>();
                foreach (var part in parts)
                {
                    if (int.TryParse(part.Trim(), out var n)) list.Add(n);
                }
                return list.Count > 0 ? list : null;
            }

            if (value is IEnumerable enumerable and not string)
            {
                var list = new List<int>();
                foreach (var item in enumerable)
                {
                    if (item is int i) list.Add(i);
                    else if (item is long l) list.Add(checked((int)l));
                    else if (item is short sh) list.Add(sh);
                    else if (item is byte by) list.Add(by);
                    else if (item is string st && int.TryParse(st, out var n)) list.Add(n);
                }
                return list.Count > 0 ? list : null;
            }

            return null;
        }

        private static void AddIntListTvp(DynamicParameters p, string paramName, IEnumerable<int> ids)
        {
            var dt = new DataTable();
            dt.Columns.Add("Id", typeof(int));
            foreach (var id in ids) dt.Rows.Add(id);
            if (dt.Rows.Count > 0)
                p.Add("@" + paramName, dt.AsTableValuedParameter(IntListTypeName));
        }

        // Build params from a DTO/object.
        // ✅ SKIPS NULLS so only explicitly-provided properties are sent to SQL.
        // Any "*Ids" property is treated as TVP (dbo.IntList).
        private static DynamicParameters BuildParamsWithTvps(object? dtoOrFilter)
        {
            var p = new DynamicParameters();
            if (dtoOrFilter == null) return p;

            foreach (var prop in dtoOrFilter.GetType().GetProperties(BindingFlags.Instance | BindingFlags.Public))
            {
                // skip indexers / unreadable props
                if (prop.GetIndexParameters().Length > 0 || !prop.CanRead) continue;

                var name = prop.Name;
                var value = prop.GetValue(dtoOrFilter);

                // ← Skip nulls: don't add unless client actually sent it
                if (value == null) continue;

            if (name.EndsWith("Ids", StringComparison.OrdinalIgnoreCase))
                {
                    var ids = TryToIntEnumerable(value) ?? Array.Empty<int>();
                    AddIntListTvp(p, name, ids);
                    continue;
                }
                p.Add(name, value);
                
            }

            return p;
        }

        // Build params from JSON dictionary (when using raw dictionary body).
        // Only keys present in JSON are added (fits "send only what I provided").
        private static object? FromJson(JsonElement e)
        {
            switch (e.ValueKind)
            {
                case JsonValueKind.Null:
                case JsonValueKind.Undefined: return null;

                case JsonValueKind.Number:
                    if (e.TryGetInt32(out var i)) return i;
                    if (e.TryGetInt64(out var l)) return l;
                    if (e.TryGetDecimal(out var d)) return d;
                    return e.GetDouble();

                case JsonValueKind.True:
                case JsonValueKind.False: return e.GetBoolean();

                case JsonValueKind.String:
                    if (e.TryGetDateTime(out var dt)) return dt;
                    return e.GetString();

                case JsonValueKind.Array:
                    var list = new List<object?>();
                    foreach (var item in e.EnumerateArray()) list.Add(FromJson(item));
                    return list;

                case JsonValueKind.Object:
                    var dict = new Dictionary<string, object?>(StringComparer.OrdinalIgnoreCase);
                    foreach (var prop in e.EnumerateObject()) dict[prop.Name] = FromJson(prop.Value);
                    return dict;

                default: return null;
            }
        }

        private static DynamicParameters BuildParamsWithTvps(IDictionary<string, JsonElement> dict)
        {
            var p = new DynamicParameters();
            if (dict == null) return p;

            foreach (var kv in dict)
            {
                var name = kv.Key;
                var val  = FromJson(kv.Value);

               if (name.EndsWith("Ids", StringComparison.OrdinalIgnoreCase))
                {
                    var ids = TryToIntEnumerable(val) ?? Array.Empty<int>();
                    AddIntListTvp(p, name, ids);
                    continue;
                }

                // lenient: if array was sent where scalar expected, take first
                if (val is IList list && list.Count > 0)
                    p.Add(name, list[0]);
                else
                    p.Add(name, val);
            }

            return p;
        }

        private static (string key, Type type)[] Normalize((string? name, Type type)[] resultSets)
        {
            if (resultSets == null || resultSets.Length == 0)
                throw new ArgumentException("At least one (name?, type) must be provided.", nameof(resultSets));

            var normalized = new (string key, Type type)[resultSets.Length];
            for (int i = 0; i < resultSets.Length; i++)
            {
                var (name, type) = resultSets[i];
                normalized[i] = (string.IsNullOrWhiteSpace(name) ? type.Name : name!, type);
            }
            return normalized;
        }

        private static DynamicParameters Also(this DynamicParameters p, Action<DynamicParameters> mutate)
        {
            mutate(p);
            return p;
        }

        // ------------------------- Grouping & options -------------------------
        public sealed class StoredProcedureEndpointOptions
        {
            public string RoutePrefix { get; set; } = default!;
            public bool RequiresAuthorization { get; set; } = false;
            public bool RequiresTransaction  { get; set; } = false;

            public string[]? AllowedRoles { get; set; }
            public string[]? ReadRoles    { get; set; }
            public string[]? CreateRoles  { get; set; }
            public string[]? UpdateRoles  { get; set; }
            public string[]? DeleteRoles  { get; set; }
        }

        public readonly struct SpRoute
        {
            internal SpRoute(RouteGroupBuilder group, StoredProcedureEndpointOptions opts) { Group = group; Opts = opts; }
            internal RouteGroupBuilder Group { get; }
            internal StoredProcedureEndpointOptions Opts { get; }

            public SpRoute WithGroupName(string name) { Group.WithGroupName(name); return this; }
            public SpRoute WithTags(params string[] tags) { Group.WithTags(tags); return this; }
        }

        private static RouteGroupBuilder BuildGroup(IEndpointRouteBuilder app, StoredProcedureEndpointOptions opts)
        {
            var g = app.MapGroup(opts.RoutePrefix);
            if (opts.RequiresAuthorization)
            {
                g = (opts.AllowedRoles is { Length: > 0 })
                    ? g.RequireAuthorization(p => p.RequireRole(opts.AllowedRoles))
                    : g.RequireAuthorization();
            }
            return g;
        }

        public static SpRoute MapSpGroup(this IEndpointRouteBuilder app, StoredProcedureEndpointOptions opts)
            => new SpRoute(BuildGroup(app, opts), opts);

        // ------------------------- Multi-result (UNDERSTANDABLE NAMES) -------------------------

        /// <summary>
        /// Maps a POST endpoint that calls a stored procedure returning multiple result sets
        /// and returns them as a single object with named arrays. Filter body is a typed DTO (e.g., CommonFilterDto).
        /// Any property ending with "*Ids" on the DTO is sent as TVP (dbo.IntList).
        /// Only non-null properties are sent to SQL; @UserId is added automatically by the service.
        /// </summary>
        public static RouteHandlerBuilder MapStoredProcedureMultiResult<TFilter>(
            this SpRoute r,
            string route,
            string procedure,
            params (string? name, Type type)[] resultSets)
            where TFilter : class
        {
            var normalized = Normalize(resultSets);

            var b = r.Group.MapPost(route, async (
                TFilter? filter,
                IDapperService d,
                HttpContext ctx) =>
            {
                var dp = BuildParamsWithTvps(filter);

                var dict = await d.QueryMultipleAsDictionaryAsync(
                    procedure: procedure,
                    param: dp,
                    uow: null,
                    userId: GetUserId(ctx),   // ← always include UserId
                    normalized
                );

                return Results.Ok(ApiResponse<object>.Ok(dict));
            });

            b.ApplyAuth(r.Opts.RequiresAuthorization, r.Opts.ReadRoles, r.Opts.AllowedRoles)
             .MaybeTx(r.Opts.RequiresTransaction);

            return b;
        }

        /// <summary>
        /// Same as MapStoredProcedureMultiResult&lt;TFilter&gt; but accepts a raw JSON object
        /// (Dictionary&lt;string, JsonElement&gt;) as the filter. Useful for fully dynamic calls.
        /// </summary>
        public static RouteHandlerBuilder MapStoredProcedureMultiResult(
            this SpRoute r,
            string route,
            string procedure,
            params (string? name, Type type)[] resultSets)
        {
            var normalized = Normalize(resultSets);

            var b = r.Group.MapPost(route, async (
                IDictionary<string, JsonElement>? filter,
                IDapperService d,
                HttpContext ctx) =>
            {
                var dp = filter == null ? new DynamicParameters() : BuildParamsWithTvps(filter);

                var dict = await d.QueryMultipleAsDictionaryAsync(
                    procedure: procedure,
                    param: dp,
                    uow: null,
                    userId: GetUserId(ctx),   // ← always include UserId
                    normalized
                );

                return Results.Ok(ApiResponse<object>.Ok(dict));
            });

            b.ApplyAuth(r.Opts.RequiresAuthorization, r.Opts.ReadRoles, r.Opts.AllowedRoles)
             .MaybeTx(r.Opts.RequiresTransaction);

            return b;
        }

        // ------------------------- (Optional) Single-result helpers kept for completeness -------------------------

        public static RouteHandlerBuilder MapStoredProcedureGetList<TItem>(this SpRoute r, string route, string procedure)
            where TItem : class
        {
            var b = r.Group.MapGet(route, async (IDapperService d, HttpContext ctx) =>
            {
                var rows = await d.QueryAsync<TItem>(procedure, param: null, uow: null, userId: GetUserId(ctx));
                return Results.Ok(ApiResponse<IEnumerable<TItem>>.Ok(rows));
            });
            b.ApplyAuth(r.Opts.RequiresAuthorization, r.Opts.ReadRoles, r.Opts.AllowedRoles);
            return b;
        }

        public static RouteHandlerBuilder MapStoredProcedureGetList<TItem, TFilter>(this SpRoute r, string route, string procedure)
            where TItem : class
            where TFilter : class, new()
        {
            var b = r.Group.MapGet(route, async ([AsParameters] TFilter filter, IDapperService d, HttpContext ctx) =>
            {
                var dp = BuildParamsWithTvps(filter);
                var rows = await d.QueryAsync<TItem>(procedure, dp, uow: null, userId: GetUserId(ctx));
                return Results.Ok(ApiResponse<IEnumerable<TItem>>.Ok(rows));
            });
            b.ApplyAuth(r.Opts.RequiresAuthorization, r.Opts.ReadRoles, r.Opts.AllowedRoles);
            return b;
        }



        

        public static RouteHandlerBuilder MapStoredProcedureGetById<TItem>(this SpRoute r, string route, string procedure)
            where TItem : class
        {
            var b = r.Group.MapGet(route, async (int id, IDapperService d, HttpContext ctx) =>
            {
                var row = await d.QuerySingleAsync<TItem>(procedure, new { Id = id }, userId: GetUserId(ctx));
                return row is null
                    ? Results.NotFound(ApiResponse<object>.FailSingle("Not found."))
                    : Results.Ok(ApiResponse<TItem>.Ok(row));
            });
            b.ApplyAuth(r.Opts.RequiresAuthorization, r.Opts.ReadRoles, r.Opts.AllowedRoles);
            return b;
        }

        public static RouteHandlerBuilder MapStoredProcedureInsert<TCreate>(this SpRoute r, string route, string procedure, Func<TCreate, object>? buildInsert = null)
            where TCreate : class
        {
            var b = r.Group.MapPost(route, async (TCreate dto, IDapperService d, HttpContext ctx) =>
            {
                var spParam = buildInsert?.Invoke(dto) ?? BuildParamsWithTvps(dto);
                var (ok, msg) = await d.ExecuteWithOutputAsync(procedure, spParam, userId: GetUserId(ctx));
                return ok ? Results.Ok(ApiResponse<object>.Ok(null, msg))
                          : Results.BadRequest(ApiResponse<object>.FailSingle(msg));
            });
            b.ApplyAuth(r.Opts.RequiresAuthorization, r.Opts.CreateRoles, r.Opts.AllowedRoles)
             .MaybeTx(r.Opts.RequiresTransaction);
            return b;
        }

        public static RouteHandlerBuilder MapStoredProcedureUpdate<TUpdate>(this SpRoute r, string route, string procedure, Func<int, TUpdate, object>? buildUpdate = null)
            where TUpdate : class
        {
            var b = r.Group.MapPut(route, async (int id, TUpdate dto, IDapperService d, HttpContext ctx) =>
            {
                object spParam = buildUpdate != null
                    ? buildUpdate(id, dto)
                    : BuildParamsWithTvps(dto).Also(p => p.Add("Id", id));

                var (ok, msg) = await d.ExecuteWithOutputAsync(procedure, spParam, userId: GetUserId(ctx));
                return ok ? Results.Ok(ApiResponse<object>.Ok(null, msg))
                          : Results.BadRequest(ApiResponse<object>.FailSingle(msg));
            });
            b.ApplyAuth(r.Opts.RequiresAuthorization, r.Opts.UpdateRoles, r.Opts.AllowedRoles)
             .MaybeTx(r.Opts.RequiresTransaction);
            return b;
        }

        public static RouteHandlerBuilder MapStoredProcedureDelete(this SpRoute r, string route, string procedure)
        {
            var b = r.Group.MapDelete(route, async (int id, IDapperService d, HttpContext ctx) =>
            {
                var (ok, msg) = await d.ExecuteWithOutputAsync(procedure, new { Id = id }, userId: GetUserId(ctx));
                return ok ? Results.Ok(ApiResponse<object>.Ok(null, msg))
                          : Results.BadRequest(ApiResponse<object>.FailSingle(msg));
            });
            b.ApplyAuth(r.Opts.RequiresAuthorization, r.Opts.DeleteRoles, r.Opts.AllowedRoles)
             .MaybeTx(r.Opts.RequiresTransaction);
            return b;
        }
    }
}
