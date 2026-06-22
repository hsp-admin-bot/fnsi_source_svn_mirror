import { defineComponent, h, inject, onBeforeUnmount, onMounted, onUpdated, provide, ref } from "vue";
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
  emits: ["editor"],
  setup(props, { emit }) {
    const register = inject("legacyKendoRegisterColumn", null);
    const column = () => {
      const result = {};
      ["field", "title", "hidden", "locked", "editable", "width", "format", "values", "sortable", "template", "command"].forEach(key => {
        if (props[key] !== undefined && props[key] !== null) result[key] = props[key];
      });
      if (emit) {
        result.editor = (container, options) => emit("editor", container, options);
      }
      return result;
    };
    onMounted(() => register?.(column()));
    onUpdated(() => register?.(column()));
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
        const data = normalizeDataSource(props.dataSource);
        const options = {
          dataSource: data,
          columns: columns.length ? columns : undefined,
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
          if (current.setDataSource && kendo?.data?.DataSource) current.setDataSource(new kendo.data.DataSource({ data }));
          else if (current.dataSource?.data) current.dataSource.data(data);
          if (props.height && current.wrapper) current.wrapper.height(props.height);
          current.refresh?.();
        } else if (jq.kendoGrid) {
          jq.kendoGrid(options);
        } else {
          renderFallbackTable(node, data, columns, props.change);
        }
      } finally {
        applying = false;
      }
    }

    onMounted(() => {
      setTimeout(init, 0);
      emit("hook:mounted");
    });
    onUpdated(() => setTimeout(init, 0));
    onBeforeUnmount(() => {
      const grid = el.value ? $(el.value).data("kendoGrid") : null;
      grid?.destroy?.();
    });
    expose({ refresh: init, get kendoGrid() { return el.value ? $(el.value).data("kendoGrid") : null; } });
    return () => h("div", { id: props.id, ref: el }, [h("div", { style: "display:none" }, slots.default?.())]);
  }
});

function renderFallbackTable(node, data, columns, change) {
  const visible = (columns || []).filter(column => !column.hidden);
  const rows = Array.isArray(data) ? data : [];
  node.innerHTML = `<table class="k-grid-table"><thead><tr>${visible.map(c => `<th>${c.title || c.field || ""}</th>`).join("")}</tr></thead><tbody>${rows.map(row => `<tr>${visible.map(c => `<td>${row?.[c.field] ?? ""}</td>`).join("")}</tr>`).join("")}</tbody></table>`;
  const fake = {
    select: () => node.querySelectorAll("tbody tr"),
    content: [node],
    dataSource: { _sort: null, sort(v) { this._sort = v; }, data: () => rows },
    pager: { dataSource: { _page: 1, page(v) { this._page = v; } } }
  };
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
    onMounted(() => {
      const jq = $(el.value);
      if (jq.kendoTabStrip && !jq.data("kendoTabStrip")) jq.kendoTabStrip();
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
