<template>
  <div class="main-content-area master-maintenance-page">
    <div class="ntss-list" :style="ntssListStyles">
      <div class="k-grid-toolbar k-header kendo-grid-toolbar-style" :style="heightStyles">
        <div id="grid-header" :class="['header-btn-area', 'left', isMobileDevice ? 'mobile-header' : '']">
          <v-ons-button
            v-show="!isSortMode && isAllowAddRecord"
            class="btn3-normal toolbar-btn"
            @click="addRow()"
          >
            追加
          </v-ons-button>
          <v-ons-row v-show="isMobileDevice" style="width: 6em; height: 1em;">
            <v-ons-col width="45%" vertical-align="center">
              <label class="fab-font-color">編集</label>
            </v-ons-col>
            <v-ons-col width="55%" vertical-align="center">
              <v-ons-switch modifier="outline" style="float: left; margin-left: 2px;" v-model="allowEdit" />
            </v-ons-col>
          </v-ons-row>
          <!-- <v-ons-button
            v-show="!isSortMode && isAllowSort"
            class="btn3-normal toolbar-btn"
            @click="toRankEditBtnClick()"
          >
            並び順表示
          </v-ons-button> -->
          <v-ons-button
            v-show="isSortMode && isAllowSort"
            class="btn3-normal toolbar-btn"
            @click="sortBtnClick()"
          >
            反映
          </v-ons-button>
        </div>

        <!-- 施設情報を表示用に変換してから画面表示 -->
        <div
          v-show="isSettedFacilityDataChacked"
          id="grid-font-size"
          ref="grid"
          :class="[
            fontSizeSet,
            'ntss-kendo-grid-legacy',
            'mst-device-edge-direct-jq-grid'
          ]"
        ></div>
      </div>
      <div id="grid-footer">
        <v-ons-row v-show="!isSortMode" width="100%">
          <v-ons-col width="50%">
            <v-ons-button
              class="button btn2-cancel denial-btn"
              style="width: auto;"
              @click="cancel"
            >
              キャンセル
            </v-ons-button>
          </v-ons-col>
          <v-ons-col width="50%" class="right">
            <v-ons-button
              class="button btn1-execute registration-btn"
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
//#10715：日付IF修正20240910検証NG対応：村上Start
import { createApp, markRaw } from "@/compat/vue/runtime";
//#10715：日付IF修正20240910検証NG対応：村上End

import _ from "@/compat/collections/lodash";
import dayjs from "@/compat/date/dayjs";
import { ApiHelper } from "@/apis/AxiosHelper";
import { mapActions, mapGetters } from "@/compat/vue/vuex";
import { EventBus } from "@/compat/vue/event-bus.js";
import { prefectures } from "@/components/master-maintenance/mst-device-edge/Prefectures.js";
import messageDialog from "@/components/common/message-dialog/MessageDialog";
//FNSI-修正 VUEのエラー場合のログ対応 liuimx add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 liuimx add end
// add #8403 【デグレ】デバイスエッジマスタで新規レコードが保存できない dou start
import { ERROR_DEVICE_EDGE_SAVE } from "@/constants/deviceEdgeManageDefine";
// add #8403 【デグレ】デバイスエッジマスタで新規レコードが保存できない dou end
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
//#10715：日付IF修正20240910検証NG対応：村上Start
import commonCalender from "@/components/common/custom-calendar/CustomCalendar";
import { getScopedAlertDialogs } from "@/functions/common/LayoutMeasureHelper";
import kendo from "@progress/kendo-ui";
import $ from "jquery";
import {
  bindGridEditorDropDownListToCloseCell,
  bindGridEditorEnterToCloseCell,
  commitDirectGridAddedRowDropDownCell,
  getGridEditFieldFromEvent,
  syncDirectGridRecordFieldCells
} from "@/compat/kendo/grid-edit";

const FACILITY_ROW_FIELDS = ["facilityCd", "facilityName", "prefecturesCd", "departmentCd"];


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

//#10715：日付IF修正20240910検証NG対応：村上End
export default {

  // 共通タグコンポーネント読み込み
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
      scrollPosition: {
        top: 0,
        left: 0
      },
      lastScrollTop: 0,
      lastScrollLeft: 0,
      columnWidth: 14,
      kendoValidatorSetup: {
        rules: {},
        messages: {}
      },
      // 編集失敗時のマスタ/列/スキーマ情報のバックアップ
      backupMasterRecordList: [],
      // 施設マスタ
      mstFacility: null,
      // 表示データ変換フラグ
      isSettedFacilityDataChacked: false,
      // 施設マスタ取得フラグ
      isGetMstFacility: false,
      // エラーメッセージ内容
      stringParams: null,
      messageCd: null,
      isDialogVisible: false,
      //Android端末で編集中であることを示すフラグ
      editingFlg: false,
      androidFlg: false,
      iosFlg: false,
      // 自画面の名称
      selfScreenName: "",
      mntFacilityCancelManageList: "",
      allowEdit: true, // NOTE: true = 編集モード、 false = 閲覧モード
      directGridDataSource: null,
      directGridWidget: null,
      directGridReady: false,
      directGridMounted: false,
      directGridLayoutRafId: null,
      directGridFilterRefreshRafId: null,
      directGridScrollSyncRafId: null,
      directGridRowVisualRafIds: markRaw(new Map()),
      kendoValidator: null,
      directGridSaveGuard: false
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
      // main部の高さをCSS変数を利用して書き換え
      return { "--height": `${this.kendoGridToolbarHeight}px` };
    },
    ntssListStyles() {
      return { display: this.columns.length === 1 ? "none" : "inherit" };
    },
    ...mapGetters("master-maintenance", {
      getMasterRecordList: "getMasterRecordList",
      getFilteredMasterRecordList: "getFilteredMasterRecordList",
      getUpdateRecordList: "getUpdateRecordList",
      masterPhysicalName: "getMasterName",
      columnDefinition: "getColumns",
      editRecord: "getEditRecord",
      isEdited: "isEdited",
      hasValueColumn: "hasValueColumn"
    }),
    masterRecords() {
      // storeからデータを取得

      // del デバイスエッジマスタ 更新後の画面表示異常 孔 start
      // 表示内容切替「施設名・都道府県・部署符号」※DBデバイスエッジマスタに無いカラムの初期表示は施設コードで表示される
      // if (this.getMasterRecordList.length !== 0) {
      //   if (this.isGetMstFacility) {
      //     // 施設マスタが空の状態ではエラーになる
      //
      //     // ディープコピー
      //     const editMasterRecordData = this.getMasterRecordList.data.map(
      //       record => ({ ...record })
      //     );
      //     // 施設データ設定
      //     const data = editMasterRecordData.map(record =>
      //       this.setFacilityData(record)
      //     );
      //
      //     // ディープコピー
      //     const schema = JSON.parse(
      //       JSON.stringify(this.getMasterRecordList.schema)
      //     );
      //
      //     // 施設名と各施設情報を紐づけるため、id設定
      //     schema.model.id = "code";
      //
      //     const editedMasterRecordList = {
      //       ...this.getMasterRecordList,
      //       data,
      //       schema
      //     };
      //
      //     this.sortRecords(editedMasterRecordList.data);
      //
      //     // 表示内容を更新するため、storeに設定
      //     this.setMasterRecordList(editedMasterRecordList);
      //     this.showDisplay();
      //   }
      // }
      // del デバイスエッジマスタ 更新後の画面表示異常 孔 end

      return this.getFilteredMasterRecordList;
    },
    masterConditionSignature() {
      const condition = this.$store?.state?.["master-maintenance"]?.condition || this.condition || {};
      return `${condition.recordName || ""}|${condition.includeDeleted ? 1 : 0}`;
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
          this.isSorted ||
          !this.kendoValidator?.validate())
      );
    },

    ...mapGetters("mst-machine", {
      getMachineTypeList: "getMachineTypeList",
      getDeviceEdgeList: "getDeviceEdgeList"
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

  async created() {
    this.setLoadingScreenVisible(true);

    const response = await ApiHelper.get("/mstInfo/mstFacility").catch(
      error => {
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
        getErrorMessage('MstDeviceEdgeMainComponent.vue', 'created', error);
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
        throw error;
      }
    );
    this.mstFacility = response.data;

    this.setCondition(this.condition);
    this.findList();
    this.calculateColumnsWidth();
    // 共通ローダー:表示名設定
    this.setLoadingScreenMessage("処理中・・・");
    // 施設マスタ取得フラグ
    this.isGetMstFacility = true;
    const mntFacilityCancelManage = await ApiHelper.get("/facilities/MntFacilityCancelManage/SelectAll").catch(error => {
      //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
      getErrorMessage('MstDeviceEdgeMainComponent.vue', 'created', error);
      //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
      throw error;
    });
    this.mntFacilityCancelManageList =  mntFacilityCancelManage.data.map(e => e.facilityCd)
    // 端末判別
    const ua = ((this?.$el?.ownerDocument?.defaultView?.navigator?.userAgent) || globalThis?.navigator?.userAgent || "").toLowerCase();
    if (/android/.test(ua)) {
      this.androidFlg = true;
    } else if (/iphone|ipad|mac|os/.test(ua)) {
      this.iosFlg = true;
    }
    this.selfScreenName = this.$route.name;
    EventBus.$on("refresh", this.refresh);
  },

  mounted() {
    this.directGridMounted = true;
    this.kendoValidator = { validate: () => this.validateDirectKendoGrid() };
    this.$nextTick(() => {
      this.calculateColumnsWidth();
      this.calculateGridHeight();
      this.calculateGridWidth();
      this.initDirectGridIfReady();
      this.scheduleDirectGridLayoutContract();
    });
  },

  beforeUnmount() {
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

  methods: {
    ...mapActions("multi-modal", ["showMasterEdit"]),
    ...mapActions("master-maintenance", [
      "findRecordList",
      "setMasterRecordList",
      "edit",
      "setCondition",
      "updateRecordList",
      "setEditRecord",
      "editRecordBeEmpty"
    ]),
    // 共通ローダー設定
    ...mapActions("loading-screen", {
      setLoadingScreenVisible: "setLoadingScreenVisible",
      setLoadingScreenMessage: "setLoadingScreenMessage",
      resetLoadingScreenVisibleCount:  "resetLoadingScreenVisibleCount"
    }),
    ...mapActions("mst-machine", [
      "getComboRecordList",
      "deleteMstMachineList",
      "synchroMstMachine"
    ]),
    validateDirectKendoGrid() {
      return true;
    },
    cancel() {
      this.$router.go(-1);
    },
    getColumnIndex(fieldName) {
      return this.columns.findIndex(e => e.field === fieldName);
    },
    getMaxSortRank() {
      const data = this.getFilteredMasterRecordList?.data || [];
      return data.length ? data.reduce((a, b) => Math.max(a, +b.sortRank || 0), 0) : 0;
    },
    calculateColumnsWidth() {
      const root = this.$el?.ownerDocument?.getElementById?.("app") || document.getElementById("app");
      const width = root ? parseFloat(getComputedStyle(root).width || "0") : window.innerWidth;
      this.columnWidth = width > 1000 ? 14 : 9;
    },
    calculateGridHeight() {
      if (this.editingFlg) {
        return;
      }
      const wh = Number(this.windowHeight) || window.innerHeight || 0;
      const headerElements = Array.from(document.getElementsByClassName("header"));
      const hh = headerElements.length ? headerElements[headerElements.length - 1].clientHeight : 0;
      const footerMenu = document.getElementById("footer-menu");
      const fmh = (this.isDispMenu === 1 && footerMenu ? footerMenu.clientHeight : 0) + 5;
      this.kendoGridToolbarHeight = Math.max(100, wh - hh - fmh);
      const gridFooterHeight = document.getElementById("grid-footer")?.clientHeight || 0;
      const headerAreaHeight = document.getElementById("grid-header")?.clientHeight || 0;
      this.kendoGridHeight = Math.max(160, this.kendoGridToolbarHeight - (gridFooterHeight + headerAreaHeight));
    },
    onDataBoundKendoGrid() {
      this.$nextTick(() => {
        if (this.scrollPosition.top > 0 || this.scrollPosition.left > 0) {
          const currentPosition = this.getGridScrollPosition();
          this.setGridScrollPosition({
            top: Math.max(Number(currentPosition.top || 0), Number(this.scrollPosition.top || 0)),
            left: this.scrollPosition.left,
          });
        }
        this.applyDirectGridLegacyStyleContract();
      });
    },
    editStart() {
      this.editingFlg = true;
    },
    editEnd() {
      this.editingFlg = false;
    },
    showSortColumn() {
      const sortRankIndex = this.columns.findIndex(col => col.field === "sortRank");
      if (sortRankIndex >= 0) {
        this.columns[sortRankIndex].hidden = !(this.isAllowSort && this.isSortMode);
        const dummyIndex = this.columns.findIndex(col => col.field === "dummy");
        if (dummyIndex >= 0) {
          this.columns[dummyIndex].hidden = !this.columns[sortRankIndex].hidden;
        }
      }
      this.applyDirectGridColumnsContract();
      this.scheduleDirectGridLayoutContract();
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
          ? this.isAllowSort
            ? () => true
            : () => false
          : () => false;
      });
      this.applyDirectGridColumnsContract();
    },
    syncDirectGridSortValuesToMasterRecords() {
      const dataSourceData = this.directGridWidget?.dataSource?.data?.();
      if (!dataSourceData || !Array.isArray(this.getMasterRecordList?.data)) {
        return;
      }
      const gridRows = typeof dataSourceData.toJSON === "function" ? dataSourceData.toJSON() : Array.from(dataSourceData);
      const byCode = new Map();
      gridRows.forEach((row, index) => {
        if (row && row.code !== undefined && row.code !== null) {
          byCode.set(String(row.code), row);
        } else if (row?.serialNo !== undefined && row?.serialNo !== null) {
          byCode.set(`serial:${row.serialNo}`, row);
        } else {
          byCode.set(`__index_${index}`, row);
        }
      });
      this.getMasterRecordList.data.forEach((record, index) => {
        const gridRow = byCode.get(String(record.code)) || byCode.get(`serial:${record.serialNo}`) || byCode.get(`__index_${index}`);
        if (!gridRow) {
          return;
        }
        if (gridRow.sortRank !== undefined) {
          record.sortRank = gridRow.sortRank;
        }
        if (gridRow.sortInputTime !== undefined) {
          record.sortInputTime = gridRow.sortInputTime;
        }
      });
    },
    sort() {
      const list = this.getMasterRecordList?.data || [];
      const compare = (a, b) => (a.sortRank || 0) - (b.sortRank || 0) || (a.sortInputTime || 0) - (b.sortInputTime || 0);
      list.sort(compare);
      for (let i = 0; i < list.length; i++) {
        if (list[i].isDisp === "1") {
          list[i].sortRank = i + 1;
        }
      }
    },
    sortChange(tempData) {
      let flag = false;
      const beforeMap = new Map((tempData || []).map(item => [String(item.code ?? item.serialNo), item]));
      (this.getMasterRecordList?.data || []).forEach(item => {
        const before = beforeMap.get(String(item.code ?? item.serialNo));
        if (before && item.sortRank !== before.sortRank) {
          flag = true;
        }
      });
      return flag;
    },
    toRankEditBtnClick() {
      this.setLastScroll();
      if (!this.kendoValidator.validate()) {
        return;
      }
      this.isSortMode = true;
      this.disableColumns();
      this.showSortColumn();
    },
    sortBtnClick() {
      this.setLastScroll();
      try {
        this.directGridWidget?.closeCell?.();
      } catch (_error) {
        // noop
      }
      this.syncDirectGridSortValuesToMasterRecords();
      const tempData = JSON.parse(JSON.stringify(this.getMasterRecordList?.data || []));
      this.isSortMode = false;
      this.editableColumns();
      this.showSortColumn();
      this.sort();
      this.isSorted = this.sortChange(tempData);
      this.refreshDirectGridDataFromMasterRecords(false, true);
      this.setGridScrollPosition({ top: this.lastScrollTop, left: this.lastScrollLeft });
    },
    scheduleMasterGridScrollToAddedRow() {
      const apply = () => {
        const content = this.getDirectGridScrollContent();
        if (!content) {
          return;
        }
        const top = Math.max(Number(this.lastScrollTop || 0), Number(content.scrollHeight || 0));
        this.scrollPosition.top = top;
        this.scrollPosition.left = 0;
        this.lastScrollTop = top;
        this.lastScrollLeft = 0;
        this.setGridScrollPosition({ top, left: 0 });
      };
      apply();
      this.$nextTick(() => {
        apply();
        requestAnimationFrame(apply);
        [0, 32, 80, 180].forEach(ms => setTimeout(apply, ms));
      });
    },
    normalization(items) {
      const source = typeof items?.toJSON === "function" ? items.toJSON() : { ...(items || {}) };
      const columnNames = (this.columnDefinition || this.columns || []).map(column => column.field);
      return Object.keys(source)
        .filter(key => columnNames.includes(key) || key === "isAddRow")
        .reduce((acc, key) => {
          acc[key] = source[key];
          return acc;
        }, {});
    },
    showMasterEditModal(e) {
      this.setLastScroll();
      this.showMasterEdit();
      e?.preventDefault?.();
      const row = e?.currentTarget?.closest?.("tr");
      const selectedRowItem = row ? this.directGridWidget?.dataItem?.(row) : null;
      if (!selectedRowItem) {
        return;
      }
      if (!selectedRowItem.code) {
        this.edit({ editRecord: selectedRowItem, isSortMode: this.isSortMode });
      }
      this.setEditRecord(this.normalization(selectedRowItem));
    },
    getDirectGridRoot() {
      return this.$refs.grid || null;
    },
    getDirectGridScrollContent() {
      return this.getDirectGridRoot()?.querySelector?.(".k-grid-content") || null;
    },
    getDirectGridLockedScrollContent() {
      return this.getDirectGridRoot()?.querySelector?.(".k-grid-content-locked") || null;
    },
    getGridWidget() {
      return this.directGridWidget || null;
    },
    getGridScrollContainer() {
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
      let appliedLeft;
      if (Number.isFinite(position.left)) {
        appliedLeft = position.left;
        content.scrollLeft = appliedLeft;
      }
      if (Number.isFinite(position.top)) {
        content.scrollTop = position.top;
        this.syncDirectGridLockedScrollPosition(position.top);
      }
      if (Number.isFinite(appliedLeft)) {
        const grid = this.getGridWidget();
        if (grid?.content?.[0]) {
          grid.content[0].scrollLeft = appliedLeft;
        }
        const headerWrap = this.getDirectGridRoot()?.querySelector?.(".k-grid-header-wrap");
        if (headerWrap) {
          headerWrap.scrollLeft = appliedLeft;
        }
        if (grid && typeof grid._scrollLeft !== "undefined") {
          grid._scrollLeft = appliedLeft;
        }
      }
      this.dispatchDirectGridContentScroll();
    },
    setLastScroll() {
      const position = this.getGridScrollPosition();
      this.lastScrollTop = position.top;
      this.lastScrollLeft = position.left;
      this.scrollPosition.top = position.top;
      this.scrollPosition.left = position.left;
    },
    calculateGridWidth() {
      this.resizeDirectGrid();
    },
    resizeDirectGrid() {
      const grid = this.directGridWidget;
      if (!grid) {
        return;
      }
      try {
        grid.setOptions({ height: this.kendoGridHeight });
        grid.resize(true);
        this.applyDirectGridLockedWidthContract();
        this.applyDirectGridLockedHeightContract();
      } catch (_error) {
        // direct jq では resize 失敗時に追加 rebuild しない。
      }
    },
    getDirectGridDisplayDataSourceOption() {
      // Vue2 は <kendo-grid :data-source="masterRecords"> で、
      // getter が返す DataSource option / data / schema を wrapper がそのまま Kendo に渡していた。
      // direct jq でも JSON clone せず、schema / validation / model / data の参照を保つ。
      const source = this.masterRecords || this.getFilteredMasterRecordList || {};
      return {
        ...source,
        data: (Array.isArray(source.data) ? source.data : []).map(record =>
          this.normalizeRecordDatesForGrid(record)
        ),
        schema: source.schema
      };
    },
    createDirectGridDataSource() {
      const sourceOption = this.getDirectGridDisplayDataSourceOption();
      this.directGridDataSource = markRaw(new kendo.data.DataSource(sourceOption));
      return this.directGridDataSource;
    },
    buildDirectGridColumns() {
      return (this.columns || []).map(column => {
        const gridColumn = { ...column };
        if (column.field === "$modalType") {
          gridColumn.command = { text: "詳細", click: event => this.showMasterEditModal(event) };
          delete gridColumn.values;
        } else if (column.field === "serialNo") {
          gridColumn.editor = (container, options) => this.serialNoEditor(container, options);
        } else if (column.field === "deviceEdgeNo") {
          gridColumn.editor = (container, options) => this.deviceEdgeNoEditor(container, options);
        } else if (column.field === "facilityName") {
          gridColumn.editor = (container, options) => this.editorDropDown(container, options);
        } else if (column.dataType === "date") {
          gridColumn.editor = (container, options) => this.eachModelCalendar(container, options);
        }
        return gridColumn;
      });
    },
    initDirectGridIfReady() {
      const root = this.getDirectGridRoot();
      if (!this.directGridMounted || !root || !this.isSettedFacilityDataChacked || this.columns.length <= 1) {
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
        cellClose: event => this.editEnd(event),
        save: event => this.onDirectGridSave(event),
        dataBound: event => {
          this.onDataBoundKendoGrid?.(event);
          this.applyDirectGridLegacyStyleContract();
        },
        columns: this.buildDirectGridColumns()
      });
      this.directGridWidget = markRaw($(root).data("kendoGrid"));
      this.installDirectGridFacade();
      this.applyDirectGridLegacyStyleContract();
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
      const root = this.getDirectGridRoot();
      if (root) {
        $(root).empty();
      }
      this.directGridWidget = null;
      this.directGridReady = false;
    },
    installDirectGridFacade() {
      const root = this.getDirectGridRoot();
      if (!root) {
        return;
      }
      root.kendoWidget = () => this.directGridWidget;
      root.gridWidget = () => this.directGridWidget;
      root.gridRootEl = () => root;
      root.gridContentEl = () => this.getDirectGridScrollContent();
      root.gridAutoScrollableEl = () => this.getDirectGridScrollContent();
      root.gridLockedContentEl = () => this.getDirectGridLockedScrollContent();
      root.gridDataItem = row => this.directGridWidget?.dataItem?.(row);
      root.scrollGridTo = position => this.setGridScrollPosition(position);
    },
    applyDirectGridColumnsContract() {
      const grid = this.directGridWidget;
      if (!grid) {
        return;
      }
      const existingFields = (grid.columns || []).map(column => column.field).join("|");
      const nextFields = (this.columns || []).map(column => column.field).join("|");
      if (existingFields !== nextFields) {
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
    refreshDirectGridDataFromMasterRecords(resetScroll = false, applyVisibleVisual = true) {
      const grid = this.directGridWidget;
      if (!grid?.dataSource) {
        return;
      }
      const sourceOption = this.getDirectGridDisplayDataSourceOption();
      try {
        grid.dataSource.data(sourceOption.data || []);
      } catch (_error) {
        return;
      }
      if (resetScroll) {
        const content = this.getDirectGridScrollContent();
        if (content) {
          content.scrollTop = 0;
          content.scrollLeft = 0;
        }
      }
      this.$nextTick(() => {
        this.applyDirectGridLegacyStyleContract();
        if (applyVisibleVisual) {
          this.editBackgroundColor();
        }
      });
    },
    gridDataRefresh() {
      this.refreshDirectGridDataFromMasterRecords();
    },
    applyDirectGridLockedWidthContract() {
      // Kendo 2026 内部の _applyLockedContainersWidth は内部関数
      // columnsWidth(cols) で `parseInt(col.style.width, 10)` を行い、
      // "14em" → 14 のように単位を完全に無視して数値だけ取り出す
      // (kendo.grid-C8hPyP-1.js L1772 確認済み)。
      // 本画面の column.width は "14em" / "9em" / "10px" 等を混在しているため、
      // Kendo が算出する locked コンテナ幅は実描画よりはるかに小さくなり、
      // 固定列が極端に狭くなる。
      //
      // そのため locked コンテナ幅は単位換算した結果でこちらから上書きする。
      // 一方 .k-grid-header-wrap / .k-grid-content への marginLeft 上書きは
      // 行わない (Kendo の flex 配置と二重に効くと、固定列と非固定列の間に
      // lockedWidth 幅の空白が発生する)。
      const root = this.getDirectGridRoot();
      if (!root || !this.directGridWidget) {
        return;
      }
      const lockedWidth = (this.columns || []).reduce((sum, column) => {
        if (!column.locked || column.hidden) {
          return sum;
        }
        const width = `${column.width || ""}`.trim();
        if (width.endsWith("em")) {
          const fontSize = parseFloat(getComputedStyle(root).fontSize || "16") || 16;
          return sum + parseFloat(width) * fontSize;
        }
        if (width.endsWith("px")) {
          return sum + parseFloat(width);
        }
        const numeric = parseFloat(width);
        return sum + (Number.isFinite(numeric) ? numeric : 0);
      }, 0);
      if (!lockedWidth) {
        return;
      }
      const px = `${Math.ceil(lockedWidth)}px`;
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
      lockedContent.style.height = `${content.clientHeight}px`;
      lockedContent.style.maxHeight = `${content.clientHeight}px`;
    },
    applyDirectGridLegacyStyleContract() {
      const root = this.getDirectGridRoot();
      if (!root) {
        return;
      }
      root.classList.add("ntss-kendo-grid-legacy", "k-widget", "k-grid", "k-editable", "k-display-block");
      root.querySelectorAll("th").forEach(th => th.classList.add("k-header"));
      root.querySelectorAll(".k-grid-content tbody tr, .k-grid-content-locked tbody tr").forEach((tr, index) => {
        tr.classList.add("k-master-row");
        tr.classList.toggle("k-alt", index % 2 === 1);
      });
      root.querySelectorAll(".k-grid-content td, .k-grid-content-locked td").forEach(td => td.classList.add("k-td", "k-table-td"));
      this.applyDirectGridLockedWidthContract();
      this.applyDirectGridLockedHeightContract();
      this.syncDirectGridLockedScrollPosition();
    },
    scheduleDirectGridLayoutContract() {
      if (this.directGridLayoutRafId != null) {
        cancelAnimationFrame(this.directGridLayoutRafId);
      }
      this.directGridLayoutRafId = requestAnimationFrame(() => {
        this.resizeDirectGrid();
        this.applyDirectGridLegacyStyleContract();
        this.directGridLayoutRafId = requestAnimationFrame(() => {
          this.directGridLayoutRafId = null;
          this.resizeDirectGrid();
          this.applyDirectGridLegacyStyleContract();
          this.setGridScrollPosition(this.scrollPosition);
        });
      });
    },
    syncDirectGridLockedScrollPosition(scrollTop = null) {
      const lockedContent = this.getDirectGridLockedScrollContent();
      if (!lockedContent) {
        return;
      }
      const content = this.getDirectGridScrollContent();
      lockedContent.scrollTop = scrollTop !== null && scrollTop !== undefined ? scrollTop : (content?.scrollTop || 0);
    },
    dispatchDirectGridContentScroll() {
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
    scheduleDirectGridLockedScrollSync() {
      if (this.directGridScrollSyncRafId != null) {
        cancelAnimationFrame(this.directGridScrollSyncRafId);
      }
      this.directGridScrollSyncRafId = requestAnimationFrame(() => {
        this.directGridScrollSyncRafId = null;
        this.syncDirectGridLockedScrollPosition();
      });
    },
    onDirectGridSave(event) {
      if (this.directGridSaveGuard) {
        return;
      }
      this.editingFlg = false;
      const model = event?.model;
      if (!model) {
        return;
      }
      const field = getGridEditFieldFromEvent(event, this.columns);
      if (field === "facilityName" && model.operation === 1) {
        return;
      }
      this.directGridSaveGuard = true;
      try {
        Object.keys(event.values || {}).forEach(fieldName => {
          if (typeof model.set === "function") {
            model.set(fieldName, event.values[fieldName]);
          } else {
            model[fieldName] = event.values[fieldName];
          }
        });
        if (model.operation === 1) {
          model.edited = true;
        }
        this.edit({ editRecord: model, isSortMode: this.isSortMode });
        this.scheduleDirectGridCurrentRowVisual(model);
      } finally {
        this.directGridSaveGuard = false;
      }
    },
    scheduleDirectGridCurrentRowVisual(record) {
      const rowKey = record?.uid || record?.code || record?.serialNo;
      if (!rowKey) {
        return;
      }
      const oldId = this.directGridRowVisualRafIds.get(rowKey);
      if (oldId != null) {
        cancelAnimationFrame(oldId);
      }
      const rafId = requestAnimationFrame(() => {
        this.directGridRowVisualRafIds.delete(rowKey);
        this.applyDirectGridRowVisual(record);
      });
      this.directGridRowVisualRafIds.set(rowKey, rafId);
    },
    applyDirectGridRowVisual(record) {
      const root = this.getDirectGridRoot();
      const grid = this.directGridWidget;
      if (!root || !grid || !record) {
        return;
      }
      const rows = [];
      if (record.uid) {
        rows.push(...root.querySelectorAll(`tr[data-uid="${record.uid}"]`));
      }
      if (rows.length === 0) {
        root.querySelectorAll("tbody tr[data-uid]").forEach(row => {
          const item = grid.dataItem?.(row);
          if (item && (
            (record.code != null && String(item.code) === String(record.code)) ||
            (record.serialNo != null && String(item.serialNo) === String(record.serialNo))
          )) {
            rows.push(row);
          }
        });
      }
      rows.forEach(row => {
        row.classList.toggle("master-edited-row", !!record.operation || !!record.edited);
      });
    },
    editBackgroundColor() {
      const grid = this.directGridWidget;
      if (!grid) {
        return;
      }
      const rows = grid.tbody?.children?.() || [];
      Array.from(rows).forEach(row => {
        const item = grid.dataItem(row);
        if (item) {
          row.classList.toggle("master-edited-row", !!item.operation || !!item.edited);
        }
      });
    },
    // add デバイスエッジマスタ 更新後の画面表示異常 孔 start
    changeMasterRecordsData(){
      // 表示内容切替「施設名・都道府県・部署符号」※DBデバイスエッジマスタに無いカラムの初期表示は施設コードで表示される
      if (this.getMasterRecordList.length !== 0) {
        // if (this.isGetMstFacility) {
        // 施設マスタが空の状態ではエラーになる

        // ディープコピー
        const editMasterRecordData = this.getMasterRecordList.data.map(
          record => ({ ...record })
        );
        // 施設データ設定
        const data = editMasterRecordData.map(record =>
          this.normalizeRecordDatesForGrid(this.setFacilityData(record))
        );

        // ディープコピー
        const schema = JSON.parse(
          JSON.stringify(this.getMasterRecordList.schema)
        );

        // 施設名と各施設情報を紐づけるため、id設定
        schema.model.id = "code";

        const editedMasterRecordList = {
          ...this.getMasterRecordList,
          data,
          schema
        };

        this.sortRecords(editedMasterRecordList.data);

        // 表示内容を更新するため、storeに設定
        this.setMasterRecordList(editedMasterRecordList);
        this.showDisplay();
        // }
      }
    },
    // add デバイスエッジマスタ 更新後の画面表示異常 孔 end
    formatDirectGridDateString(value) {
      if (!value) {
        return "";
      }
      const date = value instanceof Date ? value : new Date(value);
      if (Number.isNaN(date.getTime())) {
        return "";
      }
      return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, "0")}-${String(date.getDate()).padStart(2, "0")}`;
    },
    getDirectGridDateFields() {
      const fromColumns = (this.columns || [])
        .filter(column => column.dataType === "date" && column.field)
        .map(column => column.field);
      if (fromColumns.length) {
        return fromColumns;
      }
      const schemaFields = this.getMasterRecordList?.schema?.model?.fields || {};
      return Object.keys(schemaFields).filter(field => schemaFields[field]?.type === "date");
    },
    normalizeDirectGridDateValue(value) {
      if (value === "" || value == null) {
        return null;
      }
      if (value instanceof Date) {
        return Number.isNaN(value.getTime()) ? null : value;
      }
      const text = String(value).trim();
      const match = text.match(/^(\d{4})-(\d{2})-(\d{2})/);
      if (match) {
        return new Date(Number(match[1]), Number(match[2]) - 1, Number(match[3]));
      }
      const date = new Date(value);
      return Number.isNaN(date.getTime()) ? null : date;
    },
    normalizeRecordDatesForGrid(record) {
      if (!record || typeof record !== "object") {
        return record;
      }
      const dateFields = this.getDirectGridDateFields();
      if (!dateFields.length) {
        return record;
      }
      const next = { ...record };
      dateFields.forEach(field => {
        next[field] = this.normalizeDirectGridDateValue(record[field]);
      });
      return next;
    },
    hasDirectGridDateValueChanged(oldValue, newRawValue) {
      const oldDate = oldValue instanceof Date ? oldValue : (oldValue ? new Date(oldValue) : null);
      const newDate = newRawValue === "" || newRawValue == null ? null : new Date(newRawValue);
      if ((!oldDate || Number.isNaN(oldDate.getTime())) && (!newDate || Number.isNaN(newDate.getTime()))) {
        return false;
      }
      if (!oldDate || Number.isNaN(oldDate.getTime()) || !newDate || Number.isNaN(newDate.getTime())) {
        return true;
      }
      return oldDate.getFullYear() !== newDate.getFullYear()
        || oldDate.getMonth() !== newDate.getMonth()
        || oldDate.getDate() !== newDate.getDate();
    },
    finishDirectGridCalendarEdit(hiddenDateInputEditor, displayedDummyEditor, value, model, field) {
      const normalizedValue = value ?? "";
      if (hiddenDateInputEditor) {
        hiddenDateInputEditor.value = normalizedValue;
      }
      if (displayedDummyEditor) {
        displayedDummyEditor.value = normalizedValue;
      }
      // CustomCalendar.emitValue() が input より先に editCell.click() するため、
      // change/closeCell 任せにせず onDirectGridSave を直接呼ぶ。
      if (model && field) {
        const saveValue = this.normalizeDirectGridDateValue(normalizedValue);
        if (this.hasDirectGridDateValueChanged(model[field], normalizedValue)) {
          this.onDirectGridSave({
            model,
            values: { [field]: saveValue },
            container: hiddenDateInputEditor?.closest?.("td") || displayedDummyEditor?.closest?.("td"),
            sender: this.directGridWidget
          });
        }
      } else if (hiddenDateInputEditor) {
        $(hiddenDateInputEditor).trigger("change");
      }
      requestAnimationFrame(() => {
        try {
          this.directGridWidget?.closeCell?.();
        } catch (_error) {
          // noop
        }
        this.editingFlg = false;
        this.scheduleDirectGridCurrentRowVisual(model);
      });
    },
    eachModelCalendar(container, data) {
      if (this.androidFlg === true) {
        // Androidの場合は、HTML5のカレンダーを表示
        $(`<input type="date" name="${data.field}" />`).appendTo(container);
      } else {
        let moveOutFlg = false;
        container.mouseenter(() => (moveOutFlg = false));
        container.mouseleave(() => (moveOutFlg = true));
        const editedData = data.model[data.field];
        let hasInitValue = true;
        let nowDtatString = this.formatDirectGridDateString(editedData);
        if (!editedData) {
          hasInitValue = false;
          nowDtatString = "";
        }
        $(
          `<span style="position:relative"><input type="date" style="width:8em" id="displayedDummyEditor" class="ntss-input-date" min="1880-01-01" max="2099-12-31" value="${nowDtatString}"/><input type="date" id="hiddenDateInputEditor" name="${data.field}" style="display: none;" /><span id="clear" class="k-icon k-i-close close-btn" title="clear" style="position:absolute;left:75%;top:-1px;color: #212529;z-index:9999999" ></span></span>`
        ).appendTo(container);
        const editorRoot = container?.[0] || container?.get?.(0) || null;
        const queryEditorElement = (selector) => editorRoot?.querySelector?.(selector) || null;
        const displayedDummyEditor = queryEditorElement("#displayedDummyEditor");
        const hiddenDateInputEditor = queryEditorElement("#hiddenDateInputEditor");
        const clearButton = queryEditorElement("#clear");
        displayedDummyEditor?.addEventListener("blur", (ev) => {
          if (!moveOutFlg) {
            return;
          }
          let resultData = "";
          if (ev.target.value) {
            resultData = this.formatDirectGridDateString(ev.target.value);
          } else if (!hasInitValue) {
            hasInitValue = true;
          }
          if ((!hasInitValue || nowDtatString !== resultData) && hiddenDateInputEditor) {
            this.finishDirectGridCalendarEdit(
              hiddenDateInputEditor,
              displayedDummyEditor,
              resultData,
              data.model,
              data.field
            );
            nowDtatString = resultData;
            hasInitValue = true;
          }
        });
        const commonCalenderMountNode = (editorRoot?.ownerDocument || this.$el?.ownerDocument || document).createElement("span");
        container.append(commonCalenderMountNode);
        const commonCalenderApp = createApp(commonCalender, {
          onInput: value => {
            this.finishDirectGridCalendarEdit(
              hiddenDateInputEditor,
              displayedDummyEditor,
              value,
              data.model,
              data.field
            );
          }
        });
        const commonCalenderPicker = commonCalenderApp.mount(commonCalenderMountNode);
        commonCalenderPicker.setSilently(nowDtatString);
        const userAgent = ((this?.$el?.ownerDocument?.defaultView?.navigator?.userAgent) || globalThis?.navigator?.userAgent || "");
        if (userAgent.indexOf("Intel Mac OS") > -1) {
          displayedDummyEditor?.addEventListener("change", (ev) => {
            this.finishDirectGridCalendarEdit(
              hiddenDateInputEditor,
              displayedDummyEditor,
              ev.target.value,
              data.model,
              data.field
            );
          });
        } else {
          displayedDummyEditor?.addEventListener("change", (ev) => {
            commonCalenderPicker.setSilently(ev.target.value);
          });
        }
        clearButton?.addEventListener("mousedown", () => {
          this.finishDirectGridCalendarEdit(
            hiddenDateInputEditor,
            displayedDummyEditor,
            null,
            data.model,
            data.field
          );
        });
        clearButton?.addEventListener("touchstart", () => {
          this.finishDirectGridCalendarEdit(
            hiddenDateInputEditor,
            displayedDummyEditor,
            null,
            data.model,
            data.field
          );
        });
      }
    },
    // マスタ一覧のデータを取得
    findList() {
      // apiをコールして値を取得
      this.findRecordList()
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
          // add デバイスエッジマスタ 更新後の画面表示異常 孔 start
          this.changeMasterRecordsData()
          // add デバイスエッジマスタ 更新後の画面表示異常 孔 end
          // カラム幅等初期調整
          this.showSortColumn();
          this.$nextTick(() => {
            this.calculateGridHeight();
            this.calculateGridWidth();
            this.initDirectGridIfReady();
            this.refreshDirectGridDataFromMasterRecords();
            this.scheduleDirectGridLayoutContract();
          });
        })
        .catch(error => {
          if (error.response.status === 400) {
            //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
            getErrorMessage('MstDeviceEdgeMainComponent.vue', 'findList', '指定されたマスタが見つかりません。');
            //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
            this.$ons.notification.alert({
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
              // title: "取得失敗",
              // message: "指定されたマスタが見つかりません。"
              title: DIALOG_MESSAGES[12000003].title,
              message: messageFormat(DIALOG_MESSAGES[12000003].message),
            });
          }
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
          else{
            getErrorMessage('MstDeviceEdgeMainComponent.vue', 'findList', error);
          }
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
        });
    },
    async saveRecord() {
      // 共通ローダー:表示開始
      this.setLoadingScreenVisible(true);
      const { top: scrollTop, left: scrollLeft } = this.getGridScrollPosition();
      this.scrollPosition.top = scrollTop;
      this.scrollPosition.left = scrollLeft;
      this.lastScrollTop = scrollTop;
      this.lastScrollLeft = scrollLeft;
      // グリッドでエラーが発生している場合は処理を中断
      if (!this.kendoValidator.validate()) {
        //共通ローダー：表示終了
        this.setLoadingScreenVisible(false);
        return;
      }

      // 必須チェック
      if (!this.isFilledRequired()) {
        //共通ローダー：表示終了
        this.setLoadingScreenVisible(false);
        return;
      }

      // 半角英数字チェック
      if (!this.validateSerialNo()) {
        //共通ローダー：表示終了
        this.setLoadingScreenVisible(false);
        return;
      }

      // 重複チェック
      if (this.hasSameRecord()) {
        //共通ローダー：表示終了
        this.setLoadingScreenVisible(false);
        return;
      }

      const keys = [
        "deleteDate",
        "deviceEdgeNo",
        "deviceName",
        "facilityCd",
        "isDel",
        "isDisp",
        "memo",
        "serialNo",
        "settingDate"
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
            deleteCdList.push(record.serialNo);
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
          regDate: now,
          upDate: now
        })
      );

      const serializedUpdateRecords = updateRecords.map(record =>
        JSON.stringify({
          ..._.pick(record, keys),
          upDate: now
        })
      );

      const editRecord = {
        insertRecord: serializedInsertRecords,
        updateRecord: serializedUpdateRecords,
        deleteCdList
      };

      // // 登録日時・更新日時用の現在日時
      // const now = dayjs().format("YYYY-MM-DDTHH:mm:ss.SSSZ");

      // // ※編集レコード
      // const editedRecords = this.getUpdateRecordList.filter(record => {
      //   if (Object.prototype.hasOwnProperty.call(record, "operation")) {
      //     return record;
      //   }
      // });

      // // ※新規レコードは空配列で判定
      // const saveRecords = editedRecords.map(record => {
      //   // 更新レコード
      //   const saveRecord = {
      //     record: { ..._.pick(record, keys), upDate: now },
      //     orgSerialNo: record.orgSerialNo,
      //     deleteSerialNo: null
      //   };
      //   if (record.operation === 1) {
      //     // 新規レコード
      //     saveRecord.record = { ...saveRecord.record, regDate: now };
      //   } else if (record.operation === 2) {
      //     if (record.isDisp === "0") {
      //       // 削除レコード
      //       saveRecord.deleteSerialNo = record.orgSerialNo;
      //     }
      //   }
      //   saveRecord.record = JSON.stringify(saveRecord.record);
      //   return saveRecord;
      // });

      // mod #8403 【デグレ】デバイスエッジマスタで新規レコードが保存できない dou start
      // await ApiHelper.put("/mstInfo/saveMstDeviceEdge/", editRecord).catch(
      //   error => {
      //     //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
      //     getErrorMessage('MstDeviceEdgeMainComponent.vue', 'saveRecord', error);
      //     //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
      //     //共通ローダー：表示終了
      //     this.setLoadingScreenVisible(false);
      //     throw error;
      //     // console.log(`API:"${uri}"の実行に失敗しました。`);
      //     // console.log(error);
      //   }
      // );
      //
      // this.$ons.notification.alert({
      //   title: "更新完了",
      //   message: "マスタ更新が完了しました。"
      // });
      //
      // this.isSorted = false;
      // this.findList();
      //
      // // 画面表示フラグ
      // this.isSettedFacilityDataChacked = false;
      // // 施設マスタ取得フラグ
      // this.isGetMstFacility = true;
      //
      // //共通ローダー：表示終了
      // this.setLoadingScreenVisible(false);
      //
      // // グリッドのデータ再表示
      // this.gridDataRefresh();
      // apiをコールして値を登録
      await ApiHelper.put("/mstInfo/saveMstDeviceEdge", editRecord).then(() => {
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
        // 施設マスタ取得フラグ
        this.isGetMstFacility = true;
        //共通ローダー：表示終了
        this.setLoadingScreenVisible(false);
        // グリッドのデータ再表示
        this.gridDataRefresh();
      }).catch(
        error => {
          getErrorMessage('MstDeviceEdgeMainComponent.vue', 'saveRecord', error);
          //共通ローダー：表示終了
          this.setLoadingScreenVisible(false);
          this.$ons.notification.alert(ERROR_DEVICE_EDGE_SAVE,{title: ""});
        }
      );
      // 画面表示フラグ
      this.setLoadingScreenVisible(false);
      // mod #8403 【デグレ】デバイスエッジマスタで新規レコードが保存できない dou end
    },
    addRow() {
      // グリッドでエラーが発生している場合は処理を中断
      if (!this.kendoValidator.validate()) {
        return;
      }

      // 空レコードをストアに登録
      const d = new Object();
      const fields = this.getMasterRecordList.schema.model.fields;

      // 追加レコードに対応した初期値を設定
      Object.keys(fields).forEach(k => {
        if (fields[k].defaultValue) {
          d[k] = fields[k].defaultValue;
        } else if (k === "isDisp") {
          d[k] = "1";
        } else if (k === "isDel") {
          d[k] = "0";
        } else if (fields[k].type === "string") {
          d[k] = "";
        // add #9502 デバイスエッジ番号の範囲とデフォルト 宮崎 start
        } else if (k === "deviceEdgeNo") {
          d[k] = 1;
        // add #9502 デバイスエッジ番号の範囲とデフォルト 宮崎 end
        } else if (fields[k].type === "number") {
          d[k] = 0;
        } else if (k === "deleteDate") {
          d[k] = null;
        } else if (fields[k].type === "date") {
          d[k] = new Date();
        } else {
          d[k] = null;
        }

        // 初期時、新しいレコードに全レコードの並び順の最大値をセット
        if (k === "sortRank") {
          d[k] = this.getMaxSortRank() + 1;
        }
      });
      this.scrollPosition.left = 0;
      this.lastScrollLeft = 0;
      this.lastScrollTop = this.getGridScrollContainer()?.scrollHeight || 0;
      this.scheduleMasterGridScrollToAddedRow?.();
      // 画面編集内容をstoreに反映※レコード（d）追加
      this.edit({ editRecord: d, isSortMode: this.isSortMode });

      this.refreshDirectGridDataFromMasterRecords(false, false);
      this.$nextTick(() => {
        this.scheduleMasterGridScrollToAddedRow?.();
        this.applyDirectGridRowVisual(d);
      });
    },
    /**
     * @description 編集時、テキストエリアをプルダウンメニューに変換
     * @summary コンボ代用: ReferenceCombo.java: identifierValue(Long型)でfacility_cd(character varying型)エラー発生するため
     * @param {}
     * @param {}
     */
    editorDropDown(container, data) {
      // add 追加時に編集可能、他の状態は編集できません 宋qy start
      if (data.model.operation === 1) {
      // add 追加時に編集可能、他の状態は編集できません 宋qy end

        const initialFacilityName = data.model[data.field] || null;
        let selectionCommitted = false;
        const finishSelection = (selectedFacilityName) => {
          if (selectionCommitted || !selectedFacilityName) {
            return;
          }
          selectionCommitted = true;
          this.onFacilityNameSelected(data, selectedFacilityName, container);
        };
        $(`<input class="k-textbox" name="${data.field}"/>`)
          .appendTo(container)
          .kendoDropDownList({
            dataSource: this.mstFacility.filter(e=> !this.mntFacilityCancelManageList.includes(e.facilityCd)),
            dataTextField: "facilityName",
            dataValueField: "facilityName",
            value: initialFacilityName,
            filter: "contains",
            select(e) {
              finishSelection(e.dataItem?.facilityName);
            },
            change(e) {
              finishSelection(e.sender.value());
            }
          });
      } else {
        // 編集不可時でもeditStart()が発火するため、ここでフラグをoffにする
        this.editingFlg = false;
        // 既存レコードはlabelにして編集させない
        $(`<label>${data.model.facilityName}</label>`).appendTo(container);
      }
    },

    /**
     * @description 製造番号列のkendo editor
     */
    serialNoEditor(container, data) {
      /* mod 制御条件の変更 楊 start */
      // if (data.model.operation) {
      if (data.model.operation === 1) {
      /* mod 制御条件の変更 楊 end */
        // 新規レコードは編集可なのでinput
        $(
          `<input class="k-textbox" name="${data.field}" maxlength="20" />`
        ).appendTo(container);
      } else {
        // 編集不可時でもeditStart()が発火するため、ここでフラグをoffにする
        this.editingFlg = false;
        // 既存レコードはlabelにして編集させない
        $(`<label>${data.model.serialNo}</label>`).appendTo(container);
      }
    },

    /**
     * @description デバイスエッジ番号列のkendo editor
     */
    deviceEdgeNoEditor(container, data) {
      /* mod 制御条件の変更 楊 start */
      // if (data.model.operation) {
      if (data.model.operation === 1) {
      /* mod 制御条件の変更 楊 end */
        // 新規レコードは編集可なのでinput
        $(`<input class="deviceSetInfo-numbersTextbox" name="${data.field}"/>`)
          .appendTo(container)
          .kendoNumericTextBox({
            min: 1,
            max: 99
            // step: this.numericStepValue,
            // decimals: this.numericDecimalsValue
          });
      } else {
        // 編集不可時でもeditStart()が発火するため、ここでフラグをoffにする
        this.editingFlg = false;
        // 既存レコードはlabelにして編集させない
        $(`<label>${data.model.deviceEdgeNo}</label>`).appendTo(container);
      }
    },

    /**
     * @description 施設名プルダウン選択時の処理
     */
    onFacilityNameSelected(data, selectedFacilityName, container) {
      const model = data?.model;
      const field = data?.field || "facilityName";
      if (!model || !selectedFacilityName) {
        return model;
      }
      if (typeof model.set === "function") {
        model.set(field, selectedFacilityName);
      } else {
        model[field] = selectedFacilityName;
      }
      if (model.operation === 1) {
        model.edited = true;
      }
      const record = this.setFacilityInfo(model);
      this.setDisplayFacilityData(record);
      this.edit({ editRecord: record, isSortMode: this.isSortMode });

      this.directGridSaveGuard = true;
      if (record.operation === 1) {
        commitDirectGridAddedRowDropDownCell(
          this.directGridWidget,
          container,
          field,
          selectedFacilityName
        );
        this.editingFlg = false;
      } else {
        this.directGridWidget?.closeCell?.();
      }
      this.syncFacilityRowDisplay(record);
      requestAnimationFrame(() => {
        this.directGridSaveGuard = false;
        this.syncFacilityRowDisplay(record);
        this.scheduleDirectGridCurrentRowVisual(record);
      });
      return record;
    },

    syncFacilityRowDisplay(record) {
      syncDirectGridRecordFieldCells(
        this.directGridWidget,
        this.getDirectGridRoot(),
        record,
        FACILITY_ROW_FIELDS
      );
    },

    /**
     * @description 施設名に一致したレコードに各施設情報を設定
     * @param {Object} record
     */
    setFacilityInfo(record) {
      for (const facilityRecord of this.mstFacility) {
        if (facilityRecord.facilityName === record.facilityName) {
          const prefecture = prefectures.find(
            prefecture => prefecture.prefCd === facilityRecord.prefecturesCd
          );

          record.facilityCd = facilityRecord.facilityCd;
          record.departmentCd = facilityRecord.departmentCd;

          if (prefecture === undefined) {
            record.prefecturesCd = null;
          } else {
            record.prefecturesCd = prefecture.prefName;
          }
        }
      }
      return record;
    },

    /**
     * @description kendo画面表示内容を強制的に変更
     * @param {Object} editRecord:レコード
     */
    setDisplayFacilityData(editRecord) {
      // DB登録値を保持
      const saveFacilityCd = editRecord.facilityCd;
      const savePrefecturesCd = editRecord.prefecturesCd;
      const saveDepartmentCd = editRecord.departmentCd;

      // 表示内容を強制的に変更するためにDB登録値を表示させたい内容とは別の値を設定させる
      editRecord.facilityCd = null;
      editRecord.prefecturesCd = null;
      editRecord.departmentCd = null;

      //強制的に表示内容を変更
      const grid = this.directGridWidget || this.$refs.grid?.kendoWidget?.();
      const dataItem = grid?.dataSource?.get?.(editRecord.code) || editRecord;
      if (typeof dataItem.set !== "function") {
        editRecord.facilityCd = saveFacilityCd;
        editRecord.prefecturesCd = savePrefecturesCd;
        editRecord.departmentCd = saveDepartmentCd;
        return;
      }
      dataItem.set("facilityCd", saveFacilityCd);
      dataItem.set("prefecturesCd", savePrefecturesCd);
      dataItem.set("departmentCd", saveDepartmentCd);

      // DB登録値に元の値を設定
      editRecord.facilityCd = saveFacilityCd;
      editRecord.prefecturesCd = savePrefecturesCd;
      editRecord.departmentCd = saveDepartmentCd;
      this.syncFacilityRowDisplay(dataItem);
    },

    /**
     * @description 施設コードに一致したレコードに各施設情報を設定
     * @param {Object}
     * @returns {Object}
     */
    setFacilityData(record) {
      for (const facilityRecord of this.mstFacility) {
        if (facilityRecord.facilityCd === record.facilityCd) {
          const prefecture = prefectures.find(
            prefecture => prefecture.prefCd === facilityRecord.prefecturesCd
          );

          // 表示内容を適当な値に修正
          record.facilityName = facilityRecord.facilityName;
          record.departmentCd = facilityRecord.departmentCd;
          if (prefecture === undefined) {
            record.prefecturesCd = null;
          } else {
            record.prefecturesCd = prefecture.prefName;
          }
        }
      }
      // 各レコードを識別させるためcodeを設定
      record.code = `record_${record.serialNo}`;
      return record;
    },

    /**
     * @description 表示順設定
     * @summary 施設コードでソート、同じなら製造番号
     * @param {Array}
     */
    sortRecords(records) {
      records.sort((a, b) => {
        if (a.facilityCd === b.facilityCd) {
          // 施設コードが同じなら製造番号でソート

          const serialNoA = a.serialNo.toLowerCase(); // 大文字と小文字を無視する
          const serialNoB = b.serialNo.toLowerCase(); // 大文字と小文字を無視する
          if (serialNoA < serialNoB) {
            return -1;
          }
          if (serialNoA > serialNoB) {
            return 1;
          }
          return 0;
        } else {
          return a.facilityCd - b.facilityCd;
        }
      });
    },

    /**
     * @description 画面表示関数
     */
    showDisplay() {
      // 画面表示フラグ
      this.isSettedFacilityDataChacked = true;
      // 施設情報更新フラグ
      this.isGetMstFacility = false;
      this.$nextTick(() => {
        this.initDirectGridIfReady();
        this.refreshDirectGridDataFromMasterRecords();
        this.scheduleDirectGridLayoutContract();
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
          item => item.serialNo === null || item.serialNo === "")) {
        this.isDialogVisible = true;
        this.messageCd = 20010002;
        this.stringParams = ["製造番号"];
        return false;
      }
      return true;
    },

    /**
     * @description 重複レコードチェック
     * @summary 施設コードが重複する項目があったらダイアログを表示する
     * @returns {Boolean} true: 重複あり, false: 重複なし
     */
    hasSameRecord() {
      const serialNoList = this.getUpdateRecordList.map(
        record => record.serialNo
      );
      // 施設コードリストをSetオブジェクトに(重複排除)
      const set = new Set(serialNoList);

      if (serialNoList.length !== set.size) {
        // 元のリストと重複排除リストの長さが違うなら重複あり
        this.isDialogVisible = true;
        this.messageCd = 60000001;
        this.stringParams = ["製造番号"];
        return true;
      }

      const deviceEdgeNoList = this.getUpdateRecordList.map(item => {
        return {
          // mod #8403 【デグレ】デバイスエッジマスタで新規レコードが保存できない dou start
          // deviceEdgeNo: +item.deviceEdgeNo,
          // facilityCd: +item.facilityCd
          deviceEdgeNo: item.deviceEdgeNo,
          facilityCd: item.facilityCd
          // mod #8403 【デグレ】デバイスエッジマスタで新規レコードが保存できない dou end
        }
      });
      const uniqueDeviceEdgeNoList =  deviceEdgeNoList.reduce((unique, current) => {
        if(!unique.some(item => item.deviceEdgeNo === current.deviceEdgeNo && item.facilityCd === current.facilityCd)) {
          unique.push(current);
        }
        return unique;
      },[])

      if (deviceEdgeNoList.length !== uniqueDeviceEdgeNoList.length) {
        // 元のリストと重複排除リストの長さが違うなら重複あり
        this.isDialogVisible = true;
        this.messageCd = 60000001;
        this.stringParams = ["デバイスエッジ番号"];
        return true;
      }

      return false;
    },

    /**
     * @description 製造番号チェック
     * @summary 半角英数字でない部署符号があったらダイアログを表示する
     * @returns {Boolean} true: 部署符号が全て正しい, false: 半角英数字でない部署符号あり
     */
    validateSerialNo() {
      // 部署符号リスト
      const serialNoList = this.getUpdateRecordList.map(
        record => record.serialNo
      );
      // 半角英数字の正規表現パターン
      const regexp = /^[0-9a-zA-Z]*$/;
      if (serialNoList.some(cd => !regexp.test(cd))) {
        this.isDialogVisible = true;
        this.messageCd = 60000002;
        this.stringParams = ["製造番号"];
        return false;
      }
      return true;
    },

    // /**
    //  * 画面再描画処理
    //  */
    async refresh() {
      // 他の画面に遷移したときもrefresh()が発生する為、自分の画面のみ処理する
      if (this.selfScreenName === this.$route.name
          && getScopedAlertDialogs(this.$el || this).length === 0) {
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
                this.isSorted = false;
                this.findList();
                // 画面表示フラグ
                this.isSettedFacilityDataChacked = false;
                // 施設マスタ取得フラグ
                this.isGetMstFacility = true;
              }
            }
          });
        } else {
          this.isSorted = false;
          this.findList();
          // 画面表示フラグ
          this.isSettedFacilityDataChacked = false;
          // 施設マスタ取得フラグ
          this.isGetMstFacility = true;
        }
      }
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
      bindGridEditorEnterToCloseCell(e?.sender || this.directGridWidget, e?.container);
      const editField = getGridEditFieldFromEvent(e, this.columns);
      if (editField !== "facilityName") {
        bindGridEditorDropDownListToCloseCell(e?.sender || this.directGridWidget, e?.container);
      }
    },
  }
};
</script>

<!-- 個別スタイル定義 -->
<style scoped lang="scss">
.right {
  text-align: right;
}
.header-btn-area {
  height: auto;
  padding: 0.1em 0.1em 0.1em 0.1em;
  display: flex;
  gap: 10px;
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
  padding: 0.2em 1em 0em 1em;
  line-height: 2em;
  width: auto;
}
.kendo-grid-toolbar-style {
  padding: 0.1em 0.3em;
}
.kendo-grid-toolbar-style > span {
  margin-left: 0rem;
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

.custom-switch {
  transform: scale(0.85);
  transform-origin: center;
  touch-action: manipulation;
}

.kendo-grid-toolbar-style :deep(.k-grid-content-locked) {
  overflow-y: scroll !important;
  -webkit-overflow-scrolling: touch;
  scrollbar-width: none;
  -ms-overflow-style: none;
}
.kendo-grid-toolbar-style :deep(.k-grid-content-locked::-webkit-scrollbar) {
  display: none;
}
.mobile-header {
  min-height: 30px; /* モバイル用の高さ */
}

.mst-device-edge-direct-jq-grid {
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

:deep(td.k-dirty-cell) {
  font-weight: bold;
  &[data-field="sortRank"] {
    background-color: #ffff66 !important;
    .k-dirty {
      border-width: 0;
    }
  }
}

:deep(input[type="date"].ntss-input-date),
:deep(.k-i-close){
  font-weight: 200 !important;
}
</style>
