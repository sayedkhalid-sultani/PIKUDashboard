/*
 * Form <-> API helpers that auto-handle fields ending with Id/IDs/Ids/ids.
 *
 * Exports:
 *  - processFormPayload(fields, payload): form -> API
 *  - buildFormInitialValues(fields, apiData, opts): API -> form
 */

// ---------- helpers ----------
const norm = (k) => (k || "").toLowerCase().replace(/[^a-z0-9]/g, "");
const endsWithIds = (s) => /ids$/i.test(s || "");
const endsWithId = (s) => /id$/i.test(s || "") && !/ids$/i.test(s || "");

/** Infer target type from field config + name suffixes */
function inferIntent(field) {
  const name = field?.name || "";
  const suffixArray = endsWithIds(name);
  const suffixSingle = endsWithId(name);
  const wantNumber =
    (field.valueType || (suffixArray || suffixSingle ? "number" : "string")) ===
    "number";
  const wantArray = field.type === "multiselect" || suffixArray === true;

  return { wantNumber, wantArray };
}

function toNum(x) {
  const n = typeof x === "number" ? x : Number(x);
  return Number.isFinite(n) ? n : null;
}

function unwrapOption(x) {
  if (x && typeof x === "object") {
    if ("value" in x) return x.value;
    if ("id" in x) return x.id;
    if ("Id" in x) return x.Id;
    if ("ID" in x) return x.ID;
  }
  return x;
}

// ---------- form -> API ----------
export function processFormPayload(fields, payload) {
  const out = {};
  for (const f of fields) {
    const { wantNumber, wantArray } = inferIntent(f);
    let v = payload?.[f.name];

    // unwrap react-select shapes
    if (Array.isArray(v)) v = v.map(unwrapOption);
    else v = unwrapOption(v);

    // allow CSV → array for Ids fields
    if (wantArray && typeof v === "string") {
      v = v
        .split(",")
        .map((s) => s.trim())
        .filter(Boolean);
    }

    if (wantNumber) {
      if (wantArray) {
        v = Array.isArray(v)
          ? v.map(toNum).filter((x) => x !== null)
          : v == null
          ? []
          : [toNum(v)];
      } else {
        if (v === "" || v === undefined || v === null) v = null;
        else v = toNum(v);
      }
    } else {
      if (wantArray) {
        v = Array.isArray(v)
          ? v.map((x) => (x == null ? "" : String(x)))
          : v == null
          ? []
          : [String(v)];
      } else {
        if (v == null) v = "";
        else v = String(v);
      }
    }

    // normalize empties
    if (f.type !== "text" && f.type !== "password") {
      if (v === "") v = null;
      if (Array.isArray(v) && v.length === 0) v = [];
    }

    out[f.name] = v;
  }
  return out;
}

// ---------- API -> form ----------
export function buildFormInitialValues(fields, apiData, opts = {}) {
  const { aliases = {} } = opts;

  // index API keys in a normalized way (case/sep insensitive)
  const apiIndex = {};
  Object.entries(apiData || {}).forEach(([k, v]) => (apiIndex[norm(k)] = v));

  const guessKeys = (f) => {
    const n = norm(f.name);
    const set = new Set([n]);

    // compute base by stripping trailing id/ids if present
    let base = n;
    if (endsWithIds(n)) base = n.slice(0, -3);
    else if (endsWithId(n)) base = n.slice(0, -2);

    // add common variants around the base
    // base, baseId, baseIds, baseS (plural), original name
    set.add(base);
    set.add(`${base}id`);
    set.add(`${base}ids`);
    if (!base.endsWith("s")) set.add(`${base}s`);

    // also allow original + id/ids if the original didn't already end with them
    if (!endsWithId(n)) set.add(`${n}id`);
    if (!endsWithIds(n)) set.add(`${n}ids`);

    // user hints
    if (f.apiKey) set.add(norm(f.apiKey));
    if (Array.isArray(f.aliases)) f.aliases.forEach((a) => set.add(norm(a)));
    if (aliases[f.name])
      [].concat(aliases[f.name]).forEach((a) => set.add(norm(a)));

    return Array.from(set);
  };

  const coerce = (f, raw) => {
    const { wantNumber, wantArray } = inferIntent(f);
    const coerceOne = (x) => {
      x = unwrapOption(x);
      if (x == null) return null;
      if (wantNumber) return toNum(x);
      return String(x);
    };

    if (wantArray) {
      if (typeof raw === "string") {
        raw = raw
          .split(",")
          .map((s) => s.trim())
          .filter(Boolean);
      }
      const arr = Array.isArray(raw) ? raw : raw != null ? [raw] : [];
      return arr.map(coerceOne).filter((x) => x != null && x !== "");
    } else if (f.type === "dropdown") {
      return coerceOne(raw);
    } else {
      // text/password/date → string with "" for null
      return raw == null ? "" : String(raw);
    }
  };

  const out = {};
  for (const f of fields) {
    const candidates = guessKeys(f);
    let raw;
    for (const key of candidates) {
      if (key in apiIndex) {
        raw = apiIndex[key];
        break;
      }
    }
    out[f.name] = coerce(f, raw);
  }
  return out;
}
