<template>
  <div ref="root" class="kendo-grid-view" :style="rootStyle">
  </div>
</template>

<script>
import $ from "jquery";
import { isProxy, toRaw } from "vue";
import "@progress/kendo-ui";

function unwrap(value) {
  if (value == null) {
    return value;
  }
  return isProxy(value) ? toRaw(value) : value;
}

function getKendo() {
  const kendo = (typeof window !== "undefined" && window.kendo) || globalThis.kendo;
  if (!kendo?.data?.DataSource) {
    throw new Error("Kendo UI is not available.");
  }
  return kendo;
}

/**
 * Kendo Grid は locked 列のみでは初期化できないため、
 * すべて locked: true のとき最後の列だけ locked: false にする。
 */
function normalizeGridColumns(columns) {
  if (!Array.isArray(columns) || columns.length === 0) {
    return columns ?? [];
  }
  const allLocked = columns.every(col => col && col.locked === true);
  if (!allLocked) {
    return columns;
  }
  const result = columns.map(col => ({ ...col }));
  const lastIndex = result.length - 1;
  result[lastIndex] = { ...result[lastIndex], locked: false };
  return result;
}

/**
 * locked 列リサイズ中にスクロール列の左端位置をリアルタイム同期する。
 * Kendo Grid 標準は resizeend 時のみ _applyLockedContainersWidth を呼ぶため、
 * ドラッグ中は固定列と非固定列の境界がずれる。
 */
function syncLockedContainersDuringColumnResize(grid) {
  if (!grid?.lockedContent || typeof grid._applyLockedContainersWidth !== "function") {
    return;
  }
  const contentEl = grid.content?.[0];
  const virtualWrap = grid.wrapper?.find(".k-virtual-scrollable-wrap")?.[0];
  const scrollLeft = contentEl?.scrollLeft ?? 0;
  const virtualScrollLeft = virtualWrap?.scrollLeft ?? 0;

  grid._applyLockedContainersWidth(true);
  if (typeof grid._syncLockedContentHeight === "function") {
    grid._syncLockedContentHeight();
  }
  if (typeof grid._syncLockedHeaderHeight === "function") {
    grid._syncLockedHeaderHeight();
  }

  if (contentEl) {
    contentEl.scrollLeft = scrollLeft;
  }
  if (virtualWrap) {
    virtualWrap.scrollLeft = virtualScrollLeft;
  }
}

export default {
  name: "KendoGridView",
  inheritAttrs: false,
  props: {
    options: {
      type: Object,
      default: null,
    },
    columns: {
      type: Array,
      default: null,
    },
    columnMenu: {
      type: [Object, Boolean],
      default: undefined,
    },
    height: {
      type: [Number, String],
      default: 680,
    },
    width: {
      type: [Number, String],
      default: undefined,
    },
    editable: {
      type: [String, Boolean, Object],
      default: false,
    },
    pageable: {
      type: [Boolean, Object],
      default: false,
    },
    sortable: {
      type: [Boolean, Object],
      default: false,
    },
    scrollable: {
      type: [Boolean, Object],
      default: false,
    },
    navigatable: {
      type: Boolean,
      default: false,
    },
    resizable: {
      type: Boolean,
      default: true,
    },
    reorderable: {
      type: Boolean,
      default: false,
    },
    groupable: {
      type: [Boolean, Object],
      default: false,
    },
    filterable: {
      type: [Boolean, Object],
      default: false,
    },
    dataBound: {
      type: Function,
      default: null,
    },
    toolbar: {
      type: Array,
      default: () => [],
    },
  },
  emits: [],
  computed: {
    rootStyle() {
      const width = this.width;
      if (width == null || width === "") {
        return { width: "100%" };
      }
      return {
        width: typeof width === "number" ? `${width}px` : width,
      };
    },
  },
  data() {
    return {
      grid: null,
      dataSource: null,
      lockedResizeSyncState: null,
    };
  },
  mounted() {
    this.mountGrid();
  },
  beforeUnmount() {
    this.teardownLockedColumnResizeSync();
    if (this.grid) {
      this.grid.destroy();
      this.grid = null;
    }
    this.dataSource = null;
  },
  watch: {
    height() {
      this.applyGridSize();
    },
    width() {
      this.applyGridSize();
    },
    scrollable() {
      this.applyScrollable();
    },
    options: {
      deep: true,
      handler() {
        this.syncDataSourceFromOptions();
      },
    },
    columns: {
      deep: true,
      handler() {
        this.refreshColumns(unwrap(this.columns) ?? []);
      },
    },
  },
  methods: {
    getWidget() {
      return this.grid;
    },
    resize() {
      this.applyGridSize();
    },
    refreshData(rows) {
      if (!this.dataSource) {
        return;
      }
      this.dataSource.data(rows ?? []);
    },
    refreshColumns(columns) {
      if (!this.grid) {
        return;
      }
      this.grid.setOptions({ columns: normalizeGridColumns(columns ?? []) });
      this.applyGridSize();
      this.$nextTick(() => {
        this.setupLockedColumnResizeSync();
      });
    },
    setScrollable(scrollable) {
      if (!this.grid) {
        return;
      }
      this.grid.setOptions({ scrollable: unwrap(scrollable) });
      this.applyGridSize();
    },
    applyScrollable() {
      if (!this.grid) {
        return;
      }
      this.grid.setOptions({ scrollable: unwrap(this.scrollable) });
      this.applyGridSize();
    },
    syncDataSourceFromOptions() {
      if (!this.dataSource) {
        return;
      }
      const raw = this.options == null ? {} : unwrap(this.options);
      if (raw.data !== undefined) {
        this.dataSource.data(raw.data);
      }
      if (raw.pageSize !== undefined) {
        this.dataSource.pageSize(raw.pageSize);
      }
    },
    teardownLockedColumnResizeSync() {
      const grid = this.grid;
      const state = this.lockedResizeSyncState;
      if (!grid?.resizable || !state) {
        this.lockedResizeSyncState = null;
        return;
      }
      if (state.onStart) {
        grid.resizable.unbind("start", state.onStart);
      }
      if (state.onResize) {
        grid.resizable.unbind("resize", state.onResize);
      }
      if (state.onResizeEnd) {
        grid.resizable.unbind("resizeend", state.onResizeEnd);
      }
      this.lockedResizeSyncState = null;
    },
    setupLockedColumnResizeSync() {
      const grid = this.grid;
      if (!grid?.resizable || !grid.lockedContent) {
        return;
      }
      this.teardownLockedColumnResizeSync();
      const state = {
        isLockedResize: false,
        onStart: null,
        onResize: null,
        onResizeEnd: null,
      };
      state.onStart = e => {
        state.isLockedResize = false;
        const handle = $(e.currentTarget);
        const th = handle.data("th");
        if (th?.length) {
          state.isLockedResize = th.closest("table").parent().hasClass("k-grid-header-locked");
        }
      };
      state.onResize = () => {
        if (state.isLockedResize) {
          syncLockedContainersDuringColumnResize(grid);
        }
      };
      state.onResizeEnd = () => {
        state.isLockedResize = false;
        syncLockedContainersDuringColumnResize(grid);
      };
      grid.resizable.bind("start", state.onStart);
      grid.resizable.bind("resize", state.onResize);
      grid.resizable.bind("resizeend", state.onResizeEnd);
      this.lockedResizeSyncState = state;
    },
    applyGridSize() {
      if (!this.grid) {
        return;
      }
      const wrapper = this.grid.wrapper;
      if (wrapper && this.height != null && this.height !== "") {
        wrapper.height(this.height);
      }
      try {
        this.grid.resize(true);
      } catch (_error) {
        try {
          this.grid.resize();
        } catch (_ignored) {
          // noop
        }
      }
    },
    mountGrid() {
      const kendo = getKendo();
      const rawDataSourceOptions = this.options == null ? {} : unwrap(this.options);
      this.dataSource = new kendo.data.DataSource(rawDataSourceOptions);

      const $root = $(this.$refs.root);
      const gridOptions = {
        dataSource: this.dataSource,
        height: this.height,
        editable: this.editable,
        pageable: this.pageable,
        sortable: this.sortable,
        scrollable: unwrap(this.scrollable),
        navigatable: this.navigatable,
        resizable: this.resizable,
        reorderable: this.reorderable,
        groupable: this.groupable,
        filterable: this.filterable,
        columns: normalizeGridColumns(unwrap(this.columns) ?? []),
      };
      const rawWidth = this.width;
      if (rawWidth != null && rawWidth !== "") {
        gridOptions.width = typeof rawWidth === "number" ? rawWidth : rawWidth;
      }
      const rawColumnMenu = unwrap(this.columnMenu);
      if (rawColumnMenu !== undefined) {
        gridOptions.columnMenu = rawColumnMenu;
      }
      const rawToolbar = unwrap(this.toolbar);
      if (Array.isArray(rawToolbar) && rawToolbar.length > 0) {
        gridOptions.toolbar = rawToolbar;
      }
      const userDataBound = this.dataBound;
      gridOptions.dataBound = e => {
        if (typeof userDataBound === "function") {
          userDataBound(e);
        }
        this.$nextTick(() => {
          this.setupLockedColumnResizeSync();
        });
      };

      this.grid = $root.kendoGrid(gridOptions).data("kendoGrid");
      this.applyGridSize();
      this.$nextTick(() => {
        this.setupLockedColumnResizeSync();
      });
    },
  },
};
</script>

<style scoped>
.kendo-grid-view {
  box-sizing: border-box;
  max-width: 100%;
}
</style>
