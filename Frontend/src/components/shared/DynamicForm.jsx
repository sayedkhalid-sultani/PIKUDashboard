// src/components/shared/DynamicForm.jsx
import React, {
  useEffect,
  useMemo,
  useState,
  forwardRef,
  useImperativeHandle,
  useRef,
} from "react";
import { useForm, Controller, useWatch } from "react-hook-form";
import { yupResolver } from "@hookform/resolvers/yup";
import Select from "react-select";
import { useLocation } from "react-router-dom";
import { Get, Post } from "../../api/controllers/controller";

/* ───────── small utils to prevent loops ───────── */

const arraysEqual = (a, b) => {
  if (a === b) return true;
  if (!Array.isArray(a) || !Array.isArray(b)) return false;
  if (a.length !== b.length) return false;
  for (let i = 0; i < a.length; i++) if (a[i] !== b[i]) return false;
  return true;
};
const isSelectType = (t) => t === "dropdown" || t === "multiselect";
const isNumericField = (f) =>
  (f?.valueType || "").toString().toLowerCase() === "number";

/* ───────── helpers ───────── */

const computeDepends = (fields) => {
  const set = new Set();
  fields.forEach((f) => {
    if (isSelectType(f.type) && Array.isArray(f.dependsOn)) {
      f.dependsOn.forEach((k) => set.add(k));
    }
  });
  return Array.from(set);
};

// normalize option shapes
const valueOf = (o) => o?.value ?? o?.Value ?? o?.id ?? o?.Id;
const labelOf = (o) =>
  o?.label ?? o?.Label ?? o?.name ?? o?.Name ?? String(valueOf(o) ?? "");

// convert any shape to {value,label}
const toReactOptions = (arr) =>
  (arr || []).map((o) => ({ value: valueOf(o), label: labelOf(o) }));

// ensure option.value type matches field.valueType
const normalizeOptionsForField = (field, arr) => {
  if (!Array.isArray(arr)) return [];
  if (!isNumericField(field)) return arr;
  return arr.map((o) => {
    const n = Number(o.value);
    return Number.isFinite(n) ? { ...o, value: n } : o;
  });
};

// tolerant extraction: array | {data:[...]} | {data:{key:[...]}} | {key:[...]} | {data:{Options:[...]}} | {Options:[...]}
const extractOptions = (payload, field) => {
  if (!payload) return undefined;
  if (Array.isArray(payload)) return payload;
  if (Array.isArray(payload.data)) return payload.data;

  const key = field.dataKey || field.name;
  if (payload.data && Array.isArray(payload.data[key]))
    return payload.data[key];
  if (Array.isArray(payload[key])) return payload[key];

  // common backend for lookups
  if (payload.data && Array.isArray(payload.data.Options))
    return payload.data.Options;
  if (Array.isArray(payload.Options)) return payload.Options;

  return undefined;
};

const depsReady = (field, deps) =>
  !Array.isArray(field.dependsOn) ||
  field.dependsOn.every(
    (k) => deps[k] !== undefined && deps[k] !== null && deps[k] !== ""
  );

const buildDefaultValues = (fields) => {
  const dv = {};
  for (const f of fields) {
    switch (f.type) {
      case "text":
      case "password":
      case "date":
        dv[f.name] = f.defaultValue ?? "";
        break;
      case "dropdown":
        dv[f.name] = f.defaultValue ?? null;
        break;
      case "multiselect":
        dv[f.name] = Array.isArray(f.defaultValue) ? f.defaultValue : [];
        break;
      default:
        break;
    }
  }
  return dv;
};

const isOptionsRoute = (ep) =>
  typeof ep === "string" && /\/options(?:$|[/?#])/i.test(ep);

const singularize = (s) =>
  typeof s === "string" && s.endsWith("s") ? s.slice(0, -1) : s;

const firstMatchKey = (obj, candidates) => {
  if (!obj) return undefined;
  for (const k of candidates) if (k in obj) return k;
  const lower = Object.fromEntries(
    Object.keys(obj).map((k) => [k.toLowerCase(), k])
  );
  for (const k of candidates) {
    const hit = lower[k.toLowerCase()];
    if (hit) return hit;
  }
  return undefined;
};

const coerceToArray = (v) => {
  if (v == null || v === "") return [];
  if (Array.isArray(v)) return v;
  if (typeof v === "string")
    return v
      .split(",")
      .map((x) => x.trim())
      .filter(Boolean);
  return [v];
};

// Incoming server values -> RHF shapes
const normalizeInitialValues = (fields, values) => {
  if (!values) return {};
  const out = {};

  for (const f of fields) {
    const name = f.name;
    const s = singularize(name);
    const candidates = [name, `${name}Id`, s, `${s}Id`];

    const hitKey = firstMatchKey(values, candidates);
    if (!hitKey) continue;

    let v = values[hitKey];

    const wantNumber =
      (f.valueType || (f.type === "multiselect" ? "number" : "string")) ===
      "number";
    const toNum = (x) => {
      const n = typeof x === "number" ? x : Number(x);
      return Number.isFinite(n) ? n : null;
    };

    if (isSelectType(f.type)) {
      if (f.type === "dropdown") {
        if (v == null || v === "") {
          out[name] = null;
          continue;
        }
        if (typeof v === "object") v = valueOf(v);
        out[name] = wantNumber ? toNum(v) : String(v);
        continue;
      }
      if (f.type === "multiselect") {
        const arr = coerceToArray(v)
          .map((x) => (typeof x === "object" ? valueOf(x) : x))
          .map((x) => (wantNumber ? toNum(x) : String(x)))
          .filter((x) => x !== null && x !== "");
        out[name] = arr;
        continue;
      }
    }

    out[name] = v ?? "";
  }

  return out;
};

// Read initial text labels for selects from the server payload
const readInitialSelectText = (fields, values) => {
  const out = {};
  if (!values) return out;

  const get = (obj, key) => {
    if (!obj) return undefined;
    if (key in obj) return obj[key];
    const lower = Object.fromEntries(
      Object.keys(obj).map((k) => [k.toLowerCase(), obj[k]])
    );
    return lower[key.toLowerCase()];
  };

  for (const f of fields) {
    if (!isSelectType(f.type)) continue;
    const name = f.name;
    const s = singularize(name);

    const candidates = [
      name,
      s,
      `${name}Name`,
      `${s}Name`,
      `${name}_Name`,
      `${s}_Name`,
      `${name}Label`,
      `${s}Label`,
    ];

    for (const key of candidates) {
      const v = get(values, key);
      if (typeof v === "string") {
        out[name] = v; // single label
        break;
      }
      if (Array.isArray(v) && v.every((x) => typeof x === "string")) {
        out[name] = v; // multi labels
        break;
      }
    }
  }
  return out;
};

// stable DOM ids
const domId = (prefix, name) =>
  `${prefix}-${String(name || "field")}`.replace(/\s+/g, "-").toLowerCase();

// coerce a value to the correct type for matching against options
const coerceValueForField = (field, v) => {
  if (!isNumericField(field)) return v == null ? null : String(v);
  if (v == null || v === "") return null;
  const n = Number(v);
  return Number.isFinite(n) ? n : v;
};

const coerceArrayForField = (field, arr) => {
  const input = Array.isArray(arr) ? arr : arr == null ? [] : [arr];
  if (!isNumericField(field))
    return input
      .map((v) => (typeof v === "object" ? valueOf(v) : v))
      .map((v) => String(v));
  return input
    .map((v) => (typeof v === "object" ? valueOf(v) : v))
    .map((v) => Number(v))
    .filter((n) => Number.isFinite(n));
};

/* ───────── component ───────── */

const DynamicForm = forwardRef(
  (
    {
      title,
      subtitle,
      fields = [],
      validationSchema,
      schema,
      onSubmit,
      isSubmitting = false,
      submitButtonText = "Submit",
      formClassName = "",
      resetOnSuccess = false,
      validationMode = "onSubmit",
      reactSelectProps = {},
      initialValues = null,
      enableReinitialize = true,
      disableUntilValid = false,
      shouldFocusError = false,
    },
    ref
  ) => {
    const location = useLocation();

    const effectiveSchema = validationSchema || schema || null;
    const resolver = effectiveSchema
      ? yupResolver(effectiveSchema, { abortEarly: false })
      : undefined;

    // defaults (field defaults + server overrides)
    const defaults = useMemo(() => {
      const base = buildDefaultValues(fields);
      const fromServer = normalizeInitialValues(fields, initialValues);
      return { ...base, ...fromServer };
    }, [fields, initialValues]);

    // labels from the server to prefill selects when ids are missing
    const initialSelectText = useMemo(
      () => readInitialSelectText(fields, initialValues),
      [fields, initialValues]
    );
    const initialSelectTextHash = useMemo(
      () => JSON.stringify(initialSelectText),
      [initialSelectText]
    );

    const {
      register,
      handleSubmit,
      control,
      setValue,
      getValues,
      reset,
      formState: { errors, isValid, touchedFields, submitCount },
    } = useForm({
      resolver,
      mode: validationMode,
      reValidateMode: validationMode,
      shouldFocusError,
      defaultValues: defaults,
    });

    useImperativeHandle(ref, () => ({
      resetForm: () => {
        reset(buildDefaultValues(fields), {
          keepErrors: false,
          keepTouched: false,
          keepDirty: false,
          keepIsSubmitted: false,
          keepSubmitCount: false,
        });
        if (document.activeElement instanceof HTMLElement)
          document.activeElement.blur();
      },
    }));

    // Reinitialize when server data arrives/changes
    useEffect(() => {
      if (!enableReinitialize) return;
      reset(defaults, { keepDefaultValues: false });
      // eslint-disable-next-line react-hooks/exhaustive-deps
    }, [defaults, enableReinitialize, reset]);

    const [options, setOptions] = useState({}); // { [fieldName]: [{value,label}] }
    const latestReq = useRef({});
    const lastFetchKeyRef = useRef({});
    const clearedWhenDepsMissingRef = useRef({});

    // reset dedupe when route changes
    useEffect(() => {
      lastFetchKeyRef.current = {};
      clearedWhenDepsMissingRef.current = {};
    }, [location.pathname]);

    const submit = async (data) => {
      try {
        await onSubmit?.(data);
        if (resetOnSuccess) {
          reset(buildDefaultValues(fields), {
            keepErrors: false,
            keepTouched: false,
            keepDirty: false,
            keepIsSubmitted: false,
            keepSubmitCount: false,
          });
          if (document.activeElement instanceof HTMLElement)
            document.activeElement.blur();
        }
      } catch (e) {
        console.error("Form submit failed:", e);
      }
    };

    /* ---------- dependency tracking ---------- */
    const depKeys = useMemo(() => computeDepends(fields), [fields]);
    const depVals = useWatch({ control, name: depKeys });
    const depsObj = useMemo(
      () => Object.fromEntries(depKeys.map((k, i) => [k, depVals?.[i]])),
      [depKeys, depVals]
    );
    const depsHash = useMemo(() => JSON.stringify(depsObj), [depsObj]);

    /* ---------- inline options (static arrays) ---------- */
    useEffect(() => {
      const map = {};
      fields.forEach((f) => {
        if (isSelectType(f.type) && Array.isArray(f.options)) {
          const arr = normalizeOptionsForField(f, toReactOptions(f.options));
          map[f.name] = arr;
        }
      });
      if (Object.keys(map).length) setOptions((p) => ({ ...p, ...map }));
    }, [fields]);

    /* ---------- remote options (optionsFetcher | optionsEndpoint) ---------- */
    useEffect(() => {
      let cancelled = false;
      const deps = JSON.parse(depsHash);
      const initialText = JSON.parse(initialSelectTextHash);

      const tryPrefillByLabel = (f, arr) => {
        const curr = getValues(f.name);
        const isEmpty =
          f.type === "multiselect"
            ? !(Array.isArray(curr) && curr.length > 0)
            : curr === null || curr === undefined || curr === "";
        const want = initialText[f.name];
        if (!isEmpty || !want) return;

        if (f.type === "multiselect") {
          const wants = Array.isArray(want) ? want : [want];
          const lower = new Set(wants.map((x) => String(x).toLowerCase()));
          const matches = arr
            .filter((o) => lower.has(String(o.label).toLowerCase()))
            .map((o) => o.value);
          if (matches.length > 0) {
            const coerced = coerceArrayForField(f, matches);
            setValue(f.name, coerced, {
              shouldValidate: false,
              shouldTouch: false,
              shouldDirty: false,
            });
          }
        } else {
          const match = arr.find(
            (o) => String(o.label).toLowerCase() === String(want).toLowerCase()
          );
          if (match) {
            const coerced = coerceValueForField(f, match.value);
            setValue(f.name, coerced, {
              shouldValidate: false,
              shouldTouch: false,
              shouldDirty: false,
            });
          }
        }
      };

      (async () => {
        const next = {};

        for (const f of fields) {
          if (!isSelectType(f.type)) continue;

          const hasDeps = Array.isArray(f.dependsOn) && f.dependsOn.length > 0;

          // Clear once while deps missing
          if (hasDeps && !depsReady(f, deps)) {
            const desired = f.type === "multiselect" ? [] : null;
            const curr = getValues(f.name);
            const currentArr =
              f.type === "multiselect" ? coerceArrayForField(f, curr) : null;

            const needsClear =
              f.type === "multiselect"
                ? !arraysEqual(currentArr, [])
                : !(curr === null || curr === undefined || curr === "");

            if (needsClear && !clearedWhenDepsMissingRef.current[f.name]) {
              clearedWhenDepsMissingRef.current[f.name] = true;
              setValue(f.name, desired, {
                shouldValidate: false,
                shouldTouch: false,
                shouldDirty: false,
              });
            }
            continue;
          } else {
            delete clearedWhenDepsMissingRef.current[f.name];
          }

          // ---- 1) optionsFetcher (preferred) ----
          if (typeof f.optionsFetcher === "function") {
            const fetchKey = [
              "fetcher",
              f.name,
              depsHash,
              location.pathname,
            ].join("|");
            if (lastFetchKeyRef.current[f.name] !== fetchKey) {
              lastFetchKeyRef.current[f.name] = fetchKey;

              const reqId = (latestReq.current[f.name] ?? 0) + 1;
              latestReq.current[f.name] = reqId;

              try {
                const raw = await f.optionsFetcher(deps, location);
                const arr = normalizeOptionsForField(f, toReactOptions(raw));
                const isLatest = latestReq.current[f.name] === reqId;
                if (!cancelled && isLatest && Array.isArray(arr)) {
                  next[f.name] = arr;

                  // validate current
                  const allowed = new Set(arr.map((o) => o.value));
                  if (f.type === "multiselect") {
                    const curr = coerceArrayForField(f, getValues(f.name));
                    const keep = curr.filter((v) => allowed.has(v));
                    if (!arraysEqual(keep, curr)) {
                      setValue(f.name, keep, {
                        shouldValidate: false,
                        shouldTouch: false,
                        shouldDirty: false,
                      });
                    }
                  } else {
                    const curr = coerceValueForField(f, getValues(f.name));
                    if (curr != null && curr !== "" && !allowed.has(curr)) {
                      setValue(f.name, null, {
                        shouldValidate: false,
                        shouldTouch: false,
                        shouldDirty: false,
                      });
                    }
                  }

                  // NEW: prefill by label if value still empty
                  tryPrefillByLabel(f, arr);
                }
              } catch (err) {
                console.error(`optionsFetcher failed for "${f.name}"`, err);
              }
            }
            continue; // don’t also hit optionsEndpoint
          }

          // ---- 2) optionsEndpoint (GET/POST) ----
          let ep = f.optionsEndpoint;
          if (typeof ep === "function") ep = ep(deps, location);
          if (!ep) continue;

          if (!depsReady(f, deps)) continue;

          const defaultMethod = isOptionsRoute(ep) ? "POST" : "GET";
          const method = (f.optionsMethod || defaultMethod).toUpperCase();

          const body =
            typeof f.optionsBody === "function"
              ? f.optionsBody(deps, location)
              : f.optionsBody || {};

          const parentIds = (Array.isArray(f.dependsOn) ? f.dependsOn : [])
            .map((k) => deps[k])
            .flat()
            .filter((v) => v != null && v !== "");

          const fetchKey = [
            "endpoint",
            f.name,
            method,
            String(ep),
            JSON.stringify(parentIds),
            JSON.stringify(body),
            location.pathname,
          ].join("|");
          if (lastFetchKeyRef.current[f.name] === fetchKey) continue;
          lastFetchKeyRef.current[f.name] = fetchKey;

          const reqId = (latestReq.current[f.name] ?? 0) + 1;
          latestReq.current[f.name] = reqId;

          try {
            let resp;
            if (isOptionsRoute(ep)) {
              if (method === "GET") {
                const params = {
                  Dropdown: f.name,
                  ...(parentIds.length
                    ? { ParentIds: parentIds.join(",") }
                    : {}),
                  ...body,
                };
                resp = await Get(ep, params);
              } else {
                const postBody = {
                  Dropdown: f.name,
                  ...(parentIds.length ? { ParentIds: parentIds } : {}),
                  ...body,
                };
                resp = await Post(ep, postBody);
              }
            } else {
              resp =
                method === "GET" ? await Get(ep, body) : await Post(ep, body);
            }

            const payload = resp?.data ?? resp;
            const raw = extractOptions(payload, f);
            const arr = normalizeOptionsForField(f, toReactOptions(raw));
            const isLatest = latestReq.current[f.name] === reqId;

            if (!cancelled && isLatest && Array.isArray(arr)) {
              next[f.name] = arr;

              const allowed = new Set(arr.map((o) => o.value));
              if (f.type === "multiselect") {
                const curr = coerceArrayForField(f, getValues(f.name));
                const keep = curr.filter((v) => allowed.has(v));
                if (!arraysEqual(keep, curr)) {
                  setValue(f.name, keep, {
                    shouldValidate: false,
                    shouldTouch: false,
                    shouldDirty: false,
                  });
                }
              } else {
                const curr = coerceValueForField(f, getValues(f.name));
                if (curr != null && curr !== "" && !allowed.has(curr)) {
                  setValue(f.name, null, {
                    shouldValidate: false,
                    shouldTouch: false,
                    shouldDirty: false,
                  });
                }
              }

              // NEW: prefill by label if value still empty
              tryPrefillByLabel(f, arr);
            }
          } catch (err) {
            const status = err?.response?.status;
            const bodyDump = err?.response?.data;
            console.error(
              `Failed loading options for "${f.name}" (${method} ${ep})`,
              { status, body: bodyDump, err }
            );
          }
        }

        if (!cancelled && Object.keys(next).length) {
          setOptions((prev) => ({ ...prev, ...next }));
        }
      })();

      return () => {
        cancelled = true;
      };
    }, [
      fields,
      depsHash,
      getValues,
      location.pathname,
      setValue,
      initialSelectTextHash, // so prefill reacts if server labels change
    ]);

    const disabled = (disableUntilValid && !isValid) || isSubmitting;

    /* ---------- render ---------- */
    return (
      <form
        onSubmit={handleSubmit(submit)}
        className={`grid gap-6 ${formClassName}`}
        autoComplete="off"
      >
        {title && (
          <div className="space-y-1">
            <h2 className="text-xl font-semibold tracking-tight text-slate-800">
              {title}
            </h2>
            {subtitle && <p className="text-sm text-slate-500">{subtitle}</p>}
          </div>
        )}

        {fields.map((f) => {
          const fieldOptions = options[f.name] || [];
          const showError =
            errors[f.name] && (touchedFields[f.name] || submitCount > 0);

          // disable selects until dependencies have values
          const deps = JSON.parse(depsHash);
          const depsOk = depsReady(f, deps);
          const isSelectDisabled =
            f.disabled || (isSelectType(f.type) && !depsOk);

          const fid = domId("df", f.name);
          const labelId = `${fid}-label`;

          return (
            <div
              key={f.name}
              className={f.wrapperClassName || "flex flex-col gap-1.5"}
            >
              {f.label && (
                <label
                  id={labelId}
                  htmlFor={fid}
                  className="text-sm font-medium text-slate-700"
                >
                  {f.label}
                </label>
              )}

              {/* text / password */}
              {["text", "password"].includes(f.type) && (
                <>
                  {f.type === "password" && (
                    <input
                      type="password"
                      name="fake-pw"
                      autoComplete="new-password"
                      hidden
                    />
                  )}
                  <input
                    id={fid}
                    type={f.type}
                    placeholder={f.placeholder || ""}
                    autoComplete={
                      f.type === "password" ? "new-password" : "off"
                    }
                    aria-invalid={!!errors[f.name]}
                    {...register(f.name)}
                    className="w-full rounded-xl border border-slate-300 bg-white px-3 py-2.5 text-[15px] text-slate-900 placeholder:text-slate-400 outline-none focus:border-blue-500 focus:ring-2 focus:ring-blue-500/30 transition"
                  />
                </>
              )}

              {/* date */}
              {f.type === "date" && (
                <input
                  id={fid}
                  type="date"
                  {...register(f.name)}
                  aria-invalid={!!errors[f.name]}
                  className="w-full rounded-xl border border-slate-300 bg-white px-3 py-2.5 text-[15px] text-slate-900 outline-none focus:border-blue-500 focus:ring-2 focus:ring-blue-500/30 transition"
                />
              )}

              {/* dropdown */}
              {f.type === "dropdown" && (
                <Controller
                  name={f.name}
                  control={control}
                  render={({ field }) => {
                    const coercedValue = coerceValueForField(f, field.value);
                    const selected =
                      fieldOptions.find((o) => o.value === coercedValue) ||
                      null;

                    return (
                      <Select
                        {...reactSelectProps}
                        inputId={fid}
                        instanceId={fid}
                        aria-labelledby={labelId}
                        name={f.name}
                        options={fieldOptions}
                        value={selected}
                        onChange={(opt) => {
                          const v = coerceValueForField(
                            f,
                            opt ? opt.value : null
                          );
                          if (v !== field.value) field.onChange(v);
                        }}
                        onBlur={field.onBlur}
                        isClearable
                        isDisabled={isSelectDisabled}
                        placeholder={f.placeholder || "Select..."}
                        className="react-select"
                        classNamePrefix="rs"
                      />
                    );
                  }}
                />
              )}

              {/* multiselect */}
              {f.type === "multiselect" && (
                <Controller
                  name={f.name}
                  control={control}
                  render={({ field }) => {
                    const current = coerceArrayForField(f, field.value);
                    const selected = current
                      .map((v) => fieldOptions.find((o) => o.value === v))
                      .filter(Boolean);

                    return (
                      <Select
                        {...reactSelectProps}
                        inputId={fid}
                        instanceId={fid}
                        aria-labelledby={labelId}
                        name={f.name}
                        options={fieldOptions}
                        value={selected}
                        onChange={(opts) => {
                          const raw = (opts || []).map((o) => o.value);
                          const coerced = coerceArrayForField(f, raw);
                          if (!arraysEqual(coerced, current))
                            field.onChange(coerced);
                        }}
                        onBlur={field.onBlur}
                        isMulti
                        isClearable
                        isDisabled={isSelectDisabled}
                        closeMenuOnSelect={false}
                        placeholder={f.placeholder || "Select..."}
                        className="react-select"
                        classNamePrefix="rs"
                      />
                    );
                  }}
                />
              )}

              {/* helper / error */}
              {f.help && !showError && (
                <p className="text-[13px] text-slate-500">{f.help}</p>
              )}
              {showError && (
                <p className="text-[13px] text-red-600">
                  {errors[f.name]?.message}
                </p>
              )}
            </div>
          );
        })}

        <div className="flex justify-end pt-2">
          <button
            type="submit"
            disabled={(disableUntilValid && !isValid) || isSubmitting}
            className={`inline-flex items-center justify-center rounded-xl px-4 py-2.5 text-sm font-medium text-white shadow-sm transition ${
              (disableUntilValid && !isValid) || isSubmitting
                ? "bg-slate-400 cursor-not-allowed"
                : "bg-blue-600 hover:bg-blue-700"
            }`}
          >
            {submitButtonText}
          </button>
        </div>
      </form>
    );
  }
);

export default DynamicForm;
