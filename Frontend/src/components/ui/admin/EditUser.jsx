import React, { useMemo } from "react";
import { useParams, useNavigate } from "react-router-dom";
import { useAppQuery } from "../../../hooks/Shared/useAppQuery";
import { useAppMutation } from "../../../hooks/Shared/useAppMutation";
import { Get, Put } from "../../../api/controllers/controller";
import DynamicForm from "../../shared/DynamicForm";
import { buildYupSchema } from "../../../utils/buildYupSchema";
import {
  processFormPayload,
  buildFormInitialValues,
} from "../../../utils/processFormPayload";

// User form fields config
// Password is optional for editing (don't force user to change password)
const baseFields = [
  { name: "Username", label: "Username", type: "text", required: true },
  { name: "Password", label: "Password", type: "password", required: false },
  {
    name: "Role",
    label: "Role",
    type: "dropdown",
    required: true,
    valueType: "string",
    options: [
      { value: "Admin", label: "Admin" },
      { value: "Manager", label: "Manager" },
      { value: "Viewer", label: "Viewer" },
    ],
    placeholder: "Select a role",
  },
  {
    name: "Departments",
    label: "Department",
    type: "dropdown", // Use "multiselect" if multiple departments allowed
    required: true,
    valueType: "number",
    min: 1,
    optionsEndpoint: "/api/users/options",
    placeholder: "Choose departments",
  },
];

// EditUser page for updating user details
export default function EditUser() {
  // Get user ID from route params
  const { id } = useParams();
  const navigate = useNavigate();

  // Use baseFields for form config
  const fields = baseFields;
  // Build Yup validation schema for the form
  const schema = useMemo(() => buildYupSchema(fields), [fields]);

  // Fetch user data from API (only if id is present)
  const { data: res, isLoading } = useAppQuery(
    `user:${id}`,
    () => Get(`/api/users/${id}`),
    { enabled: !!id }
  );

  // Build initial form values from API response
  const initialValues = useMemo(() => {
    // API may return { data: ... } or just the user object
    const apiUser = res?.data ?? res ?? null;
    if (!apiUser) return null;
    // Use helper to map API user to form initial values
    const iv = buildFormInitialValues(fields, apiUser);
    iv.Password = ""; // Never prefill password for security
    return iv;
  }, [fields, res]);

  // Save handler for form submission
  // If password is blank, don't send it (keep existing password)
  const save = async (payload) => {
    let body = processFormPayload(fields, payload);
    if (!body.Password) {
      // Remove Password key if empty
      const { Password, ...rest } = body;
      body = rest;
    }
    return await Put(`/api/users/${id}`, body);
  };

  // Mutation hook for updating user
  // Redirect to user list on success
  const mutation = useAppMutation("UpdateUser", save, {
    onSuccessRedirect: "/admin/users",
  });

  return (
    <div className="flex items-start min-h-full">
      <div className="w-[32rem] p-6 rounded shadow-lg bg-white border">
        {/* Header with title and back button */}
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-2xl font-bold text-blue-800">Edit User</h2>
          <button
            onClick={() => navigate(-1)}
            className="rounded bg-slate-200 px-3 py-1 hover:bg-slate-300"
          >
            Back
          </button>
        </div>

        {/* Show loading indicator while fetching user */}
        {isLoading ? (
          <div className="text-center text-slate-500 py-8">Loading…</div>
        ) : (
          <DynamicForm
            fields={fields}
            validationSchema={schema}
            initialValues={initialValues}
            enableReinitialize
            onSubmit={(data) => mutation.mutate(data)}
            submitButtonText={mutation.isPending ? "Updating…" : "Update"}
            isSubmitting={mutation.isPending}
          />
        )}
      </div>
    </div>
  );
}
