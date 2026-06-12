import $ from "@/compat/jquery";
import {
  collectPopupLayers,
  closeTopmostPopup,
  getTopmostPopupLayer,
  hidePopupLayer,
  isPopupLayerOwnedBy,
  resolveControlledPopup,
  resolvePopupLayer,
  resolvePopupOwnerDocument,
  resolvePopupOwnerHost,
  resolvePopupTarget,
  syncPopupLayerOwnerScope,
} from "@/compat/popup/host";
import {
  queryElementsBySelectors,
  resolveHostElement,
  resolveOwnerDocument,
} from "@/compat/dom/host";

const POPUP_SELECTOR = ".k-animation-container, .k-child-animation-container, .k-popup, .k-list-container, .k-calendar-container, .k-menu-popup, .k-tooltip-wrapper, .k-tooltip, .k-window, .k-dialog";

function asElement(root = null) {
  return resolveHostElement(root) || resolvePopupOwnerDocument(root) || resolveOwnerDocument(root);
}

function isDocumentScope(scope) {
  return !!scope && (scope.nodeType === 9 || scope === scope.ownerDocument?.body);
}

const legacyKendoPopupRefs = new WeakMap();

function findPropertyDescriptor(target, propertyName) {
  let current = target;
  while (current && typeof current === "object") {
    const descriptor = Object.getOwnPropertyDescriptor(current, propertyName);
    if (descriptor) {
      return descriptor;
    }
    current = Object.getPrototypeOf(current);
  }
  return null;
}

function canWriteLegacyProperty(target, propertyName) {
  const descriptor = findPropertyDescriptor(target, propertyName);
  return !descriptor || descriptor.writable === true || typeof descriptor.set === "function";
}

function safeSetLegacyProperty(target, propertyName, value) {
  if (!target || typeof target !== "object" || !canWriteLegacyProperty(target, propertyName)) {
    return false;
  }
  try {
    target[propertyName] = value;
    return true;
  } catch (_error) {
    return false;
  }
}

function getWritableLegacyPopupRefs(widget) {
  let popup = null;
  try {
    popup = widget?.popup;
  } catch (_error) {
    popup = null;
  }
  if (popup && typeof popup === "object") {
    return popup;
  }
  if (!legacyKendoPopupRefs.has(widget)) {
    legacyKendoPopupRefs.set(widget, {});
  }
  const popupRefs = legacyKendoPopupRefs.get(widget);
  safeSetLegacyProperty(widget, "popup", popupRefs);
  return popupRefs;
}

function markKendoPopupLayer(layer, owner = null, kind = "kendo") {
  const popupLayer = syncPopupLayerOwnerScope(layer, owner || layer, {
    className: "ntss-kendo-popup-hosted",
    kind,
  });
  if (popupLayer?.classList) {
    popupLayer.classList.add("ntss-kendo-popup-legacy");
  }
  const wrapper = popupLayer?.closest?.(".k-animation-container, .k-child-animation-container") || null;
  if (wrapper?.classList) {
    wrapper.classList.add("ntss-kendo-popup-legacy");
  }
  return popupLayer || layer || null;
}

function isCandidateOwnedByScope(candidate, scope) {
  if (!candidate || !scope || isDocumentScope(scope)) {
    return true;
  }
  const ownerHost = resolvePopupOwnerHost(scope) || scope;
  if (ownerHost?.contains?.(candidate) || candidate.contains?.(ownerHost)) {
    return true;
  }
  return isPopupLayerOwnedBy(candidate, ownerHost);
}

function collectPopupCandidates(scope = null) {
  const safeScope = asElement(scope);
  if (!safeScope) {
    return [];
  }
  const candidates = [];
  const push = (element) => {
    const marked = markKendoPopupLayer(element, safeScope, "kendo");
    if (marked && !candidates.includes(marked)) {
      candidates.push(marked);
    }
  };
  collectPopupLayers(safeScope, { selectors: [POPUP_SELECTOR], includeHidden: true }).forEach(push);
  queryElementsBySelectors([POPUP_SELECTOR], safeScope, {
    includeSelf: true,
    includeClosestHost: false,
    includeBody: true,
    includeOwnerDocument: true
  }).forEach(push);
  return candidates;
}

function resolveCloseTargets(scope = null) {
  const safeScope = asElement(scope);
  const candidates = collectPopupCandidates(safeScope);
  if (!safeScope || isDocumentScope(safeScope)) {
    return candidates;
  }
  // Vue2 の widget close は現在 popup を閉じる口径。popup 入れ子時は DOM 後方の最上層だけを対象にする。
  // Vue3/Kendo Native は body portal になりやすいため、owner scope を写した popup を優先して、
  // 他 modal / 他 editor の popup まで閉じない。
  const scopedCandidates = candidates.filter((candidate) => isCandidateOwnedByScope(candidate, safeScope));
  const targets = scopedCandidates.length ? scopedCandidates : candidates;
  return targets.length ? [targets[targets.length - 1]] : [];
}

export function closeKendoPopups(root = null) {
  const scope = asElement(root);
  try { scope?.activeElement?.blur?.(); } catch (_error) { /* noop */ }
  const targets = resolveCloseTargets(scope);
  if (!targets.length) {
    closeTopmostPopup(root);
    return;
  }
  const ownerDocument = resolvePopupOwnerDocument(scope || root);
  const controls = Array.from(ownerDocument?.querySelectorAll?.('[aria-expanded="true"]') || []);
  controls.forEach((element) => { element.setAttribute('aria-expanded', 'false'); });
  targets.forEach((element) => hidePopupLayer(element));
}

export function detachKendoPopupEventHandlers(root = null) {
  const scope = asElement(root);
  const candidates = resolveCloseTargets(scope);
  Array.from(new Set(candidates)).forEach((element) => {
    try { $(element).off(); } catch (_error) { /* noop */ }
  });
}

export function resolveKendoPopupLayer(root = null) {
  const layer = resolvePopupLayer(root) || getTopmostPopupLayer(root, { selectors: [POPUP_SELECTOR], includeHidden: true });
  return markKendoPopupLayer(layer, root, "kendo");
}

export function resolveKendoControlledPopup(root = null) {
  const layer = resolveControlledPopup(root) || resolveKendoPopupLayer(root);
  return markKendoPopupLayer(layer, root, "kendo-controlled");
}

export function syncKendoPopupHostScope(popupOrWidget = null, root = null, kind = "kendo") {
  const host = resolvePopupTarget(popupOrWidget, root) || resolvePopupOwnerHost(root);
  const layer = resolveKendoControlledPopup(popupOrWidget) || resolveKendoPopupLayer(host || root);
  return markKendoPopupLayer(layer, host || root, kind);
}

export function syncKendoPopupWidgetRefs(widget, root = null) {
  if (!widget) {
    return widget;
  }
  const host = resolvePopupTarget(widget, root);
  const popupElement = syncKendoPopupHostScope(widget, host || root, "kendo-widget") || resolveKendoControlledPopup(widget) || resolveKendoPopupLayer(host || root);
  const $popup = popupElement ? $(popupElement) : $();
  const $wrapper = popupElement
    ? $(popupElement).closest(".k-animation-container, .k-popup, .k-list-container, .k-calendar-container")
    : $();
  const popupRefs = getWritableLegacyPopupRefs(widget);
  popupRefs.element = popupRefs.element || $popup;
  popupRefs.wrapper = popupRefs.wrapper || ($wrapper.length ? $wrapper : $popup);
  const ownerDocument = resolvePopupOwnerDocument(host || popupElement || root);
  safeSetLegacyProperty(widget, "ownerDocument", ownerDocument);
  safeSetLegacyProperty(widget, "ownerWindow", ownerDocument?.defaultView || widget.ownerWindow);
  safeSetLegacyProperty(widget, "ownerHost", resolvePopupOwnerHost(host || popupElement || root));
  return widget;
}
