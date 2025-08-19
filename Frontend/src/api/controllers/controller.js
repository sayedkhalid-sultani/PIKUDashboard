import api from "../../api/Shared/axiosInstance";

/**
 * Generic request handler for all HTTP methods.
 * @param {string} method - HTTP method (get, post, put, delete)
 * @param {string} url - API endpoint
 * @param {object} [data] - Request body or params
 * @param {object} [config] - Axios config
 */
const request = async (method, url, data = {}, config = {}) => {
  const options = {
    validateStatus: () => true,
    ...config,
  };
  if (method === "get" || method === "delete") {
    options.params = data;
    return (await api[method](url, options)).data;
  } else {
    options.headers = {
      "Content-Type": "application/json",
      ...options.headers,
    };
    return (await api[method](url, data, options)).data;
  }
};

export const Get = (url, params = {}, config = {}) =>
  request("get", url, params, config);

export const Post = (url, body = {}, config = {}) =>
  request("post", url, body, config);

export const Put = (url, body = {}, config = {}) =>
  request("put", url, body, config);

export const Delete = (url, params = {}, config = {}) =>
  request("delete", url, params, config);
