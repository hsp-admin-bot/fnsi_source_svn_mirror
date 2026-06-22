/** * 装置マスタメンテナンスデータページ MainContent */
<template>
  <div class="main-content-area master-maintenance-page">
    <div class="ntss-list" :style="ntssListStyles">
      <div class="k-grid-toolbar k-header kendo-grid-toolbar-style mst-machine-direct-jq-toolbar" :style="heightStyles">
        <div id="grid-header" :class="['header-btn-area', 'right', isMobileDevice ? 'mobile-header' : '']">
          <v-ons-button
            class="btn3-normal toolbar-btn"
            style="float: left; margin-right:10px;"
            v-show="!isSortMode && isAllowAddRecord"
            @click="addRow()"
            >追加</v-ons-button
          >
          <v-ons-button
            v-show="!isSortMode && isAllowAddRecord"
            class="btn3-normal toolbar-btn"
            style="float: left; margin-left: 1px"
            @click="showRegistModal"
            >装置検索登録</v-ons-button
          >
          <v-ons-row v-show="isMobileDevice" style="float: left; width: 6em; height: 1em;">
            <v-ons-col width="45%" vertical-align="center">
              <label class="fab-font-color">編集</label>
            </v-ons-col>
            <v-ons-col width="55%" vertical-align="center">
              <v-ons-switch modifier="outline" v-model="allowEdit" />
            </v-ons-col>
          </v-ons-row>
          <v-ons-button
            modifier="outline"
            class="btn3-normal toolbar-btn csv-btn"
            style="margin-right: 10px"
            v-show="!isSortMode && isAllowSort"
            @click="importCsv($event)"
            >CSV取込
          </v-ons-button>
          <v-ons-button
            class="btn3-normal toolbar-btn"
            v-show="!isSortMode && isAllowSort"
            @click="toRankEditBtnClick()"
            >並び順表示</v-ons-button
          >
          <v-ons-button
            class="btn3-normal toolbar-btn"
            v-show="isSortMode && isAllowSort"
            @click="sortBtnClick()"
            >反映</v-ons-button
          >
        </div>
        <div
          v-show="columns.length > 1"
          id="grid-font-size"
          ref="gridRoot"
          :class="[fontSizeSet, 'ntss-kendo-grid-legacy', 'mst-machine-direct-jq-grid']"
        ></div>
      </div>
      <div id="grid-footer">
        <v-ons-row
          width="100%"
          :style="{ visibility: this.isSortMode ? 'hidden' : 'visible' }"
        >
          <v-ons-col width="50%">
            <v-ons-button
              class="btn2-cancel denial-btn"
              style="width: auto"
              @click="cancel"
              >キャンセル</v-ons-button
            >
          </v-ons-col>
          <v-ons-col width="50%" class="right">
            <v-ons-button
              class="btn1-execute registration-btn"
              style="width: auto"
              :disabled="!isChanged"
              @click="saveRecord"
              >保存</v-ons-button
            >
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
import { markRaw } from "@/compat/vue/runtime";
import { mapActions, mapGetters, mapMutations } from "@/compat/vue/vuex";
import $ from "jquery";
import kendo from "@progress/kendo-ui";
import { EventBus } from "@/compat/vue/event-bus.js";
import { deepCopy } from "@/functions/common/CommonFunctions";
import { sendRequestGetMstFacilityHashByFacilityCd } from "@/apis/mst-facility-hash";
import MasterCsvComponent from "@/components/master-maintenance/MasterCsvComponent";
import {
  bindGridEditorDropDownListToCloseCell,
  bindGridEditorEnterToCloseCell,
  commitDirectGridAddedRowDropDownCell,
  getGridEditFieldFromEvent,
  getGridEditorDropDownListWidget,
  resolveGridEditorDropDownListSaveValue
} from "@/compat/kendo/grid-edit";
import { appendValidationCallout } from "@/compat/kendo/validator.js";
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages.js";
//FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
import { messageFormat } from "@/functions/common/MessageFormat";
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 end

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

/**
 * TODO
 * more: モーダルで編集した項目が、一覧上で「編集済み（三角マーク）」をつけたい。
 */
export default {
  components: {
    "master-csv": MasterCsvComponent,
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
          values: null,
        },
      ],
      condition: {
        recordName: "",
        includeDeleted: false,
      },
      updateResponse: {
        isSuccess: false,
        errorMessage: "",
      },
      isSortMode: false,
      isSorted: false,
      kendoGridToolbarHeight: 500,
      kendoGridHeight: 300,
      columnWidth: 14,
      kendoValidatorSetup: {
        rules: {},
        messages: {},
      },
      // 編集失敗時のマスタ/列/スキーマ情報のバックアップ
      backupMasterRecordList: [],
      // 編集前情報のバックアップ
      preEditMasterRecordList: [],
      //Android端末で編集中であることを示すフラグ
      editingFlg: false,
      androidFlg: false,
      iosFlg: false,
      scrollPosition: {
        top: 0,
        left: 0,
      },
      // 選択中の施設コード
      facilitylistValue: "",
      // 自画面の名称
      selfScreenName: "",
      //変更前の施設
      prevFacilityCd: "",
      //選択施設のシステム利用設定
      facilitySysUseSetting: "",
      masterCsvVisible: false,
      masterCsvTarget: null,
      // add デバイスエッジのいずれか同期失敗であれば、同期中止問題の対応 劉 start
      // 同期失敗のデバイスエッジ
      errorName: [],
      // add デバイスエッジのいずれか同期失敗であれば、同期中止問題の対応 劉 end
      // add #7663 C重複情報のメッセージ画面を表示する。 xiaosonglei start
      intervalID: null,
      // add #7663 C重複情報のメッセージ画面を表示する。 xiaosonglei end
      gridScrollSyncBound: false,
      gridScrollSyncCleanup: [],
      directGridSyncingScroll: false,
      allowEdit: true, // NOTE: true = 編集モード、 false = 閲覧モード
      lastScrollTop: 0,
      lastScrollLeft: 0,
      lastscrollTop: 0,
      lastscrollLeft: 0,
      dbBeforeData: [],
      directGridDataSource: null,
      directGridReady: false,
      directGridMounted: false,
      directGridWidget: null,
      directGridResizeHandler: null,
      directGridFontResizeRafId: null,
      directGridFilterRefreshRafId: null,
      directGridScrollSyncRafId: null,
      directGridLayoutRefreshRafId: null,
      directGridEditVisualRafId: null,
      directGridRowVisualRafIds: markRaw(new Map()),
      directGridPendingSaveVisual: null,
      directGridPendingSaveVisualTimer: null,
      directGridSortEditedCodes: markRaw(new Set()),
      directGridEditedFieldsByCode: markRaw(new Map()),
      __pendingScrollLeftReset: false,
      // Vue2 KendoGrid rememberLegacyDirtyCellFromEvent 相当（locked/body 別 tbody の cellIndex）
      directGridDirtyCellHints: markRaw({}),
      // 最終行バリデーション tooltip の表示位置調整用（検証条件・保存処理には非関与）
      validationTooltipPlacementIntervalId: null,
      validationTooltipPlacementTimers: [],
      validationTooltipPlacementRafId: null,
    };
  },
  computed: {
    ...mapGetters("master-maintenance", {
      getFacilitySwitch: "getFacilitySwitch",
      // #9275 装置マスタの並び順が保存できない linjunfeng start
      isRecordModified: "isRecordModified",
      // #9275 装置マスタの並び順が保存できない linjunfeng end
    }),
    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight",
      windowWidth: "getWindowWidth",
    }),
    ...mapGetters("account-edit", {
      isDispMenu: "isDispMenu",
      getFontSize: "getFontSize",
      getStateUserAccountInfo: "getStateUserAccountInfo",
    }),
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
      const condition = this.$store?.state?.["master-maintenance"]?.condition || {};
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
    }),
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
      const data = this.getMasterRecordList?.data || [];
      const validatorInvalid = this.kendoValidator && typeof this.kendoValidator.validate === "function"
        ? !this.validateBeforeSortMode()
        : false;
      return (
        this.getStateUserAccountInfo !== null &&
        data !== undefined &&
        (data.filter((row) => row.operation > 0 || row.edited || row.dirty).length ||
          this.isSorted ||
          // #9275 装置マスタの並び順が保存できない linjunfeng start
          this.isRecordModified ||
          // #9275 装置マスタの並び順が保存できない linjunfeng end
          validatorInvalid)
      );
    },
    facilities() {
      // storeからデータを取得
      return this.getFacilityList;
    },
    isMasterUser: {
      get() {
        return this.getStateUserAccountInfo.userType === 1 ? true : false;
      },
      set() {},
    },
    ...mapGetters("mst-machine", {
      getMachineTypeList: "getMachineTypeList",
      getDeviceEdgeList: "getDeviceEdgeList",
      getFacilityList: "getFacilityList",
      getComTypeList: "getComTypeList",
      getMessageList: "getMessageList",
    }),
    ...mapGetters("toggle-dev-tool", ["isLockDevTool"]),
    isMobileDevice() {
      return this.iosFlg || this.androidFlg;
    }
  },
  watch: {
    windowHeight() {
      this.scheduleDirectGridFontSizeRefresh();
    },
    windowWidth() {
      this.scheduleDirectGridFontSizeRefresh();
    },
    isDispMenu() {
      this.scheduleDirectGridFontSizeRefresh();
    },
    getFontSize() {
      this.scheduleDirectGridFontSizeRefresh();
    },
    masterConditionSignature() {
      this.scheduleDirectGridFilterRefresh();
    },
    columns(val) {
      this.$nextTick(() => {
        if (val.length > 1) {
          this.initDirectGridIfReady();
          this.scheduleDirectGridPostLayoutRefresh();
        }
      });
    },
  },
  methods: {
    ...mapActions("multi-modal", ["showMasterEdit", "showMntFindMachineModal"]),
    ...mapActions("master-maintenance", [
      "findRecordListByFacilityCd",
      "setMasterRecordList",
      "edit",
      "setCondition",
      "findColumnInfo",
      "updateRecordListByFacilityCd",
      "setEditRecord",
      "editRecordBeEmpty",
      // #9275 装置マスタの並び順が保存できない linjunfeng start
      "setComparisonRecordModel",
      // #9275 装置マスタの並び順が保存できない linjunfeng end
    ]),
    // 共通ローダー設定
    ...mapActions("loading-screen", {
      setLoadingScreenVisible: "setLoadingScreenVisible",
      setLoadingScreenMessage: "setLoadingScreenMessage",
      resetLoadingScreenVisibleCount: "resetLoadingScreenVisibleCount",
    }),
    ...mapActions("mst-machine", [
      "getComboRecordList",
      "deleteMstMachineList",
      "synchroMstMachine",
      "facilityList",
      "updateSwitchOfflineMachineState",
      "updateChangeMachineState",
      "setFacilitySysUseSetting",
      "sendRequestGetDialysisState",
      "setEntryMachineList",
      "setEditCode",
    ]),
    ...mapMutations("mst-machine", ["setSelectedFacilityCd"]),

    getCurrentRouteName() {
      return this.$router?.currentRoute?.value?.name || this.$router?.currentRoute?.name || this.$route?.name || "";
    },
    cancel() {
      this.$router?.back?.();
    },
    getMaxSortRank() {
      const data = this.getFilteredMasterRecordList?.data || [];
      if (data.length > 0) {
        return data.reduce((a, b) => Math.max(a, +b.sortRank || 0), 0);
      }
      return 0;
    },
    getColumnIndex(fieldName) {
      return this.columns.findIndex(e => e.field === fieldName);
    },
    calculateColumnsWidth() {
      const fontSize = Number(this.getFontSize || 1);
      const widthMap = [12, 14, 16, 18];
      this.columnWidth = widthMap[fontSize] || 14;
    },
    calculateGridHeight() {
      if (this.editingFlg) {
        return;
      }
      const wh = Number(this.windowHeight) || window.innerHeight || 0;
      const headerElements = Array.prototype.slice.call(document.getElementsByClassName("header"));
      const hh = headerElements.length ? headerElements.pop().clientHeight : 0;
      const footerMenu = document.getElementById("footer-menu");
      const fmh = (this.isDispMenu === 1 && footerMenu ? footerMenu.clientHeight : 0) + 5;
      const kendoToolbarHeight = wh - hh - fmh;
      this.kendoGridToolbarHeight = kendoToolbarHeight > 100 ? kendoToolbarHeight : 100;

      let gridFooterHeight = 0;
      const gridFooter = document.getElementById("grid-footer");
      if (gridFooter) {
        gridFooterHeight = gridFooter.clientHeight;
      }
      let tableToolbarHeight = 0;
      const toolbarElements = document.getElementsByClassName("header-btn-area");
      if (toolbarElements && toolbarElements.length) {
        tableToolbarHeight = toolbarElements[0].clientHeight;
      }
      this.kendoGridHeight = Math.max(160, this.kendoGridToolbarHeight - (gridFooterHeight + tableToolbarHeight));
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
        this.$nextTick(() => {
          this.scheduleValidationTooltipPlacement();
        });
      } catch (_error) {
        // direct jq では resize 失敗時に追加 rebuild しない。
      }
    },
    scheduleDirectGridFontSizeRefresh() {
      if (this.directGridFontResizeRafId != null) {
        cancelAnimationFrame(this.directGridFontResizeRafId);
      }
      this.directGridFontResizeRafId = requestAnimationFrame(() => {
        this.directGridFontResizeRafId = null;
        this.calculateColumnsWidth();
        this.calculateGridHeight();
        this.applyDirectGridLegacyStyleContract();
        this.resizeDirectGrid();
        this.applyDirectGridLegacyStyleContract();
        this.editComFormatCd();
        this.scheduleDirectGridPostLayoutRefresh();
      });
    },
    scheduleDirectGridPostLayoutRefresh() {
      if (this.directGridLayoutRefreshRafId != null) {
        cancelAnimationFrame(this.directGridLayoutRefreshRafId);
      }
      // direct jq では locked 側に横スクロールバーが無い。
      // Kendo が非 locked 側の横スクロールバー高さを確定した後で、locked content の高さだけを合わせる。
      this.directGridLayoutRefreshRafId = requestAnimationFrame(() => {
        this.applyDirectGridLockedWidthContract();
        this.applyDirectGridLockedHeightContract();
        this.directGridLayoutRefreshRafId = requestAnimationFrame(() => {
          this.directGridLayoutRefreshRafId = null;
          this.applyDirectGridLockedWidthContract();
          this.applyDirectGridLockedHeightContract();
          this.restoreDirectGridScrollPosition();
          if (this.gridScrollSyncBound) {
            this.syncDirectGridLockedScrollPosition();
          } else {
            this.bindGridScrollSync();
          }
        });
      });
    },
    validateBeforeSortMode() {
      const validator = this.kendoValidator || this.$refs?.kendoValidator;
      if (validator && typeof validator.validate === "function") {
        const valid = validator.validate();
        if (!valid) {
          this.scheduleValidationTooltipPlacement();
        }
        return valid;
      }
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
          const columnValue = row[combo.field];
          const isEmpty = columnValue === null || columnValue === undefined || columnValue === "" || columnValue === "null";
          if (isEmpty) {
            return;
          }
          const exists = (combo.values || []).some(value => String(value?.value) === String(columnValue));
          if (!exists) {
            validateMessageArr.push(combo.title);
          }
        });
      });
      return this.convertToStr(validateMessageArr);
    },
    normalization(items) {
      const columnNames = (this.columnDefinition || this.columns || []).map(column => column.field);
      return Object.keys(items || {})
        .filter(key => columnNames.includes(key) || key === "isAddRow")
        .reduce((acc, key) => {
          acc[key] = items[key];
          return acc;
        }, {});
    },
    applyMachineSchemaValidationMessages(schema) {
      const fields = schema?.model?.fields;
      if (!fields || !Array.isArray(this.columns) || this.columns.length <= 1) {
        return;
      }
      Object.keys(fields).forEach(fieldName => {
        const targetField = fields[fieldName];
        if (targetField?.validation?.required) {
          const targetColumn = this.columns.find(column => column.field === fieldName);
          if (targetColumn?.title) {
            targetField.validation.validationMessage = `${targetColumn.title}は必須入力です。`;
          }
        }
      });
    },
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
    onCloseMasterEditModal() {
      this.$nextTick(() => {
        this.syncDirectGridDataFromStore();
        this.refreshDirectGridDataFromMasterRecords();
        this.$nextTick(() => this.restoreDirectGridScrollPosition());
      });
    },
    clearScrollPosition() {
      this.scrollPosition.top = 0;
      this.scrollPosition.left = 0;
    },
    gridDataRefresh() {
      this.refreshDirectGridDataFromMasterRecords();
    },
    importCsv(event) {
      if (!this.validateBeforeSortMode()) {
        return;
      }
      this.masterCsvTarget = event?.target || null;
      this.masterCsvVisible = true;
    },
    prehideCsvPopover() {
      this.masterCsvVisible = false;
      this.refreshDirectGridDataFromMasterRecords();
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
        const content = this.getDirectGridScrollContent();
        if (content) {
          content.scrollTop = 0;
          content.scrollLeft = 0;
        }
        try {
          this.directGridWidget.dataSource.data(this.getDirectGridDisplayData());
        } catch (_error) {
          return;
        }
        this.$nextTick(() => {
          this.applyDirectGridLegacyStyleContract();
          this.refreshDirectGridDirtyVisualState();
          this.editComFormatCd();
        });
      });
    },
    getGridWidget() {
      return this.directGridWidget || null;
    },
    getGridScrollPosition() {
      const content = this.getDirectGridScrollContent();
      return { top: content?.scrollTop || 0, left: content?.scrollLeft || 0 };
    },
    setGridScrollPosition(position = {}) {
      this.scrollPosition.top = position.top || 0;
      this.scrollPosition.left = position.left || 0;
      this.restoreDirectGridScrollPosition();
    },
    getGridScrollHostEl() {
      return this.getDirectGridScrollContent();
    },
    getGridHeaderEl() {
      return this.$refs.gridRoot?.querySelector?.(".k-grid-header") || null;
    },
    getGridTableEl() {
      return this.directGridWidget?.table?.[0] || this.$refs.gridRoot?.querySelector?.(".k-grid-content table") || null;
    },
    getGridTbodyEl() {
      return this.directGridWidget?.tbody?.[0] || this.$refs.gridRoot?.querySelector?.(".k-grid-content tbody") || null;
    },
    setGridDataSource(data) {
      if (this.directGridWidget?.dataSource) {
        this.directGridWidget.dataSource.data(Array.isArray(data?.data) ? data.data : data || []);
      }
    },
    editBackgroundColor() {
      this.refreshDirectGridDirtyVisualState();
    },
    getDirectGridScrollContent() {
      return this.$refs.gridRoot?.querySelector?.(".k-grid-content") || null;
    },
    getDirectGridLockedScrollContent() {
      return this.$refs.gridRoot?.querySelector?.(".k-grid-content-locked") || null;
    },
    getDirectGridSearchRoot() {
      const widget = this.directGridWidget;
      return widget?.wrapper?.[0] || widget?.element?.[0] || this.$refs.gridRoot || null;
    },
    getDirectGridDataSourceItems() {
      const collection = this.directGridWidget?.dataSource?.data?.();
      return collection ? Array.from(collection) : [];
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
      root.querySelectorAll(".ntss-validation-above").forEach((element) => {
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
    clearValidationTooltipPlacementState() {
      const root = this.getDirectGridSearchRoot();
      root?.querySelectorAll?.(".ntss-validation-above")?.forEach?.((element) => {
        element.classList.remove("ntss-validation-above");
        this.resetValidationTooltipCalloutDirection(element);
      });
    },
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
    storeDirectGridScrollPosition() {
      const pos = this.getGridScrollPosition();
      this.scrollPosition.top = pos.top;
      this.scrollPosition.left = pos.left;
      this.lastscrollTop = pos.top;
      this.lastscrollLeft = pos.left;
    },
    restoreDirectGridScrollPosition() {
      const gridContent = this.getDirectGridScrollContent();
      if (!gridContent) {
        return;
      }
      const top = this.scrollPosition.top || this.lastscrollTop || this.lastScrollTop || 0;
      const left = this.scrollPosition.left || this.lastscrollLeft || this.lastScrollLeft || 0;
      gridContent.scrollTop = top;
      gridContent.scrollLeft = left;
      this.syncDirectGridLockedScrollPosition(top);
      this.dispatchDirectGridContentScroll();
    },
    resetDirectGridHorizontalScroll() {
      const left = 0;
      const grid = this.directGridWidget;
      const gridContent = this.getDirectGridScrollContent();
      if (gridContent) {
        gridContent.scrollLeft = left;
      }
      if (grid?.content?.[0] && grid.content[0] !== gridContent) {
        grid.content[0].scrollLeft = left;
      }
      const headerWrap = this.$refs.gridRoot?.querySelector?.(".k-grid-header-wrap");
      if (headerWrap) {
        headerWrap.scrollLeft = left;
      }
      if (typeof grid?._scrollLeft !== "undefined") {
        grid._scrollLeft = left;
      }
      if (grid?.scrollables?.each) {
        grid.scrollables.each((_i, el) => {
          if (el && typeof el.scrollLeft === "number") {
            el.scrollLeft = left;
          }
        });
      }
      this.scrollPosition.left = left;
      this.lastscrollLeft = left;
      this.lastScrollLeft = left;
    },
    syncDirectGridLockedScrollPosition(scrollTop = null) {
      const lockedContent = this.getDirectGridLockedScrollContent();
      if (!lockedContent) {
        return;
      }
      const gridContent = this.getDirectGridScrollContent();
      lockedContent.scrollTop = scrollTop !== null && scrollTop !== undefined ? scrollTop : (gridContent?.scrollTop || 0);
    },
    unbindGridScrollSync() {
      this.gridScrollSyncCleanup?.forEach?.((cleanup) => {
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
      const lockedContent = this.getDirectGridLockedScrollContent();
      const scrollableContent = this.getDirectGridScrollContent();
      if (!lockedContent || !scrollableContent) {
        return;
      }
      this.unbindGridScrollSync();
      const onScrollableScroll = (event) => this.syncScrollFromScrollable(event);
      const onLockedScroll = (event) => this.syncScrollFromLocked(event);
      scrollableContent.addEventListener("scroll", onScrollableScroll, { passive: true });
      lockedContent.addEventListener("scroll", onLockedScroll, { passive: true });
      this.gridScrollSyncCleanup = [
        () => scrollableContent.removeEventListener("scroll", onScrollableScroll),
        () => lockedContent.removeEventListener("scroll", onLockedScroll),
      ];
      this.gridScrollSyncBound = true;
      this.syncDirectGridLockedScrollPosition(scrollableContent.scrollTop || 0);
    },
    syncScrollFromScrollable(event) {
      if (this.directGridSyncingScroll) {
        return;
      }
      const scrollableContent = event?.currentTarget || this.getDirectGridScrollContent();
      const lockedContent = this.getDirectGridLockedScrollContent();
      if (!scrollableContent) {
        return;
      }
      const nextTop = scrollableContent.scrollTop || 0;
      const nextLeft = scrollableContent.scrollLeft || 0;
      if (lockedContent && Math.abs((lockedContent.scrollTop || 0) - nextTop) > 1) {
        this.directGridSyncingScroll = true;
        lockedContent.scrollTop = nextTop;
        this.directGridSyncingScroll = false;
      }
      this.scrollPosition.top = nextTop;
      this.scrollPosition.left = nextLeft;
      this.lastscrollTop = nextTop;
      this.lastscrollLeft = nextLeft;
      this.lastScrollTop = nextTop;
      this.lastScrollLeft = nextLeft;
    },
    syncScrollFromLocked(event) {
      if (this.directGridSyncingScroll) {
        return;
      }
      const lockedContent = event?.currentTarget || this.getDirectGridLockedScrollContent();
      const scrollableContent = this.getDirectGridScrollContent();
      if (!lockedContent || !scrollableContent) {
        return;
      }
      const nextTop = lockedContent.scrollTop || 0;
      if (Math.abs((scrollableContent.scrollTop || 0) - nextTop) > 1) {
        this.directGridSyncingScroll = true;
        scrollableContent.scrollTop = nextTop;
        this.directGridSyncingScroll = false;
      }
      const nextLeft = scrollableContent.scrollLeft || 0;
      this.scrollPosition.top = nextTop;
      this.scrollPosition.left = nextLeft;
      this.lastscrollTop = nextTop;
      this.lastscrollLeft = nextLeft;
      this.lastScrollTop = nextTop;
      this.lastScrollLeft = nextLeft;
    },
    dispatchDirectGridContentScroll() {
      const gridContent = this.getDirectGridScrollContent();
      if (!gridContent) {
        return;
      }
      try {
        gridContent.dispatchEvent(new Event("scroll", { bubbles: true }));
      } catch (_error) {
        // noop
      }
      try {
        $(gridContent).trigger("scroll");
      } catch (_error) {
        // noop
      }
    },
    scrollDirectGridToBottom() {
      const content = this.getDirectGridScrollContent();
      if (!content) {
        return;
      }
      const targetTop = Math.max(0, content.scrollHeight - content.clientHeight);
      content.scrollTop = targetTop;
      this.syncDirectGridLockedScrollPosition(targetTop);
      this.scrollPosition.top = targetTop;
      this.lastscrollTop = targetTop;
      this.dispatchDirectGridContentScroll();
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
    setDirectGridColumnHidden(fieldName, hidden) {
      const grid = this.directGridWidget;
      if (!grid) {
        return;
      }
      const gridColumn = Array.isArray(grid.columns) ? grid.columns.find(col => col.field === fieldName) : null;
      if (!gridColumn || !!gridColumn.hidden === !!hidden) {
        return;
      }
      try {
        hidden ? grid.hideColumn(fieldName) : grid.showColumn(fieldName);
      } catch (_error) {
        // Vue2 wrapper と同じく列切替失敗で rebuild しない。
      }
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
    showSortColumn() {
      const sortRankIndex = this.columns.findIndex(col => col.field === "sortRank");
      if (sortRankIndex >= 0) {
        this.columns[sortRankIndex].hidden = !(this.isAllowSort && this.isSortMode);
        const dummyIndex = this.columns.findIndex(col => col.field === "dummy");
        if (dummyIndex >= 0) {
          this.columns[dummyIndex].hidden = !this.columns[sortRankIndex].hidden;
        }
      }
      this.setDirectGridColumnHidden("sortRank", !!this.columns.find(col => col.field === "sortRank")?.hidden);
      this.setDirectGridColumnHidden("dummy", !!this.columns.find(col => col.field === "dummy")?.hidden);
      this.syncDirectGridColumnStateToWidget();
      this.applyDirectGridLegacyStyleContract();
      this.restoreDirectGridScrollPosition();
      this.scheduleDirectGridPostColumnScrollSync();
      this.scheduleDirectGridPostLayoutRefresh();
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
        } else {
          byCode.set(`__index_${index}`, row);
        }
      });
      this.getMasterRecordList.data.forEach((record, index) => {
        const gridRow = byCode.get(String(record.code)) || byCode.get(`__index_${index}`);
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
    isDirectGridDisplayRecord(record) {
      return !!record;
    },
    getDirectGridDisplayRecords() {
      const source = this.getMasterRecordList?.data || [];
      const condition = this.$store?.state?.["master-maintenance"]?.condition || {};
      const recordName = condition.recordName ? String(condition.recordName) : "";
      const includeDeleted = !!condition.includeDeleted;

      const visible = includeDeleted ? source : source.filter(record => record?.isDisp !== "0");
      if (!recordName) {
        return visible.filter(record => this.isDirectGridDisplayRecord(record));
      }

      const filterKeys = ["name", "machineSerial", "comFormatCd", "ipAddress", "port", "version"];
      const matched = visible.filter(record => {
        if (!record) {
          return false;
        }
        if (record.skipSearch) {
          return true;
        }
        return filterKeys.some(key => String(record[key] ?? "").indexOf(recordName) !== -1);
      });
      return matched.filter(record => this.isDirectGridDisplayRecord(record));
    },
    getDirectGridDisplayData() {
      // 表示データも Vue2 wrapper の masterRecords getter 参照に寄せる。
      // Snapshot 用の clone は dbBeforeData 側に限定し、grid 表示用には使わない。
      return this.getDirectGridDisplayRecords();
    },
    refreshDirectGridDataFromMasterRecords() {
      if (!this.directGridWidget?.dataSource) {
        return;
      }
      try {
        this.directGridWidget.dataSource.data(this.getDirectGridDisplayData());
      } catch (_error) {
        return;
      }
      this.$nextTick(() => {
        this.applyDirectGridLegacyStyleContract();
        requestAnimationFrame(() => {
          requestAnimationFrame(() => {
            this.refreshDirectGridDirtyVisualState();
            this.editComFormatCd();
            this.restoreDirectGridScrollPosition();
            this.scheduleDirectGridPostLayoutRefresh();
          });
        });
      });
    },
    sort() {
      const list = this.getMasterRecordList?.data;
      if (!Array.isArray(list)) {
        return;
      }
      const compare = (a, b) => {
        const rankA = Number(a?.sortRank);
        const rankB = Number(b?.sortRank);
        const safeRankA = Number.isFinite(rankA) ? rankA : Number.MAX_SAFE_INTEGER;
        const safeRankB = Number.isFinite(rankB) ? rankB : Number.MAX_SAFE_INTEGER;
        if (safeRankA !== safeRankB) {
          return safeRankA - safeRankB;
        }
        const timeA = Number(a?.sortInputTime);
        const timeB = Number(b?.sortInputTime);
        const safeTimeA = Number.isFinite(timeA) ? timeA : 0;
        const safeTimeB = Number.isFinite(timeB) ? timeB : 0;
        return safeTimeA - safeTimeB;
      };
      list.sort(compare);
      for (let i = 0; i < list.length; i++) {
        if (list[i].isDisp === "1") {
          list[i].sortRank = i + 1;
        }
      }
    },
    sortChange(tempData) {
      const list = this.getMasterRecordList?.data || [];
      const beforeByCode = new Map((tempData || []).map(item => [String(item?.code), item]));
      return list.some(item => {
        const before = beforeByCode.get(String(item?.code));
        return before ? !this.machineCompareValuesEqual(item?.sortRank, before?.sortRank) : false;
      });
    },
    toRankEditBtnClick() {
      this.storeDirectGridScrollPosition();
      if (!this.validateBeforeSortMode()) {
        return;
      }
      this.isSortMode = true;
      this.disableColumns();
      this.showSortColumn();
    },
    sortBtnClick() {
      this.storeDirectGridScrollPosition();
      const tempData = clonePlain(this.getMasterRecordList?.data || []);
      try {
        this.directGridWidget?.closeCell?.();
      } catch (_error) {
        // noop
      }
      this.syncDirectGridSortValuesToMasterRecords();
      this.isSortMode = false;
      this.editableColumns();
      this.showSortColumn();
      this.sort();
      this.isSorted = this.sortChange(tempData);
      this.refreshDirectGridDataFromMasterRecords();
    },
    resolveDirectGridFontPixel() {
      const root = this.$refs.gridRoot || this.$el;
      const ownerWindow = root?.ownerDocument?.defaultView || window;
      const fontSize = Number.parseFloat(ownerWindow.getComputedStyle?.(root)?.fontSize || "");
      return Number.isFinite(fontSize) && fontSize > 0 ? fontSize : 14;
    },
    normalizeDirectGridColumnWidth(width) {
      return typeof width === "string" ? width.trim() : width;
    },
    parseDirectGridColumnWidthPx(width) {
      if (width === null || width === undefined || width === "") {
        return 0;
      }
      if (typeof width === "number") {
        return Number.isFinite(width) ? width : 0;
      }
      const value = String(width).trim().toLowerCase();
      const numeric = Number.parseFloat(value);
      if (!Number.isFinite(numeric)) {
        return 0;
      }
      if (value.endsWith("em")) {
        return numeric * this.resolveDirectGridFontPixel();
      }
      if (value.endsWith("px") || /^[0-9.]+$/.test(value)) {
        return numeric;
      }
      return 0;
    },
    getDirectGridVisibleLockedWidthPx() {
      return this.columns.reduce((total, column) => {
        if (!column?.locked || column.hidden) {
          return total;
        }
        return total + this.parseDirectGridColumnWidthPx(column.width);
      }, 0);
    },
    applyDirectGridLockedWidthContract() {
      const root = this.$refs.gridRoot;
      const width = this.getDirectGridVisibleLockedWidthPx();
      if (!root || !width) {
        return;
      }
      const widthPx = `${Math.ceil(width)}px`;
      [
        ".k-grid-header-locked",
        ".k-grid-content-locked",
        ".k-grid-footer-locked",
        ".k-grid-content-locked table",
        ".k-grid-header-locked table"
      ].forEach(selector => {
        root.querySelectorAll(selector).forEach(element => {
          element.style.width = widthPx;
          element.style.minWidth = widthPx;
        });
      });
    },
    applyDirectGridLockedHeightContract() {
      const content = this.getDirectGridScrollContent();
      const lockedContent = this.getDirectGridLockedScrollContent();
      if (!content || !lockedContent) {
        return;
      }
      const ownerWindow = content.ownerDocument?.defaultView || window;
      const styleHeight = Number.parseFloat(ownerWindow.getComputedStyle?.(content)?.height || "");
      const offsetHeight = content.offsetHeight || styleHeight || 0;
      const clientHeight = content.clientHeight || 0;
      const horizontalScrollbarHeight = Math.max(0, Math.ceil(offsetHeight - clientHeight));
      const targetHeight = clientHeight || (Number.isFinite(styleHeight) ? styleHeight - horizontalScrollbarHeight : 0);
      if (!Number.isFinite(targetHeight) || targetHeight <= 0) {
        return;
      }
      const heightPx = `${Math.floor(targetHeight)}px`;
      lockedContent.style.height = heightPx;
      lockedContent.style.maxHeight = heightPx;
      this.syncDirectGridLockedScrollPosition();
    },
    applyDirectGridLegacyShellClasses() {
      const root = this.$refs.gridRoot;
      if (!root) {
        return;
      }
      root.classList.add("ntss-kendo-grid-legacy", "k-widget", "k-grid", "k-editable", "k-display-block", "mst-machine-direct-jq-grid");
    },
    applyDirectGridLegacyContentClasses() {
      const root = this.$refs.gridRoot;
      if (!root) {
        return;
      }
      root.querySelectorAll("th").forEach(th => th.classList.add("k-header"));
      root.querySelectorAll("tbody tr").forEach((tr, index) => {
        tr.classList.add("k-master-row");
        if (index % 2 === 1) {
          tr.classList.add("k-alt");
        } else {
          tr.classList.remove("k-alt");
        }
      });
      root.querySelectorAll("td").forEach(td => td.classList.add("k-td", "k-table-td"));
    },
    applyDirectGridLegacyStyleContract() {
      this.applyDirectGridLegacyShellClasses();
      this.applyDirectGridLegacyContentClasses();
      this.applyDirectGridLockedWidthContract();
      this.applyDirectGridLockedHeightContract();
      this.syncDirectGridLockedScrollPosition();
    },
    getDirectGridColumnIndex(fieldName) {
      return this.columns.findIndex(column => column.field === fieldName);
    },
    getDirectGridRowsByRecord(record, preferredUid = null) {
      const root = this.$refs.gridRoot;
      const grid = this.directGridWidget;
      if (!root || !grid || !record) {
        return [];
      }
      const rows = [];
      if (preferredUid) {
        rows.push(...root.querySelectorAll(`tbody tr[data-uid="${preferredUid}"]`));
      }
      if (rows.length === 0 && record.code !== undefined && record.code !== null) {
        root.querySelectorAll("tbody tr[data-uid]").forEach(row => {
          let item = null;
          try {
            item = grid.dataItem?.(row);
          } catch (_error) {
            item = null;
          }
          if (String(item?.code) === String(record.code)) {
            rows.push(row);
          }
        });
      }
      return rows;
    },
    getDirectGridCellsByField(rows, fieldName) {
      if (!fieldName) {
        return [];
      }
      return (rows || [])
        .map(row => this.findDirectGridCellForField(row, fieldName))
        .filter(Boolean);
    },
    findDirectGridCellForField(row, fieldName) {
      if (!row || !fieldName) {
        return null;
      }
      const escapedField = CSS.escape(String(fieldName));
      const dataFieldCell = row.querySelector(
        `td[data-field="${escapedField}"], .k-table-td[data-field="${escapedField}"]`
      );
      if (dataFieldCell) {
        return dataFieldCell;
      }
      const grid = this.directGridWidget;
      if (!Array.isArray(grid?.columns)) {
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
      const cells = Array.from(row.children || []);
      let columnVisibleIndex = 0;
      for (const column of this.columns || []) {
        if (!column || column.hidden) {
          continue;
        }
        if (!!column.locked !== isLockedRow) {
          continue;
        }
        if (column.field === fieldName) {
          return cells[columnVisibleIndex] || null;
        }
        columnVisibleIndex += 1;
      }
      return null;
    },
    isDirectGridLeadDataColumn(column) {
      const field = column?.field;
      return !!field && field !== "dummy" && field !== "sortRank" && field !== "$modalType" && !column.hidden;
    },
    getDirectGridLeadDataFieldName() {
      const scrollableColumn = (this.columns || []).find(
        col => this.isDirectGridLeadDataColumn(col) && !col.locked
      );
      if (scrollableColumn?.field) {
        return scrollableColumn.field;
      }
      const column = (this.columns || []).find(col => this.isDirectGridLeadDataColumn(col));
      return column?.field || "name";
    },
    getDirectGridDomColumns(locked) {
      const columns = (this.columns || []).length > 1 ? this.columns : (this.directGridWidget?.columns || []);
      return columns.filter(column => !column.hidden && !!column.locked === !!locked);
    },
    getDirectGridCellByFieldInRow(row, fieldName, record = null) {
      if (!row || !fieldName) {
        return null;
      }
      const locked = !!row.closest?.(".k-grid-content-locked");
      const section = locked ? "locked" : "body";
      const cells = Array.from(row.children || []);
      const recordKey = record?.code !== undefined && record?.code !== null
        ? String(record.code)
        : "";
      const hint = recordKey ? this.directGridDirtyCellHints?.[`${recordKey}:${fieldName}`] : null;
      if (hint?.section === section && Number.isInteger(hint.cellIndex) && cells[hint.cellIndex]) {
        return cells[hint.cellIndex];
      }
      const columns = this.getDirectGridDomColumns(locked);
      const columnIndex = columns.findIndex(column => column.field === fieldName);
      if (columnIndex < 0) {
        return null;
      }
      return cells[columnIndex] || null;
    },
    rememberDirectGridDirtyCellFromEvent(ev, fieldName = null) {
      const field = fieldName || this.getDirectGridFieldFromEvent(ev);
      const cell = ev?.container?.[0] || ev?.container;
      const model = ev?.model;
      if (!field || !cell || !model) {
        return;
      }
      const recordKey = this.getDirectGridRecordKey(this.getDirectGridModelPlain(model));
      if (!recordKey) {
        return;
      }
      const row = cell.closest?.("tr[data-uid]");
      if (!row) {
        return;
      }
      const cellIndex = Array.from(row.children || []).indexOf(cell);
      if (cellIndex < 0) {
        return;
      }
      const section = row.closest?.(".k-grid-content-locked") ? "locked" : "body";
      if (!this.directGridDirtyCellHints) {
        this.directGridDirtyCellHints = markRaw({});
      }
      this.directGridDirtyCellHints[`${recordKey}:${field}`] = { section, cellIndex };
    },
    // Vue2 MasterMaintenanceMixin.changeEditColor：k-dirty-cell 付きセルのみ master-edited-cell + 三角
    applyDirectGridChangeEditColor(rows) {
      if (!Array.isArray(rows) || !rows.length) {
        return;
      }
      const sortRankIndex = this.getDirectGridColumnIndex("sortRank");
      rows.forEach(row => {
        const isLockedRow = !!row.closest?.(".k-grid-content-locked");
        Array.from(row.children || []).forEach((cell, index) => {
          const colIndex = Number(cell.getAttribute("aria-colindex")) - 1;
          const effectiveIndex = Number.isFinite(colIndex) ? colIndex : index;
          const isSortRank = effectiveIndex === sortRankIndex;
          const hasDirtyCell = cell?.classList?.contains("k-dirty-cell");
          if (!hasDirtyCell) {
            return;
          }
          if (isLockedRow && isSortRank) {
            return;
          }
          const fieldName = this.getDirectGridFieldFromCell(cell)
            || this.getDirectGridDomColumns(isLockedRow)[effectiveIndex]?.field;
          if (fieldName) {
            this.markDirectGridDirtyCell(cell, fieldName);
          }
        });
      });
    },
    resolveDirectGridFieldFromAriaColIndex(colIndex) {
      if (!Number.isFinite(colIndex) || colIndex < 0) {
        return null;
      }
      const gridColumns = this.directGridWidget?.columns;
      if (Array.isArray(gridColumns) && colIndex < gridColumns.length) {
        const gridField = gridColumns[colIndex]?.field;
        if (gridField && gridField !== "dummy") {
          return gridField;
        }
      }
      const field = this.columns[colIndex]?.field || null;
      return field === "dummy" ? null : field;
    },
    findDirectGridCellsForRecordField(record, fieldName, preferredUid = null, resolvedRows = null) {
      const root = this.$refs.gridRoot;
      if (!fieldName) {
        return [];
      }
      const rows = resolvedRows || this.getDirectGridRowsByRecord(record, preferredUid);
      const uid = preferredUid || rows[0]?.getAttribute?.("data-uid");
      if (root && uid) {
        const escapedUid = CSS.escape(String(uid));
        const escapedField = CSS.escape(String(fieldName));
        const cells = Array.from(
          root.querySelectorAll(
            `tr[data-uid="${escapedUid}"] td[data-field="${escapedField}"], tr[data-uid="${escapedUid}"] .k-table-td[data-field="${escapedField}"]`
          )
        );
        if (cells.length) {
          return cells;
        }
      }
      const cellsFromRows = rows
        .map(row => this.findDirectGridCellForField(row, fieldName))
        .filter(Boolean);
      if (cellsFromRows.length) {
        return cellsFromRows;
      }
      if (!root || record?.code === undefined || record?.code === null) {
        return [];
      }
      return Array.from(root.querySelectorAll("tbody tr[data-uid]"))
        .filter(row => {
          try {
            const item = this.directGridWidget?.dataItem?.(row);
            return item && String(item.code) === String(record.code);
          } catch (_error) {
            return false;
          }
        })
        .map(row => this.findDirectGridCellForField(row, fieldName))
        .filter(Boolean);
    },
    markDirectGridDirtyCell(cell, fieldName = null) {
      if (!cell?.classList) {
        return;
      }
      if (fieldName) {
        cell.setAttribute("data-field", fieldName);
      }
      cell.classList.add("k-dirty-cell", "master-edited-cell");
      cell.style.setProperty("font-weight", "bold", "important");
      cell.style.setProperty("color", "#003300", "important");
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
    applyDirectGridEditBoldFromDirtyCells(rows) {
      (rows || []).forEach(row => {
        Array.from(row.children || []).forEach(cell => {
          if (cell?.classList?.contains("k-dirty-cell")) {
            cell.classList.add("master-edited-cell");
            cell.style.setProperty("font-weight", "bold", "important");
            cell.style.setProperty("color", "#003300", "important");
          }
        });
      });
    },
    resolveDirectGridSaveField(ev) {
      const fromEvent = this.getDirectGridFieldFromEvent(ev);
      if (fromEvent) {
        return fromEvent;
      }
      const valueKeys = Object.keys(ev?.values || {});
      return valueKeys.length ? valueKeys[0] : null;
    },
    getDirectGridEditedFields(record) {
      const key = this.getDirectGridRecordKey(record);
      if (!key || !this.directGridEditedFieldsByCode?.has?.(key)) {
        return [];
      }
      return Array.from(this.directGridEditedFieldsByCode.get(key));
    },
    markDirectGridEditedField(record, fieldName) {
      const key = this.getDirectGridRecordKey(record);
      if (!key || !fieldName || fieldName === "dummy" || fieldName === "sortRank") {
        return;
      }
      if (!this.directGridEditedFieldsByCode) {
        this.directGridEditedFieldsByCode = markRaw(new Map());
      }
      if (!this.directGridEditedFieldsByCode.has(key)) {
        this.directGridEditedFieldsByCode.set(key, markRaw(new Set()));
      }
      this.directGridEditedFieldsByCode.get(key).add(fieldName);
    },
    unmarkDirectGridEditedField(record, fieldName) {
      const key = this.getDirectGridRecordKey(record);
      if (!key || !fieldName || !this.directGridEditedFieldsByCode?.has?.(key)) {
        return;
      }
      this.directGridEditedFieldsByCode.get(key).delete(fieldName);
      if (this.directGridEditedFieldsByCode.get(key).size === 0) {
        this.directGridEditedFieldsByCode.delete(key);
      }
    },
    reconcileDirectGridEditedFields(record, fieldNames = []) {
      if (!record || !Array.isArray(fieldNames) || fieldNames.length === 0) {
        return;
      }
      const original = this.isDirectGridAddedRecord(record) ? null : this.findMachineOriginalRecord(record);
      fieldNames.forEach(fieldName => {
        if (!this.isDirectGridVisualEditField(fieldName)) {
          return;
        }
        if (original) {
          if (this.machineCompareValuesEqual(record[fieldName], original[fieldName])) {
            this.unmarkDirectGridEditedField(record, fieldName);
          } else {
            this.markDirectGridEditedField(record, fieldName);
          }
          return;
        }
        if (this.isDirectGridAddedFieldChanged(record, fieldName)) {
          this.markDirectGridEditedField(record, fieldName);
        } else {
          this.unmarkDirectGridEditedField(record, fieldName);
        }
      });
    },
    clearDirectGridEditedFields(record) {
      const key = this.getDirectGridRecordKey(record);
      if (key) {
        this.directGridEditedFieldsByCode?.delete?.(key);
      }
    },
    getMachineChangedFieldsFromSnapshot(record) {
      if (!record || this.isDirectGridAddedRecord(record)) {
        return [];
      }
      const original = this.findMachineOriginalRecord(record);
      if (!original) {
        return [];
      }
      const skipFields = new Set(["sortRank", "sortInputTime", "dummy", "uid"]);
      const keys = this.getMachineSchemaFieldKeys() || Object.keys(original);
      return keys.filter(key => {
        if (skipFields.has(key)) {
          return false;
        }
        if (this.isMachineDateField(key)) {
          return this.machineCompareDateValue(record?.[key]) !== this.machineCompareDateValue(original?.[key]);
        }
        return !this.machineCompareValuesEqual(record[key], original[key]);
      });
    },
    getDirectGridDirtyFieldNames(record) {
      if (!record) {
        return [];
      }
      const skipFields = new Set(["sortRank", "sortInputTime", "dummy", "uid"]);
      const fromSnapshot = this.getMachineChangedFieldsFromSnapshot(record);
      const fromSession = this.getDirectGridEditedFields(record).filter(fieldName => !skipFields.has(fieldName));
      return [...new Set([...fromSnapshot.filter(fieldName => !skipFields.has(fieldName)), ...fromSession])];
    },
    syncDirectGridDirtyCellMarkersForRecord(record, preferredUid = null, resolvedRows = null) {
      if (!record) {
        return;
      }
      const rows = resolvedRows || this.getDirectGridRowsByRecord(record, preferredUid);
      if (!rows.length) {
        return;
      }
      const dirtyFieldNames = this.getDirectGridDirtyFieldNames(record);
      // Vue2：追加直後は三角なし。セル保存後（dirtyFields 相当）にのみ markDirectGridDirtyCell
      if (dirtyFieldNames.length === 0) {
        return;
      }
      this.markDirectGridDirtyCellsForFields(record, dirtyFieldNames, preferredUid, rows);
    },
    clearDirectGridRowVisualState(rows) {
      rows.forEach(row => {
        row.classList.remove("k-dirty-row", "master-edited-row", "edited-bg", "master-deleted-row", "deleted-bg", "master-sort-edited");
        row.style.removeProperty("background");
        row.style.removeProperty("background-color");
        Array.from(row.children || []).forEach(cell => {
          cell.classList.remove("master-edited-row", "master-edited-cell", "master-deleted-row", "deleted-bg", "master-sort-edited", "k-dirty-cell");
          cell.style.removeProperty("font-weight");
          cell.style.removeProperty("color");
          cell.style.removeProperty("background");
          cell.style.removeProperty("background-color");
          cell.querySelectorAll("span.k-dirty").forEach(span => span.remove());
        });
      });
    },
    isDirectGridAddedRecord(record) {
      return record?.operation === 1 || String(record?.operation) === "1" || record?.isAddRow === true;
    },
    isDirectGridDeletedRecord(record) {
      return String(record?.isDisp) === "0" || String(record?.isDel) === "1";
    },
    isDirectGridVisualEditField(fieldName) {
      return !!fieldName && !["dummy", "sortRank", "sortInputTime", "uid", "isDisp", "isDel"].includes(fieldName);
    },
    isDirectGridAddedFieldChanged(record, fieldName) {
      if (!record || !this.isDirectGridVisualEditField(fieldName)) {
        return false;
      }
      return this.machineCompareValue(record[fieldName]) !== null;
    },
    isDirectGridRecordVisuallyChanged(record) {
      if (!record) {
        return false;
      }
      const dirtyFieldNames = this.getDirectGridDirtyFieldNames(record);
      if (this.isDirectGridAddedRecord(record)) {
        return dirtyFieldNames
          .filter(fieldName => this.isDirectGridVisualEditField(fieldName))
          .some(fieldName => this.isDirectGridAddedFieldChanged(record, fieldName));
      }
      return dirtyFieldNames.length > 0;
    },
    findMachineOriginalRecord(record) {
      if (!record || record.code === undefined || record.code === null) {
        return null;
      }
      return (this.dbBeforeData || []).find(item => String(item.code) === String(record.code)) || null;
    },
    machineCompareValue(value) {
      if (value === undefined || value === null || value === "" || value === "null") {
        return null;
      }
      if (typeof value === "string") {
        const trimmed = value.trim();
        return trimmed === "" ? null : trimmed;
      }
      return value;
    },
    machineCompareValuesEqual(a, b) {
      const na = this.machineCompareValue(a);
      const nb = this.machineCompareValue(b);
      if (na == nb) {
        return true;
      }
      const numA = Number(na);
      const numB = Number(nb);
      if (!Number.isNaN(numA) && !Number.isNaN(numB) && `${na}`.trim() !== "" && `${nb}`.trim() !== "") {
        return numA === numB;
      }
      return `${na}` === `${nb}`;
    },
    machineCompareDateValue(value) {
      if (value === undefined || value === null || value === "" || value === "null") {
        return null;
      }
      if (value instanceof Date && !Number.isNaN(value.getTime())) {
        const year = value.getFullYear();
        const month = String(value.getMonth() + 1).padStart(2, "0");
        const day = String(value.getDate()).padStart(2, "0");
        return `${year}-${month}-${day}`;
      }
      const text = String(value).trim();
      if (!text) {
        return null;
      }
      const slashDate = text.match(/^(\d{4})\/(\d{1,2})\/(\d{1,2})/);
      if (slashDate) {
        return `${slashDate[1]}-${slashDate[2].padStart(2, "0")}-${slashDate[3].padStart(2, "0")}`;
      }
      const hyphenDate = text.match(/^(\d{4})-(\d{1,2})-(\d{1,2})(?:T.*)?$/);
      if (hyphenDate) {
        const parsed = text.includes("T") ? new Date(text) : null;
        if (parsed && !Number.isNaN(parsed.getTime())) {
          const year = parsed.getFullYear();
          const month = String(parsed.getMonth() + 1).padStart(2, "0");
          const day = String(parsed.getDate()).padStart(2, "0");
          return `${year}-${month}-${day}`;
        }
        return `${hyphenDate[1]}-${hyphenDate[2].padStart(2, "0")}-${hyphenDate[3].padStart(2, "0")}`;
      }
      return text;
    },
    getMachineSchemaFieldKeys() {
      const fields = this.getMasterRecordList?.schema?.model?.fields;
      return fields ? Object.keys(fields).filter(key => key !== "$modalType") : null;
    },
    isMachineDateField(key) {
      const fields = this.getMasterRecordList?.schema?.model?.fields || {};
      return fields?.[key]?.type === "date" || ["settingDate", "deleteDate"].includes(key);
    },
    sanitizeMachineCompareRecord(record) {
      const clone = clonePlain(record);
      const ignore = new Set(["$modalType", "_defaultId", "_events", "_handlers", "dirty", "dirtyFields", "edited", "operation", "parent", "skipSearch", "sortInputTime", "uid", "upDate", "dummy"]);
      const keyList = this.getMachineSchemaFieldKeys() || Object.keys(clone).filter(key => !ignore.has(key));
      return keyList.reduce((acc, key) => {
        if (!ignore.has(key)) {
          acc[key] = this.isMachineDateField(key)
            // Kendo の Date は JSON clone 後に別形式へ変わるため、日付項目は元 record から直接比較値を作る。
            ? this.machineCompareDateValue(record?.[key])
            : clone[key] === "" || clone[key] === undefined || clone[key] === "[]" ? null : clone[key];
        }
        return acc;
      }, {});
    },
    isSameMachineRecord(currentRecord, originalRecord) {
      const current = this.sanitizeMachineCompareRecord(currentRecord);
      const original = this.sanitizeMachineCompareRecord(originalRecord);
      const keys = new Set([...Object.keys(current), ...Object.keys(original)]);
      for (const key of keys) {
        if (!this.machineCompareValuesEqual(current[key], original[key])) {
          return false;
        }
      }
      return true;
    },
    isMachineRecordChangedFromSnapshot(record) {
      const original = this.findMachineOriginalRecord(record);
      return original ? !this.isSameMachineRecord(record, original) : false;
    },
    isMachineSortRankChangedFromSnapshot(record) {
      const original = this.findMachineOriginalRecord(record);
      return original ? !this.machineCompareValuesEqual(record.sortRank, original.sortRank) : false;
    },
    isMachineNonSortRecordChangedFromSnapshot(record) {
      const original = this.findMachineOriginalRecord(record);
      if (!original) {
        return false;
      }
      const currentWithoutSort = clonePlain(record);
      const originalWithoutSort = clonePlain(original);
      currentWithoutSort.sortRank = originalWithoutSort.sortRank;
      currentWithoutSort.sortInputTime = originalWithoutSort.sortInputTime;
      return !this.isSameMachineRecord(currentWithoutSort, originalWithoutSort);
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
      if (!this.directGridSortEditedCodes) {
        this.directGridSortEditedCodes = markRaw(new Set());
      }
      edited ? this.directGridSortEditedCodes.add(key) : this.directGridSortEditedCodes.delete(key);
    },
    isDirectGridSortManuallyEdited(record) {
      const key = this.getDirectGridRecordKey(record);
      return !!key && !!this.directGridSortEditedCodes?.has?.(key);
    },
    clearMachineRowPendingEdit(record) {
      if (!record || typeof record !== "object") {
        return;
      }
      ["operation", "edited", "dirty", "dirtyFields"].forEach(key => {
        if (Object.prototype.hasOwnProperty.call(record, key)) {
          delete record[key];
        }
      });
    },
    markMachineRowPendingEdit(record) {
      if (!record || typeof record !== "object") {
        return;
      }
      if (!this.isDirectGridAddedRecord(record)) {
        record.operation = 2;
      }
      record.edited = true;
    },
    getDirectGridModelPlain(model, overrides = {}) {
      const plain = typeof model?.toJSON === "function" ? model.toJSON() : clonePlain(model || {});
      Object.keys(overrides || {}).forEach(key => {
        plain[key] = overrides[key];
      });
      return plain;
    },
    findMasterRecordByCode(code) {
      if (code === undefined || code === null || !Array.isArray(this.getMasterRecordList?.data)) {
        return null;
      }
      return this.getMasterRecordList.data.find(record => String(record.code) === String(code)) || null;
    },
    updateDirectMasterRecordFromModel(model, overrides = {}) {
      const plain = this.getDirectGridModelPlain(model, overrides);
      const target = this.findMasterRecordByCode(plain.code);
      if (!target) {
        return plain;
      }
      const internalKeys = new Set(["uid", "_events", "_handlers", "parent", "dirty", "dirtyFields"]);
      Object.keys(plain).forEach(key => {
        if (!internalKeys.has(key)) {
          target[key] = plain[key];
        }
      });
      if (this.isSortMode && Object.prototype.hasOwnProperty.call(overrides, "sortRank")) {
        target.sortInputTime = Object.prototype.hasOwnProperty.call(overrides, "sortInputTime") ? overrides.sortInputTime : Date.now();
      }
      if (this.isDirectGridAddedRecord(target) || this.isMachineNonSortRecordChangedFromSnapshot(target) || this.isDirectGridSortManuallyEdited(target)) {
        this.markMachineRowPendingEdit(target);
      } else {
        this.setDirectGridSortManuallyEdited(target, false);
        this.clearMachineRowPendingEdit(target);
      }
      return target;
    },
    applyDirectGridRowBackgroundOnly(record, preferredUid = null, resolvedRows = null) {
      this.applyDirectGridRowVisualState(record, preferredUid, resolvedRows);
    },
    flushDirectGridPendingSaveVisual() {
      const pending = this.directGridPendingSaveVisual;
      if (!pending) {
        return;
      }
      this.directGridPendingSaveVisual = null;
      if (this.directGridPendingSaveVisualTimer != null) {
        clearTimeout(this.directGridPendingSaveVisualTimer);
        this.directGridPendingSaveVisualTimer = null;
      }
      const { record, preferredUid } = pending;
      if (!record) {
        return;
      }
      const applyBold = () => {
        const rows = this.getDirectGridRowsByRecord(record, preferredUid);
        if (!rows.length) {
          return;
        }
        this.applyDirectGridRowVisualState(record, preferredUid, rows);
      };
      requestAnimationFrame(() => {
        requestAnimationFrame(applyBold);
      });
    },
    onDirectGridCellClose(ev) {
      this.clearValidationTooltipPlacementTimers();
      this.stopValidationTooltipPlacementWatch();
      const closedCell = ev?.container?.[0] || ev?.container;
      if (closedCell?.classList) {
        closedCell.classList.remove("ntss-validation-above");
        this.resetValidationTooltipCalloutDirection(closedCell);
      }
      this.clearValidationTooltipPlacementState();
      this.flushDirectGridPendingSaveVisual();
    },
    applyDirectGridRowVisualState(record, preferredUid = null, resolvedRows = null) {
      const rows = resolvedRows || this.getDirectGridRowsByRecord(record, preferredUid);
      if (!rows.length || !record) {
        return;
      }
      this.clearDirectGridRowVisualState(rows);
      const deleted = this.isDirectGridDeletedRecord(record);
      const changed = this.isDirectGridRecordVisuallyChanged(record);
      const sortChanged = this.isDirectGridSortManuallyEdited(record) || (this.isSortMode && this.isMachineSortRankChangedFromSnapshot(record));
      if (!changed && !deleted && !sortChanged) {
        return;
      }
      const sortRankIndex = this.getDirectGridColumnIndex("sortRank");
      const dummyIndex = this.getDirectGridColumnIndex("dummy");
      rows.forEach(row => {
        if (deleted) {
          row.classList.add("master-deleted-row", "deleted-bg");
          Array.from(row.children || []).forEach(cell => {
            cell.classList.add("master-deleted-row", "deleted-bg");
          });
        }
        if (changed) {
          row.classList.add("k-dirty-row", "master-edited-row", "edited-bg");
          const isLockedRow = !!row.closest?.(".k-grid-content-locked");
          if (isLockedRow) {
            const cells = Array.from(row.children || []);
            cells.forEach(cell => {
              const colIndex = Number(cell.getAttribute("aria-colindex")) - 1;
              const effectiveIndex = Number.isFinite(colIndex) ? colIndex : cells.indexOf(cell);
              if (effectiveIndex !== dummyIndex && effectiveIndex !== sortRankIndex) {
                cell.classList.add("master-edited-row");
              }
            });
          } else {
            Array.from(row.children || []).forEach(cell => {
              cell.classList.add("master-edited-row");
            });
          }
        }
      });
      if (changed) {
        this.syncDirectGridDirtyCellMarkersForRecord(record, preferredUid, rows);
        this.applyDirectGridChangeEditColor(rows);
        this.applyDirectGridEditBoldFromDirtyCells(rows);
      }
      if (sortChanged) {
        if (this.isSortMode) {
          // 並び順表示中は「並び順」列そのものを黄色にする。
          this.getDirectGridCellsByField(rows, "sortRank").forEach(cell => cell.classList.add("k-dirty-cell", "master-sort-edited"));
        } else {
          // 通常表示では左側の目印列のみ黄色にする。
          this.getDirectGridCellsByField(rows, "dummy").forEach(cell => cell.classList.add("k-dirty-cell", "master-sort-edited"));
          rows.forEach(row => {
            const isLockedRow = !!row?.closest?.(".k-grid-content-locked");
            if (!isLockedRow) {
              return;
            }
            const leftCell = row?.children?.[0];
            if (leftCell) {
              leftCell.classList.add("k-dirty-cell", "master-sort-edited");
            }
          });
        }
      }
    },
    buildDirectGridRowsByCodeMap() {
      const result = new Map();
      const root = this.$refs.gridRoot;
      const grid = this.directGridWidget;
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
    scheduleDirectGridDirtyVisualRefresh() {
      if (this.directGridEditVisualRafId != null) {
        cancelAnimationFrame(this.directGridEditVisualRafId);
      }
      this.directGridEditVisualRafId = requestAnimationFrame(() => {
        this.directGridEditVisualRafId = null;
        this.applyDirectGridLegacyStyleContract();
      });
    },
    getDirectGridSchemaFields() {
      return (
        this.directGridDataSource?.schema?.model?.fields ||
        this.getMasterRecordList?.schema?.model?.fields ||
        {}
      );
    },
    isDirectGridComboField(fieldName) {
      if (!fieldName) {
        return false;
      }
      const column = (this.columns || []).find(item => item.field === fieldName);
      return !!column?.values;
    },
    getDirectGridComboDisplayText(fieldName, value) {
      const column = (this.columns || []).find(item => item.field === fieldName);
      const matched = (column?.values || []).find(item => String(item?.value) === String(value));
      return matched?.text ?? (value == null || value === "" ? "" : String(value));
    },
    readDirectGridEditorValue(container, fieldName = null, model = null) {
      if (fieldName && this.isDirectGridComboField(fieldName)) {
        return resolveGridEditorDropDownListSaveValue(fieldName, { container, model }, this.getDirectGridSchemaFields());
      }
      const input = container?.querySelector?.("input");
      if (!input) {
        return undefined;
      }
      const value = input.value;
      const numeric = Number(value);
      return value !== "" && !Number.isNaN(numeric) ? numeric : value;
    },
    clearKendoModelDirtyFlags(model) {
      if (!model) {
        return;
      }
      model.dirty = false;
      model._dirty = false;
      ["dirtyFields", "_dirtyFields"].forEach(fieldName => {
        const fields = model[fieldName];
        if (fields && typeof fields === "object") {
          Object.keys(fields).forEach(key => delete fields[key]);
        }
      });
    },
    syncDirectGridModelDirtyState(model, record) {
      if (!model || !record) {
        return;
      }
      if (this.isDirectGridAddedRecord(record)) {
        this.clearKendoModelDirtyFlags(model);
        return;
      }
      if (this.isMachineNonSortRecordChangedFromSnapshot(record) || this.isDirectGridSortManuallyEdited(record)) {
        return;
      }
      this.clearKendoModelDirtyFlags(model);
    },
    markDirectGridDirtyCellsForFields(record, fieldNames = [], preferredUid = null, resolvedRows = null) {
      if (!record || !Array.isArray(fieldNames) || fieldNames.length === 0) {
        return;
      }
      const rows = resolvedRows || this.getDirectGridRowsByRecord(record, preferredUid);
      if (!rows.length) {
        return;
      }
      const targetFields = [...new Set(
        fieldNames.filter(fieldName => fieldName && fieldName !== "dummy" && fieldName !== "sortRank")
      )];
      if (!targetFields.length) {
        return;
      }
      const markedCells = new Set();
      const markCell = (cell, fieldName = null) => {
        if (!cell || markedCells.has(cell)) {
          return;
        }
        markedCells.add(cell);
        this.markDirectGridDirtyCell(cell, fieldName);
      };
      rows.forEach(row => {
        Array.from(row.children || []).forEach(cell => {
          const cellField = this.getDirectGridFieldFromCell(cell);
          if (cellField && targetFields.includes(cellField)) {
            markCell(cell, cellField);
          }
        });
      });
      targetFields.forEach(fieldName => {
        this.findDirectGridCellsForRecordField(record, fieldName, preferredUid, rows).forEach(cell => {
          markCell(cell, fieldName);
        });
      });
      targetFields.forEach(fieldName => {
        rows.forEach(row => {
          const cell = this.getDirectGridCellByFieldInRow(row, fieldName, record);
          markCell(cell, fieldName);
        });
      });
    },
    getDirectGridFieldFromCell(cell) {
      const element = cell?.nodeType === 1 ? cell : cell?.[0];
      if (!element) {
        return null;
      }
      const containerFor = element.getAttribute?.("data-container-for");
      if (containerFor) {
        const fieldName = String(containerFor).split(/[;,]/)[0]?.trim();
        if (fieldName && fieldName !== "dummy") {
          return fieldName;
        }
      }
      const dataField = element.getAttribute?.("data-field");
      if (dataField) {
        return dataField;
      }
      const row = element.closest?.("tr[data-uid]");
      if (row) {
        const locked = !!row.closest?.(".k-grid-content-locked");
        const domColumns = this.getDirectGridDomColumns(locked);
        const cellIndex = Array.from(row.children || []).indexOf(element);
        const fieldFromDom = domColumns[cellIndex]?.field;
        if (fieldFromDom) {
          return fieldFromDom;
        }
        for (const column of this.columns || []) {
          const fieldName = column?.field;
          if (!fieldName || fieldName === "sortRank" || column.hidden) {
            continue;
          }
          if (this.findDirectGridCellForField(row, fieldName) === element) {
            return fieldName;
          }
        }
      }
      return null;
    },
    getDirectGridFieldFromEvent(ev) {
      const activeField = ev?.sender?.editable?.options?.field
        || ev?.sender?.editable?.options?.fields?.field;
      if (activeField && activeField !== "dummy") {
        return activeField;
      }
      const fromCell = this.getDirectGridFieldFromCell(ev?.container?.[0] || ev?.container);
      if (fromCell && fromCell !== "dummy") {
        return fromCell;
      }
      const fromGrid = getGridEditFieldFromEvent(ev, this.columns);
      return fromGrid && fromGrid !== "dummy" ? fromGrid : null;
    },
    onDirectGridEdit(ev) {
      if (this.isMobileDevice && !this.allowEdit) {
        ev?.preventDefault?.();
        return;
      }
      const grid = ev?.sender || this.directGridWidget;
      bindGridEditorEnterToCloseCell(grid, ev?.container);
      const field = this.getDirectGridFieldFromEvent(ev);
      this.rememberDirectGridDirtyCellFromEvent(ev, field);
      const cell = ev?.container?.[0] || ev?.container;
      if (!field || !cell) {
        return;
      }
      this.applyDirectGridEditorValidationMessage(cell, field);
      this.scheduleValidationTooltipPlacement();
      if (this.isDirectGridComboField(field)) {
        bindGridEditorDropDownListToCloseCell(grid, ev?.container);
        const onComboValueChange = () => {
          const value = this.readDirectGridEditorValue(cell, field, ev?.model);
          if (value === undefined) {
            return;
          }
          if (ev?.model) {
            ev.model.__ntssComboSave = { field, value };
          }
          const visualRecord = this.getDirectGridModelPlain(ev.model, { [field]: value });
          this.markDirectGridEditedField(visualRecord, field);
        };
        const bindComboEditedField = () => {
          const widget = getGridEditorDropDownListWidget(cell);
          if (!widget) {
            return;
          }
          widget.bind?.("select", onComboValueChange);
          widget.bind?.("change", onComboValueChange);
        };
        bindComboEditedField();
        const ownerWindow = cell?.ownerDocument?.defaultView || window;
        ownerWindow.setTimeout(bindComboEditedField, 0);
        const comboInputs = Array.from(
          cell.querySelectorAll?.("input:not([type='hidden']), select") || []
        );
        const onComboValidationPlacement = () => {
          this.scheduleValidationTooltipPlacement();
        };
        comboInputs.forEach((comboInput) => {
          comboInput.addEventListener("blur", onComboValidationPlacement, { passive: true });
          comboInput.addEventListener("invalid", onComboValidationPlacement, { passive: true });
        });
        return;
      }
      const input = cell?.querySelector?.("input");
      if (!input) {
        return;
      }
      const onValidationPlacement = () => {
        this.scheduleValidationTooltipPlacement();
      };
      input.addEventListener("blur", onValidationPlacement, { passive: true });
      input.addEventListener("invalid", onValidationPlacement, { passive: true });
      const onInput = () => {
        const value = this.readDirectGridEditorValue(cell, field, ev?.model);
        const visualRecord = this.getDirectGridModelPlain(ev.model, { [field]: value });
        this.markDirectGridEditedField(visualRecord, field);
        if (this.isSortMode && field === "sortRank") {
          this.setDirectGridSortManuallyEdited(visualRecord, this.isMachineSortRankChangedFromSnapshot(visualRecord));
        }
      };
      input.addEventListener("input", onInput, { passive: true });
      // 変色タイミングは blur(save) 後に統一する。
      // 編集中は preview 着色を行わない。
    },
    onDirectGridSave(ev) {
      const field = this.resolveDirectGridSaveField(ev);
      const container = ev?.container?.[0] || ev?.container;
      const values = { ...(ev?.values || {}) };
      if (field && !Object.prototype.hasOwnProperty.call(values, field)) {
        const value = this.readDirectGridEditorValue(container, field, ev?.model);
        if (value !== undefined) {
          values[field] = value;
        } else if (ev?.model) {
          values[field] = typeof ev.model.get === "function" ? ev.model.get(field) : ev.model[field];
        }
      }
      const savedFields = field ? [...new Set([...Object.keys(values || {}), field])] : Object.keys(values || {});
      if (this.isSortMode && Object.prototype.hasOwnProperty.call(values, "sortRank")) {
        const modelPlain = this.getDirectGridModelPlain(ev?.model, values);
        const original = this.findMachineOriginalRecord(modelPlain);
        const sortBackToOriginal = original && this.machineCompareValuesEqual(modelPlain.sortRank, original.sortRank);
        values.sortInputTime = sortBackToOriginal ? original.sortInputTime : Date.now();
        if (typeof ev?.model?.set === "function") {
          ev.model.set("sortInputTime", values.sortInputTime);
        } else if (ev?.model) {
          ev.model.sortInputTime = values.sortInputTime;
        }
      }
      const preferredUid = ev?.model?.uid;
      const updatedRecord = this.updateDirectMasterRecordFromModel(ev?.model, values);
      this.reconcileDirectGridEditedFields(updatedRecord, savedFields);
      if (this.isSortMode && Object.prototype.hasOwnProperty.call(values, "sortRank")) {
        this.setDirectGridSortManuallyEdited(updatedRecord, this.isMachineSortRankChangedFromSnapshot(updatedRecord));
      }
      if (this.isDirectGridAddedRecord(updatedRecord) || this.isMachineNonSortRecordChangedFromSnapshot(updatedRecord) || this.isDirectGridSortManuallyEdited(updatedRecord)) {
        this.markMachineRowPendingEdit(updatedRecord);
      } else {
        this.setDirectGridSortManuallyEdited(updatedRecord, false);
        this.clearMachineRowPendingEdit(updatedRecord);
      }
      this.syncDirectGridModelDirtyState(ev?.model, updatedRecord);
      if (this.isDirectGridAddedRecord(updatedRecord) && field && this.isDirectGridComboField(field)) {
        const displayText = this.getDirectGridComboDisplayText(field, values[field]);
        commitDirectGridAddedRowDropDownCell(
          this.directGridWidget,
          container,
          field,
          displayText
        );
      }
      this.directGridPendingSaveVisual = {
        record: updatedRecord,
        preferredUid,
        savedFields,
        field
      };
      this.applyDirectGridRowVisualState(updatedRecord, preferredUid);
      if (this.directGridPendingSaveVisualTimer != null) {
        clearTimeout(this.directGridPendingSaveVisualTimer);
      }
      this.directGridPendingSaveVisualTimer = setTimeout(() => {
        this.flushDirectGridPendingSaveVisual();
      }, 120);
      this.editComFormatCd();
    },
    scheduleDirectGridRowVisualRefresh(record, preferredUid = null, model = null) {
      const rowKey = preferredUid || record?.code || "__unknown__";
      if (!this.directGridRowVisualRafIds) {
        this.directGridRowVisualRafIds = markRaw(new Map());
      }
      const oldRaf = this.directGridRowVisualRafIds.get(rowKey);
      if (oldRaf != null) {
        cancelAnimationFrame(oldRaf);
      }
      const rafId = requestAnimationFrame(() => {
        requestAnimationFrame(() => {
          this.directGridRowVisualRafIds?.delete(rowKey);
          this.syncDirectGridModelDirtyState(model, record);
          this.applyDirectGridRowVisualState(record, preferredUid);
          const rows = this.getDirectGridRowsByRecord(record, preferredUid);
          const fieldsToMark = this.getDirectGridDirtyFieldNames(record);
          this.markDirectGridDirtyCellsForFields(record, fieldsToMark, preferredUid, rows);
          this.applyDirectGridEditBoldFromDirtyCells(rows);
        });
      });
      this.directGridRowVisualRafIds.set(rowKey, rafId);
    },
    syncDirectGridDataFromStore() {
      const grid = this.directGridWidget;
      if (!grid?.dataSource) {
        return;
      }
      try {
        grid.dataSource.data(this.getDirectGridDisplayData());
      } catch (_error) {
        // noop
      }
    },
    buildDirectGridColumns() {
      return this.columns.map(column => {
        const gridColumn = {
          title: column.title,
          field: column.field,
          hidden: !!column.hidden,
          locked: !!column.locked,
          editable: column.editable,
          width: this.normalizeDirectGridColumnWidth(column.width),
          format: column.format,
          values: column.values || null
        };
        if (column.field === "port") {
          gridColumn.editor = this.editorInput;
        }
        if (column.field === "$modalType") {
          gridColumn.attributes = { class: "btn3-kendo-normal" };
          gridColumn.command = { text: "詳細", click: event => this.showMasterEditModal(event) };
          delete gridColumn.values;
        }
        return gridColumn;
      });
    },
    createDirectDataSource() {
      // Vue2 wrapper は :data-source の data/schema/model/validation をそのまま Kendo に渡していた。
      // direct jq でも DataSource option は JSON clone せず、schema / model / validation の参照を保持する。
      const sourceConfig = { ...(this.directGridDataSource || {}) };
      sourceConfig.data = this.getDirectGridDisplayData();
      if (kendo?.data?.DataSource) {
        return markRaw(new kendo.data.DataSource(sourceConfig));
      }
      return sourceConfig;
    },
    initDirectGridIfReady() {
      if (!this.directGridMounted || this.columns.length <= 1 || !this.directGridDataSource || !this.$refs.gridRoot) {
        return;
      }
      installComponentJQuery();
      this.destroyDirectGrid();
      const $gridRoot = $(this.$refs.gridRoot);
      this.applyDirectGridLegacyShellClasses();
      const options = {
        dataSource: this.createDirectDataSource(),
        editable: true,
        selectable: true,
        reorderable: false,
        height: this.kendoGridHeight,
        scrollable: true,
        columns: this.buildDirectGridColumns(),
        beforeEdit: (ev) => {
          if (this.isMobileDevice && !this.allowEdit) {
            ev?.preventDefault?.();
          }
        },
        edit: this.onDirectGridEdit,
        save: this.onDirectGridSave,
        cellClose: this.onDirectGridCellClose,
        dataBound: () => {
          this.directGridReady = true;
          this.applyDirectGridLegacyStyleContract();
          this.bindGridScrollSync();
          this.refreshDirectGridDirtyVisualState();
          this.editComFormatCd();
          this.scheduleDirectGridPostLayoutRefresh();
          this.setLoadingScreenVisible(false);
          if (this.__pendingScrollLeftReset) {
            this.__pendingScrollLeftReset = false;
            const resetHorizontalScroll = () => this.resetDirectGridHorizontalScroll();
            resetHorizontalScroll();
            this.$nextTick(() => {
              resetHorizontalScroll();
              requestAnimationFrame(resetHorizontalScroll);
              [0, 32, 80].forEach((ms) => setTimeout(resetHorizontalScroll, ms));
            });
          }
        }
      };
      $gridRoot.kendoGrid(options);
      this.directGridWidget = markRaw($gridRoot.data("kendoGrid"));
      this.applyDirectGridLegacyShellClasses();
      this.bindGridScrollSync();
      this.scheduleDirectGridPostLayoutRefresh();
      if (!this.directGridWidget) {
        this.setLoadingScreenVisible(false);
      }
    },
    destroyDirectGrid() {
      this.unbindGridScrollSync();
      const grid = this.directGridWidget;
      if (grid) {
        try {
          grid.destroy();
        } catch (_error) {
          // noop
        }
      }
      if (this.$refs.gridRoot) {
        $(this.$refs.gridRoot).empty();
      }
      this.directGridWidget = null;
      this.directGridReady = false;
    },

    // 装置マスタ 障害対応 編集してない状態で「マスタ編集（装置マスタ）」ボタンを押下するとメッセージが表示される start
    refresh() {
      // 他の画面に遷移したときもrefresh()が発生する為、自分の画面のみ処理する
      if (
        this.selfScreenName === this.getCurrentRouteName() &&
        document.getElementsByTagName("ons-alert-dialog").length === 0) {
        if (this.isChanged) {
          this.$ons.notification.confirm({
            title: DIALOG_MESSAGES[12000014].title,
            // add 全マスタメッセージ調整 王 start
            // message: "編集内容が破棄されます。</br>よろしいですか？",
            message: DIALOG_MESSAGES[12000014].message,
            // add 全マスタメッセージ調整 王 end
            callback: (answer) => {
              if (answer === 1) {
                this.loadGridData();
              }
            },
          });
        } else {
          this.loadGridData();
        }
      }
    },
    // 装置マスタ 障害対応 編集してない状態で「マスタ編集（装置マスタ）」ボタンを押下するとメッセージが表示される end
    async systemUseSetting() {
      if (this.facilitylistValue) {
        // 施設のシステム利用設定を取得する
        const mstFacilityHash = await sendRequestGetMstFacilityHashByFacilityCd(
          this.facilitylistValue
        );
        this.facilitySysUseSetting = mstFacilityHash.data.systemUseSetting
          ? mstFacilityHash.data.systemUseSetting
          : "";
      } else {
        this.facilitySysUseSetting = "";
      }
    },
    // マスタ一覧のデータを取得
    findList() {
      // システム利用設定取得処理
      this.systemUseSetting();
      // 選択中の施設コードをStoreに保存する
      this.setSelectedFacilityCd(this.facilitylistValue);
      // apiをコールして既存の装置マスタから条件送信済み～治療中の装置を取得
      this.sendRequestGetDialysisState(this.facilitylistValue).then(
        (response) => {
          this.setEntryMachineList(response.data);
        }
      );
      // apiをコールして型式マスタ、デバイスエッジの値を取得
      this.getComboRecordList(this.facilitylistValue).then(() => {
        // apiをコールして値を取得
        this.findRecordListByFacilityCd(this.facilitylistValue)
          .then((response) => {
            // 編集前初期値を保存
            this.preEditMasterRecordList = deepCopy(this.getMasterRecordList);
            this.dbBeforeData = clonePlain(this.getMasterRecordList?.data || []);
            this.directGridDataSource = markRaw(response.data.localDataSource || {});
            // editableをKendoUI用にfunctionオブジェクトに変換
            const toFunction = response.data.columns;
            toFunction.forEach((column) => {
              // 初期表示時の編集可否を退避
              column.originalEditable = column.editable;
              // 編集可否を関数化
              column.editable = column.editable ? () => true : () => false;
              // 列幅初期化
              column["width"] = column.width ? column.width : "0";
            });
            // 型式コンボボックス用データ取得
            const machineTypeList = this.getMachineTypeList;
            // デバイスエッジコンボボックス用データ取得
            const deviceEdgeList = this.getDeviceEdgeList;
            // 通信種別コンボボックス用データ取得
            const comTypeList = this.getComTypeList;
            toFunction.forEach((column) => {
              // 型式コンボ用データを追加
              if (column.field === "machineTypeCd") {
                column.values = machineTypeList;
              }
              // デバイスエッジコンボ用データを追加
              if (column.field === "deviceEdgeNo") {
                column.values = deviceEdgeList;
              }
              // 通信種別コンボ用データを追加
              if (column.field === "comType") {
                column.values = comTypeList;
              }
            });

            this.columns = toFunction.filter(function (col) {
              return col;
            });
            this.applyMachineSchemaValidationMessages(
              this.directGridDataSource?.schema || this.getMasterRecordList?.schema
            );

            // 横スクロールバーを表示するために列幅を指定
            this.columns.forEach((column) => {
              // 「削除」のプルダウンが改行しない幅に調整
              // mod #7289-マスタの削除ボタンが縦表示になる 徐博 start
              column.width =
                column.field === "isDisp" ? "9em" : this.columnWidth + "em";
              // mod #7289-マスタの削除ボタンが縦表示になる 徐博 end
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
              values: null,
            });
            // ReMsの場合、装置ビューア使用を非表示
            if (this.facilitySysUseSetting === "1") {
              this.columns.forEach((column) => {
                if (column.field === "isVa") {
                  column.hidden = true;
                }
              });
            }
            // #9275 装置マスタの並び順が保存できない linjunfeng start
            // 初期データ内容を保存
            this.setComparisonRecordModel();
            // #9275 装置マスタの並び順が保存できない linjunfeng end
            // カラム幅等初期調整
            this.showSortColumn();
            this.$nextTick(() => {
              this.calculateGridHeight();
              this.initDirectGridIfReady();
              this.scheduleDirectGridPostLayoutRefresh();
              this.restoreDirectGridScrollPosition();
              setTimeout(() => {
                this.lastScrollTop = 0;
                this.lastScrollLeft = 0;
                this.lastscrollTop = 0;
                this.lastscrollLeft = 0;
              }, 1000);
            });
          })
          .catch((error) => {
            //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
            getErrorMessage(
              "MstMachineMainComponent.vue",
              "findList",
              "指定されたマスタが見つかりません。"
            );
            //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
            if (error.response?.status === 400) {
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
      });
      // カラム定義情報を取得
      this.findColumnInfo();
    },
    //#8918 ポート 整数を制限します 张博 start
    editorInput(container, data) {
      $(`<input class="k-numerictextbox" name="${data.field}"/>`)
        .appendTo(container)
        .kendoNumericTextBox({
          //整数を制限します
          max: 65535,
          min: 0,
          decimals: 0,
          format: "n0",
          restrictDecimals: true,
        });
    },
    //#8918 ポート 整数を制限します 张博 end
    // 施設一覧のデータを取得
    findFacilityList() {
      // 日機装ユーザ以外の場合
      if (this.getStateUserAccountInfo.userType !== 1) {
        // ログイン者の担当施設を選択（初期値は自分の所属する施設）
        this.facilitylistValue = this.getStateUserAccountInfo.facilityCd;
        // 選択した施設を元に装置一覧の取得
        this.findList();
        return;
      }
      // apiをコールして施設一覧を取得
      this.facilityList()
        .then(() => {
          // ログイン者の担当施設を選択
          this.facilitylistValue = this.getStateUserAccountInfo.facilityCd;
          // 選択した施設を元に装置一覧の取得
          this.findList();
        })
        .catch((error) => {
          if (error.response?.status === 400) {
            //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
            getErrorMessage(
              "MstMachineMainComponent.vue",
              "findFacilityList",
              "指定されたマスタが見つかりません。"
            );
            //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
            this.$ons.notification.alert({
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
              // title: "取得失敗",
              // message: "指定されたマスタが見つかりません。"
              title: DIALOG_MESSAGES[12000003].title,
              message: messageFormat(DIALOG_MESSAGES[12000003].message),
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
            });
          }
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
          else {
            getErrorMessage(
              "MstMachineMainComponent.vue",
              "findFacilityList",
              error
            );
          }
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
        });
    },
    onOpenFacility(e) {
      // 変更前の値を取得
      this.prevFacilityCd = e.sender._old;
    },
    // 施設を選択時の動作
    onChangeFacility(e) {
      if (this.prevFacilityCd != e.sender._old) {
        if (this.isChanged) {
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
            callback: (answer) => {
              if (answer === 1) {
                // 選択した施設を元に装置一覧の取得
                this.facilitylistValue = newFacilityCd;
                this.findList();
              } else {
                // 変更前の施設を設定する
                this.facilitylistValue = this.prevFacilityCd;
              }
            },
          });
        } else {
          // 選択した施設を元に装置一覧の取得
          this.facilitylistValue = e.sender._old;
          this.findList();
        }
      }
    },
    // 指定したデバイスエッジとのマスタ同期
    synchroMstMachineToDeviceEdge(list, idx) {
      // mod #6107 2023/04/04 メッセージボックス全調整 林峻峰 start
      // let title = "装置マスタ同期";
      let title = messageFormat(
        DIALOG_MESSAGES["00100009"].title,
        "装置マスタ"
      );
      // mod #6107 2023/04/04 メッセージボックス全調整 林峻峰 end
      const infos = list;
      if (!infos || infos.length <= idx) {
        // 共通ローダー：表示終了
        this.setLoadingScreenVisible(false);
        this.resetLoadingScreenVisibleCount();
        this.$ons.notification.alert({
          title: DIALOG_MESSAGES[12000004].title,
          message: messageFormat(DIALOG_MESSAGES[12000004].message),
        });
        return;
      }
      const info = infos[idx];
      // マスタ同期
      this.synchroMstMachine({
        deviceEdgeNo: info.value,
        facilityCd: this.facilitylistValue,
      })
        .then(() => {
          if (infos.length === idx + 1) {
            //共通ローダー：表示終了
            this.setLoadingScreenVisible(false);
            this.resetLoadingScreenVisibleCount();
            // mod デバイスエッジのいずれか同期失敗であれば、同期中止問題の対応。 劉 start
            if (this.errorName.length > 0) {
              let name = "";
              this.errorName.forEach((e) => {
                name = name + e.text + "</br>";
              });
              name = "デバイスエッジ：</br>" + name + "</br>";
              this.$ons.notification.alert({
                title: title,
                // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
                // message:
                //   name +
                //   "との同期に失敗しました。<br>デバイスエッジの装置と整合性が<br>取れていないので<br>再度「保存」を行ってください。"
                message: messageFormat(DIALOG_MESSAGES[12000333].message, name),
                // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
              });
            } else {
              this.$ons.notification.alert({
                title: title,
                // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
                // message: "マスタ同期が完了しました。"
                message: messageFormat(DIALOG_MESSAGES["00100009"].message),
                // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
              });
            }
            this.errorName = [];
            // mod デバイスエッジのいずれか同期失敗であれば、同期中止問題の対応。 劉 end
          } else {
            // 次のデバイスエッジ
            this.synchroMstMachineToDeviceEdge(list, idx + 1);
          }
        })
        .catch((error) => {
          getErrorMessage("MstMachineMainComponent.vue", "synchroMstMachineToDeviceEdge", error);

          const deviceEdgeName = info && info.text ? info.text : "デバイスエッジ";
          getErrorMessage(
            "MstMachineMainComponent.vue",
            "synchroMstMachineToDeviceEdge",
            deviceEdgeName +
              "との同期に失敗しました。デバイスエッジの装置と整合性が取れていないので再度「保存」を行ってください。"
          );

          this.errorName.push(info);
          if (infos.length === idx + 1) {
            let name = "";
            this.errorName.forEach((e) => {
              name = name + e.text + "</br>";
            });
            name = "デバイスエッジ：</br>" + name + "</br>";
            //共通ローダー：表示終了
            this.setLoadingScreenVisible(false);
            // add/ #12573装置マスタで保存後にマスタ同期中にもかかわらず処理中が消える tianqidong start
            this.resetLoadingScreenVisibleCount();
            // add/ #12573装置マスタで保存後にマスタ同期中にもかかわらず処理中が消える tianqidong end
            this.$ons.notification.alert({
              title: title,
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
              // message:
              //   name +
              //   "との同期に失敗しました。<br>デバイスエッジの装置と整合性が<br>取れていないので<br>再度「保存」を行ってください。"
              message: messageFormat(DIALOG_MESSAGES[12000333].message, name),
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
            });
            this.errorName = [];
          } else {
            // 次のデバイスエッジ
            this.synchroMstMachineToDeviceEdge(list, idx + 1);
          }
        });
    },
    async validCanNotChangeParam(editedRecords) {
      // apiをコールして既存の装置マスタから条件送信済み～治療中の装置を取得
      let ret = [];
      const response = await this.sendRequestGetDialysisState(
        this.facilitylistValue
      );
      if (response.data) {
        // 治療完了前の装置のコード
        const dialysisCodeList = response.data.map((r) => r.machineNo);
        // 編集されたレコードかつ治療完了前の装置のコード
        const editedRecordList = editedRecords.data.filter(
          (r) =>
            r.facilityCd === this.facilitylistValue &&
            r.operation === 2 &&
            dialysisCodeList.includes(r.code)
        );
        // 編集前のレコード
        const editedCodeList = editedRecordList.map((r) => r.code);
        const preEditRecordList = this.preEditMasterRecordList.data.filter(
          (r) =>
            r.facilityCd === this.facilitylistValue &&
            editedCodeList.includes(r.code)
        );
        for (const edited of editedRecordList) {
          const preEdit = preEditRecordList.find((r) => r.code === edited.code);
          if (
            edited.machineSerial !== preEdit.machineSerial || // 製造番号
            edited.machineTypeCd !== preEdit.machineTypeCd || // 型式
            edited.comType !== preEdit.comType || // 通信種別
            edited.comFormatCd !== preEdit.comFormatCd || // 通信フォーマット
            edited.ipAddress !== preEdit.ipAddress || // IPアドレス
            +edited.port !== +preEdit.port || // ポート番号
            edited.deviceEdgeNo !== preEdit.deviceEdgeNo || // デバイスエッジ
            edited.isDisp === "0" || // 削除フラグ
            edited.isDel === "1"
          ) {
            ret.push(`装置名: ${edited.name}`);
          }
        }
      }
      return this.convertToStr(ret);
    },
    buildSwitchOfflineRequest(editedRecords) {
      // 新たにオフライン装置となったレコード
      const newOfflineCodeList = editedRecords.data
        .filter(
          (r) =>
            r.facilityCd === this.facilitylistValue &&
            r.comFormatCd === "F" &&
            r.operation === 2
        )
        .map((r) => r.code);
      // オフラインから新たにオンライン装置となったレコード
      const editedRecordList = editedRecords.data
        .filter(
          (r) =>
            r.facilityCd === this.facilitylistValue &&
            r.comFormatCd !== "F" &&
            r.operation === 2
        )
        .map((r) => r.code);
      const newOnlineCodeList = this.preEditMasterRecordList.data
        .filter(
          (r) =>
            r.facilityCd === this.facilitylistValue &&
            r.comFormatCd === "F" &&
            editedRecordList.includes(r.code)
        )
        .map((r) => r.code);

      return {
        facilityCd: this.facilitylistValue,
        offline: newOfflineCodeList,
        online: newOnlineCodeList,
      };
    },
    buildChangeMachineRequest(editedRecords) {
      // 編集された装置のコード
      const editedRecordList = editedRecords.data.filter(
        (r) => r.facilityCd === this.facilitylistValue && r.operation === 2
      );
      // 編集前のレコード
      const editedCodeList = editedRecordList.map((r) => r.code);
      const preEditRecordList = this.preEditMasterRecordList.data.filter(
        (r) =>
          r.facilityCd === this.facilitylistValue &&
          editedCodeList.includes(r.code)
      );
      let newOfflineAndCommonCodeList = [];
      let changeMachineCodeList = [];

      for (const edited of editedRecordList) {
        const preEdit = preEditRecordList.find((r) => r.code === edited.code);
        if (
          edited.machineSerial !== preEdit.machineSerial || // 製造番号
          edited.comType !== preEdit.comType || // 通信種別
          edited.comFormatCd !== preEdit.comFormatCd // 通信フォーマット
        ) {
          // 装置の変更があった
          changeMachineCodeList.push(edited.code);
          if (
            edited.comFormatCd !== preEdit.comFormatCd &&
            edited.comFormatCd === "F"
          ) {
            // 新たにオフラインになった
            newOfflineAndCommonCodeList.push(edited.code);
          } else if (
            edited.comType !== preEdit.comType &&
            +edited.comType === 3
          ) {
            // 新たに医器工になった
            newOfflineAndCommonCodeList.push(edited.code);
          }
        }
      }

      return {
        facilityCd: this.facilitylistValue,
        newOfflineAndCommonCodeList: newOfflineAndCommonCodeList,
        changeMachineCodeList: changeMachineCodeList,
      };
    },
    async saveRecord() {
      // 共通ローダー:表示開始
      this.setLoadingScreenVisible(true);
      // add #8344 【デグレ】チェックリストマスタの保存までが長い dou start
      this.setLoadingScreenVisible(true);
      this.setLoadingScreenVisible(true);
      // add #8344 【デグレ】チェックリストマスタの保存までが長い dou end
      // add スクロールの位置を維持
      this.storeDirectGridScrollPosition();
      // add スクロールの位置を維持
      try {
        this.directGridWidget?.closeCell?.();
      } catch (_error) {
        // noop
      }
      this.syncDirectGridSortValuesToMasterRecords();
      // グリッドでエラーが発生している場合は処理を中断
      if (!this.validateBeforeSortMode()) {
        //共通ローダー：表示終了
        this.setLoadingScreenVisible(false);
        // add #8580 「マスタの保存時に制限による注意喚起メッセージ後に処理中のまま固まる」について、対応する。 dengshen start
        this.resetLoadingScreenVisibleCount();
        // add #8580 「マスタの保存時に制限による注意喚起メッセージ後に処理中のまま固まる」について、対応する。 dengshen end
        return;
      }

      // 更新前の情報をバックアップ
      this.backupMasterRecordList = JSON.parse(
        JSON.stringify(this.getMasterRecordList)
      );

      // 新規追加＆未入力のレコードを除外
      const records = this.getMasterRecordList;
      records.data = records.data.filter(
        (r) => !(r.operation === 1 && !r.edited)
      );
      this.setMasterRecordList(records);

      // 必須エラーをチェック
      const validateMessage = this.validateRequired();
      // コンボで削除済みのレコードが指定されていないかをチェック
      const validateComboMessage = this.validateComboValue();
      // 型式+製造番号、IPアドレス重複チェック
      const validateMachineInfoMessage = this.validateMachineTypeSerialNo(
        this.isLockDevTool
      );
      const validateCannotEditedValueMessage =
        await this.validCanNotChangeParam(records);

      let message = "";
      if (validateMessage.length !== 0) {
        // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
        // message = "以下の列に未入力項目が存在します。" + validateMessage;
        message =
          messageFormat(DIALOG_MESSAGES[12000270].message) + validateMessage;
        // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
      }
      if (validateComboMessage.length !== 0) {
        if (message.length !== 0) message = message + "</br>";
        message =
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
          // message + "以下の列の選択を見直してください。" + validateComboMessage;
          message +
          messageFormat(DIALOG_MESSAGES[12000006].message) +
          validateComboMessage;
        // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
      }
      if (validateMachineInfoMessage.length !== 0) {
        if (message.length !== 0) message = message + "</br>";
        message =
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
          // message + "以下の項目で問題があります。" + validateMachineInfoMessage;
          message +
          messageFormat(DIALOG_MESSAGES["00200071"].message) +
          validateMachineInfoMessage;
        // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
      }
      if (validateCannotEditedValueMessage.length !== 0) {
        if (message.length !== 0) message = message + "</br>";
        message =
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
          // message + "以下の装置は治療完了前につき変更できない項目が編集されています。" + validateCannotEditedValueMessage;
          message +
          messageFormat(DIALOG_MESSAGES["00200072"].message) +
          validateCannotEditedValueMessage;
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
          message: '<div style="text-align:left;">' + message + "</div>",
        });
        // add #7663 C重複情報のメッセージ画面を表示する。 zhou start
        this.resetLoadingScreenVisibleCount();
        this.restoreDirectGridScrollPosition();
        // add #7663 C重複情報のメッセージ画面を表示する。 zhou end
        return;
      }

      // デバイスエッジ一覧
      //mod #12298 装置通信・仮想端末マスタにてマスタ同期失敗のメッセージに削除済みDEが表示される start
      const deviceEdgeList = this.getDeviceEdgeList.filter(item => item.del !== '1');
      //mod #12298 装置通信・仮想端末マスタにてマスタ同期失敗のメッセージに削除済みDEが表示される end
      const switchOfflineRequest = this.buildSwitchOfflineRequest(records);
      const changeMachineRequest = this.buildChangeMachineRequest(records);
      const updRecLst = this.getUpdateRecordList.map((rec) => {
        rec.machineSerial = rec.machineSerial == null ? "" : String(rec.machineSerial).trim();
        return rec;
      });

      // apiをコールして値を保存
      this.updateRecordListByFacilityCd({
        facilityCd: this.facilitylistValue,
        request: updRecLst,
      })
        .then((response) => {
          this.updateResponse = response.data;

          Promise.all([
            // 新たにオフライン・オンライン装置化したレコードの工程を変更する
            this.updateSwitchOfflineMachineState(switchOfflineRequest),
            this.updateChangeMachineState(changeMachineRequest),
          ]).then(() => {
            this.isSorted = false;
            this.findList();
            // マスタ同期開始
            this.synchroMstMachineToDeviceEdge(deviceEdgeList, 0);
          });
        })
        .catch((error) => {
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
          getErrorMessage("MstMachineMainComponent.vue", "saveRecord", error);
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
          //共通ローダー：表示終了
          this.setLoadingScreenVisible(false);
          // add #7663 C重複情報のメッセージ画面を表示する。 zhou start
          this.resetLoadingScreenVisibleCount();
          // add #7663 C重複情報のメッセージ画面を表示する。 zhou end
          if (error.response?.status === 400) {
            this.$ons.notification.alert({
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
              // title: "更新失敗",
              title: DIALOG_MESSAGES["00300005"].title,
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
              message: error.response.data.errorMessage,
            });
          }
          // 更新前の情報に戻す
          const backups = this.backupMasterRecordList;
          this.setMasterRecordList(backups);

          // グリッドのデータ再表示
          this.gridDataRefresh();
        });
    },
    // 装置名、型式+製造番号、IPアドレス重複チェック
    validateMachineTypeSerialNo(isLockDevTool) {
      let validateMessageArr = [];
      let checkMachineTypeSerialNo = [];
      let checkIpAddress = [];

      // IPアドレス正規表現
      const reg = new RegExp(
        "^(([1-9]?[0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([1-9]?[0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$"
      );

      // 製造番号 正規表現
      const regSerial = new RegExp(/^[a-zA-Z0-9!-/:-@¥[-`{-~]*$/);

      // 削除されていないレコード
      const gridData = this.getMasterRecordList;
      const rows = gridData.data;
      for (let rowIdx = 0; rowIdx < rows.length; rowIdx++) {
        const rowNo = rowIdx + 1;
        // 製造番号取得
        const machineSerial = rows[rowIdx]["machineSerial"];
        // 型式+製造番号取得
        const key = rows[rowIdx]["machineTypeCd"] + "_" + machineSerial;
        // IPアドレス取得
        const ip = rows[rowIdx]["ipAddress"];
        // 削除対象判定
        const del = rows[rowIdx]["isDisp"] === "1" ? "" : "(削除分)";
        // オフラインフラグ
        const isOffline =
          rows[rowIdx]["comFormatCd"] === "" ||
          rows[rowIdx]["comFormatCd"] === "F";
        // 装置名
        const name = rows[rowIdx]["name"];

        // 装置名未入力チェック
        if (!name) {
          let strerr = "装置名未入力：" + rowNo + " 行目";
          validateMessageArr.push(strerr);
        }
        // 製造番号不正文字チェック
        if (
          machineSerial &&
          machineSerial.length > 0 &&
          !regSerial.test(machineSerial)
        ) {
          let strerr = "製造番号不正文字あり：" + rowNo + " 行目" + del;
          validateMessageArr.push(strerr);
        }
        // 型式+製造番号重複チェック
        let idxNo = 1 + checkMachineTypeSerialNo.indexOf(key);
        if (1 <= idxNo) {
          // 重複あり
          let strerr =
            "型式 + 製造番号重複あり：<br>　　　" +
            idxNo +
            "行目と" +
            rowNo +
            "行目" +
            del;
          validateMessageArr.push(strerr);
        }
        checkMachineTypeSerialNo.push(key);

        // IPアドレス形式チェック
        if (ip && ip.length > 0 && !reg.test(ip)) {
          let strerr = "IPアドレス不正：" + rowNo + " 行目" + del;
          validateMessageArr.push(strerr);
        }

        if (!isOffline && rows[rowIdx]["isDisp"] === "1") {
          // 削除分とオフラインはチェック対象外
          if (reg.test(ip) == true) {
            // IPアドレスOK
            // ユーザーフロートボタン赤でない場合、IPアドレス重複チェックを行う

            if (isLockDevTool) {
              idxNo = 1 + checkIpAddress.indexOf(ip);
              if (1 <= idxNo) {
                // 重複あり
                let strerr =
                  "IPアドレス重複あり：<br>　　　" +
                  idxNo +
                  "行目と" +
                  rowNo +
                  "行目" +
                  del;
                validateMessageArr.push(strerr);
              }
              checkIpAddress.push(ip);
            }
          }
        } else {
          checkIpAddress.push("");
        }
      }

      return this.convertToStr(validateMessageArr);
    },
    showMasterEditModal(e) {
      this.storeDirectGridScrollPosition();

      // モーダルを表示
      this.showMasterEdit();

      e.preventDefault();
      const grid = this.directGridWidget;
      const selectedRowItem = grid?.dataItem?.(e.currentTarget.closest("tr"));
      if (!selectedRowItem) {
        return;
      }
      let code = selectedRowItem.code;
      this.setEditCode(code);

      // codeがない場合はcodeを付番
      if (!code) {
        this.edit({ editRecord: selectedRowItem, isSortMode: this.isSortMode });
        this.refreshDirectGridDataFromMasterRecords();
        code = selectedRowItem.code;
      }

      // プロパティを正規化する。
      const normalizedItem = this.normalization(typeof selectedRowItem.toJSON === "function" ? selectedRowItem.toJSON() : selectedRowItem);

      // ストアに保存する。
      this.setEditRecord(normalizedItem);

      // モーダル画面表示用のシステム利用設定を設定
      this.setFacilitySysUseSetting(this.facilitySysUseSetting);
    },
    addRow() {
      try {
        this.directGridWidget?.closeCell?.();
      } catch (_error) {
        // noop
      }
      this.scheduleValidationTooltipPlacement();
      // グリッドでエラーが発生している場合は処理を中断
      if (!this.validateBeforeSortMode()) {
        return;
      }

      // 空レコードをストアに登録
      let d = new Object();
      const fields = this.getMasterRecordList.schema.model.fields;
      Object.keys(fields).forEach((k) => {
        if (fields[k].defaultValue) {
          d[k] = fields[k].defaultValue;
        } else if (fields[k].type === "string") {
          d[k] = "";
        } else if (fields[k].type === "number") {
          //8918 初期に不正を追加します 张博 start
          d[k] = "";
          //8918 初期に不正を追加します 张博 end
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
      // Vue2 store.edit / MasterRecordComponent.addRow と同じ追加行フラグ
      d.isAddRow = true;
      // 追加行: 横スクロールを先頭へ（MasterRecordComponent.addRow と同様）
      this.scrollPosition.left = 0;
      this.lastscrollLeft = 0;
      this.lastScrollLeft = 0;
      this.__pendingScrollLeftReset = true;
      this.edit({ editRecord: d, isSortMode: this.isSortMode });
      const addedCode = d.code;
      this.clearDirectGridEditedFields(d);
      this.refreshDirectGridDataFromMasterRecords();
      const applyAddedRowVisualState = () => {
        const addedRecord = this.findMasterRecordByCode(addedCode);
        if (!addedRecord) {
          return;
        }
        const rows = this.getDirectGridRowsByRecord(addedRecord);
        const preferredUid = rows[0]?.getAttribute?.("data-uid") || null;
        // Vue2 editBackgroundColor → changeEditColor + changeRowColor 相当
        this.applyDirectGridRowVisualState(addedRecord, preferredUid, rows.length ? rows : null);
      };
      this.$nextTick(() => {
        this.resetDirectGridHorizontalScroll();
        this.scrollDirectGridToBottom();
        this.scheduleValidationTooltipPlacement();
        requestAnimationFrame(() => {
          this.scrollDirectGridToBottom();
          this.resetDirectGridHorizontalScroll();
          requestAnimationFrame(() => {
            applyAddedRowVisualState();
            this.editComFormatCd();
            this.scheduleValidationTooltipPlacement();
          });
        });
        setTimeout(() => {
          this.scrollDirectGridToBottom();
          this.resetDirectGridHorizontalScroll();
          applyAddedRowVisualState();
          this.scheduleValidationTooltipPlacement();
        }, 180);
      });
    },
    editComFormatCd() {
      this.$nextTick(() => {
        const root = this.$refs.gridRoot;
        if (!root || !this.directGridWidget) {
          return;
        }
        const comTypeList = this.getComTypeList || [];
        const rows = Array.from(root.querySelectorAll(".k-grid-content tbody tr[data-uid]"));
        rows.forEach(row => {
          const comTypeCell = this.getDirectGridCellsByField([row], "comType")[0];
          const comFormatCell = this.getDirectGridCellsByField([row], "comFormatCd")[0];
          if (!comTypeCell || !comFormatCell) {
            return;
          }
          const comTypeText = comTypeCell.textContent;
          const comFormatValue = comFormatCell.textContent;
          const filteredComTypeList = comTypeList.filter(type => type.text === comTypeText || String(type.value) === String(comTypeText));
          if (filteredComTypeList.length > 0) {
            const comFormatCdList = filteredComTypeList[0].com_format_cd || [];
            const filteredComFormatCdList = comFormatCdList.filter(format => String(format.value) === String(comFormatValue));
            if (filteredComFormatCdList.length > 0) {
              comFormatCell.textContent = filteredComFormatCdList[0].text;
            }
          }
        });
      });
    },
    loadGridData() {
      this.findList();
    },
    showRegistModal() {
      this.findList();
      this.showMntFindMachineModal();
    },
    messageMachine() {
      // mod #7663 C重複情報のメッセージ画面を表示する。 xiaosonglei start
      this.intervalID = setInterval(() => {
        // 他の画面に遷移したときもmessageMachine()が発生する為、自分の画面のみ処理する
        if (
          this.selfScreenName === this.getCurrentRouteName() &&
          document.getElementsByTagName("ons-alert-dialog").length === 0) {
          // メッセージの確認
          if (this.getMessageList.length > 0) {
            let messages = "";
            for (const item of this.getMessageList) {
              // 型式、通信フォーマット、製造番号、通信種別、IPアドレス
              messages =
                messages +
                "・【型式】" +
                item.machineTypeName +
                " 【通信フォーマット】" +
                item.comFormatName +
                " 【製造番号】" +
                item.machineSerial +
                " 【通信種別】" +
                item.comType +
                " 【ＩＰアドレス】" +
                item.ipAddress +
                "<br>";
            }

            this.$ons.notification.alert({
              class: "machine-dialog",
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
              // title: "下記は重複したので登録しない。",
              title: DIALOG_MESSAGES["00300033"].title,
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
              messageHTML: messages,
            });
            clearInterval(this.intervalID);
          }
        }
        // mod #7663 C重複情報のメッセージ画面を表示する。 zhou start
      });
      // mod #7663 C重複情報のメッセージ画面を表示する。 zhou end
      // mod #7663 C重複情報のメッセージ画面を表示する。 xiaosonglei end
    },
  },
  created() {
    installComponentJQuery();
    this.setLoadingScreenVisible(true);
    this.calculateColumnsWidth();
    // mod マスタ一覧 1･施設切替を可能とする 孔 start
    this.facilitylistValue = this.getFacilitySwitch;
    this.findList();
    // mod マスタ一覧 1･施設切替を可能とする 孔 end
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
    EventBus.$on("onCloseMasterEditModal", this.onCloseMasterEditModal);
    EventBus.$on("refresh", this.refresh);
    EventBus.$on("messageMachine", this.messageMachine);
    this.__machineValidateArrowHandler = () => this.handleAddValidateArrow();
    const ownerDocument = this.$el?.ownerDocument || (typeof document !== "undefined" ? document : null);
    ownerDocument?.addEventListener?.("click", this.__machineValidateArrowHandler);
  },
  mounted() {
    this.directGridMounted = true;
    this.$nextTick(() => {
      this.calculateColumnsWidth();
      this.calculateGridHeight();
      this.resizeDirectGrid();
      this.initDirectGridIfReady();
      this.scheduleDirectGridPostLayoutRefresh();
    });
    this.directGridResizeHandler = () => {
      this.calculateColumnsWidth();
      this.calculateGridHeight();
      this.resizeDirectGrid();
      this.scheduleDirectGridPostLayoutRefresh();
    };
    window.addEventListener("resize", this.directGridResizeHandler);
  },
  // add 性能改善メモリ不足 shan start
  beforeUnmount() {
    if (this.directGridFontResizeRafId != null) {
      cancelAnimationFrame(this.directGridFontResizeRafId);
      this.directGridFontResizeRafId = null;
    }
    if (this.directGridFilterRefreshRafId != null) {
      cancelAnimationFrame(this.directGridFilterRefreshRafId);
      this.directGridFilterRefreshRafId = null;
    }
    if (this.directGridScrollSyncRafId != null) {
      cancelAnimationFrame(this.directGridScrollSyncRafId);
      this.directGridScrollSyncRafId = null;
    }
    if (this.directGridLayoutRefreshRafId != null) {
      cancelAnimationFrame(this.directGridLayoutRefreshRafId);
      this.directGridLayoutRefreshRafId = null;
    }
    if (this.directGridEditVisualRafId != null) {
      cancelAnimationFrame(this.directGridEditVisualRafId);
      this.directGridEditVisualRafId = null;
    }
    if (this.directGridRowVisualRafIds) {
      this.directGridRowVisualRafIds.forEach(rafId => cancelAnimationFrame(rafId));
      this.directGridRowVisualRafIds.clear();
      this.directGridRowVisualRafIds = null;
    }
    if (this.directGridEditedFieldsByCode) {
      this.directGridEditedFieldsByCode.clear();
      this.directGridEditedFieldsByCode = null;
    }
    EventBus.$off("onCloseMasterEditModal", this.onCloseMasterEditModal);
    EventBus.$off("refresh", this.refresh);
    EventBus.$off("messageMachine", this.messageMachine);
    const ownerDocument = this.$el?.ownerDocument || (typeof document !== "undefined" ? document : null);
    if (this.__machineValidateArrowHandler) {
      ownerDocument?.removeEventListener?.("click", this.__machineValidateArrowHandler);
      this.__machineValidateArrowHandler = null;
    }
    this.clearValidationTooltipPlacementTimers();
    this.stopValidationTooltipPlacementWatch();
    this.clearValidationTooltipPlacementState();
    clearInterval(this.intervalID);
    this.destroyDirectGrid();
    if (this.directGridResizeHandler) {
      window.removeEventListener("resize", this.directGridResizeHandler);
      this.directGridResizeHandler = null;
    }
  },
  // add 性能改善メモリ不足 shan end
};
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
 
/* add 8130 全施設マスタでフリーズする 周安寧 start */
.kendo-grid-toolbar-style :deep(.k-tooltip.k-tooltip-validation) {
  width: auto;
}
.kendo-grid-toolbar-style :deep(.k-edit-cell) {
  position: relative;
  overflow: visible;
}
.kendo-grid-toolbar-style :deep(.k-edit-cell > .k-invalid-msg:not(.k-hidden)),
.kendo-grid-toolbar-style :deep(.k-edit-cell > .k-tooltip-error:not(.k-hidden)),
.mst-machine-direct-jq-grid :deep(.k-edit-cell > .k-invalid-msg:not(.k-hidden)),
.mst-machine-direct-jq-grid :deep(.k-edit-cell > .k-tooltip-error:not(.k-hidden)) {
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
/* 下端行: JS ntss-validation-above で tooltip をセル上に表示（locked/non-locked 行ずれ防止） */
.kendo-grid-toolbar-style :deep(td.k-edit-cell.ntss-validation-above > .k-invalid-msg),
.kendo-grid-toolbar-style :deep(td.k-edit-cell.ntss-validation-above .k-tooltip.k-tooltip-validation),
.mst-machine-direct-jq-grid :deep(td.k-edit-cell.ntss-validation-above > .k-invalid-msg),
.mst-machine-direct-jq-grid :deep(td.k-edit-cell.ntss-validation-above .k-tooltip.k-tooltip-validation) {
  position: absolute !important;
  left: 0 !important;
  bottom: 38px !important;
  top: auto !important;
  margin-top: 0 !important;
  overflow: visible !important;
}
.kendo-grid-toolbar-style :deep(td.k-edit-cell.ntss-validation-above .k-callout.k-callout-s),
.mst-machine-direct-jq-grid :deep(td.k-edit-cell.ntss-validation-above .k-callout.k-callout-s) {
  top: auto !important;
  bottom: calc(-12px) !important;
  border-bottom-color: transparent !important;
  border-block-start-color: currentColor !important;
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

/* add #7663 C重複情報のメッセージ画面を表示する。 xiaosonglei start*/
.machine-dialog > .alert-dialog {
  width: auto;
}
/* add #7663 C重複情報のメッセージ画面を表示する。 xiaosonglei end*/
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
.mst-machine-direct-jq-grid :deep(td.master-edited-row),
.mst-machine-direct-jq-grid :deep(tr.master-edited-row > td.master-edited-row),
.mst-machine-direct-jq-grid :deep(tr.k-selected > td.master-edited-row),
.mst-machine-direct-jq-grid :deep(tr.k-state-selected > td.master-edited-row),
.mst-machine-direct-jq-grid :deep(tr.k-table-row.k-selected > td.master-edited-row),
.mst-machine-direct-jq-grid :deep(tr.k-grid-edit-row > td.master-edited-row) {
  color: #003300 !important;
  background-color: #ccffcc !important;
}
.mst-machine-direct-jq-grid :deep(.k-dirty) {
  display: none;
}
.mst-machine-direct-jq-grid :deep(td.master-edited-cell .k-dirty) {
  display: block;
}
.mst-machine-direct-jq-grid :deep(td.master-edited-cell) {
  position: relative;
}
.master-maintenance-page .mst-machine-direct-jq-grid :deep(.k-grid-content td.master-edited-cell),
.master-maintenance-page .mst-machine-direct-jq-grid :deep(.k-grid-content .k-table-td.master-edited-cell),
.master-maintenance-page .mst-machine-direct-jq-grid :deep(.k-grid-content-locked td.master-edited-cell),
.master-maintenance-page .mst-machine-direct-jq-grid :deep(.k-grid-content-locked .k-table-td.master-edited-cell),
.mst-machine-direct-jq-grid :deep(td.master-edited-cell),
.mst-machine-direct-jq-grid :deep(.k-table-td.master-edited-cell) {
  color: #003300 !important;
  font-weight: bold !important;
}
.mst-machine-direct-jq-grid :deep(td.master-edited-row.master-edited-cell),
.mst-machine-direct-jq-grid :deep(.k-table-td.master-edited-row.master-edited-cell),
.mst-machine-direct-jq-grid :deep(tr.k-selected > td.master-edited-row.master-edited-cell),
.mst-machine-direct-jq-grid :deep(tr.k-state-selected > td.master-edited-row.master-edited-cell),
.mst-machine-direct-jq-grid :deep(tr.k-table-row.k-selected > td.master-edited-row.master-edited-cell),
.mst-machine-direct-jq-grid :deep(tr.k-grid-edit-row > td.master-edited-row.master-edited-cell),
.mst-machine-direct-jq-grid :deep(tr.k-grid-edit-row > .k-table-td.master-edited-row.master-edited-cell) {
  font-weight: bold !important;
}
.mst-machine-direct-jq-grid :deep(td.master-sort-edited),
.mst-machine-direct-jq-grid :deep(td.master-sort-edited.master-edited-row),
.mst-machine-direct-jq-grid :deep(tr.master-edited-row > td.master-sort-edited),
.mst-machine-direct-jq-grid :deep(tr.k-selected > td.master-sort-edited),
.mst-machine-direct-jq-grid :deep(tr.k-state-selected > td.master-sort-edited),
.mst-machine-direct-jq-grid :deep(tr.k-table-row.k-selected > td.master-sort-edited),
.mst-machine-direct-jq-grid :deep(tr.k-grid-edit-row > td.master-sort-edited) {
  color: #000000 !important;
  background-color: #ffff66 !important;
}

.mst-machine-direct-jq-grid :deep(.k-grid-content),
.mst-machine-direct-jq-grid :deep(.k-grid-content table),
.mst-machine-direct-jq-grid :deep(.k-grid-content tbody),
.mst-machine-direct-jq-grid :deep(.k-grid-content-locked),
.mst-machine-direct-jq-grid :deep(.k-grid-content-locked table),
.mst-machine-direct-jq-grid :deep(.k-grid-content-locked tbody) {
  background-color: var(--master-maintenance-kgrid-item-background-color) !important;
  color: var(--master-maintenance-kgrid-body-color) !important;
}
.mst-machine-direct-jq-grid :deep(td.master-deleted-row),
.mst-machine-direct-jq-grid :deep(.k-table-td.master-deleted-row),
.mst-machine-direct-jq-grid :deep(tr.master-deleted-row > td),
.mst-machine-direct-jq-grid :deep(tr.deleted-bg > td),
.mst-machine-direct-jq-grid :deep(tr:hover > td.master-deleted-row),
.mst-machine-direct-jq-grid :deep(tr.k-hover > td.master-deleted-row),
.mst-machine-direct-jq-grid :deep(tr.k-table-row:hover > .k-table-td.master-deleted-row),
.mst-machine-direct-jq-grid :deep(td.master-deleted-row:hover) {
  color: #050505 !important;
  background-color: #aaa !important;
}
.mst-machine-direct-jq-grid :deep(td.master-edited-row),
.mst-machine-direct-jq-grid :deep(.k-table-td.master-edited-row),
.mst-machine-direct-jq-grid :deep(tr.master-edited-row > td.master-edited-row),
.mst-machine-direct-jq-grid :deep(tr:hover > td.master-edited-row),
.mst-machine-direct-jq-grid :deep(tr.k-hover > td.master-edited-row),
.mst-machine-direct-jq-grid :deep(tr.k-selected > td.master-edited-row),
.mst-machine-direct-jq-grid :deep(tr.k-state-selected > td.master-edited-row),
.mst-machine-direct-jq-grid :deep(tr.k-table-row:hover > .k-table-td.master-edited-row),
.mst-machine-direct-jq-grid :deep(tr.k-table-row.k-selected > td.master-edited-row),
.mst-machine-direct-jq-grid :deep(tr.k-grid-edit-row > td.master-edited-row),
.mst-machine-direct-jq-grid :deep(td.master-edited-row:hover) {
  color: #003300 !important;
  background-color: #ccffcc !important;
}
.mst-machine-direct-jq-grid :deep(td.master-sort-edited),
.mst-machine-direct-jq-grid :deep(.k-table-td.master-sort-edited),
.mst-machine-direct-jq-grid :deep(td.master-sort-edited.master-edited-row),
.mst-machine-direct-jq-grid :deep(tr.master-edited-row > td.master-sort-edited),
.mst-machine-direct-jq-grid :deep(tr:hover > td.master-sort-edited),
.mst-machine-direct-jq-grid :deep(tr.k-hover > td.master-sort-edited),
.mst-machine-direct-jq-grid :deep(tr.k-selected > td.master-sort-edited),
.mst-machine-direct-jq-grid :deep(tr.k-state-selected > td.master-sort-edited),
.mst-machine-direct-jq-grid :deep(tr.k-table-row:hover > .k-table-td.master-sort-edited),
.mst-machine-direct-jq-grid :deep(tr.k-table-row.k-selected > td.master-sort-edited),
.mst-machine-direct-jq-grid :deep(tr.k-grid-edit-row > td.master-sort-edited),
.mst-machine-direct-jq-grid :deep(td.master-sort-edited:hover) {
  color: #000000 !important;
  background-color: #ffff66 !important;
}



/* Direct machine grid color priority. Hover/selected state must not override explicit row state. */
.mst-machine-direct-jq-grid :deep(.k-grid-content tr.k-table-row:not(.master-edited-row):not(.master-deleted-row):not(.k-selected):not(.k-state-selected) > td:not(.master-edited-row):not(.master-deleted-row):not(.master-sort-edited)),
.mst-machine-direct-jq-grid :deep(.k-grid-content tr.k-master-row:not(.master-edited-row):not(.master-deleted-row):not(.k-selected):not(.k-state-selected) > td:not(.master-edited-row):not(.master-deleted-row):not(.master-sort-edited)),
.mst-machine-direct-jq-grid :deep(.k-grid-content-locked tr.k-table-row:not(.master-edited-row):not(.master-deleted-row):not(.k-selected):not(.k-state-selected) > td:not(.master-edited-row):not(.master-deleted-row):not(.master-sort-edited)),
.mst-machine-direct-jq-grid :deep(.k-grid-content-locked tr.k-master-row:not(.master-edited-row):not(.master-deleted-row):not(.k-selected):not(.k-state-selected) > td:not(.master-edited-row):not(.master-deleted-row):not(.master-sort-edited)) {
  color: var(--master-maintenance-kgrid-body-color) !important;
  background-color: var(--master-maintenance-kgrid-item-background-color) !important;
}

.mst-machine-direct-jq-grid :deep(.k-grid-content tr.k-alt:not(.master-edited-row):not(.master-deleted-row):not(.k-selected):not(.k-state-selected) > td:not(.master-edited-row):not(.master-deleted-row):not(.master-sort-edited)),
.mst-machine-direct-jq-grid :deep(.k-grid-content tr.k-table-alt-row:not(.master-edited-row):not(.master-deleted-row):not(.k-selected):not(.k-state-selected) > td:not(.master-edited-row):not(.master-deleted-row):not(.master-sort-edited)),
.mst-machine-direct-jq-grid :deep(.k-grid-content-locked tr.k-alt:not(.master-edited-row):not(.master-deleted-row):not(.k-selected):not(.k-state-selected) > td:not(.master-edited-row):not(.master-deleted-row):not(.master-sort-edited)),
.mst-machine-direct-jq-grid :deep(.k-grid-content-locked tr.k-table-alt-row:not(.master-edited-row):not(.master-deleted-row):not(.k-selected):not(.k-state-selected) > td:not(.master-edited-row):not(.master-deleted-row):not(.master-sort-edited)) {
  color: var(--master-maintenance-kgrid-body-color) !important;
  background-color: var(--ntss-list-content-2nd-background-color) !important;
}

.mst-machine-direct-jq-grid :deep(tr.master-deleted-row:hover > td),
.mst-machine-direct-jq-grid :deep(tr.master-deleted-row.k-hover > td),
.mst-machine-direct-jq-grid :deep(tr.master-deleted-row.k-state-hover > td),
.mst-machine-direct-jq-grid :deep(tr.deleted-bg:hover > td),
.mst-machine-direct-jq-grid :deep(tr.deleted-bg.k-hover > td),
.mst-machine-direct-jq-grid :deep(tr.deleted-bg.k-state-hover > td),
.mst-machine-direct-jq-grid :deep(td.master-deleted-row:hover),
.mst-machine-direct-jq-grid :deep(td.master-deleted-row.k-hover),
.mst-machine-direct-jq-grid :deep(td.master-deleted-row.k-state-hover),
.mst-machine-direct-jq-grid :deep(td.master-deleted-row.k-selected),
.mst-machine-direct-jq-grid :deep(td.master-deleted-row[aria-selected="true"]) {
  color: #050505 !important;
  background: #aaa !important;
  background-color: #aaa !important;
}

.mst-machine-direct-jq-grid :deep(tr.master-edited-row:hover > td.master-edited-row),
.mst-machine-direct-jq-grid :deep(tr.master-edited-row.k-hover > td.master-edited-row),
.mst-machine-direct-jq-grid :deep(tr.master-edited-row.k-state-hover > td.master-edited-row),
.mst-machine-direct-jq-grid :deep(tr.master-edited-row.k-selected > td.master-edited-row),
.mst-machine-direct-jq-grid :deep(tr.master-edited-row[aria-selected="true"] > td.master-edited-row),
.mst-machine-direct-jq-grid :deep(td.master-edited-row:hover),
.mst-machine-direct-jq-grid :deep(td.master-edited-row.k-hover),
.mst-machine-direct-jq-grid :deep(td.master-edited-row.k-state-hover),
.mst-machine-direct-jq-grid :deep(td.master-edited-row.k-selected),
.mst-machine-direct-jq-grid :deep(td.master-edited-row[aria-selected="true"]) {
  color: #003300 !important;
  background: #ccffcc !important;
  background-color: #ccffcc !important;
}

.mst-machine-direct-jq-grid :deep(tr:hover > td.master-sort-edited),
.mst-machine-direct-jq-grid :deep(tr.k-hover > td.master-sort-edited),
.mst-machine-direct-jq-grid :deep(tr.k-state-hover > td.master-sort-edited),
.mst-machine-direct-jq-grid :deep(tr.k-selected > td.master-sort-edited),
.mst-machine-direct-jq-grid :deep(tr[aria-selected="true"] > td.master-sort-edited),
.mst-machine-direct-jq-grid :deep(td.master-sort-edited:hover),
.mst-machine-direct-jq-grid :deep(td.master-sort-edited.k-hover),
.mst-machine-direct-jq-grid :deep(td.master-sort-edited.k-state-hover),
.mst-machine-direct-jq-grid :deep(td.master-sort-edited.k-selected),
.mst-machine-direct-jq-grid :deep(td.master-sort-edited[aria-selected="true"]) {
  color: #000000 !important;
  background: #ffff66 !important;
  background-color: #ffff66 !important;
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
