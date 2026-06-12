import {
  closestWithinHost,
  getScopedBody,
  queryElementBySelectors,
  queryElementsBySelectors,
  resolveHostElement,
  resolveOwnerDocument,
  resolveOwnerWindow,
} from "@/compat/dom/host";

const POPUP_LAYER_SELECTORS = [
  ".k-animation-container",
  ".k-child-animation-container",
  ".k-popup",
  ".k-list-container",
  ".k-calendar-container",
  ".k-menu-popup",
  ".k-tooltip",
  ".k-tooltip-wrapper",
  ".k-window",
  ".k-dialog",
  ".k-overlay",
  ".popover",
  ".tooltip",
  "ons-popover",
  "ons-dialog",
  "ons-alert-dialog",
  "ons-modal",
  ".ons-dialog",
  ".ons-alert-dialog",
  ".ons-modal",
];

const POPUP_OWNER_SCOPE_SELECTORS = [
  "[data-ntss-kendo-popup-owner]",
  "[data-ntss-scope-root]",
  "[data-ntss-owner-root]",
  "[data-ntss-layout-root]",
  "[data-ntss-role=\"modal-root\"]",
  "[data-ntss-role=\"popover-root\"]",
  "[role=\"dialog\"]",
  ".modal-container",
  ".modal-content",
  ".modal-body",
  ".popover",
  ".popover__content",
  ".k-window",
  ".k-dialog",
  ".k-editor",
  ".k-grid",
  "#app",
];

const TARGET_SELECTORS = [
  "[data-popup-target]",
  "[aria-controls]",
  "[aria-owns]",
  "button",
  "input",
  "select",
  "textarea",
  "[tabindex]",
];

function asArray(value) {
  return Array.isArray(value) ? value : value ? [value] : [];
}

function unique(elements) {
  const result = [];
  asArray(elements).forEach((element) => {
    if (element && !result.includes(element)) {
      result.push(element);
    }
  });
  return result;
}

function isConnected(element) {
  if (!element) {
    return false;
  }
  const documentElement = element.ownerDocument?.documentElement;
  return !documentElement || documentElement.contains(element) || element === documentElement;
}

function isVisible(element) {
  if (!element || element.nodeType !== 1) {
    return false;
  }
  if (element.getAttribute?.("aria-hidden") === "true") {
    return false;
  }
  const style = resolveOwnerWindow(element)?.getComputedStyle?.(element);
  if (style && (style.display === "none" || style.visibility === "hidden")) {
    return false;
  }
  const rect = element.getBoundingClientRect?.();
  return !rect || rect.width > 0 || rect.height > 0 || element.children?.length > 0;
}

function elementFromId(scope, id) {
  if (!scope || !id) {
    return null;
  }
  const ownerDocument = resolveOwnerDocument(scope);
  try {
    return ownerDocument?.getElementById?.(String(id)) || null;
  } catch (_error) {
    return null;
  }
}

function getElementClassList(element) {
  try {
    return Array.from(element?.classList || []);
  } catch (_error) {
    return [];
  }
}

function copyScopeAttributes(source, target) {
  if (!source?.attributes || !target?.setAttribute) {
    return;
  }
  Array.from(source.attributes).forEach((attribute) => {
    const name = attribute?.name || "";
    if (/^data-v-[\w-]+$/.test(name) || name === "data-ntss-scope-root" || name === "data-ntss-owner-root" || name === "data-ntss-layout-root") {
      try { target.setAttribute(name, attribute.value || ""); } catch (_error) { /* noop */ }
    }
  });
}

function copyOwnerClasses(owner, target) {
  if (!owner?.classList || !target?.classList) {
    return;
  }
  getElementClassList(owner)
    .filter((className) => className
      && !className.startsWith("k-")
      && !className.startsWith("dp__")
      && !className.startsWith("v-")
      && !className.startsWith("ons-")
      && className !== "active"
      && className !== "disabled")
    .slice(0, 12)
    .forEach((className) => {
      try {
        target.classList.add(className);
        target.classList.add(`ntss-popup-owner-${String(className).replace(/[^a-zA-Z0-9_-]/g, "-")}`);
      } catch (_error) {
        // noop
      }
    });
}

function ensureOwnerToken(owner) {
  if (!owner?.dataset) {
    return "";
  }
  if (!owner.dataset.ntssPopupOwnerToken) {
    owner.dataset.ntssPopupOwnerToken = `ntss-popup-${Math.random().toString(36).slice(2, 10)}`;
  }
  return owner.dataset.ntssPopupOwnerToken;
}

function closestOwnerScope(element) {
  const host = resolveHostElement(element, { allowDocument: false, allowFragment: false });
  if (!host?.closest) {
    return null;
  }
  try {
    return host.closest(POPUP_OWNER_SCOPE_SELECTORS.join(",")) || null;
  } catch (_error) {
    return null;
  }
}

export function resolvePopupOwnerHost(target = null, fallback = null) {
  const targetElement = resolvePopupTarget(target, fallback);
  return closestOwnerScope(targetElement)
    || closestOwnerScope(fallback)
    || targetElement
    || resolveHostElement(fallback, { allowDocument: false, allowFragment: false })
    || null;
}

export function getPopupOwnerToken(target = null, fallback = null) {
  const owner = resolvePopupOwnerHost(target, fallback);
  return ensureOwnerToken(owner);
}

export function syncPopupLayerOwnerScope(layer = null, target = null, options = {}) {
  const popupLayer = resolveHostElement(layer, { allowDocument: false, allowFragment: false });
  const owner = resolvePopupOwnerHost(target || popupLayer, options.fallback || null);
  if (!popupLayer || !owner) {
    return popupLayer || null;
  }
  const ownerToken = ensureOwnerToken(owner);
  const wrapper = popupLayer.closest?.(".k-animation-container, .k-child-animation-container, .k-popup, .k-list-container, .k-calendar-container, .k-tooltip-wrapper, .dp--menu-wrapper") || popupLayer;
  const targets = unique([wrapper, popupLayer, popupLayer.firstElementChild]);
  targets.forEach((element) => {
    if (!element?.classList) return;
    copyScopeAttributes(owner, element);
    copyOwnerClasses(owner, element);
    element.classList.add(options.className || "ntss-popup-hosted");
    if (element.dataset) {
      element.dataset.ntssPopupOwner = ownerToken;
      if (options.kind) {
        element.dataset.ntssPopupKind = options.kind;
      }
    }
  });
  return popupLayer;
}

export function isPopupLayerOwnedBy(layer = null, target = null) {
  const popupLayer = resolveHostElement(layer, { allowDocument: false, allowFragment: false });
  const ownerToken = getPopupOwnerToken(target);
  if (!popupLayer || !ownerToken) {
    return false;
  }
  return popupLayer.dataset?.ntssPopupOwner === ownerToken
    || popupLayer.closest?.(`[data-ntss-popup-owner="${ownerToken}"]`) != null;
}

export function resolvePopupOwnerDocument(target = null) {
  return resolveOwnerDocument(target);
}

export function resolvePopupOwnerWindow(target = null) {
  return resolveOwnerWindow(target);
}

export function resolvePopupTarget(target = null, fallback = null) {
  const direct = target?.currentTarget
    || target?.target
    || target?.element
    || target?.anchor
    || target?.sender?.element
    || target?.sender?.wrapper
    || target;
  return resolveHostElement(direct)
    || resolveHostElement(fallback)
    || null;
}

export function resolvePopupLayer(target = null, fallback = null) {
  const base = resolvePopupTarget(target, fallback);
  if (!base) {
    return null;
  }
  return queryElementBySelectors(POPUP_LAYER_SELECTORS, base, {
    includeSelf: true,
    includeClosestHost: true,
    includeBody: true,
    includeOwnerDocument: true,
  });
}

export function collectPopupLayers(target = null, options = {}) {
  const base = resolvePopupTarget(target, options.fallback) || resolveOwnerDocument(target);
  const body = getScopedBody(base);
  const roots = unique([base, options.root, body, resolveOwnerDocument(base)]);
  const candidates = [];
  roots.forEach((root) => {
    queryElementsBySelectors(options.selectors || POPUP_LAYER_SELECTORS, root, {
      includeSelf: true,
      includeClosestHost: false,
      includeBody: false,
      includeOwnerDocument: false,
    }).forEach((element) => {
      if (!candidates.includes(element)) {
        candidates.push(element);
      }
    });
  });
  return candidates.filter((element) => options.includeHidden || isVisible(element) || isConnected(element));
}

export function getTopmostPopupLayer(target = null, options = {}) {
  const candidates = collectPopupLayers(target, options);
  return candidates[candidates.length - 1] || null;
}

export function resolvePopupInteractiveTarget(target = null, fallback = null) {
  const base = resolvePopupTarget(target, fallback);
  if (!base) {
    return null;
  }
  return closestWithinHost(base, TARGET_SELECTORS.join(","), resolveOwnerDocument(base))
    || queryElementBySelectors(TARGET_SELECTORS, base, { includeSelf: true, includeBody: false, includeOwnerDocument: false })
    || base;
}

export function createCompatPopupEvent(event = {}, context = {}) {
  const target = resolvePopupTarget(event, context.target || context.element || context.host);
  const layer = context.layer || resolvePopupLayer(event, target);
  const ownerDocument = resolvePopupOwnerDocument(target || layer || context.host);
  return {
    ...(event || {}),
    target: event?.target || target || layer || null,
    currentTarget: event?.currentTarget || target || layer || null,
    element: event?.element || target || null,
    layer,
    popup: context.popup || event?.popup || layer || null,
    dialog: context.dialog || event?.dialog || null,
    tooltip: context.tooltip || event?.tooltip || null,
    ownerDocument,
    ownerWindow: resolveOwnerWindow(ownerDocument),
  };
}

export function wrapCompatPopupHandler(handler, context = {}) {
  if (typeof handler !== "function") {
    return handler;
  }
  return function compatPopupHandler(event) {
    return handler.call(this, createCompatPopupEvent(event, context));
  };
}

export function hidePopupLayer(layer) {
  const element = resolveHostElement(layer);
  if (!element) {
    return false;
  }
  try {
    element.setAttribute("aria-hidden", "true");
    element.classList?.remove?.("k-state-border-up", "k-state-border-down", "show");
    if (element.style) {
      element.style.display = "none";
    }
    return true;
  } catch (_error) {
    return false;
  }
}

export function closeTopmostPopup(target = null) {
  return hidePopupLayer(getTopmostPopupLayer(target, { includeHidden: false }));
}

export function resolveControlledPopup(target = null) {
  const element = resolvePopupInteractiveTarget(target);
  const ownerDocument = resolveOwnerDocument(element);
  const controls = element?.getAttribute?.("aria-controls") || element?.getAttribute?.("aria-owns");
  const controlled = elementFromId(ownerDocument, controls) || resolvePopupLayer(element);
  return syncPopupLayerOwnerScope(controlled, element, { kind: "controlled" }) || controlled;
}

export default {
  resolvePopupOwnerDocument,
  resolvePopupOwnerWindow,
  resolvePopupTarget,
  resolvePopupLayer,
  collectPopupLayers,
  getTopmostPopupLayer,
  resolvePopupInteractiveTarget,
  resolvePopupOwnerHost,
  getPopupOwnerToken,
  syncPopupLayerOwnerScope,
  isPopupLayerOwnedBy,
  createCompatPopupEvent,
  wrapCompatPopupHandler,
  hidePopupLayer,
  closeTopmostPopup,
  resolveControlledPopup,
};
