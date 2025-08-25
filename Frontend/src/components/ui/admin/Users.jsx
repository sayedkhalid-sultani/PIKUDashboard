import React, { useMemo } from "react";
import { useNavigate } from "react-router-dom";
import SmartDataTable from "../../shared/SmartDataTable";
import { cls } from "../../../utils/SmartDataTableui";
import { Post, Delete } from "../../../api/controllers/controller";
import { useAppQuery } from "../../../hooks/Shared/useAppQuery";
import { useAppMutation } from "../../../hooks/Shared/useAppMutation";

export default function Users() {
  const navigate = useNavigate();

  // Fetch list via POST /api/users/search (CommonFilterDto body)
  const {
    data: resp,
    refetch,
    isLoading,
    isError,
    error,
  } = useAppQuery(
    "users",
    () =>
      Post("/api/users/search", {
        // send empty body for "all users" or add filters/paging here
        // e.g. { Page: 1, PageSize: 20 }
      }),
    {
      refetchOnMount: "always",
      refetchOnWindowFocus: true,
      refetchOnReconnect: true,
      staleTime: 0,
      gcTime: 0,
      keepPreviousData: false,
      structuralSharing: false,
    }
  );

  // Extract rows from multi-result shape: { data: { Items: [...] } }
  const rows = useMemo(() => {
    const data = resp?.data ?? resp;
    return Array.isArray(data?.Items) ? data.Items : [];
  }, [resp]);

  // Stable key for table to force re-render when dataset changes
  const tableKey = useMemo(
    () => `users:${rows.length}:${rows.map((r) => r.id).join(",")}`,
    [rows]
  );

  // Delete endpoint remains: DELETE /api/users/{id}
  const deleteMutation = useAppMutation(
    "deleteUser",
    async (row) => Delete(`/api/users/${row.Id}`),
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

      {isLoading ? (
        <div className="py-10 text-center text-slate-500">Loading…</div>
      ) : isError ? (
        <div className="py-10 text-center text-red-600">
          Failed to load users{error?.message ? `: ${error.message}` : ""}.
        </div>
      ) : (
        <SmartDataTable
          key={tableKey}
          title="User List"
          data={rows}
          hiddenKeys={["id"]}
          filterKeys={["Username", "Role"]}
          onEdit={(row) => navigate(`/admin/users/edit/${row.id}`)}
          onDelete={(row) => {
            if (window.confirm(`Delete ${row.Username}?`)) {
              deleteMutation.mutate(row);
            }
          }}
          dense
        />
      )}
    </div>
  );
}
