// utils/ui.js
export const cls = {
  page: "p-4",
  select: "px-2 py-1.5 text-sm border border-gray-300 rounded",
  btn: "text-sm px-2 py-1.5 border border-gray-300 rounded hover:bg-gray-200",
};

export const cx = (...parts) => parts.filter(Boolean).join(" ");

export const toTitle = (s) =>
  String(s)
    .replace(/[_\-]+/g, " ")
    .replace(/([a-z])([A-Z])/g, "$1 $2")
    .replace(/\s+/g, " ")
    .trim()
    .replace(/^./, (c) => c.toUpperCase());

/** unique values for a field, given pre-filters `{key:value}` */
export const uniqueValues = (list, field, filterObj) => {
  const s = new Set();
  list.forEach((r) => {
    const ok = Object.entries(filterObj).every(([k, v]) => !v || r[k] === v);
    if (ok && r[field]) s.add(r[field]);
  });
  return Array.from(s).sort();
};
