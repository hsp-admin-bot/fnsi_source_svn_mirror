/**
 * 自己診断判定マスタメンテナンスデータページ  MainContent
 */
<template>
  <div class="main-content-area master-maintenance-page">
    <div class="ntss-list ntss-new-width" :style="ntssListStyles">
      <div class="k-grid-toolbar k-header kendo-grid-toolbar-style" :style="heightStyles">
        <div id="grid-header" :class="['header-btn-area', 'right', isMobileDevice ? 'mobile-header' : '']">
          <v-ons-button v-show="!isSortMode && isAllowAddRecord" style="float: left;" modifier="outline" class="btn3-normal toolbar-btn" @click="addRow()">追加</v-ons-button>
          <v-ons-button modifier="outline" class="btn3-normal toolbar-btn csv-btn" style="margin-right:1em" v-show="!isSortMode && isAllowAddRecord && !iosFlg && !androidFlg && systemUseSetting !== '1'" @click="importCsv($event)">CSV取込</v-ons-button>
          <div v-show="isMobileDevice" class="custom-switch-wrapper">
            <label class="fab-font-color">編集</label>
            <v-ons-switch modifier="outline" v-model="allowEdit" />
          </div>
          <v-ons-button v-show="!isSortMode && isAllowSort" modifier="outline" class="btn3-normal toolbar-btn" @click="toRankEditBtnClick()">並び順表示</v-ons-button>
          <v-ons-button v-show="isSortMode && isAllowSort" modifier="outline" class="btn3-normal toolbar-btn" @click="sortBtnClick()">反映</v-ons-button>
        </div>
        <!-- ソート後グリッド表示 -->
        <div
          v-show="columns.length > 1"
          id="grid-font-size"
          ref="gridRoot"
          :class="[fontSizeSet, 'content-style', 'ntss-kendo-grid-legacy', 'mst-self-measure-result-direct-jq-grid']"
        ></div>
      </div>
      <div id="grid-footer">
        <v-ons-row :style="{ visibility:this.isSortMode ?  'hidden' : 'visible' }" width="100%">
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
import { bindGridEditorEnterToCloseCell } from "@/compat/kendo/grid-edit";
//FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
import { UFRC, BLOOD_LEAKAGE, DIALYSATE_FLOW_RATE, CONCENTRATION } from "@/constants/mstSelfMeasureResultDefine";
import { markRaw } from "@/compat/vue/runtime";
import kendo from "@progress/kendo-ui";
import $ from "jquery";

// 自己診断判定マスタ デフォルト値
const SELF_MEASURE_RESULT_ITEMS = [
  ...UFRC,
  ...BLOOD_LEAKAGE,
  ...DIALYSATE_FLOW_RATE,
  ...CONCENTRATION
];

/**
 * TODO
 * more: モーダルで編集した項目が、一覧上で「編集済み（三角マーク）」をつけたい。
 */
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
      kendoValidatorSetup: {
        rules: {},
        messages: {}
      },
      // 編集失敗時のマスタ/列/スキーマ情報のバックアップ
      backupMasterRecordList: [],
      //Android端末で編集中であることを示すフラグ
      editingFlg: false,
      androidFlg: false,
      iosFlg: false,
      scrollPosition: {
        top: 0,
        left: 0
      },
      scrollTop: 0,
      scrollLeft: 0,
      lastScrollTop: 0,
      lastScrollLeft: 0,
      columnWidth: 14,
      editFlg: false,
      masterCsvVisible: false,
      masterCsvTarget: null,
      //自画面の名称
      selfScreenName: "",
      allowEdit: true, // NOTE: true = 編集モード、 false = 閲覧モード
      directGridWidget: null,
      directGridMounted: false,
      directGridDataSource: null,
      directGridLayoutRafId: null,
      directGridFilterRefreshRafId: null,
      directGridScrollSyncRafId: null,
      directGridRowVisualRafIds: markRaw(new Map()),
      directGridSortEditedCodes: markRaw(new Set()),
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
    ...mapGetters("user", {
      systemUseSetting: "getSystemUseSetting"
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
      // #9275 自己診断判定マスタの並び順が保存できない linjunfeng start
      isRecordModified: "isRecordModified",
      // #9275 自己診断判定マスタの並び順が保存できない linjunfeng end
      comparisonRecordModel: "getComparisonRecordModel"
    }),

    heightStyles() {
      // main部の高さをCSS変数を利用して書き換え
      return { "--height": `${this.kendoGridToolbarHeight}px` };
    },
    ntssListStyles() {
      return { display: this.columns.length === 1 ? "none" : "inherit" };
    },
    fontSizeSet() {
      const names = ["small", "medium", "large", "x-large"];
      return `font-size-set-${names[this.getFontSize] || "medium"}`;
    },
    masterConditionSignature() {
      const condition = this.$store?.state?.["master-maintenance"]?.condition || this.condition || {};
      return `${condition.recordName || ""}|${condition.includeDeleted ? 1 : 0}`;
    },
    masterRecords() {
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
        // add #6279[自己診断判定マスタ] dengshen start
        this.kendoValidator !== undefined &&
        // add #6279[自己診断判定マスタ] dengshen end
        // #10053 破棄確認・保存活性(複数変更含む)・削除対応_自己診断判定マスタ 20240119 linjunfeng start
        // (data.filter(row => row.operation > 0).length ||
        // #10053 破棄確認・保存活性(複数変更含む)・削除対応_自己診断判定マスタ 20240119 linjunfeng end
          (data.filter(row => row.operation > 0 || row.edited || row.dirty).length ||
          this.isSorted ||
          // #9275 自己診断判定マスタの並び順が保存できない linjunfeng start
          this.isRecordModified || 
          // #9275 自己診断判定マスタの並び順が保存できない linjunfeng end
          !this.kendoValidator.validate())
      );
    },
    isMobileDevice() {
      return this.iosFlg || this.androidFlg;
    },
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
    EventBus.$on("onCloseMasterEditModal", this.onCloseMasterEditModal);
    EventBus.$on("refresh", this.refresh)
  },
  // add 性能改善メモリ不足 shan start
  beforeUnmount() {
    EventBus.$off("onCloseMasterEditModal", this.onCloseMasterEditModal);
    EventBus.$off("refresh", this.refresh);
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
  },
  // add 性能改善メモリ不足 shan end
  mounted() {
    this.directGridMounted = true;
    this.$nextTick(() => {
      this.calculateColumnsWidth();
      this.calculateGridHeight();
      this.calculateGridWidth();
      this.initDirectGridIfReady();
      this.scheduleDirectGridLayoutContract();
    });
  },

  methods: {
    ...mapActions("multi-modal", [
      "showMstSelfMeasureResultMainModal"
    ]),
    ...mapActions("master-maintenance", [
      "findRecordList",
      "findColumnInfo",
      "setMasterRecordList",
      "edit",
      "setComparisonRecordModel",
      "setCondition",
      "updateRecordList",
      "updateRecordListByFacilityCd",
      "setEditRecord",
      "editRecordBeEmpty",
      "findRecordListByFacilityCdWithSql",
    ]),
    ...mapActions("mst-self-measure-result", [
      "fetchMachineTypeList"
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
    validateDirectKendoGrid() {
      return true;
    },
    getColumnIndex(fieldName) {
      return this.columns.findIndex(e => e.field === fieldName);
    },
    getMaxSortRank() {
      const data = this.getFilteredMasterRecordList?.data || [];
      return data.length > 0 ? data.reduce((a, b) => Math.max(a, +b.sortRank || 0), 0) : 0;
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
      this.kendoGridToolbarHeight = Math.max(100, wh - headerHeight - footerMenuHeight);
      const gridFooter = document.getElementById("grid-footer");
      const gridHeader = document.getElementById("grid-header");
      this.kendoGridHeight = Math.max(160, this.kendoGridToolbarHeight - ((gridFooter?.clientHeight || 0) + (gridHeader?.clientHeight || 0)));
    },
    calculateGridWidth() {
      this.resizeDirectGrid();
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
    getGridContentEl() {
      return this.getDirectGridScrollContent();
    },
    getGridScrollHostEl() {
      return this.getDirectGridScrollContent();
    },
    getGridColumns() {
      return this.directGridWidget?.columns || [];
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
      content.scrollTop = position.top || 0;
      content.scrollLeft = position.left || 0;
      this.syncDirectGridLockedScrollPosition(content.scrollTop);
    },
    validateBeforeGridAction() {
      return this.kendoValidator?.validate?.() !== false;
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
        if (column.title === "詳細") {
          gridColumn.attributes = { class: "btn3-kendo-normal" };
          gridColumn.command = { text: "詳細", click: event => this.showMasterEditModal(event) };
        }
        if (column.title === "削除") {
          gridColumn.width = "9em";
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
        edit: event => this.onDirectGridEdit(event),
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
      const data = (this.getDirectGridDataSourceOption().data || []).map(record => clonePlain(record));
      grid.dataSource.data(data);
      if (resetScroll) {
        this.setGridScrollPosition({ top: 0, left: 0 });
      }
      this.$nextTick(() => {
        this.applyDirectGridStyleContract();
        this.refreshDirectGridDirtyVisualState();
      });
    },
    gridDataRefresh() {
      this.refreshDirectGridDataFromMasterRecords();
    },
    resizeDirectGrid() {
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
      this.syncDirectGridLockedScrollPosition();
    },
    scheduleDirectGridLayoutContract() {
      if (this.directGridLayoutRafId != null) {
        cancelAnimationFrame(this.directGridLayoutRafId);
      }
      this.directGridLayoutRafId = requestAnimationFrame(() => {
        this.directGridLayoutRafId = null;
        this.calculateColumnsWidth();
        this.calculateGridHeight();
        this.resizeDirectGrid();
        this.applyDirectGridStyleContract();
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
    onDirectGridDataBound(event) {
      this.applyDirectGridStyleContract();
      const position = this.getGridScrollPosition();
      if (position.top !== 0) {
        this.lastScrollTop = position.top;
      }
      if (position.left !== 0) {
        this.lastScrollLeft = position.left;
      }
      this.autoFitGridColumns();
    },
    onDirectGridSave(event) {
      const model = event?.model;
      if (!model) {
        return;
      }
      const field = this.getDirectGridFieldFromEvent(event);
      const values = { ...(event?.values || {}) };
      if (field && Object.keys(values).length === 0) {
        const value = this.readDirectGridEditorValue(event?.container?.[0] || event?.container);
        if (value !== undefined) {
          values[field] = value;
        }
      }
      Object.keys(values).forEach(key => {
        if (typeof model.set === "function") {
          model.set(key, values[key]);
        } else {
          model[key] = values[key];
        }
      });
      if (model.operation === 1) {
        model.edited = true;
      }
      const updatedRecord = this.getDirectGridModelPlain(model, values);
      if (this.isSortMode && Object.prototype.hasOwnProperty.call(values, "sortRank")) {
        this.setDirectGridSortManuallyEdited(updatedRecord, this.isSortRankChangedFromSnapshot(updatedRecord));
      }
      this.edit({ editRecord: updatedRecord, isSortMode: this.isSortMode });
      this.scheduleDirectGridRowVisualState(updatedRecord, model?.uid);
    },
    parseComparisonRecordModel() {
      try {
        return JSON.parse(this.comparisonRecordModel || "[]");
      } catch (_error) {
        return [];
      }
    },
    findOriginalRecord(record) {
      if (!record || record.code === undefined || record.code === null) {
        return null;
      }
      return this.parseComparisonRecordModel().find(item => String(item.code) === String(record.code)) || null;
    },
    compareSortRankValues(a, b) {
      const numA = Number(a);
      const numB = Number(b);
      if (!Number.isNaN(numA) && !Number.isNaN(numB)) {
        return numA === numB;
      }
      return String(a) === String(b);
    },
    isSortRankChangedFromSnapshot(record) {
      const original = this.findOriginalRecord(record);
      return original ? !this.compareSortRankValues(record.sortRank, original.sortRank) : false;
    },
    getDirectGridRecordKey(record) {
      if (!record || record.code === undefined || record.code === null) {
        return null;
      }
      return String(record.code);
    },
    setDirectGridSortManuallyEdited(record, edited) {
      const key = this.getDirectGridRecordKey(record);
      if (!key) {
        return;
      }
      edited ? this.directGridSortEditedCodes.add(key) : this.directGridSortEditedCodes.delete(key);
    },
    isDirectGridSortManuallyEdited(record) {
      const key = this.getDirectGridRecordKey(record);
      return !!key && this.directGridSortEditedCodes.has(key);
    },
    getDirectGridModelPlain(model, overrides = {}) {
      const plain = typeof model?.toJSON === "function" ? model.toJSON() : clonePlain(model || {});
      Object.keys(overrides || {}).forEach(key => {
        plain[key] = overrides[key];
      });
      return plain;
    },
    readDirectGridEditorValue(container) {
      const input = container?.querySelector?.("input");
      if (!input) {
        return undefined;
      }
      const value = input.value;
      const numeric = Number(value);
      return value !== "" && !Number.isNaN(numeric) ? numeric : value;
    },
    getDirectGridFieldFromCell(cell) {
      const colIndex = Number(cell?.getAttribute?.("aria-colindex")) - 1;
      if (!Number.isFinite(colIndex) || colIndex < 0) {
        return null;
      }
      return this.columns[colIndex]?.field || null;
    },
    getDirectGridFieldFromEvent(ev) {
      const activeField = ev?.sender?.editable?.options?.fields?.field;
      return activeField || this.getDirectGridFieldFromCell(ev?.container?.[0] || ev?.container);
    },
    getDirectGridRowsByRecord(record, preferredUid = null) {
      const root = this.getGridRootEl();
      const grid = this.directGridWidget;
      if (!root || !grid || !record) {
        return [];
      }
      if (preferredUid) {
        const rows = Array.from(root.querySelectorAll(`tr[data-uid="${preferredUid}"]`));
        if (rows.length) {
          return rows;
        }
      }
      if (record.uid) {
        const rows = Array.from(root.querySelectorAll(`tr[data-uid="${record.uid}"]`));
        if (rows.length) {
          return rows;
        }
      }
      if (record.code === undefined || record.code === null) {
        return [];
      }
      return Array.from(root.querySelectorAll("tbody tr[data-uid]")).filter(row => {
        try {
          const item = grid.dataItem?.(row);
          return item && String(item.code) === String(record.code);
        } catch (_error) {
          return false;
        }
      });
    },
    getDirectGridCellsByField(rows, fieldName) {
      return (rows || [])
        .map(row => this.findDirectGridCellForField(row, fieldName))
        .filter(Boolean);
    },
    resolveDirectGridCellByColumnField(row, fieldName) {
      const grid = this.directGridWidget;
      if (!row || !fieldName || !Array.isArray(grid?.columns)) {
        return null;
      }
      const isLockedRow = !!row.closest?.(".k-grid-content-locked");
      let visibleCellIndex = 0;
      for (let columnIndex = 0; columnIndex < grid.columns.length; columnIndex++) {
        const column = grid.columns[columnIndex];
        if (column.hidden) {
          continue;
        }
        const inThisRow = !!column.locked === isLockedRow;
        if (!inThisRow) {
          continue;
        }
        if (column.field === fieldName) {
          const cells = Array.from(row.children || []);
          const ariaColIndex = String(columnIndex + 1);
          const byAria = cells.find(cell => cell.getAttribute("aria-colindex") === ariaColIndex);
          if (byAria) {
            return byAria;
          }
          return cells[visibleCellIndex] || null;
        }
        visibleCellIndex += 1;
      }
      return null;
    },
    findDirectGridCellForField(row, fieldName) {
      if (!row || !fieldName) {
        return null;
      }
      const escapedField = typeof CSS !== "undefined" && CSS.escape
        ? CSS.escape(String(fieldName))
        : String(fieldName).replace(/["\\]/g, "\\$&");
      const dataFieldCell = row.querySelector(
        `td[data-field="${escapedField}"], .k-table-td[data-field="${escapedField}"]`
      );
      if (dataFieldCell) {
        return dataFieldCell;
      }
      return this.resolveDirectGridCellByColumnField(row, fieldName);
    },
    markDirectGridDirtyCell(cell) {
      if (!cell?.classList) {
        return;
      }
      cell.classList.add("k-dirty-cell", "master-edited-cell");
      if (cell.querySelector(".k-dirty")) {
        return;
      }
      const marker = cell.ownerDocument?.createElement("span");
      if (!marker) {
        return;
      }
      marker.className = "k-dirty";
      cell.insertBefore(marker, cell.firstChild || null);
    },
    getDirectGridChangedFields(record) {
      if (!record) {
        return [];
      }
      const skip = new Set(["sortRank", "sortInputTime", "dummy", "uid"]);
      const original = this.findOriginalRecord(record);
      if (!original) {
        return [];
      }
      return (this.columns || [])
        .map(column => column.field)
        .filter(field => field && !skip.has(field))
        .filter(field => String(record[field] ?? "") !== String(original[field] ?? ""));
    },
    syncDirectGridDirtyCellMarkers(record, rows) {
      const { lockedRows, scrollableRows } = this.splitDirectGridRows(rows);
      this.getDirectGridChangedFields(record).forEach(field => {
        const column = (this.columns || []).find(item => item.field === field);
        const targetRows = column?.locked ? lockedRows : scrollableRows;
        this.getDirectGridCellsByField(targetRows.length ? targetRows : rows, field).forEach(cell => {
          this.markDirectGridDirtyCell(cell);
        });
      });
    },
    clearDirectGridRowVisualState(rows) {
      rows.forEach(row => {
        row.classList.remove("k-dirty-row", "master-edited-row");
        Array.from(row.children || []).forEach(cell => {
          cell.classList.remove(
            "master-edited-cell",
            "master-edited-row",
            "master-sort-edited",
            "k-dirty-cell"
          );
          cell.querySelectorAll?.(".k-dirty")?.forEach?.(element => element.remove());
        });
      });
    },
    splitDirectGridRows(rows) {
      const lockedRows = [];
      const scrollableRows = [];
      (rows || []).forEach(row => {
        if (row?.closest?.(".k-grid-content-locked")) {
          lockedRows.push(row);
        } else {
          scrollableRows.push(row);
        }
      });
      return { lockedRows, scrollableRows };
    },
    hasDirectGridNonSortChanges(record) {
      return (
        this.getDirectGridChangedFields(record).length > 0
        || !!(record?.code != null && this.isEdited(record.code))
      );
    },
    clearDirectGridRowSelection(rows) {
      (rows || []).forEach(row => {
        row.classList.remove("k-selected", "k-state-selected", "k-focus", "k-state-focused");
        row.removeAttribute?.("aria-selected");
        Array.from(row.children || []).forEach(cell => {
          cell.classList.remove("k-selected", "k-state-selected", "k-focus", "k-state-focused");
          cell.removeAttribute?.("aria-selected");
        });
      });
    },
    applyDirectGridRowVisualState(record, preferredUid = null, resolvedRows = null) {
      if (!record) {
        return;
      }
      const rows = resolvedRows || this.getDirectGridRowsByRecord(record, preferredUid);
      if (!rows.length) {
        return;
      }
      this.clearDirectGridRowVisualState(rows);
      const changed = this.hasDirectGridNonSortChanges(record);
      const sortChanged = this.isDirectGridSortManuallyEdited(record);
      if (!changed && !sortChanged) {
        this.clearDirectGridRowSelection(rows);
        return;
      }
      const sortRankIndex = this.getColumnIndex("sortRank");
      const dummyIndex = this.getColumnIndex("dummy");
      const { lockedRows, scrollableRows } = this.splitDirectGridRows(rows);
      if (changed) {
        lockedRows.forEach(row => {
          row.classList.add("k-dirty-row");
          Array.from(row.children || []).forEach((cell, index) => {
            const colIndex = Number(cell.getAttribute("aria-colindex")) - 1;
            const effectiveIndex = Number.isFinite(colIndex) ? colIndex : index;
            if (effectiveIndex > sortRankIndex && effectiveIndex !== dummyIndex) {
              cell.classList.add("master-edited-row");
            }
          });
        });
        scrollableRows.forEach(row => {
          row.classList.add("k-dirty-row");
          Array.from(row.children || []).forEach(cell => {
            cell.classList.add("master-edited-row");
          });
        });
        this.syncDirectGridDirtyCellMarkers(record, rows);
      }
      if (sortChanged) {
        // sortRank / dummy は locked 列のみ。scrollable 行に渡すと aria-colindex ずれで対象機種等が誤マークされる。
        const sortRows = lockedRows.length ? lockedRows : rows;
        this.getDirectGridCellsByField(sortRows, "sortRank").forEach(cell => {
          this.markDirectGridDirtyCell(cell);
          cell.classList.add("master-sort-edited");
        });
        this.getDirectGridCellsByField(sortRows, "dummy").forEach(cell => {
          cell.classList.add("master-sort-edited");
        });
      }
      this.clearDirectGridRowSelection(rows);
    },
    scheduleDirectGridRowVisualState(record, preferredUid = null) {
      if (!this.directGridRowVisualRafIds) {
        this.directGridRowVisualRafIds = markRaw(new Map());
      }
      const key = String(preferredUid || record?.uid || record?.code || "__row__");
      const oldRaf = this.directGridRowVisualRafIds.get(key);
      if (oldRaf != null) {
        cancelAnimationFrame(oldRaf);
      }
      const rafId = requestAnimationFrame(() => {
        requestAnimationFrame(() => {
          this.directGridRowVisualRafIds.delete(key);
          this.applyDirectGridRowVisualState(record, preferredUid);
        });
      });
      this.directGridRowVisualRafIds.set(key, rafId);
    },
    buildDirectGridRowsByCodeMap() {
      const root = this.getGridRootEl();
      const grid = this.directGridWidget;
      const result = new Map();
      if (!root || !grid) {
        return result;
      }
      Array.from(root.querySelectorAll("tbody tr[data-uid]")).forEach(row => {
        let item = null;
        try {
          item = grid.dataItem?.(row);
        } catch (_error) {
          item = null;
        }
        if (item?.code === undefined || item?.code === null) {
          return;
        }
        const key = String(item.code);
        if (!result.has(key)) {
          result.set(key, []);
        }
        result.get(key).push(row);
      });
      return result;
    },
    refreshDirectGridDirtyVisualState() {
      const rowsByCode = this.buildDirectGridRowsByCodeMap();
      (this.getMasterRecordList?.data || []).forEach(record => {
        const rows = rowsByCode.get(String(record.code));
        if (rows?.length) {
          this.applyDirectGridRowVisualState(record, null, rows);
        }
      });
    },
    editBackgroundColor() {
      this.refreshDirectGridDirtyVisualState();
    },
    onDirectGridEdit(event) {
      if (this.isMobileDevice && !this.allowEdit) {
        return;
      }
      bindGridEditorEnterToCloseCell(event?.sender || this.directGridWidget, event?.container);
      const field = this.getDirectGridFieldFromEvent(event);
      const cell = event?.container?.[0] || event?.container;
      const input = cell?.querySelector?.("input");
      if (!field || !cell || !input) {
        return;
      }
      const onInput = () => {
        const value = this.readDirectGridEditorValue(cell);
        const visualRecord = this.getDirectGridModelPlain(event.model, { [field]: value });
        if (this.isSortMode && field === "sortRank") {
          this.setDirectGridSortManuallyEdited(visualRecord, this.isSortRankChangedFromSnapshot(visualRecord));
        }
        this.applyDirectGridRowVisualState(visualRecord, event?.model?.uid);
      };
      input.addEventListener("input", onInput, { passive: true });
      input.addEventListener("change", onInput, { passive: true });
      setTimeout(onInput, 0);
    },
    autoFitGridColumn(column) {
      try {
        this.directGridWidget?.autoFitColumn?.(column);
      } catch (_error) {
        // noop
      }
    },
    autoFitGridColumns() {
      const columns = this.getGridColumns();
      for (let i = 0; i < columns.length; i++) {
        if (["name", "content"].includes(columns[i]?.field)) {
          this.autoFitGridColumn(columns[i]);
        }
      }
    },
    syncDirectGridColumnStateToWidget() {
      const grid = this.directGridWidget;
      if (!grid || !Array.isArray(grid.columns)) {
        return;
      }
      this.columns.forEach(column => {
        const gridColumn = grid.columns.find(col => col.field === column.field);
        if (gridColumn) {
          gridColumn.editable = column.editable;
        }
      });
    },
    editableColumns() {
      this.columns.forEach(column => {
        column.editable = column.field === "sortRank" ? () => false : column.originalEditable ? () => true : () => false;
      });
      this.syncDirectGridColumnStateToWidget();
    },
    disableColumns() {
      this.columns.forEach(column => {
        column.editable = column.field === "sortRank" ? (this.isAllowSort ? () => true : () => false) : () => false;
      });
      this.syncDirectGridColumnStateToWidget();
    },
    setDirectGridColumnHidden(field, hidden) {
      const grid = this.directGridWidget;
      if (!grid) {
        return;
      }
      const column = (grid.columns || []).find(item => item.field === field);
      if (!column || !!column.hidden === !!hidden) {
        return;
      }
      hidden ? grid.hideColumn(field) : grid.showColumn(field);
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
      this.setDirectGridColumnHidden("sortRank", !!sortRank?.hidden);
      this.setDirectGridColumnHidden("dummy", !!dummy?.hidden);
      this.syncDirectGridColumnStateToWidget();
      this.applyDirectGridStyleContract();
    },
    syncDirectGridSortValuesToMasterRecords() {
      const data = this.directGridWidget?.dataSource?.data?.();
      if (!data || !Array.isArray(this.getMasterRecordList?.data)) {
        return;
      }
      const rows = typeof data.toJSON === "function" ? data.toJSON() : Array.from(data);
      rows.forEach((row, index) => {
        const target = this.getMasterRecordList.data.find(record => String(record.code) === String(row.code)) || this.getMasterRecordList.data[index];
        if (target && row.sortRank !== undefined) {
          target.sortRank = row.sortRank;
          target.sortInputTime = row.sortInputTime || Date.now();
        }
      });
    },
    sort() {
      const list = this.getMasterRecordList?.data || [];
      list.sort((a, b) => a.sortRank - b.sortRank || (a.sortInputTime || 0) - (b.sortInputTime || 0));
      for (let i = 0; i < list.length; i++) {
        if (list[i].isDisp === "1") {
          list[i].sortRank = i + 1;
        }
      }
    },
    sortChange(tempData) {
      let flag = false;
      const list = this.getMasterRecordList?.data || [];
      list.forEach(item => {
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
    },
    sortBtnClick() {
      try {
        this.directGridWidget?.closeCell?.();
      } catch (_error) {
        // noop
      }
      this.syncDirectGridSortValuesToMasterRecords();
      (this.getMasterRecordList?.data || []).forEach(record => {
        this.setDirectGridSortManuallyEdited(record, this.isSortRankChangedFromSnapshot(record));
      });
      const tempData = clonePlain(this.getMasterRecordList?.data || []);
      this.isSortMode = false;
      this.editableColumns();
      this.showSortColumn();
      this.sort();
      this.isSorted = this.sortChange(tempData);
      this.refreshDirectGridDataFromMasterRecords();
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
    validateComboValue() {
      const comboFields = this.columns.filter(column => column.values != null);
      const validateMessageArr = [];
      (this.getMasterRecordList?.data || []).filter(row => row.isDisp !== "0" && row.isDel === "0").forEach(row => {
        comboFields.forEach(combo => {
          const value = row[combo.field];
          const isEmpty = value === null || value === undefined || value === "" || value === "null";
          if (!isEmpty && !(combo.values || []).some(item => String(item.value) === String(value))) {
            validateMessageArr.push(combo.title);
          }
        });
      });
      return this.convertToStr(validateMessageArr);
    },
    normalization(items) {
      const columnNames = (this.columnDefinition || this.columns || []).map(column => column.field);
      return Object.keys(items || {}).filter(key => columnNames.includes(key) || key === "isAddRow").reduce((acc, key) => {
        acc[key] = items[key];
        return acc;
      }, {});
    },
    resolveEditRecordForModal(selectedRowItem) {
      if (!selectedRowItem) {
        return null;
      }
      let code = selectedRowItem.code;
      if (code === undefined || code === null || code === "") {
        this.edit({ editRecord: selectedRowItem, isSortMode: this.isSortMode });
        code = selectedRowItem.code;
      }
      const storeRecord = (this.getMasterRecordList?.data || []).find(
        record => String(record.code) === String(code)
      );
      const source = storeRecord
        ? clonePlain(storeRecord)
        : clonePlain(typeof selectedRowItem.toJSON === "function" ? selectedRowItem.toJSON() : selectedRowItem);
      const normalizedItem = this.normalization(source);
      ["machineInfo", "selfMeasureResult", "dispMachineName", "operation", "edited", "code"].forEach(field => {
        if (source[field] !== undefined && normalizedItem[field] === undefined) {
          normalizedItem[field] = source[field];
        }
      });
      if (storeRecord?.code !== undefined) {
        normalizedItem.code = storeRecord.code;
      }
      return normalizedItem;
    },
    importCsv(event = null) {
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
    onCloseMasterEditModal() {
      this.$nextTick(() => {
        this.refreshDirectGridDataFromMasterRecords();
        this.setGridScrollPosition({ top: this.scrollTop || 0, left: this.scrollLeft || 0 });
      });
    },
    refresh() {
      if (this.selfScreenName === this.getCurrentRouteName() && document.getElementsByTagName("ons-alert-dialog").length === 0) {
        if (this.isChanged) {
          this.$ons.notification.confirm({
            title: DIALOG_MESSAGES[13000004].title,
            message: messageFormat(DIALOG_MESSAGES[13000004].message),
            callback: answer => {
              if (answer === 1) {
                this.findList();
              }
            }
          });
        } else {
          this.findList();
        }
      }
    },

    /**
     * @description 内容列のkendo editor
     */
    // contentEditor(container, data) {
    //   $(
    //     `<textarea name="${data.field}" class="k-valid k-textarea" style="font-size: 1.0em;"/>`
    //   ).appendTo(container);
    //   this.$refs.grid.kendoWidget().autoFitColumn(
    //     this.columns.findIndex(c => c.field === data.field)
    //   );
    //   this.calculateGridWidth();
    // },
    // データの取得
    loadGridData() {
      // delete start #9590
      // this.setCondition(this.condition);
      // delete end #9590
      this.findList();
    },
    // マスタ一覧のデータを取得
    async findList() {
      // 型式一覧を取得
      await this.fetchMachineTypeList();
      // apiをコールして値を取得
      // add マスタ一覧 1･施設切替を可能とする 王
      // this.findRecordList()
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
            if (column.field === "dispMachineName") {
              column.width = "25em";
            } else {
              column.width = "8em";
            }
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
            editable: () => false,
            locked: true,
            width: "10px",
            format: "",
            values: null
          });
          // 初期データ内容を保存
          this.setComparisonRecordModel();
          this.directGridSortEditedCodes.clear();
          // カラム幅等初期調整
          this.showSortColumn();

          this.$nextTick(() => {
            this.calculateGridHeight();
            this.calculateGridWidth();
            this.initDirectGridIfReady();
            this.refreshDirectGridDataFromMasterRecords();
            // 元のスクロール位置に移動
            // mod スクロールの位置を維持
            this.setGridScrollPosition({ top: this.scrollTop, left: this.scrollLeft });
            this.scheduleDirectGridLayoutContract();
            // 保存後のフィルタ再適用(resetScroll)やレイアウト再構築(setOptions/resize)が
            // 複数フレームにまたがってスクロールを先頭へ戻すため、2フレーム分だけ位置を再適用する。
            // setGridScrollPosition はスクロール値を設定するだけで新たなスクロールバーは生成しない。
            const keepScrollTop = this.scrollTop;
            const keepScrollLeft = this.scrollLeft;
            const restoreScroll = () => this.setGridScrollPosition({ top: keepScrollTop, left: keepScrollLeft });
            requestAnimationFrame(() => {
              restoreScroll();
              requestAnimationFrame(restoreScroll);
            });
            setTimeout(() => {
              this.scrollTop = 0;
              this.scrollLeft = 0;
            }, 1000);
            // mod スクロールの位置を維持
          });
        })
        .catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
          getErrorMessage('MstSelfMeasureResultMainComponent.vue', 'findList', '指定されたマスタが見つかりません。');
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

    showMasterEditModal(e){
      // モーダル確定時にスクロール位置が戻ってしまう問題の対処
      const grid = this.getGridContentEl();
      this.scrollTop = grid?.scrollTop || 0;
      this.scrollLeft = grid?.scrollLeft || 0;
      this.editFlg = true;
      /**
       * 「詳細」ボタンを押下したレコードのデータを取得する。
       * see: https://www.telerik.com/forums/selected-row-at-wrappers-for-vue
       */
      e.preventDefault();
      const row = this.getGridWidget();
      const selectedRowItem = row?.dataItem?.(e.currentTarget.closest("tr"));
      const normalizedItem = this.resolveEditRecordForModal(selectedRowItem);
      if (!normalizedItem) {
        return;
      }

      // store の最新データを setEditRecord してからモーダルを開く
      this.setEditRecord(normalizedItem);
      this.showMstSelfMeasureResultMainModal();
    },
    saveRecord() {
      // 共通ローダー:表示開始
      this.setLoadingScreenVisible(true);
      // モーダル確定時にスクロール位置が戻ってしまう問題の対処
      const grid = this.getGridContentEl();
      this.scrollTop = grid?.scrollTop || 0;
      this.scrollLeft = grid?.scrollLeft || 0;
      this.editFlg = true;
      try {
        this.directGridWidget?.closeCell?.();
      } catch (_error) {
        // noop
      }
      this.syncDirectGridSortValuesToMasterRecords();
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
        // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
        // message = "以下の列に未入力項目が存在します。" + validateMessage;
        message = messageFormat(DIALOG_MESSAGES[12000270].message) + validateMessage;
        // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
      }
      if (validateComboMessage.length !== 0) {
        if (message.length !== 0) message = message + "</br>";
        message =
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
          // message + "以下の列の選択を見直してください。" + validateComboMessage;
          message +  messageFormat(DIALOG_MESSAGES[12000006].message) + validateComboMessage;
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
      }
      // エラーメッセージは左寄せで表示
      if (message.length !== 0) {
        //共通ローダー：表示終了
        this.setLoadingScreenVisible(false);
        this.$ons.notification.alert({
           // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
            // title: "チェックエラー",
            title: DIALOG_MESSAGES[12000006].title,
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
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
          this.directGridSortEditedCodes.clear();

          this.findList();
        })
        .catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
          getErrorMessage('MstSelfMeasureResultMainComponent.vue', 'saveRecord', error);
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
    addRow() {
      // グリッドでエラーが発生している場合は処理を中断
      if (!this.validateBeforeGridAction()) {
        return;
      }

      // 空レコードをストアに登録
      let d = new Object();
      const fields = this.getMasterRecordList.schema.model.fields;

      // 初期値を設定
      Object.keys(fields).forEach(k => {
        if (fields[k].defaultValue) {
          d[k] = fields[k].defaultValue;
        } else if (fields[k].type === "string") {
          d[k] = "";
        } else if (fields[k].type === "number") {
          d[k] = 0;
        } else if (fields[k].type === "date") {
          d[k] = new Date();
        } else {
          d[k] = null;
        }

        if (k === "sortRank") {
          d[k] = this.getMaxSortRank() + 1;
        } else if (k === "machineInfo") {
          d[k] = "[]"
        } else if (k === "selfMeasureResult") {
          // デフォルト値を展開
          const selfMeasureResult = SELF_MEASURE_RESULT_ITEMS.map(item => ({
            key: item.jsonAddress,
            judge: "0",
            caution_up: item.default_caution_up,
            failure_up: item.default_failure_up,
            caution_low: item.default_caution_low,
            failure_low: item.default_failure_low
          }));
          d[k] = JSON.stringify(selfMeasureResult);
        }
      });
      this.lastScrollTop = this.getGridScrollHostEl()?.scrollHeight;
      // 画面編集内容をstoreに反映 ※新規レコード追加
      this.edit({ editRecord: d, isSortMode: this.isSortMode });
      this.refreshDirectGridDataFromMasterRecords();
      this.$nextTick(() => {
        const content = this.getDirectGridScrollContent();
        if (content) {
          content.scrollTop = content.scrollHeight;
          content.scrollLeft = 0;
          this.syncDirectGridLockedScrollPosition(content.scrollTop);
        }
        this.editBackgroundColor();
      });
    },
    onBeforeEdit(e) {
      if (this.isMobileDevice && !this.allowEdit) {
        e.preventDefault();
        return;
      }
      this.editingFlg = true;
    },
    editEnd(ev) {
      this.editingFlg = false;
      if (ev?.model) {
        const record = this.getDirectGridModelPlain(ev.model);
        this.scheduleDirectGridRowVisualState(record, ev.model.uid);
      } else {
        this.$nextTick(() => {
          this.refreshDirectGridDirtyVisualState();
        });
      }
    },
  }
};
</script>

<!-- 個別スタイル定義 -->
<style>
.ntss-new-width .k-grid-edit-row td>.k-widget.k-tooltip-validation:not(.k-switch), .k-edit-cell>.k-widget.k-tooltip-validation:not(.k-switch) {
  width: 170px;
}

</style>
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
.content-style :deep(.k-grid-content) {
  white-space: pre-wrap;
}
.custom-switch-wrapper {
  display: flex;
  float: left;
  align-items: center;
  min-width: 7em;
  margin-left: 10px;
}
.custom-switch {
  transform: scale(0.85);
  transform-origin: center;
  touch-action: manipulation;
}
.mobile-header {
  min-height: 35px; /* モバイル用の高さ */
}

.mst-self-measure-result-direct-jq-grid {
  width: 100%;
}

.mst-self-measure-result-direct-jq-grid :deep(td.master-edited-row),
.mst-self-measure-result-direct-jq-grid :deep(tr.k-selected > td.master-edited-row),
.mst-self-measure-result-direct-jq-grid :deep(tr.k-state-selected > td.master-edited-row),
.mst-self-measure-result-direct-jq-grid :deep(tr.k-table-row.k-selected > td.master-edited-row) {
  color: #003300 !important;
  background-color: #ccffcc !important;
}

.mst-self-measure-result-direct-jq-grid :deep(td.master-sort-edited),
.mst-self-measure-result-direct-jq-grid :deep(td.master-sort-edited.master-edited-cell),
.mst-self-measure-result-direct-jq-grid :deep(tr.k-selected > td.master-sort-edited),
.mst-self-measure-result-direct-jq-grid :deep(tr.k-state-selected > td.master-sort-edited),
.mst-self-measure-result-direct-jq-grid :deep(tr.k-table-row.k-selected > td.master-sort-edited),
.mst-self-measure-result-direct-jq-grid :deep(tr.k-grid-edit-row > td.master-sort-edited) {
  color: #000000 !important;
  background-color: #ffff66 !important;
}

.mst-self-measure-result-direct-jq-grid :deep(td.master-edited-cell.master-sort-edited) {
  color: #003300 !important;
  font-weight: bold !important;
}

.mst-self-measure-result-direct-jq-grid :deep(td.master-edited-cell) {
  color: #003300 !important;
  font-weight: bold !important;
  position: relative;
}
.mst-self-measure-result-direct-jq-grid :deep(.k-dirty) {
  display: none;
}
.mst-self-measure-result-direct-jq-grid :deep(td.k-dirty-cell .k-dirty),
.mst-self-measure-result-direct-jq-grid :deep(td.master-edited-cell .k-dirty) {
  display: block;
}

/* Vue2 kendo-grid wrapper style contract for this direct jq screen. */
.kendo-grid-toolbar-style > * + * {
  margin-left: .375rem;
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
