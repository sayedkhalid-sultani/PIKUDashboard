import React, { useMemo } from "react";
import { useNavigate } from "react-router-dom";
import SmartDataTable from "../../shared/SmartDataTable";
import { cls } from "../../../utils/SmartDataTableui";
import { Get, Delete } from "../../../api/controllers/controller";
import { useAppQuery } from "../../../hooks/Shared/useAppQuery";
import { useAppMutation } from "../../../hooks/Shared/useAppMutation";

export default function Users() {
  const navigate = useNavigate();

  // fetch list
  const { data: resp, refetch } = useAppQuery(
    "users",
    () => Get("/api/users"),
    {
      refetchOnMount: "always",
      refetchOnWindowFocus: true,
      refetchOnReconnect: true,
      staleTime: 0,
      gcTime: 0,
      keepPreviousData: false,
      structuralSharing: false, // <— important: don’t reuse old array refs
    }
  );
  const rows = useMemo(() => resp?.data ?? resp ?? [], [resp]);

  const tableKey = useMemo(
    () => `users:${rows.length}:${rows.map((r) => r.id).join(",")}`,
    [rows]
  );

  // delete
  const deleteMutation = useAppMutation(
    "deleteUser",
    async (row) => Delete(`/api/users/${row.id}`), // adjust if your endpoint differs
    { onSuccess: () => refetch() }
  );

  return (
    <div className={cls.page}>
      <div className="flex items-center justify-between mb-2 ">
        <h1 className="text-xl font-semibold text-slate-900">Users</h1>
        <div className="flex justify-end ">
          <button
            onClick={() => navigate("/admin/users/new")}
            className="rounded bg-blue-600 text-white px-4 py-1 hover:bg-blue-700 "
          >
            Add
          </button>
        </div>
      </div>

      <SmartDataTable
        key={tableKey}
        title="User List"
        data={rows}
        hiddenKeys={["id"]}
        filterKeys={["username", "role"]}
        onEdit={(row) => navigate(`/admin/users/edit/${row.id}`)}
        onDelete={(row) => {
          if (window.confirm(`Delete ${row.username}?`)) {
            deleteMutation.mutate(row);
          }
        }}
        dense
      />
    </div>
  );
}
