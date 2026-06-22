<template>
  <div ref="root" v-bind="$attrs">
    <slot />
  </div>
</template>

<script>
import $ from "@/compat/jquery";
import { ensureJQueryKendo } from "@/compat/kendo/kendo-jquery.js";
import { createLegacyKendoEvent, updateLegacySenderState } from "@/compat/kendo/legacy-sender.js";

const patchedWidgets = new WeakSet();
function debugTabStrip() {}

function getTabItems($root) {
  if (!$root?.length) {
    return $();
  }
  const directItems = $root.children("ul").children("li");
  const wrappedItems = $root.children(".k-tabstrip-items-wrapper").children("ul").children("li");
  return directItems.add(wrappedItems);
}

function getContentPanels($root) {
  if (!$root?.length) {
    return $();
  }
  const directPanels = $root.children("div")
    .not(".k-tabstrip-items-wrapper")
    .not(".k-tabstrip-wrapper")
    .not(".k-tabstrip-content-wrapper");
  const wrappedPanels = $root.children(".k-tabstrip-content-wrapper").children("div");
  return directPanels.add(wrappedPanels);
}

function resolveInitialTabIndex(root) {
  if (!root) {
    return 0;
  }
  const $root = $(root);
  const $tabs = getTabItems($root);
  if (!$tabs.length) {
    return 0;
  }
  const activeIndex = $tabs.toArray().findIndex((tab) => {
    if (!tab) {
      return false;
    }
    return tab.classList.contains("k-active")
      || tab.classList.contains("k-state-active")
      || tab.getAttribute("aria-selected") === "true";
  });
  return activeIndex >= 0 ? activeIndex : 0;
}

function syncLegacyStructuralClasses(root) {
  if (!root) {
    return;
  }
  const $root = $(root);
  // Vue2 の kendo-tabstrip は k-widget/k-header/k-floatwrap と k-content/k-item を前提に画面側CSSが組まれている。
  // Kendo 2026 の構造差は残し、画面側 CSS が参照する旧クラスだけを薄く補う。
  $root.addClass("k-widget k-header k-floatwrap k-tabstrip-wrapper ntss-kendo-tabstrip-legacy");
  $root.children("ul").addClass("k-reset k-tabstrip-items");
  $root.children(".k-tabstrip-items-wrapper").addClass("k-tabstrip-items-wrapper");
  $root.children(".k-tabstrip-items-wrapper").children("ul").addClass("k-reset k-tabstrip-items");
  $root.children(".k-tabstrip-content-wrapper").addClass("k-tabstrip-content-wrapper");
  const $items = getTabItems($root);
  $items.addClass("k-item k-tabstrip-item ntss-kendo-tabstrip-item-legacy");
  $items.children("a, span, button, .k-link").addClass("k-link ntss-kendo-tabstrip-link-legacy");
  $items.find("button, [role='button']").addClass("k-button k-button-icontext ntss-kendo-tabstrip-button-legacy");
  $items.find(".k-icon, .k-svg-icon, svg").addClass("ntss-kendo-tabstrip-icon-legacy");
  getContentPanels($root).addClass("k-content k-tabstrip-content");
}

function syncLegacyActiveClasses(root) {
  if (!root) {
    return;
  }
  syncLegacyStructuralClasses(root);
  const $root = $(root);
  const $tabs = getTabItems($root);
  const $contents = getContentPanels($root);
  const $activeTabs = $tabs.filter(".k-active, .k-selected, [aria-selected='true']");

  // Vue2 Kendo TabStrip では選択タブだけが k-state-active を持つ。
  // Vue3/Kendo 2026 のラッパー構造では初期テンプレート由来の k-state-active が残るため、旧 active 契約を毎回同期する。
  $tabs.removeClass("k-state-active");
  if ($activeTabs.length) {
    $activeTabs.addClass("k-state-active");
  }
  //Vue3 新版Kendo此段代码将状态又再次进行手动覆盖，在错误时间干预了状态的修改，导致内部状态错乱 start
  //Vue3 新版Kendoでは、このコードセグメントで状態が再度手動で上書きされ、タイミングを誤って状態変更を介入したため、内部状態が混乱した
  // $contents.removeClass("k-state-active");
  // const $activeContents = $contents.filter(".k-active, [aria-hidden='false']");
  // if ($activeContents.length) {
  //   $activeContents.addClass("k-state-active");
  //   return;
  // }
  //Vue3 新版Kendo此段代码将状态又再次进行手动覆盖，在错误时间干预了状态的修改，导致内部状态错乱 end

  const activeIndex = $activeTabs.length ? $tabs.index($activeTabs.first()) : -1;
  if (activeIndex >= 0 && activeIndex < $contents.length) {
    $contents.eq(activeIndex).addClass("k-state-active");
  }
}

function applyLegacyInitialHints(root, index) {
  if (!root) {
    return;
  }
  const safeIndex = Number.isInteger(index) && index >= 0 ? index : 0;
  const $root = $(root);
  const $tabs = getTabItems($root);
  if ($tabs.length) {
    $tabs.removeClass("k-active k-state-active");
    $tabs.eq(safeIndex).addClass("k-state-active");
  }
  const $contents = getContentPanels($root);
  if ($contents.length) {
    $contents.removeClass("k-active k-state-active");
    $contents.eq(safeIndex).addClass("k-state-active");
  }
}

function ensureInitialSelection(widget, initialIndex = 0) {
  if (!widget || typeof widget.select !== "function") {
    return;
  }
  const selected = widget.select();
  if (!selected?.length) {
    const target = resolveTabTarget(widget, initialIndex);
    if (target?.length) {
      widget.select(target);
    }
  }
}

function resolveTabTarget(widget, target) {
  if (!widget) return null;
  if (typeof target === "number") {
    const item = widget.tabGroup?.children?.().eq(target >= 0 ? target : 0);
    return item?.length ? item : null;
  }
  if (target?.jquery) return target.length ? target : null;
  if (target?.$el) return $(target.$el);
  if (target instanceof Element) return $(target);
  return target ? $(target) : null;
}

function resolveTabIndex(widget, target) {
  const $tabs = widget?.tabGroup?.children?.();
  if (!$tabs?.length) {
    return -1;
  }
  if (typeof target === "number") {
    return target >= 0 ? target : 0;
  }
  const resolved = resolveTabTarget(widget, target);
  if (resolved?.length) {
    return $tabs.index(resolved.first());
  }
  return -1;
}

function createLegacyTabStripEvent(rawEvent, widget, root, type) {
  const safeRoot = root || widget?.element?.[0] || widget?.wrapper?.[0] || null;
  const $root = safeRoot ? $(safeRoot) : (widget?.element || widget?.wrapper || $());
  const $tabs = widget?.tabGroup?.children?.() || getTabItems($root);
  const rawItem = rawEvent?.item || rawEvent?.target || null;
  const $item = rawItem ? $(rawItem) : (rawEvent?.itemIndex !== undefined ? $tabs.eq(rawEvent.itemIndex) : widget?.select?.());
  const item = $item?.[0] || rawItem || null;
  const itemIndex = $item?.length ? $tabs.index($item.first()) : resolveTabIndex(widget, rawEvent?.itemIndex);
  const contentElement = itemIndex >= 0 ? widget?.contentElement?.(itemIndex) : undefined;
  updateLegacySenderState(widget, {
    selectedIndex: itemIndex,
    element: widget?.element || $root,
    wrapper: widget?.wrapper || $root
  });
  return createLegacyKendoEvent(rawEvent, widget, {
    type,
    item,
    target: item,
    itemIndex,
    index: itemIndex,
    contentElement,
    content: contentElement
  });
}

function createPendingWidgetProxy(root) {
  const pendingOps = [];
  const pendingCallbacks = [];
  const proxy = {
    __isPendingKendoTabStripProxy: true,
    element: root ? $(root) : $(),
    wrapper: root ? $(root) : $(),
    tabGroup: root ? getTabItems($(root)).parent() : $(),
    _resolve(widget) {
      if (!widget) {
        return;
      }
      const ops = pendingOps.splice(0);
      ops.forEach((op) => {
        try {
          op(widget);
        } catch (e) {
          setTimeout(() => { throw e; }, 0);
        }
      });
      const callbacks = pendingCallbacks.splice(0);
      callbacks.forEach((callback) => {
        try {
          callback(widget);
        } catch (e) {
          setTimeout(() => { throw e; }, 0);
        }
      });
    },
    _clear() {
      pendingOps.splice(0);
      pendingCallbacks.splice(0);
    },
    _queue(op) {
      pendingOps.push(op);
      return proxy;
    },
    whenReady(callback) {
      if (typeof callback === "function") {
        pendingCallbacks.push(callback);
      }
      return proxy;
    },
    activateTab(target) {
      return proxy._queue((widget) => widget.activateTab(target));
    },
    enable(target, enabled = true) {
      return proxy._queue((widget) => widget.enable(target, enabled));
    },
    disable(target) {
      return proxy._queue((widget) => widget.disable(target));
    },
    select(target) {
      if (arguments.length === 0) {
        return $();
      }
      return proxy._queue((widget) => widget.select(target));
    },
    contentElement() {
      return undefined;
    },
    contentHolder() {
      return $();
    },
    destroy() {
      proxy._clear();
    }
  };
  return proxy;
}

function patchWidgetCompatMethods(widget) {
  if (!widget || patchedWidgets.has(widget)) return widget;
  const rawActivateTab = typeof widget.activateTab === "function" ? widget.activateTab.bind(widget) : null;
  const rawEnable = typeof widget.enable === "function" ? widget.enable.bind(widget) : null;
  const rawDisable = typeof widget.disable === "function" ? widget.disable.bind(widget) : null;
  const rawSelect = typeof widget.select === "function" ? widget.select.bind(widget) : null;
  updateLegacySenderState(widget, {
    element: widget.element,
    wrapper: widget.wrapper || widget.element,
    selectedIndex: resolveTabIndex(widget, widget.select?.())
  });
  widget.contentElement = (itemIndex) => {
    const numericIndex = resolveTabIndex(widget, itemIndex);
    if (!Number.isFinite(numericIndex) || numericIndex < 0) {
      return undefined;
    }
    const id = widget.tabGroup?.children?.().eq(numericIndex)?.attr?.("aria-controls");
    const root = widget.element?.[0] || widget.wrapper?.[0] || null;
    const panels = getContentPanels($(root));
    if (id) {
      const matched = panels.toArray().find((panel) => panel?.id === id || panel?.closest?.(".k-content, .k-tabstrip-content")?.id === id);
      if (matched) {
        return matched;
      }
    }
    return panels.get?.(numericIndex);
  };
  widget.contentHolder = (itemIndex) => {
    const contentElement = $(widget.contentElement(itemIndex));
    const scrollContainer = contentElement.children(".km-scroll-container");
    return scrollContainer[0] ? scrollContainer : contentElement;
  };
  widget.activateTab = (target) => {
    const resolved = resolveTabTarget(widget, target);
    if (resolved?.length && rawActivateTab) rawActivateTab(resolved);
    else if (typeof target === "number" && rawSelect) {
      const selected = resolveTabTarget(widget, target);
      if (selected?.length) rawSelect(selected);
    }
    syncLegacyActiveClasses(widget.element?.[0] || widget.wrapper?.[0] || null);
    return widget;
  };
  widget.enable = (target, enabled = true) => {
    const resolved = resolveTabTarget(widget, target);
    if (resolved?.length) {
      if (rawEnable) rawEnable(resolved, enabled);
      else if (rawDisable && enabled === false) rawDisable(resolved);
    }
    return widget;
  };
  widget.disable = (target) => {
    const resolved = resolveTabTarget(widget, target);
    if (resolved?.length && rawDisable) rawDisable(resolved);
    return widget;
  };
  widget.select = function(target) {
    if (arguments.length === 0) return rawSelect ? rawSelect() : null;
    const resolved = resolveTabTarget(widget, target);
    if (resolved?.length && rawSelect) rawSelect(resolved);
    syncLegacyActiveClasses(widget.element?.[0] || widget.wrapper?.[0] || null);
    return widget;
  };
  patchedWidgets.add(widget);
  return widget;
}

export default {
  name: "KendoTabStrip",
  inheritAttrs: false,
  emits: ["select", "activate"],
  props: {
    activate: { type: Function, default: null },
    scrollable: { type: [Boolean, Object], default: false }
  },
  data() { return { widget: null, pendingWidget: null }; },
  mounted() {
    this.pendingWidget = createPendingWidgetProxy(this.$refs.root);
    this.$nextTick(() => { this.createWidget(); });
  },
  beforeUnmount() { this.destroyWidget(); },
  methods: {
    destroyWidget() {
      if (this.pendingWidget?._clear) this.pendingWidget._clear();
      if (this.widget?.destroy) this.widget.destroy();
      debugTabStrip("destroyWidget", { hasWidget: !!this.widget });
      this.widget = null;
      this.pendingWidget = null;
    },
    async createWidget() {
      debugTabStrip("createWidget:start", {
        hasRoot: !!this.$refs.root,
        scrollable: this.scrollable
      });
      await ensureJQueryKendo();
      const root = this.$refs.root;
      if (!root) return;
      const $root = $(root);
      const initialTabIndex = resolveInitialTabIndex(root);
      debugTabStrip("createWidget:resolvedInitialTabIndex", {
        initialTabIndex,
        tabCount: getTabItems($root).length
      });
      syncLegacyStructuralClasses(root);
      applyLegacyInitialHints(root, initialTabIndex);
      const current = $root.data("kendoTabStrip");
      if (current?.destroy) current.destroy();
      $root.kendoTabStrip({
        scrollable: this.scrollable,
        select: (e) => {
          syncLegacyActiveClasses(root);
          const compatEvent = createLegacyTabStripEvent(e, this.widget || $root.data("kendoTabStrip"), root, "select");
          debugTabStrip("event:select", {
            itemIndex: compatEvent?.itemIndex,
            hasItem: !!compatEvent?.item
          });
          this.$emit("select", compatEvent);
        },
        activate: (e) => {
          syncLegacyActiveClasses(root);
          const compatEvent = createLegacyTabStripEvent(e, this.widget || $root.data("kendoTabStrip"), root, "activate");
          debugTabStrip("event:activate", {
            itemIndex: compatEvent?.itemIndex,
            hasItem: !!compatEvent?.item
          });
          this.$emit("activate", compatEvent);
          if (typeof this.activate === "function") this.activate(compatEvent);
        }
      });
      this.widget = patchWidgetCompatMethods($root.data("kendoTabStrip") || null);
      if (this.widget) {
        this.widget.element = this.widget.element || $root;
        this.widget.wrapper = this.widget.wrapper || $root;
        updateLegacySenderState(this.widget, {
          element: this.widget.element,
          wrapper: this.widget.wrapper,
          selectedIndex: resolveTabIndex(this.widget, this.widget.select?.())
        });
      }
      syncLegacyStructuralClasses(root);
      ensureInitialSelection(this.widget, initialTabIndex);
      if (this.pendingWidget?._resolve) {
        this.pendingWidget._resolve(this.widget);
      }
      syncLegacyActiveClasses(root);
      debugTabStrip("createWidget:done", {
        hasWidget: !!this.widget,
        selectedCount: this.widget?.select?.()?.length || 0
      });
    },
    kendoWidget() {
      return this.widget || this.pendingWidget || null;
    }
  }
};
</script>
