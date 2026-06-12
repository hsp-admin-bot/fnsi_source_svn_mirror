import axios from "axios";

export function normalizeAxiosParams(params) {
  if (typeof URLSearchParams === "function" && params instanceof URLSearchParams) {
    return params;
  }
  if (params !== null && typeof params === "object") {
    return params;
  }
  return undefined;
}

export function createAxiosInstance(config = {}) {
  return axios.create(config);
}

export { axios };
export default axios;
