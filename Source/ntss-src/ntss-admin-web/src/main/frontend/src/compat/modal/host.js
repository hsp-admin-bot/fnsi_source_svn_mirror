import {
  createCompatPopupEvent,
  getTopmostPopupLayer,
  resolvePopupOwnerDocument,
  resolvePopupTarget,
  wrapCompatPopupHandler,
} from "@/compat/popup/host";
import { queryElementBySelectors, queryElementsBySelectors, resolveHostElement } from "@/compat/dom/host";

const MODAL_SELECTORS = [
  "ons-modal",
  "ons-dialog",
  "ons-alert-dialog",
  ".ons-modal",
  ".ons-dialog",
  ".ons-alert-dialog",
  ".k-window",
  ".k-dialog",
  ".modal",
  ".modal-dialog",
];

export function resolveModalHost(target = null, fallback = null) {
  const base = resolvePopupTarget(target, fallback);
  return queryElementBySelectors(MODAL_SELECTORS, base, {
    includeSelf: true,
    includeClosestHost: true,
    includeBody: true,
    includeOwnerDocument: true,
  }) || base || null;
}

export function collectModalHosts(target = null) {
  const host = resolveModalHost(target);
  return queryElementsBySelectors(MODAL_SELECTORS, host || resolvePopupOwnerDocument(target), {
    includeSelf: true,
    includeBody: true,
    includeOwnerDocument: true,
  });
}

export function getTopmostModalHost(target = null) {
  return collectModalHosts(target).pop() || getTopmostPopupLayer(target) || null;
}

export function createCompatModalEvent(event = {}, context = {}) {
  const modal = context.modal || resolveModalHost(event, context.host);
  return createCompatPopupEvent(event, {
    ...context,
    layer: modal,
    dialog: context.dialog || modal,
  });
}

export function wrapCompatModalHandler(handler, context = {}) {
  return wrapCompatPopupHandler(function modalHandler(event) {
    return handler.call(this, createCompatModalEvent(event, context));
  }, context);
}

export function focusFirstModalElement(target = null) {
  const host = resolveHostElement(resolveModalHost(target));
  const focusTarget = queryElementBySelectors([
    "[autofocus]",
    "button:not([disabled])",
    "input:not([disabled])",
    "select:not([disabled])",
    "textarea:not([disabled])",
    "[tabindex]:not([tabindex='-1'])",
  ], host, { includeSelf: false, includeBody: false, includeOwnerDocument: false });
  try {
    focusTarget?.focus?.();
  } catch (_error) {
    // noop
  }
  return focusTarget || null;
}

export default {
  resolveModalHost,
  collectModalHosts,
  getTopmostModalHost,
  createCompatModalEvent,
  wrapCompatModalHandler,
  focusFirstModalElement,
};
