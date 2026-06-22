<template>
  <input ref="root" v-bind="$attrs" />
</template>

<script>
import { toRaw } from "vue";
import { getComponentParent } from "@/functions/common/ComponentOwnerResolver";
import { mountDropDownList, syncJQueryDropDownListPresentation } from "@/compat/kendo/native-widgets.js";
import { createLegacyKendoEvent, updateLegacySenderState, withProgrammaticKendoUpdate, isKendoChangeSuppressed, isSameKendoValue } from "@/compat/kendo/legacy-sender.js";
import { findKendoPopupItems, getKendoPopupListBoxId, getKendoPopupRoot, getKendoPopupSurface, getKendoPopupScroller, setKendoPopupHeight, setKendoPopupSurfaceWidth, setKendoPopupSurfaceStyles, syncKendoDropDownListEditedStateFromWidget, syncKendoPopupWidgetRefs } from "@/compat/kendo/dom.js";

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

function toPlainArray(value) {
  const rawValue = toRaw(value);
  if (!rawValue) {
    return [];
  }
  if (Array.isArray(rawValue)) {
    return rawValue;
  }
  if (typeof rawValue.toJSON === "function") {
    try {
      const json = rawValue.toJSON();
      if (Array.isArray(json)) {
        return json;
      }
    } catch (_error) {
      // noop
    }
  }
  if (typeof rawValue.slice === "function") {
    try {
      const sliced = rawValue.slice(0);
      if (Array.isArray(sliced)) {
        return sliced;
      }
    } catch (_error) {
      // noop
    }
  }
  if (typeof rawValue[Symbol.iterator] === "function") {
    try {
      return Array.from(rawValue);
    } catch (_error) {
      // noop
    }
  }
  if (Number.isFinite(rawValue.length)) {
    try {
      return Array.prototype.slice.call(rawValue);
    } catch (_error) {
      // noop
    }
  }
  if (rawValue._data) {
    return toPlainArray(rawValue._data);
  }
  return [];
}

function readDataSourceItems(source) {
  const rawSource = normalizeExternalDataSource(source);
  if (!rawSource) {
    return [];
  }
  const directItems = toPlainArray(rawSource);
  if (directItems.length || Array.isArray(rawSource)) {
    return directItems;
  }
  if (typeof rawSource.view === "function") {
    const view = toPlainArray(rawSource.view());
    if (view.length || Array.isArray(rawSource.view())) {
      return view;
    }
  }
  if (typeof rawSource.data === "function") {
    const data = toPlainArray(rawSource.data());
    if (data.length || Array.isArray(rawSource.data())) {
      return data;
    }
  }
  return toPlainArray(rawSource.data);
}

function getItemValue(item, valueField) {
  if (item == null) {
    return item;
  }
  return typeof item === "object" ? item?.[valueField] : item;
}

function getItemText(item, textField) {
  if (item == null) {
    return "";
  }
  return typeof item === "object" ? item?.[textField] ?? "" : String(item);
}

function isWidgetPopupOpen(widget) {
  if (!widget) {
    return false;
  }
  if (widget.vm && Object.prototype.hasOwnProperty.call(widget.vm, "opened")) {
    return widget.vm.opened === true;
  }
  const popup = widget.popup?.wrapper?.[0] || widget.popup?.element?.[0] || null;
  if (!popup) {
    return false;
  }
  const style = popup.ownerDocument?.defaultView?.getComputedStyle?.(popup);
  return popup.getAttribute?.("aria-hidden") !== "true" && style?.display !== "none" && style?.visibility !== "hidden";
}

export default {
  name: "KendoDropDownList",
  inheritAttrs: false,
  props: {
    modelValue: { default: null },
    value: { default: null },
    dataSource: { type: [Array, Object], default: () => [] },
    dataSourceRef: { type: String, default: undefined },
    dataTextField: { type: String, default: "text" },
    dataValueField: { type: String, default: "value" },
    filter: { type: String, default: undefined },
    disabled: { type: Boolean, default: false },
    optionLabel: { type: [String, Object], default: undefined },
    messages: { type: Object, default: undefined },
    placeholder: { type: String, default: undefined },
    virtualValueMapper: { type: Function, default: null },
    height: { type: [Number, String], default: undefined },
    autoSelectFirstOnEmpty: { type: Boolean, default: true }
  },
  emits: ["update:modelValue", "input", "change", "select", "open", "close", "filtering"],
  data() {
    return {
      widget: null,
      lastValue: null,
      mountedReplayReady: false,
      pendingSyncValue: false,
      pendingRebind: false,
      pendingRecreate: false,
      internalRebind: false,
      legacyDomFrame: null,
      legacyDomTimer: null
    };
  },
  mounted() {
    this.createWidget();
    this.mountedReplayReady = true;
    this.flushPendingOperations();
  },
  watch: {
    modelValue() { this.syncValue(); },
    value() { this.syncValue(); },
    // Vue2 wrapper では dataSource 内部 mutation だけで再 rebind しない。
    // Vue3 reactive proxy 由来の setDataSource 再帰を避け、参照変更だけを拾う。
    dataSource: { handler() { this.rebind(); } },
    dataSourceRef() { this.rebind(); },
    disabled(value) { if (this.widget?.enable) this.widget.enable(!value); },
    dataTextField() { this.recreateWidget(); },
    dataValueField() { this.recreateWidget(); },
    filter() { this.recreateWidget(); },
    optionLabel: { deep: true, handler() { this.recreateWidget(); } },
    messages: { deep: true, handler() { this.recreateWidget(); } },
    placeholder() { this.recreateWidget(); },
    virtualValueMapper() { this.recreateWidget(); },
    height() { this.recreateWidget(); },
    autoSelectFirstOnEmpty() { this.recreateWidget(); },
  },
  updated() {
    syncJQueryDropDownListPresentation(this.widget, this.$refs.root);
  },
  beforeUnmount() {
    this.clearLegacyDomSchedule();
    if (this.widget?.destroy) this.widget.destroy();
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
    resolveDataItems() {
      const widgetItems = toPlainArray(this.widget?.dataItems?.());
      return widgetItems.length ? widgetItems : readDataSourceItems(this.resolveDataSource());
    },
    currentValue() {
      return this.modelValue !== null && this.modelValue !== undefined ? this.modelValue : this.value;
    },
    resolveDataItem(value = this.currentValue()) {
      const items = this.resolveDataItems();
      return items.find((item) => String(getItemValue(item, this.dataValueField)) === String(value)) || null;
    },
    resolveSelectedIndex(value = this.currentValue()) {
      const items = this.resolveDataItems();
      return items.findIndex((item) => String(getItemValue(item, this.dataValueField)) === String(value));
    },
    resolveText(value = this.currentValue()) {
      const widgetText = this.widget?.text?.();
      if (widgetText !== undefined && widgetText !== null && widgetText !== "") {
        return widgetText;
      }
      return getItemText(this.resolveDataItem(value), this.dataTextField);
    },
    syncWidgetDisplayText(value = this.currentValue()) {
      if (!this.widget || this.resolveSelectedIndex(value) < 0) {
        return;
      }
      const text = getItemText(this.resolveDataItem(value), this.dataTextField);
      if (!text) {
        return;
      }

      if (!this.widget.text?.()) {
        this.widget.text?.(text);
      }

      const textElement = this.widget.wrapper?.[0]?.querySelector?.(".k-input-value-text, .k-input");
      if (!textElement || textElement.textContent || textElement.value) {
        return;
      }

      if (textElement.tagName === "INPUT") {
        textElement.value = text;
      } else {
        textElement.textContent = text;
      }
      this.widget.wrapper?.[0]?.setAttribute?.("title", text);
    },
    syncSenderState(value = this.currentValue(), sender = this.widget) {
      const dataItem = this.resolveDataItem(value);
      const selectedIndex = this.resolveSelectedIndex(value);
      return updateLegacySenderState(sender, {
        value,
        text: this.resolveText(value),
        dataItem,
        selectedIndex
      });
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
    syncPopupMetadataIfOpen(forceOpen = false) {
      if (!forceOpen && !isWidgetPopupOpen(this.widget)) {
        return;
      }
      this.$nextTick(() => {
        this.widget?.open?.();
        syncKendoDropDownListEditedStateFromWidget(this.widget, this.$refs.root);
        syncKendoPopupWidgetRefs(this.widget, this.$refs.root);
        this.scheduleLegacyDomSync(() => {
          syncKendoDropDownListEditedStateFromWidget(this.widget, this.$refs.root);
          syncKendoPopupWidgetRefs(this.widget, this.$refs.root);
        });
      });
    },
    syncRootValue(value) {
      if (this.$refs.root) {
        this.$refs.root.value = value ?? "";
      }
    },
    emitValueChange(nextValue, rawEvent = null, reason = "change") {
      this.lastValue = nextValue;
      this.syncRootValue(nextValue);
      const sender = this.syncSenderState(nextValue, rawEvent?.sender || this.widget);
      const compatEvent = createLegacyKendoEvent(rawEvent, sender, {
        value: nextValue,
        dataItem: this.resolveDataItem(nextValue),
        selectedIndex: this.resolveSelectedIndex(nextValue),
        reason
      });
      this.$emit("update:modelValue", nextValue);
      this.$emit("input", nextValue);
      this.$emit("change", compatEvent);
      return nextValue;
    },
    destroyWidget() {
      this.clearLegacyDomSchedule();
      if (this.widget?.destroy) {
        this.widget.destroy();
      }
      this.widget = null;
    },
    createWidget() {
      this.destroyWidget();
      this.widget = mountDropDownList(this.$refs.root, {
        dataSource: this.resolveDataSource(),
        dataTextField: this.dataTextField,
        dataValueField: this.dataValueField,
        optionLabel: this.optionLabel,
        messages: this.messages,
        placeholder: this.placeholder,
        filter: this.filter,
        valuePrimitive: true,
        virtual: this.virtualValueMapper ? { valueMapper: this.virtualValueMapper } : undefined,
        height: this.height,
        autoSelectFirstOnEmpty: this.autoSelectFirstOnEmpty,
        value: this.currentValue(),
        disabled: this.disabled,
        change: (e) => {
          if (isKendoChangeSuppressed(e?.sender || this.widget)) {
            return;
          }
          const nextValue = e.sender.value();
          this.emitValueChange(nextValue, e, "change");
        },
        select: (e) => {
          const dataItem = e?.dataItem || (typeof e?.sender?.dataItem === "function" && e?.item ? e.sender.dataItem(e.item) : null);
          const value = e?.value ?? getItemValue(dataItem, this.dataValueField) ?? e?.sender?.value?.() ?? this.currentValue();
          const sender = this.syncSenderState(value, e?.sender || this.widget);
          this.$emit("select", createLegacyKendoEvent(e, sender, {
            value,
            dataItem: dataItem || this.resolveDataItem(value),
            selectedIndex: e?.index ?? e?.item?.index?.() ?? this.resolveSelectedIndex(value)
          }));
        },
        open: (e) => {
          const sender = this.syncSenderState(this.widget?.value?.() ?? this.currentValue(), e?.sender || this.widget);
          syncKendoDropDownListEditedStateFromWidget(sender, this.$refs.root);
          syncKendoPopupWidgetRefs(sender, this.$refs.root);
          this.$emit("open", createLegacyKendoEvent(e, sender));
        },
        close: (e) => this.$emit("close", createLegacyKendoEvent(e, this.syncSenderState(this.widget?.value?.() ?? this.currentValue(), e?.sender || this.widget))),
        filtering: (e) => this.$emit("filtering", createLegacyKendoEvent(e, this.syncSenderState(this.widget?.value?.() ?? this.currentValue(), e?.sender || this.widget)))
      });
      this.lastValue = this.widget?.value?.() ?? this.currentValue();
      this.syncRootValue(this.lastValue);
      this.syncSenderState(this.lastValue, this.widget);
      this.syncWidgetDisplayText(this.lastValue);
      syncJQueryDropDownListPresentation(this.widget, this.$refs.root);
      syncKendoDropDownListEditedStateFromWidget(this.widget, this.$refs.root);
      syncKendoPopupWidgetRefs(this.widget, this.$refs.root);
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
      if (this.widget?.setDataSource) {
        const wasOpen = isWidgetPopupOpen(this.widget);
        this.internalRebind = true;
        try {
          withProgrammaticKendoUpdate(this.widget, () => {
            this.widget.setDataSource(this.resolveDataSource());
            let effectiveValue = this.widget.value?.() ?? this.currentValue();
            if (!isSameKendoValue(this.widget.value?.(), this.currentValue())) {
              this.widget.value?.(this.currentValue());
              effectiveValue = this.widget.value?.() ?? this.currentValue();
            }
            this.widget.refresh?.();
            this.syncSenderState(effectiveValue, this.widget);
            this.syncWidgetDisplayText(effectiveValue);
          });
          if (wasOpen) {
            this.syncPopupMetadataIfOpen(true);
          }
        } finally {
          this.$nextTick(() => {
            this.internalRebind = false;
          });
        }
        return;
      }
      this.recreateWidget();
    },
    syncValue() {
      if (!this.mountedReplayReady || !this.widget) {
        this.pendingSyncValue = true;
        return;
      }
      const nextValue = this.currentValue();
      let effectiveValue = this.widget.value?.() ?? nextValue;
      if (!isSameKendoValue(this.widget.value?.(), nextValue)) {
        withProgrammaticKendoUpdate(this.widget, () => {
          this.widget.value(nextValue);
        });
        effectiveValue = this.widget.value?.() ?? nextValue;
      }
      this.lastValue = effectiveValue;
      this.syncRootValue(effectiveValue);
      this.syncSenderState(effectiveValue, this.widget);
      this.syncWidgetDisplayText(effectiveValue);
      syncJQueryDropDownListPresentation(this.widget, this.$refs.root);
      syncKendoDropDownListEditedStateFromWidget(this.widget, this.$refs.root);
      syncKendoPopupWidgetRefs(this.widget, this.$refs.root);
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
        return null;
      }
      withProgrammaticKendoUpdate(this.widget, () => {
        this.widget.value("");
      });
      this.syncSenderState(this.widget.value?.() ?? null, this.widget);
      return this.emitValueChange(null, null, "clear");
    },
    text() {
      return this.widget?.text?.();
    },
    dataItem(value) {
      if (value !== undefined) {
        return this.resolveDataItem(value);
      }
      return this.widget?.dataItem?.() || this.resolveDataItem();
    },
    dataItems() {
      const widgetItems = toPlainArray(this.widget?.dataItems?.());
      return widgetItems.length ? widgetItems : this.resolveDataItems();
    },
    widgetValue(nextValue) {
      if (!this.widget?.value) {
        return nextValue === undefined ? this.currentValue() : nextValue;
      }
      if (nextValue === undefined) {
        return this.widget.value();
      }
      return withProgrammaticKendoUpdate(this.widget, () => {
        const result = this.widget.value(nextValue);
        const effectiveValue = result ?? this.widget.value?.() ?? nextValue;
        this.syncRootValue(effectiveValue);
        this.syncSenderState(effectiveValue, this.widget);
        syncKendoDropDownListEditedStateFromWidget(this.widget, this.$refs.root);
        syncKendoPopupWidgetRefs(this.widget, this.$refs.root);
        this.lastValue = effectiveValue;
        return result;
      });
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
