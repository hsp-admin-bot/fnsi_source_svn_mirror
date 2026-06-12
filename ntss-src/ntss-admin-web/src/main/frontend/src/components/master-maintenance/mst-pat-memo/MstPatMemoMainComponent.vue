/**
 * 患者メモマスタページ(患者メモマスタ)  MainContent
 */
<template>
  <div :class="['main-content-area', { 'no-scroll': isMobileDevice }, 'master-maintenance-page']">
    <div class="ntss-list" :style="ntssListStyles">
      <div class="k-grid-toolbar k-header kendo-grid-toolbar-style" :style="heightStyles">
        <div v-if="isMobileDevice" id="grid-header" class="header-btn-area right" style="height: 30px;">
          <v-ons-row style="width: 7em;">
            <v-ons-col width="45%" vertical-align="center">
              <label class="fab-font-color">編集</label>
            </v-ons-col>
            <v-ons-col width="55%" vertical-align="center">
              <v-ons-switch modifier="outline" v-model="allowEdit" />
            </v-ons-col>
          </v-ons-row>
        </div>
        <div
          v-show="columns.length > 1"
          id="grid-font-size"
          ref="gridRoot"
          :class="[fontSizeSet, 'content-style', 'ntss-kendo-grid-legacy', 'mst-pat-memo-direct-jq-grid']"
        ></div>
      </div>
      <div id="grid-footer">
        <v-ons-row width="100%" v-show="!isSortMode">
          <v-ons-col width="50%">
            <v-ons-button class="btn2-cancel button denial-btn" style="width: auto;" @click="cancel">キャンセル</v-ons-button>
          </v-ons-col>
          <v-ons-col width="50%" class="right">
            <v-ons-button class="btn1-execute button registration-btn" style="width: auto;" :disabled="!isChanged" @click="beforeSaveRecord">保存</v-ons-button>
          </v-ons-col>
        </v-ons-row>
      </div>
      <master-csv
        :popoverVisible="masterCsvVisible"
        :popoverTarget="masterCsvTarget"
        @popover-close="prehideCsvPopover"
      />
      <message-dialog
        v-if="isDialogVisible"
        v-model:visible="isDialogVisible"
        :message-cd="messageCd"
        type="5"
        @confirm="setUpdateAllPatFlg"
      />
    </div>
  </div>
</template>

<script>
import { mapActions, mapGetters } from "@/compat/vue/vuex";
import { EventBus } from "@/compat/vue/event-bus.js";

import MasterCsvComponent from "@/components/master-maintenance/MasterCsvComponent";
import { ApiHelper } from "@/apis/AxiosHelper";
import messageDialog from "@/components/common/message-dialog/MessageDialog";
//FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
import { markRaw } from "@/compat/vue/runtime";
import kendo from "@progress/kendo-ui";
import $ from "jquery";
import MasterMaintenanceMixin from "@/components/master-maintenance/MasterMaintenanceMixin";
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 end

/**
 * TODO
 * more: モーダルで編集した項目が、一覧上で「編集済み（三角マーク）」をつけたい。
 */
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
  components: {
    "master-csv": MasterCsvComponent,
    "message-dialog": messageDialog
  },
  mixins: [MasterMaintenanceMixin],
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
      lastScrollTop: 0,
      lastScrollLeft: 0,
      preserveGridScrollAfterSave: false,
      //自画面の名称
      selfScreenName: "",
      masterCsvVisible: false,
      masterCsvTarget: null,

      // 修正済み判定用情報(ローカル用)
      comparisonRecordLocalModel: "",
      updatePatMemoInfo: null,

      // ダイアログ関連
      isDialogVisible: false,
      messageCd: null,
      lockedColumnsWidth: 0,
      allowEdit: true, // NOTE: true = 編集モード、 false = 閲覧モード
      directGridWidget: null,
      directGridMounted: false,
      directGridDataSource: null,
      directGridLayoutRafId: null,
      directGridFilterRefreshRafId: null,
      directGridScrollSyncRafId: null,
      directGridRowVisualRafIds: markRaw(new Map()),
      contentEditorResizeObserver: null,
      kendoValidator: null
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
    heightStyles() {
      const mobileHeader = this.isMobileDevice ? 32 : 0;
      // main部の高さをCSS変数を利用して書き換え
      return { "--height": `${this.kendoGridToolbarHeight - mobileHeader}px` };
    },
    ntssListStyles() {
      return { display: this.columns.length == 1 ? "none" : "inherit" };
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
      columnDefinition: "getColumns",
      editRecord: "getEditRecord",
      isEdited: "isEdited",
      hasValueColumn: "hasValueColumn",
      isRecordModified: "isRecordModified",
      getFacilitySwitch: "getFacilitySwitch"
    }),
    masterRecords() {
      // storeからデータを取得
      let returnData = this.getFilteredMasterRecordList;

      if(returnData.data !== undefined) {

        // ★削除選択で行が消える現象への対処
        // getFilteredMasterRecordListにて、編集中であろうとis_disp=0のレコードを除外してしまうのが原因
        // Redmineのチケット#689:削除選択で行が消える が修正されればここの処理は不要

        // storeからフィルタ前のデータを取得
        const data = this.getMasterRecordList.data;
        // フィルタ前のgetMasterRecordListから、編集中かつis_disp=0のレコードを抽出する
        const editedDeleteData = data.filter(
          data => this.isEdited(data.code) && data.isDisp === "0"
        );
        // 抽出したレコードをgetFilteredMasterRecordListに追加する
        // 同じ番号のレコードがgetFilteredMasterRecordListに無い場合のみ追加する
        for (let deleteData of editedDeleteData) {
          if (returnData.data.filter(data => data.code === deleteData.code).length <= 0) {
            returnData.data.push(deleteData);
          }
        }

        // ★削除選択で行が消える現象への対処 ここまで

        // 削除済み列が下に固まるのを防ぐためソート
        returnData.data.sort(function(a,b){
          if( a.code < b.code) return -1;
          if( a.code > b.code) return 1;
          return 0;
        });
      }
      return returnData;
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
        (this.isRecordModified || !this.validateDirectKendoGrid())
      );
    },
    isMobileDevice() {
      return this.iosFlg || this.androidFlg;
    }
  },
  watch: {
    windowHeight() {
      this.scheduleDirectGridLayoutContract();
    },
    windowWidth() {
      this.scheduleDirectGridLayoutContract();
    },
    isDispMenu() {
      this.scheduleDirectGridLayoutContract();
    },
    getFontSize() {
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
    ...mapActions("multi-modal", ["showMasterEdit"]),
    ...mapActions("master-maintenance", [
      "findRecordList",
      "findRecordListByFacilityCd",
      "findColumnInfo",
      "setMasterRecordList",
      "edit",
      "setCondition",
      "updateRecordList",
      "updateRecordListByFacilityCd",
      "setEditRecord",
      "editRecordBeEmpty",
      "setComparisonRecordModel"
    ]),
    // 共通ローダー設定
    ...mapActions("loading-screen", {
      setLoadingScreenVisible: "setLoadingScreenVisible",
      setLoadingScreenMessage: "setLoadingScreenMessage",
      resetLoadingScreenVisibleCount:  "resetLoadingScreenVisibleCount"
    }),
    getCurrentRouteName() {
      return this.$router?.currentRoute?.value?.name || this.$router?.currentRoute?.name || this.$route?.name || "";
    },
    cancel() {
      this.$router?.back?.();
    },
    // refresh() {
    //   this.loadGridData();
    // },
    validateDirectKendoGrid() {
      return true;
    },
    getColumnIndex(fieldName) {
      return this.columns.findIndex(e => e.field === fieldName);
    },
    calculateColumnsWidth() {
      const widthMap = [12, 14, 16, 18];
      this.columnWidth = widthMap[Number(this.getFontSize || 1)] || 14;
    },
    calculateGridHeight() {
      if (this.editingFlg) {
        return;
      }
      const wh = Number(this.windowHeight) || window.innerHeight || 0;
      const header = document.getElementsByClassName("header");
      const headerHeight = header?.length ? header[header.length - 1].clientHeight : 0;
      const footerMenu = document.getElementById("footer-menu");
      const footerMenuHeight = (this.isDispMenu === 1 && footerMenu ? footerMenu.clientHeight : 0) + 5;
      const mobileHeader = this.isMobileDevice ? 32 : 0;
      this.kendoGridToolbarHeight = Math.max(100, wh - headerHeight - footerMenuHeight);
      const gridFooter = document.getElementById("grid-footer");
      const gridHeader = document.getElementById("grid-header");
      this.kendoGridHeight = Math.max(160, this.kendoGridToolbarHeight - ((gridFooter?.clientHeight || 0) + (gridHeader?.clientHeight || mobileHeader)));
    },
    calculateGridWidth() {
      if (this.editingFlg || this.isMasterGridEditInteractionActive()) {
        return;
      }
      this.resizeDirectGrid();
    },
    disconnectContentEditorResizeObserver() {
      if (!this.contentEditorResizeObserver) {
        return;
      }
      try {
        this.contentEditorResizeObserver.disconnect();
      } catch (_error) {
        // noop
      }
      this.contentEditorResizeObserver = null;
    },
    getGridRootEl() {
      return this.$refs.gridRoot || null;
    },
    getDirectGridScrollContent() {
      return (
        this.getGridRootEl()?.querySelector?.(".k-grid-content:not(.k-grid-content-locked)")
        || this.getGridRootEl()?.querySelector?.(".k-grid-content")
        || null
      );
    },
    getDirectGridLockedScrollContent() {
      return this.getGridRootEl()?.querySelector?.(".k-grid-content-locked") || null;
    },
    getGridWidget() {
      return this.directGridWidget || null;
    },
    getGridContentEl() {
      return this.getDirectGridScrollContent();
    },
    getGridLockedContentEl() {
      return this.getDirectGridLockedScrollContent();
    },
    getGridScrollHostEl() {
      return this.getDirectGridScrollContent();
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
      const top = position.top ?? 0;
      const left = position.left ?? 0;
      content.scrollTop = top;
      content.scrollLeft = left;
      this.scrollPosition.top = top;
      this.scrollPosition.left = left;
      this.lastScrollTop = top;
      this.lastScrollLeft = left;
      this.syncDirectGridLockedScrollPosition(top);
    },
    storeDirectGridScrollPosition() {
      const position = this.getGridScrollPosition();
      this.scrollPosition.top = position.top;
      this.scrollPosition.left = position.left;
      this.lastScrollTop = position.top;
      this.lastScrollLeft = position.left;
    },
    restoreDirectGridScrollPosition() {
      const top = this.scrollPosition.top ?? this.lastScrollTop ?? 0;
      const left = this.scrollPosition.left ?? this.lastScrollLeft ?? 0;
      this.setGridScrollPosition({ top, left });
    },
    scheduleDirectGridPostColumnScrollSync() {
      if (this.directGridScrollSyncRafId != null) {
        cancelAnimationFrame(this.directGridScrollSyncRafId);
      }
      this.directGridScrollSyncRafId = requestAnimationFrame(() => {
        this.restoreDirectGridScrollPosition();
        this.directGridScrollSyncRafId = requestAnimationFrame(() => {
          this.directGridScrollSyncRafId = null;
          this.restoreDirectGridScrollPosition();
        });
      });
    },
    setLastScroll() {
      this.storeDirectGridScrollPosition();
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
    buildDirectGridColumns() {
      return this.columns.map(column => {
        const gridColumn = { ...column };
        if (column.field === "name") {
          gridColumn.editor = (container, options) => this.nameEditor(container, options);
        }
        if (column.field === "content" || column.dataType === "textarea") {
          gridColumn.editor = (container, options) => this.contentEditor(container, options);
        }
        if (column.colorTemplate) {
          gridColumn.template = column.colorTemplate;
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
        beforeEdit: event => this.onBeforeEdit(event),
        edit: event => this.addInputAssist?.(event),
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
      const current = (grid.columns || []).map(column => `${column.field}:${column.hidden ? 1 : 0}`).join("|");
      const next = (this.columns || []).map(column => `${column.field}:${column.hidden ? 1 : 0}`).join("|");
      if (current !== next) {
        grid.setOptions({ columns: this.buildDirectGridColumns() });
      }
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
      const preservedScroll = !resetScroll ? {
        top: this.scrollPosition.top ?? this.lastScrollTop ?? 0,
        left: this.scrollPosition.left ?? this.lastScrollLeft ?? 0
      } : null;
      if (!resetScroll && !this.preserveGridScrollAfterSave) {
        this.storeDirectGridScrollPosition();
      }
      grid.dataSource.data(this.getDirectGridDataSourceOption().data || []);
      if (resetScroll) {
        this.setGridScrollPosition({ top: 0, left: 0 });
        this.preserveGridScrollAfterSave = false;
      }
      this.$nextTick(() => {
        this.applyDirectGridStyleContract();
        this.editBackgroundColor();
        if (!resetScroll) {
          const scroll = preservedScroll || {
            top: this.scrollPosition.top ?? this.lastScrollTop ?? 0,
            left: this.scrollPosition.left ?? this.lastScrollLeft ?? 0
          };
          this.setGridScrollPosition(scroll);
          this.scheduleDirectGridPostColumnScrollSync();
        }
      });
    },
    gridDataRefresh() {
      this.refreshDirectGridDataFromMasterRecords();
    },
    resizeDirectGrid() {
      if (this.editingFlg || this.isMasterGridEditInteractionActive()) {
        return;
      }
      const grid = this.directGridWidget;
      if (!grid) {
        return;
      }
      try {
        grid.setOptions({ height: this.kendoGridHeight });
        grid.resize(true);
        this.applyDirectGridStyleContract();
      } catch (_error) {
        // noop
      }
    },
    getDirectGridVisibleLockedWidthPx() {
      const root = this.getGridRootEl();
      const fontSize = parseFloat(getComputedStyle(root || document.body).fontSize || "16") || 16;
      return (this.columns || []).reduce((sum, column) => {
        if (!column.locked || column.hidden) {
          return sum;
        }
        const width = `${column.width || ""}`.trim();
        if (width.endsWith("em")) {
          return sum + parseFloat(width) * fontSize;
        }
        if (width.endsWith("px")) {
          return sum + parseFloat(width);
        }
        const numeric = parseFloat(width);
        return sum + (Number.isFinite(numeric) ? numeric : 0);
      }, 0);
    },
    applyDirectGridLockedWidthContract() {
      const root = this.getGridRootEl();
      const width = this.getDirectGridVisibleLockedWidthPx();
      if (!root || !width) {
        return;
      }
      const px = `${Math.ceil(width)}px`;
      root.querySelectorAll(".k-grid-header-locked,.k-grid-content-locked,.k-grid-header-locked table,.k-grid-content-locked table").forEach(element => {
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
      if (height > 0) {
        lockedContent.style.height = `${height}px`;
        lockedContent.style.maxHeight = `${height}px`;
      }
    },
    applyDirectGridStyleContract() {
      const root = this.getGridRootEl();
      if (!root) {
        return;
      }
      root.classList.add("ntss-kendo-grid-legacy", "k-widget", "k-grid", "k-editable", "k-display-block");
      root.querySelectorAll("th").forEach(th => th.classList.add("k-header"));
      root.querySelectorAll(".k-grid-content tr,.k-grid-content-locked tr").forEach((tr, index) => {
        tr.classList.add("k-master-row");
        if (index % 2 === 1) {
          tr.classList.add("k-alt");
        }
      });
      root.querySelectorAll("td").forEach(td => td.classList.add("k-td", "k-table-td"));
      this.applyDirectGridLockedWidthContract();
      this.applyDirectGridLockedHeightContract();
      this.applyDirectGridLockedDividerContract();
      this.applyDirectGridBackgroundContract();
      this.syncDirectGridLockedScrollPosition();
    },
    applyDirectGridBackgroundContract() {
      const root = this.getGridRootEl();
      if (!root) {
        return;
      }
      const computed = getComputedStyle(root);
      const bodyBackgroundColor =
        computed.getPropertyValue("--main-background-color").trim() || "#fafafa";
      root.style.backgroundColor = bodyBackgroundColor;
      [
        ".k-grid-content-locked",
        ".k-grid-content:not(.k-grid-content-locked)"
      ].forEach(selector => {
        root.querySelectorAll(selector).forEach(element => {
          element.style.backgroundColor = bodyBackgroundColor;
        });
      });
      root.querySelectorAll(".k-grid-content .k-selectable, .k-grid-content-locked .k-selectable").forEach(element => {
        element.style.backgroundColor = bodyBackgroundColor;
      });
      const sampleHeaderCell = root.querySelector(".k-grid-header th, .k-grid-header .k-table-th");
      const headerCellStyle = sampleHeaderCell ? getComputedStyle(sampleHeaderCell) : null;
      const headerBackgroundColor =
        headerCellStyle?.backgroundColor
        || computed.getPropertyValue("--master-maintenance-kgrid-header-background-color").trim()
        || "#333333";
      const headerBackgroundImage =
        headerCellStyle?.backgroundImage && headerCellStyle.backgroundImage !== "none"
          ? headerCellStyle.backgroundImage
          : "linear-gradient(rgba(255, 255, 255, 0.3) 0%, transparent 50%, transparent 50%, rgba(0, 0, 0, 0.1) 100%)";
      [
        ".k-grid-header",
        ".k-grid-header-wrap",
        ".k-grid-header-locked"
      ].forEach(selector => {
        root.querySelectorAll(selector).forEach(element => {
          element.style.backgroundColor = headerBackgroundColor;
          element.style.backgroundImage = headerBackgroundImage;
        });
      });
    },
    applyDirectGridLockedDividerContract() {
      const root = this.getGridRootEl();
      if (!root) {
        return;
      }
      const computed = getComputedStyle(root);
      const bodyDividerColor =
        computed.getPropertyValue("--master-maintenance-kgrid-border-color").trim() || "#dee2e6";
      const headerDividerColor =
        computed.getPropertyValue("--ntss-list-border-color").trim() || "#dee2e6";

      const mountDivider = (container, className, color) => {
        if (!container) {
          return;
        }
        container.style.position = "relative";
        container.style.borderRight = "none";
        container.style.boxShadow = "none";
        let divider = container.querySelector(`:scope > .${className}`);
        if (!divider) {
          divider = document.createElement("div");
          divider.className = className;
          container.appendChild(divider);
        }
        divider.style.position = "absolute";
        divider.style.top = "0";
        divider.style.right = "0";
        divider.style.width = "1px";
        divider.style.height = "100%";
        divider.style.background = color;
        divider.style.pointerEvents = "none";
        divider.style.zIndex = "2";
      };

      mountDivider(root.querySelector(".k-grid-header-locked"), "mst-pat-memo-locked-divider-header", headerDividerColor);
      mountDivider(root.querySelector(".k-grid-content-locked"), "mst-pat-memo-locked-divider-body", bodyDividerColor);

      const scrollContent = this.getDirectGridScrollContent();
      if (scrollContent) {
        scrollContent.style.boxShadow = "none";
        const selectable = scrollContent.querySelector(":scope > .k-selectable");
        if (selectable) {
          selectable.style.boxShadow = "none";
          selectable.style.borderRight = "none";
        }
      }

      root.querySelectorAll(
        ".k-grid-content-locked tbody td:last-child, .k-grid-content-locked tbody .k-table-td:last-child"
      ).forEach(cell => {
        cell.style.borderRightWidth = "0";
        cell.style.borderRightColor = "transparent";
      });

      root.querySelectorAll(
        ".k-grid-content:not(.k-grid-content-locked) tbody td:first-child, .k-grid-content:not(.k-grid-content-locked) tbody .k-table-td:first-child"
      ).forEach(cell => {
        cell.style.borderLeftWidth = "0";
        cell.style.borderLeftColor = "transparent";
      });

      root.querySelectorAll(
        ".k-grid-header-wrap th:first-child, .k-grid-header-wrap .k-table-th:first-child"
      ).forEach(cell => {
        cell.style.borderLeftWidth = "0";
        cell.style.borderLeftColor = "transparent";
      });
    },
    scheduleDirectGridLayoutContract() {
      if (!this.preserveGridScrollAfterSave) {
        this.storeDirectGridScrollPosition();
      }
      if (this.directGridLayoutRafId != null) {
        cancelAnimationFrame(this.directGridLayoutRafId);
      }
      this.directGridLayoutRafId = requestAnimationFrame(() => {
        this.calculateColumnsWidth();
        if (!this.editingFlg && !this.isMasterGridEditInteractionActive()) {
          this.calculateGridHeight();
          this.resizeDirectGrid();
        }
        this.applyDirectGridStyleContract();
        this.restoreDirectGridScrollPosition();
        this.directGridLayoutRafId = requestAnimationFrame(() => {
          this.directGridLayoutRafId = null;
          if (!this.editingFlg && !this.isMasterGridEditInteractionActive()) {
            this.resizeDirectGrid();
          }
          this.applyDirectGridStyleContract();
          this.restoreDirectGridScrollPosition();
          this.scheduleDirectGridPostColumnScrollSync();
        });
      });
    },
    syncDirectGridLockedScrollPosition(scrollTop = null) {
      const lockedContent = this.getDirectGridLockedScrollContent();
      const content = this.getDirectGridScrollContent();
      if (!lockedContent) {
        return;
      }
      lockedContent.scrollTop = scrollTop !== null && scrollTop !== undefined ? scrollTop : (content?.scrollTop || 0);
    },
    onDirectGridDataBound() {
      this.applyDirectGridStyleContract();
      this.editBackgroundColor();
      this.restoreDirectGridScrollPosition();
    },
    onDirectGridSave(event) {
      const model = event?.model;
      if (!model) {
        return;
      }
      Object.keys(event.values || {}).forEach(field => {
        if (typeof model.set === "function") {
          model.set(field, event.values[field]);
        } else {
          model[field] = event.values[field];
        }
      });
      if (model.operation === 1) {
        model.edited = true;
      }
      this.edit({ editRecord: model, isSortMode: this.isSortMode });
      this.scheduleDirectGridCurrentRowVisual(model);
    },
    scheduleDirectGridCurrentRowVisual(record) {
      const key = record?.uid || record?.code;
      if (!key) {
        return;
      }
      const oldId = this.directGridRowVisualRafIds.get(key);
      if (oldId != null) {
        cancelAnimationFrame(oldId);
      }
      const rafId = requestAnimationFrame(() => {
        this.directGridRowVisualRafIds.delete(key);
        this.applyDirectGridRowVisual(record);
      });
      this.directGridRowVisualRafIds.set(key, rafId);
    },
    applyDirectGridRowVisual(record) {
      const root = this.getGridRootEl();
      if (!root || !record?.uid) {
        return;
      }
      root.querySelectorAll(`tr[data-uid="${record.uid}"]`).forEach(row => {
        row.classList.toggle("master-edited-row", !!record.operation || !!record.edited);
      });
    },
    editBackgroundColor() {
      const grid = this.directGridWidget;
      if (!grid?.tbody) {
        return;
      }
      Array.from(grid.tbody.children()).forEach(row => {
        const item = grid.dataItem(row);
        if (item) {
          row.classList.toggle("master-edited-row", !!item.operation || !!item.edited);
        }
      });
    },
    autoFitGridColumn(column) {
      try {
        this.directGridWidget?.autoFitColumn?.(column);
      } catch (_error) {
        // noop
      }
    },
    autoFitGridColumns() {
      const columns = this.directGridWidget?.columns || [];
      for (let i = 0; i < columns.length; i++) {
        if (["name"].includes(columns[i]?.field)) {
          this.autoFitGridColumn(columns[i]);
        }
      }
    },
    showSortColumn() {
      const sortRank = this.columns.find(column => column.field === "sortRank");
      const dummy = this.columns.find(column => column.field === "dummy");
      if (sortRank) {
        sortRank.hidden = !(this.isAllowSort && this.isSortMode);
      }
      if (dummy) {
        dummy.hidden = !sortRank?.hidden;
      }
      this.applyDirectGridColumnsContract();
      this.applyDirectGridStyleContract();
    },
    convertToStr(messageArr) {
      if (!messageArr || messageArr.length === 0) {
        return "";
      }
      const unique = messageArr.reduce((acc, cur) => acc.includes(cur) ? acc : acc.concat(cur), []);
      return "</br>&nbsp&nbsp・" + unique.join("</br>&nbsp&nbsp・");
    },
    validateRequired() {
      const validateMessageArr = [];
      const fields = this.getMasterRecordList?.schema?.model?.fields || {};
      (this.getMasterRecordList?.data || []).filter(row => row.isDisp !== "0").forEach(row => {
        Object.keys(fields).forEach(key => {
          if (fields[key]?.validation?.required && row[key] !== null && row[key] === "") {
            const columnInfo = this.columns.find(column => column.field == key);
            if (columnInfo?.title) {
              validateMessageArr.push(columnInfo.title);
            }
          }
        });
      });
      return this.convertToStr(validateMessageArr);
    },
    importCsv(event = null) {
      this.masterCsvTarget = event?.target || null;
      this.masterCsvVisible = true;
    },
    prehideCsvPopover() {
      this.masterCsvVisible = false;
      this.refreshDirectGridDataFromMasterRecords();
    },
    ...mapActions("mst-synchro", ["startMstSynchro"]),
    /**
     * @description 内容列のkendo editor
     */
    nameEditor(container, data) {
      $(`<input type="text" class="k-input k-textbox k-valid" name="${data.field}"/>`).appendTo(container);
    },
    /**
     * @description 内容列のkendo editor
     */
    contentEditor(container, options) {
      const fieldName = options?.field;
      if (!fieldName) {
        return;
      }
      const $textarea = $(
        `<textarea name="${fieldName}" class="k-valid k-textarea resize-obs-target" style="font-size: 1.0em;resize: vertical;min-height: calc(0.75rem + 2em);width: 100%;height: 100%;max-height: 65vh;"/>`
      );
      $textarea.appendTo(container);
      this.disconnectContentEditorResizeObserver();
      const textareaEl = $textarea[0];
      if (textareaEl) {
        this.contentEditorResizeObserver = new ResizeObserver(() => {
          if (this.editingFlg || this.isMasterGridEditInteractionActive()) {
            return;
          }
          this.calculateGridWidth();
        });
        this.contentEditorResizeObserver.observe(textareaEl);
      }
      this.$nextTick(() => {
        textareaEl?.focus?.();
      });
    },
    // マスタ一覧のデータを取得
    findList() {
      // apiをコールして値を取得
      // add マスタ一覧 1･施設切替を可能とする 王
      // this.findRecordList()
      this.findRecordListByFacilityCd(this.getFacilitySwitch)
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
            column["width"] = column.width ? column.width : "0";
            // No列表示
            column.hidden = column.field === "code" ? false : column.hidden;
          });
          this.columns = toFunction;

          // 横スクロールバーを表示するために列幅を指定
          this.columns.forEach(column => {
            // 「削除」のプルダウンが改行しない幅に調整
            // mod #7289-マスタの削除ボタンが縦表示になる 徐博 start
            // column.width = column.field === "isDisp" ? "8em" : (this.columnWidth + "em");
            column.width = column.field === "isDisp" ? "9em" : (this.columnWidth + "em");
            // mod #7289-マスタの削除ボタンが縦表示になる 徐博 end
            // ※※※※※※※※
            // ここのコードは非常に混乱で、その他部分に影響するですが、再改造しています 徐博
            // 内容列のテキストエリアがはみ出さないように調整
            // column.width = column.field === "content" ? "21em" : (this.columnWidth + "em");
            if (column.field === "content") {
              column.width = "21em";
            }
            if (column.field === "code") {
              column.width = "5em";
            }
            // add 削除の欄が広い 王 start
            // if (column.field === "isDisp")column.width = "8em";
            // add 削除の欄が広い 王 end
            // ※※※※※※※※
            // #9185 最小フォント、mst画面編集文字、テキストボックス幅を超えます linjunfeng start
            // #8612 ウィンドウサイズの変更で、マスタレイアウトが崩れる。林峻峰 start
            // if (column.locked && column.title === "No") {
            //   column.width = typeof column.width == 'string' ? Number(column.width.slice(0,-2)) * 15 : column.width * 15
            // }
            // #8612 ウィンドウサイズの変更で、マスタレイアウトが崩れる。林峻峰 end
            // #9185 最小フォント、mst画面編集文字、テキストボックス幅を超えます linjunfeng end
          });

          this.lockedColumnsWidth = 5;

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
          // カラム幅等初期調整
          this.showSortColumn();
          this.$nextTick(() => {
            this.calculateGridHeight();
            this.calculateGridWidth();
            this.initDirectGridIfReady();
            this.refreshDirectGridDataFromMasterRecords();
            this.scheduleDirectGridLayoutContract();
            const savedScrollTop = this.scrollPosition.top ?? this.lastScrollTop ?? 0;
            const savedScrollLeft = this.scrollPosition.left ?? this.lastScrollLeft ?? 0;
            const restoreSavedScroll = () => {
              this.setGridScrollPosition({ top: savedScrollTop, left: savedScrollLeft });
            };
            restoreSavedScroll();
            this.$nextTick(() => {
              restoreSavedScroll();
              requestAnimationFrame(() => {
                restoreSavedScroll();
                this.preserveGridScrollAfterSave = false;
              });
            });
          });
          // null値があるか調べて、あったら空欄に変更する
          let records = this.getMasterRecordList;
          for (let record of records.data) {
            if (record.name === null) {
              record.name = "";
            }
          }
          this.setMasterRecordList(records);
          // 初期データ内容を保存
          this.setComparisonRecordModel();
          this.comparisonRecordLocalModel = JSON.stringify(this.getMasterRecordList.data);
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
          getErrorMessage('MstPatMemoMainComponent.vue', 'findList', '指定されたマスタが見つかりません。');
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
          if (error.response.status === 400) {
            this.$ons.notification.alert({
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
              // title: "取得失敗",
              // message: "指定されたマスタが見つかりません。"
              title: DIALOG_MESSAGES[12000003].title,
              message: messageFormat(DIALOG_MESSAGES[12000003].message),
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
            });
          }
        });
      // カラム定義情報を取得
      this.findColumnInfo();
    },
    // ダイアログ表示制御
    beforeSaveRecord() {
      // 変更済みセルの確認
      this.updatePatMemoInfo = this.findChangedValue();
      if (this.updatePatMemoInfo !== null) {
        this.isDialogVisible = true;
        this.messageCd = 60000004;
      } else {
        this.isUpdateAllPat = false;
        this.saveRecord();
      }
    },

    // 患者情報に上書きするフラグの設定
    setUpdateAllPatFlg(answer) {
      this.isDialogVisible = false;
      this.isUpdateAllPat = answer === "No";
      this.saveRecord();
    },

    async saveRecord() {
      // 共通ローダー:表示開始
      this.setLoadingScreenVisible(true);
      /* add スクロールの位置を維持 楊 start */
      this.storeDirectGridScrollPosition();
      this.preserveGridScrollAfterSave = true;
      /* add スクロールの位置を維持 楊 end */
      this.directGridWidget?.closeCell?.();
      // グリッドでエラーが発生している場合は処理を中断
      if (!this.validateDirectKendoGrid()) {
        // 共通ローダー：表示終了
        this.setLoadingScreenVisible(false);
        this.preserveGridScrollAfterSave = false;
        this.restoreDirectGridScrollPosition();
        return;
      }

      // 新規追加＆未入力のレコードを除外
      const records = this.getMasterRecordList;
      records.data = records.data.filter(
        r => !(r.operation === 1 && !r.edited)
      );

      // No昇順にソート
      // sortRankをNoと同じ値に書き換える
      for (let data of records.data) {
        data.sortRank = data.code;
      }

      this.setMasterRecordList(records);

      // 必須エラーをチェック
      const validateMessage = this.validateRequired();

      let message = "";
      if (validateMessage.length !== 0) {
        // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
        // message = "以下の列に未入力項目が存在します。" + validateMessage;
        message = messageFormat(DIALOG_MESSAGES[12000270].message) + validateMessage;
        // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
      }
      // エラーメッセージは左寄せで表示
      if (message.length !== 0) {
        //共通ローダー：表示終了
        this.setLoadingScreenVisible(false);
        this.preserveGridScrollAfterSave = false;
        this.restoreDirectGridScrollPosition();
        this.$ons.notification.alert({
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
          // title: "チェックエラー",
          title: DIALOG_MESSAGES["00300006"].title,
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
          message: '<div style="text-align:left;">' + message + "</div>"
        });
        return;
      }

      if (this.isUpdateAllPat) {
        // 患者情報の患者メモJSONを上書き
        await ApiHelper.post("/patInfo/updatePatMemo", {
          strSql: this.updatePatMemoInfo
          }).catch(
          error => {
            //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
            getErrorMessage('MstPatMemoMainComponent.vue', 'saveRecord', error);
            //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
            this.preserveGridScrollAfterSave = false;
            this.restoreDirectGridScrollPosition();
            //共通ローダー：表示終了
            this.setLoadingScreenVisible(false);
            throw new Error(error);
          }
        );
      }

      // null値があるか調べて、あったら空欄に変更する
      let updateRecords = this.getUpdateRecordList
      for (let record of updateRecords) {
        if (record.name === null) {
          record.name = "";
        }
      }

      // apiをコールして値を保存
      // add マスタ一覧 1･施設切替を可能とする 王
      // this.updateRecordList(updateRecords)
      this.updateRecordListByFacilityCd({facilityCd: this.getFacilitySwitch, request: updateRecords})
        .then(response => {
          this.updateResponse = response.data;

          this.$ons.notification.alert({
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
            // title: "更新完了",
            // message: "マスタ更新が完了しました。"
            title: DIALOG_MESSAGES[12000004].title,
            message: messageFormat(DIALOG_MESSAGES[12000004].message),
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
          });

          this.findList();
        })
        .catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
          getErrorMessage('MstPatMemoMainComponent.vue', 'setUpdateAllPatFlg', error);
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
          this.preserveGridScrollAfterSave = false;
          this.restoreDirectGridScrollPosition();
          if (error.response.status === 400) {
            this.$ons.notification.alert({
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
              // title: "更新失敗",
              title: DIALOG_MESSAGES["00300005"].title,
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
              message: error.response.data.errorMessage
            });
          }
        })
        // 共通ローダー：表示終了
        .finally(() => this.setLoadingScreenVisible(false));
    },
    findChangedValue() {
      let patMemoInfo = null;

      // 初期データ
      const initData = JSON.parse(this.comparisonRecordLocalModel);
      initData.sort(function(a,b){
        if( a.code < b.code) return -1;
        if( a.code > b.code) return 1;
        return 0;
      });

      // 編集中データ
      const gridData = this.getMasterRecordList;
      gridData.data.sort(function(a,b){
        if( a.code < b.code) return -1;
        if( a.code > b.code) return 1;
        return 0;
      });

      // 編集済みのセルを抽出してSQLを作成する
      for (let idx = 0; idx < gridData.data.length; idx++) {
        // 編集済みかつ編集中データが未削除
        if (this.isEdited(gridData.data[idx].code) && gridData.data[idx].isDisp === "1") {
          // 0始まりのJSON用index
          const jsonIdx = gridData.data[idx].code - 1;

          // タイトル列の編集SQL作成
          if (initData[idx].name !== gridData.data[idx].name) {
            // 空欄の場合は"null"にする（患者情報画面では空欄にするとnullで入力される）
            const convertedName = gridData.data[idx].name === "" ? "null" : `"${gridData.data[idx].name}"`;
            patMemoInfo = patMemoInfo === null ? "pat_memo_info," : patMemoInfo;
            patMemoInfo = `jsonb_set(${patMemoInfo} '{${jsonIdx}, title}', '${convertedName}'),`;
          }
          // 内容列の編集SQL作成
          if (initData[idx].content !== gridData.data[idx].content) {
            // 空欄の場合は"null"に、そうでない場合は改行を文字列"\n"に変換
            const convertedContent = gridData.data[idx].content === "" ? "null" : `"${gridData.data[idx].content.replace(/\r?\n/g, "\\n")}"`;
            patMemoInfo = patMemoInfo === null ? "pat_memo_info," : patMemoInfo;
            patMemoInfo = `jsonb_set(${patMemoInfo} '{${jsonIdx}, content}', '${convertedContent}'),`;
          }
        }
      }
      return patMemoInfo;
    },
    loadGridData() {
      // delete start #9590
      // this.setCondition(this.condition);
      // delete end #9590
      this.findList();
    },
    onBeforeEdit(e) {
      if (this.isMobileDevice && !this.allowEdit) {
        e.preventDefault();
        return;
      }
      this.editingFlg = true;
    },
    editEnd() {
      this.disconnectContentEditorResizeObserver();
      this.editingFlg = false;
    },
  },
  created() {
    this.setLoadingScreenVisible(true);
    this.calculateColumnsWidth();
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
    this.kendoValidator = { validate: () => this.validateDirectKendoGrid() };
  },
  mounted() {
    this.directGridMounted = true;
    this.$nextTick(() => {
      this.calculateColumnsWidth();
      this.calculateGridHeight();
      this.calculateGridWidth();
      this.initDirectGridIfReady();
      this.scheduleDirectGridLayoutContract();
    });
    EventBus.$on("refresh", this.refresh);
  },
  // add 性能改善メモリ不足 shan start
  beforeUnmount() {
    EventBus.$off("refresh", this.refresh);
    this.disconnectContentEditorResizeObserver();
    this.destroyDirectGrid();
    [
      this.directGridLayoutRafId,
      this.directGridFilterRefreshRafId,
      this.directGridScrollSyncRafId
    ].forEach(id => {
      if (id != null) {
        cancelAnimationFrame(id);
      }
    });
    this.directGridRowVisualRafIds?.forEach?.(id => cancelAnimationFrame(id));
    this.directGridRowVisualRafIds?.clear?.();
  }
  // add 性能改善メモリ不足 shan end
};
</script>

<!-- 個別スタイル定義 -->
<style scoped>
.ntss-list {
  height: 100%;
}
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
.csv-btn {
  margin-right: 1em;
}
.kendo-grid-toolbar-style {
  padding: 0.1em 0.3em;
}
.kendo-grid-toolbar-style :deep(.k-tooltip.k-tooltip-validation) {
  width: auto;
}
.content-style :deep(.k-grid-content) {
  white-space: pre-wrap;
}
/* Kendo 2026 では .k-grid td から overflow:hidden / text-overflow:ellipsis が削除されたため、
   非編集状態のセルでテキストが折り返して全表示される。
   Kendo 2019（Vue2）と同等の切り詰め表示を復元する。
   編集中（.k-edit-cell）は Kendo の overflow:visible ルールが優先されるため影響しない。 */
.content-style :deep(.k-grid-content td:not(.k-edit-cell)),
.content-style :deep(.k-grid-content .k-table-td:not(.k-edit-cell)) {
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.kendo-grid-toolbar-style :deep(.k-grid-header-locked > table) {
  border-right-width: 0px;
}
/* No列｜タイトル列の境界線: applyDirectGridLockedDividerContract で描画（Kendo 2026 対応） */
.kendo-grid-toolbar-style :deep(.mst-pat-memo-locked-divider-header),
.kendo-grid-toolbar-style :deep(.mst-pat-memo-locked-divider-body) {
  position: absolute;
  top: 0;
  right: 0;
  width: 1px;
  height: 100%;
  pointer-events: none;
  z-index: 2;
}
.kendo-grid-toolbar-style :deep(.k-grid-content-locked) {
  z-index: 1;
  overflow-y: scroll !important;
  -webkit-overflow-scrolling: touch;
  scrollbar-width: none;
  -ms-overflow-style: none;
}
.custom-switch {
  transform: scale(0.85);
  transform-origin: center;
  touch-action: manipulation;
}
.kendo-grid-toolbar-style :deep(.k-grid-content-locked::-webkit-scrollbar) {
  display: none;
}
.no-scroll {
  overflow-y: unset !important;
}
/* :deep(.k-textarea){
  min-height: 50px !important;
} */
.mst-pat-memo-direct-jq-grid {
  width: 100%;
}
/* Kendo 2026: 表体の列右余白が白(app-surface)になるため、Vue2 同等の灰色背景に戻す */
.kendo-grid-toolbar-style :deep(.mst-pat-memo-direct-jq-grid.k-grid),
.kendo-grid-toolbar-style :deep(.mst-pat-memo-direct-jq-grid .k-grid-content-locked),
.kendo-grid-toolbar-style :deep(.mst-pat-memo-direct-jq-grid .k-grid-content:not(.k-grid-content-locked)),
.kendo-grid-toolbar-style :deep(.mst-pat-memo-direct-jq-grid .k-grid-content .k-selectable) {
  background-color: var(--main-background-color) !important;
}
/* 表頭の列右余白は th と同じグラデーション背景（単色 #333 だと削除列より黒く見える） */
.kendo-grid-toolbar-style :deep(.mst-pat-memo-direct-jq-grid .k-grid-header),
.kendo-grid-toolbar-style :deep(.mst-pat-memo-direct-jq-grid .k-grid-header-wrap),
.kendo-grid-toolbar-style :deep(.mst-pat-memo-direct-jq-grid .k-grid-header-locked) {
  background-color: var(--master-maintenance-kgrid-header-background-color) !important;
  background-image: linear-gradient(rgba(255, 255, 255, 0.3) 0%, transparent 50%, transparent 50%, rgba(0, 0, 0, 0.1) 100%) !important;
}

/* Vue2 kendo-grid wrapper style contract for this direct jq screen. */
.kendo-grid-toolbar-style :deep(.toolbar-btn),
.kendo-grid-toolbar-style :deep(.toolbar-btn *) {
  font-family: inherit;
}
.kendo-grid-toolbar-style :deep(.k-grid-header th),
.kendo-grid-toolbar-style :deep(.k-grid-header .k-table-th),
.kendo-grid-toolbar-style :deep(.k-grid-header .k-link),
.kendo-grid-toolbar-style :deep(.k-grid-header-locked th),
.kendo-grid-toolbar-style :deep(.k-grid-header-locked .k-table-th),
.kendo-grid-toolbar-style :deep(.k-grid-header-locked .k-link) {
  border-right-color: currentColor;
  cursor: default;
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
