/**
 * 車いすマスタメンテナンスデータページ  MainContent
 */
<template>
  <div class="main-content-area master-maintenance-page">
    <div class="ntss-list" ref="ntssList" :style="ntssListStyles">
      <div class="k-grid-toolbar k-header kendo-grid-toolbar-style" :style="heightStyles">
        <div id="grid-header" :class="['header-btn-area', 'right', isMobileDevice ? 'mobile-header' : '']">
          <v-ons-button modifier="outline" class="btn3-normal toolbar-btn" style="float: left;" v-show="!isSortMode && isAllowAddRecord" @click="addRow()">追加</v-ons-button>
          <v-ons-row v-show="isMobileDevice" style="float: left; width: 7em; height: 1em;">
            <v-ons-col width="45%" vertical-align="center">
              <label class="fab-font-color">編集</label>
            </v-ons-col>
            <v-ons-col width="55%" vertical-align="center">
              <v-ons-switch modifier="outline" v-model="allowEdit" />
            </v-ons-col>
          </v-ons-row>
          <v-ons-button modifier="outline" class="btn3-normal toolbar-btn csv-btn" style="margin-right: 10px;" v-show="!isSortMode && isAllowSort" @click="importCsv($event)">CSV取込</v-ons-button>
          <v-ons-button modifier="outline" class="btn3-normal toolbar-btn" v-show="!isSortMode && isAllowSort" @click="toRankEditBtnClick()">並び順表示</v-ons-button>
          <v-ons-button modifier="outline" class="btn3-normal toolbar-btn" v-show="isSortMode && isAllowSort" @click="sortBtnClick()">反映</v-ons-button>
        </div>
        <div
          style="clear: both"
          v-show="columns.length > 1"
          id="grid-font-size"
          ref="gridRoot"
          :class="[fontSizeSet, 'ntss-kendo-grid-legacy', 'mst-wheel-chair-direct-jq-grid']"
        ></div>
      </div>
      <div id="grid-footer">
        <v-ons-row width="100%" :style="{ visibility: isSortMode ? 'hidden' : 'visible' }">
          <v-ons-col width="50%">
            <v-ons-button class="btn2-cancel button denial-btn" style="width: auto;" @click="cancel">キャンセル</v-ons-button>
          </v-ons-col>
          <v-ons-col width="50%" class="right">
            <v-ons-button class="btn1-execute button registration-btn" style="width: auto;" :disabled="!isChanged" @click="saveRecord">保存</v-ons-button>
          </v-ons-col>
        </v-ons-row>
      </div>
    </div>
    <master-csv
      :popoverVisible="masterCsvVisible"
      :popoverTarget="masterCsvTarget"
      @popover-close="prehideCsvPopover"
    />
  </div>
</template>

<script>
import { mapActions, mapGetters } from "@/compat/vue/vuex";
import { markRaw } from "@/compat/vue/runtime";
import { EventBus } from "@/compat/vue/event-bus.js";
import kendo from "@progress/kendo-ui";
import $ from "jquery";
import MasterCsvComponent from "@/components/master-maintenance/MasterCsvComponent";
//FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
import { deepCopy } from "@/functions/common/CommonFunctions";
import MasterMaintenanceMixin from "@/components/master-maintenance/MasterMaintenanceMixin";
import {
  createJQueryValidator,
  destroyJQueryValidator,
} from "@/compat/kendo/kendo-jquery.js";
import { getGridEditorDropDownListWidget } from "@/compat/kendo/grid-edit";
// バリデーション tooltip の callout（赤角標）追加用。表示位置調整のみで検証ロジックは変更しない。
import { appendValidationCallout } from "@/compat/kendo/validator.js";
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end

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
          editable: () => true,
          values: null
        }
      ],
      // 初期状態のcolumnsを保持
      _initialColumns: [],
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
      lastScrollTop: 0,
      lastScrollLeft: 0,
      preserveGridScrollAfterSave: false,
      facilitylistValue: "",
      masterCsvVisible: false,
      masterCsvTarget: null,
      getMasterRecordListOld: null,
      pageTypeName: 'MstWheelChairMainComponent',
      allowEdit: true, // NOTE: true = 編集モード、 false = 閲覧モード
      directGridWidget: null,
      directGridMounted: false,
      directGridDataSource: null,
      directGridLayoutRafId: null,
      directGridFilterRefreshRafId: null,
      directGridScrollSyncRafId: null,
      directGridRowVisualRafIds: markRaw(new Map()),
      directGridSortInitialRanks: markRaw(new Map()),
      directGridSortEditedCodes: markRaw(new Set()),
      kendoValidator: null,
      initialGridHeightAdjusted: false,
      // 最終行バリデーション tooltip の表示位置調整用タイマー（業務ロジック・検証条件には非関与）
      validationTooltipPlacementIntervalId: null,
      validationTooltipPlacementTimers: [],
      validationTooltipPlacementRafId: null,
    };
  },
  computed: {
    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight",
      windowWidth: "getWindowWidth"
    }),
    ...mapGetters("user", ["getFacilityCd"]),
    ...mapGetters("account-edit", {
      isDispMenu: "isDispMenu",
      getFontSize: "getFontSize",
      getStateUserAccountInfo: "getStateUserAccountInfo"
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
    gridColumnSignature() {
      return (this.columns || []).map(column => column?.field || column?.title || "").join("|");
    },
    ...mapGetters("master-maintenance", {
      getFacilitySwitch: "getFacilitySwitch",
      getMasterRecordList: "getMasterRecordList",
      getFilteredMasterRecordList: "getFilteredMasterRecordList",
      getUpdateRecordList: "getUpdateRecordList",
      masterPhysicalName: "getMasterName",
      columnDefinition: "getColumns",
      editRecord: "getEditRecord",
      isEdited: "isEdited",
      hasValueColumn: "hasValueColumn",
      isRecordModified: "isRecordModified"
    }),
    masterRecords() {
      // storeからデータを取得
      const masterRecordList = this.getFilteredMasterRecordList;
      const records = Array.isArray(masterRecordList?.data) ? masterRecordList.data : [];
      records.forEach(ele=>{
        if (!ele?.scaleDate) return;
        const date = new Date(ele.scaleDate);
        if (Number.isNaN(date.getTime())) return;
        const result =
          `${date.getFullYear()}/` +
          `${String(date.getMonth() + 1).padStart(2, '0')}/` +
          `${String(date.getDate()).padStart(2, '0')}`;
        ele.scaleDate = result;
      })
      return masterRecordList;
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
        (this.isRecordModified || !this.validateDirectKendoGrid())
      );
    },
    ...mapGetters("mst-wheel-chair", {
      getPersonalUserList: "getPersonalUserList",
      getPatPersonalList: "getPatPersonalList",
      getMstWeightScaleData: "getMstWeightScaleData",
      getFetchPersonalUserWithDeleted:"fetchPersonalUserWithDeleted"
    }),
    isMobileDevice() {
      return this.iosFlg || this.androidFlg;
    }
  },
  watch: {
    windowHeight() {
      this.calculateColumnsWidth();
      this.calculateGridHeight();
      this.calculateGridWidth();
      this.scheduleDirectGridLayoutContract();
    },
    windowWidth() {
      this.calculateColumnsWidth();
      this.calculateGridHeight();
      this.calculateGridWidth();
      this.scheduleDirectGridLayoutContract();
    },
    isDispMenu() {
      this.calculateColumnsWidth();
      this.calculateGridHeight();
      this.calculateGridWidth();
      this.scheduleDirectGridLayoutContract();
    },
    getFontSize() {
      this.calculateColumnsWidth();
      this.calculateGridHeight();
      this.calculateGridWidth();
      this.scheduleDirectGridLayoutContract();
    },
    columns(val) {
      this.$nextTick(() => {
        if (Array.isArray(val) && val.length > 1) {
          this.initDirectGridIfReady();
          this.setLoadingScreenVisible(false);
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
      "setMasterRecordList",
      "edit",
      "setCondition",
      "findColumnInfo",
      "updateRecordList",
      "setEditRecord",
      "editRecordBeEmpty",
      "setComparisonRecordModel",
      "findRecordListByFacilityCd",
      "updateRecordListByFacilityCd"
    ]),
    ...mapActions("mst-wheel-chair", [
      "fetchPersonalUserByFacilityCd",
      "fetchPersonalUser",
      "fetchPatPersonal",
      "fetchMstWeightScale",
      "setMstWeightScale",
      "fetchPatNameByFacilityCd",
    ]),
    getCurrentRouteName() {
      return this.$router?.currentRoute?.value?.name || this.$router?.currentRoute?.name || this.$route?.name || "";
    },
    cancel() {
      this.$router?.back?.();
    },
    validateDirectKendoGrid() {
      if (this.kendoValidator && typeof this.kendoValidator.validate === "function") {
        return this.kendoValidator.validate();
      }
      return true;
    },
    initKendoValidatorIfReady() {
      const ntssList = this.$refs.ntssList;
      if (!ntssList || this.columns.length <= 1) {
        return;
      }
      installComponentJQuery();
      destroyJQueryValidator(ntssList);
      this.kendoValidator = createJQueryValidator(ntssList, this.kendoValidatorSetup);
    },
    destroyKendoValidator() {
      destroyJQueryValidator(this.$refs.ntssList);
      this.kendoValidator = null;
    },
    validateBeforeGridAction() {
      return this.validateDirectKendoGrid();
    },
    getColumnIndex(fieldName) {
      return this.columns.findIndex(e => e.field === fieldName);
    },
    getMaxSortRank() {
      const data = this.getFilteredMasterRecordList?.data || [];
      return data.length ? data.reduce((a, b) => Math.max(a, +b.sortRank || 0), 0) : 0;
    },
    calculateColumnsWidth() {
      const widthMap = [12, 14, 16, 18];
      this.columnWidth = widthMap[Number(this.getFontSize || 1)] || 14;
    },
    calculateGridHeight() {
      if (this.editingFlg) {
        return;
      }
      const ownerDocument = this.$el?.ownerDocument || document;
      const ownerWindow = ownerDocument.defaultView || window;
      const wh = Number(this.windowHeight) || ownerWindow.innerHeight || 0;
      const headerElements = Array.prototype.slice.call(ownerDocument.getElementsByClassName("header") || []);
      const hh = headerElements.length ? headerElements.pop().clientHeight : 0;
      const footerMenu = ownerDocument.getElementById("footer-menu");
      const fmh = (this.isDispMenu === 1 && footerMenu ? footerMenu.clientHeight : 0) + 5;
      let toolbarHeight = wh - hh - fmh;

      // Vue2 wrapper では #grid-footer が一覧領域の下端に収まる。
      // direct jq では absolute footer の基準が viewport 側へ逃げると下メニューに重なるため、
      // 実 DOM の toolbar top から footer-menu top までの可視領域を上限にする。
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
      const gridFooter = this.$el?.querySelector?.("#grid-footer");
      const footerHeight = gridFooter ? (gridFooter.offsetHeight || gridFooter.clientHeight || 0) : 0;
      const headerArea = this.$el?.querySelector?.("#grid-header") || this.$el?.querySelector?.(".header-btn-area");
      const headerHeight = headerArea ? (headerArea.offsetHeight || headerArea.clientHeight || 0) : 0;
      const gridRoot = this.getGridRootEl?.();
      const content = gridRoot?.querySelector?.(".k-grid-content");
      const horizontalScrollbarHeight = content
        ? Math.max(0, (content.offsetHeight || 0) - (content.clientHeight || 0))
        : 17;
      // direct jq では footer が .ntss-list 下端に absolute 配置され、横スクロールバーと footer の
      // 余白を Vue2 wrapper ほど自動では吸収しない。最終行が footer に半行隠れないよう、
      // 横スクロールバー実測値に最低 30px の下端余白を確保する。
      const gridBottomReserve = Math.max(30, horizontalScrollbarHeight + 8);
      this.kendoGridHeight = Math.max(140, this.kendoGridToolbarHeight - footerHeight - headerHeight);
      if (gridRoot && Number.isFinite(this.kendoGridHeight)) {
        gridRoot.style.height = `${this.kendoGridHeight}px`;
        gridRoot.style.maxHeight = `${this.kendoGridHeight}px`;
        gridRoot.style.overflow = "hidden";
      }
      // Vue2 MasterMaintenanceMixin では mst_wheel_chair を外スクロール抑止対象にしている。
      // direct jq でも同じ画面スコープで main 側の外スクロールを止める。
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
    getGridRootEl() {
      return this.$refs.gridRoot || null;
    },
    getDirectGridScrollContent() {
      return this.getGridRootEl()?.querySelector?.(".k-grid-content") || null;
    },
    getDirectGridLockedScrollContent() {
      return this.getGridRootEl()?.querySelector?.(".k-grid-content-locked") || null;
    },
    getDirectGridHeaderWrap() {
      return this.getGridRootEl()?.querySelector?.(".k-grid-header-wrap") || null;
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
    getGridScrollPosition() {
      const content = this.getDirectGridScrollContent();
      return { top: content?.scrollTop ?? 0, left: content?.scrollLeft ?? 0 };
    },
    setGridScrollPosition(position = {}) {
      const content = this.getDirectGridScrollContent();
      if (!content) return;
      const top = position.top ?? 0;
      const left = position.left ?? 0;
      content.scrollTop = top;
      content.scrollLeft = left;
      const headerWrap = this.getDirectGridHeaderWrap();
      if (headerWrap) {
        headerWrap.scrollLeft = left;
      }
      this.scrollPosition.top = top;
      this.scrollPosition.left = left;
      this.lastScrollTop = top;
      this.lastScrollLeft = left;
      this.syncDirectGridLockedScrollPosition(top);
      this.dispatchDirectGridContentScroll();
    },
    storeDirectGridScrollPosition() {
      const pos = this.getGridScrollPosition();
      this.scrollPosition.top = pos.top;
      this.scrollPosition.left = pos.left;
      this.lastScrollTop = pos.top;
      this.lastScrollLeft = pos.left;
    },
    restoreDirectGridScrollPosition() {
      const top = this.scrollPosition.top ?? this.lastScrollTop ?? 0;
      const left = this.scrollPosition.left ?? this.lastScrollLeft ?? this.lastInputScrollLeft ?? 0;
      this.setGridScrollPosition({ top, left });
    },
    captureDirectGridScrollBeforeEditClose() {
      const current = this.getGridScrollPosition();
      const top = current.top > 0
        ? current.top
        : (this.scrollPosition.top ?? this.lastScrollTop ?? 0);
      const left = current.left > 0
        ? current.left
        : (this.scrollPosition.left ?? this.lastScrollLeft ?? this.lastInputScrollLeft ?? 0);
      this.scrollPosition.top = top;
      this.scrollPosition.left = left;
      this.lastScrollTop = top;
      this.lastScrollLeft = left;
      return { top, left };
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
    getDirectGridDataSourceOption() {
      const source = this.masterRecords || this.getFilteredMasterRecordList || {};
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
      return (this.columns || []).map(column => {
        const gridColumn = { ...column };
        if (column.field === "$modalType") {
          gridColumn.attributes = { class: "btn3-kendo-normal" };
          gridColumn.command = { text: "詳細", click: event => this.showMasterEditModal(event) };
          delete gridColumn.values;
        } else if (column.field === "wheelChairWeight") {
          gridColumn.editor = (container, options) => this.numericEditor(container, options);
        }
        return gridColumn;
      });
    },
    initDirectGridIfReady() {
      const root = this.getGridRootEl();
      if (!this.directGridMounted || !root || this.columns.length <= 1) return;
      if (this.directGridWidget) {
        this.applyDirectGridColumnsContract();
        this.scheduleDirectGridFilterRefresh();
        this.scheduleDirectGridLayoutContract();
        this.initKendoValidatorIfReady();
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
        // addInputAssist 相当の編集補助に加え、tooltip 表示位置のみを調整する（save/validate 条件は従来どおり）
        edit: event => this.onDirectGridEdit(event),
        // editEnd 相当の後処理に加え、tooltip 配置状態のみを解除する
        cellClose: event => this.onDirectGridCellClose(event),
        save: event => this.onDirectGridSave(event),
        dataBound: event => this.onDirectGridDataBound(event),
        columns: this.buildDirectGridColumns()
      });
      this.directGridWidget = markRaw($(root).data("kendoGrid"));
      this.installDirectGridFacade();
      this.applyDirectGridStyleContract();
      this.initKendoValidatorIfReady();
      this.scheduleDirectGridLayoutContract();
    },
    destroyDirectGrid() {
      // グリッド破棄時に tooltip 配置用タイマーだけ片付ける（データ保存・検証ロジックは触らない）
      this.clearValidationTooltipPlacementTimers();
      this.stopValidationTooltipPlacementWatch();
      this.clearValidationTooltipPlacementState();
      if (this.directGridWidget) {
        try { this.directGridWidget.destroy(); } catch (_error) {}
      }
      const root = this.getGridRootEl();
      if (root) $(root).empty();
      this.directGridWidget = null;
    },
    installDirectGridFacade() {
      const root = this.getGridRootEl();
      if (!root) return;
      root.kendoWidget = () => this.directGridWidget;
      root.gridWidget = () => this.directGridWidget;
      root.gridRootEl = () => root;
      root.gridContentEl = () => this.getDirectGridScrollContent();
      root.gridAutoScrollableEl = () => this.getDirectGridScrollContent();
      root.gridLockedContentEl = () => this.getDirectGridLockedScrollContent();
      root.scrollGridTo = position => this.setGridScrollPosition(position);
    },
    applyDirectGridColumnsContract() {
      const grid = this.directGridWidget;
      if (!grid) return;
      const before = (grid.columns || []).map(column => column.field).join("|");
      const after = (this.columns || []).map(column => column.field).join("|");
      if (before !== after) {
        grid.setOptions({ columns: this.buildDirectGridColumns() });
      }
    },
    scheduleDirectGridFilterRefresh() {
      if (!this.directGridWidget?.dataSource) return;
      if (this.directGridFilterRefreshRafId != null) cancelAnimationFrame(this.directGridFilterRefreshRafId);
      this.directGridFilterRefreshRafId = requestAnimationFrame(() => {
        this.directGridFilterRefreshRafId = null;
        this.refreshDirectGridDataFromMasterRecords(true);
      });
    },
    refreshDirectGridDataFromMasterRecords(resetScroll = false) {
      const grid = this.directGridWidget;
      if (!grid?.dataSource) return;
      const preservedScroll = !resetScroll ? {
        top: this.scrollPosition.top ?? this.lastScrollTop ?? 0,
        left: this.scrollPosition.left ?? this.lastScrollLeft ?? 0
      } : null;
      if (!resetScroll && !this.preserveGridScrollAfterSave) {
        this.storeDirectGridScrollPosition();
      }
      const option = this.getDirectGridDataSourceOption();
      grid.dataSource.data(option.data || []);
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
      const grid = this.directGridWidget;
      if (!grid) return;
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
        this.$nextTick(() => {
          this.restoreDirectGridScrollPosition();
          // resize 後も編集中セルの tooltip 位置だけ再計算する
          this.scheduleValidationTooltipPlacement();
        });
      } catch (_error) {}
    },
    /*
     * direct jq grid 向けバリデーション tooltip 表示位置調整。
     * MstBedMainComponent / MasterRecordComponent と同趣旨で、最終行の必須エラー表示時に
     * locked/non-locked の行がずれないよう tooltip をセル上へ出す。
     * 必須判定・saveRecord・kendoValidator の rules/messages は一切変更しない。
     */
    getDirectGridFieldFromCell(cell) {
      const colIndex = Number(cell?.getAttribute?.("aria-colindex")) - 1;
      if (!Number.isFinite(colIndex) || colIndex < 0) {
        return null;
      }
      return this.columns[colIndex]?.field || null;
    },
    getDirectGridFieldFromEvent(ev) {
      const activeField = ev?.sender?.editable?.options?.fields?.field;
      if (activeField) {
        return activeField;
      }
      return this.getDirectGridFieldFromCell(ev?.container?.[0] || ev?.container);
    },
    // スキーマ定義から必須メッセージ文言を取得（既存 validateRequired と同じ列タイトルベース）
    getDirectGridFieldValidationMessage(field) {
      if (!field) {
        return "";
      }
      const schemaFields =
        this.directGridDataSource?.schema?.model?.fields ||
        this.getMasterRecordList?.schema?.model?.fields ||
        {};
      const fieldDef = schemaFields[field];
      if (fieldDef?.validation?.validationMessage) {
        return fieldDef.validation.validationMessage;
      }
      if (fieldDef?.validation?.required) {
        const column = this.columns.find(item => item.field === field);
        if (column?.title) {
          return `${column.title}は必須入力です。`;
        }
      }
      return "";
    },
    // HTML5 required / validationMessage を編集 input に付与（Kendo validator 表示用。値の保存処理は変更しない）
    applyDirectGridEditorValidationMessage(cell, field) {
      const message = this.getDirectGridFieldValidationMessage(field);
      if (!message || !cell) {
        return;
      }
      const root = cell?.querySelector ? cell : null;
      if (!root) {
        return;
      }
      const inputs = root.matches?.("input, select, textarea")
        ? [root]
        : Array.from(root.querySelectorAll?.("input, select, textarea") || []);
      inputs.forEach(input => {
        input.setAttribute("required", "required");
        input.setAttribute("validationMessage", message);
      });
    },
    // tooltip 探索・callout 向き調整の基点となる grid DOM
    getDirectGridSearchRoot() {
      const widget = this.directGridWidget;
      return widget?.wrapper?.[0] || widget?.element?.[0] || this.$refs.gridRoot || null;
    },
    getDirectGridDataSourceItems() {
      const collection = this.directGridWidget?.dataSource?.data?.();
      return collection ? Array.from(collection) : [];
    },
    // 現在編集中の td.k-edit-cell（locked / non-locked 両方を考慮）
    findActiveGridEditCell(root) {
      const grid = this.directGridWidget;
      const lockedCell = grid?.lockedTable?.find?.(".k-edit-cell")?.[0];
      if (lockedCell) {
        return lockedCell;
      }
      const mainCell = grid?.table?.find?.(".k-edit-cell")?.[0];
      if (mainCell) {
        return mainCell;
      }
      const searchRoot = root || this.getDirectGridSearchRoot();
      return (
        searchRoot?.querySelector?.(".k-grid-content-locked .k-edit-cell")
        || searchRoot?.querySelector?.(".k-grid-content .k-edit-cell")
        || searchRoot?.querySelector?.(".k-edit-cell")
        || null
      );
    },
    // 編集セルが属するスクロール領域（下端判定に使用）
    findGridScrollContentForEditCell(root, editCell) {
      const lockedContent = editCell?.closest?.(".k-grid-content-locked");
      if (lockedContent) {
        return lockedContent;
      }
      const scrollContent = editCell?.closest?.(".k-grid-content");
      if (scrollContent) {
        return scrollContent;
      }
      return (
        root?.querySelector?.(".k-grid-content-locked")
        || root?.querySelector?.(".k-grid-content")
        || null
      );
    },
    // 編集セル内で表示中の k-invalid-msg / k-tooltip-validation を取得
    findVisibleValidationTooltip(editCell) {
      if (!editCell) {
        return null;
      }
      const candidates = editCell.querySelectorAll(
        ".k-invalid-msg, .k-tooltip-error, .k-validator-tooltip, .k-tooltip.k-tooltip-validation"
      );
      for (const element of candidates) {
        if (element?.classList?.contains?.("k-hidden")) {
          continue;
        }
        const text = element.textContent?.trim?.() || "";
        const hasMessage = text.length > 0 || element.querySelector?.(".k-tooltip-content");
        if (hasMessage || element.classList.contains("k-tooltip-error")) {
          return element;
        }
      }
      return null;
    },
    // callout（赤角標）を下向きデフォルトへ戻す
    resetValidationTooltipCalloutDirection(editCell) {
      editCell?.querySelectorAll?.(".k-callout")?.forEach?.(callout => {
        callout.classList.remove("k-callout-s", "k-callout-e", "k-callout-w");
        callout.classList.add("k-callout-n");
      });
    },
    // tooltip をセル上/下のどちらに出すかに応じて callout 向きを切り替える
    setValidationTooltipCalloutDirection(tooltip, above) {
      const callout = tooltip?.querySelector?.(".k-callout");
      if (!callout) {
        return;
      }
      if (above) {
        callout.classList.remove("k-callout-n", "k-callout-e", "k-callout-w");
        callout.classList.add("k-callout-s");
      } else {
        callout.classList.remove("k-callout-s", "k-callout-e", "k-callout-w");
        callout.classList.add("k-callout-n");
      }
    },
    // dataSource 上の最終行かどうか（最終行は tooltip を上に出す）
    isLastDataSourceEditRow(editRow) {
      if (!editRow) {
        return false;
      }
      const grid = this.directGridWidget;
      const dataItem = grid?.dataItem?.(editRow);
      const items = this.getDirectGridDataSourceItems();
      if (!items.length) {
        return false;
      }
      const lastItem = items[items.length - 1];
      if (dataItem && lastItem) {
        return dataItem === lastItem || dataItem.uid === lastItem.uid;
      }
      const rowUid = editRow.getAttribute("data-uid");
      return !!rowUid && lastItem?.uid === rowUid;
    },
    // tbody 内の最終 visible 行かどうか
    isLastVisibleTbodyRow(editRow) {
      const tbody = editRow?.closest?.("tbody");
      if (!tbody) {
        return false;
      }
      const dataRows = tbody.querySelectorAll(":scope > tr[data-uid]");
      if (!dataRows.length) {
        return false;
      }
      return dataRows[dataRows.length - 1] === editRow;
    },
    // スクロール領域下端付近の行かどうか（tooltip が下にはみ出す場合の判定）
    isEditRowInVisibleBottomBand(editCell, content) {
      const editRow = editCell?.closest?.("tr");
      if (!editRow || !content) {
        return false;
      }
      const contentRect = content.getBoundingClientRect();
      const rowRect = editRow.getBoundingClientRect();
      const rowBottomGap = contentRect.bottom - rowRect.bottom;
      if (rowBottomGap < 52) {
        return true;
      }
      const tbody = editRow.closest("tbody");
      if (!tbody) {
        return false;
      }
      const dataRows = Array.from(tbody.querySelectorAll(":scope > tr[data-uid]"));
      const rowIndex = dataRows.indexOf(editRow);
      if (rowIndex < 0) {
        return false;
      }
      return rowIndex >= dataRows.length - 2;
    },
    // 下端・最終行など、tooltip をセル上（ntss-validation-above）に出すべきか判定
    shouldPlaceValidationTooltipAbove(editCell, content, anchor, tooltip) {
      const editRow = editCell?.closest?.("tr");
      const anchorRect = anchor.getBoundingClientRect();
      const contentRect = content.getBoundingClientRect();
      const tooltipRect = tooltip.getBoundingClientRect();
      const rowRect = editRow?.getBoundingClientRect?.() || anchorRect;
      const tooltipHeight = Math.max(
        tooltip.offsetHeight || 0,
        tooltip.scrollHeight || 0,
        tooltipRect.height || 0,
        36
      );
      const spaceBelow = contentRect.bottom - anchorRect.bottom;
      const rowBottomGap = contentRect.bottom - rowRect.bottom;
      const overflowsBelow =
        tooltipRect.height > 0 && tooltipRect.bottom > contentRect.bottom - 2;
      const projectedOverflow =
        anchorRect.bottom + tooltipHeight + 4 > contentRect.bottom;
      return (
        overflowsBelow
        || projectedOverflow
        || spaceBelow < tooltipHeight + 4
        || rowBottomGap < tooltipHeight + 8
        || this.isEditRowInVisibleBottomBand(editCell, content)
        || this.isLastDataSourceEditRow(editRow)
        || this.isLastVisibleTbodyRow(editRow)
      );
    },
    // ntss-validation-above クラスと callout 向きを編集中セルへ反映
    applyValidationTooltipPlacement() {
      const root = this.getDirectGridSearchRoot();
      if (!root) {
        return;
      }
      const editCell = this.findActiveGridEditCell(root);
      if (!editCell) {
        this.clearValidationTooltipPlacementState();
        return;
      }
      const content = this.findGridScrollContentForEditCell(root, editCell);
      if (!content) {
        this.clearValidationTooltipPlacementState();
        return;
      }
      root.querySelectorAll(".ntss-validation-above").forEach(element => {
        if (element !== editCell) {
          element.classList.remove("ntss-validation-above");
          this.resetValidationTooltipCalloutDirection(element);
        }
      });
      const tooltip = this.findVisibleValidationTooltip(editCell);
      if (!tooltip) {
        editCell.classList.remove("ntss-validation-above");
        this.resetValidationTooltipCalloutDirection(editCell);
        return;
      }
      const anchor =
        editCell.querySelector(".k-input.k-textbox, .k-picker, .k-input")
        || editCell.querySelector("input, textarea, select, .k-input-inner, .k-textbox")
        || editCell;
      const needsAbove = this.shouldPlaceValidationTooltipAbove(
        editCell,
        content,
        anchor,
        tooltip
      );
      if (needsAbove) {
        editCell.classList.add("ntss-validation-above");
      } else {
        editCell.classList.remove("ntss-validation-above");
      }
      this.setValidationTooltipCalloutDirection(tooltip, needsAbove);
    },
    // interval による tooltip 位置監視を停止
    stopValidationTooltipPlacementWatch() {
      const ownerWindow = this.getDirectGridSearchRoot()?.ownerDocument?.defaultView || window;
      if (this.validationTooltipPlacementIntervalId) {
        ownerWindow.clearInterval?.(this.validationTooltipPlacementIntervalId);
        this.validationTooltipPlacementIntervalId = null;
      }
    },
    // Kendo が tooltip DOM を描画し終えるまで短時間リトライ
    startValidationTooltipPlacementWatch() {
      this.stopValidationTooltipPlacementWatch();
      const ownerWindow = this.getDirectGridSearchRoot()?.ownerDocument?.defaultView || window;
      let attempts = 0;
      const tick = () => {
        attempts += 1;
        this.applyValidationTooltipPlacement();
        const editCell = this.findActiveGridEditCell(this.getDirectGridSearchRoot());
        const tooltip = this.findVisibleValidationTooltip(editCell);
        if (!tooltip || attempts >= 5) {
          this.stopValidationTooltipPlacementWatch();
        }
      };
      tick();
      this.validationTooltipPlacementIntervalId = ownerWindow.setInterval?.(tick, 100);
    },
    // rAF / setTimeout 用タイマーを解除
    clearValidationTooltipPlacementTimers() {
      const ownerWindow = this.getDirectGridSearchRoot()?.ownerDocument?.defaultView || window;
      this.validationTooltipPlacementTimers.forEach(timerId => {
        ownerWindow.clearTimeout?.(timerId);
      });
      this.validationTooltipPlacementTimers = [];
      if (this.validationTooltipPlacementRafId) {
        ownerWindow.cancelAnimationFrame?.(this.validationTooltipPlacementRafId);
        this.validationTooltipPlacementRafId = null;
      }
    },
    // rAF / setTimeout / interval で tooltip 位置を再計算（表示タイミング調整のみ）
    scheduleValidationTooltipPlacement() {
      this.clearValidationTooltipPlacementTimers();
      const ownerWindow = this.getDirectGridSearchRoot()?.ownerDocument?.defaultView || window;
      const run = () => this.applyValidationTooltipPlacement();
      run();
      this.$nextTick(run);
      this.validationTooltipPlacementRafId = ownerWindow.requestAnimationFrame?.(() => {
        this.validationTooltipPlacementRafId = ownerWindow.requestAnimationFrame?.(() => {
          this.validationTooltipPlacementRafId = null;
          run();
        }) || null;
      }) || null;
      const timerId = ownerWindow.setTimeout?.(run, 80);
      if (timerId) {
        this.validationTooltipPlacementTimers.push(timerId);
      }
      this.startValidationTooltipPlacementWatch();
    },
    // ntss-validation-above と callout 向きの残留状態を解除
    clearValidationTooltipPlacementState() {
      const root = this.getDirectGridSearchRoot();
      root?.querySelectorAll?.(".ntss-validation-above")?.forEach?.(element => {
        element.classList.remove("ntss-validation-above");
        this.resetValidationTooltipCalloutDirection(element);
      });
    },
    /*
     * MasterMaintenanceMixin.handleAddValidateArrow の本画面向け上書き。
     * mixin 既定は scope 内最初の k-invalid-msg へ callout を付けるため、
     * 行選択時に角標が隣行へ移って見える。編集中セルの tooltip のみ対象に限定する。
     * 検証結果そのもの（必須/保存可否）は従来どおり kendoValidator / validateRequired が担当。
     */
    handleAddValidateArrow() {
      const root = this.getDirectGridSearchRoot() || this.$el;
      const editCell = this.findActiveGridEditCell(root);
      const tooltip = this.findVisibleValidationTooltip(editCell);
      if (editCell && tooltip) {
        appendValidationCallout(tooltip);
        this.scheduleValidationTooltipPlacement();
        return;
      }
      this.clearValidationTooltipPlacementState();
    },
    /*
     * cellClose 時: editEnd（editingFlg 解除）は従来どおり呼び、
     * 追加で tooltip 配置状態だけ片付ける。save/onSave の値反映ロジックは変更しない。
     */
    onDirectGridCellClose(ev) {
      this.clearValidationTooltipPlacementTimers();
      this.stopValidationTooltipPlacementWatch();
      const closedCell = ev?.container?.[0] || ev?.container;
      if (closedCell?.classList) {
        closedCell.classList.remove("ntss-validation-above");
        this.resetValidationTooltipCalloutDirection(closedCell);
      }
      this.clearValidationTooltipPlacementState();
      const savedScroll = this.captureDirectGridScrollBeforeEditClose();
      this.editEnd(ev);
      this.$nextTick(() => {
        this.setGridScrollPosition(savedScroll);
        this.scheduleDirectGridPostColumnScrollSync();
      });
    },
    /*
     * edit 時: 従来の addInputAssist をそのまま呼び、
     * 必須メッセージ属性付与と tooltip 位置調整だけを追加する。
     */
    onDirectGridEdit(ev) {
      this.storeDirectGridScrollPosition();
      this.addInputAssist(ev);
      const field = this.getDirectGridFieldFromEvent(ev);
      const cell = ev?.container?.[0] || ev?.container;
      if (!field || !cell) {
        return;
      }
      this.applyDirectGridEditorValidationMessage(cell, field);
      this.scheduleValidationTooltipPlacement();
      const input = cell.querySelector?.("input");
      if (!input) {
        return;
      }
      const onValidationPlacement = () => {
        this.scheduleValidationTooltipPlacement();
      };
      input.addEventListener("blur", onValidationPlacement, { passive: true });
      input.addEventListener("invalid", onValidationPlacement, { passive: true });
    },
    getDirectGridVisibleLockedWidthPx() {
      const root = this.getGridRootEl();
      const fontSize = parseFloat(getComputedStyle(root || document.body).fontSize || "16") || 16;
      return (this.columns || []).reduce((sum, column) => {
        if (!column.locked || column.hidden) return sum;
        const width = `${column.width || ""}`.trim();
        if (width.endsWith("em")) return sum + parseFloat(width) * fontSize;
        if (width.endsWith("px")) return sum + parseFloat(width);
        const numeric = parseFloat(width);
        return sum + (Number.isFinite(numeric) ? numeric : 0);
      }, 0);
    },
    applyDirectGridLockedWidthContract() {
      const root = this.getGridRootEl();
      const width = this.getDirectGridVisibleLockedWidthPx();
      if (!root || !width) return;
      const px = `${Math.ceil(width)}px`;
      root.querySelectorAll(".k-grid-header-locked,.k-grid-content-locked,.k-grid-header-locked > table,.k-grid-content-locked > table").forEach(element => {
        element.style.width = px;
        element.style.minWidth = px;
      });
    },
    applyDirectGridLockedHeightContract() {
      const content = this.getDirectGridScrollContent();
      const lockedContent = this.getDirectGridLockedScrollContent();
      if (!content || !lockedContent) return;
      lockedContent.style.height = `${content.clientHeight}px`;
      lockedContent.style.maxHeight = `${content.clientHeight}px`;
    },
    applyDirectGridStyleContract() {
      const root = this.getGridRootEl();
      if (!root) return;
      root.classList.add("ntss-kendo-grid-legacy", "k-widget", "k-grid", "k-editable", "k-display-block");
      root.querySelectorAll("th").forEach(th => th.classList.add("k-header"));
      [".k-grid-content tbody", ".k-grid-content-locked tbody"].forEach(selector => {
        root.querySelectorAll(`${selector} tr`).forEach((tr, index) => {
          tr.classList.add("k-master-row");
          tr.classList.toggle("k-alt", index % 2 === 1);
        });
      });
      root.querySelectorAll(".k-grid-content tbody td, .k-grid-content-locked tbody td").forEach(td => td.classList.add("k-td", "k-table-td"));
      this.applyDirectGridLockedWidthContract();
      this.applyDirectGridLockedHeightContract();
      this.syncDirectGridLockedScrollPosition();
    },
    scheduleDirectGridLayoutContract() {
      if (!this.preserveGridScrollAfterSave) {
        this.storeDirectGridScrollPosition();
      }
      if (this.directGridLayoutRafId != null) cancelAnimationFrame(this.directGridLayoutRafId);
      this.directGridLayoutRafId = requestAnimationFrame(() => {
        this.resizeDirectGrid();
        this.applyDirectGridStyleContract();
        this.restoreDirectGridScrollPosition();
        this.directGridLayoutRafId = requestAnimationFrame(() => {
          this.directGridLayoutRafId = null;
          this.resizeDirectGrid();
          this.applyDirectGridStyleContract();
          this.restoreDirectGridScrollPosition();
          this.scheduleDirectGridPostColumnScrollSync();
        });
      });
    },
    syncDirectGridLockedScrollPosition(scrollTop = null) {
      const lockedContent = this.getDirectGridLockedScrollContent();
      if (!lockedContent) return;
      const content = this.getDirectGridScrollContent();
      lockedContent.scrollTop = scrollTop !== null && scrollTop !== undefined ? scrollTop : (content?.scrollTop || 0);
    },
    dispatchDirectGridContentScroll() {
      const content = this.getDirectGridScrollContent();
      if (!content) return;
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
    getDirectGridRecordKeys(record) {
      if (!record) {
        return [];
      }
      const raw = typeof record.toJSON === "function" ? record.toJSON() : record;
      return [
        ["code", raw.code],
        ["wheelChairCd", raw.wheelChairCd],
        ["wheelChairName", raw.wheelChairName],
        ["uid", raw.uid],
        ["sortInputTime", raw.sortInputTime]
      ]
        .filter(([, value]) => value !== null && value !== undefined && value !== "")
        .map(([field, value]) => `${field}:${String(value)}`);
    },
    getDirectGridRecordKey(record) {
      return this.getDirectGridRecordKeys(record)[0] || "";
    },
    normalizeSortRankValue(value) {
      if (value === null || value === undefined || value === "") {
        return "";
      }
      const numeric = Number(String(value).replace(/,/g, ""));
      return Number.isFinite(numeric) ? String(numeric) : String(value);
    },
    rememberDirectGridSortInitialRanks() {
      this.directGridSortInitialRanks = markRaw(new Map());
      this.directGridSortEditedCodes = markRaw(new Set());
      (this.getMasterRecordList?.data || []).forEach(record => {
        const initialRank = this.normalizeSortRankValue(record.sortRank);
        this.getDirectGridRecordKeys(record).forEach(key => {
          this.directGridSortInitialRanks.set(key, initialRank);
        });
      });
    },
    markDirectGridSortEditedRecord(record, forceEdited = false) {
      const keys = this.getDirectGridRecordKeys(record);
      if (!keys.length) {
        return false;
      }
      const currentRank = this.normalizeSortRankValue(record?.sortRank);
      const initialRanks = keys
        .map(key => this.directGridSortInitialRanks?.get?.(key))
        .filter(rank => rank !== undefined);
      const edited = !!forceEdited || (initialRanks.length > 0 && initialRanks.some(rank => rank !== currentRank));
      keys.forEach(key => {
        if (edited) {
          this.directGridSortEditedCodes.add(key);
        } else {
          this.directGridSortEditedCodes.delete(key);
        }
      });
      return edited;
    },
    isDirectGridSortEditedRecord(record) {
      return this.getDirectGridRecordKeys(record).some(key => this.directGridSortEditedCodes?.has?.(key));
    },
    getDirectGridDirtyFields(record) {
      const dirtyFields = record?.dirtyFields || {};
      return Object.keys(dirtyFields).filter(field => dirtyFields[field]);
    },
    isDirectGridSortRankDirtyRecord(record) {
      return this.isDirectGridSortEditedRecord(record) || this.getDirectGridDirtyFields(record).includes("sortRank");
    },
    isDirectGridRecordEditedForRowVisual(record) {
      if (!record) {
        return false;
      }
      if (record.operation || record.edited) {
        return true;
      }
      const dirtyFields = this.getDirectGridDirtyFields(record);
      if (dirtyFields.length) {
        return dirtyFields.some(field => field !== "sortRank");
      }
      return !!record.dirty && !this.isDirectGridSortRankDirtyRecord(record);
    },
    shouldApplyDirectGridEditedRowColor(row, cell, locked) {
      if (!locked) {
        return true;
      }
      const columns = this.getDirectGridDomColumns(true);
      const cellIndex = Array.from(row?.children || []).indexOf(cell);
      const sortIndex = columns.findIndex(column => column.field === "sortRank");
      if (sortIndex >= 0) {
        return cellIndex > sortIndex;
      }
      const dummyIndex = columns.findIndex(column => column.field === "dummy");
      return dummyIndex >= 0 ? cellIndex > dummyIndex : true;
    },
    markDirectGridSortEditedRowsFromGrid() {
      const rows = this.directGridWidget?.dataSource?.data?.();
      if (!rows) {
        return;
      }
      Array.from(rows).forEach(row => this.markDirectGridSortEditedRecord(row));
    },
    flushDirectGridPendingEdit() {
      const grid = this.directGridWidget;
      if (!grid) {
        return;
      }
      try {
        grid.closeCell?.();
      } catch (_error) {
        // Vue2 wrapper では外部ボタン押下前に current cell の save が走る。
        // direct jq で close に失敗しても以降の同期処理は継続する。
      }
    },
    getDirectGridVisibleColumns(locked) {
      const columns = (this.columns || []).length > 1 ? this.columns : (this.directGridWidget?.columns || []);
      return columns.filter(column => !column.hidden && (!!column.locked) === !!locked);
    },
    getDirectGridDomColumns(locked) {
      const columns = (this.columns || []).length > 1 ? this.columns : (this.directGridWidget?.columns || []);
      return columns.filter(column => (!!column.locked) === !!locked);
    },
    getDirectGridDataItemFromRow(row) {
      if (!row) {
        return null;
      }
      try {
        return this.directGridWidget?.dataItem?.(row) || null;
      } catch (_error) {
        return null;
      }
    },
    getDirectGridCellByField(row, fieldName, locked) {
      if (!row || !fieldName) {
        return null;
      }
      const columns = this.getDirectGridDomColumns(locked);
      const index = columns.findIndex(column => column.field === fieldName);
      return index >= 0 ? row.children[index] || null : null;
    },
    getDirectGridFirstDataCell(row, locked) {
      if (!row) {
        return null;
      }
      const columns = this.getDirectGridDomColumns(locked);
      const fieldsToSkip = new Set(["dummy", "sortRank", "$modalType", "detail", "button", "buttons"]);
      for (const fieldName of ["wheelChairName", "name", "code"]) {
        const cell = this.getDirectGridCellByField(row, fieldName, locked);
        if (cell) {
          return cell;
        }
      }
      for (let i = 0; i < columns.length; i += 1) {
        if (!fieldsToSkip.has(columns[i].field) && row.children[i]) {
          return row.children[i];
        }
      }
      // Vue2 wrapper では sortRank 非表示後、dummy だけが残った固定列には黄色を置かない。
      // direct jq の locked 側 fallback で dummy を塗ると、同一行が painted 済みになり、
      // 非固定側の先頭データ列（車いす名称）へ黄色が移らないため null を返す。
      if (locked) {
        return null;
      }
      return Array.from(row.children || []).find((cell, index) => {
        const column = columns[index];
        return column && !fieldsToSkip.has(column.field) && (cell.textContent || "").trim() !== "";
      }) || null;
    },
    getDirectGridSortVisualTargetCells(row, locked) {
      if (!locked) {
        return [];
      }
      return [
        this.getDirectGridCellByField(row, "sortRank", locked),
        this.getDirectGridCellByField(row, "dummy", locked)
      ].filter(Boolean);
    },
    resetDirectGridSortCellClasses() {
      const root = this.getGridRootEl();
      if (!root) {
        return;
      }
      // root.querySelectorAll("td.master-sort-edited").forEach(cell => cell.classList.remove("master-sort-edited"));
    },
    applyDirectGridSortVisual() {
      const root = this.getGridRootEl();
      if (!root || !this.directGridSortEditedCodes?.size) {
        this.resetDirectGridSortCellClasses();
        return;
      }
      this.resetDirectGridSortCellClasses();
      const paintedKeys = new Set();
      const resolveItem = (row, index) => this.getDirectGridDataItemFromRow(row)
        || this.directGridWidget?.dataSource?.view?.()?.[index]
        || this.directGridWidget?.dataSource?.data?.()?.[index]
        || null;
      [
        { selector: ".k-grid-content-locked tbody tr", locked: true },
        { selector: ".k-grid-content tbody tr", locked: false }
      ].forEach(({ selector, locked }) => {
        root.querySelectorAll(selector).forEach((row, index) => {
          const item = resolveItem(row, index);
          const key = this.getDirectGridRecordKey(item);
          if (!key || paintedKeys.has(key) || !this.directGridSortEditedCodes.has(key)) {
            return;
          }
          const cells = this.getDirectGridSortVisualTargetCells(row, locked);
          if (cells.length) {
            cells.forEach(cell => {
              cell.classList.remove("master-edited-row", "master-deleted-row");
              cell.classList.add("master-sort-edited");
            });
            paintedKeys.add(key);
          }
        });
      });
    },
    onDirectGridDataBound(event) {
      this.onDataBoundKendoGrid?.(event);
      this.applyDirectGridStyleContract();
      this.editBackgroundColor();
      this.restoreDirectGridScrollPosition();
    },
    editStart() {
      this.editingFlg = true;
    },
    scheduleDirectGridCurrentRowVisual(record) {
      const key = record?.uid || record?.code || record?.sortRank;
      if (!key) return;
      const oldId = this.directGridRowVisualRafIds.get(key);
      if (oldId != null) cancelAnimationFrame(oldId);
      const rafId = requestAnimationFrame(() => {
        this.directGridRowVisualRafIds.delete(key);
        this.applyDirectGridRowVisual(record);
        this.applyDirectGridSortVisual();
      });
      this.directGridRowVisualRafIds.set(key, rafId);
    },
    applyDirectGridRowVisual(record) {
      const root = this.getGridRootEl();
      if (!root || !record?.uid) return;
      const dirtyFields = this.getDirectGridDirtyFields(record);
      const comparisonModel = this.$store?.state?.["master-maintenance"]?.comparisonRecordModel || "[]";
      let originalRecord = null;
      try {
        const originalRows = JSON.parse(comparisonModel);
        originalRecord = Array.isArray(originalRows)
          ? originalRows.find(row => String(row.code) === String(record.code))
          : null;
      } catch (_error) {
        originalRecord = null;
      }
      const normalizeValue = value => {
        if (value === undefined || value === null || value === "" || value === "null") {
          return null;
        }
        if (typeof value === "string") {
          const trimmed = value.trim();
          return trimmed === "" ? null : trimmed;
        }
        return value;
      };
      const isSameValue = (currentValue, originalValue) => {
        const current = normalizeValue(currentValue);
        const original = normalizeValue(originalValue);
        if (current == original) {
          return true;
        }
        const currentNumber = Number(current);
        const originalNumber = Number(original);
        if (!Number.isNaN(currentNumber) && !Number.isNaN(originalNumber) && `${current}`.trim() !== "" && `${original}`.trim() !== "") {
          return currentNumber === originalNumber;
        }
        return `${current}` === `${original}`;
      };
      const isFieldChanged = fieldName => {
        if (!fieldName) {
          return false;
        }
        if (originalRecord) {
          return !isSameValue(record?.[fieldName], originalRecord?.[fieldName]);
        }
        return dirtyFields.includes(fieldName);
      };
      const nonSortDirtyFields = dirtyFields.filter(field => field !== "sortRank");
      const ignoredCompareFields = ["dummy", "sortRank", "$modalType", "detail", "button", "buttons", "operation", "upDate", "sortInputTime", "scaleDate", "scaleUserId", "uid", "skipSearch"];
      const nonSortCompareFields = [
        ...(this.columnDefinition || this.columns || []).filter(column => column.originalEditable).map(column => column.field),
        ...nonSortDirtyFields
      ].filter((field, index, fields) => (
        field
        && !ignoredCompareFields.includes(field)
        && fields.indexOf(field) === index
      ));
      let edited = this.isDirectGridRecordEditedForRowVisual(record);
      if (dirtyFields.includes("sortRank") && nonSortDirtyFields.length === 0 && record.operation !== 1) {
        edited = false;
      }
      if (originalRecord && record.operation !== 1) {
        edited = nonSortCompareFields.some(field => isFieldChanged(field));
      }
      let sortEdited = this.isDirectGridSortRankDirtyRecord(record);
      if (originalRecord && dirtyFields.includes("sortRank")) {
        sortEdited = this.isDirectGridSortEditedRecord(record) || isFieldChanged("sortRank");
      }
      root.querySelectorAll(`tr[data-uid="${record.uid}"]`).forEach(row => {
        const locked = !!row.closest?.(".k-grid-content-locked");
        const sortCells = new Set(sortEdited ? this.getDirectGridSortVisualTargetCells(row, locked) : []);
        const columns = this.getDirectGridDomColumns(locked);
        this.getDirectGridSortVisualTargetCells(row, locked).forEach(cell => {
          cell.classList.remove("master-edited-row", "master-deleted-row", "master-sort-edited");
          if (sortCells.has(cell)) {
            cell.classList.add("master-sort-edited");
          }
        });
        row.classList.remove("master-edited-row", "master-deleted-row");
        row.querySelectorAll("td").forEach(cell => {
          const cellIndex = Array.from(row.children || []).indexOf(cell);
          const fieldName = columns[cellIndex]?.field;
          if (!isFieldChanged(fieldName)) {
            cell.classList.remove("k-dirty-cell", "master-edited-cell");
            cell.querySelectorAll?.(".k-dirty")?.forEach?.(element => element.remove());
          }
          if (!sortCells.has(cell)) {
            cell.classList.remove("master-edited-row", "master-deleted-row");
          }
        });
        if (!edited) {
          return;
        }
        row.querySelectorAll("td").forEach(cell => {
          if (sortCells.has(cell)) {
            return;
          }
          cell.classList.remove("master-edited-row", "master-deleted-row");
          if (this.shouldApplyDirectGridEditedRowColor(row, cell, locked)) {
            cell.classList.add("master-edited-row");
          }
        });
      });
    },
    editBackgroundColor() {
      const grid = this.directGridWidget;
      if (!grid || this.editingFlg) return;
      Array.from(grid.dataSource?.data?.() || []).forEach(item => {
        this.applyDirectGridRowVisual(item);
      });
      this.applyDirectGridSortVisual();
    },
    editableColumns() {
      this.columns.forEach(column => {
        column.editable = column.field === "sortRank" ? () => false : column.originalEditable ? () => true : () => false;
      });
      this.applyDirectGridColumnsContract();
    },
    disableColumns() {
      this.columns.forEach(column => {
        column.editable = column.field === "sortRank" ? (this.isAllowSort ? () => true : () => false) : () => false;
      });
      this.applyDirectGridColumnsContract();
    },
    setDirectGridColumnHidden(fieldName, hidden) {
      const column = this.columns.find(col => col.field === fieldName);
      if (column) column.hidden = hidden;
      const grid = this.directGridWidget;
      if (!grid) return;
      try { hidden ? grid.hideColumn(fieldName) : grid.showColumn(fieldName); } catch (_error) {}
    },
    showSortColumn() {
      const sortRank = this.columns.find(col => col.field === "sortRank");
      const dummy = this.columns.find(col => col.field === "dummy");
      if (sortRank) this.setDirectGridColumnHidden("sortRank", !(this.isAllowSort && this.isSortMode));
      if (dummy) this.setDirectGridColumnHidden("dummy", !(!sortRank || sortRank.hidden));
      this.scheduleDirectGridLayoutContract();
    },
    syncDirectGridSortValuesToMasterRecords() {
      const rows = this.directGridWidget?.dataSource?.data?.();
      if (!rows || !Array.isArray(this.getMasterRecordList?.data)) return;
      const byKey = new Map();
      Array.from(rows).forEach(row => {
        const key = this.getDirectGridRecordKey(row);
        if (key) {
          byKey.set(key, row);
        }
      });
      this.getMasterRecordList.data.forEach(record => {
        const row = byKey.get(this.getDirectGridRecordKey(record));
        if (row?.sortRank !== undefined) {
          record.sortRank = row.sortRank;
        }
      });
    },
    sort() {
      const list = this.getMasterRecordList?.data || [];
      list.sort((a, b) => a.sortRank - b.sortRank || (a.sortInputTime || 0) - (b.sortInputTime || 0));
      list.forEach((row, index) => {
        if (row.isDisp === "1") row.sortRank = index + 1;
      });
    },
    sortChange(tempData) {
      const list = this.getMasterRecordList?.data || [];
      return list.some(item => tempData.some(old => item.code === old.code && item.sortRank !== old.sortRank));
    },
    toRankEditBtnClick() {
      if (!this.validateBeforeGridAction()) return;
      this.storeDirectGridScrollPosition();
      this.isSortMode = true;
      if (!this.directGridSortInitialRanks?.size) {
        this.rememberDirectGridSortInitialRanks();
      }
      this.disableColumns();
      this.showSortColumn();
      this.$nextTick(() => {
        this.applyDirectGridSortVisual();
        this.restoreDirectGridScrollPosition();
        this.scheduleDirectGridPostColumnScrollSync();
      });
    },
    sortBtnClick() {
      this.storeDirectGridScrollPosition();
      this.flushDirectGridPendingEdit();
      const tempData = clonePlain(this.getMasterRecordList?.data || []);
      this.syncDirectGridSortValuesToMasterRecords();
      const changedInCurrentSortMode = this.sortChange(tempData);
      if (changedInCurrentSortMode) {
        this.markDirectGridSortEditedRowsFromGrid();
      }
      this.isSortMode = false;
      this.editableColumns();
      this.showSortColumn();
      this.sort();
      this.isSorted = changedInCurrentSortMode || this.directGridSortEditedCodes?.size > 0;
      this.refreshDirectGridDataFromMasterRecords();
      this.$nextTick(() => {
        this.applyDirectGridSortVisual();
        this.restoreDirectGridScrollPosition();
        this.scheduleDirectGridPostColumnScrollSync();
      });
    },
    convertToStr(messageArr) {
      if (!messageArr || messageArr.length === 0) return "";
      const unique = messageArr.reduce((acc, cur) => {
        if (acc.indexOf(cur) === -1) acc.push(cur);
        return acc;
      }, []);
      return "</br>&nbsp&nbsp・" + unique.join("</br>&nbsp&nbsp・");
    },
    validateRequired() {
      const validateMessageArr = [];
      const gridData = this.getMasterRecordList;
      const rows = (gridData?.data || []).filter(row => row.isDisp !== "0");
      const fields = gridData?.schema?.model?.fields || {};
      rows.forEach(row => {
        Object.keys(fields).forEach(key => {
          if (fields[key]?.validation?.required && row[key] !== null && row[key] === "") {
            const columnInfo = this.columns.find(column => column.field == key);
            if (columnInfo?.title) validateMessageArr.push(columnInfo.title);
          }
        });
      });
      return this.convertToStr(validateMessageArr);
    },
    validateComboValue() {
      const comboFields = this.columns.filter(column => column.values != null).map(column => ({ field: column.field, title: column.title, values: column.values }));
      const rows = (this.getMasterRecordList?.data || []).filter(row => row.isDisp !== "0" && row.isDel === "0");
      const validateMessageArr = [];
      rows.forEach(row => {
        comboFields.forEach(combo => {
          const value = row[combo.field];
          if (value === null || value === undefined || value === "" || value === "null") return;
          if (!(combo.values || []).some(item => String(item.value) === String(value))) validateMessageArr.push(combo.title);
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
    importCsv(event) {
      if (!this.validateBeforeGridAction()) return;
      this.masterCsvTarget = event?.target || null;
      this.masterCsvVisible = true;
    },
    prehideCsvPopover() {
      this.masterCsvVisible = false;
      this.refreshDirectGridDataFromMasterRecords();
    },
    showMasterEditModal(e) {
      e.preventDefault();
      const grid = this.directGridWidget;
      const selectedRowItem = grid?.dataItem?.(e.currentTarget.closest("tr"));
      if (!selectedRowItem) return;
      let code = selectedRowItem.code;
      this.showMasterEdit();
      this.setEditRecord(this.normalization(typeof selectedRowItem.toJSON === "function" ? selectedRowItem.toJSON() : selectedRowItem));
      if (!code) {
        this.edit({ editRecord: selectedRowItem, isSortMode: this.isSortMode });
        code = selectedRowItem.code;
      }
    },
    onCloseMasterEditModal() {
      this.$nextTick(() => this.refreshDirectGridDataFromMasterRecords());
    },
    // refresh() {
    //   if (this.selfScreenName === this.getCurrentRouteName() && document.getElementsByTagName("ons-alert-dialog").length === 0) {
    //     this.setCondition(this.condition);
    //     this.loadGridData();
    //   }
    // },
    getisChanged() {
      return !!this.isChanged;
    },
    // 共通ローダー設定
    ...mapActions("loading-screen", {
      setLoadingScreenVisible: "setLoadingScreenVisible",
      setLoadingScreenMessage: "setLoadingScreenMessage",
      resetLoadingScreenVisibleCount:  "resetLoadingScreenVisibleCount"
    }),
    numericEditor(container, options){
      $('<input data-bind="value:' + options.field + '"/> ')
        .appendTo(container)
        .kendoNumericTextBox({"format": "n2", "decimals": 2, "round": false, "step": "0.01", "min": 0, "max": 300});
    },
    // add 車いすマスタ BUG改修 「個人所有」がキャンセルされる場合、まだ「所有患者」している start

    onDirectGridSave(ev) {
      this.editingFlg = false;
      this.captureDirectGridScrollBeforeEditClose();
      const appliedSaveValue = this.applyKendoSaveValuesToModel(ev);
      let appliedSideEffect = false;
      const saveValues = ev.values || {};
      const dropDownWidget = getGridEditorDropDownListWidget(ev?.container);
      //所有患者なしの場合
      if (saveValues.isPersonal && saveValues.isPersonal=="0") {
        if (ev.model.patId !== "") {
          ev.model.patId=""
          appliedSideEffect = true;
        }
      }
      if (Object.prototype.hasOwnProperty.call(saveValues, "wheelChairWeight")) {
        const comparisonModel = this.$store.state["master-maintenance"].comparisonRecordModel;
        const originalRows = comparisonModel ? JSON.parse(comparisonModel) : [];
        const originalRow = originalRows.find(row => row.code === ev.model.code);
        const newWeight = saveValues.wheelChairWeight;
        const originalWeight = originalRow?.wheelChairWeight;
        if (newWeight && Number(newWeight) !== 0 && Number(newWeight) !== Number(originalWeight)) {
          if (ev.model.scaleUserId !== this.getStateUserAccountInfo.userId) {
            ev.model.scaleUserId = this.getStateUserAccountInfo.userId;
            appliedSideEffect = true;
          }
        }
      }
      let sortRankEdited = false;
      if (Object.prototype.hasOwnProperty.call(saveValues, "sortRank")) {
        const nextSortRank = saveValues.sortRank;
        sortRankEdited = this.markDirectGridSortEditedRecord({ ...(typeof ev.model?.toJSON === "function" ? ev.model.toJSON() : ev.model), sortRank: nextSortRank });
      }
      if (!appliedSaveValue && !appliedSideEffect && !sortRankEdited && !ev.model.edited) {
        this.scheduleDirectGridCurrentRowVisual(ev.model);
        this.scheduleDirectGridDropDownRefreshIfNeeded(ev, dropDownWidget);
        return;
      }
      const editRecord = typeof ev.model?.toJSON === "function" ? ev.model.toJSON() : { ...ev.model };
      if (ev.model.operation === 1) {
        editRecord.edited = true;
      }
      this.edit({ editRecord, isSortMode: this.isSortMode });
      !this.isRecordModified && this.editBackgroundColor();
      this.scheduleDirectGridCurrentRowVisual(ev.model);
      this.scheduleDirectGridDropDownRefreshIfNeeded(ev, dropDownWidget);
    },
    scheduleDirectGridDropDownRefreshIfNeeded(ev, dropDownWidget) {
      if (!dropDownWidget) {
        return;
      }
      const savedScroll = this.captureDirectGridScrollBeforeEditClose();
      this.$nextTick(() => {
        try {
          ev?.sender?.refresh?.();
        } catch (_error) {
          // noop
        }
        this.setGridScrollPosition(savedScroll);
        this.scheduleDirectGridPostColumnScrollSync();
      });
    },
    onSave(ev) {
      this.onDirectGridSave(ev);
    },
    // add 車いすマスタ BUG改修 「個人所有」がキャンセルされる場合、まだ「所有患者」している end
    getG2KgTemplate() {
      return (dataItem = {}) => {
        const value = dataItem?.wheelChairWeight;
        return value == null ? "" : Number(value).toFixed(2);
      };
    },
    // マスタ一覧のデータを取得
    findList() {
      // apiをコールして値を取得
      // mod マスタ一覧 1･施設切替を可能とする 孔 this.findRecordList => this.findRecordListByFacilityCd
      // this.findRecordList()
      this.findRecordListByFacilityCd(this.facilitylistValue)
        .then(async response => {
                this.directGridSortInitialRanks = markRaw(new Map());
                this.directGridSortEditedCodes = markRaw(new Set());
                this.getMasterRecordListOld = deepCopy(this.getMasterRecordList.data)
                this.getMasterRecordListOld.forEach(item => {
                  if (item.wheelChairWeight) {
                    item.wheelChairWeight = (item.wheelChairWeight / 1000).toFixed(2)
                  }
                });
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
            /* del by chamaojia 2023-07-10 装置マスタ初期化エラー  --start */
            // // 利用者氏名・・・
            // if (column.field === "scaleUserId") {
            //   column.values = personalUserList;
            // }
            // // 患者氏名・・・
            // if (column.field === "patId") {
            //   column.values = patPersonalList;
            // }
            /* del by chamaojia 2023-07-10 装置マスタ初期化エラー  --end */
          });
          // 利用者氏名のデータ取得
          const personalUserList = this.getPersonalUserList;
          // 患者氏名のデータ取得
          const patPersonalList = this.getPatPersonalList;
          toFunction.forEach(column => {
            // 利用者データを追加
            if (column.field === "scaleUserId") {
              column.values = personalUserList;
            }
            // 患者氏名用データを追加
            if (column.field === "patId") {
              column.values = patPersonalList;
            }
            // 表示設定
            if (column.field === "wheelChairWeight") {
              column.format = "{0:##,#}";
              column.template = this.getG2KgTemplate();
            }
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
            this.normalizeInitialGridHeight();
            /* add スクロールの位置を維持 楊 start */
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
            setTimeout(() => {
              this.lastScrollTop = 0;
              this.lastScrollLeft = 0;
            }, 1000);
            /* add スクロールの位置を維持 楊 end */
          });

          for (const argument of response.data.localDataSource.data) {
            argument.wheelChairWeight /= 1000;
          }

          // 初期データ内容を保存
          this.setComparisonRecordModel();

        })
        .catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
          getErrorMessage('MstWheelChairMainComponent.vue', 'findList', '指定されたマスタが見つかりません。');
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
          if (error.response.status === 400) {
            this.$ons.notification.alert({
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // title: "取得失敗",
              // message: "指定されたマスタが見つかりません。"
              title: DIALOG_MESSAGES[12000003].title,
              message: messageFormat(DIALOG_MESSAGES[12000003].message),
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
            });
          }
        });
      // カラム定義情報を取得
      this.findColumnInfo();
    },
    async saveRecord() {
      // 共通ローダー:表示開始
      this.setLoadingScreenVisible(true);
      /* add スクロールの位置を維持 楊 start */
      this.storeDirectGridScrollPosition();
      this.preserveGridScrollAfterSave = true;
      /* add スクロールの位置を維持 楊 end */
      // グリッドでエラーが発生している場合は処理を中断
      if (!this.validateBeforeGridAction()) {
        //共通ローダー：表示終了
        this.setLoadingScreenVisible(false);
        this.preserveGridScrollAfterSave = false;
        this.restoreDirectGridScrollPosition();
        return;
      }
      for (let i = 0; i < this.getMasterRecordList.data.length; i++) {
        this.getMasterRecordList.data[i].wheelChairWeight = this.getMasterRecordList.data[i].wheelChairWeight * 1000;
      }
      // 新規追加＆未入力のレコードを除外
      const records = this.getMasterRecordList;
      records.data = records.data.filter(
        r => !(r.operation === 1 && !r.edited)
      );
      this.setMasterRecordList(records);

      // 必須エラーをチェック
      const validateMessage = this.validateRequired();
      // 所有チェック
      const validatePersonalMessage = this.validatePersonal();
      // 所有者の重複チェック
      const validateSamePatIdMessage = this.validateSamePatId();
      // コンボで削除済みのレコードが指定されていないかをチェック
      const validateComboMessage = this.validateComboValue();

      let message = "";
      if (validateMessage.length !== 0) {
        // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
        // message = "以下の列に未入力項目が存在します。" + validateMessage;
        message = messageFormat(DIALOG_MESSAGES[12000270].message) + validateMessage;
        // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
      }
      if (validatePersonalMessage.length !== 0) {
        if (message.length !== 0) message = message + "</br>";
        message =
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
          // message + "以下の項目で問題があります。" + validatePersonalMessage;
          message +  messageFormat(DIALOG_MESSAGES['00200071'].message) + validatePersonalMessage;
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
      }
      if (validateComboMessage.length !== 0) {
        if (message.length !== 0) message = message + "</br>";
        message =
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
          // message + "以下の列に異常な項目が存在します。" + validateComboMessage;
          message +  messageFormat(DIALOG_MESSAGES['00200110'].message) + validateComboMessage;
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
      }
      if (validateSamePatIdMessage.length !== 0) {
        if (message.length !== 0) message = message + "</br>";
        message =
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
          // message + "以下の項目で問題があります。" + validateSamePatIdMessage;
          message +  messageFormat(DIALOG_MESSAGES['00200071'].message) + validateSamePatIdMessage;
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
      }
      // エラーメッセージは左寄せで表示
      if (message.length !== 0) {
        for (let i = 0; i < this.getMasterRecordList.data.length; i++) {
          this.getMasterRecordList.data[i].wheelChairWeight = this.getMasterRecordList.data[i].wheelChairWeight / 1000;
        }
        //共通ローダー：表示終了
        this.setLoadingScreenVisible(false);
        this.preserveGridScrollAfterSave = false;
        this.restoreDirectGridScrollPosition();
        this.$ons.notification.alert({
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
          // title: "チェックエラー",
          title: DIALOG_MESSAGES['00200071'].title,
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
          message: '<div style="text-align:left;">' + message + "</div>"
        });
        return;
      }

      // apiをコールして値を保存
      // mod マスタ一覧 1･施設切替を可能とする 孔 this.updateRecordList => this.updateRecordListByFacilityCd
      // await this.updateRecordList(this.getUpdateRecordList)
      await this.updateRecordListByFacilityCd({
        facilityCd: this.facilitylistValue,
        request: this.getUpdateRecordList
      })
        .then(response => {
          //共通ローダー：表示終了
          this.setLoadingScreenVisible(false);
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
          getErrorMessage('MstWheelChairMainComponent.vue', 'saveRecord', error);
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
          this.preserveGridScrollAfterSave = false;
          this.restoreDirectGridScrollPosition();
          if (error.response.status === 400) {
          //共通ローダー：表示終了
          this.setLoadingScreenVisible(false);
            this.$ons.notification.alert({
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // title: "更新失敗",
              title: DIALOG_MESSAGES["00300005"].title,
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
              message: error.response.data.errorMessage
            });
          }
        });
    },
    /**
     * 各項目の検証
     */
    validatePersonal() {
      let validateMessageArr = [];
      // 削除されていないレコード
      const gridData = this.getMasterRecordList;
      const rows = gridData.data;
      for (let rowIdx = 0; rowIdx < rows.length; rowIdx++) {
        let rowNo = rowIdx + 1;
        // 所有フラグ
        let isPersonal = rows[rowIdx]["isPersonal"];
        // 患者指定
        let patId = rows[rowIdx]["patId"];
        // 所有患者未指定チェック
        if (isPersonal === "1" && (patId === null || patId === "")) {
          // 患者未指定
          const strErr =
            "所有患者未指定：<br>　　　" +
            rowNo +
            "行目";
          validateMessageArr.push(strErr);
        }
      }
      this.getMasterRecordList.data = rows;
      this.setMasterRecordList(this.getMasterRecordList);
      return this.convertToStr(validateMessageArr);
    },
    /**
     * 患者重複チェック
     */
    validateSamePatId() {
      let validateMessageArr = [];
      const gridData = this.getMasterRecordList;
      const rows = gridData.data;
      for (let rowIdx = 0; rowIdx < rows.length; rowIdx++) {
        let rowNo = rowIdx + 1;
        // 患者指定
        let patId = rows[rowIdx]["patId"];
        if(patId !== null && patId !== "") {
          const ret = rows.filter(item => {
            return +item.patId === +patId;
          })
          if(ret.length > 1){
            // 指定患者が重複
            const strErr =
              "所有患者が重複してます：<br>　　　" +
              rowNo +
              "行目";
            validateMessageArr.push(strErr);
          }
        }
      }
      return this.convertToStr(validateMessageArr);
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
        // バリデーションで必須が定義されているかどうか
        const validation = fields[k].validation;
        const isRequired =
          typeof validation !== "undefined" && validation.required;
        if (fields[k].defaultValue) {
          d[k] = fields[k].defaultValue;
        } else if (fields[k].type === "string") {
          d[k] = "";
        } else if (fields[k].type === "number") {
          if (isRequired) {
            d[k] = 0;
          } else {
            d[k] = null;
          }
        } else if (fields[k].type === "date") {
          if (isRequired) {
            d[k] = new Date();
          } else {
            d[k] = null;
          }
        } else {
          d[k] = null;
        }

        // 初期時、新しいレコードに全レコードの並び順の最大値をセット
        if (k === "sortRank") {
          d[k] = this.getMaxSortRank() + 1;
        }
      });
      this.lastScrollLeft = 0;
      this.scrollPosition.left = 0;
      this.edit({ editRecord: d, isSortMode: this.isSortMode });
      this.refreshDirectGridDataFromMasterRecords(true);
      this.$nextTick(() => {
        const content = this.getDirectGridScrollContent();
        if (content) {
          const top = Math.max(0, content.scrollHeight - content.clientHeight);
          this.setGridScrollPosition({ top, left: 0 });
        }
        this.editBackgroundColor();
        requestAnimationFrame(() => {
          const gridContent = this.getDirectGridScrollContent();
          if (gridContent) {
            const top = Math.max(0, gridContent.scrollHeight - gridContent.clientHeight);
            this.setGridScrollPosition({ top, left: 0 });
          }
        });
      });
    },
    async loadGridData(){
      // delete start #9590
        // this.setCondition(this.condition);
        // delete end #9590
      // mod マスタ一覧 1･施設切替を可能とする 孔 start
      // await this.fetchPersonalUser();
      const facilityCds = new Array();
      facilityCds.push(this.facilitylistValue)
      if (this.facilitylistValue !== "nkknkk") {
        facilityCds.push("nkknkk")
      }
      await this.fetchPersonalUserByFacilityCd(facilityCds);
      // await this.fetchPatPersonal(this.getFacilityCd);
      await this.fetchPatNameByFacilityCd(this.facilitylistValue);
      // mod マスタ一覧 1･施設切替を可能とする 孔 end

      // mod マスタ一覧 1･施設切替を可能とする 孔 this.getFacilityCd => this.facilitylistValue
      // this.fetchMstWeightScale(this.getFacilityCd).then(response => {
      this.fetchMstWeightScale(this.facilitylistValue).then(response => {
        this.setMstWeightScale(response.data).then(() => {
          this.findList();
        }).catch(e => {
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
          getErrorMessage('MstWheelChairMainComponent.vue', 'loadGridData', e);
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
          console.error(e);
          this.findList();
        });
      }).catch(e => {
        //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
        getErrorMessage('MstWheelChairMainComponent.vue', 'loadGridData', e);
        //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
        console.error(e);
        this.findList();
      });
    },
    onBeforeEdit(e) {
      if (this.isMobileDevice && !this.allowEdit) {
        /* NOTE:
         * モバイル系は、スワイプ・フリック操作で入力パッドが表示される。
         * そのため、スクロール操作が損なわれるので、閲覧モードのときは
         * 後続のイベントを発火させないように制御する。
         */
        e.preventDefault();
        return;
      }
      this.editStart(e);
    },
    /** 画面印刷前の処理 */
    handleBeforePrint() {
      const grid = this.getGridWidget();
      if (!grid) return;
      if (!this._initialColumns?.length || this._initialColumns.length !== this.columns.length) {
        this._initialColumns = this.columns.map(col => ({ ...col }));
      }

      const columns = (grid.getOptions?.().columns || grid.columns || this.columns || [])
        .map(col => ({ ...col }));
      columns.forEach((col, index) => {
        col.locked = false;
        if (index === 0) {
          col.hidden = true;
        } else if (!col.hidden) {
          col.width = undefined;
        }
      });

      const scaleDateCol = columns.find(col => col.field === "scaleDate");
      if (scaleDateCol) {
        scaleDateCol.width = 90;
      }

      grid.setOptions?.({ columns });
    },
    /** 画面印刷後の処理 */
    handleAfterPrint() {
      if (this._initialColumns?.length) {
        this._initialColumns.forEach((savedCol, index) => {
          if (this.columns[index]) {
            Object.assign(this.columns[index], savedCol);
          }
        });
      }

      const grid = this.getGridWidget();
      if (!grid) return;
      grid.setOptions?.({ columns: this.buildDirectGridColumns() });
      grid.dataSource?.read?.();
    },
    normalizeInitialGridHeight() {
      if (this.initialGridHeightAdjusted) {
        return;
      }
      const ownerWindow = this.$el?.ownerDocument?.defaultView || globalThis;
      const isGridHeightReady = () => {
        const gridRoot = this.getGridRootEl?.()
          || this.$el?.querySelector?.('.k-grid.k-grid-lockedcolumns');
        return !!(gridRoot
          && gridRoot.clientHeight > 0
          && Number.isFinite(this.kendoGridHeight)
          && this.kendoGridHeight > 0);
      };
      const runAdjust = () => {
        this.calculateGridHeight();
        this.calculateGridWidth();
      };
      this.$nextTick(() => {
        (ownerWindow.requestAnimationFrame || ((cb) => setTimeout(cb, 16)))(() => {
          runAdjust();
          setTimeout(() => {
            runAdjust();
            if (isGridHeightReady()) {
              this.initialGridHeightAdjusted = true;
            }
          }, 80);
        });
      });
    }
  },
  created() {
    this.setLoadingScreenVisible(true);
    this.calculateColumnsWidth();
    // add マスタ一覧 1･施設切替を可能とする 孔 start
    this.facilitylistValue = this.getFacilitySwitch;
    // add マスタ一覧 1･施設切替を可能とする 孔 end
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
    EventBus.$on("refresh", this.refresh);
  },
  mounted() {
    installComponentJQuery();
    this.directGridMounted = true;
    this.$nextTick(() => {
      this.calculateColumnsWidth();
      this.calculateGridHeight();
      this.calculateGridWidth();
      this.initDirectGridIfReady();
      this.normalizeInitialGridHeight();
      const ownerWindow = this.$el?.ownerDocument?.defaultView || window;
      ownerWindow.addEventListener("beforeprint", this.handleBeforePrint);
      ownerWindow.addEventListener("afterprint", this.handleAfterPrint);
    });
    // 初期columnsをシャローコピーで保存（関数も保持される）
    this._initialColumns = this.columns.map(col => ({ ...col }));
  },
  // add 性能改善メモリ不足 shan start
  beforeUnmount() {
    EventBus.$off("onCloseMasterEditModal", this.onCloseMasterEditModal);
    EventBus.$off("refresh", this.refresh);
    const ownerWindow = this.$el?.ownerDocument?.defaultView || window;
    ownerWindow.removeEventListener("beforeprint", this.handleBeforePrint);
    ownerWindow.removeEventListener("afterprint", this.handleAfterPrint);
    [this.directGridLayoutRafId, this.directGridFilterRefreshRafId, this.directGridScrollSyncRafId].forEach(id => {
      if (id != null) cancelAnimationFrame(id);
    });
    this.directGridRowVisualRafIds?.forEach?.(id => cancelAnimationFrame(id));
    this.directGridRowVisualRafIds?.clear?.();
    // tooltip 配置用タイマーのみ解除（業務データ・store は触らない）
    this.clearValidationTooltipPlacementTimers();
    this.stopValidationTooltipPlacementWatch();
    this.clearValidationTooltipPlacementState();
    this.destroyKendoValidator();
    this.destroyDirectGrid();
  },
  // add 性能改善メモリ不足 shan end
  // add #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（車いすマスタ画面）20231107 ztc start
  beforeRouteLeave(to, from, next) {
    if (this.getisChanged()) {
      this.$ons.notification.confirm({
        // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
        // title: "内容破棄",
        title: DIALOG_MESSAGES[13000004].title,
        // message: "編集内容が破棄されます。</br>よろしいですか？",
        message: messageFormat(DIALOG_MESSAGES[13000004].message),
        // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
        callback: answer => {
          next(answer === 1);
        }
      });
    } else {
      next();
    }
  },
  // add #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（車いすマスタ画面）20231107 ztc end
};
</script>


<style scoped>

/* Vue2 kendo-grid wrapper style contract for this direct jq screen. */
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
  padding: 0.1em 0.3em;
  box-sizing: border-box;
}
.toolbar-btn {
  font-size: 1.0em;
  padding: 0.2em 1em 0em 1em;
  line-height: 2em;
  width: auto;
}
.kendo-grid-toolbar-style :deep(.toolbar-btn),
.kendo-grid-toolbar-style :deep(.toolbar-btn *) {
  font-family: inherit;
  width: auto;
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

.kendo-grid-toolbar-style :deep(.k-grid-header-locked > table) {
  border-right-width: 0px;
}
.kendo-grid-toolbar-style :deep(.k-grid-header-locked) {
  border-right: 1px solid var(--ntss-list-border-color) !important;
}
.kendo-grid-toolbar-style :deep(.k-grid-content-locked) {
  z-index: 1;
  box-shadow: 1px 0px 0px 0px var(--ntss-border-color) !important;
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
/* バリデーション tooltip をセル外へ absolute 配置（行高を変えず locked/non-locked のずれを防ぐ） */
.kendo-grid-toolbar-style :deep(.k-edit-cell) {
  position: relative;
  overflow: visible;
}
.kendo-grid-toolbar-style :deep(.k-edit-cell > .k-invalid-msg:not(.k-hidden)),
.kendo-grid-toolbar-style :deep(.k-edit-cell > .k-form-error:not(.k-hidden)),
.kendo-grid-toolbar-style :deep(.k-edit-cell > .k-validator-tooltip:not(.k-hidden)),
.kendo-grid-toolbar-style :deep(.k-edit-cell > .k-tooltip-error:not(.k-hidden)),
.mst-wheel-chair-direct-jq-grid :deep(.k-edit-cell > .k-invalid-msg:not(.k-hidden)),
.mst-wheel-chair-direct-jq-grid :deep(.k-edit-cell > .k-tooltip-error:not(.k-hidden)) {
  position: absolute;
  top: calc(100% + 2px);
  bottom: auto;
  z-index: 10;
  width: auto;
  min-width: 10em;
  max-width: min(24em, 90vw);
  margin: 0;
  white-space: normal;
  display: flex !important;
  align-items: flex-start;
  font-family: inherit !important;
  font-size: inherit !important;
  font-weight: normal !important;
  line-height: 1.4 !important;
  box-sizing: border-box;
  transform: none !important;
}
/*
 * 最終行など下端: JS が付与する ntss-validation-above で tooltip をセル上に表示。
 * 表示位置・callout 向きのみ。必須判定や saveRecord の処理は変更しない。
 */
.kendo-grid-toolbar-style :deep(td.k-edit-cell.ntss-validation-above > .k-invalid-msg),
.kendo-grid-toolbar-style :deep(td.k-edit-cell.ntss-validation-above .k-tooltip.k-tooltip-validation),
.mst-wheel-chair-direct-jq-grid :deep(td.k-edit-cell.ntss-validation-above > .k-invalid-msg),
.mst-wheel-chair-direct-jq-grid :deep(td.k-edit-cell.ntss-validation-above .k-tooltip.k-tooltip-validation) {
  position: absolute !important;
  left: 0 !important;
  bottom: 38px !important;
  top: auto !important;
  margin-top: 0 !important;
  overflow: visible !important;
}
/* セル上表示時の callout（赤角標）向き */
.kendo-grid-toolbar-style :deep(td.k-edit-cell.ntss-validation-above .k-callout.k-callout-s),
.mst-wheel-chair-direct-jq-grid :deep(td.k-edit-cell.ntss-validation-above .k-callout.k-callout-s) {
  top: auto !important;
  bottom: calc(-12px) !important;
  border-bottom-color: transparent !important;
  border-block-start-color: currentColor !important;
}
.kendo-grid-toolbar-style :deep(.k-edit-cell .k-tooltip-content) {
  font-family: inherit !important;
  font-size: inherit !important;
  font-weight: normal !important;
  line-height: 1.4 !important;
}
.kendo-grid-toolbar-style :deep(.k-grid-content > .k-selectable) {
  box-shadow: 1px 0px 0px 0px white;
  border-right: 1px solid transparent;
}
.kendo-grid-toolbar-style :deep(.k-grid-content-locked > .k-selectable) {
  border-right-width: 0px;
}
.kendo-grid-toolbar-style :deep(.k-grid-content td:not(.k-edit-cell)),
.kendo-grid-toolbar-style :deep(.k-grid-content .k-table-td:not(.k-edit-cell)),
.kendo-grid-toolbar-style :deep(.k-grid-content-locked td:not(.k-edit-cell)),
.kendo-grid-toolbar-style :deep(.k-grid-content-locked .k-table-td:not(.k-edit-cell)) {
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.mst-wheel-chair-direct-jq-grid :deep(td.master-edited-row),
.mst-wheel-chair-direct-jq-grid :deep(tr.master-edited-row > td.master-edited-row),
.mst-wheel-chair-direct-jq-grid :deep(tr.k-selected > td.master-edited-row),
.mst-wheel-chair-direct-jq-grid :deep(tr.k-state-selected > td.master-edited-row),
.mst-wheel-chair-direct-jq-grid :deep(tr.k-table-row.k-selected > td.master-edited-row),
.mst-wheel-chair-direct-jq-grid :deep(tr.k-grid-edit-row > td.master-edited-row) {
  color: #003300 !important;
  background-color: #ccffcc !important;
}
.mst-wheel-chair-direct-jq-grid :deep(td.master-edited-cell) {
  color: #003300 !important;
  font-weight: bold !important;
}
.mst-wheel-chair-direct-jq-grid :deep(td.master-sort-edited),
.mst-wheel-chair-direct-jq-grid :deep(td.master-sort-edited.master-edited-row),
.mst-wheel-chair-direct-jq-grid :deep(tr.master-edited-row > td.master-sort-edited),
.mst-wheel-chair-direct-jq-grid :deep(tr.k-selected > td.master-sort-edited),
.mst-wheel-chair-direct-jq-grid :deep(tr.k-state-selected > td.master-sort-edited),
.mst-wheel-chair-direct-jq-grid :deep(tr.k-table-row.k-selected > td.master-sort-edited),
.mst-wheel-chair-direct-jq-grid :deep(tr.k-grid-edit-row > td.master-sort-edited) {
  color: #000000 !important;
  background-color: #ffff66 !important;
}
.mobile-header {
  min-height: 30px;
}

@media print {
  /* kendoグリッド全体を紙幅に合わせる */
  .ntss-list :deep(div),
  .kendo-grid-toolbar-style {
    height: auto !important;
  }
  .k-grid {
    width: 100% !important;
  }

  .k-grid :deep(.k-grid-header) {
    padding-right: 0 !important;
  }

  /* ヘッダー・ボディ両方のテーブルを紙幅に収める */
  .k-grid :deep(table),
  .k-grid :deep(.k-grid-header table),
  .k-grid :deep(.k-grid-content table) {
    width: 100% !important;
    table-layout: fixed !important;
  }
  .k-grid :deep(td),
  .k-grid :deep(th) {
    padding: 1px 1px !important;
    white-space: normal !important;
    word-break: break-all !important;
    overflow: visible !important;
  }

  /* スクロール解除 */
  .k-grid :deep(.k-grid-content),
  .k-grid :deep(.k-grid-header-wrap) {
    overflow: visible !important;
    height: auto !important;
  }

  /* 詳細ボタン幅 */
  .k-grid :deep(.k-button) {
    padding: .375rem .2rem;
  }
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
