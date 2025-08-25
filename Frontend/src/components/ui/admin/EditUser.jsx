import React, { useMemo } from "react";
import { useParams, useNavigate } from "react-router-dom";
import { useAppQuery } from "../../../hooks/Shared/useAppQuery";
import { useAppMutation } from "../../../hooks/Shared/useAppMutation";
import { Post, Put } from "../../../api/controllers/controller";
import DynamicForm from "../../shared/DynamicForm";
import { buildYupSchema } from "../../../utils/buildYupSchema";
import {
  processFormPayload,
  buildFormInitialValues,
} from "../../../utils/processFormPayload";

// ---- API helpers ----
const fetchDepartmentsOptions = async () => {
  const res = await Post("/api/users/options", { Dropdown: "Departments" });
  const payload = res?.data ?? res;
  const list =
    payload?.Options ??
    payload?.data?.Options ??
    payload?.data ??
    payload ??
    [];
  // allow any shape; DynamicForm can accept {value,label} OR raw items
  return Array.isArray(list) ? list : [];
};

const pickFirstDetail = (res) => {
  const data = res?.data ?? res;
  const arr = Array.isArray(data?.Item) ? data.Item : [];
  return arr[0] ?? null;
};

// ---- Base fields (Departments options will be injected later) ----
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
    label: "Department(s)",
    type: "dropdown", // or "multiselect" if you allow many
    required: true,
    valueType: "number",
    // options will be injected after we fetch them
    placeholder: "Choose departments",
  },
];

export default function EditUser() {
  const params = useParams();
  const idStr = params.id ?? params.userId ?? params.userID ?? params.Id;
  const idNum = Number.parseInt(idStr, 10);
  const hasValidId = Number.isFinite(idNum);

  const navigate = useNavigate();

  // 1) Fetch dropdown options FIRST
  const {
    data: deptResp,
    isLoading: isLoadingOpts,
    isError: isOptsError,
    error: optsError,
  } = useAppQuery("deptOptions", fetchDepartmentsOptions);

  // Map options to whatever shape; DynamicForm is tolerant either way
  const deptOptions = useMemo(() => {
    const list = deptResp ?? [];
    // if not already {value,label}, keep raw; DynamicForm will normalize
    return Array.isArray(list) ? list : [];
  }, [deptResp]);

  // 2) Only after options are ready, fetch the user detail
  const {
    data: detailResp,
    isLoading: isDetailLoading,
    isError: isDetailError,
    error: detailError,
  } = useAppQuery(
    `user:${idStr}`,
    () => Post("/api/users/detail", { Id: idNum }),
    { enabled: !!hasValidId && !isLoadingOpts && !isOptsError }
  );

  // Inject the fetched options into fields so the form doesn't refetch them
  const fields = useMemo(() => {
    return baseFields.map((f) =>
      f.name === "Departments"
        ? {
            ...f,
            options: deptOptions, // static options -> no optionsFetcher call
            optionsFetcher: undefined,
          }
        : f
    );
  }, [deptOptions]);

  const schema = useMemo(() => buildYupSchema(fields), [fields]);

  // Build initial values once both: options ready & detail ready
  const initialValues = useMemo(() => {
    const apiUser = pickFirstDetail(detailResp);
    if (!apiUser) return null;
    const iv = buildFormInitialValues(fields, apiUser);
    iv.Password = ""; // never prefill
    return iv;
  }, [fields, detailResp]);

  // Save
  const save = async (payload) => {
    let body = processFormPayload(fields, payload);
    if (!body.Password) {
      const { Password, ...rest } = body;
      body = rest;
    }
    // make sure Departments is number (or array of numbers if multiselect)
    if (Array.isArray(body.Departments)) {
      body.Departments = body.Departments.map((v) => Number(v));
    } else if (body.Departments != null) {
      body.Departments = Number(body.Departments);
    }
    return await Put(`/api/users/${idNum}`, body);
  };

  const mutation = useAppMutation("UpdateUser", save, {
    onSuccessRedirect: "/admin/users",
  });

  // ---- UI ----
  if (!hasValidId) {
    return (
      <div className="flex items-start min-h-full">
        <div className="w-[32rem] p-6 rounded shadow-lg bg-white border">
          <div className="text-center text-red-600 py-8">
            Invalid user id in URL.
          </div>
        </div>
      </div>
    );
  }

  if (isLoadingOpts) {
    return (
      <div className="flex items-start min-h-full">
        <div className="w-[32rem] p-6 rounded shadow-lg bg-white border">
          <div className="text-center text-slate-500 py-8">
            Loading options…
          </div>
        </div>
      </div>
    );
  }

  if (isOptsError) {
    return (
      <div className="flex items-start min-h-full">
        <div className="w-[32rem] p-6 rounded shadow-lg bg-white border">
          <div className="text-center text-red-600 py-8">
            Failed to load dropdown options
            {optsError?.message ? `: ${optsError.message}` : ""}.
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="flex items-start min-h-full">
      <div className="w-[32rem] p-6 rounded shadow-lg bg-white border">
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-2xl font-bold text-blue-800">Edit User</h2>
          <button
            onClick={() => navigate(-1)}
            className="rounded bg-slate-200 px-3 py-1 hover:bg-slate-300"
          >
            Back
          </button>
        </div>

        {isDetailLoading ? (
          <div className="text-center text-slate-500 py-8">Loading…</div>
        ) : isDetailError ? (
          <div className="text-center text-red-600 py-8">
            Failed to load user
            {detailError?.message ? `: ${detailError.message}` : ""}.
          </div>
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
