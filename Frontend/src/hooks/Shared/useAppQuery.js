// useAppQuery.js
import { useQuery } from "@tanstack/react-query";
import { useNavigate, useLocation } from "react-router-dom";
import { run } from "./kit";
export { plugins } from "./kit";
import { toast } from "react-toastify";

export const useAppQuery = (
  key, // string | array
  queryFn,
  {
    plugins: userPlugins = [],
    enabled = true,

    // fresher-by-default:
    refetchOnWindowFocus = true,
    refetchOnReconnect = true,
    refetchOnMount = "always",
    staleTime = 0,
    gcTime = 0, // v5 name for cacheTime
    keepPreviousData = false,
    structuralSharing = false, // avoid reusing old refs

    toastOnSuccess = false,
    queryKey, // optional explicit override
    ...rest
  } = {}
) => {
  const navigate = useNavigate();
  const location = useLocation();

  const finalKey = queryKey ?? (Array.isArray(key) ? key : [key]);

  return useQuery({
    queryKey: finalKey,
    queryFn,
    enabled,

    // freshness defaults
    refetchOnWindowFocus,
    refetchOnReconnect,
    refetchOnMount,
    staleTime,
    gcTime,
    keepPreviousData,
    structuralSharing,

    onSuccess: (data) => {
      run(userPlugins, "onSuccess", {
        data,
        navigate,
        location,
        queryKey: finalKey,
      });
      if (toastOnSuccess) {
        const msg = data?.message || data?.data?.message;
        if (msg) toast.success(msg);
      }
      rest.onSuccess?.(data);
    },

    onError: (error) => {
      run(userPlugins, "onError", {
        error,
        navigate,
        location,
        queryKey: finalKey,
      });
      rest.onError?.(error);
    },

    onSettled: (data, error) => {
      run(userPlugins, "onSettled", {
        data,
        error,
        navigate,
        location,
        queryKey: finalKey,
      });
      rest.onSettled?.(data, error);
    },

    ...rest,
  });
};
