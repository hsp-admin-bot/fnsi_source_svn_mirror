// 影響範囲:
// 38:職種マスタ mst_job
// 190:よく使う施設マスタ mst_favorite_facility
// 210:禁忌・アレルギーマスタ mst_taboo_allergy
// 300:病名マスタ mst_disease
// 460:薬剤マスタ mst_medicine
// 610:検査項目マスタ mst_exam_item
// 1100:日常・定期点検項目マスタ mst_mainte_detail
<template>
  <div class="virtual-container master-maintenance-page">
    <div class="tool-bar" :class="{ 'sort-mode': isSortMode, 'sort-mode-exam-item': masterPhysicalName === 'mst_exam_item' } ">
      <div :class="['tool-bar-left', isMobileDevice ? 'mobile-header' : '']">
        <v-ons-button
          v-if="!isSortMode && isAllowAddRecord && isAddButton"
          modifier="outline"
          class="btn3-normal toolbar-btn"
          @click="onAdd"
          >追加
        </v-ons-button>
        <v-ons-button
          modifier="outline"
          v-if="masterPhysicalName === 'mst_exam_item'"
          class="btn3-normal toolbar-btn re-calculation-btn"
          @click="showMstExamItemRecManagementModal"
          >再計算</v-ons-button
        >
        <v-ons-row v-show="isMobileDevice" style="float: right; width: 7em; height: 1em; margin-left: 1em;">
          <v-ons-col width="45%" vertical-align="center">
            <label class="fab-font-color">編集</label>
          </v-ons-col>
          <v-ons-col width="55%" vertical-align="center">
            <v-ons-switch modifier="outline" v-model="allowEdit" />
          </v-ons-col>
        </v-ons-row>
      </div>
      <div class="tool-bar-right">
        <v-ons-button
          v-if="
            !isSortMode &&
            isAllowAddRecord &&
            masterPhysicalName !== 'mst_favorite_facility'
          "
          modifier="outline"
          class="btn3-normal toolbar-btn right10"
          @click="importCsv"
          >CSV取込</v-ons-button
        >
        <v-ons-button
          v-if="isAllowSort"
          modifier="outline"
          class="btn3-normal toolbar-btn"
          @click="handleToggleSortMode"
          >{{ isSortMode ? "反映" : "並び順表示" }}
        </v-ons-button>
      </div>
    </div>
    <div
      class="grid-content virtual-grid-locked-layout"
      :style="gridContentStyles"
    >
      <div
        ref="grid"
        :class="[
          isSortMode ? 'sort-mode' : '',
          'ntss-kendo-grid-legacy',
          'master-direct-jq-grid',
          'master-record-virtual-scrollable-direct-jq-grid',
        ]"
        style="height: 100%; clear: both;"
      ></div>
    </div>
    <div v-if="!isSortMode" class="footer">
      <v-ons-button class="btn2-cancel toolbar-btn" @click="onCancel"
        >キャンセル</v-ons-button
      >
      <v-ons-button
        type="submit"
        modifier="outline"
        class="btn3-normal toolbar-btn"
        :disabled="isNotChanged"
        @click="onSaveChanges"
        >保存
      </v-ons-button>
    </div>
    <master-csv
      :popoverVisible="masterCsvVisible"
      :popoverTarget="masterCsvTarget"
      @popover-close="masterCsvVisible = false"
      @addRow="getCsvData"
    />
  </div>
</template>

<script>
import {
  sendRequestFindRecordListByFacilityCd,
  sendRequestUpdateRecordListByFacilityCd,
  sendRequestFindRecordListByFacilityCdWithSql,
} from "@/apis/master-maintenance";
import { sendRequestGetMstFacilitySettingValue } from "@/apis/facility-setting";
import {
  PERMISSION_CHANGE_SIGNOUT,
  DEFAULT_PROCEDURE,
  DEFAULT_MEDICATE_TIMING,
} from "@/constants/facilitySetting";
import MasterCsvComponent from "@/components/master-maintenance/MasterCsvComponent";
import { EventBus } from "@/compat/vue/event-bus.js";
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages.js";
import { messageFormat } from "@/functions/common/MessageFormat";
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
import { mapState, mapActions, mapMutations } from "@/compat/vue/vuex";
import _ from "@/compat/collections/lodash";
import {
  customComparator,
  emToPx,
  pxForFontSize,
  diffObj,
  isEmpty,
} from "@/utils/util.js";
import MstValidateMixins from "./MstValidateMixins";
import MstExamItemMixins from "./MstExamItemMixins";
import ColumnWidthMap from "./MasterColumnWidth.js";

import commonCalender from "@/components/common/custom-calendar/CustomCalendar";
import { createApp, markRaw } from "@/compat/vue/runtime";
import { deleteDataProcessing } from "@/functions/mst/MasterMaintenanceFunctions";
import { syncKendoGridLockedRowHeights } from "@/utils/kendoGridLockedSync";
import dayjs from "@/compat/date/dayjs";


import $ from "jquery";
import {
  bindGridEditorEnterToCloseCell,
  bindGridEditorNumericWheelSpinAssist,
  getGridEditFieldFromEvent,
  readGridEditorNumericValue,
} from "@/compat/kendo/grid-edit";
import {
  createJQueryValidator,
  destroyJQueryValidator,
} from "@/compat/kendo/kendo-jquery.js";

const getKendoCtor = () => {
  const ownerWindow = typeof window !== "undefined" ? window : globalThis;
  return ownerWindow?.kendo || globalThis?.kendo;
};

const getKendoDataSourceCollection = (dataSource) => dataSource?.data?.() || null;

const getKendoDataSourceItems = (dataSource) => {
  const collection = getKendoDataSourceCollection(dataSource);
  return collection ? Array.from(collection) : [];
};

const toKendoDataSourcePlainItem = (item) => item?.toJSON?.() || { ...item };

const toKendoDataSourcePlainItems = (items) => Array.from(items || []).map((item) => toKendoDataSourcePlainItem(item));

const getKendoDataSourcePlainItems = (dataSource) => {
  const collection = getKendoDataSourceCollection(dataSource);
  if (!collection) {
    return [];
  }
  return collection.toJSON?.() || toKendoDataSourcePlainItems(collection);
};

const createDataSource = (options) => {
  const kendoObject = getKendoCtor();
  return new kendoObject.data.DataSource(options);
};

const getKendoDataSourceTake = (dataSource) => dataSource?.take?.() || dataSource?._take || 0;
const getKendoDataSourceTotal = (dataSource) => dataSource?.total?.() || getKendoDataSourceItems(dataSource).length;
const getKendoDataSourceCurrentRangeStart = (dataSource) => dataSource?._currentRangeStart || 0;
const getKendoDataSourceItemAt = (dataSource, index) => getKendoDataSourceCollection(dataSource)?.at?.(index);
const getKendoDataSourceItemByUid = (dataSource, uid) => dataSource?.getByUid?.(uid) || null;
const addKendoDataSourceItem = (dataSource, item) => dataSource?.add?.(item);
const triggerKendoDataSourceEvent = (dataSource, eventName) => dataSource?.trigger?.(eventName);
const hasKendoDataSourceChanges = (dataSource) => !!dataSource?.hasChanges?.();
const rangeKendoDataSource = (dataSource, start, take, callback) => dataSource?.range?.(start, take, callback);

const getKendoGridWrapperElement = (grid) => grid?.wrapper?.[0] || null;
const getKendoGridDataItems = (grid) => Array.from(grid?.dataItems?.() || []);
const getKendoGridDataItem = (grid, row) => grid?.dataItem?.(row);
const getKendoEventContainerElement = (event) => event?.container?.[0] || event?.container || null;

const findAllKendoGridRowByUid = (grid, uid) => {
  const wrapper = getKendoGridWrapperElement(grid);
  return wrapper ? Array.from(wrapper.querySelectorAll(`tr[data-uid="${uid}"]`)) : [];
};

const clearKendoEditorControlTitles = (container) => {
  const $container = container?.jquery ? container : $(container);
  $container.find(".k-textbox, .k-input, .k-dropdown, .k-link").attr("title", "");
};

const isValidDate = (date) => date instanceof Date && !Number.isNaN(date.getTime());

/** DB/API の日付値を Kendo 日付列表示用の Date に変換する（MasterRecordComponent と同様） */
const yyyymmddToDate = (value) => {
  if (value == null || value === "") {
    return value;
  }
  if (value instanceof Date) {
    return value;
  }
  const str = String(value);
  const fromYyyymmdd = dayjs(str, "YYYYMMDD", true);
  if (fromYyyymmdd.isValid()) {
    return fromYyyymmdd.toDate();
  }
  const fromSlashDate = dayjs(str, "YYYY/MM/DD", true);
  if (fromSlashDate.isValid()) {
    return fromSlashDate.toDate();
  }
  const fromIsoDate = dayjs(str, "YYYY-MM-DD", true);
  if (fromIsoDate.isValid()) {
    return fromIsoDate.toDate();
  }
  const fromIsoDateTime = str.match(/^(\d{4})-(\d{2})-(\d{2})T/);
  if (fromIsoDateTime) {
    return new Date(
      Number(fromIsoDateTime[1]),
      Number(fromIsoDateTime[2]) - 1,
      Number(fromIsoDateTime[3])
    );
  }
  return value;
};

/** HTML5 date 入力・CustomCalendar 用（YYYY-MM-DD） */
const formatMasterDateIsoValue = (value) => {
  const date = yyyymmddToDate(value);
  if (!isValidDate(date)) {
    return value || "";
  }
  return `${date.getFullYear()}-${("0" + (date.getMonth() + 1)).slice(-2)}-${("0" + date.getDate()).slice(-2)}`;
};

/** 詳細画面→主画面の日付比較用（形式差を吸収） */
const getMasterDateCompareKey = (value) => {
  if (value == null || value === "") {
    return null;
  }
  const date = yyyymmddToDate(value);
  return isValidDate(date) ? date.getTime() : value;
};

/** 詳細画面からの日付値を Kendo 日付列表示用 Date に変換する */
const normalizeMasterDateForGrid = (value) => {
  if (value == null || value === "") {
    return null;
  }
  const date = yyyymmddToDate(value);
  return isValidDate(date) ? date : value;
};

export default {
  mixins: [MstValidateMixins, MstExamItemMixins],
  data() {
    return {
      keys: 0,
      gridData: null,
      gridColumns: [],
      allGridData: [],
      gridSchemaModel: {},
      nextId: 0,
      isSortMode: false,
      isAllowSort: false,
      isAllowAddRecord: false,
      isAddButton: false,
      masterCsvVisible: false,
      masterCsvTarget: null,
      originalDataSource: null,
      isNotChanged: true,
      requiredFields: [],
      fieldsMap: new Map(),
      signoutFlg: false, // used for 職種マスタ
      zoomObserver: null,
      androidFlg: false,
      iosFlg: false,
      allowEdit: true, // NOTE: true = 編集モード、 false = 閲覧モード
      scrollPosition: {
        top: 0,
        left: 0
      },
      scrollRestored: true,
      updatedFlg: false,
      saveFlg: false,
      gridTouchHandlerCleanup: null,
      gridTouchRafId: null,
      directGridWidget: null,
      directGridInitRafId: null,
      directGridLayoutRafId: null,
      lockedRowSyncRafId: null,
      directGridColumnSignature: "",
      validationTooltipPlacementTimers: [],
      validationTooltipPlacementRafId: null,
      validationTooltipPlacementIntervalId: null,
      validationTooltipObserver: null,
      kendoValidator: null,
      /** 手入力で変更した sortRank の code 一覧（反映後の採番差分と区別、MasterRecordComponent と同様） */
      masterRecordSortEditedCodes: null,
      __pendingScrollToAddedRow: false,
    };
  },
  components: {
    "master-csv": MasterCsvComponent,
  },
  computed: {
    ...mapState("master-maintenance", {
      facilityCd: "facilitySwitch",
      masterPhysicalName: "selectedMasterName",
      editedRowItem: "editRecord",
      virtualCondition: "virtualCondition",
      mstFavoriteFacilityAddRows: "mstFavoriteFacilityAddRows",
    }),
    ...mapState("account-edit", ["fontSize", "showSidebarFlg"]),
    ...mapState("window-size", ["windowWidth", "windowHeight"]),
    isChanged() {
      return !this.isNotChanged;
    },
    isMobileDevice() {
      return this.iosFlg || this.androidFlg;
    },
    lockedWidthStyle() {
      const lockedCols = (this.gridColumns || []).filter(
        (column) => column?.locked === true && column?.hidden !== true
      );
      if (lockedCols.length === 0) {
        return null;
      }
      const totalPx = lockedCols.reduce((sum, column) => {
        const width = parseFloat(String(column.width || "0"));
        return sum + (Number.isFinite(width) ? width : 0);
      }, 0);
      return totalPx > 0 ? `${Math.round(totalPx)}px` : null;
    },
    gridContentStyles() {
      const lockedWidth = this.lockedWidthStyle;
      return lockedWidth ? { "--locked-width": lockedWidth } : {};
    },
  },
  methods: {
    ...mapActions("loading-screen", [
      "setLoadingScreenVisible",
      "setLoadingScreenMessage",
    ]),
    ...mapActions("multi-modal", [
      "showMasterEdit",
      "showJobMasterEditAuthority",
      "showMstExamItemRecManagementModal",
      "showMstFavoriteFacilityModal",
      "showMstJobEditDefaultSettingModal",
      "showMstJobEditNotificationSettingModal"
    ]),
    ...mapActions("mst-job", ["setIsEditAuthority", "setIsMenuSettings", "setIsDefaultDispSettings", "setIsDefaultNotificationSettings"]),
    ...mapActions("master-maintenance", ["findColumnInfo", "setEditRecord"]),
    ...mapMutations("master-maintenance", [
      "setColumns",
      "setVirtualCondition",
      "resetVirtualCondition",
      "setGridData",
      "setSchemaModel",
      "setMstFavoriteFacilityAddRows",
    ]),
    validateDirectGridContract() {
      // Vue2 では validator directive が wrapper 経由で接続されていた。
      // direct jq では同名 validator が存在する時だけ同じ分岐位置で実行し、
      // それ以外は Kendo Grid 自身のセル保存 validation と MstValidateMixins に委譲する。
      const validator = this.kendoValidator || this.$refs?.kendoValidator;
      if (validator && typeof validator.validate === "function") {
        return validator.validate();
      }
      return true;
    },
    getGridRootElement() {
      const root = this.$refs.grid;
      return root?.$el || root || null;
    },
    getGridSearchRoot() {
      const widget = this.getGridWidget();
      return (
        widget?.wrapper?.[0]
        || widget?.element?.[0]
        || this.getGridRootElement()
      );
    },
    scheduleDirectGridInit() {
      const ownerWindow = this.getGridRootElement()?.ownerDocument?.defaultView || window;
      if (this.directGridInitRafId) {
        ownerWindow.cancelAnimationFrame?.(this.directGridInitRafId);
      }
      this.directGridInitRafId = ownerWindow.requestAnimationFrame?.(() => {
        this.directGridInitRafId = null;
        this.initDirectGridIfReady();
      }) || null;
      if (!this.directGridInitRafId) {
        this.$nextTick(() => this.initDirectGridIfReady());
      }
    },
    initDirectGridIfReady() {
      const root = this.getGridRootElement();
      if (!root || !this.gridData || !this.gridColumns?.length) {
        return false;
      }
      if (this.directGridWidget) {
        this.applyDirectGridDataSourceContract();
        this.applyDirectGridColumnsContract();
        this.installValidationTooltipPlacementObserver();
        this.scheduleDirectGridLayoutContract();
        return true;
      }
      this.destroyDirectGrid();
      $(root).kendoGrid({
        dataSource: this.gridData,
        height: "100%",
        editable: {
          createAt: "bottom",
        },
        columns: this.buildDirectGridColumns(),
        selectable: true,
        scrollable: {
          virtual: true,
        },
        filterable: false,
        save: (event) => this.onSave(event),
        dataBound: (event) => this.onDirectGridDataBound(event),
        edit: (event) => this.onEdit(event),
        beforeEdit: (event) => this.onBeforeEdit(event),
        cellClose: (event) => this.onCellClose(event),
      });
      this.directGridWidget = $(root).data("kendoGrid") || null;
      this.directGridColumnSignature = this.getDirectGridColumnSignature();
      this.installDirectGridFacade();
      this.installDirectGridValidator();
      this.applyDirectGridStyleContract();
      this.installValidationTooltipPlacementObserver();
      this.scheduleDirectGridLayoutContract();
      return !!this.directGridWidget;
    },
    installDirectGridValidator() {
      const container = this.$el;
      if (!container) {
        return;
      }
      destroyJQueryValidator(container);
      this.kendoValidator = createJQueryValidator(container, {
        rules: {},
        messages: {},
      });
    },
    destroyDirectGrid() {
      this.teardownValidationTooltipPlacement();
      destroyJQueryValidator(this.$el);
      this.kendoValidator = null;
      this.cancelPendingLockedRowSync();
      const root = this.getGridRootElement();
      if (this.directGridWidget) {
        try {
          this.directGridWidget.destroy();
        } catch (_error) {
          // noop
        }
      }
      if (root) {
        try {
          $(root).empty();
        } catch (_error) {
          // noop
        }
      }
      this.directGridWidget = null;
      this.directGridColumnSignature = "";
    },
    buildDirectGridColumns() {
      return (this.gridColumns || []).map((column) => {
        const directColumn = { ...column };
        if (directColumn.command && !Array.isArray(directColumn.command)) {
          directColumn.command = [directColumn.command];
        }
        return directColumn;
      });
    },
    installDirectGridFacade() {
      const root = this.getGridRootElement();
      if (!root) {
        return;
      }
      root.kendoWidget = () => this.directGridWidget;
      root.gridWidget = () => this.directGridWidget;
      root.gridVirtualScrollable = () => this.directGridWidget?.virtualScrollable || null;
      root.gridVerticalScrollbarEl = () => this.directGridWidget?.virtualScrollable?.verticalScrollbar?.[0] || null;
      root.gridContentEl = () => root.querySelector?.(".k-grid-content") || null;
      root.gridAutoScrollableEl = () => root.querySelector?.(".k-grid-content") || null;
      root.gridWrapper = () => this.directGridWidget?.wrapper || $(root);
      root.gridElement = () => this.directGridWidget?.element || $(root);
      root.gridTbodyEl = () => this.directGridWidget?.tbody?.[0] || root.querySelector?.(".k-grid-content tbody") || null;
      root.gridLockedTbodyEl = () => root.querySelector?.(".k-grid-content-locked tbody") || null;
      root.refreshGrid = () => this.refreshVirtualGrid();
      root.resizeGridColumn = (column, width) => this.getGridWidget()?.resizeColumn?.(column, width);
    },
    applyDirectGridDataSourceContract() {
      const grid = this.getGridWidget();
      if (!grid || !this.gridData || grid.dataSource === this.gridData) {
        return;
      }
      grid.setDataSource(this.gridData);
      this.installDirectGridFacade();
    },
    getDirectGridColumnSignature() {
      return (this.gridColumns || [])
        .map(column => [
          column.field || "",
          column.title || "",
          column.width || "",
          column.hidden === true ? 1 : 0,
          column.locked === true ? 1 : 0,
          column.neverEditable === true ? 1 : 0,
          column.isEditable === true ? 1 : 0,
          column.dataType || "",
          column.command?.text || "",
          column.command?.className || ""
        ].join(":"))
        .join("|");
    },
    applyDirectGridColumnsContract() {
      const grid = this.getGridWidget();
      if (!grid || !this.gridColumns?.length) {
        return;
      }
      const nextSignature = this.getDirectGridColumnSignature();
      if (this.directGridColumnSignature !== nextSignature) {
        grid.setOptions({
          columns: this.buildDirectGridColumns(),
        });
        this.directGridColumnSignature = nextSignature;
      }
      this.installDirectGridFacade();
    },
    onDirectGridDataBound(event) {
      this.installDirectGridFacade();
      this.applyDirectGridStyleContract();
      this.installValidationTooltipPlacementObserver();
      this.scheduleDirectGridLayoutContract();
      this.scheduleValidationTooltipPlacement();
      this.onDataBound(event);
    },
    scheduleDirectGridLayoutContract() {
      const root = this.getGridRootElement();
      const ownerWindow = root?.ownerDocument?.defaultView || window;
      if (this.directGridLayoutRafId) {
        ownerWindow.cancelAnimationFrame?.(this.directGridLayoutRafId);
      }
      this.directGridLayoutRafId = ownerWindow.requestAnimationFrame?.(() => {
        this.applyDirectGridLayoutContract();
        this.directGridLayoutRafId = ownerWindow.requestAnimationFrame?.(() => {
          this.directGridLayoutRafId = null;
          this.applyDirectGridLayoutContract();
        }) || null;
      }) || null;
      if (!this.directGridLayoutRafId) {
        this.$nextTick(() => this.applyDirectGridLayoutContract());
      }
    },
    applyDirectGridLayoutContract() {
      this.applyDirectGridStyleContract();
      this.applyDirectGridLockedWidthContract();
      // 注意:
      //  Kendo 2026 内部の _syncLockedContentHeight / _syncLockedScroll が
      //  locked container の height と scrollTop を担当する。手動で上書きすると
      //  Kendo 内部の sync と取り合って scrollbar が震える / 行がずれるため、
      //  applyDirectGridLockedHeightContract / syncDirectGridLockedScrollContract
      //  は呼ばない。
      //
      //  さらに virtualScrollable.refresh() / repaintScrollbar() も呼ばない。
      //  これらは scrollbar の placeholder を再構築し、page === 1 のとき
      //  verticalScrollbar.scrollTop を 0 に巻き戻すため、dataBound のたびに
      //  実行すると wheel / ドラッグ操作で grid 全体が 1〜2 行分縦に飛ぶ。
      //  Kendo 自身が dataSource.change → refresh 経路で既に呼んでいるので
      //  ここで二重に呼ぶ必要は無い。windowResize / fontSize 変更等の
      //  layout が本当に変わるケースは refreshVirtualGrid 側で対処する。
      this.scheduleLockedRowSync();
    },
    scheduleLockedRowSync() {
      const root = this.getGridRootElement();
      const ownerWindow = root?.ownerDocument?.defaultView || window;
      if (this.lockedRowSyncRafId) {
        ownerWindow.cancelAnimationFrame?.(this.lockedRowSyncRafId);
      }
      this.lockedRowSyncRafId = ownerWindow.requestAnimationFrame?.(() => {
        this.lockedRowSyncRafId = null;
        const el = this.getGridRootElement();
        if (el) {
          syncKendoGridLockedRowHeights(el);
        }
      }) || null;
      if (!this.lockedRowSyncRafId) {
        this.$nextTick(() => {
          const el = this.getGridRootElement();
          if (el) {
            syncKendoGridLockedRowHeights(el);
          }
        });
      }
    },
    cancelPendingLockedRowSync() {
      const ownerWindow = this.getGridRootElement()?.ownerDocument?.defaultView || window;
      if (this.lockedRowSyncRafId) {
        ownerWindow.cancelAnimationFrame?.(this.lockedRowSyncRafId);
        this.lockedRowSyncRafId = null;
      }
    },
    applyDirectGridStyleContract() {
      const root = this.getGridRootElement();
      if (!root) {
        return;
      }
      root.classList.add(
        "ntss-kendo-grid-legacy",
        "master-direct-jq-grid",
        "master-record-virtual-scrollable-direct-jq-grid",
        "k-widget",
        "k-grid",
        "k-editable",
        "k-display-block"
      );
      root.querySelectorAll?.(".k-grid-header th, .k-grid-header .k-table-th")?.forEach?.((cell) => {
        cell.classList.add("k-header");
      });
      root.querySelectorAll?.(".k-grid-content tr, .k-grid-content-locked tr")?.forEach?.((row) => {
        row.classList.add("k-master-row");
      });
      root.querySelectorAll?.(".k-grid-content tr:nth-child(even), .k-grid-content-locked tr:nth-child(even)")?.forEach?.((row) => {
        row.classList.add("k-alt");
      });
      root.querySelectorAll?.(".k-grid-content td, .k-grid-content-locked td")?.forEach?.((cell) => {
        cell.classList.add("k-td", "k-table-td");
      });
    },
    applyDirectGridLockedWidthContract() {
      const root = this.getGridRootElement();
      const lockedWidth = Number.parseFloat(this.lockedWidthStyle || "");
      if (!root || !Number.isFinite(lockedWidth) || lockedWidth <= 0) {
        return;
      }
      root.querySelectorAll?.(".k-grid-header-locked, .k-grid-content-locked, .k-grid-header-locked table, .k-grid-content-locked table")?.forEach?.((element) => {
        const width = `${Math.round(lockedWidth)}px`;
        element.style.width = width;
        element.style.minWidth = width;
      });
    },
    applyDirectGridLockedHeightContract() {
      const root = this.getGridRootElement();
      const content = root?.querySelector?.(".k-grid-content");
      if (!content) {
        return;
      }
      const contentHeight = content.clientHeight;
      if (!Number.isFinite(contentHeight) || contentHeight <= 0) {
        return;
      }
      root.querySelectorAll?.(".k-grid-content-locked")?.forEach?.((lockedContent) => {
        lockedContent.style.height = `${contentHeight}px`;
      });
    },
    syncDirectGridLockedScrollContract() {
      const root = this.getGridRootElement();
      const content = root?.querySelector?.(".k-grid-content");
      if (!content) {
        return;
      }
      root.querySelectorAll?.(".k-grid-content-locked")?.forEach?.((lockedContent) => {
        lockedContent.scrollTop = content.scrollTop;
      });
      try {
        $(content).trigger("scroll");
      } catch (_error) {
        // noop
      }
    },
    getGridWidget() {
      return this.directGridWidget || this.$refs.grid?.gridWidget?.() || this.$refs.grid?.kendoWidget?.() || null;
    },
    getGridVirtualScrollable() {
      return this.$refs.grid?.gridVirtualScrollable?.() || this.getGridWidget()?.virtualScrollable || null;
    },
    getGridVerticalScrollbarEl() {
      return this.$refs.grid?.gridVerticalScrollbarEl?.() || this.getGridVirtualScrollable()?.verticalScrollbar?.[0] || null;
    },
    getGridHorizontalScrollerEl() {
      return this.$refs.grid?.gridAutoScrollableEl?.() || this.$refs.grid?.gridContentEl?.() || null;
    },
    getGridScrollPosition() {
      const hScroller = this.getGridHorizontalScrollerEl();
      const vScroller = this.getGridVerticalScrollbarEl();
      return {
        top: vScroller?.scrollTop ?? hScroller?.lastChild?.scrollTop ?? hScroller?.scrollTop ?? 0,
        left: hScroller?.firstChild?.scrollLeft ?? hScroller?.scrollLeft ?? 0,
      };
    },
    getGridHorizontalScrollTargets() {
      const grid = this.getGridWidget();
      const root = this.getGridRootElement();
      const content = grid?.content?.[0] || root?.querySelector?.(".k-grid-content") || this.getGridHorizontalScrollerEl();
      const headerWrap = root?.querySelector?.(".k-grid-header-wrap");
      const targets = [content, headerWrap];
      if (content?.firstElementChild) {
        targets.push(content.firstElementChild);
      }
      const hScroller = this.getGridHorizontalScrollerEl();
      if (hScroller && hScroller !== content) {
        targets.push(hScroller);
        if (hScroller.firstElementChild) {
          targets.push(hScroller.firstElementChild);
        }
      }
      return [...new Set(targets.filter(Boolean))];
    },
    applyGridHorizontalScrollLeft(left = 0) {
      const grid = this.getGridWidget();
      if (!grid) {
        return;
      }
      this.scrollPosition.left = left;
      if (typeof grid._scrollLeft !== "undefined") {
        grid._scrollLeft = left;
      }
      if (grid.scrollables?.each) {
        grid.scrollables.each((_i, el) => {
          if (el && typeof el.scrollLeft === "number") {
            el.scrollLeft = left;
          }
        });
      }
      this.getGridHorizontalScrollTargets().forEach((el) => {
        el.scrollLeft = left;
        try {
          $(el).scrollLeft(left).trigger("scroll");
        } catch (_error) {
          try {
            el.dispatchEvent(new Event("scroll", { bubbles: true }));
          } catch (_innerError) {
            // noop
          }
        }
      });
    },
    setGridScrollPosition(position = {}) {
      const hScroller = this.getGridHorizontalScrollerEl();
      const vScroller = this.getGridVerticalScrollbarEl();
      if (Number.isFinite(position?.left)) {
        this.applyGridHorizontalScrollLeft(position.left);
      }
      if (Number.isFinite(position?.top)) {
        if (hScroller?.lastChild) hScroller.lastChild.scrollTop = position.top;
        if (hScroller) hScroller.scrollTop = position.top;
        if (vScroller) vScroller.scrollTop = position.top;
      }
      if (hScroller && Number.isFinite(position?.top)) {
        try {
          hScroller.dispatchEvent(new Event("scroll", { bubbles: true }));
        } catch (_error) {
          try {
            $(hScroller).trigger("scroll");
          } catch (_innerError) {
            // noop
          }
        }
      }
    },
    scrollVirtualGridTo(top = 0) {
      const virtualScrollable = this.getGridVirtualScrollable();
      if (virtualScrollable?._scrollTo) {
        virtualScrollable._scrollTo(top);
      }
      const vScroller = this.getGridVerticalScrollbarEl();
      if (vScroller) {
        vScroller.scrollTop = top;
      }
    },
    scrollGridToAddedRow() {
      const grid = this.getGridWidget();
      if (!grid) {
        return;
      }
      const virtualScrollable = this.getGridVirtualScrollable();
      const content = grid.content?.[0] || this.getGridHorizontalScrollerEl();
      const vScroller = this.getGridVerticalScrollbarEl();
      const left = 0;

      if (virtualScrollable?.scrollToBottom) {
        virtualScrollable.scrollToBottom();
      }

      let top = Number(virtualScrollable?._scrollTop);
      if (!Number.isFinite(top) || top < 0) {
        top = 0;
      }
      const total = getKendoDataSourceTotal(this.gridData);
      const itemHeight = virtualScrollable?.itemHeight;
      const contentHeight = content?.clientHeight || 0;
      if (Number.isFinite(itemHeight) && itemHeight > 0 && total > 0) {
        top = Math.max(top, total * itemHeight - contentHeight);
      }
      if (vScroller) {
        top = Math.max(top, vScroller.scrollHeight - vScroller.clientHeight);
      }
      if (content) {
        top = Math.max(top, content.scrollHeight - content.clientHeight);
      }
      top = Math.max(0, top);

      this.scrollPosition.top = top;
      this.scrollPosition.left = left;

      // 仮想スクロールは scrollbar の scrollTop だけでは表示行が更新されない。
      // _scrollTo と verticalScrollbar の scroll イベント発火が必要。
      if (virtualScrollable) {
        virtualScrollable._preventScroll = false;
        if (virtualScrollable._scrollTo) {
          virtualScrollable._scrollTo(top);
        }
        const wrapper = virtualScrollable.wrapper?.[0];
        if (wrapper) {
          wrapper.scrollTop = top;
        }
        if (vScroller) {
          try {
            $(vScroller).scrollTop(top).trigger("scroll");
          } catch (_error) {
            vScroller.scrollTop = top;
            try {
              vScroller.dispatchEvent(new Event("scroll", { bubbles: true }));
            } catch (_innerError) {
              // noop
            }
          }
        }
      }
      if (content) {
        content.scrollTop = top;
      }
      if (grid.lockedContent?.[0]) {
        grid.lockedContent[0].scrollTop = top;
      }
      this.syncDirectGridLockedScrollContract();
      // 縦スクロール処理後に横スクロールを最左へ（scrollToBottom 後に上書きされるのを防ぐ）
      this.applyGridHorizontalScrollLeft(left);
    },
    scheduleGridScrollToAddedRow() {
      const apply = () => this.scrollGridToAddedRow();
      apply();
      this.$nextTick(() => {
        apply();
        const ownerWindow = this.getGridRootElement()?.ownerDocument?.defaultView || window;
        ownerWindow.requestAnimationFrame?.(apply);
        [32, 80, 180, 320].forEach((ms) => setTimeout(apply, ms));
      });
    },
    refreshVirtualGrid() {
      this.getGridWidget()?.refresh?.();
      this.getGridVirtualScrollable()?.refresh?.();
      this.getGridVirtualScrollable()?.repaintScrollbar?.();
      this.scheduleDirectGridLayoutContract();
    },
    resizeVirtualGrid(height = 30, force = true) {
      this.getGridWidget()?._resize?.(height, force);
      this.getGridWidget()?.resize?.(force);
      this.getGridVirtualScrollable()?.repaintScrollbar?.();
      this.scheduleDirectGridLayoutContract();
    },
    closeGridCell() {
      this.getGridWidget()?.closeCell?.();
    },
    findActiveGridEditCell(root) {
      const grid = this.getGridWidget();
      const lockedCell = grid?.lockedTable?.find?.(".k-edit-cell")?.[0];
      if (lockedCell) {
        return lockedCell;
      }
      const mainCell = grid?.table?.find?.(".k-edit-cell")?.[0];
      if (mainCell) {
        return mainCell;
      }
      const searchRoot = root || this.getGridSearchRoot();
      return (
        searchRoot?.querySelector?.(".k-grid-content-locked .k-edit-cell")
        || searchRoot?.querySelector?.(".k-grid-content .k-edit-cell")
        || searchRoot?.querySelector?.(".k-edit-cell")
        || null
      );
    },
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
    resetValidationTooltipCalloutDirection(editCell) {
      editCell?.querySelectorAll?.(".k-callout")?.forEach?.((callout) => {
        callout.classList.remove("k-callout-s", "k-callout-e", "k-callout-w");
        callout.classList.add("k-callout-n");
      });
    },
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
    isLastDataSourceEditRow(editRow) {
      if (!editRow || !this.gridData) {
        return false;
      }
      const grid = this.getGridWidget();
      const dataItem = grid?.dataItem?.(editRow);
      const items = getKendoDataSourceItems(this.gridData);
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
    applyValidationTooltipPlacement() {
      const root = this.getGridSearchRoot();
      if (!root) {
        return;
      }
      const editCell = this.findActiveGridEditCell(root);
      const content = this.findGridScrollContentForEditCell(root, editCell);
      if (!content || !editCell) {
        return;
      }
      const tooltip = this.findVisibleValidationTooltip(editCell);
      if (!tooltip) {
        return;
      }
      root.querySelectorAll(".ntss-validation-above").forEach((element) => {
        if (element !== editCell) {
          element.classList.remove("ntss-validation-above");
          this.resetValidationTooltipCalloutDirection(element);
        }
      });
      const anchor =
        editCell.querySelector(".k-input.k-textbox, .k-picker, .k-input")
        || editCell.querySelector(
          "input, textarea, select, .k-input-inner, .k-textbox"
        )
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
    stopValidationTooltipPlacementWatch() {
      const ownerWindow = this.getGridSearchRoot()?.ownerDocument?.defaultView || window;
      if (this.validationTooltipPlacementIntervalId) {
        ownerWindow.clearInterval?.(this.validationTooltipPlacementIntervalId);
        this.validationTooltipPlacementIntervalId = null;
      }
    },
    startValidationTooltipPlacementWatch() {
      this.stopValidationTooltipPlacementWatch();
      const ownerWindow = this.getGridSearchRoot()?.ownerDocument?.defaultView || window;
      let attempts = 0;
      const tick = () => {
        attempts += 1;
        this.applyValidationTooltipPlacement();
        const root = this.getGridSearchRoot();
        const editCell = this.findActiveGridEditCell(root);
        const tooltip = this.findVisibleValidationTooltip(editCell);
        if (!tooltip || attempts >= 5) {
          this.stopValidationTooltipPlacementWatch();
        }
      };
      tick();
      this.validationTooltipPlacementIntervalId = ownerWindow.setInterval?.(tick, 100);
    },
    clearValidationTooltipPlacementTimers() {
      const ownerWindow = this.getGridRootElement()?.ownerDocument?.defaultView || window;
      this.validationTooltipPlacementTimers.forEach((timerId) => {
        ownerWindow.clearTimeout?.(timerId);
      });
      this.validationTooltipPlacementTimers = [];
      if (this.validationTooltipPlacementRafId) {
        ownerWindow.cancelAnimationFrame?.(this.validationTooltipPlacementRafId);
        this.validationTooltipPlacementRafId = null;
      }
    },
    scheduleValidationTooltipPlacement() {
      this.clearValidationTooltipPlacementTimers();
      const ownerWindow = this.getGridSearchRoot()?.ownerDocument?.defaultView || window;
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
    installValidationTooltipPlacementObserver() {
      this.teardownValidationTooltipPlacementObserver();
      const root = this.getGridSearchRoot();
      const scrollAreas = [
        root?.querySelector?.(".k-grid-content"),
        root?.querySelector?.(".k-grid-content-locked"),
        root,
      ].filter(Boolean);
      if (!scrollAreas.length || typeof MutationObserver === "undefined") {
        return;
      }
      const ownerWindow = scrollAreas[0].ownerDocument?.defaultView || window;
      const onMutation = () => {
        if (this.validationTooltipPlacementRafId) {
          ownerWindow.cancelAnimationFrame?.(this.validationTooltipPlacementRafId);
        }
        this.validationTooltipPlacementRafId = ownerWindow.requestAnimationFrame?.(() => {
          this.validationTooltipPlacementRafId = null;
          this.applyValidationTooltipPlacement();
        }) || null;
      };
      this.validationTooltipObserver = new MutationObserver(onMutation);
      scrollAreas.forEach((scrollArea) => {
        this.validationTooltipObserver.observe(scrollArea, {
          childList: true,
          subtree: true,
        });
      });
    },
    teardownValidationTooltipPlacementObserver() {
      this.validationTooltipObserver?.disconnect?.();
      this.validationTooltipObserver = null;
    },
    teardownValidationTooltipPlacement() {
      this.clearValidationTooltipPlacementTimers();
      this.stopValidationTooltipPlacementWatch();
      this.teardownValidationTooltipPlacementObserver();
      this.getGridSearchRoot()?.querySelectorAll?.(".ntss-validation-above")?.forEach?.((element) => {
        element.classList.remove("ntss-validation-above");
        this.resetValidationTooltipCalloutDirection(element);
      });
    },
    getCsvData(dataArr) {
      if (!Array.isArray(dataArr) || dataArr.length === 0 || !this.gridData) {
        return;
      }
      // フィルタ条件をクリア
      if (this.virtualCondition.value) {
        this.resetVirtualCondition();
      }
      this.gridData.filter({});
      this.gridData.page(1);

      const gridItems = getKendoDataSourceItems(this.gridData);
      const nonDeletedData = gridItems.filter((item) => {
        return (
          item.isDisp == "1" &&
          (Object.prototype.hasOwnProperty.call(item, "isDel") ? item.isDel == "0" : true));
      });
      let codeTemp = -1;
      let sortTemp = 0;
      if (gridItems.length > 0) {
        let { code } = _.maxBy(gridItems, "code");
        codeTemp = code;
      }
      if (nonDeletedData.length > 0) {
        let { sortRank } = _.maxBy(nonDeletedData, "sortRank");
        sortTemp = sortRank;
      }
      let dataMap = new Map();
      let schemaKeys = Object.keys(this.gridSchemaModel);

      dataArr = dataArr.map((item) => {
        if (item.code) {
          dataMap.set(item.code, item);
        }
        schemaKeys.forEach((key) => {
          if (!Object.prototype.hasOwnProperty.call(item, key)) {
            let defaultValue =
              this.gridSchemaModel[key].type === "number" ? 0 : "";
            item[key] =
              Number(this.gridSchemaModel[key]?.defaultValue) || defaultValue;
          } else if (this.gridSchemaModel[key].type === "number" && item[key]) {
            item[key] = Number(item[key]) || item[key];
          }
        });
        return {
          ...item,
          code: item.code || ++codeTemp,
          sortRank: ++sortTemp,
          isImport: true,
          dirty: true,
          isDisp: "1",
          // isDel: "0",
        };
      });
      const repeatDataSet = new Set();
      dataMap.size &&
        gridItems.forEach((item) => {
          if (item.isDisp == "1" && dataMap.has(item.code)) {
            item.init(dataMap.get(item.code));
            repeatDataSet.add(codeTemp);
          }
        });
      let addedNewRows = false;
      dataArr.forEach((item) => {
        if (repeatDataSet.size && repeatDataSet.has(item.code)) {
          return;
        }
        addedNewRows = true;
        const row = addKendoDataSourceItem(this.gridData, item);
        if (row?.set) {
          row.set("dirty", true);
        } else if (row) {
          row.dirty = true;
        }
      });
      if (addedNewRows) {
        // 追加行: 横スクロール先頭・縦スクロール最下部（onAdd / onDataBound と同様）
        // change 発火前に設定しないと dataBound が先に走りスクロールが効かない。
        this.scrollPosition.left = 0;
        this.scrollRestored = true;
        this.__pendingScrollToAddedRow = true;
      }
      triggerKendoDataSourceEvent(this.gridData, "change");
      this.$nextTick(() => {
        this.applyDirectGridDataSourceContract();
        this.handleFilterByCondition(this.virtualCondition);
        if (addedNewRows) {
          // virtualScrollable.refresh() は scrollTop を 0 に戻し、
          // 表示行とスクロールバー位置がずれるため追加時は呼ばない。
          this.getGridWidget()?.refresh?.();
          this.scheduleDirectGridLayoutContract();
          if (!this.__pendingScrollToAddedRow) {
            this.scheduleGridScrollToAddedRow();
          }
        } else {
          this.refreshVirtualGrid();
          this.getGridVirtualScrollable()?.refresh?.();
          this.scheduleDirectGridLayoutContract();
        }
      });
    },
    importCsv(event) {
      // グリッドでエラーが発生している場合は処理を中断
      if (!this.validateDirectGridContract()) {
        return;
      }
      this.masterCsvTarget = event.target;
      this.masterCsvVisible = true;
    },
    onAdd() {
      this.setVirtualCondition({
        value: "",
        fields: this.virtualCondition.fields,
        includeDeleted: false,
      });
      if (this.masterPhysicalName === "mst_favorite_facility") {
        this.setEditRecord({});
        this.setMstFavoriteFacilityAddRows([]);
        this.setGridData(_.cloneDeep(getKendoDataSourcePlainItems(this.gridData)));
        this.showMstFavoriteFacilityModal();
        return;
      }
      // 追加行: 横スクロール先頭・縦スクロール最下部（MasterRecordComponent.addRow / dataBound と同様）
      this.scrollPosition.left = 0;
      this.scrollRestored = true;
      this.__pendingScrollToAddedRow = true;
      this.$nextTick(() => {
        const grid = this.getGridWidget();
        const totalBefore = getKendoDataSourceTotal(this.gridData);
        const gridItems = getKendoDataSourceItems(this.gridData);
        if (gridItems.length > 0) {
          const maxCode = _.maxBy(gridItems, "code")?.code ?? 0;
          grid.addRow();
          const newItem = getKendoDataSourceItemAt(this.gridData, getKendoDataSourceTotal(this.gridData) - 1);
          newItem.set("code", maxCode + 1);
        } else {
          grid.addRow();
        }
        this.scheduleValidationTooltipPlacement();
      });
    },
    onCellClose() {
      const savedScroll = {
        top: this.scrollPosition.top,
        left: this.scrollPosition.left,
      };
      this.getGridRootElement()?.querySelectorAll?.(".ntss-validation-above")?.forEach?.((element) => {
        element.classList.remove("ntss-validation-above");
        this.resetValidationTooltipCalloutDirection(element);
      });
      this.$nextTick(() => {
        this.resizeVirtualGrid(30, true);
        this.scheduleDirectGridLayoutContract();
        this.$nextTick(() => {
          this.setGridScrollPosition(savedScroll);
        });
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
      const { top, left } = this.getGridScrollPosition();
      this.scrollPosition.top = top;
      this.scrollPosition.left = left;
      this.$nextTick(() => {
        this.getGridVirtualScrollable()?.repaintScrollbar?.();
      });
    },
    onEdit(e) {
      clearKendoEditorControlTitles(e.container);
      bindGridEditorEnterToCloseCell(e?.sender || this.getGridWidget(), e?.container);
      const cell = e?.container?.[0] || e?.container;
      const field = getGridEditFieldFromEvent(e, this.gridColumns);
      if (this.isSortMode && field === "sortRank" && cell) {
        const model = e.model;
        bindGridEditorNumericWheelSpinAssist({
          cell,
          gridRoot: this.getGridRootElement(),
          onEditorValueChange: () => {
            const value = readGridEditorNumericValue(cell);
            if (model?.set) {
              model.set("sortRank", value);
              model.set("sortInputTime", Date.now());
            } else if (model) {
              model.sortRank = value;
              model.sortInputTime = Date.now();
            }
          },
        });
      }
      this.$nextTick(() => {
        this.getGridVirtualScrollable()?.repaintScrollbar?.();
        this.scheduleValidationTooltipPlacement();
      });
    },
    onSave(e) {
      const { uid } = e.model;
      const editField = Object.keys(e.values)[0];
      const editedValue = e.values[editField];
      if (e.model[editField] == editedValue) {
        return;
      }
      const originalItem = this.originalDataSource.find((item) => {
        return item.uid === uid;
      });
      const isEqual = _.isEqualWith(
        originalItem?.[editField],
        editedValue,
        customComparator
      );
      if (this.masterPhysicalName === "mst_mainte_detail") {
        // 日常・定期点検項目マスタ
        if (e.values.isCmt) {
          // 補足コメント有無
          e.model.set("iniText", null); // 初期展開テキスト
        }
        if (e.values.mainteClass) {
          // 用途
          e.model.set("mainteContent3", null); // 内容3
          if (e.values.mainteClass === "1") {
            // 用途: 日常点検
            e.model.set("ansPattern", "0"); // 回答パターン: 日常点検
          } else if (e.values.mainteClass === "2") {
            // 用途: 定期点検
            e.model.set("ansPattern", "1"); // 回答パターン: 定期点検
          }
        }
      }
      // 新追加行
      if (e.model.isNew()) {
        if (e.model.sortRank) {
          return;
        }
        // e.model.sortRank === 0
        this.judgeNewRowRequiredFields(e.model);
        this.handleChangeEditedBackgroundColor(e, uid, "new", "addBg");
        return;
      }
      if (this.isSortMode && editField === "sortRank" && !isEqual) {
        e.model.sortInputTime = Date.now();
        this.markMasterRecordSortRankEdited(e.model, true);
      }
      if (isEqual) {
        delete e.model.dirtyFields[editField];
        if (editField === "sortRank") {
          this.markMasterRecordSortRankEdited(e.model, false);
        }
        this.$nextTick(() => {
          getKendoEventContainerElement(e)?.classList?.remove("k-dirty-cell");
        });
        if (Object.keys(e.model.dirtyFields).length === 0) {
          e.model.set("dirty", false);
          delete e.model.dirtyFields.dirty;
          this.handleChangeEditedBackgroundColor(e, uid, "edited", "removeBg");
        } else if (this.isMasterRecordSortRankOnlyDirty(e.model)) {
          this.$nextTick(() => {
            const grid = e.sender || this.getGridWidget();
            this.clearEditedBackgroundForUid(grid, uid);
            this.refreshMasterRecordSortRankVisualForUid(grid, uid);
          });
        }
        // this.$nextTick(() => {
        //   this.gridData.updated();
        // });
        return;
      }
      if (this.isMasterRecordSortRankOnlyDirty(e.model)) {
        this.isNotChanged = !hasKendoDataSourceChanges(this.gridData);
        this.$nextTick(() => {
          const grid = e.sender || this.getGridWidget();
          this.clearEditedBackgroundForUid(grid, uid);
          this.refreshMasterRecordSortRankVisualForUid(grid, uid);
        });
        return;
      }
      this.handleChangeEditedBackgroundColor(e, uid, "edited", "addBg");
    },
    judgeNewRowRequiredFields(newRowItem) {
      const dataTemp = _.cloneDeep(getKendoDataSourcePlainItems(this.gridData));
      const nonDeletedData = dataTemp.filter((item) => {
        return (
          item.isDisp == "1" &&
          (Object.prototype.hasOwnProperty.call(item, "isDel") ? item.isDel == "0" : true) &&
          item.code !== newRowItem.code);
      });
      let sortTemp = 0;
      if (nonDeletedData.length > 0) {
        let { sortRank } = _.maxBy(nonDeletedData, "sortRank");
        sortTemp = sortRank;
      }
      this.$nextTick(() => {
        let allRequiredFieldsEdited = this.requiredFields.every(
          (item) => !isEmpty(newRowItem[item])
        );
        if (allRequiredFieldsEdited) {
          newRowItem.set("sortRank", ++sortTemp);
        }
      });
    },
    async onSaveChanges() {
      let grid = this.getGridWidget();
      if (!this.validateDirectGridContract()) {
        return;
      }
      // saveFlg / scrollRestored / scrollPosition の設定は handleValidate の
      // バリデーション通過後 (= callback 実行時) まで遅延する。
      //
      // 以前ここで先に saveFlg = true / scrollRestored = false を設定していたが、
      // 検査項目マスタ等のバリデーションエラー時に handleValidate (MstValidateMixins)
      // が alert を表示して return すると、これらのフラグが残留する。
      // その後 onDataBound が呼ばれるたびに setGridScrollPosition で scrollTop が
      // 保存ボタン押下時の位置へ巻き戻され、ユーザーがホイール / ドラッグで動かしても
      // 反映されず、スクロールバーが震える不具合が発生していた (#検証 NG)。
      this.handleValidate(async () => {
        // MstValidateMixins
        this.saveFlg = true;
        this.scrollRestored = false;
        //イベント発生前のスクロールバーの位置を保持
        const { top: scrollTop, left: scrollLeft } = this.getGridScrollPosition();
        this.scrollPosition.top = scrollTop;
        this.scrollPosition.left = scrollLeft;
        try {
          await this.handleUpdateRecordList();
          grid.saveChanges();
          this.isNotChanged = true;
          await this.getRecordDataList();
          this.$nextTick(() => {
            const ownerWindow = this.getGridRootElement()?.ownerDocument?.defaultView || window;
            ownerWindow.requestAnimationFrame?.(() => {
              this.setGridScrollPosition(this.scrollPosition);
            }) || this.setGridScrollPosition(this.scrollPosition);
          });
          // this.$nextTick(() => {
          //   this.originalDataSource = _.cloneDeep(getKendoDataSourceCollection(this.gridData));
          // });
        } finally {
          this.saveFlg = false;
          this.updatedFlg = false;
          this.scrollRestored = true;
        }
      });
    },
    async handleUpdateRecordList() {
      
      
      this.setLoadingScreenMessage("処理中・・・");
      this.setLoadingScreenVisible(true);

      let data = _.cloneDeep(getKendoDataSourceCollection(this.gridData));
      data.forEach(item => {
        if (item.dirty) {
          if (item.isImport || item.isNew()) {
            item.set("operation", 1);
            delete item.isImport;
          } else {
            item.set("operation", 2);
          }
        }
        // add #11559 禁忌・アレルギーマスタで詳細の登録が行われていないと患者経過総合ビューアで医材のマスタが表示されなくなる linjunfeng start
        if (this.masterPhysicalName === "mst_taboo_allergy" && (item.detailInfo === "" || item.detailInfo == null)) {
          item.detailInfo = "[]";
        }
        // add #11559 禁忌・アレルギーマスタで詳細の登録が行われていないと患者経過総合ビューアで医材のマスタが表示されなくなる linjunfeng end
        if (this.masterPhysicalName === "mst_favorite_facility") {
          const keys = [
            "code",
            "favoriteFacilityCd",
            "medicalInstitutionCd",
            "sortRank",
            "sortInputTime",
            "isDisp",
            "operation",
          ];
          Object.keys(item).forEach(key => {
            if (!keys.includes(key)) {
              delete item[key];
            }
          });
        }
      });
      data = toKendoDataSourcePlainItems(data);
      const tasks = [];
      if ([
        "mst_mainte_detail",
        "mst_mainte_category",
        "mst_mainte_layout",
        "mst_mainte_layout_group",
      ].includes(this.masterPhysicalName)) {
        tasks.push(deleteDataProcessing(
          this.facilityCd,
          this.masterPhysicalName,
          data));
      }
      tasks.push(new Promise((resolve, reject) => {
        sendRequestUpdateRecordListByFacilityCd(
          this.masterPhysicalName,
          this.facilityCd,
          data).then(response => {
          if (this.masterPhysicalName === "mst_exam_item") {
            this.masterSynchroOrder(); // MstExamItemMixins
          } else {
            this.$ons.notification.alert({
              title: DIALOG_MESSAGES[12000004].title,
              message: messageFormat(DIALOG_MESSAGES[12000004].message),
            });
          }
          resolve(response);
        }).catch(error => {
          getErrorMessage(
            "MasterRecordVirtualScrollableComponent.vue",
            "handleUpdateRecordList",
            error
          );
          if (error.response.status === 400) {
            this.$ons.notification.alert({
              title: DIALOG_MESSAGES["00300005"].title,
              message: error.response.data.errorMessage,
            });
          }
          reject(error);
        });
      }));
      await Promise.all(tasks).finally(() => {
        this.setLoadingScreenVisible(false);
      });
    },
    clearGridTouchScrollHandlers() {
      if (typeof this.gridTouchHandlerCleanup === "function") {
        this.gridTouchHandlerCleanup();
        this.gridTouchHandlerCleanup = null;
      }
      if (this.gridTouchRafId) {
        const ownerWindow = this.$el?.ownerDocument?.defaultView || window;
        ownerWindow.cancelAnimationFrame?.(this.gridTouchRafId);
        this.gridTouchRafId = null;
      }
    },
    bindGridTouchScrollHandlers(wrapper) {
      this.clearGridTouchScrollHandlers();
      if (!wrapper?.addEventListener) {
        return;
      }
      const ownerWindow = wrapper.ownerDocument?.defaultView || this.$el?.ownerDocument?.defaultView || window;
      let startY = 0;
      let scrollStart = 0;
      let isVerticalScroll = false;
      const onTouchStart = (e) => {
        if (e.touches.length === 1) {
          startY = e.touches[0].clientY;
          scrollStart = this.getGridVerticalScrollbarEl()?.scrollTop || this.getGridScrollPosition().top;
          isVerticalScroll = false;
        }
      };
      const onTouchMove = (e) => {
        if (e.touches.length !== 1) {
          return;
        }
        const currentY = e.touches[0].clientY;
        const deltaY = startY - currentY;
        if (!isVerticalScroll && Math.abs(deltaY) > 10) {
          isVerticalScroll = true;
        }
        if (isVerticalScroll) {
          const newScrollTop = scrollStart + deltaY;
          if (this.gridTouchRafId) {
            ownerWindow.cancelAnimationFrame?.(this.gridTouchRafId);
          }
          this.gridTouchRafId = ownerWindow.requestAnimationFrame?.(() => {
            this.gridTouchRafId = null;
            this.setGridScrollPosition({ top: newScrollTop });
          }) || null;
          e.preventDefault(); // iOSでスクロールを有効にするために必要
        }
      };
      wrapper.addEventListener('touchstart', onTouchStart, { passive: true });
      wrapper.addEventListener('touchmove', onTouchMove, { passive: false });
      this.gridTouchHandlerCleanup = () => {
        wrapper.removeEventListener('touchstart', onTouchStart, { passive: true });
        wrapper.removeEventListener('touchmove', onTouchMove, { passive: false });
      };
    },
    getMasterRecordRemainingDirtyFields(record) {
      if (!record?.dirtyFields) {
        return [];
      }
      return Object.keys(record.dirtyFields).filter((key) => {
        return key !== "dirty" && record.dirtyFields[key];
      });
    },
    isMasterRecordSortRankOnlyDirty(record) {
      const keys = this.getMasterRecordRemainingDirtyFields(record);
      if (!keys.includes("sortRank")) {
        return false;
      }
      const sortInternalFields = new Set(["sortRank", "sortInputTime"]);
      return keys.every((key) => sortInternalFields.has(key));
    },
    isMasterRecordSortRankOnlyEdited(record) {
      const keys = this.getMasterRecordRemainingDirtyFields(record);
      const sortInternalFields = new Set(["sortRank", "sortInputTime"]);
      if (keys.length > 0) {
        return keys.every((key) => sortInternalFields.has(key));
      }
      return this.isMasterRecordSortRankEdited(record);
    },
    resetMasterRecordSortEditedCodes() {
      this.masterRecordSortEditedCodes = new Set();
    },
    markMasterRecordSortRankEdited(record, edited = true) {
      if (record?.code == null || record?.code === "") {
        return;
      }
      if (!this.masterRecordSortEditedCodes) {
        this.resetMasterRecordSortEditedCodes();
      }
      const code = String(record.code);
      if (edited) {
        this.masterRecordSortEditedCodes.add(code);
      } else {
        this.masterRecordSortEditedCodes.delete(code);
      }
    },
    isMasterRecordSortRankEdited(record) {
      if (!record) {
        return false;
      }
      if (this.getMasterRecordRemainingDirtyFields(record).includes("sortRank")) {
        return true;
      }
      if (record.code == null || record.code === "") {
        return false;
      }
      return !!this.masterRecordSortEditedCodes?.has(String(record.code));
    },
    findMasterRecordSortVisualCells(rows) {
      return rows.flatMap((row) =>
        Array.from(row?.children || []).filter((cell) => {
          const field = cell.getAttribute?.("data-field");
          return field === "sortRank" || field === "dummy";
        })
      );
    },
    clearMasterRecordSortRankVisual(rows) {
      this.findMasterRecordSortVisualCells(rows).forEach((cell) => {
        cell.classList.remove("master-sort-edited");
      });
    },
    applyMasterRecordSortRankVisual(rows) {
      this.findMasterRecordSortVisualCells(rows).forEach((cell) => {
        cell.classList.add("master-sort-edited");
      });
    },
    refreshMasterRecordSortRankVisualForUid(grid, uid) {
      if (!grid || !uid) {
        return;
      }
      const rows = findAllKendoGridRowByUid(grid, uid).filter(Boolean);
      this.clearMasterRecordSortRankVisual(rows);
      const record =
        getKendoGridDataItems(grid).find((item) => item.uid === uid)
        || grid.dataSource?.getByUid?.(uid);
      if (record && this.isMasterRecordSortRankOnlyEdited(record)) {
        rows.forEach((row) => row.classList.remove("edited-bg", "master-edited-row"));
      }
      if (record && this.isMasterRecordSortRankEdited(record)) {
        this.applyMasterRecordSortRankVisual(rows);
      }
    },
    /** 並び順列の show/hide や dataBound 後に、変更済み sortRank の黄色を復元する */
    refreshMasterRecordSortRankVisuals(grid) {
      const widget = grid || this.getGridWidget();
      if (!widget) {
        return;
      }
      getKendoGridDataItems(widget).forEach((record) => {
        this.refreshMasterRecordSortRankVisualForUid(widget, record.uid);
      });
    },
    clearEditedBackgroundForUid(grid, uid) {
      findAllKendoGridRowByUid(grid, uid).filter(Boolean).forEach((row) => {
        row.classList.remove("edited-bg", "master-edited-row");
      });
    },
    onDataBound(e) {
      if (this.__pendingScrollToAddedRow) {
        this.__pendingScrollToAddedRow = false;
        this.scrollRestored = true;
        this.scrollPosition.left = 0;
        this.$nextTick(() => {
          this.scheduleGridScrollToAddedRow();
        });
      } else if (!this.scrollRestored && !this.saveFlg && (this.scrollPosition.top > 0 || this.scrollPosition.left > 0)) {
        this.scrollRestored = true;
        //スクロールバーの位置をイベント発生前の位置に戻す
        this.$nextTick(() => {
          this.setGridScrollPosition(this.scrollPosition);
        });
      }
      this.$nextTick(() => {
        let deletedRows = [];
        let editedRows = [];
        getKendoGridDataItems(e.sender).forEach((item) => {
          if (item.dirty) {
            item.dirty && editedRows.push(item);
          } else if (item.isDisp == "0") {
            deletedRows.push(item);
          }
        });
        deletedRows.forEach((tr) => {
          this.handleChangeEditedBackgroundColor(e, tr.uid, "deleted", "addBg");
        });
        if (this.isSortMode) {
          getKendoGridDataItems(e.sender).forEach((item) => {
            this.clearEditedBackgroundForUid(e.sender, item.uid);
          });
          requestAnimationFrame(() => {
            this.refreshMasterRecordSortRankVisuals(e.sender);
          });
        } else {
          editedRows.forEach((tr) => {
            if (this.isMasterRecordSortRankOnlyEdited(tr)) {
              this.clearEditedBackgroundForUid(e.sender, tr.uid);
              requestAnimationFrame(() => {
                this.refreshMasterRecordSortRankVisualForUid(e.sender, tr.uid);
              });
              return;
            }
            this.handleChangeEditedBackgroundColor(e, tr.uid, "edited", "addBg");
          });
        }

        const grid = this.getGridWidget();
        if (!grid || !grid.virtualScrollable) return;
        const wrapper = getKendoGridWrapperElement(grid);
        if (!wrapper) return;

        this.bindGridTouchScrollHandlers(wrapper);
      });
    },
    onCancel() {
      this.$router.go(-1);
    },
    /**
     * 編集行の背景色を変える
     * @param {*} e
     * @param {String} uid
     * @param {String} type new, edited, deleted
     * @param {String} operation  addBg, removeBg
     */
    handleChangeEditedBackgroundColor(e, uid, type, operation) {
      const rows = findAllKendoGridRowByUid(e.sender, uid).filter(Boolean);
      const record =
        getKendoGridDataItems(e.sender).find((item) => item.uid === uid)
        || e.sender?.dataSource?.getByUid?.(uid);
      const isSortRankOnlyDirty = this.isMasterRecordSortRankOnlyEdited(record);
      if ((this.isSortMode || isSortRankOnlyDirty) && (type === "edited" || type === "new")) {
        if (operation === "addBg") {
          rows.forEach((row) => row.classList.remove("edited-bg", "master-edited-row"));
          this.$nextTick(() => {
            this.refreshMasterRecordSortRankVisualForUid(e.sender, uid);
          });
        } else {
          rows.forEach((row) => row.classList.remove("edited-bg", "master-edited-row"));
          this.clearMasterRecordSortRankVisual(rows);
        }
        this.isNotChanged = !hasKendoDataSourceChanges(this.gridData);
        return;
      }
      rows.forEach((item) => {
        if (type === "deleted") {
          operation === "addBg"
            ? item.classList.add("deleted-bg", "master-deleted-row")
            : item.classList.remove("deleted-bg", "master-deleted-row");
        } else if (type === "edited" || type === "new") {
          operation === "addBg"
            ? item.classList.add("edited-bg", "master-edited-row")
            : item.classList.remove("edited-bg", "master-edited-row");
        }
      });
      this.isNotChanged = !hasKendoDataSourceChanges(this.gridData);
    },
    generatedData() {
      var that = this;
      const rowHeight = this.$el.querySelector('.k-grid-content tr')?.clientHeight || 30;
      const gridHeight = this.getGridRootElement()?.offsetHeight || this.$el.querySelector('.grid-content')?.offsetHeight || 900;
      const pageSize = Math.floor(gridHeight / rowHeight);
      const dateFields = Object.keys(that.gridSchemaModel || {}).filter((key) => {
        return that.gridSchemaModel[key]?.type === "date";
      });
      const data = (that.allGridData || []).map((item) => {
        if (!dateFields.length) {
          return item;
        }
        const nextItem = { ...item };
        dateFields.forEach((field) => {
          const converted = yyyymmddToDate(nextItem[field]);
          if (isValidDate(converted)) {
            nextItem[field] = converted;
          }
        });
        return nextItem;
      });
      const dataSource = createDataSource({
        pageSize: pageSize,
        data: data,
        schema: {
          model: {
            fields: that.gridSchemaModel,
            id: "code",
          },
        },
      });
      return markRaw(dataSource);
    },
    getRecordDataList() {
      let getDataList = sendRequestFindRecordListByFacilityCd;
      if (this.masterPhysicalName === "mst_favorite_facility") {
        this.setLoadingScreenVisible(true);
        getDataList = sendRequestFindRecordListByFacilityCdWithSql;
      }
      return getDataList(this.masterPhysicalName, this.facilityCd)
        .then((response) => {
          if (response.status === 200) {
            const localDataSource = response.data.localDataSource;
            this.gridColumns = this.handleFormatColumns(response.data.columns);
            this.allGridData = localDataSource.data.filter(item => (
              Object.prototype.hasOwnProperty.call(item, "isDel") ? item.isDel == "0" : true));
            this.gridSchemaModel = this.handleFormatModel(
              localDataSource.schema.model.fields);
            this.gridData = markRaw(this.generatedData());
            this.handleFilterByCondition(this.virtualCondition);
            this.$nextTick(() => {
              this.scheduleDirectGridInit();
              this.originalDataSource = _.cloneDeep(getKendoDataSourceCollection(this.gridData));
            });
          }
        })
        .catch((error) => {
          getErrorMessage(
            "MasterRecordVirtualScrollableComponent.vue",
            "getRecordDataList",
            error
          );
        })
        .finally(() => {
          this.masterPhysicalName === "mst_favorite_facility" &&
            this.setLoadingScreenVisible(false);
        });
    },
    handleFormatColumns(columns) {
      const fieldsMap = new Map();
      columns.forEach((col) => {
        col.neverEditable = !col.editable;
        col.isEditable = col.editable;
        col.editable = () => col.isEditable;
        col.width = emToPx(
          ColumnWidthMap.get(this.masterPhysicalName) || 14,
          this.fontSize
        );
        if (col.field === "allowAddRecord") {
          this.isAllowAddRecord = true;
        }
        if (col.field === "allowSort") {
          this.isAllowSort = true;
        }
        if (col.field === "sortRank") {
          col.template = ({ sortRank }) => {
            return `${this.isSortMode ? (sortRank ? sortRank : "") : ""}`;
          };
          col.width = this.isSortMode
            ? emToPx(9, this.fontSize)
            : emToPx(1, this.fontSize);
          col.editable = () => this.isSortMode;
          col.title = this.isSortMode ? col.title : "&nbsp;";
          col.neverEditable = false;
        }
        if (col.dataType === "modal") {
          const titleForBtnTextContrast = {
            詳細: {
              text: "詳細",
              width: 7,
            },
            デフォルト権限設定: {
              text: "権限設定",
              width: 13,
            },
            デフォルトメニュー設定: {
              text: "機能設定",
              width: 13,
            },
            施設選択: {
              text: "変更",
              width: 7,
            },
            デフォルト表示設定: {
              text: "表示設定",
              width: 13,
            },
            デフォルト通知設定: {
              text: "通知設定",
              width: 13,
            },
          };
          col.width = emToPx(
            titleForBtnTextContrast[col.title].width,
            this.fontSize
          );
          col.command = {
            text: titleForBtnTextContrast[col.title].text,
            click: (e) => this.showEditModal(e, col.title),
            className: "detail-btn",
          };
        }
        if (col.field === "isDisp") {
          col.width = emToPx(7, this.fontSize);
        }
        if (!col.hidden && col.title) {
          fieldsMap.set(col.field, col.title);
        }
        if (col.dataType === "date") {
          if (!col.format) {
            col.format = "{0:yyyy/MM/dd}";
          }
          col.editor = (container, data) =>
            this.eachModelCalendar(container, data);
        }
        if (col.field === "mainteContent3") {
          col.editor = (container, data) => {
            if (
              this.masterPhysicalName == "mst_mainte_detail" &&
              (!data.model.mainteClass || data.model.mainteClass === "1")
            ) {
              container.text(data.model[data.field] || '');
            } else {
              $(
                `<input type="text" name="${data.field}" class="k-input k-textbox k-valid"/>`
              ).appendTo(container);
            }
          };
        }
        if (
          this.masterPhysicalName == "mst_mainte_detail"
          && col.field === "iniText"
        ) {
          // 点検項目マスタの初期展開テキストの場合
          col.editor = (container, data) => {
            if (data.model.isCmt === "1") {
              // 補足コメント有無がコメント要の場合はテキスト入力可能とする
              $(
                `<input type="text" name="${data.field}" class="k-input k-textbox k-valid"/>`
              ).appendTo(container);
            } else {
              container.text(data.model[data.field] || "");
            }
          };
        }
        if (col.dataType === "textarea") {
          col.editor = (container, data) => {
            $(
              `<textarea name="${data.field}" class="k-valid k-textarea resize-obs-target" style="font-size: 1.0em; width:100%; resize: vertical; max-height: 65vh;"/>`
            ).appendTo(container);
          };
        }
      });
      this.setColumns(columns);
      columns = columns.filter((col) => {
        return col.hidden === false;
      });
      this.fieldsMap = fieldsMap;
      return columns;
    },
    eachModelCalendar(container, data) {
      if (this.androidFlg === true) {
        // Androidの場合は、HTML5のカレンダーを表示
        $(`<input type="date" name="${data.field}" />`).appendTo(container);
      } else {
        let moveOutFlg = false;
        container.mouseenter(() => (moveOutFlg = false));
        container.mouseleave(() => (moveOutFlg = true));
        // デスクトップ、iOSの場合は、処理で補正したHTML5のカレンダーを表示
        let nowData;
        let hasInitValue = true;
        const editedData = data.model[data.field];
        let nowDtatString;
        if (editedData) {
          nowData = yyyymmddToDate(editedData);
        } else {
          nowData = new Date();
          hasInitValue = false;
        }
        nowDtatString = formatMasterDateIsoValue(nowData);
        if (!editedData || !nowData) {
          nowDtatString = "";
        }
        $(
          `<span style="position:relative"><input type="date" style="width:8em" id="displayedDummyEditor" class="ntss-input-date" min="1880-01-01" max="2099-12-31" value="${nowDtatString}"/><input type="date" id="hiddenDateInputEditor" name="${data.field}" style="display: none;"/><span id="clear" class="k-icon k-i-close close-btn" title="clear" style="position:absolute;left:75%;top:-1px;color: #212529;z-index:9999999" ></span></span>`).appendTo(container);
        const editorRoot = container?.[0] || container?.get?.(0) || null;
        const editorDocument = editorRoot?.ownerDocument || this.$el?.ownerDocument || document;
        const getEditorElement = (selector) => editorRoot?.querySelector?.(selector) || editorDocument.querySelector(selector);
        const displayedDummyEditor = getEditorElement("#displayedDummyEditor");
        const hiddenDateInputEditor = getEditorElement("#hiddenDateInputEditor");
        const clearButton = getEditorElement("#clear");
        // フォーカスアウトで編集データを反映するイベントを発火
        displayedDummyEditor?.addEventListener("blur", function (ev) {
            if (!moveOutFlg) {
              return;
            }

            let resultData;
            const dayData = yyyymmddToDate(ev.target.value);
            if (ev.target.value === "" && !hasInitValue) {
              resultData = "";
              nowDtatString = "";
              hasInitValue = true;
            } else {
              resultData = formatMasterDateIsoValue(dayData);
            }

            if ((!hasInitValue || nowDtatString != resultData) && hiddenDateInputEditor) {
              hiddenDateInputEditor.value = resultData;
              $(hiddenDateInputEditor).trigger("change");
            }
          });

        const commonCalenderMountNode = editorDocument.createElement("span");
        container.append(commonCalenderMountNode);
        const commonCalenderApp = createApp(commonCalender, {
          onInput: (value) => {
            if (hiddenDateInputEditor) {
              hiddenDateInputEditor.value = value;
              $(hiddenDateInputEditor).trigger("change");
              this.closeGridCell();
            }
          }
        });
        let commonCalenderPicker = commonCalenderApp.mount(commonCalenderMountNode);
        commonCalenderPicker.setSilently(nowDtatString);
        
        const userAgent = ((this?.$el?.ownerDocument?.defaultView?.navigator?.userAgent) || globalThis?.navigator?.userAgent || "");
        if (userAgent.indexOf("Intel Mac OS") > -1) {
          displayedDummyEditor?.addEventListener("change", (ev) => {
              if (hiddenDateInputEditor) {
                hiddenDateInputEditor.value = ev.target.value;
                $(hiddenDateInputEditor).trigger("change");
              }
            });
        } else {
          displayedDummyEditor?.addEventListener("change", (ev) => {
              commonCalenderPicker.setSilently(ev.target.value);
            });
          clearButton?.addEventListener("mousedown", function () {
              if (hiddenDateInputEditor) {
                hiddenDateInputEditor.value = null;
                $(hiddenDateInputEditor).trigger("change");
              }
            });
          clearButton?.addEventListener("touchstart", function () {
              if (hiddenDateInputEditor) {
                hiddenDateInputEditor.value = null;
                $(hiddenDateInputEditor).trigger("change");
              }
            });
        }
      }
    },
    handleFormatModel(fields) {
      const getTitleText = (fieldName) => {
        const item = this.gridColumns.find((col) => {
          return col.field === fieldName;
        });
        if (item) {
          return item.title;
        }
        return "";
      };
      const requiredFields = [];
      Object.keys(fields).forEach((key) => {
        if (fields[key]?.validation?.required) {
          fields[key].validation.validationMessage = `${getTitleText(
            key)}は必須入力です。`;
          if (this.fieldsMap.get(key)) {
            requiredFields.push(key);
          }
        }
        if (key === "isDel") {
          fields[key].defaultValue = "0";
        }
        if (fields[key]?.type === "date") {
          fields[key].defaultValue = "";
        }
      });
      if (this.masterPhysicalName === "mst_exam_item") {
        fields.normalValueClass.defaultValue = "0"; // 正常値区分
        fields.examClass.defaultValue = "0"; // 検査使用区分
        fields.dataType.defaultValue = "1"; // データ形式
      }
      this.requiredFields = requiredFields;
      return fields;
    },
    handleToggleSortMode() {
      const take = getKendoDataSourceTake(this.gridData);
      const currentRangeStart = getKendoDataSourceCurrentRangeStart(this.gridData);
      const scrollTop = this.getGridVirtualScrollable()?._scrollTop;
      const top = this.getGridVerticalScrollbarEl()?.scrollTop;
      this.isSortMode = !this.isSortMode;
      this.gridColumns = this.gridColumns.map((column) => {
        if (column.field === "$modalType") {
          column.command.disabled = this.isSortMode;
        }
        if (column.field === "sortRank") {
          column.width = this.isSortMode
            ? emToPx(9, this.fontSize)
            : emToPx(1, this.fontSize);
          column.editable = () => this.isSortMode;
          column.title = this.isSortMode ? "並び順" : "&nbsp;";
          column.template = ({ sortRank }) => {
            return `${this.isSortMode ? ((sortRank || sortRank === 0) ? sortRank : "") : ""}`;
          };
        } else {
          column.editable = () => {
            if (column.neverEditable) {
              return false;
            } else {
              return !this.isSortMode;
            }
          };
        }
        return column;
      });
      this.applyDirectGridColumnsContract();
      this.scheduleDirectGridLayoutContract();
      // mod #10072 移植: 病名マスタ・検査項目マスタ等の大量行で「反映」押下時に
      // item.set() が行数分の change イベントを発火し Grid が何百回も refresh されて
      // UI スレッドが詰まり画面フリーズする問題を修正。
      // Vue2 と同様に change を一時 unbind → 直接代入でバッチ更新 → 1回だけ trigger。
      //
      // originalDataSource を Map 化して O(n²) → O(n) に改善（Vue2 と同様）。
      const originalMap = new Map(
        (this.originalDataSource || []).map((i) => [i.uid, i])
      );

      const sortItems =
        getKendoDataSourceCollection(this.gridData) ||
        getKendoDataSourceItems(this.gridData);

      // 「反映」(true→false) 時のみ sortRank 再整理を行う。
      // 「並び順表示」(false→true) 時は sortRank 変更不要。
      if (!this.isSortMode) {
        if (sortItems && typeof sortItems.sort === "function") {
          sortItems.sort((a, b) => {
            return a.sortRank - b.sortRank || a.sortInputTime - b.sortInputTime;
          });
        }

        // item.set() の代わりに直接プロパティを更新する。
        // item.set() は呼ぶたびに DataSource の change イベントを発火して
        // Grid refresh を引き起こすため、行数が多い病名マスタ・検査項目マスタでは
        // 何百回もの refresh が連続して UI スレッドが詰まり画面がフリーズする。
        sortItems?.forEach((item, index) => {
          if (item.isDisp == "1") {
            const newRank = index + 1;
            item.sortRank = newRank;
            if (item.dirty && item.dirtyFields.sortRank) {
              const originalItem = originalMap.get(item.uid);
              if (originalItem && newRank === originalItem.sortRank) {
                delete item.dirtyFields.sortRank;
                delete item.dirtyFields.dirty;
                if (Object.keys(item.dirtyFields).length === 0) {
                  item.dirty = false;
                  delete item.dirtyFields.dirty;
                }
              }
            } else {
              delete item.dirtyFields.sortRank;
              delete item.dirtyFields.dirty;
              if (Object.keys(item.dirtyFields).length === 0) {
                item.dirty = false;
              }
            }
          }
        });
      }

      this.isNotChanged = !hasKendoDataSourceChanges(this.gridData);

      // Vue2 の keys++ と同等: Grid を作り直して virtualScrollable を全新初期化する。
      // keys++ は <kendo-grid :key="keys"> コンポーネントを完全再構築し
      // virtualScrollable を初期状態に戻すことで scrollbar ずれを防いでいた。
      // Vue3 では destroyDirectGrid + initDirectGridIfReady で同等の効果を得る。
      // 直接代入で変更した gridData は DataSource のまま引き継がれるため
      // 新しい Grid でも最新データが表示される。
      this.destroyDirectGrid();
      this.$nextTick(() => {
        this.initDirectGridIfReady();
        rangeKendoDataSource(this.gridData, currentRangeStart, take, () => {
          this.scrollVirtualGridTo(scrollTop);
        });
        this.setGridScrollPosition({ top });
        if (this.isSortMode || getKendoGridDataItems(this.gridData).some((item) => this.isMasterRecordSortRankEdited(item))) {
          requestAnimationFrame(() => {
            requestAnimationFrame(() => {
              this.refreshMasterRecordSortRankVisuals(this.getGridWidget());
            });
          });
        }
      });
    },
    handleFilterByCondition(condition) {
      let { value, fields, includeDeleted } = condition;
      const filters = [];
      if (!includeDeleted) {
        filters.push({
          logic: "or",
          filters: [
            {
              logic: "and",
              filters: [
                {
                  field: "isDisp",
                  operator: "eq",
                  value: "1",
                },
              ],
            },
            {
              field: "dirty",
              operator: "eq",
              value: true,
            },
          ],
        });
        if (
          !["mst_job", "mst_favorite_facility"].includes(
            this.masterPhysicalName)) {
          filters[0].filters[0].filters.push({
            field: "isDel",
            operator: "eq",
            value: "0",
          });
        }
      }
      let fieldFilterList = [];
      if (fields?.length === 0) {
        fields = ["name"];
      }
      fields?.forEach((field) => {
        fieldFilterList.push({
          field: field,
          operator: "contains",
          value: value,
        });
      });
      fieldFilterList.push({
        field: "dirty",
        operator: "eq",
        value: true,
      });
      value &&
        filters.push({
          name: "condition",
          logic: "or",
          filters: fieldFilterList,
        });
      this.gridData?.filter({
        logic: "and",
        filters: filters,
      });
      this.applyDirectGridDataSourceContract();
      if (!this.__pendingScrollToAddedRow) {
        this.scrollVirtualGridTo(0);
      }
      this.scheduleDirectGridLayoutContract();
    },
    showEditModal(e, title) {
      this.scrollRestored = false;
   //イベント発生前のスクロールバーの位置を保持
      const { top: scrollTop, left: scrollLeft } = this.getGridScrollPosition();
      this.scrollPosition.top = scrollTop;
      this.scrollPosition.left = scrollLeft;
      e.preventDefault();
      const grid = this.getGridWidget();
      const dataItem = getKendoGridDataItem(grid, e.currentTarget.closest("tr"));
      if (
        this.masterPhysicalName === "mst_medicine" &&
        (dataItem.isNew() || dataItem.isImport)
      ) {
        dataItem.set(
          "medicateTimingCd",
          dataItem.medicateTimingCd || (this.DEFAULT_MEDICATE_TIMING === '-1' ? '' : this.DEFAULT_MEDICATE_TIMING)
        );
        dataItem.set(
          "procedureCd",
          dataItem.procedureCd || (this.DEFAULT_PROCEDURE === '-1' ? '' : this.DEFAULT_PROCEDURE)
        );
      }
      if (["mst_taboo_allergy"].includes(this.masterPhysicalName)) {
        this.setSchemaModel(this.gridSchemaModel);
      }
      if (
        ["mst_exam_item", "mst_favorite_facility"].includes(
          this.masterPhysicalName)) {
        this.setGridData(_.cloneDeep(getKendoDataSourcePlainItems(this.gridData)));
      }
      this.setEditRecord(dataItem);
      if (title === "デフォルト権限設定") {
        this.showJobMasterEditAuthority();
      }
      if (title === "施設選択") {
        this.showMstFavoriteFacilityModal();
      }
      if (["詳細", "デフォルトメニュー設定"].includes(title)) {
        this.showMasterEdit();
      }
      if (title === "デフォルト表示設定") {
        this.showMstJobEditDefaultSettingModal();
      }
      if (title === "デフォルト通知設定") {
        this.showMstJobEditNotificationSettingModal();
      }
    },
    onClickBreadcrumb() {
      if (this.isChanged) {
        this.$ons.notification.confirm({
          title: DIALOG_MESSAGES[13000004].title,
          message: messageFormat(DIALOG_MESSAGES[13000004].message),
          callback: (answer) => {
            if (answer) {
              this.getRecordDataList();
            }
          },
        });
        return;
      }
      this.getRecordDataList();
    },
    getMstFacilitySetting() {
      const contrast = {
        mst_job: {
          permissiones: {
            PERMISSION_CHANGE_SIGNOUT: PERMISSION_CHANGE_SIGNOUT
          },
          isBoolean: true,
        },
        mst_medicine_mix: {
          permissiones: {
            DEFAULT_MEDICATE_TIMING: DEFAULT_MEDICATE_TIMING,
            DEFAULT_PROCEDURE: DEFAULT_PROCEDURE
          },
        },
        mst_medicine: {
          permissiones: {
            DEFAULT_MEDICATE_TIMING: DEFAULT_MEDICATE_TIMING,
            DEFAULT_PROCEDURE: DEFAULT_PROCEDURE
          },
        }
      };
      const permissionesObj = contrast[this.masterPhysicalName]?.permissiones;
      Object.keys(permissionesObj).forEach((key) => {
        sendRequestGetMstFacilitySettingValue(this.facilityCd, permissionesObj[key]).then(
          (response) => {
            this[key] = contrast[this.masterPhysicalName]
              .isBoolean
              ? response.data === 1
              : response.data;
          }
        );
      });
    },
    initZoomObserver() {
      const target = this.$el.querySelector('.grid-content');
      if (!target || typeof ResizeObserver === 'undefined') return;

      this.zoomObserver = new ResizeObserver(() => {
        const grid = this.getGridWidget();
        if (grid?.virtualScrollable) {
          const dirtyItemsMap = new Map();
          if (!this.gridData || !this.gridData.data) return;
          getKendoDataSourceItems(this.gridData).forEach(item => {
            if (item.dirty) {
              dirtyItemsMap.set(item.code, toKendoDataSourcePlainItem(item));
            }
          });

          const newDataSource = this.generatedData();
          grid.setDataSource(newDataSource);
          this.gridData = newDataSource;
          this.installDirectGridFacade();

          // 復元処理
          getKendoDataSourceItems(this.gridData).forEach(item => {
            const saved = dirtyItemsMap.get(item.code);
            if (saved) {
              item.dirtyFields = {};
              Object.keys(saved).forEach(key => {
                item.set(key, saved[key]);
              });
              item.set("dirty", true);
              item.dirtyFields = saved.dirtyFields || {};
            }
          });

          this.handleFilterByCondition(this.virtualCondition);

          grid.refresh();
          this.refreshVirtualGrid();
          this.resizeVirtualGrid(30, true);
          this.scheduleDirectGridLayoutContract();
        }
      });

      this.zoomObserver.observe(target);
    },
  },
  created() {
    this.findColumnInfo();
    this.getRecordDataList();
    if (["mst_job", "mst_medicine", "mst_medicine_mix"].includes(this.masterPhysicalName)) {
      this.getMstFacilitySetting();
    }
    // 端末判別
    const ua = ((this?.$el?.ownerDocument?.defaultView?.navigator?.userAgent) || globalThis?.navigator?.userAgent || "").toLowerCase();
    if (/android/.test(ua)) {
      this.androidFlg = true;
    } else if (/iphone|ipad|mac|os/.test(ua)) {
      this.iosFlg = true;
    }
  },
  updated() {
    //updatedが2回目に呼ばれた場合
    if(this.updatedFlg){
      this.updatedFlg = false;
      this.saveFlg = false;
      this.scrollRestored = true;
    }
    //updatedが最初に呼ばれた場合
    if(this.saveFlg){
      this.updatedFlg = true;
    }
  },
  mounted() {
    EventBus.$emit("calculateMainHeight");
    EventBus.$on("refresh", this.onClickBreadcrumb);
    this.initZoomObserver();
    this.$nextTick(() => this.scheduleDirectGridInit());
  },
  beforeUnmount() {
    this.teardownValidationTooltipPlacement();
    const ownerWindow = this.getGridRootElement()?.ownerDocument?.defaultView || window;
    if (this.directGridInitRafId) {
      ownerWindow.cancelAnimationFrame?.(this.directGridInitRafId);
      this.directGridInitRafId = null;
    }
    if (this.directGridLayoutRafId) {
      ownerWindow.cancelAnimationFrame?.(this.directGridLayoutRafId);
      this.directGridLayoutRafId = null;
    }
    this.destroyDirectGrid();
    this.clearGridTouchScrollHandlers();
    this.setVirtualCondition({
      fields: [],
      includeDeleted: false,
      value: "",
    });
    EventBus.$off("refresh", this.onClickBreadcrumb);
    if (this.zoomObserver) {
      this.zoomObserver.disconnect();
    }
  },
  watch: {
    masterPhysicalName: {
      handler(val) {
        this.isAddButton = ![
          "sys_medicine",
          "mst_take_medicine",
          "mst_vital_graph",
        ].includes(val);
      },
      immediate: true,
    },
    virtualCondition: {
      handler(condition) {
        this.handleFilterByCondition(condition);
      },
      deep: true,
    },
    editedRowItem: {
      handler(val) {
        if (val && Object.keys(val).length) {
          if (this.masterPhysicalName === "mst_exam_item") {
            getKendoDataSourceItems(this.gridData).forEach((item) => {
              if (item.infectionCd && item.infectionCd == val.infectionCd && item.code !== val.code) {
                item.set("infectionCd", null);
              }
            })
          }
          const currentItem = getKendoDataSourceItemByUid(this.gridData, val.uid);
          if (!currentItem) {
            return;
          }
          const dateFieldSet = new Set(
            Object.keys(this.gridSchemaModel || {}).filter(
              (key) => this.gridSchemaModel[key]?.type === "date"
            )
          );
          const currentPlain = toKendoDataSourcePlainItem(currentItem);
          const valPlain = toKendoDataSourcePlainItem(val);
          const diff = diffObj(currentPlain, valPlain);
          Object.keys(val).forEach((key) => {
            const shouldSync = dateFieldSet.has(key)
              ? getMasterDateCompareKey(currentPlain[key]) !== getMasterDateCompareKey(valPlain[key])
              : Object.keys(diff).includes(key);
            if (!shouldSync) {
              return;
            }
            const nextValue = dateFieldSet.has(key)
              ? normalizeMasterDateForGrid(val[key])
              : val[key];
            currentItem.set(key, nextValue);
          });
          if (typeof val.isNew === "function" && val.isNew() && val.sortRank === 0) {
            this.judgeNewRowRequiredFields(val);
          }
        }
      },
      deep: true,
    },
    windowWidth() {
      this.refreshVirtualGrid();
    },
    windowHeight() {
      this.refreshVirtualGrid();
    },
    fontSize: {
      handler(newVal, oldVal) {
        this.gridColumns.forEach((column, index) => {
          if (column.width) {
            column.width = pxForFontSize(column.width, oldVal, newVal);
            this.getGridWidget()?.resizeColumn?.(
              this.getGridWidget()?.columns[index],
              parseFloat(column.width)
            );
          }
        });
        const isScrollBottom = this.getGridVirtualScrollable()?._isScrolledToBottom?.();

        this.applyDirectGridColumnsContract();
        this.getGridWidget()?.refresh?.();
        this.getGridVirtualScrollable()?.refresh?.();
        if (isScrollBottom) {
          this.$nextTick(() => {
            this.getGridVirtualScrollable()?.scrollToBottom?.();
          });
        }
      },
    },
    showSidebarFlg() {
      this.refreshVirtualGrid();
    },
    mstFavoriteFacilityAddRows: {
      handler(val) {
        if (!val?.length) {
          return;
        }
        try {
          this.getCsvData(_.cloneDeep(val));
        } catch (error) {
          getErrorMessage(
            "MasterRecordVirtualScrollableComponent.vue",
            "mstFavoriteFacilityAddRows",
            error
          );
        } finally {
          this.setMstFavoriteFacilityAddRows([]);
        }
      },
      deep: true,
    },
  },
};
</script>

<style scoped lang="scss">
* {
  box-sizing: border-box;
}
.virtual-container {
  height: 100%;
  padding: 0 5px;
}
.grid-content {
  height: calc(100% - 5.4em);
}
/* direct jq private wrapper contract: locked side width follows current Kendo columns. */
.virtual-grid-locked-layout {
  :deep(.k-grid-header-locked),
  :deep(.k-grid-content-locked),
  :deep(.k-grid-header-locked > table),
  :deep(.k-grid-content-locked > table) {
    width: var(--locked-width, auto) !important;
    min-width: 0 !important;
    flex-basis: auto !important;
    max-width: none !important;
  }
}
.tool-bar {
  display: flex;
  flex-direction: row;
  justify-content: space-between;
  padding: 0.2em 0;
}
.re-calculation-btn {
  margin-left: 10px;
}
.sort-mode {
  justify-content: flex-end;
  &.sort-mode-exam-item {
    justify-content: space-between;
  }
}
.tool-bar-right {
  align-self: flex-end;
}
.toolbar-btn {
  font-size: 1em;
  padding: 0.2em 1em 0em 1em;
  line-height: 2em;
  width: auto;
}
.right10 {
  margin-right: 10px;
}
.footer {
  margin: 0.5em 0;
  display: flex;
  flex-direction: row;
  justify-content: space-between;
}

:deep(.master-record-virtual-scrollable-direct-jq-grid) {
  height: 100%;
}
:deep(.k-widget) {
  border-width: 0 1px !important;
}
:deep(.k-grid tr) {
  td {
    border-width: 0 0 1px 1px !important;
    border-color: var(--master-maintenance-kgrid-border-color, var(--ntss-list-border-color)) !important;
  }
}
:deep(.edited-bg) {
  color: #003300;
  td {
    background-color: #ccffcc !important;
    border-color: var(--master-maintenance-kgrid-border-color, var(--ntss-list-border-color)) !important;
    &[data-field="sortRank"] {
      background-color: unset !important;
      .k-dirty {
        border-width: 0;
      }
    }
  }
}
/* 並び順 (sortRank) の黄色は master-sort-edited のみ（k-dirty-cell だけだと反映後に全行が黄色化しうる） */
:deep(td.master-sort-edited[data-field="sortRank"]),
:deep(td.master-sort-edited[data-field="dummy"]) {
  background-color: #ffff66 !important;
}
:deep(td.master-sort-edited[data-field="sortRank"]) .k-dirty {
  border-width: 0;
}
/* 並び順表示中は編集色（緑）を行全体に付けず、並び順列の黄色のみ */
:deep(.sort-mode tr.edited-bg td:not([data-field="sortRank"]):not([data-field="dummy"])) {
  background-color: unset !important;
  color: inherit !important;
}
:deep(td.k-dirty-cell) {
  font-weight: bold;
  &[data-field="sortRank"] {
    background-color: #ffff66 !important;
    .k-dirty {
      border-width: 0;
    }
  }
}
:deep(.sort-mode td.k-dirty-cell) {
  &[data-field="sortRank"] {
    .k-dirty {
      border-width: 5px;
    }
  }
}
:deep(.deleted-bg:not(.k-selected):not(.k-state-selected):not([aria-selected="true"])),
:deep(.deleted-bg:not(.k-selected):not(.k-state-selected):not([aria-selected="true"]):hover),
:deep(.deleted-bg:not(.k-selected):not(.k-state-selected):not([aria-selected="true"]).k-hover) {
  color: #333333 !important;
  background-color: #aaaaaa !important;
}

:deep(.deleted-bg:not(.k-selected):not(.k-state-selected):not([aria-selected="true"]) > td),
:deep(.deleted-bg:not(.k-selected):not(.k-state-selected):not([aria-selected="true"]):hover > td),
:deep(.deleted-bg:not(.k-selected):not(.k-state-selected):not([aria-selected="true"]).k-hover > td) {
  color: #333333 !important;
  background-color: #aaaaaa !important;
  border-color: var(--master-maintenance-kgrid-border-color, var(--ntss-list-border-color)) !important;
}
:deep(.detail-btn) {
  color: #ffffff !important;
  background-color: var(--btn3-normal-color);
  background-image: linear-gradient(
    var(--btn3-normal-color),
    var(--btn3-normal-color)
  ) !important;
  border-bottom: solid 3px var(--btn-common-border-color) !important;
  box-shadow: unset;
}
// :deep(.sort-edited-cell) {
//   background-color: #ffff66 !important;
// }
:deep(.k-tooltip.k-tooltip-validation) {
  width: auto;
}
:deep(.k-grid-content .k-edit-cell),
:deep(.k-grid-content-locked .k-edit-cell) {
  position: relative;
  overflow: visible;
}
.virtual-container :deep(td.k-edit-cell > .k-invalid-msg:not(.k-hidden)),
.virtual-container :deep(td.k-edit-cell > .k-form-error:not(.k-hidden)),
.virtual-container :deep(td.k-edit-cell > .k-validator-tooltip:not(.k-hidden)),
.virtual-container :deep(td.k-edit-cell > .k-tooltip-error:not(.k-hidden)),
.master-record-virtual-scrollable-direct-jq-grid :deep(td.k-edit-cell > .k-invalid-msg:not(.k-hidden)),
.master-record-virtual-scrollable-direct-jq-grid :deep(td.k-edit-cell > .k-form-error:not(.k-hidden)),
.master-record-virtual-scrollable-direct-jq-grid :deep(td.k-edit-cell > .k-validator-tooltip:not(.k-hidden)),
.master-record-virtual-scrollable-direct-jq-grid :deep(td.k-edit-cell > .k-tooltip-error:not(.k-hidden)) {
  position: absolute !important;
  top: calc(100% + 2px) !important;
  left: 0 !important;
  bottom: auto !important;
  z-index: 10;
  width: auto;
  padding:9px 15px !important;
  align-items: center;
  margin: 0.5em;
}

.virtual-container :deep(td.k-edit-cell .k-tooltip-content),
.master-record-virtual-scrollable-direct-jq-grid :deep(td.k-edit-cell .k-tooltip-content) {
  font-family: inherit !important;
  font-size: inherit !important;
  font-weight: normal !important;
  line-height: 1.4 !important;
}
/* 位置のみ：JS ntss-validation-above + ロック列 tbody 末尾行の CSS フォールバック（Vue2 仮想スクロール） */
.master-record-virtual-scrollable-direct-jq-grid {
  :deep(td.k-edit-cell.ntss-validation-above > .k-invalid-msg:not(.k-hidden)),
  :deep(td.k-edit-cell.ntss-validation-above .k-invalid-msg.k-tooltip-error:not(.k-hidden)),
  :deep(td.k-edit-cell.ntss-validation-above .k-tooltip.k-tooltip-error:not(.k-hidden)),
  :deep(td.k-edit-cell.ntss-validation-above .k-tooltip.k-tooltip-validation:not(.k-hidden)),
  :deep(td.k-edit-cell.ntss-validation-above .k-validator-tooltip:not(.k-hidden)),
  :deep(.k-grid-content-locked tbody > tr:nth-last-child(-n + 2) td.k-edit-cell > .k-invalid-msg:not(.k-hidden)),
  :deep(.k-grid-content-locked tbody > tr:nth-last-child(-n + 2) td.k-edit-cell .k-tooltip.k-tooltip-error:not(.k-hidden)) {
    position: absolute !important;
    left: 0 !important;
    bottom: 40px !important;
    top: auto !important;
    /* margin-top: 0 !important; */
    overflow: visible !important;
    padding:9px 15px !important;
    align-items: center;
    margin: 0.5em;
  }
  :deep(.k-grid-content-locked tbody > tr td.k-edit-cell .k-callout.k-callout-n) {
    border-block-end-color: #000000 !important;
  }
  :deep(td.k-edit-cell.ntss-validation-above .k-callout.k-callout-s),
  :deep(.k-grid-content-locked tbody > tr:nth-last-child(-n + 2) td.k-edit-cell .k-callout.k-callout-n) {
    top: auto !important;
    bottom: calc(-12px) !important;
    border-bottom-color: transparent !important;
    border-block-start-color: #000000 !important;
  }

}
:deep(.k-grid-content),
:deep(.k-grid-content-locked),
:deep(.k-pager-wrap) {
  white-space: nowrap;
}
:deep(.k-grid-edit-row) {
  .k-button,
  .k-textbox,
  .k-input.k-textbox {
    height: 2em;
  }
  .k-widget {
    white-space: normal;
  }
  td {
    text-overflow: ellipsis;
  }
}

.custom-switch {
  transform: scale(0.85);
  transform-origin: center;
  touch-action: manipulation;
}
:deep(.k-grid-content),
:deep(.k-grid-content-locked) {
  touch-action: manipulation !important;
  -webkit-overflow-scrolling: touch !important;
}
.mobile-header {
  min-height: 30px; /* モバイル用の高さ */
}


/* Vue2 direct jq 画面: 表頭 .k-link の cursor を default に（列ソート無しの誤表示防止） */
.virtual-container :deep(.k-grid-header th),
.virtual-container :deep(.k-grid-header .k-table-th),
.virtual-container :deep(.k-grid-header-locked th),
.virtual-container :deep(.k-grid-header-locked .k-table-th) {
  border-right-color: var(--master-maintenance-kgrid-border-color);
}
.virtual-container :deep(.k-grid-header th),
.virtual-container :deep(.k-grid-header .k-table-th),
.virtual-container :deep(.k-grid-header .k-link),
.virtual-container :deep(.k-grid-header-locked th),
.virtual-container :deep(.k-grid-header-locked .k-table-th),
.virtual-container :deep(.k-grid-header-locked .k-link) {
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
