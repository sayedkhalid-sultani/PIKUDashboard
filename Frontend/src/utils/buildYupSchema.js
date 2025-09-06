import * as yup from "yup";

// Helper for casting array items to number
const numberArrayItem = () =>
  yup
    .number()
    .transform((val, orig) =>
      orig === "" || orig === undefined ? NaN : Number(orig)
    )
    .typeError("Invalid value");

// Helper for single-select dropdowns with number values
const dropdownNumber = () =>
  yup
    .number()
    .transform((val, orig) => {
      if (orig === "" || orig === null || orig === undefined) return null;
      const n = typeof orig === "number" ? orig : Number(orig);
      return Number.isFinite(n) ? n : NaN;
    })
    .nullable()
    .typeError("Invalid value");

// Builds a Yup rule for a single field config
function buildFieldRule(field) {
  const label = field.label || field.name;
  const requiredMsg = field.requiredMessage || `${label} is required`;

  // Allow custom Yup schema override
  if (field.yup) return field.yup;

  // Helper to add required if needed
  const addRequired = (schema) =>
    field.required ? schema.required(requiredMsg) : schema;
  const valueType =
    field.valueType || (field.type === "multiselect" ? "number" : "string");

  switch (field.type) {
    case "text": {
      let schema = yup.string();
      if (field.kind === "email") schema = schema.email("Enter a valid email");
      if (field.min)
        schema = schema.min(
          field.min,
          `${label} must be at least ${field.min} characters`
        );
      if (field.max)
        schema = schema.max(
          field.max,
          `${label} must be at most ${field.max} characters`
        );
      if (field.matches)
        schema = schema.matches(
          field.matches.regex,
          field.matches.message || "Invalid format"
        );
      return addRequired(schema);
    }
    case "password": {
      let schema = yup.string();
      if (field.min)
        schema = schema.min(
          field.min,
          `${label} must be at least ${field.min} characters`
        );
      if (field.max)
        schema = schema.max(
          field.max,
          `${label} must be at most ${field.max} characters`
        );
      return addRequired(schema);
    }
    case "date": {
      return addRequired(yup.date().nullable());
    }
    case "dropdown": {
      // store null when empty; validate required on presence
      if (valueType === "number") return addRequired(dropdownNumber());
      return addRequired(yup.string().trim().nullable());
    }
    case "multiselect": {
      // Array of items, cast to number or string
      const itemSchema =
        valueType === "number" ? numberArrayItem() : yup.string().trim();
      let schema = yup.array().of(itemSchema).default([]).ensure();
      // Minimum selection logic
      const minSel = field.min ?? (field.required ? 1 : undefined);
      if (typeof minSel === "number") {
        schema = schema.min(
          minSel,
          field.minMessage || `Pick at least ${minSel} ${label.toLowerCase()}`
        );
      }
      return schema;
    }
    case "checkbox": {
      let schema = yup
        .boolean()
        .transform((val, orig) => {
          if (typeof orig === "string") return orig === "true";
          if (typeof orig === "number") return orig === 1;
          return !!orig;
        });
      return addRequired(schema);
    }
    default:
      return addRequired(yup.string());
  }
}

// Main builder: takes fields config and returns Yup schema
export function buildYupSchema(fields) {
  const shape = {};
  fields.forEach((field) => {
    shape[field.name] = buildFieldRule(field);
  });
  return yup.object(shape);
}
