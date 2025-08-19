import React, { useRef, useEffect } from "react";
import * as yup from "yup";
import { useAppMutation } from "../../hooks/Shared/useAppMutation";
import { Post } from "../../api/controllers/controller";
import DynamicForm from "../shared/DynamicForm";

/* ───────────────── schema & field list ───────────────── */
const schema = yup.object({
  NewPassword: yup.string().required("New password is required"),
});

const fields = [
  {
    name: "NewPassword",
    label: "New Password",
    type: "password",
    placeholder: "Enter your new password",
    className: "border border-gray-400 rounded p-2 text-blue-900",
  },
];

/* ───────────────── component ───────────────── */
const ChangePassword = () => {
  const formRef = useRef(null);

  // one hard reset on initial mount
  useEffect(() => formRef.current?.resetForm(), []);

  // 👉 Post to /api/auth/change-password using controllers.js Post helper
  const changePassword = async (payload) => {
    const data = await Post("/auth/change-password", payload);
    return data;
  };

  const mutation = useAppMutation("changepassword", changePassword);

  return (
    <div className="flex  items-start min-h-full">
      <div className="w-full max-w-md p-6 rounded shadow-lg bg-white border">
        <h2 className="text-2xl font-bold text-center text-blue-800 mb-6">
          Change Password
        </h2>

        {/* key={location.key} forces remount on every visit */}
        <DynamicForm
          key={location.key}
          ref={formRef}
          fields={fields}
          validationSchema={schema}
          onSubmit={(d) => mutation.mutate(d)}
          resetOnSuccess /* clear after success */
          submitButtonText={mutation.isPending ? "Saving…" : "Save"}
          isSubmitting={mutation.isPending}
        />
      </div>
    </div>
  );
};

export default ChangePassword;
