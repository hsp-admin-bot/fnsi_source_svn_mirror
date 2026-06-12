import VueDOMPurifyHTML from "vue-dompurify-html";

function encodeHtmlTextWithDocument(text, ownerDocument) {
  const div = ownerDocument?.createElement?.("div");
  if (!div) {
    return null;
  }
  div.textContent = text;
  return div.innerHTML;
}

export function sanitizeText(value, root = null) {
  if (value === null || value === undefined) {
    return "";
  }
  const text = String(value);
  const ownerDocument = root?.ownerDocument || root?.$el?.ownerDocument || globalThis.document || null;
  const encoded = encodeHtmlTextWithDocument(text, ownerDocument);
  if (encoded !== null) {
    return encoded;
  }
  return text
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#39;");
}

export default {
  install(app) {
    app?.use?.(VueDOMPurifyHTML);
    if (app?.config?.globalProperties) {
      app.config.globalProperties.$sanitize = sanitizeText;
    }
  },
  sanitizeText
};
