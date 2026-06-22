import { Grid as KendoNativeGrid, GridNoRecords, GridToolbar } from "@progress/kendo-vue-grid";
import { h, markRaw, toRaw } from "@/compat/vue/runtime";

const EmptyGridSlotComponent = {
  name: "KendoCompatEmptyGridSlot",
  inheritAttrs: false,
  setup() {
    return () => null;
  }
};

// Kendo Vue 8 の public export は Vue2 wrapper 時代の tag 群と一致しない。
// 画面側は compat 経由で旧 import 名を使い続け、存在しない tag は wrapper 側で収集する。
const GridColumn = {
  name: "GridColumn",
  inheritAttrs: false,
  setup() {
    return () => null;
  }
};

const COMPONENT_LIKE_KEYS = new Set([
  "cell",
  "cells",
  "headerCell",
  "footerCell",
  "filterCell",
  "editor",
  "editCell",
  "groupHeaderCell",
  "groupFooterCell",
  "children",
  "columns"
]);

function isComponentLike(value) {
  if (!value || typeof value !== "object") {
    return false;
  }
  const raw = toRaw(value);
  return !!(
    raw.render ||
    raw.setup ||
    raw.template ||
    raw.__file ||
    raw.__hmrId ||
    raw.mixins ||
    raw.extends
  );
}

function markRawComponent(value) {
  if (!value || typeof value !== "object") {
    return value;
  }
  const raw = toRaw(value);
  return isComponentLike(raw) ? markRaw(raw) : raw;
}

function normalizeColumnValue(key, value) {
  if (Array.isArray(value)) {
    return value.map((item) => normalizeColumnValue(key, item));
  }
  if (!value || typeof value !== "object") {
    return value;
  }
  if (isComponentLike(value)) {
    return markRawComponent(value);
  }
  const raw = toRaw(value);
  if (!COMPONENT_LIKE_KEYS.has(key)) {
    return raw;
  }
  const normalized = { ...raw };
  Object.keys(normalized).forEach((childKey) => {
    normalized[childKey] = normalizeColumnValue(childKey, normalized[childKey]);
  });
  return normalized;
}

function normalizeColumn(column) {
  if (!column || typeof column !== "object") {
    return column;
  }
  const raw = toRaw(column);
  const normalized = { ...raw };
  Object.keys(normalized).forEach((key) => {
    normalized[key] = normalizeColumnValue(key, normalized[key]);
  });
  return normalized;
}

function normalizeColumns(columns) {
  if (!Array.isArray(columns)) {
    return columns;
  }
  return columns.map((column) => normalizeColumn(column));
}

const Grid = (KendoNativeGrid && {
  name: "KendoVueGridStateProvider",
  inheritAttrs: false,
  props: KendoNativeGrid.props || {},
  setup(props, { attrs, slots }) {
    return () => {
      const normalizedProps = {
        ...attrs,
        ...props,
        columns: normalizeColumns(props.columns ?? attrs.columns)
      };

      Object.keys(attrs).forEach((key) => {
        if (/^on[A-Z]/.test(key)) {
          normalizedProps[key] = attrs[key];
        }
      });

      return h(KendoNativeGrid, normalizedProps, slots);
    };
  }
}) || EmptyGridSlotComponent;

export { Grid, GridNoRecords, GridToolbar, GridColumn };
export const KendoGridNativeExports = {
  Grid,
  GridNoRecords,
  GridToolbar,
  GridColumn
};

export function renderGridCompatSlot(tagName, attrs = {}, children = []) {
  return h(tagName, attrs, children);
}

export default Grid;
