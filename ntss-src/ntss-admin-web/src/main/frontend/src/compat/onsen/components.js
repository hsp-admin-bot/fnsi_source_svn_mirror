import "onsenui/css/onsenui.css";
import "onsenui/css/onsenui-core.css";
import "onsenui/css/onsen-css-components.css";
import { h, getCurrentInstance } from "vue";
import { createOnsCompat } from "@/compat/onsen/functions.js";
import VueOnsen from "vue-onsenui";
import * as VueOnsenComponents from "vue-onsenui/esm/components";
import { normalizeOnsInputAttrs } from "@/compat/onsen/input-attrs.js";
import { resolveOnsPopoverTargetElement } from "@/compat/onsen/popover.js";
import { getOnsElement, wrapOnsEventHandler } from "@/compat/onsen/host.js";

const {
  VOnsActionSheet: RawVOnsActionSheet,
  VOnsActionSheetButton,
  VOnsAlertDialog: RawVOnsAlertDialog,
  VOnsAlertDialogButton,
  VOnsBackButton,
  VOnsBottomToolbar: RawVOnsBottomToolbar,
  VOnsButton: RawVOnsButton,
  VOnsCard,
  VOnsCarousel,
  VOnsCarouselItem,
  VOnsCheckbox: RawVOnsCheckbox,
  VOnsCol,
  VOnsDialog: RawVOnsDialog,
  VOnsFab,
  VOnsIcon,
  VOnsInput: RawVOnsInput,
  VOnsLazyRepeat,
  VOnsList,
  VOnsListHeader,
  VOnsListItem: RawVOnsListItem,
  VOnsListTitle,
  VOnsModal: RawVOnsModal,
  VOnsNavigator,
  VOnsPage,
  VOnsPopover: RawVOnsPopover,
  VOnsProgressBar,
  VOnsProgressCircular,
  VOnsPullHook,
  VOnsRadio: RawVOnsRadio,
  VOnsRange,
  VOnsRipple,
  VOnsRow,
  VOnsSearchInput: RawVOnsSearchInput,
  VOnsSegment,
  VOnsSelect: RawVOnsSelect,
  VOnsSpeedDial: RawVOnsSpeedDial,
  VOnsSpeedDialItem,
  VOnsSplitter,
  VOnsSplitterContent,
  VOnsSplitterMask,
  VOnsSplitterSide,
  VOnsSwitch: RawVOnsSwitch,
  VOnsTab,
  VOnsTabbar,
  VOnsToast,
  VOnsToolbar,
  VOnsToolbarButton
} = VueOnsenComponents;

const ONS_LIFECYCLE_EVENT_ATTRS = new Set([
  "onPreshow",
  "onPostshow",
  "onPrehide",
  "onPosthide",
  "onShow",
  "onHide",
  "onCancel",
  "onDeviceBackButton"
]);

const ONS_NATIVE_LIFECYCLE_EVENT_MAP = {
  onPreshow: "preshow",
  onPostshow: "postshow",
  onPrehide: "prehide",
  onPosthide: "posthide",
  onCancel: "dialogcancel"
};

function isOnsLifecycleEventHandled(event) {
  return !!(event && typeof event === "object" && event.__ntssOnsLifecycleHandled);
}

function markOnsLifecycleEventHandled(event) {
  if (!event || typeof event !== "object") {
    return;
  }
  try {
    Object.defineProperty(event, "__ntssOnsLifecycleHandled", {
      configurable: true,
      value: true
    });
  } catch (_error) {
    event.__ntssOnsLifecycleHandled = true;
  }
}

function normalizeOnsForwardedAttrs(attrs, roleName, tagName, legacySelector, vm = null) {
  return Object.entries(attrs || {}).reduce((forwarded, [key, value]) => {
    if (ONS_LIFECYCLE_EVENT_ATTRS.has(key) && typeof value === "function") {
      const wrappedHandler = wrapOnsEventHandler(value, roleName, (event) => getOnsElement(
        event?.[roleName] || event?.target || event?.currentTarget || vm,
        tagName,
        legacySelector,
        vm
      ));
      forwarded[key] = (event, ...args) => {
        if (isOnsLifecycleEventHandled(event)) {
          return undefined;
        }
        markOnsLifecycleEventHandled(event);
        return wrappedHandler(event, ...args);
      };
      return forwarded;
    }
    forwarded[key] = value;
    return forwarded;
  }, {});
}

function removeOnsNativeLifecycleBridge(element) {
  const handlers = element?.__ntssOnsNativeLifecycleHandlers;
  if (!element || !Array.isArray(handlers)) {
    return;
  }
  handlers.forEach(({ eventName, handler }) => {
    element.removeEventListener?.(eventName, handler);
  });
  element.__ntssOnsNativeLifecycleHandlers = null;
}

function syncOnsNativeLifecycleBridge(element, attrs) {
  if (!element || !attrs) {
    return;
  }
  removeOnsNativeLifecycleBridge(element);
  const handlers = Object.entries(ONS_NATIVE_LIFECYCLE_EVENT_MAP)
    .map(([attrName, eventName]) => ({
      eventName,
      handler: attrs[attrName]
    }))
    .filter(({ handler }) => typeof handler === "function");
  handlers.forEach(({ eventName, handler }) => {
    element.addEventListener?.(eventName, handler);
  });
  element.__ntssOnsNativeLifecycleHandlers = handlers;
}

function cleanupOnsPortalElement(element) {
  if (!element || element.__ntssOnsPortalCleanup) {
    return;
  }
  element.__ntssOnsPortalCleanup = true;

  const removeElement = () => {
    try {
      element.remove?.();
    } catch (_error) {
      // noop
    }
  };

  if (element.visible === true && typeof element.hide === "function") {
    Promise.resolve(element.hide()).then(removeElement).catch(removeElement);
    return;
  }

  removeElement();
}

function withOnsPortalUnmountCleanup(attrs) {
  const forwardedAttrs = attrs || {};
  const originalBeforeUnmount = forwardedAttrs.onVnodeBeforeUnmount;
  forwardedAttrs.onVnodeBeforeUnmount = (vnode) => {
    originalBeforeUnmount?.(vnode);
    cleanupOnsPortalElement(vnode?.el);
  };
  return forwardedAttrs;
}

function getOnsModifierTokens(modifier) {
  return String(modifier || "")
    .split(/\s+/)
    .map((token) => token.trim())
    .filter(Boolean);
}

function hasOnsModifier(modifier, expected) {
  return getOnsModifierTokens(modifier).includes(expected);
}

function withOnsHostClass(attrs, className) {
  const forwardedAttrs = { ...(attrs || {}) };
  const existingClass = forwardedAttrs.class;
  if (!existingClass) {
    forwardedAttrs.class = className;
  } else if (typeof existingClass === "string") {
    forwardedAttrs.class = existingClass.split(/\s+/).includes(className)
      ? existingClass
      : `${existingClass} ${className}`;
  } else {
    forwardedAttrs.class = [existingClass, className];
  }
  return forwardedAttrs;
}

function getOnsPart(root, selector) {
  if (!root || !selector) {
    return null;
  }
  try {
    if (root.matches?.(selector)) {
      return root;
    }
  } catch (_error) {
    // noop
  }
  return root.querySelector?.(selector) || null;
}

function addOnsModifierClass(element, baseClass, modifier) {
  if (!element || !baseClass || !modifier) {
    return;
  }
  element.classList?.add?.(`${baseClass}--${modifier}`);
}

function syncOnsAlertDialogModifierClasses(element, modifier) {
  const alertDialog = getOnsElement(element, "ons-alert-dialog", ".alert-dialog", element);
  const modifierTokens = getOnsModifierTokens(modifier || alertDialog?.getAttribute?.("modifier"));
  if (!alertDialog || modifierTokens.length === 0) {
    return;
  }

  const currentModifier = alertDialog.getAttribute?.("modifier") || "";
  const currentTokens = getOnsModifierTokens(currentModifier);
  const nextTokens = [...currentTokens];
  modifierTokens.forEach((token) => {
    if (!nextTokens.includes(token)) {
      nextTokens.push(token);
    }
  });
  if (nextTokens.length !== currentTokens.length) {
    const nextModifier = nextTokens.join(" ");
    alertDialog.setAttribute?.("modifier", nextModifier);
  }

  const dialogPanel = getOnsPart(alertDialog, ".alert-dialog");
  const dialogContainer = getOnsPart(alertDialog, ".alert-dialog-container");
  const title = getOnsPart(alertDialog, ".alert-dialog-title");
  const content = getOnsPart(alertDialog, ".alert-dialog-content");
  const footer = getOnsPart(alertDialog, ".alert-dialog-footer");

  modifierTokens.forEach((token) => {
    addOnsModifierClass(dialogPanel, "alert-dialog", token);
    addOnsModifierClass(dialogContainer, "alert-dialog-container", token);
    addOnsModifierClass(title, "alert-dialog-title", token);
    addOnsModifierClass(content, "alert-dialog-content", token);
    addOnsModifierClass(footer, "alert-dialog-footer", token);
  });

  const buttonRoot = footer || alertDialog;
  Array.from(buttonRoot.querySelectorAll?.(".alert-dialog-button, ons-alert-dialog-button") || [])
    .forEach((button) => {
      button.classList?.add?.("alert-dialog-button");
      modifierTokens.forEach((token) => {
        addOnsModifierClass(button, "alert-dialog-button", token);
      });
      if (modifierTokens.includes("rowfooter")) {
        // Vue2 + vue-onsenui 2 の生成 DOM では rowfooter modifier がボタン側にも反映される。
        // Vue3 wrapper では内部生成タイミングによって欠落する場合があるため、既存のページ個別補正と同じ互換 class も補う。
        button.classList?.add?.("alert-dialog-button--rowfooter--rowfooter");
      }
    });
}

function scheduleOnsAlertDialogModifierSync(element, modifier) {
  const run = () => syncOnsAlertDialogModifierClasses(element, modifier);
  run();
  Promise.resolve().then(run);
  const ownerWindow = element?.ownerDocument?.defaultView || globalThis;
  ownerWindow?.requestAnimationFrame?.(run);
  setTimeout(run, 32);
}

function withOnsAlertDialogModifierBridge(attrs, vm = null) {
  const forwardedAttrs = withOnsPortalUnmountCleanup(
    normalizeOnsForwardedAttrs(attrs, "alertDialog", "ons-alert-dialog", ".alert-dialog", vm)
  );
  const originalMounted = forwardedAttrs.onVnodeMounted;
  const originalUpdated = forwardedAttrs.onVnodeUpdated;
  const syncModifier = (vnode) => {
    scheduleOnsAlertDialogModifierSync(vnode?.el, forwardedAttrs.modifier);
  };
  forwardedAttrs.onVnodeMounted = (vnode) => {
    originalMounted?.(vnode);
    syncModifier(vnode);
  };
  forwardedAttrs.onVnodeUpdated = (vnode) => {
    originalUpdated?.(vnode);
    syncModifier(vnode);
  };
  return forwardedAttrs;
}

function createOnsHostWrapper(name, RawComponent, roleName, tagName, legacySelector = "") {
  return {
    name,
    inheritAttrs: false,
    setup(_props, { attrs, slots }) {
      const instance = getCurrentInstance();
      return () => h(
        RawComponent,
        withOnsPortalUnmountCleanup(
          normalizeOnsForwardedAttrs(attrs, roleName, tagName, legacySelector, instance?.proxy)
        ),
        slots
      );
    }
  };
}

function installOnsInputEventBridge(host) {
  if (!host || host.__ntssOnsInputEventBridge) {
    return;
  }
  const input = host._input || host.querySelector?.("input, textarea, select");
  if (!input) {
    return;
  }
  host.__ntssOnsInputEventBridge = true;
  const syncValue = (eventType) => {
    try {
      host.value = input.value;
    } catch (_error) {
      // noop
    }
    host.dispatchEvent(new Event(eventType, { bubbles: true }));
  };
  input.addEventListener("input", () => syncValue("input"));
  input.addEventListener("change", () => syncValue("change"));
}

function withOnsInputEventBridge(attrs) {
  const forwardedAttrs = normalizeOnsInputAttrs(attrs);
  const originalMounted = forwardedAttrs.onVnodeMounted;
  const originalUpdated = forwardedAttrs.onVnodeUpdated;
  forwardedAttrs.onVnodeMounted = (vnode) => {
    originalMounted?.(vnode);
    installOnsInputEventBridge(vnode.el);
  };
  forwardedAttrs.onVnodeUpdated = (vnode) => {
    originalUpdated?.(vnode);
    installOnsInputEventBridge(vnode.el);
  };
  return forwardedAttrs;
}

function withOnsHostValueAttr(attrs) {
  const forwardedAttrs = normalizeOnsInputAttrs(attrs);
  const originalMounted = forwardedAttrs.onVnodeMounted;
  const originalUpdated = forwardedAttrs.onVnodeUpdated;
  const syncValueAttr = (vnode) => {
    const value = forwardedAttrs.value;
    if (value !== undefined && value !== null) {
      vnode.el?.setAttribute?.("value", String(value));
    }
  };
  forwardedAttrs.onVnodeMounted = (vnode) => {
    originalMounted?.(vnode);
    syncValueAttr(vnode);
  };
  forwardedAttrs.onVnodeUpdated = (vnode) => {
    originalUpdated?.(vnode);
    syncValueAttr(vnode);
  };
  return forwardedAttrs;
}

function hasOwnAttr(attrs, key) {
  return Object.prototype.hasOwnProperty.call(attrs || {}, key);
}

function toOnsBoolean(value) {
  if (value === false || value === null || value === undefined) {
    return false;
  }
  if (typeof value === "string") {
    return value !== "false";
  }
  return Boolean(value);
}

function getOnsControlInput(host) {
  return host?._input || host?.querySelector?.("input[type='checkbox'], input[type='radio'], input") || null;
}

function getOnsControlChecked(host, fallback = false) {
  const input = getOnsControlInput(host);
  if (input && typeof input.checked === "boolean") {
    return input.checked;
  }
  if (typeof host?.checked === "boolean") {
    return host.checked;
  }
  return fallback;
}

function setOnsControlChecked(host, checked) {
  if (!host) {
    return;
  }
  const nextChecked = Boolean(checked);
  const input = getOnsControlInput(host);
  try {
    host.checked = nextChecked;
  } catch (_error) {
    // noop
  }
  try {
    if (input) {
      input.checked = nextChecked;
    }
  } catch (_error) {
    // noop
  }
  host.__ntssOnsCheckedControlCurrent = nextChecked;
  if (nextChecked) {
    host.setAttribute?.("checked", "");
    input?.setAttribute?.("checked", "");
  } else {
    host.removeAttribute?.("checked");
    input?.removeAttribute?.("checked");
  }
}

function setOnsControlDisabled(host, disabled) {
  if (!host) {
    return;
  }
  const nextDisabled = Boolean(disabled);
  const input = getOnsControlInput(host);
  try {
    host.disabled = nextDisabled;
  } catch (_error) {
    // noop
  }
  try {
    if (input) {
      input.disabled = nextDisabled;
    }
  } catch (_error) {
    // noop
  }
  if (nextDisabled) {
    host.setAttribute?.("disabled", "");
    input?.setAttribute?.("disabled", "");
  } else {
    host.removeAttribute?.("disabled");
    input?.removeAttribute?.("disabled");
  }
}

function syncOnsCheckedControlState(host, attrs) {
  if (!host || !attrs) {
    return;
  }
  if (hasOwnAttr(attrs, "checked")) {
    setOnsControlChecked(host, toOnsBoolean(attrs.checked));
  }
  if (hasOwnAttr(attrs, "disabled")) {
    setOnsControlDisabled(host, toOnsBoolean(attrs.disabled));
  }
}

function callOnsLegacyHandler(handler, event) {
  if (Array.isArray(handler)) {
    handler.forEach((entry) => callOnsLegacyHandler(entry, event));
    return;
  }
  if (typeof handler === "function") {
    handler(event);
  }
}

function createOnsLegacyControlEvent(event, currentTarget) {
  const legacyEvent = Object.create(event || null);
  Object.defineProperty(legacyEvent, "target", {
    configurable: true,
    enumerable: true,
    get: () => event?.target || currentTarget
  });
  Object.defineProperty(legacyEvent, "currentTarget", {
    configurable: true,
    enumerable: true,
    get: () => currentTarget
  });
  Object.defineProperty(legacyEvent, "defaultPrevented", {
    configurable: true,
    enumerable: true,
    get: () => Boolean(event?.defaultPrevented)
  });
  legacyEvent.preventDefault = () => event?.preventDefault?.();
  legacyEvent.stopPropagation = () => event?.stopPropagation?.();
  return legacyEvent;
}

function dispatchOnsLegacyCheckedControlEvent(host, eventName, event, forceToggle = false) {
  if (!host || event?.__ntssOnsCheckedControlHandled) {
    return;
  }
  if (event) {
    event.__ntssOnsCheckedControlHandled = true;
  }

  const attrs = host.__ntssOnsCheckedControlAttrs || {};
  const handlers = host.__ntssOnsCheckedControlHandlers || {};
  const handler = handlers[eventName];
  if (!handler) {
    return;
  }

  const currentChecked = typeof host.__ntssOnsCheckedControlCurrent === "boolean"
    ? host.__ntssOnsCheckedControlCurrent
    : hasOwnAttr(attrs, "checked")
      ? toOnsBoolean(attrs.checked)
      : getOnsControlChecked(host, false);
  const nextChecked = forceToggle ? !currentChecked : getOnsControlChecked(host, currentChecked);
  setOnsControlChecked(host, nextChecked);

  const legacyEvent = createOnsLegacyControlEvent(event, host);
  callOnsLegacyHandler(handler, legacyEvent);

  if (legacyEvent.defaultPrevented || event?.defaultPrevented) {
    syncOnsCheckedControlState(host, attrs);
  }
}

function installOnsCheckedControlEventBridge(host) {
  if (!host || host.__ntssOnsCheckedControlEventBridge) {
    return;
  }
  host.__ntssOnsCheckedControlEventBridge = true;

  host.addEventListener("click", (event) => {
    dispatchOnsLegacyCheckedControlEvent(host, "click", event, true);
  });

  const installInputListeners = () => {
    const input = getOnsControlInput(host);
    if (!input || input.__ntssOnsCheckedControlEventBridge) {
      return;
    }
    input.__ntssOnsCheckedControlEventBridge = true;
    input.addEventListener("change", (event) => {
      dispatchOnsLegacyCheckedControlEvent(host, "change", event, false);
    });
    input.addEventListener("input", (event) => {
      dispatchOnsLegacyCheckedControlEvent(host, "input", event, false);
    });
  };

  installInputListeners();
  Promise.resolve().then(installInputListeners);
  const ownerWindow = host.ownerDocument?.defaultView || globalThis;
  ownerWindow?.requestAnimationFrame?.(installInputListeners);
}

function withOnsCheckedControlCompatAttrs(attrs) {
  const forwardedAttrs = withOnsHostValueAttr(attrs);
  const originalMounted = forwardedAttrs.onVnodeMounted;
  const originalUpdated = forwardedAttrs.onVnodeUpdated;
  const legacyHandlers = {
    click: forwardedAttrs.onClick,
    change: forwardedAttrs.onChange,
    input: forwardedAttrs.onInput
  };
  delete forwardedAttrs.onClick;
  delete forwardedAttrs.onChange;
  delete forwardedAttrs.onInput;

  const syncCompat = (vnode) => {
    const host = vnode?.el;
    if (!host) {
      return;
    }
    host.__ntssOnsCheckedControlAttrs = forwardedAttrs;
    host.__ntssOnsCheckedControlHandlers = legacyHandlers;
    syncOnsCheckedControlState(host, forwardedAttrs);
    installOnsCheckedControlEventBridge(host);

    Promise.resolve().then(() => {
      host.__ntssOnsCheckedControlAttrs = forwardedAttrs;
      host.__ntssOnsCheckedControlHandlers = legacyHandlers;
      syncOnsCheckedControlState(host, forwardedAttrs);
      installOnsCheckedControlEventBridge(host);
    });
  };

  forwardedAttrs.onVnodeMounted = (vnode) => {
    originalMounted?.(vnode);
    syncCompat(vnode);
  };
  forwardedAttrs.onVnodeUpdated = (vnode) => {
    originalUpdated?.(vnode);
    syncCompat(vnode);
  };
  return forwardedAttrs;
}

const VOnsActionSheet = createOnsHostWrapper(
  "VOnsActionSheet",
  RawVOnsActionSheet,
  "actionSheet",
  "ons-action-sheet",
  ".action-sheet"
);

const VOnsBottomToolbar = {
  name: "VOnsBottomToolbar",
  inheritAttrs: false,
  setup(_props, { attrs, slots }) {
    return () => h(RawVOnsBottomToolbar, withOnsHostClass(attrs, "bottom-bar"), slots);
  }
};

const VOnsAlertDialog = {
  name: "VOnsAlertDialog",
  inheritAttrs: false,
  setup(_props, { attrs, slots }) {
    const instance = getCurrentInstance();
    return () => h(
      RawVOnsAlertDialog,
      withOnsAlertDialogModifierBridge(attrs, instance?.proxy),
      slots
    );
  }
};

const VOnsDialog = createOnsHostWrapper(
  "VOnsDialog",
  RawVOnsDialog,
  "dialog",
  "ons-dialog",
  ".dialog"
);

const VOnsModal = createOnsHostWrapper(
  "VOnsModal",
  RawVOnsModal,
  "modal",
  "ons-modal",
  ".modal"
);

const VOnsSpeedDial = createOnsHostWrapper(
  "VOnsSpeedDial",
  RawVOnsSpeedDial,
  "speedDial",
  "ons-speed-dial",
  ".speed-dial"
);

const VOnsButton = {
  name: "VOnsButton",
  inheritAttrs: false,
  setup(_props, { attrs, slots }) {
    const instance = getCurrentInstance();
    return () => {
      const forwardedAttrs = normalizeOnsForwardedAttrs(
        attrs,
        "button",
        "ons-button",
        ".button",
        instance?.proxy
      );

      const existingClass = forwardedAttrs.class;
      if (existingClass === undefined || existingClass === null) {
        forwardedAttrs.class = "button";
      } else if (Array.isArray(existingClass)) {
        if (!existingClass.includes("button")) existingClass.push("button");
      } else if (typeof existingClass === "string") {
        forwardedAttrs.class = [existingClass, "button"];
      } else if (typeof existingClass === "object") {
        forwardedAttrs.class = { ...existingClass, button: true };
      } else {
        forwardedAttrs.class = [existingClass, "button"];
      }

      return h(RawVOnsButton, withOnsPortalUnmountCleanup(forwardedAttrs), slots);
    };
  }
};

const VOnsPopover = {
  name: "VOnsPopover",
  inheritAttrs: false,
  setup(_props, { attrs, slots }) {
    const instance = getCurrentInstance();
    return () => {
      const forwardedAttrs = normalizeOnsForwardedAttrs(
        attrs,
        "popover",
        "ons-popover",
        ".popover",
        instance?.proxy
      );
      const coverTarget = Object.prototype.hasOwnProperty.call(forwardedAttrs, "cover-target")
        ? forwardedAttrs["cover-target"]
        : forwardedAttrs.coverTarget;
      const originalMounted = forwardedAttrs.onVnodeMounted;
      const originalUpdated = forwardedAttrs.onVnodeUpdated;
      const originalBeforeUnmount = forwardedAttrs.onVnodeBeforeUnmount;
      const syncLegacyCoverTarget = (vnode) => {
        if (coverTarget === true || coverTarget === "true") {
          vnode.el?.setAttribute?.("cover-target", "true");
        } else if (coverTarget === false || coverTarget === "false") {
          vnode.el?.removeAttribute?.("cover-target");
        }
      };
      if (Object.prototype.hasOwnProperty.call(forwardedAttrs, "target")) {
        const resolvedTarget = resolveOnsPopoverTargetElement(forwardedAttrs.target, instance?.proxy);
        if (resolvedTarget) {
          forwardedAttrs.target = resolvedTarget;
        }
      }
      if (coverTarget === false || coverTarget === "false") {
        delete forwardedAttrs["cover-target"];
        delete forwardedAttrs.coverTarget;
      } else if (coverTarget === true || coverTarget === "true") {
        forwardedAttrs["cover-target"] = "true";
        delete forwardedAttrs.coverTarget;
      }
      forwardedAttrs.onVnodeMounted = (vnode) => {
        originalMounted?.(vnode);
        syncLegacyCoverTarget(vnode);
        syncOnsNativeLifecycleBridge(vnode?.el, forwardedAttrs);
      };
      forwardedAttrs.onVnodeUpdated = (vnode) => {
        originalUpdated?.(vnode);
        syncLegacyCoverTarget(vnode);
        syncOnsNativeLifecycleBridge(vnode?.el, forwardedAttrs);
      };
      forwardedAttrs.onVnodeBeforeUnmount = (vnode) => {
        removeOnsNativeLifecycleBridge(vnode?.el);
        originalBeforeUnmount?.(vnode);
      };
      return h(RawVOnsPopover, withOnsPortalUnmountCleanup(forwardedAttrs), slots);
    };
  }
};

const VOnsListItem = {
  name: "VOnsListItem",
  inheritAttrs: false,
  setup(_props, { attrs, slots }) {
    return () => {
      const {
        expanded,
        onVnodeMounted: originalMounted,
        onVnodeUpdated: originalUpdated,
        ...forwardedAttrs
      } = attrs;
      const syncExpanded = (vnode) => {
        if (expanded === undefined) return;
        const nextExpanded = expanded === true || expanded === "true";
        const element = vnode?.el;
        if (!element || element.expanded === nextExpanded) return;
        element.expanded = nextExpanded;
      };
      forwardedAttrs.onVnodeMounted = (vnode) => {
        originalMounted?.(vnode);
        syncExpanded(vnode);
      };
      forwardedAttrs.onVnodeUpdated = (vnode) => {
        originalUpdated?.(vnode);
        syncExpanded(vnode);
      };
      return h(RawVOnsListItem, forwardedAttrs, slots);
    };
  }
};

const VOnsInput = {
  name: "VOnsInput",
  inheritAttrs: false,
  setup(_props, { attrs, slots }) {
    return () => h(RawVOnsInput, withOnsInputEventBridge(attrs), slots);
  }
};

const VOnsSearchInput = {
  name: "VOnsSearchInput",
  inheritAttrs: false,
  setup(_props, { attrs, slots }) {
    return () => h(RawVOnsSearchInput, withOnsInputEventBridge(attrs), slots);
  }
};

const VOnsCheckbox = {
  name: "VOnsCheckbox",
  inheritAttrs: false,
  setup(_props, { attrs, slots }) {
    return () => {
      const forwardedAttrs = withOnsCheckedControlCompatAttrs(attrs);
      // Vue2 の v-ons-checkbox では type="checkbox" が実質不要だったが、
      // Vue3 では ons-checkbox の読み取り専用 type property に patch されるため除外する。
      delete forwardedAttrs.type;
      return h(RawVOnsCheckbox, forwardedAttrs, slots);
    };
  }
};

const VOnsRadio = {
  name: "VOnsRadio",
  inheritAttrs: false,
  setup(_props, { attrs, slots }) {
    return () => {
      const forwardedAttrs = withOnsHostValueAttr(attrs);
      delete forwardedAttrs.type;
      return h(RawVOnsRadio, forwardedAttrs, slots);
    };
  }
};

const VOnsSelect = {
  name: "VOnsSelect",
  inheritAttrs: false,
  props: {
    inputId: {
      type: String,
      default: undefined
    },
    selectId: {
      type: String,
      default: undefined
    }
  },
  setup(props, { attrs, slots }) {
    return () => {
      const forwardedAttrs = normalizeOnsInputAttrs(attrs);
      const resolvedInputId = props.inputId ?? props.selectId;
      if (resolvedInputId !== undefined) {
        // Vue2 の v-ons-select select-id を Onsen の input-id DOM 属性に橋渡しする。
        forwardedAttrs["input-id"] = resolvedInputId;
      }
      return h(RawVOnsSelect, forwardedAttrs, slots);
    };
  }
};

const VOnsSwitch = {
  name: "VOnsSwitch",
  inheritAttrs: false,
  setup(_props, { attrs, slots }) {
    return () => h(RawVOnsSwitch, normalizeOnsInputAttrs(attrs), slots);
  }
};

const MainContent = {
  name: "MainContent",
  inheritAttrs: false,
  setup(_props, { attrs, slots }) {
    return () => h("main-content", { class: "main-content", ...attrs }, slots.default ? slots.default() : []);
  }
};

const components = [
  VOnsActionSheet,
  VOnsActionSheetButton,
  VOnsAlertDialog,
  VOnsAlertDialogButton,
  VOnsBackButton,
  VOnsBottomToolbar,
  VOnsButton,
  VOnsCard,
  VOnsCarousel,
  VOnsCarouselItem,
  VOnsCheckbox,
  VOnsCol,
  VOnsDialog,
  VOnsFab,
  VOnsIcon,
  VOnsInput,
  VOnsLazyRepeat,
  VOnsList,
  VOnsListHeader,
  VOnsListItem,
  VOnsListTitle,
  VOnsModal,
  VOnsNavigator,
  VOnsPage,
  VOnsPopover,
  VOnsProgressBar,
  VOnsProgressCircular,
  VOnsPullHook,
  VOnsRadio,
  VOnsRange,
  VOnsRipple,
  VOnsRow,
  VOnsSearchInput,
  VOnsSegment,
  VOnsSelect,
  VOnsSpeedDial,
  VOnsSpeedDialItem,
  VOnsSplitter,
  VOnsSplitterContent,
  VOnsSplitterMask,
  VOnsSplitterSide,
  VOnsSwitch,
  VOnsTab,
  VOnsTabbar,
  VOnsToast,
  VOnsToolbar,
  VOnsToolbarButton
].filter(Boolean);

const VueOnsenBridge = {
  install(app) {
    app.use(VueOnsen);
    app.config.globalProperties.$ons = createOnsCompat(app.config.globalProperties.$ons);

    components.forEach((component) => {
      if (component?.name) {
        app.component(component.name, component);
      }
    });
    app.component("v-ons-popover", VOnsPopover);

    app.component("main-content", MainContent);
  }
};

export default VueOnsenBridge;

export {
  MainContent,
  normalizeOnsInputAttrs,
  VOnsActionSheet,
  VOnsActionSheetButton,
  VOnsAlertDialog,
  VOnsAlertDialogButton,
  VOnsBackButton,
  VOnsBottomToolbar,
  VOnsButton,
  VOnsCard,
  VOnsCarousel,
  VOnsCarouselItem,
  VOnsCheckbox,
  VOnsCol,
  VOnsDialog,
  VOnsFab,
  VOnsIcon,
  VOnsInput,
  VOnsLazyRepeat,
  VOnsList,
  VOnsListHeader,
  VOnsListItem,
  VOnsListTitle,
  VOnsModal,
  VOnsNavigator,
  VOnsPage,
  VOnsPopover,
  VOnsProgressBar,
  VOnsProgressCircular,
  VOnsPullHook,
  VOnsRadio,
  VOnsRange,
  VOnsRipple,
  VOnsRow,
  VOnsSearchInput,
  VOnsSegment,
  VOnsSelect,
  VOnsSpeedDial,
  VOnsSpeedDialItem,
  VOnsSplitter,
  VOnsSplitterContent,
  VOnsSplitterMask,
  VOnsSplitterSide,
  VOnsSwitch,
  VOnsTab,
  VOnsTabbar,
  VOnsToast,
  VOnsToolbar,
  VOnsToolbarButton
};
