using System;
using System.Reflection;
using Dapper;

namespace GenericMinimalApi.Helpers
{
    public static class ParamBuilder
    {
        public static DynamicParameters From<T>(T dto)
        {
            var dp = new DynamicParameters();
            if (dto == null)
                return dp;

            // Only public instance properties
            var props = dto.GetType()
                           .GetProperties(BindingFlags.Public | BindingFlags.Instance);

            foreach (var prop in props)
            {
                // **Skip** indexer properties (they have GetIndexParameters().Length > 0)
                if (prop.GetIndexParameters().Length > 0)
                    continue;

                // Should have a public getter
                if (!prop.CanRead)
                    continue;

                // Read the value
                var value = prop.GetValue(dto, null);

                // Skip nulls (optional: you can also skip defaults if you want)
                if (value == null)
                    continue;

                dp.Add(prop.Name, value);
            }

            return dp;
        }
    }
}
