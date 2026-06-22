<template>
  <select ref="root" multiple v-bind="$attrs"></select>
</template>

<script>
import { getComponentParent } from "@/functions/common/ComponentOwnerResolver";
import $ from "@/compat/jquery";
import { toRaw } from "vue";
import { mountMultiSelect, getOriginalMultiSelectPlugin } from "@/compat/kendo/native-widgets.js";
import { findKendoPopupItems, getKendoPopupListBoxId, getKendoPopupRoot, getKendoPopupSurface, getKendoPopupScroller, setKendoPopupHeight, setKendoPopupSurfaceWidth, setKendoPopupSurfaceStyles, syncKendoPopupWidgetRefs } from "@/compat/kendo/dom.js";

function isDefined(value) {
  return value !== undefined && value !== null;
}

function normalizeExternalDataSource(source) {
  const rawSource = toRaw(source);
  if (!rawSource || typeof rawSource !== "object") {
    return rawSource;
  }
  if (Array.isArray(rawSource)) {
    return rawSource;
  }
  const rawData = toRaw(rawSource.data);
  if (Array.isArray(rawData)) {
    return { ...rawSource, data: rawData };
  }
  return rawSource;
}

function readDataSourceItems(source) {
  const rawSource = normalizeExternalDataSource(source);
  if (!rawSource) {
    return [];
  }
  if (Array.isArray(rawSource)) {
    return rawSource;
  }
  if (typeof rawSource.view === "function") {
    try {
      const view = rawSource.view();
      if (view) {
        return Array.from(view);
      }
    } catch (_error) {
      // noop
    }
  }
  if (typeof rawSource.data === "function") {
    try {
      const data = rawSource.data();
      if (data) {
        return Array.from(data);
      }
    } catch (_error) {
      // noop
    }
  }
  return Array.isArray(rawSource.data) ? rawSource.data : [];
}

function getItemValue(item, valueField) {
  if (item == null) {
    return item;
  }
  return typeof item === "object" ? item?.[valueField] : item;
}

function uniqueValueArray(values) {
  const normalizedValues = Array.isArray(values) ? values : [];
  const seen = new Set();
  return normalizedValues.filter((value) => {
    const key = String(value);
    if (seen.has(key)) {
      return false;
    }
    seen.add(key);
    return true;
  });
}

function limitValueArray(values, maxSelectedItems) {
  const normalizedValues = Array.isArray(values) ? values : [];
  const numericLimit = Number(maxSelectedItems);
  if (Number.isFinite(numericLimit) && numericLimit > 0 && normalizedValues.length > numericLimit) {
    return normalizedValues.slice(0, numericLimit);
  }
  return normalizedValues;
}

function normalizeValuesAgainstDataSource(values, source, valueField) {
  const normalizedValues = Array.isArray(values) ? values : [];
  const items = readDataSourceItems(source);
  return uniqueValueArray(normalizedValues.map((value) => {
    const matchedItem = items.find((item) => String(getItemValue(item, valueField)) === String(value));
    return matchedItem ? getItemValue(matchedItem, valueField) : value;
  }));
}

function isSameValueArray(left, right) {
  const leftValue = Array.isArray(left) ? left : [];
  const rightValue = Array.isArray(right) ? right : [];
  if (leftValue.length !== rightValue.length) {
    return false;
  }
  return leftValue.every((value, index) => String(value) === String(rightValue[index]));
}

function applyCompatSenderState(widget, currentValue, currentText = "") {
  if (!widget || typeof widget !== "object") {
    return widget;
  }
  widget._old = Array.isArray(currentValue) ? [...currentValue] : [];
  widget._oldText = currentText ?? "";
  return widget;
}

function addLegacyClass(element, classNames = []) {
  if (!element?.classList) {
    return;
  }
  classNames.forEach((className) => {
    if (className) {
      element.classList.add(className);
    }
  });
}

function resolveMultiSelectWrapper(widget, root) {
  return widget?.wrapper?.[0]
    || root?.closest?.(".k-multiselect")
    || widget?.mountNode?.firstElementChild
    || widget?.mountNode
    || null;
}

function collectRenderedChips(wrapper) {
  const candidates = Array.from(wrapper?.querySelectorAll?.(".k-chip, .k-chip-list > li, ul.k-reset > li") || []);
  return candidates.filter((chip) => {
    const text = chip.textContent?.trim?.() || "";
    return chip.classList?.contains?.("k-chip")
      || chip.classList?.contains?.("k-button")
      || (text && !chip.querySelector?.("input"));
  });
}

function syncRenderedChipsToValue(wrapper, widget) {
  let widgetValue = [];
  try {
    widgetValue = typeof widget?.value === "function" && Array.isArray(widget.value()) ? widget.value() : [];
  } catch (_error) {
    widgetValue = [];
  }
  const chips = collectRenderedChips(wrapper);
  if (chips.length > widgetValue.length) {
    chips.slice(widgetValue.length).forEach((chip) => chip.remove());
    return chips.slice(0, widgetValue.length);
  }
  return chips;
}

function syncLegacyMultiSelectDomFacade(widget, root) {
  const wrapper = resolveMultiSelectWrapper(widget, root);
  if (!wrapper) {
    return;
  }

  // Vue3/Kendo の生成 class は削らず、Vue2 側が参照していた class 契約だけを追加する。
  // ただし Vue2 では k-reset は inner ul/tag-list 側であり、wrapper 側には付けない。
  addLegacyClass(wrapper, ["k-widget", "k-header", "k-multiselect", "k-multiselect-clearable", "k-legacy-multiselect"]);
  wrapper.setAttribute?.("unselectable", "on");
  wrapper.setAttribute?.("aria-haspopup", "true");
  const listBoxId = widget?.popupListBoxId?.() || widget?.listBoxId || null;
  if (listBoxId) {
    wrapper.setAttribute?.("aria-controls", listBoxId);
    wrapper.setAttribute?.("aria-owns", listBoxId);
  }

  const valueArea = wrapper.querySelector?.(".k-input-values, .k-multiselect-wrap");
  addLegacyClass(valueArea, ["k-multiselect-wrap", "k-floatwrap"]);
  valueArea?.setAttribute?.("role", "listbox");
  valueArea?.setAttribute?.("unselectable", "on");
  if (listBoxId) {
    valueArea?.setAttribute?.("aria-controls", listBoxId);
    valueArea?.setAttribute?.("aria-owns", listBoxId);
  }

  const input = wrapper.querySelector?.("input.k-input-inner, input.k-input, .k-input-inner, .k-input");
  addLegacyClass(input, ["k-input"]);
  input?.setAttribute?.("role", "listbox");
  input?.setAttribute?.("unselectable", "on");
  if (listBoxId) {
    input?.setAttribute?.("aria-controls", listBoxId);
    input?.setAttribute?.("aria-owns", listBoxId);
  }

  const chipList = wrapper.querySelector?.(".k-selection-multiple, .k-chip-list, ul.k-reset, .k-input-values > ul, .k-multiselect-wrap > ul");
  addLegacyClass(chipList, ["k-reset"]);
  chipList?.setAttribute?.("unselectable", "on");
  const chips = syncRenderedChipsToValue(wrapper, widget);
  chips.forEach((chip) => {
    addLegacyClass(chip, ["k-button"]);
    chip.classList?.remove?.("k-state-default");
    chip.setAttribute?.("unselectable", "on");
    chip.setAttribute?.("aria-setsize", String(chips.length));
    chip.setAttribute?.("aria-posinset", String(chips.indexOf(chip) + 1));
  });
  wrapper.querySelectorAll?.(".k-chip-action, .k-chip-remove-action").forEach((action) => {
    addLegacyClass(action, ["k-select"]);
    action.setAttribute?.("unselectable", "on");
  });
  wrapper.querySelectorAll?.(".k-chip-remove-action .k-icon, .k-chip-remove-action .k-svg-icon").forEach((icon) => {
    addLegacyClass(icon, ["k-icon", "k-i-close"]);
  });
  wrapper.querySelectorAll?.(".k-clear-value").forEach((clear) => {
    addLegacyClass(clear, ["k-icon", "k-i-close"]);
    clear.setAttribute?.("unselectable", "on");
    //阻止事件冒泡
    //イベントの泡立ちを防ぐ
    clear.addEventListener("mousedown", (e) => {
      e.stopPropagation();
    });
  });
  wrapper.querySelectorAll?.(".k-chip-content, .k-chip-label").forEach((label) => label.setAttribute?.("unselectable", "on"));
  //下拉框里清除按钮的显示和隐藏
  //ドロップダウンボックスでのクリアボタンの表示と非表示
  const hasValue =
  Array.isArray(widget?.value?.()) &&
  widget.value().length > 0;

  wrapper.classList.toggle("k-no-value", !hasValue);
}

function getJQueryMultiSelectFactory() {
  const factory = getOriginalMultiSelectPlugin();
  return typeof factory === "function" ? { $, factory } : null;
}

export default {
  name: "KendoMultiSelect",
  inheritAttrs: false,
  props: {
    modelValue: { type: Array, default: undefined },
    value: { type: Array, default: undefined },
    dataSource: { type: [Array, Object], default: () => [] },
    dataSourceRef: { type: String, default: undefined },
    dataTextField: { type: String, default: "text" },
    dataValueField: { type: String, default: "value" },
    disabled: { type: Boolean, default: false },
    autoClose: { type: Boolean, default: true },
    filter: { type: String, default: undefined },
    placeholder: { type: String, default: undefined },
    maxSelectedItems: { type: [Number, String], default: undefined },
    virtualValueMapper: { type: Function, default: null }
  },
  emits: ["update:modelValue", "input", "change", "select", "deselect", "open", "close", "filtering"],
  data() {
    return {
      widget: null,
      lastValue: [],
      mountedReplayReady: false,
      pendingSyncValue: false,
      pendingRebind: false,
      pendingRecreate: false,
      internalRebind: false,
      legacyDomFrame: null,
      legacyDomTimer: null,
      popupPositionFrame: null,
      popupPositionTimer: null
    };
  },
  mounted() {
    this.createWidget();
    this.mountedReplayReady = true;
    this.flushPendingOperations();
  },
  // Vue2 の kendo-multiselect-vue-wrapper は updated フックで毎回 refresh() を呼ばない。
  // ここでも Vue2 と合わせ、rebind / syncValue / emitValueChange の明示的な経路でのみ
  // widget.refresh() を呼ぶように揃える。
  watch: {
    modelValue: { deep: true, handler() { this.syncValue(); } },
    value: { deep: true, handler() { this.syncValue(); } },
    // Vue2 wrapper では dataSource 内部の Kendo 側 mutation で再 rebind しない。
    // Vue3 の reactive proxy を deep watch すると setDataSource() 自身で再帰するため、参照変更だけを監視する。
    dataSource: { handler() { this.rebind(); } },
    dataSourceRef() { this.rebind(); },
    disabled(value) {
      if (this.widget?.enable) {
        this.widget.enable(!value);
      }
    },
    autoClose() { this.recreateWidget(); },
    filter() { this.recreateWidget(); },
    placeholder() { this.recreateWidget(); },
    maxSelectedItems() { this.recreateWidget(); },
    dataTextField() { this.recreateWidget(); },
    dataValueField() { this.recreateWidget(); },
    virtualValueMapper() { this.recreateWidget(); },
  },
  beforeUnmount() {
    this.clearLegacyDomSchedule();
    this.clearPopupPositionSchedule();
    this.destroyWidget();
  },
  methods: {
    flushPendingOperations() {
      if (!this.mountedReplayReady) {
        return;
      }
      if (this.pendingRecreate) {
        this.pendingRecreate = false;
        this.createWidget();
      } else if (this.pendingRebind) {
        this.pendingRebind = false;
        this.rebind();
      } else if (this.pendingSyncValue) {
        this.pendingSyncValue = false;
        this.syncValue();
      }
    },
    resolveDataSourceRef() {
      const refName = this.dataSourceRef || this.$attrs["data-source-ref"];
      if (!refName) {
        return null;
      }
      let owner = getComponentParent(this);
      while (owner) {
        const candidate = owner.$refs?.[refName];
        const resolvedCandidate = Array.isArray(candidate) ? candidate[0] : candidate;
        const dataSource = resolvedCandidate?.getDataSource?.()
          || resolvedCandidate?.kendoWidget?.()
          || resolvedCandidate?.dataSource
          || null;
        if (dataSource) {
          return dataSource;
        }
        owner = getComponentParent(owner);
      }
      return null;
    },
    resolveDataSource() {
      return normalizeExternalDataSource(this.resolveDataSourceRef() || this.dataSource);
    },
    currentValue() {
      const source = this.resolveDataSource();
      let currentValue = [];
      if (isDefined(this.modelValue)) {
        currentValue = normalizeValuesAgainstDataSource(this.modelValue, source, this.dataValueField);
      } else {
        currentValue = normalizeValuesAgainstDataSource(this.value, source, this.dataValueField);
      }
      return limitValueArray(currentValue, this.maxSelectedItems);
    },
    emitValueChange(nextValue, rawEvent = null, reason = "change") {
      const normalized = limitValueArray(uniqueValueArray(nextValue), this.maxSelectedItems);
      this.lastValue = [...normalized];
      applyCompatSenderState(this.widget, normalized, this.text() || "");
      this.$emit("update:modelValue", normalized);
      this.$emit("input", normalized);
      const compatEvent = rawEvent ? { ...rawEvent, sender: applyCompatSenderState(rawEvent.sender || this.widget, normalized, this.text() || "") } : { sender: applyCompatSenderState(this.widget, normalized, this.text() || ""), value: normalized, reason };
      this.$emit("change", compatEvent);
      // this.widget?.refresh?.();
      this.syncLegacyDom();
      return normalized;
    },
    destroyWidget() {
      this.clearLegacyDomSchedule();
      this.clearPopupPositionSchedule();
      if (this.widget?.destroy) {
        this.widget.destroy();
      }
      this.widget = null;
    },
    createWidget() {
      const root = this.$refs.root;
      if (!root) {
        return;
      }
      this.destroyWidget();
      const widgetOptions = {
        dataSource: this.resolveDataSource(),
        dataTextField: this.dataTextField,
        dataValueField: this.dataValueField,
        autoClose: this.autoClose,
        filter: this.filter,
        placeholder: this.placeholder ?? this.$attrs.placeholder,
        valuePrimitive: true,
        virtual: this.virtualValueMapper ? { valueMapper: this.virtualValueMapper } : undefined,
        value: this.currentValue(),
        disabled: this.disabled,
        maxSelectedItems: this.maxSelectedItems,
        change: (e) => {
          const widgetValue = Array.isArray(e.sender.value()) ? e.sender.value() : [];
          let nextValue = limitValueArray(uniqueValueArray(widgetValue), this.maxSelectedItems);
          if (nextValue.length < widgetValue.length && Array.isArray(this.lastValue) && this.lastValue.length >= nextValue.length) {
            nextValue = [...this.lastValue];
          }
          if (!isSameValueArray(widgetValue, nextValue)) {
            e.sender.value(nextValue);
          }
          applyCompatSenderState(e.sender, nextValue, e.sender?.text?.() || "");
          this.emitValueChange(nextValue, e, "change");
        },
        select: (e) => this.$emit("select", { ...e, sender: applyCompatSenderState(e.sender || this.widget, this.currentValue(), e.sender?.text?.() || this.text() || "") }),
        deselect: (e) => this.$emit("deselect", { ...e, sender: applyCompatSenderState(e.sender || this.widget, this.currentValue(), e.sender?.text?.() || this.text() || "") }),
        open: (e) => {
          const sender = applyCompatSenderState(e.sender || this.widget, this.currentValue(), e.sender?.text?.() || this.text() || "");
          syncKendoPopupWidgetRefs(sender, this.$refs.root);
          const compatEvent = { ...e, sender };
          this.syncLegacyDom(true);
          this.schedulePopupPosition(sender);
          this.$emit("open", compatEvent);
        },
        close: (e) => this.$emit("close", { ...e, sender: applyCompatSenderState(e.sender || this.widget, this.currentValue(), e.sender?.text?.() || this.text() || "") }),
        filtering: (e) => this.$emit("filtering", { ...e, sender: applyCompatSenderState(e.sender || this.widget, this.currentValue(), e.sender?.text?.() || this.text() || "") }),
        dataBound: (e) => {
          this.syncLegacyDom(true);
          this.schedulePopupPosition(e.sender || this.widget);
        }
      };
      const jqFactory = getJQueryMultiSelectFactory();
      if (jqFactory) {
        const { $, factory } = jqFactory;
        const $root = $(root);
        factory.call($root, widgetOptions);
        this.widget = $root.data("kendoMultiSelect") || null;
      }
      if (!this.widget) {
        this.widget = mountMultiSelect(root, widgetOptions);
      }
      this.lastValue = this.currentValue();
      applyCompatSenderState(this.widget, this.lastValue, this.widget?.text?.() || "");
      if (this.widget?.enable) {
        this.widget.enable(!this.disabled);
      }
      this.syncLegacyDom();
    },
    recreateWidget() {
      if (!this.mountedReplayReady) {
        this.pendingRecreate = true;
        return;
      }
      this.$nextTick(() => {
        this.createWidget();
      });
    },
    rebind() {
      if (!this.mountedReplayReady) {
        this.pendingRebind = true;
        return;
      }
      if (this.internalRebind) {
        return;
      }
      if (!this.widget?.setDataSource) {
        this.recreateWidget();
        return;
      }
      this.internalRebind = true;
      try {
        this.widget.setDataSource(this.resolveDataSource());
        this.syncValue();
        this.widget?.refresh?.();
        this.syncLegacyDom();
        this.schedulePopupPosition();
      } finally {
        this.$nextTick(() => {
          this.internalRebind = false;
        });
      }
    },
    syncValue() {
      if (!this.mountedReplayReady || !this.widget?.value) {
        this.pendingSyncValue = true;
        return;
      }
      const nextValue = this.currentValue();
      const currentWidgetValue = this.widget.value();
      this.lastValue = [...nextValue];
      if (!isSameValueArray(currentWidgetValue, nextValue)) {
        this.widget.value(nextValue);
        this.widget?.refresh?.();
      }
      applyCompatSenderState(this.widget, nextValue, this.widget?.text?.() || "");
      this.syncLegacyDom();
      this.schedulePopupPosition();
    },
    clearLegacyDomSchedule() {
      const ownerWindow = this.$refs.root?.ownerDocument?.defaultView || (typeof window !== "undefined" ? window : globalThis);
      if (this.legacyDomFrame !== null) {
        ownerWindow.cancelAnimationFrame?.(this.legacyDomFrame);
        ownerWindow.clearTimeout?.(this.legacyDomFrame);
        this.legacyDomFrame = null;
      }
      if (this.legacyDomTimer !== null) {
        ownerWindow.clearTimeout?.(this.legacyDomTimer);
        this.legacyDomTimer = null;
      }
    },
    clearPopupPositionSchedule() {
      const ownerWindow = this.$refs.root?.ownerDocument?.defaultView || (typeof window !== "undefined" ? window : globalThis);
      if (this.popupPositionFrame !== null) {
        ownerWindow.cancelAnimationFrame?.(this.popupPositionFrame);
        ownerWindow.clearTimeout?.(this.popupPositionFrame);
        this.popupPositionFrame = null;
      }
      if (this.popupPositionTimer !== null) {
        ownerWindow.clearTimeout?.(this.popupPositionTimer);
        this.popupPositionTimer = null;
      }
    },
    isPopupOpen(widget = this.widget) {
      try {
        if (typeof widget?.popup?.visible === "function") {
          return widget.popup.visible();
        }
      } catch (_error) {
        // noop
      }
      const popupRoot = getKendoPopupRoot(widget, this.$refs.root);
      if (!popupRoot) {
        return false;
      }
      const ownerWindow = popupRoot.ownerDocument?.defaultView || (typeof window !== "undefined" ? window : globalThis);
      const display = ownerWindow.getComputedStyle?.(popupRoot)?.display;
      return popupRoot.isConnected !== false && display !== "none";
    },
    positionPopup(widget = this.widget) {
      const targetWidget = widget || this.widget;
      if (!targetWidget || !this.isPopupOpen(targetWidget)) {
        return;
      }
      syncKendoPopupWidgetRefs(targetWidget, this.$refs.root);
      try {
        targetWidget.popup?.position?.();
      } catch (_error) {
        // noop
      }
    },
    schedulePopupPosition(widget = this.widget) {
      const targetWidget = widget || this.widget;
      if (!targetWidget) {
        return;
      }
      const ownerWindow = this.$refs.root?.ownerDocument?.defaultView || (typeof window !== "undefined" ? window : globalThis);
      this.clearPopupPositionSchedule();
      this.positionPopup(targetWidget);
      const requestFrame = typeof ownerWindow.requestAnimationFrame === "function"
        ? ownerWindow.requestAnimationFrame.bind(ownerWindow)
        : (callback) => ownerWindow.setTimeout(callback, 0);
      this.popupPositionFrame = requestFrame(() => {
        this.popupPositionFrame = null;
        this.positionPopup(targetWidget);
        this.popupPositionTimer = ownerWindow.setTimeout(() => {
          this.popupPositionTimer = null;
          this.positionPopup(targetWidget);
        }, 0);
      });
    },
    scheduleLegacyDomSync(callback) {
      this.clearLegacyDomSchedule();
      const ownerWindow = this.$refs.root?.ownerDocument?.defaultView || (typeof window !== "undefined" ? window : globalThis);
      this.legacyDomFrame = typeof ownerWindow.requestAnimationFrame === "function"
        ? ownerWindow.requestAnimationFrame(() => {
          this.legacyDomFrame = null;
          callback?.();
        })
        : ownerWindow.setTimeout(() => {
          this.legacyDomFrame = null;
          callback?.();
        }, 0);
    },
    syncLegacyDom(syncPopup = false) {
      const apply = () => {
        syncLegacyMultiSelectDomFacade(this.widget, this.$refs.root);
        if (syncPopup) {
          syncKendoPopupWidgetRefs(this.widget, this.$refs.root);
          this.schedulePopupPosition();
        }
      };
      this.$nextTick(() => {
        apply();
        this.scheduleLegacyDomSync(apply);
      });
    },
    open() {
      return this.widget?.open?.();
    },
    close() {
      return this.widget?.close?.();
    },
    focus() {
      return this.widget?.focus?.();
    },
    clear() {
      if (!this.widget?.value) {
        return [];
      }
      this.widget.value([]);
      return this.emitValueChange([], null, "clear");
    },
    remove(valueOrItem) {
      if (!this.widget?.value) {
        return [];
      }
      const currentValue = Array.isArray(this.widget.value()) ? this.widget.value() : [];
      if (!currentValue.length) {
        return [];
      }
      const resolvedValue = typeof valueOrItem === "object" && valueOrItem !== null
        ? valueOrItem[this.dataValueField]
        : (valueOrItem !== undefined ? valueOrItem : currentValue[currentValue.length - 1]);
      const nextValue = currentValue.filter((entry) => String(entry) !== String(resolvedValue));
      this.widget.value(nextValue);
      return this.emitValueChange(nextValue, null, "remove");
    },
    text() {
      return this.widget?.text?.();
    },
    dataItem(value) {
      if (!this.widget) {
        return null;
      }
      if (value === undefined) {
        return this.widget?.dataItems?.()?.[0] || null;
      }
      const allItems = this.widget?.dataSource?.view?.() || this.widget?.dataSource?.data?.() || [];
      return Array.from(allItems).find((item) => String(item?.[this.dataValueField]) === String(value)) || null;
    },
    dataItems() {
      return this.widget?.dataItems?.() || [];
    },
    widgetValue(nextValue) {
      if (!this.widget?.value) {
        return nextValue === undefined ? this.currentValue() : nextValue;
      }
      if (nextValue === undefined) {
        return this.widget.value();
      }
      this.widget.value(nextValue);
      return this.emitValueChange(nextValue, null, "widgetValue");
    },
    enable(enabled = true) {
      return this.widget?.enable?.(enabled);
    },
    popupListBoxId() {
      return getKendoPopupListBoxId(this.widget);
    },
    popupOwnerDocument() {
      return this.$refs.root?.ownerDocument || this.widget?.mountNode?.ownerDocument || null;
    },
    popupRootEl() {
      return getKendoPopupRoot(this.widget, this.$refs.root);
    },
    popupSurfaceEl() {
      return getKendoPopupSurface(this.widget, this.$refs.root);
    },
    popupScrollerEl() {
      return getKendoPopupScroller(this.widget, this.$refs.root);
    },
    popupItemEls() {
      return findKendoPopupItems(this.popupRootEl(), this.popupListBoxId());
    },
    hasPopupScroller() {
      return !!(this.popupRootEl() && this.popupScrollerEl());
    },
    applyPopupHeight(height) {
      return setKendoPopupHeight(this.widget, height, this.$refs.root);
    },
    applyPopupSurfaceWidth(width) {
      return setKendoPopupSurfaceWidth(this.widget, width, this.$refs.root);
    },
    applyPopupSurfaceStyles(styles) {
      return setKendoPopupSurfaceStyles(this.widget, styles, this.$refs.root);
    },
    kendoWidget() {
      return this.widget;
    }
  }
};
</script>
