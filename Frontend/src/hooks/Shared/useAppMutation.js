import { useMutation, useQueryClient } from "@tanstack/react-query";
import { useNavigate, useLocation } from "react-router-dom";
import { useAuthStore } from "../../store/Shared/Store";
import { toast } from "react-toastify";
import { run } from "./kit";
export { plugins } from "./kit";

export const useAppMutation = (
  key,
  mutationFn,
  {
    plugins: userPlugins = [],
    onSuccessRedirect,
    navigateOptions = { replace: true },

    // pull user-provided callbacks so we can compose them
    onMutate: userOnMutate,
    onSuccess: userOnSuccess,
    onError: userOnError,
    onSettled: userOnSettled,

    ...rest
  } = {}
) => {
  const queryClient = useQueryClient();
  const navigate = useNavigate();
  const location = useLocation();
  const clearError = useAuthStore((s) => s.clearError);

  return useMutation({
    mutationKey: [key],
    mutationFn,
    // spread the rest FIRST so our handlers cannot be overridden
    ...rest,

    onMutate: (variables) => {
      if (typeof clearError === "function") clearError();
      run(userPlugins, "onMutate", {
        variables,
        queryClient,
        navigate,
        location,
        navigateOptions,
        mutationKey: key,
      });
      // compose
      userOnMutate?.(variables);
    },

    onSuccess: (data, variables, context) => {
      run(userPlugins, "onSuccess", {
        data,
        variables,
        context,
        queryClient,
        navigate,
        location,
        navigateOptions,
        mutationKey: key,
      });

      const msg =
        data?.message || // when helpers return res.data
        data?.data?.message || // when helpers return axios response
        "Operation successful";

      toast.success(msg, { toastId: `mut-success-${key}` });

      // compose (let caller run too)
      userOnSuccess?.(data, variables, context);

      if (onSuccessRedirect) {
        navigate(onSuccessRedirect, navigateOptions);
      }
    },

    onError: (error, variables, context) => {
      run(userPlugins, "onError", {
        error,
        variables,
        context,
        queryClient,
        navigate,
        location,
        navigateOptions,
        mutationKey: key,
      });

      toast.error(
        error?.response?.data?.message || error?.message || "An error occurred"
      );

      // compose
      userOnError?.(error, variables, context);
    },

    onSettled: (data, error, variables, context) => {
      run(userPlugins, "onSettled", {
        data,
        error,
        variables,
        context,
        queryClient,
        navigate,
        location,
        navigateOptions,
        mutationKey: key,
      });

      // compose
      userOnSettled?.(data, error, variables, context);
    },
  });
};
