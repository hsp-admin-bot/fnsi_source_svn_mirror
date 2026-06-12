<template>
  <div class="main-content-area master-maintenance-page">
    <div
      class="ntss-list"
      :style="ntssListStyles"
    >
      <kendo-grid-toolbar
        class="k-grid-toolbar kendo-grid-toolbar-style"
        :style="heightStyles"
      >
        <div class="header-btn-area right">
          <v-ons-button
            v-show="!isSortMode && isAllowAddRecord"
            modifier="outline"
            class="btn3-normal toolbar-btn"
            style="float:left"
            @click="showMasterModal"
          >
            追加
          </v-ons-button>
          <v-ons-button
            v-show="!isSortMode && isAllowSort"
            modifier="outline"
            class="btn3-normal toolbar-btn"
            @click="toRankEditBtnClick()"
          >
            並び順表示
          </v-ons-button>
          <v-ons-button
            v-show="isSortMode && isAllowSort"
            modifier="outline"
            class="btn3-normal toolbar-btn"
            @click="sortBtnClick()"
          >
            反映
          </v-ons-button>
        </div>
        <!-- ソート後グリッド表示 -->
        <span v-show="isSortChacked">
          <div
            id="grid-font-size"
            ref="grid"
            :class="[
              fontSizeSet,
              'ntss-kendo-grid-legacy',
              'mst-favorite-facility-direct-jq-grid'
            ]"
          ></div>
        </span>
      </kendo-grid-toolbar>
      <div id="grid-footer">
        <v-ons-row v-show="!isSortMode" width="100%">
          <v-ons-col width="50%">
            <v-ons-button
              class="btn2-cancel button denial-btn"
              style="width: auto;"
              @click="cancel"
            >
              キャンセル
            </v-ons-button>
          </v-ons-col>
          <v-ons-col width="50%" class="right">
            <v-ons-button
              class="btn1-execute button registration-btn"
              style="width: auto;"
              :disabled="!isChanged"
              @click="saveRecord"
            >
              保存
            </v-ons-button>
          </v-ons-col>
        </v-ons-row>
      </div>
    </div>

    <message-dialog
      v-if="isDialogVisible"
      v-model:visible="isDialogVisible"
      :message-cd="messageCd"
      :string-params="stringParams"
      type="1"
    />
  </div>
</template>

<script>
import { mapActions, mapGetters } from "@/compat/vue/vuex";
import { EventBus } from "@/compat/vue/event-bus.js";
import messageDialog from "@/components/common/message-dialog/MessageDialog";
//FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
import { markRaw } from "@/compat/vue/runtime";
import kendo from "@progress/kendo-ui";
import $ from "@/compat/jquery";
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 end

export default {
  components: {
    "message-dialog": messageDialog
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
      isSorted: false,
      kendoGridToolbarHeight: 500,
      kendoGridHeight: 300,
      columnWidth: 14,
      kendoValidatorSetup: {
        rules: {},
        messages: {}
      },
      // 編集失敗時のマスタ/列/スキーマ情報のバックアップ
      backupMasterRecordList: [],
      isDialogVisible: false,
      stringParams: null,
      messageCd: null,
      isSortChacked: false,
      //Android端末で編集中であることを示すフラグ
      editingFlg: false,
      androidFlg: false,
      iosFlg: false,
      scrollPosition: {
        top: 0,
        left: 0
      },
      // 自画面の名称
      selfScreenName: "",
      lockedColumnsWidth: 0,
      lastScrollTop: 0,
      lastScrollLeft: 0,
      directGridWidget: null,
      directGridDataSource: null,
      directGridColumnSignature: "",
      directGridLayoutRafId: null,
      directGridVisualRafId: null,
      directGridRowVisualRafIds: markRaw(new Map()),
      directGridEditOriginalValues: markRaw(new Map()),
      kendoValidator: { validate: () => true }
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
    ...mapGetters("master-maintenance", {
      getMasterRecordList: "getMasterRecordList",
      getFilteredMasterRecordList: "getFilteredMasterRecordList",
      getUpdateRecordList: "getUpdateRecordList",
      masterPhysicalName: "getMasterName",
      columnDefinition: "getColumns",
      editRecord: "getEditRecord",
      isEdited: "isEdited",
      hasValueColumn: "hasValueColumn",
      getFacilitySwitch: "getFacilitySwitch",
      isRecordModified: "isRecordModified"
    }),
    ...mapGetters("user", { facilityCd: "getFacilityCd" }),

    heightStyles() {
      // main部の高さをCSS変数を利用して書き換え
      return { "--height": `${this.kendoGridToolbarHeight}px` };
    },
    ntssListStyles() {
      return { display: this.columns.length === 1 ? "none" : "inherit" };
    },
    masterRecords() {
      if (this.getMasterRecordList.length !== 0) {
        // フィルター処理
        this.filterRecords(this.getFilteredMasterRecordList.data);
        if (!this.isSortChacked) {
          // storeからデータ取得後施設コードでソート
          this.sortRecords(this.getFilteredMasterRecordList.data);

          // 表示順を更新するため、storeに設定
          this.setMasterRecordList(this.getFilteredMasterRecordList);
          // ソート後グリッドを表示
          this.showDisplay();
        }
      }

      // storeからデータを取得
      return this.getFilteredMasterRecordList;
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
        (data.filter(row => row.operation > 0).length ||
          this.isRecordModified ||
          !this.kendoValidator.validate())
      );
    }
  },
  watch: {
    windowHeight() {
      this.calculateColumnsWidth();
      this.calculateGridHeight();
      this.calculateGridWidth();
    },
    windowWidth() {
      this.calculateColumnsWidth();
      this.calculateGridHeight();
      this.calculateGridWidth();
    },
    isDispMenu() {
      this.calculateColumnsWidth();
      this.calculateGridHeight();
      this.calculateGridWidth();
    },
    getFontSize() {
      this.calculateColumnsWidth();
      this.calculateGridHeight();
      this.calculateGridWidth();
    },
    columns(val) {
      this.$nextTick(() => {
        if (val.length > 1) {
          this.setLoadingScreenVisible(false);
          this.initDirectGridIfReady();
          this.scheduleDirectGridLayoutContract();
        }
      });
    }
  },

  created() {
    this.setLoadingScreenVisible(true);
    this.calculateColumnsWidth();
    this.loadGridData();

    // 共通ローダー:表示名設定
    this.setLoadingScreenMessage("処理中・・・");
    // 端末判別
    const ua = ((this?.$el?.ownerDocument?.defaultView?.navigator?.userAgent) || globalThis?.navigator?.userAgent || "");
    if (ua.match(/Android/)) {
      this.androidFlg = true;
    } else if (ua.match(/iPhone|iPad/)) {
      this.iosFlg = true;
    }
    this.selfScreenName = this.$route.name;
    EventBus.$on("onCloseMasterEditModal", this.onCloseMasterEditModal);
    EventBus.$on("refresh", this.refresh);
  },
  // add 性能改善メモリ不足 shan start
  beforeUnmount() {
    EventBus.$off("onCloseMasterEditModal", this.onCloseMasterEditModal);
    EventBus.$off("refresh", this.refresh);
    this.destroyDirectGrid();
    if (this.directGridLayoutRafId != null) {
      cancelAnimationFrame(this.directGridLayoutRafId);
      this.directGridLayoutRafId = null;
    }
    if (this.directGridVisualRafId != null) {
      cancelAnimationFrame(this.directGridVisualRafId);
      this.directGridVisualRafId = null;
    }
    this.directGridRowVisualRafIds?.forEach?.(id => cancelAnimationFrame(id));
    this.directGridRowVisualRafIds?.clear?.();
  },
  // add 性能改善メモリ不足 shan end
  mounted() {
    this.$nextTick(() => {
      this.calculateColumnsWidth();
      this.calculateGridHeight();
      this.calculateGridWidth();
      this.initDirectGridIfReady();
    });
  },

  methods: {
    ...mapActions("multi-modal", [
      "showMasterEdit",
      "showMstFavoriteFacilityModal"
    ]),
    ...mapActions("master-maintenance", [
      "findRecordListByFacilityCdWithSql",
      "setMasterRecordList",
      "edit",
      "setCondition",
      "updateRecordListByFacilityCd",
      "setComparisonRecordModel",
      "setEditRecord",
      "editRecordBeEmpty"
    ]),
    // 共通ローダー設定
    ...mapActions("loading-screen", {
      setLoadingScreenVisible: "setLoadingScreenVisible",
      setLoadingScreenMessage: "setLoadingScreenMessage",
      resetLoadingScreenVisibleCount:  "resetLoadingScreenVisibleCount"
    }),
    getGridRoot() {
      return this.$refs.grid || null;
    },
    getGridWidget() {
      return this.directGridWidget || null;
    },
    getGridHeaderEl() {
      return this.getGridRoot()?.querySelector?.(".k-grid-header") || null;
    },
    getGridContentEl() {
      return this.getGridRoot()?.querySelector?.(".k-grid-content") || null;
    },
    getGridLockedContentEl() {
      return this.getGridRoot()?.querySelector?.(".k-grid-content-locked") || null;
    },
    getGridScrollContainer() {
      return this.getGridContentEl();
    },
    getGridDataItem(row) {
      return this.directGridWidget?.dataItem?.(row) || null;
    },
    getGridScrollPosition() {
      const content = this.getGridContentEl();
      return { top: content?.scrollTop || 0, left: content?.scrollLeft || 0 };
    },
    setGridScrollPosition(position = {}) {
      const content = this.getGridContentEl();
      if (!content) {
        return;
      }
      if (Number.isFinite(position.left)) {
        content.scrollLeft = position.left;
      }
      if (Number.isFinite(position.top)) {
        content.scrollTop = position.top;
        this.syncDirectGridLockedScrollPosition(position.top);
      }
      try {
        $(content).trigger("scroll");
      } catch (_error) {
        // noop
      }
    },
    getColumnIndex(fieldName) {
      return this.columns.findIndex(e => e.field === fieldName);
    },
    getMaxSortRank() {
      const data = this.getFilteredMasterRecordList?.data || [];
      return data.length > 0 ? data.reduce((a, b) => Math.max(a, +b.sortRank || 0), 0) : 0;
    },
    calculateColumnsWidth() {
      const ownerWindow = this.$el?.ownerDocument?.defaultView || window;
      const width = this.$el?.closest?.("#app")?.clientWidth || ownerWindow.innerWidth || 0;
      this.columnWidth = width > 1000 ? 14 : 9;
    },
    calculateGridHeight() {
      if (this.editingFlg) {
        return;
      }
      const ownerDocument = this.$el?.ownerDocument || document;
      const ownerWindow = ownerDocument.defaultView || window;
      const header = ownerDocument.getElementById("header") || ownerDocument.getElementById("header-id");
      const footer = ownerDocument.getElementById("footer-menu-id");
      const gridFooter = this.$el?.querySelector?.("#grid-footer");
      const headerArea = this.$el?.querySelector?.(".header-btn-area");
      const wh = this.windowHeight || ownerWindow.innerHeight || 0;
      const hh = header?.offsetHeight || 0;
      const fmh = footer?.offsetHeight || 0;
      const gfh = gridFooter?.offsetHeight || 0;
      const ghd = headerArea?.offsetHeight || 0;
      this.kendoGridToolbarHeight = Math.max(100, wh - hh - fmh - 5);
      this.kendoGridHeight = Math.max(100, this.kendoGridToolbarHeight - gfh - ghd);
      const root = this.getGridRoot();
      if (root) {
        root.style.height = `${this.kendoGridHeight}px`;
      }
      this.resizeDirectGrid();
    },
    calculateGridWidth() {
      this.resizeDirectGrid();
      this.applyDirectGridLockedWidthContract();
    },
    resizeDirectGrid() {
      if (!this.directGridWidget) {
        return;
      }
      try {
        this.directGridWidget.setOptions({ height: this.kendoGridHeight });
        this.directGridWidget.resize(true);
      } catch (_error) {
        // direct jq では resize 失敗時に rebuild しない。
      }
    },
    getDirectGridDataSourceOption() {
      const source = this.masterRecords || {};
      return {
        ...source,
        data: Array.isArray(source.data) ? source.data : []
      };
    },
    createDirectGridDataSource() {
      this.directGridDataSource = markRaw(new kendo.data.DataSource(this.getDirectGridDataSourceOption()));
      return this.directGridDataSource;
    },
    getDirectGridColumnSignature() {
      return (this.columns || []).map(column => [
        column.field,
        column.hidden ? 1 : 0,
        column.locked ? 1 : 0,
        column.width || ""
      ].join(":" )).join("|");
    },
    buildDirectGridColumns() {
      return (this.columns || []).map(column => {
        const gridColumn = { ...column };
        if (column.title === "施設選択") {
          gridColumn.command = { text: "変更", click: event => this.showMasterEditModal(event) };
          gridColumn.attributes = { class: "btn3-kendo-normal" };
          gridColumn.width = column.width;
          delete gridColumn.values;
        } else if (column.field === "isDel") {
          gridColumn.editor = (container, options) => this.isDelEditor(container, options);
        }
        return gridColumn;
      });
    },
    initDirectGridIfReady() {
      const root = this.getGridRoot();
      if (!root || this.columns.length <= 1) {
        return;
      }
      if (this.directGridWidget) {
        this.applyDirectGridColumnsContract();
        this.refreshDirectGridDataSource();
        this.scheduleDirectGridLayoutContract();
        return;
      }
      $(root).empty();
      $(root).kendoGrid({
        dataSource: this.createDirectGridDataSource(),
        editable: true,
        selectable: true,
        reorderable: false,
        height: this.kendoGridHeight,
        scrollable: true,
        beforeEdit: event => this.editStart(event),
        cellClose: event => this.editEnd(event),
        edit: event => this.addInputAssist(event),
        save: event => this.onSave(event),
        dataBound: event => this.onDataBoundKendoGrid(event),
        columns: this.buildDirectGridColumns()
      });
      this.directGridWidget = markRaw($(root).data("kendoGrid"));
      this.directGridColumnSignature = this.getDirectGridColumnSignature();
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
      const root = this.getGridRoot();
      if (root) {
        $(root).empty();
      }
      this.directGridWidget = null;
      this.directGridDataSource = null;
      this.directGridColumnSignature = "";
    },
    applyDirectGridColumnsContract() {
      const grid = this.directGridWidget;
      if (!grid) {
        return;
      }
      const nextSignature = this.getDirectGridColumnSignature();
      if (nextSignature !== this.directGridColumnSignature) {
        grid.setOptions({ columns: this.buildDirectGridColumns() });
        this.directGridColumnSignature = nextSignature;
      }
    },
    refreshDirectGridDataSource() {
      const grid = this.directGridWidget;
      if (!grid?.dataSource) {
        return;
      }
      const source = this.getDirectGridDataSourceOption();
      grid.dataSource.data(source.data || []);
      this.scheduleDirectGridVisualRefresh();
    },
    onDataBoundKendoGrid() {
      this.applyDirectGridStyleContract();
      this.scheduleDirectGridVisualRefresh();
    },
    getDirectGridVisibleColumns(locked) {
      return (this.columns || []).filter(column => !column.hidden && (!!column.locked) === locked);
    },
    getDirectGridCell(row, lockedRow, fieldName) {
      const column = (this.columns || []).find(item => item.field === fieldName && !item.hidden);
      if (!column) {
        return null;
      }
      const locked = !!column.locked;
      const columns = this.getDirectGridVisibleColumns(locked);
      const index = columns.findIndex(item => item.field === fieldName);
      const targetRow = locked ? lockedRow : row;
      return index >= 0 ? targetRow?.children?.[index] || null : null;
    },
    getDirectGridCells(row, lockedRow) {
      return (this.columns || [])
        .filter(column => !column.hidden)
        .map(column => ({ column, cell: this.getDirectGridCell(row, lockedRow, column.field) }))
        .filter(item => item.cell);
    },
    isDirectGridRowDeleted(row, lockedRow, rowData) {
      if (String(rowData?.isDisp ?? rowData?.isDel ?? "") === "0") {
        return true;
      }
      const isDelCell = this.getDirectGridCell(row, lockedRow, "isDel") || this.getDirectGridCell(row, lockedRow, "isDisp");
      return !!isDelCell?.classList?.contains("k-dirty-cell") && isDelCell.textContent.includes("削除");
    },
    applyDirectGridRowVisual(row, lockedRow) {
      if (!row) {
        return;
      }
      const rowData = this.getGridDataItem(row) || this.getGridDataItem(lockedRow);
      const cells = this.getDirectGridCells(row, lockedRow);
      const sortRankCell = this.getDirectGridCell(row, lockedRow, "sortRank");
      const dummyCell = this.getDirectGridCell(row, lockedRow, "dummy");
      if (sortRankCell?.classList?.contains("k-dirty-cell")) {
        sortRankCell.classList.add("master-sort-edited");
        dummyCell?.classList?.add("master-sort-edited");
      }
      let edited = !!rowData?.edited || !!rowData?.operation;
      cells.forEach(({ column, cell }) => {
        if (cell.classList.contains("k-dirty-cell") && column.field !== "sortRank") {
          cell.classList.add("master-edited-cell");
          edited = true;
        }
      });
      const deleted = this.isDirectGridRowDeleted(row, lockedRow, rowData);
      if (edited || deleted) {
        const addClass = deleted ? "master-deleted-row" : "master-edited-row";
        cells.forEach(({ cell }) => cell.classList.add(addClass));
      }
    },
    scheduleDirectGridVisualRefresh() {
      if (this.editingFlg) {
        return;
      }
      if (this.directGridVisualRafId != null) {
        cancelAnimationFrame(this.directGridVisualRafId);
      }
      this.directGridVisualRafId = requestAnimationFrame(() => {
        this.directGridVisualRafId = null;
        this.editBackgroundColor();
      });
    },
    applyDirectGridStyleContract() {
      const root = this.getGridRoot();
      if (!root) {
        return;
      }
      root.classList.add("ntss-kendo-grid-legacy", "k-widget", "k-grid", "k-editable", "k-display-block");
      root.querySelectorAll(".k-grid-header th, .k-grid-header .k-table-th").forEach(cell => cell.classList.add("k-header"));
      [".k-grid-content tbody", ".k-grid-content-locked tbody"].forEach(selector => {
        root.querySelectorAll(selector).forEach(tbody => {
          Array.from(tbody.children).forEach((row, index) => {
            row.classList.add("k-master-row");
            row.classList.toggle("k-alt", index % 2 === 1);
          });
        });
      });
      root.querySelectorAll(".k-grid-content tbody td, .k-grid-content-locked tbody td").forEach(cell => cell.classList.add("k-td", "k-table-td"));
      this.applyDirectGridLockedWidthContract();
      this.applyDirectGridLockedHeightContract();
      this.syncDirectGridLockedScrollPosition();
    },
    applyDirectGridLockedWidthContract() {
      const root = this.getGridRoot();
      if (!root) {
        return;
      }
      const width = this.getDirectGridVisibleColumns(true).reduce((sum, column) => {
        const raw = `${column.width || ""}`;
        if (raw.endsWith("em")) {
          const fontSize = parseFloat(root.ownerDocument?.defaultView?.getComputedStyle(root).fontSize || "16") || 16;
          return sum + parseFloat(raw) * fontSize;
        }
        if (raw.endsWith("px")) {
          return sum + parseFloat(raw);
        }
        const parsed = parseFloat(raw);
        return sum + (Number.isFinite(parsed) ? parsed : 0);
      }, 0);
      if (!width) {
        return;
      }
      const widthPx = `${Math.ceil(width)}px`;
      root.querySelectorAll(".k-grid-header-locked,.k-grid-content-locked,.k-grid-header-locked table,.k-grid-content-locked table").forEach(element => {
        element.style.width = widthPx;
        element.style.minWidth = widthPx;
      });
    },
    applyDirectGridLockedHeightContract() {
      const content = this.getGridContentEl();
      const lockedContent = this.getGridLockedContentEl();
      if (!content || !lockedContent) {
        return;
      }
      lockedContent.style.height = `${content.clientHeight}px`;
      lockedContent.style.maxHeight = `${content.clientHeight}px`;
    },
    syncDirectGridLockedScrollPosition(scrollTop = null) {
      const lockedContent = this.getGridLockedContentEl();
      if (!lockedContent) {
        return;
      }
      const content = this.getGridContentEl();
      lockedContent.scrollTop = scrollTop !== null && scrollTop !== undefined ? scrollTop : (content?.scrollTop || 0);
    },
    scheduleDirectGridLayoutContract() {
      if (this.directGridLayoutRafId != null) {
        cancelAnimationFrame(this.directGridLayoutRafId);
      }
      this.directGridLayoutRafId = requestAnimationFrame(() => {
        this.applyDirectGridStyleContract();
        this.directGridLayoutRafId = requestAnimationFrame(() => {
          this.directGridLayoutRafId = null;
          this.applyDirectGridStyleContract();
        });
      });
    },
    addInputAssist() {
      if (this.isSortMode) {
        const editCell = this.getGridRoot()?.querySelector?.(".k-edit-cell");
        editCell?.classList?.add("master-sort-edited");
      }
    },
    editableColumns() {
      this.columns.forEach(column => {
        column.editable = column.originalEditable ? () => true : () => false;
      });
    },
    disableColumns() {
      this.columns.forEach(column => {
        column.editable = column.field === "sortRank" ? () => true : () => false;
      });
    },
    showSortColumn() {
      const sortIndex = this.getColumnIndex("sortRank");
      if (sortIndex >= 0) {
        this.columns[sortIndex].hidden = !this.isSortMode;
        this.columns[sortIndex].editable = this.isSortMode ? () => true : () => false;
      }
      const dummyIndex = this.getColumnIndex("dummy");
      if (dummyIndex >= 0) {
        this.columns[dummyIndex].hidden = !this.isSortMode;
      }
      this.applyDirectGridColumnsContract();
      this.scheduleDirectGridLayoutContract();
    },
    toRankEditBtnClick() {
      this.setScrollPosition(this.scrollPosition);
      if (!this.kendoValidator.validate()) {
        return;
      }
      this.isSortMode = true;
      this.disableColumns();
      this.showSortColumn();
      EventBus.$emit("setSortMode", this.isSortMode);
      this.$nextTick(() => this.calculateGridWidth());
    },
    sort() {
      const compare = (a, b) => a.sortRank - b.sortRank || a.sortInputTime - b.sortInputTime;
      this.getMasterRecordList.data.sort(compare);
      for (let i = 0; i < this.getMasterRecordList.data.length; i++) {
        if (String(this.getMasterRecordList.data[i].isDisp ?? this.getMasterRecordList.data[i].isDel ?? "1") !== "0") {
          this.getMasterRecordList.data[i].sortRank = i + 1;
        }
      }
    },
    sortBtnClick() {
      this.setScrollPosition(this.scrollPosition);
      const tempData = JSON.parse(JSON.stringify(this.getMasterRecordList.data || []));
      this.isSortMode = false;
      this.editableColumns();
      this.showSortColumn();
      this.sort();
      this.isSorted = this.sortChange(tempData);
      EventBus.$emit("setSortMode", this.isSortMode);
      this.refreshDirectGridDataSource();
      this.$nextTick(() => this.calculateGridWidth());
    },
    sortChange(tempData) {
      let flag = false;
      (this.getMasterRecordList.data || []).forEach(item => {
        tempData.forEach(tempItem => {
          if (item.code === tempItem.code && item.sortRank !== tempItem.sortRank) {
            flag = true;
          }
        });
      });
      return flag;
    },
    cancel() {
      this.$router.go(-1);
    },
    refresh() {
      if (!this.isSorted) {
        this.findList();
      }
    },
    getDirectGridEditingField(event) {
      const container = event?.container;
      const cell = container?.closest?.("td")?.[0] || container?.closest?.("td") || this.getGridRoot()?.querySelector?.(".k-edit-cell");
      const row = cell?.closest?.("tr");
      if (!cell || !row) {
        return Object.keys(event?.values || {})[0] || null;
      }
      const locked = !!row.closest?.(".k-grid-content-locked");
      const index = Array.from(row.children || []).indexOf(cell);
      return this.getDirectGridVisibleColumns(locked)[index]?.field || Object.keys(event?.values || {})[0] || null;
    },
    getDirectGridEditValueKey(model, field) {
      return `${model?.uid || model?.code || model?.id || "__row__"}:${field || "__field__"}`;
    },
    captureDirectGridEditOriginalValue(event) {
      const field = this.getDirectGridEditingField(event);
      if (!field || !event?.model) {
        return;
      }
      this.directGridEditOriginalValues.set(this.getDirectGridEditValueKey(event.model, field), event.model[field]);
    },
    isDirectGridValueChanged(event) {
      const field = Object.keys(event?.values || {})[0];
      if (!field || !event?.model) {
        return false;
      }
      const key = this.getDirectGridEditValueKey(event.model, field);
      const oldValue = this.directGridEditOriginalValues.has(key)
        ? this.directGridEditOriginalValues.get(key)
        : event.model[field];
      this.directGridEditOriginalValues.delete(key);
      return oldValue !== event.values[field];
    },
    clearDirectGridTransientDirty(event) {
      const field = Object.keys(event?.values || {})[0];
      if (!field || !event?.model?.uid) {
        return;
      }
      const root = this.getGridRoot();
      const rows = Array.from(root?.querySelectorAll?.(`tr[data-uid="${event.model.uid}"]`) || []);
      rows.forEach(row => {
        const columns = this.getDirectGridVisibleColumns(!!row.closest?.(".k-grid-content-locked"));
        const index = columns.findIndex(column => column.field === field);
        const cell = index >= 0 ? row.children?.[index] : null;
        cell?.classList?.remove?.("k-dirty-cell", "master-sort-edited");
        cell?.querySelector?.(".k-dirty")?.remove?.();
      });
    },
    editStart(event) {
      this.editingFlg = true;
      this.captureDirectGridEditOriginalValue(event);
    },
    editEnd() {
      this.editingFlg = false;
      this.scheduleDirectGridLayoutContract();
    },
    applyKendoSaveValuesToModel(ev) {
      const model = ev?.model;
      Object.keys(ev?.values || {}).forEach(field => {
        if (typeof model?.set === "function") {
          model.set(field, ev.values[field]);
        } else if (model) {
          model[field] = ev.values[field];
        }
      });
    },
    onSave(ev) {
      const currentScrollPosition = this.getGridScrollPosition();
      this.scrollLeft = currentScrollPosition.left ?? ev.sender?._scrollLeft ?? 0;
      this.scrollTop = currentScrollPosition.top ?? 0;
      this.editingFlg = false;
      if (!this.isDirectGridValueChanged(ev)) {
        this.clearDirectGridTransientDirty(ev);
        this.scheduleDirectGridRowVisualRefresh(ev.model);
        return;
      }
      this.applyKendoSaveValuesToModel(ev);
      this.edit({ editRecord: ev.model, isSortMode: this.isSortMode });
      if (ev.model.operation === 1) {
        ev.model.edited = true;
      }
      this.scheduleDirectGridRowVisualRefresh(ev.model);
    },
    scheduleDirectGridRowVisualRefresh(record) {
      const key = record?.uid || record?.code || record?.favoriteFacilityCd || record?.medicalInstitutionCd;
      if (!key) {
        this.scheduleDirectGridVisualRefresh();
        return;
      }
      const oldId = this.directGridRowVisualRafIds.get(key);
      if (oldId != null) {
        cancelAnimationFrame(oldId);
      }
      const id = requestAnimationFrame(() => {
        this.directGridRowVisualRafIds.delete(key);
        const root = this.getGridRoot();
        if (!root) {
          return;
        }
        root.querySelectorAll(`tr[data-uid="${record.uid}"]`).forEach(row => {
          const lockedRow = root.querySelector(`.k-grid-content-locked tr[data-uid="${record.uid}"]`);
          if (!row.closest(".k-grid-content-locked")) {
            this.applyDirectGridRowVisual(row, lockedRow);
          }
        });
      });
      this.directGridRowVisualRafIds.set(key, id);
    },
    editBackgroundColor() {
      if (this.editingFlg) {
        return;
      }
      const root = this.getGridRoot();
      const contentRows = Array.from(root?.querySelectorAll?.(".k-grid-content tbody tr") || []);
      const lockedRows = Array.from(root?.querySelectorAll?.(".k-grid-content-locked tbody tr") || []);
      contentRows.forEach((row, index) => this.applyDirectGridRowVisual(row, lockedRows[index] || null));
    },

    /**
     * @description 削除列のkendo editor
     */
    isDelEditor(container, data) {
      if (data.model.operation === 1) {
        // 編集不可時でもeditStart()が発火するため、ここでフラグをoffにする
        this.editingFlg = false;
        // 新規レコードはlabelにして編集させない
        $(`<label></label>`).appendTo(container);
      } else {
        // 既存レコードは編集可
        $(`<input class="k-textbox" name="${data.field}"/>`)
          .appendTo(container)
          .kendoDropDownList({
            dataSource: [
              { text: "", value: "0" },
              { text: "削除", value: "1" }
            ],
            dataTextField: "text",
            dataValueField: "value",
            value: data.model[data.field]
          });
      }
    },
    // グリッドのデータ再表示
    gridDataRefresh() {
      this.refreshDirectGridDataSource();
    },

    // マスタ一覧のデータを取得
    async findList() {
      // apiをコールして値を取得
      // add マスタ一覧 1･施設切替を可能とする 王 facilityCd -> getFacilitySwitch
      // this.findRecordListByFacilityCdWithSql(this.facilityCd)
      this.findRecordListByFacilityCdWithSql(this.getFacilitySwitch)
        .then(response => {
          // カラム情報のJSONが未定義の場合には、ダイアログを出して画面を閉じる
          if (response.data.columns.length === 0) {
            this.$ons.notification.alert({
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
              // title: "取得失敗",
              // message:
              //   "マスタ定義にカラム情報が登録されていません。<BR>カラム情報を登録してください。",
              title: DIALOG_MESSAGES[12000001].title,
              message: messageFormat(DIALOG_MESSAGES[12000001].message),
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
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
            column.width = column.width ? column.width : "0";
          });
          this.columns = toFunction;

          // 横スクロールバーを表示するために列幅を指定
          this.columns.forEach(column => {
            // 「削除」のプルダウンが改行しない幅に調整
            // mod #7289-マスタの削除ボタンが縦表示になる 徐博 start
            // column.width = column.field === "isDisp" ? "8em" : (this.columnWidth + "em");
            column.width = column.field === "isDisp" ? "9em" : (this.columnWidth + "em");
            // mod #7289-マスタの削除ボタンが縦表示になる 徐博 end
            if (column.title === "施設選択") {
              column.width = "6em";
            }
            //よく使う施設マスタで施設を追加した時に高さが異なる修正 #7292 xmj start
            if (column.title === "施設名") {
              column.width = "20em";
            }
            //よく使う施設マスタで施設を追加した時に高さが異なる修正 #7292 xmj end
          });

          // del redmine 4531 よく使う施設マスタで並び順変更をすると施設名が見えなくなる 宋qy start
          // if (this.androidFlg || this.iosFlg) {
          //   this.lockedColumnsWidth = 15;
          // } else {
          //   this.lockedColumnsWidth = 20;
          // }
          // del redmine 4531 よく使う施設マスタで並び順変更をすると施設名が見えなくなる 宋qy end

          // 先頭列ダミー要素追加（並び順列の変更内容が"かぶって"表示されてしまう事象の対応のため）
          this.columns.unshift({
            title: " ",
            field: "dummy",
            hidden: false,
            locked: true,
            editable: () => false,
            width: "10px",
            format: "",
            values: null
          });
          // 初期データ内容を保存
          this.setComparisonRecordModel();
          // カラム幅等初期調整
          this.showSortColumn();
          this.$nextTick(() => {
            this.calculateGridHeight();
            this.calculateGridWidth();
            this.initDirectGridIfReady();
            this.refreshDirectGridDataSource();
            /* add スクロールの位置を維持 楊 start */
            this.setGridScrollPosition({ top: this.lastScrollTop, left: this.lastScrollLeft });
            /* add スクロールの位置を維持 楊 end */
          });
        })
        .catch(error => {
            //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
            getErrorMessage('MstFavoriteFacilityMainComponent.vue', 'findList', error);
            //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
        });
    },

    async saveRecord() {
      // 共通ローダー:表示開始
      this.setLoadingScreenVisible(true);
      /* add スクロールの位置を維持 楊 start */
      const { top: scrollTop, left: scrollLeft } = this.getGridScrollPosition();
      this.lastScrollTop = scrollTop;
      this.lastScrollLeft = scrollLeft;
      /* add スクロールの位置を維持 楊 end */
      // 必須チェック
      if (!this.isFilledRequired()) {
        //共通ローダー：表示終了
        this.setLoadingScreenVisible(false);
        return;
      }

      const updRecLst =
        this.getUpdateRecordList
          .filter(updRec => {
            // mod よく使う施設の変更 （施設コードから医療機関コードに主キーを変更。） 杜 start
            // 施設コード/医療機関コード の場合
            if (!(updRec.operation === 1 && !(updRec.favoriteFacilityCd || updRec.medicalInstitutionCd))) return true;
            // mod よく使う施設の変更 （施設コードから医療機関コードに主キーを変更。） 杜 end
          })
          .map(updRec => {
            return {
              code: updRec.code,
              favoriteFacilityCd: updRec.favoriteFacilityCd,
              // mod よく使う施設の変更 （施設コードから医療機関コードに主キーを変更。） 杜 start
              medicalInstitutionCd: updRec.medicalInstitutionCd,
              // mod よく使う施設の変更 （施設コードから医療機関コードに主キーを変更。） 杜 end
              sortRank: updRec.sortRank,
              sortInputTime: updRec.sortInputTime,
              isDisp: updRec.isDisp,
              operation: updRec.operation
            }
          });

      // add マスタ一覧 1･施設切替を可能とする 王 facilityCd -> getFacilitySwitch
      // this.updateRecordListByFacilityCd({facilityCd: this.facilityCd, request: updRecLst})
      this.updateRecordListByFacilityCd({facilityCd: this.getFacilitySwitch, request: updRecLst})
        .then(response => {
          this.updateResponse = response.data;
          //共通ローダー：表示終了
          this.setLoadingScreenVisible(false);
          this.$ons.notification.alert({
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
            // title: "更新完了",
            // message: "マスタ更新が完了しました。"
            title: DIALOG_MESSAGES[12000004].title,
            message: messageFormat(DIALOG_MESSAGES[12000004].message),
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
          });

          this.isSorted = false;
          this.findList();
          // 画面表示フラグ
          this.isSortChacked = false;

          //共通ローダー：表示終了
          this.setLoadingScreenVisible(false);
        })
        .catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
          getErrorMessage('MstFavoriteFacilityMainComponent.vue', 'saveRecord', error);
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
          if (error.response.status === 400) {
            //共通ローダー：表示終了
            this.setLoadingScreenVisible(false);
            this.$ons.notification.alert({
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
              // title: "更新失敗",
              title: DIALOG_MESSAGES["00300005"].title,
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
              message: error.response.data.errorMessage
            });
          }
        });
    },

    /**
     * @description 必須項目チェック
     * @summary 未入力の必須項目があったらダイアログを表示する
     * @returns {Boolean} true: 未入力なし, false: 未入力あり
     */
    isFilledRequired() {
      if (
        this.getUpdateRecordList.some(
          item => (item.favoriteFacilityCd === null || item.favoriteFacilityCd === "") && item.operation !== 1
          // 医療機関コード の場合
          // mod よく使う施設の変更 （施設コードから医療機関コードに主キーを変更。） 杜 start
          && (item.medicalInstitutionCd === null || item.medicalInstitutionCd === "")
          && item.operation !== 1
          // mod よく使う施設の変更 （施設コードから医療機関コードに主キーを変更。） 杜 end
          )) {
        this.isDialogVisible = true;
        this.messageCd = 30000004;
        this.stringParams = ["施設を選択してください。"];
        return false;
      }
      return true;
    },
    showMasterEditModal(e) {
      this.showMasterModal();

      /**
       * 「設定」ボタンを押下したレコードのデータを取得する。
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
      const normalizedItem = this.normalization(selectedRowItem);

      // ストアに保存する。
      this.setEditRecord(normalizedItem);
    },
    showMasterModal() {
      // モーダル確定時にスクロール位置が戻ってしまう問題の対処
      const { top: scrollTop, left: scrollLeft } = this.getGridScrollPosition();
      this.scrollPosition.top = scrollTop;
      this.scrollPosition.left = scrollLeft;

      // モーダルを表示
      this.showMstFavoriteFacilityModal();
    },
    onCloseMasterEditModal(facilities) {
      // #9863 facilities.forEach is not a function 横展開2 linjunfeng start
      // if (facilities && facilities.length > 0) {
        if (facilities && typeof facilities === "object" &&  facilities.length > 0) {
        facilities.forEach(facility => this.addRow(facility));
      }
      // #9863 facilities.forEach is not a function 横展開2 linjunfeng end
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
    addRow(record) {
      // グリッドでエラーが発生している場合は処理を中断
      if (!this.kendoValidator.validate()) {
        return;
      }

      // 空レコードをストアに登録
      const newRecord = {};
      const fields = this.getMasterRecordList.schema.model.fields;

      // 初期値を設定
      Object.keys(fields).forEach(colName => {
        newRecord[colName] = record ? record[colName] : null;
        // 初期時、新しいレコードに全レコードの並び順の最大値をセット
        if (colName === "sortRank") {
          newRecord[colName] = this.getMaxSortRank() + 1;
        }
      });
      newRecord.edited = true;
      this.lastScrollTop = this.getGridScrollContainer()?.scrollHeight || 0;
      this.scheduleMasterGridScrollToAddedRow?.();
      // 画面編集内容をstoreに反映 ※新規レコード追加
      this.edit({ editRecord: newRecord, isSortMode: this.isSortMode });
      this.refreshDirectGridDataSource();
      this.$nextTick(() => {
        const content = this.getGridScrollContainer();
        if (content) {
          content.scrollTop = content.scrollHeight;
          this.syncDirectGridLockedScrollPosition(content.scrollTop);
        }
        this.scheduleDirectGridRowVisualRefresh(newRecord);
      });
    },
    /**
     * @description 表示順設定
     * @param {Array}
     */
    sortRecords(records) {
      records.sort((a, b) => {
        // 施設コードでソート
        return a.sortRank - b.sortRank;
      });
    },

    /**
     * @description 画面表示関数
     */
    showDisplay() {
      // 画面表示フラグ
      this.isSortChacked = true;
      this.$nextTick(() => {
        this.initDirectGridIfReady();
        this.refreshDirectGridDataSource();
        this.scheduleDirectGridLayoutContract();
      });
    },

    loadGridData(){
      // delete start #9590
        // this.setCondition(this.condition);
        // delete end #9590
      this.findList();
    },

    /**
     * @description フィルター処理
     * @param {Array}
     */
    filterRecords(records) {
      // フィルター処理
      const data = records.filter(item => {
        return (!item.isFavDel || item.isFavDel === "0") && (!item.isSysDel || item.isSysDel === "0");
      });
      // フィルター処理済データの格納
      this.getFilteredMasterRecordList.data = data;
    }
  }
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
  position: absolute;
  width: inherit;
}
.kendo-grid-toolbar-style {
  --height: 200px;
  height: var(--height);
  border-bottom: none;
}
.toolbar-btn {
  font-size: 1.0em;
  padding: 0.2em 1em 0em 1em;
  line-height: 2em;
  width: auto;
}
.kendo-grid-toolbar-style {
  padding: 0.1em 0.3em;
}
.kendo-grid-toolbar-style span {
  margin: 0;
}

.kendo-grid-toolbar-style :deep(.k-grid-header-locked > table) {
  border-right-width: 0px;
}
.kendo-grid-toolbar-style :deep(.k-grid-header-locked) {
  border-right: 1px solid var(--ntss-list-border-color) !important;
}
.kendo-grid-toolbar-style :deep(.k-grid-content-locked) {
  z-index: 1;
  box-shadow: 1px 0px 0px 0px var(--ntss-border-color) !important;
  padding-bottom: 16px;
}
.mst-favorite-facility-direct-jq-grid {
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
