import React, { useMemo, useState, useEffect } from "react";
import DataTable from "react-data-table-component";
import { cls, toTitle, uniqueValues } from "../../utils/SmartDataTableui";

export default function SmartDataTable({
  title,
  data = [],
  columns,
  onEdit,
  onDelete,
  hiddenKeys = [],
  headerMap = {},
  dense = false,
  filterKeys,
  placeholder = "Filter…",
  cascadeLevels = [],
  initialFilters = {},
  customFilter,
  renderExtraFilters,
  onFiltersChange,
}) {
  const cascadeDefaults = useMemo(() => {
    if (!cascadeLevels?.length) return {};
    return cascadeLevels.reduce((acc, k) => ({ ...acc, [k]: "" }), {});
  }, [cascadeLevels]);

  const [filters, setFilters] = useState({
    q: "",
    ...cascadeDefaults,
    ...initialFilters,
  });

  useEffect(() => {
    onFiltersChange && onFiltersChange(filters);
  }, [filters, onFiltersChange]);

  const setFilter = (key, value) => setFilters((f) => ({ ...f, [key]: value }));
  const clearFilters = () =>
    setFilters({
      q: "",
      ...cascadeDefaults,
      ...initialFilters,
    });

  // ───────────────── auto columns ─────────────────
  const autoColumns = useMemo(() => {
    if (columns && columns.length) return columns;

    const first = data?.[0] || {};
    const keys = Object.keys(first).filter((k) => !hiddenKeys.includes(k));

    const generated = keys.map((key) => ({
      name: headerMap[key] || toTitle(key),
      selector: (row) => row?.[key],
      sortable: true,
      wrap: true,
      cell: (row) => {
        const v = row?.[key];
        if (v === null || v === undefined) return "";
        if (typeof v === "object") return JSON.stringify(v);
        return String(v);
      },
    }));

    if (onEdit || onDelete) {
      generated.push({
        name: "Actions",
        width: "160px",
        // ⚠️ removed: right/button/allowOverflow — they leak to DOM with sc@6
        cell: (row) => (
          <div className="flex w-full justify-end gap-2 overflow-visible">
            {onEdit && (
              <button
                onClick={() => onEdit(row)}
                className="bg-blue-500 hover:bg-blue-600 text-white px-3 py-1 rounded text-sm"
                type="button"
              >
                Edit
              </button>
            )}
            {onDelete && (
              <button
                onClick={() => onDelete(row)}
                className="bg-red-500 hover:bg-red-600 text-white px-3 py-1 rounded text-sm"
                type="button"
              >
                Delete
              </button>
            )}
          </div>
        ),
        ignoreRowClick: true, // keep this, it's safe
      });
    }

    return generated;
  }, [columns, data, hiddenKeys, headerMap, onEdit, onDelete]);

  const visibleKeys = useMemo(() => {
    if (columns && columns.length) return null;
    const first = data?.[0] || {};
    return Object.keys(first).filter((k) => !hiddenKeys.includes(k));
  }, [columns, data, hiddenKeys]);

  const filteredData = useMemo(() => {
    const q = filters.q.trim().toLowerCase();
    const keysToSearch =
      filterKeys && filterKeys.length ? filterKeys : visibleKeys || null;

    return data.filter((row) => {
      if (q) {
        const keys = keysToSearch || Object.keys(row);
        let pass = false;
        for (const k of keys) {
          const v = row[k];
          if (v == null) continue;
          const s = typeof v === "object" ? JSON.stringify(v) : String(v);
          if (s.toLowerCase().includes(q)) {
            pass = true;
            break;
          }
        }
        if (!pass) return false;
      }

      if (cascadeLevels?.length) {
        for (const lv of cascadeLevels) {
          if (filters[lv] && row[lv] !== filters[lv]) return false;
        }
      }

      if (typeof customFilter === "function") {
        return customFilter(row, filters);
      }

      return true;
    });
  }, [data, filters, filterKeys, visibleKeys, customFilter, cascadeLevels]);

  const CascadeControls = () => {
    if (!cascadeLevels?.length) return null;

    const selects = [];

    for (let i = 0; i < cascadeLevels.length; i++) {
      const field = cascadeLevels[i];

      const prev = {};
      for (let j = 0; j < i; j++)
        prev[cascadeLevels[j]] = filters[cascadeLevels[j]];

      const opts = uniqueValues(data, field, prev);
      const disabled =
        i > 0 && !cascadeLevels.slice(0, i).every((k) => !!filters[k]);

      selects.push(
        <select
          key={field}
          className={cls.select}
          value={filters[field] || ""}
          onChange={(e) => {
            const next = e.target.value;
            setFilter(field, next);
            for (let k = i + 1; k < cascadeLevels.length; k++)
              setFilter(cascadeLevels[k], "");
          }}
          disabled={disabled}
          title={toTitle(field)}
        >
          <option value="">
            {disabled
              ? `Select ${toTitle(cascadeLevels[i - 1])} first`
              : `All ${toTitle(field)}s`}
          </option>
          {opts.map((o) => (
            <option key={o} value={o}>
              {o}
            </option>
          ))}
        </select>
      );
    }

    return (
      <>
        {selects}
        <button
          type="button"
          onClick={() => cascadeLevels.forEach((lv) => setFilter(lv, ""))}
          className={cls.btn}
          title="Reset cascade filters"
        >
          Reset
        </button>
      </>
    );
  };

  return (
    <div className="border border-gray-300 rounded overflow-hidden">
      {(title || true) && (
        <div className="bg-gray-100 px-4 py-3 border-b border-gray-300 flex flex-col gap-2 md:flex-row md:items-center md:justify-between">
          <h2 className="text-base font-medium text-gray-700">{title}</h2>

          {/* Toolbar */}
          <div className="flex flex-wrap items-center gap-2">
            <input
              value={filters.q}
              onChange={(e) => setFilter("q", e.target.value)}
              placeholder={placeholder}
              className="w-56 px-2 py-1.5 text-sm border border-gray-300 rounded focus:outline-none focus:ring-2 focus:ring-blue-400"
              type="text"
            />
            {filters.q && (
              <button
                type="button"
                onClick={() => setFilter("q", "")}
                className={cls.btn}
                title="Clear search"
              >
                Clear
              </button>
            )}

            <CascadeControls />

            {typeof renderExtraFilters === "function" &&
              renderExtraFilters({ filters, setFilter, clearFilters, data })}
          </div>
        </div>
      )}

      <DataTable
        data={filteredData}
        columns={autoColumns}
        pagination
        highlightOnHover
        dense={dense}
        persistTableHead
        responsive
        className="border border-gray-300"
        customStyles={{
          headCells: {
            style: {
              borderRight: "1px solid #d1d5db",
              borderBottom: "1px solid #d1d5db",
              backgroundColor: "#f9fafb",
            },
          },
          cells: {
            style: {
              borderRight: "1px solid #d1d5db",
              borderBottom: "1px solid #d1d5db",
            },
          },
        }}
      />
    </div>
  );
}
