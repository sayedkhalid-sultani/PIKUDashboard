import axios from "axios";
import { useAuthStore } from "../../store/Shared/Store";

// Create the Axios instance
const api = axios.create({
  baseURL: "/", // Change to your API base URL if needed
  // Content-Type is set per request, not globally
});

// --- Token refresh state ---
let isRefreshing = false;
let failedQueue = [];

// Helper to resolve/reject queued requests during token refresh
const processQueue = (error, token = null) => {
  failedQueue.forEach((p) => (error ? p.reject(error) : p.resolve(token)));
  failedQueue = [];
};

// --- REQUEST INTERCEPTOR ---
api.interceptors.request.use(
  async (config) => {
    // Get current auth state
    const { accessToken, refreshTokenIfNeeded } = useAuthStore.getState();
    const url = config.url || "";
    // Skip auth for login endpoints or if explicitly disabled
    const skipAuth =
      config._skipAuthRefresh ||
      /\/api\/auth\/login/i.test(url) ||
      /\/auth\/login/i.test(url);

    // Attach token if needed
    if (!skipAuth && accessToken) {
      config.headers = config.headers || {};
      config.headers.Authorization = `Bearer ${accessToken}`;
    }

    // Optionally refresh token before request
    if (!skipAuth) {
      await refreshTokenIfNeeded?.();
    }

    return config;
  },
  (error) => Promise.reject(error)
);

// --- RESPONSE INTERCEPTOR ---
api.interceptors.response.use(
  (response) => {
    const data = response?.data;

    // If API returns { success: false }, throw error
    if (data && typeof data === "object" && "success" in data) {
      if (data.success !== true) {
        const err = new Error(data?.message || "Request failed");
        err.response = {
          data,
          status: response.status,
          config: response.config,
        };
        throw err;
      }
    }

    // Throw for HTTP error status codes
    if (response.status >= 400 && response.status <= 599) {
      const err = new Error(
        data?.message || `Request failed with status ${response.status}`
      );
      err.response = { data, status: response.status, config: response.config };
      throw err;
    }

    return response;
  },
  async (error) => {
    const originalRequest = error.config || {};
    const { refreshTokenIfNeeded, logout } = useAuthStore.getState();
    const url = originalRequest.url || "";
    // Skip refresh for login endpoints or if explicitly disabled
    const skipAuth =
      originalRequest._skipAuthRefresh ||
      /\/api\/auth\/login/i.test(url) ||
      /\/auth\/login/i.test(url);

    if (skipAuth) return Promise.reject(error);

    // Handle 401 Unauthorized: try to refresh token
    const is401 = error?.response?.status === 401;
    if (is401 && !originalRequest._retry) {
      originalRequest._retry = true;

      // If already refreshing, queue this request
      if (isRefreshing) {
        return new Promise((resolve, reject) => {
          failedQueue.push({ resolve, reject });
        })
          .then((newToken) => {
            originalRequest.headers = originalRequest.headers || {};
            originalRequest.headers.Authorization = "Bearer " + newToken;
            return api(originalRequest);
          })
          .catch((err) => Promise.reject(err));
      }

      isRefreshing = true;
      try {
        await refreshTokenIfNeeded?.();
        const newToken = useAuthStore.getState().accessToken;
        processQueue(null, newToken);
        originalRequest.headers = originalRequest.headers || {};
        originalRequest.headers.Authorization = "Bearer " + newToken;
        return api(originalRequest);
      } catch (refreshError) {
        processQueue(refreshError, null);
        logout?.();
        window.location.href = "/login";
        return Promise.reject(refreshError);
      } finally {
        isRefreshing = false;
      }
    }

    return Promise.reject(error);
  }
);

export default api;
