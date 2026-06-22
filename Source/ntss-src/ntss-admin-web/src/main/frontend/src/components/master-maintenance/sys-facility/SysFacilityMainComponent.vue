<template>
  <div class="main-content-area master-maintenance-page">
    <div class="ntss-list" :style="ntssListStyles">
      <div
        :class="['k-grid-toolbar', 'k-header', 'kendo-grid-toolbar-style']"
        :style="heightStyles"
      >
        <div :class="['header-btn-area', 'right', isMobileDevice ? 'mobile-header' : '']">
          <v-ons-button
            v-show="!isSortMode && isAllowAddRecord"
            style="float: left;"
            modifier="outline"
            class="btn3-normal toolbar-btn"
            @click="addRow()"
          >
            追加
          </v-ons-button>
          <v-ons-row v-show="isMobileDevice" style="float: left; width: 6em; height: 1em;">
            <v-ons-col width="45%" vertical-align="center">
              <label class="fab-font-color">編集</label>
            </v-ons-col>
            <v-ons-col width="55%" vertical-align="center">
              <v-ons-switch modifier="outline" style="float: left; margin-left: 2px;" v-model="allowEdit"></v-ons-switch>
            </v-ons-col>
          </v-ons-row>
          <v-ons-button
            modifier="outline"
            class="btn3-normal toolbar-btn csv-btn"
            style="margin-right: 10px;"
            v-show="!isSortMode && isAllowAddRecord"
            @click="importCsv($event)"
            >CSV取込
          </v-ons-button>
          <!-- delete #6217 全施設マスタ画面が遅い guanhao start-->
          <!-- add redmine 4490 全施設マスタの並び順 鞠 start -->
          <!-- <v-ons-button
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
          </v-ons-button>-->
          <!-- add redmine 4490 全施設マスタの並び順 鞠 end -->
          <!-- delete #6217 全施設マスタ画面が遅い guanhao end-->
        </div>
        <!-- ソート後グリッド表示 -->
        <div
          v-show="isSortChacked"
          id="grid-font-size"
          ref="grid"
          :class="[
            fontSizeSet,
            'ntss-kendo-grid-legacy',
            'sys-facility-direct-jq-grid'
          ]"
          style="clear: both;"
        ></div>
      </div>
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
    <master-csv
      :popoverVisible="masterCsvVisible"
      :popoverTarget="masterCsvTarget"
      @popover-close="prehideCsvPopover"
    />
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
import { markRaw } from "@/compat/vue/runtime";
import _ from "@/compat/collections/lodash";
import dayjs from "@/compat/date/dayjs";
import { ApiHelper } from "@/apis/AxiosHelper";
import { mapActions, mapGetters, mapMutations, mapState } from "@/compat/vue/vuex";
import { EventBus } from "@/compat/vue/event-bus.js";
import messageDialog from "@/components/common/message-dialog/MessageDialog";
import MasterCsvComponent from "@/components/master-maintenance/MasterCsvComponent";

//FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages.js";
import { messageFormat } from "@/functions/common/MessageFormat";
import $ from "jquery";
import kendo from "@progress/kendo-ui";
import {
  createJQueryValidator,
  destroyJQueryValidator,
} from "@/compat/kendo/kendo-jquery.js";
import {
  bindGridEditorEnterToCloseCell,
  bindGridEditorDropDownListToCloseCell,
  getGridEditorDropDownListWidget,
} from "@/compat/kendo/grid-edit";
import { appendFirstValidationCallout } from "@/functions/common/KendoFunctions";
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start


function cloneDataSourceOption(source) {
  const option = {
    data: Array.isArray(source?.data) ? source.data : [],
    schema: source?.schema || undefined,
    pageSize: source?.pageSize || undefined,
    sort: source?.sort || undefined,
    filter: source?.filter || undefined
  };
  Object.keys(option).forEach(key => {
    if (option[key] === undefined) {
      delete option[key];
    }
  });
  return option;
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
    "message-dialog": messageDialog,
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
      updateResponse: {
        isSuccess: false,
        errorMessage: ""
      },
      isSortMode: false,
      masterCsvVisible: false,
      masterCsvTarget: null,
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
      lastScrollTop: 0,
      lastScrollLeft: 0,
      dataPageFlag: false,
      sysFacility: [],
      // 自画面の名称
      selfScreenName: "",
      lockedColumnsWidth: 0,
      directGridWidget: null,
      directGridDataSource: null,
      directGridMounted: false,
      directGridLayoutRafId: null,
      directGridFilterRefreshRafId: null,
      directGridScrollSyncRafId: null,
      directGridScrollRestoreTimerId: null,
      directGridProgrammaticScroll: false,
      directGridSuppressScrollRightUntil: 0,
      directGridSyncingScroll: false,
      directGridRowVisualRafIds: markRaw(new Map()),
      sysFacilityRowSnapshots: markRaw(new Map()),
      validationTooltipPlacementTimers: [],
      validationTooltipPlacementRafId: null,
      validationTooltipPlacementIntervalId: null,
      validationTooltipObserver: null,
      directGridResizeHandler: null,
      kendoValidator: null,
      // add #6217 全施設マスタ画面が遅い guanhao start
      scrollFlag: false,
      addRowScrollFlag: false,
      dataPageScrollFlag: false,
      offset: 0,
      sysFacilityDataTotal: null,
      keywordName: null,
      loadInsertRecords: null,
      // add #6217 全施設マスタ画面が遅い guanhao end
      // add 8130 全施設マスタでフリーズする 周安寧 start
      loadingFlag : true,
      // add 8130 全施設マスタでフリーズする 周安寧 end
      sysFacilityPageLoading: false,
      sysFacilityPageScrollRestorePending: false,
      sysFacilityPageScrollRestoreTimers: [],
      sysFacilityPageScrollRestoreRafId: null,
      sysFacilityPageScrollRestorePosition: { top: 0, left: 0 },
      sysFacilityLoading: false,
      sysFacilityLoadingCount: 0,
      sysFacilityListLoadToken: 0,
      sysFacilityPageLoadToken: 0,
      hasLoadedSysFacilityGrid: false,
      allowEdit: true, // NOTE: true = 編集モード、 false = 閲覧モード
      __pendingScrollToBottom: false,
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
      // add redmine 4490 全施設マスタの並び順 鞠 start
      isRecordModified: "isRecordModified",
      getFacilitySwitch: "getFacilitySwitch",
      comparisonRecordModel: "getComparisonRecordModel",
      masterRecordListRevision: "getMasterRecordListRevision",
      // add redmine 4490 全施設マスタの並び順 鞠 end
    }),
    ...mapGetters("mst-facility", {
      getMasterHashRecordList: "getMasterHashRecordList",
    }),
    // add start #9590
    ...mapState("master-maintenance", ["condition"]),
    // add end 9590

    /**
     * フォントサイズに応じたCSSセレクタを返す.
     * Vue2 では MasterMaintenanceMixin から提供されていたため、
     * direct jq 化した本画面側で同じ描画時点の computed として承接する。
     */
    fontSizeSet() {
      const names = ["small", "medium", "large", "x-large"];
      const fontSize = Number(this.getFontSize);
      const index = Number.isFinite(fontSize) && names[fontSize] ? fontSize : 0;
      return `font-size-set-${names[index]}`;
    },

    heightStyles() {
      // main部の高さをCSS変数を利用して書き換え
      return { "--height": `${this.kendoGridToolbarHeight}px` };
    },
    ntssListStyles() {
      const display = this.columns.length === 1 ? "none" : "inherit";
      const height = `${this.kendoGridToolbarHeight}px`;
      return {
        display,
        height,
        maxHeight: height,
        position: "relative",
        overflow: "hidden"
      };
    },
    masterRecords() {
      if (this.getMasterRecordList.length !== 0) {
        // delete #6217 全施設マスタ画面が遅い guanhao start
        // add redmine 4490 全施設マスタの並び順 鞠 start
        // this.sortRank();
        // add redmine 4490 全施設マスタの並び順 鞠 end
        // delete #6217 全施設マスタ画面が遅い guanhao end
        if (!this.isSortChacked) {
          // storeからデータ取得後施設コードでソート
          // mod+del redmine 4490 全施設マスタの並び順 鞠 start
          // this.sortRecords(this.getFilteredMasterRecordList.data);

          // 表示順を更新するため、storeに設定
          // this.setMasterRecordList(this.getFilteredMasterRecordList);
          this.setMasterRecordList(this.getMasterRecordList);
          // mod+del redmine 4490 全施設マスタの並び順 鞠 end
          // ソート後グリッドを表示
          this.showDisplay();
        }
      }

      // storeからデータを取得
      return this.getFilteredMasterRecordList;
    },
    masterConditionSignature() {
      const condition = this.condition || {};
      return `${condition.recordName || ""}|${condition.includeDeleted ? 1 : 0}`;
    },
    isAllowAddRecord() {
      // allowAddRecordが定義されていない場合は追加ボタンは使用不可
      return !(this.getColumnIndex("allowAddRecord") < 0);
    },
    // delete #6217 全施設マスタ画面が遅い guanhao start
    // isAllowSort() {
    //   // allowSortが定義されていない場合は並び替えボタンは使用不可
    //   return !(this.getColumnIndex("allowSort") < 0);
    // },
    // delete #6217 全施設マスタ画面が遅い guanhao end
    isAllowSort() {
      return !(this.getColumnIndex("allowSort") < 0);
    },
    isChanged() {
      if (this.getStateUserAccountInfo === null) {
        return false;
      }
      const data = this.getMasterRecordList?.data;
      if (data === undefined) {
        return false;
      }
      // edit / revert / 分页加载 後に確実に再評価させる
      void this.masterRecordListRevision;
      if (this.kendoValidator && !this.kendoValidator.validate()) {
        return true;
      }
      // 分页加载会导致 masterRecordList 行数增加，isRecordModified 整表对比会误判。
      // 本画面は行级快照对比 isSysFacilityRowEdited のみで保存ボタンを制御する。
      return this.isSorted || data.some(row => this.isSysFacilityRowEdited(row));
    },
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
        if (val.length > 1 && !this.sysFacilityLoading) {
          this.setLoadingScreenVisible(false);
        }
        if (val.length > 1) {
          this.initDirectGridIfReady();
          this.applyDirectGridColumnsContract();
          this.scheduleDirectGridLayoutContract();
        }
      });
    },
    masterConditionSignature() {
      this.scheduleDirectGridFilterRefresh();
    }
  },

  created() {
    // 共通ローダー:表示名設定
    this.setLoadingScreenMessage("処理中・・・");
    this.selfScreenName = this.$route.name;
    EventBus.$on("onCloseMasterEditModal", this.onCloseMasterEditModal);
    EventBus.$on("refresh", this.refresh);
    EventBus.$on("sysFacilityDataPage", this.sysFacilityDataPage);
    EventBus.$on("loadGridData", this.loadGridData);
    this.calculateColumnsWidth();
    this.loadGridData();
    // 端末判別
    const ua = ((this?.$el?.ownerDocument?.defaultView?.navigator?.userAgent) || globalThis?.navigator?.userAgent || "").toLowerCase();
    if (/android/.test(ua)) {
      this.androidFlg = true;
    } else if (/iphone|ipad|mac|os/.test(ua)) {
      this.iosFlg = true;
    }
  },
  // add 性能改善メモリ不足 shan start
  beforeUnmount() {
    EventBus.$off("onCloseMasterEditModal", this.onCloseMasterEditModal);
    EventBus.$off("refresh", this.refresh);
    // add #6217 全施設マスタ画面が遅い guanhao start
    (this.$el?.ownerDocument?.defaultView || window).removeEventListener("scroll", this.scrollRight,true);
    EventBus.$off("sysFacilityDataPage", this.sysFacilityDataPage);
    EventBus.$off("loadGridData", this.loadGridData);
    // add #6217 全施設マスタ画面が遅い guanhao end
    if (this.directGridResizeHandler) {
      (this.$el?.ownerDocument?.defaultView || window).removeEventListener("resize", this.directGridResizeHandler);
      this.directGridResizeHandler = null;
    }
    this.detachDirectGridScrollHandlers();
    this.clearSysFacilityPageScrollRestoreTimers();
    if (this.directGridScrollRestoreTimerId != null) {
      clearTimeout(this.directGridScrollRestoreTimerId);
      this.directGridScrollRestoreTimerId = null;
    }
    this.destroyDirectGrid();
    this.destroyDirectGridValidator();
    this.teardownValidationTooltipPlacement();
    this.setCondition({
      recordName: null,
      includeDeleted: false
    });
  },
  // add 性能改善メモリ不足 shan end
  mounted() {
    installComponentJQuery();
    this.directGridMounted = true;
    this.$nextTick(() => {
      this.initDirectGridValidator();
      this.calculateColumnsWidth();
      this.calculateGridHeight();
      this.calculateGridWidth();
      this.initDirectGridIfReady();
      this.scheduleDirectGridLayoutContract();
    });
    this.directGridResizeHandler = () => {
      this.calculateColumnsWidth();
      this.calculateGridHeight();
      this.calculateGridWidth();
      this.scheduleDirectGridLayoutContract();
    };
    (this.$el?.ownerDocument?.defaultView || window).addEventListener("resize", this.directGridResizeHandler);
    // add #6217 全施設マスタ画面が遅い guanhao start
    ApiHelper.get(`/master_maintenance/getTotal`).then((res) => {
      this.sysFacilityDataTotal = res.data
    });
    (this.$el?.ownerDocument?.defaultView || window).addEventListener("scroll", this.scrollRight,true);
    // add #6217 全施設マスタ画面が遅い guanhao end
  },


  methods: {
    ...mapActions("multi-modal", [
      "showMasterEdit",
    ]),
    ...mapActions("master-maintenance", [
      "findRecordList",
      "setMasterRecordList",
      "setComparisonRecordModel",
      "edit",
      "setCondition",
      "findColumnInfo",
    ]),
    ...mapMutations("master-maintenance", [
      "bumpMasterRecordListRevision",
    ]),
    // 共通ローダー設定
    ...mapActions("loading-screen", {
      setLoadingScreenVisible: "setLoadingScreenVisible",
      setLoadingScreenMessage: "setLoadingScreenMessage",
      resetLoadingScreenVisibleCount:  "resetLoadingScreenVisibleCount"
    }),

    importCsv(event) {
      // Vue2 MasterMaintenanceMixin と同じく、CSV ポップアップ表示前に
      // 現在の grid validator 時点を確認する。
      if (this.kendoValidator && !this.kendoValidator.validate()) {
        return;
      }
      const sourceEvent = event || window.event;
      this.masterCsvTarget = sourceEvent?.target || null;
      this.masterCsvVisible = true;
    },
    prehideCsvPopover() {
      // Vue2 の prehideCsvPopover と同じ時点で visible を閉じ、
      // popover close 後に direct jq grid の行状態色を再適用する。
      this.masterCsvVisible = false;
      this.editBackgroundColor();
    },

    cancel() {
      this.$router?.go?.(-1);
    },
    getColumnIndex(fieldName) {
      return this.columns.findIndex(column => column.field === fieldName);
    },
    calculateColumnsWidth() {
      const root = this.$el?.ownerDocument?.getElementById?.("app") || document.getElementById("app");
      const ownerWindow = root?.ownerDocument?.defaultView || window;
      const appWidth = root ? parseFloat(ownerWindow.getComputedStyle(root).width || 0) : ownerWindow.innerWidth;
      this.columnWidth = appWidth > 1000 ? 14 : 9;
      if (this.columnWidth < 10) {
        this.columnWidth = 10;
      }
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
      const headerHeight = header?.clientHeight || 0;
      const footerMenuHeight = (this.isDispMenu === 1 && footerMenu ? footerMenu.clientHeight : 0) + 5;
      const windowHeight = Number(this.windowHeight) || ownerWindow.innerHeight || 0;
      let toolbarHeight = windowHeight - headerHeight - footerMenuHeight;
      const list = this.$el?.querySelector?.(".ntss-list");
      const listTop = list?.getBoundingClientRect?.().top;
      const footerTop = this.isDispMenu === 1
        ? footerMenu?.getBoundingClientRect?.().top
        : ownerWindow.innerHeight;
      const actualListHeight = (Number.isFinite(listTop) && Number.isFinite(footerTop))
        ? footerTop - listTop - 5
        : NaN;
      if (Number.isFinite(actualListHeight) && actualListHeight > 100) {
        toolbarHeight = Math.min(toolbarHeight, actualListHeight);
      }
      this.kendoGridToolbarHeight = Math.max(100, toolbarHeight);
      const gridHeader = this.$el?.querySelector?.(".header-btn-area");
      const gridFooter = this.$el?.querySelector?.("#grid-footer");
      const gridHeaderHeight = gridHeader?.clientHeight || 0;
      const gridFooterHeight = gridFooter?.clientHeight || 0;
      this.kendoGridHeight = Math.max(160, this.kendoGridToolbarHeight - gridHeaderHeight - gridFooterHeight - 2);
      const root = this.getDirectGridRoot?.();
      if (root) {
        root.style.height = `${this.kendoGridHeight}px`;
        root.style.maxHeight = `${this.kendoGridHeight}px`;
      }
    },
    calculateGridWidth() {
      this.resizeDirectGrid();
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
    },
    beginDirectGridProgrammaticScroll(duration = 200) {
      this.directGridProgrammaticScroll = true;
      this.directGridSuppressScrollRightUntil = Date.now() + duration;
      if (this.directGridScrollRestoreTimerId != null) {
        clearTimeout(this.directGridScrollRestoreTimerId);
      }
      this.directGridScrollRestoreTimerId = setTimeout(() => {
        this.directGridProgrammaticScroll = false;
        this.directGridScrollRestoreTimerId = null;
      }, duration);
    },
    isDirectGridProgrammaticScroll() {
      return this.directGridProgrammaticScroll || Date.now() < (this.directGridSuppressScrollRightUntil || 0);
    },
    beginDirectGridScrollSync() {
      this.directGridSyncingScroll = true;
      requestAnimationFrame(() => {
        this.directGridSyncingScroll = false;
      });
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
      }
      if (Number.isFinite(left)) {
        this.lastScrollLeft = left;
        this.scrollPosition.left = left;
      }
    },
    restoreGridScrollPosition(position = this.scrollPosition) {
      const restorePosition = {
        top: Number(position?.top) || 0,
        left: Number(position?.left) || 0
      };
      this.$nextTick(() => {
        this.setGridScrollPosition(restorePosition);
        requestAnimationFrame(() => this.setGridScrollPosition(restorePosition));
        setTimeout(() => this.setGridScrollPosition(restorePosition), 0);
      });
    },
    captureDirectGridScrollBeforeEditClose() {
      const current = this.getGridScrollPosition();
      const top = current.top > 0
        ? current.top
        : (this.scrollPosition.top ?? this.lastScrollTop ?? 0);
      const left = current.left > 0
        ? current.left
        : (this.scrollPosition.left ?? this.lastScrollLeft ?? 0);
      this.rememberGridScrollPosition({ top, left });
      return { top, left };
    },
    scheduleDirectGridPostColumnScrollSync(position = this.scrollPosition) {
      if (this.directGridScrollSyncRafId != null) {
        cancelAnimationFrame(this.directGridScrollSyncRafId);
      }
      this.directGridScrollSyncRafId = requestAnimationFrame(() => {
        this.restoreGridScrollPosition(position);
        this.directGridScrollSyncRafId = requestAnimationFrame(() => {
          this.directGridScrollSyncRafId = null;
          this.restoreGridScrollPosition(position);
        });
      });
    },
    scheduleDirectGridDropDownRefreshIfNeeded(ev, dropDownWidget, savedScroll) {
      if (!dropDownWidget) {
        return;
      }
      const position = savedScroll || this.captureDirectGridScrollBeforeEditClose();
      this.$nextTick(() => {
        try {
          ev?.sender?.refresh?.();
        } catch (_error) {
          // noop
        }
        this.setGridScrollPosition(position);
        this.scheduleDirectGridPostColumnScrollSync(position);
      });
    },
    clearSysFacilityPageScrollRestoreTimers() {
      (this.sysFacilityPageScrollRestoreTimers || []).forEach(timerId => clearTimeout(timerId));
      this.sysFacilityPageScrollRestoreTimers = [];
      if (this.sysFacilityPageScrollRestoreRafId != null) {
        cancelAnimationFrame(this.sysFacilityPageScrollRestoreRafId);
        this.sysFacilityPageScrollRestoreRafId = null;
      }
    },
    normalizeGridScrollPosition(position = {}) {
      return {
        top: Math.max(0, Number(position.top) || 0),
        left: Math.max(0, Number(position.left) || 0)
      };
    },
    restoreSysFacilityPageScrollPosition(position = this.sysFacilityPageScrollRestorePosition) {
      const content = this.getGridScrollHostEl();
      if (!content) {
        return false;
      }
      const nextPosition = this.normalizeGridScrollPosition(position);
      const maxTop = Math.max(0, (content.scrollHeight || 0) - (content.clientHeight || 0));
      const maxLeft = Math.max(0, (content.scrollWidth || 0) - (content.clientWidth || 0));
      nextPosition.top = Math.min(nextPosition.top, maxTop);
      nextPosition.left = Math.min(nextPosition.left, maxLeft);
      this.lastScrollTop = nextPosition.top;
      this.lastScrollLeft = nextPosition.left;
      this.scrollPosition.top = nextPosition.top;
      this.scrollPosition.left = nextPosition.left;
      this.setGridScrollPosition(nextPosition);
      return Math.abs((content.scrollTop || 0) - nextPosition.top) <= 1;
    },
    scheduleSysFacilityPageScrollRestore(position = this.getGridScrollPosition()) {
      this.clearSysFacilityPageScrollRestoreTimers();
      this.sysFacilityPageScrollRestorePending = true;
      this.sysFacilityPageScrollRestorePosition = this.normalizeGridScrollPosition(position);
      this.rememberGridScrollPosition(this.sysFacilityPageScrollRestorePosition);
      let attempt = 0;
      const maxAttempt = 18;
      const restore = () => {
        this.sysFacilityPageScrollRestoreRafId = null;
        const stable = this.restoreSysFacilityPageScrollPosition(this.sysFacilityPageScrollRestorePosition);
        attempt += 1;
        if (this.sysFacilityPageScrollRestorePending && attempt < maxAttempt) {
          this.sysFacilityPageScrollRestoreRafId = requestAnimationFrame(restore);
          return;
        }
        this.sysFacilityPageScrollRestoreTimers.push(setTimeout(() => {
          this.restoreSysFacilityPageScrollPosition(this.sysFacilityPageScrollRestorePosition);
          this.sysFacilityPageScrollRestorePending = false;
          this.sysFacilityPageLoading = false;
          this.clearSysFacilityPageScrollRestoreTimers();
        }, stable ? 40 : 120));
      };
      this.$nextTick(() => {
        this.sysFacilityPageScrollRestoreRafId = requestAnimationFrame(restore);
      });
    },
    getDirectGridRecordKey(record) {
      if (!record) {
        return "";
      }
      return String(record.code ?? record.medicalInstitutionCd ?? record.uid ?? record.id ?? "");
    },
    filterSysFacilityDisplayRows(rows = []) {
      if (!rows.length) {
        return rows;
      }
      const visibleKeys = new Set(
        (this.getFilteredMasterRecordList?.data || [])
          .map(row => this.getDirectGridRecordKey(row))
          .filter(Boolean)
      );
      return rows.filter(row => {
        const key = this.getDirectGridRecordKey(row);
        return key && visibleKeys.has(key);
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
    appendSysFacilityPageRowsToDirectGrid(rows = [], position = this.getGridScrollPosition()) {
      const grid = this.directGridWidget;
      const dataSource = grid?.dataSource;
      if (!grid || !dataSource || !rows.length || typeof dataSource.insert !== "function") {
        this.applyDirectGridDataSourceContract({ preserveScroll: true });
        this.scheduleSysFacilityPageScrollRestore(position);
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
        this.scheduleSysFacilityPageScrollRestore(position);
        return;
      }
      this.batchAppendDirectGridDataSourceRows(dataSource, appendRows);
      this.scheduleDirectGridLayoutContract(position);
      this.scheduleSysFacilityPageScrollRestore(position);
    },
    detachDirectGridScrollHandlers() {
      const content = this.getDirectGridScrollContent?.();
      const lockedContent = this.getDirectGridLockedScrollContent?.();
      content?.removeEventListener?.("scroll", this.onDirectGridScrollableScroll);
      lockedContent?.removeEventListener?.("scroll", this.onDirectGridLockedScroll);
    },
    attachDirectGridScrollHandlers() {
      const content = this.getDirectGridScrollContent();
      const lockedContent = this.getDirectGridLockedScrollContent();
      if (!content) {
        return;
      }
      content.removeEventListener("scroll", this.onDirectGridScrollableScroll);
      content.addEventListener("scroll", this.onDirectGridScrollableScroll, { passive: true });
      if (lockedContent) {
        lockedContent.removeEventListener("scroll", this.onDirectGridLockedScroll);
        lockedContent.addEventListener("scroll", this.onDirectGridLockedScroll, { passive: true });
      }
    },
    onDirectGridScrollableScroll(event) {
      const content = event?.currentTarget || this.getDirectGridScrollContent();
      const lockedContent = this.getDirectGridLockedScrollContent();
      if (!content) {
        return;
      }
      const syncing = this.directGridSyncingScroll;
      this.rememberGridScrollPosition({ top: content.scrollTop || 0, left: content.scrollLeft || 0 });
      if (lockedContent && Math.abs((lockedContent.scrollTop || 0) - (content.scrollTop || 0)) > 1) {
        this.beginDirectGridScrollSync();
        lockedContent.scrollTop = content.scrollTop || 0;
      }
      if (!this.isDirectGridProgrammaticScroll() && !syncing) {
        this.scrollRight();
      }
    },
    onDirectGridLockedScroll(event) {
      const lockedContent = event?.currentTarget || this.getDirectGridLockedScrollContent();
      const content = this.getDirectGridScrollContent();
      if (!lockedContent || !content) {
        return;
      }
      const syncing = this.directGridSyncingScroll;
      if (Math.abs((content.scrollTop || 0) - (lockedContent.scrollTop || 0)) > 1) {
        this.beginDirectGridScrollSync();
        content.scrollTop = lockedContent.scrollTop || 0;
      }
      this.rememberGridScrollPosition({ top: lockedContent.scrollTop || 0, left: content.scrollLeft || 0 });
      if (!this.isDirectGridProgrammaticScroll() && !syncing) {
        this.scrollRight();
      }
    },
    onCloseMasterEditModal() {
      this.$nextTick(() => this.setGridScrollPosition(this.scrollPosition));
      setTimeout(() => this.setGridScrollPosition(this.scrollPosition), 1000);
    },
    refresh() {
      if (this.selfScreenName !== this.$route.name) {
        return;
      }
      const alertDialogs = Array.from((this.$el?.ownerDocument || document).getElementsByTagName("ons-alert-dialog"));
      if (alertDialogs.length > 0) {
        return;
      }
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
    },

    getDirectGridRoot() {
      return this.$refs.grid || null;
    },
    getDirectGridWidget() {
      return this.directGridWidget || $(this.getDirectGridRoot()).data("kendoGrid") || null;
    },
    getGridWidget() {
      return this.getDirectGridWidget();
    },
    getGridRootEl() {
      return this.getDirectGridRoot();
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
    getGridHeaderEl() {
      return this.getDirectGridRoot()?.querySelector?.(".k-grid-header") || null;
    },
    getGridHeaderWrapEl() {
      return this.getDirectGridRoot()?.querySelector?.(".k-grid-header-wrap") || null;
    },
    getGridTableEl() {
      return this.directGridWidget?.table?.[0] || this.getDirectGridRoot()?.querySelector?.(".k-grid-content table") || null;
    },
    getGridTbodyEl() {
      return this.directGridWidget?.tbody?.[0] || this.getDirectGridRoot()?.querySelector?.(".k-grid-content tbody") || null;
    },
    getGridLockedTbodyEl() {
      return this.getDirectGridRoot()?.querySelector?.(".k-grid-content-locked tbody") || null;
    },
    getDirectGridScrollContent() {
      return this.getDirectGridRoot()?.querySelector?.(".k-grid-content") || null;
    },
    getDirectGridLockedScrollContent() {
      return this.getDirectGridRoot()?.querySelector?.(".k-grid-content-locked") || null;
    },
    getDirectGridDisplayDataSourceOption() {
      return cloneDataSourceOption(this.getFilteredMasterRecordList || this.getMasterRecordList || {});
    },
    createDirectGridDataSource() {
      this.directGridDataSource = markRaw(new kendo.data.DataSource(this.getDirectGridDisplayDataSourceOption()));
      return this.directGridDataSource;
    },
    buildDirectGridColumns() {
      return (this.columns || []).map(column => {
        const gridColumn = { ...column };
        if (column.field === "medicalInstitutionCd") {
          gridColumn.editor = (container, options) => this.medicalInstitutionCdEditor(container, options);
        } else if (column.field === "isDisp") {
          gridColumn.editor = (container, options) => this.isDispEditor(container, options);
        }
        if (column.field === "name") {
          gridColumn.attributes = { ...(gridColumn.attributes || {}), class: "facility-name" };
        }
        return gridColumn;
      });
    },
    initDirectGridIfReady(options = {}) {
      const root = this.getDirectGridRoot();
      if (!this.directGridMounted || !root || this.columns.length <= 1 || !this.isSortChacked) {
        return;
      }
      installComponentJQuery();
      const existingGrid = $(root).data("kendoGrid");
      if (existingGrid) {
        this.directGridWidget = markRaw(existingGrid);
        this.applyDirectGridColumnsContract();
        this.applyDirectGridDataSourceContract({ preserveScroll: true });
        this.scheduleDirectGridLayoutContract();
        this.$nextTick(() => {
          this.installValidationTooltipPlacementObserver();
        });
        return;
      }
      this.applyDirectGridLegacyShellClasses();
      $(root).kendoGrid({
        dataSource: this.createDirectGridDataSource(),
        columns: this.buildDirectGridColumns(),
        editable: true,
        selectable: true,
        reorderable: false,
        height: this.kendoGridHeight,
        scrollable: true,
        beforeEdit: event => this.modifyEditStart(event),
        edit: event => this.onDirectGridEdit(event),
        cellClose: event => this.editEnd(event),
        save: event => this.onDirectGridSave(event),
        dataBound: event => {
          this.directGridWidget = markRaw(event?.sender || this.directGridWidget);
          this.onDataBoundKendoGrid(event);
        }
      });
      this.directGridWidget = markRaw($(root).data("kendoGrid"));
      this.installDirectGridFacade();
      this.applyDirectGridLegacyStyleContract();
      this.scheduleDirectGridLayoutContract();
      this.$nextTick(() => {
        this.installValidationTooltipPlacementObserver();
      });
    },
    installDirectGridFacade() {
      const root = this.getDirectGridRoot();
      if (!root) {
        return;
      }
      root.kendoWidget = () => this.directGridWidget;
      root.gridWidget = () => this.directGridWidget;
      root.gridRootEl = () => root;
      root.gridElement = () => this.directGridWidget?.element;
      root.gridWrapper = () => this.directGridWidget?.wrapper;
      root.gridContentEl = () => this.getDirectGridScrollContent();
      root.gridScrollHostEl = () => this.getDirectGridScrollContent();
      root.gridAutoScrollableEl = () => this.getDirectGridScrollContent();
      root.gridLockedContentEl = () => this.getDirectGridLockedScrollContent();
      root.gridLockedContentEls = () => Array.from(root.querySelectorAll(".k-grid-content-locked"));
      root.gridLockedHeaderEls = () => Array.from(root.querySelectorAll(".k-grid-header-locked"));
      root.gridTableEl = () => this.directGridWidget?.table?.[0] || root.querySelector(".k-grid-content table");
      root.gridLockedTableEl = () => root.querySelector(".k-grid-content-locked table");
      root.gridTheadEl = () => this.directGridWidget?.thead?.[0] || root.querySelector(".k-grid-header-wrap thead");
      root.gridTbodyEl = () => this.directGridWidget?.tbody?.[0] || root.querySelector(".k-grid-content tbody");
      root.gridLockedTbodyEl = () => root.querySelector(".k-grid-content-locked tbody");
      root.gridDataItem = row => this.directGridWidget?.dataItem?.(row);
      root.gridDataSource = () => this.directGridWidget?.dataSource;
      root.gridColumns = () => this.directGridWidget?.columns || [];
      root.setGridDataSource = dataSource => this.setGridDataSource(dataSource);
      root.requestGridResize = () => this.resizeDirectGrid();
      root.scrollGridTo = position => this.setGridScrollPosition(position);
    },
    destroyDirectGrid() {
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
      if (this.directGridWidget) {
        try {
          this.directGridWidget.destroy();
        } catch (_error) {
          // noop
        }
      }
      const root = this.getDirectGridRoot();
      if (root) {
        $(root).empty();
      }
      this.directGridWidget = null;
      this.directGridDataSource = null;
      this.teardownValidationTooltipPlacement();
    },
    initDirectGridValidator() {
      const root = this.$el?.querySelector?.(".ntss-list");
      if (!root) {
        this.kendoValidator = { validate: () => true };
        return;
      }
      destroyJQueryValidator(root);
      const baseValidator = createJQueryValidator(root, this.kendoValidatorSetup || {});
      if (!baseValidator || typeof baseValidator.validate !== "function") {
        this.kendoValidator = { validate: () => true };
        return;
      }
      const originalValidate = baseValidator.validate.bind(baseValidator);
      this.kendoValidator = {
        validate: () => {
          const result = originalValidate();
          this.$nextTick(() => {
            this.handleAddValidateArrow();
            this.scheduleValidationTooltipPlacement();
          });
          return result;
        }
      };
    },
    destroyDirectGridValidator() {
      destroyJQueryValidator(this.$el?.querySelector?.(".ntss-list"));
      this.kendoValidator = null;
    },
    setGridDataSource(dataSource) {
      if (!this.directGridWidget?.dataSource) {
        return;
      }
      const position = this.getGridScrollPosition();
      this.rememberGridScrollPosition(position);
      const option = Array.isArray(dataSource)
        ? { data: dataSource }
        : cloneDataSourceOption(dataSource || this.getFilteredMasterRecordList || {});
      this.directGridWidget.dataSource.data(option.data || []);
      this.$nextTick(() => {
        this.applyDirectGridLegacyStyleContract();
        this.refreshDirectGridVisualState();
        this.scheduleDirectGridLayoutContract(position);
        this.restoreGridScrollPosition(position);
      });
    },
    applyDirectGridDataSourceContract(options = {}) {
      const { preserveScroll = false, resetScroll = false } = options;
      const grid = this.getDirectGridWidget();
      if (!grid?.dataSource) {
        this.initDirectGridIfReady();
        return;
      }
      const pos = this.getGridScrollPosition();
      if (preserveScroll) {
        this.rememberGridScrollPosition(pos);
      }
      const data = this.getDirectGridDisplayDataSourceOption().data || [];
      grid.dataSource.data(data);
      if (resetScroll) {
        this.rememberGridScrollPosition({ top: 0, left: 0 });
        this.setGridScrollPosition({ top: 0, left: 0 });
      } else if (preserveScroll) {
        this.restoreGridScrollPosition(pos);
      }
      this.$nextTick(() => {
        this.applyDirectGridLegacyStyleContract();
        this.refreshDirectGridVisualState();
        this.scheduleDirectGridLayoutContract(preserveScroll ? pos : this.scrollPosition);
        if (preserveScroll) {
          this.restoreGridScrollPosition(pos);
        }
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
        this.applyDirectGridDataSourceContract({ resetScroll: true });
      });
    },
    applyDirectGridColumnsContract() {
      const grid = this.getDirectGridWidget();
      if (!grid?.setOptions || this.columns.length <= 1) {
        return;
      }
      const position = this.getGridScrollPosition();
      const currentSignature = (grid.columns || [])
        .map(column => `${column.field}:${column.hidden ? 1 : 0}:${column.locked ? 1 : 0}`)
        .join("|");
      const nextSignature = (this.columns || [])
        .map(column => `${column.field}:${column.hidden ? 1 : 0}:${column.locked ? 1 : 0}`)
        .join("|");
      if (currentSignature !== nextSignature) {
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
      this.$nextTick(() => {
        this.setGridScrollPosition(position);
        this.applyDirectGridLegacyStyleContract();
        this.scheduleDirectGridLayoutContract();
      });
    },
    applyDirectGridLegacyShellClasses() {
      const root = this.getDirectGridRoot();
      if (!root) {
        return;
      }
      root.classList.add("ntss-kendo-grid-legacy", "k-widget", "k-grid", "k-editable", "k-display-block");
    },
    applyDirectGridLegacyStyleContract() {
      this.applyDirectGridLegacyShellClasses();
      const root = this.getDirectGridRoot();
      if (!root) {
        return;
      }
      root.querySelectorAll(".k-grid-header th, .k-grid-header [role='columnheader']").forEach(th => th.classList.add("k-header"));
      root.querySelectorAll(".k-grid-content tr, .k-grid-content-locked tr").forEach((tr, index) => {
        tr.classList.add("k-master-row");
        if (index % 2 === 1) {
          tr.classList.add("k-alt");
        }
      });
      root.querySelectorAll(".k-grid-content td, .k-grid-content-locked td").forEach(td => td.classList.add("k-td", "k-table-td"));
      this.applyDirectGridLockedWidthContract();
      this.applyDirectGridLockedHeightContract();
      this.applyDirectGridLockedScrollContract();
    },
    getDirectGridColumnWidthPx(width) {
      if (typeof width === "number") {
        return width;
      }
      if (typeof width !== "string") {
        return 0;
      }
      const parsed = parseFloat(width);
      if (!Number.isFinite(parsed)) {
        return 0;
      }
      if (width.endsWith("em")) {
        const root = this.getDirectGridRoot() || this.$el;
        const fontSize = parseFloat((root?.ownerDocument?.defaultView || window).getComputedStyle(root).fontSize) || 16;
        return parsed * fontSize;
      }
      return parsed;
    },
    applyDirectGridLockedWidthContract() {
      const root = this.getDirectGridRoot();
      if (!root) {
        return;
      }
      const lockedColumns = (this.columns || []).filter(column => column.locked && !column.hidden).length;
      const sortColumn = this.isSortMode ? 0 : 1;
      let lockedColumnWidth = (lockedColumns - sortColumn) * this.columnWidth;
      if (this.lockedColumnsWidth) {
        lockedColumnWidth = this.lockedColumnsWidth;
      }
      const lockedWidthCss = lockedColumnWidth === 0
        ? "10px"
        : (this.isSortMode ? `${lockedColumnWidth}em` : `calc(${lockedColumnWidth}em + 10px)`);
      const lockedTargets = [
        ".k-grid-header-locked",
        ".k-grid-content-locked"
      ];
      lockedTargets.forEach(selector => {
        root.querySelectorAll(selector).forEach(element => {
          element.style.width = lockedWidthCss;
          element.style.minWidth = lockedWidthCss;
        });
      });
      root.querySelectorAll(".k-grid-header-locked table, .k-grid-content-locked table").forEach(element => {
        element.style.width = "100%";
        element.style.minWidth = "100%";
      });

      const headerLocked = root.querySelector(".k-grid-header-locked");
      const contentLocked = root.querySelector(".k-grid-content-locked");
      const headerWrap = root.querySelector(".k-grid-header-wrap");
      const content = root.querySelector(".k-grid-content");
      if (!headerLocked || !contentLocked || !headerWrap || !content) {
        return;
      }
      const targetWidth = ((this.androidFlg || this.iosFlg) || lockedColumnWidth === 0) ? 0 : 14;
      headerWrap.style.marginLeft = "";
      content.style.marginLeft = "";
      if (root.clientWidth < headerLocked.clientWidth) {
        root.style.width = `${headerLocked.clientWidth + 100 + targetWidth}px`;
        headerWrap.style.width = `${100 + targetWidth}px`;
      } else {
        root.style.width = "auto";
        const headerWidth = root.clientWidth - headerLocked.clientWidth + targetWidth;
        headerWrap.style.width = `${Math.max(100, headerWidth)}px`;
        let contentWidth = root.clientWidth - contentLocked.clientWidth;
        if (!this.androidFlg && !this.iosFlg && lockedColumnWidth !== 0) {
          contentWidth += 17;
        }
        content.style.width = `${Math.max(100, contentWidth)}px`;
      }
    },
    applyDirectGridLockedHeightContract() {
      const content = this.getDirectGridScrollContent();
      const lockedContent = this.getDirectGridLockedScrollContent();
      if (!content || !lockedContent) {
        return;
      }
      const scrollbarHeight = Math.max(0, content.offsetHeight - content.clientHeight);
      const lockedHeight = Math.max(0, content.offsetHeight - (scrollbarHeight || 17));
      lockedContent.style.height = `${lockedHeight}px`;
      lockedContent.style.maxHeight = `${lockedHeight}px`;
    },
    applyDirectGridLockedScrollContract() {
      const content = this.getDirectGridScrollContent();
      const lockedContent = this.getDirectGridLockedScrollContent();
      if (!content || !lockedContent) {
        return;
      }
      this.beginDirectGridProgrammaticScroll();
      lockedContent.scrollTop = content.scrollTop;
      if (this.directGridScrollSyncRafId != null) {
        cancelAnimationFrame(this.directGridScrollSyncRafId);
      }
      this.directGridScrollSyncRafId = requestAnimationFrame(() => {
        this.directGridScrollSyncRafId = null;
        this.beginDirectGridProgrammaticScroll();
        lockedContent.scrollTop = content.scrollTop;
      });
    },
    scheduleDirectGridLayoutContract(position = this.scrollPosition) {
      if (this.sysFacilityPageScrollRestorePending) {
        position = this.sysFacilityPageScrollRestorePosition;
      }
      const restorePosition = {
        top: Number(position?.top) || 0,
        left: Number(position?.left) || 0
      };
      this.rememberGridScrollPosition(restorePosition);
      if (this.directGridLayoutRafId != null) {
        cancelAnimationFrame(this.directGridLayoutRafId);
      }
      this.directGridLayoutRafId = requestAnimationFrame(() => {
        this.resizeDirectGrid();
        this.applyDirectGridLegacyStyleContract();
        this.setGridScrollPosition(restorePosition);
        this.directGridLayoutRafId = requestAnimationFrame(() => {
          this.directGridLayoutRafId = null;
          this.resizeDirectGrid();
          this.applyDirectGridLegacyStyleContract();
          this.setGridScrollPosition(restorePosition);
        });
      });
    },
    resizeDirectGrid() {
      const grid = this.getDirectGridWidget();
      const root = this.getDirectGridRoot();
      if (root) {
        root.style.height = `${this.kendoGridHeight}px`;
        root.style.maxHeight = `${this.kendoGridHeight}px`;
      }
      if (grid?.wrapper) {
        grid.wrapper.height(this.kendoGridHeight);
      }
      if (grid?.element) {
        grid.element.height(this.kendoGridHeight);
      }
      if (grid?.options) {
        grid.options.height = this.kendoGridHeight;
      }
      if (grid?.resize) {
        grid.resize(true);
      }
    },
    getGridScrollPosition() {
      const content = this.getDirectGridScrollContent();
      if (content) {
        return { top: content.scrollTop || 0, left: content.scrollLeft || 0 };
      }
      return { top: this.scrollPosition?.top || 0, left: this.scrollPosition?.left || 0 };
    },
    setGridScrollPosition(position = {}) {
      const content = this.getDirectGridScrollContent();
      const lockedContent = this.getDirectGridLockedScrollContent();
      const grid = this.getDirectGridWidget();
      let appliedTop = Number(position.top);
      let appliedLeft = Number(position.left);
      this.beginDirectGridProgrammaticScroll();
      if (content) {
        if (Number.isFinite(appliedTop)) {
          const maxTop = Math.max(0, content.scrollHeight - content.clientHeight);
          content.scrollTop = Math.min(Math.max(0, appliedTop), maxTop);
          appliedTop = content.scrollTop || 0;
        }
        if (Number.isFinite(appliedLeft)) {
          const maxLeft = Math.max(0, content.scrollWidth - content.clientWidth);
          content.scrollLeft = Math.min(Math.max(0, appliedLeft), maxLeft);
          appliedLeft = content.scrollLeft || 0;
        }
      }
      if (grid?.content?.[0] && Number.isFinite(appliedLeft)) {
        grid.content[0].scrollLeft = appliedLeft;
      }
      const headerWrap = this.getGridHeaderWrapEl();
      if (headerWrap && Number.isFinite(appliedLeft)) {
        headerWrap.scrollLeft = appliedLeft;
      }
      if (grid && typeof grid._scrollLeft !== "undefined" && Number.isFinite(appliedLeft)) {
        grid._scrollLeft = appliedLeft;
      }
      if (lockedContent && Number.isFinite(appliedTop)) {
        lockedContent.scrollTop = appliedTop;
      }
      this.rememberGridScrollPosition({
        top: Number.isFinite(appliedTop) ? appliedTop : this.scrollPosition.top,
        left: Number.isFinite(appliedLeft) ? appliedLeft : this.scrollPosition.left
      });
    },
    syncDirectGridScrollToAddedRow() {
      const content = this.getDirectGridScrollContent();
      if (!content) {
        return;
      }
      const top = Math.max(0, content.scrollHeight - content.clientHeight);
      this.beginDirectGridProgrammaticScroll(300);
      this.setGridScrollPosition({ top, left: 0 });
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
    editBackgroundColor() {
      this.refreshDirectGridVisualState();
    },
    handleAddValidateArrow() {
      const scope = this.getDirectGridSearchRoot() || this.$el;
      this.$nextTick(() => {
        appendFirstValidationCallout(scope);
        this.scheduleValidationTooltipPlacement();
      });
    },
    getDirectGridSearchRoot() {
      const widget = this.directGridWidget;
      return widget?.wrapper?.[0] || widget?.element?.[0] || this.getDirectGridRoot() || null;
    },
    getDirectGridDataSourceItems() {
      const collection = this.directGridWidget?.dataSource?.data?.();
      return collection ? Array.from(collection) : [];
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
      if (activeField) {
        return activeField;
      }
      const container = ev?.container?.[0] || ev?.container;
      const cell = container?.closest?.("td") || container;
      return this.getDirectGridFieldFromCell(cell)
        || (Object.keys(ev?.values || {}).length === 1 ? Object.keys(ev.values)[0] : null);
    },
    getDirectGridFieldValidationMessage(field) {
      const schemaFields =
        this.directGridDataSource?.schema?.model?.fields
        || this.getMasterRecordList?.schema?.model?.fields
        || {};
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
    applyDirectGridEditorValidationMessage(cell, field) {
      const message = this.getDirectGridFieldValidationMessage(field);
      if (!message || !cell) {
        return;
      }
      const inputs = cell.matches?.("input, select, textarea")
        ? [cell]
        : Array.from(cell.querySelectorAll?.("input, select, textarea") || []);
      inputs.forEach(input => {
        input.setAttribute("required", "required");
        input.setAttribute("validationMessage", message);
      });
    },
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
      editCell?.querySelectorAll?.(".k-callout")?.forEach?.(callout => {
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
      const root = this.getDirectGridSearchRoot();
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
      root.querySelectorAll(".ntss-validation-above").forEach(element => {
        if (element !== editCell) {
          element.classList.remove("ntss-validation-above");
          this.resetValidationTooltipCalloutDirection(element);
        }
      });
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
    stopValidationTooltipPlacementWatch() {
      const ownerWindow = this.getDirectGridSearchRoot()?.ownerDocument?.defaultView || window;
      if (this.validationTooltipPlacementIntervalId) {
        ownerWindow.clearInterval?.(this.validationTooltipPlacementIntervalId);
        this.validationTooltipPlacementIntervalId = null;
      }
    },
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
    installValidationTooltipPlacementObserver() {
      this.teardownValidationTooltipPlacementObserver();
      const root = this.getDirectGridSearchRoot();
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
      scrollAreas.forEach(scrollArea => {
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
    clearValidationTooltipPlacementState() {
      this.getDirectGridSearchRoot()?.querySelectorAll?.(".ntss-validation-above")?.forEach?.(element => {
        element.classList.remove("ntss-validation-above");
        this.resetValidationTooltipCalloutDirection(element);
      });
    },
    teardownValidationTooltipPlacement() {
      this.clearValidationTooltipPlacementTimers();
      this.stopValidationTooltipPlacementWatch();
      this.teardownValidationTooltipPlacementObserver();
      this.clearValidationTooltipPlacementState();
    },
    onDirectGridEdit(ev) {
      bindGridEditorEnterToCloseCell(ev?.sender || this.directGridWidget, ev?.container);
      bindGridEditorDropDownListToCloseCell(ev?.sender || this.directGridWidget, ev?.container);
      const field = this.getDirectGridFieldFromEvent(ev);
      const cell = ev?.container?.[0] || ev?.container;
      if (field && cell) {
        this.applyDirectGridEditorValidationMessage(cell, field);
      }
      this.scheduleValidationTooltipPlacement();
      if (!cell) {
        return;
      }
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
    stripSysFacilityCompareFields(record) {
      const plain = typeof record?.toJSON === "function" ? record.toJSON() : { ...(record || {}) };
      ["operation", "edited", "dirty", "dirtyFields", "uid", "skipSearch", "sortInputTime", "upDate", "dummy"].forEach(key => {
        delete plain[key];
      });
      Object.keys(plain).forEach(key => {
        if (plain[key] === "") {
          plain[key] = null;
        }
      });
      return plain;
    },
    findSysFacilityOriginalRecord(record) {
      const key = this.getDirectGridRecordKey(record);
      if (key && this.sysFacilityRowSnapshots.has(key)) {
        return this.sysFacilityRowSnapshots.get(key);
      }
      try {
        return JSON.parse(this.comparisonRecordModel || "[]")
          .find(row => String(row.code) === String(record?.code)) || null;
      } catch {
        return null;
      }
    },
    rememberSysFacilityRowSnapshot(record) {
      const key = this.getDirectGridRecordKey(record);
      if (!key || this.sysFacilityRowSnapshots.has(key)) {
        return;
      }
      this.sysFacilityRowSnapshots.set(key, this.stripSysFacilityCompareFields(record));
    },
    clearSysFacilityRowSnapshots() {
      this.sysFacilityRowSnapshots?.clear?.();
    },
    isSysFacilityRowEdited(record) {
      if (Number(record?.operation) === 1) {
        return record?.edited === true;
      }
      const original = this.findSysFacilityOriginalRecord(record);
      if (!original) {
        return Number(record?.operation || 0) > 0 || record?.edited === true;
      }
      const current = this.stripSysFacilityCompareFields(record);
      const orig = this.stripSysFacilityCompareFields(original);
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
    clearSysFacilityRowIfMatchesOriginal(model) {
      if (!model || this.isSysFacilityRowEdited(model)) {
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
      const grid = this.getDirectGridWidget();
      if (!grid?.dataSource) {
        return;
      }
      Array.from(grid.dataSource.data() || []).forEach(record => this.applyDirectGridRowVisualState(record, record.uid));
    },
    scheduleDirectGridRowVisualState(record, uid = null, deferUntilCellClose = false) {
      const key = uid || record?.uid || record?.code || record?.medicalInstitutionCd || Math.random();
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
      const grid = this.getDirectGridWidget();
      if (!grid || !record) {
        return;
      }
      const rowUid = uid || record.uid;
      const rows = rowUid
        ? Array.from(this.getDirectGridRoot()?.querySelectorAll?.(`tr[data-uid='${rowUid}']`) || [])
        : [];
      const edited = this.isSysFacilityRowEdited(record);
      rows.forEach(row => {
        row.classList.toggle("master-edited-row", edited);
        if (!edited) {
          row.classList.remove("k-dirty-row");
          Array.from(row.children || []).forEach(cell => {
            cell.classList.remove("k-dirty-cell", "master-edited-cell");
            cell.querySelectorAll(".k-dirty").forEach(marker => marker.remove());
          });
        }
      });
    },
    syncDirectGridDataSourceToStore() {
      const grid = this.getDirectGridWidget();
      const records = this.getMasterRecordList;
      if (!grid?.dataSource || !Array.isArray(records?.data)) {
        return;
      }
      const displayData = Array.from(grid.dataSource.data() || []).map(item => item?.toJSON ? item.toJSON() : item);
      displayData.forEach(row => {
        const target = records.data.find(item =>
          (row.uid && item.uid === row.uid) ||
          (row.code != null && item.code === row.code) ||
          (row.medicalInstitutionCd != null && item.medicalInstitutionCd === row.medicalInstitutionCd)
        );
        if (target) {
          Object.keys(row).forEach(key => {
            if (key !== "uid") {
              target[key] = row[key];
            }
          });
        }
      });
      this.setMasterRecordList(records);
    },
    onDirectGridSave(ev) {
      const savedScroll = this.captureDirectGridScrollBeforeEditClose();
      const dropDownWidget = getGridEditorDropDownListWidget(ev?.container);
      this.editingFlg = false;
      const values = ev?.values && typeof ev.values === "object" && !Array.isArray(ev.values)
        ? ev.values
        : null;
      if (values && ev?.model) {
        Object.keys(values).forEach(field => {
          if (typeof ev.model.set === "function") {
            ev.model.set(field, values[field]);
          } else {
            ev.model[field] = values[field];
          }
        });
      }
      this.edit({ editRecord: ev.model, isSortMode: this.isSortMode });
      if (ev.model.operation === 1) {
        ev.model.edited = true;
      }
      this.clearSysFacilityRowIfMatchesOriginal(ev.model);
      const revertedToOriginal = !this.isSysFacilityRowEdited(ev.model);
      this.scheduleDirectGridRowVisualState(ev.model, ev.model.uid, revertedToOriginal);
      this.setGridScrollPosition(savedScroll);
      this.scheduleDirectGridPostColumnScrollSync(savedScroll);
      this.scheduleDirectGridDropDownRefreshIfNeeded(ev, dropDownWidget, savedScroll);
    },

    beginSysFacilityLoading() {
      this.sysFacilityLoadingCount += 1;
      if (!this.sysFacilityLoading) {
        this.sysFacilityLoading = true;
        this.setLoadingScreenVisible(true);
      }
    },
    endSysFacilityLoading() {
      this.sysFacilityLoadingCount = Math.max(0, this.sysFacilityLoadingCount - 1);
      if (this.sysFacilityLoadingCount === 0 && this.sysFacilityLoading) {
        this.sysFacilityLoading = false;
        this.setLoadingScreenVisible(false);
      }
    },
    beginSysFacilityListLoading() {
      this.sysFacilityListLoadToken += 1;
      // full list reload は、進行中の追加ページ応答を古いものとして扱う。
      this.sysFacilityPageLoadToken += 1;
      this.beginSysFacilityLoading();
      return this.sysFacilityListLoadToken;
    },
    isSysFacilityListLoadingActive(loadToken) {
      return loadToken === this.sysFacilityListLoadToken;
    },
    beginSysFacilityPageLoading() {
      this.sysFacilityPageLoadToken += 1;
      this.beginSysFacilityLoading();
      return this.sysFacilityPageLoadToken;
    },
    isSysFacilityPageLoadingActive(loadToken) {
      return loadToken === this.sysFacilityPageLoadToken;
    },
    hasSysFacilityRecordSchema() {
      return !!this.getMasterRecordList?.schema?.model?.fields;
    },

    // delete #6217 全施設マスタ画面が遅い guanhao start
    // // add 4490 全施設マスタの並び順 鞠 start
    // sortRank(){
    //   if (this.getMasterRecordList.data.length !=0 && this.getMasterRecordList.data[0].sortRank === null) {
    //     for (let i = 0; i < this.getMasterRecordList.data.length; i++) {
    //       this.getMasterRecordList.data[i].sortRank = i+1;
    //     }
    //   }
    // // #6231:is_disp 画面からの削除でロジック削除となります。ljg start
    // // for (let i = 0; i < this.getMasterRecordList.data.length; i++) {
    // //     this.getMasterRecordList.data[i].isDisp = '1';
    // // }
    // // #6231:is_disp 画面からの削除でロジック削除となります。ljg end
    // },
    // // add redmine 4490 全施設マスタの並び順 鞠 end
    // delete #6217 全施設マスタ画面が遅い guanhao end
    /**
     * @description 施設コード列のkendo editor
     */
    medicalInstitutionCdEditor(container, data) {
      // add 追加時に編集可能、他の状態は編集できません 宋qy start
      if (data.model.operation === 1) {
      // add 追加時に編集可能、他の状態は編集できません 宋qy end

        // 新規レコードは編集可なのでinput
        $(
          `<input type="text" name="${data.field}" maxlength="10" class="k-input k-textbox"
            required="true" validationmessage="医療機関コードは必須入力です。" />`
        ).appendTo(container);
      } else {
        // 編集不可時でもeditStart()が発火するため、ここでフラグをoffにする
        this.editingFlg = false;
        // 既存レコードはlabelにして編集させない
        $(`<label>${data.model.medicalInstitutionCd}</label>`).appendTo(container);
      }
    },

    /**
     * @description 削除列のkendo editor
     */
    isDispEditor(container, data) {
      if (data.model.operation === 1) {
        // 編集不可時でもeditStart()が発火するため、ここでフラグをoffにする
        this.editingFlg = false;
        // 新規レコードはlabelにして編集させない
        $(`<label></label>`).appendTo(container);
      } else {
        // 既存レコードは編集可
        $(container).kendoDropDownList({
          name: data.field,
          className: "k-textbox",
          dataSource: [
            { text: " ", value: "1" },
            { text: "削除", value: "0" },
          ],
          dataTextField: "text",
          dataValueField: "value",
          value: data.model[data.field]
        });
      }
    },
    // グリッドのデータ再表示
    gridDataRefresh() {
      this.applyDirectGridDataSourceContract({ preserveScroll: true });
    },
    // マスタ一覧のデータを取得
    async findList() {
      const loadToken = this.beginSysFacilityListLoading();
      try {
        // apiをコールして値を取得
        const preserveCurrent = this.hasLoadedSysFacilityGrid
          && Array.isArray(this.getMasterRecordList?.data)
          && this.getMasterRecordList.data.length > 0;
        const response = await this.findRecordList({ preserveCurrent });
        if (!this.isSysFacilityListLoadingActive(loadToken)) {
          return;
        }
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
          column.width = column.width ? column.width : "0";
        });
        this.columns = toFunction;

        // 横スクロールバーを表示するために列幅を指定
        this.columns.forEach(column => {
          // 「削除」のプルダウンが改行しない幅に調整
          // mod #7289-マスタの削除ボタンが縦表示になる 徐博 start
          // column.width = column.field === "isDisp" ? "8em" : (this.columnWidth + "em");
          column.width = column.field === "isDisp" ? "9em" : (this.columnWidth + "em");
          // add 削除の欄が広い 王 start
          // column.width = column.field === "isDel" ? "8em" : (this.columnWidth + "em");
          column.width = column.field === "isDel" ? "9em" : (this.columnWidth + "em");
          // mod #7289-マスタの削除ボタンが縦表示になる 徐博 end
          // add 削除の欄が広い 王 end

          if (this.androidFlg || this.iosFlg) {
            if (column.field === "medicalInstitutionCd") {
              column.width = "6em";
            }

            if (column.field === "prefecturesCd") {
              column.width = "5em"
            }

            if (column.field === "name") {
              column.width = "6em"
            }
          }

          // #9185 最小フォント、mst画面編集文字、テキストボックス幅を超えます linjunfeng start
          // #8612 ウィンドウサイズの変更で、マスタレイアウトが崩れる。林峻峰 start
          // if (column.locked && column.dataType === "string" && column.field === "name") {
          //   column.width = typeof column.width == 'string' ? Number(column.width.slice(0,-2)) * 15 : column.width * 15
          // }
          // #8612 ウィンドウサイズの変更で、マスタレイアウトが崩れる。林峻峰 end
          // #9185 最小フォント、mst画面編集文字、テキストボックス幅を超えます linjunfeng end
        });

        if (this.androidFlg || this.iosFlg) {
          this.lockedColumnsWidth = 17.5;
        }

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
        this.clearSysFacilityRowSnapshots();
        // Vue2 wrapper の data-source 評価で行われていた表示開始を direct jq 版では明示する
        this.setMasterRecordList(this.getMasterRecordList);
        this.showDisplay();
        // カラム幅等初期調整
        this.showSortColumn();
        this.hasLoadedSysFacilityGrid = true;
        this.$nextTick(() => {
          this.initDirectGridIfReady();
          this.calculateGridHeight();
          this.calculateGridWidth();
          this.scheduleDirectGridLayoutContract();
        });
        await this.findColumnInfo();
      } catch (error) {
        getErrorMessage('SysFacilityMainComponent.vue', 'findList', error);
      } finally {
        this.endSysFacilityLoading();
      }
    },
    async saveRecord() {
      // 共通ローダー:表示開始
      this.setLoadingScreenVisible(true);
      /* add スクロール位置を保存 楊 start */
      this.setLastScroll();
      /* add スクロール位置を保存 楊 end */
      this.syncDirectGridDataSourceToStore();
      // 必須チェック
      if (!this.isFilledRequired()) {
        //共通ローダー：表示終了
        this.setLoadingScreenVisible(false);
        return;
      }

      // 施設コードチェック
      if (!this.validateMmedicalInstitutionCd()) {
        //共通ローダー：表示終了
        this.setLoadingScreenVisible(false);
        return;
      }

      const keys = [
        "medicalInstitutionCd",
        "prefecturesCd",
        "facilityName",
        "facilityShortName",
        "jsdtFacilityCd",
        "facilityCd",
        "zipcd",
        "address",
        "addressKana",
        "phoneNo1",
        "phoneNo2",
        "faxNo1",
        "faxNo2"
      ];

      // 編集中のレコードを新規/更新/削除に分類
      const insertRecords = [];
      const updateRecords = [];
      const deleteCdList = [];
      for (const record of this.getUpdateRecordList) {
        if (record.operation === 1) {
          // 新規レコード
          insertRecords.push(record);
        } else if (record.operation === 2) {
          if (record.isDisp === "0") {
            // 削除レコード
            deleteCdList.push(record.medicalInstitutionCd);
          } else {
            // 更新レコード
            updateRecords.push(record);
          }
        }
      }

      // 登録日時・更新日時用の現在日時
      const now = dayjs().format("YYYY-MM-DDTHH:mm:ss.SSSZ");

      const serializedInsertRecords = insertRecords.map(record =>
        JSON.stringify({
          ..._.pick(record, keys),
          facilityName: record.name,
          // kendoのドロップダウンにnullが設定できないため擬似的に設定している未登録コード'00'をnullに変換
          prefecturesCd:
            record.prefecturesCd === "00" ? null : record.prefecturesCd,
          regDate: now,
          upDate: now
        })
      );

      // add #6217 全施設マスタ画面が遅い guanhao start
      this.loadInsertRecords = serializedInsertRecords;
      // add #6217 全施設マスタ画面が遅い guanhao end
      const serializedUpdateRecords = updateRecords.map(record =>
        JSON.stringify({
          ..._.pick(record, keys),
          facilityName: record.name,
          prefecturesCd:
            record.prefecturesCd === "00" ? null : record.prefecturesCd,
          upDate: now
        })
      );
      // add redmine 4490 全施設マスタの並び順 鞠 start
      const getMasterRecordList = this.getMasterRecordList.data.map(record => {
        return JSON.stringify({
          facilityCd : record.facilityCd,
          facilityName : record.name,
          medicalInstitutionCd: record.medicalInstitutionCd
        })
      });

      const getFacility = [this.getFacilitySwitch,this.masterPhysicalName];
      // add redmine 4490 全施設マスタの並び順 鞠 end
      const editRecord = {
        insertRecord: serializedInsertRecords,
        updateRecord: serializedUpdateRecords,
        deleteCdList,
        // add redmine 4490 全施設マスタの並び順 鞠 start
        getMasterRecordList:getMasterRecordList,
        getFacility : getFacility
        // add redmine 4490 全施設マスタの並び順 鞠 end
      };

      // apiをコールして値を保存
      let errFlg = false; // NOTE: 一意制約違反（409）で返却された場合、catch内でフラグをOnにし準正常として処理を終了する
      await ApiHelper.put("/mstInfo/saveSysFacility", editRecord).catch(
        error => {
          //FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
          getErrorMessage('SysFacilityMainComponent.vue', 'saveRecord', error);
          //FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
          //共通ローダー：表示終了
          this.setLoadingScreenVisible(false);
          if (error.response.status == 409) {
            errFlg = true;
            this.isDialogVisible = true;
            this.messageCd = 60000001;
            this.stringParams = ["医療機関コード"];
            return;
          } else {
            throw new Error(error);
          }
        }
      );
      if (errFlg) return; // NOTE : 重複エラーのため、後続の処理は行わせない

      this.$ons.notification.alert({
        // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
        // title: "更新完了",
        // message: "マスタ更新が完了しました。"
        title: DIALOG_MESSAGES[12000004].title,
        message: messageFormat(DIALOG_MESSAGES[12000004].message),
        // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
      });

      this.isSorted = false;
      // modify #6217 全施設マスタ画面が遅い guanhao start
      //await this.findList();
      const params = {
        insertRecord: serializedInsertRecords,
        limit: this.getMasterRecordList.data.length,
        keywordName : this.keywordName
      };
      let sysFacilityData = await ApiHelper.post("/master_maintenance/getSysFacilityAfterSaveByLimit", params);
      this.sysFacility = sysFacilityData.data;
      this.getMasterRecordList.data = [];
      for (let i = 0; i < this.sysFacility.length; i++) {
        let d = new Object();
        const fields = this.getMasterRecordList.schema.model.fields;
        Object.keys(fields).forEach(k => {
          Object.keys(this.sysFacility[i]).forEach(sysFacilityKey => {
            if (sysFacilityKey === k) {
              d[k] = this.sysFacility[i][sysFacilityKey];
            }
          });
          if (k === "code") {
            d[k] = this.sysFacility[i].medicalInstitutionCd;
          }
          d["name"] = this.sysFacility[i].facilityName;
        });
        this.getMasterRecordList.data.push(d);
        this.edit({editRecord: d, isSortMode: true});
      }
      ApiHelper.get(`/master_maintenance/getTotal`).then((res) => {
        this.sysFacilityDataTotal = res.data
      });
      // modify #6217 全施設マスタ画面が遅い guanhao end

      // 画面表示フラグ
      this.isSortChacked = false;
      //add FNSI-8129 劉全航 start
      this.loadGridData();
      //add FNSI-8129 劉全航 end
      //共通ローダー：表示終了
      this.setLoadingScreenVisible(false);

      // グリッドのデータ再表示
      this.gridDataRefresh();
    },

    /**
     * @description 必須項目チェック
     * @summary 未入力の必須項目があったらダイアログを表示する
     * @returns {Boolean} true: 未入力なし, false: 未入力あり
     */
    isFilledRequired() {
      let message = "";
      if (this.getUpdateRecordList.some( item => item.medicalInstitutionCd === null || item.medicalInstitutionCd === "")) {
        // #10082 全施設マスタで追加行が空行で保存を押したときエラーにならない linjunfeng start
        // message = DIALOG_MESSAGES[20010002].replace(/{\$\d*}/, "医療機関コード");
        message = DIALOG_MESSAGES[20010002].message.replace(/{\$\d*}/, "医療機関コード");
        // #10082 全施設マスタで追加行が空行で保存を押したときエラーにならない linjunfeng end
      }
      if (this.getUpdateRecordList.some(item => item.name === null || item.name === "")) {
        if(message.length > 0){
          message = message.substring(0,message.indexOf("。")+1)
        }
        // #10082 全施設マスタで追加行が空行で保存を押したときエラーにならない linjunfeng start
        // message = message + DIALOG_MESSAGES[20010002].replace(/{\$\d*}/, "\n施設名");
        message = message + DIALOG_MESSAGES[20010002].message.replace(/{\$\d*}/, "\n施設名");
        // #10082 全施設マスタで追加行が空行で保存を押したときエラーにならない linjunfeng end
      }
      if(message.length > 0){
        // 改行文字列をbrタグに置換
        message = message.replace(/\n/g, "<br>");
        this.$ons.notification.alert({
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
            // title: "チェックエラー",
            title: DIALOG_MESSAGES["00300006"].title,
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
            message: message
          });
        return false;
      }
      return true;
    },

    /**
     * @description 医療機関コードチェック
     * @summary 重複または半角数字以外があったらダイアログを表示する
     * @returns {Boolean} true: 正, false: 不正
     */
    validateMmedicalInstitutionCd() {
      const facilityCdList = this.getUpdateRecordList.map(
        record => record.medicalInstitutionCd
      );
      // 医療機関コードリストをSetオブジェクトに(重複排除)
      const set = new Set(facilityCdList);
      if (facilityCdList.length !== set.size) {
        // 元のリストと重複排除リストの長さが違うなら重複あり
        this.isDialogVisible = true;
        this.messageCd = 60000001;
        this.stringParams = ["医療機関コード"];
        return false;
      }

      // 半角数字の正規表現パターン
      const regexp = /^[0-9]*$/;
      if (facilityCdList.some(cd => !regexp.test(cd))) {
        this.isDialogVisible = true;
        this.messageCd = 60000002;
        this.stringParams = ["医療機関コード"];
        return false;
      }

      return true;
    },
    addRow() {
      // グリッドでエラーが発生している場合は処理を中断
      if (!this.kendoValidator.validate()) {
        return;
      }

      // add #6217 全施設マスタ画面が遅い guanhao start
      this.addRowScrollFlag = true;
      // add #6217 全施設マスタ画面が遅い guanhao end
      // add 8130 全施設マスタでフリーズする 周安寧 start
      this.loadingFlag = false;
      // add 8130 全施設マスタでフリーズする 周安寧 end

      // 空レコードをストアに登録
      let newRecord = {};
      const fields = this.getMasterRecordList.schema.model.fields;

      // 初期値を設定
      Object.keys(fields).forEach(colName => {
        switch (colName) {
          case "prefecturesCd":
            newRecord[colName] = "00";
            break;

          case "name":
            newRecord[colName] = "";
            break;

          default:
            newRecord[colName] = null;
            break;
        }
        // delete #6217 全施設マスタ画面が遅い guanhao start
// add redmine 4490 全施設マスタの並び順 鞠 start
//         // 初期時、新しいレコードに全レコードの並び順の最大値をセット
//         if (colName === "sortRank") {
//           newRecord[colName] = this.getMaxSortRank() + 1;
//         }
// add redmine 4490 全施設マスタの並び順 鞠 end
        // delete #6217 全施設マスタ画面が遅い guanhao end
      });
      // 追加行: 縦スクロール最下部・横スクロール先頭へ（MasterRecordComponent.addRow と同様）
      this.scrollPosition.left = 0;
      this.lastScrollLeft = 0;
      this.__pendingScrollToBottom = true;
      // 画面編集内容をstoreに反映 ※新規レコード追加
      this.edit({ editRecord: newRecord, isSortMode: this.isSortMode });
      this.$nextTick(() => {
        this.applyDirectGridDataSourceContract();
        this.scheduleDirectGridAddRowScroll();
      });
    },
    /**
     * @description 表示順設定
     * @param {Array}
     */
    sortRecords(records) {
      records.sort((a, b) => {
        // 施設コードでソート
        return a.medicalInstitutionCd - b.medicalInstitutionCd;
      });
    },

    /**
     * @description 画面表示関数
     */
    showDisplay() {
      // 画面表示フラグ
      this.isSortChacked = true;
    },

    // add #6217 全施設マスタ画面が遅い guanhao start
    scrollRight() {
      if (this.isDirectGridProgrammaticScroll() || this.sysFacilityPageLoading) {
        return;
      }
      if (this.$refs.grid !== undefined) {
        let e = this.getGridScrollHostEl();
        if (!e) {
          return;
        }
        let scrollBottom = Math.abs(e.scrollHeight - e.scrollTop - e.clientHeight) < 4;
        if (Math.abs(e.scrollHeight - e.scrollTop - e.clientHeight) >= 4) {
          this.scrollFlag=true;
          // del 8130 全施設マスタでフリーズする 周安寧 start
          // this.addRowScrollFlag = false;
          // del 8130 全施設マスタでフリーズする 周安寧 end
        }
        // mod 8130 全施設マスタでフリーズする 周安寧 start
        //if (scrollBottom) {
          //if (this.scrollFlag) {
            //if (this.dataPageScrollFlag || this.offset === this.sysFacilityDataTotal || this.addRowScrollFlag) {
              //this.setLoadingScreenVisible(false);
              //return
            //}
            //this.setLoadingScreenVisible(true);
           // this.scrollFlag = false;
           // this.dataPageFlag = false;
           // this.sysFacilityDataPage('');
            // add 8130 全施設マスタでフリーズする 周安寧 start
          //  this.setLoadingScreenVisible(false);
            // add 8130 全施設マスタでフリーズする 周安寧 end
          //}
        //}
        if (scrollBottom) {
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
            if (this.dataPageScrollFlag || this.offset === this.sysFacilityDataTotal) {
              this.setLoadingScreenVisible(false);
              return
            }
            // スクロール位置を保存
            this.lastScrollTop = e.scrollTop;
            this.lastScrollLeft = e.scrollLeft || 0;
            this.rememberGridScrollPosition({ top: e.scrollTop || 0, left: e.scrollLeft || 0 });
            this.scrollFlag = false;
            this.dataPageFlag = false;
            this.sysFacilityDataPage('');
          }
          // mod 8130 全施設マスタでフリーズする 周安寧 end
        }
      }
    },
    async sysFacilityDataPage(recordName) {
      if (!this.hasSysFacilityRecordSchema()) {
        return;
      }
      if (!recordName && this.sysFacilityPageLoading) {
        return;
      }
      this.sysFacilityPageLoading = true;
      const loadToken = this.beginSysFacilityPageLoading();
      let releasePageLoadingInRestore = false;
      const resetPage = recordName != '';
      const pagingScrollPosition = this.normalizeGridScrollPosition(this.getGridScrollPosition());
      try {
        if (resetPage) {

          this.dataPageScrollFlag = false;
          this.keywordName = recordName;
          this.getMasterRecordList.data = [];
          this.clearSysFacilityRowSnapshots();
        }
        this.offset = this.getMasterRecordList.data.length;
        const paramsLoad = {
          insertRecord: this.loadInsertRecords,
          offset: this.getMasterRecordList.data.length,
          keywordName : this.keywordName
        };
        let sysFacilityData = await ApiHelper.post("/master_maintenance/getSysFacilityByLimitAndOffset", paramsLoad);
        if (!this.isSysFacilityPageLoadingActive(loadToken)) {
          return;
        }

        if (sysFacilityData.data.length < 100) {

          this.dataPageScrollFlag = true;
        }

        this.sysFacility = sysFacilityData.data;
        if (!this.kendoValidator.validate()) {
          return;
        }
        const appendedRows = [];
        for (let i = 0; i < this.sysFacility.length; i++) {
          let d = new Object();
          const fields = this.getMasterRecordList.schema?.model.fields;
          fields && Object.keys(fields)?.forEach(k => {
            Object.keys(this.sysFacility[i]).forEach(sysFacilityKey => {
              if (sysFacilityKey === k) {
                d[k] = this.sysFacility[i][sysFacilityKey];
              }
            });
            if (k === "code") {
              d[k] = this.sysFacility[i].medicalInstitutionCd;
            }
            d["name"] = this.sysFacility[i].facilityName;
          });
          // add start #9590
          if (!this.getMasterRecordList?.data) {
            return;
          }
          // add end #9590

          this.getMasterRecordList.data = this.getMasterRecordList.data.filter(data => data.code !== this.sysFacility[i].medicalInstitutionCd);

          // mod redmine 6619 標準医薬品マスタで抽出条件に関係ないデータが表示される,6620 編集していないのに編集内容破棄メッセージが表示される 宋qy start
          this.getMasterRecordList.data.push(d);
          // mod redmine 6619 標準医薬品マスタで抽出条件に関係ないデータが表示される,6620 編集していないのに編集内容破棄メッセージが表示される 宋qy end
          this.rememberSysFacilityRowSnapshot(d);
          this.edit({editRecord: d, isSortMode: true});
          appendedRows.push(d);
        }

        for (const record of this.getUpdateRecordList) {
          if (record.operation === 1) {
            this.getMasterRecordList.data = this.getMasterRecordList.data.filter(data => data.code !== record.code);
            // 新規レコード
            this.getMasterRecordList.data.push(record);
            appendedRows.push(record);
          }
        }
        if (resetPage) {
          this.applyDirectGridDataSourceContract({ resetScroll: true });
        } else {
          this.appendSysFacilityPageRowsToDirectGrid(
            this.filterSysFacilityDisplayRows(appendedRows),
            pagingScrollPosition
          );
          releasePageLoadingInRestore = true;
        }
      } catch (error) {
        getErrorMessage('SysFacilityMainComponent.vue', 'sysFacilityDataPage', error);
      } finally {
        if (!releasePageLoadingInRestore) {
          this.sysFacilityPageLoading = false;
        }
        this.endSysFacilityLoading();
      }
    },
    generatedGridData() {
      const source = this.masterRecords || this.getFilteredMasterRecordList || {};
      return new kendo.data.DataSource({
        pageSize: 300000,
        data: Array.isArray(source.data) ? source.data : [],
        schema: source.schema
      });
    },
    // add #6217 全施設マスタ画面が遅い guanhao end
    async loadGridData(){
      // add #6217 全施設マスタ画面が遅い guanhao start
      this.keywordName = null;
      this.dataPageScrollFlag = false;
      // add #6217 全施設マスタ画面が遅い guanhao end
      // mod #9590 start
      if (this.condition.recordName) {
        if (!this.hasSysFacilityRecordSchema()) {
          await this.findList();
        }
        this.setCondition(this.condition);
        this.showDisplay();
      } else {
        await this.findList();
      }
      // mod #9590 start
    },
    editStart(e) {
      if (this.androidFlg) {
        this.editingFlg = true;
      }
      this.$nextTick(() => {
        if (e?.sender?.editable?.options?.fields?.field === "isDisp") {
          const element = this.getDirectGridScrollContent();
          if (element) {
            element.scrollLeft = element.scrollWidth - element.clientWidth;
          }
        }
        const root = this.getDirectGridRoot();
        const textInput = root?.querySelector?.(".k-input.k-textbox");
        if (textInput) {
          textInput.setAttribute("title", "");
        }
        const editCell = root?.querySelector?.(".k-edit-cell");
        const editTarget = editCell?.children?.[0];
        if (editTarget?.title) {
          editTarget.title = "";
        }
      });
    },
    editEnd() {
      this.editingFlg = false;
      this.clearValidationTooltipPlacementState();
    },
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
    onDataBoundKendoGrid() {
      const pendingAddRowScroll = this.__pendingScrollToBottom;
      if (pendingAddRowScroll) {
        this.__pendingScrollToBottom = false;
      }
      const position = this.sysFacilityPageScrollRestorePending
        ? { ...this.sysFacilityPageScrollRestorePosition }
        : pendingAddRowScroll
          ? { top: 0, left: 0 }
          : { ...this.scrollPosition };
      this.applyDirectGridLegacyStyleContract();
      this.attachDirectGridScrollHandlers();
      this.refreshDirectGridVisualState();
      this.scheduleDirectGridLayoutContract(position);
      if (pendingAddRowScroll) {
        this.scheduleDirectGridAddRowScroll();
      } else {
        this.restoreGridScrollPosition(position);
      }
      this.installValidationTooltipPlacementObserver();
      this.scheduleValidationTooltipPlacement();
    },
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
  left: 0;
  right: 0;
  position: absolute;
  width: auto;
  z-index: 2;
}
.main-content-area.master-maintenance-page {
  overflow: hidden;
}
.ntss-list {
  position: relative;
  overflow: hidden;
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
 
/* add 8130 全施設マスタでフリーズする 周安寧 start */
.kendo-grid-toolbar-style :deep(.k-grid
  tr:nth-child(n + 3):nth-last-child(n-3)
  .k-tooltip.k-tooltip-validation
  .k-callout) {
  border-bottom: 0;
  border-top: 6px solid #000;
  top: unset;
  bottom: -6px;
}
.kendo-grid-toolbar-style :deep(.k-grid
  tr:nth-child(n + 3):nth-last-child(n-3)
  .k-tooltip.k-tooltip-validation) {
  bottom: 38px;
}
.kendo-grid-toolbar-style :deep(.k-edit-cell) {
  position: relative;
  overflow: visible;
}
/* add 8130 全施設マスタでフリーズする 周安寧 end */
.kendo-grid-toolbar-style :deep(.k-grid-header-locked > table) {
  border-right-width: 0px;
}
.kendo-grid-toolbar-style :deep(.k-grid-header-locked) {
  border-right: 1px solid var(--ntss-list-border-color) !important;
}
.kendo-grid-toolbar-style :deep(.k-grid-content-locked) {
  z-index: 1;
  box-shadow: 1px 0px 0px 0px var(--ntss-border-color) !important;
}

@media screen and (max-width: 480px) {
  .kendo-grid-toolbar-style :deep(.k-grid-header-locked th),
  .kendo-grid-toolbar-style :deep(.k-grid-content-locked td) {
    padding: 0.25rem !important;
  }
  .kendo-grid-toolbar-style :deep(.k-grid-content-locked .facility-name) {
    overflow-wrap: break-word;
  }
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

.sys-facility-direct-jq-grid {
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
.kendo-grid-toolbar-style :deep(.k-tooltip.k-tooltip-validation) {
  width: auto;
}
.kendo-grid-toolbar-style :deep(.k-edit-cell > .k-invalid-msg:not(.k-hidden)),
.kendo-grid-toolbar-style :deep(.k-edit-cell > .k-form-error:not(.k-hidden)),
.kendo-grid-toolbar-style :deep(.k-edit-cell > .k-validator-tooltip:not(.k-hidden)),
.kendo-grid-toolbar-style :deep(.k-edit-cell > .k-tooltip-error:not(.k-hidden)) {
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
.kendo-grid-toolbar-style :deep(.k-edit-cell .k-tooltip-content) {
  font-family: inherit !important;
  font-size: inherit !important;
  font-weight: normal !important;
  line-height: 1.4 !important;
}
:deep(.k-dirty-cell){
  font-weight: 600 !important;
}
/* JS ntss-validation-above：スクロール領域下端で tooltip をセル上に表示 */
.kendo-grid-toolbar-style :deep(td.k-edit-cell.ntss-validation-above > .k-invalid-msg),
.kendo-grid-toolbar-style :deep(td.k-edit-cell.ntss-validation-above .k-invalid-msg.k-tooltip-error),
.kendo-grid-toolbar-style :deep(td.k-edit-cell.ntss-validation-above .k-tooltip.k-tooltip-error),
.kendo-grid-toolbar-style :deep(td.k-edit-cell.ntss-validation-above .k-tooltip.k-tooltip-validation),
.kendo-grid-toolbar-style :deep(td.k-edit-cell.ntss-validation-above .k-validator-tooltip),
.master-record-direct-jq-grid :deep(td.k-edit-cell.ntss-validation-above > .k-invalid-msg),
.master-record-direct-jq-grid :deep(td.k-edit-cell.ntss-validation-above .k-invalid-msg.k-tooltip-error),
.master-record-direct-jq-grid :deep(td.k-edit-cell.ntss-validation-above .k-tooltip.k-tooltip-error),
.master-record-direct-jq-grid :deep(td.k-edit-cell.ntss-validation-above .k-tooltip.k-tooltip-validation),
.master-record-direct-jq-grid :deep(td.k-edit-cell.ntss-validation-above .k-validator-tooltip),
.master-record-direct-jq-grid :deep(.k-grid-content-locked tbody > tr:nth-last-child(-n + 2) td.k-edit-cell > .k-invalid-msg),
.master-record-direct-jq-grid :deep(.k-grid-content-locked tbody > tr:nth-last-child(-n + 2) td.k-edit-cell .k-tooltip.k-tooltip-error) {
  position: absolute !important;
  left: 0 !important;
  bottom: 37px !important;
  top: auto !important;
  /* margin-top: 0 !important; */
  overflow: visible !important;
  padding:9px 15px !important;
  align-items: center;
  margin: 0.5em;
}
.kendo-grid-toolbar-style :deep(td.k-edit-cell.ntss-validation-above .k-callout.k-callout-s),
.master-record-direct-jq-grid :deep(td.k-edit-cell.ntss-validation-above .k-callout.k-callout-s),
.master-record-direct-jq-grid :deep(.k-grid-content-locked tbody > tr:nth-last-child(-n + 2) td.k-edit-cell .k-callout.k-callout-n) {
  top: auto !important;
  bottom: calc(-12px) !important;
  border-bottom-color: transparent !important;
  
}
:deep(.kendo-grid-toolbar-style[data-v-9de96129] .k-edit-cell > .k-validator-tooltip:not(.k-hidden)){
  top: calc(100% + 7px) !important;
}
</style>
