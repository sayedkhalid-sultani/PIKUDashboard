// StoredProcedureEndpointExtensions.cs
using System;
using System.Collections;
using System.Data;
using System.Reflection;
using System.Security.Claims;
using Dapper;
using GenericMinimalApi.Filters;   // TransactionFilter
using GenericMinimalApi.Models;    // ApiResponse<T>
using GenericMinimalApi.Services;  // IDapperService
using Microsoft.AspNetCore.Builder; // For .WithTags/.WithGroupName
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;     // [AsParameters]
using Microsoft.AspNetCore.Routing;
 // For OpenAPI metadata


namespace GenericMinimalApi.Extensions
{
    public sealed class NoFilter { }

    public static class StoredProcedureEndpointExtensions
    {
        private const string IntListTypeName = "dbo.IntList";

        private static int? GetUserId(HttpContext ctx)
        {
            var s = ctx.User.FindFirstValue(ClaimTypes.NameIdentifier);
            return int.TryParse(s, out var id) ? id : (int?)null;
        }

        // ---- RouteHandlerBuilder helpers ----
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

        // ---- TVP helpers ----
        private static IEnumerable<int>? TryToIntEnumerable(object? value)
        {
            if (value == null) return null;

            if (value is string s)
            {
                var parts = s.Split(new[] { ',', ';' }, StringSplitOptions.RemoveEmptyEntries);
                var list = new List<int>();
                foreach (var part in parts)
                    if (int.TryParse(part.Trim(), out var n)) list.Add(n);
                return list.Count > 0 ? list : null;
            }

            if (value is IEnumerable enumerable and not string)
            {
                var list = new List<int>();
                foreach (var item in enumerable)
                {
                    if (item is int i) list.Add(i);
                    else if (item is long l) list.Add((int)l);
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

        private static DynamicParameters BuildParamsWithTvps(object? dtoOrFilter)
        {
            var p = new DynamicParameters();
            if (dtoOrFilter == null) return p;

            foreach (var prop in dtoOrFilter.GetType().GetProperties(BindingFlags.Instance | BindingFlags.Public))
            {
                var name = prop.Name;
                var value = prop.GetValue(dtoOrFilter);

                // ONLY treat "*Ids" properties as TVPs.
                var isTvpCandidate = name.EndsWith("Ids", StringComparison.OrdinalIgnoreCase);

                if (isTvpCandidate)
                {
                    var ids = TryToIntEnumerable(value);
                    if (ids != null) AddIntListTvp(p, name, ids);
                    continue;
                }

                p.Add(name, value);
            }

            return p;
        }

        private static DynamicParameters Also(this DynamicParameters p, Action<DynamicParameters> mutate)
        {
            mutate(p);
            return p;
        }

        // ───────────────────────── Fluent API types ─────────────────────────

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

        /// <summary>Wrapper that carries the group and the options so we can chain.</summary>
        public readonly struct SpRoute
        {
            internal SpRoute(RouteGroupBuilder group, StoredProcedureEndpointOptions opts)
            { Group = group; Opts = opts; }

            internal RouteGroupBuilder Group { get; }
            internal StoredProcedureEndpointOptions Opts { get; }

            // Group-level OpenAPI conveniences (chainable)
            public SpRoute WithGroupName(string name)
            {
                Group.WithGroupName(name);
                return this;
            }

            public SpRoute WithTags(params string[] tags)
            {
                Group.WithTags(tags);
                return this;
            }
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

        /// <summary>Create a secured group and return a fluent builder.</summary>
        public static SpRoute MapSpGroup(this IEndpointRouteBuilder app, StoredProcedureEndpointOptions opts)
            => new SpRoute(BuildGroup(app, opts), opts);

        // ───────────────────────── Fluent (SpRoute-returning) mappers ─────────────────────────
        // Use these when you want to keep chaining more endpoints on the same group.

        public static SpRoute MapSpInsert<TCreate>(
            this SpRoute r,
            string route,
            string procedure,
            Func<TCreate, object>? buildInsert = null)
            where TCreate : class
        {
            r.Group.MapPost(route, async (TCreate dto, IDapperService d, HttpContext ctx) =>
            {
                var spParam = buildInsert?.Invoke(dto) ?? BuildParamsWithTvps(dto);
                var (ok, msg) = await d.ExecuteWithOutputAsync(procedure, spParam, userId: GetUserId(ctx));
                return ok ? Results.Ok(ApiResponse<object>.Ok(null, msg))
                          : Results.BadRequest(ApiResponse<object>.FailSingle(msg));
            })
            .ApplyAuth(r.Opts.RequiresAuthorization, r.Opts.CreateRoles, r.Opts.AllowedRoles)
            .MaybeTx(r.Opts.RequiresTransaction);

            return r;
        }

        public static SpRoute MapSpUpdate<TUpdate>(
            this SpRoute r,
            string route,
            string procedure,
            Func<int, TUpdate, object>? buildUpdate = null)
            where TUpdate : class
        {
            r.Group.MapPut(route, async (int id, TUpdate dto, IDapperService d, HttpContext ctx) =>
            {
                object spParam = buildUpdate != null
                    ? buildUpdate(id, dto)
                    : BuildParamsWithTvps(dto).Also(p => p.Add("Id", id));

                var (ok, msg) = await d.ExecuteWithOutputAsync(procedure, spParam, userId: GetUserId(ctx));
                return ok ? Results.Ok(ApiResponse<object>.Ok(null, msg))
                          : Results.BadRequest(ApiResponse<object>.FailSingle(msg));
            })
            .ApplyAuth(r.Opts.RequiresAuthorization, r.Opts.UpdateRoles, r.Opts.AllowedRoles)
            .MaybeTx(r.Opts.RequiresTransaction);

            return r;
        }

        public static SpRoute MapSpDelete(this SpRoute r, string route, string procedure)
        {
            r.Group.MapDelete(route, async (int id, IDapperService d, HttpContext ctx) =>
            {
                var (ok, msg) = await d.ExecuteWithOutputAsync(procedure, new { Id = id }, userId: GetUserId(ctx));
                return ok ? Results.Ok(ApiResponse<object>.Ok(null, msg))
                          : Results.BadRequest(ApiResponse<object>.FailSingle(msg));
            })
            .ApplyAuth(r.Opts.RequiresAuthorization, r.Opts.DeleteRoles, r.Opts.AllowedRoles)
            .MaybeTx(r.Opts.RequiresTransaction);

            return r;
        }

        public static SpRoute MapSpSelectGet<TItem>(this SpRoute r, string route, string procedure)
            where TItem : class
        {
            r.Group.MapGet(route, async (IDapperService d, HttpContext ctx) =>
            {
                var rows = await d.QueryAsync<TItem>(procedure, param: null, uow: null, userId: GetUserId(ctx));
                return Results.Ok(ApiResponse<IEnumerable<TItem>>.Ok(rows));
            })
            .ApplyAuth(r.Opts.RequiresAuthorization, r.Opts.ReadRoles, r.Opts.AllowedRoles);

            return r;
        }

        public static SpRoute MapSpSelectGet<TItem, TFilter>(this SpRoute r, string route, string procedure)
            where TItem : class
            where TFilter : class, new()
        {
            r.Group.MapGet(route, async ([AsParameters] TFilter filter, IDapperService d, HttpContext ctx) =>
            {
                var dp = BuildParamsWithTvps(filter);
                var rows = await d.QueryAsync<TItem>(procedure, dp, uow: null, userId: GetUserId(ctx));
                return Results.Ok(ApiResponse<IEnumerable<TItem>>.Ok(rows));
            })
            .ApplyAuth(r.Opts.RequiresAuthorization, r.Opts.ReadRoles, r.Opts.AllowedRoles);

            return r;
        }

        public static SpRoute MapSpGetById<TItem>(this SpRoute r, string route, string procedure)
            where TItem : class
        {
            r.Group.MapGet(route, async (int id, IDapperService d, HttpContext ctx) =>
            {
                var row = await d.QuerySingleAsync<TItem>(procedure, new { Id = id }, userId: GetUserId(ctx));
                return row is null
                    ? Results.NotFound(ApiResponse<object>.FailSingle("Not found."))
                    : Results.Ok(ApiResponse<TItem>.Ok(row));
            })
            .ApplyAuth(r.Opts.RequiresAuthorization, r.Opts.ReadRoles, r.Opts.AllowedRoles);

            return r;
        }

        public static SpRoute MapSpSelect<TItem>(this SpRoute r, string route, string procedure)
            where TItem : class
        {
            r.Group.MapPost(route, async (IDapperService d, HttpContext ctx) =>
            {
                var rows = await d.QueryAsync<TItem>(procedure, param: null, uow: null, userId: GetUserId(ctx));
                return Results.Ok(ApiResponse<IEnumerable<TItem>>.Ok(rows));
            })
            .ApplyAuth(r.Opts.RequiresAuthorization, r.Opts.ReadRoles, r.Opts.AllowedRoles);

            return r;
        }

        public static SpRoute MapSpSelect<TItem, TFilter>(this SpRoute r, string route, string procedure)
            where TItem : class
            where TFilter : class
        {
            r.Group.MapPost(route, async (TFilter? filter, IDapperService d, HttpContext ctx) =>
            {
                var dp = BuildParamsWithTvps(filter);
                var rows = await d.QueryAsync<TItem>(procedure, dp, uow: null, userId: GetUserId(ctx));
                return Results.Ok(ApiResponse<IEnumerable<TItem>>.Ok(rows));
            })
            .ApplyAuth(r.Opts.RequiresAuthorization, r.Opts.ReadRoles, r.Opts.AllowedRoles);

            return r;
        }

        // ───────────────────────── BUILDER-returning overloads ─────────────────────────
        // Use these when you want to chain .WithName/.WithTags/.WithSummary on the endpoint.

        public static RouteHandlerBuilder MapSpSelectGetB<TItem>(this SpRoute r, string route, string procedure)
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

        public static RouteHandlerBuilder MapSpSelectGetB<TItem, TFilter>(this SpRoute r, string route, string procedure)
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

        public static RouteHandlerBuilder MapSpGetByIdB<TItem>(this SpRoute r, string route, string procedure)
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

        public static RouteHandlerBuilder MapSpInsertB<TCreate>(this SpRoute r, string route, string procedure, Func<TCreate, object>? buildInsert = null)
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

        public static RouteHandlerBuilder MapSpUpdateB<TUpdate>(this SpRoute r, string route, string procedure, Func<int, TUpdate, object>? buildUpdate = null)
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

        public static RouteHandlerBuilder MapSpDeleteB(this SpRoute r, string route, string procedure)
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

        // (Add builder-returning MultiSelect variants if you need to tag those individually)
    }
}
