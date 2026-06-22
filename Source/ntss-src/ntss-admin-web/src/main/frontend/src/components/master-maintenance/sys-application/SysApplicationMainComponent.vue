/** アプリケーションダウンロードページ */
 <template>
  <div class='main-content-area master-maintenance-page'>
    <div class='sys-app-main-content-area'>
      <div
        ref='sysApplicationGrid'
        :class='[fontSizeSet, "ntss-kendo-grid-legacy", "sys-application-direct-jq-grid"]'
      ></div>
    </div>
  </div>
</template>

<script>
import { createApp, markRaw } from "@/compat/vue/runtime";
import { mapActions, mapGetters } from "@/compat/vue/vuex";
import { EventBus } from "@/compat/vue/event-bus.js";
import kendo from "@progress/kendo-ui";
import $ from "jquery";
import DownloadTemplate from "./SysApplicationDownloadButtonTemplate";
import { getScopedAlertDialogs } from "@/functions/common/LayoutMeasureHelper";

function installComponentJQuery() {
  if (typeof window !== "undefined") {
    window.$ = window.$ || $;
    window.jQuery = window.jQuery || $;
  }
  if (typeof globalThis !== "undefined") {
    globalThis.$ = globalThis.$ || $;
    globalThis.jQuery = globalThis.jQuery || $;
  }
}

export default {
  data() {
    return {
      columns: [],
      selfScreenName: "",
      kendoGridHeight: 300,
      directGridWidget: null,
      directGridDataSource: null,
      directGridColumnSignature: "",
      directGridLayoutRafId: null,
      directGridDownloadApps: markRaw(new Map()),
    };
  },
  computed: {
    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight",
      windowWidth: "getWindowWidth"
    }),
    ...mapGetters("account-edit", {
      isDispMenu: "isDispMenu",
      getFontSize: "getFontSize"
    }),
    ...mapGetters("sys-application", ["getSysApplicationColumn", "getApplicationInfo", "getCondition"]),
    fontSizeSet() {
      const names = ["small", "medium", "large", "x-large"];
      return `font-size-set-${names[this.getFontSize] || names[1]}`;
    },
  },
  watch: {
    windowHeight() {
      this.calculateGridHeight();
      this.scheduleDirectGridLayoutContract();
    },
    windowWidth() {
      this.calculateGridHeight();
      this.scheduleDirectGridLayoutContract();
    },
    getFontSize() {
      this.calculateGridHeight();
      this.scheduleDirectGridLayoutContract();
    },
    isDispMenu() {
      this.calculateGridHeight();
      this.scheduleDirectGridLayoutContract();
    },
    getCondition() {
      this.loadGridData();
    },
    getApplicationInfo() {
      this.refreshDirectGridDataSource();
    },
    getSysApplicationColumn() {
      this.applyDirectGridColumnsContract();
      this.scheduleDirectGridLayoutContract();
    },
  },
  methods: {
    ...mapActions("sys-application", [
      "setCondition",
      "setSysApplicationColumn",
      "fetchApplicationInfo",
      "cleanApplicationInfo"
    ]),
    // 共通ローダー設定
    ...mapActions("loading-screen", {
      setLoadingScreenVisible: "setLoadingScreenVisible",
      setLoadingScreenMessage: "setLoadingScreenMessage",
    }),
    getGridRoot() {
      return this.$refs.sysApplicationGrid || null;
    },
    getGridWidget() {
      return this.directGridWidget;
    },
    getGridContent() {
      return this.getGridRoot()?.querySelector?.(".k-grid-content") || null;
    },
    getGridLockedContent() {
      return this.getGridRoot()?.querySelector?.(".k-grid-content-locked") || null;
    },
    calculateGridHeight() {
      const root = this.$el?.querySelector?.(".sys-app-main-content-area");
      const ownerWindow = this.$el?.ownerDocument?.defaultView || window;
      const rectHeight = root?.getBoundingClientRect?.().height || 0;
      const fallback = (this.windowHeight || ownerWindow.innerHeight || 0) - 120;
      this.kendoGridHeight = Math.max(100, Math.floor(rectHeight || fallback || 300));
    },
    buildColumnSignature(columns = this.getSysApplicationColumn || []) {
      return (columns || []).map(column => [
        column.field,
        column.title,
        column.width,
        column.hidden ? 1 : 0,
        column.locked ? 1 : 0
      ].join(":")) .join("|");
    },
    buildDirectGridColumns() {
      return (this.getSysApplicationColumn || []).map((column) => {
        const gridColumn = { ...column };
        if (column.title === "ダウンロード") {
          gridColumn.attributes = { style: "text-align: center;" };
          gridColumn.template = (dataItem) => {
            const uid = dataItem?.uid || "";
            return `<div class="sys-application-download-host" data-uid="${uid}"></div>`;
          };
        }
        return gridColumn;
      });
    },
    createDirectGridDataSource() {
      this.directGridDataSource = markRaw(new kendo.data.DataSource({
        data: Array.isArray(this.getApplicationInfo) ? this.getApplicationInfo : []
      }));
      return this.directGridDataSource;
    },
    initDirectGridIfReady() {
      const root = this.getGridRoot();
      if (!root || !this.getSysApplicationColumn?.length) {
        return;
      }
      if (this.directGridWidget) {
        this.refreshDirectGridDataSource();
        this.applyDirectGridColumnsContract();
        this.scheduleDirectGridLayoutContract();
        return;
      }
      installComponentJQuery();
      $(root).empty();
      $(root).kendoGrid({
        dataSource: this.createDirectGridDataSource(),
        height: this.kendoGridHeight,
        editable: false,
        scrollable: true,
        columns: this.buildDirectGridColumns(),
        dataBound: () => {
          // resize 由来の dataBound から layout schedule を呼ぶと
          // dataBound → resize → dataBound の無限ループになるため、ここでは style のみ適用する。
          this.applyDirectGridStyleContract();
          this.mountDownloadTemplates();
          this.setLoadingScreenVisible(false);
        }
      });
      this.directGridWidget = markRaw($(root).data("kendoGrid"));
      this.directGridColumnSignature = this.buildColumnSignature();
      this.applyDirectGridStyleContract();
      this.mountDownloadTemplates();
      this.scheduleDirectGridLayoutContract();
    },
    destroyDirectGrid() {
      this.unmountDownloadTemplates();
      if (this.directGridWidget) {
        try {
          this.directGridWidget.destroy();
        } catch (_error) {
          // noop
        }
      }
      const root = this.getGridRoot();
      if (root) {
        $(root).empty();
      }
      this.directGridWidget = null;
      this.directGridDataSource = null;
      this.directGridColumnSignature = "";
    },
    refreshDirectGridDataSource() {
      const grid = this.directGridWidget;
      if (!grid?.dataSource) {
        return;
      }
      grid.dataSource.data(Array.isArray(this.getApplicationInfo) ? this.getApplicationInfo : []);
      this.$nextTick(() => {
        this.applyDirectGridStyleContract();
        this.mountDownloadTemplates();
      });
    },
    applyDirectGridColumnsContract() {
      const grid = this.directGridWidget;
      if (!grid) {
        return;
      }
      const signature = this.buildColumnSignature();
      if (signature === this.directGridColumnSignature) {
        return;
      }
      this.directGridColumnSignature = signature;
      grid.setOptions({ columns: this.buildDirectGridColumns() });
      this.mountDownloadTemplates();
    },
    unmountDownloadTemplates() {
      this.directGridDownloadApps.forEach(app => {
        try {
          app.unmount();
        } catch (_error) {
          // noop
        }
      });
      this.directGridDownloadApps.clear();
    },
    mountDownloadTemplates() {
      const grid = this.directGridWidget;
      const root = this.getGridRoot();
      if (!grid || !root) {
        return;
      }
      this.unmountDownloadTemplates();
      root.querySelectorAll(".sys-application-download-host").forEach((host, index) => {
        const row = host.closest("tr");
        const dataItem = row ? grid.dataItem(row) : null;
        if (!dataItem) {
          return;
        }
        const app = createApp(DownloadTemplate, { templateArgs: dataItem });
        if (this.$ons) {
          app.config.globalProperties.$ons = this.$ons;
        }
        app.mount(host);
        this.directGridDownloadApps.set(`${dataItem.uid || index}`, app);
      });
    },
    applyDirectGridStyleContract() {
      const root = this.getGridRoot();
      if (!root) {
        return;
      }
      root.classList.add("ntss-kendo-grid-legacy", "k-widget", "k-grid", "k-display-block");
      root.querySelectorAll(".k-grid-content tbody tr").forEach((row, index) => {
        row.classList.add("k-master-row");
        row.classList.toggle("k-alt", index % 2 === 1);
      });
      root.querySelectorAll(".k-grid-content-locked tbody tr").forEach((row, index) => {
        row.classList.add("k-master-row");
        row.classList.toggle("k-alt", index % 2 === 1);
      });
      root.querySelectorAll(".k-grid-content tbody td, .k-grid-content-locked tbody td").forEach(cell => {
        cell.classList.add("k-td", "k-table-td");
      });
      this.applyDirectGridLockedWidthContract();
      this.applyDirectGridLockedHeightContract();
      this.syncDirectGridLockedScroll();
    },
    applyDirectGridLockedWidthContract() {
      const root = this.getGridRoot();
      if (!root) {
        return;
      }
      const lockedWidth = (this.getSysApplicationColumn || []).reduce((sum, column) => {
        if (!column.locked || column.hidden) {
          return sum;
        }
        const width = `${column.width || ""}`.trim();
        if (width.endsWith("px")) {
          return sum + Number.parseFloat(width);
        }
        if (width.endsWith("em")) {
          const ownerWindow = root.ownerDocument?.defaultView || window;
          const fontSize = Number.parseFloat(ownerWindow.getComputedStyle(root).fontSize || "16") || 16;
          return sum + Number.parseFloat(width) * fontSize;
        }
        const numeric = Number.parseFloat(width);
        return Number.isFinite(numeric) ? sum + numeric : sum;
      }, 0);
      if (!lockedWidth) {
        return;
      }
      const widthPx = `${Math.ceil(lockedWidth)}px`;
      [
        ".k-grid-header-locked",
        ".k-grid-content-locked",
        ".k-grid-header-locked table",
        ".k-grid-content-locked table"
      ].forEach(selector => {
        root.querySelectorAll(selector).forEach(element => {
          element.style.width = widthPx;
          element.style.minWidth = widthPx;
        });
      });
    },
    applyDirectGridLockedHeightContract() {
      const content = this.getGridContent();
      const lockedContent = this.getGridLockedContent();
      if (!content || !lockedContent) {
        return;
      }
      const height = content.clientHeight;
      if (height > 0) {
        lockedContent.style.height = `${height}px`;
        lockedContent.style.maxHeight = `${height}px`;
      }
    },
    syncDirectGridLockedScroll() {
      const content = this.getGridContent();
      const lockedContent = this.getGridLockedContent();
      if (!content || !lockedContent) {
        return;
      }
      lockedContent.scrollTop = content.scrollTop;
    },
    scheduleDirectGridLayoutContract() {
      if (this.directGridLayoutRafId != null) {
        cancelAnimationFrame(this.directGridLayoutRafId);
      }
      this.directGridLayoutRafId = requestAnimationFrame(() => {
        this.resizeDirectGrid();
        this.applyDirectGridStyleContract();
        this.directGridLayoutRafId = requestAnimationFrame(() => {
          this.directGridLayoutRafId = null;
          this.applyDirectGridStyleContract();
        });
      });
    },
    resizeDirectGrid() {
      const grid = this.directGridWidget;
      if (!grid) {
        return;
      }
      try {
        grid.setOptions({ height: this.kendoGridHeight });
        grid.resize(true);
      } catch (_error) {
        // noop
      }
    },
    /** データ取得 */
    async loadGridData() {
      this.setLoadingScreenVisible(true);
      await this.fetchApplicationInfo();
      this.$nextTick(() => {
        this.calculateGridHeight();
        this.initDirectGridIfReady();
        this.refreshDirectGridDataSource();
        this.scheduleDirectGridLayoutContract();
      });
    },
    /** リフレッシュ処理 */
    refresh() {
      // 他の画面に遷移したときもrefresh()が発生する為、自分の画面のみ処理する
      if (this.selfScreenName === this.$route.name
          && getScopedAlertDialogs(this.$el || this).length === 0) {
        this.loadGridData();
      }
    },
  },
  created() {
    this.setLoadingScreenVisible(true);
    // 共通ローダー:表示名設定
    this.setLoadingScreenMessage("処理中・・・");
    this.cleanApplicationInfo();
    this.selfScreenName = this.$route.name;
    EventBus.$on("refresh", this.refresh);
  },
  mounted() {
    this.loadGridData();
  },
  beforeUnmount() {
    EventBus.$off("refresh", this.refresh);
    this.setCondition(JSON.parse(JSON.stringify({recordName: ""})));
    if (this.directGridLayoutRafId != null) {
      cancelAnimationFrame(this.directGridLayoutRafId);
      this.directGridLayoutRafId = null;
    }
    this.destroyDirectGrid();
  }
};
</script>

<style scoped>
.sys-app-main-content-area :deep(.k-selectable) {
  box-shadow: 1px 0px 0px 0px white;
  border-right: 1px solid transparent;
}
.sys-app-main-content-area :deep(.k-grid-content-locked) {
  border-right: 0px solid transparent !important;
}
.sys-app-main-content-area :deep(.k-grid-header-locked) {
  border-right-width: 0px;
}
.sys-app-main-content-area :deep(.k-grid td) {
  height: 2.4em;
}

.sys-app-main-content-area :deep(.k-grid .k-table-td) {
  height: 2.4em;
}

.sys-application-direct-jq-grid {
  width: 100%;
}


/* Vue2 Kendo locked layout contract.
   Kendo 2026 renders locked content inside flex containers; keep the locked area
   at the width Kendo/column definitions already calculated, as Kendo 2019 did. */
:deep(.k-grid-lockedcolumns .k-grid-header-locked),
:deep(.k-grid-lockedcolumns .k-grid-content-locked),
:deep(.k-grid-lockedcolumns .k-grid-footer-locked) {
  flex: 0 0 auto;
  flex-shrink: 0;
}
</style>
