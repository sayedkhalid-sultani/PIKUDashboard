// src/components/admin/RegisterUser.jsx
import React, { useRef } from "react";
import { useAppMutation } from "../../../hooks/Shared/useAppMutation";
import { Post } from "../../../api/controllers/controller"; // ✅ use your controllers.js helpers
import DynamicForm from "../../shared/DynamicForm";
import { buildYupSchema } from "../../../utils/buildYupSchema";
import { processFormPayload } from "../../../utils/processFormPayload";
import { useNavigate } from "react-router-dom";

// ───────────────────── Fields config ─────────────────────
const fields = [
  { name: "Username", label: "Username", type: "text", required: true },
  { name: "Password", label: "Password", type: "password", required: true },
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
    label: "Departments",
    type: "dropdown",
    required: true,
    valueType: "number",
    min: 1,
    optionsEndpoint: "/api/users/options",
    placeholder: "Choose departments",
  },
];

// Build Yup schema
const schema = buildYupSchema(fields);

const RegisterUser = () => {
  const navigate = useNavigate();
  const formRef = useRef(null);

  // Post to /api/users using controllers.js Post helper
  const createUser = async (payload) => {
    const body = processFormPayload(fields, payload);
    const data = await Post("/auth/register", body);
    return data;
  };

  // Reset form after successful registration
  const mutation = useAppMutation("RegisterUser", createUser, {
    onSuccess: () => {
      formRef.current?.resetForm();
    },
  });

  return (
    <div className="flex items-start min-h-full">
      <div className="w-full p-6 rounded shadow-lg bg-white border ">
        <button
          onClick={() => navigate(-1)}
          className="rounded bg-slate-200 px-3 py-1 hover:bg-slate-300"
        >
          Back
        </button>
        <h2 className="text-2xl font-bold text-center text-blue-800 mb-6">
          Register New User
        </h2>

        <DynamicForm
          key={location.key}
          ref={formRef}
          fields={fields}
          validationSchema={schema}
          onSubmit={(data) => mutation.mutate(data)}
          resetOnSuccess
          submitButtonText={mutation.isPending ? "Saving…" : "Save"}
          isSubmitting={mutation.isPending}
        />
      </div>
    </div>
  );
};

export default RegisterUser;
