// Extensions/DtoGenerationExtensions.cs
using System.Text;
using System.Text.RegularExpressions;
using Dapper;
using Microsoft.Data.SqlClient;

namespace YourApp.Extensions;

public static class DtoGenerationExtensions
{
    // ---------------- Public options ----------------
    public sealed class DtoGenOptions
    {
        public string Namespace { get; set; } = "YourApp.Contracts";
        public string OutputRoot { get; set; } = "Generated";
        public string TablesFolderName { get; set; } = "Tables";
        public string ProcsFolderName  { get; set; } = "StoredProcedures";
        public string TablesFileName { get; set; } = "TablesDtos.cs";
        public string ProcsFileName  { get; set; } = "StoreProcedureDtos.cs";

        public bool IncludeChildCollections { get; set; } = true;  // parent -> children
        public bool IncludeStoredProcParams { get; set; } = true;  // SP params + TVP rows
        public bool IncludeParentNavigation { get; set; } = true;  // child -> parent
    }

    // ---------------- Entry points (choose one or use both) ----------------

    /// <summary>
    /// Runs the generator immediately (no HTTP endpoint). Call from Program.cs.
    /// </summary>
    public static async Task GenerateDtosNowAsync(this WebApplication app, Action<DtoGenOptions>? configure = null)
    {
        var opts = BuildDefaultOptions(app, configure);

        var cs = app.Configuration.GetConnectionString("DefaultConnection")
            ?? app.Configuration["ConnectionStrings:DefaultConnection"]
            ?? throw new InvalidOperationException("Connection string not found.");

        var generator = new DtoGenerator(cs, opts);
        await generator.GenerateAsync();
        app.Logger.LogInformation("DTOs generated into {Root}", Path.GetFullPath(opts.OutputRoot));
    }

    /// <summary>
    /// Exposes GET {route} to run the generator on demand.
    /// </summary>
    public static IEndpointRouteBuilder MapDtoGenerator(
        this IEndpointRouteBuilder endpoints,
        string route = "/tools/generate-dtos",
        Action<DtoGenOptions>? configure = null)
    {
        var app = (endpoints as WebApplication) ?? throw new InvalidOperationException("Use with WebApplication");
        var opts = BuildDefaultOptions(app, configure);

        endpoints.MapGet(route, async () =>
        {
            var cs = app.Configuration.GetConnectionString("DefaultConnection")
                ?? app.Configuration["ConnectionStrings:DefaultConnection"]
                ?? throw new InvalidOperationException("Connection string not found.");

            var generator = new DtoGenerator(cs, opts);
            var result = await generator.GenerateAsync();
            return Results.Ok(result);
        });

        return endpoints;
    }

    private static DtoGenOptions BuildDefaultOptions(WebApplication app, Action<DtoGenOptions>? configure)
    {
        var opts = new DtoGenOptions
        {
            // sensible default under the project folder
            OutputRoot = Path.GetFullPath(Path.Combine(app.Environment.ContentRootPath, "Generated"))
        };
        configure?.Invoke(opts);
        return opts;
    }

    // ---------------- Implementation ----------------

    private sealed class DtoGenerator
    {
        private readonly string _cs;
        private readonly DtoGenOptions _opt;

        public DtoGenerator(string connectionString, DtoGenOptions opt)
        {
            _cs = connectionString;
            _opt = opt;
        }

        public async Task<object> GenerateAsync()
        {
            using var conn = new SqlConnection(_cs);
            await conn.OpenAsync();

            // Tables metadata
            var tables = (await conn.QueryAsync<TableInfo>(SqlGetTables)).ToList();
            var cols   = (await conn.QueryAsync<ColumnInfo>(SqlGetColumns)).ToList();
            var fks    = (await conn.QueryAsync<ForeignKeyInfo>(SqlGetForeignKeys)).ToList();

            var tableCols = cols.GroupBy(c => (c.SchemaName, c.TableName))
                                .ToDictionary(g => (g.Key.SchemaName, g.Key.TableName),
                                              g => g.OrderBy(x => x.OrdinalPosition).ToList());

            var childrenByParent = fks.GroupBy(f => (f.ParentSchema, f.ParentTable))
                                      .ToDictionary(g => (g.Key.ParentSchema, g.Key.ParentTable), g => g.ToList());

            var parentsByChild = fks.GroupBy(f => (f.ChildSchema, f.ChildTable))
                                    .ToDictionary(g => (g.Key.ChildSchema, g.Key.ChildTable), g => g.ToList());

            // Procedures metadata (optional)
            List<ProcInfo> procs = new();
            List<ProcParamInfo> procParams = new();
            List<TvpColumnInfo> tvpColumns = new();

            if (_opt.IncludeStoredProcParams)
            {
                procs      = (await conn.QueryAsync<ProcInfo>(SqlGetProcs)).ToList();
                procParams = (await conn.QueryAsync<ProcParamInfo>(SqlGetProcParams)).ToList();
                tvpColumns = (await conn.QueryAsync<TvpColumnInfo>(SqlGetTvpColumns)).ToList();
            }

            var paramsByProc = procParams.GroupBy(p => (p.SchemaName, p.ProcName, p.ProcId))
                                         .ToDictionary(g => (g.Key.SchemaName, g.Key.ProcName, g.Key.ProcId),
                                                       g => g.OrderBy(p => p.ParameterId).ToList());

            var tvpColsByTypeId = tvpColumns.GroupBy(t => t.UserTypeId)
                                            .ToDictionary(g => g.Key, g => g.OrderBy(x => x.OrdinalPosition).ToList());

            // Build tables file
            var tablesSb = new StringBuilder();
            AppendHeader(tablesSb, _opt.Namespace);

            foreach (var t in tables)
            {
                var key = (t.SchemaName, t.TableName);
                if (!tableCols.TryGetValue(key, out var tcols)) continue;

                var recordName = ToPascal($"{t.TableName}Dto");
                tablesSb.AppendLine($"public record {recordName}");
                tablesSb.AppendLine("{");

                // scalar props
                foreach (var c in tcols)
                {
                    var csharpType = MapSqlToCSharp(c.DataType, c.IsNullable);
                    var propName   = ToPascal(c.ColumnName);
                    tablesSb.AppendLine($"    public {csharpType} {propName} {{ get; init; }}");
                }

                // child -> parent navigations on child
                if (_opt.IncludeParentNavigation && parentsByChild.TryGetValue(key, out var parentFks))
                {
                    foreach (var grp in parentFks.GroupBy(f => (f.ParentSchema, f.ParentTable)))
                    {
                        var parentDto = ToPascal($"{grp.Key.ParentTable}Dto");

                        if (grp.Count() == 1)
                        {
                            var propName = parentDto.Replace("Dto", "");
                            tablesSb.AppendLine($"    public {parentDto}? {propName} {{ get; init; }}");
                        }
                        else
                        {
                            foreach (var fk in grp)
                            {
                                var suffix = ToPascal(fk.ChildColumn);
                                var propName = $"{parentDto.Replace("Dto", "")}By{suffix}";
                                tablesSb.AppendLine($"    public {parentDto}? {propName} {{ get; init; }}");
                            }
                        }
                    }
                }

                // parent -> children collections
                if (_opt.IncludeChildCollections && childrenByParent.TryGetValue(key, out var childFks))
                {
                    foreach (var grp in childFks.GroupBy(x => (x.ChildSchema, x.ChildTable)))
                    {
                        var childRecord = ToPascal($"{grp.Key.ChildTable}Dto");
                        var propName    = ToPascal(Pluralize(grp.Key.ChildTable));
                        tablesSb.AppendLine($"    public List<{childRecord}> {propName} {{ get; init; }} = new();");
                    }
                }

                tablesSb.AppendLine("}");
                tablesSb.AppendLine();
            }

            // Build procs file
            var procsSb = new StringBuilder();
            AppendHeader(procsSb, _opt.Namespace);

            if (_opt.IncludeStoredProcParams)
            {
                var usedTvpTypeIds = new HashSet<int>(procParams.Where(p => p.IsTableType).Select(p => p.UserTypeId));
                foreach (var typeId in usedTvpTypeIds)
                {
                    if (!tvpColsByTypeId.TryGetValue(typeId, out var colsForType)) continue;

                    var rowRecord = ToPascal($"{colsForType.First().TypeName}Row");
                    procsSb.AppendLine($"public record {rowRecord}");
                    procsSb.AppendLine("{");
                    foreach (var c in colsForType)
                    {
                        var csharpType = MapSqlToCSharp(c.DataType, c.IsNullable);
                        var propName   = ToPascal(c.ColumnName);
                        procsSb.AppendLine($"    public {csharpType} {propName} {{ get; init; }}");
                    }
                    procsSb.AppendLine("}");
                    procsSb.AppendLine();
                }

                foreach (var p in procs.OrderBy(p => p.SchemaName).ThenBy(p => p.ProcName))
                {
                    var key = (p.SchemaName, p.ProcName, p.ProcId);
                    if (!paramsByProc.TryGetValue(key, out var plist)) continue;

                    var dtoName = ToPascal($"{p.ProcName}Params");
                    procsSb.AppendLine($"public record {dtoName}");
                    procsSb.AppendLine("{");

                    foreach (var prm in plist)
                    {
                        var cleanName = (prm.ParamName ?? "").TrimStart('@');
                        var propName  = ToPascal(string.IsNullOrWhiteSpace(cleanName) ? "Param" + prm.ParameterId : cleanName);

                        string propType;
                        if (prm.IsTableType)
                        {
                            if (tvpColsByTypeId.TryGetValue(prm.UserTypeId, out var _))
                            {
                                var tvpTypeName = tvpColsByTypeId[prm.UserTypeId].First().TypeName;
                                var rowRecord   = ToPascal($"{tvpTypeName}Row");
                                propType = $"List<{rowRecord}>";
                            }
                            else propType = "List<object>";
                        }
                        else
                        {
                            propType = MapSqlToCSharp(prm.DataType, isNullable: true);
                        }

                        var outNote = prm.IsOutput ? " // OUTPUT" : "";
                        procsSb.AppendLine($"    public {propType} {propName} {{ get; init; }}{(propType.StartsWith("List<") ? " = new();" : "")}{outNote}");
                    }

                    procsSb.AppendLine("}");
                    procsSb.AppendLine();
                }
            }

            // Write files
            var tablesDir = Path.Combine(_opt.OutputRoot, _opt.TablesFolderName);
            var procsDir  = Path.Combine(_opt.OutputRoot, _opt.ProcsFolderName);
            Directory.CreateDirectory(tablesDir);
            Directory.CreateDirectory(procsDir);

            var tablesPath = Path.Combine(tablesDir, _opt.TablesFileName);
            var procsPath  = Path.Combine(procsDir, _opt.ProcsFileName);

            await File.WriteAllTextAsync(tablesPath, tablesSb.ToString(), Encoding.UTF8);
            await File.WriteAllTextAsync(procsPath,  procsSb.ToString(),  Encoding.UTF8);

            return new { message = "DTOs generated", tablesPath, procsPath };
        }

        private static void AppendHeader(StringBuilder sb, string @namespace)
        {
            sb.AppendLine("// <auto-generated />");
            sb.AppendLine("// Re-run the generator to refresh this file.");
            sb.AppendLine("using System;");
            sb.AppendLine("using System.Collections.Generic;");
            sb.AppendLine();
            sb.AppendLine($"namespace {@namespace};");
            sb.AppendLine();
        }

        private static string MapSqlToCSharp(string sqlType, bool isNullable)
        {
            var t = (sqlType ?? "").ToLowerInvariant();
            string type = t switch
            {
                "bigint" => "long",
                "int" => "int",
                "smallint" => "short",
                "tinyint" => "byte",
                "bit" => "bool",
                "decimal" or "numeric" or "money" or "smallmoney" => "decimal",
                "float" => "double",
                "real" => "float",
                "date" or "datetime" or "datetime2" or "smalldatetime" => "DateTime",
                "datetimeoffset" => "DateTimeOffset",
                "time" => "TimeSpan",
                "uniqueidentifier" => "Guid",
                "binary" or "varbinary" or "image" or "rowversion" or "timestamp" => "byte[]",
                "char" or "nchar" or "varchar" or "nvarchar" or "text" or "ntext" or "xml" => "string",
                "sql_variant" => "object",
                _ => "string"
            };

            bool valueType = type is not ("string" or "byte[]" or "object");
            if (isNullable && valueType) type += "?";
            return type;
        }

        private static string ToPascal(string s)
        {
            var parts = Regex.Split(s ?? "", @"[^A-Za-z0-9]+").Where(p => p.Length > 0);
            var combined = string.Concat(parts.Select(p => char.ToUpperInvariant(p[0]) + (p.Length > 1 ? p[1..] : "")));
            return string.IsNullOrWhiteSpace(combined) ? "Unnamed" : combined;
        }

        private static string Pluralize(string name)
        {
            if (string.IsNullOrWhiteSpace(name)) return "Items";
            if (name.EndsWith("y", StringComparison.OrdinalIgnoreCase) &&
                name.Length > 1 &&
                !"aeiou".Contains(char.ToLowerInvariant(name[^2])))
                return name[..^1] + "ies";
            if (name.EndsWith("s", StringComparison.OrdinalIgnoreCase)) return name + "es";
            return name + "s";
        }

        // -------- SQL (metadata) --------
        private const string SqlGetTables = @"
SELECT s.name AS SchemaName, t.name AS TableName
FROM sys.tables t
JOIN sys.schemas s ON s.schema_id = t.schema_id
WHERE t.is_ms_shipped = 0
ORDER BY s.name, t.name;";

        private const string SqlGetColumns = @"
SELECT
    s.name  AS SchemaName,
    t.name  AS TableName,
    c.name  AS ColumnName,
    ty.name AS DataType,
    c.is_nullable AS IsNullable,
    c.column_id AS OrdinalPosition
FROM sys.columns c
JOIN sys.tables t ON t.object_id = c.object_id
JOIN sys.schemas s ON s.schema_id = t.schema_id
JOIN sys.types ty ON ty.user_type_id = c.user_type_id
WHERE t.is_ms_shipped = 0
ORDER BY s.name, t.name, c.column_id;";

        private const string SqlGetForeignKeys = @"
SELECT
    ps.name AS ParentSchema,
    pt.name AS ParentTable,
    pc.name AS ParentColumn,
    cs.name AS ChildSchema,
    ct.name AS ChildTable,
    cc.name AS ChildColumn,
    fk.name AS ForeignKeyName
FROM sys.foreign_keys fk
JOIN sys.foreign_key_columns fkc ON fkc.constraint_object_id = fk.object_id
JOIN sys.tables pt ON pt.object_id = fk.referenced_object_id
JOIN sys.schemas ps ON ps.schema_id = pt.schema_id
JOIN sys.columns pc ON pc.object_id = pt.object_id AND pc.column_id = fkc.referenced_column_id
JOIN sys.tables ct ON ct.object_id = fk.parent_object_id
JOIN sys.schemas cs ON cs.schema_id = ct.schema_id
JOIN sys.columns cc ON cc.object_id = ct.object_id AND cc.column_id = fkc.parent_column_id
ORDER BY ps.name, pt.name, cs.name, ct.name, fk.name;";

        private const string SqlGetProcs = @"
SELECT s.name AS SchemaName, p.name AS ProcName, p.object_id AS ProcId
FROM sys.procedures p
JOIN sys.schemas s ON s.schema_id = p.schema_id
WHERE p.is_ms_shipped = 0
ORDER BY s.name, p.name;";

        private const string SqlGetProcParams = @"
SELECT
    s.name           AS SchemaName,
    p.name           AS ProcName,
    p.object_id      AS ProcId,
    prm.parameter_id AS ParameterId,
    prm.name         AS ParamName,
    ty.name          AS DataType,
    prm.max_length   AS MaxLength,
    prm.precision    AS [Precision],
    prm.scale        AS Scale,
    prm.is_output    AS IsOutput,
    ty.is_table_type AS IsTableType,
    ty.user_type_id  AS UserTypeId
FROM sys.parameters prm
JOIN sys.procedures p ON p.object_id = prm.object_id
JOIN sys.schemas s ON s.schema_id = p.schema_id
JOIN sys.types ty ON ty.user_type_id = prm.user_type_id
ORDER BY s.name, p.name, prm.parameter_id;";

        private const string SqlGetTvpColumns = @"
SELECT
    tt.user_type_id AS UserTypeId,
    ss.name         AS TypeSchema,
    tt.name         AS TypeName,
    c.name          AS ColumnName,
    ty.name         AS DataType,
    c.is_nullable   AS IsNullable,
    c.column_id     AS OrdinalPosition
FROM sys.table_types tt
JOIN sys.schemas ss ON ss.schema_id = tt.schema_id
JOIN sys.columns c ON c.object_id = tt.type_table_object_id
JOIN sys.types ty ON ty.user_type_id = c.user_type_id
ORDER BY ss.name, tt.name, c.column_id;";
    }

    // ---------- metadata DTOs (internal) ----------
    private sealed class TableInfo
    {
        public string SchemaName { get; set; } = default!;
        public string TableName  { get; set; } = default!;
    }

    private sealed class ColumnInfo
    {
        public string SchemaName { get; set; } = default!;
        public string TableName  { get; set; } = default!;
        public string ColumnName { get; set; } = default!;
        public string DataType   { get; set; } = default!;
        public bool   IsNullable { get; set; }
        public int    OrdinalPosition { get; set; }
    }

    private sealed class ForeignKeyInfo
    {
        public string ParentSchema { get; set; } = default!;
        public string ParentTable  { get; set; } = default!;
        public string ParentColumn { get; set; } = default!;
        public string ChildSchema  { get; set; } = default!;
        public string ChildTable   { get; set; } = default!;
        public string ChildColumn  { get; set; } = default!;
        public string ForeignKeyName { get; set; } = default!;
    }

    private sealed class ProcInfo
    {
        public string SchemaName { get; set; } = default!;
        public string ProcName   { get; set; } = default!;
        public int    ProcId     { get; set; }
    }

    private sealed class ProcParamInfo
    {
        public string SchemaName { get; set; } = default!;
        public string ProcName   { get; set; } = default!;
        public int    ProcId     { get; set; }
        public int    ParameterId { get; set; }
        public string? ParamName { get; set; }
        public string DataType   { get; set; } = default!;
        public short  MaxLength  { get; set; }
        public byte   Precision  { get; set; }
        public byte   Scale      { get; set; }
        public bool   IsOutput   { get; set; }
        public bool   IsTableType { get; set; }
        public int    UserTypeId { get; set; }
    }

    private sealed class TvpColumnInfo
    {
        public int    UserTypeId { get; set; }
        public string TypeSchema { get; set; } = default!;
        public string TypeName   { get; set; } = default!;
        public string ColumnName { get; set; } = default!;
        public string DataType   { get; set; } = default!;
        public bool   IsNullable { get; set; }
        public int    OrdinalPosition { get; set; }
    }
}
