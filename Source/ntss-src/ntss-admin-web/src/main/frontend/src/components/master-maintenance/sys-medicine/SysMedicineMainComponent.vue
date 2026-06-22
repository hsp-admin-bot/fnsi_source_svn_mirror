/**
* マスタメンテナンスデータページ  MainContent
*/
<template>
  <div class='main-content-area master-maintenance-page'>
    <div class='ntss-list' :style="ntssListStyles">
      <div class="k-grid-toolbar k-header kendo-grid-toolbar-style" :style="heightStyles">
        <div id="grid-header" :class="['header-btn-area', 'right', isMobileDevice ? 'mobile-header' : '']">
          <v-ons-button modifier="outline" class="btn3-normal toolbar-btn" style="float: left;"
                        v-show="!isSortMode && isAllowSort" @click="addRow()">追加
          </v-ons-button>
          <v-ons-row v-show="isMobileDevice" style="float: left; width: 6em; height: 1em;">
            <v-ons-col width="45%" vertical-align="center">
              <label class="fab-font-color">編集</label>
            </v-ons-col>
            <v-ons-col width="55%" vertical-align="center">
              <v-ons-switch modifier="outline" style="float: left; margin-left: 2px;" v-model="allowEdit"></v-ons-switch>
            </v-ons-col>
          </v-ons-row>
          <v-ons-button modifier="outline" class="btn3-normal toolbar-btn csv-btn" style="margin-right: 10px;" v-show="!isSortMode && isAllowAddRecord" @click="importCsv()">CSV取込</v-ons-button>
          <v-ons-button modifier="outline" class="btn3-normal toolbar-btn" v-show="!isSortMode && isAllowSort"
                        @click="toRankEditBtnClick()">並び順表示
          </v-ons-button>
          <v-ons-button modifier="outline" class="btn3-normal toolbar-btn" v-show="isSortMode && isAllowSort"
                        @click="sortBtnClick()">反映
          </v-ons-button>
        </div>
        <div
          v-show="columns.length > 1"
          id="grid-font-size"
          ref="gridRoot"
          :class="[fontSizeSet, 'ntss-kendo-grid-legacy', 'sys-medicine-direct-jq-grid']"
        ></div>
      </div>
      <div id="grid-footer">
        <v-ons-row width="100%" v-show="!isSortMode">
          <v-ons-col width="50%">
            <v-ons-button class="btn2-cancel denial-btn" style="width: auto;" @click="cancel">キャンセル
            </v-ons-button>
          </v-ons-col>
          <v-ons-col width="50%" class="right">
            <v-ons-button class="btn1-execute registration-btn" style="width: auto;" :disabled="!isChanged"
                          @click="saveRecord">保存
            </v-ons-button>
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
import NextTransitionMixin from "@/components/NextTransitionMixin";
import MasterMaintenanceMixin from "@/components/master-maintenance/MasterMaintenanceMixin";
import { mapActions, mapGetters, mapMutations, mapState } from "@/compat/vue/vuex";
import {EventBus} from "@/compat/vue/event-bus.js";
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages.js";
import MasterCsvComponent from "@/components/master-maintenance/MasterCsvComponent";

import {deepCopy} from "@/functions/common/CommonFunctions";
import {ApiHelper} from "@/apis/AxiosHelper";
// add 鞠 start
import commonCalender from "@/components/common/custom-calendar/CustomCalendar";
import { createApp, markRaw } from "@/compat/vue/runtime";
// add 鞠 end
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start

// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end

import _ from "@/compat/collections/lodash";
import { getMainContentAreaElement, getScopedDocument, queryElementBySelectors } from "@/functions/common/LayoutMeasureHelper";
import { messageFormat } from "@/functions/common/MessageFormat";
import kendo from "@progress/kendo-ui";
import $ from "jquery";
import {
  captureKendoGridScrollPosition,
  restoreKendoGridScrollPosition
} from "@/compat/kendo/grid-scroll.js";

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
  mixins: [NextTransitionMixin, MasterMaintenanceMixin],
  components: {
    "master-csv": MasterCsvComponent
  },
  data() {
    return {
      reportCategory: [],
      dataGrouping: [],
      isSortMode: false,
      columns: [
        {
          field: "code",
          title: "code",
          hidden: false,
          locked: false,
          editable: () => true,
          values: null,
        },
      ],
      kendoValidatorSetup: {
        rules: {},
        messages: {},
      },
      kendoGridToolbarHeight: 500,
      kendoGridHeight: 300,
      columnWidth: 14,
      condition: {
        recordName: "",
        includeDeleted: false
      },
      scrollPosition: {
        top: 0,
        left: 0
      },
      //自画面の名称
      selfScreenName: "",
      masterCsvVisible: false,
      masterCsvTarget: null,
      lastScrollTop: 0,
      lastInputScrollLeft: 0,
      facilitylistValue: "",

      dataSourceItems: {},
      scrollFlag: false,
      offset: 0,
      // add #6930 標準医薬品マスタの抽出で追加読み込みが行われない 付 start
      sysMedicineDataTotal: null,
      // add #6930 標準医薬品マスタの抽出で追加読み込みが行われない 付 end
      allowEdit: true, // NOTE: true = 編集モード、 false = 閲覧モード,
      androidFlg: false,
      iosFlg: false,
      isSorted: false,
      editingFlg: false,
      editFlg: false,
      loadingFlag: false,
      addRowScrollFlag: false,
      __pendingScrollToBottom: false,
      __preserveScrollOnReload: false,
      __reloadScrollPosition: { top: 0, left: 0 },
      dataPageScrollFlag: false,
      sysMedicine: [],
      lockedColumnsWidth: null,
      updateResponse: null,
      scrollLeft: 0,
      scrollTop: 0,
      waterSurveyPointValueFalg: false,
      gridScrollSyncBound: false,
      gridScrollSyncCleanup: [],
      directGridWidget: null,
      directGridMounted: false,
      directGridLayoutRafId: null,
      directGridFilterRefreshRafId: null,
      directGridScrollSyncRafId: null,
      directGridRowVisualRafIds: markRaw(new Map()),
      sysMedicineRowSnapshots: markRaw(new Map()),
      directGridProgrammaticScrollDepth: 0,
      directGridProgrammaticScrollTimer: null,
      sysMedicinePageLoading: false,
      sysMedicinePageScrollRestorePending: false,
      sysMedicinePageScrollRestoreTimers: [],
      sysMedicinePageScrollRestoreRafId: null,
      sysMedicinePageScrollRestorePosition: { top: 0, left: 0 },
      directGridLastHeight: null,
      kendoValidator: null,
    }
  },
  async created() {
    // add redmine 6238 標準医薬品マスタでデータが表示されない 宋qy start
    this.setLoadingScreenVisible(true);
    // add redmine 6238 標準医薬品マスタでデータが表示されない 宋qy end
    // 端末判別
    const ua = ((this?.$el?.ownerDocument?.defaultView?.navigator?.userAgent) || globalThis?.navigator?.userAgent || "").toLowerCase();
    if (/android/.test(ua)) {
      this.androidFlg = true;
    } else if (/iphone|ipad|mac|os/.test(ua)) {
      this.iosFlg = true;
    }
    this.setCondition(this.condition);
    this.loadGridData();
    this.selfScreenName = this.getCurrentRouteName();
    this.kendoValidator = { validate: () => this.validateDirectKendoGrid() };
    this.facilitylistValue = this.getFacilitySwitch;
    EventBus.$on("onCloseMasterEditModal", this.onCloseMasterEditModal);
    EventBus.$on("refresh", this.refresh);
    EventBus.$on("onSearchForMstVirtualScrollable", this.onSearch);
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
    // add redmine 6238 標準医薬品マスタでデータが表示されない 宋qy start
    // 关闭loading
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
    },
    // add redmine 6238 標準医薬品マスタでデータが表示されない 宋qy end
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
    ...mapGetters("user", {facilityCd: "getFacilityCd"}),
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
      getFacilitySwitch: "getFacilitySwitch",
      comparisonRecordModel: "getComparisonRecordModel",
      masterRecordListRevision: "getMasterRecordListRevision",
    }),
    // add #9590 start
    ...mapState("master-maintenance", {
      conditions: "condition"
    }),
    // add #9590 end
    heightStyles() {
      // main部の高さをCSS変数を利用して書き換え
      return {"--height": `${this.kendoGridToolbarHeight}px`};
    },
    ntssListStyles() {
      if (this.columns.length == 1) {
        return { display: "none" };
      }
      const height = Number(this.kendoGridToolbarHeight) || 0;
      return {
        display: "inherit",
        "--height": `${height}px`,
        height: `${height}px`,
        maxHeight: `${height}px`,
        overflow: "hidden"
      };
    },
    masterConditionSignature() {
      const condition = this.$store?.state?.["master-maintenance"]?.condition || this.conditions || this.condition || {};
      return `${condition.recordName || ""}|${condition.includeDeleted ? 1 : 0}|${this.getMasterRecordList?.data?.length || 0}`;
    },
    isAllowSort() {
      // allowSortが定義されていない場合は並び替えボタンは使用不可
      return !(this.getColumnIndex("allowSort") < 0);
    },
    isAllowAddRecord() {
      // allowAddRecordが定義されていない場合は追加ボタンは使用不可
      return !(this.getColumnIndex("allowAddRecord") < 0);
    },
    isAddButton() {
      let addMasterName = ["sys_medicine","mst_take_medicine","mst_vital_graph"]
      return addMasterName.indexOf(this.masterPhysicalName) < 0 ;
    },
    fontSizeSet() {
      const names = ["small", "medium", "large", "x-large"];
      return "font-size-set-" + names[this.getFontSize];
    },
    masterRecords() {
      // storeからデータを取得
      return this.getFilteredMasterRecordList;
    },
    isChanged() {
      const data = this.getMasterRecordList?.data;
      if (
        this.getStateUserAccountInfo === null ||
        this.kendoValidator === undefined ||
        data === undefined
      ) {
        return false;
      }
      void this.masterRecordListRevision;
      if (!this.validateBeforeGridAction()) {
        return true;
      }
      return this.isSorted || data.some(row => this.isSysMedicineRowEdited(row));
    },
    isMobileDevice() {
      return this.iosFlg || this.androidFlg;
    },
  },
  methods: {
    getCurrentRouteName() {
      return this.$router?.currentRoute?.value?.name || this.$router?.currentRoute?.name || this.$route?.name || "";
    },
    validateBeforeGridAction() {
      const validator = this.kendoValidator;
      if (validator && typeof validator.validate === "function") {
        return validator.validate();
      }
      return true;
    },
    validateDirectKendoGrid() {
      return true;
    },
    getDirectGridRoot() {
      return this.$refs.gridRoot || null;
    },
    getGridWidget() {
      return this.directGridWidget || null;
    },
    getGridRootElement() {
      return this.getDirectGridRoot();
    },
    getGridScrollSender() {
      return this.directGridWidget || this.getDirectGridRoot() || null;
    },
    getGridScrollPosition() {
      const sender = this.getGridScrollSender();
      if (!sender) {
        return this.normalizeGridScrollPosition({
          top: this.lastScrollTop,
          left: this.lastInputScrollLeft
        });
      }
      const captured = captureKendoGridScrollPosition(sender);
      return {
        top: Math.max(captured.top || 0, this.lastScrollTop || 0),
        left: captured.left || this.lastInputScrollLeft || 0
      };
    },
    captureReloadScrollPosition() {
      this.__reloadScrollPosition = this.normalizeGridScrollPosition(this.getGridScrollPosition());
      this.rememberGridScrollPosition(this.__reloadScrollPosition);
      return this.__reloadScrollPosition;
    },
    getGridScrollMaxTop() {
      const content = this.getGridScrollHostEl();
      const locked = this.getGridLockedContentElement();
      return Math.max(
        0,
        (content?.scrollHeight || 0) - (content?.clientHeight || 0),
        (locked?.scrollHeight || 0) - (locked?.clientHeight || 0)
      );
    },
    canApplyGridScrollTop(top) {
      const desiredTop = Number(top) || 0;
      if (desiredTop <= 0) {
        return true;
      }
      return this.getGridScrollMaxTop() >= desiredTop;
    },
    setGridScrollPosition(position = {}) {
      this.restoreGridScrollPosition(position);
    },
    setLastScroll() {
      this.rememberGridScrollPosition(this.getGridScrollPosition());
    },
    rememberGridScrollPosition(position = {}) {
      const top = Number(position.top);
      const left = Number(position.left);
      if (Number.isFinite(top)) {
        this.lastScrollTop = top;
        this.scrollPosition.top = top;
        this.scrollTop = top;
      }
      if (Number.isFinite(left)) {
        this.lastInputScrollLeft = left;
        this.scrollPosition.left = left;
        this.scrollLeft = left;
      }
    },
    getGridContentElement() {
      return this.getGridContentEl?.() || this.$refs.grid?.gridContentEl?.() || null;
    },
    getGridLockedContentElement() {
      return this.getGridLockedContentEl?.() || this.$refs.grid?.gridLockedContentEl?.() || null;
    },
    getGridHeaderWrapElement() {
      return this.getGridHeaderWrapEl?.() || this.$refs.grid?.gridHeaderWrapEl?.() || null;
    },
    getGridLockedHeaderElement() {
      return this.getGridLockedHeaderEl?.() || this.$refs.grid?.gridLockedHeaderEl?.() || null;
    },
    getGridAutoScrollableElement() {
      return this.getGridAutoScrollableEl?.() || this.$refs.grid?.gridAutoScrollableEl?.() || this.getGridContentElement();
    },
    readGridScrollPosition() {
      return this.getGridScrollPosition();
    },
    runWithDirectGridProgrammaticScroll(callback) {
      this.directGridProgrammaticScrollDepth += 1;
      try {
        callback?.();
      } finally {
        if (this.directGridProgrammaticScrollTimer != null) {
          clearTimeout(this.directGridProgrammaticScrollTimer);
        }
        this.directGridProgrammaticScrollTimer = setTimeout(() => {
          this.directGridProgrammaticScrollDepth = 0;
          this.directGridProgrammaticScrollTimer = null;
        }, 80);
      }
    },
    isDirectGridProgrammaticScrolling() {
      return this.directGridProgrammaticScrollDepth > 0;
    },
    restoreGridScrollPosition(position = {}) {
      const sender = this.getGridScrollSender();
      const content = this.getGridScrollHostEl();
      if (!sender && !content) {
        return false;
      }
      let appliedTop = Number(position.top) || 0;
      let appliedLeft = Number(position.left) || 0;
      if (!this.canApplyGridScrollTop(appliedTop)) {
        return false;
      }
      const maxLeft = Math.max(0, (content?.scrollWidth || 0) - (content?.clientWidth || 0));
      appliedLeft = Math.min(Math.max(0, appliedLeft), maxLeft);
      const maxTop = this.getGridScrollMaxTop();
      appliedTop = Math.min(Math.max(0, appliedTop), maxTop);
      this.runWithDirectGridProgrammaticScroll(() => {
        if (sender) {
          restoreKendoGridScrollPosition(sender, { top: appliedTop, left: appliedLeft });
        } else if (content) {
          content.scrollLeft = appliedLeft;
          content.scrollTop = appliedTop;
          this.syncDirectGridLockedScrollPosition(appliedTop);
        }
        const grid = this.directGridWidget;
        if (grid?.content?.[0]) {
          grid.content[0].scrollLeft = appliedLeft;
        }
        const headerWrap = this.getGridHeaderWrapElement();
        if (headerWrap) {
          headerWrap.scrollLeft = appliedLeft;
        }
        if (grid && typeof grid._scrollLeft !== "undefined") {
          grid._scrollLeft = appliedLeft;
        }
      });
      this.rememberGridScrollPosition({ top: appliedTop, left: appliedLeft });
      return true;
    },
    syncDirectGridScrollToAddedRow() {
      const content = this.getGridScrollHostEl();
      const locked = this.getGridLockedContentElement();
      if (!content && !locked) {
        return;
      }
      const top = Math.max(
        0,
        (content?.scrollHeight || 0) - (content?.clientHeight || 0),
        (locked?.scrollHeight || 0) - (locked?.clientHeight || 0)
      );
      this.restoreGridScrollPosition({ top, left: 0 });
    },
    scheduleDirectGridAddRowScroll() {
      const apply = () => this.syncDirectGridScrollToAddedRow();
      apply();
      this.$nextTick(() => {
        apply();
        requestAnimationFrame(apply);
        [0, 32, 80, 180].forEach(ms => setTimeout(apply, ms));
      });
    },
    clearSysMedicinePageScrollRestoreTimers() {
      (this.sysMedicinePageScrollRestoreTimers || []).forEach(timerId => clearTimeout(timerId));
      this.sysMedicinePageScrollRestoreTimers = [];
      if (this.sysMedicinePageScrollRestoreRafId != null) {
        cancelAnimationFrame(this.sysMedicinePageScrollRestoreRafId);
        this.sysMedicinePageScrollRestoreRafId = null;
      }
    },
    normalizeGridScrollPosition(position = {}) {
      return {
        top: Math.max(0, Number(position.top) || 0),
        left: Math.max(0, Number(position.left) || 0)
      };
    },
    restoreSysMedicinePageScrollPosition(position = this.sysMedicinePageScrollRestorePosition) {
      const nextPosition = this.normalizeGridScrollPosition(position);
      if (!this.restoreGridScrollPosition(nextPosition)) {
        return false;
      }
      const current = this.getGridScrollPosition();
      return Math.abs((current.top || 0) - nextPosition.top) <= 1
        && Math.abs((current.left || 0) - nextPosition.left) <= 1;
    },
    scheduleSysMedicinePageScrollRestore(position = this.getGridScrollPosition()) {
      this.clearSysMedicinePageScrollRestoreTimers();
      this.sysMedicinePageScrollRestorePending = true;
      this.sysMedicinePageScrollRestorePosition = this.normalizeGridScrollPosition(position);
      this.rememberGridScrollPosition(this.sysMedicinePageScrollRestorePosition);
      let attempt = 0;
      const maxAttempt = 18;
      const restore = () => {
        this.sysMedicinePageScrollRestoreRafId = null;
        const stable = this.restoreSysMedicinePageScrollPosition(this.sysMedicinePageScrollRestorePosition);
        attempt += 1;
        if (this.sysMedicinePageScrollRestorePending && attempt < maxAttempt) {
          this.sysMedicinePageScrollRestoreRafId = requestAnimationFrame(restore);
          return;
        }
        this.sysMedicinePageScrollRestoreTimers.push(setTimeout(() => {
          this.restoreSysMedicinePageScrollPosition(this.sysMedicinePageScrollRestorePosition);
          this.sysMedicinePageScrollRestorePending = false;
          this.__preserveScrollOnReload = false;
          this.sysMedicinePageLoading = false;
          this.clearSysMedicinePageScrollRestoreTimers();
        }, stable ? 40 : 120));
      };
      const applyRestore = () => this.restoreSysMedicinePageScrollPosition(this.sysMedicinePageScrollRestorePosition);
      this.$nextTick(() => {
        this.sysMedicinePageScrollRestoreRafId = requestAnimationFrame(restore);
        [0, 32, 80, 180, 320, 520].forEach(ms => {
          this.sysMedicinePageScrollRestoreTimers.push(setTimeout(applyRestore, ms));
        });
      });
    },
    getDirectGridRecordKey(record) {
      if (!record) {
        return "";
      }
      return String(record.code ?? record.standardNo ?? record.uid ?? record.id ?? "");
    },
    stripSysMedicineCompareFields(record) {
      const plain = typeof record?.toJSON === "function" ? record.toJSON() : { ...(record || {}) };
      ["operation", "edited", "dirty", "dirtyFields", "uid", "skipSearch", "sortInputTime", "upDate", "dummy", "isAddRow"].forEach(key => {
        delete plain[key];
      });
      Object.keys(plain).forEach(key => {
        if (plain[key] === "") {
          plain[key] = null;
        }
      });
      return plain;
    },
    findSysMedicineOriginalRecord(record) {
      const key = this.getDirectGridRecordKey(record);
      if (key && this.sysMedicineRowSnapshots.has(key)) {
        return this.sysMedicineRowSnapshots.get(key);
      }
      try {
        return JSON.parse(this.comparisonRecordModel || "[]")
          .find(row => String(row.code) === String(record?.code)) || null;
      } catch {
        return null;
      }
    },
    rememberSysMedicineRowSnapshot(record) {
      const key = this.getDirectGridRecordKey(record);
      if (!key || this.sysMedicineRowSnapshots.has(key)) {
        return;
      }
      this.sysMedicineRowSnapshots.set(key, this.stripSysMedicineCompareFields(record));
    },
    clearSysMedicineRowSnapshots() {
      this.sysMedicineRowSnapshots?.clear?.();
    },
    resetSysMedicineRowEditBaseline() {
      const data = this.getMasterRecordList?.data;
      if (Array.isArray(data)) {
        data.forEach(row => {
          delete row.operation;
          row.edited = false;
          row.dirty = false;
          if (row.dirtyFields) {
            Object.keys(row.dirtyFields).forEach(key => delete row.dirtyFields[key]);
          }
        });
      }
      this.setComparisonRecordModel();
      this.clearSysMedicineRowSnapshots();
      (data || []).forEach(row => this.rememberSysMedicineRowSnapshot(row));
      this.bumpMasterRecordListRevision();
    },
    isSysMedicineRowEdited(record) {
      if (Number(record?.operation) === 1) {
        return record?.edited === true;
      }
      const original = this.findSysMedicineOriginalRecord(record);
      if (!original) {
        return Number(record?.operation || 0) > 0 || record?.edited === true;
      }
      const current = this.stripSysMedicineCompareFields(record);
      const orig = this.stripSysMedicineCompareFields(original);
      const keys = new Set([...Object.keys(current), ...Object.keys(orig)]);
      for (const key of keys) {
        const a = current[key] == null || current[key] === "" ? null : current[key];
        const b = orig[key] == null || orig[key] === "" ? null : orig[key];
        if (a != b) {
          return true;
        }
      }
      return false;
    },
    clearSysMedicineRowIfMatchesOriginal(model) {
      if (!model || this.isSysMedicineRowEdited(model)) {
        return;
      }
      delete model.operation;
      model.edited = false;
      model.dirty = false;
      if (model.dirtyFields) {
        Object.keys(model.dirtyFields).forEach(key => delete model.dirtyFields[key]);
      }
      const data = this.getMasterRecordList?.data;
      if (Array.isArray(data)) {
        const target = data.find(row => String(row.code) === String(model.code));
        if (target) {
          delete target.operation;
          target.edited = false;
        }
      }
      this.bumpMasterRecordListRevision();
    },
    refreshDirectGridVisualState() {
      const grid = this.directGridWidget;
      if (!grid?.dataSource) {
        return;
      }
      Array.from(grid.dataSource.data() || []).forEach(record => this.applyDirectGridRowVisualState(record, record.uid));
    },
    scheduleDirectGridRowVisualState(record, uid = null, deferUntilCellClose = false) {
      const key = uid || record?.uid || this.getDirectGridRecordKey(record) || Math.random();
      const oldId = this.directGridRowVisualRafIds.get(key);
      if (oldId != null) {
        cancelAnimationFrame(oldId);
      }
      const run = () => {
        this.directGridRowVisualRafIds.delete(key);
        this.applyDirectGridRowVisualState(record, uid);
      };
      const scheduleRun = () => {
        if (deferUntilCellClose) {
          requestAnimationFrame(() => requestAnimationFrame(run));
          return;
        }
        const id = requestAnimationFrame(run);
        this.directGridRowVisualRafIds.set(key, id);
      };
      if (deferUntilCellClose) {
        this.$nextTick(scheduleRun);
      } else {
        scheduleRun();
      }
    },
    applyDirectGridRowVisualState(record, uid = null) {
      const grid = this.directGridWidget;
      if (!grid || !record) {
        return;
      }
      const rowUid = uid || record.uid;
      const rows = rowUid
        ? Array.from(this.getDirectGridRoot()?.querySelectorAll?.(`tr[data-uid='${rowUid}']`) || [])
        : [];
      const edited = this.isSysMedicineRowEdited(record);
      rows.forEach(row => {
        row.classList.toggle("master-edited-row", edited);
        if (!edited) {
          row.classList.remove("k-dirty-row");
          Array.from(row.children || []).forEach(cell => {
            cell.classList.remove("k-dirty-cell", "master-edited-cell", "master-deleted-row");
            cell.querySelectorAll(".k-dirty").forEach(marker => marker.remove());
          });
        }
      });
    },
    createDirectGridDataSourceModel(dataSource, row) {
      const Model = dataSource?.reader?.model;
      if (Model && typeof Model === "function") {
        return row instanceof Model ? row : new Model(row);
      }
      return row;
    },
    batchAppendDirectGridDataSourceRows(dataSource, rows = []) {
      if (!dataSource || !rows.length || typeof dataSource.insert !== "function") {
        return [];
      }
      const observableData = dataSource._data;
      const changeHandler = dataSource._changeHandler;
      const canSuspendDataChange = observableData
        && typeof observableData.unbind === "function"
        && typeof observableData.bind === "function"
        && typeof changeHandler === "function";
      const originalAutoSync = dataSource.options?.autoSync;
      const appendedModels = [];
      if (canSuspendDataChange) {
        observableData.unbind("change", changeHandler);
      }
      if (dataSource.options) {
        dataSource.options.autoSync = false;
      }
      try {
        rows.forEach(row => {
          const model = this.createDirectGridDataSourceModel(dataSource, row);
          const inserted = dataSource.insert(dataSource.data().length, model);
          appendedModels.push(inserted);
        });
      } finally {
        if (dataSource.options) {
          dataSource.options.autoSync = originalAutoSync;
        }
        if (canSuspendDataChange) {
          observableData.bind("change", changeHandler);
        }
      }
      if (appendedModels.length) {
        if (typeof dataSource._change === "function") {
          dataSource._change({ action: "add", items: appendedModels });
        } else if (typeof dataSource.trigger === "function") {
          dataSource.trigger("change", { action: "add", items: appendedModels });
        }
      }
      return appendedModels;
    },
    appendSysMedicinePageRowsToDirectGrid(rows = [], position = this.getGridScrollPosition()) {
      const grid = this.directGridWidget;
      const dataSource = grid?.dataSource;
      if (!grid || !dataSource || !rows.length || typeof dataSource.insert !== "function") {
        this.dataSourceItems = this.generatedGridData();
        this.setGridDataSource(this.dataSourceItems);
        this.scheduleSysMedicinePageScrollRestore(position);
        return;
      }
      const currentItems = typeof dataSource.data === "function" ? Array.from(dataSource.data() || []) : [];
      const existingKeys = new Set(currentItems.map(item => this.getDirectGridRecordKey(item)).filter(Boolean));
      const appendRows = rows.filter(row => {
        const key = this.getDirectGridRecordKey(row);
        if (key && existingKeys.has(key)) {
          return false;
        }
        if (key) {
          existingKeys.add(key);
        }
        return true;
      });
      if (!appendRows.length) {
        this.scheduleSysMedicinePageScrollRestore(position);
        return;
      }
      this.batchAppendDirectGridDataSourceRows(dataSource, appendRows);
      this.dataSourceItems = dataSource;
      this.scheduleDirectGridLayoutContract();
      this.scheduleSysMedicinePageScrollRestore(position);
    },
    getGridScrollHostEl() {
      return this.getDirectGridRoot()?.querySelector?.(".k-grid-content") || null;
    },
    getGridContentElement() {
      return this.getGridScrollHostEl();
    },
    getGridLockedContentElement() {
      return this.getDirectGridRoot()?.querySelector?.(".k-grid-content-locked") || null;
    },
    getGridHeaderWrapElement() {
      return this.getDirectGridRoot()?.querySelector?.(".k-grid-header-wrap") || null;
    },
    getGridLockedHeaderElement() {
      return this.getDirectGridRoot()?.querySelector?.(".k-grid-header-locked") || null;
    },
    getGridAutoScrollableElement() {
      return this.getGridScrollHostEl();
    },
    getGridHeaderEl() {
      return this.getDirectGridRoot()?.querySelector?.(".k-grid-header") || null;
    },
    getGridTableEl() {
      return this.directGridWidget?.table?.[0] || this.getDirectGridRoot()?.querySelector?.(".k-grid-content table") || null;
    },
    getGridTbodyEl() {
      return this.directGridWidget?.tbody?.[0] || this.getDirectGridRoot()?.querySelector?.(".k-grid-content tbody") || null;
    },
    getGridLockedTableEl() {
      return this.getDirectGridRoot()?.querySelector?.(".k-grid-content-locked table") || null;
    },
    getGridLockedTbodyEl() {
      return this.getDirectGridRoot()?.querySelector?.(".k-grid-content-locked tbody") || null;
    },
    getGridDataSource() {
      return this.directGridWidget?.dataSource || this.dataSourceItems;
    },
    setGridDataSource(dataSource) {
      this.dataSourceItems = dataSource;
      if (this.directGridWidget && this.directGridWidget.dataSource !== dataSource) {
        this.directGridWidget.setDataSource(dataSource);
      }
      this.scheduleDirectGridLayoutContract();
    },
    resizeDirectGrid() {
      if (!this.directGridWidget) {
        return;
      }
      try {
        const height = Math.max(0, Number(this.kendoGridHeight) || 0);
        const root = this.getDirectGridRoot();
        if (root && height) {
          root.style.height = `${height}px`;
          root.style.maxHeight = `${height}px`;
        }
        this.directGridWidget.wrapper?.height?.(height);
        this.directGridWidget.element?.height?.(height);
        if (this.directGridLastHeight !== height) {
          this.directGridLastHeight = height;
          this.directGridWidget.setOptions({ height });
        }
        this.directGridWidget.resize(true);
      } catch (_error) {
        // direct jq では resize 失敗で rebuild しない。
      }
    },
    applyDirectGridColumnsContract() {
      const grid = this.directGridWidget;
      if (!grid || !Array.isArray(this.columns) || this.columns.length <= 1) {
        return;
      }
      const existingFields = (grid.columns || []).map(column => `${column.field}:${column.hidden ? 1 : 0}:${column.locked ? 1 : 0}`).join("|");
      const nextFields = (this.columns || []).map(column => `${column.field}:${column.hidden ? 1 : 0}:${column.locked ? 1 : 0}`).join("|");
      if (existingFields !== nextFields) {
        grid.setOptions({ columns: this.buildDirectGridColumns() });
      } else {
        (grid.columns || []).forEach(gridColumn => {
          const column = this.columns.find(item => item.field === gridColumn.field);
          if (column) {
            gridColumn.editable = column.editable;
            gridColumn.hidden = column.hidden;
          }
        });
      }
    },
    buildDirectGridColumns() {
      return (this.columns || []).map(column => {
        const gridColumn = { ...column };
        if (column.field === "$modalType") {
          gridColumn.attributes = { class: "btn3-kendo-normal" };
          gridColumn.command = { text: "詳細", click: event => this.showMasterEditModal(event) };
          delete gridColumn.values;
        } else if (column.dataType === "number") {
          gridColumn.editor = (container, options) => this.numericEditor(container, options);
        } else if (column.dataType === "date") {
          gridColumn.editor = (container, options) => this.eachModelCalendar(container, options);
        }
        return gridColumn;
      });
    },
    initDirectGridIfReady() {
      const root = this.getDirectGridRoot();
      if (!this.directGridMounted || !root || this.columns.length <= 1 || !this.dataSourceItems) {
        return;
      }
      if (this.directGridWidget) {
        this.applyDirectGridColumnsContract();
        if (this.directGridWidget.dataSource !== this.dataSourceItems) {
          this.setGridDataSource(this.dataSourceItems);
        }
        this.scheduleDirectGridLayoutContract();
        return;
      }
      installComponentJQuery();
      $(root).empty();
      $(root).kendoGrid({
        dataSource: this.dataSourceItems,
        editable: true,
        selectable: true,
        reorderable: false,
        height: this.kendoGridHeight,
        scrollable: true,
        beforeEdit: event => this.modifyEditStart(event),
        edit: event => this.addInputAssist?.(event),
        cellClose: event => this.editEnd(event),
        save: event => this.onDirectGridSave(event),
        dataBound: event => this.onDirectGridDataBound(event),
        columns: this.buildDirectGridColumns()
      });
      this.directGridWidget = markRaw($(root).data("kendoGrid"));
      this.installDirectGridFacade();
      this.scheduleDirectGridLayoutContract();
    },
    destroyDirectGrid() {
      if (this.directGridWidget) {
        try { this.directGridWidget.destroy(); } catch (_error) { /* noop */ }
      }
      const root = this.getDirectGridRoot();
      if (root) {
        $(root).empty();
      }
      this.directGridWidget = null;
    },
    installDirectGridFacade() {
      const root = this.getDirectGridRoot();
      if (!root) {
        return;
      }
      root.kendoWidget = () => this.directGridWidget;
      root.gridWidget = () => this.directGridWidget;
      root.gridRootEl = () => root;
      root.gridContentEl = () => this.getGridScrollHostEl();
      root.gridAutoScrollableEl = () => this.getGridScrollHostEl();
      root.gridLockedContentEl = () => this.getGridLockedContentElement();
    },
    onDirectGridDataBound(event) {
      this.onDataBoundKendoGridVirtual(event);
      this.applyDirectGridStyleContract();
      this.scheduleDirectGridLayoutContract();
    },
    onDirectGridSave(event) {
      this.onSave(event);
    },
    applyDirectGridStyleContract() {
      const root = this.getDirectGridRoot();
      if (!root) {
        return;
      }
      root.classList.add("ntss-kendo-grid-legacy", "k-widget", "k-grid", "k-editable", "k-display-block");
      root.querySelectorAll("th").forEach(th => th.classList.add("k-header"));
      root.querySelectorAll("tbody tr").forEach((tr, index) => {
        tr.classList.add("k-master-row");
        if (index % 2 === 1) {
          tr.classList.add("k-alt");
        }
      });
      root.querySelectorAll("tbody td").forEach(td => td.classList.add("k-td", "k-table-td"));
      this.applyDirectGridLockedWidthContract();
      this.applyDirectGridLockedHeightContract();
      this.syncDirectGridLockedScrollPosition();
    },
    applyDirectGridLockedWidthContract() {
      const root = this.getDirectGridRoot();
      if (!root) {
        return;
      }
      const width = (this.columns || []).reduce((sum, column) => {
        if (!column.locked || column.hidden) {
          return sum;
        }
        const value = `${column.width || ""}`.trim();
        if (value.endsWith("em")) {
          const fontSize = parseFloat(getComputedStyle(root).fontSize || "16") || 16;
          return sum + parseFloat(value) * fontSize;
        }
        if (value.endsWith("px")) {
          return sum + parseFloat(value);
        }
        const n = parseFloat(value);
        return sum + (Number.isFinite(n) ? n : 0);
      }, 0);
      if (!width) {
        return;
      }
      const px = `${Math.ceil(width)}px`;
      root.querySelectorAll(".k-grid-header-locked,.k-grid-content-locked,.k-grid-header-locked table,.k-grid-content-locked table").forEach(el => {
        el.style.width = px;
        el.style.minWidth = px;
      });
    },
    applyDirectGridLockedHeightContract() {
      const content = this.getGridScrollHostEl();
      const locked = this.getGridLockedContentElement();
      if (content && locked) {
        const height = !this.androidFlg && !this.iosFlg ? content.offsetHeight - 17 : content.clientHeight;
        locked.style.height = `${Math.max(0, height)}px`;
        locked.style.maxHeight = `${Math.max(0, height)}px`;
      }
    },
    syncDirectGridLockedScrollPosition(scrollTop = null) {
      const locked = this.getGridLockedContentElement();
      const content = this.getGridScrollHostEl();
      if (locked) {
        locked.scrollTop = scrollTop !== null && scrollTop !== undefined ? scrollTop : (content?.scrollTop || 0);
      }
    },
    scheduleDirectGridLayoutContract(position = null) {
      const restorePosition = this.sysMedicinePageScrollRestorePending
        ? { ...this.sysMedicinePageScrollRestorePosition }
        : position
          || (this.__preserveScrollOnReload ? this.__reloadScrollPosition : null)
          || { ...this.scrollPosition };
      if (restorePosition.top > 0 || restorePosition.left > 0) {
        this.rememberGridScrollPosition(restorePosition);
      }
      if (this.directGridLayoutRafId != null) {
        cancelAnimationFrame(this.directGridLayoutRafId);
      }
      const shouldRestore = this.sysMedicinePageScrollRestorePending
        || this.__preserveScrollOnReload
        || restorePosition.top > 0
        || restorePosition.left > 0;
      this.directGridLayoutRafId = requestAnimationFrame(() => {
        this.resizeDirectGrid();
        this.applyDirectGridStyleContract();
        this._calculateGridWidth();
        this.bindGridScrollSync();
        if (shouldRestore) {
          this.restoreGridScrollPosition(restorePosition);
        }
        this.directGridLayoutRafId = requestAnimationFrame(() => {
          this.directGridLayoutRafId = null;
          if (shouldRestore) {
            this.restoreGridScrollPosition(restorePosition);
          }
        });
      });
    },
    scheduleDirectGridFilterRefresh() {
      if (this.directGridFilterRefreshRafId != null) {
        cancelAnimationFrame(this.directGridFilterRefreshRafId);
      }
      this.directGridFilterRefreshRafId = requestAnimationFrame(() => {
        this.directGridFilterRefreshRafId = null;
        this.dataSourceItems = this.generatedGridData();
        this.setGridDataSource(this.dataSourceItems);
      });
    },
    ...mapActions("multi-modal", ["showMasterEdit"]),
    ...mapActions("master-maintenance", [
      "findRecordList",
      "findColumnInfo",
      "setMasterRecordList",
      "edit",
      "setCondition",
      "updateRecordList",
      "updateRecordListByFacilityCd",
      "setEditRecord",
      "editRecordBeEmpty",
      "setComparisonRecordModel",
      "findRecordListByFacilityCd",
      "updateIndCondInfo",
      "setColumns"
    ]),
    ...mapActions("master-maintenance", {
      facilityList: "facilityList"
    }),
    ...mapActions("loading-screen", {
      setLoadingScreenVisible: "setLoadingScreenVisible"
    }),
    ...mapMutations("master-maintenance", [
      "bumpMasterRecordListRevision",
    ]),
    cancel() {
      this.$router?.go?.(-1);
    },
    getColumnIndex(fieldName) {
      return this.columns.findIndex(column => column.field === fieldName);
    },
    calculateColumnsWidth() {
      if (this.masterPhysicalName === "sys_medicine") {
        this.columnWidth = 19;
        return;
      }
      const ownerWindow = this.$el?.ownerDocument?.defaultView || window;
      const appRoot = this.$el?.ownerDocument?.getElementById?.("app") || document.getElementById("app");
      const appWidth = appRoot ? parseFloat(ownerWindow.getComputedStyle(appRoot).width || 0) : ownerWindow.innerWidth;
      this.columnWidth = appWidth > 1000 ? 14 : 10;
    },
    calculateGridHeight() {
      if (this.editingFlg) {
        return;
      }
      const ownerDocument = this.$el?.ownerDocument || document;
      const ownerWindow = ownerDocument.defaultView || window;
      const headers = Array.from(ownerDocument.getElementsByClassName("header") || []);
      const header = headers.length ? headers[headers.length - 1] : null;
      const footerMenu = ownerDocument.getElementById("footer-menu");
      const ntssList = this.$el?.querySelector?.(".ntss-list");
      const headerHeight = header?.clientHeight || 0;
      const footerHeight = (this.isDispMenu === 1 && footerMenu ? footerMenu.clientHeight : 0) + 5;
      const windowHeight = Number(this.windowHeight) || ownerWindow.innerHeight || 0;
      let toolbarHeight = windowHeight - headerHeight - footerHeight;
      const listTop = ntssList?.getBoundingClientRect?.().top;
      const footerTop = this.isDispMenu === 1
        ? footerMenu?.getBoundingClientRect?.().top
        : ownerWindow.innerHeight;
      const actualVisibleHeight = (Number.isFinite(listTop) && Number.isFinite(footerTop))
        ? footerTop - listTop - 2
        : NaN;
      if (Number.isFinite(actualVisibleHeight) && actualVisibleHeight > 100) {
        toolbarHeight = Math.min(toolbarHeight, actualVisibleHeight);
      }
      this.kendoGridToolbarHeight = Math.max(100, toolbarHeight);
      const headerButton = this.getHeaderButtonAreaElement();
      const gridFooter = this.$el?.querySelector?.("#grid-footer") || ownerDocument.getElementById("grid-footer");
      const headerButtonHeight = headerButton?.clientHeight || 0;
      const gridFooterHeight = gridFooter?.clientHeight || 0;
      const verticalReserve = this.androidFlg || this.iosFlg ? 4 : 18;
      this.kendoGridHeight = Math.max(160, this.kendoGridToolbarHeight - headerButtonHeight - gridFooterHeight - verticalReserve);
      const root = this.getDirectGridRoot?.();
      if (root) {
        root.style.height = `${this.kendoGridHeight}px`;
        root.style.maxHeight = `${this.kendoGridHeight}px`;
      }
    },
    calculateGridWidth() {
      this.resizeDirectGrid();
      this.applyDirectGridStyleContract();
      this._calculateGridWidth();
      this.bindGridScrollSync();
    },
    getMaxSortRank() {
      const data = this.getFilteredMasterRecordList?.data || this.getMasterRecordList?.data || [];
      return data.length > 0 ? data.reduce((a, b) => Math.max(a, +b.sortRank || 0), 0) : 0;
    },
    editableColumns() {
      this.columns.forEach(column => {
        column.editable = column.field === "sortRank"
          ? () => false
          : column.originalEditable
            ? () => true
            : () => false;
      });
      this.applyDirectGridColumnsContract();
    },
    disableColumns() {
      this.columns.forEach(column => {
        column.editable = column.field === "sortRank"
          ? this.isAllowSort ? () => true : () => false
          : () => false;
      });
      this.applyDirectGridColumnsContract();
    },
    showSortColumn() {
      const sortRankIndex = this.columns.findIndex(column => column.field === "sortRank");
      if (sortRankIndex >= 0) {
        this.columns[sortRankIndex].hidden = !(this.isAllowSort && this.isSortMode);
        const dummyIndex = this.columns.findIndex(column => column.field === "dummy");
        if (dummyIndex >= 0) {
          this.columns[dummyIndex].hidden = !this.columns[sortRankIndex].hidden;
        }
      }
      this.applyDirectGridColumnsContract();
      this.scheduleDirectGridLayoutContract();
    },
    sort() {
      const compare = (a, b) => a.sortRank - b.sortRank || a.sortInputTime - b.sortInputTime;
      this.getMasterRecordList.data.sort(compare);
      for (let i = 0; i < this.getMasterRecordList.data.length; i++) {
        if (this.getMasterRecordList.data[i].isDisp === "1") {
          this.getMasterRecordList.data[i].sortRank = i + 1;
        }
      }
    },
    sortChange(tempData) {
      return this.getMasterRecordList.data.some(item => tempData.some(tempItem => item.code === tempItem.code && item.sortRank !== tempItem.sortRank));
    },
    normalization(items) {
      const source = typeof items?.toJSON === "function" ? items.toJSON() : items || {};
      const columnNames = (this.columnDefinition || this.columns || []).map(column => column.field);
      return Object.keys(source)
        .filter(key => columnNames.includes(key) || key === "isAddRow")
        .reduce((acc, key) => {
          acc[key] = source[key];
          return acc;
        }, {});
    },
    getMasterAlertDialogs() {
      return Array.from((this.$el?.ownerDocument || document).getElementsByTagName("ons-alert-dialog"));
    },
    getisChanged() {
      const data = this.getMasterRecordList?.data;
      if (this.getStateUserAccountInfo === null || data === undefined) {
        return false;
      }
      void this.masterRecordListRevision;
      if (!this.validateBeforeGridAction()) {
        return true;
      }
      return this.isSorted || data.some(row => this.isSysMedicineRowEdited(row));
    },
    onCloseMasterEditModal() {
      this.$nextTick(() => this.setGridScrollPosition(this.scrollPosition));
      setTimeout(() => this.setGridScrollPosition(this.scrollPosition), 1000);
    },
    convertToStr(messageArr) {
      if (!messageArr || messageArr.length === 0) {
        return "";
      }
      const unique = messageArr.reduce((acc, cur) => {
        if (acc.indexOf(cur) === -1) {
          acc.push(cur);
        }
        return acc;
      }, []);
      const prefix = "</br>&nbsp&nbsp・";
      return prefix + unique.join(prefix);
    },
    validateRequired() {
      const validateMessageArr = [];
      const rows = (this.getMasterRecordList?.data || []).filter(row => row.isDisp !== "0");
      const fields = this.getMasterRecordList?.schema?.model?.fields || {};
      rows.forEach(row => {
        Object.keys(fields).forEach(key => {
          const validation = fields[key]?.validation;
          if (validation?.required && row[key] !== null && row[key] === "") {
            const columnInfo = this.columns.find(column => column.field === key);
            if (columnInfo?.title) {
              validateMessageArr.push(columnInfo.title);
            }
          }
        });
      });
      return this.convertToStr(validateMessageArr);
    },
    // validateComboValue() {
    //   const comboFields = this.columns
    //     .filter(column => column.values != null)
    //     .map(column => ({ field: column.field, title: column.title, values: column.values }));
    //     console.log('comboFields',comboFields);
        
    //   const rows = (this.getMasterRecordList?.data || []).filter(row => row.isDisp !== "0" && row.isDel !== "1");
    //   console.log('rows',rows);
      
    //   const validateMessageArr = [];
    //   rows.forEach(row => {
    //     comboFields.forEach(combo => {
    //       const columnValue = row[combo.field];
    //       const isEmpty = columnValue === null || columnValue === undefined || columnValue === "" || columnValue === "null";
    //       if (isEmpty) {
    //         return;
    //       }
    //       const exists = (combo.values || []).some(value => String(value?.value) === String(columnValue));
    //       if (!exists) {
    //         validateMessageArr.push(combo.title);
    //       }
    //     });
    //   });
    //   return this.convertToStr(validateMessageArr);
    // },
    editStart(e) {
      if (this.androidFlg) {
        this.editingFlg = true;
      }
      this.$nextTick(() => {
        if (e?.sender?.editable?.options?.fields?.field === "isDisp") {
          const element = this.getGridScrollHostEl();
          if (element) {
            element.scrollLeft = element.scrollWidth - element.clientWidth;
          }
        }
        const root = this.getDirectGridRoot();
        root?.querySelectorAll?.(".k-textbox,.k-input,.k-dropdown,.k-link").forEach(element => element.setAttribute("title", ""));
      });
    },
    editEnd() {
      this.editingFlg = false;
    },
    addInputAssist() {
      // Vue2 wrapper の edit イベント時点を残すためのページローカル no-op。
    },
    onSave(ev) {
      const position = this.getGridScrollPosition();
      this.rememberGridScrollPosition(position);
      this.editFlg = true;
      this.editingFlg = false;
      if (ev?.values && ev?.model) {
        Object.keys(ev.values).forEach(field => {
          if (typeof ev.model.set === "function") {
            ev.model.set(field, ev.values[field]);
          } else {
            ev.model[field] = ev.values[field];
          }
        });
      }
      if (ev?.model) {
        this.edit({ editRecord: ev.model, isSortMode: this.isSortMode });
        if (ev.model.operation === 1) {
          ev.model.edited = true;
        }
        this.clearSysMedicineRowIfMatchesOriginal(ev.model);
        const revertedToOriginal = !this.isSysMedicineRowEdited(ev.model);
        this.scheduleDirectGridRowVisualState(ev.model, ev.model.uid, revertedToOriginal);
      }
      this.setGridScrollPosition(position);
    },
    isDeleteRow(currentTrc) {
      const isDispIndex = this.getColumnIndex("isDisp");
      return isDispIndex >= 0 && currentTrc?.[isDispIndex]?.textContent === "削除";
    },
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
    changeSortColorByRow(row) {
      const sortCell = this.getDirectSortColorCellByField(row, "sortRank");
      if (!sortCell || !this.isEditRow(sortCell)) {
        return false;
      }
      sortCell.classList.add("master-sort-edited");
      const dummyCell = this.getDirectSortColorCellByField(row, "dummy");
      dummyCell?.classList?.add("master-sort-edited");
      return true;
    },
    changeSortColor(currentTrc, currentLockTrc = null) {
      [currentTrc, currentLockTrc].forEach(cells => {
        this.changeSortColorByRow(this.getDirectSortColorRowFromCells(cells));
      });
    },
    changeEditColor(currentTrc, currentLockTrc) {
      let edited = false;
      [...Array.from(currentTrc || []), ...Array.from(currentLockTrc || [])].forEach(cell => {
        if (cell.classList.contains("k-dirty-cell")) {
          cell.classList.add("master-edited-cell");
          edited = true;
        }
      });
      return edited;
    },
    changeRowColor(currentTrc, currentLockTrc, edited, deleted) {
      const addClass = deleted ? "master-deleted-row" : "master-edited-row";
      const cells = [...Array.from(currentTrc || []), ...Array.from(currentLockTrc || [])];
      cells.forEach(cell => {
        if (edited || deleted) {
          cell.classList.add(addClass);
        } else {
          cell.classList.remove("master-deleted-row", "master-edited-row", "master-edited-cell", "k-dirty-cell");
        }
      });
    },
    changeRefErrorComboColor() {
      // 標準医薬品マスタでは data source 参照エラー色は direct jq current row visual に委譲する。
    },
    getSysMedicineOwnerDocument() {
      return getScopedDocument(this.$el || null);
    },
    getSysMedicineScopeRoot() {
      return this.$el?.closest?.('[data-ntss-layout-root], .main-content-area, #app')
        || this.$el
        || this.getSysMedicineOwnerDocument();
    },
    getRecordNameInputElement() {
      return this.queryMaster?.("#recordName")
        || this.$el?.querySelector?.("#recordName")
        || this.getSysMedicineScopeRoot()?.querySelector?.("#recordName")
        || this.getSysMedicineOwnerDocument()?.getElementById?.("recordName")
        || null;
    },
    getHeaderButtonAreaElement() {
      return this.getMasterLayoutElements?.()?.elements?.headerButtonArea
        || this.$el?.querySelector?.(".header-btn-area")
        || this.getSysMedicineScopeRoot()?.querySelector?.(".header-btn-area")
        || null;
    },
    getCalendarEditorElements(container) {
      const editorRoot = container?.[0] || container?.get?.(0) || container || null;
      const searchRoot = editorRoot || this.getSysMedicineScopeRoot();
      const getEditorElement = (selector) => queryElementBySelectors([selector], searchRoot);
      return {
        editorRoot,
        displayedDummyEditor: getEditorElement("#displayedDummyEditor"),
        hiddenDateInputEditor: getEditorElement("#hiddenDateInputEditor")
      };
    },
    // add 鞠 start カレンダー機能の追加
    eachModelCalendar(container, data) {
      if (this.androidFlg === true) {
        // Androidの場合は、HTML5のカレンダーを表示
        $(`<input type="date" name="${data.field}" />`).appendTo(container);
      } else {
        let moveOutFlg = false;
        container.mouseenter(() => moveOutFlg = false);
        container.mouseleave(() => moveOutFlg = true);
        // デスクトップ、iOSの場合は、処理で補正したHTML5のカレンダーを表示
        let nowData;
        let hasInitValue = true;
        const editedData = data.model[data.field];
        let nowDtatString;
        if (editedData) {
          nowData = new Date(editedData);
        } else {
          nowData = new Date();
          hasInitValue = false;
        }
        nowDtatString = nowData.getFullYear() + "-" + ('0' + (nowData.getMonth() + 1)).slice(-2) + "-" + ('0' + nowData.getDate()).slice(-2);
        $(
          `<input type="date" id="displayedDummyEditor" class="ntss-input-date" min="1880-01-01" max="2099-12-31" value="${nowDtatString}"/><input type="date" id="hiddenDateInputEditor" name="${data.field}" style="display: none;"/>`).appendTo(container);
        const { editorRoot, displayedDummyEditor, hiddenDateInputEditor } = this.getCalendarEditorElements(container);
        // フォーカスアウトで編集データを反映するイベントを発火
        displayedDummyEditor?.addEventListener("blur", function(ev) {
          if (!moveOutFlg) {
            return;
          }

          let resultData;
          const dayData = new Date(ev.target.value);
          // 初期と編集後の値が空欄の場合、更新レコードとして判断しない
          if (ev.target.value === "" && !hasInitValue) {
            resultData = "";
            nowDtatString = "";
            hasInitValue = true;
          } else {
            resultData = dayData.getFullYear() + "-" + ('0' + (dayData.getMonth() + 1)).slice(-2) + "-" + ('0' + dayData.getDate()).slice(-2);
          }

          // 変更前の値と比較し、同じ値の場合は処理しない。又は、初期値がない場合、必ず処理する。
          if ((!hasInitValue || nowDtatString != resultData) && hiddenDateInputEditor) {
            hiddenDateInputEditor.value = resultData;
            // name="${data.field}" で割り当てた箇所に付与されているchangeメソッドを発火します。次いで@saveの処理が発生します。
            $(hiddenDateInputEditor).trigger('change');
          }
        });

        const editorDocument = editorRoot?.ownerDocument || this.getSysMedicineOwnerDocument();
        const commonCalenderMountNode = editorDocument.createElement("span");
        container.append(commonCalenderMountNode);
        const commonCalenderApp = createApp(commonCalender, {
          onInput: value => {
            if (hiddenDateInputEditor) {
              hiddenDateInputEditor.value = value;
              // name="${data.field}" で割り当てた箇所に付与されているchangeメソッドを発火します。次いで@saveの処理が発生します。
              $(hiddenDateInputEditor).trigger('change');
            }
          }
        });
        let commonCalenderPicker = commonCalenderApp.mount(commonCalenderMountNode);
        commonCalenderPicker.setSilently(nowDtatString);

        displayedDummyEditor?.addEventListener("change", (ev) => {
          commonCalenderPicker.setSilently(ev.target.value);
        });
      }
    },
    // add 鞠 end カレンダーの追加
    setScrollPosition(position) {
      this.restoreGridScrollPosition(position);
      this.applyDirectGridStyleContract();
    },
    showMasterEditModal(e) {
      // モーダル確定時にスクロール位置が戻ってしまう問題の対処
      const gridScrollPosition = this.readGridScrollPosition();
      this.scrollPosition.top = gridScrollPosition.top;
      this.scrollPosition.left = gridScrollPosition.left;

      // モーダルを表示
      this.showMasterEdit();

      /**
       * 「詳細」ボタンを押下したレコードのデータを取得する。
       * see: https://www.telerik.com/forums/selected-row-at-wrappers-for-vue
       */
      e.preventDefault();
      const row = this.getGridWidget();
      let selectedRowItem = row?.dataItem?.(e.currentTarget.closest("tr"));
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
    unbindGridScrollSync() {
      this.gridScrollSyncCleanup?.forEach?.(cleanup => {
        try {
          cleanup();
        } catch (_error) {
          // noop
        }
      });
      this.gridScrollSyncCleanup = [];
      this.gridScrollSyncBound = false;
    },
    bindGridScrollSync() {
      const lockedContent = this.getGridLockedContentElement();
      const scrollableContent = this.getGridScrollHostEl();
      if (!lockedContent || !scrollableContent) {
        return;
      }
      this.unbindGridScrollSync();
      lockedContent.removeEventListener("scroll", this.syncScrollFromLocked);
      scrollableContent.removeEventListener("scroll", this.syncScrollFromScrollable);
      lockedContent.addEventListener("scroll", this.syncScrollFromLocked);
      scrollableContent.addEventListener("scroll", this.syncScrollFromScrollable);
      this.gridScrollSyncCleanup = [
        () => lockedContent.removeEventListener("scroll", this.syncScrollFromLocked),
        () => scrollableContent.removeEventListener("scroll", this.syncScrollFromScrollable)
      ];
      this.gridScrollSyncBound = true;
    },
    onDataBoundKendoGridVirtual() {
      const pendingAddRowScroll = this.__pendingScrollToBottom;
      if (pendingAddRowScroll) {
        this.__pendingScrollToBottom = false;
      }
      const position = this.sysMedicinePageScrollRestorePending
        ? { ...this.sysMedicinePageScrollRestorePosition }
        : { ...this.scrollPosition };
      this.$nextTick(() => {
        this.calculateGridHeight();
        this.applyDirectGridStyleContract();
        this._calculateGridWidth();
        this.bindGridScrollSync();
        this.refreshDirectGridVisualState();
        if (pendingAddRowScroll) {
          this.scheduleDirectGridAddRowScroll();
        } else if (!this.sysMedicinePageScrollRestorePending) {
          this.restoreGridScrollPosition(position);
        }
      });
    },
    syncScrollFromLocked(e) {
      const scrollableContent = this.getGridScrollHostEl();
      const nextTop = e.target?.scrollTop || 0;
      this.rememberGridScrollPosition({
        top: nextTop,
        left: scrollableContent?.scrollLeft || this.lastInputScrollLeft
      });
      if (scrollableContent && Math.abs((scrollableContent.scrollTop || 0) - nextTop) > 1) {
        this.runWithDirectGridProgrammaticScroll(() => {
          scrollableContent.scrollTop = nextTop;
        });
      }
      if (!this.isDirectGridProgrammaticScrolling()) {
        this.scrollRight();
      }
    },
    syncScrollFromScrollable(e) {
      const lockedContent = this.getGridLockedContentElement();
      const nextTop = e.target?.scrollTop || 0;
      this.rememberGridScrollPosition({ top: nextTop, left: e.target?.scrollLeft || 0 });
      if (lockedContent && Math.abs((lockedContent.scrollTop || 0) - nextTop) > 1) {
        this.runWithDirectGridProgrammaticScroll(() => {
          lockedContent.scrollTop = nextTop;
        });
      }
    },
    prehideCsvPopover() {
      this.masterCsvVisible = false;
      this.refreshDirectGridVisualState();
    },
    onSearch(){
      this.resetSysMedicineRowEditBaseline();
      this.dataSourceItems = this.generatedGridData();
      this.setGridDataSource(this.dataSourceItems);
      this.$nextTick(() => {
        this.refreshDirectGridVisualState();
      });
    },
    _calculateGridWidth() {
      // 描画後に実行
      const lockedContent = this.getGridLockedContentElement();
      const scrollableContent = this.getGridAutoScrollableElement();
      const headerWrap = this.getGridHeaderWrapElement();
      const lockedHeader = this.getGridLockedHeaderElement();
      const gridRoot = this.getGridRootElement();
      if (lockedContent && scrollableContent && headerWrap && lockedHeader && gridRoot) {
        // 固定列数のカウント
        const lockedColumns = this.columns
          .filter(col => col.locked === true && col.hidden === false).length;

        // 固定列幅算出
        // ソートモード以外では -1 する(ダミー列)
        const sortColumn = this.isSortMode ? 0 : 1;
        let lockedColumnWidth = (lockedColumns - sortColumn) * this.columnWidth;
        if (this.lockedColumnsWidth) {
          lockedColumnWidth = this.lockedColumnsWidth;
        }
        // リサイズする前のscroll値を取得する
        let tmpScrollLeft = 0;
        let tmpScrollTop = 0;
        if (this.sysMedicinePageScrollRestorePending) {
          tmpScrollLeft = this.sysMedicinePageScrollRestorePosition.left;
          tmpScrollTop = this.sysMedicinePageScrollRestorePosition.top;
        } else if (this.__preserveScrollOnReload) {
          tmpScrollLeft = this.lastInputScrollLeft;
          tmpScrollTop = this.lastScrollTop;
        } else if (this.editFlg) {
          tmpScrollLeft = this.lastInputScrollLeft;
          tmpScrollTop = this.lastScrollTop -40;
          this.editFlg = false;
        } else {
          tmpScrollLeft = scrollableContent.firstChild?.scrollLeft ?? scrollableContent.scrollLeft ?? 0;
          tmpScrollTop = Math.max(
            lockedContent?.scrollTop || 0,
            scrollableContent.scrollTop || 0
          );
        }

        // スマートフォン以外で固定行有：空白行幅の調整値
        const targetWidth = ((this.androidFlg || this.iosFlg) || lockedColumnWidth == 0) ? 0 : 14;
        // kendoGridのリサイズを呼び出して自動リサイズがされないケースがある問題に対応
        const firstVisibleColumn = this.directGridWidget?.columns?.find?.(column => !column.hidden);
        if (firstVisibleColumn) {
          const setWidth = parseInt(firstVisibleColumn.width, 10);
          if (Number.isFinite(setWidth)) {
            this.directGridWidget?.resizeColumn?.(firstVisibleColumn, setWidth);
          }
        }
        // 固定列の幅確保
        lockedHeader.style.width = `calc(${lockedColumnWidth}em + 10px)`;
        lockedContent.style.width = `calc(${lockedColumnWidth}em + 10px)`;

        // 画面幅よりも固定列の幅が大きくなった場合、可変列のヘッダが見切れるため
        // グリッドサイズを画面幅以上に拡張する
        if (gridRoot.clientWidth < lockedHeader.clientWidth) {
          // グリッドサイズ拡張
          gridRoot.style.width = (lockedHeader.clientWidth + 100 + targetWidth) + 'px';
          // 拡張分の幅で可変列のヘッダ幅定義
          headerWrap.style.width = (100 + targetWidth) + 'px';
        } else {
          gridRoot.style.width = 'auto';
          const headerLockWidth = (gridRoot.clientWidth - lockedHeader.clientWidth) - 10;
          const contentScrollableWidth = (gridRoot.clientWidth - lockedContent.clientWidth) - 10;
          // 固定列の幅を確保
          headerWrap.style.width = headerLockWidth + 'px';
          scrollableContent.style.width = contentScrollableWidth  + 'px';

          // 縦スクロールの幅を確保
          if (headerLockWidth === contentScrollableWidth && lockedColumnWidth) {
            scrollableContent.style.width = (contentScrollableWidth - 18) + 'px';
          }
        }

        if (scrollableContent
          && lockedContent.clientHeight !== scrollableContent.clientHeight
          && !this.androidFlg && !this.iosFlg) {
          lockedContent.style.height = scrollableContent.offsetHeight - 17 + 'px';
        }
        // mod #8745 【デグレ】マスタにて追加をし行が増えると縦横のスクロールが発生する。テキストボックスが切れる。 林峻峰 start
        getMainContentAreaElement(this.$el || document).style.overflowY = 'hidden'
        getMainContentAreaElement(this.$el || document).style.overflowX = 'hidden'
        const headerButtonAreaElement = this.getHeaderButtonAreaElement();
        if (headerButtonAreaElement?.clientWidth) {
          gridRoot.style.width = `${headerButtonAreaElement.clientWidth - 18}px`;
        }
        // mod #8745 【デグレ】マスタにて追加をし行が増えると縦横のスクロールが発生する。テキストボックスが切れる。 林峻峰 end

        // 固定列の幅確保後、リサイズする前のscroll値を設定
        setTimeout(() => {
          if (this.sysMedicinePageScrollRestorePending) {
            this.restoreSysMedicinePageScrollPosition(this.sysMedicinePageScrollRestorePosition);
            return;
          }
          this.restoreGridScrollPosition({ left: tmpScrollLeft, top: tmpScrollTop });
        });
      }
    },
    sortBtnClick() {
      // モーダル確定時にスクロール位置が戻ってしまう問題の対処
      const gridScrollPosition = this.readGridScrollPosition();
      this.scrollPosition.top = gridScrollPosition.top;
      this.scrollPosition.left = gridScrollPosition.left;
      EventBus.$emit("onCloseMasterEditModal", this.onCloseMasterEditModal);

      const tempData = deepCopy(this.getMasterRecordList.data);
      this.isSortMode = false;
      this.editableColumns();
      this.showSortColumn();
      this.sort();
      this.isSorted = this.sortChange(tempData);
      this.dataSourceItems = this.generatedGridData();
      this.setGridDataSource(this.dataSourceItems);
      EventBus.$emit("setSortMode", this.isSortMode);
      this.$nextTick(() => {
        // this.editBackgroundColor()
        this.calculateGridWidth();
      });
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
        const tbodyc = (this.getGridTbodyEl()?.children || []);
        const gridData = this.getGridDataSource();
        let lockTbodyc = null;
        if(this.getGridLockedTableEl()?.tBodies != undefined){
          lockTbodyc = (this.getGridLockedTbodyEl()?.children || []);

          // 列の行数は固定・可変で同一なため可変列の行数を使用
          for (let rwCount = 0; rwCount < tbodyc.length; rwCount++) {
            const currentTrc = tbodyc[rwCount].children;
            const currentLockTrc = lockTbodyc[rwCount].children;

            // 並び順の色変更
            this.changeSortColor(currentLockTrc);
            // 編集項目の色を変更
            let edited = this.changeEditColor(currentTrc, currentLockTrc);
            // 削除対象を判定
            const deleted = this.isDeleteRow(currentTrc);

            // モーダルからの編集も色を変更する
            if (
              this.isEdited(gridData._view[rwCount].code)
            ) {
              edited = true;
            }
            // 並び順以外の項目が変更されていた場合は、削除か修正にあわせて並び順より後の項目の背景色を変更
            this.changeRowColor(currentTrc, currentLockTrc, edited, deleted);
            // データ参照エラーコンボの背景色を変更
            this.changeRefErrorComboColor(currentTrc, deleted, currentLockTrc);
          }
        }
      });
    },
    gridDataRefresh() {
      this.setGridDataSource(this.generatedGridData());
    },
    generatedGridData() {
      let that = this;

      // const columnObject = {};
      // that.columns.forEach(column => {
      //   let name = column.field;
      //   if ("dummy" !== name) {
      //     columnObject[name] = {};
      //   } else {
      //     columnObject[name] = column;
      //   }
      // })
      return markRaw(new kendo.data.DataSource({
        pageSize: 300000,
        // mod 5515 標準医薬品マスタ検索で検索できない 周安寧 start
         data : that.masterRecords.data,
         schema: that.masterRecords.schema
        // mod 5515 標準医薬品マスタ検索で検索できない 周安寧 end
      }))
    },
    numericEditor(container, options) {
      const format = options.format.slice(3, options.format.length - 1);
      const decimals = format.slice(1);

      let parameter = { format, decimals, round: false };
      let  strinput= '<input data-bind="value:' + options.field + '"/> ';
      const masterField = this.getMasterRecordList.schema.model.fields[options.field];
      if (this.masterPhysicalName == "sys_medicine"){
        if(masterField.validation.maxlength) {
            let maxlength = masterField.validation.maxlength;
            masterField.validation.max = Math.pow(10,maxlength-decimals) - Math.pow(10,-decimals);
            masterField.validation.min = (Math.pow(10,maxlength-decimals) - Math.pow(10,-decimals)) *-1;
        }
        parameter = { format, decimals, round: false, min: masterField.validation.min, max: masterField.validation.max, step :Math.pow(10,-decimals),};
      }
      $(strinput).appendTo(container).kendoNumericTextBox(parameter);
    },
    loadGridData() {
      // modify #9590 start
      // this.setCondition(this.condition);
      // EventBus.$emit("clearHeaderSearch");
      if (this.conditions.recordName) {
        EventBus.$emit("handleSearch");
      } else {
        this.findList();
      }
      // modify #9590 end
    },
    refresh() {
      // 他の画面に遷移したときもrefresh()が発生する為、自分の画面のみ処理する
      if (this.selfScreenName === this.$route.name
        && this.getMasterAlertDialogs?.().length === 0) {
        if (this.getisChanged()) {
          this.$ons.notification.confirm({
            // title: "内容破棄",
            title: DIALOG_MESSAGES[13000004].title,
            // message: "編集内容が破棄されます。</br>よろしいですか？",
            message: messageFormat(DIALOG_MESSAGES[13000004].message),
            callback: answer => {
              if (answer === 1) {
                //スクロールバーの位置をクリア
                this.lastScrollTop = 0;
                this.lastInputScrollLeft = 0;
                this.findList();
              }
            },
          });
        }
        else {
          //スクロールバーの位置をクリア
          this.lastScrollTop = 0;
          this.lastInputScrollLeft = 0;
          this.findList();
        }
      }
    },
    findList() {
      // apiをコールして値を取得
      this.findRecordListByFacilityCd(this.getFacilitySwitch)
        .then(response => {
          // カラム情報のJSONが未定義の場合には、ダイアログを出して画面を閉じる
          if (response.data.columns.length === 0) {
            this.$ons.notification.alert({
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // title: "取得失敗",
              title: DIALOG_MESSAGES[12000001].title,
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
              message:
                DIALOG_MESSAGES[12000001].message,
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
            locked: true,
            editable: () => false,
            width: "10px",
            format: "",
            values: null
          });
          // カラム幅等初期調整
          this.showSortColumn();
          const reloadScrollPosition = this.__preserveScrollOnReload
            ? this.normalizeGridScrollPosition(this.__reloadScrollPosition)
            : this.normalizeGridScrollPosition({
              top: this.lastScrollTop,
              left: this.lastInputScrollLeft
            });
          const shouldRestoreScroll = this.__preserveScrollOnReload
            || reloadScrollPosition.top > 0
            || reloadScrollPosition.left > 0;
          this.$nextTick(() => {
            this.calculateGridHeight();
            this.calculateGridWidth();
          });
          // 初期データ内容を保存
          this.resetSysMedicineRowEditBaseline();
          this.dataSourceItems = this.generatedGridData();
          this.$nextTick(() => {
            this.initDirectGridIfReady();
            if (shouldRestoreScroll) {
              this.sysMedicinePageScrollRestorePending = true;
              this.sysMedicinePageScrollRestorePosition = reloadScrollPosition;
              this.rememberGridScrollPosition(reloadScrollPosition);
            }
            this.setGridDataSource(this.dataSourceItems);
            this.scheduleDirectGridLayoutContract();
            if (shouldRestoreScroll) {
              this.scheduleSysMedicinePageScrollRestore(reloadScrollPosition);
            } else if (!this.__preserveScrollOnReload) {
              this.lastScrollTop = 0;
              this.lastInputScrollLeft = 0;
            }
          });
        })
        .catch(error => {
          if (error.response.status === 400) {
            this.$ons.notification.alert({
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // title: "取得失敗",
              title: DIALOG_MESSAGES[12000003].title,
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
              message:
                DIALOG_MESSAGES[12000003].message
            });
          }
        })
      // カラム定義情報を取得
      this.findColumnInfo();
    },
    addRow() {
      // グリッドでエラーが発生している場合は処理を中断
      if (!this.validateBeforeGridAction()) {
        return;
      }
      this.addRowScrollFlag = true;
      this.scrollPosition.left = 0;
      this.lastInputScrollLeft = 0;
      this.__pendingScrollToBottom = true;
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
        d["isAddRow"] = true;
        // 初期時、新しいレコードに全レコードの並び順の最大値をセット
        if (k === "sortRank") {
          d[k] = this.getMaxSortRank() + 1;
        }
      });
      this.edit({editRecord: d, isSortMode: this.isSortMode});
      this.dataSourceItems = this.generatedGridData();
      this.setGridDataSource(this.dataSourceItems);
      this.$nextTick(() => {
        this.applyDirectGridStyleContract();
        this.scheduleDirectGridAddRowScroll();
        this.scheduleDirectGridRowVisualState(d);
      });
    },
    async saveRecord() {
      // 共通ローダー:表示開始
      this.setLoadingScreenVisible(true);
      this.captureReloadScrollPosition();
      // グリッドでエラーが発生している場合は処理を中断
      if (!this.validateBeforeGridAction()) {
        // 共通ローダー：表示終了
        this.setLoadingScreenVisible(false);
        return;
      }

      // 新規追加＆未入力のレコードを除外
      const records = this.getMasterRecordList;
      let isSysMedicine = false;
      if (this.masterPhysicalName == "sys_medicine") isSysMedicine = true;
      records.data = records.data.filter(
        r => !(r.operation === 1 && (!r.edited || !(r.isAddRow && (r.isDisp == '1'|| isSysMedicine))))
      );

      this.setMasterRecordList(records);

      // 必須エラーをチェック
      const validateMessage = this.validateRequired();
      // コンボで削除済みのレコードが指定されていないかをチェック
      const validateComboMessage = this.validateComboValue();
      let message = "";
      if (validateMessage.length !== 0) {
        // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
        // message = "以下の列に未入力項目が存在します。" + validateMessage +"</br>";
        message = messageFormat(DIALOG_MESSAGES[12000270].message) + validateMessage +"</br>";
        // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
      }
      if (validateComboMessage.length !== 0) {
        if (message.length !== 0) message = message + "</br>";
        message =
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
          // message + "以下の列の選択を見直してください。" + validateComboMessage +"</br>";
          message + messageFormat(DIALOG_MESSAGES[12000006].message) + validateComboMessage +"</br>";
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
      }

      // エラーメッセージは左寄せで表示
      if (message.length !== 0) {
        //共通ローダー：表示終了
        this.setLoadingScreenVisible(false);
        this.$ons.notification.alert({
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
          // title: "チェックエラー",
          title: DIALOG_MESSAGES[12000006].title,
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
          message: '<div style="text-align:left;">' + message + "</div>"
        });
        this.waterSurveyPointValueFalg = false;
        return;
      }

      // add FNSI-分類変更のメッセージ表示 李 start
      let classiFicationFlg = false;
      this.getMasterRecordList.data.forEach(
        item => {
          if (item.operation !== 1) {
            // 医療材料の分類が変更された
            if(item.dirtyFields && item.dirtyFields.classCd) {
              classiFicationFlg = true;
            } else if(item.dirtyFields && item.dirtyFields.classType){// 薬剤の分類が変更された
              classiFicationFlg = true;
            } else if (item.classiFicationFlg) {
              classiFicationFlg = true;
            }
          }
        });

      // add 分類区分/分類 修正 王 start
      if (
        this.masterPhysicalName === 'mst_medicine_class' ||
        this.masterPhysicalName === 'mst_equipment_class' ||
        this.masterPhysicalName === 'mst_equipment' ||
        this.masterPhysicalName === 'mst_medicine' ||
        this.masterPhysicalName === 'mst_medicine_mix'){
        let tempData = null;
        await ApiHelper.get(
          `/master_maintenance/${this.masterPhysicalName}/data/${this.facilitylistValue}`).then(response => {
          tempData = response.data.localDataSource.data
        });
        for (let i = 0; i < this.getMasterRecordList.data.length; i++) {
          for (let j = 0; j < tempData.length; j++) {
            if (tempData[j].code === this.getMasterRecordList.data[i].code){
              if (this.getMasterRecordList.data[i].classType !== undefined){
                if(tempData[j].classType.toString() == this.getMasterRecordList.data[i].classType){
                  classiFicationFlg = false;
                } else {
                  classiFicationFlg = true;
                  i = this.getMasterRecordList.data.length;
                  break;
                }
              }
              if (this.getMasterRecordList.data[i].classCd !== undefined){
                if(tempData[j].classCd.toString() == this.getMasterRecordList.data[i].classCd){
                  classiFicationFlg = false;
                } else {
                  classiFicationFlg = true;
                  i = this.getMasterRecordList.data.length;
                  break;
                }
              }
            }
          }
        }
      }
      // add 分類区分/分類 修正 王 end

      // 画面上で医療材料の分類が変更された場合
      if (classiFicationFlg) {
        await this.$ons.notification.alert({
          title: DIALOG_MESSAGES[12000051].title,
          // add 全マスタメッセージ調整 王 start
          // message: "分類が変更されました。透析指示に影響がないことを確認してください"
          message: DIALOG_MESSAGES[12000051].message
          // add 全マスタメッセージ調整 王 end
        });
      }
      // 更新処理呼び出す
      this.updateRecordList();
      // add FNSI-分類変更のメッセージ表示 李 end
    },
    updateRecordList() {
      /* add スクロールの位置を維持 楊 start */
      this.captureReloadScrollPosition();
      this.__preserveScrollOnReload = true;
      /* add スクロールの位置を維持 楊 end */
      // 調製薬剤マスタ画面の分類が変更されない場合
      if (this.masterPhysicalName === "mst_medicine_mix" || this.masterPhysicalName === "mst_medicine") {
        for (let i = 0; i < this.getUpdateRecordList.length; i++) {
          delete this.getUpdateRecordList[i].classiFicationFlg;
        }
      }


      const keys = [
        "code",
        "standardNo",
        "prescriptionNo",
        "companyNo",
        "dispensingNo",
        "logisticsNo",
        "janCd",
        "drugPriceStandardCd",
        "standardMedicineCd",
        "receiptCd1",
        "receiptCd2",
        "noticeName",
        "name",
        "receiptMedicineName",
        "standardUnit",
        "pkgPresentation",
        "pkgAmount",
        "pkgUnit",
        "pkgTotalAmount",
        "pkgTotalUnit",
        "usageCategoryClass",
        "manufactureCompany",
        "salesCompany",
        "recordClass",
        "standardUpDate",
        "pkgQtyQuantity",
        "pkgQtyUnit",
        "pkgQtyPerCartonQuantity",
        "pkgQtyPerCartonUnit",
        "unit",
        "unitSecond",
        "unitConvertedAmount",
        "unitConvertedAmountSecond",
        "unitDecimalPoint",
        "unitDecimalPointSecond",
        "operation"
      ];

      const updateRecords = this.getUpdateRecordList.map(record =>
          _.pick(record, keys)
      );

      // console.log(this.getUpdateRecordList)
      // apiをコールして値を保存
      this.updateRecordListByFacilityCd({facilityCd: this.facilitylistValue, request: updateRecords})
        .then(response => {
          this.updateResponse = response.data;
          // add #6930 標準医薬品マスタの抽出で追加読み込みが行われない 付 start
          ApiHelper.get(`/sys_medicine/getTotal`).then((res) => {
            this.sysMedicineDataTotal = res.data
          });
          // add #6930 標準医薬品マスタの抽出で追加読み込みが行われない 付 end
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
          this.__preserveScrollOnReload = false;
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
    // add redmine 6238 標準医薬品マスタでデータが表示されない 宋qy start
    scrollRight() {
      if (this.isDirectGridProgrammaticScrolling() || this.sysMedicinePageLoading) {
        return;
      }
      if (this.$refs.gridRoot !== undefined) {
        let e = this.getGridScrollHostEl();
        if (!e) {
          return;
        }
        let scrollBottom = Math.abs(e.scrollHeight - e.scrollTop - e.clientHeight) < 4;
        if(Math.abs(e.scrollHeight - e.scrollTop - e.clientHeight) >= 4){
          this.scrollFlag=true;
        }
        if(scrollBottom){
          if (this.scrollFlag) {
            if (this.loadingFlag) {
              if (this.addRowScrollFlag) {
                this.loadingFlag = false;
              }
            } else {
              this.loadingFlag = true;
              this.setLoadingScreenVisible(false);
              this.scrollFlag = false;
              return
            }
            if (this.dataPageScrollFlag || this.offset === this.sysMedicineDataTotal) {
              this.setLoadingScreenVisible(false);
              return
            }
            // スクロール位置を保存
            this.rememberGridScrollPosition({ top: e.scrollTop || 0, left: e.scrollLeft || 0 });
            this.setLoadingScreenVisible(true);
            this.scrollFlag = false;
            this.sysMedicineDataPage();
          }
        }
      }
    },
    async sysMedicineDataPage() {
      if (this.sysMedicinePageLoading) {
        return;
      }
      this.sysMedicinePageLoading = true;
      let releaseInNextTick = false;
      try {
        this.offset = this.getMasterRecordList.data.length;
        const obj = this.getRecordNameInputElement();
        let keyword = "";
        if(obj){
          keyword = obj.value;
        }
        // 標準医薬品マスタ
        const url = keyword
          ? `/sys_medicine/getSysMedicineByLimitAndOffset/${this.offset}/${encodeURIComponent(keyword)}`
          : `/sys_medicine/getSysMedicineByLimitAndOffset/${this.offset}`;
        let sysMedicineData = await ApiHelper.get(url);
        this.sysMedicine = sysMedicineData.data;

        // グリッドでエラーが発生している場合は処理を中断
        if (!this.validateBeforeGridAction()) {
          this.setLoadingScreenVisible(false);
          return;
        }
        const pagingScrollPosition = this.normalizeGridScrollPosition({
          top: this.lastScrollTop,
          left: this.lastInputScrollLeft
        });
        const appendedRows = [];
        for (let i = 0; i < this.sysMedicine.length; i++) {
          let d = new Object();
          const fields = this.getMasterRecordList.schema.model.fields;
          Object.keys(fields).forEach(k => {
            Object.keys(this.sysMedicine[i]).forEach(sysMedicineKey => {
              if (sysMedicineKey === k) {
                d[k] = this.sysMedicine[i][sysMedicineKey];
              }
            });
            if (k === "sortRank") {
              d[k] = this.getMaxSortRank() + 1;
            }
            if (k === "code") {
              d[k] = this.sysMedicine[i].standardNo;
            }
            d["name"] = this.sysMedicine[i].salesName;
          });
          // mod redmine 6619 標準医薬品マスタで抽出条件に関係ないデータが表示される,6620 編集していないのに編集内容破棄メッセージが表示される 宋qy start
          this.getMasterRecordList.data.push(d);
          // mod redmine 6619 標準医薬品マスタで抽出条件に関係ないデータが表示される,6620 編集していないのに編集内容破棄メッセージが表示される 宋qy end
          this.rememberSysMedicineRowSnapshot(d);
          this.edit({editRecord: d, isSortMode: true});
          appendedRows.push(d);
        }

        this.appendSysMedicinePageRowsToDirectGrid(appendedRows, pagingScrollPosition);
        this.setLoadingScreenVisible(false);
        releaseInNextTick = true;
      } finally {
        if (!releaseInNextTick) {
          this.sysMedicinePageLoading = false;
        }
      }
    },
    // add redmine 6238 標準医薬品マスタでデータが表示されない 宋qy end
    modifyEditStart(e) {
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
    // add #6930 標準医薬品マスタの抽出で追加読み込みが行われない 付 start
    ApiHelper.get(`/sys_medicine/getTotal`).then((res) => {
      this.sysMedicineDataTotal = res.data
    });
    // add #6930 標準医薬品マスタの抽出で追加読み込みが行われない 付 end
    // add redmine 6238 標準医薬品マスタでデータが表示されない 宋qy start
    // 滚动条监听
    (this.$el?.ownerDocument?.defaultView || window).addEventListener("scroll", this.scrollRight,true);
    // add redmine 6238 標準医薬品マスタでデータが表示されない 宋qy end
  },
  // add 性能改善メモリ不足 shan start
  beforeUnmount() {
    this.unbindGridScrollSync();
    this.clearSysMedicinePageScrollRestoreTimers();
    this.destroyDirectGrid();
    [this.directGridLayoutRafId, this.directGridFilterRefreshRafId, this.directGridScrollSyncRafId].forEach(id => {
      if (id != null) cancelAnimationFrame(id);
    });
    if (this.directGridProgrammaticScrollTimer != null) {
      clearTimeout(this.directGridProgrammaticScrollTimer);
    }
    this.directGridRowVisualRafIds?.forEach?.(id => cancelAnimationFrame(id));
    this.directGridRowVisualRafIds?.clear?.();
    this.clearSysMedicineRowSnapshots();
    EventBus.$off("onCloseMasterEditModal", this.onCloseMasterEditModal);
    EventBus.$off("refresh", this.refresh);
    EventBus.$off("onSearchForMstVirtualScrollable", this.onSearch);
    // add by shiyw for 6119
    (this.$el?.ownerDocument?.defaultView || window).removeEventListener("scroll", this.scrollRight,true);
  },
  // add 性能改善メモリ不足 shan start
}
</script>

<style scoped>
.right {
  text-align: right;
}

.header-btn-area {
  height: auto;
  padding: 0.1em 0.1em 0.1em 0.1em;
}

.ntss-list {
  position: relative;
  overflow: hidden;
}

#grid-footer {
  margin: 0;
  padding: 5px;
  bottom: 0;
  left: 0;
  right: 0;
  position: absolute;
  width: auto;
  z-index: 2;
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

.custom-switch {
  transform: scale(0.85);
  transform-origin: center;
  touch-action: manipulation;
}
.kendo-grid-toolbar-style :deep(.k-grid-content-locked) {
  overflow-y: scroll !important;
  -webkit-overflow-scrolling: touch;
  touch-action: pan-y;
  pointer-events: auto;
  scrollbar-width: none;
}
.kendo-grid-toolbar-style :deep(.k-grid-content-locked::-webkit-scrollbar) {
  width: 0px;
  height: 0px;
  background: transparent;
  display: none;
}
.mobile-header {
  min-height: 30px; /* モバイル用の高さ */
}

.sys-medicine-direct-jq-grid {
  width: 100%;
  overflow: hidden;
}

.sys-medicine-direct-jq-grid :deep(.k-grid-content),
.sys-medicine-direct-jq-grid :deep(.k-grid-content-locked) {
  box-sizing: border-box;
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
:deep(.k-dirty-cell){
  font-weight: 600 !important;
}
</style>
