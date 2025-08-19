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

/* ───────── helpers ───────── */

const isSelectType = (t) => t === "dropdown" || t === "multiselect";

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

// tolerant extraction: array | {data:[...]} | {data:{key:[...]}} | {key:[...]}
const extractOptions = (payload, field) => {
  if (!payload) return undefined;
  if (Array.isArray(payload)) return payload;
  if (Array.isArray(payload.data)) return payload.data;
  const key = field.dataKey || field.name;
  if (payload.data && Array.isArray(payload.data[key]))
    return payload.data[key];
  if (Array.isArray(payload[key])) return payload[key];
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
        dv[f.name] = f.defaultValue ?? null; // single-select uses null
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

// Match “…/options” anywhere (e.g., /api/users/options)
const isOptionsRoute = (ep) =>
  typeof ep === "string" && /\/options(?:$|[/?#])/i.test(ep);

// ── tolerant initial-value helpers ──
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

// Coerce incoming server values into RHF raw shapes (null / [] / scalar)
// Looks for: Name, NameId, singular(Name), singular(Name)Id (case-insensitive)
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

    // text/password/date: keep as-is
    out[name] = v ?? "";
  }

  return out;
};

// stable DOM ids for inputs/selects/labels
const domId = (prefix, name) =>
  `${prefix}-${String(name || "field")}`.replace(/\s+/g, "-").toLowerCase();

/* ───────── component ───────── */

const DynamicForm = forwardRef(
  (
    {
      title,
      subtitle,
      fields = [],
      validationSchema, // or `schema`
      schema,
      onSubmit,
      isSubmitting = false,
      submitButtonText = "Submit",
      formClassName = "",
      resetOnSuccess = false,
      validationMode = "onSubmit",
      reactSelectProps = {},
      initialValues = null, // server values for edit
      enableReinitialize = true, // re-fill when initialValues change
      disableUntilValid = false, // if true, disable submit until RHF deems valid
      shouldFocusError = false, // prevent RHF from refocusing on first error
    },
    ref
  ) => {
    const location = useLocation(); // track current path

    const effectiveSchema = validationSchema || schema || null;
    const resolver = effectiveSchema
      ? yupResolver(effectiveSchema, { abortEarly: false })
      : undefined;

    // Initial defaults (field defaults + server overrides)
    const defaults = useMemo(() => {
      const base = buildDefaultValues(fields);
      const fromServer = normalizeInitialValues(fields, initialValues);
      return { ...base, ...fromServer };
    }, [fields, initialValues]);

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
    // per-field last fetch key to avoid StrictMode duplicate requests
    const lastFetchKeyRef = useRef({});

    // 🔁 when the path changes, clear the per-field de-dupe keys so new page can refetch
    useEffect(() => {
      lastFetchKeyRef.current = {};
      // Optional: clear values on route change
      // fields.forEach((f) => {
      //   if (isSelectType(f.type)) {
      //     setValue(f.name, f.type === "multiselect" ? [] : null, {
      //       shouldValidate: false,
      //       shouldTouch: false,
      //       shouldDirty: false,
      //     });
      //   }
      // });
    }, [location.pathname, fields, setValue]);

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
    const depsStable = useMemo(() => JSON.parse(depsHash), [depsHash]);

    /* ---------- inline options ---------- */
    useEffect(() => {
      const map = {};
      fields.forEach((f) => {
        if (isSelectType(f.type) && Array.isArray(f.options)) {
          map[f.name] = toReactOptions(f.options);
        }
      });
      if (Object.keys(map).length) setOptions((p) => ({ ...p, ...map }));
    }, [fields]);

    /* ---------- remote options (Dropdown + ParentIds) ---------- */
    useEffect(() => {
      let cancelled = false;

      (async () => {
        const next = {};

        for (const f of fields) {
          if (!isSelectType(f.type)) continue;

          // resolve endpoint
          let ep = f.optionsEndpoint;
          if (typeof ep === "function") ep = ep(depsStable, location);
          if (!ep) continue;

          const hasDeps = Array.isArray(f.dependsOn) && f.dependsOn.length > 0;

          // wait for parent(s) to have values
          if (!depsReady(f, depsStable)) {
            setValue(f.name, f.type === "multiselect" ? [] : null, {
              shouldValidate: false,
              shouldTouch: false,
              shouldDirty: false,
            });
            continue;
          }

          const finalEndpoint = ep;
          const method = (f.optionsMethod || "GET").toUpperCase();
          const body =
            typeof f.optionsBody === "function"
              ? f.optionsBody(depsStable, location)
              : f.optionsBody || {};

          // ParentIds for de-dupe key
          const parentKey = hasDeps ? f.dependsOn[0] : null;
          const parentVal = parentKey ? depsStable[parentKey] : null;
          const parentIds =
            parentVal == null || parentVal === ""
              ? []
              : Array.isArray(parentVal)
              ? parentVal
              : [parentVal];

          // ─── DE-DUPE: skip issuing the exact same request twice (StrictMode) ───
          const fetchKey = [
            f.name,
            method,
            String(finalEndpoint),
            JSON.stringify(parentIds),
            JSON.stringify(body),
            location.pathname, // include path so new pages refetch
          ].join("|");

          if (lastFetchKeyRef.current[f.name] === fetchKey) {
            continue; // Same request was just made—skip this duplicate
          }
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
                resp = await Get(finalEndpoint, params);
              } else {
                const postBody = {
                  Dropdown: f.name,
                  ...(parentIds.length ? { ParentIds: parentIds } : {}),
                  ...body,
                };
                resp = await Post(finalEndpoint, postBody);
              }
            } else {
              // Non-standard endpoints: pass params for GET; body for POST
              if (method === "GET") resp = await Get(finalEndpoint, body);
              else resp = await Post(finalEndpoint, body);
            }

            const payload = resp?.data ?? resp;
            const raw = extractOptions(payload, f);
            const arr = toReactOptions(raw);
            const isLatest = latestReq.current[f.name] === reqId;

            if (!cancelled && isLatest && Array.isArray(arr)) {
              next[f.name] = arr;

              // After options load, keep current value if valid; otherwise clear silently.
              const allowed = new Set(arr.map((o) => o.value));
              if (f.type === "multiselect") {
                const curr = Array.isArray(getValues(f.name))
                  ? getValues(f.name)
                  : [];
                const keep = curr.filter((v) => allowed.has(v));
                if (keep.length !== curr.length) {
                  setValue(f.name, keep, {
                    shouldValidate: false,
                    shouldTouch: false,
                    shouldDirty: false,
                  });
                }
              } else {
                const curr = getValues(f.name);
                if (curr != null && curr !== "" && !allowed.has(curr)) {
                  setValue(f.name, null, {
                    shouldValidate: false,
                    shouldTouch: false,
                    shouldDirty: false,
                  });
                }
              }
            }
          } catch (err) {
            const status = err?.response?.status;
            const bodyDump = err?.response?.data;
            console.error(
              `Failed loading options for "${f.name}" (${method} ${finalEndpoint})`,
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
      // include location.pathname so options refetch when the route changes
    }, [fields, depsHash, setValue, getValues, location, depsStable]);

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
          const depsOk = depsReady(f, depsStable);
          const isSelectDisabled =
            f.disabled || (isSelectType(f.type) && !depsOk);

          // stable ids for inputs and labels (prevents "Empty string passed to getElementById()")
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
                    // prevent browser autofill quirks
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

              {/* dropdown (single) */}
              {f.type === "dropdown" && (
                <Controller
                  name={f.name}
                  control={control}
                  render={({ field }) => {
                    const selected =
                      fieldOptions.find((o) => o.value === field.value) || null;
                    return (
                      <Select
                        {...reactSelectProps}
                        inputId={fid}
                        instanceId={fid}
                        aria-labelledby={labelId}
                        name={f.name}
                        options={fieldOptions}
                        value={selected} // null when empty, never ""
                        onChange={(opt) =>
                          field.onChange(opt ? opt.value : null)
                        }
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
                    const selected = (
                      Array.isArray(field.value) ? field.value : []
                    )
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
                        onChange={(opts) =>
                          field.onChange((opts || []).map((o) => o.value))
                        }
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
