/**
 * public 配下の静的リソースパスを Vite の base に合わせて解決します。
 * Vue2 時代の相対 public パス（img/..., help/..., audio/...）をページ側で個別に直さず、
 * compat 層で /ntss-admin-web/ 等の base に揃えるための facade です。
 */
const PUBLIC_ROOTS = [
  "application/",
  "audio/",
  "css/",
  "error/",
  "help/",
  "img/",
  "static/"
];

const ASSET_ATTRS = ["src", "href", "poster", "data", "xlink:href"];
const OBSERVED_ATTRS = [...ASSET_ATTRS, "srcset", "style"];
const publicAssetObservers = new WeakMap();

function getEnvBase() {
  return (import.meta.env && import.meta.env.BASE_URL ? import.meta.env.BASE_URL : "/").replace(/\/?$/, "/");
}

function isExternalPath(path) {
  return /^(?:[a-z][a-z\d+.-]*:|\/\/|data:|blob:|mailto:|tel:|#)/i.test(String(path || ""));
}

function stripPublicPrefix(path = "") {
  return String(path || "")
    .trim()
    .replace(/^~?\/?public\//, "")
    .replace(/^\.\/?public\//, "")
    .replace(/^\/+/, "");
}

function getOwnerDocument(root = null) {
  const host = root?.$el || root;
  return host?.ownerDocument || globalThis.document || null;
}

function getOwnerWindow(root = null) {
  const ownerDocument = getOwnerDocument(root);
  return ownerDocument?.defaultView || globalThis.window || null;
}

function getNormalizeRoot(root = null) {
  const host = root?.$el || root;
  if (host?.nodeType === 1 || host?.nodeType === 9 || host?.nodeType === 11) {
    return host;
  }
  return getOwnerDocument(root)?.body || null;
}

function normalizeUrlToken(token = "") {
  const value = String(token || "").trim();
  return isPublicAssetPath(value) ? publicAssetPath(value) : value;
}

function normalizeSrcsetValue(value = "") {
  return String(value || "")
    .split(",")
    .map((part) => {
      const trimmed = part.trim();
      if (!trimmed) {
        return trimmed;
      }
      const [url, ...descriptors] = trimmed.split(/\s+/);
      return [normalizeUrlToken(url), ...descriptors].filter(Boolean).join(" ");
    })
    .join(", ");
}

function normalizeStylePublicAssets(value = "") {
  return String(value || "").replace(/url\((['"]?)([^)'"]+)\1\)/g, (match, quote, url) => {
    const nextUrl = normalizeUrlToken(url);
    return nextUrl === url ? match : `url(${quote}${nextUrl}${quote})`;
  });
}

function normalizeElementPublicAssetAttrs(node) {
  if (!node?.getAttribute || !node?.setAttribute) {
    return;
  }

  ASSET_ATTRS.forEach((attr) => {
    const value = node.getAttribute(attr);
    if (!isPublicAssetPath(value)) {
      return;
    }
    const nextValue = publicAssetPath(value);
    if (nextValue !== value) {
      node.setAttribute(attr, nextValue);
    }
  });

  const srcset = node.getAttribute("srcset");
  if (srcset) {
    const nextSrcset = normalizeSrcsetValue(srcset);
    if (nextSrcset !== srcset) {
      node.setAttribute("srcset", nextSrcset);
    }
  }

  const style = node.getAttribute("style");
  if (style && /url\(/.test(style)) {
    const nextStyle = normalizeStylePublicAssets(style);
    if (nextStyle !== style) {
      node.setAttribute("style", nextStyle);
    }
  }
}

export function publicBasePath() {
  return getEnvBase();
}

export function isPublicAssetPath(path = "") {
  if (!path || isExternalPath(path)) {
    return false;
  }
  const normalized = stripPublicPrefix(path);
  return PUBLIC_ROOTS.some((root) => normalized.startsWith(root));
}

export function publicAssetPath(path = "") {
  const raw = String(path || "");
  if (!raw || isExternalPath(raw)) {
    return raw;
  }
  const base = publicBasePath();
  const normalizedPath = stripPublicPrefix(raw);
  if (raw.startsWith(base)) {
    return raw;
  }
  return `${base}${normalizedPath}`;
}

export function normalizePublicAssetPath(path = "") {
  return isPublicAssetPath(path) ? publicAssetPath(path) : path;
}

export function normalizeElementPublicAssets(root = null) {
  const host = getNormalizeRoot(root);
  if (!host) {
    return;
  }

  if (host.nodeType === 1) {
    normalizeElementPublicAssetAttrs(host);
  }

  if (!host.querySelectorAll) {
    return;
  }

  const selector = [
    ...ASSET_ATTRS.map((attr) => `[${attr.replace(":", "\\:")}]`),
    "[srcset]",
    "[style*=\"url(\"]"
  ].join(",");

  try {
    host.querySelectorAll(selector).forEach((node) => normalizeElementPublicAssetAttrs(node));
  } catch (_error) {
    host.querySelectorAll?.("[src], [href], [poster], [data], [srcset], [style]").forEach((node) => normalizeElementPublicAssetAttrs(node));
  }
}

function scheduleNormalize(root) {
  const run = () => normalizeElementPublicAssets(root);
  const ownerWindow = getOwnerWindow(root);
  if (typeof ownerWindow?.requestAnimationFrame === "function") {
    ownerWindow.requestAnimationFrame(run);
  } else if (typeof requestAnimationFrame === "function") {
    requestAnimationFrame(run);
  } else {
    setTimeout(run, 0);
  }
}

export function observePublicAssetMutations(root = null) {
  const ownerDocument = getOwnerDocument(root);
  const ownerWindow = getOwnerWindow(root);
  const observeRoot = ownerDocument?.body || getNormalizeRoot(root);
  const MutationObserverCtor = ownerWindow?.MutationObserver || globalThis.MutationObserver;

  if (!observeRoot || typeof MutationObserverCtor !== "function") {
    return null;
  }

  const existing = publicAssetObservers.get(observeRoot);
  if (existing) {
    return existing;
  }

  const observer = new MutationObserverCtor((mutations) => {
    mutations.forEach((mutation) => {
      if (mutation.type === "attributes") {
        normalizeElementPublicAssetAttrs(mutation.target);
        return;
      }
      mutation.addedNodes?.forEach((node) => {
        if (node?.nodeType === 1) {
          normalizeElementPublicAssets(node);
        }
      });
    });
  });

  observer.observe(observeRoot, {
    childList: true,
    subtree: true,
    attributes: true,
    attributeFilter: OBSERVED_ATTRS
  });
  publicAssetObservers.set(observeRoot, observer);
  return observer;
}

export function installPublicAssetsCompat(app) {
  if (app?.config?.globalProperties) {
    app.config.globalProperties.publicAssetPath = publicAssetPath;
    app.config.globalProperties.$publicAssetPath = publicAssetPath;
    app.config.globalProperties.normalizePublicAssetPath = normalizePublicAssetPath;
    app.config.globalProperties.$normalizePublicAssetPath = normalizePublicAssetPath;
  }
  app?.mixin?.({
    mounted() {
      scheduleNormalize(this.$el);
      observePublicAssetMutations(this.$el);
    },
    updated() {
      scheduleNormalize(this.$el);
    }
  });
}

export default {
  install: installPublicAssetsCompat,
  publicBasePath,
  publicAssetPath,
  normalizePublicAssetPath,
  normalizeElementPublicAssets,
  observePublicAssetMutations
};
