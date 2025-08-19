// src/components/Auth/Login.jsx

import DynamicForm from "../shared/DynamicForm";
import { Post } from "../../api/controllers/controller";
import {
  useAppMutation,
  plugins as mutationPlugins,
} from "../../hooks/Shared/useAppMutation";
import { buildYupSchema } from "../../utils/buildYupSchema";
import { useAuthStore } from "../../store/Shared/Store";

/* ------------------------------------------------------------------
 * 1) Form model: fields drive both UI and validation
 * ------------------------------------------------------------------ */

const LOGIN_FIELDS = [
  {
    name: "username",
    label: "Username",
    type: "text",
    required: true,
    placeholder: "Enter your username",
    className: "border border-gray-400 rounded p-2 text-blue-900",
    autoFocus: true,
  },
  {
    name: "password",
    label: "Password",
    type: "password",
    required: true,
    placeholder: "Enter your password",
    className: "border border-gray-400 rounded p-2 text-blue-900",
  },
];

// Build Yup schema directly from the field definitions (no manual Yup code)
const LOGIN_SCHEMA = buildYupSchema(LOGIN_FIELDS);

/* ------------------------------------------------------------------
 * 2) API call: single-purpose function for clarity and reuse
 * ------------------------------------------------------------------ */
const authenticate = async (credentials) => {
  // POST /auth/login with { username, password }
  // Post() returns response data; let the hook handle toasts/errors.
  return await Post("/auth/login", credentials);
};

/* ------------------------------------------------------------------
 * 3) Component
 * ------------------------------------------------------------------ */

const Login = () => {
  // Mutation: handles async call + plugins (toast/redirect/store/etc.)
  const loginMutation = useAppMutation("auth.login", authenticate, {
    // Store the returned auth payload in Zustand on success
    plugins: [
      mutationPlugins.store({
        onSuccess: ({ data }) => {
          useAuthStore.getState().applyFromApi(data);
        },
      }),
    ],
    // Let the hook redirect after success
    onSuccessRedirect: "/dashboard",
  });

  // Submit handler kept tiny & readable
  const handleSubmit = (formValues) => {
    // formValues = { username, password }
    loginMutation.mutate(formValues);
  };

  const isSubmitting = loginMutation.isPending;

  return (
    <div className="flex min-h-screen items-center justify-center bg-gray-100">
      <div className="w-full max-w-md rounded border bg-white p-6 shadow-lg">
        <h2 className="mb-6 text-center text-2xl font-bold text-blue-800">
          Login
        </h2>

        <DynamicForm
          fields={LOGIN_FIELDS}
          validationSchema={LOGIN_SCHEMA}
          onSubmit={handleSubmit}
          isSubmitting={isSubmitting}
          submitButtonText={isSubmitting ? "Logging in..." : "Log in"}
          // Optional: pass a form-level className if your DynamicForm supports it
          formClassName="space-y-4"
        />
      </div>
    </div>
  );
};

export default Login;
