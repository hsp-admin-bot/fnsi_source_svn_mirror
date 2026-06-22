/**
 * API 層で利用するブラウザ API 参照を現在の実行 window に寄せる。
 * Vue2 の単一 window 前提の呼び出しを Vue3/Vite の module 実行下でも保つため、
 * API ファイル側に DOM/Window 取得のばらつきを残さない。
 */
export function getApiWindow() {
  if (typeof window !== "undefined") {
    return window;
  }
  if (typeof globalThis !== "undefined") {
    return globalThis;
  }
  return null;
}

export function getApiLocation() {
  const apiWindow = getApiWindow();
  if (apiWindow?.location) {
    return apiWindow.location;
  }
  if (typeof location !== "undefined") {
    return location;
  }
  return null;
}

export function getApiURLSearchParamsCtor() {
  const apiWindow = getApiWindow();
  if (typeof apiWindow?.URLSearchParams === "function") {
    return apiWindow.URLSearchParams;
  }
  if (typeof URLSearchParams === "function") {
    return URLSearchParams;
  }
  return null;
}

export function isApiURLSearchParams(params) {
  const URLSearchParamsCtor = getApiURLSearchParamsCtor();
  return !!URLSearchParamsCtor && params instanceof URLSearchParamsCtor;
}

export function createApiFormData() {
  const apiWindow = getApiWindow();
  const FormDataCtor = typeof apiWindow?.FormData === "function"
    ? apiWindow.FormData
    : (typeof FormData === "function" ? FormData : null);
  if (!FormDataCtor) {
    throw new Error("FormData is not available.");
  }
  return new FormDataCtor();
}

export function encodeApiBase64(content = "") {
  const apiWindow = getApiWindow();
  if (typeof apiWindow?.btoa === "function") {
    return apiWindow.btoa(content);
  }
  if (typeof btoa === "function") {
    return btoa(content);
  }
  const BufferCtor = typeof globalThis !== "undefined" ? globalThis.Buffer : null;
  if (typeof BufferCtor?.from === "function") {
    return BufferCtor.from(content, "binary").toString("base64");
  }
  return content;
}
