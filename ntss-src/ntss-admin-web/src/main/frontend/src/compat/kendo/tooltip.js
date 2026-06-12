import $ from "@/compat/jquery";
import { getJQueryKendo } from "@/compat/kendo/kendo-jquery.js";
import {
  createCompatPopupEvent,
  resolvePopupLayer,
  resolvePopupOwnerDocument,
  resolvePopupTarget,
  syncPopupLayerOwnerScope,
  wrapCompatPopupHandler,
} from "@/compat/popup/host";
import { queryElementBySelectors, resolveHostElement } from "@/compat/dom/host";

const tooltipAdapters = new WeakMap();

function queryTooltipElement(root) {
  const scopeRoot = resolveHostElement(root) || root?.[0] || root;
  if (!scopeRoot) {
    return null;
  }
  return queryElementBySelectors([
    ".k-animation-container .k-tooltip",
    ".k-tooltip",
    ".tooltip",
  ], scopeRoot, {
    includeSelf: true,
    includeBody: true,
    includeOwnerDocument: true,
  });
}

function resolveTooltipElement(widget, event, root = null) {
  const popupElement = event?.sender?.popup?.element?.[0]
    || widget?.popup?.element?.[0]
    || resolvePopupLayer(event, root)
    || null;
  const tooltip = popupElement?.querySelector?.(".k-tooltip")
    || queryTooltipElement(popupElement || root || event?.target)
    || null;
  syncPopupLayerOwnerScope(tooltip || popupElement, event?.target || root || widget?.element, {
    className: "ntss-kendo-popup-hosted",
    kind: "kendo-tooltip",
  });
  tooltip?.classList?.add?.("ntss-kendo-tooltip-legacy");
  return tooltip;
}

function createTooltipEvent(widget, event, root = null) {
  const target = resolvePopupTarget(event, root);
  const tooltip = resolveTooltipElement(widget, event, target || root);
  return createCompatPopupEvent(event, {
    target,
    layer: tooltip || resolvePopupLayer(event, root),
    tooltip,
    popup: widget?.popup || event?.popup || null,
  });
}

function createTooltipAdapter(widget, root) {
  if (!widget) {
    return null;
  }
  const cached = tooltipAdapters.get(widget);
  if (cached) {
    return cached;
  }

  const adapter = {
    get element() {
      return root?.jquery ? root : $(root);
    },
    get wrapper() {
      const tooltip = resolveTooltipElement(widget, null, root);
      return tooltip ? $(tooltip) : this.element;
    },
    get popup() {
      const tooltip = resolveTooltipElement(widget, null, root);
      return {
        element: tooltip ? $(tooltip) : $(),
        wrapper: tooltip ? $(tooltip).closest(".k-animation-container, .k-popup, .tooltip") : $(),
      };
    },
    bind(name, handler) {
      if ((name === "show" || name === "hide") && typeof handler === "function") {
        return widget.bind?.(name, (event) => handler.call(widget, createTooltipEvent(widget, event, root)));
      }
      return widget.bind?.(name, handler);
    },
    one(name, handler) {
      if ((name === "show" || name === "hide") && typeof handler === "function") {
        return widget.one?.(name, (event) => handler.call(widget, createTooltipEvent(widget, event, root)));
      }
      return widget.one?.(name, handler);
    },
    show(target) {
      return widget.show?.(resolvePopupTarget(target, root) || target);
    },
    hide() {
      return widget.hide?.();
    },
    refresh() {
      return widget.refresh?.();
    },
    destroy() {
      widget.destroy?.();
    },
    rawWidget() {
      return widget;
    }
  };

  tooltipAdapters.set(widget, adapter);
  return adapter;
}

export function attachTooltip(root, options = {}) {
  if (!root) {
    return null;
  }

  const kendo = getJQueryKendo();
  if (!kendo?.ui?.Tooltip) {
    return null;
  }

  const $root = root?.jquery ? root : $(root);
  const current = $root.data("kendoTooltip");
  if (current?.destroy) {
    current.destroy();
    $root.removeData("kendoTooltip");
  }

  const normalizedOptions = {
    ...options,
    content: typeof options.content === "function"
      ? (event) => options.content(createTooltipEvent(null, event, root))
      : options.content,
    show: wrapCompatPopupHandler(options.show, { host: root }),
    hide: wrapCompatPopupHandler(options.hide, { host: root }),
  };

  $root.kendoTooltip(normalizedOptions);
  const widget = $root.data("kendoTooltip") || null;
  syncPopupLayerOwnerScope(widget?.popup?.wrapper?.[0] || widget?.popup?.element?.[0], root, {
    className: "ntss-kendo-popup-hosted",
    kind: "kendo-tooltip",
  });
  const adapter = createTooltipAdapter(widget, $root);
  if (adapter && widget) {
    widget.ownerDocument = resolvePopupOwnerDocument(root);
  }
  return adapter;
}
