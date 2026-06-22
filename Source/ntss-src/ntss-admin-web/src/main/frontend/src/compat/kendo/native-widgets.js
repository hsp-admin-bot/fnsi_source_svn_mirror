import $, { defineJQueryWidgetData, removeJQueryWidgetData, bridgeJQueryWidgetPlugin } from "@/compat/jquery";
import { createApp, h, nextTick } from "vue";
import { MultiSelect } from "@progress/kendo-vue-dropdowns";
import { NumericTextBox, ColorPicker } from "@progress/kendo-vue-inputs";
import { Editor } from "@progress/kendo-vue-editor";
import { clearKendoEditorControlTitles, syncKendoPopupWidgetRefs } from "@/compat/kendo/dom.js";
import { createLegacyKendoEvent, updateLegacySenderState, withProgrammaticKendoUpdate, isKendoChangeSuppressed, isSameKendoValue } from "@/compat/kendo/legacy-sender.js";
import { BigNumber } from "@/compat/number/bignumber.js";

const sourceElementsByOriginal = new WeakMap();
const nativeWidgetHolders = new WeakMap();
const editorListenersByBody = new WeakMap();
const editorWidgetsByBody = new WeakMap();
const editorAdapters = new WeakMap();
const popupMetadataByWidget = new WeakMap();
const popupSearchRootByWidget = new WeakMap();
let nativeWidgetsInstalled = false;
let originalEditorPlugin = null;
let originalDropDownListPlugin = null;
let originalMultiSelectPlugin = null;
let bodyScrollbarWidthObserver = null;

function getElementOwnerWindow(element = null) {
  return element?.ownerDocument?.defaultView || (typeof window !== "undefined" ? window : globalThis);
}

function getWidgetCleanupList(widget) {
  if (!widget) {
    return null;
  }
  if (!Array.isArray(widget.__ntssKendoNativeCleanups)) {
    try {
      Object.defineProperty(widget, "__ntssKendoNativeCleanups", {
        configurable: true,
        enumerable: false,
        value: [],
        writable: true
      });
    } catch (_error) {
      widget.__ntssKendoNativeCleanups = [];
    }
  }
  return widget.__ntssKendoNativeCleanups;
}

function registerWidgetCleanup(widget, cleanup) {
  if (!widget || typeof cleanup !== "function") {
    return cleanup;
  }
  getWidgetCleanupList(widget)?.push(cleanup);
  return cleanup;
}

function runWidgetCleanups(widget) {
  const cleanups = getWidgetCleanupList(widget);
  if (!cleanups) {
    return;
  }
  while (cleanups.length) {
    try {
      cleanups.pop()?.();
    } catch (_error) {
      // noop
    }
  }
}

function scheduleWidgetFrame(widget, callback) {
  if (!widget || typeof callback !== "function") {
    return null;
  }
  const ownerWindow = getElementOwnerWindow(widget.mountNode || widget.originalElement || widget.element?.[0] || null);
  let active = true;
  const run = () => {
    if (!active) {
      return;
    }
    active = false;
    callback();
  };
  const frameId = typeof ownerWindow.requestAnimationFrame === "function"
    ? ownerWindow.requestAnimationFrame(run)
    : ownerWindow.setTimeout(run, 0);
  registerWidgetCleanup(widget, () => {
    if (!active) {
      return;
    }
    active = false;
    if (typeof ownerWindow.cancelAnimationFrame === "function") {
      ownerWindow.cancelAnimationFrame(frameId);
    }
    ownerWindow.clearTimeout?.(frameId);
  });
  return frameId;
}

function scheduleWidgetTimeout(widget, callback, delay = 0) {
  if (!widget || typeof callback !== "function") {
    return null;
  }
  const ownerWindow = getElementOwnerWindow(widget.mountNode || widget.originalElement || widget.element?.[0] || null);
  let active = true;
  const timerId = ownerWindow.setTimeout(() => {
    if (!active) {
      return;
    }
    active = false;
    callback();
  }, delay);
  registerWidgetCleanup(widget, () => {
    if (!active) {
      return;
    }
    active = false;
    ownerWindow.clearTimeout?.(timerId);
  });
  return timerId;
}

function cleanupWidgetPopupArtifacts(widget) {
  const metadata = popupMetadataByWidget.get(widget);
  const popupRoot = metadata?.root || null;
  popupMetadataByWidget.delete(widget);
  popupSearchRootByWidget.delete(widget);
  try {
    if (popupRoot?.ownerDocument?.documentElement?.contains?.(popupRoot)) {
      popupRoot.remove?.();
    }
  } catch (_error) {
    // noop
  }
}

const LEGACY_WIDGET_DATA_KEYS = {
  dropdownlist: ["kendoDropDownList"],
  multiselect: ["kendoMultiSelect"],
  numerictextbox: ["kendoNumericTextBox"],
  colorpicker: ["kendoColorPicker"],
  editor: ["kendoEditor"],
};

const LEGACY_WIDGET_OPTION_NAMES = new Set([
  "DropDownList",
  "MultiSelect",
  "NumericTextBox",
  "ColorPicker",
  "Editor"
]);

function resolveLegacyInputName(options = {}, element = null) {
  const candidate = options.inputName ?? options.fieldName ?? options.name;
  if (candidate !== undefined && candidate !== null && !LEGACY_WIDGET_OPTION_NAMES.has(String(candidate))) {
    return candidate;
  }
  return element?.getAttribute?.("name") || undefined;
}

function createLegacyWidgetOptions(options = {}, widgetName, inputName = undefined) {
  const widgetOptions = {
    ...options,
    name: widgetName
  };
  if (inputName !== undefined && inputName !== null && inputName !== "") {
    widgetOptions.inputName = inputName;
  }
  return widgetOptions;
}

function setLegacyWidgetRole(element, role) {
  if (!element || !role) {
    return;
  }
  if (element.setAttribute) {
    element.setAttribute("data-role", role);
  }
  try {
    $(element).data("role", role);
  } catch (_error) {
    // Kendo MVVM reads the jQuery data cache in some paths.  Vue2/jQuery Kendo
    // had the role in both attr/data; keep the same tolerance here.
  }
}

function syncLegacyWidgetRole(widget, role) {
  if (!widget || !role) {
    return;
  }
  [
    widget.originalElement,
    widget.mountNode,
    widget.wrapper?.[0],
    widget.element?.[0],
    widget.input?.[0]
  ].filter(Boolean).forEach((element) => setLegacyWidgetRole(element, role));
}

function toPlainDataItems(value) {
  if (!value) {
    return [];
  }
  if (Array.isArray(value)) {
    return value;
  }
  if (typeof value.toJSON === "function") {
    try {
      const json = value.toJSON();
      if (Array.isArray(json)) {
        return json;
      }
    } catch (_error) {
      // noop
    }
  }
  if (typeof value.slice === "function") {
    try {
      const sliced = value.slice(0);
      if (Array.isArray(sliced)) {
        return sliced;
      }
    } catch (_error) {
      // noop
    }
  }
  if (typeof value[Symbol.iterator] === "function") {
    try {
      return Array.from(value);
    } catch (_error) {
      // noop
    }
  }
  if (Number.isFinite(value.length)) {
    try {
      return Array.prototype.slice.call(value);
    } catch (_error) {
      // noop
    }
  }
  if (value._data) {
    return toPlainDataItems(value._data);
  }
  return [];
}

function normalizeDataSource(source) {
  if (!source) {
    return [];
  }
  const directItems = toPlainDataItems(source);
  if (directItems.length || Array.isArray(source)) {
    return directItems;
  }
  if (typeof source.view === "function") {
    const rawView = source.view();
    const view = toPlainDataItems(rawView);
    if (view.length || Array.isArray(rawView)) {
      return view;
    }
  }
  if (typeof source.data === "function") {
    const rawData = source.data();
    const data = toPlainDataItems(rawData);
    if (data.length || Array.isArray(rawData)) {
      return data;
    }
  }
  return toPlainDataItems(source.data);
}

function resolveDefaultItem(dataItems, options = {}) {
  const optionLabel = options.optionLabel;
  if (optionLabel === undefined || optionLabel === null || optionLabel === "") {
    return undefined;
  }
  const first = Array.isArray(dataItems) ? dataItems[0] : undefined;
  if (first && typeof first === "object" && !Array.isArray(first) && typeof optionLabel === "string") {
    return {
      [options.dataTextField || "text"]: optionLabel,
      [options.dataValueField || "value"]: ""
    };
  }
  return optionLabel;
}

function getItemText(item, options = {}) {
  if (item == null) {
    return "";
  }
  if (typeof item === "object") {
    const textField = options.dataTextField || "text";
    return item[textField] ?? "";
  }
  return item;
}

function getItemValue(item, options = {}) {
  if (item == null) {
    return item;
  }
  if (typeof item === "object") {
    const valueField = options.dataValueField || "value";
    return item[valueField];
  }
  return item;
}

function normalizeFilterText(value) {
  return String(value ?? "").toLocaleLowerCase();
}

function matchesKendoTextFilter(text, filterValue, operator = "contains") {
  const candidate = normalizeFilterText(text);
  const filterText = normalizeFilterText(filterValue);
  if (!filterText) {
    return true;
  }
  if (operator === "startswith" || operator === "startsWith") {
    return candidate.startsWith(filterText);
  }
  if (operator === "endswith" || operator === "endsWith") {
    return candidate.endsWith(filterText);
  }
  return candidate.includes(filterText);
}

function filterDropDownDataItems(dataItems, filterValue, options = {}) {
  const normalizedItems = Array.isArray(dataItems) ? dataItems : [];
  if (!options.filter || filterValue === undefined || filterValue === null || String(filterValue) === "") {
    return normalizedItems;
  }
  return normalizedItems.filter((item) => {
    const text = getItemText(item, options);
    return matchesKendoTextFilter(text, filterValue, options.filter);
  });
}

function findSelectedIndex(dataItems, value, options = {}) {
  const normalized = Array.isArray(dataItems) ? dataItems : [];
  return normalized.findIndex((item) => getItemValue(item, options) == value);
}

function findSelectedItem(dataItems, value, options = {}) {
  const index = findSelectedIndex(dataItems, value, options);
  return index >= 0 ? dataItems[index] : null;
}

function hasDropDownOptionLabel(options = {}) {
  return options.optionLabel !== undefined && options.optionLabel !== null && options.optionLabel !== "";
}

function isEmptyDropDownValue(value) {
  return value === undefined || value === null || value === "";
}

function resolveDropDownValue(value, dataItems, options = {}) {
  const normalizedItems = Array.isArray(dataItems) ? dataItems : [];
  const shouldAutoSelectFirstOnEmpty = options.autoSelectFirstOnEmpty !== false;
  if (
    shouldAutoSelectFirstOnEmpty
    && isEmptyDropDownValue(value)
    && !hasDropDownOptionLabel(options)
    && normalizedItems.length > 0
  ) {
    return getItemValue(normalizedItems[0], options);
  }
  if (options.valuePrimitive !== false && !isEmptyDropDownValue(value)) {
    const matchedItem = findSelectedItem(normalizedItems, value, options);
    if (matchedItem) {
      return getItemValue(matchedItem, options);
    }
  }
  return value;
}

function normalizeMultiSelectValuesAgainstDataItems(values, dataItems, options = {}) {
  const normalizedValues = Array.isArray(values) ? values : [];
  const normalizedItems = Array.isArray(dataItems) ? dataItems : [];
  return normalizedValues.map((value) => {
    const matchedItem = findSelectedItem(normalizedItems, value, options);
    return matchedItem ? getItemValue(matchedItem, options) : value;
  });
}

function resolveDataItemsReference(source, fallbackItems = []) {
  const normalized = normalizeDataSource(source);
  if (Array.isArray(normalized)) {
    return normalized;
  }
  return Array.isArray(fallbackItems) ? fallbackItems : [];
}

function syncCompatDataSource(compatDataSource, source, fallbackItems = []) {
  if (!compatDataSource) {
    return null;
  }
  const nextItems = resolveDataItemsReference(source, fallbackItems);
  compatDataSource.__source = source;
  compatDataSource.options = compatDataSource.options || {};
  compatDataSource.options.data = nextItems;
  return compatDataSource;
}

function createCompatDataSource(source, fallbackItems = []) {
  const compatDataSource = {
    __source: source,
    options: {
      data: []
    },
    data(nextData) {
      if (nextData !== undefined) {
        syncCompatDataSource(this, nextData, Array.isArray(nextData) ? nextData : []);
      }
      return Array.isArray(this.options?.data) ? this.options.data : [];
    },
    view() {
      return this.data();
    },
    at(index) {
      return this.data()[index] ?? null;
    },
    fetch(callback) {
      const currentData = this.data();
      if (typeof callback === "function") {
        callback.call(this, currentData);
      }
      return Promise.resolve(currentData);
    },
    read(callback) {
      return this.fetch(callback);
    },
    total() {
      return this.data().length;
    },
    get(id) {
      return this.data().find((item) => item?.id == id) || null;
    }
  };
  return syncCompatDataSource(compatDataSource, source, fallbackItems);
}

function resolveDropdownPopupItem(widget, selectedIndex) {
  const popupItems = popupMetadataByWidget.get(widget)?.items || [];
  if (selectedIndex == null || selectedIndex < 0) {
    return $([]);
  }
  return $(popupItems[selectedIndex] || []);
}

function resolveDropdownPopupItemByValue(widget, value) {
  const visibleItems = Array.isArray(widget?.vm?.filteredDataItems)
    ? widget.vm.filteredDataItems
    : (Array.isArray(widget?.vm?.dataItems) ? widget.vm.dataItems : []);
  const visibleIndex = visibleItems.findIndex((item) => String(getItemValue(item, widget?.options)) === String(value));
  return resolveDropdownPopupItem(widget, visibleIndex);
}

function resolveMultiSelectPopupItem(widget, value) {
  const dataItems = Array.isArray(widget?.vm?.filteredDataItems)
    ? widget.vm.filteredDataItems
    : (Array.isArray(widget?.vm?.dataItems) ? widget.vm.dataItems : []);
  const selectedIndex = dataItems.findIndex((item) => String(getItemValue(item, widget?.options)) === String(value));
  if (selectedIndex < 0) {
    return $([]);
  }
  return resolveDropdownPopupItem(widget, selectedIndex);
}

function replayDropDownSelection(widget, nextValue) {
  if (!widget || !widget.vm) {
    return nextValue;
  }
  const effectiveValue = resolveDropDownValue(nextValue, widget.vm.dataItems, widget.options);
  widget.vm.value = effectiveValue;
  syncOriginalValue(widget.originalElement, effectiveValue);
  const currentDataItem = findSelectedItem(widget.vm.dataItems, effectiveValue, widget.options);
  const selectedIndex = findSelectedIndex(widget.vm.dataItems, effectiveValue, widget.options);
  updateLegacySenderState(widget, {
    value: effectiveValue,
    text: getItemText(currentDataItem, widget.options),
    dataItem: currentDataItem,
    selectedIndex
  });
  syncCompatDataSource(widget.dataSource, widget.options?.dataSource, widget.vm.dataItems);
  if (widget.vm.opened) {
    schedulePopupMetadataSync(widget, "dropdown");
  }
  return effectiveValue;
}

function normalizeArrayValue(value) {
  return Array.isArray(value) ? [...value] : [];
}

function parseArrayOptionValue(value) {
  if (Array.isArray(value)) {
    return [...value];
  }
  if (value === undefined || value === null) {
    return [];
  }
  if (typeof value === "string") {
    const trimmed = value.trim();
    if (!trimmed) {
      return [];
    }
    try {
      const parsed = JSON.parse(trimmed);
      if (Array.isArray(parsed)) {
        return [...parsed];
      }
    } catch (_error) {
      // noop
    }
    if (trimmed.includes(",")) {
      return trimmed
        .split(",")
        .map((entry) => entry.trim())
        .filter((entry) => entry !== "");
    }
    return [trimmed];
  }
  return [value];
}

function getSelectedOptionValues(element) {
  if (!element || element.tagName?.toLowerCase?.() !== "select") {
    return [];
  }
  return Array.from(element.options || [])
    .filter((option) => option.selected)
    .map((option) => option.value)
    .filter((value) => value !== undefined && value !== null && String(value) !== "");
}

function resolveInitialMultiSelectValue(optionValue, element) {
  const parsedOptionValue = parseArrayOptionValue(optionValue);
  if (parsedOptionValue.length) {
    return parsedOptionValue;
  }
  return getSelectedOptionValues(element);
}

function resolveInitialDropDownValue(optionValue, element) {
  if (optionValue !== undefined) {
    return optionValue;
  }
  if (element?.value !== undefined && element.value !== null && String(element.value) !== "") {
    return element.value;
  }
  const field = resolveKendoDataBindValueField(element) || element?.getAttribute?.("name") || "";
  if (!field) {
    return "";
  }
  const dataItem = resolveKendoGridDataItemFromEditorElement(element);
  if (!dataItem) {
    return "";
  }
  const dataBindValue = dataItem[field];
  return dataBindValue === undefined || dataBindValue === null ? "" : dataBindValue;
}

function parseNumericValue(value) {
  if (value === undefined || value === null || value === "") {
    return null;
  }
  const parsed = Number(String(value).replace(/,/g, ""));
  return Number.isFinite(parsed) ? parsed : null;
}

function resolveKendoDataBindValueField(element) {
  const dataBind = element?.getAttribute?.("data-bind") || "";
  const matched = dataBind.match(/(?:^|[,;\s])value\s*:\s*([^,;\s}]+)/);
  return matched?.[1]?.trim?.() || "";
}

function resolveKendoGridDataItemFromEditorElement(element) {
  const row = element?.closest?.("tr");
  if (!row) {
    return null;
  }
  if (row.__ntssKendoDataItem) {
    return row.__ntssKendoDataItem;
  }
  const gridRoot = row.closest?.(".k-grid");
  const gridWidget = gridRoot ? $(gridRoot).data("kendoGrid") : null;
  if (gridWidget?.dataItem) {
    try {
      const item = gridWidget.dataItem(row);
      if (item) {
        return item;
      }
    } catch (_error) {
      // noop
    }
  }
  const uid = row.getAttribute?.("data-uid");
  if (uid && gridWidget?.dataSource) {
    try {
      const item = gridWidget.dataSource.getByUid?.(uid);
      if (item) {
        return item;
      }
    } catch (_error) {
      // noop
    }
    try {
      const view = gridWidget.dataSource.view?.() || [];
      return Array.from(view).find((item) => String(item?.uid || item?._uid || "") === String(uid)) || null;
    } catch (_error) {
      // noop
    }
  }
  return null;
}

function resolveInitialNumericDataBindValue(element) {
  const field = resolveKendoDataBindValueField(element);
  if (!field) {
    return null;
  }
  const dataItem = resolveKendoGridDataItemFromEditorElement(element);
  if (!dataItem) {
    return null;
  }
  return parseNumericValue(dataItem[field]);
}

function resolveInitialNumericValue(optionValue, element) {
  const optionNumericValue = parseNumericValue(optionValue);
  if (optionNumericValue !== null) {
    return optionNumericValue;
  }
  const elementValue = parseNumericValue(element?.value);
  if (elementValue !== null) {
    return elementValue;
  }
  return resolveInitialNumericDataBindValue(element);
}

function toUngroupedNumericTextBoxFormat(format, decimals) {
  if (typeof format !== "string") {
    return format;
  }
  const match = format.trim().match(/^[nN](\d*)$/);
  if (!match) {
    return format;
  }
  const decimalPlaces = match[1] === "" ? Number(decimals || 0) : Number(match[1]);
  const places = Number.isFinite(decimalPlaces) && decimalPlaces > 0 ? Math.trunc(decimalPlaces) : 0;
  return places > 0 ? `0.${"0".repeat(places)}` : "0";
}

function normalizeNumericTextBoxFormat(format, decimals) {
  if (typeof format !== "string") {
    return format;
  }
  const normalizedFormat = format.trim();
  const legacyFormat = normalizedFormat.match(/^\{0(?::([^}]+))?\}$/);
  if (legacyFormat) {
    // Vue2/jQuery Kendo の数値 format は "{0}" / "{0:##,#}" 形式。
    // Kendo Vue Native へそのまま渡すと "{02}" のように括弧が表示値へ混入するため、
    // 旧 wrapper の書式指定だけを Native 側の format へ変換する。
    return legacyFormat[1] ? toUngroupedNumericTextBoxFormat(legacyFormat[1], decimals) : undefined;
  }
  return toUngroupedNumericTextBoxFormat(format, decimals);
}

function normalizeNumericTextBoxValue(value) {
  return parseNumericValue(value);
}

function normalizeNumericTextBoxNumberOption(value) {
  const parsed = parseNumericValue(value);
  return parsed === null ? undefined : parsed;
}

function resolveNumericTextBoxFieldValidation(element) {
  const fieldName = resolveKendoDataBindValueField(element);
  if (!fieldName) {
    return null;
  }
  const gridRoot = element?.closest?.(".k-grid");
  const gridWidget = gridRoot ? $(gridRoot).data("kendoGrid") : null;
  const fields = gridWidget?.dataSource?.options?.schema?.model?.fields;
  const field = fields && fields[fieldName];
  return field?.validation || null;
}

function resolveNumericTextBoxNumberOption(options = {}, element = null, optionName = "") {
  const optionValue = normalizeNumericTextBoxNumberOption(options[optionName]);
  if (optionValue !== undefined) {
    return optionValue;
  }

  const attrNames = optionName === "min"
    ? ["min", "data-min", "aria-valuemin"]
    : optionName === "max"
      ? ["max", "data-max", "aria-valuemax"]
      : optionName === "step"
        ? ["step", "data-step"]
        : [optionName];

  for (const attrName of attrNames) {
    const attrValue = normalizeNumericTextBoxNumberOption(element?.getAttribute?.(attrName));
    if (attrValue !== undefined) {
      return attrValue;
    }
  }

  if (options.ignoreFieldValidationBounds) {
    return undefined;
  }

  const validation = resolveNumericTextBoxFieldValidation(element);
  const validationValue = normalizeNumericTextBoxNumberOption(validation?.[optionName]);
  return validationValue === undefined ? undefined : validationValue;
}

function resolveNumericTextBoxLoopBounds(options = {}) {
  const loopBounds = options.loopBounds;
  if (!loopBounds) {
    return null;
  }
  const min = normalizeNumericTextBoxNumberOption(loopBounds.min);
  const max = normalizeNumericTextBoxNumberOption(loopBounds.max);
  if (min === undefined || max === undefined) {
    return null;
  }
  return { min, max };
}

function isNonNegativeNumericTextBoxMin(min) {
  return min !== undefined && min !== null && Number.isFinite(Number(min)) && Number(min) >= 0;
}

/** min>=0 かつ max ありのとき、滚轮/箭头在边界循环（0↓→max、max↑→min） */
function resolveEffectiveNumericTextBoxLoopBounds(options = {}, min, max) {
  const explicit = resolveNumericTextBoxLoopBounds(options);
  if (explicit) {
    return explicit;
  }
  const resolvedMin = min !== undefined ? normalizeNumericTextBoxNumberOption(min) : undefined;
  const resolvedMax = max !== undefined ? normalizeNumericTextBoxNumberOption(max) : undefined;
  if (isNonNegativeNumericTextBoxMin(resolvedMin) && resolvedMax !== undefined) {
    return { min: resolvedMin, max: resolvedMax };
  }
  return null;
}

function getWidgetEffectiveNumericTextBoxLoopBounds(widget) {
  if (widget?._effectiveLoopBounds) {
    return widget._effectiveLoopBounds;
  }
  return resolveEffectiveNumericTextBoxLoopBounds(
    widget?.options || {},
    widget?.vm?.min,
    widget?.vm?.max
  );
}

function installNonNegativeNumericTextBoxInputGuard(input, min) {
  if (!input || !isNonNegativeNumericTextBoxMin(min)) {
    if (input?.__ntssNonNegativeGuardCleanup) {
      input.__ntssNonNegativeGuardCleanup();
    }
    return;
  }

  const guardKey = String(min);
  if (input.__ntssNonNegativeGuardKey === guardKey) {
    return;
  }
  if (input.__ntssNonNegativeGuardCleanup) {
    input.__ntssNonNegativeGuardCleanup();
  }

  const onKeydown = (event) => {
    if (event.key === "-" || event.key === "Subtract") {
      event.preventDefault();
    }
  };
  const onBeforeInput = (event) => {
    if (event.data === "-" || event.data === "−") {
      event.preventDefault();
    }
  };
  const onPaste = (event) => {
    const text = event.clipboardData?.getData?.("text") ?? "";
    if (/^\s*-/.test(text)) {
      event.preventDefault();
    }
  };

  input.addEventListener("keydown", onKeydown);
  input.addEventListener("beforeinput", onBeforeInput);
  input.addEventListener("paste", onPaste);
  input.__ntssNonNegativeGuardKey = guardKey;
  input.__ntssNonNegativeGuardCleanup = () => {
    input.removeEventListener("keydown", onKeydown);
    input.removeEventListener("beforeinput", onBeforeInput);
    input.removeEventListener("paste", onPaste);
    delete input.__ntssNonNegativeGuardKey;
    delete input.__ntssNonNegativeGuardCleanup;
  };
}

function clampNumericTextBoxValue(value, min, max) {
  if (value === null || value === undefined || value === "") {
    return value;
  }
  let nextValue = value;
  if (min !== undefined && nextValue < min) {
    nextValue = min;
  }
  if (max !== undefined && nextValue > max) {
    nextValue = max;
  }
  return nextValue;
}

function loopNumericTextBoxValue(value, min, max) {
  if (value === null || value === undefined || value === "") {
    return value;
  }
  if (value > max) {
    return min;
  }
  if (value < min) {
    return max;
  }
  return value;
}

/** 上下箭头・滚轮用：仅在边界处循环（2→1、1→8、7→8、8→1） */
function stepNumericTextBoxWithLoop(currentValue, step, direction, loopBounds) {
  const current = normalizeNumericTextBoxValue(currentValue) ?? loopBounds.min;
  const stepValue = normalizeNumericTextBoxNumberOption(step) ?? 1;
  if (direction > 0) {
    return current >= loopBounds.max ? loopBounds.min : current + stepValue;
  }
  return current <= loopBounds.min ? loopBounds.max : current - stepValue;
}

function normalizeNumericTextBoxBounds(value, min, max, loopBounds) {
  if (loopBounds) {
    return loopNumericTextBoxValue(value, loopBounds.min, loopBounds.max);
  }
  return clampNumericTextBoxValue(value, min, max);
}

function toPlainNumericText(value) {
  if (value === null || value === undefined || value === "") {
    return "";
  }
  const text = String(value).trim().replace(/,/g, "");
  if (!/[eE]/.test(text)) {
    return text;
  }

  const matched = text.match(/^([+-]?)(\d+)(?:\.(\d*))?[eE]([+-]?\d+)$/);
  if (!matched) {
    return text;
  }

  const [, sign, integerPart, fractionPart = "", exponentText] = matched;
  const exponent = Number(exponentText);
  if (!Number.isFinite(exponent)) {
    return text;
  }

  const digits = `${integerPart}${fractionPart}`;
  const decimalPosition = integerPart.length + exponent;
  if (decimalPosition <= 0) {
    return `${sign}0.${"0".repeat(Math.abs(decimalPosition))}${digits}`;
  }
  if (decimalPosition >= digits.length) {
    return `${sign}${digits}${"0".repeat(decimalPosition - digits.length)}`;
  }
  return `${sign}${digits.slice(0, decimalPosition)}.${digits.slice(decimalPosition)}`;
}

function formatNumericTextBoxValue(value) {
  return toPlainNumericText(value);
}

function isLegacyUngroupedDecimalFormat(format) {
  return typeof format === "string" && /^0\.0+$/.test(format.trim());
}

function resolveNumericTextBoxBlurDecimals(options = {}) {
  if (options.decimals !== undefined && options.decimals !== null) {
    const decimals = Number(options.decimals);
    if (Number.isFinite(decimals) && decimals >= 0) {
      return Math.trunc(decimals);
    }
  }
  const normalizedFormat = normalizeNumericTextBoxFormat(options.format, options.decimals);
  if (isLegacyUngroupedDecimalFormat(normalizedFormat)) {
    return normalizedFormat.slice(2).length;
  }
  return undefined;
}

function resolveNumericTextBoxRoundingMode(options = {}) {
  if (options.roundingMode === "down" || options.round === false) {
    return BigNumber.ROUND_DOWN;
  }
  if (options.roundingMode === "up") {
    return BigNumber.ROUND_UP;
  }
  return BigNumber.ROUND_HALF_UP;
}

function formatNumericTextBoxBlurDisplay(
  value,
  decimals,
  roundingMode = BigNumber.ROUND_HALF_UP,
  padDecimalPlaces = true
) {
  if (value === null || value === undefined || value === "") {
    return "";
  }
  const places = Number(decimals) || 0;
  const normalized = BigNumber(String(value).replace(/,/g, ""));
  if (!normalized.isFinite()) {
    return formatNumericTextBoxValue(value);
  }
  const truncated = normalized.decimalPlaces(places, roundingMode);
  return padDecimalPlaces ? truncated.toFixed(places) : truncated.toFixed();
}

function resolveNumericTextBoxKendoFormat(options = {}) {
  const normalizedFormat = normalizeNumericTextBoxFormat(options.format, options.decimals);
  if (isLegacyUngroupedDecimalFormat(normalizedFormat)) {
    return undefined;
  }
  return normalizedFormat;
}

function stripNumericInputCommas(input) {
  if (!input || typeof input.value !== "string" || !input.value.includes(",")) {
    return;
  }
  const selectionStart = input.selectionStart;
  const selectionEnd = input.selectionEnd;
  const stripped = input.value.replace(/,/g, "");
  const removed = input.value.length - stripped.length;
  input.value = stripped;
  if (selectionStart !== null && selectionEnd !== null) {
    const nextPos = Math.max(0, selectionStart - removed);
    input.setSelectionRange(nextPos, nextPos);
  }
}

function installNumericTextBoxCommaGuard(input) {
  if (!input || input.__ntssNumericCommaGuard) {
    return;
  }
  input.__ntssNumericCommaGuard = true;
  input.addEventListener("input", () => {
    stripNumericInputCommas(input);
  });
}

function applyNumericTextBoxBlurRounding(value, blurDecimals, roundingMode) {
  if (value === null || value === undefined || value === "") {
    return value;
  }
  if (blurDecimals === undefined) {
    return value;
  }
  return BigNumber(value).decimalPlaces(blurDecimals, roundingMode).toNumber();
}

function syncNumericTextBoxInputDisplay(input, value, blurDecimals, roundingMode, isFocused, padDecimalPlaces = true) {
  if (!input) {
    return;
  }
  if (isFocused) {
    input.value = formatNumericTextBoxValue(value);
    return;
  }
  input.value = formatNumericTextBoxBlurDisplay(value, blurDecimals, roundingMode, padDecimalPlaces);
}

function resolveNumericTextBoxInput(root) {
  return root?.querySelector?.("input.k-input-inner, input.k-input, input") || findVisibleInput(root);
}

function syncLegacyNumericTextBoxInput(input, sourceElement = null) {
  if (!input) {
    return;
  }
  input.setAttribute("type", "text");
  input.setAttribute("inputmode", "decimal");
  input.style.appearance = "textfield";
  input.style.MozAppearance = "textfield";
  const legacyTextAlign = sourceElement?.style?.textAlign;
  if (legacyTextAlign) {
    input.style.textAlign = legacyTextAlign;
  }
}

function syncFocusedNumericTextBoxInput(input, value) {
  if (!input || input.ownerDocument?.activeElement !== input) {
    return;
  }
  input.value = formatNumericTextBoxValue(value);
}

function decimalPlaces(value) {
  const text = String(value ?? "").replace(/,/g, "");
  const exponential = text.match(/^[+-]?\d+(?:\.(\d*))?[eE]([+-]?\d+)$/);
  if (exponential) {
    const fractionLength = exponential[1]?.length || 0;
    const exponent = Number(exponential[2]);
    return exponent < 0 ? Math.abs(exponent) + fractionLength : Math.max(fractionLength - exponent, 0);
  }
  const [, decimals = ""] = text.split(".");
  return decimals.length;
}

function addNumericTextBoxStep(value, step, direction) {
  const currentValue = normalizeNumericTextBoxValue(value) ?? 0;
  const stepValue = normalizeNumericTextBoxValue(step) ?? 1;
  const precision = Math.min(Math.max(decimalPlaces(currentValue), decimalPlaces(stepValue)), 20);
  return Number((currentValue + stepValue * direction).toFixed(precision));
}

function stepLegacyNumericTextBoxSpinner(widget, direction, nativeEvent = null) {
  if (!widget?.vm || widget.vm.disabled || widget.vm.readonly) {
    return;
  }
  const loopBounds = getWidgetEffectiveNumericTextBoxLoopBounds(widget);
  const input = resolveNumericTextBoxInput(widget.mountNode || widget.wrapper?.[0]);
  const displayedValue = normalizeNumericTextBoxValue(input?.value);
  const currentValue = displayedValue !== null ? displayedValue : widget.value();
  const nextValue = loopBounds
    ? stepNumericTextBoxWithLoop(currentValue, widget.vm.step, direction, loopBounds)
    : normalizeNumericTextBoxBounds(
      addNumericTextBoxStep(currentValue, widget.vm.step, direction),
      widget.vm.min,
      widget.vm.max,
      null
    );
  widget.value(nextValue);
  if (input) {
    input.value = formatNumericTextBoxValue(nextValue);
  }
  widget.trigger("spin", {
    event: nativeEvent,
    originalEvent: nativeEvent,
    target: nativeEvent?.target || null,
    value: nextValue
  });
  scheduleWidgetFrame(widget, () => {
    const latestInput = resolveNumericTextBoxInput(widget.mountNode || widget.wrapper?.[0]);
    const latestText = formatNumericTextBoxValue(widget.value());
    if (latestInput && latestInput.value !== latestText) {
      latestInput.value = latestText;
    }
  });
  if (loopBounds && !isKendoChangeSuppressed(widget)) {
    scheduleWidgetTimeout(widget, () => widget.trigger("change"), 0);
  }
}

function installLegacyNumericTextBoxSpinnerRepeat(widget) {
  const wrapper = widget?.wrapper?.[0] || widget?.mountNode;
  if (!widget || !wrapper || widget.__ntssLegacyNumericSpinnerRepeatInstalled) {
    return;
  }

  let initialTimer = null;
  let repeatTimer = null;
  let activeButton = null;
  let shouldSuppressReleaseClick = false;
  const ownerWindow = getElementOwnerWindow(wrapper);
  const captureOptions = { capture: true };
  const passiveCaptureOptions = { capture: true, passive: true };

  const clearTimers = () => {
    if (initialTimer !== null) {
      ownerWindow.clearTimeout(initialTimer);
      initialTimer = null;
    }
    if (repeatTimer !== null) {
      ownerWindow.clearInterval(repeatTimer);
      repeatTimer = null;
    }
    activeButton?.classList?.remove?.("k-selected", "k-state-selected");
    activeButton = null;
  };

  const resolveSpinnerButton = (target) => target?.closest?.(".k-spinner-increase, .k-spinner-decrease") || null;

  const triggerSpinnerButtonClick = (button, event) => {
    const direction = button?.classList?.contains?.("k-spinner-increase") ? 1 : -1;
    stepLegacyNumericTextBoxSpinner(widget, direction, event);
  };

  const keepNumericInputFocused = (event) => {
    const input = resolveNumericTextBoxInput(widget.mountNode || widget.wrapper?.[0]);
    // Vue2/jQuery Kendo は spinner の mousedown で input の blur を発生させない。
    // Vue3 Native では blur 側の change が先に走ると旧値で再同期され、
    // click 直後に値が初期値へ戻るため、共通層で旧 mousedown 契約を戻す。
    if (typeof event.preventDefault === "function" && event.cancelable !== false) {
      event.preventDefault();
    }
    if (input && input.ownerDocument?.activeElement !== input) {
      input.focus?.();
    }
  };

  const startRepeat = (event) => {
    if (event.type === "mousedown" && event.button !== 0) {
      return;
    }
    const button = resolveSpinnerButton(event.target);
    if (!button || button.disabled || widget.vm?.disabled || widget.vm?.readonly) {
      return;
    }

    keepNumericInputFocused(event);
    event.stopPropagation?.();
    clearTimers();

    activeButton = button;
    shouldSuppressReleaseClick = false;
    button.classList.add("k-selected", "k-state-selected");

    initialTimer = ownerWindow.setTimeout(() => {
      shouldSuppressReleaseClick = true;
      triggerSpinnerButtonClick(button, event);
      repeatTimer = ownerWindow.setInterval(() => {
        triggerSpinnerButtonClick(button, event);
      }, 50);
    }, 500);
  };

  const handleSpinnerClick = (event) => {
    const button = resolveSpinnerButton(event.target);
    if (!button) {
      return;
    }
    event.preventDefault();
    event.stopImmediatePropagation();
    if (shouldSuppressReleaseClick) {
      shouldSuppressReleaseClick = false;
      return;
    }
    triggerSpinnerButtonClick(button, event);
  };

  wrapper.addEventListener("mousedown", startRepeat, captureOptions);
  wrapper.addEventListener("touchstart", startRepeat, captureOptions);
  wrapper.addEventListener("click", handleSpinnerClick, captureOptions);
  ownerWindow.addEventListener("mouseup", clearTimers, captureOptions);
  ownerWindow.addEventListener("touchend", clearTimers, passiveCaptureOptions);
  ownerWindow.addEventListener("touchcancel", clearTimers, passiveCaptureOptions);
  ownerWindow.addEventListener("blur", clearTimers, captureOptions);

  widget.__ntssLegacyNumericSpinnerRepeatInstalled = true;
  registerWidgetCleanup(widget, () => {
    clearTimers();
    wrapper.removeEventListener("mousedown", startRepeat, captureOptions);
    wrapper.removeEventListener("touchstart", startRepeat, captureOptions);
    wrapper.removeEventListener("click", handleSpinnerClick, captureOptions);
    ownerWindow.removeEventListener("mouseup", clearTimers, captureOptions);
    ownerWindow.removeEventListener("touchend", clearTimers, passiveCaptureOptions);
    ownerWindow.removeEventListener("touchcancel", clearTimers, passiveCaptureOptions);
    ownerWindow.removeEventListener("blur", clearTimers, captureOptions);
    delete widget.__ntssLegacyNumericSpinnerRepeatInstalled;
  });
}

function installLoopNumericTextBoxWheel(widget, loopBounds) {
  if (!widget || !loopBounds) {
    return;
  }

  const bindLoopInputHandlers = () => {
    const input = resolveNumericTextBoxInput(widget.mountNode || widget.wrapper?.[0]);
    if (!input || widget.__ntssLoopWheelInput === input) {
      return;
    }
    widget.__ntssLoopWheelInput = input;
    let wheelHandled = false;
    // Kendo Vue NumericTextBox も onWheel で増減するため、capture で先に処理し二重ステップを防ぐ
    input.addEventListener("wheel", (event) => {
      if (input.ownerDocument?.activeElement !== input) {
        return;
      }
      if (wheelHandled) {
        event.preventDefault();
        event.stopImmediatePropagation();
        return;
      }
      wheelHandled = true;
      scheduleWidgetTimeout(widget, () => {
        wheelHandled = false;
      }, 0);
      event.preventDefault();
      event.stopPropagation();
      event.stopImmediatePropagation();
      const direction = event.deltaY < 0 ? 1 : -1;
      stepLegacyNumericTextBoxSpinner(widget, direction, event);
    }, { passive: false, capture: true });
    input.addEventListener("keydown", (event) => {
      if (input.ownerDocument?.activeElement !== input) {
        return;
      }
      if (event.keyCode !== 38 && event.keyCode !== 40) {
        return;
      }
      event.preventDefault();
      event.stopPropagation();
      event.stopImmediatePropagation();
      const direction = event.keyCode === 38 ? 1 : -1;
      stepLegacyNumericTextBoxSpinner(widget, direction, event);
    }, { capture: true });
  };

  bindLoopInputHandlers();
  scheduleWidgetTimeout(widget, bindLoopInputHandlers, 0);
  scheduleWidgetFrame(widget, bindLoopInputHandlers);
}

function syncNumericTextBoxOriginalValue(element, value, emit = false) {
  syncOriginalValue(element, formatNumericTextBoxValue(value), emit);
}

function diffSelection(previousValue, nextValue) {
  const previous = normalizeArrayValue(previousValue);
  const next = normalizeArrayValue(nextValue);
  const previousSet = new Set(previous.map((item) => String(item)));
  const nextSet = new Set(next.map((item) => String(item)));
  return {
    added: next.filter((item) => !previousSet.has(String(item))),
    removed: previous.filter((item) => !nextSet.has(String(item)))
  };
}

function limitMultiSelectValue(previousValue, nextValue, maxSelectedItems) {
  const normalizedNext = normalizeArrayValue(nextValue);
  const limit = Number(maxSelectedItems);
  if (!Number.isFinite(limit) || limit <= 0 || normalizedNext.length <= limit) {
    return normalizedNext;
  }
  const normalizedPrevious = normalizeArrayValue(previousValue);
  if (normalizedPrevious.length >= limit) {
    return normalizedPrevious.slice(0, limit);
  }
  return normalizedNext.slice(0, limit);
}

function findVisibleInput(root) {
  if (!root || typeof root.querySelector !== "function") {
    return null;
  }
  return root.querySelector("input, textarea, select, [contenteditable='true']");
}


function clickElement(element) {
  if (!element || typeof element.dispatchEvent !== "function") {
    return false;
  }
  const eventInit = { bubbles: true, cancelable: true, view: typeof window !== "undefined" ? window : undefined };
  try {
    element.dispatchEvent(new MouseEvent("mousedown", eventInit));
    element.dispatchEvent(new MouseEvent("mouseup", eventInit));
    element.dispatchEvent(new MouseEvent("click", eventInit));
    return true;
  } catch (_error) {
    try {
      element.click?.();
      return true;
    } catch (_innerError) {
      return false;
    }
  }
}

function focusWidgetInput(widget) {
  const focusTarget = findVisibleInput(widget?.mountNode) || widget?.wrapper?.[0] || widget?.mountNode || null;
  focusTarget?.focus?.();
  return focusTarget;
}

function isConnectedElement(element) {
  return !!element?.ownerDocument?.documentElement?.contains?.(element);
}

function readNumericZIndex(element) {
  if (!element) {
    return null;
  }
  const view = element.ownerDocument?.defaultView || null;
  const rawValue = element.style?.zIndex || view?.getComputedStyle?.(element)?.zIndex || "";
  const value = Number.parseInt(rawValue, 10);
  return Number.isFinite(value) ? value : null;
}

function resolveOwnerStackZIndex(widget) {
  const startElements = collectCompatTargets(
    widget?.mountNode,
    widget?.wrapper?.[0],
    widget?.element?.[0],
    widget?.originalElement
  );
  let maxZIndex = null;
  startElements.forEach((startElement) => {
    let current = startElement?.parentElement || startElement || null;
    while (current) {
      const value = readNumericZIndex(current);
      if (value !== null && (maxZIndex === null || value > maxZIndex)) {
        maxZIndex = value;
      }
      current = current.parentElement;
    }
  });
  return maxZIndex;
}

function syncLegacyPopupZIndex(widget, popupRoot = null, popupSurface = null) {
  const ownerZIndex = resolveOwnerStackZIndex(widget);
  if (ownerZIndex === null) {
    return null;
  }
  const currentPopupZIndex = Math.max(
    readNumericZIndex(popupRoot) ?? 0,
    readNumericZIndex(popupSurface) ?? 0
  );
  if (currentPopupZIndex > ownerZIndex) {
    return currentPopupZIndex;
  }
  const nextZIndex = ownerZIndex + 1;
  [popupRoot, popupSurface].forEach((element) => {
    element?.style?.setProperty?.("z-index", String(nextZIndex), "important");
  });
  return nextZIndex;
}

function getWidgetPopup(widget) {
  const cachedPopup = popupMetadataByWidget.get(widget)?.root || null;
  if (isConnectedElement(cachedPopup)) {
    return cachedPopup;
  }
  return findPopupByListBoxId(widget, getListBoxIdFromWidget(widget));
}

function getPopupListElement(widget) {
  const popup = getWidgetPopup(widget);
  const listBoxId = getListBoxIdFromWidget(widget);
  if (!popup) {
    return null;
  }
  return getPopupListBoxElement(widget, popup, listBoxId);
}

function setWidgetPopupOpenState(widget, opened) {
  if (widget?.vm && Object.prototype.hasOwnProperty.call(widget.vm, "opened")) {
    widget.vm.opened = opened;
  }
}

function closeWidgetPopup(widget) {
  const popup = getWidgetPopup(widget);
  const wrapperElement = widget?.wrapper?.[0] || widget?.mountNode || null;
  const controlled = queryWithin(wrapperElement, ["[aria-controls]", "[role='combobox']"]);

  // popup の表示/非表示そのものは Kendo/Vue component の opened state に任せる。
  // runtime は Vue2 wrapper と同じく close API と aria 互換だけを担当する。
  setWidgetPopupOpenState(widget, false);
  if (popup) {
    popup.setAttribute("aria-hidden", "true");
  }
  if (controlled) {
    controlled.setAttribute("aria-expanded", "false");
  }
  findVisibleInput(widget?.mountNode)?.blur?.();
  return popup;
}

function openWidgetPopup(widget, role) {
  focusWidgetInput(widget);
  const wrapperElement = widget?.wrapper?.[0] || widget?.mountNode || null;
  const trigger = queryWithin(wrapperElement, [".k-input-button", ".k-select", "button[aria-label='select']"]);
  const clicked = clickElement(trigger);
  setWidgetPopupOpenState(widget, true);
  schedulePopupMetadataSync(widget, role);
  if (role === "multiselect") {
    scheduleLegacyKendoDomFacade(widget, "multiselect");
  } else if (role === "dropdown") {
    scheduleLegacyKendoDomFacade(widget, "dropdown");
  }
  return clicked || true;
}

function preservePopupOpenState(widget, role, wasOpen) {
  if (!wasOpen) {
    return;
  }
  const apply = () => {
    if (!widget?.mountNode?.ownerDocument?.documentElement?.contains?.(widget.mountNode)) {
      return;
    }
    setWidgetPopupOpenState(widget, true);
    schedulePopupMetadataSync(widget, role);
    scheduleLegacyKendoDomFacade(widget, role);
  };
  scheduleWidgetFrame(widget, apply);
}

function copyCommonAttributes(sourceEl, targetEl) {
  if (!sourceEl || !targetEl) {
    return;
  }
  const cls = sourceEl.getAttribute("class");
  const style = sourceEl.getAttribute("style");
  const dir = sourceEl.getAttribute("dir");
  if (cls) {
    targetEl.setAttribute("class", cls);
  }
  if (style) {
    targetEl.setAttribute("style", style);
  }
  if (dir) {
    targetEl.setAttribute("dir", dir);
  }
}



function isInputLikeElement(element) {
  if (!element || !element.tagName) {
    return false;
  }
  const tagName = String(element.tagName).toLowerCase();
  return tagName === "input" || tagName === "textarea" || tagName === "select";
}

function queryWithin(root, selectors) {
  if (!root || typeof root.querySelector !== "function") {
    return null;
  }
  for (const selector of selectors) {
    const found = root.querySelector(selector);
    if (found) {
      return found;
    }
  }
  return null;
}

function queryAllWithin(root, selectors) {
  if (!root || typeof root.querySelectorAll !== "function") {
    return [];
  }
  const found = [];
  selectors.forEach((selector) => {
    root.querySelectorAll(selector).forEach((element) => {
      if (!found.includes(element)) {
        found.push(element);
      }
    });
  });
  return found;
}

function collectCompatTargets(...candidates) {
  const result = [];
  candidates.flat(Infinity).forEach((candidate) => {
    if (candidate && !result.includes(candidate)) {
      result.push(candidate);
    }
  });
  return result;
}

function getListBoxIdFromWidget(widget) {
  const wrapperElement = widget?.wrapper?.[0] || widget?.mountNode?.firstElementChild || widget?.mountNode || null;
  const controlled = queryWithin(wrapperElement, ["[aria-controls]", "[aria-owns]", "[role='combobox']"]);
  return controlled?.getAttribute?.("aria-controls")
    || controlled?.getAttribute?.("aria-owns")
    || null;
}

function getLegacyWidgetSourceId(widget) {
  return widget?.originalElement?.id || widget?.options?.id || null;
}

function getLegacyWidgetPopupId(widget) {
  const sourceId = getLegacyWidgetSourceId(widget);
  return sourceId ? `${sourceId}-list` : null;
}

function getLegacyWidgetListBoxId(widget) {
  const sourceId = getLegacyWidgetSourceId(widget);
  // Vue2 Kendo DropDownList uses "<input-id>_listbox" for aria-owns/aria-controls.
  // Keep the old id separate from the popup surface id ("<input-id>-list"),
  // because page-side legacy code still targets #sijisya-list while ARIA points at #sijisya_listbox.
  return sourceId ? `${sourceId}_listbox` : getListBoxIdFromWidget(widget);
}

function rememberNativeWidgetListBoxId(widget, wrapperElement = null) {
  if (!widget || widget.__ntssNativeListBoxId) {
    return widget?.__ntssNativeListBoxId || null;
  }
  const controlled = queryWithin(wrapperElement || widget?.wrapper?.[0] || widget?.mountNode, ["[aria-controls]", "[aria-owns]", "[role='combobox']"]);
  const nativeListBoxId = controlled?.getAttribute?.("aria-controls") || controlled?.getAttribute?.("aria-owns") || null;
  if (nativeListBoxId && nativeListBoxId !== getLegacyWidgetListBoxId(widget)) {
    try {
      Object.defineProperty(widget, "__ntssNativeListBoxId", {
        configurable: true,
        enumerable: false,
        writable: true,
        value: nativeListBoxId
      });
    } catch (_error) {
      widget.__ntssNativeListBoxId = nativeListBoxId;
    }
  }
  return widget.__ntssNativeListBoxId || null;
}

function syncLegacyWidgetListBoxId(widget, listBox = null) {
  const legacyListBoxId = getLegacyWidgetListBoxId(widget);
  if (!legacyListBoxId) {
    return null;
  }
  if (listBox?.setAttribute) {
    listBox.setAttribute("id", legacyListBoxId);
  }
  const wrapperElement = widget?.wrapper?.[0] || widget?.mountNode?.firstElementChild || widget?.mountNode || null;
  const controlled = queryWithin(wrapperElement, ["[role='combobox']", "[aria-controls]", "[aria-owns]"]);
  if (controlled?.setAttribute) {
    controlled.setAttribute("aria-controls", legacyListBoxId);
    controlled.setAttribute("aria-owns", legacyListBoxId);
  }
  return legacyListBoxId;
}

function syncLegacyWidgetPopupId(widget, popupSurface = null, popupRoot = null) {
  const legacyPopupId = getLegacyWidgetPopupId(widget);
  if (!legacyPopupId) {
    return null;
  }
  const target = popupSurface || popupRoot || null;
  if (target?.setAttribute) {
    target.setAttribute("id", legacyPopupId);
  }
  return legacyPopupId;
}

function getWidgetOwnerDocument(widget) {
  return widget?.mountNode?.ownerDocument
    || widget?.wrapper?.[0]?.ownerDocument
    || null;
}

function getWidgetPopupSearchRoots(widget) {
  const mountNode = widget?.mountNode || widget?.wrapper?.[0] || null;
  const ownerDocument = getWidgetOwnerDocument(widget);
  return collectCompatTargets(
    popupMetadataByWidget.get(widget)?.root || null,
    popupSearchRootByWidget.get(widget) || null,
    mountNode || null,
    mountNode?.parentElement || null,
    ownerDocument?.body || null,
    ownerDocument || null
  );
}

function queryElementsById(root, id) {
  if (!root || !id) {
    return [];
  }
  let escaped = null;
  try {
    if (typeof CSS !== "undefined" && typeof CSS.escape === "function") {
      escaped = CSS.escape(id);
    }
  } catch (_error) {
    escaped = null;
  }
  const result = [];
  const push = (candidate) => {
    if (candidate && (!root.contains || root.contains(candidate) || root === candidate || root.nodeType === 9) && !result.includes(candidate)) {
      result.push(candidate);
    }
  };
  if (typeof root.getElementById === "function") {
    push(root.getElementById(id));
  }
  const literal = String(id).replace(/"/g, '\\"');
  const selector = `${escaped ? `#${escaped}, ` : ''}[id="${literal}"]`;
  root.querySelectorAll?.(selector)?.forEach?.(push);
  return result;
}

function queryElementById(root, id) {
  const matches = queryElementsById(root, id);
  const connected = matches.filter((element) => element?.ownerDocument?.documentElement?.contains?.(element));
  const candidates = connected.length ? connected : matches;
  return candidates[candidates.length - 1] || null;
}

function resolvePopupContainerFromListBox(listBox, roots = []) {
  if (!listBox) {
    return null;
  }
  const scopedPopupSurface = listBox.closest?.('.k-popup, .k-list-container');
  const scopedPopupRoot = scopedPopupSurface?.closest?.('.k-animation-container')
    || listBox.closest?.('.k-animation-container')
    || scopedPopupSurface;
  if (scopedPopupRoot) {
    return scopedPopupRoot;
  }
  let candidate = listBox;
  const scopedRoots = roots.filter(Boolean);
  const boundary = scopedRoots.find((root) => root !== listBox && root.contains?.(listBox)) || null;
  if (!boundary) {
    return listBox.parentElement || listBox;
  }
  while (candidate?.parentElement && candidate.parentElement !== boundary) {
    candidate = candidate.parentElement;
  }
  return candidate || listBox;
}

function findPopupByListBoxId(widgetOrListBoxId, maybeListBoxId = null) {
  const widget = widgetOrListBoxId && typeof widgetOrListBoxId === 'object' ? widgetOrListBoxId : null;
  const listBoxId = widget ? (maybeListBoxId || getListBoxIdFromWidget(widget)) : widgetOrListBoxId;
  if (!listBoxId) {
    return null;
  }
  const roots = widget ? getWidgetPopupSearchRoots(widget) : [];
  const matches = [];
  roots.forEach((root) => {
    queryElementsById(root, listBoxId).forEach((element) => {
      if (!matches.includes(element)) {
        matches.push(element);
      }
    });
  });
  const connected = matches.filter((element) => element?.ownerDocument?.documentElement?.contains?.(element));
  const candidates = connected.length ? connected : matches;
  const listBox = candidates[candidates.length - 1] || null;
  if (!listBox) {
    return popupMetadataByWidget.get(widget)?.root || null;
  }
  return resolvePopupContainerFromListBox(listBox, roots) || popupMetadataByWidget.get(widget)?.root || listBox;
}

function getPopupListBoxElement(widget, popup, listBoxId = null) {
  const cachedListBox = popupMetadataByWidget.get(widget)?.listBox || null;
  if (isConnectedElement(cachedListBox)) {
    return cachedListBox;
  }
  // popup が入れ子になった場合、先頭 listbox ではなく現在 widget の aria-controls/listbox id を優先する。
  const byId = listBoxId ? queryElementById(popup, listBoxId) : null;
  if (byId?.matches?.("[role='listbox'], ul")) {
    return byId;
  }
  const nestedById = byId && byId !== popup
    ? queryWithin(byId, ["[role='listbox']", "ul"])
    : null;
  if (nestedById) {
    return nestedById;
  }
  return popup?.querySelector?.("[role='listbox'], ul") || null;
}

function getPopupSurfaceElement(widget, popup, listBox = null) {
  const cachedSurface = popupMetadataByWidget.get(widget)?.surface || null;
  if (isConnectedElement(cachedSurface)) {
    return cachedSurface;
  }
  const scopedSurface = listBox?.closest?.('.k-popup, .k-list-container') || null;
  return (scopedSurface && scopedSurface !== popup ? scopedSurface : null)
    || (listBox?.parentElement && listBox.parentElement !== popup ? listBox.parentElement : null)
    || popup?.firstElementChild
    || popup
    || null;
}

function isScrollableElement(element) {
  if (!element) {
    return false;
  }
  const ownerDocument = element.ownerDocument || null;
  const view = ownerDocument?.defaultView || null;
  const style = view?.getComputedStyle?.(element) || null;
  const overflowY = style?.overflowY || style?.overflow || '';
  return /(auto|scroll)/.test(overflowY) || ((element.scrollHeight || 0) > ((element.clientHeight || 0) + 1));
}

function findScrollablePopupContainer(startElement, popup) {
  let current = startElement || null;
  while (current && current !== popup) {
    if (isScrollableElement(current)) {
      return current;
    }
    current = current.parentElement;
  }
  if (popup && isScrollableElement(popup)) {
    return popup;
  }
  return null;
}

function collectPopupItems(popup, listBox = null) {
  const itemRoot = listBox || popup;
  return Array.from(itemRoot?.querySelectorAll?.("[role='option'], li") || []);
}


function collectLegacyPopupOwnerClasses(widget) {
  const mountNode = widget?.mountNode || widget?.wrapper?.[0] || null;
  const classes = new Set();
  const scopeAttributes = new Set();
  let current = mountNode?.parentElement || null;
  let depth = 0;
  while (current && depth < 10) {
    const tagName = String(current.tagName || '').toLowerCase();
    if (tagName === 'body' || tagName === 'html') {
      break;
    }
    Array.from(current.classList || []).forEach((className) => {
      if (!className || className.startsWith('k-') || className.startsWith('v-') || className.startsWith('ntss-kendo-popup-owner-')) {
        return;
      }
      classes.add(className);
    });
    Array.from(current.attributes || []).forEach((attribute) => {
      if (/^data-v-/.test(attribute.name)) {
        scopeAttributes.add(attribute.name);
      }
    });
    current = current.parentElement;
    depth += 1;
  }
  return { classes: Array.from(classes), scopeAttributes: Array.from(scopeAttributes) };
}

function toPopupOwnerClassName(className) {
  return `ntss-kendo-popup-owner-${String(className).replace(/[^a-zA-Z0-9_-]/g, '-')}`;
}

function syncLegacyPopupOwnerScope(widget, popup, popupSurface, listBox, items = [], role = '') {
  const popupRoot = popup || popupSurface || listBox?.parentElement || listBox || null;
  if (!popupRoot?.classList) {
    return;
  }

  // Vue2 wrapper では popup/listbox が画面の scoped CSS と同じ owner で扱われていた。
  // Vue3/Kendo Native で body portal になっても、owner class と scoped attribute を popup 側へ写して
  // 画面側の旧 selector（例: .multi-pat-list >>> .k-popup）の意味を維持する。
  const { classes, scopeAttributes } = collectLegacyPopupOwnerClasses(widget);
  classes.forEach((className) => {
    popupRoot.classList.add(className);
    popupRoot.classList.add(toPopupOwnerClassName(className));
  });
  scopeAttributes.forEach((attributeName) => popupRoot.setAttribute(attributeName, ''));

  const surface = popupSurface || popupRoot;
  addClasses(popupRoot, ['k-animation-container', 'ntss-kendo-dropdown-popup-legacy']);
  addClasses(surface, ['k-popup', 'k-group', 'k-list-container', 'k-reset']);
  addClasses(listBox, ['k-list', 'k-reset']);

  if (role === 'dropdown') {
    addClasses(popupRoot, ['ntss-kendo-dropdownlist-popup-legacy']);
    addClasses(surface, ['k-dropdownlist-popup']);
  } else if (role === 'multiselect') {
    addClasses(popupRoot, ['ntss-kendo-multiselect-popup-legacy']);
    addClasses(surface, ['k-multiselect-popup']);
  }

  items.forEach((item) => {
    addClasses(item, ['k-item']);
    syncClass(item, 'k-state-selected', item.getAttribute?.('aria-selected') === 'true' || item.classList?.contains?.('k-selected'));
    syncClass(item, 'k-state-focused', item.classList?.contains?.('k-focus') || item.classList?.contains?.('k-focused'));
    syncClass(item, 'k-state-disabled', item.getAttribute?.('aria-disabled') === 'true' || item.classList?.contains?.('k-disabled'));
  });
}

function schedulePopupMetadataSync(widget, role) {
  const mountNode = widget?.mountNode || widget?.element?.[0] || widget?.input?.[0] || null;
  const ownerDocument = mountNode?.ownerDocument || (typeof document !== "undefined" ? document : null);
  if (!mountNode || !ownerDocument?.documentElement?.contains?.(mountNode)) {
    return;
  }
  scheduleWidgetFrame(widget, () => {
    if (!ownerDocument?.documentElement?.contains?.(mountNode)) {
      return;
    }
    syncPopupMetadata(widget, role);
  });
}

function syncPopupMetadata(widget, _role) {
  const currentListBoxId = getListBoxIdFromWidget(widget);
  const nativeListBoxId = widget?.__ntssNativeListBoxId || null;
  const legacyListBoxIdCandidate = getLegacyWidgetListBoxId(widget);
  const listBoxIdCandidates = [currentListBoxId, nativeListBoxId, legacyListBoxIdCandidate].filter(Boolean);
  let popup = null;
  let resolvedListBoxId = null;
  for (const listBoxId of listBoxIdCandidates) {
    popup = findPopupByListBoxId(widget, listBoxId);
    if (popup) {
      resolvedListBoxId = listBoxId;
      break;
    }
  }
  if (!popup) {
    return;
  }
  const listBox = getPopupListBoxElement(widget, popup, resolvedListBoxId);
  const legacyListBoxId = syncLegacyWidgetListBoxId(widget, listBox);
  const popupSurface = getPopupSurfaceElement(widget, popup, listBox);
  syncLegacyWidgetPopupId(widget, popupSurface, popup);
  const scroller = popupMetadataByWidget.get(widget)?.scroller
    || findScrollablePopupContainer(listBox, popup)
    || (popupSurface !== popup && isScrollableElement(popupSurface) ? popupSurface : null);
  addClasses(scroller, ["k-list-scroller"]);
  if (legacyListBoxId && listBox && popupSurface && popupSurface !== listBox) {
    // Vue2 had #<id>-list as the popup/list surface and #<id>_listbox as the actual listbox.
    // Keep both so old page code and Kendo ARIA selectors resolve to the same owner chain.
    popupSurface.setAttribute?.("aria-owns", legacyListBoxId);
  }
  const items = collectPopupItems(popup, listBox);
  popupMetadataByWidget.set(widget, {
    root: popup,
    surface: popupSurface || null,
    listBox: listBox || null,
    scroller: scroller || null,
    items
  });
  syncLegacyPopupOwnerScope(widget, popup, popupSurface, listBox, items, _role);
  syncLegacyPopupZIndex(widget, popup, popupSurface);
  syncKendoPopupWidgetRefs(widget, widget?.mountNode || widget?.wrapper?.[0] || null);
}

// DropDownList / MultiSelect の画面側 selector は Vue2 の旧 class 名を維持する。
// Kendo Native の内部 DOM 差分は runtime 側で旧 facade class を付与して吸収する。






function snapshotPresentationAttributes(element) {
  if (!element) {
    return { className: undefined, style: undefined, dir: undefined, id: undefined, name: undefined };
  }
  return {
    className: element.getAttribute("class") || undefined,
    style: element.getAttribute("style") || undefined,
    dir: element.getAttribute("dir") || undefined,
    id: element.id || undefined,
    name: element.getAttribute("name") || undefined
  };
}

function parseStyleAttribute(styleText) {
  if (!styleText) {
    return undefined;
  }
  const ownerDocument = typeof document !== "undefined" ? document : null;
  const scratch = ownerDocument?.createElement?.("div");
  if (!scratch) {
    return undefined;
  }
  scratch.setAttribute("style", styleText);
  const style = {};
  Array.from(scratch.style || []).forEach((name) => {
    style[name] = scratch.style.getPropertyValue(name);
  });
  return Object.keys(style).length ? style : undefined;
}

function isWidgetSourceElement(element) {
  return ["INPUT", "SELECT", "TEXTAREA"].includes(element?.tagName);
}

function resolveWidgetSourceElement(element, tagName = "input", attributes = {}) {
  const original = element?.jquery ? element[0] : element;
  if (!original) {
    return null;
  }
  if (isWidgetSourceElement(original)) {
    if (attributes.name && !original.getAttribute("name")) {
      original.setAttribute("name", attributes.name);
    }
    if (attributes.className && !original.getAttribute("class")) {
      original.setAttribute("class", attributes.className);
    }
    if (attributes.placeholder && original.tagName === "INPUT" && !original.getAttribute("placeholder")) {
      original.setAttribute("placeholder", attributes.placeholder);
    }
    if (attributes.multiple && original.tagName === "SELECT") {
      original.multiple = true;
    }
    return original;
  }

  const normalizedTag = String(tagName || "input").toLowerCase();
  const ownerDocument = original.ownerDocument || (typeof document !== "undefined" ? document : null);
  let sourceMap = sourceElementsByOriginal.get(original);
  if (!sourceMap) {
    sourceMap = new Map();
    sourceElementsByOriginal.set(original, sourceMap);
  }
  let source = sourceMap.get(normalizedTag) || null;
  if (!source || source.parentElement !== original) {
    source = Array.from(original.children || []).find((child) => String(child?.tagName || "").toLowerCase() === normalizedTag) || null;
  }
  if (!source && ownerDocument) {
    source = ownerDocument.createElement(normalizedTag);
    if (attributes.multiple && normalizedTag === "select") {
      source.multiple = true;
    }
    original.appendChild(source);
  }
  sourceMap.set(normalizedTag, source);
  if (attributes.name) {
    source.setAttribute("name", attributes.name);
  }
  if (attributes.className) {
    source.setAttribute("class", attributes.className);
  }
  if (attributes.placeholder && normalizedTag === "input") {
    source.setAttribute("placeholder", attributes.placeholder);
  }
  return source;
}

function createMountNode(originalElement) {
  const ownerDocument = originalElement?.ownerDocument || (typeof document !== "undefined" ? document : null);
  if (!ownerDocument) {
    return null;
  }
  const mountNode = ownerDocument.createElement("div");
  copyCommonAttributes(originalElement, mountNode);
  originalElement.parentNode?.insertBefore(mountNode, originalElement);
  originalElement.style.display = "none";
  return mountNode;
}

function destroyMountedWidget(originalElement) {
  if (!originalElement) {
    return;
  }
  const holder = nativeWidgetHolders.get(originalElement);
  if (!holder) {
    return;
  }
  if (holder.destroying) {
    return;
  }
  holder.destroying = true;
  runWidgetCleanups(holder.widget);
  cleanupWidgetPopupArtifacts(holder.widget);
  try {
    holder.app?.unmount?.();
  } catch (_error) {
    // noop
  }
  const keys = LEGACY_WIDGET_DATA_KEYS[holder.type] || [];
  [originalElement, holder.mountNode, holder.wrapper, holder.widget?.wrapper?.[0], holder.widget?.element?.[0]].forEach((target) => {
    removeJQueryWidgetData(target, keys);
  });
  holder.wrapper?.remove?.();
  holder.mountNode?.remove?.();
  nativeWidgetHolders.delete(originalElement);
}

function invokeHandler(handler, widget, event) {
  if (typeof handler === "function") {
    return handler.call(widget, event);
  }
  return undefined;
}

function normalizeWidgetEventNames(eventName) {
  if (Array.isArray(eventName)) {
    return eventName.flatMap((name) => normalizeWidgetEventNames(name));
  }
  return String(eventName || "")
    .split(/\s+/)
    .map((name) => name.trim())
    .filter(Boolean);
}

function installLegacyWidgetObservable(widget) {
  if (!widget || widget.__ntssLegacyObservableInstalled) {
    return widget;
  }

  const handlers = new Map();
  const originalTrigger = typeof widget.trigger === "function" ? widget.trigger.bind(widget) : null;

  const addHandler = (eventName, handler, options = {}) => {
    if (typeof handler !== "function") {
      return widget;
    }
    normalizeWidgetEventNames(eventName).forEach((name) => {
      const bucket = handlers.get(name) || [];
      const entry = { handler, once: options.once === true, first: options.first === true };
      if (options.first === true) {
        bucket.unshift(entry);
      } else {
        bucket.push(entry);
      }
      handlers.set(name, bucket);
    });
    return widget;
  };

  widget.bind = function bind(eventName, handler) {
    if (eventName && typeof eventName === "object" && !Array.isArray(eventName)) {
      Object.entries(eventName).forEach(([name, fn]) => addHandler(name, fn));
      return widget;
    }
    return addHandler(eventName, handler);
  };

  widget.one = function one(eventName, handler) {
    return addHandler(eventName, handler, { once: true });
  };

  widget.first = function first(eventName, handler) {
    return addHandler(eventName, handler, { first: true });
  };

  widget.unbind = function unbind(eventName, handler) {
    if (!eventName) {
      handlers.clear();
      return widget;
    }
    normalizeWidgetEventNames(eventName).forEach((name) => {
      if (typeof handler !== "function") {
        handlers.delete(name);
        return;
      }
      const nextHandlers = (handlers.get(name) || []).filter((entry) => entry.handler !== handler);
      if (nextHandlers.length) {
        handlers.set(name, nextHandlers);
      } else {
        handlers.delete(name);
      }
    });
    return widget;
  };

  widget.trigger = function trigger(eventName, rawEvent = null) {
    const event = rawEvent && typeof rawEvent === "object" ? rawEvent : { type: eventName, sender: widget };
    const name = String(eventName || event?.type || "");
    const bucket = handlers.get(name);
    const remaining = [];
    const invokeEntry = (entry, eventObject) => {
      try {
        entry.handler.call(widget, eventObject);
      } catch (_error) {
        // Keep Kendo's legacy event chain tolerant.  The caller side still
        // owns explicit validation/business errors.
      }
      if (!entry.once) {
        remaining.push(entry);
      }
    };
    const entries = bucket ? bucket.slice() : [];
    entries.filter((entry) => entry.first).forEach((entry) => invokeEntry(entry, event));
    const triggeredEvent = originalTrigger ? originalTrigger(eventName, event) : event;
    const dispatchedEvent = triggeredEvent && typeof triggeredEvent === "object" ? triggeredEvent : event;
    entries.filter((entry) => !entry.first).forEach((entry) => invokeEntry(entry, dispatchedEvent));
    if (bucket && remaining.length) {
      handlers.set(name, remaining);
    } else if (bucket) {
      handlers.delete(name);
    }
    return triggeredEvent;
  };

  widget.__ntssLegacyObservableInstalled = true;
  return widget;
}

function defineWidgetData(originalElement, key, widget) {
  ensureLegacyWidgetResize(widget);
  const holder = nativeWidgetHolders.get(originalElement);
  const targets = [
    originalElement,
    holder?.mountNode,
    holder?.wrapper,
    widget?.wrapper?.[0],
    widget?.element?.[0],
  ];
  targets.forEach((target) => {
    defineJQueryWidgetData(target, key, widget);
  });
  if (widget && !widget.destroyed) {
    defineWritableWidgetProperty(widget, "element", widget.element || $(originalElement));
    defineWritableWidgetProperty(widget, "wrapper", widget.wrapper || $(holder?.mountNode || originalElement));
    defineWritableWidgetProperty(widget, "originalElement", widget.originalElement || originalElement);
  }
  return $(originalElement);
}

function ensureLegacyWidgetResize(widget) {
  if (!widget || typeof widget.resize === "function") {
    return widget;
  }
  widget.resize = function resize() {
    if (typeof this.refresh === "function") {
      this.refresh();
    }
    return this;
  };
  return widget;
}

function defineWritableWidgetProperty(widget, propertyName, value) {
  if (!widget || widget[propertyName]) {
    return;
  }
  try {
    widget[propertyName] = value;
  } catch (_error) {
    try {
      Object.defineProperty(widget, propertyName, {
        configurable: true,
        enumerable: true,
        value,
        writable: true
      });
    } catch (_defineError) {
      // Some Kendo objects expose read-only accessors; their existing getter value is enough.
    }
  }
}

function syncOriginalValue(originalElement, value, emit = false) {
  if (!originalElement) {
    return;
  }
  if (Array.isArray(value)) {
    const selected = new Set(value.map((item) => String(item)));
    Array.from(originalElement.options || []).forEach((option) => {
      option.selected = selected.has(String(option.value));
    });
  } else {
    originalElement.value = value ?? "";
  }
  if (!emit) {
    return;
  }
  try {
    originalElement.dispatchEvent(new Event("input", { bubbles: true }));
    originalElement.dispatchEvent(new Event("change", { bubbles: true }));
  } catch (_error) {
    // noop
  }
  try {
    $(originalElement).trigger("input");
    $(originalElement).trigger("change");
  } catch (_error) {
    // noop
  }
}

function resolveOriginalDropDownListPlugin() {
  const currentPlugin = $.fn.kendoDropDownList;
  if (typeof originalDropDownListPlugin === "function") {
    return originalDropDownListPlugin;
  }
  if (typeof currentPlugin?.__compatOriginal === "function") {
    originalDropDownListPlugin = currentPlugin.__compatOriginal;
    return originalDropDownListPlugin;
  }
  if (currentPlugin && Object.prototype.hasOwnProperty.call(currentPlugin, "__compatOriginal")) {
    return null;
  }
  if (typeof currentPlugin === "function") {
    originalDropDownListPlugin = currentPlugin;
    return originalDropDownListPlugin;
  }
  return null;
}

function restoreJQueryDropDownListSourceId(sourceElement) {
  if (!sourceElement) {
    return null;
  }
  const sourceId = sourceElement.dataset?.ntssKendoDropdownlistSourceId || sourceElement.getAttribute?.("data-ntss-kendo-dropdownlist-source-id") || null;
  if (sourceId && sourceElement.id !== sourceId) {
    sourceElement.id = sourceId;
  }
  return sourceId || sourceElement.id || null;
}

function parsePresentationStyleNames(styleText, ownerDocument = typeof document !== "undefined" ? document : null) {
  if (!styleText || !ownerDocument?.createElement) {
    return [];
  }
  const scratch = ownerDocument.createElement("div");
  scratch.setAttribute("style", styleText);
  return Array.from(scratch.style || []).filter((name) => name && name !== "display");
}

function applyPresentationStyle(sourceElement, wrapperElement, widget) {
  if (!sourceElement || !wrapperElement) {
    return;
  }
  const ownerDocument = sourceElement.ownerDocument || wrapperElement.ownerDocument || (typeof document !== "undefined" ? document : null);
  const styleText = sourceElement.getAttribute?.("style") || "";
  const nextStyleNames = parsePresentationStyleNames(styleText, ownerDocument);
  const previousStyleNames = Array.isArray(widget?.__ntssJQueryDropDownListStyleNames)
    ? widget.__ntssJQueryDropDownListStyleNames
    : [];
  previousStyleNames
    .filter((name) => !nextStyleNames.includes(name))
    .forEach((name) => wrapperElement.style?.removeProperty?.(name));
  if (ownerDocument?.createElement && styleText) {
    const scratch = ownerDocument.createElement("div");
    scratch.setAttribute("style", styleText);
    nextStyleNames.forEach((name) => {
      const value = scratch.style.getPropertyValue(name);
      const priority = scratch.style.getPropertyPriority(name);
      if (value !== undefined && value !== null && value !== "") {
        wrapperElement.style?.setProperty?.(name, value, priority || undefined);
      }
    });
  }
  if (widget) {
    widget.__ntssJQueryDropDownListStyleNames = nextStyleNames;
  }
}


function isTransparentBackgroundColor(value) {
  if (value === undefined || value === null) {
    return true;
  }
  const normalized = String(value).trim().replace(/\s+/g, " ").toLowerCase();
  if (!normalized || normalized === "transparent") {
    return true;
  }
  const rgbaMatch = normalized.match(/^rgba?\((.+)\)$/);
  if (rgbaMatch) {
    const parts = rgbaMatch[1].split(",").map((part) => part.trim());
    if (parts.length >= 4) {
      const alpha = Number.parseFloat(parts[3]);
      return Number.isFinite(alpha) && alpha <= 0;
    }
  }
  return normalized === "rgba(0, 0, 0, 0)" || normalized === "rgba(0,0,0,0)";
}

function resolveEffectiveBackgroundColor(elements = []) {
  for (const element of elements) {
    if (!element) {
      continue;
    }
    const inlineValue = element.style?.getPropertyValue?.("background-color");
    if (!isTransparentBackgroundColor(inlineValue)) {
      return {
        value: inlineValue,
        priority: element.style?.getPropertyPriority?.("background-color") || ""
      };
    }
    const ownerWindow = element.ownerDocument?.defaultView;
    const computedValue = ownerWindow?.getComputedStyle?.(element)?.backgroundColor;
    if (!isTransparentBackgroundColor(computedValue)) {
      return { value: computedValue, priority: "" };
    }
  }
  return null;
}

function clearDropDownListButtonBackgroundSync(widget, button) {
  const styleNames = Array.isArray(widget?.__ntssJQueryDropDownListButtonBackgroundStyleNames)
    ? widget.__ntssJQueryDropDownListButtonBackgroundStyleNames
    : [];
  styleNames.forEach((name) => button?.style?.removeProperty?.(name));
  button?.removeAttribute?.("data-ntss-dropdown-button-bg");
  if (widget) {
    widget.__ntssJQueryDropDownListButtonBackgroundStyleNames = [];
  }
}

function syncDropDownListButtonBackground(widget, wrapper, inputWrap, text, button) {
  if (!widget || !wrapper || !button) {
    return;
  }
  const background = resolveEffectiveBackgroundColor([inputWrap, text, wrapper]);
  if (!background) {
    clearDropDownListButtonBackgroundSync(widget, button);
    return;
  }

  const priority = background.priority || "important";
  const styleValues = {
    "background": background.value,
    "background-color": background.value,
    "background-image": "none",
    "position": "relative",
    "z-index": "1",
    "flex-shrink": "0"
  };

  Object.entries(styleValues).forEach(([name, value]) => {
    button.style?.setProperty?.(name, value, priority);
  });

  // Vue2 の .k-select は不透明な背景で長い表示文字を覆う。Vue3/Kendo 2025 の
  // 独立した button でも同じ見え方にするため、透明/inherit ではなく実背景色を置く。
  button.setAttribute?.("data-ntss-dropdown-button-bg", background.value);
  widget.__ntssJQueryDropDownListButtonBackgroundStyleNames = Object.keys(styleValues);
}

function syncJQueryDropDownListPresentation(widget, sourceElement = null) {
  const source = sourceElement?.jquery ? sourceElement[0] : (sourceElement || widget?.originalElement || widget?.element?.[0] || null);
  const wrapper = widget?.wrapper?.[0] || null;
  if (!source || !wrapper) {
    return widget;
  }

  const sourceId = restoreJQueryDropDownListSourceId(source);
  if (sourceId) {
    if (source.dataset) {
      source.dataset.ntssKendoDropdownlistSourceId = sourceId;
    }
    source.setAttribute?.("data-ntss-kendo-dropdownlist-source-id", sourceId);
    source.id = `${sourceId}_input`;
    wrapper.id = sourceId;
  }

  const previousClasses = Array.isArray(widget.__ntssJQueryDropDownListClasses)
    ? widget.__ntssJQueryDropDownListClasses
    : [];
  previousClasses.forEach((className) => wrapper.classList?.remove?.(className));
  const nextClasses = Array.from(source.classList || [])
    .filter((className) => className && className !== "k-hidden");
  nextClasses.forEach((className) => wrapper.classList?.add?.(className));
  widget.__ntssJQueryDropDownListClasses = nextClasses;

  const dir = source.getAttribute?.("dir");
  if (dir) {
    wrapper.setAttribute?.("dir", dir);
  } else {
    wrapper.removeAttribute?.("dir");
  }
  applyPresentationStyle(source, wrapper, widget);
  // Vue2 pages and shared layout code still key off the old jQuery Kendo DOM
  // contract: .k-widget.k-dropdown > .k-dropdown-wrap > .k-input/.k-select.
  // Kendo 2025 renders the same jQuery widget with the new .k-picker DOM, so
  // keep the actual widget instance but add the Vue2 facade classes/ARIA here.
  applyLegacyKendoDomFacade(widget, "dropdown");
  defineJQueryWidgetData(wrapper, "kendoDropDownList", widget);
  defineJQueryWidgetData(source, "kendoDropDownList", widget);
  syncLegacyWidgetRole(widget, "dropdownlist");
  return widget;
}


function resolveDropDownListValueFromEvent(widget, event = null, options = {}) {
  const dataItem = event?.dataItem || (typeof widget?.dataItem === "function" && event?.item ? widget.dataItem(event.item) : null);
  const fromEvent = event && Object.prototype.hasOwnProperty.call(event, "value") ? event.value : undefined;
  const fromDataItem = dataItem ? getItemValue(dataItem, options) : undefined;
  const fromWidget = typeof widget?.value === "function" ? widget.value() : undefined;
  return fromEvent ?? fromDataItem ?? fromWidget ?? "";
}

function syncJQueryDropDownListValueState(widget, options = {}, originalElement = null, event = null, emit = false) {
  if (!widget) {
    return widget;
  }
  const value = resolveDropDownListValueFromEvent(widget, event, options);
  const dataItems = normalizeDataSource(widget.dataSource || options.dataSource);
  const selectedItem = event?.dataItem
    || findSelectedItem(dataItems, value, options)
    || widget.dataItem?.()
    || null;
  updateLegacySenderState(widget, {
    value,
    text: getItemText(selectedItem, options) || widget.text?.() || "",
    dataItem: selectedItem,
    selectedIndex: event?.index ?? event?.item?.index?.() ?? findSelectedIndex(dataItems, value, options),
    element: widget.element || (originalElement ? $(originalElement) : undefined),
    wrapper: widget.wrapper
  });
  syncOriginalValue(originalElement || widget.originalElement || widget.element?.[0], value, emit);
  return widget;
}

function patchJQueryDropDownListValueSync(widget, options = {}, originalElement = null) {
  if (!widget || widget.__ntssKendoDropDownListValueSyncPatched || typeof widget.value !== "function") {
    return widget;
  }
  const originalValue = widget.value;
  try {
    Object.defineProperty(widget, "__ntssKendoDropDownListValueSyncPatched", {
      configurable: true,
      enumerable: false,
      value: true
    });
  } catch (_error) {
    widget.__ntssKendoDropDownListValueSyncPatched = true;
  }
  widget.value = function ntssDropDownListValue(nextValue) {
    if (arguments.length === 0) {
      return originalValue.call(this);
    }
    const result = originalValue.call(this, nextValue);
    syncJQueryDropDownListValueState(this, options, originalElement, { value: nextValue }, false);
    return result;
  };
  registerWidgetCleanup(widget, () => {
    widget.value = originalValue;
    try {
      delete widget.__ntssKendoDropDownListValueSyncPatched;
    } catch (_error) {
      widget.__ntssKendoDropDownListValueSyncPatched = false;
    }
  });
  return widget;
}

function buildJQueryDropDownListOptions(options = {}, originalElement = null) {
  const dataSource = options.dataSource;
  const dataItems = normalizeDataSource(dataSource);
  const initialValue = resolveDropDownValue(resolveInitialDropDownValue(options.value, originalElement), dataItems, options);
  const widgetOptions = {
    dataSource,
    dataTextField: options.dataTextField,
    dataValueField: options.dataValueField,
    optionLabel: options.optionLabel,
    filter: options.filter,
    messages: normalizeDropDownListMessages(options),
    height: options.height,
    virtual: options.virtual,
    animation: options.animation === undefined ? false : options.animation,
    value: initialValue,
    change(e) {
      const widget = e?.sender || this;
      if (isKendoChangeSuppressed(widget)) {
        return;
      }
      syncJQueryDropDownListValueState(widget, options, originalElement, e, false);
      return invokeHandler(options.change, widget, e);
    },
    select(e) {
      const widget = e?.sender || this;
      syncJQueryDropDownListValueState(widget, options, originalElement, e, false);
      return invokeHandler(options.select, widget, e);
    },
    open(e) {
      const widget = e?.sender || this;
      syncJQueryDropDownListPresentation(widget, originalElement);
      syncDropDownListFilterInput(widget, options);
      syncKendoPopupWidgetRefs(widget, widget?.wrapper?.[0] || originalElement);
      return invokeHandler(options.open, widget, e);
    },
    close(e) {
      return invokeHandler(options.close, e?.sender || this, e);
    },
    filtering(e) {
      return invokeHandler(options.filtering, e?.sender || this, e);
    }
  };

  Object.keys(widgetOptions).forEach((key) => {
    if (widgetOptions[key] === undefined) {
      delete widgetOptions[key];
    }
  });
  if (options.autoSelectFirstOnEmpty === false && isEmptyDropDownValue(initialValue) && !hasDropDownOptionLabel(options)) {
    widgetOptions.index = -1;
    delete widgetOptions.value;
  }
  return widgetOptions;
}

function destroyExistingJQueryDropDownList(originalElement) {
  if (!originalElement) {
    return;
  }
  const existing = $(originalElement).data("kendoDropDownList");
  if (!existing) {
    return;
  }
  restoreJQueryDropDownListSourceId(originalElement);
  runWidgetCleanups(existing);
  try {
    existing.destroy?.();
  } catch (_error) {
    // noop
  }
  removeJQueryWidgetData(originalElement, ["kendoDropDownList"]);
  removeJQueryWidgetData(existing.wrapper?.[0], ["kendoDropDownList"]);
}

function normalizeDropDownListMessages(options = {}) {
  const sourceMessages = options.messages && typeof options.messages === "object" ? options.messages : null;
  if (!options.filter && !sourceMessages) {
    return undefined;
  }
  const messages = { ...(sourceMessages || {}) };
  // Vue2/Kendo 2019 の filter input はプレースホルダ文字なし。
  // Kendo 2025+ は既定で "Filter" を表示するため、明示指定がない場合だけ旧挙動へ戻す。
  if (messages.filterInputPlaceholder === undefined && options.filter) {
    messages.filterInputPlaceholder = "";
  }
  return Object.keys(messages).length ? messages : undefined;
}

function resolveDomElement(value) {
  return value?.jquery ? value[0] : value?.[0] || value || null;
}

function createLegacySearchSvg(ownerDocument) {
  const svg = ownerDocument.createElementNS("http://www.w3.org/2000/svg", "svg");
  svg.setAttribute("aria-hidden", "true");
  svg.setAttribute("focusable", "false");
  svg.setAttribute("viewBox", "0 0 512 512");
  svg.classList.add("k-svg-icon", "k-svg-i-search", "ntss-kendo-dropdownlist-filter-search-svg");
  const path = ownerDocument.createElementNS("http://www.w3.org/2000/svg", "path");
  path.setAttribute("d", "M365.3 320h-22.7l-8-7.7a186.3 186.3 0 0 0 45.4-121.8C380 85.3 294.7 0 189.5 0S-1 85.3-1 190.5 84.3 381 189.5 381c46.2 0 88.6-16.5 121.8-44.1l7.7 8v22.7L465.4 514 512 467.4 365.3 320zM189.5 320C118 320 60 262 60 190.5S118 61 189.5 61 319 119 319 190.5 261 320 189.5 320z");
  svg.appendChild(path);
  return svg;
}

function ensureDropDownListFilterSearchIcon(widget) {
  const filterInput = resolveDomElement(widget?.filterInput);
  if (!filterInput) {
    return widget;
  }
  const ownerDocument = filterInput.ownerDocument || (typeof document !== "undefined" ? document : null);
  if (!ownerDocument) {
    return widget;
  }
  const filterRoot = filterInput.closest?.(".k-list-filter") || filterInput.parentElement;
  const filterBox = filterInput.closest?.(".k-searchbox, .k-input") || filterInput.parentElement || filterRoot;
  if (!filterBox) {
    return widget;
  }

  filterRoot?.classList?.add("ntss-kendo-dropdownlist-filter-root");
  filterBox.classList.add("ntss-kendo-dropdownlist-filter-box");
  filterInput.classList.add("ntss-kendo-dropdownlist-filter-input");

  let icon = filterBox.querySelector?.(
    ":scope > .ntss-kendo-dropdownlist-filter-search-icon, :scope > .k-input-icon, :scope > .k-icon.k-i-search, :scope > .k-svg-icon.k-svg-i-search"
  ) || null;
  if (!icon && filterRoot && filterRoot !== filterBox) {
    icon = filterRoot.querySelector?.(
      ".ntss-kendo-dropdownlist-filter-search-icon, .k-input-icon, .k-icon.k-i-search, .k-svg-icon.k-svg-i-search"
    ) || null;
  }
  if (icon && icon.parentElement !== filterBox) {
    filterBox.appendChild(icon);
  }
  if (!icon) {
    icon = ownerDocument.createElement("span");
    icon.className = "k-input-icon k-icon k-i-search ntss-kendo-dropdownlist-filter-search-icon";
    icon.setAttribute("aria-hidden", "true");
    icon.appendChild(createLegacySearchSvg(ownerDocument));
    filterBox.appendChild(icon);
  }
  icon.classList.add("ntss-kendo-dropdownlist-filter-search-icon");
  icon.setAttribute("aria-hidden", "true");
  return widget;
}

function syncDropDownListFilterInput(widget, options = {}) {
  if (!widget || !options.filter) {
    return widget;
  }
  const placeholder = options.messages?.filterInputPlaceholder ?? "";
  try {
    widget.filterInput?.attr?.("placeholder", placeholder);
  } catch (_error) {
    // noop
  }
  try {
    widget.filterInput?.[0]?.setAttribute?.("placeholder", placeholder);
  } catch (_error) {
    // noop
  }
  ensureDropDownListFilterSearchIcon(widget);
  return widget;
}

function mountDropDownList(element, options = {}) {
  const sourceElement = element?.jquery ? element[0] : element;
  const inputName = resolveLegacyInputName(options, sourceElement);
  const originalElement = resolveWidgetSourceElement(element, "input", {
    name: inputName,
    className: options.className,
    id: options.id,
    placeholder: options.placeholder
  });
  if (!originalElement) {
    return null;
  }

  restoreJQueryDropDownListSourceId(originalElement);
  destroyMountedWidget(originalElement);
  destroyExistingJQueryDropDownList(originalElement);
  setLegacyWidgetRole(originalElement, "dropdownlist");

  const widgetOptions = buildJQueryDropDownListOptions(options, originalElement);
  const $element = $(originalElement);
  const kendoDropDownListPlugin = resolveOriginalDropDownListPlugin();
  if (typeof kendoDropDownListPlugin !== "function") {
    throw new Error("jQuery Kendo DropDownList is not available.");
  }
  kendoDropDownListPlugin.call($element, widgetOptions);
  const widget = $element.data("kendoDropDownList") || null;
  if (!widget) {
    return null;
  }

  syncDropDownListFilterInput(widget, widgetOptions);
  patchJQueryDropDownListValueSync(widget, widgetOptions, originalElement);
  ensureLegacyWidgetResize(widget);
  defineWritableWidgetProperty(widget, "originalElement", originalElement);
  defineWritableWidgetProperty(widget, "element", widget.element || $element);
  defineWritableWidgetProperty(widget, "wrapper", widget.wrapper || $element.closest(".k-dropdown, .k-dropdownlist, .k-picker"));
  widget.options = widget.options || {};
  widget.options.autoSelectFirstOnEmpty = options.autoSelectFirstOnEmpty !== false;
  if (options.enabled === false || options.disabled === true) {
    widget.enable?.(false);
  }

  const effectiveValue = widget.value?.() ?? widgetOptions.value ?? "";
  const dataItems = normalizeDataSource(widget.dataSource || options.dataSource);
  const selectedItem = findSelectedItem(dataItems, effectiveValue, options) || widget.dataItem?.() || null;
  updateLegacySenderState(widget, {
    value: effectiveValue,
    text: getItemText(selectedItem, options) || widget.text?.() || "",
    dataItem: selectedItem,
    selectedIndex: findSelectedIndex(dataItems, effectiveValue, options),
    element: widget.element || $element,
    wrapper: widget.wrapper
  });
  syncOriginalValue(originalElement, effectiveValue);
  syncJQueryDropDownListPresentation(widget, originalElement);
  syncKendoPopupWidgetRefs(widget, widget.wrapper?.[0] || originalElement);
  return widget;
}

function mountMultiSelect(element, options = {}) {
  const sourceElement = element?.jquery ? element[0] : element;
  const inputName = resolveLegacyInputName(options, sourceElement);
  const originalElement = resolveWidgetSourceElement(element, "select", {
    name: inputName,
    className: options.className,
    id: options.id,
    multiple: true
  });
  if (!originalElement) {
    return null;
  }

  destroyMountedWidget(originalElement);
  setLegacyWidgetRole(originalElement, "multiselect");
  const widgetOptions = createLegacyWidgetOptions(options, "MultiSelect", inputName || originalElement.getAttribute?.("name"));

  const presentation = snapshotPresentationAttributes(originalElement);
  const mountNode = createMountNode(originalElement);
  const initialDataItems = normalizeDataSource(options.dataSource);
  const initialMultiSelectValue = normalizeMultiSelectValuesAgainstDataItems(
    resolveInitialMultiSelectValue(options.value, originalElement),
    initialDataItems,
    options
  );
  const state = {
    dataItems: initialDataItems,
    value: initialMultiSelectValue,
    disabled: options.enabled === false || options.disabled === true,
    opened: false,
    filter: options.filterValue || ""
  };

  let widget = null;

  const Root = {
    provide() {
      return {
        kCurrentZIndex: resolveOwnerStackZIndex({ mountNode, originalElement })
      };
    },
    data() {
      return state;
    },
    computed: {
      filteredDataItems() {
        return filterDropDownDataItems(this.dataItems, this.filter, options);
      }
    },
    methods: {
      handleChange(event) {
        if (isKendoChangeSuppressed(widget)) {
          return;
        }
        const previousValue = normalizeArrayValue(widget?._old);
        const nextValue = normalizeMultiSelectValuesAgainstDataItems(
          limitMultiSelectValue(previousValue, event?.value, options.maxSelectedItems),
          this.dataItems,
          options
        );
        this.value = nextValue;
        syncOriginalValue(originalElement, nextValue);
        const selected = new Set(nextValue.map((item) => String(item)));
        widget.currentDataItems = this.dataItems.filter((item) => selected.has(String(getItemValue(item, options))));
        updateLegacySenderState(widget, {
          value: nextValue,
          text: widget.text?.() || "",
          dataItems: widget.currentDataItems
        });
        const { added, removed } = diffSelection(previousValue, nextValue);
        added.forEach((value) => {
          const dataItem = findSelectedItem(this.dataItems, value, options);
          widget.trigger("select", createLegacyKendoEvent(event, widget, {
            value,
            dataItem,
            item: resolveMultiSelectPopupItem(widget, value),
            added: true,
            dataItems: widget.currentDataItems
          }));
        });
        removed.forEach((value) => {
          const dataItem = findSelectedItem(this.dataItems, value, options);
          widget.trigger("deselect", createLegacyKendoEvent(event, widget, {
            value,
            dataItem,
            item: resolveMultiSelectPopupItem(widget, value),
            removed: true,
            dataItems: widget.currentDataItems
          }));
        });
        const payload = createLegacyKendoEvent(event, widget, {
          value: nextValue,
          dataItems: widget.currentDataItems
        });
        widget.trigger("change", payload);
      },
      handleOpen(event) {
        this.opened = true;
        schedulePopupMetadataSync(widget, "multiselect");
        widget.trigger("open", createLegacyKendoEvent(event, widget));
      },
      handleClose(event) {
        this.opened = false;
        widget.trigger("close", createLegacyKendoEvent(event, widget));
      },
      handleFilterChange(event) {
        this.filter = event?.filter?.value ?? event?.value ?? "";
        widget.filterInput.val(this.filter);
        schedulePopupMetadataSync(widget, "multiselect");
        widget.trigger("filtering", createLegacyKendoEvent(event, widget));
      }
    },
    render() {
      const componentOptions = {
        id: presentation.id,
        name: presentation.name,
        className: presentation.className,
        style: undefined,
        dataItems: this.filteredDataItems,
        textField: options.dataTextField,
        valueField: options.dataValueField,
        valuePrimitive: options.valuePrimitive !== false,
        value: this.value,
        filterable: !!options.filter,
        autoClose: options.autoClose !== false,
        placeholder: options.placeholder,
        filter: this.filter,
        disabled: this.disabled,
        opened: this.opened,
        clearButton: false,
        onChange: this.handleChange,
        onOpen: this.handleOpen,
        onClose: this.handleClose,
        onFilterchange: this.handleFilterChange
      };
      if (options.virtual && typeof options.virtual === "object") {
        componentOptions.virtual = options.virtual;
      }
      return h(MultiSelect, componentOptions);
    }
  };

  const app = createApp(Root);
  const vm = app.mount(mountNode);

  widget = {
    options: widgetOptions,
    vm,
    app,
    mountNode,
    originalElement,
    dataSource: createCompatDataSource(options.dataSource, state.dataItems),
    currentDataItems: state.dataItems.filter((item) => state.value.some((value) => String(value) === String(getItemValue(item, options)))),
    _old: [...state.value],
    get element() {
      return $(originalElement);
    },
    get wrapper() {
      return $(mountNode.firstElementChild || mountNode);
    },
    get popup() {
      const popup = getWidgetPopup(widget);
      if (!popup) {
        return null;
      }
      const popupHandle = $(popup);
      return {
        element: popupHandle,
        wrapper: popupHandle
      };
    },
    get listBoxId() {
      return getListBoxIdFromWidget(widget);
    },
    get list() {
      return $(getPopupListElement(widget) || []);
    },
    get ul() {
      return widget.list;
    },
    get filterInput() {
      const input = findVisibleInput(mountNode);
      return $(input || []);
    },
    value(nextValue) {
      if (nextValue === undefined) {
        return Array.isArray(vm.value) ? [...vm.value] : [];
      }
      vm.value = normalizeMultiSelectValuesAgainstDataItems(
        Array.isArray(nextValue) ? nextValue : [],
        vm.dataItems,
        options
      );
      syncOriginalValue(originalElement, vm.value);
      const selected = new Set(vm.value.map((item) => String(item)));
      widget.currentDataItems = vm.dataItems.filter((item) => selected.has(String(getItemValue(item, options))));
      updateLegacySenderState(widget, {
        value: vm.value,
        text: widget.text?.() || "",
        dataItems: widget.currentDataItems
      });
      if (vm.opened) {
        schedulePopupMetadataSync(widget, "multiselect");
      }
      scheduleLegacyKendoDomFacade(widget, "multiselect");
      return [...vm.value];
    },
    text() {
      return widget.currentDataItems.map((item) => getItemText(item, options)).join(", ");
    },
    dataItem(value) {
      if (value !== undefined) {
        return findSelectedItem(vm.dataItems, value, options);
      }
      return widget.currentDataItems[0] || null;
    },
    dataItems() {
      return [...widget.currentDataItems];
    },
    focus() {
      return focusWidgetInput(widget);
    },
    open() {
      return openWidgetPopup(widget, "multiselect");
    },
    close() {
      closeWidgetPopup(widget);
    },
    clear() {
      return widget.value([]);
    },
    remove(valueOrItem) {
      const currentValue = Array.isArray(vm.value) ? [...vm.value] : [];
      if (!currentValue.length) {
        return [];
      }
      const resolvedValue = typeof valueOrItem === "object" && valueOrItem !== null
        ? getItemValue(valueOrItem, options)
        : (valueOrItem !== undefined ? valueOrItem : currentValue[currentValue.length - 1]);
      const nextValue = currentValue.filter((entry) => String(entry) !== String(resolvedValue));
      return widget.value(nextValue);
    },
    trigger(name, rawEvent = null) {
      const event = createLegacyKendoEvent(rawEvent, widget, {
        value: Array.isArray(vm.value) ? [...vm.value] : [],
        dataItems: widget.currentDataItems || []
      });
      if (name === "select") {
        invokeHandler(options.select, widget, event);
        return event;
      }
      if (name === "deselect") {
        invokeHandler(options.deselect, widget, event);
        return event;
      }
      if (name === "change") {
        invokeHandler(options.change, widget, event);
        return event;
      }
      if (name === "open") {
        invokeHandler(options.open, widget, event);
        return event;
      }
      if (name === "close") {
        invokeHandler(options.close, widget, event);
        return event;
      }
      if (name === "filtering") {
        invokeHandler(options.filtering, widget, event);
        return event;
      }
      return event;
    },
    enable(enabled = true) {
      vm.disabled = !enabled;
    },
    setDataSource(source) {
      const wasOpen = vm.opened === true;
      widget.options.dataSource = source;
      vm.dataItems = resolveDataItemsReference(source, vm.dataItems);
      syncCompatDataSource(widget.dataSource, source, vm.dataItems);
      vm.value = normalizeMultiSelectValuesAgainstDataItems(vm.value, vm.dataItems, options);
      syncOriginalValue(originalElement, vm.value);
      const selected = new Set(vm.value.map((item) => String(item)));
      widget.currentDataItems = vm.dataItems.filter((item) => selected.has(String(getItemValue(item, options))));
      updateLegacySenderState(widget, {
        value: vm.value,
        text: widget.text?.() || "",
        dataItems: widget.currentDataItems
      });
      preservePopupOpenState(widget, "multiselect", wasOpen);
      scheduleLegacyKendoDomFacade(widget, "multiselect");
      return widget.dataSource;
    },
    refresh() {
      syncCompatDataSource(widget.dataSource, widget.options?.dataSource, vm.dataItems);
      if (vm.opened) {
        schedulePopupMetadataSync(widget, "multiselect");
      }
      scheduleLegacyKendoDomFacade(widget, "multiselect");
      return widget;
    },
    destroy() {
      destroyMountedWidget(originalElement);
    }
  };

  installLegacyWidgetObservable(widget);
  syncLegacyWidgetRole(widget, "multiselect");
  scheduleLegacyKendoDomFacade(widget, "multiselect");
  const shouldResolveDeferredMultiSelectValue = parseArrayOptionValue(options.value).length === 0;
  popupSearchRootByWidget.set(widget, mountNode.parentElement || mountNode || null);
  nativeWidgetHolders.set(originalElement, { app, vm, mountNode, widget, type: "multiselect" });
  syncOriginalValue(originalElement, state.value);
  syncCompatDataSource(widget.dataSource, widget.options?.dataSource, vm.dataItems);
  if (shouldResolveDeferredMultiSelectValue) {
    scheduleWidgetTimeout(widget, () => {
      if (nativeWidgetHolders.get(originalElement)?.widget !== widget) {
        return;
      }
      const deferredValue = getSelectedOptionValues(originalElement);
      if (!deferredValue.length) {
        return;
      }
      if (!widget.value().length) {
        widget.value(deferredValue);
      }
    }, 0);
  }
  return defineWidgetData(originalElement, "kendoMultiSelect", widget).data("kendoMultiSelect");
}


function scheduleLegacyKendoDomFacade(widget, type = "") {
  if (!widget) {
    return;
  }
  installLegacyKendoDomFacadeObserver(widget, type);
  const apply = () => applyLegacyKendoDomFacade(widget, type);
  apply();
  scheduleWidgetFrame(widget, apply);
  scheduleWidgetTimeout(widget, apply, 0);
  scheduleWidgetTimeout(widget, apply, 50);
}

function installLegacyKendoDomFacadeObserver(widget, type = "") {
  if (!widget || widget.__ntssLegacyDomFacadeObserver) {
    return;
  }
  const root = widget.mountNode || widget.wrapper?.[0] || null;
  const ownerWindow = getElementOwnerWindow(root);
  if (!root || typeof ownerWindow.MutationObserver !== "function") {
    return;
  }
  let pending = false;
  const scheduleApply = () => {
    if (widget.__ntssLegacyDomFacadeApplying || pending) {
      return;
    }
    pending = true;
    scheduleWidgetTimeout(widget, () => {
      pending = false;
      applyLegacyKendoDomFacade(widget, type);
    }, 0);
  };
  const observer = new ownerWindow.MutationObserver(scheduleApply);
  observer.observe(root, {
    childList: true,
    subtree: true,
    attributes: true,
    attributeFilter: ["class", "style", "id", "aria-controls", "aria-owns", "aria-expanded"]
  });
  try {
    Object.defineProperty(widget, "__ntssLegacyDomFacadeObserver", {
      configurable: true,
      enumerable: false,
      value: observer
    });
  } catch (_error) {
    widget.__ntssLegacyDomFacadeObserver = observer;
  }
  registerWidgetCleanup(widget, () => {
    observer.disconnect();
    delete widget.__ntssLegacyDomFacadeObserver;
  });
}

function addClasses(element, classes = []) {
  if (!element || !element.classList) {
    return;
  }
  classes.forEach((className) => {
    if (className && !element.classList.contains(className)) {
      element.classList.add(className);
    }
  });
}

function syncClass(element, className, enabled) {
  if (!element || !element.classList || !className) {
    return;
  }
  if (enabled) {
    element.classList.add(className);
  } else {
    element.classList.remove(className);
  }
}


function applyLegacyKendoDomFacade(widget, type = "") {
  const wrapper = widget?.wrapper?.[0] || widget?.mountNode?.firstElementChild || widget?.mountNode || null;
  if (!wrapper) {
    return;
  }
  widget.__ntssLegacyDomFacadeApplying = true;
  try {

  if (type === "dropdown") {
    addClasses(wrapper, ["k-widget", "k-header", "k-dropdown", "k-legacy-dropdownlist"]);
    wrapper.setAttribute?.("unselectable", "on");
    if (!wrapper.getAttribute?.("role") || wrapper.getAttribute("role") === "combobox") {
      wrapper.setAttribute?.("role", "listbox");
    }
    wrapper.setAttribute?.("aria-haspopup", "true");
    wrapper.setAttribute?.("aria-live", "polite");
    syncClass(wrapper, "k-state-disabled", wrapper.classList.contains("k-disabled") || widget?.vm?.disabled === true);
    rememberNativeWidgetListBoxId(widget, wrapper);
    const legacyListBoxId = getLegacyWidgetListBoxId(widget);
    if (legacyListBoxId) {
      wrapper.setAttribute?.("aria-controls", legacyListBoxId);
      wrapper.setAttribute?.("aria-owns", legacyListBoxId);
    }
    const inputWrap = wrapper.querySelector?.(".k-dropdown-wrap, .k-input-inner, .k-input");
    addClasses(inputWrap, ["k-dropdown-wrap", "k-state-default"]);
    inputWrap?.setAttribute?.("unselectable", "on");
    syncClass(inputWrap, "k-state-disabled", widget?.vm?.disabled === true);
    const text = wrapper.querySelector?.(".k-input-value-text") || inputWrap;
    addClasses(text, ["k-input"]);
    text?.setAttribute?.("unselectable", "on");
    const button = wrapper.querySelector?.(".k-input-button, .k-select");
    addClasses(button, ["k-select"]);
    button?.setAttribute?.("unselectable", "on");
    button?.setAttribute?.("aria-label", button.getAttribute?.("aria-label") || "select");
    syncDropDownListButtonBackground(widget, wrapper, inputWrap, text, button);
    const icon = button?.querySelector?.(".k-icon, .k-svg-icon");
    addClasses(icon, ["k-i-arrow-60-down"]);
    if (widget?.originalElement?.setAttribute) {
      widget.originalElement.setAttribute("data-role", "dropdownlist");
    }
    if (widget?.vm?.opened === true) {
      schedulePopupMetadataSync(widget, "dropdown");
    }
    return;
  }

  if (type === "multiselect") {
    addClasses(wrapper, ["k-widget", "k-header", "k-multiselect", "k-multiselect-clearable", "k-legacy-multiselect"]);
    wrapper.setAttribute?.("unselectable", "on");
    wrapper.setAttribute?.("aria-haspopup", "true");
    syncClass(wrapper, "k-state-disabled", wrapper.classList.contains("k-disabled") || widget?.vm?.disabled === true);
    rememberNativeWidgetListBoxId(widget, wrapper);
    const legacyListBoxId = getLegacyWidgetListBoxId(widget);
    const valueArea = wrapper.querySelector?.(".k-input-values, .k-multiselect-wrap");
    // Vue2: div.k-multiselect-wrap.k-floatwrap is the value container.
    // The k-reset class belongs to the inner ul/tag list, not to the wrapper itself.
    addClasses(valueArea, ["k-multiselect-wrap", "k-floatwrap"]);
    valueArea?.setAttribute?.("role", "listbox");
    valueArea?.setAttribute?.("unselectable", "on");
    const input = wrapper.querySelector?.("input.k-input-inner, input.k-input, .k-input-inner, .k-input");
    addClasses(input, ["k-input"]);
    input?.setAttribute?.("role", "listbox");
    input?.setAttribute?.("unselectable", "on");
    if (legacyListBoxId) {
      wrapper.setAttribute?.("aria-controls", legacyListBoxId);
      wrapper.setAttribute?.("aria-owns", legacyListBoxId);
      valueArea?.setAttribute?.("aria-controls", legacyListBoxId);
      valueArea?.setAttribute?.("aria-owns", legacyListBoxId);
      input?.setAttribute?.("aria-controls", legacyListBoxId);
      input?.setAttribute?.("aria-owns", legacyListBoxId);
    }
    const chipList = wrapper.querySelector?.(".k-selection-multiple, .k-chip-list, ul.k-reset, .k-input-values > ul, .k-multiselect-wrap > ul");
    addClasses(chipList, ["k-reset"]);
    chipList?.setAttribute?.("unselectable", "on");
    const chips = Array.from(wrapper.querySelectorAll?.(".k-chip, .k-chip-list > li, ul.k-reset > li") || []);
    chips.forEach((chip) => {
      addClasses(chip, ["k-button"]);
      chip.classList?.remove?.("k-state-default");
      chip.setAttribute?.("unselectable", "on");
      chip.setAttribute?.("aria-setsize", String(chips.length));
    });
    wrapper.querySelectorAll?.(".k-chip-action, .k-chip-remove-action").forEach((action) => {
      addClasses(action, ["k-select"]);
      action.setAttribute?.("unselectable", "on");
    });
    wrapper.querySelectorAll?.(".k-chip-remove-action .k-icon, .k-chip-remove-action .k-svg-icon").forEach((icon) => addClasses(icon, ["k-icon", "k-i-close"]));
    wrapper.querySelectorAll?.(".k-clear-value").forEach((clear) => {
      addClasses(clear, ["k-icon", "k-i-close"]);
      clear.setAttribute?.("unselectable", "on");
    });
    wrapper.querySelectorAll?.(".k-chip-content, .k-chip-label").forEach((label) => label.setAttribute?.("unselectable", "on"));
    if (widget?.originalElement?.setAttribute) {
      widget.originalElement.setAttribute("data-role", "multiselect");
    }
    if (widget?.vm?.opened === true) {
      schedulePopupMetadataSync(widget, "multiselect");
    }
    if (valueArea && input && !valueArea.__ntssNativeLegacyMultiSelectOpenBound) {
      valueArea.__ntssNativeLegacyMultiSelectOpenBound = true;
      const openHandler = (event) => {
        if (event.target?.closest?.(".k-select, .k-clear-value, .k-chip-action, .k-chip-remove-action")) {
          return;
        }
        widget.open?.();
        input.focus?.();
      };
      valueArea.__ntssNativeLegacyMultiSelectOpenHandler = openHandler;
      valueArea.addEventListener("click", openHandler);
      registerWidgetCleanup(widget, () => {
        valueArea.removeEventListener("click", openHandler);
        delete valueArea.__ntssNativeLegacyMultiSelectOpenBound;
        delete valueArea.__ntssNativeLegacyMultiSelectOpenHandler;
      });
    }
    return;
  }

  if (type === "numerictextbox") {
    addClasses(wrapper, ["k-widget", "k-numerictextbox", "k-numeric-wrap", "k-state-default"]);
    syncClass(wrapper, "k-state-disabled", widget?.vm?.disabled === true);
    const input = resolveNumericTextBoxInput(wrapper);
    addClasses(input, ["k-input", "k-input-inner"]);
    syncLegacyNumericTextBoxInput(input, widget?.originalElement);
    input?.setAttribute?.("role", "spinbutton");
    const spinner = wrapper.querySelector?.(".k-input-spinner, .k-select");
    addClasses(spinner, ["k-select"]);
    spinner?.setAttribute?.("unselectable", "on");
    const increaseButton = spinner?.querySelector?.(".k-spinner-increase");
    const decreaseButton = spinner?.querySelector?.(".k-spinner-decrease");
    addClasses(increaseButton, ["k-link", "k-link-increase"]);
    addClasses(decreaseButton, ["k-link", "k-link-decrease"]);
    increaseButton?.setAttribute?.("unselectable", "on");
    decreaseButton?.setAttribute?.("unselectable", "on");
    addClasses(increaseButton?.querySelector?.(".k-icon, .k-svg-icon"), ["k-icon", "k-i-arrow-60-up"]);
    addClasses(decreaseButton?.querySelector?.(".k-icon, .k-svg-icon"), ["k-icon", "k-i-arrow-60-down"]);
    const inputName = widget?.options?.inputName;
    if (inputName && !input?.getAttribute?.("name")) {
      input.setAttribute("name", inputName);
    }
    return;
  }
  } finally {
    widget.__ntssLegacyDomFacadeApplying = false;
  }
}


function mountNumericTextBox(element, options = {}) {
  const originalElement = element?.jquery ? element[0] : element;
  if (!originalElement) {
    return null;
  }

  destroyMountedWidget(originalElement);
  setLegacyWidgetRole(originalElement, "numerictextbox");
  const inputName = resolveLegacyInputName(options, originalElement);
  const widgetOptions = createLegacyWidgetOptions(options, "NumericTextBox", inputName);

  const mountNode = createMountNode(originalElement);
  const numericValue = resolveInitialNumericValue(options.value, originalElement);
  const min = resolveNumericTextBoxNumberOption(options, originalElement, "min");
  const max = resolveNumericTextBoxNumberOption(options, originalElement, "max");
  const step = resolveNumericTextBoxNumberOption(options, originalElement, "step");
  const loopBounds = resolveEffectiveNumericTextBoxLoopBounds(options, min, max);
  const state = {
    value: Number.isFinite(numericValue) ? numericValue : null,
    disabled: options.enable === false || options.enabled === false || options.disabled === true,
    readonly: options.readonly === true || originalElement.readOnly === true,
    min,
    max,
    step,
    // spin コールバックが Kendo Vue の算出値と異なる値にしたとき NumericTextBox を再マウントする
    spinResetKey: 0
  };
  const blurDecimals = resolveNumericTextBoxBlurDecimals(options);
  const blurRoundingMode = resolveNumericTextBoxRoundingMode(options);
  const padDecimalPlaces = options.padDecimalPlaces !== false;
  const freeDecimalInput = isLegacyUngroupedDecimalFormat(normalizeNumericTextBoxFormat(options.format, options.decimals));
  const kendoFormat = resolveNumericTextBoxKendoFormat(options);

  let widget = null;

  const syncNumericState = (nextValue, emit = false, clamp = true) => {
    const parsedValue = normalizeNumericTextBoxValue(nextValue);
    const normalized = clamp
      ? (loopBounds
        ? clampNumericTextBoxValue(parsedValue, loopBounds.min, loopBounds.max)
        : clampNumericTextBoxValue(parsedValue, state.min, state.max))
      : parsedValue;
    const text = freeDecimalInput
      ? formatNumericTextBoxBlurDisplay(normalized, blurDecimals, blurRoundingMode, padDecimalPlaces)
      : formatNumericTextBoxValue(normalized);
    updateLegacySenderState(widget, {
      value: normalized,
      text
    });
    if (widget) {
      widget._value = normalized;
    }
    syncNumericTextBoxOriginalValue(originalElement, normalized, emit);
    if (freeDecimalInput) {
      const input = resolveNumericTextBoxInput(mountNode);
      const isFocused = input?.ownerDocument?.activeElement === input;
      if (!isFocused) {
        syncNumericTextBoxInputDisplay(input, normalized, blurDecimals, blurRoundingMode, false, padDecimalPlaces);
      }
    }
    return normalized;
  };

  const Root = {
    data() {
      return state;
    },
    methods: {
      applyInputState() {
        const input = resolveNumericTextBoxInput(mountNode);
        if (!input) {
          return;
        }
        input.readOnly = this.readonly === true;
        if (this.min !== undefined) input.setAttribute("min", this.min);
        if (this.max !== undefined) input.setAttribute("max", this.max);
        if (this.step !== undefined) input.setAttribute("step", this.step);
        syncLegacyNumericTextBoxInput(input, originalElement);
        installNonNegativeNumericTextBoxInputGuard(input, this.min);
        if (freeDecimalInput) {
          installNumericTextBoxCommaGuard(input);
        }
      },
      applySpinnerResolvedValue(nextValue, resolvedValue) {
        this.value = resolvedValue;
        syncNumericState(resolvedValue);

        // spin ハンドラが循環 wrap 等で Kendo Vue 内部の currentLooseValue と乖離した場合は再マウントする
        if (!isSameKendoValue(resolvedValue, nextValue)) {
          this.spinResetKey += 1;
          nextTick(() => {
            widget?.focus?.();
            applyLegacyKendoDomFacade(widget, "numerictextbox");
          });
          return;
        }

        applyLegacyKendoDomFacade(widget, "numerictextbox");
      },
      handleFreeDecimalInput(event) {
        stripNumericInputCommas(event?.target);
      },
      handleFreeDecimalFocus(event) {
        const input = event?.target || resolveNumericTextBoxInput(mountNode);
        syncNumericTextBoxInputDisplay(input, this.value, blurDecimals, blurRoundingMode, true);
        installNumericTextBoxCommaGuard(input);
        widget.trigger("focus", createLegacyKendoEvent(event, widget, { value: this.value }));
      },
      handleFreeDecimalBlur(event) {
        const input = event?.target || resolveNumericTextBoxInput(mountNode);
        let nextValue = clampNumericTextBoxValue(
          normalizeNumericTextBoxValue(input?.value ?? this.value),
          this.min,
          this.max
        );
        nextValue = applyNumericTextBoxBlurRounding(nextValue, blurDecimals, blurRoundingMode);
        this.value = nextValue;
        syncNumericState(nextValue, true);
        syncNumericTextBoxInputDisplay(input, nextValue, blurDecimals, blurRoundingMode, false, padDecimalPlaces);
        applyLegacyKendoDomFacade(widget, "numerictextbox");
        if (!isKendoChangeSuppressed(widget)) {
          widget.trigger("change", createLegacyKendoEvent(event, widget, { value: nextValue }));
        }
        widget.trigger("blur", createLegacyKendoEvent(event, widget, { value: this.value }));
      },
      handleFreeDecimalWheel(event) {
        const input = event?.target || resolveNumericTextBoxInput(mountNode);
        if (!input || input.ownerDocument?.activeElement !== input) {
          return;
        }
        event.preventDefault();
        const direction = event.deltaY < 0 ? 1 : -1;
        stepLegacyNumericTextBoxSpinner(widget, direction, event);
      },
      handleChange(event) {
        if (isKendoChangeSuppressed(widget)) {
          return;
        }
        const nativeEvent = event?.event || event;
        const isSpinner = nativeEvent?.target?.closest?.(".k-spinner-increase, .k-spinner-decrease");
        const isArrowKey = nativeEvent?.keyCode === 38 || nativeEvent?.keyCode === 40;
        const isWheel = nativeEvent?.type === "wheel";
        // 循環入力は stepLegacyNumericTextBoxSpinner 側で既に反映済み。Kendo の onChange が旧値で上書きするのを防ぐ
        if (loopBounds && (isWheel || isSpinner)) {
          return;
        }
        if (loopBounds && isArrowKey) {
          const direction = nativeEvent.keyCode === 38 ? 1 : -1;
          stepLegacyNumericTextBoxSpinner(widget, direction, nativeEvent);
          return;
        }
        const nextValue = normalizeNumericTextBoxBounds(
          normalizeNumericTextBoxValue(event?.value ?? event?.target?.value ?? this.value),
          this.min,
          this.max,
          loopBounds
        );
        if (isSpinner || isArrowKey || isWheel) {
          widget.trigger("spin", createLegacyKendoEvent(event, widget, { value: nextValue }));
          const resolvedValue = widget.value();
          this.applySpinnerResolvedValue(nextValue, resolvedValue);
        } else {
          if (freeDecimalInput) {
            stripNumericInputCommas(resolveNumericTextBoxInput(mountNode));
          }
          this.value = nextValue;
          syncNumericState(nextValue);
          applyLegacyKendoDomFacade(widget, "numerictextbox");
        }
      },
      handleFocus(event) {
        const input = resolveNumericTextBoxInput(mountNode);
        if (freeDecimalInput) {
          syncNumericTextBoxInputDisplay(input, this.value, blurDecimals, blurRoundingMode, true);
          installNumericTextBoxCommaGuard(input);
          scheduleWidgetTimeout(widget, () => {
            syncNumericTextBoxInputDisplay(
              resolveNumericTextBoxInput(mountNode),
              this.value,
              blurDecimals,
              blurRoundingMode,
              true
            );
            installNumericTextBoxCommaGuard(resolveNumericTextBoxInput(mountNode));
          }, 0);
        } else {
          syncFocusedNumericTextBoxInput(input, this.value);
          scheduleWidgetTimeout(widget, () => syncFocusedNumericTextBoxInput(resolveNumericTextBoxInput(mountNode), this.value), 0);
        }
        widget.trigger("focus", createLegacyKendoEvent(event, widget, { value: this.value }));
      },
      handleBlur(event) {
        const input = resolveNumericTextBoxInput(mountNode);
        let nextValue = loopBounds
          ? clampNumericTextBoxValue(
            normalizeNumericTextBoxValue(input?.value ?? this.value),
            loopBounds.min,
            loopBounds.max
          )
          : clampNumericTextBoxValue(
            normalizeNumericTextBoxValue(input?.value ?? this.value),
            this.min,
            this.max
          );
        if (freeDecimalInput) {
          nextValue = applyNumericTextBoxBlurRounding(nextValue, blurDecimals, blurRoundingMode);
        }
        this.value = nextValue;
        syncNumericState(nextValue, true);
        if (freeDecimalInput) {
          syncNumericTextBoxInputDisplay(input, nextValue, blurDecimals, blurRoundingMode, false, padDecimalPlaces);
        }
        applyLegacyKendoDomFacade(widget, "numerictextbox");
        if (!isKendoChangeSuppressed(widget)) {
          widget.trigger("change", createLegacyKendoEvent(event, widget, { value: nextValue }));
        }
        widget.trigger("blur", createLegacyKendoEvent(event, widget, { value: this.value }));
      }
    },
    mounted() {
      this.applyInputState();
      if (freeDecimalInput) {
        const input = resolveNumericTextBoxInput(mountNode);
        syncNumericTextBoxInputDisplay(input, this.value, blurDecimals, blurRoundingMode, false, padDecimalPlaces);
      }
    },
    updated() {
      this.applyInputState();
      if (freeDecimalInput) {
        const input = resolveNumericTextBoxInput(mountNode);
        const isFocused = input?.ownerDocument?.activeElement === input;
        if (!isFocused) {
          syncNumericTextBoxInputDisplay(input, this.value, blurDecimals, blurRoundingMode, false, padDecimalPlaces);
        }
      }
      applyLegacyKendoDomFacade(widget, "numerictextbox");
    },
    render() {
      if (freeDecimalInput) {
        const inputStyle = {};
        const legacyTextAlign = originalElement?.style?.textAlign;
        if (legacyTextAlign) {
          inputStyle.textAlign = legacyTextAlign;
        }
        const children = [
          h("input", {
            class: ["k-input-inner", options.inputClass].filter(Boolean),
            type: "text",
            inputmode: "decimal",
            disabled: this.disabled,
            readOnly: this.readonly,
            placeholder: options.placeholder,
            style: inputStyle,
            onInput: this.handleFreeDecimalInput,
            onFocus: this.handleFreeDecimalFocus,
            onBlur: this.handleFreeDecimalBlur,
            onWheel: this.handleFreeDecimalWheel
          })
        ];
        if (options.spinners !== false) {
          children.push(h("span", {
            class: "k-input-spinner k-select",
            unselectable: "on"
          }, [
            h("button", {
              type: "button",
              class: "k-button k-button-icon k-spinner-increase k-link k-link-increase",
              unselectable: "on",
              tabindex: -1,
              disabled: this.disabled,
              "aria-label": "Increase value"
            }, [h("span", { class: "k-icon k-i-arrow-60-up" })]),
            h("button", {
              type: "button",
              class: "k-button k-button-icon k-spinner-decrease k-link k-link-decrease",
              unselectable: "on",
              tabindex: -1,
              disabled: this.disabled,
              "aria-label": "Decrease value"
            }, [h("span", { class: "k-icon k-i-arrow-60-down" })])
          ]));
        }
        return h("span", {
          key: this.spinResetKey,
          class: [
            "k-widget",
            "k-numerictextbox",
            "k-input",
            "k-numeric-wrap",
            this.disabled ? "k-disabled" : null
          ].filter(Boolean)
        }, children);
      }
      return h(NumericTextBox, {
        key: this.spinResetKey,
        value: this.value,
        disabled: this.disabled,
        format: kendoFormat,
        min: this.min,
        max: this.max,
        step: this.step,
        spinners: options.spinners !== false,
        placeholder: options.placeholder,
        onChange: this.handleChange,
        onFocus: this.handleFocus,
        onBlur: this.handleBlur
      });
    }
  };

  const app = createApp(Root);
  const vm = app.mount(mountNode);

  widget = {
    options: widgetOptions,
    vm,
    app,
    mountNode,
    originalElement,
    _value: state.value,
    _old: state.value,
    _oldText: formatNumericTextBoxValue(state.value),
    get input() {
      return $(resolveNumericTextBoxInput(mountNode) || []);
    },
    get element() {
      return $(resolveNumericTextBoxInput(mountNode) || originalElement || []);
    },
    get wrapper() {
      return $(mountNode.firstElementChild || mountNode);
    },
    value(nextValue) {
      if (nextValue === undefined) {
        return vm.value;
      }
      const normalized = loopBounds
        ? clampNumericTextBoxValue(
          normalizeNumericTextBoxValue(nextValue),
          loopBounds.min,
          loopBounds.max
        )
        : normalizeNumericTextBoxBounds(
          normalizeNumericTextBoxValue(nextValue),
          vm.min,
          vm.max,
          null
        );
      if (isSameKendoValue(vm.value, normalized)) {
        return vm.value;
      }
      withProgrammaticKendoUpdate(widget, () => {
        vm.value = normalized;
        syncNumericState(normalized);
        const input = resolveNumericTextBoxInput(mountNode);
        if (input) {
          if (freeDecimalInput) {
            const isFocused = input.ownerDocument?.activeElement === input;
            syncNumericTextBoxInputDisplay(input, normalized, blurDecimals, blurRoundingMode, isFocused, padDecimalPlaces);
          } else {
            input.value = formatNumericTextBoxValue(normalized);
          }
        }
      });
      scheduleWidgetTimeout(widget, () => applyLegacyKendoDomFacade(widget, "numerictextbox"), 0);
      return vm.value;
    },
    text() {
      return widget._oldText || formatNumericTextBoxValue(vm.value);
    },
    min(nextValue) {
      if (nextValue === undefined) {
        return vm.min;
      }
      vm.min = normalizeNumericTextBoxNumberOption(nextValue);
      options.min = nextValue;
      vm.value = clampNumericTextBoxValue(vm.value, vm.min, vm.max);
      syncNumericState(vm.value);
      return widget;
    },
    max(nextValue) {
      if (nextValue === undefined) {
        return vm.max;
      }
      vm.max = normalizeNumericTextBoxNumberOption(nextValue);
      options.max = nextValue;
      vm.value = clampNumericTextBoxValue(vm.value, vm.min, vm.max);
      syncNumericState(vm.value);
      return widget;
    },
    step(nextValue) {
      if (nextValue === undefined) {
        return vm.step;
      }
      vm.step = normalizeNumericTextBoxNumberOption(nextValue);
      options.step = nextValue;
      return widget;
    },
    readonly(readonly = true) {
      vm.readonly = readonly === true;
      const input = resolveNumericTextBoxInput(mountNode);
      if (input) {
        input.readOnly = vm.readonly;
      }
      return widget;
    },
    enable(enabled = true) {
      vm.disabled = !enabled;
      applyLegacyKendoDomFacade(widget, "numerictextbox");
      return widget;
    },
    focus() {
      resolveNumericTextBoxInput(mountNode)?.focus?.();
      return widget;
    },
    setOptions(nextOptions = {}) {
      Object.assign(options, nextOptions || {});
      if (Object.prototype.hasOwnProperty.call(nextOptions, "min")) vm.min = normalizeNumericTextBoxNumberOption(nextOptions.min);
      if (Object.prototype.hasOwnProperty.call(nextOptions, "max")) vm.max = normalizeNumericTextBoxNumberOption(nextOptions.max);
      if (Object.prototype.hasOwnProperty.call(nextOptions, "step")) vm.step = normalizeNumericTextBoxNumberOption(nextOptions.step);
      if (Object.prototype.hasOwnProperty.call(nextOptions, "value")) widget.value(nextOptions.value);
      if (Object.prototype.hasOwnProperty.call(nextOptions, "enable")) vm.disabled = nextOptions.enable === false;
      if (Object.prototype.hasOwnProperty.call(nextOptions, "enabled")) vm.disabled = nextOptions.enabled === false;
      if (Object.prototype.hasOwnProperty.call(nextOptions, "disabled")) vm.disabled = nextOptions.disabled === true;
      applyLegacyKendoDomFacade(widget, "numerictextbox");
      return widget;
    },
    trigger(name, rawEvent = null) {
      const inputElement = resolveNumericTextBoxInput(mountNode);
      if (name === "spin") {
        const spinValue = rawEvent?.value;
        if (spinValue !== undefined && spinValue !== null) {
          const parsedSpinValue = normalizeNumericTextBoxValue(spinValue);
          if (parsedSpinValue !== null) {
            vm.value = parsedSpinValue;
          }
        }
      } else if (inputElement && inputElement.value !== "") {
        const parsed = normalizeNumericTextBoxValue(inputElement.value);
        if (parsed !== null) {
          vm.value = parsed;
        }
      }
      const shouldClamp = name !== "focus";
      const normalizedValue = syncNumericState(vm.value, name === "change", shouldClamp);
      if (shouldClamp && !isSameKendoValue(vm.value, normalizedValue)) {
        vm.value = normalizedValue;
      }
      if (shouldClamp && inputElement) {
        const normalizedText = formatNumericTextBoxValue(normalizedValue);
        if (inputElement.value !== normalizedText) {
          inputElement.value = normalizedText;
        }
      }
      const event = createLegacyKendoEvent(rawEvent, widget, { value: normalizedValue });
      if (name === "spin") {
        invokeHandler(options.spin, widget, event);
        return event;
      }
      if (name === "focus") {
        invokeHandler(options.focus, widget, event);
        return event;
      }
      if (name === "change") {
        invokeHandler(options.change, widget, event);
        return event;
      }
      if (name === "blur") {
        invokeHandler(options.blur, widget, event);
        return event;
      }
      return event;
    },
    refresh() {
      syncNumericState(vm.value);
      applyLegacyKendoDomFacade(widget, "numerictextbox");
      return widget;
    },
    destroy() {
      destroyMountedWidget(originalElement);
    }
  };

  Object.defineProperty(widget, "placeholder", {
    get() {
      return widget.element.attr("placeholder");
    },
    set(value) {
      widget.element.attr("placeholder", value ?? "");
    }
  });

  const shouldResolveDeferredNumericValue = options.value === undefined || options.value === null || options.value === "";
  widget._effectiveLoopBounds = loopBounds;
  nativeWidgetHolders.set(originalElement, { app, vm, mountNode, widget, type: "numerictextbox" });
  syncNumericState(state.value, false, false);
  installLegacyNumericTextBoxSpinnerRepeat(widget);
  installLoopNumericTextBoxWheel(widget, loopBounds);
  scheduleWidgetTimeout(widget, () => applyLegacyKendoDomFacade(widget, "numerictextbox"), 0);
  if (shouldResolveDeferredNumericValue) {
    scheduleWidgetTimeout(widget, () => {
      if (nativeWidgetHolders.get(originalElement)?.widget !== widget) {
        return;
      }
      const deferredValue = resolveInitialNumericValue(undefined, originalElement);
      const currentValue = widget.value();
      if (deferredValue !== null && (currentValue === undefined || currentValue === null || currentValue === "")) {
        widget.value(deferredValue);
      }
    }, 0);
  }
  installLegacyWidgetObservable(widget);
  syncLegacyWidgetRole(widget, "numerictextbox");
  return defineWidgetData(originalElement, "kendoNumericTextBox", widget).data("kendoNumericTextBox");
}



function mountColorPicker(element, options = {}) {
  const originalElement = element?.jquery ? element[0] : element;
  if (!originalElement) {
    return null;
  }

  destroyMountedWidget(originalElement);
  setLegacyWidgetRole(originalElement, "colorpicker");
  const inputName = resolveLegacyInputName(options, originalElement);
  const widgetOptions = createLegacyWidgetOptions(options, "ColorPicker", inputName);

  const mountNode = createMountNode(originalElement);
  const state = {
    value: options.value ?? originalElement.value ?? '#000000',
    disabled: options.enabled === false || options.disabled === true || originalElement.disabled === true
  };

  let widget = null;

  const Root = {
    data() {
      return state;
    },
    methods: {
      handleChange(event) {
        const nextValue = event?.value ?? event?.target?.value ?? this.value;
        this.value = nextValue;
        syncOriginalValue(originalElement, nextValue);
        widget.trigger("change", createLegacyKendoEvent(event, widget, { value: nextValue }));
      }
    },
    render() {
      return h(ColorPicker, {
        value: this.value,
        disabled: this.disabled,
        palette: options.palette || 'basic',
        tileSize: options.tileSize,
        onChange: this.handleChange
      });
    }
  };

  const app = createApp(Root);
  const vm = app.mount(mountNode);

  widget = {
    options: widgetOptions,
    vm,
    app,
    mountNode,
    originalElement,
    get element() {
      return $(findVisibleInput(mountNode) || originalElement);
    },
    get wrapper() {
      return $(mountNode);
    },
    value(nextValue) {
      if (nextValue === undefined) {
        return vm.value;
      }
      vm.value = nextValue;
      syncOriginalValue(originalElement, nextValue);
      return vm.value;
    },
    enable(enabled = true) {
      vm.disabled = !enabled;
    },
    open() {
      const trigger = mountNode.querySelector('button, [role="button"], input');
      trigger?.click?.();
    },
    trigger(name, rawEvent = null) {
      const event = createLegacyKendoEvent(rawEvent, widget, { value: vm.value });
      if (name === "change") {
        invokeHandler(options.change, widget, event);
        return event;
      }
      return event;
    },
    destroy() {
      destroyMountedWidget(originalElement);
    }
  };

  nativeWidgetHolders.set(originalElement, { app, vm, mountNode, widget, type: 'colorpicker' });
  syncOriginalValue(originalElement, state.value);
  installLegacyWidgetObservable(widget);
  syncLegacyWidgetRole(widget, "colorpicker");
  return defineWidgetData(originalElement, 'kendoColorPicker', widget).data('kendoColorPicker');
}

function getEditorBodyElement(root) {
  if (!root || typeof root.querySelector !== "function") {
    return null;
  }
  return root.querySelector(".k-editor-content [contenteditable='true'], .ProseMirror, [contenteditable='true']");
}


function normalizeEditorEvent(event, pseudoWindow, body) {
  return {
    ...event,
    originalEvent: event,
    type: event?.type,
    target: event?.target || body,
    currentTarget: pseudoWindow,
    preventDefault: () => event?.preventDefault?.(),
    stopPropagation: () => event?.stopPropagation?.(),
    stopImmediatePropagation: () => event?.stopImmediatePropagation?.(),
    clipboardData: event?.clipboardData,
    inputType: event?.inputType,
    data: event?.data,
    key: event?.key
  };
}

function moveCaretToEnd(body) {
  if (!body) {
    return;
  }
  const selection = body.ownerDocument?.getSelection?.();
  if (!selection) {
    return;
  }
  const range = body.ownerDocument.createRange();
  range.selectNodeContents(body);
  range.collapse(false);
  selection.removeAllRanges();
  selection.addRange(range);
}

function insertHtmlAtSelection(body, html) {
  if (!body) {
    return;
  }
  const doc = body.ownerDocument;
  const selection = doc.getSelection?.();
  body.focus?.();
  if (!selection || selection.rangeCount === 0 || !body.contains(selection.anchorNode)) {
    moveCaretToEnd(body);
  }
  const currentSelection = doc.getSelection?.();
  if (!currentSelection || currentSelection.rangeCount === 0) {
    body.insertAdjacentHTML('beforeend', html || '');
    return;
  }
  const range = currentSelection.getRangeAt(0);
  range.deleteContents();
  const fragment = range.createContextualFragment(html || '');
  const lastNode = fragment.lastChild;
  range.insertNode(fragment);
  if (lastNode) {
    range.setStartAfter(lastNode);
    range.collapse(true);
    currentSelection.removeAllRanges();
    currentSelection.addRange(range);
  }
}

function createPseudoEditorDocument(body) {
  const ownerDocument = body?.ownerDocument || (typeof document !== 'undefined' ? document : null);
  if (!ownerDocument) {
    return null;
  }
  const documentElement = ownerDocument.documentElement || body;
  const pseudoDocumentElement = typeof Proxy !== 'undefined'
    ? new Proxy(documentElement, {
      get(target, property) {
        if (property === 'lastElementChild') {
          return body;
        }
        if (property === 'children') {
          return [body];
        }
        const value = target[property];
        return typeof value === 'function' ? value.bind(target) : value;
      }
    })
    : documentElement;
  if (typeof Proxy === 'undefined') {
    return ownerDocument;
  }
  return new Proxy(ownerDocument, {
    get(target, property) {
      if (property === 'body') {
        return body;
      }
      if (property === 'documentElement') {
        return pseudoDocumentElement;
      }
      if (property === 'activeElement') {
        return body.contains?.(target.activeElement) ? target.activeElement : body;
      }
      if (property === 'defaultView') {
        return body.ownerDocument?.defaultView || target.defaultView;
      }
      if (property === 'createRange') {
        return target.createRange?.bind(target);
      }
      if (property === 'getSelection') {
        return target.getSelection?.bind(target);
      }
      if (property === 'querySelector') {
        return body.querySelector?.bind(body);
      }
      if (property === 'querySelectorAll') {
        return body.querySelectorAll?.bind(body);
      }
      if (property === 'getElementById') {
        return (id) => {
          const found = target.getElementById?.(id) || null;
          return found && body.contains?.(found) ? found : null;
        };
      }
      const value = target[property];
      return typeof value === 'function' ? value.bind(target) : value;
    }
  });
}

function getEditorBodyCleanups(body) {
  if (!body) {
    return null;
  }
  if (!Array.isArray(body.__ntssKendoEditorCleanups)) {
    try {
      Object.defineProperty(body, "__ntssKendoEditorCleanups", {
        configurable: true,
        enumerable: false,
        value: [],
        writable: true
      });
    } catch (_error) {
      body.__ntssKendoEditorCleanups = [];
    }
  }
  return body.__ntssKendoEditorCleanups;
}

function registerEditorBodyCleanup(body, cleanup) {
  if (typeof cleanup === "function") {
    getEditorBodyCleanups(body)?.push(cleanup);
  }
}

function cleanupEditorBody(body) {
  const listeners = editorListenersByBody.get(body);
  if (listeners) {
    listeners.forEach((current) => {
      try {
        body.removeEventListener(current.type, current.wrapped, true);
      } catch (_error) {
        // noop
      }
    });
    listeners.clear?.();
  }
  editorListenersByBody.delete(body);
  editorWidgetsByBody.delete(body);
  const cleanups = getEditorBodyCleanups(body);
  while (cleanups?.length) {
    try {
      cleanups.pop()?.();
    } catch (_error) {
      // noop
    }
  }
}

function createPseudoEditorWindow(body) {
  const pseudoDocument = createPseudoEditorDocument(body);
  const proxy = {
    document: pseudoDocument || body.ownerDocument,
    getSelection() {
      return body.ownerDocument?.getSelection?.();
    },
    addEventListener(type, handler) {
      const wrapped = (event) => handler(normalizeEditorEvent(event, proxy, body));
      let listeners = editorListenersByBody.get(body);
      if (!listeners) {
        listeners = new Map();
        editorListenersByBody.set(body, listeners);
      }
      listeners.set(handler, { type, wrapped });
      body.addEventListener(type, wrapped, true);
      registerEditorBodyCleanup(body, () => body.removeEventListener(type, wrapped, true));
    },
    removeEventListener(type, handler) {
      const listeners = editorListenersByBody.get(body);
      const current = listeners?.get?.(handler);
      if (!current) {
        return;
      }
      body.removeEventListener(current.type, current.wrapped, true);
      listeners.delete(handler);
    },
    focus() {
      body.focus?.();
    }
  };

  ["blur", "keydown", "keyup", "beforeinput", "input", "compositionend", "copy"].forEach((type) => {
    const handler = (event) => {
      const normalized = normalizeEditorEvent(event, proxy, body);
      const jEvent = $.Event(type);
      Object.assign(jEvent, normalized);
      $(proxy).triggerHandler(jEvent);
    };
    body.addEventListener(type, handler, true);
    registerEditorBodyCleanup(body, () => body.removeEventListener(type, handler, true));
  });

  const pasteHandler = (event) => {
    const widget = editorWidgetsByBody.get(body);
    if (!widget?.options?.paste) {
      return;
    }
    const html = event.clipboardData?.getData?.('text/html') || event.clipboardData?.getData?.('text/plain') || '';
    const payload = { sender: widget, html };
    widget.options.paste.call(widget, payload);
    if (payload.html !== html) {
      event.preventDefault();
      insertHtmlAtSelection(body, payload.html || '');
      body.dispatchEvent(new Event('input', { bubbles: true }));
    }
  };
  body.addEventListener('paste', pasteHandler, true);
  registerEditorBodyCleanup(body, () => body.removeEventListener('paste', pasteHandler, true));

  return proxy;
}

function createEditorAdapter(rawWidget, originalElement, mountNode = null) {
  if (!rawWidget) {
    return null;
  }
  const cached = editorAdapters.get(rawWidget);
  if (cached) {
    return cached;
  }

  const adapter = {
    get element() {
      return rawWidget.element || $(originalElement);
    },
    get wrapper() {
      return rawWidget.wrapper || $(mountNode || originalElement);
    },
    get body() {
      return rawWidget.body
        || rawWidget.window?.document?.body
        || this.wrapper?.[0]?.querySelector?.('.k-editor-content, [contenteditable="true"]')
        || null;
    },
    get window() {
      return rawWidget.window || this.body?.ownerDocument?.defaultView || null;
    },
    exec(command, payload = {}) {
      const cmd = typeof command === 'string' ? String(command).toLowerCase() : command;
      return rawWidget.exec?.(cmd, payload);
    },
    createRange() {
      return rawWidget.createRange?.() || this.body?.ownerDocument?.createRange?.() || null;
    },
    selectRange(range) {
      if (rawWidget.selectRange) {
        return rawWidget.selectRange(range);
      }
      const selection = this.window?.getSelection?.();
      if (!selection || !range) {
        return;
      }
      selection.removeAllRanges();
      selection.addRange(range);
    },
    value(nextValue) {
      if (nextValue === undefined) {
        return rawWidget.value?.() ?? this.body?.innerHTML ?? '';
      }
      if (rawWidget.value) {
        return rawWidget.value(nextValue);
      }
      if (this.body) {
        this.body.innerHTML = nextValue || '';
      }
      return this.body?.innerHTML || '';
    },
    focus() {
      return rawWidget.focus?.() || this.body?.focus?.();
    },
    destroy() {
      cleanupEditorBody(this.body);
      return rawWidget.destroy?.();
    },
    rawWidget() {
      return rawWidget;
    }
  };

  editorAdapters.set(rawWidget, adapter);
  return adapter;
}

function applyLegacyEditorHeightSemantics(rawWidget, originalElement) {
  const wrapper = rawWidget?.wrapper?.[0]
    || originalElement?.closest?.('.k-editor')
    || null;
  if (!wrapper) {
    return;
  }

  wrapper.classList.add('k-legacy-editor');
  const heightStyle = String(wrapper.style?.height || '').trim().toLowerCase();
  const heightValue = parseFloat(heightStyle);
  if (heightStyle.endsWith('px') && !Number.isNaN(heightValue) && heightValue <= 0) {
    wrapper.classList.add('k-legacy-editor-zero-height');
    wrapper.setAttribute('aria-hidden', 'true');
  } else {
    wrapper.classList.remove('k-legacy-editor-zero-height');
    wrapper.removeAttribute('aria-hidden');
  }
}

function normalizeEditorStylesheetList(options = {}) {
  const raw = Array.isArray(options.stylesheets) ? options.stylesheets : [];
  return raw.filter((href) => typeof href === 'string' && href.trim() !== '');
}

function ensureEditorDocumentStylesheets(rawWidget, options = {}) {
  const body = rawWidget?.body || rawWidget?.window?.document?.body || null;
  const ownerDocument = body?.ownerDocument || rawWidget?.window?.document || null;
  const head = ownerDocument?.head || ownerDocument?.documentElement || null;
  if (!head) {
    return;
  }
  normalizeEditorStylesheetList(options).forEach((href) => {
    const token = String(href);
    const escaped = token.replace(/"/g, '\"');
    if (ownerDocument.querySelector?.(`link[data-ntss-kendo-editor-stylesheet="${escaped}"]`)) {
      return;
    }
    const link = ownerDocument.createElement('link');
    link.rel = 'stylesheet';
    link.href = token;
    link.setAttribute('data-ntss-kendo-editor-stylesheet', token);
    head.appendChild(link);
  });
}

function applyLegacyEditorDomFacade(rawWidget, originalElement, options = {}) {
  if (!rawWidget) {
    return;
  }
  const wrapper = rawWidget?.wrapper?.[0]
    || originalElement?.closest?.('.k-editor')
    || null;
  const body = rawWidget?.body || rawWidget?.window?.document?.body || null;
  addClasses(wrapper, ['k-widget', 'k-editor', 'k-legacy-editor']);
  const toolbar = rawWidget?.toolbar?.element?.[0] || wrapper?.querySelector?.('.k-editor-toolbar, [role="toolbar"]') || null;
  addClasses(toolbar, ['k-editor-toolbar', 'k-toolbar', 'k-legacy-editor-toolbar']);
  toolbar?.querySelectorAll?.('button, .k-button, [role="button"]').forEach((button) => addClasses(button, ['k-button', 'k-button-icontext', 'k-legacy-editor-button']));
  toolbar?.querySelectorAll?.('.k-icon, .k-svg-icon, svg').forEach((icon) => addClasses(icon, ['k-legacy-editor-icon']));
  toolbar?.querySelectorAll?.('.k-dropdownlist, .k-combobox, .k-picker, .k-input, .k-input-inner').forEach((control) => addClasses(control, ['k-legacy-editor-control']));
  addClasses(body, ['k-legacy-editor-body']);
  // リッチテキストエディタではtitle属性の表示が必須であり、これを非表示にすることはできません
  // clearKendoEditorControlTitles(wrapper || originalElement);
  // clearKendoEditorControlTitles(body);
  applyLegacyEditorHeightSemantics(rawWidget, originalElement);
  ensureEditorDocumentStylesheets(rawWidget, options);
}

function ensureEditorBody(mountNode, state) {
  let body = getEditorBodyElement(mountNode);
  if (body) {
        body.setAttribute('contenteditable', state.disabled ? 'false' : 'true');
    if (state.html && body.innerHTML !== state.html) {
      body.innerHTML = state.html;
    }
    return body;
  }

  const ownerDocument = mountNode?.ownerDocument || (typeof document !== 'undefined' ? document : null);
  if (!ownerDocument) {
    return null;
  }

  body = ownerDocument.createElement('div');
  body.className = 'k-editor-content';
  body.setAttribute('contenteditable', state.disabled ? 'false' : 'true');
  body.innerHTML = state.html || '';
  mountNode.appendChild(body);
  return body;
}

function mountEditor(element, options = {}) {
  const originalElement = element?.jquery ? element[0] : element;
  if (!originalElement) {
    return null;
  }

  destroyMountedWidget(originalElement);
  setLegacyWidgetRole(originalElement, "editor");
  const inputName = resolveLegacyInputName(options, originalElement);
  const widgetOptions = createLegacyWidgetOptions(options, "Editor", inputName);

  const $original = $(originalElement);
  const currentEditor = $original.data('kendoEditor');
  if (currentEditor?.destroy) {
    currentEditor.destroy();
  }

  const originalPlugin = originalEditorPlugin;
  if (typeof originalPlugin === 'function') {
    originalPlugin.call($original, options);
    const widget = $original.data('kendoEditor') || null;
    if (widget) {
      widget.element = widget.element || $original;
      widget.wrapper = widget.wrapper || $original.closest('.k-editor');
      syncLegacyWidgetRole(widget, "editor");
      applyLegacyEditorDomFacade(widget, originalElement, options);
    }
    return createEditorAdapter(widget, originalElement, widget?.wrapper?.[0] || null);
  }

  const mountNode = createMountNode(originalElement);
  mountNode.classList.add('k-widget', 'k-editor');
  const state = {
    html: options.value ?? originalElement.value ?? '',
    disabled: options.enabled === false || options.disabled === true || originalElement.disabled === true
  };

  let widget = null;

  const Root = {
    data() {
      return state;
    },
    methods: {
      handleChange(event) {
        this.html = event?.html ?? event?.value ?? state.html;
        syncOriginalValue(originalElement, this.html);
        if (widget?.body && widget.body.innerHTML !== this.html) {
          widget.body.innerHTML = this.html || '';
        }
      }
    },
    render() {
      return h('div', { class: 'k-editor' }, [
        h(Editor, {
          tools: options.tools || [],
          value: this.html,
          defaultContent: this.html,
          disabled: this.disabled,
          onChange: this.handleChange
        })
      ]);
    }
  };

  const app = createApp(Root);
  const vm = app.mount(mountNode);
  const body = ensureEditorBody(mountNode, state);
  // リッチテキストエディタではtitle属性の表示が必須であり、これを非表示にすることはできません
  // clearKendoEditorControlTitles(mountNode);
  const pseudoWindow = createPseudoEditorWindow(body);

  function syncStateFromBody() {
    state.html = body.innerHTML || '';
    syncOriginalValue(originalElement, state.html);
  }

  body.addEventListener('input', syncStateFromBody, true);
  registerEditorBodyCleanup(body, () => body.removeEventListener('input', syncStateFromBody, true));
  editorWidgetsByBody.set(body, widget);

  widget = {
    options: widgetOptions,
    vm,
    app,
    mountNode,
    originalElement,
    body,
    window: pseudoWindow,
    get element() {
      return $(originalElement);
    },
    get wrapper() {
      return $(mountNode);
    },
    exec(command, payload = {}) {
      const doc = body.ownerDocument;
      body.focus?.();
      const commandName = String(command || '').toLowerCase();
      if (commandName === 'inserthtml') {
        insertHtmlAtSelection(body, payload.value || '');
        syncStateFromBody();
        return;
      }
      if (commandName === 'fontname' && doc.execCommand) {
        doc.execCommand('fontName', false, payload.value || '');
      } else if (commandName === 'fontsize' && doc.execCommand) {
        const size = payload.value || '';
        body.style.fontSize = size;
      } else if (commandName === 'forecolor' && doc.execCommand) {
        doc.execCommand('foreColor', false, payload.value || '');
      } else if (commandName === 'backcolor' && doc.execCommand) {
        doc.execCommand('hiliteColor', false, payload.value || '');
      } else if (doc.execCommand) {
        doc.execCommand(command, false, payload.value || null);
      }
      syncStateFromBody();
    },
    createRange() {
      return body.ownerDocument.createRange();
    },
    selectRange(range) {
      const selection = body.ownerDocument.getSelection?.();
      if (!selection || !range) {
        return;
      }
      selection.removeAllRanges();
      selection.addRange(range);
    },
    value(nextValue) {
      if (nextValue === undefined) {
        return body.innerHTML || '';
      }
      body.innerHTML = nextValue || '';
      syncStateFromBody();
      return body.innerHTML;
    },
    focus() {
      body.focus?.();
    },
    destroy() {
      cleanupEditorBody(body);
      destroyMountedWidget(originalElement);
    }
  };

  registerWidgetCleanup(widget, () => cleanupEditorBody(body));
  editorWidgetsByBody.set(body, widget);
  syncLegacyWidgetRole(widget, "editor");
  const adapter = createEditorAdapter(widget, originalElement, mountNode);
  syncLegacyWidgetRole(adapter, "editor");
  registerWidgetCleanup(adapter, () => cleanupEditorBody(body));
  nativeWidgetHolders.set(originalElement, { app, vm, mountNode, widget: adapter, type: 'editor' });
  syncOriginalValue(originalElement, state.html);
  applyLegacyEditorDomFacade(adapter, originalElement, options);
  defineWidgetData(originalElement, 'kendoEditor', widget);
  return adapter;
}


function escapeSelectorId(id) {
  try {
    return typeof CSS !== "undefined" && typeof CSS.escape === "function"
      ? CSS.escape(String(id))
      : String(id).replace(/([ #;?%&,.+*~':"!^$[\]()=>|/@])/g, "\\$1");
  } catch (_error) {
    return String(id || "").replace(/"/g, '\\"');
  }
}

function quoteAttributeValue(value) {
  return String(value || "").replace(/"/g, '\\"');
}

function buildEditorTargetSelectors(target) {
  const text = String(target || "").trim();
  if (!text) {
    return [];
  }
  if (text.startsWith("#")) {
    const id = text.slice(1);
    return [`#${escapeSelectorId(id)}`, `[id="${quoteAttributeValue(id)}"]`];
  }
  if (/^[A-Za-z][A-Za-z0-9_-]*$/.test(text)) {
    return [`#${escapeSelectorId(text)}`, `[id="${quoteAttributeValue(text)}"]`, text];
  }
  return [text];
}

function queryEditorTarget(candidate, selectors) {
  if (!candidate || typeof candidate.querySelector !== 'function') {
    return null;
  }
  for (const selector of selectors) {
    try {
      const found = candidate.querySelector(selector);
      if (found) {
        return found;
      }
    } catch (_error) {
      // noop
    }
  }
  return null;
}

function resolveTargetWithinScope(target, root = null) {
  if (!target || typeof target !== 'string') {
    return null;
  }
  const rawRoot = root?.jquery ? root[0] : root;
  const activeDocument = rawRoot?.ownerDocument || (typeof document !== 'undefined' ? document : null);
  const selectors = buildEditorTargetSelectors(target);
  const roots = [];
  const pushRoot = (candidate) => {
    if (candidate && !roots.includes(candidate)) {
      roots.push(candidate);
    }
  };
  pushRoot(rawRoot);
  pushRoot(rawRoot?.closest?.('.k-editor'));
  pushRoot(activeDocument?.body);
  pushRoot(activeDocument);
  for (const candidate of roots) {
    const found = queryEditorTarget(candidate, selectors);
    if (found) {
      return found;
    }
  }
  return null;
}


function getEditorWidget(target) {
  if (!target) {
    return null;
  }
  if (target?.rawWidget) {
    return target;
  }
  if (target.jquery) {
    return createEditorAdapter(target.data('kendoEditor'), target[0] || null, target.closest?.('.k-editor')?.[0] || null);
  }
  if (typeof target === 'string') {
    const activeElement = typeof document !== 'undefined' ? document.activeElement : null;
    const found = resolveTargetWithinScope(target, activeElement || null);
    return found ? createEditorAdapter($(found).data('kendoEditor'), found, found.closest?.('.k-editor') || null) : null;
  }
  return createEditorAdapter($(target).data('kendoEditor'), target, target.closest?.('.k-editor') || null);
}

function getNativeWidget(target, keys = []) {
  const list = Array.isArray(keys) ? keys : [keys];
  const element = target?.jquery ? target[0] : target;
  if (element) {
    const holder = nativeWidgetHolders.get(element);
    if (holder?.widget) {
      return holder.widget;
    }
  }
  const $target = target?.jquery ? target : $(target || []);
  for (const key of list.filter(Boolean)) {
    const widget = $target.data(key);
    if (widget) {
      return widget;
    }
  }
  return null;
}

function destroyNativeWidget(target) {
  const element = target?.jquery ? target[0] : target;
  if (!element) {
    return;
  }
  const directWidget = getNativeWidget(element, Object.values(LEGACY_WIDGET_DATA_KEYS).flat());
  if (directWidget?.destroy && !nativeWidgetHolders.has(element)) {
    try {
      directWidget.destroy();
    } catch (_error) {
      // noop
    }
  }
  destroyMountedWidget(element);
}

function destroyNativeWidgetsIn(root = null) {
  const scope = root?.jquery ? root[0] : root;
  if (!scope) {
    return 0;
  }
  const nodes = [scope, ...Array.from(scope.querySelectorAll?.('*') || [])];
  const seenWidgets = new Set();
  let count = 0;
  nodes.forEach((node) => {
    const $node = $(node);
    Object.values(LEGACY_WIDGET_DATA_KEYS).flat().forEach((key) => {
      const widget = $node.data(key);
      if (!widget || seenWidgets.has(widget)) {
        return;
      }
      seenWidgets.add(widget);
      try {
        widget.destroy?.();
        count += 1;
      } catch (_error) {
        // noop
      }
      removeJQueryWidgetData(node, [key]);
    });
    destroyMountedWidget(node);
  });
  return count;
}

function installKendoNativeWidgets() {
  if (nativeWidgetsInstalled) {
    return;
  }

  installLegacyBodyStyleGuard();

  if (!originalEditorPlugin && typeof $.fn.kendoEditor === "function") {
    originalEditorPlugin = $.fn.kendoEditor;
  }
  if (!originalDropDownListPlugin && typeof $.fn.kendoDropDownList === "function") {
    originalDropDownListPlugin = $.fn.kendoDropDownList.__compatOriginal || $.fn.kendoDropDownList;
  }
  if (!originalMultiSelectPlugin && typeof $.fn.kendoMultiSelect === "function") {
    originalMultiSelectPlugin = $.fn.kendoMultiSelect;
  }

  // Vue2 の DropDownList は Vue wrapper tag でも直接 jQuery API でも、実体は jQuery Kendo。
  // Vue3 ではどちらの入口も同じ compat bridge に集約し、bridge 内部で原生 jQuery Kendo を作成する。
  bridgeJQueryWidgetPlugin("kendoDropDownList", mountDropDownList, { preserveExisting: false });

  if (typeof originalMultiSelectPlugin !== "function") {
    bridgeJQueryWidgetPlugin("kendoMultiSelect", mountMultiSelect, { preserveExisting: false });
  }

  bridgeJQueryWidgetPlugin("kendoNumericTextBox", mountNumericTextBox, { preserveExisting: false });

  bridgeJQueryWidgetPlugin("kendoColorPicker", mountColorPicker, { preserveExisting: false });

  bridgeJQueryWidgetPlugin("kendoEditor", mountEditor, { preserveExisting: false });

  nativeWidgetsInstalled = true;
}

function removeKendoNativeBodyScrollbarWidth(documentRef = typeof document !== "undefined" ? document : null) {
  const body = documentRef?.body || null;
  if (!body?.style) {
    return;
  }
  body.style.removeProperty("--kendo-scrollbar-width");
}

function installLegacyBodyStyleGuard() {
  const documentRef = typeof document !== "undefined" ? document : null;
  const body = documentRef?.body || null;
  if (!body || bodyScrollbarWidthObserver || typeof MutationObserver !== "function") {
    return;
  }
  removeKendoNativeBodyScrollbarWidth(documentRef);
  bodyScrollbarWidthObserver = new MutationObserver(() => removeKendoNativeBodyScrollbarWidth(documentRef));
  bodyScrollbarWidthObserver.observe(body, {
    attributes: true,
    attributeFilter: ["style"]
  });
}

function getOriginalMultiSelectPlugin() {
  const current = typeof $.fn.kendoMultiSelect === "function" ? $.fn.kendoMultiSelect : null;
  return originalMultiSelectPlugin
    || current?.__compatOriginal
    || (current && current.name !== "bridgedJQueryWidget" ? current : null);
}

function setupKendoNativeWidgets() {
  installKendoNativeWidgets();
  return {
    mountDropDownList,
    mountMultiSelect,
    mountNumericTextBox,
    mountColorPicker,
    mountEditor,
    getEditorWidget
  };
}

export {
  installKendoNativeWidgets,
  setupKendoNativeWidgets,
  mountDropDownList,
  syncJQueryDropDownListPresentation,
  mountMultiSelect,
  mountNumericTextBox,
  mountColorPicker,
  mountEditor,
  getEditorWidget,
  getNativeWidget,
  destroyNativeWidget,
  destroyNativeWidgetsIn,
  getOriginalMultiSelectPlugin
};
