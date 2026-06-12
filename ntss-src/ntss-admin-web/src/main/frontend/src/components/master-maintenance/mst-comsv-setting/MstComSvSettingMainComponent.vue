/**
 * 通信サーバーマスタメンテナンスデータページ  MainContent
 */
<template>
  <div class='main-content-area master-maintenance-page'>
    <div ref="validatorRoot" class='ntss-list' :style="ntssListStyles">
      <div class="k-grid-toolbar k-header kendo-grid-toolbar-style mst-comsv-direct-jq-toolbar" :style="heightStyles">
        <div id="grid-header" class='header-btn-area right' :style="isMobileDevice ? { minHeight: '30px' } : {}">
          <v-ons-button modifier="outline" class="btn3-normal toolbar-btn" style="float: left;" v-show="!isSortMode && isAllowAddRecord" @click="addRow()">追加</v-ons-button>
          <v-ons-button modifier="outline" class="btn3-normal toolbar-btn" style="float: left; margin-left: 10px;" v-show="!isSortMode && isAllowAddRecord" @click="copyAdd">コピー追加</v-ons-button>
          <v-ons-row v-show="isMobileDevice" style="float: left; width: 6em; height: 2em;">
            <v-ons-col width="45%" vertical-align="center">
              <label class="fab-font-color">編集</label>
            </v-ons-col>
            <v-ons-col width="55%" vertical-align="center">
              <v-ons-switch modifier="outline" v-model="allowEdit" />
            </v-ons-col>
          </v-ons-row>
          <!-- del マスタ一覧 1･施設切替を可能とする 王 start -->
          <!--          <kendo-dropdownlist ref="dropDownList" v-if="isMasterUser"-->
          <!--                    v-model="facilityListValue"-->
          <!--                    :data-source="facilities"-->
          <!--                    :data-text-field="'facilityName'"-->
          <!--                    :data-value-field="'facilityCd'"-->
          <!--                    :filter="'contains'"-->
          <!--                    @open="onOpenFacility"-->
          <!--                    @change="onChangeFacility"-->
          <!--                    style="width: 13em;">-->
          <!--          </kendo-dropdownlist>-->
          <!-- del マスタ一覧 1･施設切替を可能とする 王 end -->
          <v-ons-button modifier="outline" class="btn3-normal toolbar-btn" v-show="!isSortMode && isAllowSort" @click="toRankEditBtnClick()">並び順表示</v-ons-button>
          <v-ons-button modifier="outline" class="btn3-normal toolbar-btn" v-show="isSortMode && isAllowSort" @click="sortBtnClick()">反映</v-ons-button>
        </div>
        <div
          v-show="columns.length > 1"
          ref="grid"
          :class="[
            fontSizeSet,
            'ntss-kendo-grid-legacy',
            'mst-comsv-direct-jq-grid'
          ]"
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
    <master-copy-add
      :popoverVisible="masterCopyAddVisible"
      :popoverTarget="masterCopyAddTarget"
      :copySrcData="copySrcData"
      @added-row="addedRow"
      @popover-close="prehideCopyAddPopover"
    />
  </div>
</template>

<script>
import { markRaw } from "@/compat/vue/runtime";
import { mapActions, mapGetters } from "@/compat/vue/vuex";
import MasterMaintenanceMixin from "@/components/master-maintenance/MasterMaintenanceMixin";
const { updated: _masterMaintenanceUpdated, ...MstComSvSettingMaintenanceMixin } = MasterMaintenanceMixin;
import { EventBus } from "@/compat/vue/event-bus.js";
import kendo from "@progress/kendo-ui";

//FNSI-修正 VUEのエラー場合のログ対応 liuimx add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 liuimx add end
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
import MasterCopyAddComponent from "@/components/master-maintenance/MasterCopyAddComponent";
import { getScopedNumericTextBox } from '@/functions/common/LayoutMeasureHelper';

import { getScopedAlertDialogs } from "@/functions/common/LayoutMeasureHelper";
import $ from "@/compat/jquery";
import {
  createJQueryValidator,
  destroyJQueryValidator,
} from "@/compat/kendo/kendo-jquery.js";

/**
 * TODO
 * more: モーダルで編集した項目が、一覧上で「編集済み（三角マーク）」をつけたい。
 */
export default {
  mixins: [MstComSvSettingMaintenanceMixin],
  components: {
    "master-copy-add": MasterCopyAddComponent,
  },
  data() {
    return {
      recordList: [],
      // add 6113 について 修正 chen start
      flg: false,
      machineName: "",
      // add 6113 について 修正 chen end
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
      isAndroid: false,
      isIOS: false,
      scrollPosition: {
        top: 0,
        left: 0
      },
      //自画面の名称
      selfScreenName: "",
      // 選択施設情報
      facilityListValue: "",
      //変更前の施設
      prevFacilityCd: "",
      lastscrollTop: 0,
      lastscrollLeft: 0,
      errorName: [],
      // コピー追加 吹き出し用 start
      masterCopyAddVisible: false,
      masterCopyAddTarget: null,
      // コピー追加 吹き出し用 end
      allowEdit: true, // NOTE: true = 編集モード、 false = 閲覧モード
      directGridWidget: null,
      directGridDataSource: null,
      directGridLayoutRafId: null,
      directGridScrollSyncRafId: null,
      directGridColumnSignature: "",
      directGridReady: false,
      directGridRowVisualRafIds: markRaw(new Map()),
      directComsvSortEditOriginalValues: markRaw(new Map()),
      directComsvSortEditedCodes: markRaw(new Set()),
      kendoValidator: undefined,
    };
  },
  computed: {
    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight"
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
      return { display: this.columns.length == 1 ? "none" : "inherit" };
    },
    ...mapGetters("user", {
      facilityCd: "getFacilityCd"
    }),
    ...mapGetters("master-maintenance", {
      getMasterRecordList: "getMasterRecordList",
      getFilteredMasterRecordList: "getFilteredMasterRecordList",
      getUpdateRecordList: "getUpdateRecordList",
      masterPhysicalName: "getMasterName",
      columnDefinition: "getColumns",
      editRecord: "getEditRecord",
      isEdited: "isEdited",
      getFacilitySwitch: "getFacilitySwitch",
      hasValueColumn: "hasValueColumn",
      // #9275 装置通信・仮想端末マスタの並び順が保存できない linjunfeng start
      isRecordModified: "isRecordModified"
      // #9275 装置通信・仮想端末マスタの並び順が保存できない linjunfeng end

    }),
    ...mapGetters("mst-com-sv-setting", {
      getMachineTypeList: "getMachineTypeList",
      getDeviceEdgeList: "getDeviceEdgeList",
      getFacilityList: "getFacilityList",
    }),
    masterRecords() {
      // storeからデータを取得
      return this.getFilteredMasterRecordList;
    },
    directComsvDisplayRecordSignature() {
      const records = this.getDirectComsvDisplayRecords?.() || [];
      return records
        .map(record => [
          record?.code ?? record?.generalKey1 ?? record?.deviceEdgeNo ?? "",
          record?.isDisp ?? "",
          record?.operation ?? "",
          record?.sortRank ?? ""
        ].join(":"))
        .join("|");
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
        data !== undefined && this.kendoValidator !== undefined &&
        (
          // del #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（装置通信・仮想端末マスタ画面）20231108 ztc start
          // data.filter(row => row.operation > 0).length ||
          // this.isSorted ||
          // del #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（装置通信・仮想端末マスタ画面）20231108 ztc end
          // #9275 装置通信・仮想端末マスタの並び順が保存できない linjunfeng start
          this.isRecordModified ||
          // #9275 装置通信・仮想端末マスタの並び順が保存できない linjunfeng end
          !this.kendoValidator.validate())
      );
    },
    isMasterUser: {
      get() {
        return this.getStateUserAccountInfo.userType === 1 ? true : false;
      },
      set() {}
    },
    facilities() {
      // storeからデータを取得
      return this.getFacilityList;
    },
    // grid表示データから吹き出しびプルダウンリストデータ生成
    copySrcData() {
      if (!this.masterRecords || this.masterRecords.length === 0) {
        return [];
      }
      return this.masterRecords.data
        .filter(item => item.operation !== 1) // 追加行は除外
        .map(item => {
          // デバイスエッジのリスト から value が一致する要素を探す
          const matchingDevice = this.getDeviceEdgeList.find(device => device.value == item.deviceEdgeNo);
          return {
            code: item.code,
            name: matchingDevice ? matchingDevice.text : ""
          };
        });
    },
    isMobileDevice() {
      return this.isIOS || this.isAndroid;
    }
  },
  watch: {
    windowHeight() {
      this.calculateGridHeight();
    },
    isDispMenu() {
      this.calculateGridHeight();
    },
    getFontSize() {
      this.calculateGridHeight();
    },
    columns(val) {
      this.$nextTick(() => {
        if (val.length > 1) {
          this.initDirectComsvGridIfReady();
          this.applyDirectComsvColumnsContract();
          this.scheduleDirectComsvLayoutContract();
        }
      });
    },
    directComsvDisplayRecordSignature() {
      if (this.editingFlg || this.isSortMode) {
        return;
      }
      this.$nextTick(() => {
        this.refreshDirectComsvGridDataSource();
        this.applyDirectComsvColumnsContract();
        this.scheduleDirectComsvLayoutContract();
      });
    },
  },
  methods: {
    getComsvNumericTextBoxElement() {
      return getScopedNumericTextBox(this.getComsvScopeRoot()) || null;
    },
    ...mapActions("multi-modal", ["showMasterEdit"]),
    ...mapActions("master-maintenance", [
      "findRecordListByFacilityCd",
      "setMasterRecordList",
      "edit",
      "setCondition",
      "updateRecordListByFacilityCd",
      "setEditRecord",
      "editRecordBeEmpty",
      // #9275 装置通信・仮想端末マスタの並び順が保存できない linjunfeng start
      "setComparisonRecordModel",
      // #9275 装置通信・仮想端末マスタの並び順が保存できない linjunfeng end
    ]),
    // 共通ローダー設定
    ...mapActions("loading-screen", {
      setLoadingScreenVisible: "setLoadingScreenVisible",
      setLoadingScreenMessage: "setLoadingScreenMessage",
      resetLoadingScreenVisibleCount:  "resetLoadingScreenVisibleCount"
    }),
    ...mapActions("mst-com-sv-setting", [
      "getComboRecordList",
      "deleteMstMachineList",
      "synchroMstComSvSetting",
      "facilityList",
      "setSelectFacility"
    ]),
    getComsvGridRoot() {
      return this.$refs.grid || null;
    },
    getComsvScopeRoot() {
      return this.getComsvGridRoot() || this.$el || null;
    },
    installDirectComsvJQuery() {
      if (typeof window !== "undefined") {
        window.$ = window.$ || $;
        window.jQuery = window.jQuery || $;
      }
      if (typeof globalThis !== "undefined") {
        globalThis.$ = globalThis.$ || $;
        globalThis.jQuery = globalThis.jQuery || $;
      }
    },
    normalizeDirectComsvRecords(value) {
      return Array.isArray(value) ? value : [];
    },
    getDirectComsvDisplayRecords() {
      const filtered = this.getFilteredMasterRecordList?.data;
      const source = Array.isArray(filtered) ? filtered : (this.getMasterRecordList?.data || []);
      return source.filter(record => !!record);
    },
    createDirectComsvDataSource() {
      const dataSource = new kendo.data.DataSource({
        data: this.normalizeDirectComsvRecords(this.getDirectComsvDisplayRecords()),
        schema: this.getMasterRecordList?.schema || undefined
      });
      this.directGridDataSource = markRaw(dataSource);
      return this.directGridDataSource;
    },
    buildDirectComsvColumns() {
      return (this.columns || []).map(column => {
        const gridColumn = {
          title: column.title,
          field: column.field,
          hidden: !!column.hidden,
          locked: !!column.locked,
          editable: column.editable,
          width: column.width,
          format: column.format,
          values: column.values || null
        };
        if (column.field === "$modalType") {
          gridColumn.attributes = { class: "btn3-kendo-normal" };
          gridColumn.command = { text: "詳細", click: event => this.showMasterEditModal(event) };
          delete gridColumn.values;
        }
        if (column.field === "deviceEdgeNo") {
          gridColumn.editor = this.editorDropDown;
        }
        return gridColumn;
      });
    },
    initDirectComsvGridIfReady() {
      const root = this.getComsvGridRoot();
      if (!root || this.columns.length <= 1) {
        return;
      }
      if (this.directGridWidget) {
        this.applyDirectComsvColumnsContract();
        this.refreshDirectComsvGridDataSource();
        this.scheduleDirectComsvLayoutContract();
        return;
      }
      this.installDirectComsvJQuery();
      $(root).empty();
      $(root).kendoGrid({
        dataSource: this.createDirectComsvDataSource(),
        editable: true,
        selectable: true,
        reorderable: false,
        height: this.kendoGridHeight,
        scrollable: true,
        columns: this.buildDirectComsvColumns(),
        beforeEdit: event => this.editStart(event),
        cellClose: event => this.editEnd(event),
        edit: event => this.addInputAssist(event),
        save: event => this.onSave(event),
        dataBound: event => this.onDataBoundKendoGrid(event)
      });
      this.directGridWidget = markRaw($(root).data("kendoGrid"));
      this.directGridColumnSignature = this.getDirectComsvColumnSignature();
      this.installDirectComsvGridFacade();
      this.applyDirectComsvStyleContract();
      this.scheduleDirectComsvLayoutContract();
    },
    destroyDirectComsvGrid() {
      if (this.directGridWidget) {
        try {
          this.directGridWidget.destroy();
        } catch (_error) {
          // noop
        }
      }
      const root = this.getComsvGridRoot();
      if (root) {
        $(root).empty();
      }
      this.directGridWidget = null;
      this.directGridColumnSignature = "";
      this.directGridReady = false;
    },
    initDirectComsvValidator() {
      const root = this.$refs.validatorRoot || this.$el;
      if (!root) {
        return;
      }
      this.installDirectComsvJQuery();
      destroyJQueryValidator(root);
      try {
        this.kendoValidator = markRaw(
          createJQueryValidator(root, this.kendoValidatorSetup || {})
        );
      } catch (_error) {
        this.kendoValidator = { validate: () => true };
      }
    },
    installDirectComsvGridFacade() {
      const root = this.getComsvGridRoot();
      if (!root) {
        return;
      }
      root.kendoWidget = () => this.directGridWidget;
      root.gridWidget = () => this.directGridWidget;
      root.gridContentEl = () => this.getDirectComsvScrollContent();
      root.gridAutoScrollableEl = () => this.getDirectComsvScrollContent();
      root.gridLockedContentEl = () => this.getDirectComsvLockedScrollContent();
      root.gridDataItem = row => this.directGridWidget?.dataItem?.(row);
      root.scrollGridTo = position => this.setGridScrollPosition(position);
    },
    getDirectComsvColumnSignature() {
      return (this.columns || [])
        .map(column => [
          column.field,
          column.hidden ? 1 : 0,
          column.locked ? 1 : 0,
          column.width || "",
          column.title || "",
          column.format || ""
        ].join(":"))
        .join("|");
    },
    syncDirectComsvColumnState() {
      const grid = this.directGridWidget;
      if (!grid?.columns) {
        return;
      }
      (this.columns || []).forEach(column => {
        const gridColumn = grid.columns.find(item => item.field === column.field);
        if (!gridColumn) {
          return;
        }
        gridColumn.editable = column.editable;
        gridColumn.hidden = !!column.hidden;
      });
    },
    applyDirectComsvColumnsContract() {
      if (!this.directGridWidget || this.columns.length <= 1) {
        return;
      }
      const nextSignature = this.getDirectComsvColumnSignature();
      if (this.directGridColumnSignature !== nextSignature) {
        this.directGridWidget.setOptions({
          columns: this.buildDirectComsvColumns(),
          height: this.kendoGridHeight
        });
        this.directGridColumnSignature = nextSignature;
        this.installDirectComsvGridFacade();
        this.scheduleDirectComsvLayoutContract();
        return;
      }
      this.syncDirectComsvColumnState();
      this.installDirectComsvGridFacade();
      this.scheduleDirectComsvLayoutContract();
    },
    refreshDirectComsvGridDataSource(records = null) {
      if (!this.directGridWidget?.dataSource) {
        return;
      }
      const sourceRecords = Array.isArray(records) ? records : this.getDirectComsvDisplayRecords();
      try {
        this.directGridWidget.dataSource.data(this.normalizeDirectComsvRecords(sourceRecords));
      } catch (_error) {
        return;
      }
      this.$nextTick(() => {
        this.applyDirectComsvStyleContract();
        this.markDirectComsvSortEditedRows();
        this.restoreDirectComsvScrollPosition();
      });
    },
    getGridWidget() {
      return this.directGridWidget || null;
    },
    getDirectComsvScrollContent() {
      return this.getComsvGridRoot()?.querySelector?.(".k-grid-content") || null;
    },
    getDirectComsvLockedScrollContent() {
      return this.getComsvGridRoot()?.querySelector?.(".k-grid-content-locked") || null;
    },
    getGridScrollContainer() {
      return this.getDirectComsvScrollContent() || { scrollTop: 0, scrollLeft: 0 };
    },
    getGridScrollHostEl() {
      return this.getDirectComsvScrollContent();
    },
    getGridScrollPosition() {
      const content = this.getDirectComsvScrollContent();
      return { top: content?.scrollTop || 0, left: content?.scrollLeft || 0 };
    },
    setGridScrollPosition(position = {}) {
      this.scrollPosition.top = Number.isFinite(position?.top) ? position.top : 0;
      this.scrollPosition.left = Number.isFinite(position?.left) ? position.left : 0;
      this.restoreDirectComsvScrollPosition();
    },
    restoreDirectComsvScrollPosition() {
      const content = this.getDirectComsvScrollContent();
      if (!content) {
        return;
      }
      const top = this.scrollPosition.top ?? this.lastscrollTop ?? this.lastScrollTop ?? 0;
      const left = this.scrollPosition.left ?? this.lastscrollLeft ?? this.lastScrollLeft ?? 0;
      content.scrollTop = top;
      content.scrollLeft = left;
      const headerWrap = this.getComsvGridRoot()?.querySelector?.(".k-grid-header-wrap");
      if (headerWrap) {
        headerWrap.scrollLeft = left;
      }
      if (typeof this.directGridWidget?._scrollLeft !== "undefined") {
        this.directGridWidget._scrollLeft = left;
      }
      this.syncDirectComsvLockedScrollPosition();
      try {
        content.dispatchEvent(new Event("scroll", { bubbles: true }));
        $(content).trigger("scroll");
      } catch (_error) {
        // noop
      }
    },
    syncDirectComsvLockedScrollPosition() {
      const content = this.getDirectComsvScrollContent();
      const lockedContent = this.getDirectComsvLockedScrollContent();
      if (content && lockedContent) {
        lockedContent.scrollTop = content.scrollTop;
      }
    },
    setGridDataSource(data) {
      if (!this.directGridWidget?.dataSource) {
        return;
      }
      const source = Array.isArray(data?.data) ? data.data : Array.isArray(data) ? data : this.getDirectComsvDisplayRecords();
      this.directGridWidget.dataSource.data(this.normalizeDirectComsvRecords(source));
    },
    getGridDataSource() {
      const data = this.directGridWidget?.dataSource?.data?.();
      return {
        data: typeof data?.toJSON === "function" ? data.toJSON() : Array.from(data || [])
      };
    },
    getGridHeaderEl() {
      return this.getComsvGridRoot()?.querySelector?.(".k-grid-header") || null;
    },
    getGridTableEl() {
      return this.getComsvGridRoot()?.querySelector?.(".k-grid-content table") || null;
    },
    getGridTbodyEl() {
      return this.getComsvGridRoot()?.querySelector?.(".k-grid-content tbody") || null;
    },
    getGridLockedTbodyEl() {
      return this.getComsvGridRoot()?.querySelector?.(".k-grid-content-locked tbody") || null;
    },
    getGridBodyRows() {
      return Array.from(this.getGridTbodyEl()?.children || []);
    },
    getGridLockedBodyRows() {
      return Array.from(this.getGridLockedTbodyEl()?.children || []);
    },
    scheduleDirectComsvLayoutContract() {
      if (this.directGridLayoutRafId != null) {
        cancelAnimationFrame(this.directGridLayoutRafId);
      }
      this.directGridLayoutRafId = requestAnimationFrame(() => {
        this.directGridLayoutRafId = null;
        this.resizeDirectComsvGrid();
        this.applyDirectComsvStyleContract();
        this.directGridLayoutRafId = requestAnimationFrame(() => {
          this.directGridLayoutRafId = null;
          this.applyDirectComsvStyleContract();
          this.restoreDirectComsvScrollPosition();
        });
      });
    },
    resizeDirectComsvGrid() {
      if (!this.directGridWidget) {
        return;
      }
      try {
        this.directGridWidget.setOptions({ height: this.kendoGridHeight });
        this.directGridWidget.resize(true);
      } catch (_error) {
        // direct jq では resize 失敗時に rebuild しない。
      }
    },
    resolveDirectComsvFontPixel() {
      const root = this.getComsvGridRoot() || this.$el;
      const ownerWindow = root?.ownerDocument?.defaultView || window;
      const fontSize = Number.parseFloat(ownerWindow.getComputedStyle?.(root)?.fontSize || "");
      return Number.isFinite(fontSize) && fontSize > 0 ? fontSize : 14;
    },
    parseDirectComsvWidthPx(width) {
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
        return numeric * this.resolveDirectComsvFontPixel();
      }
      if (value.endsWith("px") || /^[0-9.]+$/.test(value)) {
        return numeric;
      }
      return 0;
    },
    getDirectComsvLockedWidthPx() {
      return (this.columns || []).reduce((total, column) => {
        if (!column?.locked || column.hidden) {
          return total;
        }
        return total + this.parseDirectComsvWidthPx(column.width);
      }, 0);
    },
    getDirectComsvScrollableWidthPx() {
      return (this.columns || []).reduce((total, column) => {
        if (column?.locked || column.hidden) {
          return total;
        }
        return total + this.parseDirectComsvWidthPx(column.width);
      }, 0);
    },
    applyDirectComsvScrollableFillContract() {
      const root = this.getComsvGridRoot();
      const content = this.getDirectComsvScrollContent();
      if (!root || !content) {
        return;
      }
      const visibleWidth = this.getDirectComsvScrollableWidthPx();
      const contentWidth = content.clientWidth || 0;
      root.classList.toggle(
        "mst-comsv-scrollable-fill-contract",
        visibleWidth > 0 && contentWidth > 0 && visibleWidth < contentWidth
      );
    },
    applyDirectComsvLockedWidthContract() {
      const root = this.getComsvGridRoot();
      const width = this.getDirectComsvLockedWidthPx();
      if (!root || !width) {
        return;
      }
      const widthPx = `${Math.ceil(width)}px`;
      [
        ".k-grid-header-locked",
        ".k-grid-content-locked",
        ".k-grid-content-locked table",
        ".k-grid-header-locked table"
      ].forEach(selector => {
        root.querySelectorAll(selector).forEach(element => {
          element.style.width = widthPx;
          element.style.minWidth = widthPx;
        });
      });
    },
    applyDirectComsvLockedHeightContract() {
      const content = this.getDirectComsvScrollContent();
      const lockedContent = this.getDirectComsvLockedScrollContent();
      if (!content || !lockedContent) {
        return;
      }
      const targetHeight = content.clientHeight || 0;
      if (targetHeight <= 0) {
        return;
      }
      const heightPx = `${Math.floor(targetHeight)}px`;
      lockedContent.style.height = heightPx;
      lockedContent.style.maxHeight = heightPx;
      this.syncDirectComsvLockedScrollPosition();
    },
    applyDirectComsvStyleContract() {
      const root = this.getComsvGridRoot();
      if (!root) {
        return;
      }
      root.classList.add("ntss-kendo-grid-legacy", "k-widget", "k-grid", "k-editable", "k-display-block", "mst-comsv-direct-jq-grid");
      root.querySelectorAll("th").forEach(th => th.classList.add("k-header"));
      [".k-grid-content tbody", ".k-grid-content-locked tbody"].forEach(selector => {
        root.querySelectorAll(selector).forEach(tbody => {
          Array.from(tbody.children || []).forEach((tr, index) => {
            tr.classList.add("k-master-row");
            index % 2 === 1 ? tr.classList.add("k-alt") : tr.classList.remove("k-alt");
          });
        });
      });
      root.querySelectorAll(".k-grid-content td, .k-grid-content-locked td").forEach(td => td.classList.add("k-td", "k-table-td"));
      this.applyDirectComsvScrollableFillContract();
      this.applyDirectComsvLockedWidthContract();
      this.applyDirectComsvLockedHeightContract();
      this.syncDirectComsvLockedScrollPosition();
    },
    syncDirectComsvSortValuesToMasterRecords() {
      const data = this.directGridWidget?.dataSource?.data?.();
      const rows = typeof data?.toJSON === "function" ? data.toJSON() : Array.from(data || []);
      if (!Array.isArray(this.getMasterRecordList?.data)) {
        return;
      }
      const byCode = new Map();
      rows.forEach(row => {
        if (row?.code !== undefined && row?.code !== null) {
          byCode.set(String(row.code), row);
        }
      });
      this.getMasterRecordList.data.forEach(record => {
        const gridRow = byCode.get(String(record.code));
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
    onDataBoundKendoGrid() {
      this.directGridReady = true;
      this.installDirectComsvGridFacade();
      this.applyDirectComsvStyleContract();
      this.editBackgroundColor();
      this.setLoadingScreenVisible(false);
    },
    // Windowの高さからGirdコンポーネント領域の高さを算出
    // calculateGridHeight() {
    //   if (!this.editingFlg) {
    //     const wh = this.windowHeight;
    //     const hh = Array.prototype.slice
    //       .call(document.getElementsByClassName("header"))
    //       .pop().clientHeight;
    //     const fmh =
    //       (this.isDispMenu === 1
    //         ? document.getElementById("footer-menu").clientHeight
    //         : 0) + 5;
    //     this.kendoGridToolbarHeight = wh - hh - fmh - 10;
    //     this.kendoGridToolbarHeight =
    //       this.kendoGridToolbarHeight < 340 ? 340 : this.kendoGridToolbarHeight;
    //     const ghd = document.getElementById("grid-header").clientHeight;
    //     const gfh = document.getElementById("grid-footer").clientHeight;
    //     this.kendoGridHeight = this.kendoGridToolbarHeight - (gfh + ghd);
    //   }
    // },
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
      this.editingFlg = true;
      const model = e?.model;
      const field = e?.container?.closest?.("td")?.attr?.("data-field") || e?.container?.attr?.("data-field") || e?.field;
      if (model?.uid && field) {
        const originalValue = typeof model.get === "function" ? model.get(field) : model[field];
        this.directComsvSortEditOriginalValues.set(`${model.uid}:${field}`, originalValue);
      }
    },
    editEnd() {
      this.editingFlg = false;
    },
    addInputAssist() {
      // iOS/PWA環境でスピナーをタップすると編集が終了してしまう現象の対策
      if (this.isIOS) {
        const numericTextBox = this.getComsvNumericTextBoxElement();
        if (numericTextBox) {
          let spinnerObj = numericTextBox.getElementsByClassName("k-select")[0];
          // 編集が終了するとオブジェクトが削除されるため、removeEvent処理は不要
          spinnerObj.ontouchend = event => event.stopPropagation();
        }
      }
    },
    // グリッドのデータ再表示
    gridDataRefresh() {
      this.refreshDirectComsvGridDataSource();
    },
    // マスタ一覧のデータを取得
    findList() {
      // apiをコールして型式マスタ、デバイスエッジの値を取得
      this.getComboRecordList(this.facilityListValue).then(() => {
        // apiをコールして値を取得
        this.findRecordListByFacilityCd(this.facilityListValue)
          .then(response => {
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
              // // 型式コンボ用データを追加
              // if (column.field === "machineTypeCd") {
              //   column.values = machineTypeList;
              // }
              // // デバイスエッジコンボ用データを追加
              // if (column.field === "deviceEdgeNo") {
              //   column.values = deviceEdgeList;
              // }
              /* del by chamaojia 2023-07-10 装置マスタ初期化エラー  --end */
            });
            // 型式コンボボックス用データ取得
            const machineTypeList = this.getMachineTypeList;
            // デバイスエッジコンボボックス用データ取得
            const deviceEdgeList = this.getDeviceEdgeList;
            toFunction.forEach(column => {
              // 型式コンボ用データを追加
              if (column.field === "machineTypeCd") {
                column.values = machineTypeList;
              }
              // デバイスエッジコンボ用データを追加
              if (column.field === "deviceEdgeNo") {
                column.values = deviceEdgeList;
              }
            });

            this.columns = toFunction.filter(function(col) {
              return col;
            });

            // 横スクロールバーを表示するために列幅を指定
            this.columns.forEach(column => {
              // 「削除」のプルダウンが改行しない幅に調整
              column.width = "14em";
              // mod #7289-マスタの削除ボタンが縦表示になる 徐博 start
              // if (column.field === "isDisp")column.width = "8em";
              if (column.field === "isDisp")column.width = "9em";
              // mod #7289-マスタの削除ボタンが縦表示になる 徐博 end
              if (column.field === "isDel")column.width = "8em";
                // column.width = (column.field === "isDisp" || column.field === "isDel") ? "8em" : "14em";
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
              width: "10px",
              format: "",
              values: null
            });
            // カラム幅等初期調整
            this.showSortColumn();
            this.$nextTick(() => {
              this.calculateGridHeight();
              this.initDirectComsvGridIfReady();
              this.refreshDirectComsvGridDataSource();
            /* add スクロールの位置を維持 楊 start */
            this.setGridScrollPosition({ top: this.lastscrollTop, left: this.lastscrollLeft });
            setTimeout(() => {
                this.lastScrollTop = 0;
                this.lastScrollLeft = 0;
              }, 1000);
            /* add スクロールの位置を維持 楊 end */
            });
            // #9275 装置通信・仮想端末マスタの並び順が保存できない linjunfeng start
            // 初期データ内容を保存
            this.setComparisonRecordModel();
            // #9275 装置通信・仮想端末マスタの並び順が保存できない linjunfeng end
            // グリッドのデータ再表示
            //this.gridDataRefresh();
          })
          .catch(error => {
            if (error.response.status === 400) {
              //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
              getErrorMessage('MstComSvSettingMainComponent.vue', 'findList', '指定されたマスタが見つかりません。');
              //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
              this.$ons.notification.alert({
                // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
                // title: "取得失敗",
                // message: "指定されたマスタが見つかりません。"
                title: DIALOG_MESSAGES[12000003].title,
                message: messageFormat(DIALOG_MESSAGES[12000003].message),
                // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
              });
            }
            //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
            else{
              getErrorMessage('MstComSvSettingMainComponent.vue', 'findList', error);
            }
            //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
          });
      });
    },
    setFilterCondition(condition) {
      this.condition.recordName = condition.recordName;
      this.condition.includeDeleted = condition.includeDeleted;
      this.setCondition({ ...this.condition });
      this.$nextTick(() => {
        this.refreshDirectComsvGridDataSource();
        this.applyDirectComsvColumnsContract();
        this.scheduleDirectComsvLayoutContract();
      });
    },
    //add #12298 装置通信・仮想端末マスタにてマスタ同期失敗のメッセージに削除済みDEが表示される start
    editorDropDown(container, data) {
      const commitSelection = (value, text) => {
        this.commitDeviceEdgeNoSelection(data.model, data.field, value, text);
        requestAnimationFrame(() => {
          try {
            this.directGridWidget?.closeCell?.();
          } catch (_error) {
            // noop
          }
          this.syncDeviceEdgeNoCellText(data.model, text);
        });
      };
      $(`<input class="" name="${data.field}"/>`)
        .appendTo(container)
        .kendoDropDownList({
          dataSource: this.getDeviceEdgeList.filter(e=> e.del === '0' || e.value == data.model.deviceEdgeNo),
          dataTextField: "text",
          dataValueField: "value",
          value: data.model[data.field],
          select: e => {
            commitSelection(e.dataItem?.value, e.dataItem?.text);
          },
          change: e => {
            commitSelection(e.sender?.value?.(), e.sender?.text?.());
          }
        });
    },
    commitDeviceEdgeNoSelection(model, field, value, text) {
      if (!model || !field || value === undefined || value === null || value === "") {
        return;
      }
      const fieldInfo = this.getMasterRecordList?.schema?.model?.fields?.[field];
      const normalizedValue = fieldInfo?.type === "number" && !Number.isNaN(Number(value))
        ? Number(value)
        : String(value);
      if (typeof model.set === "function") {
        model.set(field, normalizedValue);
      } else {
        model[field] = normalizedValue;
      }
      if (model.operation === 1) {
        model.edited = true;
      }
      this.edit({ editRecord: model, isSortMode: this.isSortMode });
      this.scheduleDirectComsvRowVisualRefresh(model);
      this.syncDeviceEdgeNoCellText(model, text);
    },
    syncDeviceEdgeNoCellText(model, text) {
      if (!model) {
        return;
      }
      const displayText = text || this.getDeviceEdgeList.find(item => item.value == model.deviceEdgeNo)?.text || "";
      this.getDirectComsvRowsByRecord(model).forEach(row => {
        const cell = this.getDirectComsvCellByField(row, "deviceEdgeNo");
        if (!cell) {
          return;
        }
        cell.classList.remove("k-edit-cell", "k-grid-edit-cell");
        cell.innerHTML = "";
        cell.appendChild(cell.ownerDocument.createTextNode(displayText));
      });
    },
    //add #12298 装置通信・仮想端末マスタにてマスタ同期失敗のメッセージに削除済みDEが表示される start
    // 指定したデバイスエッジとのマスタ同期
    synchroMstMachineToDeviceEdge(list, idx) {
      // mod #6107 2023/04/04 メッセージボックス全調整 林峻峰 start
      // let title = "通信サーバーマスタ同期";
      let title = messageFormat(DIALOG_MESSAGES['00100009'].title, '通信サーバーマスタ');
      // mod #6107 2023/04/04 メッセージボックス全調整 林峻峰 end
      const infos = list;
      if (infos.length <= idx) {
        return;
      }
      const info = infos[idx];
      // マスタ同期
      this.synchroMstComSvSetting({
        facilityCd:this.facilityListValue,
        deviceEdgeNo: info.value
      })
        .then(() => {
          if (infos.length === idx + 1) {
            // 共通ローダー：表示終了
            this.setLoadingScreenVisible(false);
            if (this.errorName.length > 0){
              let name = "";
              this.errorName.forEach(e => {
                name = name + e.text + "</br>";
              });
              name = "デバイスエッジ：</br>" + name + "</br>";
              this.$ons.notification.alert({
                title: title,
                // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
                // message:
                //   name +
                //   "との同期に失敗しました。<br>デバイスエッジの装置と整合性が<br>取れていないので<br>再度「保存」を行ってください。"
                message: messageFormat(DIALOG_MESSAGES[12000320].message, name)
                // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
              });
            } else {
              this.$ons.notification.alert({
                title: title,
                // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
                // message: "マスタ同期が完了しました。"
                message: messageFormat(DIALOG_MESSAGES['00100009'].message),
                // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
              });
            }
            this.errorName = [];
          } else {
            // 次のデバイスエッジ
            this.synchroMstMachineToDeviceEdge(list, idx + 1);
          }
        })
        .catch(error => {
          if (error.response.status === 400) {
            getErrorMessage('MstComSvSettingMainComponent.vue', 'synchroMstMachineToDeviceEdge', name +'との同期に失敗しました。デバイスエッジの装置と整合性が取れていないので再度「保存」を行ってください。');

            this.errorName.push(info);
            if (infos.length === idx + 1) {
              let name = "";
              this.errorName.forEach(e => {
                name = name + e.text + "</br>";
              });
              name = "デバイスエッジ：</br>" + name + "</br>";
              //共通ローダー：表示終了
              this.setLoadingScreenVisible(false);
              this.$ons.notification.alert({
                title: title,
                // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
                // message:
                //   name +
                //   "との同期に失敗しました。<br>デバイスエッジの装置と整合性が<br>取れていないので<br>再度「保存」を行ってください。"
                message: messageFormat(DIALOG_MESSAGES[12000320].message, name)
                // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
              });
              this.errorName = [];
            } else {
              getErrorMessage('MstComSvSettingMainComponent.vue', 'synchroMstMachineToDeviceEdge', error);
              // 次のデバイスエッジ
              this.synchroMstMachineToDeviceEdge(list, idx + 1);
            }
          }
        });
    },
    saveRecord() {
      // 共通ローダー:表示開始
      this.setLoadingScreenVisible(true);
      /* add スクロールの位置を維持 楊 start */
      const preservedScrollPosition = this.getGridScrollPosition();
      this.lastscrollTop = preservedScrollPosition.top;
      this.lastscrollLeft = preservedScrollPosition.left;
      /* add スクロールの位置を維持 楊 end */
      // グリッドでエラーが発生している場合は処理を中断
      this.initDirectComsvValidator();
      if (this.kendoValidator && !this.kendoValidator.validate()) {
        // 共通ローダー：表示終了
        this.setLoadingScreenVisible(false);
        return;
      }

      // 更新前の情報をバックアップ
      this.backupMasterRecordList = JSON.parse(
        JSON.stringify(this.getMasterRecordList)
      );

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
      // 型式+製造番号、IPアドレス重複チェック
      const validateMachineInfoMessage = this.validateMachineTypeSerialNo();

      let message = "";
      if (validateMessage.length !== 0) {
        // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
        // message = "以下の列に未入力項目が存在します。" + validateMessage;
        message =  messageFormat(DIALOG_MESSAGES[12000005].message) + validateMessage;
        // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
      }
      if (validateComboMessage.length !== 0) {
        if (message.length !== 0) message = message + "</br>";
        message =
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
          // message + "以下の列の選択を見直してください。" + validateComboMessage;
          message +  messageFormat(DIALOG_MESSAGES[12000006].message) + validateMessage;
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
      }
      if (validateMachineInfoMessage.length !== 0) {
        if (message.length !== 0) message = message + "</br>";
        message =
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
          // message + "以下の項目で問題があります。" + validateMachineInfoMessage;
          message +  messageFormat(DIALOG_MESSAGES['00200071'].message) + validateMachineInfoMessage;
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
      }
      // エラーメッセージは左寄せで表示
      if (message.length !== 0) {
        // 共通ローダー：表示終了
        this.setLoadingScreenVisible(false);
        this.$ons.notification.alert({
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
          // title: "チェックエラー",
          title: DIALOG_MESSAGES[12000005].title,
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
          message: '<div style="text-align:left;">' + message + "</div>"
        });
        this.$nextTick(() => {
          this.calculateGridHeight();
          /* add スクロールの位置を維持 楊 start */
          this.setGridScrollPosition({ top: this.lastscrollTop, left: this.lastscrollLeft });
          setTimeout(() => {
            this.lastScrollTop = 0;
            this.lastScrollLeft = 0;
          }, 1000);
          /* add スクロールの位置を維持 楊 end */
        });
        return;
      }

      // デバイスエッジ一覧
      //mod #12298 装置通信・仮想端末マスタにてマスタ同期失敗のメッセージに削除済みDEが表示される start
      // const deviceEdgeList = this.getDeviceEdgeList;
      const deviceEdgeList = this.getDeviceEdgeList.filter(item => item.del !== '1');
      //mod #12298 装置通信・仮想端末マスタにてマスタ同期失敗のメッセージに削除済みDEが表示される end

      // mod 7686 修正 chen start
      // upd 8838 装置通信・仮想端末マスタの並び順がNG 修正 20230613 ztc start
      // const updateRecordList = this.getUpdateRecordList.filter(es => es.operation && es.operation > 0);
      // if (updateRecordList.length === 0) {
      //   this.setLoadingScreenVisible(false);
      //   return;
      // }
      // apiをコールして値を保存
      // this.updateRecordListByFacilityCd({facilityCd: this.facilityListValue, request: updateRecordList})
      this.updateRecordListByFacilityCd({facilityCd: this.facilityListValue, request: this.getUpdateRecordList})
      // upd 8838 装置通信・仮想端末マスタの並び順がNG 修正 20230613 ztc end
      // mod 7686 修正 chen end
        .then(response => {
          this.updateResponse = response.data;
          // this.$ons.notification.alert({
          //   title: "更新完了",
          //   message: "マスタ更新が完了しました。"
          // });
          this.isSorted = false;
          this.clearDirectComsvSortEditedVisualState();
          this.findList();

          // マスタ同期開始
          this.synchroMstMachineToDeviceEdge(deviceEdgeList, 0);
        })
        .catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
          getErrorMessage('MstComSvSettingMainComponent.vue', 'updateRecordListByFacilityCd', error);
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
          if (error.response.status === 400) {
            // 共通ローダー：表示終了
            this.setLoadingScreenVisible(false);
            this.$ons.notification.alert({
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
              // title: "更新失敗",
              title: DIALOG_MESSAGES["00300005"].title,
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
              message: error.response.data.errorMessage
            });
          }
          // 更新前の情報に戻す
          const backups = this.backupMasterRecordList;
          this.setMasterRecordList(backups);

          // グリッドのデータ再表示
          this.gridDataRefresh();
        });
    },
    validateRequired() {
      let validateMessageArr = [];
      const gridData = this.getMasterRecordList;
      // ストアに保存されているデータについて必須項目の未入力をチェックする
      for (let idx = 0; idx < gridData.data.length; idx++) {
        // スキーマ情報の件数分をチェック
        const keys = Object.keys(gridData.schema.model.fields);
        for (let keyCount = 0; keyCount < keys.length; keyCount++) {
          // バリデーションで必須が定義されている項目を対象
          const validation =
            gridData.schema.model.fields[keys[keyCount]].validation;
          if (typeof validation !== "undefined" && validation.required) {
            if (
              gridData.data[idx][keys[keyCount]] !== null &&
              gridData.data[idx][keys[keyCount]] === ""
            ) {
              // カラム名からタイトルを取得
              const columnInfo = this.columns.find(
                e => e.field == keys[keyCount]
              );
              // 項目名が重複していなければ、メッセージに追加
              validateMessageArr.push(columnInfo.title);
            }
          }
        }
      }
      return this.convertToStr(validateMessageArr);
    },
    validateComboValue() {
      // コンボ項目のfieldを取り出す
      const comboFields = this.columns
        .filter(column => column.values != null)
        .map(column => ({
          field: column.field,
          title: column.title,
          values: column.values
        }));

      // 削除されていないレコード
      const gridData = this.getMasterRecordList;
      const rows = gridData.data.filter(row => row.isDisp !== "0");
      // コンボの列を対象に、ストアの値がコンボのvaluesに存在することをチェック
      let validateMessageArr = [];
      for (let rowIdx = 0; rowIdx < rows.length; rowIdx++) {
        for (let comboIdx = 0; comboIdx < comboFields.length; comboIdx++) {
          const columnValue = rows[rowIdx][comboFields[comboIdx].field];
          // valuesにデータ値が存在せず、データ値がNullか空文字でなければエラー
          const index = comboFields[comboIdx].values.findIndex(
            e => e.value == columnValue
          );
          if (index < 0 && (columnValue !== null && columnValue !== "")) {
            validateMessageArr.push(comboFields[comboIdx].title);
          }
        }
      }
      return this.convertToStr(validateMessageArr);
    },
    // デバイスエッジの重複チェック
    validateMachineTypeSerialNo() {
      let validateMessageArr = [];
      let checkDeviceEdgeNo = [];

      // 削除されていないレコード
      const gridData = this.getMasterRecordList;
      const rows = gridData.data;
      for (let rowIdx = 0; rowIdx < rows.length; rowIdx++) {
        let rowNo = rowIdx + 1;
        // 装置名取得
        let name = rows[rowIdx]["deviceEdgeNo"];
        // 削除対象判定
        let del = rows[rowIdx]["isDisp"] === "1" ? "" : "(削除分)";
        // 装置名重複チェック
        let idxNo = 1 + checkDeviceEdgeNo.indexOf(name.toString());
        if (1 <= idxNo) {
          let dels =  rows[idxNo -1]["isDisp"]=== "1" ? "" : "(削除分)";
          // 重複あり
          let strerr =
            "デバイスエッジ重複あり：<br>　　　" +
            idxNo +
            "行目" + dels + "と" +
            rowNo +
            "行目" +
            del;
          validateMessageArr.push(strerr);
        } else {
          // 重複なし
          checkDeviceEdgeNo.push(name.toString());
        }
      }
      return this.convertToStr(validateMessageArr);
    },
    convertToStr(messageArr) {
      if (messageArr.length === 0) return "";

      const unique = messageArr.reduce((acc, cur) => {
        if (acc.indexOf(cur) === -1) {
          acc.push(cur);
        }
        return acc;
      }, []);

      const prefix = "</br>&nbsp&nbsp・";
      return prefix + unique.join(prefix);
    },
    sort() {
      const compare = (a, b) =>
        a.sortRank - b.sortRank || a.sortInputTime - b.sortInputTime;
      //グリッドデータの並び替え
      this.getMasterRecordList.data.sort(compare);
      //add 8840 装置通信・仮想端末マスタの並び順が保存できない 修正 20230613 ztc start
      let sortNum = 1;
      for (let i = 0; i < this.getMasterRecordList.data.length; i++) {
        if(this.getMasterRecordList.data[i].isDisp === '1' ) {
          this.getMasterRecordList.data[i].sortRank = sortNum;
          sortNum++;
        }
      }
      //add 8840 装置通信・仮想端末マスタの並び順が保存できない 修正 20230613 ztc end
    },
    getDirectComsvEditedKey(record) {
      const code = record?.code ?? record?.get?.("code");
      return code !== undefined && code !== null ? String(code) : null;
    },
    isSameDirectComsvValue(a, b) {
      if (a === b) {
        return true;
      }
      if (a === null || a === undefined || b === null || b === undefined) {
        return a === b;
      }
      if (String(a) === String(b)) {
        return true;
      }
      const numA = Number(a);
      const numB = Number(b);
      return Number.isFinite(numA) && Number.isFinite(numB) && numA === numB;
    },
    getDirectComsvOriginalEditValue(model, field) {
      if (!model?.uid || !field) {
        return undefined;
      }
      return this.directComsvSortEditOriginalValues.get(`${model.uid}:${field}`);
    },
    clearDirectComsvTemporaryDirty(cell) {
      if (!cell) {
        return;
      }
      cell.classList.remove("master-sort-edited", "k-dirty-cell");
      cell.querySelector?.(".k-dirty")?.remove?.();
    },
    clearDirectComsvSortEditedVisualState() {
      this.directComsvSortEditedCodes?.clear?.();
      this.directComsvSortEditOriginalValues?.clear?.();
      const data = this.directGridWidget?.dataSource?.data?.();
      if (data) {
        const items = typeof data.toJSON === "function" ? data.toJSON() : Array.from(data || []);
        items.forEach(model => {
          if (!model?.dirtyFields) {
            return;
          }
          if ("sortRank" in model.dirtyFields) {
            delete model.dirtyFields.sortRank;
          }
          if (Object.keys(model.dirtyFields).length === 0) {
            model.dirty = false;
          }
        });
      }
      const root = this.getComsvGridRoot();
      if (!root) {
        return;
      }
      root.querySelectorAll(".k-grid-content tbody tr, .k-grid-content-locked tbody tr").forEach(row => {
        this.clearDirectComsvTemporaryDirty(this.getDirectComsvCellByField(row, "sortRank"));
        this.clearDirectComsvTemporaryDirty(this.getDirectComsvCellByField(row, "dummy"));
      });
    },
    cleanupDirectComsvUnchangedSortCell(model) {
      const rows = this.getDirectComsvRowsByRecord(model);
      rows.forEach(row => {
        this.clearDirectComsvTemporaryDirty(this.getDirectComsvCellByField(row, "sortRank"));
        this.clearDirectComsvTemporaryDirty(this.getDirectComsvCellByField(row, "dummy"));
      });
    },
    onSave(ev) {
      this.editingFlg = false;
      const model = ev.model;
      const values = ev.values || {};
      const editedFields = Object.keys(values);
      const editedField = editedFields[0];
      if (this.isSortMode && editedField === "sortRank") {
        const originalValue = this.getDirectComsvOriginalEditValue(model, editedField);
        const nextValue = values[editedField];
        if (this.isSameDirectComsvValue(originalValue, nextValue)) {
          this.cleanupDirectComsvUnchangedSortCell(model);
          return;
        }
        const editedKey = this.getDirectComsvEditedKey(model);
        if (editedKey) {
          this.directComsvSortEditedCodes.add(editedKey);
        }
      }
      this.edit({ editRecord: model, isSortMode: this.isSortMode });
      if (model.operation === 1) {
        model["edited"] = true;
      }
      this.scheduleDirectComsvRowVisualRefresh(model);
    },
    cancel() {
      // 前画面に戻る
      // 編集破棄確認はMasterRecordView.vueで行う
      this.$router.go(-1);
    },
    showMasterEditModal(e) {
      // モーダル確定時にスクロール位置が戻ってしまう問題の対処
      const grid = this.getGridScrollContainer();
      this.scrollPosition.top = grid.scrollTop;
      this.scrollPosition.left = grid.scrollLeft;

      // モーダルを表示
      this.showMasterEdit();

      /**
       * 「詳細」ボタンを押下したレコードのデータを取得する。
       * see: https://www.telerik.com/forums/selected-row-at-wrappers-for-vue
       */
      e.preventDefault();
      const selectedRowItem = this.directGridWidget?.dataItem?.(e.currentTarget.closest("tr"));
      if (!selectedRowItem) {
        return;
      }
      // 確定後未保存でも一覧ストアの最新値を詳細に渡す（直连 Grid の dataItem は古いまま）
      const storeRecord = this.getMasterRecordList?.data?.find(
        record => String(record.code) === String(selectedRowItem.code)
      );
      const sourceItem = storeRecord || selectedRowItem;
      let code = sourceItem.code;

      // codeがない場合はcodeを付番
      if (!code) {
        this.edit({ editRecord: sourceItem, isSortMode: this.isSortMode });
      }

      // プロパティを正規化する。
      const normalizedItem = this.normalization(sourceItem);

      // ストアに保存する。
      this.setEditRecord(normalizedItem);
    },
    onCloseMasterEditModal() {
      this.refreshDirectComsvGridDataSource();
      this.$nextTick(() => {
        this.setScrollPosition(this.scrollPosition);
        const records = this.getDirectComsvDisplayRecords();
        records.forEach(record => {
          if (record?.operation === 2 || record?.edited || this.isEdited?.(record?.code)) {
            this.scheduleDirectComsvRowVisualRefresh(record);
          }
        });
      });
      // Androidでスクロール位置が戻らない場合があるのでもう一度設定
      setTimeout(() => {
        this.setScrollPosition(this.scrollPosition);
      }, 1000);
    },
    setScrollPosition(position) {
      this.setGridScrollPosition({ top: position.top, left: position.left });
    },
    toRankEditBtnClick() {
          // モーダル確定時にスクロール位置が戻ってしまう問題の対処
      const grid = this.getGridScrollContainer();
      this.scrollPosition.top = grid.scrollTop;
      this.scrollPosition.left = grid.scrollLeft;
      EventBus.$emit("onCloseMasterEditModal", this.onCloseMasterEditModal);
      // グリッドでエラーが発生している場合は処理を中断
      this.initDirectComsvValidator();
      if (this.kendoValidator && !this.kendoValidator.validate()) {
        return;
      }

      this.isSortMode = true;
      this.disableColumns();
      this.showSortColumn();
      EventBus.$emit("setSortMode", this.isSortMode);
    },
    addRow() {
      // グリッドでエラーが発生している場合は処理を中断
      this.initDirectComsvValidator();
      if (this.kendoValidator && !this.kendoValidator.validate()) {
        return;
      }

      // 空レコードをストアに登録
      let d = new Object();
      const fields = this.getMasterRecordList.schema.model.fields;
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
        // 通信SV専用初期値
        if (k === "offlineStartTime") {
          d[k] = null;
        }
      });
      this.lastScrollTop = this.getGridScrollHostEl()?.scrollHeight || 0;
      this.lastScrollLeft = 0;
      this.lastscrollLeft = 0;
      this.scrollPosition.left = 0;
      this.edit({ editRecord: d, isSortMode: this.isSortMode });
      this.refreshDirectComsvGridDataSource();
      this.$nextTick(() => {
        this.setGridScrollPosition({ top: this.lastScrollTop, left: 0 });
        requestAnimationFrame(() => {
          this.setGridScrollPosition({ top: this.lastScrollTop, left: 0 });
          this.scheduleDirectComsvRowVisualRefresh(d);
        });
      });
    },
    sortBtnClick() {
         // モーダル確定時にスクロール位置が戻ってしまう問題の対処
      const grid = this.getGridScrollContainer();
      this.scrollPosition.top = grid.scrollTop;
      this.scrollPosition.left = grid.scrollLeft;
      EventBus.$emit("onCloseMasterEditModal", this.onCloseMasterEditModal);

      this.syncDirectComsvSortValuesToMasterRecords();
      const tempData = JSON.parse(
        JSON.stringify(this.getMasterRecordList.data)
      );
      this.isSortMode = false;
      this.editableColumns();
      this.showSortColumn();
      this.sort();
      this.isSorted = this.sortChange(tempData);
      this.refreshDirectComsvGridDataSource();
      this.$nextTick(() => {
        this.applyDirectComsvColumnsContract();
        this.markDirectComsvSortEditedRows();
        this.setScrollPosition(this.scrollPosition);
      });
      EventBus.$emit("setSortMode", this.isSortMode);
    },
    sortChange(tempData){
      let flag = false;
      this.getMasterRecordList.data.forEach( item => {
        tempData.forEach( tempItem => {
          if(item.code === tempItem.code && item.sortRank !== tempItem.sortRank)
            flag = true;
        })
      })
      return flag;
    },
    showSortColumn() {
      // 編集・並び順設定モードによって並び順項目の表示・非表示を切り替える
      // （先頭ダミー要素列と並び順列を交互に表示・非表示する）
      const sortRankIndex = this.columns.findIndex(
        col => col.field === "sortRank"
      );
      if (sortRankIndex >= 0) {
        this.columns[sortRankIndex].hidden = !(
          this.isAllowSort && this.isSortMode
        );
        const dummyIndex = this.columns.findIndex(col => col.field === "dummy");
        if (dummyIndex >= 0) {
          this.columns[dummyIndex].hidden = !this.columns[sortRankIndex].hidden;
        }
      }
      this.$nextTick(() => {
        this.applyDirectComsvColumnsContract();
        this.scheduleDirectComsvLayoutContract();
      });
    },
    disableColumns() {
      this.columns.forEach(column => {
        // 並び順列を編集可、並び順列以外を編集不可に。
        column.editable =
          column.field == "sortRank"
            ? this.isAllowSort
              ? () => true
              : () => false
            : () => false;
      });
    },
    editableColumns() {
      this.columns.forEach(column => {
        // 編集可否の設定を初期表示時の状態に戻す
        column.editable =
          column.field == "sortRank"
            ? () => false
            : column.originalEditable
              ? () => true
              : () => false;
      });
    },
    getColumnIndex(fieldName) {
      // 指定された項目がない場合はマイナスが返る
      return this.columns.findIndex(e => e.field === fieldName);
    },
    getDirectComsvRowsByRecord(record) {
      const root = this.getComsvGridRoot();
      const grid = this.directGridWidget;
      if (!root || !grid || !record) {
        return [];
      }
      const rows = [];
      if (record.uid) {
        rows.push(...root.querySelectorAll(`tbody tr[data-uid="${record.uid}"]`));
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
    applyDirectComsvRowVisual(record) {
      const rows = this.getDirectComsvRowsByRecord(record);
      if (!rows.length) {
        return;
      }
      const lockedRows = [];
      const unlockedRows = [];
      rows.forEach(row => {
        if (row.closest?.(".k-grid-content-locked")) {
          lockedRows.push(row);
        } else {
          unlockedRows.push(row);
        }
      });
      lockedRows.forEach(row => this.changeSortColorByRow(row));
      const targetRows = unlockedRows.length ? unlockedRows : rows;
      targetRows.forEach((row, index) => {
        const currentTrc = Array.from(row.children || []);
        const currentLockTrc = Array.from((lockedRows[index] || lockedRows[0])?.children || []);
        this.changeSortColorByRow(row);
        const deleted = this.isDeleteRow(currentTrc, record);
        let edited = this.changeEditColor(currentTrc, currentLockTrc);
        if (record?.operation || record?.edited || this.isEdited?.(record?.code)) {
          edited = true;
        }
        this.changeRowColor(currentTrc, currentLockTrc, edited, deleted);
        if (deleted) {
          this.clearDirectComsvEditedVisual(currentTrc, currentLockTrc);
        }
        if (record?.operation !== 1) {
          this.changeRefErrorComboColor(currentTrc, deleted, currentLockTrc);
        }
      });
    },
    scheduleDirectComsvRowVisualRefresh(record) {
      if (!record) {
        return;
      }
      const key = record.uid || record.code || "__current__";
      if (!this.directGridRowVisualRafIds) {
        this.directGridRowVisualRafIds = markRaw(new Map());
      }
      const oldId = this.directGridRowVisualRafIds.get(key);
      if (oldId != null) {
        cancelAnimationFrame(oldId);
      }
      const rafId = requestAnimationFrame(() => {
        this.directGridRowVisualRafIds.delete(key);
        this.applyDirectComsvRowVisual(record);
      });
      this.directGridRowVisualRafIds.set(key, rafId);
    },
    editBackgroundColor() {
      this.$nextTick(() => {
        const gridHeader = this.getGridHeaderEl();
        if (!gridHeader || gridHeader.textContent === " ") {
          return;
        }
        gridHeader?.classList?.add("master-grid-header");
        // グリッドにレコードがなければ処理終了
        if (!this.getGridTableEl()?.tBodies) {
          return;
        }
        const tbodyc = this.getGridBodyRows();
        const lockTbodyc = this.getGridLockedBodyRows();
        if (!tbodyc.length) {
          return;
        }
        // add redmine 5737 デバイスエッジの設定変更後、対象のデバイスエッジの色が変わらない 宋qy start
        const gridData = this.getGridDataSource();
        if (!gridData) {
          return;
        }
        const dataItem = gridData.data;
        // add redmine 5737 デバイスエッジの設定変更後、対象のデバイスエッジの色が変わらない 宋qy end
        for (let rwCount = 0; rwCount < tbodyc.length; rwCount++) {
          const currentTrc = tbodyc[rwCount]?.children;
          if (!currentTrc) {
            continue;
          }
          // add #9863 編集時背景色表示異常の横展開 蔡 start
          const currentLockTrc = lockTbodyc[rwCount]?.children || [];
          // add #9863 編集時背景色表示異常の横展開 蔡 end
          // 並び順の色変更
          this.changeSortColorByRow(tbodyc[rwCount]);
          this.changeSortColorByRow(lockTbodyc[rwCount]);
          // 編集項目の色を変更
          let edited = this.changeEditColor(currentTrc, currentLockTrc);
          // 削除対象を判定
          const deleted = this.isDeleteRow(currentTrc, dataItem[rwCount]);

          // モーダルからの編集も色を変更する
          if (
            // mod redmine 5737 デバイスエッジの設定変更後、対象のデバイスエッジの色が変わらない 宋qy start
            dataItem[rwCount] && this.isEdited(dataItem[rwCount].code)
            // mod redmine 5737 デバイスエッジの設定変更後、対象のデバイスエッジの色が変わらない 宋qy end
          ) {
            edited = true;
          }
          // 並び順以外の項目が変更されていた場合は、削除か修正にあわせて並び順より後の項目の背景色を変更
          this.changeRowColor(currentTrc, currentLockTrc, edited, deleted);
          if (deleted) {
            this.clearDirectComsvEditedVisual(currentTrc, currentLockTrc);
          }
          // 新規追加行は参照エラーコンボ判定をスキップ（DOM未整備時の例外回避）
          if (dataItem[rwCount] && dataItem[rwCount].operation === 1) {
            continue;
          }
          // データ参照エラーコンボの背景色を変更
          // mod #9863 編集時背景色表示異常の横展開 蔡 start
          // this.changeRefErrorComboColor(currentTrc, deleted);
          this.changeRefErrorComboColor(currentTrc, deleted, currentLockTrc);
          // mod #9863 編集時背景色表示異常の横展開 蔡 end
        }
      });
    },
    isDirectComsvLockedRow(row) {
      return !!row?.closest?.(".k-grid-content-locked");
    },
    getDirectComsvVisibleColumnsForRow(row) {
      const locked = this.isDirectComsvLockedRow(row);
      return (this.columns || []).filter(column => !column.hidden && !!column.locked === locked);
    },
    getDirectComsvCellByField(row, fieldName) {
      if (!row || !fieldName) {
        return null;
      }
      const index = this.getDirectComsvVisibleColumnsForRow(row).findIndex(column => column.field === fieldName);
      if (index < 0) {
        return null;
      }
      return Array.from(row.children || [])[index] || null;
    },
    markDirectComsvSortEditedRows() {
      if (!this.directComsvSortEditedCodes?.size || !this.directGridWidget?.tbody) {
        return;
      }
      Array.from(this.directGridWidget.tbody.children() || []).forEach(row => {
        this.changeSortColorByRow(row);
      });
      const lockedRows = this.getGridLockedBodyRows();
      lockedRows.forEach(row => this.changeSortColorByRow(row));
    },
    changeSortColorByRow(row) {
      if (!row) {
        return false;
      }
      const record = this.directGridWidget?.dataItem?.(row);
      const editedKey = this.getDirectComsvEditedKey(record);
      const forceEdited = !!editedKey && this.directComsvSortEditedCodes.has(editedKey);
      const sortCell = this.getDirectComsvCellByField(row, "sortRank");
      const dummyCell = this.getDirectComsvCellByField(row, "dummy");
      const sortDirty = !!sortCell && this.isEditRow(sortCell);
      if (!sortDirty && !forceEdited) {
        return false;
      }
      sortCell?.classList?.add("master-sort-edited");
      dummyCell?.classList?.add("master-sort-edited");
      return true;
    },
    changeSortColor(currentTrc) {
      // 並び順が変更されていれば並び順とダミー項目背景色を変更
      for (let clCount = 0; clCount < currentTrc.length; clCount++) {
        if (
          this.isEditRow(currentTrc[clCount]) &&
          clCount === this.getColumnIndex("sortRank")
        ) {
          currentTrc[clCount]?.classList?.add("master-sort-edited");
          const dummyIndex = this.getColumnIndex("dummy");
          if (dummyIndex > -1) {
            currentTrc[dummyIndex]?.classList?.add("master-sort-edited");
          }
        }
      }
    },
    getDirectComsvRowColorEntries(cells) {
      const row = cells?.[0]?.parentElement;
      if (!row) {
        return Array.from(cells || []).map((cell, visibleIndex) => ({ cell, column: null, visibleIndex }));
      }
      const columns = this.getDirectComsvVisibleColumnsForRow(row);
      const domCells = Array.from(cells || []);
      if (columns.length !== domCells.length) {
        return domCells.map((cell, visibleIndex) => ({ cell, column: null, visibleIndex }));
      }
      return columns.map((column, visibleIndex) => ({
        cell: domCells[visibleIndex],
        column,
        visibleIndex,
      }));
    },
    shouldApplyDirectComsvRowColor(entry) {
      if (!entry?.cell) {
        return false;
      }
      const field = entry.column?.field || "";
      return field !== "dummy" && field !== "sortRank";
    },
    applyDirectComsvRowColorToCells(cells, addClass, removeClass) {
      this.getDirectComsvRowColorEntries(cells).forEach(entry => {
        if (!this.shouldApplyDirectComsvRowColor(entry)) {
          entry.cell.classList.remove("master-edited-row", "master-deleted-row");
          return;
        }
        entry.cell.classList.remove(removeClass);
        entry.cell.classList.add(addClass);
      });
    },
    clearDirectComsvEditedVisual(currentTrc, currentLockTrc) {
      [...Array.from(currentTrc || []), ...Array.from(currentLockTrc || [])].forEach(cell => {
        cell?.classList?.remove("master-edited-cell", "master-edited-row");
      });
    },
    changeEditColor(currentTrc, currentLockTrc = []) {
      let edited = false;
      const applyToCells = cells => {
        this.getDirectComsvRowColorEntries(cells).forEach(entry => {
          if (!entry?.cell || !this.isEditRow(entry.cell)) {
            return;
          }
          const field = entry.column?.field || "";
          if (field === "sortRank" || field === "dummy") {
            return;
          }
          entry.cell.classList.add("master-edited-cell");
          edited = true;
        });
      };
      applyToCells(currentLockTrc);
      applyToCells(currentTrc);
      return edited;
    },
    isDeleteRow(currentTrc, record = null) {
      if (String(record?.isDisp) === "0") {
        return true;
      }
      const row = currentTrc?.[0]?.parentElement;
      const isDispCell = row ? this.getDirectComsvCellByField(row, "isDisp") : null;
      if (isDispCell) {
        const text = (isDispCell.textContent || "").trim();
        if (text.indexOf("削除") >= 0 && this.isEditRow(isDispCell)) {
          return true;
        }
      }
      return false;
    },
    changeRowColor(currentTrc, currentLockTrc, edited, deleted) {
      if (!edited && !deleted) {
        return;
      }
      const addClass = deleted ? "master-deleted-row" : "master-edited-row";
      const removeClass = deleted ? "master-edited-row" : "master-deleted-row";
      this.applyDirectComsvRowColorToCells(currentLockTrc, addClass, removeClass);
      this.applyDirectComsvRowColorToCells(currentTrc, addClass, removeClass);
    },
    // mod #9863 編集時背景色表示異常の横展開 蔡 start
    // changeRefErrorComboColor(currentTrc, rowDeleted) {
    // currentLockTrc：左gridのリストを取得する
    changeRefErrorComboColor(currentUnLockTrc, rowDeleted, currentLockTrc) {
    // mod #9863 編集時背景色表示異常の横展開 蔡 end
      // 削除行は処理対象外
      if (rowDeleted) {
        return;
      }
      // add #9863 編集時背景色表示異常の横展開 蔡 start
      let currentTrc = [];
      for (let clCount = 0; clCount < currentLockTrc.length; clCount++) {
        currentTrc.push(currentLockTrc[clCount]);
      }
      for (let clCount = 0; clCount < currentUnLockTrc.length; clCount++) {
        currentTrc.push(currentUnLockTrc[clCount]);
      }
      if (currentTrc.length !== this.columns.length) {
        return;
      }
      // add #9863 編集時背景色表示異常の横展開 蔡 end
      // コンボリストが設定されていてデータが存在するが、画面表示上は空の場合は削除済みレコードを参照として背景色を変更
      for (let clCount = 0; clCount < currentTrc.length; clCount++) {
        const columnInfo = this.columns[clCount];
        const hasValueColumn = this.hasValueColumn(
          // mod #9863 編集時背景色表示異常の横展開 蔡 start
          // currentTrc[this.getColumnIndex("code")].textContent,
          currentTrc[this.getColumnIndex('code')].textContent.replaceAll(",", ""),
          // mod #9863 編集時背景色表示異常の横展開 蔡 end
          columnInfo.field
        );
        if (
          columnInfo.values !== null &&
          hasValueColumn &&
          currentTrc[clCount].textContent === ""
        ) {
          currentTrc[clCount]?.classList?.add("master-deleted-combo");
        }
      }
    },
    isEditRow(currentTd) {
      // 編集した行を判定
      return currentTd?.classList?.contains("k-dirty-cell");
    },
    normalization(items) {
      // columnの定義にあわせてデータを正規化する。
      const columnNames = this.columnDefinition.map(column => column.field);

      return Object.keys(items)
        .filter(key => columnNames.includes(key))
        .reduce((acc, key) => {
          acc[key] = items[key];
          return acc;
        }, {});
    },

    //画面表示
    loadGridData(){
      // 日機装ユーザ以外の場合
      if (this.getStateUserAccountInfo.userType !== 1) {
        // ログイン者の担当施設を選択（初期値は自分の所属する施設）
        // add マスタ一覧 1･施設切替を可能とする 王 start
        // this.facilityListValue = this.getStateUserAccountInfo.facilityCd;
        this.facilityListValue = this.getFacilitySwitch;
        // add マスタ一覧 1･施設切替を可能とする 王 end
        this.setSelectFacility(this.facilityListValue);
        // delete start #9590
        // this.setCondition(this.condition);
        // delete end #9590
        this.findList();
        return;
      }
      // apiをコールして施設一覧を取得
      this.facilityList()
        .then(() => {
          // ログイン者の担当施設を選択
          // add マスタ一覧 1･施設切替を可能とする 王 start
          // this.facilityListValue = this.getStateUserAccountInfo.facilityCd;
          this.facilityListValue = this.getFacilitySwitch;
          // add マスタ一覧 1･施設切替を可能とする 王 end
          this.setSelectFacility(this.facilityListValue);
          // delete start #9590
        // this.setCondition(this.condition);
        // delete end #9590
          this.findList();
        })
        .catch(error => {
          alert(error);
          if (error.response.status === 400) {
            //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
            getErrorMessage('MstComSvSettingMainComponent.vue', 'loadGridData', '指定されたマスタが見つかりません。');
            //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
            this.$ons.notification.alert({
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
              // title: "取得失敗",
              // message: "指定されたマスタが見つかりません。"
              title: DIALOG_MESSAGES[12000003].title,
              message: messageFormat(DIALOG_MESSAGES[12000003].message),
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
            });
          }
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
          else{
            getErrorMessage('MstComSvSettingMainComponent.vue', 'loadGridData', error);
          }
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
        });
    },
    onOpenFacility(e) {
      // 変更前の値を取得
      this.prevFacilityCd = e.sender._old;
    },
    // 施設を選択時の動作
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
                // 選択した施設を元に装置一覧の取得
                this.facilityListValue = newFacilityCd;
                this.setSelectFacility(this.facilityListValue);
                this.findList();
              } else {
                // 変更前の施設を設定する
                this.facilityListValue = this.prevFacilityCd;
              }
            }
          });
        } else {
          // 選択した施設を元に装置一覧の取得
          this.facilityListValue = e.sender._old;
          this.setSelectFacility(this.facilityListValue);
          this.findList();
        }
      }
    },

    // パンくずリストをクリックされた場合に呼び出される関数
    refresh() {
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
                 // delete start #9590
        // this.setCondition(this.condition);
        // delete end #9590
                  this.findList();
              }
            }
          });
        } else {
          // delete start #9590
        // this.setCondition(this.condition);
        // delete end #9590
          this.findList();
        }
      }
    },
    /**
     * 行をコピー追加した時の処理
     */
    addedRow() {
      this.lastScrollTop = this.getGridScrollHostEl()?.scrollHeight || 0;
      this.refreshDirectComsvGridDataSource();
      this.$nextTick(() => {
        const records = this.getDirectComsvDisplayRecords();
        const newRecord =
          [...records].reverse().find(record => record.operation === 1) ||
          records[records.length - 1];
        const scrollTop = Math.max(
          Number(this.lastScrollTop || 0),
          Number(this.getGridScrollHostEl()?.scrollHeight || 0)
        );
        this.setGridScrollPosition({ top: scrollTop, left: this.lastScrollLeft || 0 });
        if (newRecord) {
          this.scheduleDirectComsvRowVisualRefresh(newRecord);
        }
      });
    },
  },
  created() {
    this.setLoadingScreenVisible(true);
    this.loadGridData();
    // 共通ローダー:表示名設定
    this.setLoadingScreenMessage("処理中・・・");
    // 端末判別
    const ua = ((this?.$el?.ownerDocument?.defaultView?.navigator?.userAgent) || globalThis?.navigator?.userAgent || "").toLowerCase();
    if (/android/.test(ua)) {
      this.isAndroid = true;
    } else if (/iphone|ipad|mac|os/.test(ua)) {
      this.isIOS = true;
    }
    this.selfScreenName = this.$route.name;
    EventBus.$on("onCloseMasterEditModal", this.onCloseMasterEditModal);
    EventBus.$on("refresh", this.refresh);
  },
  mounted() {
    this.$nextTick(() => {
      this.calculateGridHeight();
      this.initDirectComsvValidator();
      this.initDirectComsvGridIfReady();
    });
  },
  beforeUnmount() {
    EventBus.$off("onCloseMasterEditModal", this.onCloseMasterEditModal);
    EventBus.$off("refresh", this.refresh);
    if (this.directGridLayoutRafId != null) {
      cancelAnimationFrame(this.directGridLayoutRafId);
      this.directGridLayoutRafId = null;
    }
    if (this.directGridScrollSyncRafId != null) {
      cancelAnimationFrame(this.directGridScrollSyncRafId);
      this.directGridScrollSyncRafId = null;
    }
    this.directGridRowVisualRafIds?.forEach?.(id => cancelAnimationFrame(id));
    this.directGridRowVisualRafIds?.clear?.();
    destroyJQueryValidator(this.$refs.validatorRoot || this.$el);
    this.kendoValidator = undefined;
    this.destroyDirectComsvGrid();
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
  position: absolute;
  width: inherit;
}
.kendo-grid-toolbar-style {
  --height: 100%;
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
.mst-comsv-direct-jq-grid.mst-comsv-scrollable-fill-contract :deep(.k-grid-header-wrap table),
.mst-comsv-direct-jq-grid.mst-comsv-scrollable-fill-contract :deep(.k-grid-content table) {
  width: 100% !important;
  min-width: 100% !important;
  table-layout: fixed;
}
.mst-comsv-direct-jq-grid :deep(td.master-edited-row),
.mst-comsv-direct-jq-grid :deep(tr.k-selected > td.master-edited-row),
.mst-comsv-direct-jq-grid :deep(tr.k-state-selected > td.master-edited-row),
.mst-comsv-direct-jq-grid :deep(tr.k-table-row.k-selected > td.master-edited-row) {
  color: #003300 !important;
  background-color: #ccffcc !important;
}
.mst-comsv-direct-jq-grid :deep(td.master-edited-cell) {
  color: #003300 !important;
  font-weight: bold !important;
}
.mst-comsv-direct-jq-grid :deep(td.master-sort-edited),
.mst-comsv-direct-jq-grid :deep(tr.k-selected > td.master-sort-edited),
.mst-comsv-direct-jq-grid :deep(tr.k-state-selected > td.master-sort-edited),
.mst-comsv-direct-jq-grid :deep(tr.k-table-row.k-selected > td.master-sort-edited) {
  background-color: #ffff66 !important;
}
.mst-comsv-direct-jq-grid :deep(td.master-deleted-row),
.mst-comsv-direct-jq-grid :deep(tr.k-selected > td.master-deleted-row),
.mst-comsv-direct-jq-grid :deep(tr.k-state-selected > td.master-deleted-row),
.mst-comsv-direct-jq-grid :deep(tr.k-table-row.k-selected > td.master-deleted-row),
.mst-comsv-direct-jq-grid :deep(tr.k-alt > td.master-deleted-row) {
  color: #333333 !important;
  background-color: #9d9d9d !important;
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
