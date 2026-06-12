/**
 * P-Ca9分割グラフ管理マスタメンテナンスデータページ  MainContent
 */
<template>
  <div class="main-content-area master-maintenance-page">
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
        <div v-if="isMasterUser" class="header-btn-area right">
          <!-- del マスタ一覧 1･施設切替を可能とする 王 start -->
          <!--          <kendo-dropdownlist-->
          <!--            v-model="facilitylistValue"-->
          <!--            :data-source="facilitys"-->
          <!--            :data-text-field="'facilityName'"-->
          <!--            :data-value-field="'facilityCd'"-->
          <!--            :filter="'contains'"-->
          <!--            @open="onOpenFacility"-->
          <!--            @change="onChangeFacility"-->
          <!--            style="width: 13em;">-->
          <!--          </kendo-dropdownlist>-->
          <!-- del マスタ一覧 1･施設切替を可能とする 王 start -->
        </div>
        <div v-else class="header-btn-area left"></div>
        <div
          v-show="columns.length > 1"
          id="grid-font-size"
          ref="gridRoot"
          :class="[fontSizeSet, 'content-style', 'ntss-kendo-grid-legacy', 'mst-graph-setting-direct-jq-grid']"
          style="clear: both;"
        ></div>
      </div>
      <!-- 高さ調整 -->
      <div id="grid-footer">
        <v-ons-row v-show="!isSortMode" width="100%">
          <v-ons-col width="50%">
            <v-ons-button
              class="btn2-cancel denial-btn"
              style="width: auto;"
              @click="cancel"
            >
              キャンセル
            </v-ons-button>
          </v-ons-col>
          <v-ons-col width="50%" class="right">
            <v-ons-button
              class="btn1-execute registration-btn"
              style="width: auto;"
              :disabled="!isChanged"
              @click="saveRecord"
            >
              保存
            </v-ons-button>
          </v-ons-col>
        </v-ons-row>
      </div>
      <message-dialog
        v-if="isDialogVisible"
        v-model:visible="isDialogVisible"
        :message-cd="messageCd"
        :string-params="stringParams"
        type="1"
      />
    </div>
  </div>
</template>

<script>

import { markRaw } from "@/compat/vue/runtime";
import kendo from "@progress/kendo-ui";
import $ from "jquery";
import _ from "@/compat/collections/lodash";
import dayjs from "@/compat/date/dayjs";
import { mapActions, mapGetters } from "@/compat/vue/vuex";
import messageDialog from "@/components/common/message-dialog/MessageDialog";
import { EventBus } from "@/compat/vue/event-bus.js";
import { ApiHelper } from "@/apis/AxiosHelper";
import PatGroup from "@/apis/pat-group";
//FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
//FNSI-修正 設定値の大小チェック対応 Huangxl add start
import {
  settingErrorMessage
} from "@/apis/mst-graph-setting-maintenance";
//FNSI-修正 設定値の大小チェック対応 Huangxl add end
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
import { cloneDeep, isEqual } from "@/compat/collections/lodash";

import { messageFormat } from "@/functions/common/MessageFormat";
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
import { withProgrammaticKendoUpdate } from "@/compat/kendo/legacy-sender.js";

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

function getKendoWidgetValue(widget) {
  if (!widget) {
    return null;
  }
  if (typeof widget.value === "function") {
    return widget.value();
  }
  return widget._value;
}

function setKendoWidgetValue(widget, value) {
  if (!widget) {
    return;
  }
  if (typeof widget.value === "function") {
    widget.value(value);
  } else {
    widget._value = value;
  }
}

const GRAPH_SETTING_ON_OFF_OPTIONS = [
  { id: "0", name: "OFF" },
  { id: "1", name: "ON" }
];

export default {
  components: {
    "message-dialog": messageDialog
  },
  data() {
    return {
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
        recordName: ""
      },
      kendoGridToolbarHeight: 500,
      kendoGridHeight: 300,
      kendoValidatorSetup: {
        rules: {},
        messages: {}
      },
      kendoValidator: undefined,
      facilitylistValue: "",

      // DB取得個別ドロップダウンリスト表示項目
      kendoGridDrop:{
        mstExamItemList: null,
        patGroupList: null
      },
      isDialogVisible: false,
      stringParams: null,
      messageCd: null,
      isSortChacked: false,

      delUserId: -1,
      //Android端末で編集中であることを示すフラグ
      editingFlg: false,
      androidFlg: false,
      //ソートはしないが共通画面仕様で使うため設定
      isSortMode: false,
      isSorted : false,
      //自画面の名称
      selfScreenName: "",
      // 表示権限ユーザー
      userType: "",
      //変更前の施設
      prevFacilityCd: "",
      lastscrollTop: 0,
      lastscrollLeft: 0,
      iosFlg: false,
      allowEdit: true, // NOTE: true = 編集モード、 false = 閲覧モード
      // 初期値退避用オブジェクト
      originalDataSource: null,
      directGridWidget: null,
      directGridMounted: false,
      directGridDataSource: null,
      directGridLayoutRafId: null,
      directGridFilterRefreshRafId: null,
      directGridScrollSyncRafId: null,
      directGridRowVisualRafIds: markRaw(new Map()),
      pendingGridScrollRestore: null,
      directGridNumericEditKeepUntil: 0
    };
  },
  computed: {
    // add マスタ一覧 1･施設切替を可能とする 王 start
    ...mapGetters("master-maintenance", { getFacilitySwitch: "getFacilitySwitch",}),
    // add マスタ一覧 1･施設切替を可能とする 王 end
    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight"
    }),
    ...mapGetters("account-edit", {
      isDispMenu: "isDispMenu",
      getFontSize: "getFontSize",
      getStateUserAccountInfo: "getStateUserAccountInfo"
    }),
    ...mapGetters("user", ["getFacilityCd"]),

    heightStyles() {
      const mobileHeader = this.isMobileDevice ? 32 : 0;
      // main部の高さをCSS変数を利用して書き換え
      return { "--height": `${this.kendoGridToolbarHeight - mobileHeader}px` };
    },
    ntssListStyles() {
      return { display: this.columns.length === 1 ? "none" : "inherit" };
    },
    fontSizeSet() {
      const names = ["small", "medium", "large", "x-large"];
      return `font-size-set-${names[this.getFontSize] || "medium"}`;
    },
    masterConditionSignature() {
      const condition = this.$store?.state?.["mst-graph-setting"]?.condition || this.condition || {};
      return `${condition.recordName || ""}|${condition.includeDeleted ? 1 : 0}`;
    },
    ...mapGetters("mst-graph-setting", {
      getFacilityList: "getFacilityList",
      getFilteredMasterRecordList: "getFilteredMasterRecordList",
      getEditRecord: "getEditRecord",
      getMasterRecordList: "getMasterRecordList", // add #10198 検索した状態で保存すると保存が完了しない 宮崎
      getUpdateRecordList: "getUpdateRecordList"
    }),
    isMasterUser() {
        return this.getStateUserAccountInfo.userType === 1 ? true : false;
    },
    facilitys() {
      // storeからデータを取得
      return this.getFacilityList;
    },
    masterRecords() {
      // storeからデータを取得
      return this.getFilteredMasterRecordList;
    },
    isChanged() {
      const data = this.getMasterRecordList.data;
      return (
        this.getStateUserAccountInfo !== null &&
        data !== undefined &&
        // add 9462 P-Ca９分割グラフ設定マスタのコンバートが正しくない zhao start
        this.kendoValidator !== undefined &&
        // add 9462 P-Ca９分割グラフ設定マスタのコンバートが正しくない zhao end
        (data.filter(row => row.operation > 0).length ||
          this.isSorted ||
          !this.validateDirectKendoGrid())
      );
    },

    editRecord(){
      return this.getEditRecord;
    },
    isMobileDevice() {
      return this.iosFlg || this.androidFlg;
    }
  },
  watch: {
    windowHeight() {
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
    ...mapActions("multi-modal", [
      "showUserMasterIdReset",
      "showUserMasterAuthFunction"
    ]),
    ...mapActions("mst-graph-setting", [
      "getGraphSettingDataList",
      "edit",
      "setEditRecord",
      "facilityList",
      "setCondition",
      "setUserData",
      "setMasterRecordList",
      "setUserType",
      "getDoctorsAtFacility",
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
    validateDirectKendoGrid() {
      return true;
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
    getGridHeaderEl() {
      return this.getGridRootEl()?.querySelector?.(".k-grid-header") || null;
    },
    getGridTableEl() {
      return this.directGridWidget?.table?.[0] || this.getGridRootEl()?.querySelector?.(".k-grid-content table") || null;
    },
    getGridTbodyEl() {
      return this.directGridWidget?.tbody?.[0] || this.getGridRootEl()?.querySelector?.(".k-grid-content tbody") || null;
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
      this.triggerDirectGridContentScroll();
    },
    savePendingGridScrollRestore(position = this.getGridScrollPosition()) {
      this.pendingGridScrollRestore = {
        top: position?.top || 0,
        left: position?.left || 0
      };
    },
    restorePendingGridScrollPosition() {
      const position = this.pendingGridScrollRestore || this.getGridScrollPosition();
      this.setGridScrollPosition(position);
      return position;
    },
    scheduleDirectGridScrollRestore() {
      if (this.directGridScrollSyncRafId != null) {
        cancelAnimationFrame(this.directGridScrollSyncRafId);
      }
      this.directGridScrollSyncRafId = requestAnimationFrame(() => {
        this.directGridScrollSyncRafId = requestAnimationFrame(() => {
          this.directGridScrollSyncRafId = null;
          this.restorePendingGridScrollPosition();
        });
      });
    },
    triggerDirectGridContentScroll() {
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
    calculateColumnsWidth() {
      const widthMap = [12, 14, 16, 18];
      this.columnWidth = widthMap[Number(this.getFontSize || 1)] || 14;
    },

    // Windowの高さからGirdコンポーネント領域の高さを算出
    calculateGridHeight() {
      if (!this.editingFlg) {
        const wh = Number(this.windowHeight) || window.innerHeight || 0;
        const headerElements = Array.from(document.getElementsByClassName("header"));
        const hh = headerElements.length ? headerElements[headerElements.length - 1].clientHeight : 0;
        const footerMenu = document.getElementById("footer-menu");
        const fmh = (this.isDispMenu === 1 && footerMenu ? footerMenu.clientHeight : 0) + 5;
        this.kendoGridToolbarHeight = wh - hh - fmh - 10;
        this.kendoGridToolbarHeight =
          this.kendoGridToolbarHeight < 340 ? 340 : this.kendoGridToolbarHeight;

        const gridFooter = document.getElementById("grid-footer");
        const gridHeader = document.getElementById("grid-header");
        const gfh = gridFooter?.clientHeight || 0;
        const hbh = gridHeader?.clientHeight || 0;
        this.kendoGridHeight = this.kendoGridToolbarHeight - (gfh + hbh);
      }
    },
    calculateGridWidth() {
      this.resizeDirectGrid();
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
        if (column.title === "設定値") {
          gridColumn.template = dataItem => this.dispValueTemplate(dataItem);
          gridColumn.editor = (container, options) => this.editorInput(container, options);
        } else if (column.field === "dispOrder") {
          gridColumn.width = "4em";
          gridColumn.editor = (container, options) => this.editorInput(container, options);
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
        cellClose: event => this.editEnd(event),
        save: event => this.onDirectGridSave(event),
        dataBound: () => this.onDirectGridDataBound(),
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
      const position = resetScroll
        ? { top: 0, left: 0 }
        : (this.pendingGridScrollRestore || this.getGridScrollPosition());
      grid.dataSource.data(this.getDirectGridDataSourceOption().data || []);
      this.$nextTick(() => {
        this.applyDirectGridStyleContract();
        this.editBackgroundColor();
        this.setGridScrollPosition(position);
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
      root.querySelectorAll(".k-grid-header th, .k-grid-header .k-table-th").forEach(th => th.classList.add("k-header"));
      [".k-grid-content tbody", ".k-grid-content-locked tbody"].forEach(selector => {
        const tbody = root.querySelector(selector);
        if (!tbody) {
          return;
        }
        Array.from(tbody.children || []).forEach((tr, index) => {
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
      if (this.directGridLayoutRafId != null) {
        cancelAnimationFrame(this.directGridLayoutRafId);
      }
      if (!this.pendingGridScrollRestore) {
        this.savePendingGridScrollRestore();
      }
      this.directGridLayoutRafId = requestAnimationFrame(() => {
        this.calculateColumnsWidth();
        this.calculateGridHeight();
        this.resizeDirectGrid();
        this.applyDirectGridStyleContract();
        this.restorePendingGridScrollPosition();
        this.directGridLayoutRafId = requestAnimationFrame(() => {
          this.directGridLayoutRafId = null;
          this.resizeDirectGrid();
          this.applyDirectGridStyleContract();
          this.restorePendingGridScrollPosition();
          this.scheduleDirectGridScrollRestore();
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
      if (this.pendingGridScrollRestore) {
        this.scheduleDirectGridScrollRestore();
      }
    },
    onDirectGridSave(event) {
      this.editingFlg = false;
      const model = event?.model;
      if (!model) return;

      Object.keys(event.values || {}).forEach(field => {
        const nextValue = event.values[field];
        if (typeof model.set === "function") {
          model.set(field, nextValue);
        } else {
          model[field] = nextValue;
        }
        if (Number(model.inputType) === 2 && field === "dispValue") {
          if (typeof model.set === "function") {
            model.set("value", nextValue);
            model.set("val", nextValue);
          } else {
            model.value = nextValue;
            model.val = nextValue;
          }
        }
      });

      const unchanged = this.handleUnchangedState(event);
      if (unchanged) {
        this.scheduleDirectGridCurrentRowVisual(model);
        this.scheduleDirectGridLayoutContract();
        this.scheduleDirectGridScrollRestore();
        return;
      }

      this.edit({ editRecord: model, isSortMode: false });
      if (model.operation === 1) model.edited = true;
      this.scheduleDirectGridCurrentRowVisual(model);
      this.scheduleDirectGridLayoutContract();
      this.scheduleDirectGridScrollRestore();
    },
    scheduleGraphSettingDropdownEditorCommit(model) {
      if (!model) {
        return;
      }
      const ownerWindow = this.$el?.ownerDocument?.defaultView || window;
      const runFallbackCommit = () => {
        if (!model || Number(model.operation) > 0) {
          return;
        }
        const values = { value: model.value ?? model.val ?? model.dispValue };
        if (this.handleUnchangedState({ model, values })) {
          this.scheduleDirectGridCurrentRowVisual(model);
          this.scheduleDirectGridLayoutContract();
          this.scheduleDirectGridScrollRestore();
          return;
        }
        this.editingFlg = false;
        this.edit({ editRecord: model, isSortMode: false });
        if (Number(model.operation) > 0) {
          model.edited = true;
        }
        this.scheduleDirectGridCurrentRowVisual(model);
        this.scheduleDirectGridLayoutContract();
        this.scheduleDirectGridScrollRestore();
      };
      this.$nextTick(() => {
        if (typeof ownerWindow.requestAnimationFrame === "function") {
          ownerWindow.requestAnimationFrame(runFallbackCommit);
        } else {
          ownerWindow.setTimeout(runFallbackCommit, 0);
        }
      });
    },
    scheduleDirectGridCurrentRowVisual(record) {
      const key = record?.uid || record?.code || record?.graphSettingNo;
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
      if (!record?.uid) {
        return;
      }
      this.getDirectGridRowsByUid(record.uid).forEach(row => {
        this.clearDirectGridRowVisual(row);
        const edited = this.changeEditColor(row) || !!record.operation || !!record.edited;
        this.changeRowColor(row, edited, false);
      });
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
      this.savePendingGridScrollRestore();
      this.editingFlg = true;
    },
    editEnd(e) {
      if (e?.model?.inputType == 2 && Date.now() <= this.directGridNumericEditKeepUntil) {
        e?.preventDefault?.();
        this.editingFlg = true;
        return;
      }
      this.editingFlg = false;
    },

    // マスタ一覧のデータを取得
    async findList() {
      // スクロールの位置を維持
      /* mod スクロールの位置を維持 楊 start */
      // let scrollTop = 0;
      // let scrollLeft = 0;
      // if(this.$refs.grid != null){
      //   scrollTop = this.$refs.grid.$el.children[1].scrollTop;
      //   scrollLeft = this.$refs.grid.$el.children[1].scrollLeft;
      // }
      /* mod スクロールの位置を維持 楊 end */
      // 設定値リストのうちDB参照系をコールして再取得
      await this.setkendoGridDropList();

      try {
        const response = await this.getGraphSettingDataList(this.facilitylistValue);
        const toFunction = response.data.columns;
        toFunction.forEach(column => {
          column.editable = column.editable ? () => true : () => false;
          column["width"] = column.width ? column.width : "0";
        });
        this.columns = toFunction;
        // mod #10198 検索した状態で保存すると保存が完了しない 宮崎 start
        this.getMasterRecordList.data.forEach(columnData => {
          columnData.dispValue = this.resolveDispValueDisplay(columnData);
        });
        this.setMasterRecordList(this.getMasterRecordList);
        // mod #10198 検索した状態で保存すると保存が完了しない 宮崎 end

        this.originalDataSource = cloneDeep(this.getMasterRecordList.data);

        this.columns.forEach(column => {
          column.width = column.field === "description" ? "24em" : "14em";
          column.encoded = column.field === "description" ? false : true;
        });
        this.columns.unshift({
          title: " ",
          field: "dummy",
          hidden: false,
          editable: () => false,
          width: "10px",
          format: "",
          values: null
        });

        const sortRankIndex = this.columns.findIndex(
          col => col.field === "sortRank"
        );
        if (sortRankIndex >= 0) {
          this.columns[sortRankIndex].hidden = true;
          const dummyIndex = this.columns.findIndex(
            col => col.field === "dummy"
          );
          if (dummyIndex >= 0) {
            this.columns[dummyIndex].hidden = false;
          }
        }

        this.$nextTick(() => {
          this.calculateGridHeight();
          this.initDirectGridIfReady();
          this.pendingGridScrollRestore = {
            top: this.lastscrollTop,
            left: this.lastscrollLeft
          };
          this.refreshDirectGridDataFromMasterRecords();
          this.scheduleDirectGridLayoutContract();
          this.setGridScrollPosition({ top: this.lastscrollTop, left: this.lastscrollLeft });
          setTimeout(() => {
            this.lastscrollTop = 0;
            this.lastscrollLeft = 0;
            this.pendingGridScrollRestore = null;
          }, 1000);
        });
      } catch (error) {
        getErrorMessage('MstGraphSettingMainComponent.vue', 'findList', '指定されたマスタが見つかりません。');
        if (error.response && error.response.status === 400) {
          this.$ons.notification.alert({
            title: DIALOG_MESSAGES[12000003].title,
            message: messageFormat(DIALOG_MESSAGES[12000003].message),
          });
        }
      }
    },
    // 施設一覧のデータを取得
    findFacilityList() {
      // 日機装ユーザ以外の場合
      if (this.getStateUserAccountInfo.userType !== 1) {
        // ログイン者の担当施設を選択（初期値は自分の所属する施設）
        this.setFacilitylistValue();
        // 選択した施設を元に利用者一覧の取得
        this.findList();
        return;
      }
      // apiをコールして施設一覧を取得
      this.facilityList()
        .then(() => {
          // ログイン者の担当施設を選択
          this.setFacilitylistValue();
          // 選択した施設を元に利用者一覧の取得
          this.findList();
        })
        .catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
          getErrorMessage('MstGraphSettingMainComponent.vue', 'findFacilityList', '指定されたマスタが見つかりません。');
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
          alert(error);
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
    },
    setFilterCondition(condition) {
      this.condition.userType = this.getStateUserAccountInfo.userType;
      this.condition.recordName = condition.recordName;
    },
    setFacilitylistValue() {
      this.facilitylistValue = this.getStateUserAccountInfo.facilityCd;
    },
    /**
     * グラフ設定項目
     * X,Y軸検査マスタ指定
     */
    async findExamList() {
      const requestParam = {
        facilityCd: this.getFacilityCd
      };
      const [
        mstExamItem
      ] = await Promise.all([
        ApiHelper.get("/mstInfo/mstExamItem", requestParam)
      ]);
      return mstExamItem.data.filter(item=>item.isDel== "0" && item.isDisp=="1");
    },

    async setkendoGridDropList(){
      const mstExamItemResponse = await this.findExamList();
      let examItemList = [{id: "0", name: "未登録"}];
      mstExamItemResponse.forEach(examItem => {
        examItemList.push({
          id: `${examItem.examItemCd}`,
          name: examItem.examItemName
        });
      });
      this.kendoGridDrop.mstExamItemList = examItemList;

      const patGroupListResponse = await PatGroup.list(this.getFacilityCd);
      let patGroupList = [{id: "0", name: "未登録"}];
      patGroupListResponse.data.patGroupInfo.forEach(patGroup => {
        patGroupList.push({
          id: `${patGroup.patGroupCd}`,
          name: patGroup.patGroupName
        });
      });
      this.kendoGridDrop.patGroupList = patGroupList;
    },
    onOpenFacility(e) {
      //変更前の施設を取得
      this.prevFacilityCd = e.sender._old;
    },
    onChangeFacility(e) {
      if(this.prevFacilityCd != e.sender._old) {
        if (this.isChanged){
          // 編集時は未保存確認メッセージを出力する
          const newFacilityCd = e.sender._old;
          e.preventDefault();
          this.$ons.notification.confirm({
            // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
            // title: "内容破棄",
            title: DIALOG_MESSAGES[13000004].title,
            // message: "編集内容が破棄されます。</br>よろしいですか？",
            message: messageFormat(DIALOG_MESSAGES[13000004].message),
            // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
            callback: answer => {
              if (answer === 1) {
                // 選択した施設を元に施設設定一覧の取得
                this.facilitylistValue = newFacilityCd;
                this.findList();
              } else {
                // 変更前の施設を設定する
                this.facilitylistValue = this.prevFacilityCd;
              }
            }
          });
        } else {
          // 選択した施設を元に施設設定一覧の取得
          this.facilitylistValue = e.sender._old;
          this.findList();
        }
      }
    },

    editBackgroundColor() {
      this.$nextTick(() => {
        if (this.editingFlg) {
          return;
        }
        const gridHeader = this.getGridHeaderEl();
        if (!gridHeader || gridHeader.textContent === " ") {
          return;
        }
        gridHeader?.classList?.add("master-grid-header");
        this.refreshDirectGridDirtyVisualState();
      });
    },
    getDirectGridRowsByUid(uid) {
      const root = this.getGridRootEl();
      if (!root || !uid) {
        return [];
      }
      return Array.from(root.querySelectorAll(`.k-grid-content tbody tr[data-uid="${uid}"], .k-grid-content-locked tbody tr[data-uid="${uid}"]`));
    },
    isDirectGridLockedRow(row) {
      return !!row?.closest?.(".k-grid-content-locked");
    },
    getDirectGridVisibleColumnsForRow(row) {
      return (this.columns || []).filter(column => !column.hidden && !!column.locked === this.isDirectGridLockedRow(row));
    },
    getDirectGridCellField(row, cellIndex) {
      return this.getDirectGridVisibleColumnsForRow(row)[cellIndex]?.field || null;
    },
    getDirectGridVisibleColumnOrder(fieldName) {
      return (this.columns || []).filter(column => !column.hidden).findIndex(column => column.field === fieldName);
    },
    clearDirectGridRowVisual(row) {
      Array.from(row?.children || []).forEach(cell => {
        cell.classList.remove("master-edited-cell", "master-edited-row", "master-deleted-row");
      });
      row?.classList?.remove?.("master-edited-row", "master-deleted-row");
    },
    refreshDirectGridDirtyVisualState() {
      const grid = this.directGridWidget;
      if (!grid?.tbody) {
        return;
      }
      Array.from(grid.tbody.children() || []).forEach(row => {
        const record = grid.dataItem(row);
        if (record) {
          this.applyDirectGridRowVisual(record);
        }
      });
    },
    changeEditColor(row) {
      let edited = false;
      Array.from(row?.children || []).forEach((cell, cellIndex) => {
        const fieldName = this.getDirectGridCellField(row, cellIndex);
        if (fieldName !== "sortRank" && this.isEditRow(cell)) {
          cell.classList.add("master-edited-cell");
          edited = true;
        }
      });
      return edited;
    },
    isEditRow(currentTd) {
      // 編集した行を判定
      return currentTd?.classList?.contains("k-dirty-cell");
    },
    changeRowColor(row, edited, deleted) {
      if (!edited && !deleted) {
        return;
      }
      const addClass = deleted ? "master-deleted-row" : "master-edited-row";
      const sortRankOrder = this.getDirectGridVisibleColumnOrder("sortRank");
      Array.from(row?.children || []).forEach((cell, cellIndex) => {
        const fieldName = this.getDirectGridCellField(row, cellIndex);
        const columnOrder = this.getDirectGridVisibleColumnOrder(fieldName);
        if (sortRankOrder < 0 || columnOrder > sortRankOrder) {
          cell.classList.add(addClass);
        }
      });
      row?.classList?.add?.(addClass);
    },
    getColumnIndex(fieldName) {
      // 指定された項目がない場合はマイナスが返る
      return this.columns.findIndex(e => e.field === fieldName);
    },
    parseJsonValue(value, fallback = []) {
      if (value == null || value === "") {
        return fallback;
      }
      if (typeof value !== "string") {
        return value;
      }
      try {
        return JSON.parse(value);
      } catch (_error) {
        return fallback;
      }
    },
    syncGraphSettingOptionValue(columnData) {
      const graphSettingNo = String(columnData.graphSettingNo ?? "");
      if (graphSettingNo === "2" || graphSettingNo === "3") {
        columnData.optionValue = JSON.stringify(this.kendoGridDrop.mstExamItemList);
      } else if (graphSettingNo >= "33" && graphSettingNo <= "42") {
        columnData.optionValue = JSON.stringify(this.kendoGridDrop.patGroupList);
      }
    },
    getGraphSettingOptionList(columnData) {
      this.syncGraphSettingOptionValue(columnData);
      return this.parseJsonValue(columnData.optionValue, []);
    },
    resolveDispValueDisplay(columnData) {
      const inputType = Number(columnData.inputType);
      if ([4, 5, 9].includes(inputType)) {
        const optionList = this.getGraphSettingOptionList(columnData);
        const matched = optionList.find(
          item => String(item.id) === String(columnData.value)
        );
        if (matched) {
          return matched.name;
        }
        return columnData.dispValue ?? columnData.value ?? "";
      }
      if (inputType === 3) {
        const matched = GRAPH_SETTING_ON_OFF_OPTIONS.find(
          item => String(item.id) === String(columnData.value)
        );
        return matched ? matched.name : (columnData.dispValue ?? columnData.value ?? "");
      }
      if (inputType === 2 && columnData.value != null) {
        return String(columnData.value);
      }
      return columnData.dispValue ?? columnData.value ?? "";
    },
    resolveSaveValueFromRecord(columnData) {
      const inputType = Number(columnData.inputType);
      if ([4, 5, 9].includes(inputType)) {
        const optionList = this.getGraphSettingOptionList(columnData);
        let matched = optionList.find(
          item =>
            item.name == columnData.dispValue &&
            columnData.val &&
            String(item.id) === String(columnData.val)
        );
        if (!matched && columnData.dispValue != null && columnData.dispValue !== "") {
          matched = optionList.find(
            item => String(item.name) === String(columnData.dispValue)
          );
        }
        if (!matched && columnData.value != null && columnData.value !== "") {
          matched = optionList.find(
            item => String(item.id) === String(columnData.value)
          );
        }
        return matched ? String(matched.id) : columnData.value;
      }
      if (inputType === 3) {
        const matched = GRAPH_SETTING_ON_OFF_OPTIONS.find(
          item => String(item.name) === String(columnData.dispValue)
        );
        return matched ? matched.id : columnData.value;
      }
      return columnData.dispValue;
    },
    dispValueTemplate(dataItem) {
      const value = this.resolveDispValueDisplay(dataItem);
      const inputType = Number(dataItem.inputType);
      const display = value == null ? "" : String(value);
      return display.startsWith("#") && inputType === 1
        ? `<div style='background-color: ${display}; width: 4em;'>&nbsp;</div>`
        : this.$sanitize(display);
    },

    async saveRecord() {
      // 共通ローダー:表示開始
      this.directGridWidget?.closeCell?.();
      this.setLoadingScreenVisible(true);
      /* add スクロールの位置を維持 楊 start */
      const { top: scrollTop, left: scrollLeft } = this.getGridScrollPosition();
      this.lastscrollTop = scrollTop;
      this.lastscrollLeft = scrollLeft;
      /* add スクロールの位置を維持 楊 end */
      await this.setkendoGridDropList();

      // masterListの表示値から登録値を再設定(ドロップダウンリストの表示と値を再設定)
      this.getMasterRecordList.data.forEach(columnData => {
        if (columnData.operation === 2) {
          columnData.value = this.resolveSaveValueFromRecord(columnData);
        }
      });
      this.setMasterRecordList(this.getMasterRecordList);

      if (!this.isFilledRequired()) {
        this.setLoadingScreenVisible(false);
        return;
      }
      //FNSI-修正 設定値の大小チェック対応 Huangxl add start
      if (!this.settingValidation()) {
        //共通ローダー：表示終了
        this.setLoadingScreenVisible(false);
        return;
      }
      //FNSI-修正 設定値の大小チェック対応 Huangxl add end
      // 登録用項目一覧
      const keys = [
        "graphSettingNo",
        "value"
      ];

      // 編集中のレコードを取得
      const insertRecords = [];
      for (const record of this.getUpdateRecordList) {
         if (record.operation === 2) {
           //更新対象データ
            insertRecords.push(record);
        }
      }

      // 登録日時・更新日時用の現在日時
      const now = dayjs().format("YYYY-MM-DDTHH:mm:ss.SSSZ");

      const serializedInsertRecords = insertRecords.map(record =>
        JSON.stringify({
          ..._.pick(record, keys),
          facilityCd: this.facilitylistValue,
          regDate: now,
          upDate: now
        })
      );

      //登録更新用レコードの作成
      const editRecord = {
        insertRecord: serializedInsertRecords
      };

      // apiをコールして値を保存
      await ApiHelper.put("/master_maintenance/saveMstGraphSetting", editRecord).catch(
        error => {
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
          getErrorMessage('MstGraphSettingMainComponent.vue', 'saveRecord', error);
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
          //共通ローダー：表示終了
          this.setLoadingScreenVisible(false);
          throw new Error(error);
        }
      );

      this.$ons.notification.alert({
        // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
        // title: "更新完了",
        // message: "マスタ更新が完了しました。"
        title: DIALOG_MESSAGES[12000004].title,
        message: messageFormat(DIALOG_MESSAGES[12000004].message),
        // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
      });

      await this.findList();

      // 共通ローダー:表示終了
      this.setLoadingScreenVisible(false);
    },
    /**
     * @description 必須項目チェック
     * @summary 未入力の必須項目があったらダイアログを表示する
     * @returns {Boolean} true: 未入力なし, false: 未入力あり
     */
    isFilledRequired() {
      if (
        this.getUpdateRecordList.some(
          item =>
            item.operation === 2 &&
            (item.dispValue === null || item.dispValue === ""))) {
        this.isDialogVisible = true;
        this.messageCd = 20010002;
        this.stringParams = ["設定値"];
        return false;
      }
      return true;
    },

    //FNSI-修正 設定値の大小チェック対応 Huangxl add start
    /**
     * 設定不備の条件
     */
    settingValidation() {
      // mod #10198 検索した状態で保存すると保存が完了しない 宮崎 start
      if (this.getUpdateRecordList != null) {
        let graphSettings = [];
        graphSettings.push({
          limitUpperThresholdX: this.getUpdateRecordList[4].value,
          limitLowerThresholdX: this.getUpdateRecordList[5].value,
          limitUpperThresholdY: this.getUpdateRecordList[8].value,
          limitLowerThresholdY: this.getUpdateRecordList[9].value,
          limitLowerX: this.getUpdateRecordList[6].value,
          limitLowerY: this.getUpdateRecordList[10].value,
          limitUpperX: this.getUpdateRecordList[3].value,
          limitUpperY: this.getUpdateRecordList[7].value,
        });
        // mod #10198 検索した状態で保存すると保存が完了しない 宮崎 end
        let errorStatus = settingErrorMessage(graphSettings);
        if (errorStatus) {
          this.$ons.notification.alert({
            title: "",
            message: errorStatus,
          });
          return false;
        }
        return true;
      }
    },
    //FNSI-修正 設定値の大小チェック対応 Huangxl add end

    // -----------------------------------------
    // 抽出UI表示イベント
    // -----------------------------------------
    showPopover(event) {
      this.popoverTarget = event;
      this.popoverVisible = true;
    },
    // パンくずリストをクリックされた場合に呼び出される関数
    refresh() {
      // 他の画面に遷移したときもrefresh()が発生する為、自分の画面のみ処理する
      if (this.selfScreenName === this.getCurrentRouteName()
          && document.getElementsByTagName("ons-alert-dialog").length === 0) {
        if (this.isChanged) {
          this.$ons.notification.confirm({
            // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
            // title: "内容破棄",
            title: DIALOG_MESSAGES[13000004].title,
            // message: "編集内容が破棄されます。</br>よろしいですか？",
            message: messageFormat(DIALOG_MESSAGES[13000004].message),
            // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
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
     * @description 編集時、テキストボックスをDB指定の入力フィールドへ変換
     * @summary inputType 1.テキストボックス 2.数値用テキストボックス 3.ドロップダウンリスト(ON/OFF選択用) 4.ドロップダウンリスト(DB設定項目の選択)
     * @param container grid生成情報
     * @param data DB取得値
     */
    editorInput(container, data) {
      if (data.model.inputType == 4 || data.model.inputType == 5 || data.model.inputType == 9) {
        const optionValue = this.getGraphSettingOptionList(data.model);
        const findById = candidate =>
          optionValue.find(item => String(item.id) === String(candidate));
        const findByName = candidate =>
          optionValue.find(item => String(item.name) === String(candidate));
        let initialValue = "";
        const matchedByValue = findById(data.model.value);
        if (matchedByValue) {
          initialValue = matchedByValue.id;
        }
        const matchedByVal = findById(data.model.val);
        if (matchedByVal) {
          initialValue = matchedByVal.id;
        }
        if (!initialValue && data.model.dispValue != null) {
          const matchedByDisp = findByName(data.model.dispValue);
          if (matchedByDisp) {
            initialValue = matchedByDisp.id;
          }
        }
        const vm = this;
        const applySelection = (widget, selectedValue) => {
          const selectedItem = optionValue.find(
            item => String(item.id) === String(selectedValue)
          );
          const normalizedValue = selectedItem
            ? String(selectedItem.id)
            : String(selectedValue ?? "");
          if (widget && typeof widget.value === "function" && String(widget.value() ?? "") !== normalizedValue) {
            withProgrammaticKendoUpdate(widget, () => widget.value(normalizedValue));
          }
          data.model.val = normalizedValue;
          data.model.value = normalizedValue;
          data.model.dispValue = selectedItem?.name || "";
          return true;
        };
        const $dropDownInput = $(`<input class="k-textbox" name="${data.field}" data-bind="value:value"/>`).appendTo(container);
        const dropDownWidget = $dropDownInput
          .kendoDropDownList({
            dataSource: optionValue,
            dataTextField: "name",
            dataValueField: "id",
            value: String(initialValue),
            change: function(e) {
              vm.savePendingGridScrollRestore();
              applySelection(e.sender, getKendoWidgetValue(e.sender));
              vm.directGridWidget?.closeCell?.();
              vm.scheduleGraphSettingDropdownEditorCommit(data.model);
            },
            filter: "contains"
          }).data("kendoDropDownList");
        $dropDownInput.blur(() => {
          const value = data.model.val || data.model.value;
          if (optionValue && value) {
            const optionValueItem = optionValue.find(
              item => String(item.id) === String(value)
            );
            if (optionValueItem?.name) {
              data.model.dispValue = optionValueItem.name;
            }
          } else if (optionValue && data.model.dispValue) {
            const optionValueItem = findByName(data.model.dispValue);
            if (optionValueItem) {
              data.model.val = String(optionValueItem.id);
              data.model.value = String(optionValueItem.id);
              data.model.dispValue = optionValueItem.name;
            }
          }
        });
        this.$nextTick(() => {
          if (!dropDownWidget) {
            return;
          }
          // 初期値が空でない場合は選択値を再適用し、表示を確実に反映する
          if (initialValue !== "" && initialValue != null) {
            dropDownWidget.value(String(initialValue));
          }
          // セル編集開始時にドロップダウンを自動展開する
          setTimeout(() => dropDownWidget.open?.(), 0);
        });
      } else if (data.model.inputType == 3) {
        const findOnOffById = candidate =>
          GRAPH_SETTING_ON_OFF_OPTIONS.find(
            item => String(item.id) === String(candidate)
          );
        const findOnOffByName = candidate =>
          GRAPH_SETTING_ON_OFF_OPTIONS.find(
            item => String(item.name) === String(candidate)
          );
        let onOffDisplayValue = findOnOffByName(data.model.dispValue)?.name || "";
        if (!onOffDisplayValue) {
          onOffDisplayValue =
            findOnOffById(data.model.value)?.name ||
            findOnOffById(data.model.val)?.name ||
            "";
        }
        const vm = this;
        $(`<input class="k-textbox" name="${data.field}" data-bind="value:dispValue"/>`)
          .appendTo(container)
          .kendoDropDownList({
            dataSource: GRAPH_SETTING_ON_OFF_OPTIONS,
            dataTextField: "name",
            dataValueField: "name",
            value: onOffDisplayValue,
            change: function(e) {
              vm.savePendingGridScrollRestore();
              const selectedName = getKendoWidgetValue(e.sender);
              const selectedItem = findOnOffByName(selectedName);
              data.model.dispValue = selectedItem?.name || "";
              data.model.value = selectedItem?.id ?? "";
              data.model.val = selectedItem?.id ?? "";
              vm.directGridWidget?.closeCell?.();
              vm.scheduleGraphSettingDropdownEditorCommit(data.model);
            }
          });
      }else if(data.model.inputType == 2){
        // mod #5589 2023/04/10 数値IFのスタイル全不正 林峻峰 start
        // var numberScope = $.parseJSON(data.model.optionValue);
        // $(`<input class="k-numerictextbox" name="${data.field}"/>`)
        //   .appendTo(container)
        //   .mountNumericTextBox({
        //     min: -9999999,
        //     max: 9999999
        //   });
        let strinput= `<input id="myInputNumber" type="number" style="text-align:right" name="${data.field}"/>`;
        let parameterMin = -9999999
        let parameterMax = 9999999
        let parameterStep = 1
        let parameter = {step: parameterStep, format: "n0"}
        let numericTextBox = null;
        let pendingNumericValue = null;
        const markNumericEdit = () => {
          this.directGridNumericEditKeepUntil = Date.now() + 1000;
        };
        const setNumericModelValue = (value) => {
          data.model[data.field] = value
          data.model.value = value
          data.model.val = value
        };
        const getNumericEditorValue = () => {
          const rawValue = pendingNumericValue ??
            numericTextBox?._value ??
            numericTextBox?.element?.val?.() ??
            numericTextBox?._text?.val?.() ??
            data.model[data.field] ??
            data.model.value;
          const value = parseFloat(rawValue);
          return Number.isNaN(value) ? 0 : value;
        };
        const setNumericEditorValue = (value) => {
          pendingNumericValue = value;
          setNumericModelValue(value);
          if (numericTextBox) {
            numericTextBox._value = value;
          }
          const displayValue = value == null ? "" : String(value);
          const inputs = [];
          const addInput = input => {
            if (input && inputs.indexOf(input) === -1) {
              inputs.push(input);
            }
          };
          addInput(numericTextBox?.element?.get?.(0));
          addInput(numericTextBox?._text?.get?.(0));
          numericTextBox?.wrapper?.get?.(0)?.querySelectorAll?.("input").forEach(addInput);
          inputs.forEach(input => {
            input.value = displayValue;
          });
        };
        parameter.spin = ()=> {
          markNumericEdit();
          let value = getNumericEditorValue()
          // 数値範囲内かどうかの確認
          if (value > parameterMax) {
            setNumericEditorValue(parameterMin)
          } else if (value < parameterMin) {
            setNumericEditorValue(parameterMax)
          }
          const gridElement = this.getGridRootEl();
          if (gridElement) {
            gridElement.onmousewheel = () => {
            return true
          }
          }
        }
        parameter.change = (e)=> {
          let value = pendingNumericValue !== null ? pendingNumericValue : e.sender._value
          if (value == null || value === "") {
            value = e.sender.element?.val?.()
          }
          value = parseFloat(value)
          if (Number.isNaN(value)) {
            value = 0
          }
          // 数値範囲内かどうかの確認
          if (value > parameterMax) {
            value = parameterMax
          } else if (value <  parameterMin) {
            value = parameterMin
          }
          setNumericModelValue(value)
          setNumericEditorValue(value)
          pendingNumericValue = null;
          const gridElement = this.getGridRootEl();
          if (gridElement) {
            gridElement.onmousewheel = () => {
            return true
          }
          }
        }
        numericTextBox = $(strinput).appendTo(container).kendoNumericTextBox(parameter).data("kendoNumericTextBox");
        this.$nextTick(() => {
          const gridElement = this.getGridRootEl();
          if (gridElement) {
            gridElement.onmousewheel = () => {
            return false
          }
          }
          const closeNumericCellEditor = () => {
            const gridElement = this.getGridRootEl();
            if (gridElement) {
              gridElement.onmousewheel = () => {
                return true
              }
            }
            numericTextBox?.trigger("change");
            this.directGridNumericEditKeepUntil = 0;
            this.directGridWidget?.closeCell?.();
          };
          const handleNumericWheel = event => {
            markNumericEdit();
            event.preventDefault();
            event.stopPropagation();
            event.stopImmediatePropagation?.();
            const originalEvent = event.originalEvent || event;
            let delta = (originalEvent.wheelDelta && (originalEvent.wheelDelta > 0 ? 1 : -1)) ||
                        (originalEvent.deltaY && (originalEvent.deltaY < 0 ? 1 : -1)) ||
                        (originalEvent.detail && (originalEvent.detail < 0 ? 1 : -1))
            let value = getNumericEditorValue()
            if (delta > 0) {
              // 滑ります
              value += parameterStep
            } else {
              // 下がります
              value -= parameterStep
            }
            // 数値範囲内かどうかの確認
            if (value > parameterMax) {
              value = parameterMin
            } else if (value <  parameterMin) {
              value = parameterMax
            }
            setNumericEditorValue(value)
          }
          const wheelTargets = [
            numericTextBox?.element?.get?.(0),
            numericTextBox?._text?.get?.(0),
            numericTextBox?.wrapper?.get?.(0)
          ].filter((target, index, targets) => target && targets.indexOf(target) === index);
          wheelTargets.forEach(target => {
            target.addEventListener("wheel", handleNumericWheel, { capture: true, passive: false });
            target.addEventListener("mousewheel", handleNumericWheel, { capture: true, passive: false });
            target.addEventListener("DOMMouseScroll", handleNumericWheel, { capture: true, passive: false });
          });
          numericTextBox.element.on("keydown", (event) => {
            if (event.key === "Enter") {
              event.preventDefault();
              closeNumericCellEditor();
              return;
            }
            markNumericEdit();
          })
          numericTextBox.element.on("blur", () => {
            this.directGridNumericEditKeepUntil = 0;
            const gridElement = this.getGridRootEl();
            if (gridElement) {
              gridElement.onmousewheel = () => {
                return true
              }
            }
            //6954 【EOL対応内部】【P-Ca9分割グラフ設定マスタ】报错 start zhao
            if(numericTextBox){
              numericTextBox.trigger('change')
            }
            //6954 【EOL対応内部】【P-Ca9分割グラフ設定マスタ】报错 end zhao
          })
          numericTextBox.element.css("text-align", "right");
          numericTextBox._text?.css?.("text-align", "right");
        })
        // mod #5589 2023/04/10 数値IFのスタイル全不正 林峻峰 end
      }else if(data.model.inputType == 1){
        if(data.model.dispValue.toString().startsWith('#')) {
          const dummyField = $(`<input type="color" data-bind="value:dispValue" style="inline-size: 50px !important;" />`).appendTo(container);
          this.$nextTick(() => {
            const colorInput = dummyField[0];
            const ownerWindow = colorInput?.ownerDocument?.defaultView || window;
            ownerWindow.requestAnimationFrame(() => {
              colorInput?.focus?.({ preventScroll: true });
              try {
                colorInput?.showPicker?.();
              } catch (_error) {
                colorInput?.click?.();
              }
            });
          });
        }else{
          $(`<textarea name="${data.field}" class="k-valid k-textarea" style="font-size: 1.0em;resize: vertical;width: 100%;height: 100%;max-height: 65vh;"/>`).appendTo(container)
          // $(`<input type="text" class="k-input k-textbox k-valid" name="${data.field}" maxlength="128" data-bind="value:dispValue"/>`).appendTo(container)
        }

      }else if(data.model.inputType == 6){
        $('<textarea data-text-field="Label" class="k-textbox k-valid" data-value-field="Value" data-bind="value:dispValue" style="width: ' + (container.width() - 10) + 'px;height:' + (container.height() - 12) + 'px;margin-top:10px;margin-bottom:10px" />').appendTo(container);

      }else{
        this.editingFlg = false;
        $(`<label>${data.model.value}</label>`).appendTo(container);
      }
    },
    onSave(ev) {
      this.onDirectGridSave(ev);
    },
    /**
     * 編集終了時に、初期値とセルの値が同一か判定し、同一の場合はGrid行のdirty状態を解除する
     * @param {Object} e - KendoGridのイベント引数
     */
    handleUnchangedState(e) {
      const originalDataSource = Array.isArray(this.originalDataSource)
        ? this.originalDataSource
        : [];
      if (originalDataSource.length === 0 || !e?.model || !e?.values) {
        return;
      }

      const { graphSettingNo } = e.model;
      const originalItem = originalDataSource.find(item => {
        return String(item.graphSettingNo) === String(graphSettingNo);
      });
      if (!originalItem) {
        return;
      }

      const editField = Object.keys(e.values)[0];
      if (editField == null) {
        return;
      }
      const editedValue = e.values[editField];
      const originalValue = [4, 5, 9].includes(Number(e.model.inputType))
        ? originalItem?.value
        : originalItem?.[editField];

      const isUnchanged = isEqual(originalValue, editedValue);

      if (isUnchanged) {
        delete e.model.operation;
        e.model.edited = false;
        if (e.model.dirtyFields) {
          Object.keys(e.model.dirtyFields).forEach(k => delete e.model.dirtyFields[k]);
        }
        e.model.dirty = false;
        return true;
      }
      return false;
    },
    cancel() {
      // 前画面に戻る
      // 編集破棄確認はMasterRecordView.vueで行う
      this.$router.go(-1);
    }
  },
  created() {
    this.setUserType(this.getStateUserAccountInfo.userType);
    this.setLoadingScreenVisible(true);
    // add マスタ一覧 1･施設切替を可能とする 王 start
    // this.findFacilityList();
    this.facilitylistValue = this.getFacilitySwitch
    this.findList();
    // add マスタ一覧 1･施設切替を可能とする 王 end
    this.setCondition(this.condition);
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
    EventBus.$on("refresh", this.refresh);
  },
  mounted() {
    this.directGridMounted = true;
    this.kendoValidator = { validate: () => this.validateDirectKendoGrid() };
    this.$nextTick(() => {
      this.calculateGridHeight();
      this.initDirectGridIfReady();
      this.scheduleDirectGridLayoutContract();
    });
  },
  beforeUnmount() {
    EventBus.$off("refresh", this.refresh);
    [this.directGridLayoutRafId, this.directGridFilterRefreshRafId, this.directGridScrollSyncRafId].forEach(id => {
      if (id != null) {
        cancelAnimationFrame(id);
      }
    });
    this.directGridRowVisualRafIds?.forEach?.(id => cancelAnimationFrame(id));
    this.directGridRowVisualRafIds?.clear?.();
    this.destroyDirectGrid();
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
  padding: 5px 5px 5px 5px;
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
.content-style :deep(.k-grid-content){
  white-space: pre-wrap;
}
.custom-switch {
  transform: scale(0.85);
  transform-origin: center;
  touch-action: manipulation;
}
.mst-graph-setting-direct-jq-grid {
  width: 100%;
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

/* theme.css の line-height: 2em !important を上書き（jq 生成 td は scoped 直指定不可のため :deep） */
.master-maintenance-page :deep(.ntss-kendo-grid-legacy td),
.master-maintenance-page :deep(.ntss-kendo-grid-legacy .k-table-td) {
  line-height: 1.5em !important;
}
</style>
