/**
 * 装置記録マスタページ  MainContent
 */
<template>
  <div class="main-content-area master-maintenance-page">
    <div class="ntss-list" :style="ntssListStyles">
      <div class="k-grid-toolbar k-header kendo-grid-toolbar-style" :style="heightStyles">
        <div id="grid-header" :class="['header-btn-area', 'right', isMobileDevice ? 'mobile-header' : '']">
          <v-ons-row v-show="isMobileDevice" style="width: 7em;">
            <v-ons-col width="45%" vertical-align="center">
              <label class="fab-font-color">編集</label>
            </v-ons-col>
            <v-ons-col width="55%" vertical-align="center">
              <v-ons-switch modifier="outline" v-model="allowEdit" />
            </v-ons-col>
          </v-ons-row>
          <!-- del マスタ一覧 1･施設切替を可能とする 王 start -->
          <!-- <v-ons-button modifier="outline" class="toolbar-btn" style="float: left;" v-show="!isSortMode && isAllowAddRecord" @click="addRow()">追加</v-ons-button> -->
          <!--          <kendo-dropdownlist ref="dropDownList" v-if="isMasterUser"-->
          <!--              v-model="facilitylistValue"-->
          <!--              :data-source="facilities"-->
          <!--              :data-text-field="'facilityName'"-->
          <!--              :data-value-field="'facilityCd'"-->
          <!--              :filter="'contains'"-->
          <!--              @open="onOpenFacility"-->
          <!--              @change="onChangeFacility"-->
          <!--              style="width: 13em;">-->
          <!--          </kendo-dropdownlist>-->
          <v-ons-button modifier="outline" class="btn3-normal toolbar-btn" v-show=" !iosFlg && !androidFlg" @click="importCsv($event)">CSV取込</v-ons-button>
          <!-- <v-ons-button modifier="outline" class="toolbar-btn" v-show="!isSortMode && isAllowSort" @click="toRankEditBtnClick()">並び順表示</v-ons-button> -->
          <!-- <v-ons-button modifier="outline" class="toolbar-btn" v-show="isSortMode && isAllowSort" @click="sortBtnClick()">反映</v-ons-button> -->
          <!-- del マスタ一覧 1･施設切替を可能とする 王 start -->
        </div>
        <div
          v-show="columns.length > 1"
          id="grid-font-size"
          ref="gridRoot"
          :class="[fontSizeSet, 'ntss-kendo-grid-legacy', 'mst-machine-record-control-direct-jq-grid']"
        ></div>
      </div>
      <div id="grid-footer">
<!--        del 装置記録マスタ ページネーションを削除 start-->
<!--        <v-ons-row width="100%" style="margin-bottom: 3px;text-align: center;">-->
<!--          <v-ons-col width="100%" vertical-align='center' >-->
<!--            <v-ons-button class="button toolbar-btn paginationClass" v-show="true" :disabled="pageNum<=1" @click="setPage(pageNum-1)">前のページ</v-ons-button>-->
<!--            <a href="#" class="paginationClass" @click="setPage(1)" v-if="startPage>1&&totalPage>7">1···</a>-->
<!--            <a href="#"-->
<!--              class="paginationClass"-->
<!--              v-for="(n,key) in totalPage>7 ? 7: totalPage"-->
<!--              :key ="key"-->
<!--              v-text="startPage+n-1"-->
<!--              @click="setPage(startPage+n-1)"-->
<!--              :disabled="startPage+n-1==pageNum"-->
<!--              :class="{'disableATag':startPage+n-1==pageNum}"-->
<!--            ></a>-->
<!--            <a href="#" class="paginationClass" v-text="'···'+totalPage" @click="setPage(totalPage)" v-if="startPage+6<totalPage&&totalPage>7"></a>-->
<!--            <v-ons-button class="button toolbar-btn paginationClass" :disabled="pageNum>=totalPage" @click="setPage(pageNum+1)">次のページ</v-ons-button>-->
<!--            <v-ons-input type='number' class="pageInput paginationClass" float :disabled="totalPage==1" @blur="formatPage" @keydown.enter='pageInputEnter' style="height: 100%;width: 30px"></v-ons-input>-->
<!--            <v-ons-button class="button toolbar-btn paginationClass" :disabled="totalPage==1" @click="setPage(pageInputValue)">ジャンプ</v-ons-button>-->
<!--          </v-ons-col>-->
<!--        </v-ons-row>-->
<!--        del 装置記録マスタ ページネーションを削除 end-->
        <v-ons-row width="100%" v-show="!isSortMode" >
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
import dayjs from "@/compat/date/dayjs";
import _ from "@/compat/collections/lodash";
import { mapActions, mapGetters } from "@/compat/vue/vuex";
import { markRaw } from "@/compat/vue/runtime";
import { EventBus } from "@/compat/vue/event-bus.js";
import { ApiHelper } from "@/apis/AxiosHelper";
import MasterCsvComponent from "@/components/master-maintenance/MasterCsvComponent";
import { ADVANCED_SETTINGS } from "@/constants/advancedSettings";
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages.js";
//FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
import { getScopedAlertDialogs, getScopedDocument, getScopedElementById } from "@/functions/common/LayoutMeasureHelper";
import { messageFormat } from "@/functions/common/MessageFormat";
import kendo from "@progress/kendo-ui";
import $ from "jquery";
//FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 start

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
  name:"MstMachineRecordControl",
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
        recordCode: "",
        recordMessage: "",
        recordName: "",
        dispFlg: "",
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
      editFlg: false,
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
      // 選択中の施設コード
      facilitylistValue: "",
      // 選択中施設の在宅機能有無
      facilityHemoDialysis: false,
      //変更前の施設
      prevFacilityCd: "",
      // del 装置記録マスタ ページネーションを削除 start
      // pageNum:1,
      // pageSize:100,
      // totalPage:0,
      // pageInputValue:1
      // del 装置記録マスタ ページネーションを削除 end
      pageNum: 1,
      pageSize: 100,
      totalPage: 1,
      pageInputValue: 1,
      lastScrollTop: 0,
      lastScrollLeft: 0,
      // add 性能改善 劉 start
      dataSourceItems: {},
      // add 性能改善 劉 end
      allowEdit: true, // NOTE: true = 編集モード、 false = 閲覧モード
      zoomObserver: null,
      scrollRestored: true,
      directGridWidget: null,
      directGridMounted: false,
      directGridLayoutRafId: null,
      directGridFilterRefreshRafId: null,
      directGridScrollSyncRafId: null,
      directGridScrollRestoreTimer: null,
      directGridTouchCleanup: null,
      directGridScrollHandler: null,
      directGridScrollTrackingTargets: null,
      preserveGridScrollAfterSave: false,
      pendingSaveScrollSnapshot: null,
      directGridSaveScrollRestoreTimerIds: [],
      directGridRowVisualRafIds: markRaw(new Map()),
      kendoValidator: null,
    };
  },
  computed: {
    // add マスタ一覧 1･施設切替を可能とする 王 start
    ...mapGetters("master-maintenance", { getFacilitySwitch: "getFacilitySwitch",}),
    // add マスタ一覧 1･施設切替を可能とする 王 end
    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight",
      windowWidth: "getWindowWidth"
    }),
    ...mapGetters("account-edit", {
      isDispMenu: "isDispMenu",
      getFontSize: "getFontSize",
      getStateUserAccountInfo: "getStateUserAccountInfo"
    }),
    ...mapGetters("user", ["getAdvancedSettings", "getSystemUseSetting"]),
    heightStyles() {
      // main部の高さをCSS変数を利用して書き換え
      return { "--height": `${this.kendoGridToolbarHeight}px` };
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
      return `${condition.recordCode || ""}|${condition.recordName || ""}|${condition.recordMessage || ""}|${condition.dispFlg || ""}|${condition.includeDeleted ? 1 : 0}`;
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
      getFacilityList: "getFacilityList"
    }),
    // 装置記録マスタ バグ修正 start
    viewMasterRecords() {
      return this.dataSourceItems._view;
    },
    // 装置記録マスタ バグ修正 end
    facilities() {
      // storeからデータを取得
      return this.getFacilityList;
    },
    isMasterUser: {
      get() {
        return this.getStateUserAccountInfo.userType === 1 ? true : false;
      },
      set() {}
    },
    startPage(){
      if(this.totalPage <= 7 || this.pageNum-3 < 1){
        return 1;
      }
      if(this.pageNum+3 > this.totalPage){
        return this.totalPage - 6;
      }
      return this.pageNum-3;
    },
    masterRecords() {
      // storeからデータを取得
      let RecordList = this.getFilteredMasterRecordList;
      if(!RecordList.data)RecordList={data:[]}
      // mod 装置記録マスタ ページネーションを削除 start
      // const searchRecord = this.searchRecord(RecordList);
      // this.setTotalPage(searchRecord);
      // const PaginationList = this.Pagination(searchRecord);
      // return PaginationList;
      return this.searchRecord(RecordList);
      // mod 装置記録マスタ ページネーションを削除 end
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
        (this.isRecordModified || !this.validateBeforeGridAction())
      );
    },
    isMobileDevice() {
      return this.iosFlg || this.androidFlg;
    },
  },
  watch: {
    windowHeight() {
      this.calculateColumnsWidth();
      this.calculateGridHeight();
      this.scheduleDirectGridLayoutContract();
    },
    windowWidth() {
      this.calculateColumnsWidth();
      this.calculateGridHeight();
      this.scheduleDirectGridLayoutContract();
    },
    isDispMenu() {
      this.calculateColumnsWidth();
      this.calculateGridHeight();
      this.scheduleDirectGridLayoutContract();
    },
    getFontSize() {
      this.calculateColumnsWidth();
      this.calculateGridHeight();
      this.$nextTick(() => this.refreshDirectGridPageSizeByFont());
    },
    columns(val) {
      this.$nextTick(() => {
        if (val.length > 1) {
          this.setLoadingScreenVisible(false);
          this.calculateGridHeight();
          this.calculateGridWidth();
          this.initDirectGridIfReady();
          this.scheduleDirectGridLayoutContract();
        }
      });
    },
    masterConditionSignature() {
      this.scheduleDirectGridFilterRefresh();
    },
  },
  methods: {
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
      "findRecordListByFacilityCdWithSql"
     ,"updateIndCondInfo"
    ]),
    ...mapActions("master-maintenance", {
      facilityList: "facilityList"
    }),
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
    getisChanged() {
      return this.isChanged;
    },
    validateBeforeGridAction() {
      return this.kendoValidator?.validate?.() !== false;
    },
    validateDirectKendoGrid() {
      return true;
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
      const comboFields = this.columns
        .filter(column => column.values != null)
        .map(column => ({ field: column.field, title: column.title, values: column.values }));
      const rows = (this.getMasterRecordList?.data || []).filter(row => row.isDisp !== "0" && row.isDel === "0");
      const validateMessageArr = [];
      rows.forEach(row => {
        comboFields.forEach(combo => {
          const value = row[combo.field];
          const empty = value === null || value === undefined || value === "" || value === "null";
          if (empty) return;
          const exists = (combo.values || []).some(item => String(item?.value) === String(value));
          if (!exists) validateMessageArr.push(combo.title);
        });
      });
      return this.convertToStr(validateMessageArr);
    },
    getColumnIndex(fieldName) {
      return this.columns.findIndex(e => e.field === fieldName);
    },
    getGridRootEl() {
      return this.$refs.gridRoot || null;
    },
    getGridWidget() {
      return this.directGridWidget || null;
    },
    getGridContentElement() {
      return this.getGridRootEl()?.querySelector?.(".k-grid-content") || null;
    },
    getGridLockedContentElement() {
      return this.getGridRootEl()?.querySelector?.(".k-grid-content-locked") || null;
    },
    getGridAutoScrollableElement() {
      return this.getGridContentElement();
    },
    getGridHeaderEl() {
      return this.getGridRootEl()?.querySelector?.(".k-grid-header") || null;
    },
    getGridBodyRows() {
      return this.getGridRootEl()?.querySelectorAll?.(".k-grid-content tbody tr") || [];
    },
    getGridDataSource() {
      return this.dataSourceItems;
    },
    getDirectGridHorizontalScrollTargets() {
      const content = this.getGridContentElement();
      const headerWrap = this.getGridRootEl()?.querySelector?.(".k-grid-header-wrap");
      const grid = this.directGridWidget;
      const gridContent = grid?.content?.[0];
      const targets = [content, headerWrap];
      if (content?.firstElementChild) {
        targets.push(content.firstElementChild);
      }
      if (gridContent && gridContent !== content) {
        targets.push(gridContent);
      }
      return [...new Set(targets.filter(Boolean))];
    },
    getGridScrollPosition() {
      const content = this.getGridContentElement();
      const grid = this.directGridWidget;
      const virtualScrollbar = grid?.virtualScrollable?.verticalScrollbar?.[0] || null;
      const topValues = [virtualScrollbar?.scrollTop, content?.scrollTop]
        .map(value => Number(value))
        .filter(value => Number.isFinite(value));
      const leftValues = this.getDirectGridHorizontalScrollTargets()
        .map(el => Number(el.scrollLeft))
        .concat([Number(grid?._scrollLeft)])
        .filter(value => Number.isFinite(value));
      return {
        top: topValues.length ? Math.max(...topValues) : 0,
        left: leftValues.length ? Math.max(...leftValues) : 0
      };
    },
    setGridScrollPosition(position = {}) {
      const content = this.getGridContentElement();
      const grid = this.directGridWidget;
      const top = Number.isFinite(position.top) ? position.top : null;
      const left = Number.isFinite(position.left) ? position.left : null;
      const virtualScrollable = grid?.virtualScrollable;
      const virtualScrollbar = virtualScrollable?.verticalScrollbar?.[0];
      const wrapper = virtualScrollable?.wrapper?.[0];
      if (virtualScrollbar && top !== null) {
        virtualScrollable._preventScroll = false;
        $(virtualScrollbar).scrollTop(top).trigger("scroll");
      }
      if (wrapper && top !== null) {
        wrapper.scrollTop = top;
      }
      if (content && top !== null) {
        content.scrollTop = top;
      }
      if (left !== null) {
        this.getDirectGridHorizontalScrollTargets().forEach(el => {
          el.scrollLeft = left;
        });
        if (grid && typeof grid._scrollLeft !== "undefined") {
          grid._scrollLeft = left;
        }
      }
      const lockedContent = this.getGridLockedContentElement();
      if (lockedContent && top !== null) {
        lockedContent.scrollTop = top;
      } else if (lockedContent && wrapper) {
        lockedContent.scrollTop = wrapper.scrollTop;
      }
      this.syncDirectGridLockedScrollContract();
      if (content && (top !== null || left !== null)) {
        try {
          content.dispatchEvent(new Event("scroll", { bubbles: true }));
          $(content).trigger("scroll");
        } catch (_error) {
          // noop
        }
      }
    },
    capturePendingSaveScrollSnapshot() {
      const position = this.getGridScrollPosition();
      this.pendingSaveScrollSnapshot = {
        top: position.top,
        left: position.left
      };
      this.scrollPosition.top = position.top;
      this.scrollPosition.left = position.left;
      this.lastScrollTop = position.top;
      this.lastScrollLeft = position.left;
      this.preserveGridScrollAfterSave = true;
      this.scrollRestored = false;
    },
    clearPendingSaveScrollSnapshot() {
      this.clearPendingSaveScrollRestoreTimers();
      this.pendingSaveScrollSnapshot = null;
      this.preserveGridScrollAfterSave = false;
    },
    clearPendingSaveScrollRestoreTimers() {
      this.directGridSaveScrollRestoreTimerIds.forEach(id => clearTimeout(id));
      this.directGridSaveScrollRestoreTimerIds = [];
      clearTimeout(this.directGridScrollRestoreTimer);
      this.directGridScrollRestoreTimer = null;
    },
    getPendingSaveScrollSnapshot() {
      return this.pendingSaveScrollSnapshot;
    },
    schedulePendingSaveScrollRestore() {
      const snapshot = this.getPendingSaveScrollSnapshot();
      if (!snapshot) return;
      this.clearPendingSaveScrollRestoreTimers();
      const restoreScroll = () => this.setGridScrollPosition(snapshot);
      restoreScroll();
      this.$nextTick(() => {
        restoreScroll();
        requestAnimationFrame(() => {
          restoreScroll();
          requestAnimationFrame(restoreScroll);
        });
      });
      [50, 150, 300, 500, 1000].forEach(ms => {
        const timerId = setTimeout(() => {
          if (!this.preserveGridScrollAfterSave) return;
          restoreScroll();
          if (ms === 1000) {
            this.lastScrollTop = 0;
            this.lastScrollLeft = 0;
            this.scrollRestored = true;
            this.clearPendingSaveScrollSnapshot();
          }
        }, ms);
        this.directGridSaveScrollRestoreTimerIds.push(timerId);
      });
    },
    storeDirectGridScrollPosition() {
      if (this.preserveGridScrollAfterSave && this.pendingSaveScrollSnapshot) {
        return;
      }
      const position = this.getGridScrollPosition();
      this.scrollPosition.top = position.top;
      this.scrollPosition.left = position.left;
      this.lastScrollTop = position.top;
      this.lastScrollLeft = position.left;
    },
    bindDirectGridScrollPositionTracking() {
      this.unbindDirectGridScrollPositionTracking();
      const onScroll = () => {
        this.storeDirectGridScrollPosition();
      };
      this.directGridScrollHandler = onScroll;
      const content = this.getGridContentElement();
      const headerWrap = this.getGridRootEl()?.querySelector?.(".k-grid-header-wrap");
      const targets = [content, headerWrap].filter(Boolean);
      targets.forEach(el => {
        el.addEventListener("scroll", onScroll, { passive: true });
      });
      this.directGridScrollTrackingTargets = targets;
    },
    unbindDirectGridScrollPositionTracking() {
      const handler = this.directGridScrollHandler;
      if (!handler) return;
      (this.directGridScrollTrackingTargets || this.getDirectGridHorizontalScrollTargets()).forEach(el => {
        el.removeEventListener("scroll", handler);
      });
      this.directGridScrollHandler = null;
      this.directGridScrollTrackingTargets = null;
    },
    resizeGridStableTargets() {
      this.resizeDirectGrid();
    },
    calculateColumnsWidth() {
      const fontSize = Number(this.getFontSize || 1);
      const widthMap = [12, 14, 16, 18];
      this.columnWidth = widthMap[fontSize] || 14;
    },
    calculateGridHeight() {
      if (this.editingFlg) return;
      const ownerDocument = getScopedDocument(this.$el);
      const ownerWindow = ownerDocument.defaultView || window;
      const wh = this.windowHeight || ownerWindow.innerHeight || 0;
      const headerElements = ownerDocument.getElementsByClassName("header");
      const hh = headerElements.length ? headerElements[headerElements.length - 1].clientHeight : 0;
      const footerMenu = getScopedElementById("footer-menu", this.$el) || ownerDocument.getElementById?.("footer-menu");
      const fmh = (this.isDispMenu === 1 && footerMenu ? footerMenu.clientHeight : 0) + 5;
      this.kendoGridToolbarHeight = Math.max(100, wh - hh - fmh - 10);

      const gridFooter = getScopedElementById("grid-footer", this.$el) || ownerDocument.getElementById?.("grid-footer");
      const gridFooterHeight = gridFooter ? gridFooter.clientHeight : 0;
      const gridHeader = getScopedElementById("grid-header", this.$el) || ownerDocument.getElementById?.("grid-header");
      const headerAreaHeight = gridHeader ? gridHeader.clientHeight : 0;
      this.kendoGridHeight = Math.max(160, this.kendoGridToolbarHeight - (gridFooterHeight + headerAreaHeight));

      const gridRoot = this.getGridRootEl();
      if (gridRoot && Number.isFinite(this.kendoGridHeight)) {
        gridRoot.style.height = `${this.kendoGridHeight}px`;
      }
    },
    calculateGridWidth() {
      this.resizeDirectGrid();
    },
    showSortColumn() {
      this.applyDirectGridColumnsContract();
      this.scheduleDirectGridLayoutContract();
    },
    editStart() {
      this.editingFlg = true;
      this.storeDirectGridScrollPosition();
    },
    editEnd() {
      this.editingFlg = false;
      this.restoreDirectGridScrollPositionAfterEdit();
    },
    addInputAssist() {
      // Vue2 wrapper の edit hook と同じ時点だけ維持する。入力補助は各 editor / Kendo に委譲。
    },
    changeEditColor(currentTrc) {
      let edited = false;
      Array.from(currentTrc || []).forEach(td => {
        if (td.querySelector?.(".k-dirty") || td.classList.contains("k-dirty-cell")) {
          td.classList.add("master-edited-row");
          edited = true;
        }
      });
      return edited;
    },
    changeRowColor(currentTrc, currentLockTrc, edited) {
      [...Array.from(currentTrc || []), ...Array.from(currentLockTrc || [])].forEach(td => {
        td.classList.toggle("master-edited-row", !!edited);
      });
    },
    importCsv(event) {
      if (!this.validateBeforeGridAction()) return;
      this.masterCsvTarget = event?.target || null;
      this.masterCsvVisible = true;
    },
    prehideCsvPopover() {
      this.masterCsvVisible = false;
      this.dataSourceItems = this.generatedGridData();
      this.$nextTick(() => {
        this.applyDirectGridDataSourceContract();
        this.scheduleDirectGridLayoutContract();
      });
    },
    onCloseMasterEditModal() {
      this.gridDataRefresh();
    },
    getDirectGridPageSize() {
      const rowHeight = this.getGridContentElement()?.querySelector?.("tr")?.clientHeight || 30;
      const gridHeight = this.getGridRootEl()?.offsetHeight || this.kendoGridHeight || 900;
      return Math.max(1, Math.floor(gridHeight / rowHeight));
    },
    refreshDirectGridPageSizeByFont() {
      const grid = this.directGridWidget;
      if (!grid || !grid.virtualScrollable) return;
      const newPageSize = this.getDirectGridPageSize();
      const currentPageSize = this.dataSourceItems?.pageSize?.();
      if (newPageSize !== currentPageSize) {
        this.dataSourceItems = this.generatedGridData(newPageSize);
        this.applyDirectGridDataSourceContract();
      }
      this.resizeDirectGrid();
    },
    buildDirectGridColumns() {
      return (this.columns || []).map(column => {
        const gridColumn = { ...column };
        if (column.field === "code") {
          gridColumn.hidden = false;
        }
        return gridColumn;
      });
    },
    initDirectGridIfReady() {
      const root = this.getGridRootEl();
      if (!this.directGridMounted || !root || this.columns.length <= 1 || !this.dataSourceItems) return;
      if (this.directGridWidget) {
        this.applyDirectGridColumnsContract();
        this.applyDirectGridDataSourceContract();
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
        scrollable: { virtual: true },
        beforeEdit: event => this.onBeforeEdit(event),
        edit: event => this.addInputAssist(event),
        cellClose: event => this.editEnd(event),
        save: event => this.onDirectGridSave(event),
        dataBound: event => this.onDataBoundKendoGrid(event),
        columns: this.buildDirectGridColumns()
      });
      this.directGridWidget = markRaw($(root).data("kendoGrid"));
      this.installDirectGridFacade();
      this.applyDirectGridStyleContract();
      this.scheduleDirectGridLayoutContract();
    },
    destroyDirectGrid() {
      this.clearPendingSaveScrollRestoreTimers();
      this.unbindDirectGridScrollPositionTracking();
      if (this.directGridWidget) {
        try { this.directGridWidget.destroy(); } catch (_error) { /* noop */ }
      }
      const root = this.getGridRootEl();
      if (root) $(root).empty();
      this.directGridWidget = null;
      this.directGridMounted = false;
      if (this.directGridTouchCleanup) {
        this.directGridTouchCleanup();
        this.directGridTouchCleanup = null;
      }
    },
    installDirectGridFacade() {
      const root = this.getGridRootEl();
      if (!root) return;
      root.kendoWidget = () => this.directGridWidget;
      root.gridWidget = () => this.directGridWidget;
      root.gridVerticalScrollbarEl = () => this.directGridWidget?.virtualScrollable?.verticalScrollbar?.[0] || null;
      root.gridScrollPosition = () => this.getGridScrollPosition();
      root.scrollGridTo = position => this.setGridScrollPosition(position);
      root.gridContentEl = () => this.getGridContentElement();
      root.gridLockedContentEl = () => this.getGridLockedContentElement();
      this.bindDirectGridScrollPositionTracking();
    },
    applyDirectGridColumnsContract() {
      const grid = this.directGridWidget;
      if (!grid) return;
      const oldFields = (grid.columns || []).map(column => column.field).join("|");
      const newFields = (this.columns || []).map(column => column.field).join("|");
      if (oldFields !== newFields) {
        const snapshot = this.getPendingSaveScrollSnapshot();
        const position = snapshot || this.getGridScrollPosition();
        grid.setOptions({ columns: this.buildDirectGridColumns() });
        if (snapshot || this.preserveGridScrollAfterSave) {
          this.$nextTick(() => {
            this.setGridScrollPosition(position);
            this.schedulePendingSaveScrollRestore();
          });
        }
      }
    },
    refreshDirectGridDataFromMasterRecords(resetScroll = false) {
      const grid = this.directGridWidget;
      if (!grid?.dataSource) return false;
      const nextData = this.masterRecords?.data || [];
      try {
        grid.dataSource.data(nextData);
      } catch (_error) {
        return false;
      }
      if (resetScroll) {
        this.setGridScrollPosition({ top: 0, left: 0 });
      } else {
        this.restoreDirectGridScrollFromSnapshotIfNeeded();
      }
      this.$nextTick(() => {
        this.applyDirectGridStyleContract();
        if (!resetScroll) {
          this.restoreDirectGridScrollFromSnapshotIfNeeded();
        }
      });
      return true;
    },
    applyDirectGridDataSourceContract(options = {}) {
      const grid = this.directGridWidget;
      if (!grid) return;
      const preserveScroll = this.preserveGridScrollAfterSave || !!options.preserveScroll;
      if (grid.dataSource && (preserveScroll || options.refreshInPlace)) {
        this.refreshDirectGridDataFromMasterRecords(!!options.resetScroll);
        return;
      }
      if (!this.dataSourceItems) return;
      const snapshot = this.getPendingSaveScrollSnapshot();
      if (grid.dataSource !== this.dataSourceItems) {
        grid.setDataSource(this.dataSourceItems);
        if (snapshot) {
          this.$nextTick(() => this.setGridScrollPosition(snapshot));
        }
      }
      this.installDirectGridFacade();
      this.scheduleDirectGridLayoutContract({
        skipVirtualRefresh: !!options.skipVirtualRefresh || this.preserveGridScrollAfterSave
      });
    },
    scheduleDirectGridFilterRefresh() {
      if (this.directGridFilterRefreshRafId != null) cancelAnimationFrame(this.directGridFilterRefreshRafId);
      this.directGridFilterRefreshRafId = requestAnimationFrame(() => {
        this.directGridFilterRefreshRafId = null;
        const preservedScroll = this.getPendingSaveScrollSnapshot();
        if (preservedScroll && this.refreshDirectGridDataFromMasterRecords(false)) {
          this.schedulePendingSaveScrollRestore();
          return;
        }
        this.dataSourceItems = this.generatedGridData();
        this.applyDirectGridDataSourceContract({ resetScroll: !preservedScroll });
        if (preservedScroll) {
          this.setGridScrollPosition(preservedScroll);
        } else {
          this.setGridScrollPosition({ top: 0, left: 0 });
        }
      });
    },
    refreshDirectGridVirtualScrollable() {
      const grid = this.directGridWidget;
      if (!grid || this.preserveGridScrollAfterSave) return;
      grid.virtualScrollable?.refresh?.();
      grid.virtualScrollable?.repaintScrollbar?.();
    },
    restoreDirectGridScrollFromSnapshotIfNeeded() {
      const snapshot = this.getPendingSaveScrollSnapshot();
      if (snapshot) {
        this.setGridScrollPosition(snapshot);
        return;
      }
      if (!this.scrollRestored && (this.lastScrollTop > 0 || this.lastScrollLeft > 0)) {
        this.restoreDirectGridScrollPosition();
      }
    },
    resizeDirectGrid() {
      const grid = this.directGridWidget;
      if (!grid) return;
      const snapshot = this.getPendingSaveScrollSnapshot();
      try {
        grid.setOptions({ height: this.kendoGridHeight });
        grid.resize(true);
        if (!this.preserveGridScrollAfterSave) {
          this.refreshDirectGridVirtualScrollable();
        }
        this.restoreDirectGridScrollFromSnapshotIfNeeded();
      } catch (_error) {
        // direct jq では resize 失敗時に追加 rebuild しない。
      }
      if (snapshot) {
        this.setGridScrollPosition(snapshot);
      }
      this.applyDirectGridStyleContract();
    },
    scheduleDirectGridLayoutContract(options = {}) {
      if (this.directGridLayoutRafId != null) cancelAnimationFrame(this.directGridLayoutRafId);
      const skipVirtualRefresh = !!options.skipVirtualRefresh || this.preserveGridScrollAfterSave;
      this.directGridLayoutRafId = requestAnimationFrame(() => {
        this.directGridLayoutRafId = null;
        this.applyDirectGridStyleContract();
        if (!skipVirtualRefresh) {
          this.refreshDirectGridVirtualScrollable();
        }
        this.restoreDirectGridScrollFromSnapshotIfNeeded();
      });
    },
    restoreDirectGridScrollPositionAfterEdit() {
      const position = {
        top: this.scrollPosition.top,
        left: this.scrollPosition.left
      };
      const restoreScroll = () => this.setGridScrollPosition(position);
      restoreScroll();
      this.$nextTick(() => {
        restoreScroll();
        requestAnimationFrame(restoreScroll);
      });
    },
    restoreDirectGridScrollPosition() {
      const grid = this.directGridWidget;
      if (!grid) return;
      this.setGridScrollPosition({
        top: this.lastScrollTop,
        left: this.lastScrollLeft
      });
    },
    applyDirectGridLockedWidthContract() {
      const root = this.getGridRootEl();
      if (!root) return;
      const fontSize = parseFloat(getComputedStyle(root).fontSize || "16") || 16;
      const width = (this.columns || []).reduce((sum, column) => {
        if (!column.locked || column.hidden) return sum;
        const value = `${column.width || ""}`.trim();
        if (value.endsWith("em")) return sum + parseFloat(value) * fontSize;
        if (value.endsWith("px")) return sum + parseFloat(value);
        const numeric = parseFloat(value);
        return sum + (Number.isFinite(numeric) ? numeric : 0);
      }, 0);
      if (!width) return;
      const px = `${Math.ceil(width)}px`;
      root.querySelectorAll(".k-grid-header-locked,.k-grid-content-locked").forEach(element => {
        element.style.width = px;
      });
    },
    applyDirectGridLockedHeightContract() {
      const content = this.getGridContentElement();
      const lockedContent = this.getGridLockedContentElement();
      if (!content || !lockedContent) return;
      lockedContent.style.height = `${content.clientHeight}px`;
      lockedContent.style.maxHeight = `${content.clientHeight}px`;
    },
    syncDirectGridLockedScrollContract() {
      const content = this.getGridContentElement();
      const lockedContent = this.getGridLockedContentElement();
      if (!content || !lockedContent) return;
      const wrapper = this.directGridWidget?.virtualScrollable?.wrapper?.[0];
      lockedContent.scrollTop = wrapper ? wrapper.scrollTop : content.scrollTop;
    },
    applyDirectGridStyleContract() {
      const root = this.getGridRootEl();
      if (!root) return;
      root.classList.add("ntss-kendo-grid-legacy", "k-widget", "k-grid", "k-editable", "k-display-block");
      root.querySelectorAll("th").forEach(th => th.classList.add("k-header"));
      root.querySelectorAll("tbody tr").forEach((tr, index) => {
        tr.classList.add("k-master-row");
        tr.classList.toggle("k-alt", index % 2 === 1);
      });
      root.querySelectorAll("td").forEach(td => td.classList.add("k-td", "k-table-td"));
      this.applyDirectGridLockedWidthContract();
      this.applyDirectGridLockedHeightContract();
      this.syncDirectGridLockedScrollContract();
      this.refreshDirectGridDirtyVisualState();
    },
    onDirectGridSave(ev) {
      this.storeDirectGridScrollPosition();
      this.editFlg = true;
      this.editingFlg = false;
      Object.keys(ev.values || {}).forEach(field => {
        if (typeof ev.model?.set === "function") {
          ev.model.set(field, ev.values[field]);
        } else if (ev.model) {
          ev.model[field] = ev.values[field];
        }
      });
      this.edit({ editRecord: ev.model, isSortMode: this.isSortMode });
      if (ev.model?.operation === 1) {
        ev.model.edited = true;
      }
      this.scheduleDirectGridCurrentRowVisual(ev.model);
    },
    scheduleDirectGridCurrentRowVisual(record) {
      const key = record?.uid || record?.code;
      if (!key) return;
      const old = this.directGridRowVisualRafIds.get(key);
      if (old != null) cancelAnimationFrame(old);
      const raf = requestAnimationFrame(() => {
        this.directGridRowVisualRafIds.delete(key);
        this.applyDirectGridRowVisual(record);
      });
      this.directGridRowVisualRafIds.set(key, raf);
    },
    applyDirectGridRowVisual(record) {
      if (!record?.uid) return;
      const root = this.getGridRootEl();
      const dummyIndex = this.getColumnIndex("dummy");
      root?.querySelectorAll?.(`tr[data-uid="${record.uid}"]`)?.forEach?.(row => {
        row.classList.remove("master-edited-row");
        Array.from(row.children || []).forEach((cell, index) => {
          const colIndex = Number(cell.getAttribute("aria-colindex")) - 1;
          const effectiveIndex = Number.isFinite(colIndex) ? colIndex : index;
          if (effectiveIndex === dummyIndex) {
            cell.classList.remove("master-edited-row");
            return;
          }
          cell.classList.toggle("master-edited-row", !!record.operation || !!record.edited);
        });
      });
    },
    refreshDirectGridDirtyVisualState() {
      (this.getMasterRecordList?.data || []).forEach(record => {
        if (record?.operation || record?.edited) {
          this.applyDirectGridRowVisual(record);
        }
      });
    },
    // 装置記録マスタ バグ修正 start
    // add start #9395
    onDataBoundKendoGrid(ev) {
      const grid = this.getGridWidget();
      if (!grid || !grid.virtualScrollable) return;

      if (this.preserveGridScrollAfterSave) {
        this.restoreDirectGridScrollFromSnapshotIfNeeded();
        this.schedulePendingSaveScrollRestore();
      }

      const wrapper = this.getGridRootEl();
      if (!wrapper) return;

      let startY = 0;
      let scrollStart = 0;
      let isVerticalScroll = false;

      wrapper.addEventListener('touchstart', (e) => {
        if (e.touches.length === 1) {
          startY = e.touches[0].clientY;
          scrollStart = this.getGridScrollPosition().top || 0;
          isVerticalScroll = false;
        }
      }, { passive: true });

      wrapper.addEventListener('touchmove', (e) => {
        if (e.touches.length === 1) {
          const currentY = e.touches[0].clientY;
          const deltaY = startY - currentY;

          if (!isVerticalScroll && Math.abs(deltaY) > 10) {
            isVerticalScroll = true;
          }

          if (isVerticalScroll) {
            const newScrollTop = scrollStart + deltaY;

            requestAnimationFrame(() => {
              this.setGridScrollPosition({ top: newScrollTop });
            });

            e.preventDefault(); // iOSでスクロールを有効にするために必要
          }
        }
      }, { passive: false });
    },
    // add end #9395
    editBackgroundColor() {
      this.$nextTick(() => {
        // グリッドが表示されていなかったら処理終了
        const gridHeader = this.getGridHeaderEl();
        if (!gridHeader || gridHeader.textContent === " ") {
          return;
        }
        gridHeader?.classList?.add("master-grid-header");

        // グリッドにレコードがなければ処理終了
        // 固定列、可変列、データソースの取得
        const tbodyc = this.getGridBodyRows();
        const gridData = this.getGridDataSource();

        // 列の行数は固定・可変で同一なため可変列の行数を使用
        for (let rwCount = 0; rwCount < tbodyc?.length; rwCount++) {
          const currentTrc = tbodyc[rwCount].children;
          const currentLockTrc = [];

          // 編集項目の色を変更
          let edited = this.changeEditColor(currentTrc, currentLockTrc);
          // this.changeEditColor(currentTrc, currentLockTrc);

          // モーダルからの編集も色を変更する
          if (
            this.isEdited(gridData?._view?.[rwCount]?.code)
          ) {
            edited = true;
          }
          // 並び順以外の項目が変更されていた場合は、削除か修正にあわせて並び順より後の項目の背景色を変更
          this.changeRowColor(currentTrc, currentLockTrc, edited, false);
          // データ参照エラーコンボの背景色を変更
          // this.changeRefErrorComboColor(currentTrc, false);
        }
      });
    },
    // 装置記録マスタ バグ修正 end
    // del 装置記録マスタ ページネーションを削除 start
    // pageInputEnter(event){
    //   this.formatPage(event);
    //   this.setPage(this.pageInputValue);
    // },
    // formatPage(event){
    //   if(event && event.target.value && event.target.value!="" && event.target.value!=null){
    //     if(event.target.value <= 1){
    //       event.target.value = 1
    //       return this.pageInputValue = 1;
    //     }
    //     if(event.target.value >= this.totalPage){
    //       event.target.value = this.totalPage
    //       return this.pageInputValue = this.totalPage;
    //     }
    //     return this.pageInputValue = parseInt(event.target.value);
    //   }
    //   event.target.value = this.pageInputValue;
    // },
    // setTotalPage(List){
    //   List=List.data&&List.data.length>0?List:{data:[]};
    //   this.totalPage = Math.ceil(List.data.length/this.pageSize) || 1;
    // },
    // Pagination(RecordList){
    //   RecordList = JSON.parse(JSON.stringify(RecordList))
    //   let temp = []
    //   const startItem = this.pageSize*(this.pageNum-1)+1;
    //   const endItem = this.pageSize*this.pageNum;
    //   for (let index = 1; index <= RecordList.data.length; index++) {
    //     if (index >= startItem && index <= endItem){
    //       const element = RecordList.data[index-1];
    //       temp.push(element);
    //     }
    //   }
    //   RecordList.data=temp
    //   return RecordList
    // },
    // setPage(num){
    //   if(num <= 1){
    //     return this.pageNum = 1;
    //   }
    //   if(num >= this.totalPage){
    //     return this.pageNum = this.totalPage;
    //   }
    //   this.pageNum = num;
    // },
    // del 装置記録マスタ ページネーションを削除 end
    // add 性能改善 劉 start
    // データ処理
    generatedGridData: function(pageSize = 30){
      var that = this;

      const columnObject = {};
      that.columns.forEach(column => {
        let name = column.field;
        if ("dummy" !== name){
          columnObject[name] = {};
        } else {
          columnObject[name] = column;
        }
      })
      return markRaw(new kendo.data.DataSource({
        // mod #6251 装置記録マスタの表がMAX30行固定のため無駄な余白ができる 付 start
        pageSize: pageSize,
        // mod #6251 装置記録マスタの表がMAX30行固定のため無駄な余白ができる 付 end
        transport: {
          read: function(e){
            e.success(that.masterRecords.data)
          }
        },
        schema: {
          fields: columnObject
        }
      }));
    },
    // add 性能改善 劉 end
    //  条件にマスタ名が設定されている場合は名前で抽出
    searchRecord(RecordList){
      RecordList = JSON.parse(JSON.stringify(RecordList))
      let RecordListData = RecordList.data;
      if (RecordListData && RecordListData.length > 0){
        const parseString = data => (data ? String(data) : "");
        if (this.condition.recordCode != "") {
          const recordCode = parseString(this.condition.recordCode);
          const includesrecordCode = data =>
            parseString(data).indexOf(recordCode) !== -1;
          RecordListData = RecordListData.filter(
            e => includesrecordCode(e["code"])
          );
        }
        if (this.condition.recordMessage != "") {
          const recordMessage = parseString(this.condition.recordMessage);
          const includesRecordMessage = data =>
            parseString(data).indexOf(recordMessage) !== -1;
          RecordListData = RecordListData.filter(
            e => includesRecordMessage(e["machineRecordMessage"])
          );
        }
        if (this.condition.dispFlg != "") {
          const dispFlg = parseString(this.condition.dispFlg);
          const includesDispFlg = data =>
            parseString(data).indexOf(dispFlg) !== -1;
          RecordListData = RecordListData.filter(
            e => includesDispFlg(e["dispFlg"])
          );
        }
        RecordList.data = RecordListData;
      }
      return RecordList
    },
    setMchineRecordColntrolcondition(value){
      this.condition.recordCode = value.recordCode;
      this.condition.recordMessage = value.recordMessage;
      this.condition.dispFlg = value.dispFlg;
      this.pageNum=1;

      // 装置記録マスタ バグ修正 start
      this.dataSourceItems = this.generatedGridData();
      this.applyDirectGridDataSourceContract();
      // 装置記録マスタ バグ修正 end
    },

    // グリッドのデータ再表示
    gridDataRefresh() {
      if (this.refreshDirectGridDataFromMasterRecords(false)) {
        return;
      }
      this.dataSourceItems = this.generatedGridData();
      this.applyDirectGridDataSourceContract();
    },

    // 施設一覧のデータを取得
    findFacilityList() {
      // 日機装ユーザ以外の場合
      if (this.getStateUserAccountInfo.userType !== 1) {
        // ログイン者の担当施設を選択（初期値は自分の所属する施設）
        this.facilitylistValue = this.getStateUserAccountInfo.facilityCd;
        // 選択した施設を元にベッド一覧の取得
        this.findList();
        return;
      }
      // apiをコールして施設一覧を取得
      this.facilityList()
        .then(() => {
          // ログイン者の担当施設を選択
          this.facilitylistValue = this.getStateUserAccountInfo.facilityCd;
          // 選択した施設を元にベッド一覧の取得
          this.findList();
        })
        .catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
          getErrorMessage('MstMachineRecordControlMainComponent.vue', 'findFacilityList', '指定されたマスタが見つかりません。');
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
          if (error.response.status === 400) {
            this.$ons.notification.alert({
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // title: "取得失敗",
              title: DIALOG_MESSAGES[12000003].title,
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
              // add 全マスタメッセージ調整 王 start
              // message: "指定されたマスタが見つかりません。"
              message: DIALOG_MESSAGES[12000003].message
              // add 全マスタメッセージ調整 王 end
            });
          }
        });
    },
    onOpenFacility(e) {
      // 変更前の値を取得
      this.prevFacilityCd = e.sender._old;
    },
    // 施設を選択時の動作
    onChangeFacility(e) {
      if(this.prevFacilityCd != e.sender._old) {
        this.pageNum = 1;
        // 選択施設の拡張設定を取得
        var newFacilityAdvancedSettings = {};
        const selectedItem = e.sender?.dataItem?.() || {};
        try {
          if (selectedItem?.advancedSettings) {
            newFacilityAdvancedSettings = JSON.parse(selectedItem.advancedSettings);
          }
        } catch(error) {
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
          getErrorMessage('MstMachineRecordControlMainComponent.vue', 'onChangeFacility', error);
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
          newFacilityAdvancedSettings = {};
        }

        if (!newFacilityAdvancedSettings.func_advcds) {
          newFacilityAdvancedSettings.func_advcds = [];
        }

        const enableHomeDialysis = newFacilityAdvancedSettings.func_advcds.some(
          setting => setting.func_advcd === ADVANCED_SETTINGS.HOME_DIALYSIS
        );

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
                // 選択した施設を元に装置一覧の取得
                this.facilitylistValue = newFacilityCd;
                // 選択施設の在宅機能有無を取得
                this.facilityHemoDialysis = enableHomeDialysis;
                this.findList();
              } else {
                // 変更前の施設を設定する
                this.facilitylistValue = this.prevFacilityCd;
              }
            }
          });
        } else {
          // 選択した施設を元に装置一覧の取得
          this.facilitylistValue = e.sender._old;
          // 選択施設の在宅機能有無を取得
          this.facilityHemoDialysis = enableHomeDialysis;
          this.findList();
        }
      }
    },
    // マスタ一覧のデータを取得
    findList() {
      this.setLoadingScreenVisible(true)
      // apiをコールして値を取得
      this.findRecordListByFacilityCdWithSql(this.facilitylistValue)
        .then(response => {
          // カラム情報のJSONが未定義の場合には、ダイアログを出して画面を閉じる
          if (response.data.columns.length === 0) {
            this.$ons.notification.alert({
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // title: "取得失敗",
              title: DIALOG_MESSAGES[12000001].title,
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
              message:
              // add 全マスタメッセージ調整 王 start
              // "マスタ定義にカラム情報が登録されていません。<BR>カラム情報を登録してください。",
              DIALOG_MESSAGES[12000001].message,
              // add 全マスタメッセージ調整 王 end
              callback: () => {
                this.cancel();
              }
            });
          }

          // editableをKendoUI用にfunctionオブジェクトに変換
          const toFunction = response.data.columns;
          const myFacility = this.getFacilityList.filter(
            e => e.facilityCd === this.facilitylistValue
          );
          const sysUseSetNo = myFacility.length > 0 ? myFacility[0].systemUseSetting : this.getSystemUseSetting;
          toFunction.forEach(column => {
            // 初期表示時の編集可否を退避
            column.originalEditable = column.editable;
            // 編集可否を関数化
            column.editable = column.editable ? () => true : () => false;
            // 列幅初期化
            column["width"] = column.width ? column.width : "0";
            // 表示設定カラムを、ReMSのみの場合非表示にする
            if (sysUseSetNo === "1" & column.field === "dispFlg") {
              column.hidden = true;
            }
          });
          // 並び順列は本マスタでは使用しないため除外
          this.columns = toFunction.filter(
            column => column.field !== "sortRank" && column.field !== "sortInputTime"
          );

          // 横スクロールバーを表示するために列幅を指定
          this.columns.forEach(column => {
            // 「削除」のプルダウンが改行しない幅に調整
            column.width = this.columnWidth + "em";
            if (column.field === "machineRecordMessage")column.width = "20em";
            if (column.field === "dispFlg")column.width = "20em";
            // del 装置記録マスタ 装置フラグを削除，警報フラグを削除 start
            // if (column.field === "machineFlg")column.width = "20em";
            // if (column.field === "alarmFlg")column.width = "20em";
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
          // this.$nextTick(() => {
          //   this.calculateGridHeight();
          //   this.calculateGridWidth();
          //   /* add スクロールの位置を維持 楊 start */
          //   setTimeout(() => {
          //       this.lastScrollTop = 0;
          //       this.lastScrollLeft = 0;
          //     }, 1000);
          //   });
            /* add スクロールの位置を維持 楊 end */
          // 初期データ内容を保存
          this.setComparisonRecordModel();
          // add 性能改善 劉 start
          const shouldRefreshGridInPlace = this.preserveGridScrollAfterSave && !!this.directGridWidget;
          if (!shouldRefreshGridInPlace) {
            this.dataSourceItems = null;
            this.dataSourceItems = this.generatedGridData();
          }
          this.$nextTick(() => {
            this.calculateGridHeight();
            if (shouldRefreshGridInPlace) {
              this.calculateGridWidth();
              this.refreshDirectGridDataFromMasterRecords(false);
              this.schedulePendingSaveScrollRestore();
              return;
            }
            this.calculateGridWidth();
            this.initDirectGridIfReady();
            this.applyDirectGridDataSourceContract();
            this.scheduleDirectGridLayoutContract();
          });
          // add 性能改善 劉 end
        })
        .catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
          getErrorMessage('MstMachineRecordControlMainComponent.vue', 'findList', '指定されたマスタが見つかりません。');
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
          if (error.response.status === 400) {
            this.$ons.notification.alert({
             // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // title: "取得失敗",
              title: DIALOG_MESSAGES[12000003].title,
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
              // add 全マスタメッセージ調整 王 start
              // message: "指定されたマスタが見つかりません。"
              message: DIALOG_MESSAGES[12000003].message
              // add 全マスタメッセージ調整 王 end
            });
          }
        })
        .finally(() => this.setLoadingScreenVisible(false));
      // カラム定義情報を取得
      this.findColumnInfo();
      this.scrollRestored = false;
    },
    setFilterCondition(condition) {
      this.condition.recordName = condition.recordName;
      this.condition.includeDeleted = condition.includeDeleted;
    },
    async saveRecord() {
      // 共通ローダー:表示開始
      this.setLoadingScreenVisible(true);
      //イベント発生前のスクロールバーの位置を保持
      this.capturePendingSaveScrollSnapshot();
      // グリッドでエラーが発生している場合は処理を中断
      if (!this.validateBeforeGridAction()) {
        // 共通ローダー：表示終了
        this.clearPendingSaveScrollSnapshot();
        this.setLoadingScreenVisible(false);
        return;
      }

      // 新規追加＆未入力のレコードを除外
      const records = this.getMasterRecordList;
      records.data = records.data.filter(
        r => !((!r.operation || r.operation === 1) && !r.edited)
      );
      this.setMasterRecordList(records);

      // 必須エラーをチェック
      const validateMessage = this.validateRequired();
      // コンボで削除済みのレコードが指定されていないかをチェック
      const validateComboMessage = this.validateComboValue();

      let message = "";
      // add 全マスタメッセージ調整 王 start
      if (validateMessage.length !== 0) {
        // message = "以下の列に未入力項目が存在します。" + validateMessage;
        message = DIALOG_MESSAGES[12000005].message + validateMessage;
      }
      if (validateComboMessage.length !== 0) {
        if (message.length !== 0) message = message + "</br>";
        message =
          // message + "以下の列の選択を見直してください。" + validateComboMessage;
          message + DIALOG_MESSAGES[12000006].message + validateComboMessage;
      }
      // add 全マスタメッセージ調整 王 end
      // エラーメッセージは左寄せで表示
      if (message.length !== 0) {
        //共通ローダー：表示終了
        this.clearPendingSaveScrollSnapshot();
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

      // 登録用項目一覧
      const keys = [
        // "machineRecordCd",
        "machineRecordMessage",
        "dispFlg",
        // del 装置記録マスタ 装置フラグを削除，警報フラグを削除 start
        // "machineFlg",
        // "alarmFlg"
        // del 装置記録マスタ 装置フラグを削除，警報フラグを削除 end
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
          machineRecordCd: record["code"],
          facilityCd: this.facilitylistValue,
          regDate: now,
          upDate: now
        })
      );

      //登録更新用レコードの作成
      const editRecord = {
        insertRecord: serializedInsertRecords
      }
      ApiHelper.put(`/master_maintenance/saveMachineRecord/${this.facilitylistValue}`,editRecord)
        .then(response => {
          this.updateResponse = response.data;
          this.$ons.notification.alert({
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // title: "更新完了",
              title: DIALOG_MESSAGES[12000004].title,
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
              // add 全マスタメッセージ調整 王 start
              // message: "マスタ更新が完了しました。"
              message: DIALOG_MESSAGES[12000004].message
              // add 全マスタメッセージ調整 王 end
          });
          this.findList();
        })
        .catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
          getErrorMessage('MstMachineRecordControlMainComponent.vue', 'saveRecord', error);
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
          this.clearPendingSaveScrollSnapshot();
        })
        // 共通ローダー：表示終了
        .finally(() => this.setLoadingScreenVisible(false));
    },
    loadGridData(){
      this.findList();
      // del 装置記録マスタ 装置フラグを削除，警報フラグを削除 start
      // this.pageNum=1;
      // del 装置記録マスタ 装置フラグを削除，警報フラグを削除 end
    },
    refresh() {
      // 他の画面に遷移したときもrefresh()が発生する為、自分の画面のみ処理する
      if (this.selfScreenName === this.getCurrentRouteName()
        && getScopedAlertDialogs(this.$el || this).length === 0) {
        if (this.getisChanged()) {
          this.$ons.notification.confirm({
            // title: "内容破棄",
            title: DIALOG_MESSAGES[13000004].title,
            // message: "編集内容が破棄されます。</br>よろしいですか？",
            message: messageFormat(DIALOG_MESSAGES[13000004].message),
            callback: answer => {
              if (answer === 1) {
                //スクロールバーの位置をクリア
                this.clearScrollPosition();
                this.findList();
              }
            },
          });
        }
        else {
          //スクロールバーの位置をクリア
          this.clearScrollPosition();
          this.findList();
        }
      }
    },
    /**
     * @description スクロールバーの位置をクリアする
    */
    clearScrollPosition() {
      this.clearPendingSaveScrollSnapshot();
      this.lastScrollTop = 0;
      this.lastScrollLeft = 0;
    },
    onSave(ev) {
      this.onDirectGridSave(ev);
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
    observeZoomChange() {
      const target = this.getGridRootEl()?.ownerDocument?.body || this.$el?.ownerDocument?.body || globalThis?.document?.body || null;
      if (!target || typeof ResizeObserver === "undefined") {
        return;
      }
      this.zoomObserver = new ResizeObserver(() => {
        this.$nextTick(() => this.refreshDirectGridPageSizeByFont());
      });
      this.zoomObserver.observe(target);
    },
  },
  created() {
    this.setLoadingScreenVisible(true);
    this.facilityHemoDialysis = this.getAdvancedSettings.func_advcds.some(
      setting => setting.func_advcd === ADVANCED_SETTINGS.HOME_DIALYSIS
    );
    // apiをコールして施設一覧を取得
    // add マスタ一覧 1･施設切替を可能とする 王 start
    // this.findFacilityList();
    this.facilitylistValue = this.getFacilitySwitch
    this.findList();
    // add マスタ一覧 1･施設切替を可能とする 王 end
    this.calculateColumnsWidth();
    // mod 装置記録マスタ 装置フラグを削除，警報フラグを削除 start
    // this.loadGridData();
    this.setCondition(this.condition);
    // mod 装置記録マスタ 装置フラグを削除，警報フラグを削除 end
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
    EventBus.$on("setMchineRecordColntrolcondition", this.setMchineRecordColntrolcondition);
  },
  updated() {
    // direct jq では Vue updated ごとに全表 scan / dataSource rebuild をしない。
  },

  mounted() {
    this.directGridMounted = true;
    this.kendoValidator = { validate: () => this.validateDirectKendoGrid() };
    this.$nextTick(() => {
      this.calculateColumnsWidth();
      this.calculateGridHeight();
      this.initDirectGridIfReady();
      this.scheduleDirectGridLayoutContract();
      this.observeZoomChange();
    });
    EventBus.$on("clearScrollPosition", this.clearScrollPosition);
  },
  // add 性能改善メモリ不足 shan start
  beforeUnmount() {
    if (this.zoomObserver) {
      this.zoomObserver.disconnect();
      this.zoomObserver = null;
    }
    this.destroyDirectGrid();
    this.clearPendingSaveScrollRestoreTimers();
    [this.directGridLayoutRafId, this.directGridFilterRefreshRafId, this.directGridScrollSyncRafId].forEach(id => {
      if (id != null) cancelAnimationFrame(id);
    });
    this.directGridRowVisualRafIds?.forEach?.(id => cancelAnimationFrame(id));
    this.directGridRowVisualRafIds?.clear?.();
    EventBus.$off("onCloseMasterEditModal", this.onCloseMasterEditModal);
    EventBus.$off("refresh", this.refresh);
    EventBus.$off("setMchineRecordColntrolcondition", this.setMchineRecordColntrolcondition);
    EventBus.$off("clearScrollPosition", this.clearScrollPosition);
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
  position: absolute;
  width: inherit;
  z-index: 2;
  background-color: var(--ntss-list-background-color);
  box-sizing: border-box;
}
.kendo-grid-toolbar-style {
  --height: 200px;
  height: var(--height);
  border-bottom: none;
}
/*del 装置記録マスタ ページネーションを削除 start*/
.toolbar-btn {
 padding: 0.2em 1em 0em 1em;
 line-height: 2em;
 width: auto;
}
.csv-btn {
 margin-right: 1em;
}
/*del 装置記録マスタ ページネーションを削除 start*/
.kendo-grid-toolbar-style {
  padding: 0.1em 0.3em;
}
 
 
 
 

/*del 装置記録マスタ ページネーションを削除 start*/
/* .kendo-grid-toolbar-style :deep(.k-tooltip.k-tooltip-validation){ */
/*  width: auto;*/
/*}
/*del 装置記録マスタ ページネーションを削除 start*/

.kendo-grid-toolbar-style :deep(.k-grid
  tr:nth-child(n + 3):last-child
  .k-tooltip.k-tooltip-validation
  .k-callout) {
  border-bottom: 0;
  border-top: 6px solid #000;
  top: unset;
  bottom: -6px;
}

.kendo-grid-toolbar-style :deep(.k-grid
  tr:nth-child(n + 3):last-child
  .k-tooltip.k-tooltip-validation) {
  bottom: 38px;
}

.kendo-grid-toolbar-style :deep(.k-edit-cell) {
  position: relative;
  overflow: visible;
}

.kendo-grid-toolbar-style :deep(.k-grid-content > .k-selectable) {
  box-shadow: 1px 0px 0px 0px white;
  border-right: 1px solid transparent;
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
}

.kendo-grid-toolbar-style :deep(.k-grid-header-locked > table) {
  border-right-width: 0px;
}

.kendo-grid-toolbar-style :deep(.k-grid-content-locked > .k-selectable) {
  border-right-width: 0px;
}
.paginationClass {
  margin-left: 0.5em;
  margin-right: 0.5em;
}
.disableATag {
  text-decoration: none;
  pointer-events: none;
  color: #000;
}
.pageInput :deep(input){
  height: 100%;
}
.pageInput :deep(input::-webkit-outer-spin-button),
.pageInput :deep(input::-webkit-inner-spin-button) {
  -webkit-appearance: none;
}
.pageInput :deep(input[type="number"]){
  -moz-appearance: textfield;
}
.custom-switch {
  transform: scale(0.85);
  transform-origin: center;
  touch-action: manipulation;
}
.mst-machine-record-control-direct-jq-grid {
  width: 100%;
  overflow: hidden;
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

.mst-machine-record-control-direct-jq-grid :deep(td.master-edited-row),
.mst-machine-record-control-direct-jq-grid :deep(tr.k-selected > td.master-edited-row),
.mst-machine-record-control-direct-jq-grid :deep(tr.k-state-selected > td.master-edited-row),
.mst-machine-record-control-direct-jq-grid :deep(tr.k-table-row.k-selected > td.master-edited-row) {
  color: #003300 !important;
  background-color: #ccffcc !important;
}
.mst-machine-record-control-direct-jq-grid :deep(td.master-edited-cell) {
  color: #003300 !important;
  font-weight: bold !important;
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
