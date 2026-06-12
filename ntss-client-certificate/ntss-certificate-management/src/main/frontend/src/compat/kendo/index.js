import { defineComponent, h, inject, nextTick, onBeforeUnmount, onMounted, onUpdated, provide, ref } from "vue";
import $ from "jquery";

if (typeof window !== "undefined") {
  window.$ = window.$ || $;
  window.jQuery = window.jQuery || $;
}

function getKendo() {
  return window.kendo || $.kendo;
}

function normalizeDataSource(dataSource) {
  if (Array.isArray(dataSource)) return dataSource;
  if (dataSource?.data && Array.isArray(dataSource.data)) return dataSource.data;
  return dataSource || [];
}

function getPageSize(pageable) {
  return typeof pageable === "object" && pageable?.pageSize ? pageable.pageSize : undefined;
}

function createGridDataSource(kendo, data, pageable) {
  const pageSize = getPageSize(pageable);
  if (kendo?.data?.DataSource) {
    return new kendo.data.DataSource(pageSize ? { data, pageSize } : { data });
  }
  return data;
}

function defaultColumnValue(column) {
  if (typeof column.template === "string" && column.template.includes("操作")) return "操作";
  return "";
}

function legacyKendoField(field) {
  return field && field.startsWith("$") ? `__legacy_${field.slice(1)}` : field;
}

function applyLegacyVirtualFields(data, columns) {
  if (!Array.isArray(data) || !Array.isArray(columns)) return data;
  const virtualColumns = columns.filter(column => column.field && column.field.startsWith("$"));
  if (!virtualColumns.length) return data;
  data.forEach(row => {
    if (!row || typeof row !== "object") return;
    virtualColumns.forEach(column => {
      if (!Object.prototype.hasOwnProperty.call(row, column.field)) {
        Object.defineProperty(row, column.field, {
          value: defaultColumnValue(column),
          writable: true,
          configurable: true
        });
      }
      row[legacyKendoField(column.field)] = row[column.field];
    });
  });
  return data;
}

function normalizeColumnsForKendo(columns) {
  return columns.map(column => {
    if (!column.field?.startsWith("$")) return column;
    const originalField = column.field;
    const kendoField = legacyKendoField(originalField);
    return {
      ...column,
      field: kendoField,
      editor: column.editor
        ? (container, options) => {
          const model = options?.model;
          if (model && !Object.prototype.hasOwnProperty.call(model, originalField)) {
            Object.defineProperty(model, originalField, {
              value: model[kendoField] ?? defaultColumnValue(column),
              writable: true,
              configurable: true
            });
          }
          return column.editor(container, { ...options, field: originalField });
        }
        : undefined
    };
  });
}

// add 20260605 データ更新時にページ・ソート状態を維持する（操作後に1ページ目へ一瞬戻る現象の対策） start
function getGridPageState(dataSource) {
  if (!dataSource) return { page: null, sort: null };
  const page = typeof dataSource.page === "function" ? dataSource.page() : dataSource._page;
  const sort = typeof dataSource.sort === "function" ? dataSource.sort() : dataSource._sort;
  return { page: page > 0 ? page : null, sort: sort || null };
}

function restoreGridPageState(dataSource, { page, sort }) {
  if (!dataSource) return;
  if (page != null && page > 0) {
    if (typeof dataSource.page === "function") dataSource.page(page);
    else dataSource._page = page;
  }
  if (sort) {
    if (typeof dataSource.sort === "function") dataSource.sort(sort);
    else dataSource._sort = sort;
  }
}
// add #20260605 データ更新時にページ・ソート状態を維持する（操作後に1ページ目へ一瞬戻る現象の対策） end

function ensureLegacyGridShape(grid, data, pageable) {
  if (!grid) return;
  const pageSize = getPageSize(pageable) || 10;
  if (!grid.dataSource) {
    grid.dataSource = {
      _sort: null,
      _page: 1,
      _pageSize: pageSize,
      _data: data,
      sort(v) { this._sort = v; },
      page(v) { this._page = v; },
      pageSize(v) { this._pageSize = v; },
      total() { return this._data?.length || 0; },
      data(v) {
        if (v !== undefined) this._data = v;
        return this._data || [];
      }
    };
  }
  if (!grid.pager) {
    grid.pager = {};
  }
  if (!grid.pager.dataSource) {
    grid.pager.dataSource = grid.dataSource;
  }
}

function ensureGridHost(node, data, pageable) {
  const jq = $(node);
  const current = jq.data("kendoGrid");
  if (current) {
    ensureLegacyGridShape(current, data, pageable);
    return current;
  }
  const fake = {
    select: () => node.querySelectorAll("tbody tr"),
    content: [node],
    dataSource: {
      _sort: null,
      _page: 1,
      _pageSize: getPageSize(pageable) || 10,
      _data: data,
      sort(v) { this._sort = v; },
      page(v) { this._page = v; },
      pageSize(v) { this._pageSize = v; },
      total() { return this._data?.length || 0; },
      data(v) {
        if (v !== undefined) this._data = v;
        return this._data || [];
      }
    }
  };
  fake.pager = { dataSource: fake.dataSource };
  jq.data("kendoGrid", fake);
  return fake;
}

const KendoGridColumn = defineComponent({
  name: "KendoGridColumn",
  props: {
    field: String,
    title: String,
    hidden: Boolean,
    locked: Boolean,
    editable: [Boolean, Function],
    width: [String, Number],
    format: String,
    values: Array,
    sortable: [Boolean, Object],
    template: [String, Function],
    command: Array
  },
  setup(props, { attrs }) {
    const register = inject("legacyKendoRegisterColumn", null);
    const column = () => {
      const result = {};
      ["field", "title", "hidden", "locked", "editable", "width", "format", "values", "sortable", "template", "command"].forEach(key => {
        if (props[key] !== undefined && props[key] !== null) result[key] = props[key];
      });
      const editorHandler = attrs.onEditor;
      result.editor = (container, options) => {
        if (typeof editorHandler === "function") return editorHandler(container, options);
        if (Array.isArray(editorHandler)) return editorHandler.forEach(handler => handler(container, options));
      };
      return result;
    };
    onMounted(() => {
      const registeredColumn = column();
      register?.(registeredColumn);
    });
    onUpdated(() => {
      const registeredColumn = column();
      register?.(registeredColumn);
    });
    return () => null;
  }
});

const KendoGrid = defineComponent({
  name: "KendoGrid",
  props: {
    id: String,
    dataSource: [Array, Object],
    editable: [Boolean, Object],
    pageable: [Boolean, Object],
    selectable: [Boolean, String],
    reorderable: Boolean,
    height: [Number, String],
    scrollable: [Boolean, Object],
    resizable: Boolean,
    sortable: [Boolean, Object],
    change: Function,
    dataBound: Function
  },
  emits: ["hook:mounted"],
  setup(props, { slots, emit, expose }) {
    const el = ref(null);
    const columns = [];
    let applying = false;
    provide("legacyKendoRegisterColumn", column => {
      const idx = columns.findIndex(item => item.field === column.field && item.title === column.title);
      if (idx >= 0) columns[idx] = column;
      else columns.push(column);
    });

    function init() {
      const node = el.value;
      if (!node || applying) return;
      applying = true;
      try {
        const kendo = getKendo();
        const data = applyLegacyVirtualFields(normalizeDataSource(props.dataSource), columns);
        const kendoColumns = normalizeColumnsForKendo(columns);
        ensureGridHost(node, data, props.pageable);
        const options = {
          dataSource: createGridDataSource(kendo, data, props.pageable),
          columns: kendoColumns.length ? kendoColumns : undefined,
          editable: props.editable,
          pageable: props.pageable,
          selectable: props.selectable,
          reorderable: props.reorderable,
          height: props.height,
          scrollable: props.scrollable,
          resizable: props.resizable,
          sortable: props.sortable,
          change: props.change,
          dataBound: props.dataBound
        };
        Object.keys(options).forEach(key => options[key] === undefined && delete options[key]);
        const jq = $(node);
        const current = jq.data("kendoGrid");
        if (current) {
          const isFallback = !current.wrapper && !current.tbody && !current.table;
          // add 20260605 setDataSource前に現在のページ・ソートを保存し、更新後に復元する start
          const pageState = getGridPageState(current.dataSource);
          // add 20260605 setDataSource前に現在のページ・ソートを保存し、更新後に復元する end
          ensureLegacyGridShape(current, data, props.pageable);
          if (isFallback && jq.kendoGrid) {
            jq.removeData("kendoGrid");
            jq.kendoGrid(options);
            const grid = jq.data("kendoGrid");
            ensureLegacyGridShape(grid, data, props.pageable);
            // add 20260605 データ更新後にページ・ソートを復元する start
            restoreGridPageState(grid?.dataSource, pageState);
            // add 20260605 データ更新後にページ・ソートを復元する end
            if (props.height && grid?.wrapper) grid?.wrapper?.height(props.height);
             grid?.refresh?.()
          } else if (current.setDataSource && kendo?.data?.DataSource) current.setDataSource(createGridDataSource(kendo, data, props.pageable));
          else if (current.dataSource?.data) current.dataSource.data(data);
          if (!isFallback) {
            ensureLegacyGridShape(current, data, props.pageable);
            // add 20260605 データ更新後にページ・ソートを復元する start
            restoreGridPageState(current.dataSource, pageState);
            restoreGridPageState(current.pager?.dataSource, pageState);
            // add 20260605 データ更新後にページ・ソートを復元する end
            if (props.height && current.wrapper) current.wrapper.height(props.height);
            current.refresh?.();
          }
        } else if (jq.kendoGrid) {
          jq.kendoGrid(options);
          ensureLegacyGridShape(jq.data("kendoGrid"), data, props.pageable);
        } else {
          renderFallbackTable(node, data, columns, props.change, props.pageable);
        }
      } finally {
        applying = false;
      }
    }

    onMounted(() => {
      nextTick(() => {
        init();
        emit("hook:mounted");
      });
    });
    onUpdated(() => {
      nextTick(() => init());
    });
    onBeforeUnmount(() => {
      const grid = el.value ? $(el.value).data("kendoGrid") : null;
      grid?.destroy?.();
    });
    expose({ refresh: init, get kendoGrid() { return el.value ? $(el.value).data("kendoGrid") : null; } });
    return () => h("div", { id: props.id, ref: el }, [h("div", { style: "display:none" }, slots.default?.())]);
  }
});

function renderFallbackTable(node, data, columns, change, pageable) {
  const visible = (columns || []).filter(column => !column.hidden);
  const rows = Array.isArray(data) ? data : [];
  node.innerHTML = `<table class="k-grid-table"><thead><tr>${visible.map(c => `<th>${c.title || c.field || ""}</th>`).join("")}</tr></thead><tbody>${rows.map(row => `<tr>${visible.map(c => `<td>${row?.[c.field] ?? ""}</td>`).join("")}</tr>`).join("")}</tbody></table>`;
  const fake = {
    select: () => node.querySelectorAll("tbody tr"),
    content: [node],
    dataSource: {
      _sort: null,
      _page: 1,
      _pageSize: getPageSize(pageable) || 10,
      sort(v) { this._sort = v; },
      page(v) { this._page = v; },
      pageSize(v) { this._pageSize = v; },
      total: () => rows.length,
      data: () => rows
    }
  };
  fake.pager = { dataSource: fake.dataSource };
  $(node).data("kendoGrid", fake);
  node.querySelectorAll("tbody tr").forEach(row => row.addEventListener("click", () => change?.({ sender: fake })));
}

const KendoDropDownList = defineComponent({
  name: "KendoDropDownList",
  props: {
    modelValue: [String, Number, Array, Object],
    dataSource: [Array, Object],
    dataTextField: String,
    dataValueField: String
  },
  emits: ["update:modelValue", "select", "change"],
  setup(props, { emit, attrs }) {
    const el = ref(null);
    function init() {
      const node = el.value;
      if (!node) return;
      const jq = $(node);
      if (jq.data("kendoDropDownList") || !jq.kendoDropDownList) return;
      jq.kendoDropDownList({
        dataSource: props.dataSource || [],
        dataTextField: props.dataTextField,
        dataValueField: props.dataValueField,
        select: e => emit("select", e),
        change: e => {
          emit("update:modelValue", jq.val());
          emit("change", e);
        }
      });
    }
    onMounted(init);
    onUpdated(() => {
      const ddl = el.value ? $(el.value).data("kendoDropDownList") : null;
      if (ddl?.setDataSource) ddl.setDataSource(props.dataSource || []);
    });
    return () => h("input", { ...attrs, ref: el, value: props.modelValue });
  }
});

const KendoTabStrip = defineComponent({
  name: "KendoTabStrip",
  setup(_props, { slots, attrs }) {
    const el = ref(null);
    function syncActiveTab() {
      const node = el.value;
      if (!node) return;
      const active = node.querySelector("li.k-state-active, li.k-active") || node.querySelector("li");
      if (!active) return;
      active.classList.add("k-state-active", "k-active");
      active.setAttribute("aria-selected", "true");
    }
    onMounted(() => {
      const jq = $(el.value);
      if (jq.kendoTabStrip && !jq.data("kendoTabStrip")) jq.kendoTabStrip();
      syncActiveTab();
    });
    onUpdated(() => {
      nextTick(() => syncActiveTab());
    });
    return () => h("div", { ...attrs, ref: el }, slots.default?.());
  }
});

const KendoGridToolbar = defineComponent({
  name: "KendoGridToolbar",
  setup(_props, { slots, attrs }) {
    return () => h("div", attrs, slots.default?.());
  }
});

const KendoQrCode = defineComponent({
  name: "KendoQrCode",
  props: { value: String, size: [String, Number], encoding: String },
  setup(props, { attrs }) {
    const el = ref(null);
    function init() {
      const jq = $(el.value);
      const current = jq.data("kendoQRCode");
      if (current?.value) current.value(props.value || "");
      else if (jq.kendoQRCode) jq.kendoQRCode({ value: props.value || "", size: props.size, encoding: props.encoding });
      else if (el.value) el.value.textContent = props.value || "";
    }
    onMounted(init);
    onUpdated(init);
    return () => h("div", { ...attrs, ref: el });
  }
});

const DataSource = defineComponent({ name: "KendoDataSource", setup() { return () => null; } });
const KendoUpload = defineComponent({ name: "KendoUpload", setup(_p, { attrs }) { return () => h("input", { ...attrs, type: "file" }); } });

export function installKendoCompat(app) {
  app.component("kendo-grid", KendoGrid);
  app.component("kendo-grid-native", KendoGrid);
  app.component("kendo-grid-column", KendoGridColumn);
  app.component("kendo-grid-toolbar", KendoGridToolbar);
  app.component("grid-norecords", defineComponent({ name: "GridNoRecords", setup(_p, { slots }) { return () => h("div", slots.default?.()); } }));
  app.component("kendo-datasource", DataSource);
  app.component("kendo-dropdownlist", KendoDropDownList);
  app.component("kendo-tabstrip", KendoTabStrip);
  app.component("kendo-upload", KendoUpload);
  app.component("ntss-upload", KendoUpload);
  app.component("kendo-qrcode", KendoQrCode);
}
