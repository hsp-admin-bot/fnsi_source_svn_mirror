import { h } from "vue";
import { Window, Dialog, DialogActionsBar } from "@progress/kendo-vue-dialogs";
import { createCompatModalEvent, wrapCompatModalHandler } from "@/compat/modal/host";
import { resolveHostElement } from "@/compat/dom/host";

function mergeClassValue(current, legacyClass) {
  if (!current) {
    return legacyClass;
  }
  if (Array.isArray(current)) {
    return [...current, legacyClass];
  }
  if (typeof current === "object") {
    return { ...current, [legacyClass]: true };
  }
  return `${current} ${legacyClass}`;
}

function normalizeDialogProps(props = {}, type = "dialog") {
  const normalized = { ...props };
  const legacyClass = type === "window" ? "ntss-kendo-window-legacy" : "ntss-kendo-dialog-legacy";
  normalized.class = mergeClassValue(normalized.class, legacyClass);
  normalized.className = mergeClassValue(normalized.className, legacyClass);
  normalized["data-ntss-kendo-dialog"] = type;
  ["close", "open", "activate", "deactivate", "focus"].forEach((name) => {
    const handlerName = `on${name.charAt(0).toUpperCase()}${name.slice(1)}`;
    if (typeof normalized[handlerName] === "function") {
      normalized[handlerName] = wrapCompatModalHandler(normalized[handlerName], { dialog: type });
    }
  });
  if (typeof normalized.onClose === "function") {
    normalized.onClose = wrapCompatModalHandler(normalized.onClose, { dialog: type });
  }
  return normalized;
}

export const KendoCompatWindow = {
  name: "KendoCompatWindow",
  inheritAttrs: false,
  render() {
    return h(Window, normalizeDialogProps(this.$attrs, "window"), this.$slots);
  }
};

export const KendoCompatDialog = {
  name: "KendoCompatDialog",
  inheritAttrs: false,
  render() {
    return h(Dialog, normalizeDialogProps(this.$attrs, "dialog"), this.$slots);
  }
};

export function createKendoDialogEvent(event = {}, context = {}) {
  const target = resolveHostElement(event?.target || event?.currentTarget || context.host);
  return createCompatModalEvent(event, {
    ...context,
    dialog: context.dialog || target || null,
  });
}

export function wrapKendoDialogHandler(handler, context = {}) {
  return wrapCompatModalHandler(handler, context);
}

export { Window, Dialog, DialogActionsBar };
export default {
  Window,
  Dialog,
  DialogActionsBar,
  KendoCompatWindow,
  KendoCompatDialog,
  createKendoDialogEvent,
  wrapKendoDialogHandler,
};
