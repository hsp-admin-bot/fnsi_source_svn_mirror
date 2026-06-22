/**
* 機能帳票マスタメンテナンスデータページ  MainContent
*/
<template>
  <div class='main-content-area master-maintenance-page'>
    <div class='ntss-list' :style="ntssListStyles">
      <div :class="['k-grid-toolbar', 'k-header', 'kendo-grid-toolbar-style']" :style="heightStyles">
        <div id="grid-header" class='header-btn-area right' :style="isMobileDevice ? { minHeight: '30px' } : {}">
          <v-ons-button modifier="outline" class="btn3-normal toolbar-btn" style="float: left;" v-show="!isSortMode && isAllowAddRecord" @click="addRow()">追加</v-ons-button>
          <v-ons-row v-show="isMobileDevice" style="float: left; width: 6em; height: 2em;">
            <v-ons-col width="45%" vertical-align="center">
              <label class="fab-font-color">編集</label>
            </v-ons-col>
            <v-ons-col width="55%" vertical-align="center">
              <v-ons-switch modifier="outline" v-model="allowEdit" />
            </v-ons-col>
          </v-ons-row>
          <v-ons-button modifier="outline" class="btn3-normal toolbar-btn" v-show="!isSortMode && isAllowSort" @click="toRankEditBtnClick()">並び順表示</v-ons-button>
          <v-ons-button modifier="outline" class="btn3-normal toolbar-btn" v-show="isSortMode && isAllowSort" @click="sortBtnClick()">反映</v-ons-button>
        </div>
        <div
          v-show="columns.length > 1"
          ref="grid"
          :class="[
            fontSizeSet,
            'ntss-kendo-grid-legacy',
            'mst-function-report-direct-jq-grid'
          ]"
          style="clear: both;"
        ></div>
      </div>
      <div id="grid-footer">
        <v-ons-row width="100%" v-show="!isSortMode" >
          <v-ons-col width="50%">
            <v-ons-button class="btn2-cancel denial-btn" style="width: auto;" @click="cancel">キャンセル</v-ons-button>
          </v-ons-col>
          <v-ons-col width="50%" class="right">
            <v-ons-button class="btn1-execute registration-btn" style="width: auto;" :disabled="!isChanged" @click="saveRecord">保存</v-ons-button>
          </v-ons-col>
        </v-ons-row>
      </div>
    </div>
  </div>
</template>

<script>
import { markRaw } from "@/compat/vue/runtime";
import {ApiHelper} from "@/apis/AxiosHelper";
import {mapActions, mapGetters, mapMutations} from "@/compat/vue/vuex";
import {EventBus} from "@/compat/vue/event-bus.js";
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages.js";
import { messageFormat } from "@/functions/common/MessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
import {
  getClosestMainContentAreaElement,
  getFooterMenuClientHeight,
  getGridFooterClientHeight,
  getLatestHeaderElement,
  getViewportHeight,
} from "@/functions/common/LayoutMeasureHelper";
import $ from "jquery";
import kendo from "@progress/kendo-ui";
import {
  bindGridEditorDropDownListToCloseCell,
  bindGridEditorEnterToCloseCell,
  bindGridEditorNumericWheelSpinAssist,
  getGridEditFieldFromEvent,
  getGridEditorDropDownListWidget,
  readGridEditorNumericValue,
  resolveGridEditorDropDownListSaveValue,
} from "@/compat/kendo/grid-edit";
//FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
// add 6379 【機能帳票マスタ】プルダウンメニューの選択肢、動作の不正 周安寧 start

// add 6379 【機能帳票マスタ】プルダウンメニューの選択肢、動作の不正 周安寧 end

function deepCopyPlain(value) {
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
  data() {
    return {
      mstFunctionReportList: [],
      sysReportSettingList: [],
      sysReportList: [],
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
      lastScrollTop: 0,
      lastScrollLeft: 0,
      // add 6379 【機能帳票マスタ】プルダウンメニューの選択肢、動作の不正 周安寧 start
      functionCdGrouping: [],
      // add 6379 【機能帳票マスタ】プルダウンメニューの選択肢、動作の不正 周安寧 end
      androidFlg: false,
      iosFlg: false,
      allowEdit: true, // NOTE: true = 編集モード、 false = 閲覧モード
      kendoValidator: null,
      directGridMounted: false,
      directGridWidget: null,
      directGridDataSource: null,
      directGridLayoutRafId: null,
      directGridFilterRefreshRafId: null,
      directGridScrollSyncRafId: null,
      directGridVisualStateRafId: null,
      directGridVisualStateTimeoutId: null,
      directGridRowVisualRafIds: null,
      directGridResizeHandler: null,
      directGridSortEditedCodes: markRaw(new Set()),
    }
  },
  async created() {
    this.setLoadingScreenVisible(true);
    // add マスタ一覧 1･施設切替を可能とする 王 start
    await ApiHelper.get(
      `/master_maintenance/${'mst_function_report'}/data/${this.getFacilitySwitch}`).then(response => {
      this.mstFunctionReportList = response.data.localDataSource.data
    });
    // add マスタ一覧 1･施設切替を可能とする 王 end
    this.setCondition(this.condition);
    // mod 7323 機能帳票マスタの機能名リストに初回リリースに含まれない機能が表示されている 周安寧 start
    // await ApiHelper.get("/sys_report_setting/getSysRepotrSettingAll").then(response => {
    //   this.sysReportSettingList = response.data
    // });
    await ApiHelper.get("/sys_report_setting/getSysRepotrSettingAll", {
      facilityCd: this.getFacilitySwitch
    }).then(response => {
      this.sysReportSettingList = response.data
    });
    // mod 7323 機能帳票マスタの機能名リストに初回リリースに含まれない機能が表示されている 周安寧 end
    // add マスタ一覧 1･施設切替を可能とする 王 start
    //add 6502 6498 5984 定期・日常が分離されていない 吉 start
    await ApiHelper.get(
      `/master_report/data/${this.getFacilitySwitch}/"1"`).then(response => {
      this.sysReportList = response.data
    });
    //add 6502 6498 5984 定期・日常が分離されていない 吉 end
    // add マスタ一覧 1･施設切替を可能とする 王 end
    this.dataCategory();
    // add 6379 【機能帳票マスタ】プルダウンメニューの選択肢、動作の不正 周安寧 start
    this.functionGrouping();
    // add start #9590
    this.loadGridData();
    // add end #9590
    // add 6379 【機能帳票マスタ】プルダウンメニューの選択肢、動作の不正 周安寧 end
    this.selfScreenName = this.$route.name;
    EventBus.$on("onCloseMasterEditModal", this.onCloseMasterEditModal);
    EventBus.$on("refresh", this.refresh);
    // 端末判別
    const ua = ((this?.$el?.ownerDocument?.defaultView?.navigator?.userAgent) || globalThis?.navigator?.userAgent || "").toLowerCase();
    if (/android/.test(ua)) {
      this.androidFlg = true;
    } else if (/iphone|ipad|mac|os/.test(ua)) {
      this.iosFlg = true;
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
  computed:{
    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight",
      windowWidth: "getWindowWidth"
    }),
    ...mapGetters("account-edit", {
      isDispMenu: "isDispMenu",
      getFontSize: "getFontSize",
      getStateUserAccountInfo: "getStateUserAccountInfo"
    }),
    ...mapGetters("user", { facilityCd: "getFacilityCd" }),
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
      comparisonRecordModel: "getComparisonRecordModel"
    }),
    heightStyles() {
      // main部の高さをCSS変数を利用して書き換え
      return { "--height": `${this.kendoGridToolbarHeight}px` };
    },
    ntssListStyles() {
      return { display: this.columns.length == 1 ? "none" : "inherit" };
    },
    isAllowSort() {
      // allowSortが定義されていない場合は並び替えボタンは使用不可
      return !(this.getColumnIndex("allowSort") < 0);
    },
    isAllowAddRecord() {
      // allowAddRecordが定義されていない場合は追加ボタンは使用不可
      return !(this.getColumnIndex("allowAddRecord") < 0);
    },
    fontSizeSet() {
      const names = ["small", "medium", "large", "x-large"];
      return "font-size-set-" + names[this.getFontSize];
    },
    masterRecords() {
      // storeからデータを取得
      return this.getFilteredMasterRecordList;
    },
    masterConditionSignature() {
      const condition = this.$store?.state?.["master-maintenance"]?.condition || this.condition || {};
      return `${condition.recordName || ""}|${condition.includeDeleted ? 1 : 0}`;
    },
    getReportSetting(){
      let temp = [];
      for (const item of this.sysReportSettingList) {
        temp.push({
          "text":item.functionName,
          "value":item.functionCd
        })
      }
      // const columns = this.columnDefinition;
      // if (columns.find(e => e.field === "functionCd") !== undefined) {
      //   columns.find(e => e.field === "functionCd").values = temp;
      //   this.setColumns(columns);
      // }
      return temp
    },
    getReport(){
      let temp = [];
      for (const item of this.sysReportList) {
        temp.push({
          "text":item.reportName,
          "value":item.reportCd
        })
      }
      // del #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe start
      // // add bug 6410 修正 吉 start
      // temp.push({
      //   "text": "治療経過表（自動選択）",
      //   "value": '-3'
      // })
      // temp.push({
      //   "text": "治療経過表（手書き：自動選択）",
      //   "value": '-4'
      // })
      // // add bug 6410 修正 吉 end
      // //add 6498 装置帳票：点検結果が機能帳票で出力できない 吉 start
      // temp.push({
      //   "text": "日常点検記録簿",
      //   "value": '-5'
      // })
      // temp.push({
      //   "text": "定期点検・交換部品記録簿",
      //   "value": '-6'
      // })
      // //add 6498 装置帳票：点検結果が機能帳票で出力できない 吉 end
      // del #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe end
      // const columns = this.columnDefinition;
      // if (columns.find(e => e.field === "reportCd") !== undefined) {
      //   columns.find(e => e.field === "reportCd").values = temp;
      //   this.setColumns(columns);
      // }
      return temp
    },
    isChanged() {
      const data = this.getMasterRecordList.data;
      return (
        this.getStateUserAccountInfo !== null &&
        data !== undefined &&
        (this.isRecordModified || (this.kendoValidator && !this.kendoValidator.validate()))
      );
    },
    isMobileDevice() {
      return this.iosFlg || this.androidFlg;
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
      "findRecordListByFacilityCdWithSql",
      "updateIndCondInfo",
      // "setColumns"
    ]),
    // add start #9590
    ...mapMutations("master-maintenance", ["setColumns"]),
    // add end #9590
    ...mapActions("master-maintenance", {
      facilityList: "facilityList"
    }),
    ...mapActions("loading-screen", {
      setLoadingScreenVisible: "setLoadingScreenVisible"
    }),
    getColumnIndex(fieldName) {
      return this.columns.findIndex(column => column.field === fieldName);
    },
    cancel() {
      this.$router.go(-1);
    },
    cacheGridScrollPosition(position = this.scrollPosition) {
      const current = this.getGridScrollPosition();
      position.top = current.top;
      position.left = current.left;
    },
    setScrollPosition(position) {
      this.setGridScrollPosition(position);
    },
    clearScrollPosition() {
      this.scrollPosition.top = 0;
      this.scrollPosition.left = 0;
    },
    calculateColumnsWidth() {
      const ownerWindow = this.getDirectGridRoot()?.ownerDocument?.defaultView || window;
      this.columnWidth = (ownerWindow.innerWidth || this.windowWidth || 0) > 1000 ? 14 : 9;
    },
    calculateGridHeight() {
      if (this.editingFlg) {
        return false;
      }
      const scopeRoot = this.$el || this.getDirectGridRoot();
      const ownerDocument = scopeRoot?.ownerDocument || document;
      const wh = Number(this.windowHeight) || getViewportHeight(scopeRoot) || ownerDocument.defaultView?.innerHeight || 0;
      const header = getLatestHeaderElement(ownerDocument);
      const hh = header?.clientHeight || 0;
      const fmh = (this.isDispMenu === 1 ? getFooterMenuClientHeight(scopeRoot) : 0) + 5;
      let toolbarHeight = wh - hh - fmh;
      const mainBase = this.getMasterMainContentBaseHeight();
      if (Number.isFinite(mainBase) && mainBase > 0) {
        toolbarHeight = Math.min(toolbarHeight, mainBase);
      }
      this.kendoGridToolbarHeight = Math.max(100, toolbarHeight);
      const footerHeight = getGridFooterClientHeight(scopeRoot) || 0;
      const headerButtonHeight = this.getHeaderButtonAreaHeight();
      this.kendoGridHeight = Math.max(160, this.kendoGridToolbarHeight - footerHeight - headerButtonHeight);
      const gridRoot = this.getDirectGridRoot();
      if (gridRoot && Number.isFinite(this.kendoGridHeight)) {
        gridRoot.style.height = `${this.kendoGridHeight}px`;
      }
      return true;
    },
    getMasterMainContentBaseHeight() {
      const scopeRoot = this.$el || this.getDirectGridRoot();
      const ownerDocument = scopeRoot?.ownerDocument || document;
      const mainEl = scopeRoot?.closest?.("#main-id") || ownerDocument.getElementById("main-id");
      const cssHeight = mainEl ? parseFloat(getComputedStyle(mainEl).getPropertyValue("--height")) : NaN;
      if (Number.isFinite(cssHeight) && cssHeight > 0) {
        return cssHeight - 5;
      }
      const measuredHeight = getClosestMainContentAreaElement(scopeRoot)?.clientHeight;
      return Number.isFinite(measuredHeight) && measuredHeight > 0 ? measuredHeight : NaN;
    },
    getHeaderButtonAreaHeight() {
      const gridRoot = this.getDirectGridRoot();
      const toolbar = gridRoot?.closest?.(".k-grid-toolbar");
      if (gridRoot && toolbar) {
        const toolbarTop = toolbar.getBoundingClientRect?.().top;
        const gridTop = gridRoot.getBoundingClientRect?.().top;
        const diff = gridTop - toolbarTop;
        if (Number.isFinite(diff) && diff > 0) {
          return diff;
        }
      }
      const headerButton = this.$el?.querySelector?.("#grid-header, .header-btn-area");
      if (headerButton) {
        const childBottoms = Array.from(headerButton.children || [])
          .map(child => child.getBoundingClientRect?.()?.bottom)
          .filter(value => Number.isFinite(value));
        const ownTop = headerButton.getBoundingClientRect?.()?.top;
        const maxBottom = childBottoms.length ? Math.max(...childBottoms) : NaN;
        const visualHeight = maxBottom - ownTop;
        if (Number.isFinite(visualHeight) && visualHeight > 0) {
          return visualHeight;
        }
        return headerButton.clientHeight || 0;
      }
      return 0;
    },
    calculateGridWidth() {
      this.resizeDirectGrid();
    },
    getMaxSortRank() {
      const data = this.getFilteredMasterRecordList?.data || [];
      if (data.length > 0) {
        return data.reduce((max, row) => Math.max(max, +row.sortRank || 0), 0);
      }
      return 0;
    },
    syncDirectGridColumnStateToWidget() {
      const grid = this.getDirectGridWidget();
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
        column.editable = column.field === "sortRank"
          ? () => false
          : column.originalEditable
            ? () => true
            : () => false;
      });
      this.syncDirectGridColumnStateToWidget();
    },
    disableColumns() {
      this.columns.forEach(column => {
        column.editable = column.field === "sortRank"
          ? this.isAllowSort
            ? () => true
            : () => false
          : () => false;
      });
      this.syncDirectGridColumnStateToWidget();
    },
    sort() {
      const list = this.getMasterRecordList?.data || [];
      list.sort((a, b) => (Number(a.sortRank) || 0) - (Number(b.sortRank) || 0));
      list.filter(row => row.isDisp !== "0").forEach((row, index) => {
        row.sortRank = index + 1;
      });
    },
    sortChange(tempData) {
      let changed = false;
      (this.getMasterRecordList?.data || []).forEach(item => {
        tempData.forEach(tempItem => {
          if (item.code === tempItem.code && item.sortRank !== tempItem.sortRank) {
            changed = true;
          }
        });
      });
      return changed;
    },
    editStart(e) {
      if (this.androidFlg) {
        this.editingFlg = true;
      }
      this.$nextTick(() => {
        if (e?.sender?.editable?.options?.fields?.field === "isDisp") {
          const element = this.getDirectGridScrollContent();
          element?.scrollTo?.({ left: element.scrollWidth - element.clientWidth, behavior: "smooth" });
        }
        const textInput = this.getDirectGridRoot()?.querySelector?.(".k-input.k-textbox");
        if (textInput) {
          textInput.setAttribute("title", "");
        }
        const editCell = this.getDirectGridRoot()?.querySelector?.(".k-edit-cell");
        const editTarget = editCell?.children?.[0];
        if (editTarget?.title) {
          editTarget.title = "";
        }
      });
    },
    editEnd(ev) {
      this.editingFlg = false;
      const gridRoot = this.getDirectGridRoot();
      if (gridRoot && gridRoot.__mstFunctionReportGridMouseWheelRestored !== false) {
        gridRoot.onmousewheel = null;
        gridRoot.__mstFunctionReportGridMouseWheelRestored = true;
      }
      if (ev?.model) {
        this.scheduleDirectGridRowVisualState(ev.model, ev.model.uid);
      }
    },
    addInputAssist(ev) {
      this.lastInputScrollLeft = this.getGridScrollPosition().left || 0;
      const grid = ev?.sender || this.getDirectGridWidget();
      const container = ev?.container;
      if (grid && container) {
        bindGridEditorDropDownListToCloseCell(grid, container);
      }
    },
    convertToStr(messageArr) {
      if (!messageArr || messageArr.length === 0) {
        return "";
      }
      const unique = [];
      messageArr.forEach(message => {
        if (unique.indexOf(message) < 0) {
          unique.push(message);
        }
      });
      return "</br>&nbsp&nbsp・" + unique.join("</br>&nbsp&nbsp・");
    },
    validateRequired() {
      const validateMessageArr = [];
      const gridData = this.getMasterRecordList;
      const rows = (gridData?.data || []).filter(row => row.isDisp !== "0");
      const fields = gridData?.schema?.model?.fields || {};
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
        if (!row.reportCd) {
          const reportColumn = this.columns.find(column => column.field === "reportCd");
          if (reportColumn?.title) {
            validateMessageArr.push(reportColumn.title);
          }
        }
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
          if (row.operation === undefined) {
            return;
          }
          const columnValue = row[combo.field];
          const index = (combo.values || []).findIndex(value => value.value == columnValue);
          if (index < 0 && columnValue !== null && columnValue !== "") {
            validateMessageArr.push(combo.title);
          }
        });
      });
      return this.convertToStr(validateMessageArr);
    },
    onCloseMasterEditModal() {
      this.$nextTick(() => {
        this.setScrollPosition(this.scrollPosition);
      });
      setTimeout(() => {
        this.setScrollPosition(this.scrollPosition);
      }, 1000);
    },
    refresh() {
      if (this.selfScreenName !== this.$route.name) {
        return;
      }
      if (this.isChanged) {
        this.$ons.notification.confirm({
          title: DIALOG_MESSAGES[13000004]?.title || "内容破棄",
          message: messageFormat(DIALOG_MESSAGES[13000004].message),
          callback: answer => {
            if (answer === 1) {
              this.clearScrollPosition();
              this.findList();
            }
          }
        });
      } else {
        this.clearScrollPosition();
        this.findList();
      }
    },
    getDirectGridRoot() {
      return this.$refs.grid || null;
    },
    getDirectGridWidget() {
      return this.directGridWidget || $(this.$refs.grid).data("kendoGrid") || null;
    },
    getDirectGridScrollContent() {
      const grid = this.getDirectGridWidget();
      return grid?.content?.[0] || this.getDirectGridRoot()?.querySelector?.(".k-grid-content") || null;
    },
    getDirectGridLockedScrollContent() {
      const grid = this.getDirectGridWidget();
      return grid?.lockedContent?.[0] || this.getDirectGridRoot()?.querySelector?.(".k-grid-content-locked") || null;
    },
    getGridScrollPosition() {
      const content = this.getDirectGridScrollContent();
      return {
        top: content?.scrollTop || 0,
        left: content?.scrollLeft || 0
      };
    },
    setGridScrollPosition(position = {}) {
      const content = this.getDirectGridScrollContent();
      const lockedContent = this.getDirectGridLockedScrollContent();
      if (content) {
        if (typeof position.top === "number") {
          content.scrollTop = position.top;
        }
        if (typeof position.left === "number") {
          content.scrollLeft = position.left;
        }
        $(content).trigger("scroll");
      }
      if (lockedContent && typeof position.top === "number") {
        lockedContent.scrollTop = position.top;
      }
    },
    getDirectGridDisplayDataSourceOption() {
      const source = this.masterRecords || this.getFilteredMasterRecordList || {};
      return {
        ...source,
        data: Array.isArray(source.data) ? source.data : []
      };
    },
    createDirectGridDataSource() {
      this.directGridDataSource = markRaw(new kendo.data.DataSource(this.getDirectGridDisplayDataSourceOption()));
      return this.directGridDataSource;
    },
    formatDirectGridComboCell(field, value) {
      if (value === null || value === undefined || value === "") {
        return "";
      }
      const column = (this.columns || []).find(item => item.field === field);
      let text = (column?.values || []).find(item => item.value == value)?.text;
      if (text == null || text === "") {
        const fallbackByField = {
          reportCd: () => this.sysReportList.find(item => item.reportCd == value)?.reportName,
          functionCd: () => this.sysReportSettingList.find(item => item.functionCd == value)?.functionName,
        };
        const fallback = fallbackByField[field]?.();
        if (fallback != null && fallback !== "") {
          text = fallback;
        }
      }
      return kendo?.htmlEncode ? kendo.htmlEncode(String(text ?? "")) : String(text ?? "");
    },
    installDirectGridComboDropDownList(container, data, dataSource, currentValue) {
      const that = this;
      const $input = $(`<input name="${data.field}" class="k-input k-textbox k-valid" />`).appendTo(container);
      $input.kendoDropDownList({
        dataSource,
        dataTextField: "text",
        dataValueField: "value",
        valuePrimitive: true,
        autoSelectFirstOnEmpty: false,
        value: currentValue,
        filter: "contains",
        select(e) {
          const dataItem = e.dataItem ?? e.sender?.dataItem?.();
          let selectedValue = dataItem != null ? dataItem.value : e.sender.value();
          const schemaType = that.getMasterRecordList?.schema?.model?.fields?.[data.field]?.type;
          if (schemaType === "number" && selectedValue !== undefined && selectedValue !== null && selectedValue !== "") {
            const numeric = Number(selectedValue);
            selectedValue = Number.isNaN(numeric) ? selectedValue : numeric;
          }
          if (typeof data.model.set === "function") {
            data.model.set(data.field, selectedValue);
          } else {
            data.model[data.field] = selectedValue;
          }
          data.model.__ntssComboSave = { field: data.field, value: selectedValue };
          that.edit({ editRecord: data.model, isSortMode: that.isSortMode });
          that.scheduleDirectGridRowVisualState(data.model, data.model.uid);
        }
      });
      $input.data("kendoDropDownList")?.wrapper?.css?.("width", "100%");
    },
    buildDirectGridColumns() {
      const customComboEditors = {
        functionCd: (container, options) => this.filterChangefunctionCd(container, options),
        reportCd: (container, options) => this.filterChangeReportCD(container, options),
      };
      return (this.columns || []).map(column => {
        const gridColumn = { ...column };
        const installEditor = customComboEditors[column.field];
        if (installEditor) {
          const field = column.field;
          gridColumn.editor = (container, options) => installEditor(container, options);
          gridColumn.template = dataItem => this.formatDirectGridComboCell(
            field,
            typeof dataItem?.get === "function" ? dataItem.get(field) : dataItem?.[field]
          );
          delete gridColumn.values;
        }
        return gridColumn;
      });
    },
    initDirectGridIfReady() {
      const root = this.getDirectGridRoot();
      if (!this.directGridMounted || !root || this.columns.length <= 1) {
        return;
      }
      installComponentJQuery();
      const existingGrid = $(root).data("kendoGrid");
      if (existingGrid) {
        this.directGridWidget = markRaw(existingGrid);
        this.applyDirectGridColumnsContract();
        this.scheduleDirectGridFilterRefresh();
        this.scheduleDirectGridLayoutContract();
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
          // resize 由来の dataBound から layout schedule を呼ぶと無限ループになるため、
          // 列表示状態と locked 幅/高さの style contract のみ同期する。
          this.syncDirectGridColumnVisibilityContract();
          this.applyDirectGridLegacyStyleContract();
          this.refreshDirectGridVisualState();
          this.scheduleDirectGridVisualStateRefresh();
        }
      });
      this.directGridWidget = markRaw($(root).data("kendoGrid"));
      this.installDirectGridFacade();
      this.applyDirectGridLegacyStyleContract();
      this.scheduleDirectGridLayoutContract();
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
      root.gridAutoScrollableEl = () => this.getDirectGridScrollContent();
      root.gridLockedContentEl = () => this.getDirectGridLockedScrollContent();
      root.gridLockedContentEls = () => Array.from(root.querySelectorAll(".k-grid-content-locked"));
      root.gridDataItem = row => this.directGridWidget?.dataItem?.(row);
      root.requestGridResize = () => this.resizeDirectGrid();
      root.scrollGridTo = position => this.setGridScrollPosition(position);
    },
    destroyDirectGrid() {
      [
        this.directGridLayoutRafId,
        this.directGridFilterRefreshRafId,
        this.directGridScrollSyncRafId,
        this.directGridVisualStateRafId
      ].forEach(id => {
        if (id != null) {
          cancelAnimationFrame(id);
        }
      });
      this.directGridRowVisualRafIds?.forEach?.(id => cancelAnimationFrame(id));
      this.directGridRowVisualRafIds?.clear?.();
      if (this.directGridVisualStateTimeoutId != null) {
        clearTimeout(this.directGridVisualStateTimeoutId);
      }
      this.directGridVisualStateRafId = null;
      this.directGridVisualStateTimeoutId = null;
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
    },
    applyDirectGridColumnsContract() {
      const grid = this.getDirectGridWidget();
      if (!grid) {
        return;
      }
      const currentSignature = (grid.columns || []).map(column => `${column.field}:${column.hidden ? 1 : 0}`).join("|");
      const nextSignature = (this.columns || []).map(column => `${column.field}:${column.hidden ? 1 : 0}`).join("|");
      if (currentSignature === nextSignature) {
        return;
      }
      const position = this.getGridScrollPosition();
      grid.setOptions({ columns: this.buildDirectGridColumns() });
      this.$nextTick(() => {
        this.applyDirectGridLegacyStyleContract();
        this.setGridScrollPosition(position);
        this.scheduleDirectGridLockedScrollContract();
      });
    },
    scheduleDirectGridFilterRefresh() {
      if (!this.getDirectGridWidget()?.dataSource) {
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
      const grid = this.getDirectGridWidget();
      if (!grid?.dataSource) {
        return;
      }
      const position = resetScroll ? { top: 0, left: 0 } : this.getGridScrollPosition();
      const sourceOption = this.getDirectGridDisplayDataSourceOption();
      const directGridData = sourceOption.data || [];
      const deletedCount = Array.from(directGridData).filter(row => String(row?.isDisp) === "0").length;
      if (deletedCount > 0) {
        console.info("[MST_FUNCTION_REPORT_GRID_DELETED]", {
          stage: "data-refresh",
          resetScroll,
          total: directGridData.length,
          deletedCount,
        });
      }
      grid.dataSource.data(directGridData);
      this.$nextTick(() => {
        this.applyDirectGridLegacyStyleContract();
        this.refreshDirectGridVisualState();
        this.setGridScrollPosition(position);
        this.scheduleDirectGridVisualStateRefresh();
      });
    },
    applyDirectGridDataSourceContract(options = {}) {
      this.refreshDirectGridDataFromMasterRecords(!!options.resetScroll);
    },
    resizeDirectGrid() {
      const grid = this.getDirectGridWidget();
      if (!grid) {
        return;
      }
      try {
        grid.setOptions({ height: this.kendoGridHeight });
        grid.resize(true);
      } catch (_error) {
        try {
          grid.resize();
        } catch (_ignore) {
          // noop
        }
      }
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
        this.applyDirectGridLegacyStyleContract();
      });
    },
    setDirectGridColumnHidden(field, hidden) {
      const grid = this.getDirectGridWidget();
      if (!grid || !field) {
        return;
      }
      const column = (grid.columns || []).find(item => item.field === field);
      if (!column || !!column.hidden === !!hidden) {
        return;
      }
      try {
        hidden ? grid.hideColumn(field) : grid.showColumn(field);
      } catch (_error) {
        // noop
      }
    },
    syncDirectGridColumnVisibilityContract() {
      const grid = this.getDirectGridWidget();
      if (!grid) {
        return;
      }
      (this.columns || []).forEach(column => {
        if (!column?.field) {
          return;
        }
        this.setDirectGridColumnHidden(column.field, !!column.hidden);
      });
    },
    scheduleDirectGridLockedScrollContract() {
      if (this.directGridScrollSyncRafId != null) {
        cancelAnimationFrame(this.directGridScrollSyncRafId);
      }
      this.directGridScrollSyncRafId = requestAnimationFrame(() => {
        this.directGridScrollSyncRafId = requestAnimationFrame(() => {
          this.directGridScrollSyncRafId = null;
          this.setGridScrollPosition(this.getGridScrollPosition());
        });
      });
    },
    applyDirectGridLockedWidthContract() {
      const root = this.getDirectGridRoot();
      if (!root) {
        return;
      }
      const lockedHeader = root.querySelector(".k-grid-header-locked");
      const lockedContent = root.querySelector(".k-grid-content-locked");
      if (!lockedHeader && !lockedContent) {
        return;
      }
      const fontSize = parseFloat(getComputedStyle(root).fontSize || "16") || 16;
      const lockedWidth = (this.columns || [])
        .filter(column => column.locked && !column.hidden)
        .reduce((total, column) => total + this.resolveDirectGridColumnWidth(column.width, fontSize), 0);
      if (lockedWidth <= 0) {
        return;
      }
      [
        lockedHeader,
        lockedContent,
        root.querySelector(".k-grid-header-locked table"),
        root.querySelector(".k-grid-content-locked table")
      ].forEach(element => {
        if (element) {
          element.style.width = `${lockedWidth}px`;
          element.style.minWidth = `${lockedWidth}px`;
        }
      });
    },
    applyDirectGridLockedHeightContract() {
      const content = this.getDirectGridScrollContent();
      const lockedContent = this.getDirectGridLockedScrollContent();
      if (!content || !lockedContent) {
        return;
      }
      if (content.clientHeight > 0) {
        lockedContent.style.height = `${content.clientHeight}px`;
        lockedContent.style.maxHeight = `${content.clientHeight}px`;
      }
    },
    resolveDirectGridColumnWidth(width, fontSize) {
      if (typeof width === "number") {
        return width;
      }
      if (typeof width !== "string") {
        return 0;
      }
      const trimmed = width.trim();
      if (trimmed.endsWith("em")) {
        return parseFloat(trimmed) * fontSize;
      }
      if (trimmed.endsWith("px")) {
        return parseFloat(trimmed);
      }
      const numeric = parseFloat(trimmed);
      return Number.isFinite(numeric) ? numeric : 0;
    },
    applyDirectGridLegacyShellClasses() {
      const root = this.getDirectGridRoot();
      if (!root) {
        return;
      }
      root.classList.add("ntss-kendo-grid-legacy", "k-widget", "k-grid", "k-editable", "k-display-block");
    },
    applyDirectGridLegacyContentClasses() {
      const root = this.getDirectGridRoot();
      if (!root) {
        return;
      }
      root.querySelectorAll("th").forEach(th => th.classList.add("k-header"));
      [".k-grid-content tbody", ".k-grid-content-locked tbody"].forEach(selector => {
        root.querySelectorAll(selector).forEach((tr, index) => {
          tr.classList.add("k-master-row");
          tr.classList.toggle("k-alt", index % 2 === 1);
        });
      });
      root.querySelectorAll(".k-grid-content tbody td, .k-grid-content-locked tbody td").forEach(td => td.classList.add("k-td", "k-table-td"));
    },
    applyDirectGridLegacyStyleContract() {
      this.applyDirectGridLegacyShellClasses();
      this.applyDirectGridLegacyContentClasses();
      this.applyDirectGridLockedWidthContract();
      this.applyDirectGridLockedHeightContract();
    },
    getDirectGridCellIndexByField(fieldName) {
      const grid = this.getDirectGridWidget();
      return (grid?.columns || this.columns || []).filter(column => !column.hidden).findIndex(column => column.field === fieldName);
    },
    getDirectGridModelPlain(model, overrides = {}) {
      const plain = typeof model?.toJSON === "function" ? model.toJSON() : deepCopyPlain(model || {});
      Object.keys(overrides || {}).forEach(key => {
        plain[key] = overrides[key];
      });
      return plain;
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
    getDirectGridCompareFields(record, original) {
      const ignoredFields = new Set([
        "uid",
        "operation",
        "edited",
        "dirty",
        "dirtyFields",
        "parent",
        "sortRank",
        "dummy",
        "skipSearch",
        "sortInputTime"
      ]);
      const columnFields = (this.columns || [])
        .map(column => column?.field)
        .filter(field => field && !ignoredFields.has(field));
      const originalFields = Object.keys(original || {})
        .filter(field => field && !field.startsWith("_") && !ignoredFields.has(field));
      const recordFields = Object.keys(record || {})
        .filter(field => field && !field.startsWith("_") && !ignoredFields.has(field));
      return Array.from(new Set([...columnFields, ...originalFields, ...recordFields]));
    },
    normalizeDirectGridCompareValue(value) {
      if (value === null || value === undefined) {
        return "";
      }
      return String(value);
    },
    getDirectGridFieldDefaultValue(field) {
      const schemaField = this.getMasterRecordList?.schema?.model?.fields?.[field];
      if (schemaField && Object.prototype.hasOwnProperty.call(schemaField, "defaultValue")) {
        return schemaField.defaultValue;
      }
      const validation = schemaField?.validation;
      const isRequired = typeof validation !== "undefined" && validation.required;
      if (schemaField?.type === "string") {
        return "";
      }
      if (schemaField?.type === "number") {
        return isRequired ? 0 : null;
      }
      if (schemaField?.type === "date") {
        return null;
      }
      return null;
    },
    isDirectGridAddedRecordDeleteEdited(record) {
      return String(record?.isDisp) === "0" || String(record?.isDel) === "1";
    },
    isDirectGridAddedRecordEffectivelyEdited(record) {
      if (!record) {
        return false;
      }
      if (this.isDirectGridAddedRecordDeleteEdited(record)) {
        return true;
      }
      const ignoredFields = new Set([
        "uid",
        "code",
        "operation",
        "edited",
        "dirty",
        "dirtyFields",
        "parent",
        "sortRank",
        "dummy",
        "skipSearch",
        "sortInputTime",
        "isDisp",
        "isDel"
      ]);
      const columnFields = (this.columns || [])
        .filter(column => column && column.hidden !== true)
        .map(column => column.field)
        .filter(Boolean);
      const fields = Array.from(new Set(columnFields))
        .filter(field => field && !field.startsWith("_") && !ignoredFields.has(field));
      return fields.some(field => {
        const value = this.normalizeDirectGridCompareValue(record?.[field]).trim();
        const defaultValue = this.normalizeDirectGridCompareValue(this.getDirectGridFieldDefaultValue(field)).trim();
        return value !== "" && value !== defaultValue;
      });
    },
    isDirectGridRecordChangedFromSnapshot(record) {
      const original = this.findOriginalRecord(record);
      if (!original) {
        const operation = Number(record?.operation || 0);
        if (operation === 1) {
          return this.isDirectGridAddedRecordEffectivelyEdited(record);
        }
        return operation > 1 || record?.edited === true;
      }
      return this.getDirectGridCompareFields(record, original).some(field => (
        this.normalizeDirectGridCompareValue(record?.[field]) !==
        this.normalizeDirectGridCompareValue(original?.[field])
      ));
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
      if (edited) {
        this.directGridSortEditedCodes.add(key);
      } else {
        this.directGridSortEditedCodes.delete(key);
      }
    },
    isDirectGridSortManuallyEdited(record) {
      const key = this.getDirectGridRecordKey(record);
      return !!key && this.directGridSortEditedCodes.has(key);
    },
    getDirectGridRowsByRecord(record, preferredUid = null) {
      const root = this.getDirectGridRoot();
      const grid = this.getDirectGridWidget();
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
      const index = this.getColumnIndex(fieldName);
      if (index < 0) {
        return [];
      }
      const ariaColIndex = String(index + 1);
      return rows.flatMap(row => {
        const cells = Array.from(row.children || []);
        const match = cells.find(cell => cell.getAttribute("aria-colindex") === ariaColIndex);
        return match ? [match] : (cells[index] ? [cells[index]] : []);
      });
    },
    clearDirectGridRowVisualState(rows) {
      rows.forEach(row => {
        row.classList.remove("k-dirty-row", "master-edited-row", "master-deleted-row");
        Array.from(row.children || []).forEach(cell => {
          cell.classList.remove("master-edited-cell", "master-edited-row", "master-deleted-row", "master-sort-edited", "k-dirty-cell");
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
    shouldApplyDirectGridDeletedCellClass(cell, index, dummyIndex) {
      const field = cell?.getAttribute?.("data-field");
      if (field === "dummy") {
        return false;
      }
      const colIndex = Number(cell?.getAttribute?.("aria-colindex")) - 1;
      const effectiveIndex = Number.isFinite(colIndex) ? colIndex : index;
      return effectiveIndex !== dummyIndex;
    },
    debugDirectGridDeletedVisualState(stage, record, rows, detail = {}) {
      if (String(record?.isDisp) !== "0") {
        return;
      }
      try {
        const rowSnapshots = (rows || []).map(row => ({
          uid: row.getAttribute("data-uid"),
          locked: !!row.closest(".k-grid-content-locked"),
          className: row.className,
          cells: Array.from(row.children || []).slice(0, 8).map((cell, index) => {
            const style = typeof window !== "undefined" && window.getComputedStyle
              ? window.getComputedStyle(cell)
              : null;
            return {
              index,
              ariaColIndex: cell.getAttribute("aria-colindex"),
              field: cell.getAttribute("data-field"),
              text: (cell.textContent || "").trim(),
              className: cell.className,
              color: style?.color,
              backgroundColor: style?.backgroundColor,
            };
          }),
        }));
        console.info("[MST_FUNCTION_REPORT_GRID_DELETED]", {
          stage,
          ...detail,
          code: record?.code,
          uid: record?.uid,
          isDisp: record?.isDisp,
          operation: record?.operation,
          changed: this.isDirectGridRecordChangedFromSnapshot(record),
          sortChanged: this.isDirectGridSortManuallyEdited(record),
          rowCount: rows?.length || 0,
          rows: rowSnapshots,
        });
      } catch (error) {
        console.info("[MST_FUNCTION_REPORT_GRID_DELETED] log-error", error);
      }
    },
    applyDirectGridRowVisualState(record, preferredUid = null, resolvedRows = null) {
      if (!record) {
        return;
      }
      const rows = resolvedRows || this.getDirectGridRowsByRecord(record, preferredUid);
      if (!rows.length) {
        this.debugDirectGridDeletedVisualState("rows-missing", record, rows);
        return;
      }
      this.clearDirectGridRowVisualState(rows);
      const deleted = String(record?.isDisp) === "0";
      const changed = this.isDirectGridRecordChangedFromSnapshot(record);
      const sortChanged = this.isDirectGridSortManuallyEdited(record);
      if (!changed && !sortChanged && !deleted) {
        return;
      }
      const sortRankIndex = this.getColumnIndex("sortRank");
      const dummyIndex = this.getColumnIndex("dummy");
      const { lockedRows, scrollableRows } = this.splitDirectGridRows(rows);
      if (!changed && deleted) {
        let appliedCellCount = 0;
        rows.forEach(row => {
          row.classList.add("master-deleted-row");
          Array.from(row.children || []).forEach((cell, index) => {
            if (this.shouldApplyDirectGridDeletedCellClass(cell, index, dummyIndex)) {
              cell.classList.add("master-deleted-row");
              appliedCellCount += 1;
            }
          });
        });
        this.debugDirectGridDeletedVisualState("deleted-applied", record, rows, {
          appliedCellCount,
          sortRankIndex,
          dummyIndex,
        });
        return;
      }
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
      }
      if (sortChanged) {
        const sortRows = lockedRows.length ? lockedRows : rows;
        this.getDirectGridCellsByField(sortRows, "sortRank").forEach(cell => {
          cell.classList.add("k-dirty-cell", "master-sort-edited");
        });
        this.getDirectGridCellsByField(sortRows, "dummy").forEach(cell => {
          cell.classList.add("master-sort-edited");
        });
      }
      if (deleted) {
        this.debugDirectGridDeletedVisualState("changed-deleted-applied", record, rows);
      }
    },
    scheduleDirectGridRowVisualState(record, preferredUid = null) {
      if (!this.directGridRowVisualRafIds) {
        this.directGridRowVisualRafIds = markRaw(new Map());
      }
      const key = String(record?.uid || record?.code || preferredUid || "__row__");
      const oldRaf = this.directGridRowVisualRafIds.get(key);
      if (oldRaf != null) {
        cancelAnimationFrame(oldRaf);
      }
      const rafId = requestAnimationFrame(() => {
        this.directGridRowVisualRafIds.delete(key);
        this.applyDirectGridRowVisualState(record, preferredUid);
      });
      this.directGridRowVisualRafIds.set(key, rafId);
    },
    scheduleDirectGridVisualStateRefresh() {
      if (this.directGridVisualStateRafId != null) {
        cancelAnimationFrame(this.directGridVisualStateRafId);
      }
      if (this.directGridVisualStateTimeoutId != null) {
        clearTimeout(this.directGridVisualStateTimeoutId);
      }
      const refresh = () => {
        this.applyDirectGridLegacyStyleContract();
        this.refreshDirectGridVisualState();
      };
      this.directGridVisualStateRafId = requestAnimationFrame(() => {
        this.directGridVisualStateRafId = requestAnimationFrame(() => {
          this.directGridVisualStateRafId = null;
          refresh();
        });
      });
      this.directGridVisualStateTimeoutId = setTimeout(() => {
        this.directGridVisualStateTimeoutId = null;
        refresh();
      }, 80);
    },
    refreshDirectGridVisualState() {
      const data = this.getDirectGridWidget()?.dataSource?.data?.() || [];
      Array.from(data || []).forEach(record => this.applyDirectGridRowVisualState(record, record.uid));
    },
    syncDirectGridDataSourceToStore() {
      const grid = this.getDirectGridWidget();
      const records = this.getMasterRecordList;
      if (!grid?.dataSource || !Array.isArray(records?.data)) {
        return;
      }
      const displayData = Array.from(grid.dataSource.data() || []).map(item => item?.toJSON ? item.toJSON() : item);
      const sourceData = Array.isArray(this.masterRecords?.data) ? this.masterRecords.data : [];
      displayData.forEach((row, index) => {
        const base = sourceData[index];
        const target = records.data.find(item =>
          item === base ||
          (row.uid && item.uid === row.uid) ||
          (row.code != null && item.code === row.code) ||
          (row.functionCd != null && row.reportCd != null && item.functionCd === row.functionCd && item.reportCd === row.reportCd)
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
    showSortColumn() {
      const sortRankIndex = this.columns.findIndex(col => col.field === "sortRank");
      if (sortRankIndex >= 0) {
        this.columns[sortRankIndex].hidden = !(this.isAllowSort && this.isSortMode);
        const dummyIndex = this.columns.findIndex(col => col.field === "dummy");
        if (dummyIndex >= 0) {
          this.columns[dummyIndex].hidden = !this.columns[sortRankIndex].hidden;
        }
        this.setDirectGridColumnHidden("sortRank", this.columns[sortRankIndex].hidden);
        if (dummyIndex >= 0) {
          this.setDirectGridColumnHidden("dummy", this.columns[dummyIndex].hidden);
        }
      }
      this.syncDirectGridColumnStateToWidget();
      this.applyDirectGridLegacyStyleContract();
    },
    toRankEditBtnClick() {
      this.cacheGridScrollPosition(this.scrollPosition);
      EventBus.$emit("onCloseMasterEditModal", this.onCloseMasterEditModal);
      if (!this.kendoValidator.validate()) {
        return;
      }
      this.isSortMode = true;
      this.disableColumns();
      this.showSortColumn();
      EventBus.$emit("setSortMode", this.isSortMode);
      this.$nextTick(() => {
        this.calculateGridWidth();
        this.scheduleDirectGridLayoutContract();
      });
    },
    sortBtnClick() {
      this.cacheGridScrollPosition(this.scrollPosition);
      EventBus.$emit("onCloseMasterEditModal", this.onCloseMasterEditModal);
      this.syncDirectGridDataSourceToStore();
      const tempData = deepCopyPlain(this.getMasterRecordList.data);
      this.isSortMode = false;
      this.editableColumns();
      this.showSortColumn();
      this.sort();
      this.isSorted = this.sortChange(tempData);
      EventBus.$emit("setSortMode", this.isSortMode);
      this.$nextTick(() => {
        this.refreshDirectGridDataFromMasterRecords(false);
        this.calculateGridWidth();
        this.scheduleDirectGridLayoutContract();
      });
    },
    bindDirectGridSortRankEditorAssist(event, cell, field) {
      const onEditorValueChange = () => {
        const value = readGridEditorNumericValue(cell);
        const visualRecord = this.getDirectGridModelPlain(event.model, { [field]: value });
        this.setDirectGridSortManuallyEdited(visualRecord, this.isSortRankChangedFromSnapshot(visualRecord));
        this.applyDirectGridRowVisualState(visualRecord, event?.model?.uid);
      };
      const input = cell.querySelector?.("input");
      if (input) {
        input.addEventListener("input", onEditorValueChange, { passive: true });
        input.addEventListener("change", onEditorValueChange, { passive: true });
      }
      cell.addEventListener("click", (clickEvent) => {
        if (clickEvent.target?.closest?.(
          ".k-spinner-increase, .k-spinner-decrease, .k-link-increase, .k-link-decrease, .k-spin-button"
        )) {
          setTimeout(onEditorValueChange, 0);
        }
      }, true);
      bindGridEditorNumericWheelSpinAssist({
        cell,
        gridRoot: this.getDirectGridRoot(),
        onEditorValueChange,
      });
    },
    onDirectGridEdit(event) {
      if (this.isMobileDevice && !this.allowEdit) {
        return;
      }
      this.addInputAssist(event);
      bindGridEditorEnterToCloseCell(event?.sender || this.getDirectGridWidget(), event?.container);
      const field = getGridEditFieldFromEvent(event, this.columns);
      const cell = event?.container?.[0] || event?.container;
      if (!field || !cell) {
        return;
      }
      // DropDownList 列は select ハンドラで model 反映済みのため input 監視不要
      if (getGridEditorDropDownListWidget(cell)) {
        return;
      }
      if (this.isSortMode && field === "sortRank") {
        this.bindDirectGridSortRankEditorAssist(event, cell, field);
        return;
      }
      const input = cell.querySelector?.("input");
      if (!input) {
        return;
      }
      const onEditorValueChange = () => {
        const value = readGridEditorNumericValue(cell);
        const visualRecord = this.getDirectGridModelPlain(event.model, { [field]: value });
        this.applyDirectGridRowVisualState(visualRecord, event?.model?.uid);
      };
      input.addEventListener("input", onEditorValueChange, { passive: true });
      input.addEventListener("change", onEditorValueChange, { passive: true });
      setTimeout(onEditorValueChange, 0);
    },
    onDirectGridSave(ev) {
      this.editingFlg = false;
      const field = getGridEditFieldFromEvent(ev, this.columns);
      const values = { ...(ev?.values || {}) };
      const dropDownWidget = getGridEditorDropDownListWidget(ev?.container);
      // Kendo save は DropDownList の表示テキストを values に入れる場合がある
      if (dropDownWidget && field) {
        delete values[field];
        const resolved = resolveGridEditorDropDownListSaveValue(
          field,
          ev,
          this.getMasterRecordList?.schema?.model?.fields
        );
        if (resolved !== undefined) {
          values[field] = resolved;
        }
      } else if (field && Object.keys(values).length === 0) {
        const value = readGridEditorNumericValue(ev?.container?.[0] || ev?.container);
        if (value !== undefined) {
          values[field] = value;
        }
      }
      if (values?.isPersonal && values.isPersonal == "0") {
        ev.model.patId = "";
      }
      Object.keys(values).forEach(key => {
        if (typeof ev.model.set === "function") {
          ev.model.set(key, values[key]);
        } else {
          ev.model[key] = values[key];
        }
      });
      const updatedRecord = this.getDirectGridModelPlain(ev.model, values);
      if (Number(ev.model.operation || 0) === 1) {
        ev.model.edited = this.isDirectGridAddedRecordEffectivelyEdited(updatedRecord);
        updatedRecord.edited = ev.model.edited;
      }
      if (this.isSortMode && Object.prototype.hasOwnProperty.call(values, "sortRank")) {
        this.setDirectGridSortManuallyEdited(updatedRecord, this.isSortRankChangedFromSnapshot(updatedRecord));
      }
      this.edit({ editRecord: ev.model, isSortMode: this.isSortMode });
      const visualRecord = this.getDirectGridModelPlain(ev.model, values);
      if (Number(ev.model.operation || 0) === 1) {
        visualRecord.edited = ev.model.edited;
      }
      this.applyDirectGridRowVisualState(visualRecord, ev.model?.uid);
      this.scheduleDirectGridRowVisualState(visualRecord, ev.model?.uid);
      if (dropDownWidget) {
        this.$nextTick(() => {
          try {
            ev?.sender?.refresh?.();
          } catch (_error) {
            // noop
          }
        });
      }
    },
    onSave(ev){
      this.onDirectGridSave(ev);
    },
    modifyEditStart(e){
      // del 6379 【機能帳票マスタ】プルダウンメニューの選択肢、動作の不正 周安寧 start
      // let temp = [];

      // for (const argument of this.dataGrouping) {
      //   if (argument.cd === e.model.functionCd){
      //     // add bug 6410 修正 chen start
      //     if (e.model.functionCd === "01501" || e.model.functionCd === "00401" ||
      //       e.model.functionCd === "00701" || e.model.functionCd === "00601"){
      //       let obj = {
      //         "text": "治療経過表（自動選択）",
      //         "value": '-3'
      //       }
      //       temp.push(obj);

      //       obj = {
      //         "text": "治療経過表（手書き：自動選択）",
      //         "value": '-4'
      //       }
      //       temp.push(obj)
      //     }
      //     //add 6498 装置帳票：点検結果が機能帳票で出力できない 吉 start
      //     if (e.model.functionCd === "03301"){
      //       let obj = {
      //         "text": "定期点検（記録簿・交換部品記録簿）",
      //         "value": '-6'
      //       }
      //       temp.push(obj);
      //     }
      //     if (e.model.functionCd === "03401"){
      //       let obj = {
      //         "text": "日常点検記録簿",
      //         "value": '-5'
      //       }
      //       temp.push(obj);
      //     }
      //     //add 6498 装置帳票：点検結果が機能帳票で出力できない 吉 end
      //     // add bug 6410 修正 chen end
      //     for (let i = 0; i < argument.list.length; i++) {
      //       for (let j = 0; j < this.sysReportList.length; j++) {
      //         if (argument.list[i] === this.sysReportList[j].reportCd){
      //           let obj = {
      //             "text": this.sysReportList[j].reportName,
      //             "value": argument.list[i]
      //           }
      //           temp.push(obj)
      //         }
      //       }
      //     }
      //   }
      // }
      // e.sender.columns[5].values = temp;
      // del 6379 【機能帳票マスタ】プルダウンメニューの選択肢、動作の不正 周安寧 end
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
    // add 6379 【機能帳票マスタ】プルダウンメニューの選択肢、動作の不正 周安寧 start
    filterChangefunctionCd(container, data) {
      let dataSource = [];
      let selectedReport=null;
      const columnValues = this.columns.find(column => column.field === data.field)?.values || [];
      if(data.model.functionCd){
        selectedReport=columnValues.find(el=> el.value==data.model.functionCd);
      }
      dataSource = this.modifyEditFunctionCD((data.model.reportCd), selectedReport);
      this.installDirectGridComboDropDownList(container, data, dataSource, data.model.functionCd);
      // #8745 は必須入力です。追加 林峻峰 start
      // del #11327 機能帳票マスタで間違った選択をすると目的の設定が不可能となる linjunfeng start
      // }).blur((event)=>{
      //   if (!event.target.value) {
      //     const width = document.getElementsByClassName('k-textbox')[0].clientWidth;
      //     $('.k-textbox').after(`<div class="k-widget k-tooltip k-tooltip-validation k-invalid-msg" style="width: ${width}px" ><span class="k-icon k-i-warning"> </span>機能名は必須入力です。<div class="k-callout k-callout-n"></div></div>`)
      //     document.getElementsByClassName('k-textbox')[0].style.border = '1px solid red';
      //   }
      // });
      // del #11327 機能帳票マスタで間違った選択をすると目的の設定が不可能となる linjunfeng end
      // #8745 は必須入力です。追加 林峻峰 end
    },
    filterChangeReportCD(container, data) {
      let dataSource = [];
      //mod #6927 修正：本行で選択されている帳票を表示することはできません yumingyang start
      let selectedReport=null;
      const columnValues = this.columns.find(column => column.field === data.field)?.values || [];
      if(data.model.reportCd){
        selectedReport=columnValues.find(el=> el.value==data.model.reportCd);
      }
      dataSource = this.modifyEditReportCD(data.model.functionCd, selectedReport);
      //mod #6927 修正：本行で選択されている帳票を表示することはできません yumingyang end
      this.installDirectGridComboDropDownList(container, data, dataSource, data.model.reportCd);
      // #8745 は必須入力です。追加 林峻峰 start
      // del #11327 機能帳票マスタで間違った選択をすると目的の設定が不可能となる linjunfeng start
      // }).blur((event)=>{
      //   if (!event.target.value) {
      //     const width = document.getElementsByClassName('k-textbox')[0].clientWidth;
      //     $('.k-textbox').after(`<div class="k-widget k-tooltip k-tooltip-validation k-invalid-msg" style="width: ${width}px" ><span class="k-icon k-i-warning"> </span>帳票名は必須入力です。<div class="k-callout k-callout-n"></div></div>`)
      //     document.getElementsByClassName('k-textbox')[0].style.border = '1px solid red';
      //   }
      // })
      // del #11327 機能帳票マスタで間違った選択をすると目的の設定が不可能となる linjunfeng end
      // #8745 は必須入力です。追加 林峻峰 end
    },
    modifyEditReportCD(functionCd,selectedReport){
      let temp = [];
      let list = []
      // del #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe start
      // if (functionCd === "01501" || functionCd === "00401" ||
      //    functionCd === "00701" || functionCd === "00601"){
      //   let obj = {
      //     "text": "治療経過表（自動選択）",
      //     // mod #6927「重複チェックがされていない」について、対応する。 dengshen start
      //     // "value": '-3'
      //     "value": -3
      //     // mod #6927「重複チェックがされていない」について、対応する。 dengshen end
      //   }
      //   temp.push(obj);
      //
      //   obj = {
      //     "text": "治療経過表（手書き：自動選択）",
      //     // mod #6927「重複チェックがされていない」について、対応する。 dengshen start
      //     // "value": '-4'
      //     "value": -4
      //     // mod #6927「重複チェックがされていない」について、対応する。 dengshen end
      //   }
      //   temp.push(obj)
      // }
      // if (functionCd === "03301"){
      //   let obj = {
      //     "text": "定期点検（記録簿・交換部品記録簿）",
      //     // mod #6927「重複チェックがされていない」について、対応する。 dengshen start
      //     // "value": '-6'
      //     "value": -6
      //     // mod #6927「重複チェックがされていない」について、対応する。 dengshen end
      //   }
      //   temp.push(obj);
      // }
      // if (functionCd === "03401"){
      //   let obj = {
      //     "text": "日常点検記録簿",
      //     // mod #6927「重複チェックがされていない」について、対応する。 dengshen start
      //     // "value": '-5'
      //     "value": -5
      //     // mod #6927「重複チェックがされていない」について、対応する。 dengshen end
      //   }
      //   temp.push(obj);
      // }
      // del #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe end
      if (functionCd === null || functionCd === ""){
          for (const item of this.sysReportList) {
          temp.push({
            "text":item.reportName,
            "value":item.reportCd
          })
        }
        return temp
      }
      list = this.dataGrouping.filter(item => item.cd === functionCd)
      if (list !== undefined && list.length > 0) {
        const reportNameByCd = new Map();
        this.sysReportList.forEach(report => {
          reportNameByCd.set(report.reportCd, report.reportName);
        });
        for (let i = 0; i < list[0].list.length; i++) {
          const reportCd = list[0].list[i];
          const reportName = reportNameByCd.get(reportCd);
          if (reportName !== undefined) {
            temp.push({
              "text": reportName,
              "value": reportCd
            });
          }
        }
        if (selectedReport && !temp.some(item => item.value == selectedReport.value)) {
          temp.push(selectedReport);
        }
        // add #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe start
        temp = temp.filter(item => {
          if (item.value === -3 || item.value === -4) {
            return functionCd == '00401' || functionCd == '00601' || functionCd == '00701';
          } else if (item.value === -5) {
            return functionCd == '03401';
          } else if (item.value === -6) {
            return functionCd == '03301';
          }
          // add #12582 固定帳票「水質管理記録簿」が必要 limingzhe start
          else if (item.value === -7) {
            return functionCd == '03201';
          }
          // add #12582 固定帳票「水質管理記録簿」が必要 limingzhe end
          return true;
        });
        // add #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe end
      }
      // add #6927「重複チェックがされていない」について、対応する。 dengshen start
      const usedReportCdSet = new Set();
      const filteredRecordList = this.getFilteredMasterRecordList?.data || [];
      for (let indexRecord = 0; indexRecord < filteredRecordList.length; indexRecord++){
        if (filteredRecordList[indexRecord].functionCd === functionCd) {
          usedReportCdSet.add(filteredRecordList[indexRecord].reportCd);
        }
      }
      temp = temp.filter(item => {
        if (selectedReport && item.value == selectedReport.value) {
          return true;
        }
        return !usedReportCdSet.has(item.value);
      });
      // add #6927「重複チェックがされていない」について、対応する。 dengshen end
      return temp;
    },
    modifyEditFunctionCD(reportCd, selectedReport){
      let temp = [];
      let list = []
      // del #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe start
      // if (reportCd === -3 || reportCd === -4) {
      //   let obj1 = {
      //     "text": "チェックリスト",
      //     "value": '01501'
      //   }
      //   temp.push(obj1);
      //   let obj2 = {
      //     "text": "患者経過総合ビューア",
      //     "value": '00401'
      //   }
      //   temp.push(obj2);
      //   let obj3 = {
      //     "text": "患者情報",
      //     "value": '00701'
      //   }
      //   temp.push(obj3);
      //   let obj4 = {
      //     "text": "治療記録",
      //     "value": '00601'
      //   }
      //   temp.push(obj4);
      //
      // }
      // if (reportCd === -6 ) {
      //   let obj = {
      //     "text": "定期点検",
      //     "value": '03301'
      //   }
      //   temp.push(obj);
      // }
      // if (reportCd === -5 ) {
      //   let obj = {
      //     "text": "日常点検",
      //     "value": '03401'
      //   }
      //   temp.push(obj);
      // }
      // del #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe end
      if (reportCd === null || reportCd === 0) {
        for (const item of this.sysReportSettingList) {
          temp.push({
            "text":item.functionName,
            "value":item.functionCd
          })
        }
        return temp;
      }
      list = this.functionCdGrouping.filter(item => item.cd === reportCd)
      if (list !== undefined && list.length > 0) {
        for (let i = 0; i < list[0].list.length; i++) {
          for (let j = 0; j < this.sysReportSettingList.length; j++) {
            if (list[0].list[i] === this.sysReportSettingList[j].functionCd){
              let obj = {
                "text": this.sysReportSettingList[j].functionName,
                "value": list[0].list[i]
              }
              temp.push(obj)
            }
          }
        }
        if (selectedReport && !temp.some(item => item.value == selectedReport.value)) {
          temp.push(selectedReport);
        }
        // add #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe start
        let temp1 = [];
        temp.forEach (t => {
          if(reportCd === -3){
            if (t.value === '00401' || t.value === '00601' || t.value === '00701'){
              temp1.push(t);
            }
          }
          else if(reportCd === -4){
            if (t.value === '00401' || t.value === '00601' || t.value === '00701'){
              temp1.push(t);
            }
          }
          else if(reportCd === -5){
            if (t.value === '03401'){
              temp1.push(t);
            }
          }
          else if(reportCd === -6){
            if (t.value === '03301'){
              temp1.push(t);
            }
          }
          // add #12582 固定帳票「水質管理記録簿」が必要 limingzhe start
          else if (reportCd === -7) {
            if (t.value === '03201') {
              temp1.push(t);
            }
          }
          // add #12582 固定帳票「水質管理記録簿」が必要 limingzhe end
          else {
            temp1.push(t);
          }
        });
        temp = temp1;
        // add #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe end
      }
      // add #6927「重複チェックがされていない」について、対応する。 dengshen start
      const filteredRecordList = this.getFilteredMasterRecordList?.data || [];
      for (let indexRecord = 0; indexRecord < filteredRecordList.length; indexRecord++) {
        const record = filteredRecordList[indexRecord];
        if (record.reportCd !== reportCd) {
          continue;
        }
        const usedFunctionCd = record.functionCd;
        // 編集中行の選択は削除しない（旧実装は重複 push で残っていた）
        if (selectedReport && usedFunctionCd == selectedReport.value) {
          continue;
        }
        for (let indexTemp = temp.length - 1; indexTemp >= 0; indexTemp--) {
          if (temp[indexTemp].value === usedFunctionCd) {
            temp.splice(indexTemp, 1);
          }
        }
      }
      if (selectedReport && !temp.some(item => item.value == selectedReport.value)) {
        temp.push(selectedReport);
      }
      // add #6927「重複チェックがされていない」について、対応する。 dengshen end
      return temp;
    },
    // add 6379 【機能帳票マスタ】プルダウンメニューの選択肢、動作の不正 周安寧 end
    loadGridData() {
      // delete start #9590
      // this.setCondition(this.condition);
      // delete end #9590
      this.findList();
    },
    dataCategory(){
      for (const item of this.sysReportSettingList) {
        let printReportClass = JSON.parse(item.printReportClass);
        let temp = [];
        // mod 8569 【IES起票】【機能帳票マスタ】機能名が検査結果の時、帳票種別が紹介状の設定問題 zhou start
        //let classList = null;
        let classList = [];
        // mod 8569 【IES起票】【機能帳票マスタ】機能名が検査結果の時、帳票種別が紹介状の設定問題 zhou start
        // if (printReportClass.length > 1){
        //   classList = printReportClass[0].report_class.split(',').concat(printReportClass[1].report_class.split(','))
        // } else {
        //   classList = printReportClass[0].report_class.split(',')
        // }
        for(let i = 0; i < printReportClass.length; i ++){
          classList = classList.concat(printReportClass[i].report_class.split(','));
        }
        // mod 8569 【IES起票】【機能帳票マスタ】機能名が検査結果の時、帳票種別が紹介状の設定問題 zhou end
        for (let i = 0; i < classList.length; i++) {
          classList[i] = parseInt(classList[i])
        }
        classList = classList.sort(function(a, b){return a - b});
        let finClassList = [classList[0]];
        for (let i = 1, len = classList.length; i < len; i++) {
          if (classList[i] !== classList[i - 1]) {
            finClassList.push(classList[i]);
          }
        }
        for (let i = 0; i < finClassList.length; i++) {
          for (let j = 0; j < this.sysReportList.length; j++) {
            if (finClassList[i] === this.sysReportList[j].reportClass){
              temp.push(this.sysReportList[j].reportCd)
            }
          }
        }
        let obj = {
          cd: item.functionCd,
          list: temp
        }
        this.dataGrouping.push(obj)
      }
    },
    // add 6379 【機能帳票マスタ】プルダウンメニューの選択肢、動作の不正 周安寧 start
    functionGrouping(){
      for (let i = 0; i < this.sysReportList.length; i++) {
        let temp = [];
        for (const item of this.sysReportSettingList) {
          let printReportClass = JSON.parse(item.printReportClass);
          let classList = null;
          if (printReportClass.length > 1){
            classList = printReportClass[0].report_class.split(',').concat(printReportClass[1].report_class.split(','))
          } else {
            classList = printReportClass[0].report_class.split(',')
          }
          if (classList.includes(this.sysReportList[i].reportClass.toString())) {
            temp.push(item.functionCd)
          }
        }
        let obj = {
          cd: this.sysReportList[i].reportCd,
          list: temp
        }
        this.functionCdGrouping.push(obj)
      }
    },
    // add 6379 【機能帳票マスタ】プルダウンメニューの選択肢、動作の不正 周安寧 end
    findList() {
      // apiをコールして値を取得
      // add マスタ一覧 1･施設切替を可能とする 王
      // this.findRecordListByFacilityCdWithSql(this.facilityCd)
      this.findRecordListByFacilityCdWithSql(this.getFacilitySwitch)
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
            column.width = this.columnWidth + "em";
            if (column.field === "machineRecordMessage")column.width = "20em";
            if (column.field === "dispFlg")column.width = "20em";
            // add 削除の欄が広い 王 start
            // mod #7289-マスタの削除ボタンが縦表示になる 徐博 start
            // if (column.field === "isDisp")column.width = "8em";
            if (column.field === "isDisp")column.width = "9em";
            // mod #7289-マスタの削除ボタンが縦表示になる 徐博 end
            // add 削除の欄が広い 王 end
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
          // add #9590 start
          let repArr = [];
          for (const item of this.sysReportSettingList) {
            repArr.push({
              "text": item.functionName,
              "value": item.functionCd
            })
          }
          let temp = [];
          for (const item of this.sysReportList) {
            temp.push({
              "text": item.reportName,
              "value": item.reportCd
            })
          }
          // del #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe start
          // temp.push({
          //   "text": "治療経過表（自動選択）",
          //   "value": '-3'
          // }, {
          //   "text": "治療経過表（手書き：自動選択）",
          //   "value": '-4'
          // }
          // , {
          //   "text": "日常点検記録簿",
          //   "value": '-5'
          // }, {
          //   "text": "定期点検・交換部品記録簿",
          //   "value": '-6'
          // }
          // );
          // del #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe end
          this.columns.forEach((column) => {
            if (column.field === "functionCd") {
              column.values = repArr;
            } else if (column.field === "reportCd") {
              column.values = temp;
            }
          });
          this.setColumns(this.columns);
          // add #9590 end
          this.directGridSortEditedCodes?.clear?.();
          // カラム幅等初期調整
          this.showSortColumn();
          this.$nextTick(() => {
            this.initDirectGridIfReady();
            const grid = this.getDirectGridWidget();
            if (grid) {
              const position = this.getGridScrollPosition();
              grid.setOptions({ columns: this.buildDirectGridColumns() });
              this.$nextTick(() => this.setGridScrollPosition(position));
            }
            this.editableColumns();
            this.calculateGridHeight();
            this.calculateGridWidth();
            this.scheduleDirectGridLayoutContract();
            /* add スクロールの位置を維持 楊 start */
            // 保存後のフィルタ再適用(resetScroll)やレイアウト再構築(setOptions/resize)が
            // 複数フレームにまたがってスクロールを先頭へ戻すため、2フレーム分だけ位置を再適用する。
            // setGridScrollPosition はスクロール値を設定するだけで新たなスクロールバーは生成しない。
            const keepScrollTop = this.lastScrollTop;
            const keepScrollLeft = this.lastScrollLeft;
            const restoreScroll = () => this.setGridScrollPosition({ top: keepScrollTop, left: keepScrollLeft });
            restoreScroll();
            requestAnimationFrame(() => {
              restoreScroll();
              requestAnimationFrame(restoreScroll);
            });
            setTimeout(() => {
                this.lastScrollTop = 0;
                this.lastScrollLeft = 0;
              }, 1000);
            /* add スクロールの位置を維持 楊 end */
          });
          // 初期データ内容を保存
          this.setComparisonRecordModel();
        })
        .catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
          getErrorMessage('MstFunctionReportMainComponent.vue', 'findList', '指定されたマスタが見つかりません。');
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
          if (error.response.status === 400) {
            this.$ons.notification.alert({
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // title: "取得失敗",
              title: DIALOG_MESSAGES[12000003].title,
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
              message:
                // add 全マスタメッセージ調整 王 start
                // message: "指定されたマスタが見つかりません。"
                DIALOG_MESSAGES[12000003].message
                // add 全マスタメッセージ調整 王 end
            });
          }
        })
      // カラム定義情報を取得
      this.findColumnInfo();
    },
    addRow() {
      // グリッドでエラーが発生している場合は処理を中断
      if (!this.kendoValidator.validate()) {
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
      this.edit({ editRecord: d, isSortMode: this.isSortMode });
      this.$nextTick(() => {
        this.applyDirectGridDataSourceContract();
        requestAnimationFrame(() => {
          const content = this.getDirectGridScrollContent();
          if (content) {
            // 追加: 縦スクロールは最下部、横スクロールは先頭(0)へ
            content.scrollTop = content.scrollHeight;
            content.scrollLeft = 0;
            this.setGridScrollPosition({ top: content.scrollTop, left: 0 });
          }
        });
      });
    },
    async saveRecord() {
      this.setLoadingScreenVisible(true);
      // グリッドでエラーが発生している場合は処理を中断
      if (!this.kendoValidator.validate()) {
        this.setLoadingScreenVisible(false);
        // 共通ローダー：表示終了
        return;
      }
      this.syncDirectGridDataSourceToStore();
      /* add スクロール位置を保存 楊  start */
      const preservedScrollPosition = this.getGridScrollPosition();
      this.lastScrollTop = preservedScrollPosition.top;
      this.lastScrollLeft = preservedScrollPosition.left;
      /* add スクロール位置を保存 楊 end */
      const records = this.getMasterRecordList;
      records.data = records.data.filter(
        (r) => !(r.operation === 1 && !r.edited)
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
        this.$ons.notification.alert({
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
          // title: "チェックエラー",
          title: DIALOG_MESSAGES[12000005].title,
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
          message: '<div style="text-align:left;">' + message + "</div>"
        });
        // add redmine 10_障害一覧.No42 帳票名未入力メッセージ 宋qy start
        this.setLoadingScreenVisible(false);
        // add redmine 10_障害一覧.No42 帳票名未入力メッセージ 宋qy end
        return;
      }
      // apiをコールして値を保存
      // add マスタ一覧 1･施設切替を可能とする 王
      // await this.updateRecordList(this.getUpdateRecordList)
      await this.updateRecordListByFacilityCd({facilityCd: this.getFacilitySwitch, request: this.getUpdateRecordList})
        .then(response => {
          //共通ローダー：表示終了
          this.updateResponse = response.data;
          this.$ons.notification.alert({
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
            // title: "更新完了",
            title: DIALOG_MESSAGES[12000004].title,
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
            message:
              // add 全マスタメッセージ調整 王 start
              // "マスタ更新が完了しました。"
              DIALOG_MESSAGES[12000004].message
              // add 全マスタメッセージ調整 王 end

          });
          this.findList();
        })
        .catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
          getErrorMessage('MstFunctionReportMainComponent.vue', 'saveRecord', error);
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
          if (error.response.status === 400) {
            //共通ローダー：表示終了
            this.$ons.notification.alert({
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // title: "更新失敗",
              title: DIALOG_MESSAGES["00300005"].title,
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
              message: error.response.data.errorMessage
            });
          }
        });
      this.setLoadingScreenVisible(false);
    },
  },
  mounted() {
    installComponentJQuery();
    this.kendoValidator = { validate: () => true };
    this.directGridMounted = true;
    this.$nextTick(() => {
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
    window.addEventListener("resize", this.directGridResizeHandler);
  },
  // add 性能改善メモリ不足 shan start
  beforeUnmount() {
    EventBus.$off("onCloseMasterEditModal", this.onCloseMasterEditModal);
    EventBus.$off("refresh", this.refresh);
    if (this.directGridResizeHandler) {
      window.removeEventListener("resize", this.directGridResizeHandler);
      this.directGridResizeHandler = null;
    }
    this.destroyDirectGrid();
  },
  // add 性能改善メモリ不足 shan end
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
#grid-footer {
  margin: 0;
  padding: 5px;
  bottom: 0;
  position: absolute;
  left: 0;
  right: 0;
  width: auto;
  box-sizing: border-box;
}
.kendo-grid-toolbar-style {
  --height: 200px;
  height: var(--height);
  border-bottom: none;
  box-sizing: border-box;
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
.kendo-grid-toolbar-style :deep(.k-grid-header-locked > table),
.kendo-grid-toolbar-style :deep(.k-grid-header-locked > table) {
  border-right-width: 0px;
}
.kendo-grid-toolbar-style :deep(.k-grid-header-locked),
.kendo-grid-toolbar-style :deep(.k-grid-header-locked) {
  border-right: 1px solid var(--ntss-list-border-color) !important;
}
.kendo-grid-toolbar-style :deep(.k-grid-content-locked),
.kendo-grid-toolbar-style :deep(.k-grid-content-locked) {
  z-index: 1;
  box-shadow: 1px 0px 0px 0px var(--ntss-border-color) !important;
}
/* #8745 は必須入力です。追加 林峻峰 start */
.kendo-grid-toolbar-style :deep(.k-edit-cell) {
  position: relative;
  overflow: inherit;
}
.kendo-grid-toolbar-style :deep(.k-grid
  tr:nth-last-child(1)
  .k-tooltip.k-tooltip-validation) {
  bottom: 38px;
}
.kendo-grid-toolbar-style :deep(.k-grid
  tr:nth-last-child(1)
  .k-tooltip.k-tooltip-validation
  .k-callout) {
  border-bottom: 0;
  border-top: 6px solid #000;
  top: unset;
  bottom: -6px;
}
.kendo-grid-toolbar-style :deep(.k-dropdown > .k-tooltip-validation){
  display: none !important;
}
/* #8745 は必須入力です。追加 林峻峰 end */
.custom-switch {
  transform: scale(0.85);
  transform-origin: center;
  touch-action: manipulation;
}

.mst-function-report-direct-jq-grid {
  width: 100%;
  max-width: 100%;
  box-sizing: border-box;
}

.mst-function-report-direct-jq-grid :deep(td.master-edited-row),
.mst-function-report-direct-jq-grid :deep(td.master-edited-row:hover),
.mst-function-report-direct-jq-grid :deep(td.master-edited-row.k-hover),
.mst-function-report-direct-jq-grid :deep(.k-table-td.master-edited-row),
.mst-function-report-direct-jq-grid :deep(.k-table-td.master-edited-row:hover),
.mst-function-report-direct-jq-grid :deep(.k-table-td.master-edited-row.k-hover),
.mst-function-report-direct-jq-grid :deep(tr:hover > td.master-edited-row),
.mst-function-report-direct-jq-grid :deep(tr.k-hover > td.master-edited-row),
.mst-function-report-direct-jq-grid :deep(tr.k-selected > td.master-edited-row),
.mst-function-report-direct-jq-grid :deep(tr.k-selected:hover > td.master-edited-row),
.mst-function-report-direct-jq-grid :deep(tr.k-selected.k-hover > td.master-edited-row),
.mst-function-report-direct-jq-grid :deep(tr.k-state-selected > td.master-edited-row),
.mst-function-report-direct-jq-grid :deep(tr.k-state-selected:hover > td.master-edited-row),
.mst-function-report-direct-jq-grid :deep(tr.k-state-selected.k-hover > td.master-edited-row),
.mst-function-report-direct-jq-grid :deep(tr[aria-selected="true"] > td.master-edited-row),
.mst-function-report-direct-jq-grid :deep(tr[aria-selected="true"]:hover > td.master-edited-row),
.mst-function-report-direct-jq-grid :deep(tr[aria-selected="true"].k-hover > td.master-edited-row),
.mst-function-report-direct-jq-grid :deep(tr.k-table-row.k-selected > td.master-edited-row),
.mst-function-report-direct-jq-grid :deep(.k-table-row:hover > .k-table-td.master-edited-row),
.mst-function-report-direct-jq-grid :deep(.k-table-row.k-hover > .k-table-td.master-edited-row),
.mst-function-report-direct-jq-grid :deep(.k-table-row.k-selected > .k-table-td.master-edited-row),
.mst-function-report-direct-jq-grid :deep(.k-table-row.k-selected:hover > .k-table-td.master-edited-row),
.mst-function-report-direct-jq-grid :deep(.k-table-row.k-selected.k-hover > .k-table-td.master-edited-row),
.mst-function-report-direct-jq-grid :deep(.k-table-row.k-state-selected > .k-table-td.master-edited-row),
.mst-function-report-direct-jq-grid :deep(.k-table-row.k-state-selected:hover > .k-table-td.master-edited-row),
.mst-function-report-direct-jq-grid :deep(.k-table-row.k-state-selected.k-hover > .k-table-td.master-edited-row),
.mst-function-report-direct-jq-grid :deep(.k-table-row[aria-selected="true"] > .k-table-td.master-edited-row),
.mst-function-report-direct-jq-grid :deep(.k-table-row[aria-selected="true"]:hover > .k-table-td.master-edited-row),
.mst-function-report-direct-jq-grid :deep(.k-table-row[aria-selected="true"].k-hover > .k-table-td.master-edited-row) {
  color: #003300 !important;
  background: #ccffcc !important;
  background-color: #ccffcc !important;
}

.mst-function-report-direct-jq-grid :deep(tr.master-deleted-row:not(.k-selected):not(.k-state-selected):not([aria-selected="true"]) > td),
.mst-function-report-direct-jq-grid :deep(tr.master-deleted-row:not(.k-selected):not(.k-state-selected):not([aria-selected="true"]):hover > td),
.mst-function-report-direct-jq-grid :deep(tr.master-deleted-row:not(.k-selected):not(.k-state-selected):not([aria-selected="true"]).k-hover > td),
.mst-function-report-direct-jq-grid :deep(.k-table-row.master-deleted-row:not(.k-selected):not(.k-state-selected):not([aria-selected="true"]) > .k-table-td),
.mst-function-report-direct-jq-grid :deep(.k-table-row.master-deleted-row:not(.k-selected):not(.k-state-selected):not([aria-selected="true"]):hover > .k-table-td),
.mst-function-report-direct-jq-grid :deep(.k-table-row.master-deleted-row:not(.k-selected):not(.k-state-selected):not([aria-selected="true"]).k-hover > .k-table-td),
.mst-function-report-direct-jq-grid :deep(tr:not(.k-selected):not(.k-state-selected):not([aria-selected="true"]) > td.master-deleted-row),
.mst-function-report-direct-jq-grid :deep(tr:not(.k-selected):not(.k-state-selected):not([aria-selected="true"]):hover > td.master-deleted-row),
.mst-function-report-direct-jq-grid :deep(tr:not(.k-selected):not(.k-state-selected):not([aria-selected="true"]).k-hover > td.master-deleted-row),
.mst-function-report-direct-jq-grid :deep(tr:not(.k-selected):not(.k-state-selected):not([aria-selected="true"]) > td.master-deleted-row:hover),
.mst-function-report-direct-jq-grid :deep(tr:not(.k-selected):not(.k-state-selected):not([aria-selected="true"]) > td.master-deleted-row.k-hover),
.mst-function-report-direct-jq-grid :deep(.k-table-row:not(.k-selected):not(.k-state-selected):not([aria-selected="true"]) > .k-table-td.master-deleted-row),
.mst-function-report-direct-jq-grid :deep(.k-table-row:not(.k-selected):not(.k-state-selected):not([aria-selected="true"]):hover > .k-table-td.master-deleted-row),
.mst-function-report-direct-jq-grid :deep(.k-table-row:not(.k-selected):not(.k-state-selected):not([aria-selected="true"]).k-hover > .k-table-td.master-deleted-row),
.mst-function-report-direct-jq-grid :deep(.k-table-row:not(.k-selected):not(.k-state-selected):not([aria-selected="true"]) > .k-table-td.master-deleted-row:hover),
.mst-function-report-direct-jq-grid :deep(.k-table-row:not(.k-selected):not(.k-state-selected):not([aria-selected="true"]) > .k-table-td.master-deleted-row.k-hover) {
  color: #333333 !important;
  background: #aaaaaa !important;
  background-color: #aaaaaa !important;
}

.mst-function-report-direct-jq-grid :deep(td.master-sort-edited),
.mst-function-report-direct-jq-grid :deep(td.master-sort-edited:hover),
.mst-function-report-direct-jq-grid :deep(td.master-sort-edited.k-hover),
.mst-function-report-direct-jq-grid :deep(.k-table-td.master-sort-edited),
.mst-function-report-direct-jq-grid :deep(.k-table-td.master-sort-edited:hover),
.mst-function-report-direct-jq-grid :deep(.k-table-td.master-sort-edited.k-hover),
.mst-function-report-direct-jq-grid :deep(tr:hover > td.master-sort-edited),
.mst-function-report-direct-jq-grid :deep(tr.k-hover > td.master-sort-edited),
.mst-function-report-direct-jq-grid :deep(tr.k-selected > td.master-sort-edited),
.mst-function-report-direct-jq-grid :deep(tr.k-selected:hover > td.master-sort-edited),
.mst-function-report-direct-jq-grid :deep(tr.k-selected.k-hover > td.master-sort-edited),
.mst-function-report-direct-jq-grid :deep(tr.k-state-selected > td.master-sort-edited),
.mst-function-report-direct-jq-grid :deep(tr.k-state-selected:hover > td.master-sort-edited),
.mst-function-report-direct-jq-grid :deep(tr.k-state-selected.k-hover > td.master-sort-edited),
.mst-function-report-direct-jq-grid :deep(tr[aria-selected="true"] > td.master-sort-edited),
.mst-function-report-direct-jq-grid :deep(tr[aria-selected="true"]:hover > td.master-sort-edited),
.mst-function-report-direct-jq-grid :deep(tr[aria-selected="true"].k-hover > td.master-sort-edited),
.mst-function-report-direct-jq-grid :deep(tr.k-table-row.k-selected > td.master-sort-edited),
.mst-function-report-direct-jq-grid :deep(.k-table-row:hover > .k-table-td.master-sort-edited),
.mst-function-report-direct-jq-grid :deep(.k-table-row.k-hover > .k-table-td.master-sort-edited),
.mst-function-report-direct-jq-grid :deep(.k-table-row.k-selected > .k-table-td.master-sort-edited),
.mst-function-report-direct-jq-grid :deep(.k-table-row.k-selected:hover > .k-table-td.master-sort-edited),
.mst-function-report-direct-jq-grid :deep(.k-table-row.k-selected.k-hover > .k-table-td.master-sort-edited),
.mst-function-report-direct-jq-grid :deep(.k-table-row.k-state-selected > .k-table-td.master-sort-edited),
.mst-function-report-direct-jq-grid :deep(.k-table-row.k-state-selected:hover > .k-table-td.master-sort-edited),
.mst-function-report-direct-jq-grid :deep(.k-table-row.k-state-selected.k-hover > .k-table-td.master-sort-edited),
.mst-function-report-direct-jq-grid :deep(.k-table-row[aria-selected="true"] > .k-table-td.master-sort-edited),
.mst-function-report-direct-jq-grid :deep(.k-table-row[aria-selected="true"]:hover > .k-table-td.master-sort-edited),
.mst-function-report-direct-jq-grid :deep(.k-table-row[aria-selected="true"].k-hover > .k-table-td.master-sort-edited) {
  color: #000000 !important;
  background: #ffff66 !important;
  background-color: #ffff66 !important;
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
