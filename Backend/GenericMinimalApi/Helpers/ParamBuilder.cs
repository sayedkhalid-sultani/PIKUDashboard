using System;
using System.Collections.Generic;
using System.Data;
using System.Reflection;
using Dapper;

namespace GenericMinimalApi.Helpers
{
    public static class ParamBuilder
    {
        /// <summary>
        /// Builds DynamicParameters from any DTO.
        /// - Skips null values (so you only send what you provided).
        /// - If property name ends with "Ids" and value is a list of ints,
        ///   it will be sent as TVP (expects dbo.IntList with column [Id]).
        /// </summary>
        public static DynamicParameters From<T>(T dto)
        {
            var dp = new DynamicParameters();
            if (dto == null) return dp;

            foreach (var prop in dto.GetType()
                                    .GetProperties(BindingFlags.Public | BindingFlags.Instance))
            {
                if (prop.GetIndexParameters().Length > 0 || !prop.CanRead)
                    continue;

                var name = prop.Name;
                var value = prop.GetValue(dto);

                if (value == null) 
                    continue; // ✅ skip if not provided

                if (name.EndsWith("Ids", StringComparison.OrdinalIgnoreCase) && value is IEnumerable<int> ids)
                {
                    var tvp = new DataTable();
                    tvp.Columns.Add("Id", typeof(int));
                    foreach (var id in ids)
                        tvp.Rows.Add(id);

                    dp.Add(name, tvp.AsTableValuedParameter("dbo.IntList"));
                }
                else
                {
                    dp.Add(name, value);
                }
            }

            return dp;
        }
    }
}
