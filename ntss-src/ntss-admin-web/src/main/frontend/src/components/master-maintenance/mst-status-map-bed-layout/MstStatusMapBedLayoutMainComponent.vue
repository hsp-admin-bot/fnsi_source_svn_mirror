/**
 * 治療状況ベッドレイアウトマスタメンテナンスデータページ  MainContent
 */
<template>
  <div class="main-content-area master-maintenance-page">
    <div class="ntss-list" :style="ntssListStyles">
      <div class="k-grid-toolbar k-header kendo-grid-toolbar-style" :style="heightStyles">
        <div id="grid-header" :class="['header-btn-area', 'right', isMobileDevice ? 'mobile-header' : '']" :style="isMobileDevice ? { minHeight: '30px' } : {}">
          <v-ons-button modifier="outline" class="btn3-normal toolbar-btn" style="float: left;" v-show="!isSortMode && isAllowAddRecord" @click="addRow()">追加</v-ons-button>
          <v-ons-row v-show="isMobileDevice" style="float: left; width: 6em; height: 2em;">
            <v-ons-col width="45%" vertical-align="center">
              <label class="fab-font-color">編集</label>
            </v-ons-col>
            <v-ons-col width="55%" vertical-align="center">
              <v-ons-switch modifier="outline" v-model="allowEdit" />
            </v-ons-col>
          </v-ons-row>
          <v-ons-button modifier="outline" class="btn3-normal csv-btn" v-show="!isSortMode && isAllowAddRecord && !iosFlg && !androidFlg && false" @click="importCsv($event)">CSV取込</v-ons-button>
          <v-ons-button modifier="outline" class="btn3-normal toolbar-btn" v-show="!isSortMode && isAllowSort" @click="toRankEditBtnClick()">並び順表示</v-ons-button>
          <v-ons-button modifier="outline" class="btn3-normal toolbar-btn" v-show="isSortMode && isAllowSort" @click="sortBtnClick()">反映</v-ons-button>
        </div>
        <div
          v-show="columns.length > 1"
          id="grid-font-size"
          ref="gridRoot"
          :class="[fontSizeSet, 'ntss-kendo-grid-legacy', 'mst-status-map-bed-layout-direct-jq-grid']"
        ></div>
      </div>
      <div id="grid-footer">
        <v-ons-row width="100%" :style="{ visibility:this.isSortMode ?  'hidden' : 'visible' }" >
          <v-ons-col width="50%">
            <v-ons-button class="btn2-cancel denial-btn" style="width: auto;" @click="cancel">キャンセル</v-ons-button>
          </v-ons-col>
          <v-ons-col width="50%" class="right">
            <v-ons-button class="btn1-execute registration-btn" style="width: auto;" :disabled="!isChanged" @click="saveRecord">保存</v-ons-button>
          </v-ons-col>
        </v-ons-row>
      </div>
      <master-csv
        :popoverVisible="masterCsvVisible"
        :popoverTarget="masterCsvTarget"
        @popover-close="prehideCsvPopover"
      />
    </div>
  </div>
</template>
<script>
import { mapActions, mapGetters } from "@/compat/vue/vuex";
import { EventBus } from "@/compat/vue/event-bus.js";
import MasterCsvComponent from "@/components/master-maintenance/MasterCsvComponent";
//FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
import { getScopedElementById, queryScopedSelector, queryScopedSelectorAll, getScopedAlertDialogs, getScopedDocument } from "@/functions/common/LayoutMeasureHelper";
import { messageFormat } from "@/functions/common/MessageFormat";
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
import { markRaw } from "@/compat/vue/runtime";
import kendo from "@progress/kendo-ui";
import $ from "jquery";
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end

function clonePlain(value) {
  return JSON.parse(JSON.stringify(value || {}));
}

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

/**
 * TODO
 * more: モーダルで編集した項目が、一覧上で「編集済み（三角マーク）」をつけたい。
 */
export default {
  components: {
    "master-csv": MasterCsvComponent
  },
  data() {
    return {
      recordList: [],
      // 初期状態で1列がないとその後の表示が行われないため初期列を定義
      columns: [
        {
          field: "code",
          title: "code",
          hidden: false,
          locked: false,
          editable: () => true,
          values: null
        }
      ],
      condition: {
        recordName: "",
        includeDeleted: false
      },
      updateResponse: {
        isSuccess: false,
        errorMessage: ""
      },
      isSortMode: false,
      kendoGridToolbarHeight: 500,
      kendoGridHeight: 300,
      columnWidth: 14,
      kendoValidatorSetup: {
        rules: {},
        messages: {}
      },
      mstSynchroApiParams: {
        mstTable: "mst_m_notice",
        deviceEdgeNo: -1
      },
      //Android端末で編集中であることを示すフラグ
      editingFlg: false,
      androidFlg: false,
      iosFlg: false,
      scrollPosition: {
        top: 0,
        left: 0
      },
      //自画面の名称
      selfScreenName: "",
      masterCsvVisible: false,
      masterCsvTarget: null,
      allowEdit: true, // NOTE: true = 編集モード、 false = 閲覧モード
      directGridWidget: null,
      directGridMounted: false,
      directGridDataSource: null,
      directGridLayoutRafId: null,
      directGridFilterRefreshRafId: null,
      directGridScrollSyncRafId: null,
      directGridVisualRefreshRafId: null,
      directGridRowVisualRafIds: markRaw(new Map()),
      directSortChangedCodeSet: markRaw(new Set()),
      kendoValidator: null,
      isSorted: false
    };
  },
  computed: {
    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight",
      windowWidth: "getWindowWidth"
    }),
    ...mapGetters("account-edit", {
      isDispMenu: "isDispMenu",
      getFontSize: "getFontSize",
      getStateUserAccountInfo: "getStateUserAccountInfo"
    }),
    ...mapGetters("mst-status-map-bed-layout", {
      getScrollPosition: "getScrollPosition",
    }),
    heightStyles() {
      // main部の高さをCSS変数を利用して書き換え
      return { "--height": `${this.kendoGridToolbarHeight}px` };
    },
    ntssListStyles() {
      if (this.columns.length == 1) {
        return { display: "none" };
      }
      const height = Number(this.kendoGridToolbarHeight) || 0;
      const heightPx = height > 0 ? `${height}px` : undefined;
      return {
        display: "inherit",
        "--height": heightPx,
        height: heightPx,
        maxHeight: heightPx,
        position: "relative",
        overflow: "hidden"
      };
    },
    fontSizeSet() {
      const names = ["small", "medium", "large", "x-large"];
      return `font-size-set-${names[this.getFontSize] || "medium"}`;
    },
    masterConditionSignature() {
      const condition = this.$store?.state?.["master-maintenance"]?.condition || this.condition || {};
      return `${condition.recordName || ""}|${condition.includeDeleted ? 1 : 0}`;
    },
    ...mapGetters("master-maintenance", {
      getMasterRecordList: "getMasterRecordList",
      getFilteredMasterRecordList: "getFilteredMasterRecordList",
      getUpdateRecordList: "getUpdateRecordList",
      masterPhysicalName: "getMasterName",
      getLogicalMasterName: "getLogicalMasterName",
      columnDefinition: "getColumns",
      editRecord: "getEditRecord",
      isEdited: "isEdited",
      hasValueColumn: "hasValueColumn",
      isRecordModified: "isRecordModified",
      getFacilitySwitch: "getFacilitySwitch"
    }),
    masterRecords() {
      // storeからデータを取得
      let MasterRecordList = this.getFilteredMasterRecordList;

      if (MasterRecordList.data) {
        let RecordList = this.getFilteredMasterRecordList.data.filter(row => row.sortRank == null || row.sortRank == 999999);
        if (RecordList.length > 0) {
          MasterRecordList = this.getFilteredMasterRecordList;
          let j = 0;
          for (let i = 0; i < MasterRecordList.data.length; i++) {
            if (MasterRecordList.data[i].isDisp == '1') {
              MasterRecordList.data[i].sortRank = j + 1;
              j = j+1
            }
          }
        }
      }
      return MasterRecordList;
    },
    isAllowAddRecord() {
      // allowAddRecordが定義されていない場合は追加ボタンは使用不可
      return !(this.getColumnIndex("allowAddRecord") < 0);
    },
    isAllowSort() {
      // allowSortが定義されていない場合は並び替えボタンは使用不可
      return !(this.getColumnIndex("allowSort") < 0);
    },
    isChanged() {
      const data = this.getMasterRecordList.data;
      return (
        this.getStateUserAccountInfo !== null &&
        data !== undefined &&
        (this.$store.getters["master-maintenance/isRecordModified"] || data.filter(row => row.operation > 0 || row.edited || row.dirty).length || this.isSorted || !this.validateBeforeGridAction())
      );
    },
    isMobileDevice() {
      return this.iosFlg || this.androidFlg;
    },
  },
  watch: {
    windowHeight() {
      this.calculateColumnsdWidth();
      this.calculateGridHeight();
      this.calculateGridWidth();
      this.scheduleDirectGridLayoutContract();
    },
    windowWidth() {
      this.calculateColumnsdWidth();
      this.calculateGridHeight();
      this.calculateGridWidth();
      this.scheduleDirectGridLayoutContract();
    },
    isDispMenu() {
      this.calculateColumnsdWidth();
      this.calculateGridHeight();
      this.calculateGridWidth();
      this.scheduleDirectGridLayoutContract();
    },
    getFontSize() {
      this.calculateColumnsdWidth();
      this.calculateGridHeight();
      this.calculateGridWidth();
      this.scheduleDirectGridLayoutContract();
    },
    columns(val) {
      this.$nextTick(() => {
        if (val.length > 1) {
          this.setLoadingScreenVisible(false);
          this.initDirectGridIfReady();
          this.scheduleDirectGridLayoutContract();
        }
      });
    },
    masterConditionSignature() {
      this.scheduleDirectGridFilterRefresh();
    }
  },
  methods: {
    ...mapActions("master-maintenance", [
      "findRecordList",
      "findRecordListByFacilityCdWithSql",
      "findColumnInfo",
      "setMasterRecordList",
      "edit",
      "setCondition",
      "updateRecordList",
      "updateRecordListByFacilityCd",
      "setEditRecord",
      "editRecordBeEmpty",
      "setComparisonRecordModel",
      "getDeviceEdgeNoList",
      "mstSyncDeviceEdge"
    ]),
    // 共通ローダー設定
    ...mapActions("loading-screen", {
      setLoadingScreenVisible: "setLoadingScreenVisible",
      setLoadingScreenMessage: "setLoadingScreenMessage",
      resetLoadingScreenVisibleCount:  "resetLoadingScreenVisibleCount"
    }),
    ...mapActions("mst-status-map-bed-layout", {
      setScrollPositions: "setScrollPositions"
    }),
    getCurrentRouteName() {
      return this.$router?.currentRoute?.value?.name || this.$router?.currentRoute?.name || this.$route?.name || "";
    },
    goSpecifiedView(routeName) {
      this.$router.push({ name: routeName });
    },
    validateBeforeGridAction() {
      return this.kendoValidator?.validate?.() !== false;
    },
    validateDirectKendoGrid() {
      return true;
    },
    getMaxSortRank() {
      const data = this.getFilteredMasterRecordList?.data || [];
      return data.length ? data.reduce((max, row) => Math.max(max, +row.sortRank || 0), 0) : 0;
    },
    getGridRootEl() {
      return this.$refs.gridRoot || null;
    },
    getDirectGridScrollContent() {
      return this.getGridRootEl()?.querySelector?.(".k-grid-content") || null;
    },
    getDirectGridLockedScrollContent() {
      return this.getGridRootEl()?.querySelector?.(".k-grid-content-locked") || null;
    },
    getGridWidget() {
      return this.directGridWidget || null;
    },
    getGridScrollContainer() {
      return this.getDirectGridScrollContent();
    },
    getGridContentEl() {
      return this.getDirectGridScrollContent();
    },
    getGridLockedContentEl() {
      return this.getDirectGridLockedScrollContent();
    },
    getGridLockedHeaderEl() {
      return this.getGridRootEl()?.querySelector?.(".k-grid-header-locked") || null;
    },
    getGridHeaderEl() {
      return this.getGridRootEl()?.querySelector?.(".k-grid-header") || null;
    },
    getGridHeaderWrapEl() {
      return this.getGridRootEl()?.querySelector?.(".k-grid-header-wrap") || null;
    },
    getGridTableEl() {
      return this.directGridWidget?.table?.[0] || this.getGridRootEl()?.querySelector?.(".k-grid-content table") || null;
    },
    getGridBodyRows() {
      return Array.from(this.getGridRootEl()?.querySelectorAll?.(".k-grid-content tbody tr") || []);
    },
    getGridLockedBodyRows() {
      return Array.from(this.getGridRootEl()?.querySelectorAll?.(".k-grid-content-locked tbody tr") || []);
    },
    getGridDataSource() {
      return this.directGridWidget?.dataSource || null;
    },
    getGridFirstVisibleColumn() {
      return this.directGridWidget?.columns?.find?.(column => !column.hidden);
    },
    resizeGridColumn(column, width) {
      this.directGridWidget?.resizeColumn?.(column, width);
    },
    getGridScrollPosition() {
      const content = this.getDirectGridScrollContent();
      return { top: content?.scrollTop || 0, left: content?.scrollLeft || 0 };
    },
    setGridScrollPosition(position = {}) {
      const content = this.getDirectGridScrollContent();
      if (!content) {
        return;
      }
      const top = position.top || 0;
      const left = position.left || 0;
      content.scrollTop = top;
      content.scrollLeft = left;
      const headerWrap = this.getGridHeaderWrapEl();
      if (headerWrap) {
        headerWrap.scrollLeft = left;
      }
      if (typeof this.directGridWidget?._scrollLeft !== "undefined") {
        this.directGridWidget._scrollLeft = left;
      }
      this.syncDirectGridLockedScrollPosition(top);
      this.dispatchDirectGridContentScroll();
    },
    resizeDirectGrid() {
      const grid = this.directGridWidget;
      if (!grid) {
        return;
      }
      try {
        const height = Number(this.kendoGridHeight) || 0;
        const root = this.getGridRootEl?.();
        if (height > 0) {
          root?.style && (root.style.height = `${height}px`);
          root?.style && (root.style.maxHeight = `${height}px`);
          root?.style && (root.style.overflow = "hidden");
          grid.wrapper?.height?.(height);
          grid.element?.height?.(height);
        }
        grid.setOptions({ height: this.kendoGridHeight });
        grid.resize(true);
        this.applyDirectGridLockedWidthContract();
        this.applyDirectGridLockedHeightContract();
      } catch (_error) {
        // direct jq では resize 失敗時に追加 rebuild しない。
      }
    },
    getDirectGridDataSourceOption() {
      // Vue2 は <kendo-grid :data-source="masterRecords"> で DataSource option を参照渡ししていた。
      // direct jq でも data/schema/model/validation の参照を保ち、表示行だけを wrapper contract として差し替える。
      const source = this.masterRecords || this.getFilteredMasterRecordList || {};
      return {
        ...source,
        data: Array.isArray(source.data) ? source.data : []
      };
    },
    createDirectGridDataSource() {
      const option = this.getDirectGridDataSourceOption();
      this.directGridDataSource = markRaw(new kendo.data.DataSource(option));
      return this.directGridDataSource;
    },
    buildDirectGridColumns() {
      return (this.columns || []).map(column => {
        const gridColumn = { ...column };
        if (column.field === "$modalType") {
          gridColumn.attributes = { class: "btn3-kendo-normal" };
          gridColumn.command = { text: "詳細", click: event => this.showMasterEditModal(event) };
          delete gridColumn.values;
        } else if (column.dataType === "date") {
          gridColumn.editor = (container, options) => this.eachModelCalendar(container, options);
        } else if (column.dataType === "color") {
          gridColumn.template = column.colorTemplate;
          gridColumn.editor = (container, options) => this.colorEditor(container, options);
        }
        return gridColumn;
      });
    },
    initDirectGridIfReady() {
      const root = this.getGridRootEl();
      if (!this.directGridMounted || !root || this.columns.length <= 1) {
        return;
      }
      if (this.directGridWidget) {
        this.applyDirectGridColumnsContract();
        this.scheduleDirectGridFilterRefresh();
        this.scheduleDirectGridLayoutContract();
        return;
      }
      installComponentJQuery();
      $(root).empty();
      $(root).kendoGrid({
        dataSource: this.createDirectGridDataSource(),
        editable: true,
        selectable: true,
        reorderable: false,
        height: this.kendoGridHeight,
        scrollable: true,
        beforeEdit: event => this.editStart(event),
        edit: event => this.addInputAssist(event),
        cellClose: event => this.editEnd(event),
        save: event => this.onDirectGridSave(event),
        dataBound: event => this.onDirectGridDataBound(event),
        columns: this.buildDirectGridColumns()
      });
      this.directGridWidget = markRaw($(root).data("kendoGrid"));
      this.applyDirectGridStyleContract();
      this.scheduleDirectGridLayoutContract();
    },
    destroyDirectGrid() {
      if (this.directGridWidget) {
        try {
          this.directGridWidget.destroy();
        } catch (_error) {
          // noop
        }
      }
      const root = this.getGridRootEl();
      if (root) {
        $(root).empty();
      }
      this.directGridWidget = null;
    },
    applyDirectGridColumnsContract() {
      const grid = this.directGridWidget;
      if (!grid) {
        return;
      }
      const currentFields = (grid.columns || []).map(column => column.field).join("|");
      const nextFields = (this.columns || []).map(column => column.field).join("|");
      if (currentFields !== nextFields) {
        grid.setOptions({ columns: this.buildDirectGridColumns() });
      } else {
        this.syncDirectGridColumnStateToWidget();
      }
      this.applyDirectGridStyleContract();
    },
    syncDirectGridColumnStateToWidget() {
      const grid = this.directGridWidget;
      if (!grid || !Array.isArray(grid.columns)) {
        return;
      }
      (this.columns || []).forEach(column => {
        const gridColumn = grid.columns.find(item => item.field === column.field);
        if (!gridColumn) {
          return;
        }
        gridColumn.editable = column.editable;
        gridColumn.hidden = !!column.hidden;
        gridColumn.values = column.values;
        gridColumn.template = column.colorTemplate || gridColumn.template;
      });
    },
    scheduleDirectGridFilterRefresh() {
      if (!this.directGridWidget?.dataSource) {
        return;
      }
      if (this.directGridFilterRefreshRafId != null) {
        cancelAnimationFrame(this.directGridFilterRefreshRafId);
      }
      this.directGridFilterRefreshRafId = requestAnimationFrame(() => {
        this.directGridFilterRefreshRafId = null;
        this.refreshDirectGridDataFromMasterRecords(true);
      });
    },
    refreshDirectGridDataFromMasterRecords(resetScroll = false) {
      const grid = this.directGridWidget;
      if (!grid?.dataSource) {
        return;
      }
      const option = this.getDirectGridDataSourceOption();
      grid.dataSource.data(option.data || []);
      if (resetScroll) {
        this.setGridScrollPosition({ top: 0, left: 0 });
      }
      this.scheduleDirectGridVisualRefresh();
    },
    scheduleDirectGridVisualRefresh() {
      if (this.editingFlg) {
        return;
      }
      if (this.directGridVisualRefreshRafId != null) {
        cancelAnimationFrame(this.directGridVisualRefreshRafId);
      }
      this.directGridVisualRefreshRafId = requestAnimationFrame(() => {
        this.directGridVisualRefreshRafId = requestAnimationFrame(() => {
          this.directGridVisualRefreshRafId = null;
          this.applyDirectGridStyleContract();
          this.editBackgroundColor();
        });
      });
    },
    gridDataRefresh() {
      this.refreshDirectGridDataFromMasterRecords();
    },
    getDirectGridVisibleLockedWidthPx() {
      const root = this.getGridRootEl();
      const ownerWindow = root?.ownerDocument?.defaultView || window;
      const fontSize = parseFloat(ownerWindow.getComputedStyle?.(root)?.fontSize || "16") || 16;
      return (this.columns || []).reduce((sum, column) => {
        if (!column.locked || column.hidden) {
          return sum;
        }
        const width = `${column.width || ""}`.trim();
        const numeric = parseFloat(width);
        if (!Number.isFinite(numeric)) {
          return sum;
        }
        return sum + (width.endsWith("em") ? numeric * fontSize : numeric);
      }, 0);
    },
    applyDirectGridLockedWidthContract() {
      const root = this.getGridRootEl();
      const lockedWidth = this.getDirectGridVisibleLockedWidthPx();
      if (!root || !lockedWidth) {
        return;
      }
      const px = `${Math.ceil(lockedWidth)}px`;
      root.querySelectorAll(".k-grid-header-locked,.k-grid-content-locked").forEach(element => {
        element.style.width = px;
        element.style.minWidth = px;
      });
      root.querySelectorAll(".k-grid-header-locked table,.k-grid-content-locked table").forEach(element => {
        element.style.width = px;
        element.style.minWidth = px;
      });
    },
    applyDirectGridLockedHeightContract() {
      const content = this.getDirectGridScrollContent();
      const lockedContent = this.getDirectGridLockedScrollContent();
      if (!content || !lockedContent) {
        return;
      }
      const height = content.clientHeight;
      lockedContent.style.height = `${height}px`;
      lockedContent.style.maxHeight = `${height}px`;
    },
    applyDirectGridStyleContract() {
      const root = this.getGridRootEl();
      if (!root) {
        return;
      }
      root.classList.add("ntss-kendo-grid-legacy", "k-widget", "k-grid", "k-editable", "k-display-block");
      root.querySelectorAll("th").forEach(th => th.classList.add("k-header"));
      root.querySelectorAll(".k-grid-content tr, .k-grid-content-locked tr").forEach((tr, index) => {
        tr.classList.add("k-master-row");
        if (index % 2 === 1) {
          tr.classList.add("k-alt");
        }
      });
      root.querySelectorAll("td").forEach(td => td.classList.add("k-td", "k-table-td"));
      this.applyDirectGridLockedWidthContract();
      this.applyDirectGridLockedHeightContract();
      this.syncDirectGridLockedScrollPosition();
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
          this.dispatchDirectGridContentScroll();
        });
      });
    },
    syncDirectGridLockedScrollPosition(scrollTop = null) {
      const lockedContent = this.getDirectGridLockedScrollContent();
      if (!lockedContent) {
        return;
      }
      const content = this.getDirectGridScrollContent();
      lockedContent.scrollTop = scrollTop !== null && scrollTop !== undefined ? scrollTop : (content?.scrollTop || 0);
    },
    dispatchDirectGridContentScroll() {
      const content = this.getDirectGridScrollContent();
      if (!content) {
        return;
      }
      try {
        content.dispatchEvent(new Event("scroll", { bubbles: true }));
      } catch (_error) {
        // noop
      }
      try {
        $(content).trigger("scroll");
      } catch (_error) {
        // noop
      }
    },
    onDirectGridDataBound(event) {
      this.applyDirectGridStyleContract();
      this.onDataBoundKendoGrid(event);
      this.editBackgroundColor();
    },
    onDirectGridSave(event) {
      const model = event?.model;
      if (!model) {
        return;
      }
      const changedFields = new Set();
      Object.keys(event.values || {}).forEach(field => {
        const oldValue = model[field];
        const newValue = event.values[field];
        const changed = String(oldValue ?? "") !== String(newValue ?? "");
        if (typeof model.set === "function") {
          model.set(field, newValue);
        } else {
          model[field] = newValue;
        }
        if (changed) {
          changedFields.add(field);
        }
      });
      const savedFields = Object.keys(event.values || {});
      if (savedFields.includes("sortRank") || model?.dirtyFields?.sortRank === true) {
        this.markDirectSortChangedRecord(model);
        if (!model.dirtyFields) {
          model.dirtyFields = {};
        }
        model.dirtyFields.sortRank = true;
      }
      const position = this.getGridScrollPosition();
      this.getScrollPosition.top = position.top;
      this.getScrollPosition.left = position.left;
      this.editingFlg = false;
      this.edit({ editRecord: model, isSortMode: this.isSortMode });
      if (model.operation === 1 && this.hasDirectNonSortDirtyChange(model)) {
        model.edited = true;
      }
      this.scheduleDirectGridCurrentRowVisual(model);
    },
    scheduleDirectGridCurrentRowVisual(record) {
      const uid = record?.uid;
      if (!uid) {
        return;
      }
      const oldId = this.directGridRowVisualRafIds.get(uid);
      if (oldId != null) {
        cancelAnimationFrame(oldId);
      }
      const rafId = requestAnimationFrame(() => {
        this.directGridRowVisualRafIds.delete(uid);
        this.applyDirectGridRowVisual(record);
      });
      this.directGridRowVisualRafIds.set(uid, rafId);
    },
    applyDirectGridRowVisual(record) {
      this.applyDirectGridRowVisualByRecord(record);
    },
    setDirectGridColumnHidden(fieldName, hidden) {
      const grid = this.directGridWidget;
      if (!grid) {
        return;
      }
      try {
        hidden ? grid.hideColumn(fieldName) : grid.showColumn(fieldName);
        this.scheduleDirectGridVisualRefresh();
      } catch (_error) {
        // noop
      }
    },
    getDirectRecordCode(record) {
      const code = record?.code;
      return code === undefined || code === null ? null : String(code);
    },
    markDirectSortChangedRecord(record) {
      const code = this.getDirectRecordCode(record);
      if (code) {
        this.directSortChangedCodeSet.add(code);
      }
    },
    clearDirectSortChangedRecord(record) {
      const code = this.getDirectRecordCode(record);
      if (code) {
        this.directSortChangedCodeSet.delete(code);
      }
    },
    captureDirectSortDirtyRows() {
      const rows = this.directGridWidget?.dataSource?.data?.();
      const list = Array.from(rows || []);
      list.forEach(row => {
        // Only the user's direct sortRank edits are kept as sort visual targets.
        // Rows changed later by automatic re-numbering are intentionally ignored.
        if (row?.dirtyFields?.sortRank === true) {
          this.markDirectSortChangedRecord(row);
        }
      });
    },
    markDirectSortChangedRows() {
      // Vue2 では「反映」による自動採番分は visual dirty にはしない。
      // yellow visual はユーザーが直接 sortRank を編集した行だけに限定する。
    },
    getDirectOriginalRecordByCode(code) {
      if (code === null || code === undefined) {
        return null;
      }
      try {
        const raw = this.$store?.getters?.["master-maintenance/getComparisonRecordModel"] || "[]";
        const list = typeof raw === "string" ? JSON.parse(raw || "[]") : raw;
        return (Array.isArray(list) ? list : []).find(item => String(item.code) === String(code)) || null;
      } catch (_error) {
        return null;
      }
    },
    isDirectUserSortChanged(record) {
      const code = this.getDirectRecordCode(record);
      return !!(code && this.directSortChangedCodeSet.has(code));
    },
    isDirectSortOnlyField(field) {
      return ["sortRank", "sortInputTime", "dummy"].includes(field);
    },
    hasDirectNonSortChangedFromOriginal(record) {
      const code = this.getDirectRecordCode(record);
      const original = this.getDirectOriginalRecordByCode(code);
      if (!record || !original) {
        return false;
      }
      return (this.columns || [])
        .map(column => column.field)
        .filter(field => field && !this.isDirectSortOnlyField(field))
        .some(field => String(original?.[field] ?? "") !== String(record?.[field] ?? ""));
    },
    hasDirectNonSortDirtyChange(record) {
      const dirtyFields = record?.dirtyFields || {};
      const dirtyFieldNames = Object.keys(dirtyFields).filter(field => dirtyFields[field]);
      if (dirtyFieldNames.length > 0) {
        return dirtyFieldNames.some(field => !this.isDirectSortOnlyField(field));
      }
      if (this.hasDirectNonSortChangedFromOriginal(record)) {
        return true;
      }
      return record?.operation === 2 || (record?.operation === 1 && !!record?.edited);
    },
    shouldApplyDirectEditedRowVisual(record) {
      if (!record) {
        return false;
      }
      // Vue2 wrapper: direct sortRank edit also makes the row edited (green).
      // Automatic re-numbering in sortBtnClick() must not add edited visual.
      return this.isDirectUserSortChanged(record)
        || this.isEdited(record.code)
        || this.hasDirectNonSortDirtyChange(record);
    },
    syncDirectGridSortValuesToMasterRecords() {
      const ds = this.directGridWidget?.dataSource?.data?.();
      if (!ds || !Array.isArray(this.getMasterRecordList?.data)) {
        return;
      }
      const rows = typeof ds.toJSON === "function" ? ds.toJSON() : Array.from(ds);
      rows.forEach(row => {
        const record = this.getMasterRecordList.data.find(item => String(item.code) === String(row.code));
        if (record && row.sortRank !== undefined) {
          record.sortRank = row.sortRank;
          if (row.sortInputTime !== undefined) {
            record.sortInputTime = row.sortInputTime;
          }
        }
      });
    },
    sort() {
      const list = this.getMasterRecordList?.data;
      if (!Array.isArray(list)) {
        return;
      }
      list.sort((a, b) => a.sortRank - b.sortRank || a.sortInputTime - b.sortInputTime);
      let rank = 1;
      list.forEach(row => {
        if (row.isDisp === "1") {
          row.sortRank = rank++;
        }
      });
    },
    sortChange(tempData) {
      let flag = false;
      (this.getMasterRecordList?.data || []).forEach(item => {
        tempData.forEach(tempItem => {
          if (item.code === tempItem.code && item.sortRank !== tempItem.sortRank) {
            flag = true;
          }
        });
      });
      return flag;
    },
    toRankEditBtnClick() {
      if (!this.validateBeforeGridAction()) {
        return;
      }
      this.isSortMode = true;
      this.disableColumns();
      this.showSortColumn();
      this.scheduleDirectGridVisualRefresh();
    },
    sortBtnClick() {
      try {
        this.directGridWidget?.closeCell?.();
      } catch (_error) {
        // noop
      }
      this.captureDirectSortDirtyRows();
      this.syncDirectGridSortValuesToMasterRecords();
      const tempData = clonePlain(this.getMasterRecordList?.data || []);
      this.isSortMode = false;
      this.editableColumns();
      this.showSortColumn();
      this.sort();
      this.isSorted = this.sortChange(tempData);
      this.refreshDirectGridDataFromMasterRecords();
      this.scheduleDirectGridVisualRefresh();
    },
    saveRecord() {
      this.setLoadingScreenVisible(true);
      try {
        this.directGridWidget?.closeCell?.();
      } catch (_error) {
        // noop
      }
      this.syncDirectGridSortValuesToMasterRecords();
      if (!this.validateBeforeGridAction()) {
        this.setLoadingScreenVisible(false);
        return;
      }
      const records = this.getMasterRecordList;
      records.data = records.data.filter(r => !(r.operation === 1 && !r.edited));
      this.setMasterRecordList(records);
      const validateMessage = this.validateRequired();
      const validateComboMessage = this.validateComboValue();
      let message = "";
      if (validateMessage.length !== 0) {
        message = messageFormat(DIALOG_MESSAGES[12000270].message) + validateMessage;
      }
      if (validateComboMessage.length !== 0) {
        if (message.length !== 0) message = message + "</br>";
        message = message + messageFormat(DIALOG_MESSAGES[12000006].message) + validateComboMessage;
      }
      if (message.length !== 0) {
        this.setLoadingScreenVisible(false);
        this.$ons.notification.alert({
          title: DIALOG_MESSAGES[12000006].title,
          message: '<div style="text-align:left;">' + message + "</div>"
        });
        return;
      }
      this.updateRecordListByFacilityCd({ facilityCd: this.getFacilitySwitch, request: this.getUpdateRecordList })
        .then(response => {
          this.updateResponse = response.data;
          this.setLoadingScreenVisible(false);
          this.$ons.notification.alert({
            title: DIALOG_MESSAGES[12000004].title,
            message: messageFormat(DIALOG_MESSAGES[12000004].message)
          });
          this.isSorted = false;
          this.findList();
        })
        .catch(error => {
          getErrorMessage('MstStatusMapBedLayoutMainComponent.vue', 'saveRecord', error);
          if (error.response?.status === 400) {
            this.setLoadingScreenVisible(false);
            this.$ons.notification.alert({
              title: DIALOG_MESSAGES["00300005"].title,
              message: error.response.data.errorMessage
            });
          }
        });
    },
    // Windowの高さからGirdコンポーネント領域の高さを算出
    calculateGridHeight() {
      if (this.editingFlg) {
        return;
      }
      const ownerDocument = getScopedDocument(this.$el);
      const ownerWindow = ownerDocument.defaultView || window;
      const wh = this.windowHeight || ownerWindow.innerHeight || 0;
      const headerElements = ownerDocument.getElementsByClassName("header");
      const hh = headerElements.length ? headerElements[headerElements.length - 1].clientHeight : 0;
      const footerMenu = getScopedElementById("footer-menu", this.$el) || ownerDocument.getElementById?.("footer-menu");
      const fmh = (this.isDispMenu === 1 && footerMenu ? footerMenu.clientHeight : 0) + 5;
      let toolbarHeight = wh - hh - fmh - 10;

      const toolbarElement = this.$el?.querySelector?.(".kendo-grid-toolbar-style");
      const listElement = this.$el?.querySelector?.(".ntss-list");
      const layoutTop = (toolbarElement || listElement)?.getBoundingClientRect?.().top;
      const footerTop = this.isDispMenu === 1
        ? footerMenu?.getBoundingClientRect?.().top
        : ownerWindow.innerHeight;
      const actualAvailableHeight = (Number.isFinite(layoutTop) && Number.isFinite(footerTop))
        ? footerTop - layoutTop - 5
        : NaN;
      if (Number.isFinite(actualAvailableHeight) && actualAvailableHeight > 100) {
        toolbarHeight = Math.min(toolbarHeight, actualAvailableHeight);
      }
      this.kendoGridToolbarHeight = toolbarHeight > 100 ? toolbarHeight : 100;

      const gridFooter = getScopedElementById("grid-footer", this.$el) || ownerDocument.getElementById?.("grid-footer");
      const footerHeight = gridFooter ? (gridFooter.offsetHeight || gridFooter.clientHeight || 0) : 0;
      const headerArea = this.$el?.querySelector?.("#grid-header") || this.$el?.querySelector?.(".header-btn-area");
      const headerHeight = headerArea ? (headerArea.offsetHeight || headerArea.clientHeight || 0) : 0;
      this.kendoGridHeight = Math.max(140, this.kendoGridToolbarHeight - footerHeight - headerHeight);
      const gridRoot = this.getGridRootEl();
      if (gridRoot && Number.isFinite(this.kendoGridHeight)) {
        gridRoot.style.height = `${this.kendoGridHeight}px`;
        gridRoot.style.maxHeight = `${this.kendoGridHeight}px`;
        gridRoot.style.overflow = "hidden";
      }
      if (this.$el) {
        this.$el.style.overflowY = "hidden";
        this.$el.style.overflowX = "hidden";
      }
      if (listElement) {
        listElement.style.position = "relative";
        listElement.style.height = `${this.kendoGridToolbarHeight}px`;
        listElement.style.maxHeight = `${this.kendoGridToolbarHeight}px`;
        listElement.style.overflow = "hidden";
      }
    },
    calculateGridWidth() {
      this.resizeDirectGrid();
    },
    calculateColumnsdWidth() {
      const ownerDocument = getScopedDocument(this.$el);
      const ownerWindow = ownerDocument.defaultView || window;
      const appRoot = getScopedElementById("app", this.$el) || ownerDocument.getElementById?.("app");
      const appWidth = parseFloat(
        ownerWindow
          .getComputedStyle(appRoot || ownerDocument.documentElement, null)
          .getPropertyValue("width")) || 0;
      this.columnWidth = appWidth > 1000 ? 14 : 9;
    },
    editStart(e) {
      if (this.isMobileDevice && !this.allowEdit) {
        /* NOTE:
         * モバイル系は、スワイプ・フリック操作で入力パッドが表示される。
         * そのため、スクロール操作が損なわれるので、閲覧モードのときは
         * 後続のイベントを発火させないように制御する。
         */
        e.preventDefault();
        return;
      }
      if (this.androidFlg) {
        this.editingFlg = true;
      }
    },
    addInputAssist(event = {}) {
      // iOS/PWA環境でスピナーをタップすると編集が終了してしまう現象の対策
      if (this.iosFlg) {
        const numericTextboxes = queryScopedSelectorAll('.k-numerictextbox', this.$el);
        const spinnerObj = numericTextboxes[0]?.querySelector?.('.k-select') || queryScopedSelector('.k-select', this.$el);
        if (spinnerObj) {
          // 編集が終了するとオブジェクトが削除される為、removeEvent処理は不要
          spinnerObj.ontouchend = function (event){ event.stopPropagation(); };
        }
      }
      // Vue2 wrapper ではセルに入っただけでは dirty visual は付かない。
      // sortRank の yellow visual は save / 反映後の実変更に限定する。
    },
    editEnd() {
      this.editingFlg = false;
    },
    eachModelCalendar(container, data) {
      if (this.androidFlg === true) {
        // Androidの場合は、HTML5のカレンダーを表示
        $(`<input type="date" name="${data.field}" />`).appendTo(container);
      } else {
        // デスクトップ、iOSの場合は、処理で補正したHTML5のカレンダーを表示
        const nowData = new Date(data.model[data.field]);
        const nowDtatString = nowData.getFullYear() + "-" + ('0' + (nowData.getMonth()+1)).slice(-2) + "-" + ('0' + nowData.getDate()).slice(-2);
        $(
          `<input type="date" id="displayedDummyEditor" min="1880-01-01" max="2099-12-31" value="${nowDtatString}"/><input type="date" id="hiddenDateInputEditor" name="${data.field}" style="display: none;"/>`).appendTo(container);
        const editorRoot = container?.[0] || container?.get?.(0) || null;
        const editorDocument = editorRoot?.ownerDocument || this.$el?.ownerDocument || document;
        const displayedDummyEditor = editorRoot?.querySelector?.('#displayedDummyEditor') || editorDocument.getElementById('displayedDummyEditor');
        const hiddenDateInputEditor = editorRoot?.querySelector?.('#hiddenDateInputEditor') || editorDocument.getElementById('hiddenDateInputEditor');
        // フォーカスアウトで編集データを反映するイベントを発火
        displayedDummyEditor?.addEventListener("blur", function(ev) {
          const dayData = new Date(ev.target.value);
          const resultData = dayData.getFullYear() + "-" + ('0' + (dayData.getMonth()+1)).slice(-2) + "-" + ('0' + dayData.getDate()).slice(-2);
          // 変更前の値と比較し、同じ値の場合は処理しない
          if (nowDtatString != resultData && hiddenDateInputEditor) {
            hiddenDateInputEditor.value = resultData;
            // name="${data.field}" で割り当てた箇所に付与されているchangeメソッドを発火します。次いで@saveの処理が発生します。
            $(hiddenDateInputEditor).trigger('change');
          }
        });
      }
    },
    colorEditor(container, data) {
      const dummyField = $("<input/>")
        .attr("name", data.field)
        .css("display", "none")
        .appendTo(container);

      const colorPicker = $("<input/>")
        .appendTo(container)
        .kendoColorPicker({
          value: data.model[data.field],
          palette: "basic",
          tileSize: {
            width: 32,
            height: 24
          },
          change: (e) => {
            this.$nextTick(() => {
              dummyField.val(e.value).trigger("change");
            });
          }
        });

      colorPicker.data("kendoColorPicker").open();
    },
    // マスタ一覧のデータを取得
    findList() {
      // apiをコールして値を取得
      // add マスタ一覧 1･施設切替を可能とする 王
      // this.findRecordList()
      this.findRecordListByFacilityCdWithSql(this.getFacilitySwitch)
        .then(response => {
          // カラム情報のJSONが未定義の場合には、ダイアログを出して画面を閉じる
          if (response.data.columns.length === 0) {
            this.$ons.notification.alert({
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // title: "取得失敗",
              // message:
              //   "マスタ定義にカラム情報が登録されていません。<BR>カラム情報を登録してください。",
              title: DIALOG_MESSAGES[12000001].title,
              message: messageFormat(DIALOG_MESSAGES[12000001].message),
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
              callback: () => {
                this.cancel();
              }
            });
          }

          // editableをKendoUI用にfunctionオブジェクトに変換
          const toFunction = response.data.columns;
          toFunction.forEach(column => {
            // 初期表示時の編集可否を退避
            column.originalEditable = column.editable;
            // 編集可否を関数化
            column.editable = column.editable ? () => true : () => false;
            // 列幅初期化
            column["width"] = column.width ? column.width : "0";
          });
          this.columns = toFunction;

          // 横スクロールバーを表示するために列幅を指定
          this.columns.forEach(column => {
            // 「削除」のプルダウンが改行しない幅に調整
            // mod #7289-マスタの削除ボタンが縦表示になる 徐博 start
            // column.width = column.field === "isDisp" ? "8em" : (this.columnWidth + "em");
            column.width = column.field === "isDisp" ? "9em" : (this.columnWidth + "em");
            // mod #7289-マスタの削除ボタンが縦表示になる 徐博 end
            // #9185 最小フォント、mst画面編集文字、テキストボックス幅を超えます linjunfeng start
            // #8612 ウィンドウサイズの変更で、マスタレイアウトが崩れる。林峻峰 start
            // if (column.locked && column.dataType === "string" && column.field === "name") {
            //   column.width = typeof column.width == 'string' ? Number(column.width.slice(0,-2)) * 15 : column.width * 15
            // }
            // #8612 ウィンドウサイズの変更で、マスタレイアウトが崩れる。林峻峰 end
            // #9185 最小フォント、mst画面編集文字、テキストボックス幅を超えます linjunfeng end
          });

          // 先頭列ダミー要素追加（並び順列の変更内容が"かぶって"表示されてしまう事象の対応のため）
          this.columns.unshift({
            title: " ",
            field: "dummy",
            hidden: false,
            // del #11001 並び順の変更後反映を押しても並び順が切り替わらない。 zhangyue start 
            // locked: true,
            // del #11001 並び順の変更後反映を押しても並び順が切り替わらない。 zhangyue end 
            editable: () => false,
            width: "10px",
            format: "",
            values: null
          });
          // カラム幅等初期調整
          this.showSortColumn();
          this.$nextTick(() => {
            this.calculateGridHeight();
            this.calculateGridWidth();
            // 元のスクロール位置に移動
            // mod スクロールの位置を維持
            this.setGridScrollPosition({ top: this.scrollTop, left: this.scrollLeft });
            
            setTimeout(() => {
              this.scrollTop = 0;
              this.scrollLeft = 0;
            }, 1000);
            // mod スクロールの位置を維持
          });
          // 初期データ内容を保存
          this.setComparisonRecordModel();
          // 色カラムのテンプレート生成
          this.columns.filter(column => column.dataType === "color")
            .forEach(column => {
              column.colorTemplate = (dataItem) => {
                const value = dataItem[`${column.field}`];
                return `<div style='background-color: ${value}; width: 4em;'>&nbsp;</div>`;
              }
            });
        })
        .catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
          getErrorMessage('MstStatusMapBedLayoutMainComponent.vue', 'findList', '指定されたマスタが見つかりません。');
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
          if (error.response.status === 400) {
            this.$ons.notification.alert({
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // title: "取得失敗",
              // message: "指定されたマスタが見つかりません。"
              title: DIALOG_MESSAGES[12000003].title,
              message: messageFormat(DIALOG_MESSAGES[12000003].message),
            });
          }
        });
      // カラム定義情報を取得
      this.findColumnInfo();
    },
    setFilterCondition(condition) {
      this.condition.recordName = condition.recordName;
      this.condition.includeDeleted = condition.includeDeleted;
    },
    async saveRecord() {
      // 共通ローダー:表示開始
      this.setLoadingScreenVisible(true);
      //イベント発生前のスクロールバーの位置を保持
      const grid = this.getGridScrollContainer();
      this.getScrollPosition.top = grid.scrollTop;
      this.getScrollPosition.left = grid.scrollLeft;
      this.editFlg = true;
      // グリッドでエラーが発生している場合は処理を中断
      if (!this.validateBeforeGridAction()) {
        // 共通ローダー：表示終了
        this.setLoadingScreenVisible(false);
        return;
      }

      // 新規追加＆未入力のレコードを除外
      const records = this.getMasterRecordList;
      records.data = records.data.filter(
        r => !(r.operation === 1 && !r.edited)
      );
      this.setMasterRecordList(records);

      // 必須エラーをチェック
      const validateMessage = this.validateRequired();
      // コンボで削除済みのレコードが指定されていないかをチェック
      const validateComboMessage = this.validateComboValue();

      let message = "";
      if (validateMessage.length !== 0) {
        // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
        // message = "以下の列に未入力項目が存在します。" + validateMessage;
        message =  messageFormat(DIALOG_MESSAGES[12000005].message) + validateMessage;
        // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
      }
      if (validateComboMessage.length !== 0) {
        if (message.length !== 0) message = message + "</br>";
        message =
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
          // message + "以下の列の選択を見直してください。" + validateComboMessage;
          message + messageFormat(DIALOG_MESSAGES[12000006].message) + validateComboMessage;
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
      }
      // エラーメッセージは左寄せで表示
      if (message.length !== 0) {
        //共通ローダー：表示終了
        this.setLoadingScreenVisible(false);
        this.$ons.notification.alert({
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
          // title: "チェックエラー",
          title: DIALOG_MESSAGES[12000005].title,
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
          message: '<div style="text-align:left;">' + message + "</div>"
        });
        return;
      }

      // apiをコールして値を保存
      // add マスタ一覧 1･施設切替を可能とする 王
      // this.updateRecordList(this.getUpdateRecordList)
      this.updateRecordListByFacilityCd({facilityCd: this.getFacilitySwitch, request: this.getUpdateRecordList})
        .then(response => {
          this.updateResponse = response.data;

          this.$ons.notification.alert({
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
            // title: "更新完了",
            // message: "マスタ更新が完了しました。"
            title: DIALOG_MESSAGES[12000004].title,
            message: messageFormat(DIALOG_MESSAGES[12000004].message),
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
          });

          this.findList();
        })
        .catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
          getErrorMessage('MstStatusMapBedLayoutMainComponent.vue', 'saveRecord', error);
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
          if (error.response.status === 400) {
            this.$ons.notification.alert({
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // title: "更新失敗",
              title: DIALOG_MESSAGES["00300005"].title,
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
              message: error.response.data.errorMessage
            });
          }
        })
        // 共通ローダー：表示終了
        .finally(() => this.setLoadingScreenVisible(false));
    },
    validateRequired() {
      let validateMessageArr = [];
      const gridData = this.getMasterRecordList;
      // ストアに保存されているデータについて必須項目の未入力をチェックする
      for (let idx = 0; idx < gridData.data.length; idx++) {
        // スキーマ情報の件数分をチェック
        const keys = Object.keys(gridData.schema.model.fields);
        for (let keyCount = 0; keyCount < keys.length; keyCount++) {
          // バリデーションで必須が定義されている項目を対象
          const validation =
            gridData.schema.model.fields[keys[keyCount]].validation;
          if (typeof validation !== "undefined" && validation.required) {
            if (
              gridData.data[idx][keys[keyCount]] !== null &&
              gridData.data[idx][keys[keyCount]] === ""
            ) {
              // カラム名からタイトルを取得
              const columnInfo = this.columns.find(
                e => e.field == keys[keyCount]
              );
              // 項目名が重複していなければ、メッセージに追加
              validateMessageArr.push(columnInfo.title);
            }
          }
        }
      }
      return this.convertToStr(validateMessageArr);
    },
    validateComboValue() {
      // コンボ項目のfieldを取り出す
      const comboFields = this.columns
        .filter(column => column.values != null)
        .map(column => ({
          field: column.field,
          title: column.title,
          values: column.values
        }));

      // 削除されていないレコード
      const gridData = this.getMasterRecordList;
      const rows = gridData.data.filter(row => row.isDisp !== "0");
      // コンボの列を対象に、ストアの値がコンボのvaluesに存在することをチェック
      let validateMessageArr = [];
      for (let rowIdx = 0; rowIdx < rows.length; rowIdx++) {
        for (let comboIdx = 0; comboIdx < comboFields.length; comboIdx++) {
          const columnValue = rows[rowIdx][comboFields[comboIdx].field];
          // valuesにデータ値が存在せず、データ値がNullか空文字でなければエラー
          const index = comboFields[comboIdx].values.findIndex(
            e => e.value == columnValue
          );
          if (index < 0 && (columnValue !== null && columnValue !== "")) {
            validateMessageArr.push(comboFields[comboIdx].title);
          }
        }
      }
      return this.convertToStr(validateMessageArr);
    },
    convertToStr(messageArr) {
      if (messageArr.length === 0) return "";

      const unique = messageArr.reduce((acc, cur) => {
        if (acc.indexOf(cur) === -1) {
          acc.push(cur);
        }
        return acc;
      }, []);

      const prefix = "</br>&nbsp&nbsp・";
      return prefix + unique.join(prefix);
    },
    onSave(ev) {
      this.onDirectGridSave(ev);
    },
    onDataBoundKendoGrid(ev) {
      if (this.getScrollPosition.top > 0 || this.getScrollPosition.left > 0) {
        this.$nextTick(() => {
          this.setGridScrollPosition({ top: this.getScrollPosition.top, left: this.getScrollPosition.left });
        });
      }
      this.applyDirectGridStyleContract();
    },
    cancel() {
      // 前画面に戻る
      // 編集破棄確認はMasterRecordView.vueで行う
      // mod #8183 2022/12/15 治療状況ベッドレイアウトマスタからマスター一覧に戻れない。 dou start
      // this.$router.go(-1);
      this.$router.push({ name: "master-maintenance" });
      // mod #8183 2022/12/15 治療状況ベッドレイアウトマスタからマスター一覧に戻れない。 dou end
    },
    showMasterEditModal(e) {
      // モーダル確定時にスクロール位置が戻ってしまう問題の対処
      const grid = this.getGridScrollContainer();
      this.getScrollPosition.top = grid.scrollTop;
      this.getScrollPosition.left = grid.scrollLeft;
      this.setScrollPositions(this.getScrollPosition);

      /**
       * 「詳細」ボタンを押下したレコードのデータを取得する。
       * see: https://www.telerik.com/forums/selected-row-at-wrappers-for-vue
       */
      e.preventDefault();
      const row = this.getGridWidget();
      const selectedRowItem = row?.dataItem?.(e.currentTarget.closest("tr"));
      let code = selectedRowItem.code;

      // codeがない場合はcodeを付番
      if (!code) {
        this.edit({ editRecord: selectedRowItem, isSortMode: this.isSortMode });
      }

      // プロパティを正規化する。
      let normalizedItem = this.normalization(selectedRowItem);
      normalizedItem["scrollPosition"] = this.scrollPosition;
      // ストアに保存する。
      this.setEditRecord(normalizedItem);

      // 詳細を表示
      this.goSpecifiedView("individual-master-ex-map-bed-layout");
    },
    onCloseMasterEditModal() {
      this.$nextTick(() => {
        this.setScrollPosition(this.scrollPosition);
      });
      // Androidでスクロール位置が戻らない場合があるのでもう一度設定
      setTimeout(() => {
        this.setScrollPosition(this.scrollPosition);
      }, 1000);
    },
    setScrollPosition(position) {
      this.setGridScrollPosition({ top: position.top, left: position.left });
    },
    addRow() {
      // グリッドでエラーが発生している場合は処理を中断
      if (!this.validateBeforeGridAction()) {
        return;
      }

      // 空レコードをストアに登録
      let d = new Object();
      const fields = this.getMasterRecordList.schema.model.fields;
      Object.keys(fields).forEach(k => {
        if (fields[k].defaultValue) {
          d[k] = fields[k].defaultValue;
        } else if (fields[k].type === "string") {
          d[k] = "";
        } else if (fields[k].type === "number") {
          d[k] = 0;
        } else if (fields[k].type === "date") {
          d[k] = new Date();
        } else if (fields[k].type === "color") {
          d[k] = "#000000";
        } else {
          d[k] = null;
        }
        if (k === "sortRank") {
          d[k] = this.getMaxSortRank() + 1;
        }
      });
      // this.edit({ editRecord: d, isSortMode: this.isSortMode });
      // this.editBackgroundColor();

      // プロパティを正規化する。
      const normalizedItem = this.normalization(d);
      const scrollContent = this.getDirectGridScrollContent();
      this.getScrollPosition.top = scrollContent?.scrollHeight || 0;
      this.getScrollPosition.left = 0;
      this.scrollPosition.top = this.getScrollPosition.top;
      this.scrollPosition.left = 0;
      this.setScrollPositions(this.getScrollPosition);
      this.setGridScrollPosition({ top: this.getScrollPosition.top, left: 0 });
      // ストアに保存する。
      this.setEditRecord(normalizedItem);

      // 詳細を表示
      this.goSpecifiedView("individual-master-ex-map-bed-layout");
    },
    importCsv(event) {
      // グリッドでエラーが発生している場合は処理を中断
      if (!this.validateBeforeGridAction()) {
        return;
      }

      this.masterCsvTarget = event?.target || null;
      this.masterCsvVisible = true;
    },
    prehideCsvPopover() {
      this.masterCsvVisible = false;
      this.refreshDirectGridDataFromMasterRecords();
    },
    showSortColumn() {
      // 編集・並び順設定モードによって並び順項目の表示・非表示を切り替える
      // （先頭ダミー要素列と並び順列を交互に表示・非表示する）
      const sortRankIndex = this.columns.findIndex(
        col => col.field === "sortRank"
      );
      if (sortRankIndex >= 0) {
        this.columns[sortRankIndex].hidden = !(
          this.isAllowSort && this.isSortMode
        );
        const dummyIndex = this.columns.findIndex(col => col.field === "dummy");
        if (dummyIndex >= 0) {
          this.columns[dummyIndex].hidden = !this.columns[sortRankIndex].hidden;
        }
      }
      this.setDirectGridColumnHidden?.("sortRank", !!this.columns.find(col => col.field === "sortRank")?.hidden);
      this.setDirectGridColumnHidden?.("dummy", !!this.columns.find(col => col.field === "dummy")?.hidden);
      this.scheduleDirectGridLayoutContract();
      this.scheduleDirectGridVisualRefresh();
    },
    disableColumns() {
      this.columns.forEach(column => {
        // 並び順列を編集可、並び順列以外を編集不可に。
        column.editable =
          column.field == "sortRank"
            ? this.isAllowSort
              ? () => true
              : () => false
            : () => false;
      });
      this.applyDirectGridColumnsContract();
    },
    editableColumns() {
      this.columns.forEach(column => {
        // 編集可否の設定を初期表示時の状態に戻す
        column.editable =
          column.field == "sortRank"
            ? () => false
            : column.originalEditable
              ? () => true
              : () => false;
      });
      this.applyDirectGridColumnsContract();
    },
    getColumnIndex(fieldName) {
      // 指定された項目がない場合はマイナスが返る
      return this.columns.findIndex(e => e.field === fieldName);
    },
    editBackgroundColor() {
      this.$nextTick(() => {
        // グリッドが表示されていなかったら処理終了
        const gridHeader = this.getGridHeaderEl();
        if (!gridHeader || gridHeader.textContent === " ") {
          return;
        }
        gridHeader?.classList?.add("master-grid-header");

        // グリッドにレコードがなければ処理終了
        if (!this.getGridTableEl()?.tBodies) {
          return;
        }
        // 固定列、可変列、データソースの取得
        const tbodyc = this.getGridBodyRows();
        const lockTbodyc = this.getGridLockedBodyRows();
        const grid = this.getGridWidget();

        // 列の行数は固定・可変で同一なため可変列の行数を使用
        for (let rwCount = 0; rwCount < tbodyc.length; rwCount++) {
          const bodyRow = tbodyc[rwCount];
          const uid = bodyRow?.getAttribute?.("data-uid");
          const lockedRow = uid
            ? lockTbodyc.find(row => row?.getAttribute?.("data-uid") === uid)
            : lockTbodyc[rwCount];
          const currentTrc = bodyRow?.children || [];
          const currentLockTrc = lockedRow?.children || [];
          const rowData = grid?.dataItem?.(bodyRow) || grid?.dataItem?.(lockedRow) || null;

          // 並び順の色変更
          // mod #11001 並び順の変更後反映を押しても並び順が切り替わらない。 zhangyue start 
          // this.changeSortColor(currentLockTrc);
          this.changeSortColor(currentLockTrc, currentTrc);
          // mod #11001 並び順の変更後反映を押しても並び順が切り替わらない。 zhangyue end 
          // 編集項目の色を変更
          let edited = this.changeEditColor(currentTrc,currentLockTrc);
          // 削除対象を判定
          const deleted = this.isDeleteRow(currentTrc);

          // モーダルからの編集も色を変更する。
          // ユーザーが直接 sortRank を編集した行は Vue2 と同じく編集行（緑）扱いにする。
          // ただし sortBtnClick() の自動採番だけで変わった行は対象外。
          if (this.shouldApplyDirectEditedRowVisual(rowData)) {
            edited = true;
          }
          // 並び順以外の項目が変更されていた場合は、削除か修正にあわせて並び順より後の項目の背景色を変更
          this.changeRowColor(currentTrc, currentLockTrc, edited, deleted);
          // データ参照エラーコンボの背景色を変更
          // mod #9863 編集時背景色表示異常の横展開 蔡 start
          // this.changeRefErrorComboColor(currentTrc, deleted);
          this.changeRefErrorComboColor(currentTrc, deleted, currentLockTrc);
          // mod #9863 編集時背景色表示異常の横展開 蔡 end
        }
      });
    },
    getDirectGridCellFromEvent(event = {}) {
      const container = event.container;
      if (container?.jquery) {
        return container[0]?.closest?.("td") || container[0] || null;
      }
      if (container?.nodeType === 1) {
        return container.closest?.("td") || container;
      }
      return event.currentTarget?.closest?.("td") || event.target?.closest?.("td") || null;
    },
    getDirectSortColorRowsByRecord(record) {
      const root = this.getGridRootEl();
      if (!root || !record) {
        return [];
      }
      if (record.uid) {
        return Array.from(root.querySelectorAll(`tr[data-uid="${record.uid}"]`));
      }
      if (record.code == null) {
        return [];
      }
      const grid = this.getGridWidget();
      return this.getGridBodyRows().filter(row => grid?.dataItem?.(row)?.code === record.code);
    },
    getDirectSortColorRowsFromRow(row) {
      const uid = row?.getAttribute?.("data-uid");
      const root = this.getGridRootEl();
      return uid && root ? Array.from(root.querySelectorAll(`tr[data-uid="${uid}"]`)) : row ? [row] : [];
    },
    clearDirectGridRowVisual(row) {
      row?.classList?.remove?.("master-edited-row", "master-deleted-row", "master-sort-edited");
      Array.from(row?.children || []).forEach(cell => {
        cell.classList.remove("master-edited-row", "master-deleted-row", "master-edited-cell", "master-sort-edited");
      });
    },
    getDirectSortColorRowPairByRecord(record) {
      const rows = this.getDirectSortColorRowsByRecord(record);
      return {
        lockedRow: rows.find(row => this.isDirectSortColorLockedRow(row)) || null,
        contentRow: rows.find(row => !this.isDirectSortColorLockedRow(row)) || null
      };
    },
    getDirectSortColorRowData(row) {
      return row ? this.getGridWidget()?.dataItem?.(row) || null : null;
    },
    isDirectSortRankEdited(row, sortCell = null) {
      const rowData = this.getDirectSortColorRowData(row);
      return this.isDirectUserSortChanged(rowData);
    },
    applyDirectGridRowVisualByRecord(record) {
      const { lockedRow, contentRow } = this.getDirectSortColorRowPairByRecord(record);
      if (!lockedRow && !contentRow) {
        return;
      }
      [lockedRow, contentRow].forEach(row => this.clearDirectGridRowVisual(row));
      const currentLockTrc = lockedRow?.children || [];
      const currentTrc = contentRow?.children || [];
      this.changeSortColor(currentLockTrc, currentTrc);
      let edited = this.changeEditColor(currentTrc, currentLockTrc);
      const deleted = this.isDeleteRow(currentTrc);
      const rowData = this.getDirectSortColorRowData(contentRow || lockedRow) || record || {};
      if (this.shouldApplyDirectEditedRowVisual(rowData)) {
        edited = true;
      }
      this.changeRowColor(currentTrc, currentLockTrc, edited, deleted);
      this.changeRefErrorComboColor(currentTrc, deleted, currentLockTrc);
    },
    applyDirectSortInputVisual(event = {}) {
      // Vue2 wrapper does not color the sortRank cell simply by entering edit mode.
      // Visual changes are applied only after the value actually changes and save runs.
    },
    // mod #11001 並び順の変更後反映を押しても並び順が切り替わらない。 zhangyue start 
    getDirectSortColorRowFromCells(currentTrc) {
      return Array.from(currentTrc || [])[0]?.parentElement || null;
    },
    isDirectSortColorLockedRow(row) {
      return !!row?.closest?.(".k-grid-content-locked");
    },
    getDirectSortColorVisibleColumnsForRow(row) {
      const locked = this.isDirectSortColorLockedRow(row);
      return (this.columns || []).filter(column => !column.hidden && !!column.locked === locked);
    },
    getDirectSortColorCellByField(row, fieldName) {
      if (!row || !fieldName) {
        return null;
      }
      const index = this.getDirectSortColorVisibleColumnsForRow(row).findIndex(column => column.field === fieldName);
      if (index < 0) {
        return null;
      }
      return Array.from(row.children || [])[index] || null;
    },
    getDirectSortColorFieldByCell(cell) {
      const row = cell?.parentElement;
      const index = cell?.cellIndex ?? -1;
      return this.getDirectSortColorVisibleColumnsForRow(row)[index]?.field || null;
    },
    getDirectSortVisualTargetCell(row) {
      return this.getDirectSortColorCellByField(row, "sortRank")
        || Array.from(row?.children || []).find(cell => {
          const field = this.getDirectSortColorFieldByCell(cell);
          return field && field !== "dummy" && field !== "isDisp";
        })
        || this.getDirectSortColorCellByField(row, "dummy")
        || Array.from(row?.children || [])[0]
        || null;
    },
    changeSortColorByRow(row) {
      const sortCell = this.getDirectSortColorCellByField(row, "sortRank");
      if (!this.isDirectSortRankEdited(row, sortCell)) {
        return false;
      }
      const targetCell = sortCell || this.getDirectSortVisualTargetCell(row);
      targetCell?.classList?.add("master-sort-edited");
      const dummyCell = this.getDirectSortColorCellByField(row, "dummy");
      dummyCell?.classList?.add("master-sort-edited");
      return true;
    },
    changeSortColor(currentTrc, currentLockTrc = null) {
      [currentTrc, currentLockTrc].forEach(cells => {
        this.changeSortColorByRow(this.getDirectSortColorRowFromCells(cells));
      });
    },
    // mod #11001 並び順の変更後反映を押しても並び順が切り替わらない。 zhangyue end 
    changeEditColor(currentTrc,currentLockTrc) {
      let edited = false;
      // 変更されたセルの文字色を変更(固定列と可変列の行数は一致)
      for (let lockClCount = 0; lockClCount < currentLockTrc.length; lockClCount++) {
        // 固定列セル:並び順以外の編集列
        const cell = currentLockTrc[lockClCount];
        const rowData = this.getDirectSortColorRowData(cell?.parentElement);
        const field = this.getDirectSortColorFieldByCell(cell);
        if (this.isEditRow(cell) && (field !== "sortRank" || this.isDirectUserSortChanged(rowData))) {
          cell?.classList?.add("master-edited-cell");
          edited = true;
        }
      }

      for(let clCount = 0; clCount < currentTrc.length; clCount++) {
        // 可変列セル
        const cell = currentTrc[clCount];
        const rowData = this.getDirectSortColorRowData(cell?.parentElement);
        const field = this.getDirectSortColorFieldByCell(cell);
        if (this.isEditRow(cell) && (field !== "sortRank" || this.isDirectUserSortChanged(rowData))) {
          cell?.classList?.add("master-edited-cell");
          edited = true;
        }
      }
      return edited;
    },
    isDeleteRow(currentTrc) {
      let deleted = false;
      // 削除カラムで削除が選択されている場合は削除フラグを設定
      for (let clCount = 0; clCount < currentTrc.length; clCount++) {
        if (
          this.isEditRow(currentTrc[clCount])
        ) {
          if (
            currentTrc[clCount].children[0].nextSibling &&
            currentTrc[clCount].children[0].nextSibling.data === "削除" &&
            this.getColumnIndex("isDisp") === clCount
          ) {
            deleted = true;
          }
        }
      }
      return deleted;
    },
    changeRowColor(currentTrc, currentLockTrc, edited, deleted) {
      // 並び順より後の項目の背景色を変更
      if (edited || deleted) {
        const addClass = deleted ? "master-deleted-row" : "master-edited-row";

        // 固定列（ソート順付）：ソート順後のみ
        for (
          let lockClCount = this.getColumnIndex("sortRank") + 1;
          lockClCount < currentLockTrc.length;
          lockClCount++
        ) {
          currentLockTrc[lockClCount]?.classList?.add(addClass);
        }
        // 可変列：全列対象
        for (
          let clCount  = 0;
          clCount < currentTrc.length;
          clCount++){
          currentTrc[clCount]?.classList?.add(addClass);
        }
      }
    },
    // mod #9863 編集時背景色表示異常の横展開 蔡 start
    // changeRefErrorComboColor(currentTrc, rowDeleted) {
    // currentLockTrc：左gridのリストを取得する
    changeRefErrorComboColor(currentUnLockTrc, rowDeleted, currentLockTrc) {
    // mod #9863 編集時背景色表示異常の横展開 蔡 end
      // 削除行は処理対象外
      if (rowDeleted) {
        return;
      }
      // add #9863 編集時背景色表示異常の横展開 蔡 start
      let currentTrc = [];
      for (let clCount = 0; clCount < currentLockTrc.length; clCount++) {
        currentTrc.push(currentLockTrc[clCount]);
      }
      for (let clCount = 0; clCount < currentUnLockTrc.length; clCount++) {
        currentTrc.push(currentUnLockTrc[clCount]);
      }
      if (currentTrc.length !== this.columns.length) {
        return;
      }
      // add #9863 編集時背景色表示異常の横展開 蔡 end
      // コンボリストが設定されていてデータが存在するが、画面表示上は空の場合は削除済みレコードを参照として背景色を変更
      for (let clCount = 0; clCount < currentTrc.length; clCount++) {
        const columnInfo = this.columns[clCount];
        const hasValueColumn = this.hasValueColumn(
          // mod #9863 編集時背景色表示異常の横展開 蔡 start
          // currentTrc[this.getColumnIndex("code")].textContent,
          currentTrc[this.getColumnIndex('code')].textContent.replaceAll(",", ""),
          // mod #9863 編集時背景色表示異常の横展開 蔡 end
          columnInfo.field
        );
        if (
          columnInfo.values !== null &&
          hasValueColumn &&
          currentTrc[clCount].textContent === ""
        ) {
          currentTrc[clCount]?.classList?.add("master-deleted-combo");
        }
      }
    },
    isEditRow(currentTd) {
      // 編集した行を判定
      return currentTd.classList.contains("k-dirty-cell");
    },
    normalization(items) {
      // columnの定義にあわせてデータを正規化する。
      const columnNames = this.columnDefinition.map(column => column.field);

      return Object.keys(items)
        .filter(key => columnNames.includes(key))
        .reduce((acc, key) => {
          acc[key] = items[key];
          return acc;
        }, {});
    },
    loadGridData(){
      // delete start #9590
        // this.setCondition(this.condition);
        // delete end #9590
      this.findList();
    },
    getIsChanged() {
      const data = this.getMasterRecordList.data;
      return (
        this.getStateUserAccountInfo !== null &&
        data !== undefined &&
        (this.$store.getters["master-maintenance/isRecordModified"] || !this.validateBeforeGridAction())
      );
    },
    // パンくずリストをクリックされた場合に呼び出される関数
    refresh() {
      // 他の画面に遷移したときもrefresh()が発生する為、自分の画面のみ処理する
      const scopedDocument = getScopedDocument(this.$el);
      if (this.selfScreenName === this.getCurrentRouteName()
          && getScopedAlertDialogs(this.$el || this).length === 0) {
        if (this.getIsChanged()) {
          this.$ons.notification.confirm({
              // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
              // title: "内容破棄",
              title: DIALOG_MESSAGES[13000004].title,
              // message: "編集内容が破棄されます。</br>よろしいですか？",
              message: messageFormat(DIALOG_MESSAGES[13000004].message),
              // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
            callback: answer => {
              if (answer === 1) {
                //スクロールバーの位置をクリアする
                this.clearScrollPosition();
                this.loadGridData();
              }
            }
          });
        } else {
          //スクロールバーの位置をクリアする
          this.clearScrollPosition();
          this.loadGridData();
        }
      }
    },
    /**
     * @description スクロールバーの位置をクリアする
    */
    clearScrollPosition() {
      this.getScrollPosition.top = 0;
      this.getScrollPosition.left = 0;
    }
  },
  created() {
    installComponentJQuery();
    this.setLoadingScreenVisible(true);
    this.calculateColumnsdWidth();
    this.loadGridData();
    // 共通ローダー:表示名設定
    this.setLoadingScreenMessage("処理中・・・");
    // 端末判別
    const ua = ((this?.$el?.ownerDocument?.defaultView?.navigator?.userAgent) || globalThis?.navigator?.userAgent || "").toLowerCase();
    if (/android/.test(ua)) {
      this.androidFlg = true;
    } else if (/iphone|ipad|mac|os/.test(ua)) {
      this.iosFlg = true;
    }
    this.selfScreenName = this.getCurrentRouteName();
    EventBus.$on("onCloseMasterEditModal", this.onCloseMasterEditModal);
  },

  mounted() {
    this.directGridMounted = true;
    this.kendoValidator = { validate: () => this.validateDirectKendoGrid() };
    this.$nextTick(() => {
      this.calculateColumnsdWidth();
      this.calculateGridHeight();
      this.calculateGridWidth();
      this.initDirectGridIfReady();
      this.scheduleDirectGridLayoutContract();
    });
    EventBus.$on("refresh", this.refresh);
    EventBus.$on("clearScrollPosition", this.clearScrollPosition);
  },
  // add 性能改善メモリ不足 shan start
  beforeUnmount() {
    EventBus.$off("onCloseMasterEditModal", this.onCloseMasterEditModal);
    EventBus.$off("refresh", this.refresh);
    EventBus.$off("clearScrollPosition", this.clearScrollPosition);
    this.destroyDirectGrid();
    [this.directGridLayoutRafId, this.directGridFilterRefreshRafId, this.directGridScrollSyncRafId, this.directGridVisualRefreshRafId].forEach(id => {
      if (id != null) {
        cancelAnimationFrame(id);
      }
    });
    this.directGridRowVisualRafIds?.forEach?.(id => cancelAnimationFrame(id));
    this.directGridRowVisualRafIds?.clear?.();
    this.directSortChangedCodeSet?.clear?.();
  }
  // add 性能改善メモリ不足 shan end
};
</script>

<!-- 個別スタイル定義 -->
<style scoped>
.right {
  text-align: right;
}
.header-btn-area {
  height: auto;
  padding: 0.1em 0.1em 0.1em 0.1em;
}
#grid-footer {
  margin: 0;
  padding: 5px;
  bottom: 0;
  left: 0;
  right: 0;
  position: absolute;
  width: auto;
  box-sizing: border-box;
  background: inherit;
  z-index: 2;
}
.ntss-list {
  position: relative;
  height: var(--height);
  max-height: var(--height);
  overflow: hidden;
  box-sizing: border-box;
}
.kendo-grid-toolbar-style {
  --height: 200px;
  height: var(--height);
  max-height: var(--height);
  border-bottom: none;
  box-sizing: border-box;
}
.toolbar-btn {
  font-size: 1.0em;
  padding: 0.2em 1em 0em 1em;
  line-height: 2em;
  width: auto;
}
.csv-btn {
  margin-right: 1em;
}
.kendo-grid-toolbar-style {
  padding: 0.1em 0.3em;
}
.kendo-grid-toolbar-style :deep(.k-grid-content-locked) {
  overflow-y: scroll !important;
  -webkit-overflow-scrolling: touch;
  scrollbar-width: none;
  -ms-overflow-style: none;
}
.kendo-grid-toolbar-style :deep(.k-grid-content-locked::-webkit-scrollbar) {
  display: none;
}
.kendo-grid-toolbar-style :deep(.k-tooltip.k-tooltip-validation) {
  width: auto;
}
.custom-switch {
  transform: scale(0.85);
  transform-origin: center;
  touch-action: manipulation;
}
.mst-status-map-bed-layout-direct-jq-grid {
  width: 100%;
}
.mst-status-map-bed-layout-direct-jq-grid :deep(td.master-edited-row),
.mst-status-map-bed-layout-direct-jq-grid :deep(tr.k-selected > td.master-edited-row),
.mst-status-map-bed-layout-direct-jq-grid :deep(tr.k-state-selected > td.master-edited-row) {
  color: #003300 !important;
  background-color: #ccffcc !important;
}
.mst-status-map-bed-layout-direct-jq-grid :deep(td.master-deleted-row),
.mst-status-map-bed-layout-direct-jq-grid :deep(tr.k-selected > td.master-deleted-row),
.mst-status-map-bed-layout-direct-jq-grid :deep(tr.k-state-selected > td.master-deleted-row) {
  color: #333333 !important;
  background-color: #9d9d9d !important;
}
.mst-status-map-bed-layout-direct-jq-grid :deep(td.master-edited-cell) {
  color: #003300 !important;
  font-weight: bold !important;
}
.mst-status-map-bed-layout-direct-jq-grid :deep(td.master-sort-edited),
.mst-status-map-bed-layout-direct-jq-grid :deep(tr.k-selected > td.master-sort-edited),
.mst-status-map-bed-layout-direct-jq-grid :deep(tr.k-state-selected > td.master-sort-edited) {
  background-color: #ffff66 !important;
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
