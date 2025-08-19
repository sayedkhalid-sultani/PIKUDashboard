import { toast } from "react-toastify";

/* ──────────────────────────── Helpers ──────────────────────────── */

/** Returns the first non-empty trimmed string from a list, else null */
const coalesceText = (...candidates) => {
  for (const c of candidates) {
    if (typeof c === "string") {
      const t = c.trim();
      if (t) return t;
    }
  }
  return null;
};

/** If val is a function, call with context; otherwise return val */
const valueOrFn = (val, context) =>
  typeof val === "function" ? val(context) : val;

/** Normalize a navigation target to a non-empty string or null */
export const resolveTo = (target, context) => {
  const resolved = valueOrFn(target, context);
  return typeof resolved === "string" && resolved.trim() ? resolved : null;
};

/* ─────────────────────── Default message extractors ─────────────────────── */

export const defaultSuccessMessage = (data) =>
  coalesceText(data?.message, data?.Message, data?.result?.message);

export const defaultErrorMessage = (
  error,
  fallback = "Something went wrong"
) => {
  const serverMsg =
    error?.response?.data?.message ??
    error?.response?.data?.error ??
    (Array.isArray(error?.response?.data?.errors)
      ? error.response.data.errors.join(", ")
      : null);

  return coalesceText(serverMsg, error?.message, fallback);
};

/* ───────────────────────── Plugin runner ───────────────────────── */

/**
 * Runs all plugin handlers for a given event (e.g., "onSuccess", "onError").
 * - Supports async handlers
 * - Isolates handler failures (won't break others)
 */
export const run = async (plugins, event, context) => {
  if (!Array.isArray(plugins) || plugins.length === 0) return;
  await Promise.all(
    plugins.map(async (plugin) => {
      const handler = plugin?.[event];
      if (typeof handler !== "function") return;
      try {
        await handler(context);
      } catch {
        // Optionally log here
      }
    })
  );
};

/* ──────────────────────────── Plugins ──────────────────────────── */

export const plugins = {
  /**
   * Toast plugin: shows success/error notifications using react-toastify
   * @param {Object} options
   * @param {boolean|function} options.success - true | (data)=>string | false
   * @param {boolean|function} options.error   - true | (error)=>string | false
   * @param {function} options.successExtractor - (data)=>string
   * @param {function} options.errorExtractor   - (error)=>string
   * @param {Object} options.toastOptions       - react-toastify options
   */
  toast: ({
    success = true,
    error: showError = true, // ← avoid shadowing context.error
    successExtractor = defaultSuccessMessage,
    errorExtractor = (e) => defaultErrorMessage(e),
    toastOptions = {},
  } = {}) => ({
    onSuccess: ({ data }) => {
      if (!success) return;
      const message =
        typeof success === "function" ? success(data) : successExtractor(data);
      if (message) toast.success(message, toastOptions);
    },
    onError: ({ error }) => {
      if (!showError) return;
      const message =
        typeof showError === "function"
          ? showError(error)
          : errorExtractor(error);
      if (message) toast.error(message, toastOptions);
    },
  }),

  /**
   * Redirect plugin: navigates to a route on success/error
   * @param {Object} options
   * @param {string|function} options.successTo - route or (ctx)=>route
   * @param {string|function} options.errorTo   - route or (ctx)=>route
   * @param {Object} options.navigateOptions    - e.g. { replace: true }
   * @param {function} options.shouldNavigate   - (from, to)=>boolean
   */
  redirect: ({
    successTo,
    errorTo,
    navigateOptions = { replace: true },
    shouldNavigate = (from, to) => from !== to,
  } = {}) => ({
    onSuccess: ({ data, navigate, location }) => {
      if (!navigate || !location) return;
      const target = resolveTo(successTo, { data, location });
      if (target && shouldNavigate(location.pathname, target)) {
        navigate(target, navigateOptions);
      }
    },
    onError: ({ error, navigate, location }) => {
      if (!navigate || !location) return;
      const target = resolveTo(errorTo, { error, location });
      if (target && shouldNavigate(location.pathname, target)) {
        navigate(target, navigateOptions);
      }
    },
  }),

  /**
   * Invalidate plugin: invalidates react-query cache keys after success
   * @param {Object} options
   * @param {Array<string|Array>} options.keys - query keys or key arrays
   * @param {boolean} options.exact - pass exact to invalidateQueries
   */
  invalidate: ({ keys = [], exact = true } = {}) => ({
    onSuccess: async ({ queryClient }) => {
      if (!queryClient || keys.length === 0) return;
      await Promise.all(
        keys.map((key) =>
          queryClient.invalidateQueries({
            queryKey: Array.isArray(key) ? key : [key],
            exact,
          })
        )
      );
    },
  }),

  /**
   * Store plugin: runs custom store logic on mutation/query events
   * @param {Object} handlers - { onMutate, onSuccess, onError, onSettled }
   */
  store: ({ onMutate, onSuccess, onError, onSettled } = {}) => ({
    onMutate: (context) => onMutate?.(context),
    onSuccess: (context) => onSuccess?.(context),
    onError: (context) => onError?.(context),
    onSettled: (context) => onSettled?.(context),
  }),
};
