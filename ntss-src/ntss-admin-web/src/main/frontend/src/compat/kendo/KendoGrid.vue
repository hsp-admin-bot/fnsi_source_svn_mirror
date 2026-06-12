<template>
  <div ref="root" v-bind="rootAttrs"></div>
</template>

<script>
import $ from "@/compat/jquery";
import { createApp, h, nextTick, isProxy, toRaw, markRaw } from "vue";
import { captureKendoGridScrollPosition, restoreKendoGridScrollPosition, repairKendoGridLockedColumnLayout, attachKendoGridLockedContentScrollSync, attachKendoGridLockedLayoutRepair, attachKendoGridColumnResizeGuard, isKendoGridColumnResizeActive } from "@/compat/kendo/grid-scroll.js";
import { ensureJQueryKendo, getJQueryKendo } from "@/compat/kendo/kendo-jquery.js";
import { ensureKendoDataSourceLocalData, normalizeKendoDataSourceOptions } from "@/compat/kendo/data-source.js";
import { findKendoGridRoot, findKendoGridContent, findKendoGridLockedContent, findKendoGridHeader, findKendoGridHeaderWrap, findKendoGridHeaderScrollHost, findKendoGridLockedHeader, findKendoGridAutoScrollable, findKendoGridScrollHost, findKendoGridTable, findKendoGridLockedTable, findKendoGridThead, findKendoGridTbody, findKendoGridLockedTbody, findKendoGridBodyRows, findKendoGridLockedRows, findKendoGridSelectables, findKendoGridVerticalScrollbar, getKendoOwnerDocument } from "@/compat/kendo/dom.js";
import { createViewTimingGate } from "@/utils/viewTimingGate";
import { createLegacyKendoEvent, updateLegacySenderState } from "@/compat/kendo/legacy-sender.js";
import { destroyNativeWidgetsIn } from "@/compat/kendo/native-widgets.js";

function isPlainObject(value) {
  return value != null && typeof value === "object" && !Array.isArray(value);
}

function isFunction(value) {
  return typeof value === "function";
}

function camelize(value) {
  return String(value || "").replace(/-([a-z])/g, (_m, char) => char.toUpperCase());
}

function getAttrValue(source, ...names) {
  for (const name of names) {
    if (source && Object.prototype.hasOwnProperty.call(source, name)) {
      return source[name];
    }
  }
  return undefined;
}

function normalizeBooleanLike(value) {
  if (value === "true") {
    return true;
  }
  if (value === "false") {
    return false;
  }
  return value;
}

function normalizeArrayLike(value) {
  if (Array.isArray(value)) {
    return value;
  }
  return value;
}

function isPercentGridHeight(value) {
  return typeof value === "string" && value.trim().endsWith("%");
}

function isLegacyHeaderOnlyGridHeight(value) {
  if (value === 0 || value === 1) {
    return true;
  }
  if (typeof value !== "string") {
    return false;
  }
  const normalizedValue = value.trim();
  return normalizedValue === "0" || normalizedValue === "1";
}

function measureGridDomHeight(element) {
  if (!element) {
    return 0;
  }
  const rectHeight = element.getBoundingClientRect?.().height;
  if (Number.isFinite(rectHeight) && rectHeight > 0) {
    return rectHeight;
  }
  const clientHeight = element.clientHeight;
  return Number.isFinite(clientHeight) && clientHeight > 0 ? clientHeight : 0;
}

function directChildContaining(parent, descendant) {
  if (!parent || !descendant) {
    return null;
  }
  let current = descendant;
  while (current && current.parentElement && current.parentElement !== parent) {
    current = current.parentElement;
  }
  return current?.parentElement === parent ? current : null;
}

function measurePrecedingToolbarChildrenHeight(toolbar, gridRoot) {
  const gridChild = directChildContaining(toolbar, gridRoot);
  if (!toolbar || !gridChild) {
    return 0;
  }
  let height = 0;
  for (const child of Array.from(toolbar.children || [])) {
    if (child === gridChild) {
      break;
    }
    const style = child.ownerDocument?.defaultView?.getComputedStyle?.(child) || null;
    if (style?.display === "none" || style?.position === "absolute" || style?.position === "fixed") {
      continue;
    }
    height += measureGridDomHeight(child);
  }
  return height;
}

function unwrapReactive(value) {
  return isProxy(value) ? toRaw(value) : value;
}

function resolveDataSource(source) {
  const resolvedSource = unwrapReactive(source);
  if (!resolvedSource) {
    return [];
  }
  if (resolvedSource?.getDataSource && isFunction(resolvedSource.getDataSource)) {
    return unwrapReactive(resolvedSource.getDataSource());
  }
  return resolvedSource;
}

const legacyGridDataSourceFacades = new WeakMap();

function createLegacyGridDataSourceFacade(source, itemsProvider) {
  const resolvedSource = unwrapReactive(source);
  if (!resolvedSource || (typeof resolvedSource !== "object" && typeof resolvedSource !== "function")) {
    return resolvedSource || null;
  }
  const cachedFacade = legacyGridDataSourceFacades.get(resolvedSource);
  if (cachedFacade) {
    return cachedFacade;
  }
  const facade = new Proxy(resolvedSource, {
    get(target, property, receiver) {
      if (property === "data") {
        return itemsProvider();
      }
      if (property === "__ntssNativeDataSource") {
        return target;
      }
      const value = Reflect.get(target, property, receiver);
      return isFunction(value) ? value.bind(target) : value;
    },
    set(target, property, value, receiver) {
      if (property === "data" && isFunction(target.data)) {
        target.data(value);
        return true;
      }
      return Reflect.set(target, property, value, receiver);
    }
  });
  legacyGridDataSourceFacades.set(resolvedSource, facade);
  return facade;
}


function isKendoDataSource(value) {
  return !!(
    value
    && isFunction(value.fetch)
    && isFunction(value.data)
    && (isFunction(value.view) || isFunction(value.total))
  );
}

function createGridDataSource(source) {
  const resolved = resolveDataSource(source);
  if (resolved == null) {
    return null;
  }
  if (isKendoDataSource(resolved)) {
    return markRaw(ensureKendoDataSourceLocalData(resolved));
  }
  const kendo = getJQueryKendo();
  const DataSource = kendo?.data?.DataSource;
  if (!DataSource) {
    return resolved;
  }
  if (Array.isArray(resolved) || isPlainObject(resolved)) {
    return markRaw(ensureKendoDataSourceLocalData(new DataSource(normalizeKendoDataSourceOptions(resolved))));
  }
  return resolved;
}

function getDataSourceSize(source) {
  const resolved = resolveDataSource(source);
  if (resolved == null) {
    return 0;
  }
  if (Array.isArray(resolved)) {
    return resolved.length;
  }
  const optionsData = unwrapReactive(resolved?.options?.data);
  if (Array.isArray(optionsData) && optionsData.length > 0) {
    return optionsData.length;
  }
  if (isFunction(resolved.total)) {
    try {
      const total = resolved.total();
      if (Number.isFinite(total)) {
        return total;
      }
    } catch (_error) {
      // noop
    }
  }
  if (isFunction(resolved.data)) {
    try {
      const data = resolved.data();
      return Array.isArray(data) ? data.length : (data?.length || 0);
    } catch (_error) {
      // noop
    }
  }
  if (isFunction(resolved.view)) {
    try {
      const view = resolved.view();
      return Array.isArray(view) ? view.length : (view?.length || 0);
    } catch (_error) {
      // noop
    }
  }
  return 0;
}

function unwrapComponent(candidate) {
  const rawCandidate = unwrapReactive(candidate);
  const component = unwrapReactive(rawCandidate?.default || rawCandidate);
  return component && (typeof component === "object" || typeof component === "function") ? markRaw(component) : component;
}

function cloneColumn(column) {
  if (!isPlainObject(column)) {
    return column;
  }
  const cloned = { ...column };
  if (Array.isArray(column.columns)) {
    cloned.columns = column.columns.map((item) => cloneColumn(item));
  }
  return cloned;
}

function setNestedOption(target, path, value) {
  if (!isPlainObject(target) || !Array.isArray(path) || path.length === 0) {
    return;
  }
  let cursor = target;
  path.forEach((segment, index) => {
    if (index === path.length - 1) {
      cursor[segment] = value;
      return;
    }
    if (!isPlainObject(cursor[segment])) {
      cursor[segment] = {};
    }
    cursor = cursor[segment];
  });
}


function resolveVNodeTypeName(node) {
  const nodeType = node?.type;
  if (typeof nodeType === "string") {
    return nodeType;
  }
  if (typeof nodeType === "object" && nodeType !== null) {
    return nodeType.name || nodeType.__name || "";
  }
  return "";
}

function collectColumnsFromVNodes(nodes, acc = []) {
  (nodes || []).forEach((node) => {
    if (!node || typeof node !== "object") {
      return;
    }
    if (Array.isArray(node)) {
      collectColumnsFromVNodes(node, acc);
      return;
    }

    const nodeName = resolveVNodeTypeName(node);

    if (["KendoGridColumn", "GridColumn", "kendo-grid-column"].includes(nodeName)) {
      const props = { ...(node.props || {}) };
      if (node.children && isPlainObject(node.children)) {
        const nested = [];
        Object.values(node.children).forEach((child) => {
          if (isFunction(child)) {
            try {
              collectColumnsFromVNodes(child(), nested);
            } catch (_error) {
              // noop
            }
          }
        });
        if (nested.length > 0) {
          props.columns = nested;
        }
      }
      acc.push(props);
      return;
    }

    if (Array.isArray(node.children)) {
      collectColumnsFromVNodes(node.children, acc);
      return;
    }

    if (isPlainObject(node.children)) {
      Object.values(node.children).forEach((child) => {
        if (isFunction(child)) {
          try {
            collectColumnsFromVNodes(child(), acc);
          } catch (_error) {
            // noop
          }
        }
      });
    }
  });
  return acc;
}


function collectToolbarFromVNodes(nodes) {
  for (const node of nodes || []) {
    if (!node || typeof node !== "object") {
      continue;
    }
    if (Array.isArray(node)) {
      const nested = collectToolbarFromVNodes(node);
      if (nested) {
        return nested;
      }
      continue;
    }
    const nodeName = resolveVNodeTypeName(node);
    if (["KendoGridToolbar", "GridToolbar", "kendo-grid-toolbar"].includes(nodeName)) {
      if (node.children && isPlainObject(node.children)) {
        return node.children.default || node.children;
      }
      return node.children || [];
    }
    if (Array.isArray(node.children)) {
      const nested = collectToolbarFromVNodes(node.children);
      if (nested) {
        return nested;
      }
    } else if (isPlainObject(node.children)) {
      for (const child of Object.values(node.children)) {
        if (isFunction(child)) {
          try {
            const nested = collectToolbarFromVNodes(child());
            if (nested) {
              return nested;
            }
          } catch (_error) {
            // noop
          }
        }
      }
    }
  }
  return null;
}


function isVueTemplateDescriptor(value) {
  return isPlainObject(value) && value.template;
}

const COLUMN_HANDLER_KEY_MAP = {
  onEditor: "editor",
  onEditable: "editable",
  onTemplate: "template",
  onHeaderTemplate: "headerTemplate",
  onFooterTemplate: "footerTemplate"
};

const EMIT_EVENT_MAP = {
  save: "save",
  edit: "edit",
  beforeEdit: "beforeedit",
  cellClose: "cellclose",
  dataBound: "databound",
  dataBinding: "databinding",
  change: "change",
  cancel: "cancel",
  remove: "remove",
  sort: "sort",
  columnResize: "columnresize",
  columnReorder: "columnreorder",
  detailInit: "detailinit"
};

const DIRECT_EVENT_KEYS = [
  "save",
  "edit",
  "beforeEdit",
  "before-edit",
  "cellClose",
  "cell-close",
  "dataBound",
  "data-bound",
  "dataBinding",
  "data-binding",
  "change",
  "cancel",
  "remove",
  "sort",
  "columnResize",
  "column-resize",
  "columnReorder",
  "column-reorder",
  "detailInit",
  "detail-init"
];

const DATA_SOURCE_REF_IDS = new WeakMap();
let dataSourceRefSeq = 0;

function getStableRefId(value) {
  if (value == null || (typeof value !== "object" && typeof value !== "function")) {
    return null;
  }
  const rawValue = unwrapReactive(value);
  if (!DATA_SOURCE_REF_IDS.has(rawValue)) {
    dataSourceRefSeq += 1;
    DATA_SOURCE_REF_IDS.set(rawValue, dataSourceRefSeq);
  }
  return DATA_SOURCE_REF_IDS.get(rawValue);
}

function describeDataSourceInput(value) {
  const resolved = unwrapReactive(value);
  if (resolved == null) {
    return { kind: "null" };
  }
  if (isKendoDataSource(resolved)) {
    return {
      kind: "kendo-data-source",
      refId: getStableRefId(resolved),
      dataRefId: getStableRefId(isFunction(resolved.data) ? resolved.data() : null),
      total: getDataSourceSize(resolved)
    };
  }
  if (Array.isArray(resolved)) {
    return {
      kind: "array",
      refId: getStableRefId(resolved),
      length: resolved.length
    };
  }
  if (isPlainObject(resolved)) {
    const resolvedData = unwrapReactive(resolved.data);
    return {
      kind: "plain",
      refId: getStableRefId(resolved),
      dataRefId: getStableRefId(resolvedData),
      schemaRefId: getStableRefId(unwrapReactive(resolved.schema)),
      transportRefId: getStableRefId(unwrapReactive(resolved.transport)),
      groupRefId: getStableRefId(unwrapReactive(resolved.group)),
      sortRefId: getStableRefId(unwrapReactive(resolved.sort)),
      filterRefId: getStableRefId(unwrapReactive(resolved.filter)),
      pageSize: resolved.pageSize ?? null,
      length: Array.isArray(resolvedData) ? resolvedData.length : null
    };
  }
  return { kind: typeof resolved, value: resolved };
}

const ROOT_ATTR_KEYS = new Set(["id", "class", "style", "title"]);

export default {
  name: "KendoGrid",
  inheritAttrs: false,
  emits: [
    "save",
    "edit",
    "beforeedit",
    "cellclose",
    "databound",
    "databinding",
    "change",
    "cancel",
    "remove",
    "sort",
    "columnresize",
    "columnreorder",
    "detailinit"
  ],
  data() {
    return {
      widget: null,
      dataSourceInstance: null,
      templateMounts: [],
      renderRevision: 0,
      pendingRebuild: false,
      lastColumnsSignature: "",
      lastColumnsStructuralSignature: "",
      lastOptionsSignature: "",
      timingGate: null,
      destroyingGrid: false,
      lastDataSourceSignature: "",
      pendingStructuralRebuild: false,
      suppressRefresh: false,
      suppressRefreshReleaseTimer: null,
      columnSignaturePollTimer: null,
      columnSignaturePollUntil: 0,
      gridCleanupList: [],
      gridFrameCleanupList: [],
      applyingMasterGridHeightLayout: false,
      legacyDirtyCellHints: {}
    };
  },
  computed: {
    rootAttrs() {
      const attrs = {};
      Object.entries(this.$attrs || {}).forEach(([key, value]) => {
        if (ROOT_ATTR_KEYS.has(key)) {
          attrs[key] = value;
        }
      });
      return attrs;
    },
    parsedColumns() {
      return this.resolveParsedColumns();
    },
    dataSource() {
      return this.gridDataSource()
        || createLegacyGridDataSourceFacade(
          resolveDataSource(getAttrValue(this.$attrs, "data-source", "dataSource")),
          () => this.gridDataSourceItemsFromSource(resolveDataSource(getAttrValue(this.$attrs, "data-source", "dataSource")))
        );
    },
    columns() {
      return this.widget?.columns || this.parsedColumns;
    },
    element() {
      return this.widget?.element || $(this.$refs.root || []);
    },
    wrapper() {
      return this.widget?.wrapper || $(this.$refs.root || []);
    },
    table() {
      return this.widget?.table || $([]);
    },
    thead() {
      return this.widget?.thead || $([]);
    },
    tbody() {
      return this.widget?.tbody || $([]);
    },
    content() {
      return this.widget?.content || $([]);
    }
  },
  created() {
    this.timingGate = createViewTimingGate('kendo-grid');
  },
  async mounted() {
    await this.waitForInitialDeclarativeColumns();
    if (!this.hasPotentialDeclarativeColumns() || this.hasResolvedDeclarativeColumns()) {
      await this.buildGrid();
    }
  },
  updated() {
    if (!this.widget && this.hasPotentialDeclarativeColumns() && !this.hasResolvedDeclarativeColumns()) {
      return;
    }
    if (this.isGridColumnResizeInteractionActive()) {
      return;
    }
    if (!this.shouldScheduleRefresh()) {
      return;
    }
    this.scheduleRefresh();
  },
  beforeUnmount() {
    this.stopColumnSignaturePolling();
    if (this.suppressRefreshReleaseTimer) {
      clearTimeout(this.suppressRefreshReleaseTimer);
      this.suppressRefreshReleaseTimer = null;
    }
    this.timingGate?.destroy?.();
    this.runGridFrameCleanups();
    this.runGridDomCleanups();
    this.destroyGrid();
  },
  methods: {
    hasPotentialDeclarativeColumns() {
      return !!this.$slots.default
        && getAttrValue(this.$attrs, "columns") === undefined
        && !this.isPlainGridMode();
    },
    hasResolvedDeclarativeColumns() {
      return this.resolveParsedColumns().length > 0;
    },
    async waitForInitialDeclarativeColumns() {
      if (!this.hasPotentialDeclarativeColumns() || this.hasResolvedDeclarativeColumns()) {
        return true;
      }
      const scheduleFrame = () => new Promise((resolve) => {
        const scheduler = globalThis.requestAnimationFrame || ((callback) => setTimeout(callback, 16));
        scheduler(() => resolve());
      });
      for (let index = 0; index < 12; index += 1) {
        await nextTick();
        if (!this.isGridTimingActive() || this.hasResolvedDeclarativeColumns()) {
          return this.hasResolvedDeclarativeColumns();
        }
        await scheduleFrame();
        if (!this.isGridTimingActive() || this.hasResolvedDeclarativeColumns()) {
          return this.hasResolvedDeclarativeColumns();
        }
      }
      return this.hasResolvedDeclarativeColumns();
    },
    startColumnSignaturePolling(duration = 3000) {
      if (!this.hasPotentialDeclarativeColumns()) {
        return;
      }
      const ownerWindow = this.$refs.root?.ownerDocument?.defaultView || (typeof window !== "undefined" ? window : globalThis);
      this.columnSignaturePollUntil = Date.now() + duration;
      if (this.columnSignaturePollTimer) {
        return;
      }
      const poll = async () => {
        this.columnSignaturePollTimer = null;
        if (!this.isGridTimingActive() || Date.now() > this.columnSignaturePollUntil || this.isGridColumnResizeInteractionActive()) {
          return;
        }
        const parsedColumns = this.resolveParsedColumns();
        const nextColumnsStructuralSignature = this.serializeColumnsStructuralSignature(parsedColumns);
        if (this.widget && nextColumnsStructuralSignature && nextColumnsStructuralSignature !== this.lastColumnsStructuralSignature) {
          await this.rebuildGrid({ preserveScroll: true });
        } else if (this.widget && this.serializeSignature(parsedColumns) !== this.lastColumnsSignature) {
          this.syncColumnLayoutSignatures(parsedColumns);
        }
        if (Date.now() <= this.columnSignaturePollUntil) {
          this.columnSignaturePollTimer = ownerWindow.setTimeout(poll, 80);
        }
      };
      this.columnSignaturePollTimer = ownerWindow.setTimeout(poll, 80);
    },
    stopColumnSignaturePolling() {
      if (!this.columnSignaturePollTimer) {
        return;
      }
      const ownerWindow = this.$refs.root?.ownerDocument?.defaultView || (typeof window !== "undefined" ? window : globalThis);
      ownerWindow.clearTimeout?.(this.columnSignaturePollTimer);
      this.columnSignaturePollTimer = null;
    },
    captureGridTimingToken() {
      return this.timingGate?.capture?.() ?? 0;
    },
    isGridTimingActive(token = null) {
      if (!this.timingGate) {
        return true;
      }
      return token == null
        ? this.timingGate.isAlive()
        : this.timingGate.isCurrent(token);
    },
    runGridFrameCleanups() {
      while (this.gridFrameCleanupList.length) {
        try {
          this.gridFrameCleanupList.pop()?.();
        } catch (_error) {
          // noop
        }
      }
    },
    runGridDomCleanups() {
      while (this.gridCleanupList.length) {
        try {
          this.gridCleanupList.pop()?.();
        } catch (_error) {
          // noop
        }
      }
    },
    scheduleGridFrame(callback, token = this.captureGridTimingToken()) {
      if (typeof callback !== "function") {
        return null;
      }
      const ownerWindow = this.gridRootEl?.()?.ownerDocument?.defaultView
        || this.$refs.root?.ownerDocument?.defaultView
        || (typeof window !== "undefined" ? window : globalThis);
      let active = true;
      const run = () => {
        if (!active) {
          return;
        }
        active = false;
        if (!this.isGridTimingActive(token)) {
          return;
        }
        callback();
      };
      const frameId = typeof ownerWindow.requestAnimationFrame === "function"
        ? ownerWindow.requestAnimationFrame(run)
        : ownerWindow.setTimeout(run, 16);
      this.gridFrameCleanupList.push(() => {
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
    },
    attachGridDomLifecycle(token = this.captureGridTimingToken()) {
      if (!this.isGridTimingActive(token)) {
        return;
      }
      const gridRoot = this.gridRootEl?.() || findKendoGridRoot(this.$refs.root) || this.$refs.root || null;
      if (!gridRoot) {
        return;
      }
      this.runGridDomCleanups();
      const cleanupCount = this.gridCleanupList.length;
      attachKendoGridColumnResizeGuard(this.widget || gridRoot, {
        cleanupList: this.gridCleanupList,
        onResizeEnd: () => {
          if (!this.isGridTimingActive(token)) {
            return;
          }
          repairKendoGridLockedColumnLayout(this.widget || gridRoot);
          this.scheduleGridFrame(() => {
            repairKendoGridLockedColumnLayout(this.widget || gridRoot);
          }, token);
        }
      });
      attachKendoGridLockedContentScrollSync(this.widget || gridRoot, {
        cleanupList: this.gridCleanupList,
        touch: true,
        virtual: this.isVirtualScrollableGrid()
      });
      if (this.gridCleanupList.length === cleanupCount) {
        attachKendoGridLockedLayoutRepair(this.widget || gridRoot, { cleanupList: this.gridCleanupList });
      }
    },
    resolveParsedColumns() {
      const slotColumns = collectColumnsFromVNodes(this.$slots.default ? this.$slots.default() : []);
      if (slotColumns.length > 0) {
        return slotColumns.map((column) => this.normalizeColumn(column));
      }
      const propColumns = getAttrValue(this.$attrs, "columns");
      if (Array.isArray(propColumns)) {
        return propColumns.map((column) => this.normalizeColumn(column));
      }
      return [];
    },
    serializeColumnsStructuralSignature(columns = this.resolveParsedColumns()) {
      const stripLayoutFields = (column) => {
        if (!column || typeof column !== "object") {
          return column;
        }
        const next = { ...column };
        delete next.width;
        delete next.minResizableWidth;
        if (Array.isArray(next.columns)) {
          next.columns = next.columns.map(stripLayoutFields);
        }
        return next;
      };
      return this.serializeSignature((columns || []).map(stripLayoutFields));
    },
    isGridColumnResizeInteractionActive() {
      return isKendoGridColumnResizeActive(this.widget || this.gridRootEl?.() || this.$refs.root || null);
    },
    syncColumnLayoutSignatures(columns = this.resolveParsedColumns()) {
      this.lastColumnsSignature = this.serializeSignature(columns);
      this.lastColumnsStructuralSignature = this.serializeColumnsStructuralSignature(columns);
    },
    mergeColumnResizeIntoParsedColumns(event, columns = this.resolveParsedColumns()) {
      const column = event?.column;
      const newWidth = event?.newWidth;
      if (!column?.field || newWidth == null) {
        return columns;
      }
      const applyWidth = (entry) => {
        if (!entry || typeof entry !== "object") {
          return entry;
        }
        if (Array.isArray(entry.columns)) {
          return {
            ...entry,
            columns: entry.columns.map(applyWidth)
          };
        }
        if (entry.field !== column.field) {
          return entry;
        }
        return { ...entry, width: newWidth };
      };
      return (columns || []).map(applyWidth);
    },
    scheduleGridGate(name, callback, options = {}) {
      if (!this.timingGate || typeof callback !== "function") {
        return Promise.resolve(false);
      }
      return this.timingGate.schedule(name, () => {
        if (!this.isGridTimingActive(options.token)) {
          return false;
        }
        return callback.call(this);
      }, {
        token: options.token ?? this.captureGridTimingToken(),
        retries: options.retries ?? 4,
        delay: options.delay ?? 0,
        scheduler: (job) => nextTick(job)
      });
    },
    isGridReady() {
      if (!this.isGridTimingActive()) {
        return false;
      }
      return !!(this.widget && (findKendoGridRoot(this.$refs.root) || this.$refs.root?.firstElementChild || this.$refs.root));
    },
    isPlainGridMode() {
      return normalizeBooleanLike(getAttrValue(this.$attrs, "plain-grid", "plainGrid")) === true;
    },
    isVirtualScrollableGrid() {
      return normalizeBooleanLike(getAttrValue(this.$attrs, "scrollable-virtual", "scrollableVirtual")) === true
        || this.widget?.options?.scrollable?.virtual === true
        || !!this.widget?.virtualScrollable;
    },
    requestGridResize() {
      if (!this.isGridReady() || !this.widget?.resize) {
        return null;
      }
      this.syncWidgetCompatRefs();
      try {
        return this.resizeGrid();
      } catch (_error) {
        return null;
      }
    },

    applyLegacyMasterGridHeightLayout() {
      const gridRoot = this.gridRootEl?.() || findKendoGridRoot(this.$refs.root) || null;
      if (!gridRoot || !gridRoot.closest?.('.master-maintenance-page')) {
        return false;
      }

      const requestedHeight = getAttrValue(this.$attrs, "height");
      if (!isPercentGridHeight(requestedHeight)) {
        return false;
      }

      const toolbarHost = gridRoot.closest?.('.kendo-grid-toolbar-style') || null;
      if (!toolbarHost) {
        return false;
      }

      const toolbarHeight = measureGridDomHeight(toolbarHost);
      const precedingHeight = measurePrecedingToolbarChildrenHeight(toolbarHost, gridRoot);
      const gridHeight = toolbarHeight - precedingHeight;
      if (!Number.isFinite(gridHeight) || gridHeight <= 40) {
        return false;
      }

      const normalizedGridHeight = Math.max(Math.floor(gridHeight), 40);
      const nextHeight = `${normalizedGridHeight}px`;
      if (gridRoot.style.height !== nextHeight) {
        gridRoot.style.height = nextHeight;
      }
      gridRoot.style.maxHeight = '';
      gridRoot.style.overflow = 'hidden';

      const headerTargets = [
        findKendoGridHeader(gridRoot),
        findKendoGridHeaderScrollHost(gridRoot),
        findKendoGridHeaderWrap(gridRoot),
        findKendoGridLockedHeader(gridRoot)
      ].filter(Boolean);
      headerTargets.forEach((element) => {
        element.style.removeProperty('height');
        element.style.removeProperty('max-height');
        element.style.overflowY = 'hidden';
      });

      const contentTargets = [
        findKendoGridContent(gridRoot),
        findKendoGridScrollHost(gridRoot),
        findKendoGridAutoScrollable(gridRoot),
        findKendoGridLockedContent(gridRoot),
        this.widget?.content?.[0] || null,
        this.widget?.lockedContent?.[0] || null
      ].filter(Boolean);
      contentTargets.forEach((element) => {
        element.style.removeProperty('max-height');
        element.style.overflowY = 'auto';
      });

      if (this.applyingMasterGridHeightLayout || !this.widget || !isFunction(this.widget.resize)) {
        return true;
      }
      this.applyingMasterGridHeightLayout = true;
      try {
        this.widget.resize();
      } catch (_error) {
        // Kendo 2019 wrapper did not throw on layout timing gaps; keep that
        // tolerance in the Vue3 facade.
      } finally {
        this.applyingMasterGridHeightLayout = false;
      }
      return true;
    },
    deferRefreshUntilGridIdle(token = this.captureGridTimingToken()) {
      this.afterDataBound(token);
      this.scheduleGridGate('grid-refresh-after-edit-idle', () => {
        if (!this.isGridTimingActive(token) || this.isGridEditInteractionActive()) {
          return false;
        }
        this.scheduleRefresh();
        return true;
      }, {
        token,
        retries: 20,
        delay: 50,
        scheduler: (job) => ((globalThis.requestAnimationFrame || ((cb) => setTimeout(cb, 16)))(() => nextTick(job)))
      });
    },
    releaseRefreshSuppression(delay = 0) {
      if (this.suppressRefreshReleaseTimer) {
        clearTimeout(this.suppressRefreshReleaseTimer);
        this.suppressRefreshReleaseTimer = null;
      }
      const release = () => {
        this.suppressRefresh = false;
        this.suppressRefreshReleaseTimer = null;
      };
      if (delay > 0) {
        this.suppressRefreshReleaseTimer = setTimeout(release, delay);
      } else {
        release();
      }
    },
    directHandler(name) {
      const handler = getAttrValue(this.$attrs, name, name.replace(/[A-Z]/g, (char) => `-${char.toLowerCase()}`));
      return isFunction(handler) ? handler : null;
    },
    emitKendoEvent(name, event) {
      let compatEvent = event;
      if (this.widget) {
        this.syncWidgetCompatRefs();
        updateLegacySenderState(this.widget, {
          dataItems: this.gridDataSourceItems(),
          currentDataItems: this.gridDataSourceItems()
        });
        compatEvent = createLegacyKendoEvent(event, this.widget, {
          type: event?.type || name,
          dataSource: this.gridDataSource(),
          dataItems: this.gridDataSourceItems(),
          selectedRow: this.gridSelectedRow(),
          selectedRowIndex: this.gridRowIndex(this.gridSelectedRow()),
          selectedCell: this.gridSelectedCell(),
          selectedCellIndex: this.gridSelectedCellIndex(),
          selectedDataItem: this.gridSelectedDataItem()
        });
      }
      const emitName = EMIT_EVENT_MAP[name];
      if (emitName) {
        this.$emit(emitName, compatEvent);
      }
      const direct = this.directHandler(name);
      if (direct) {
        direct(compatEvent);
      }
    },
    markLegacyDirtyFieldsFromEvent(event) {
      const values = isPlainObject(event?.values) ? event.values : {};
      const fields = Object.keys(values);
      if (!event?.model || fields.length === 0) {
        return false;
      }
      const dirtyFields = isPlainObject(event.model.dirtyFields) ? event.model.dirtyFields : {};
      let marked = false;
      fields.forEach((field) => {
        if (event.model[field] != values[field]) {
          dirtyFields[field] = true;
          marked = true;
        }
      });
      if (!marked) {
        return false;
      }
      event.model.dirtyFields = dirtyFields;
      event.model.dirty = true;
      return true;
    },
    legacyDirtyDataItemKey(dataItem) {
      if (!dataItem) {
        return "";
      }
      const key = dataItem.uid ?? dataItem._uid ?? dataItem.id ?? dataItem.code;
      return key == null ? "" : String(key);
    },
    legacyDirtyEventCell(event) {
      const container = event?.container?.[0] || event?.container || null;
      if (!container) {
        return null;
      }
      return container.matches?.("td,th") ? container : (container.closest?.("td,th") || null);
    },
    legacyDirtyCellSection(cell) {
      return cell?.closest?.(".k-grid-content-locked") ? "locked" : "body";
    },
    rememberLegacyDirtyCellFromEvent(event) {
      const fields = Object.keys(isPlainObject(event?.values) ? event.values : {});
      const key = this.legacyDirtyDataItemKey(event?.model);
      const cell = this.legacyDirtyEventCell(event);
      if (!key || fields.length === 0 || !cell || typeof cell.cellIndex !== "number") {
        return;
      }
      const section = this.legacyDirtyCellSection(cell);
      fields.forEach((field) => {
        this.legacyDirtyCellHints[`${key}:${field}`] = {
          section,
          cellIndex: cell.cellIndex
        };
      });
    },
    makeTemplatePlaceholder(prefix = "cell") {
      this.renderRevision += 1;
      return `kendo-template-${prefix}-${this.$.uid}-${this.renderRevision}`;
    },
    normalizeTemplateFactory(template, prefix = "cell") {
      if (template == null) {
        return template;
      }
      if (isVueTemplateDescriptor(template)) {
        return (dataItem) => {
          const placeholderId = this.makeTemplatePlaceholder(prefix);
          this.templateMounts.push({
            id: placeholderId,
            component: unwrapComponent(template.template),
            props: {
              templateArgs: template.templateArgs ?? dataItem ?? {}
            }
          });
          return `<span data-kendo-vue-template="${placeholderId}"></span>`;
        };
      }
      if (!isFunction(template)) {
        return template;
      }
      return (dataItem) => {
        const result = template(dataItem);
        if (isVueTemplateDescriptor(result)) {
          const placeholderId = this.makeTemplatePlaceholder(prefix);
          this.templateMounts.push({
            id: placeholderId,
            component: unwrapComponent(result.template),
            props: {
              templateArgs: result.templateArgs ?? dataItem ?? {}
            }
          });
          return `<span data-kendo-vue-template="${placeholderId}"></span>`;
        }
        return result == null ? "" : result;
      };
    },
    normalizeSlotToolbarTemplate(slotContent) {
      if (!slotContent) {
        return null;
      }
      return () => {
        const placeholderId = this.makeTemplatePlaceholder("toolbar");
        const toolbarChildrenFactory = isFunction(slotContent)
          ? slotContent
          : () => (Array.isArray(slotContent) ? slotContent : [slotContent]);
        this.templateMounts.push({
          id: placeholderId,
          component: markRaw({
            name: "KendoGridToolbarSlotCompat",
            render() {
              return h("div", { class: "k-grid-toolbar-slot" }, toolbarChildrenFactory());
            }
          }),
          props: {}
        });
        return `<span data-kendo-vue-template="${placeholderId}"></span>`;
      };
    },
    normalizeColumn(column) {
      const raw = cloneColumn(column || {});
      const normalized = {};
      Object.entries(raw).forEach(([key, value]) => {
        if (key === "key") {
          return;
        }
        const compatKey = COLUMN_HANDLER_KEY_MAP[key] || key;
        const normalizedKey = camelize(compatKey);
        normalized[normalizedKey] = value;
      });
      if (Array.isArray(normalized.columns)) {
        normalized.columns = normalized.columns.map((item) => this.normalizeColumn(item));
      }
      if (normalized.template !== undefined) {
        normalized.template = this.normalizeTemplateFactory(normalized.template, "cell");
      }
      if (normalized.headerTemplate !== undefined) {
        normalized.headerTemplate = this.normalizeTemplateFactory(normalized.headerTemplate, "header");
      }
      if (normalized.footerTemplate !== undefined) {
        normalized.footerTemplate = this.normalizeTemplateFactory(normalized.footerTemplate, "footer");
      }
      return normalized;
    },
    buildNestedOption(prefix, baseValue) {
      const attrs = this.$attrs || {};
      const hasNestedOptionAttrs = Object.keys(attrs).some((key) => key.startsWith(`${prefix}-`));
      const option = isPlainObject(baseValue)
        ? { ...baseValue }
        : (baseValue === undefined || hasNestedOptionAttrs ? {} : baseValue);
      Object.entries(attrs).forEach(([key, value]) => {
        if (!key.startsWith(`${prefix}-`)) {
          return;
        }
        const rawNestedKey = key.slice(prefix.length + 1);
        if (!isPlainObject(option)) {
          return;
        }
        if (rawNestedKey.startsWith("messages-")) {
          const messageKey = camelize(rawNestedKey.slice("messages-".length));
          setNestedOption(option, ["messages", messageKey], normalizeBooleanLike(value));
          return;
        }
        const nestedKey = camelize(rawNestedKey);
        option[nestedKey] = normalizeBooleanLike(value);
      });
      return option;
    },
    buildGridOptions() {
      const attrs = this.$attrs || {};
      const rawAttrDataSource = getAttrValue(attrs, "data-source", "dataSource");
      const attrDataSource = resolveDataSource(rawAttrDataSource);
      const dataSource = rawAttrDataSource !== undefined ? attrDataSource : this.dataSourceInstance;
      const baseSortable = normalizeBooleanLike(getAttrValue(attrs, "sortable"));
      const baseScrollable = normalizeBooleanLike(getAttrValue(attrs, "scrollable"));
      const basePageable = normalizeBooleanLike(getAttrValue(attrs, "pageable"));
      const baseGroupable = normalizeBooleanLike(getAttrValue(attrs, "groupable"));
      const hasGroupableNestedAttrs = Object.keys(attrs).some((key) => key.startsWith("groupable-"));

      const detailTemplateValue = getAttrValue(attrs, "detailTemplate", "detail-template");
      const attachDetailInit = detailTemplateValue !== undefined && detailTemplateValue !== null;
      const plainGridMode = this.isPlainGridMode();

      const slotNodes = this.$slots.default ? this.$slots.default() : [];
      const slotToolbar = collectToolbarFromVNodes(slotNodes);
      const requestedHeight = getAttrValue(attrs, "height");

      const options = {
        dataSource,
        columns: this.resolveParsedColumns(),
        editable: normalizeBooleanLike(getAttrValue(attrs, "editable")),
        selectable: getAttrValue(attrs, "selectable"),
        resizable: normalizeBooleanLike(getAttrValue(attrs, "resizable")),
        reorderable: normalizeBooleanLike(getAttrValue(attrs, "reorderable")),
        filterable: normalizeBooleanLike(getAttrValue(attrs, "filterable")),
        navigatable: normalizeBooleanLike(getAttrValue(attrs, "navigatable")),
        noRecords: normalizeBooleanLike(getAttrValue(attrs, "no-records", "noRecords")),
        persistSelection: normalizeBooleanLike(getAttrValue(attrs, "persist-selection", "persistSelection"))
      };

      if (requestedHeight !== undefined && !isLegacyHeaderOnlyGridHeight(requestedHeight)) {
        options.height = requestedHeight;
      }

      if (baseSortable !== undefined) {
        options.sortable = this.buildNestedOption("sortable", baseSortable);
      }
      if (baseScrollable !== undefined || getAttrValue(attrs, "scrollable-virtual", "scrollable-endless") !== undefined) {
        const scrollable = this.buildNestedOption("scrollable", baseScrollable === undefined ? {} : baseScrollable);
        const virtual = getAttrValue(attrs, "scrollable-virtual");
        const endless = getAttrValue(attrs, "scrollable-endless");
        if (virtual !== undefined) {
          scrollable.virtual = normalizeBooleanLike(virtual);
        }
        if (endless !== undefined) {
          scrollable.endless = normalizeBooleanLike(endless);
        }
        options.scrollable = scrollable;
      }
      if (basePageable !== undefined) {
        options.pageable = this.buildNestedOption("pageable", basePageable);
      }
      if (baseGroupable !== undefined || hasGroupableNestedAttrs) {
        options.groupable = this.buildNestedOption("groupable", baseGroupable === undefined ? {} : baseGroupable);
      }

      [
        "detailTemplate",
        "toolbar",
        "rowTemplate",
        "altRowTemplate",
        "columnMenu",
        "mobile",
        "messages"
      ].forEach((key) => {
        const value = getAttrValue(attrs, key, key.replace(/[A-Z]/g, (char) => `-${char.toLowerCase()}`));
        if (value === undefined) {
          return;
        }
        if (["detailTemplate", "toolbar", "rowTemplate", "altRowTemplate"].includes(key)) {
          options[key] = this.normalizeTemplateFactory(value, key);
          return;
        }
        options[key] = value;
      });

      if (options.toolbar === undefined && slotToolbar) {
        options.toolbar = this.normalizeSlotToolbarTemplate(slotToolbar);
      }

      Object.entries(attrs).forEach(([key, value]) => {
        if (ROOT_ATTR_KEYS.has(key) || DIRECT_EVENT_KEYS.includes(key) || key.startsWith("on")) {
          return;
        }
        if ([
          "data-source", "dataSource", "columns", "editable", "selectable", "resizable", "reorderable",
          "filterable", "navigatable", "no-records", "noRecords", "persist-selection", "persistSelection",
          "height", "sortable", "scrollable", "pageable", "groupable", "scrollable-virtual", "scrollable-endless"
        ].includes(key)) {
          return;
        }
        if (["sortable-", "scrollable-", "pageable-", "groupable-"].some((prefix) => key.startsWith(prefix))) {
          return;
        }
        const normalizedKey = camelize(key);
        if (options[normalizedKey] === undefined) {
          options[normalizedKey] = normalizeBooleanLike(value);
        }
      });

      ["save", "edit", "beforeEdit", "cellClose", "dataBound", "dataBinding", "change", "cancel", "remove", "sort", "columnResize", "columnReorder", "detailInit"].forEach((eventName) => {
        if (eventName === "detailInit" && (plainGridMode || !attachDetailInit)) {
          return;
        }
        options[eventName] = (event) => {
          if (eventName === "beforeEdit") {
            this.restoreLegacyColumnValuesFromParsedColumns();
          }
          if (eventName === "dataBinding") {
            this.destroyTemplateMounts();
            this.templateMounts = [];
          }
          if (eventName === "save") {
            this.markLegacyDirtyFieldsFromEvent(event);
            this.rememberLegacyDirtyCellFromEvent(event);
          }
          if (eventName === "columnResize") {
            this.syncColumnLayoutSignatures(this.mergeColumnResizeIntoParsedColumns(event));
            this.emitKendoEvent(eventName, event);
            return;
          }
          this.emitKendoEvent(eventName, event);
          if (eventName === "change") {
            const token = this.captureGridTimingToken();
            this.syncLegacyGridSelectionState(this.gridRootEl?.() || this.$refs.root || null);
            this.scheduleGridFrame(() => {
              this.syncLegacyGridSelectionState(this.gridRootEl?.() || this.$refs.root || null);
            }, token);
          }
          if (eventName === "save" || eventName === "cellClose") {
            this.scheduleLegacyDirtyCellMarkersSync();
          }
          if (eventName === "dataBound") {
            this.afterDataBound();
          }
          if (["edit", "save", "cellClose", "cancel"].includes(eventName)) {
            this.restoreLegacyColumnValuesFromParsedColumns();
          }
        };
      });

      return options;
    },
    serializeSignature(value) {
      return JSON.stringify(value, (_key, currentValue) => {
        if (isFunction(currentValue)) {
          return `[Function:${currentValue.name || "anonymous"}]`;
        }
        if (currentValue instanceof Date) {
          return currentValue.toISOString();
        }
        return currentValue;
      });
    },
    getRawDataSourceInput(fallback = undefined) {
      const attrs = this.$attrs || {};
      const hasAttrDataSource = Object.prototype.hasOwnProperty.call(attrs, 'data-source')
        || Object.prototype.hasOwnProperty.call(attrs, 'dataSource');
      if (hasAttrDataSource) {
        return resolveDataSource(getAttrValue(attrs, 'data-source', 'dataSource'));
      }
      if (fallback !== undefined) {
        return resolveDataSource(fallback);
      }
      return resolveDataSource(this.dataSourceInstance);
    },
    serializeDataSourceInput(source = undefined) {
      return this.serializeSignature(describeDataSourceInput(this.getRawDataSourceInput(source)));
    },
    currentGridRefreshSignature() {
      const options = this.buildGridOptions();
      return {
        columns: this.serializeSignature(this.resolveParsedColumns()),
        options: this.serializeSignature({
          editable: options.editable,
          selectable: options.selectable,
          resizable: options.resizable,
          reorderable: options.reorderable,
          filterable: options.filterable,
          navigatable: options.navigatable,
          height: options.height,
          sortable: options.sortable,
          scrollable: options.scrollable,
          pageable: options.pageable,
          groupable: options.groupable
        }),
        dataSource: this.serializeDataSourceInput(options.dataSource)
      };
    },
    shouldScheduleRefresh() {
      if (this.isGridColumnResizeInteractionActive()) {
        return false;
      }
      if (this.suppressRefresh) {
        const signature = this.currentGridRefreshSignature();
        return !!(
          this.widget
          && (
            signature.columns !== this.lastColumnsSignature
            || signature.options !== this.lastOptionsSignature
          )
        );
      }
      if (!this.widget) {
        return true;
      }
      const signature = this.currentGridRefreshSignature();
      return !(
        signature.columns === this.lastColumnsSignature
        && signature.options === this.lastOptionsSignature
        && signature.dataSource === this.lastDataSourceSignature
      );
    },
    isGridEditInteractionActive() {
      const gridRoot = this.gridRootEl?.() || findKendoGridRoot(this.$refs.root) || this.$refs.root || null;
      if (!gridRoot || typeof gridRoot.querySelector !== 'function') {
        return false;
      }
      const editContainer = gridRoot.querySelector('.k-edit-cell, .k-grid-edit-row, .k-grid-edit-cell, td.k-edit-cell, tr.k-grid-edit-row');
      if (editContainer) {
        return true;
      }
      const activeElement = gridRoot.ownerDocument?.activeElement || null;
      const widgetEditElement = this.widget?.editable?.element?.[0] || this.widget?.editable?.element || null;
      return !!(
        activeElement
        && gridRoot.contains(activeElement)
        && activeElement.closest?.('.k-numerictextbox, .k-input, input, textarea, select')
        && widgetEditElement?.contains?.(activeElement)
      );
    },
    isStructuralRebuildPending() {
      return this.pendingStructuralRebuild === true;
    },
    async rebuildGrid(options = {}) {
      const preserveScroll = options?.preserveScroll !== false;
      const token = options?.token ?? this.captureGridTimingToken();
      if (!this.isGridTimingActive(token) || this.pendingStructuralRebuild) {
        return false;
      }
      this.pendingStructuralRebuild = true;
      const preservedScroll = preserveScroll ? this.gridScrollPosition() : null;
      try {
        await nextTick();
        if (!this.isGridTimingActive(token)) {
          return false;
        }
        await this.buildGrid();
        if (!this.isGridTimingActive(token)) {
          return false;
        }
        if (preservedScroll) {
          this.scrollGridTo(preservedScroll);
        }
        this.afterDataBound(token);
        return true;
      } finally {
        this.pendingStructuralRebuild = false;
      }
    },
    async buildGrid() {
      const token = this.captureGridTimingToken();
      await ensureJQueryKendo();
      if (!this.isGridTimingActive(token)) {
        return null;
      }
      const kendo = getJQueryKendo();
      if (!kendo?.ui?.Grid) {
        throw new Error("Kendo jQuery Grid is not available.");
      }
      const root = this.$refs.root;
      if (!root || !this.isGridTimingActive(token)) {
        return null;
      }
      this.destroyGrid();
      this.templateMounts = [];
      const options = this.buildGridOptions();
      const rawDataSourceInput = options.dataSource;
      options.dataSource = createGridDataSource(rawDataSourceInput) || rawDataSourceInput;
      const $root = $(root);
      $root.empty();
      this.dataSourceInstance = options.dataSource ? markRaw(options.dataSource) : null;
      $root.kendoGrid(options);
      this.widget = $root.data("kendoGrid") || null;
      this.syncWidgetCompatRefs();
      this.dataSourceInstance = this.widget?.dataSource ? markRaw(this.widget.dataSource) : this.dataSourceInstance;
      this.lastDataSourceSignature = this.serializeDataSourceInput(rawDataSourceInput);
      this.syncColumnLayoutSignatures(this.resolveParsedColumns());
      this.lastOptionsSignature = this.serializeSignature({
        editable: options.editable,
        selectable: options.selectable,
        resizable: options.resizable,
        reorderable: options.reorderable,
        filterable: options.filterable,
        navigatable: options.navigatable,
        height: options.height,
        sortable: options.sortable,
        scrollable: options.scrollable,
        pageable: options.pageable,
        groupable: options.groupable
      });
      this.afterDataBound(token);
      this.startColumnSignaturePolling();
      return this.widget;
    },
    destroyTemplateMounts() {
      this.templateMounts.forEach((entry) => {
        try {
          entry.app?.unmount?.();
        } catch (_error) {
          // noop
        }
        delete entry.app;
      });
    },
    mountVueTemplates(token = this.captureGridTimingToken()) {
      const root = this.$refs.root;
      if (!root || !this.isGridTimingActive(token)) {
        return null;
      }
      this.templateMounts.forEach((entry) => {
        if (entry.app || !entry.component) {
          return;
        }
        const mountTarget = root.querySelector(`[data-kendo-vue-template="${entry.id}"]`);
        if (!mountTarget) {
          return;
        }
        const rawComponent = unwrapComponent(entry.component);
        const app = createApp({
          render() {
            return h(rawComponent, entry.props || {});
          }
        });
        app.mount(mountTarget);
        entry.app = app;
      });
    },
    syncWidgetCompatRefs() {
      if (!this.widget || !this.$refs.root) {
        return;
      }
      const root = this.$refs.root;
      const gridRoot = findKendoGridRoot(root) || this.widget.wrapper?.[0] || this.widget.element?.[0] || root;
      const gridHeader = findKendoGridHeader(gridRoot) || this.widget.header?.[0] || null;
      const gridHeaderWrap = findKendoGridHeaderWrap(gridRoot) || this.widget.headerWrap?.[0] || null;
      const gridHeaderScrollHost = findKendoGridHeaderScrollHost(gridRoot) || gridHeaderWrap || this.widget.headerWrap?.[0] || null;
      const gridLockedHeader = findKendoGridLockedHeader(gridRoot) || this.widget.lockedHeader?.[0] || null;
      const gridContent = findKendoGridContent(gridRoot) || this.widget.content?.[0] || null;
      const gridLockedContent = findKendoGridLockedContent(gridRoot) || this.widget.lockedContent?.[0] || null;
      const gridScrollHost = findKendoGridScrollHost(gridRoot)
        || findKendoGridAutoScrollable(gridRoot)
        || gridContent
        || this.widget.content?.[0]
        || null;
      const gridTable = findKendoGridTable(gridRoot) || this.widget.table?.[0] || null;
      const gridLockedTable = findKendoGridLockedTable(gridRoot) || this.widget.lockedTable?.[0] || null;
      const gridThead = findKendoGridThead(gridRoot) || this.widget.thead?.[0] || null;
      const gridTbody = findKendoGridTbody(gridRoot) || this.widget.tbody?.[0] || null;
      const gridLockedTbody = findKendoGridLockedTbody(gridRoot) || this.widget.lockedTbody?.[0] || null;
      const verticalScrollbar = findKendoGridVerticalScrollbar(gridRoot) || this.widget.lockedScrollbar?.[0] || null;
      const hasLockedColumns = Array.isArray(this.widget.columns)
        ? this.widget.columns.some((column) => column?.locked === true && column?.hidden !== true)
        : false;

      this.widget.element = $(gridRoot || root);
      this.widget.wrapper = $(gridRoot || root);
      this.widget.header = $(gridHeader || gridRoot || root);
      this.widget.headerWrap = $(gridHeaderWrap || gridHeaderScrollHost || this.widget.header?.[0] || []);
      this.widget.table = $(gridTable || this.widget.table?.[0] || []);
      this.widget.thead = $(gridThead || this.widget.thead?.[0] || []);
      this.widget.tbody = $(gridTbody || this.widget.tbody?.[0] || []);
      this.widget.content = $(gridContent || gridScrollHost || this.widget.content?.[0] || []);
      if (gridLockedHeader) {
        this.widget.lockedHeader = $(gridLockedHeader);
      } else if (!hasLockedColumns && Object.prototype.hasOwnProperty.call(this.widget, 'lockedHeader')) {
        delete this.widget.lockedHeader;
      }
      if (gridLockedTable) {
        this.widget.lockedTable = $(gridLockedTable);
      } else if (!hasLockedColumns && Object.prototype.hasOwnProperty.call(this.widget, 'lockedTable')) {
        delete this.widget.lockedTable;
      }
      if (gridLockedTbody) {
        this.widget.lockedTbody = $(gridLockedTbody);
      } else if (!hasLockedColumns && Object.prototype.hasOwnProperty.call(this.widget, 'lockedTbody')) {
        delete this.widget.lockedTbody;
      }
      if (gridLockedContent) {
        this.widget.lockedContent = $(gridLockedContent);
      } else if (!hasLockedColumns && Object.prototype.hasOwnProperty.call(this.widget, 'lockedContent')) {
        delete this.widget.lockedContent;
      }
      if (gridLockedContent && verticalScrollbar) {
        this.widget.lockedScrollbar = $(verticalScrollbar);
      } else if (!hasLockedColumns && Object.prototype.hasOwnProperty.call(this.widget, 'lockedScrollbar')) {
        delete this.widget.lockedScrollbar;
      }
      this.widget.scrollables = $([
        gridScrollHost || this.widget.content?.[0] || null,
        verticalScrollbar || this.widget.lockedScrollbar?.[0] || null
      ].filter(Boolean));
      this.widget.__ntssOwnerDocument = getKendoOwnerDocument(gridRoot || root);
      this.widget.__ntssHostElement = gridRoot || root;
      this.widget.__ntssCompatGrid = this;
      if (!isFunction(this.widget.items)) {
        this.widget.items = () => $(findKendoGridBodyRows(gridRoot || root));
      }
      if (!isFunction(this.widget.dataItems)) {
        this.widget.dataItems = () => this.gridDataSourceItems();
      }
      if (!isFunction(this.widget.view)) {
        this.widget.view = () => this.gridDataSourceItems();
      }
      if (!isFunction(this.widget.refreshGrid)) {
        this.widget.refreshGrid = () => this.refreshGrid();
      }
      if (!isFunction(this.widget.setGridDataSource)) {
        this.widget.setGridDataSource = (dataSource) => this.setGridDataSource(dataSource);
      }
      this.installLegacyGridRefreshHook();
      this.syncLegacyGridDomFacade(gridRoot || root);
    },
    scheduleLegacyDirtyCellMarkersSync(token = this.captureGridTimingToken()) {
      this.scheduleGridFrame(() => {
        this.syncLegacyDirtyCellMarkers();
      }, token);
    },
    scheduleLegacyGridPostRefreshSync(token = this.captureGridTimingToken()) {
      this.scheduleGridFrame(() => {
        this.syncWidgetCompatRefs();
        this.syncLegacyDirtyCellMarkers();
        this.syncLegacyGridDomFacade(this.gridRootEl?.() || this.$refs.root || null);
      }, token);
    },
    installLegacyGridRefreshHook() {
      if (!this.widget || !isFunction(this.widget.refresh) || this.widget.__ntssRefreshHookInstalled) {
        return;
      }
      const rawRefresh = this.widget.refresh.bind(this.widget);
      Object.defineProperty(this.widget, '__ntssRawRefresh', {
        value: rawRefresh,
        configurable: true
      });
      Object.defineProperty(this.widget, '__ntssRefreshHookInstalled', {
        value: true,
        configurable: true
      });
      this.widget.refresh = (...args) => {
        const token = this.captureGridTimingToken();
        const deferCompatSync = this.isGridEditInteractionActive();
        this.destroyTemplateMounts();
        this.templateMounts = [];
        this.restoreLegacyColumnValuesFromParsedColumns();
        const result = rawRefresh(...args);
        if (!this.isGridTimingActive(token)) {
          return result;
        }
        if (deferCompatSync) {
          this.scheduleLegacyGridPostRefreshSync(token);
          return result;
        }
        this.syncWidgetCompatRefs();
        this.syncLegacyDirtyCellMarkers();
        this.syncLegacyGridDomFacade(this.gridRootEl?.() || this.$refs.root || null);
        this.scheduleLegacyGridPostRefreshSync(token);
        return result;
      };
    },
    restoreLegacyColumnValuesFromParsedColumns() {
      if (!this.widget || !Array.isArray(this.widget.columns)) {
        return false;
      }
      const parsedColumns = this.resolveParsedColumns();
      const usedIndexes = new Set();
      let restored = false;
      this.widget.columns.forEach((widgetColumn) => {
        const parsedIndex = parsedColumns.findIndex((column, index) => (
          !usedIndexes.has(index)
          && column?.field === widgetColumn?.field
          && Object.prototype.hasOwnProperty.call(column, "values")
        ));
        if (parsedIndex < 0) {
          return;
        }
        usedIndexes.add(parsedIndex);
        const parsedValues = parsedColumns[parsedIndex].values;
        if (widgetColumn.values !== parsedValues) {
          widgetColumn.values = parsedValues;
          restored = true;
        }
      });
      return restored;
    },
    syncLegacyGridSelectionState(gridRoot = this.gridRootEl?.()) {
      if (!gridRoot || typeof gridRoot.querySelectorAll !== 'function') {
        return;
      }
      const selectedElements = new Set();
      try {
        const selected = this.widget?.select?.();
        selected?.each?.((_index, element) => {
          if (!element) {
            return;
          }
          selectedElements.add(element);
          const selectedRow = element.closest?.('tr');
          if (selectedRow) {
            selectedElements.add(selectedRow);
          }
        });
        const selectedElement = selected?.[0] || null;
        if (selectedElement) {
          selectedElements.add(selectedElement);
          const selectedRow = selectedElement.closest?.('tr');
          if (selectedRow) {
            selectedElements.add(selectedRow);
          }
        }
      } catch (_error) {
        // noop
      }
      const isCurrentSelection = (element) => !!(
        element?.classList?.contains?.('k-selected')
        || element?.getAttribute?.('aria-selected') === 'true'
        || selectedElements.has(element)
        || selectedElements.has(element?.closest?.('tr'))
      );
      gridRoot.querySelectorAll('tr.k-state-selected, td.k-state-selected, th.k-state-selected, .k-table-row.k-state-selected, .k-table-td.k-state-selected, .k-table-th.k-state-selected').forEach((element) => {
        if (!isCurrentSelection(element)) {
          element.classList.remove('k-state-selected');
        }
      });
      gridRoot.querySelectorAll('tr.k-selected, tr.k-table-row.k-selected, td.k-selected, th.k-selected, tr[aria-selected="true"], td[aria-selected="true"], th[aria-selected="true"]').forEach((element) => {
        element.classList.add('k-state-selected');
      });
    },
    syncLegacyGridDomFacade(gridRoot = this.gridRootEl?.()) {
      if (!gridRoot || typeof gridRoot.querySelectorAll !== 'function') {
        return;
      }
      // Keep shared legacy wrapper/class contracts here.  Concrete Kendo
      // generated table/header structure stays owned by Kendo and page CSS.
      gridRoot.classList?.add('k-widget', 'k-display-block', 'k-editable', 'ntss-kendo-grid-legacy');
      findKendoGridContent(gridRoot)?.classList?.add('k-grid-content');
      findKendoGridHeader(gridRoot)?.classList?.add('k-grid-header');
      findKendoGridHeaderWrap(gridRoot)?.classList?.add('k-grid-header-wrap');
      findKendoGridAutoScrollable(gridRoot)?.classList?.add('k-auto-scrollable');

      const toolbar = gridRoot.closest?.('.k-grid-toolbar, kendo-grid-toolbar');
      if (toolbar) {
        toolbar.classList?.add('k-grid-toolbar');
        toolbar.querySelectorAll?.('ons-switch.custom-switch').forEach((element) => {
          element.classList?.add('switch', 'switch--outline');
        });
      }

      const dataItems = this.gridDataSourceItems();
      const bodyRows = findKendoGridBodyRows(gridRoot);
      const lockedRows = findKendoGridLockedRows(gridRoot);
      [...bodyRows, ...lockedRows].forEach((row, index) => {
        row.classList.add('k-master-row');
        if (row.classList.contains('k-table-alt-row')) {
          row.classList.add('k-alt');
        }
        const effectiveIndex = bodyRows.includes(row) ? bodyRows.indexOf(row) : lockedRows.indexOf(row);
        const dataItem = dataItems[effectiveIndex] || dataItems[index] || null;
        if (dataItem) {
          row.__ntssKendoDataItem = dataItem;
          const uid = dataItem.uid || dataItem._uid;
          if (uid) {
            const uidText = String(uid);
            if (row.getAttribute('data-uid') !== uidText) {
              row.setAttribute('data-uid', uidText);
            }
          }
        }
      });
      gridRoot.querySelectorAll('tr.k-table-alt-row').forEach((row) => {
        row.classList.add('k-alt');
      });
      this.syncLegacyGridSelectionState(gridRoot);
      gridRoot.querySelectorAll('tr.k-focus, td.k-focus, th.k-focus').forEach((element) => {
        element.classList.add('k-state-focused');
      });
      gridRoot.querySelectorAll('th.k-table-th, th.k-header, .k-grid-header th, .k-grid-header .k-table-th').forEach((cell) => {
        cell.classList.add('k-header');
        cell.querySelectorAll?.('a, .k-link, button').forEach((link) => link.classList?.add?.('k-link'));
      });
      gridRoot.querySelectorAll('td.k-table-td, .k-grid-content td, .k-grid-content .k-table-td').forEach((cell) => {
        cell.classList.add('k-td');
      });
      gridRoot.querySelectorAll('.k-grid-norecords, .k-grid-norecords-template').forEach((element) => {
        element.classList.add('k-grid-norecords');
      });
      gridRoot.querySelectorAll('button, .k-button, [role="button"]').forEach((button) => {
        button.classList.add('k-button', 'k-button-icontext', 'ntss-kendo-grid-button-legacy');
        Array.from(button.querySelectorAll?.('.k-icon, .k-svg-icon, svg') || []).forEach((icon) => {
          icon.classList?.add?.('ntss-kendo-grid-icon-legacy');
        });
      });
    },
    legacyDirtyFieldNames(dataItem) {
      if (!isPlainObject(dataItem?.dirtyFields)) {
        return [];
      }
      return Object.keys(dataItem.dirtyFields).filter((field) => dataItem.dirtyFields[field]);
    },
    addLegacyDirtyCellMarker(cell) {
      if (!cell?.classList) {
        return;
      }
      cell.classList.add("k-dirty-cell");
      const hasMarker = Array.from(cell.children || []).some((child) => child.classList?.contains("k-dirty"));
      if (hasMarker) {
        return;
      }
      const marker = cell.ownerDocument?.createElement?.("span");
      if (!marker) {
        return;
      }
      marker.className = "k-dirty";
      cell.insertBefore(marker, cell.firstChild || null);
    },
    clearLegacyDirtyCellMarkers(gridRoot) {
      if (!gridRoot || typeof gridRoot.querySelectorAll !== "function") {
        return;
      }
      gridRoot.querySelectorAll(".k-dirty").forEach((marker) => {
        marker.remove?.();
      });
      gridRoot.querySelectorAll("td.k-dirty-cell, .k-table-td.k-dirty-cell").forEach((cell) => {
        cell.classList?.remove?.("k-dirty-cell");
      });
    },
    legacyDirtyColumnSource() {
      const parsedColumns = typeof this.resolveParsedColumns === "function" ? this.resolveParsedColumns() : [];
      if (Array.isArray(parsedColumns) && parsedColumns.length > 0) {
        return parsedColumns;
      }
      const widgetColumns = this.gridColumns();
      return Array.isArray(widgetColumns) ? widgetColumns : [];
    },
    legacyDirtyVisibleColumns() {
      return this.legacyDirtyColumnSource().filter((column) => column?.hidden !== true);
    },
    legacyDirtyHeaderCells(section) {
      const gridRoot = this.gridRootEl?.();
      if (!gridRoot || typeof gridRoot.querySelectorAll !== "function") {
        return [];
      }
      const headerRoot = section === "locked"
        ? findKendoGridLockedHeader(gridRoot)
        : (findKendoGridHeaderWrap(gridRoot) || findKendoGridHeader(gridRoot));
      if (!headerRoot || typeof headerRoot.querySelectorAll !== "function") {
        return [];
      }
      return Array.from(headerRoot.querySelectorAll("th, .k-table-th, [role='columnheader']"))
        .filter((cell) => cell?.style?.display !== "none" && cell?.getAttribute?.("aria-hidden") !== "true");
    },
    legacyDirtyHeaderFieldMap(section) {
      return this.legacyDirtyHeaderCells(section).map((cell) => {
        const field = cell?.getAttribute?.("data-field") || cell?.dataset?.field || "";
        return field ? String(field) : "";
      });
    },
    legacyDirtyColumnMatchesField(column, field) {
      if (!column || field == null || field === "") {
        return false;
      }
      return column?.field === field || String(column?.field) === String(field);
    },
    legacyDirtyLooksLikeLeadingCommandCells(cells, count) {
      if (!Array.isArray(cells) || count <= 0 || cells.length < count) {
        return false;
      }
      return cells.slice(0, count).every((cell) => {
        const text = String(cell?.textContent || "").trim();
        return !!(
          cell?.querySelector?.("button, .k-button, [role='button'], .btn3-kendo-normal")
          || text === "詳細"
          || cell?.classList?.contains?.("btn3-kendo-normal")
        );
      });
    },
    legacyDirtyCellIndexForField(columns, field, cells = []) {
      if (!Array.isArray(columns) || !field) {
        return -1;
      }
      const columnIndex = columns.findIndex((column) => this.legacyDirtyColumnMatchesField(column, field));
      if (columnIndex < 0) {
        return -1;
      }
      if (Array.isArray(cells) && cells.length > columns.length) {
        const extraCellCount = cells.length - columns.length;
        const hasCommandColumnBeforeField = columns
          .slice(0, columnIndex)
          .some((column) => column?.command || column?.field === "$modalType");
        if (!hasCommandColumnBeforeField && this.legacyDirtyLooksLikeLeadingCommandCells(cells, extraCellCount)) {
          return columnIndex + extraCellCount;
        }
      }
      return columnIndex;
    },
    legacyDirtyCellForField(row, columns, field, section, dataItem = null) {
      const cells = Array.from(row?.children || []);
      if (!cells.length || !field) {
        return null;
      }
      const fieldText = String(field);
      const key = this.legacyDirtyDataItemKey(dataItem);
      const hint = key ? this.legacyDirtyCellHints[`${key}:${fieldText}`] : null;
      if (hint?.section === section && Number.isInteger(hint.cellIndex) && cells[hint.cellIndex]) {
        return cells[hint.cellIndex];
      }
      const dataFieldCell = cells.find((cell) => String(cell?.getAttribute?.("data-field") || cell?.dataset?.field || "") === fieldText);
      if (dataFieldCell) {
        return dataFieldCell;
      }
      const headerFieldMap = this.legacyDirtyHeaderFieldMap(section);
      const headerIndex = headerFieldMap.findIndex((mappedField) => mappedField === fieldText);
      if (headerIndex >= 0 && cells[headerIndex]) {
        return cells[headerIndex];
      }
      const columnIndex = this.legacyDirtyCellIndexForField(columns, field, cells);
      return columnIndex >= 0 ? (cells[columnIndex] || null) : null;
    },
    syncLegacyDirtyCellMarkersForRows(rows, columns, section = "body") {
      rows.forEach((row) => {
        const dataItem = this.gridDataItem(row);
        const fields = this.legacyDirtyFieldNames(dataItem);
        if (fields.length === 0) {
          return;
        }
        fields.forEach((field) => {
          const cell = this.legacyDirtyCellForField(row, columns, field, section, dataItem);
          if (cell) {
            this.addLegacyDirtyCellMarker(cell);
          }
        });
      });
    },
    syncLegacyDirtyCellMarkers() {
      const gridRoot = this.gridRootEl();
      if (!gridRoot) {
        return;
      }
      this.clearLegacyDirtyCellMarkers(gridRoot);
      const visibleColumns = this.legacyDirtyVisibleColumns();
      const lockedRows = findKendoGridLockedRows(gridRoot)
        .filter((row) => row?.closest?.(".k-grid-content-locked"));
      const bodyRows = findKendoGridBodyRows(gridRoot)
        .filter((row) => !row?.closest?.(".k-grid-content-locked"));
      if (lockedRows.length > 0) {
        this.syncLegacyDirtyCellMarkersForRows(lockedRows, visibleColumns.filter((column) => column?.locked === true), "locked");
        this.syncLegacyDirtyCellMarkersForRows(bodyRows, visibleColumns.filter((column) => column?.locked !== true), "body");
        return;
      }
      this.syncLegacyDirtyCellMarkersForRows(bodyRows, visibleColumns, "body");
    },
    afterDataBound(token = this.captureGridTimingToken()) {
      if (this.isGridColumnResizeInteractionActive()) {
        return;
      }
      this.scheduleGridGate('grid-after-data-bound', () => {
        if (!this.isGridReady()) {
          return false;
        }
        this.syncWidgetCompatRefs();
        this.destroyTemplateMounts();
        this.mountVueTemplates(token);
        this.syncLegacyDirtyCellMarkers();
        this.applyLegacyMasterGridHeightLayout();
        repairKendoGridLockedColumnLayout(this.widget || this.gridRootEl());
        this.attachGridDomLifecycle(token);
        nextTick(() => {
          this.scheduleGridFrame(() => {
            repairKendoGridLockedColumnLayout(this.widget || this.gridRootEl());
          }, token);
        });
        return true;
      }, { token, retries: 6, delay: 0 });
    },
    destroyGrid() {
            if (this.destroyingGrid) {
        return;
      }
      this.destroyingGrid = true;
      this.runGridFrameCleanups();
      this.runGridDomCleanups();
      this.destroyTemplateMounts();
      try {
        destroyNativeWidgetsIn(this.$refs.root);
      } catch (_error) {
        // noop
      }
      const widget = this.widget || $(this.$refs.root || []).data("kendoGrid");
      try {
        if (widget?.destroy) {
          widget.destroy();
        }
      } catch (_error) {
        // noop
      }
      if (this.$refs.root) {
        $(this.$refs.root).empty();
      }
      this.widget = null;
      this.destroyingGrid = false;
    },
    scheduleRefresh() {
      const token = this.captureGridTimingToken();
      if (this.pendingRebuild || this.pendingStructuralRebuild || !this.isGridTimingActive(token)) {
        return;
      }
      this.pendingRebuild = true;
      nextTick(async () => {
        if (!this.isGridTimingActive(token)) {
          this.pendingRebuild = false;
          return;
        }
        this.pendingRebuild = false;
        const parsedColumns = this.resolveParsedColumns();
        const nextColumnsSignature = this.serializeSignature(parsedColumns);
        const nextColumnsStructuralSignature = this.serializeColumnsStructuralSignature(parsedColumns);
        const options = this.buildGridOptions();
        const rawDataSourceInput = options.dataSource;
        const nextDataSource = createGridDataSource(rawDataSourceInput);
        options.dataSource = nextDataSource || rawDataSourceInput;
        const nextOptionsSignature = this.serializeSignature({
          editable: options.editable,
          selectable: options.selectable,
          resizable: options.resizable,
          reorderable: options.reorderable,
          filterable: options.filterable,
          navigatable: options.navigatable,
          height: options.height,
          sortable: options.sortable,
          scrollable: options.scrollable,
          pageable: options.pageable,
          groupable: options.groupable
        });
        const nextDataSourceSignature = this.serializeDataSourceInput(rawDataSourceInput);
        const shouldRebuild = !this.widget
          || nextColumnsStructuralSignature !== this.lastColumnsStructuralSignature
          || nextOptionsSignature !== this.lastOptionsSignature;
        if (this.isGridEditInteractionActive()) {
          this.deferRefreshUntilGridIdle(token);
          return;
        }
        if (shouldRebuild) {
          await this.buildGrid();
          return;
        }
        if (
          this.widget
          && nextColumnsSignature !== this.lastColumnsSignature
          && nextOptionsSignature === this.lastOptionsSignature
          && nextDataSourceSignature === this.lastDataSourceSignature
        ) {
          this.syncColumnLayoutSignatures(parsedColumns);
          this.requestGridResize();
          this.afterDataBound(token);
          return;
        }
        if (
          this.widget
          && nextDataSource
          && nextDataSourceSignature !== this.lastDataSourceSignature
          && isFunction(this.widget.setDataSource)
        ) {
          if (!this.applyGridDataSource(nextDataSource, token, nextDataSourceSignature)) {
            this.afterDataBound(token);
            this.scheduleGridGate('grid-set-data-source', () => this.applyGridDataSource(nextDataSource, token, nextDataSourceSignature), {
              token,
              retries: 8,
              delay: 16,
              scheduler: (job) => ((globalThis.requestAnimationFrame || ((cb) => setTimeout(cb, 16)))(() => nextTick(job)))
            });
            return;
          }
          return;
        }
        if (this.widget && this.$attrs.height !== undefined && isFunction(this.widget.resize)) {
          this.widget.resize();
        }
        this.afterDataBound(token);
      });
    },
    kendoWidget() {
      return this.widget;
    },
    gridWidget() {
      return this.widget;
    },
    nativeGridDataSource() {
      return this.widget?.dataSource || this.dataSourceInstance || null;
    },
    gridDataSource() {
      const source = this.nativeGridDataSource();
      return createLegacyGridDataSourceFacade(source, () => this.gridDataSourceItemsFromSource(source));
    },
    setGridDataSource(dataSource) {
      const nextDataSourceSignature = this.serializeDataSourceInput(dataSource);
      if (!this.widget) {
        this.dataSourceInstance = createGridDataSource(dataSource) || null;
        if (this.dataSourceInstance) {
          this.dataSourceInstance = markRaw(this.dataSourceInstance);
        }
        this.lastDataSourceSignature = nextDataSourceSignature;
        return this.dataSourceInstance;
      }
      const nextDataSource = createGridDataSource(dataSource);
      if (this.isGridEditInteractionActive()) {
        this.dataSourceInstance = this.widget.dataSource ? markRaw(this.widget.dataSource) : (nextDataSource ? markRaw(nextDataSource) : null);
        return this.dataSourceInstance;
      }
      if (nextDataSource && nextDataSourceSignature !== this.lastDataSourceSignature && isFunction(this.widget.setDataSource)) {
        if (!this.applyGridDataSource(nextDataSource, this.captureGridTimingToken(), nextDataSourceSignature)) {
          this.afterDataBound();
        }
      } else if (nextDataSource !== undefined) {
        this.widget.dataSource = nextDataSource;
      }
      this.dataSourceInstance = this.widget.dataSource ? markRaw(this.widget.dataSource) : (nextDataSource ? markRaw(nextDataSource) : null);
      if (!nextDataSource || nextDataSourceSignature === this.lastDataSourceSignature || !isFunction(this.widget.setDataSource)) {
        this.widget.refresh?.();
        this.afterDataBound();
      }
      return this.dataSourceInstance;
    },
    gridDataSourceItemsFromSource(source) {
      try {
        const view = source?.view?.();
        if (view) {
          return Array.from(view);
        }
      } catch (_error) {
        // noop
      }
      try {
        const data = source?.data?.();
        if (data) {
          return Array.from(data);
        }
      } catch (_error) {
        // noop
      }
      return [];
    },
    gridDataSourceItems() {
      return this.gridDataSourceItemsFromSource(this.nativeGridDataSource());
    },
    gridDataSourceItemAt(index) {
      const safeIndex = Number(index);
      if (!Number.isInteger(safeIndex) || safeIndex < 0) {
        return null;
      }
      const source = this.nativeGridDataSource();
      try {
        const item = source?.at?.(safeIndex);
        if (item) {
          return item;
        }
      } catch (_error) {
        // noop
      }
      return this.gridDataSourceItems()[safeIndex] || null;
    },
    gridRowIndex(row) {
      const safeRow = row?.closest?.('tr') || row;
      if (!safeRow) {
        return -1;
      }
      const rows = findKendoGridBodyRows(this.gridRootEl());
      const bodyIndex = rows.indexOf(safeRow);
      if (bodyIndex >= 0) {
        return bodyIndex;
      }
      const lockedRows = findKendoGridLockedRows(this.gridRootEl());
      return lockedRows.indexOf(safeRow);
    },
    gridSelectedCell() {
      const selection = this.widget?.select?.();
      const element = selection?.[0] || selection || null;
      return element?.matches?.('td,th') ? element : element?.closest?.('td,th') || null;
    },
    gridSelectedCellIndex() {
      const cell = this.gridSelectedCell();
      if (!cell) {
        return -1;
      }
      try {
        const index = this.widget?.cellIndex?.(cell);
        if (Number.isFinite(index)) {
          return index;
        }
      } catch (_error) {
        // noop
      }
      return typeof cell.cellIndex === 'number' ? cell.cellIndex : -1;
    },
    gridColumns() {
      return Array.isArray(this.widget?.columns) ? this.widget.columns : [];
    },
    gridColumnAt(index) {
      return Number.isInteger(index) ? (this.gridColumns()[index] || null) : null;
    },
    gridColumnByField(field) {
      if (!field) {
        return null;
      }
      return this.gridColumns().find((column) => column?.field === field) || null;
    },
    gridFirstVisibleColumn() {
      return this.gridColumns().find((column) => column?.hidden !== true && column?.field !== 'dummy') || null;
    },
    resizeGridColumn(column, width) {
      if (!column || !this.widget?.resizeColumn) {
        return null;
      }
      try {
        return this.widget.resizeColumn(column, width);
      } catch (_error) {
        return null;
      }
    },
    resizeGridColumnByField(field, width) {
      const column = this.gridColumnByField(field);
      return column ? this.resizeGridColumn(column, width) : null;
    },
    resizeFirstVisibleGridColumn(width = null) {
      const column = this.gridFirstVisibleColumn();
      if (!column) {
        return null;
      }
      const nextWidth = width == null ? parseInt(column.width, 10) : width;
      return this.resizeGridColumn(column, nextWidth);
    },
    autoFitGridColumn(column) {
      if (!column || !this.widget?.autoFitColumn) {
        return null;
      }
      return this.widget.autoFitColumn(column);
    },
    autoFitGridColumnByField(field) {
      const column = this.gridColumnByField(field);
      return column ? this.autoFitGridColumn(column) : null;
    },
    clearGridSelection() {
      return this.widget?.clearSelection?.() || null;
    },
    gridSelectedRow() {
      const selection = this.widget?.select?.();
      if (!selection) {
        return null;
      }
      if (selection.closest) {
        const row = selection.closest('tr');
        return row?.[0] || row || null;
      }
      return selection?.[0] || selection || null;
    },
    gridDataItem(row) {
      const safeRow = row?.closest?.('tr') || row;
      if (!safeRow) {
        return null;
      }
      if (safeRow.__ntssKendoDataItem) {
        return safeRow.__ntssKendoDataItem;
      }
      if (this.widget?.dataItem) {
        try {
          const item = this.widget.dataItem(safeRow);
          if (item) {
            return item;
          }
        } catch (_error) {
          // noop
        }
      }
      const uid = safeRow.getAttribute?.('data-uid');
      if (uid && this.widget?.dataSource?.getByUid) {
        try {
          const item = this.widget.dataSource.getByUid(uid);
          if (item) {
            return item;
          }
        } catch (_error) {
          // noop
        }
      }
      return this.gridDataSourceItemAt(this.gridRowIndex(safeRow));
    },
    gridSelectedDataItem() {
      const selectedRow = this.gridSelectedRow();
      return selectedRow ? this.gridDataItem(selectedRow) : null;
    },
    gridRootEl() {
      return findKendoGridRoot(this.$refs.root);
    },
    gridContentEl() {
      return findKendoGridContent(this.$refs.root);
    },
    gridLockedContentEl() {
      return this.gridLockedContentEls()[0] || null;
    },
    gridLockedContentEls() {
      return Array.from(this.gridRootEl()?.querySelectorAll?.('.k-grid-content-locked') || []);
    },
    gridHeaderEl() {
      return findKendoGridHeader(this.$refs.root);
    },
    gridHeaderWrapEl() {
      return findKendoGridHeaderWrap(this.$refs.root);
    },
    gridHeaderScrollHostEl() {
      return findKendoGridHeaderScrollHost(this.$refs.root) || this.gridHeaderWrapEl() || null;
    },
    gridLockedHeaderEl() {
      return this.gridLockedHeaderEls()[0] || null;
    },
    gridLockedHeaderEls() {
      return Array.from(this.gridRootEl()?.querySelectorAll?.('.k-grid-header-locked') || []);
    },
    gridAutoScrollableEl() {
      return findKendoGridAutoScrollable(this.$refs.root);
    },
    gridScrollHostEl() {
      return findKendoGridScrollHost(this.$refs.root) || this.gridAutoScrollableEl() || this.gridContentEl() || null;
    },
    gridPagerEl() {
      return this.queryGrid(".k-grid-pager, .k-pager-wrap");
    },
    gridHeaderStickyEls() {
      return Array.from(this.gridRootEl()?.querySelectorAll?.('.k-grid-header-sticky') || []);
    },
    gridEditRowEls() {
      return Array.from(this.gridRootEl()?.querySelectorAll?.('.k-grid-edit-row') || []);
    },
    gridContentExpanderEls() {
      return Array.from(this.gridRootEl()?.querySelectorAll?.('.k-grid-content-expander') || []);
    },
    queryGrid(selector) {
      return this.gridRootEl()?.querySelector?.(selector) || null;
    },
    queryGridAll(selector) {
      return Array.from(this.gridRootEl()?.querySelectorAll?.(selector) || []);
    },
    gridTableEl() {
      return this.widget?.table?.[0] || findKendoGridTable(this.gridRootEl()) || null;
    },
    gridLockedTableEl() {
      return findKendoGridLockedTable(this.gridRootEl()) || null;
    },
    gridTheadEl() {
      return this.widget?.thead?.[0] || findKendoGridThead(this.gridRootEl()) || null;
    },
    gridTbodyEl() {
      return this.widget?.tbody?.[0] || findKendoGridTbody(this.gridRootEl()) || null;
    },
    gridLockedTbodyEl() {
      return findKendoGridLockedTbody(this.gridRootEl()) || null;
    },
    gridVerticalScrollbarEl() {
      return this.widget?.virtualScrollable?.verticalScrollbar?.[0]
        || findKendoGridVerticalScrollbar(this.gridRootEl())
        || null;
    },
    gridVirtualScrollable() {
      return this.widget?.virtualScrollable || null;
    },
    gridSelectableTables() {
      return findKendoGridSelectables(this.gridRootEl());
    },
    gridDataRows() {
      return this.queryGridAll(".k-grid-content tr, .k-grid-content-locked tr");
    },
    hasLockedGridColumns() {
      return this.gridColumns().some((column) => column?.locked === true && column?.hidden !== true);
    },
    canApplyGridDataSource() {
      return !!(this.widget && this.isGridReady());
    },
    applyGridDataSource(nextDataSource, token = this.captureGridTimingToken(), dataSourceSignature = null) {
      if (!this.widget || !nextDataSource || !isFunction(this.widget.setDataSource)) {
        return false;
      }
      if (!this.canApplyGridDataSource()) {
        return false;
      }
      const nextSignature = dataSourceSignature ?? this.serializeDataSourceInput(nextDataSource);
      if (nextSignature === this.lastDataSourceSignature) {
        return false;
      }
      this.suppressRefresh = true;
      this.syncWidgetCompatRefs();
      try {
        this.widget.setDataSource(nextDataSource);
        this.syncWidgetCompatRefs();
        this.dataSourceInstance = this.widget.dataSource ? markRaw(this.widget.dataSource) : (nextDataSource ? markRaw(nextDataSource) : nextDataSource);
        this.lastDataSourceSignature = nextSignature;
        if (this.widget && this.$attrs.height !== undefined && isFunction(this.widget.resize)) {
          this.widget.resize();
        }
      } finally {
        this.releaseRefreshSuppression(32);
      }
      this.afterDataBound(token);
      return true;
    },
    gridResizeTargets() {
      return [
        this.gridLockedContentEl(),
        this.gridContentEl(),
        this.gridHeaderScrollHostEl(),
        this.gridLockedHeaderEl()
      ].filter(Boolean);
    },
    resizeGrid(targets = null) {
      if (!this.widget?.resize) {
        return null;
      }
      const preservedScroll = this.gridScrollPosition();
      const resolvedTargets = Array.isArray(targets)
        ? targets.filter(Boolean)
        : (targets || this.gridResizeTargets());
      const result = resolvedTargets.length > 0 ? this.widget.resize(resolvedTargets) : this.widget.resize();
      this.applyLegacyMasterGridHeightLayout();
      const token = this.captureGridTimingToken();
      nextTick(() => {
        this.scheduleGridFrame(() => {
          this.scrollGridTo(preservedScroll);
          repairKendoGridLockedColumnLayout(this.widget || this.gridRootEl());
        }, token);
      });
      return result;
    },
    gridScrollPosition() {
      return captureKendoGridScrollPosition(this.widget || this.gridRootEl());
    },
    scrollGridTo(position = {}) {
      return restoreKendoGridScrollPosition(this.widget || this.gridRootEl(), position);
    },
    scrollGridToTop() {
      this.scrollGridTo({ top: 0 });
    },
    refreshGrid() {
      this.refresh();
    },
    refresh() {
      if (!this.isGridTimingActive()) {
        return;
      }
      this.destroyTemplateMounts();
      this.templateMounts = [];
      this.widget?.refresh?.();
      this.afterDataBound();
    }
  }
};
</script>
