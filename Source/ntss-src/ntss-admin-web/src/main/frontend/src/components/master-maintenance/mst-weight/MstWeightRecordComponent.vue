/**
 * 体重計マスタページ  MainContent
 */
<template>
  <div class='main-content-area master-maintenance-page'>
    <div v-if="isShowDetailView">
      <mst-weight-component @close="closeDetailView"/>
    </div>
    <div v-show="!isShowDetailView" class='ntss-list' :style="ntssListStyles">
      <div class="k-grid-toolbar k-header kendo-grid-toolbar-style mst-weight-direct-jq-toolbar" :style="heightStyles">
        <!-- <div class='weight-scale-area'> -->
        <mst-weight-scale-component ref="scale" :is-mobile-device="isMobileDevice" :allow-edit="allowEdit"/>
        <!-- </div> -->
        <div id="grid-header" :class="['header-btn-area', 'right', isMobileDevice ? 'mobile-header' : '']">
          <v-ons-button modifier="outline" class="btn3-normal toolbar-btn" style="float: left;" v-show="!isSortMode && isAllowAddRecord" @click="addRow()">追加</v-ons-button>
          <v-ons-button modifier="outline" class="btn3-normal toolbar-btn" style="float: left; margin-left: 10px;" v-show="!isSortMode && isAllowAddRecord" @click="copyAdd">コピー追加</v-ons-button>
          <v-ons-row v-show="isMobileDevice" style="float: left; width: 7em; height: 1em;">
            <v-ons-col width="45%" vertical-align="center">
              <label class="fab-font-color">編集</label>
            </v-ons-col>
            <v-ons-col width="55%" vertical-align="center">
              <v-ons-switch modifier="outline" style="float: left; margin-left: 2px;" v-model="allowEdit" />
            </v-ons-col>
          </v-ons-row>
          <v-ons-button modifier="outline" class="btn3-normal toolbar-btn" v-show="!isSortMode && isAllowSort" @click="toRankEditBtnClick()">並び順表示</v-ons-button>
          <v-ons-button modifier="outline" class="btn3-normal toolbar-btn" v-show="isSortMode && isAllowSort" @click="sortBtnClick()">反映</v-ons-button>
        </div>
        <div
          v-show="columns.length > 1"
          id="under-grid"
          ref="grid"
          :class="[fontSizeSet, 'ntss-kendo-grid-legacy', 'mst-weight-direct-jq-grid']"
        ></div>
      </div>
      <div id="grid-footer">
        <v-ons-row width="100%" v-show="!isSortMode" >
          <v-ons-col width="50%">
            <v-ons-button class="btn2-cancel button denial-btn" style="width: auto;" @click="cancel">キャンセル</v-ons-button>
          </v-ons-col>
          <v-ons-col width="50%" class="right">
            <v-ons-button class="btn1-execute button registration-btn" style="width: auto;" :disabled="!isChanged" @click="saveRecord">保存</v-ons-button>
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
import { mapActions, mapGetters } from "@/compat/vue/vuex";
import { markRaw } from "@/compat/vue/runtime";
import $ from "jquery";
import kendo from "@progress/kendo-ui";
import { EventBus } from "@/compat/vue/event-bus.js";
import MstWeightScaleComponent from "@/components/master-maintenance/mst-weight/MstWeightScaleListRecordComponent";
import MstWeightComponent from "@/components/master-maintenance/mst-weight/sub-item/MstWeightComponent";
import { roomBedGroup } from "@/functions/mst/MstGetters.js";

//FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start

import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
import MasterCopyAddComponent from "@/components/master-maintenance/MasterCopyAddComponent";
// #11987 2026.02.08 add スケールベッド対応 スケールベッド機能の無効・有効取得 TDC渡辺 start
import { sendRequestGetDefaultSettingDispOrder } from "@/apis/User";
import { FUNC_SCALE_BED } from "@/constants/function-code";
// #11987 2026.02.08 add スケールベッド対応 スケールベッド機能の無効・有効取得 TDC渡辺 end

import { messageFormat } from "@/functions/common/MessageFormat";
import { appendValidationCallout } from "@/compat/kendo/validator.js";

const WEIGHT_RECORD_COMPARE_OMIT_KEYS = [
  "operation",
  "edited",
  "dirty",
  "dirtyFields",
  "uid",
  "_events",
  "_handlers",
  "sortInputTime"
];

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
    "mst-weight-scale-component": MstWeightScaleComponent,
    "mst-weight-component": MstWeightComponent,
    "master-copy-add": MasterCopyAddComponent
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
      kendoValidatorSetup: {
        rules: {},
        messages: {}
      },
      isShowDetailView: false,
      //Android端末で編集中であることを示すフラグ
      isAndroid: false,
      isIOS: false,
      scrollPosition: {
        top: 0,
        left: 0
      },
      // add FNSI-データ初期種別と測定値送信間隔の制御 徐 start
      deviceClassName:"田中衡機",
      // add FNSI-データ初期種別と測定値送信間隔の制御 徐 end
      //自画面の名称
      selfScreenName: "",
      facilitylistValue: "",
      // コピー追加 吹き出し用 start
      masterCopyAddVisible: false,
      masterCopyAddTarget: null,
      // コピー追加 吹き出し用 end
      allowEdit: true, // NOTE: true = 編集モード、 false = 閲覧モード
      isSorted: false,
      lastScrollTop: 0,
      lastScrollLeft: 0,
      directGridDataSource: null,
      directGridWidget: null,
      directGridReady: false,
      directGridMounted: false,
      directGridLayoutRafId: null,
      directGridLayoutRefreshRafId: null,
      directGridFilterRefreshRafId: null,
      directGridDataRefreshRafId: null,
      directGridScrollSyncRafId: null,
      directGridColumnSignature: "",
      directGridRowVisualRafIds: markRaw(new Map()),
      directGridSortEditedCodes: markRaw(new Set()),
      directGridEditOriginals: markRaw(new Map()),
      directGridLocalChanged: false,
      weightComparisonRecordModel: "",
      weightEditedCodes: new Set(),
      weightEditTick: 0,
      isMasterRefreshConfirming: false,
      isMasterRefreshDiscarding: false,
      kendoValidator: null,
      validationTooltipPlacementIntervalId: null,
      validationTooltipPlacementTimers: [],
      validationTooltipPlacementRafId: null,
      // #11987 2025.11.13 add スケールベッド対応 スケールベッド比較文字列 TDC渡辺 start
      weightTypeNameWeight: "体重計",
      weightTypeNameScaleBed: "スケールベッド",
      // #11987 2025.11.13 add スケールベッド対応 スケールベッド比較文字列 TDC渡辺 end
      // #11987 2026.02.08 add スケールベッド対応 スケールベッド機能の無効・有効取得 TDC渡辺 start
      defaultSettingObj: [
        {
          componentName: "defScaleBedSet",
          ref: "scaleBedSettingCard",
          funcCode: FUNC_SCALE_BED,
          dispOrder: null
        },
      ],
      ScaleBedFunction: true
      // #11987 2026.02.08 add スケールベッド対応 スケールベッド機能の無効・有効取得 TDC渡辺 end
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
    ...mapGetters("user", {
      facilityCd: "getFacilityCd"
    }),
    ...mapGetters("mst-weight", {
      getIsGridEditing: "getIsGridEditing",
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_体重計マスタ 20240125 張玲 start      
      getIsChangedMstWeight:"getIsChangedMstWeight"
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_体重計マスタ 20240125 張玲 end
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
      return `font-size-set-${names[this.getFontSize] || names[1]}`;
    },
    masterConditionSignature() {
      const condition = this.$store?.state?.["master-maintenance"]?.condition || this.condition || {};
      return `${condition.recordName || ""}|${condition.includeDeleted ? 1 : 0}`;
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
      hasValueColumn: "hasValueColumn"
    }),
    // #11987 2026.01.07 add スケールベッド対応 デバックモード判定式の追加 TDC渡辺 start
    ...mapGetters("toggle-dev-tool", ["isLockDevTool"]),
    // #11987 2026.01.07 add スケールベッド対応 デバックモード判定式の追加 TDC渡辺 end
    hasWeightRecordPendingEdits() {
      void this.weightEditTick;
      return this.weightEditedCodes.size > 0;
    },
    isWeightRecordModified() {
      if (!this.weightComparisonRecordModel) {
        return false;
      }
      void this.weightEditTick;
      const data = this.collectWeightRecordsForCompare();
      return this.serializeWeightRecordsForCompare(data) !== this.weightComparisonRecordModel;
    },
    masterRecords() {
      // #11987 2026.02.09 MOD スケールベッド対応 スケールベット機能がOFFの場合、体重計種別がスケールベット物は表示させない。 TDC渡辺 start
      if (!this.getFilteredMasterRecordList || !this.getFilteredMasterRecordList.data) return {};
      if (this.ScaleBedFunction === false) {
        return {
          ...this.getFilteredMasterRecordList,
          data: this.getFilteredMasterRecordList.data.filter(row => row.weightType == 0)
        };
      }
      return {
        ...this.getFilteredMasterRecordList,
        data: this.getFilteredMasterRecordList.data
      };
      // #11987 2026.02.09 MOD スケールベッド対応 スケールベット機能がOFFの場合、体重計種別がスケールベット物は表示させない。 TDC渡辺 end
    },
    masterRecordDataLength() {
      return this.getRawMasterRecordData().length;
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
      let wsIsChanged = false;
      const refScale = this.$refs.scale;
      if (refScale) {
        wsIsChanged = refScale.isChanged;
      }
      const wIsChanged = this.getStateUserAccountInfo !== null &&
        data !== undefined &&
        (this.isWeightRecordModified || this.hasWeightRecordPendingEdits);

      // add FNSI-データ初期種別と測定値送信間隔の制御 徐 start
      this.deviceClassChange();
      // add FNSI-データ初期種別と測定値送信間隔の制御 徐 end
      return (wsIsChanged || wIsChanged);
    },
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_体重計マスタ 20240125 張玲 start      
    isChangedMstWeight(){
      return this.getIsChangedMstWeight
    },
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_体重計マスタ 20240125 張玲 end
    // grid表示データから吹き出しびプルダウンリストデータ生成
    copySrcData() {
      const data = this.getDirectGridDisplayData();
      if (!data || data.length === 0) {
        return [];
      }
      return data
        .filter(item => item.operation !== 1) // 追加行は除外
        .map(item => ({
          code: item.code,
          name: item.name
        }));
    },
    isMobileDevice() {
      return this.isIOS || this.isAndroid;
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
    masterConditionSignature() {
      this.scheduleDirectGridFilterRefresh();
    },
    masterRecordDataLength(newLength, oldLength) {
      if (!this.directGridReady || newLength === oldLength) {
        return;
      }
      this.scheduleDirectGridDataSourceRefresh({
        forceRebind: true,
        scrollToBottom: newLength > oldLength
      });
    },
    columns(val) {
      this.$nextTick(() => {
        if (val.length > 1) {
          this.initDirectGridIfReady();
          this.applyDirectGridColumnVisibilityContract();
          this.applyDirectGridColumnEditableContract();
          this.scheduleDirectGridLayoutContract();
          this.setLoadingScreenVisible(false);
        }
      });
    }
  },
  methods: {
    collectWeightRecordsForCompare() {
      const storeRows = [...this.getRawMasterRecordData()];
      const grid = this.getGridWidget();
      if (!grid?.dataSource) {
        return storeRows;
      }
      const merged = new Map(storeRows.map(row => [String(row.code), { ...row }]));
      (grid.dataSource.data() || []).forEach(model => {
        const plain = typeof model?.toJSON === "function" ? model.toJSON() : { ...model };
        if (plain.code === undefined || plain.code === null || plain.code === "") {
          return;
        }
        const key = String(plain.code);
        merged.set(key, { ...(merged.get(key) || {}), ...plain });
      });
      return Array.from(merged.values());
    },
    normalizeWeightRecordForCompare(record) {
      if (!record || typeof record !== "object") {
        return record;
      }
      const normalized = { ...record };
      WEIGHT_RECORD_COMPARE_OMIT_KEYS.forEach(key => {
        delete normalized[key];
      });
      const fields = this.getMasterRecordList?.schema?.model?.fields || {};
      Object.keys(normalized).forEach(key => {
        const fieldInfo = fields[key];
        if (!fieldInfo) {
          return;
        }
        const value = normalized[key];
        if (fieldInfo.type === "number") {
          if (value === null || value === undefined || value === "") {
            normalized[key] = null;
            return;
          }
          const numberValue = Number(String(value).replace(/,/g, "").trim());
          normalized[key] = Number.isFinite(numberValue) ? numberValue : value;
          return;
        }
        if (fieldInfo.type === "string") {
          normalized[key] = value === null || value === undefined || value === ""
            ? null
            : String(value);
        }
      });
      return normalized;
    },
    serializeWeightRecordsForCompare(data) {
      return JSON.stringify(
        (data || []).map(record => this.normalizeWeightRecordForCompare(record))
      );
    },
    isGridRecordMatchingSnapshot(record) {
      if (!this.weightComparisonRecordModel || !record) {
        return false;
      }
      const snapshot = JSON.parse(this.weightComparisonRecordModel);
      const snap = snapshot.find(item => String(item.code) === String(record.code));
      if (!snap) {
        return false;
      }
      return JSON.stringify(this.normalizeWeightRecordForCompare(record)) === JSON.stringify(snap);
    },
    isRecordDifferentFromSnapshot(rowData) {
      if (!rowData || !this.weightComparisonRecordModel) {
        return false;
      }
      const plain = typeof rowData.toJSON === "function" ? rowData.toJSON() : rowData;
      return !this.isGridRecordMatchingSnapshot(plain);
    },
    isWeightGridRecordEdited(record) {
      if (!record) {
        return false;
      }
      if (this.weightComparisonRecordModel) {
        return this.isRecordDifferentFromSnapshot(record);
      }
      return !!(record.edited || record.operation === 2 || (record.operation === 1 && record.edited));
    },
    markWeightRecordEdited(code) {
      if (code !== undefined && code !== null && code !== "") {
        if (!this.weightEditedCodes.has(String(code))) {
          this.weightEditedCodes.add(String(code));
          this.weightEditTick += 1;
        }
      }
    },
    unmarkWeightRecordEdited(code) {
      if (code !== undefined && code !== null && code !== "") {
        if (this.weightEditedCodes.delete(String(code))) {
          this.weightEditTick += 1;
        }
      }
    },
    fixStoreRowFlagsAfterRevert(code) {
      const row = this.getRawMasterRecordData().find(item => String(item.code) === String(code));
      if (!row || !this.isGridRecordMatchingSnapshot(row)) {
        return;
      }
      delete row.operation;
      delete row.edited;
      delete row.dirty;
      if (row.dirtyFields) {
        row.dirtyFields = {};
      }
    },
    applyDirectGridSaveValuesToModel(ev) {
      const model = ev?.model;
      if (!model) {
        return;
      }
      this.getDirectGridSaveFieldNames(ev).forEach(fieldName => {
        const newValue = this.getDirectGridNewValue(ev, model, fieldName);
        if (typeof model.set === "function") {
          model.set(fieldName, newValue);
        } else {
          model[fieldName] = newValue;
        }
      });
    },
    syncDirectGridModelToStore(ev) {
      const model = ev?.model;
      if (!model) {
        return;
      }
      const plain = typeof model.toJSON === "function" ? model.toJSON() : { ...model };
      const matching = this.isGridRecordMatchingSnapshot(plain);
      if (matching) {
        delete model.operation;
        delete model.edited;
        delete model.dirty;
        if (model.dirtyFields) {
          model.dirtyFields = {};
        }
        this.unmarkWeightRecordEdited(model.code);
      } else if (model.operation !== 1 && !this.isSortMode) {
        model.operation = 2;
        this.markWeightRecordEdited(model.code);
      }
      this.edit({ editRecord: model, isSortMode: this.isSortMode });
      if (matching) {
        this.$nextTick(() => this.fixStoreRowFlagsAfterRevert(model.code));
      }
    },
    getWeightSnapshotFieldValue(code, fieldName) {
      if (!this.weightComparisonRecordModel || code === undefined || code === null) {
        return undefined;
      }
      const snapshot = JSON.parse(this.weightComparisonRecordModel);
      const snap = snapshot.find(item => String(item.code) === String(code));
      if (!snap || !Object.prototype.hasOwnProperty.call(snap, fieldName)) {
        return undefined;
      }
      return snap[fieldName];
    },
    setWeightComparisonRecordModel() {
      const data = this.collectWeightRecordsForCompare();
      this.weightComparisonRecordModel = this.serializeWeightRecordsForCompare(data);
    },
    ...mapActions("multi-modal", ["showMasterEdit"]),
    ...mapActions("master-maintenance", [
      "updateRecordListByFacilityCd",
      "findRecordListByFacilityCd",
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
    ...mapActions("mst-weight", {
      setIsGridEditing: "setIsGridEditing",
      requestMst2MntTable: "requestMst2MntTable",
      requestMst2MntTableByFacilityCd: "requestMst2MntTableByFacilityCd",
      // #11987 2026.05.08 add 体重計マスタの変更をアプリに通知 TDC片口 start
      requestMstChangedNotify: "requestMstChangedNotify",
      // #11987 2026.05.08 add 体重計マスタの変更をアプリに通知 TDC片口 end
    }),
    getMasterDocument() {
      return this.$el?.ownerDocument || (typeof document !== "undefined" ? document : null);
    },
    getMasterOwnerWindow() {
      return this.getMasterDocument()?.defaultView || (typeof window !== "undefined" ? window : null);
    },
    getMasterViewportBaseHeight() {
      const doc = this.getMasterDocument();
      const header = doc ? Array.prototype.slice.call(doc.getElementsByClassName("header")).pop() : null;
      const footerMenu = doc?.getElementById("footer-menu");
      return {
        hh: header?.clientHeight || 0,
        fmh: this.isDispMenu === 1 ? (footerMenu?.clientHeight || 0) : 0
      };
    },
    getMasterGridFooterHeight(defaultValue = 0) {
      return this.getMasterDocument()?.getElementById("grid-footer")?.clientHeight || defaultValue;
    },
    getMasterHeaderButtonAreaHeight(defaultValue = 0) {
      return this.$el?.querySelector?.(".header-btn-area")?.clientHeight || defaultValue;
    },
    getGridRootElement() {
      return this.$refs.grid || null;
    },
    getUnderGridElement() {
      return this.getGridRootElement();
    },
    getGridWidget() {
      return this.directGridWidget || $(this.getGridRootElement()).data("kendoGrid") || null;
    },
    getGridDataSource() {
      return this.getGridWidget()?.dataSource || null;
    },
    getGridContentElement() {
      return this.getGridRootElement()?.querySelector?.(".k-grid-content") || null;
    },
    getGridLockedContentElement() {
      return this.getGridRootElement()?.querySelector?.(".k-grid-content-locked") || null;
    },
    getGridScrollContainer() {
      return this.getGridContentElement();
    },
    getGridScrollHostEl() {
      return this.getGridContentElement();
    },
    getGridHeaderEl() {
      return this.getGridRootElement()?.querySelector?.(".k-grid-header") || this.getGridRootElement()?.firstElementChild || null;
    },
    getGridTableEl() {
      return this.getGridContentElement()?.querySelector?.("table") || null;
    },
    getGridLockedTableEl() {
      return this.getGridLockedContentElement()?.querySelector?.("table") || null;
    },
    getGridBodyRows() {
      return Array.from(this.getGridTableEl()?.tBodies?.[0]?.rows || []);
    },
    getGridLockedBodyRows() {
      return Array.from(this.getGridLockedTableEl()?.tBodies?.[0]?.rows || []);
    },
    getGridScrollPosition() {
      const content = this.getGridContentElement();
      return { top: content?.scrollTop || 0, left: content?.scrollLeft || 0 };
    },
    setGridScrollPosition(position = {}) {
      const content = this.getGridContentElement();
      const locked = this.getGridLockedContentElement();
      if (content) {
        content.scrollTop = position.top || 0;
        content.scrollLeft = position.left || 0;
        content.dispatchEvent?.(new Event("scroll"));
      }
      if (locked) {
        locked.scrollTop = position.top || 0;
      }
    },
    storeDirectGridScrollPosition() {
      const pos = this.getGridScrollPosition();
      this.scrollPosition.top = pos.top;
      this.scrollPosition.left = pos.left;
      this.lastScrollTop = pos.top;
      this.lastScrollLeft = pos.left;
    },
    restoreDirectGridScrollPosition() {
      const gridContent = this.getGridContentElement();
      if (!gridContent) {
        return;
      }
      const top = this.scrollPosition.top ?? this.lastScrollTop ?? 0;
      const left = this.scrollPosition.left ?? this.lastScrollLeft ?? 0;
      this.setGridScrollPosition({ top, left });
    },
    scheduleDirectGridPostLayoutRefresh() {
      if (this.directGridLayoutRefreshRafId != null) {
        cancelAnimationFrame(this.directGridLayoutRefreshRafId);
      }
      this.directGridLayoutRefreshRafId = requestAnimationFrame(() => {
        this.applyDirectGridLockedWidthContract();
        this.applyDirectGridLockedHeightContract();
        this.directGridLayoutRefreshRafId = requestAnimationFrame(() => {
          this.directGridLayoutRefreshRafId = null;
          this.applyDirectGridLockedWidthContract();
          this.applyDirectGridLockedHeightContract();
          this.restoreDirectGridScrollPosition();
        });
      });
    },
    getAlertDialogs() {
      const doc = this.getMasterDocument();
      return Array.from(doc?.getElementsByTagName?.("ons-alert-dialog") || []);
    },
    prehideCopyAddPopover() {
      this.masterCopyAddVisible = false;
      this.masterCopyAddTarget = null;
    },
    scheduleMasterGridScrollToAddedRow() {
      this.$nextTick(() => {
        const content = this.getGridContentElement();
        if (content) {
          content.scrollTop = content.scrollHeight;
          this.syncDirectGridLockedScrollContract();
        }
      });
    },
    // Windowの高さからGirdコンポーネント領域の高さを算出
    calculateGridHeight() {
      if (!this.getIsGridEditing) {
        const wh = this.windowHeight;
        const { hh, fmh } = this.getMasterViewportBaseHeight();
        this.kendoGridToolbarHeight = wh - hh - fmh - 1;
        this.kendoGridToolbarHeight =
          this.kendoGridToolbarHeight < 240 ? 240 : this.kendoGridToolbarHeight;
        const wsa = this.$refs.scale?.$el || this.$refs.scale || null;
        let wsah = wsa ? wsa.clientHeight : 100;
        wsah = wsah < 100 ? 100 : wsah;
        const gfh = this.getMasterGridFooterHeight(0);
        let tableToolbar = this.getMasterHeaderButtonAreaHeight(0);
        this.kendoGridHeight = this.kendoGridToolbarHeight - (gfh + wsah + tableToolbar);
      }
    },

    getCurrentTextInputElement() {
      return this.$el?.querySelector?.('.k-input.k-textbox') || null;
    },
    getCurrentNumericTextBoxElement() {
      return this.$el?.querySelector?.('.k-numerictextbox') || null;
    },
    async editStart(e) {
      if (this.isMobileDevice && !this.allowEdit) {
        /* NOTE:
         * モバイル系は、スワイプ・フリック操作で入力パッドが表示される。
         * そのため、スクロール操作が損なわれるので、閲覧モードのときは
         * 後続のイベントを発火させないように制御する。
         */
        e.preventDefault();
        return;
      }
      if (this.isAndroid) {
        await this.setIsGridEditing(true);
      }
      this.captureDirectGridEditOriginal(e);
      // #8745 マウスが止まると中国語のtipsが現れました 林峻峰 start
      this.$nextTick(()=>{
        if (e.sender?.editable?.options?.fields?.field === 'isDisp') {
          const element = this.getGridScrollContainer();
          if (element) {
            element.scrollTo({
              left: element.scrollWidth - element.clientWidth,
              behavior: 'smooth'
            });
          }
        }
        this.getCurrentTextInputElement()?.setAttribute('title', '');
      })
      // #8745 マウスが止まると中国語のtipsが現れました 林峻峰 end
    },
    editEnd() {
      this.flushDirectGridEditorValue();
      this.setIsGridEditing(false);
    },
    addInputAssist() {
      // iOS/PWA環境でスピナーをタップすると編集が終了してしまう現象の対策
      if (this.isIOS) {
        const numericTextBox = this.getCurrentNumericTextBoxElement();
        if (numericTextBox) {
          let spinnerObj = numericTextBox.getElementsByClassName("k-select")[0];
          // 編集が終了するとオブジェクトが削除されるため、removeEvent処理は不要
          spinnerObj.ontouchend = event => event.stopPropagation();
        }
      }
    },
    // マスタ一覧のデータを取得
    findList() {
      this.directGridSortEditedCodes?.clear?.();
      // apiをコールして値を取得
      // mod マスタ一覧 1･施設切替を可能とする 孔 this.findRecordList => this.findRecordListByFacilityCd
      // this.findRecordList()
      this.findRecordListByFacilityCd(this.facilitylistValue)
        .then(response => {
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
          });
          // 透析室コンボボックス用データ取得
          // mod マスタ一覧 1･施設切替を可能とする 孔 this.facilityCd => this.facilitylistValue
          // roomBedGroup(this.facilityCd).then(response => {
          roomBedGroup(this.facilitylistValue).then(roomBedGroupResponse => {
            let roomBedGroupList = [
              {
                // mod FNSI-透析室コンボボックス用データの制御 徐 start
                // value: null,
                // text: " "
                value: "0",
                text: "なし"
                // mod FNSI-透析室コンボボックス用データの制御 徐 end
              }
            ];
            for (const r of roomBedGroupResponse) {
              if (r.isDel !== "1" && r.groupClass === 2) {
                // 有効な透析室
                roomBedGroupList.push({
                  value: r.roomBedGroupCd,
                  text: r.roomBedGroupName
                });
              }
            }
            toFunction.forEach(column => {
              // デバイスエッジコンボ用データを追加
              if (column.field === "bedGroupCd") {
                column.values = roomBedGroupList;
              }
            });
            this.directGridDataSource = markRaw(response.data?.localDataSource || this.getMasterRecordList || {});
            this.columns = toFunction;

            // 横スクロールバーを表示するために列幅を指定
            this.columns.forEach(column => {
              // 「削除」のプルダウンが改行しない幅に調整
              // add FNSI-redmine3987 徐 start
              // column.width = column.field === "isDisp" ? "8em" : "14em";
              // mod redmine 4526 小の時に生じる（削除プルダウンのレイアウト不正） 宋qy start
              // mod #7289-マスタの削除ボタンが縦表示になる 徐博 start
              // column.width = column.field === "isDisp" ? "8.3em" : "15em";
              column.width = column.field === "isDisp" ? "9em" : "15em";
              // mod #7289-マスタの削除ボタンが縦表示になる 徐博 end
              // mod redmine 4526 小の時に生じる（削除プルダウンのレイアウト不正） 宋qy end
              // add FNSI-redmine3987 徐 end
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
            this.applyWeightSchemaValidationMessages(this.directGridDataSource?.schema);
            // カラム幅等初期調整
            this.showSortColumn();
            this.$nextTick(() => {
              this.calculateGridHeight();
              this.initDirectGridIfReady();
              this.applyDirectGridDataSourceContract();
              this.scheduleDirectGridLayoutContract();
              this.scheduleDirectGridPostLayoutRefresh();
              this.restoreDirectGridScrollPosition();
              requestAnimationFrame(() => {
                this.restoreDirectGridScrollPosition();
              });
              this.$nextTick(() => {
                this.weightEditedCodes.clear();
                this.weightEditTick += 1;
                this.setWeightComparisonRecordModel();
                this.directGridLocalChanged = false;
              });
            });
          });
        })
        .catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
          getErrorMessage('MstWeightRecordComponent.vue', 'findList', '指定されたマスタが見つかりません。');
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
    },
    setFilterCondition(condition) {
      this.condition.recordName = condition.recordName;
      this.condition.includeDeleted = condition.includeDeleted;
    },
    async saveRecord() {
      // 共通ローダー:表示開始
      this.setLoadingScreenVisible(true);
      //イベント発生前のスクロールバーの位置を保持
      this.storeDirectGridScrollPosition();
      // グリッドでエラーが発生している場合は処理を中断
      if (!this.kendoValidator.validate()) {
        //共通ローダー：表示終了
        this.setLoadingScreenVisible(false);
        return;
      }
      // まずは子コンポーネントの保存処理から
      const childRes = await this.$refs.scale.saveRecord();
      if (childRes.response === -2) {
        // グリッドでエラー
        //共通ローダー：表示終了
        this.setLoadingScreenVisible(false);
        return;
      } else if (childRes.response < 0) {
        //共通ローダー：表示終了
        this.setLoadingScreenVisible(false);
        // チェックエラー
        this.$ons.notification.alert({
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
          // title: "チェックエラー",
          title: DIALOG_MESSAGES["00300006"].title,
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
          message:
            '<div style="text-align:left;">' + childRes.message + "</div>"
        });
        return;
      } else if (childRes.response === 0) {
        //共通ローダー：表示終了
        this.setLoadingScreenVisible(false);
        // 保存失敗
        this.$ons.notification.alert({
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
          // title: "更新失敗",
          title: DIALOG_MESSAGES["00300005"].title,
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
          message: childRes.message
        });
        return;
      }

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
      // 体重計番号 重複チェック
      const validateWeightMessage = this.validateWeightSetting();

      let message = "";
      if (validateMessage.length !== 0) {
        // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
        // message = "以下の列に未入力項目が存在します。" + validateMessage;
        message = messageFormat(DIALOG_MESSAGES[12000270].message) + validateMessage;
        // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
      }
      if (validateComboMessage.length !== 0) {
        if (message.length !== 0) message = message + "</br>";
        message =
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
          // message + "以下の列の選択を見直してください。" + validateComboMessage;
          message +  messageFormat(DIALOG_MESSAGES[12000006].message) + validateComboMessage;
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
      }
      if (validateWeightMessage.length !== 0) {
        if (message.length !== 0) message = message + "</br>";
        message =
          message +  messageFormat(DIALOG_MESSAGES['00200071'].message) + validateWeightMessage;
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
        return;
      }

      // mod FNSI-データ初期種別と測定値送信間隔の制御 徐 start
      if (this.getMasterRecordList.data !== undefined) {
        for (var i = 0; i < this.getMasterRecordList.data.length; i++) {
          var row = this.getMasterRecordList.data[i];
          if (row.deviceClass !== "1") {
            row.dataSelectType = "";
            row.dataSendInterval = "";
          }
        }
      }
      // mod FNSI-データ初期種別と測定値送信間隔の制御 徐 end

      // apiをコールして値を保存
      // add マスタ一覧 1･施設切替を可能とする 孔s start
      const objArgs = {
        facilityCd: this.facilitylistValue,
        request: this.getUpdateRecordList
      }
      // add マスタ一覧 1･施設切替を可能とする 孔s end
      // mod マスタ一覧 1･施設切替を可能とする 孔s this.updateRecordList => this.updateRecordListByFacilityCd
      // this.updateRecordList(this.getUpdateRecordList)
      this.updateRecordListByFacilityCd(objArgs)
        .then(response => {
          this.updateResponse = response.data;
          // メンテナンステーブルへの反映
          // mod マスタ一覧 1･施設切替を可能とする 孔 this.requestMst2MntTable => this.requestMst2MntTableByFacilityCd
          // this.requestMst2MntTable()
          this.requestMst2MntTableByFacilityCd(this.facilitylistValue)
            .then(() => {
              // #11987 2026.05.08 add 体重計マスタの変更をアプリに通知 TDC片口 start
              const updateWeightNos = this.getUpdateRecordList
                .filter(item => item.weightNo)
                .map(item => item.weightNo);
              return this.requestMstChangedNotify({
                facilityCd: this.facilitylistValue,
                weightNoList: updateWeightNos ?? []
              });
              // #11987 2026.05.08 add 体重計マスタの変更をアプリに通知 TDC片口 end
            })
            .then(() => {
              //共通ローダー：表示終了
              this.setLoadingScreenVisible(false);
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
              this.setGridScrollPosition({
                top: this.scrollPosition.top,
                left: this.scrollPosition.left
              });
              //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
              getErrorMessage('MstWeightRecordComponent.vue', 'saveRecord', error);
              //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
              //共通ローダー：表示終了
              this.setLoadingScreenVisible(false);
              if (error.response.status === 400) {
                this.$ons.notification.alert({
                  // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
                  // title: "更新失敗",
                  title: DIALOG_MESSAGES["00300005"].title,
                  // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
                  message: error.response.data.errorMessage
                });
              } else {
                this.$ons.notification.alert({
                  // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
                  // title: "更新失敗",
                  title: DIALOG_MESSAGES["00300005"].title,
                  // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
                  message: error
                });
              }
            });
        })
        .catch(error => {
            this.setGridScrollPosition({
              top: this.scrollPosition.top,
              left: this.scrollPosition.left
            });
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
          getErrorMessage('MstWeightRecordComponent.vue', 'saveRecord', error);
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
          //共通ローダー：表示終了
          this.setLoadingScreenVisible(false);
          if (error.response.status === 400) {
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
    validateWeightSetting() {
      let validateMessageArr = [];
      let checkWeightNo = [];
      let checkWeightName = [];

      // 削除されていないレコード
      const gridData = this.getMasterRecordList;
      const rows = gridData.data;
      for (let rowIdx = 0; rowIdx < rows.length; rowIdx++) {
        let rowNo = rowIdx + 1;
        // 名称取得
        let name = rows[rowIdx]["name"];
        // 体重計番号取得
        let wNo = rows[rowIdx]["weightNo"];
        // 削除対象判定
        let del = rows[rowIdx]["isDisp"] === "1" ? "" : "(削除分)";

        // 体重計番号重複チェック
        let idxNo = 1 + checkWeightNo.indexOf(wNo);
        if (1 <= idxNo) {
          // 重複あり
          let strerr =
            // mod FNSI-体重計番号重複チェックメッセージ編集 徐 start
            // "体重計番号重複あり：<br>" +
            "体重計番号重複あり（削除分含む）：<br>　　　" +
            // mod FNSI-体重計番号重複チェックメッセージ編集 徐 end
            idxNo +
            "行目と" +
            rowNo +
            "行目" +
            del;
          validateMessageArr.push(strerr);
        } else {
          // 重複なし
          checkWeightNo.push(wNo);
        }

        // 体重計名重複チェック
        idxNo = 1 + checkWeightName.indexOf(name);
        if (1 <= idxNo) {
          // 重複あり
          let strerr =
            // mod FNSI-名称重複チェックメッセージ編集 徐 start
            // "名称重複あり：<br>" +
            "名称重複あり（削除分含む）：<br>　　　" +
            // mod FNSI-名称重複チェックメッセージ編集 徐 end
            idxNo +
            "行目と" +
            rowNo +
            "行目" +
            del;
          validateMessageArr.push(strerr);
        } else {
          // 重複なし
          checkWeightName.push(name);
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
      // add #11001 並び順の変更後反映を押しても並び順が切り替わらない。 zhangyue start 
      for (let i = 0; i < this.getMasterRecordList.data.length; i++) {
        this.getMasterRecordList.data[i].sortRank = i + 1; 
      }
      // add #11001 並び順の変更後反映を押しても並び順が切り替わらない。 zhangyue end 
    },
    onSave(ev) {
      //イベント発生前のスクロールバーの位置を保持
      const position = this.getGridScrollPosition();
      this.scrollPosition.top = position.top;
      this.scrollPosition.left = position.left;
      this.setIsGridEditing(false);
      this.applyDirectGridSaveValuesToModel(ev);
      const plain = typeof ev.model?.toJSON === "function" ? ev.model.toJSON() : { ...ev.model };
      const matching = this.isGridRecordMatchingSnapshot(plain);
      const changedFields = this.getDirectGridActualChangedFields(ev);
      if (!matching) {
        if (ev.model.operation === 1) {
          ev.model.edited = true;
        } else if (!this.isSortMode) {
          ev.model.operation = 2;
        }
        this.markWeightRecordEdited(ev.model.code);
        if (this.isSortMode && changedFields.includes("sortRank")) {
          this.markDirectGridSortEdited(ev.model);
        }
        changedFields.forEach(fieldName => {
          ev.model.dirtyFields = ev.model.dirtyFields || {};
          ev.model.dirtyFields[fieldName] = true;
          this.clearDirectGridEditOriginal(ev.model, fieldName);
        });
        if (changedFields.length > 0) {
          ev.model.dirty = true;
        }
        this.edit({ editRecord: ev.model, isSortMode: this.isSortMode });
      } else {
        this.unmarkWeightRecordEdited(ev.model.code);
        delete ev.model.operation;
        delete ev.model.edited;
        delete ev.model.dirty;
        if (ev.model.dirtyFields) {
          ev.model.dirtyFields = {};
        }
        changedFields.forEach(fieldName => this.clearDirectGridEditOriginal(ev.model, fieldName));
        this.edit({ editRecord: ev.model, isSortMode: this.isSortMode });
        this.$nextTick(() => this.fixStoreRowFlagsAfterRevert(ev.model.code));
      }
      this.scheduleDirectGridRowVisualRefresh(ev.model, ev.model?.uid);
      this.scheduleDirectGridLayoutContract();
    },
    onDataBoundKendoGrid() {
      this.applyDirectGridLegacyStyleContract();
      this.refreshDirectGridDirtyVisualState();
      this.scheduleDirectGridLayoutContract();
      if (this.scrollPosition.top > 0 || this.scrollPosition.left > 0) {
        this.$nextTick(() => this.setGridScrollPosition(this.scrollPosition));
      }
    },
    cancel() {
      // 前画面に戻る
      // 編集破棄確認はMasterRecordView.vueで行う
      this.$router.go(-1);
    },
    showMasterEditView(e) {
      // モーダル確定時にスクロール位置が戻ってしまう問題の対処
      const { top: scrollTop, left: scrollLeft } = this.getGridScrollPosition();
      this.scrollPosition.top = scrollTop;
      this.scrollPosition.left = scrollLeft;
      // 次画面を表示
      this.isShowDetailView = true;
      EventBus.$emit("setIsDetailHeaderView", true);

      /**
       * 「詳細」ボタンを押下したレコードのデータを取得する。
       * see: https://www.telerik.com/forums/selected-row-at-wrappers-for-vue
       */
      e.preventDefault();
      const row = this.getGridWidget();
      const selectedRowItem = row?.dataItem?.(e.currentTarget.closest("tr"));
      let code = selectedRowItem.code;

      // codeがない場合はcodeを付番
      if (!code) {
        this.edit({ editRecord: selectedRowItem, isSortMode: this.isSortMode });
      }

      // 詳細画面で確定した直後は、GridのdataItemが古い場合があるため、storeの最新行を優先する。
      const latestStoreItem = this.getMasterRecordList?.data?.find?.(
        masterRecord => String(masterRecord.code) === String(code)
      );
      const editSourceItem = latestStoreItem || selectedRowItem;

      // プロパティを正規化する。
      const normalizedItem = this.normalization(editSourceItem);

      // ストアに保存する。
      this.setEditRecord(normalizedItem);
    },
    onCloseMasterEditModal() {
      this.$nextTick(() => {
        this.setScrollPosition(this.scrollPosition);
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
      this.scrollPosition.top = grid?.scrollTop || 0;
      this.scrollPosition.left = grid?.scrollLeft || 0;
      EventBus.$emit("onCloseMasterEditModal", this.onCloseMasterEditModal);
      // グリッドでエラーが発生している場合は処理を中断
      if (!this.kendoValidator.validate()) {
        return;
      }

      this.isSortMode = true;
      this.disableColumns();
      this.showSortColumn();
      EventBus.$emit("setSortMode", this.isSortMode);
    },
    getMaxSortRank() {
      const data = this.getRawMasterRecordData();
      return data.reduce((max, record) => {
        const rank = Number(record?.sortRank);
        return Number.isFinite(rank) && rank > max ? rank : max;
      }, 0);
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

        // 初期時、新しいレコードに全レコードの並び順の最大値をセット
        if (k === "sortRank") {
          d[k] = this.getMaxSortRank() + 1;
        }
      });
      if (Object.prototype.hasOwnProperty.call(d, "code")) {
        d.code = null;
      }
      if (Object.prototype.hasOwnProperty.call(d, "isDisp")) {
        d.isDisp = "1";
      }
      if (Object.prototype.hasOwnProperty.call(d, "isDel")) {
        d.isDel = "0";
      }
      this.lastScrollTop = this.getGridScrollHostEl()?.scrollHeight;
      this.lastScrollLeft = 0;
      this.scrollPosition.left = 0;
      this.edit({ editRecord: d, isSortMode: this.isSortMode });
      this.directGridLocalChanged = true;
      this.applyDirectGridDataSourceContract({ forceRebind: true, scrollToBottom: true });
      this.scheduleDirectGridDataSourceRefresh({ forceRebind: true, scrollToBottom: true });
      this.$nextTick(() => {
        const content = this.getGridContentElement();
        if (content) {
          content.scrollTop = content.scrollHeight;
          content.scrollLeft = 0;
          this.syncDirectGridLockedScrollContract();
        }
        requestAnimationFrame(() => {
          const gridContent = this.getGridContentElement();
          if (gridContent) {
            gridContent.scrollTop = gridContent.scrollHeight;
            gridContent.scrollLeft = 0;
            this.syncDirectGridLockedScrollContract();
          }
        });
      });
    },
    sortBtnClick() {
      this.isSortMode = false;
      this.isSorted = true;
      this.editableColumns();
      this.showSortColumn();
      this.syncDirectGridSortRankToStore();
      this.sort();
      if (this.directGridSortEditedCodes?.size > 0) {
        this.directGridLocalChanged = true;
      }
      this.applyDirectGridDataSourceContract();
      EventBus.$emit("setSortMode", this.isSortMode);
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
      // #11987 2026.02.08 add スケールベッド対応 スケールベッド機能がONの場合のみ表示する。 TDC渡辺 start
      const weightTypeIndex = this.columns.findIndex(col => col.field === "weightType");
      if (weightTypeIndex >= 0) {
        this.columns[weightTypeIndex].hidden = this.ScaleBedFunction === false;
      }
      // #11987 2026.02.08 add スケールベッド対応 スケールベッド機能がONの場合のみ表示する。 TDC渡辺 end
      this.applyDirectGridColumnVisibilityContract();
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
      this.applyDirectGridColumnEditableContract();
    },
      copyAdd(e) {
      const scrollHost = this.getGridScrollContainer();
      const inner = scrollHost?.lastChild || scrollHost;
      this.scrollPosition.top =
        typeof inner?.scrollHeight === "number"
          ? inner.scrollHeight
          : typeof scrollHost?.scrollHeight === "number"
            ? scrollHost.scrollHeight
            : 0;
      // グリッドでエラーが発生している場合は処理を中断
      if (this.kendoValidator && !this.kendoValidator.validate()) {
        return;
      }
      this.masterCopyAddTarget = e.target;
      this.masterCopyAddVisible = true;
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
      this.applyDirectGridColumnEditableContract();
    },
    getColumnIndex(fieldName) {
      // 指定された項目がない場合はマイナスが返る
      return this.columns.findIndex(e => e.field === fieldName);
    },
    // #8519 編集した項目のバッググラウンドが黄緑にならない 訾浩 start
    editBackgroundColor(masterName = null) {
      this.$nextTick(() => {
        // グリッドが表示されていなかったら処理終了
        const gridHeader = this.getGridHeaderEl();
        if (!gridHeader || gridHeader.textContent === ' ') {
          return;
        }
        gridHeader?.classList?.add('master-grid-header');

        // グリッドにレコードがなければ処理終了
        if (!this.getGridTableEl()?.tBodies) {
          return;
        }
        // 固定列、可変列、データソースの取得
        const tbodyc = this.getGridBodyRows();
        const lockTbodyc = this.getGridLockedBodyRows();
        const gridData = this.getGridDataSource();
        if (!gridData) {
          return;
        }
        const dataItem = this.getDirectGridDataItems(gridData);
        // 列の行数は固定・可変で同一なため可変列の行数を使用
        for (let rwCount = 0; rwCount < tbodyc.length; rwCount++) {
          const currentTrc = tbodyc[rwCount].children;
          const currentLockTrc = lockTbodyc[rwCount]?.children || [];
          const currentRecord = dataItem[rwCount];
          // 並び順の色変更
          const sortEdited = this.changeSortColor(currentLockTrc, currentTrc, currentRecord);
          // 編集項目の色を変更
          let edited = this.changeEditColor(currentTrc, currentLockTrc) || sortEdited;
          // 削除対象を判定
          const deleted = this.isDeleteRow(currentTrc, currentRecord);

          // モーダルからの編集も色を変更する
          if (
            currentRecord && this.isEdited(currentRecord.code)
          ) {
            edited = true;
          }
          // 対応範囲のテーブルのみ、operation = 1 (新規) の行に、k-dirty-cell" を入れる
          if (masterName != null
              && masterName === 'mst_alarm_notification'
              && currentRecord?.operation
              && currentRecord.operation === 1) {
            edited = true;
          }
          // 並び順以外の項目が変更されていた場合は、削除か修正にあわせて並び順より後の項目の背景色を変更
          this.changeRowColor(currentTrc, currentLockTrc, edited, deleted);
          // add FNSI-8131 劉全航 start
          if(currentRecord && currentRecord.operation && currentRecord.operation == 1){
            continue;
          }
          // add FNSI-8131 劉全航 end
          // #8519 編集した項目のバッググラウンドが黄緑にならない 訾浩 end
          // データ参照エラーコンボの背景色を変更
          // mod #9863 編集時背景色表示異常の横展開 蔡 start
          // this.changeRefErrorComboColor(currentTrc, deleted);
          this.changeRefErrorComboColor(currentTrc, deleted, currentLockTrc);
          // mod #9863 編集時背景色表示異常の横展開 蔡 end
        }
      });
    },
    getDirectGridDataItems(gridData = this.getGridDataSource()) {
      if (!gridData) {
        return [];
      }
      if (this.masterPhysicalName === 'mst_exam_item' && Array.isArray(gridData._data)) {
        return gridData._data;
      }
      if (Array.isArray(gridData.data)) {
        return gridData.data;
      }
      if (typeof gridData.data === "function") {
        return Array.from(gridData.data() || []);
      }
      if (Array.isArray(gridData._data)) {
        return gridData._data;
      }
      return [];
    },
    getDirectGridRecordKey(record) {
      if (!record) {
        return null;
      }
      if (record.code !== undefined && record.code !== null && record.code !== "") {
        return `code:${String(record.code)}`;
      }
      if (record.uid !== undefined && record.uid !== null && record.uid !== "") {
        return `uid:${String(record.uid)}`;
      }
      return null;
    },
    markDirectGridSortEdited(record) {
      const key = this.getDirectGridRecordKey(record);
      if (key) {
        this.directGridSortEditedCodes?.add?.(key);
      }
    },
    isDirectGridSortEditedRecord(record) {
      const key = this.getDirectGridRecordKey(record);
      return !!key && !!this.directGridSortEditedCodes?.has?.(key);
    },
    getDirectSortColorRowFromCells(currentTrc) {
      return Array.from(currentTrc || [])[0]?.parentElement || null;
    },
    isDirectSortColorLockedRow(row) {
      return !!row?.closest?.(".k-grid-content-locked");
    },
    getDirectSortColorVisibleColumnsForRow(row) {
      const locked = this.isDirectSortColorLockedRow(row);
      return (this.columns || [])
        .map((column, sourceIndex) => ({ column, sourceIndex }))
        .filter(entry => !entry.column.hidden && !!entry.column.locked === locked);
    },
    getDirectSortColorCellEntryByField(row, fieldName) {
      if (!row || !fieldName) {
        return null;
      }
      const entries = this.getDirectSortColorVisibleColumnsForRow(row);
      const index = entries.findIndex(entry => entry.column.field === fieldName);
      if (index < 0) {
        return null;
      }
      return {
        cell: Array.from(row.children || [])[index] || null,
        column: entries[index].column,
        sourceIndex: entries[index].sourceIndex,
        visibleIndex: index
      };
    },
    getDirectSortColorCellByField(row, fieldName) {
      return this.getDirectSortColorCellEntryByField(row, fieldName)?.cell || null;
    },
    getDirectSortColorNormalModeCellEntry(row) {
      if (!row) {
        return null;
      }
      for (const fieldName of ["code", "weightNo"]) {
        const entry = this.getDirectSortColorCellEntryByField(row, fieldName);
        if (entry?.cell) {
          return entry;
        }
      }
      const entries = this.getDirectSortColorVisibleColumnsForRow(row);
      const domCells = Array.from(row.children || []);
      const index = entries.findIndex(entry => {
        const field = entry.column?.field || "";
        return field !== "dummy" && field !== "sortRank";
      });
      if (index < 0) {
        return null;
      }
      return {
        ...entries[index],
        cell: domCells[index] || null,
        visibleIndex: index
      };
    },
    changeSortColorByRow(row, forceEdited = false) {
      const sortEntry = this.getDirectSortColorCellEntryByField(row, "sortRank");
      const sortCell = sortEntry?.cell || null;
      const edited = !!forceEdited || (sortCell && this.isEditRow(sortCell));
      if (!edited) {
        return false;
      }
      const targetEntry = sortCell ? sortEntry : this.getDirectSortColorNormalModeCellEntry(row);
      const targetCell = targetEntry?.cell || null;
      if (!targetCell) {
        return false;
      }
      targetCell.classList.remove("master-edited-row", "master-deleted-row");
      targetCell.classList.add("master-sort-edited");
      if (sortCell) {
        const dummyCell = this.getDirectSortColorCellByField(row, "dummy");
        dummyCell?.classList?.add("master-sort-edited");
      }
      return true;
    },
    changeSortColor(currentTrc, currentLockTrc = null, record = null) {
      let edited = this.isDirectGridSortEditedRecord(record);
      [currentTrc, currentLockTrc].forEach(cells => {
        edited = this.changeSortColorByRow(this.getDirectSortColorRowFromCells(cells), edited) || edited;
      });
      if (edited && record) {
        this.markDirectGridSortEdited(record);
      }
      return edited;
    },
    // #8519 編集した項目のバッググラウンドが黄緑にならない 訾浩 start
    changeEditColor(currentTrc, currentLockTrc) {
      let edited = false;
      // 変更されたセルの文字色を変更(固定列と可変列の行数は一致)
      for (let lockClCount = 0; lockClCount < currentLockTrc.length; lockClCount++) {
        // 固定列セル:並び順以外の編集列
        if (
          this.isEditRow(currentLockTrc[lockClCount])
          && lockClCount !== this.getColumnIndex('sortRank')
        ) {
          currentLockTrc[lockClCount]?.classList?.add('master-edited-cell');
          edited = true;
        }
      }

      for (let clCount = 0; clCount < currentTrc.length; clCount++) {
        // 可変列セル
        if (
          this.isEditRow(currentTrc[clCount])
        ) {
          currentTrc[clCount]?.classList?.add('master-edited-cell');
          // #8519 編集した項目のバッググラウンドが黄緑にならない 訾浩 end
          edited = true;
        }
      }
      return edited;
    },
    isDeleteRow(currentTrc, record = null) {
      if (String(record?.isDisp) === "0") {
        return true;
      }
      let deleted = false;
      // 削除カラムで削除が選択されている場合は削除フラグを設定
      const row = this.getDirectSortColorRowFromCells(currentTrc);
      const isDispCell = this.getDirectSortColorCellByField(row, "isDisp");
      if (isDispCell && this.isEditRow(isDispCell)) {
        const text = isDispCell.textContent || "";
        if (text.indexOf("削除") >= 0) {
          return true;
        }
      }
      for (let clCount = 0; clCount < currentTrc.length; clCount++) {
        // #8519 編集した項目のバッググラウンドが黄緑にならない 訾浩 start
        if (this.isEditRow(currentTrc[clCount])) {
          if (
            currentTrc[clCount].children[0].nextSibling
            && currentTrc[clCount].children[0].nextSibling.data === '削除'
            && this.getColumnIndex('isDisp') === clCount
            // #8519 編集した項目のバッググラウンドが黄緑にならない 訾浩 end
          ) {
            deleted = true;
          }
        }
      }
      return deleted;
    },
    getDirectGridRowColorEntries(cells) {
      const row = this.getDirectSortColorRowFromCells(cells);
      const entries = this.getDirectSortColorVisibleColumnsForRow(row);
      const domCells = Array.from(cells || []);
      if (entries.length !== domCells.length) {
        return domCells.map((cell, visibleIndex) => ({ cell, column: null, visibleIndex }));
      }
      return entries.map((entry, visibleIndex) => ({ ...entry, cell: domCells[visibleIndex], visibleIndex }));
    },
    shouldApplyDirectGridRowColor(entry, deleted) {
      if (!entry?.cell) {
        return false;
      }
      const field = entry.column?.field || "";
      if (field === "dummy" || field === "sortRank" || field === "weightNo" || field === "code") {
        return false;
      }
      if (!field && entry.visibleIndex === 0) {
        return false;
      }
      return true;
    },
    applyDirectGridRowColorToCells(cells, addClass, removeClass, deleted) {
      this.getDirectGridRowColorEntries(cells).forEach(entry => {
        if (!entry?.cell) {
          return;
        }
        if (!this.shouldApplyDirectGridRowColor(entry, deleted)) {
          entry.cell.classList.remove("master-edited-row", "master-deleted-row");
          return;
        }
        entry.cell.classList.remove(removeClass);
        entry.cell.classList.add(addClass);
      });
    },
    // #8519 編集した項目のバッググラウンドが黄緑にならない 訾浩 start
    changeRowColor(currentTrc, currentLockTrc, edited, deleted) {
      // 並び順より後の項目の背景色を変更
      if (edited || deleted) {
        const addClass = deleted ? 'master-deleted-row' : 'master-edited-row';
        const removeClass = deleted ? 'master-edited-row' : 'master-deleted-row';
        this.applyDirectGridRowColorToCells(currentLockTrc, addClass, removeClass, deleted);
        this.applyDirectGridRowColorToCells(currentTrc, addClass, removeClass, deleted);
      }
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
      const codeIndex = this.getColumnIndex('code');
      const codeCell = codeIndex >= 0 ? currentTrc[codeIndex] : null;
      if (!codeCell) {
        return;
      }
      const codeValue = String(codeCell.textContent ?? '').replaceAll(",", "");
      // コンボリストが設定されていてデータが存在するが、画面表示上は空の場合は削除済みレコードを参照として背景色を変更
      for (let clCount = 0; clCount < currentTrc.length; clCount++) {
        const columnInfo = this.columns[clCount];
        const hasValueColumn = this.hasValueColumn(
          // #8519 編集した項目のバッググラウンドが黄緑にならない 訾浩 start
          // mod #9863 編集時背景色表示異常の横展開 蔡 start
          // currentTrc[this.getColumnIndex("code")].textContent,
          codeValue,
          // mod #9863 編集時背景色表示異常の横展開 蔡 end
          columnInfo.field,
        );
        if (
          columnInfo.values !== null
          && hasValueColumn
          && currentTrc[clCount].textContent === ''
        ) {
          currentTrc[clCount]?.classList?.add('master-deleted-combo');
          // #8519 編集した項目のバッググラウンドが黄緑にならない 訾浩 end
        }
      }
    },
    isEditRow(currentTd) {
      // 編集した行を判定
      return currentTd.classList.contains("k-dirty-cell");
    },
    // add FNSI-データ初期種別と測定値送信間隔の制御 徐 start
    deviceClassChange() {
      setTimeout(() => {
        const grid = this.getGridWidget();
        const rows = this.getGridBodyRows();
        const setCellDisabled = (cell, disabled, clearValue = false) => {
          if (!cell) {
            return;
          }
          cell.disabled = disabled;
          cell.classList.toggle("kendo-grid-disabled", disabled);
          if (clearValue) {
            cell.textContent = "";
          }
        };
        for (const row of rows) {
          const dataItem = grid?.dataItem?.(row) || {};
          const weightTypeCell = this.getDirectSortColorCellByField(row, "weightType");
          const weightTypeText = (weightTypeCell?.textContent || "").trim();
          const isScaleBedRow =
            String(dataItem.weightType ?? "") === "1" ||
            weightTypeText === this.weightTypeNameScaleBed;
          const deviceClassCell = this.getDirectSortColorCellByField(row, "deviceClass");
          const isTanakaDevice = (deviceClassCell?.textContent || "").trim() === this.deviceClassName;

          [
            "portName",
            "deviceClass",
            "waitAutoSendBefore",
            "waitAutoSendAfter",
            "isHasCardReader"
          ].forEach(fieldName => {
            setCellDisabled(this.getDirectSortColorCellByField(row, fieldName), isScaleBedRow, isScaleBedRow);
          });

          ["dataSelectType", "dataSendInterval"].forEach(fieldName => {
            const disabled = isScaleBedRow || !isTanakaDevice;
            setCellDisabled(this.getDirectSortColorCellByField(row, fieldName), disabled, disabled);
          });
        }
      }, 500);
    },
    // add FNSI-データ初期種別と測定値送信間隔の制御 徐 end
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
    closeDetailView() {
      this.isShowDetailView = false;
      this.onCloseMasterEditModal();
      EventBus.$emit("setIsDetailHeaderView", false);
      this.$nextTick(() => {
        this.applyDirectGridDataSourceContract({ forceRebind: true });
        this.scheduleDirectGridDataSourceRefresh({ forceRebind: true });
        this.calculateGridHeight();
        this.scheduleDirectGridLayoutContract();
      });
    },
    getRawMasterRecordData() {
      const source = this.getMasterRecordList || {};
      if (Array.isArray(source)) {
        return source;
      }
      if (Array.isArray(source.data)) {
        return source.data;
      }
      if (typeof source.data === "function") {
        return Array.from(source.data() || []);
      }
      return [];
    },
    isDirectGridEditedRecord(record, rawData) {
      if (!record || !rawData) {
        return false;
      }
      const target = rawData.find(row => row && row.code == record.code);
      return !!target && ((target.operation === 1 && target.edited) || target.operation === 2);
    },
    isDirectGridSearchMatched(record, condition) {
      const recordName = String(condition?.recordName || "");
      if (recordName === "") {
        return true;
      }
      if (record?.skipSearch) {
        return true;
      }
      const parseString = value => (value == null ? "" : String(value));
      if (parseString(record?.name).indexOf(recordName) !== -1) {
        return true;
      }
      for (const column of this.columns || []) {
        if (column?.dataType !== "combo1" && column?.dataType !== "combo2") {
          continue;
        }
        const values = column.values || [];
        const matchedValues = values.filter(value => parseString(value?.text).indexOf(recordName) !== -1);
        if (matchedValues.some(value => value?.value == record?.[column.field])) {
          return true;
        }
      }
      return false;
    },
    getDirectGridDisplayData() {
      const rawData = this.getRawMasterRecordData();
      const condition = this.$store?.state?.["master-maintenance"]?.condition || this.condition || {};
      return rawData.filter(record => {
        const edited = this.isDirectGridEditedRecord(record, rawData);
        if (String(record?.isDel) === "1" && !edited) {
          return false;
        }
        if (condition.includeDeleted === false && String(record?.isDisp) === "0" && !edited) {
          return false;
        }
        return this.isDirectGridSearchMatched(record, condition);
      });
    },
    normalizeDirectGridColumnWidth(width) {
      return width == null || width === "" ? "0" : width;
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
        if (column.field === "$modalType") {
          gridColumn.attributes = { class: "btn3-kendo-normal" };
          gridColumn.command = { text: "詳細", click: event => this.showMasterEditView(event) };
          delete gridColumn.values;
        }
        return gridColumn;
      });
    },
    getDirectGridColumnSignature() {
      return (this.columns || []).map(column => [
        column.field,
        column.title,
        column.hidden ? 1 : 0,
        column.locked ? 1 : 0,
        column.width || "",
        column.format || "",
        Array.isArray(column.values) ? column.values.length : 0
      ].join(":")).join("|");
    },
    applyDirectGridColumnsContract(options = {}) {
      const grid = this.getGridWidget();
      if (!grid) {
        return;
      }
      const nextSignature = this.getDirectGridColumnSignature();
      if (options.force || this.directGridColumnSignature !== nextSignature) {
        grid.setOptions({ columns: this.buildDirectGridColumns() });
        this.directGridWidget = markRaw($(this.getGridRootElement()).data("kendoGrid") || grid);
        this.directGridColumnSignature = nextSignature;
      }
    },
    createDirectDataSource(data = this.getDirectGridDisplayData()) {
      const source = this.directGridDataSource || this.getMasterRecordList || {};
      const sourceConfig = { ...source };
      sourceConfig.data = Array.isArray(data) ? data.slice() : data;
      if (kendo?.data?.DataSource) {
        return markRaw(new kendo.data.DataSource(sourceConfig));
      }
      return sourceConfig;
    },
    initDirectGridIfReady() {
      if (!this.directGridMounted || this.columns.length <= 1 || !this.getGridRootElement()) {
        return;
      }
      if (this.directGridWidget) {
        this.applyDirectGridColumnsContract();
        this.applyDirectGridDataSourceContract();
        this.scheduleDirectGridLayoutContract();
        return;
      }
      installComponentJQuery();
      const $gridRoot = $(this.getGridRootElement());
      this.applyDirectGridLegacyShellClasses();
      $gridRoot.kendoGrid({
        dataSource: this.createDirectDataSource(),
        editable: true,
        selectable: true,
        reorderable: false,
        height: this.kendoGridHeight,
        scrollable: true,
        columns: this.buildDirectGridColumns(),
        beforeEdit: this.editStart,
        edit: this.onDirectGridEdit,
        save: this.onDirectGridSave,
        cellClose: this.onDirectGridCellClose,
        dataBound: this.onDataBoundKendoGrid
      });
      this.directGridWidget = markRaw($gridRoot.data("kendoGrid"));
      this.directGridReady = !!this.directGridWidget;
      this.directGridColumnSignature = this.getDirectGridColumnSignature();
      this.scheduleDirectGridLayoutContract();
    },
    destroyDirectGrid() {
      this.clearValidationTooltipPlacementTimers();
      this.stopValidationTooltipPlacementWatch();
      this.clearValidationTooltipPlacementState();
      const grid = this.directGridWidget;
      if (grid) {
        try {
          grid.destroy();
        } catch (_error) {
          // noop
        }
      }
      if (this.getGridRootElement()) {
        $(this.getGridRootElement()).empty();
      }
      this.directGridWidget = null;
      this.directGridReady = false;
      this.directGridColumnSignature = "";
    },
    applyDirectGridDataSourceContract(options = {}) {
      const grid = this.getGridWidget();
      if (!grid?.dataSource) {
        this.initDirectGridIfReady();
        return;
      }
      const position = this.getGridScrollPosition();
      const displayData = this.getDirectGridDisplayData();
      try {
        if (options.forceRebind && typeof grid.setDataSource === "function") {
          grid.setDataSource(this.createDirectDataSource(displayData));
          this.directGridWidget = markRaw($(this.getGridRootElement()).data("kendoGrid") || grid);
        } else {
          grid.dataSource.data(Array.isArray(displayData) ? displayData.slice() : displayData);
          grid.refresh?.();
        }
      } catch (_error) {
        // noop
      }
      this.$nextTick(() => {
        if (options.scrollToBottom) {
          const content = this.getGridContentElement();
          if (content) {
            content.scrollTop = content.scrollHeight;
            this.syncDirectGridLockedScrollContract();
          }
        } else {
          this.setGridScrollPosition(position);
        }
        this.scheduleDirectGridLayoutContract();
      });
    },
    scheduleDirectGridDataSourceRefresh(options = {}) {
      if (this.directGridDataRefreshRafId != null) {
        cancelAnimationFrame(this.directGridDataRefreshRafId);
      }
      this.$nextTick(() => {
        this.directGridDataRefreshRafId = requestAnimationFrame(() => {
          this.directGridDataRefreshRafId = null;
          this.applyDirectGridDataSourceContract(options);
        });
      });
    },
    scheduleDirectGridFilterRefresh() {
      if (this.directGridFilterRefreshRafId != null) {
        cancelAnimationFrame(this.directGridFilterRefreshRafId);
      }
      this.directGridFilterRefreshRafId = requestAnimationFrame(() => {
        this.directGridFilterRefreshRafId = null;
        this.applyDirectGridDataSourceContract();
      });
    },
    applyDirectGridColumnVisibilityContract() {
      if (!this.getGridWidget()) {
        return;
      }
      const position = this.getGridScrollPosition();
      this.applyDirectGridColumnsContract({ force: true });
      this.$nextTick(() => {
        this.setGridScrollPosition(position);
        this.scheduleDirectGridLayoutContract();
      });
    },
    applyDirectGridColumnEditableContract() {
      const grid = this.getGridWidget();
      if (!grid) {
        return;
      }
      grid.columns?.forEach?.(gridColumn => {
        const sourceColumn = this.columns.find(column => column.field === gridColumn.field);
        if (sourceColumn) {
          gridColumn.editable = sourceColumn.editable;
        }
      });
    },
    applyDirectGridLegacyShellClasses() {
      const root = this.getGridRootElement();
      if (!root) {
        return;
      }
      root.classList.add("ntss-kendo-grid-legacy", "k-widget", "k-grid", "k-editable", "k-display-block");
    },
    applyDirectGridLegacyStyleContract() {
      const root = this.getGridRootElement();
      if (!root) {
        return;
      }
      this.applyDirectGridLegacyShellClasses();
      root.querySelectorAll("th").forEach(th => th.classList.add("k-header"));
      [".k-grid-content tbody", ".k-grid-content-locked tbody"].forEach(selector => {
        root.querySelectorAll(selector).forEach(tbody => {
          Array.from(tbody.children || []).forEach((tr, index) => {
            tr.classList.add("k-master-row");
            tr.classList.toggle("k-alt", index % 2 === 1);
          });
        });
      });
      root.querySelectorAll(".k-grid-content tbody td, .k-grid-content-locked tbody td").forEach(td => td.classList.add("k-td", "k-table-td"));
    },
    applyDirectGridLockedWidthContract() {
      const root = this.getGridRootElement();
      if (!root) {
        return;
      }
      const lockedColumns = this.columns.filter(column => column.locked && !column.hidden);
      if (lockedColumns.length === 0) {
        return;
      }
      const fontSize = parseFloat(this.getMasterOwnerWindow()?.getComputedStyle?.(root)?.fontSize || "16") || 16;
      const toPx = width => {
        if (typeof width === "number") return width;
        const str = String(width || "0").trim();
        if (str.endsWith("em")) return parseFloat(str) * fontSize;
        if (str.endsWith("px")) return parseFloat(str);
        return parseFloat(str) || 0;
      };
      const lockedWidth = Math.ceil(lockedColumns.reduce((sum, column) => sum + toPx(column.width), 0));
      if (!lockedWidth) {
        return;
      }
      [
        ".k-grid-header-locked",
        ".k-grid-content-locked",
        ".k-grid-footer-locked",
        ".k-grid-lockedcolumns",
        ".k-grid-header-locked table",
        ".k-grid-content-locked table"
      ].forEach(selector => {
        root.querySelectorAll(selector).forEach(element => {
          element.style.width = `${lockedWidth}px`;
          element.style.minWidth = `${lockedWidth}px`;
        });
      });
    },
    applyDirectGridLockedHeightContract() {
      const content = this.getGridContentElement();
      const locked = this.getGridLockedContentElement();
      if (!content || !locked) {
        return;
      }
      const height = content.clientHeight;
      if (height > 0) {
        locked.style.height = `${height}px`;
        locked.style.maxHeight = `${height}px`;
      }
    },
    syncDirectGridLockedScrollContract() {
      const content = this.getGridContentElement();
      const locked = this.getGridLockedContentElement();
      if (content && locked) {
        locked.scrollTop = content.scrollTop;
      }
    },
    runDirectGridLayoutContract() {
      this.calculateGridHeight();
      const grid = this.getGridWidget();
      if (grid) {
        try {
          grid.wrapper?.height?.(this.kendoGridHeight);
          grid.resize?.();
        } catch (_error) {
          // noop
        }
      }
      this.applyDirectGridLegacyStyleContract();
      this.applyDirectGridLockedWidthContract();
      this.applyDirectGridLockedHeightContract();
      this.syncDirectGridLockedScrollContract();
    },
    scheduleDirectGridLayoutContract() {
      if (this.directGridLayoutRafId != null) {
        cancelAnimationFrame(this.directGridLayoutRafId);
      }
      this.directGridLayoutRafId = requestAnimationFrame(() => {
        this.runDirectGridLayoutContract();
        this.directGridLayoutRafId = requestAnimationFrame(() => {
          this.directGridLayoutRafId = null;
          this.runDirectGridLayoutContract();
        });
      });
    },
    getDirectGridEditField(ev = {}, fallbackCell = null) {
      return ev?.sender?.editable?.options?.fields?.field
        || ev?.sender?.editable?.options?.field
        || ev?.container?.find?.("input[name], textarea[name], select[name]")?.first?.()?.attr?.("name")
        || this.getDirectGridFieldFromCell(fallbackCell);
    },
    getDirectGridEditKey(model, fieldName) {
      if (!model || !fieldName) {
        return "";
      }
      return `${model.uid || model.code || model.weightNo || "__row__"}:${fieldName}`;
    },
    getDirectGridOriginalValue(model, fieldName) {
      const key = this.getDirectGridEditKey(model, fieldName);
      if (key && this.directGridEditOriginals.has(key)) {
        return this.directGridEditOriginals.get(key);
      }
      return model?.[fieldName];
    },
    normalizeDirectGridCompareValue(value, fieldName) {
      if (value instanceof Date) {
        return Number.isNaN(value.getTime()) ? "" : `date:${value.getTime()}`;
      }
      if (value == null) {
        return "";
      }
      const fieldInfo = this.getMasterRecordList?.schema?.model?.fields?.[fieldName];
      const rawValue = typeof value === "string" ? value.replace(/,/g, "").trim() : value;
      if (fieldInfo?.type === "number" || typeof rawValue === "number") {
        if (rawValue === "") {
          return "";
        }
        const numberValue = Number(rawValue);
        return Number.isFinite(numberValue) ? `number:${numberValue}` : String(rawValue);
      }
      return String(value);
    },
    isDirectGridSameValue(oldValue, newValue, fieldName) {
      return this.normalizeDirectGridCompareValue(oldValue, fieldName) === this.normalizeDirectGridCompareValue(newValue, fieldName);
    },
    captureDirectGridEditOriginal(ev = {}) {
      const model = ev?.model;
      if (!model) {
        return;
      }
      const container = ev?.container;
      const currentCell = container?.closest?.("td")?.[0] || ev?.sender?.current?.()?.[0] || null;
      const fieldName = this.getDirectGridEditField(ev, currentCell);
      if (!fieldName) {
        return;
      }
      const key = this.getDirectGridEditKey(model, fieldName);
      if (key && !this.directGridEditOriginals.has(key)) {
        const snapshotValue = this.getWeightSnapshotFieldValue(model.code, fieldName);
        this.directGridEditOriginals.set(
          key,
          snapshotValue !== undefined ? snapshotValue : model[fieldName]
        );
      }
    },
    clearDirectGridEditOriginal(model, fieldName) {
      const key = this.getDirectGridEditKey(model, fieldName);
      if (key) {
        this.directGridEditOriginals.delete(key);
      }
    },
    getDirectGridSaveFieldNames(ev = {}) {
      const fields = new Set();
      Object.keys(ev?.values || {}).forEach(field => fields.add(field));
      Object.keys(ev?.model?.dirtyFields || {}).forEach(field => fields.add(field));
      const containerCell = ev?.container?.closest?.("td")?.[0] || null;
      const fieldName = this.getDirectGridEditField(ev, containerCell || ev?.sender?.current?.()?.[0] || null);
      if (fieldName) {
        fields.add(fieldName);
      }
      return Array.from(fields).filter(Boolean);
    },
    getDirectGridNewValue(ev = {}, model, fieldName) {
      if (ev?.values && Object.prototype.hasOwnProperty.call(ev.values, fieldName)) {
        return ev.values[fieldName];
      }
      const container = ev?.container;
      const input = container
        ?.find?.("input[name], textarea[name], select[name]")
        ?.filter?.((_, element) => !element.disabled && element.type !== "hidden")
        ?.first?.();
      if (input?.length) {
        return this.getDirectGridEditorValue(input, fieldName, { triggerChange: false });
      }
      return model?.[fieldName];
    },
    clearDirectGridUnchangedField(ev = {}, fieldName = null) {
      const model = ev?.model;
      if (model?.dirtyFields && fieldName) {
        delete model.dirtyFields[fieldName];
        if (Object.keys(model.dirtyFields).length === 0) {
          model.dirty = false;
        }
      }
      const cell = ev?.container?.closest?.("td")?.[0] || ev?.sender?.current?.()?.[0] || null;
      if (cell) {
        cell.classList.remove("k-dirty-cell", "master-edited-cell", "master-sort-edited");
        cell.querySelectorAll?.(".k-dirty").forEach(element => element.remove());
      }
    },
    getDirectGridActualChangedFields(ev = {}) {
      const model = ev?.model;
      if (!model) {
        return [];
      }
      return this.getDirectGridSaveFieldNames(ev).filter(fieldName => {
        const oldValue = this.getDirectGridOriginalValue(model, fieldName);
        const newValue = this.getDirectGridNewValue(ev, model, fieldName);
        const changed = !this.isDirectGridSameValue(oldValue, newValue, fieldName);
        if (!changed) {
          this.clearDirectGridUnchangedField(ev, fieldName);
          this.clearDirectGridEditOriginal(model, fieldName);
        }
        return changed;
      });
    },
    isDirectGridSortRankEdit(ev = {}) {
      if (ev?.values && Object.prototype.hasOwnProperty.call(ev.values, "sortRank")) {
        return true;
      }
      if (ev?.model?.dirtyFields && Object.prototype.hasOwnProperty.call(ev.model.dirtyFields, "sortRank")) {
        return true;
      }
      const editableField = ev?.sender?.editable?.options?.fields?.field || ev?.sender?.editable?.options?.field;
      return editableField === "sortRank";
    },
    getDirectGridFieldFromCell(cell) {
      const row = cell?.parentElement || null;
      if (!row) {
        return null;
      }
      const index = Array.from(row.children || []).indexOf(cell);
      if (index < 0) {
        return null;
      }
      return this.getDirectSortColorVisibleColumnsForRow(row)[index]?.column?.field || null;
    },
    getDirectGridFieldFromEvent(ev) {
      const activeField = ev?.sender?.editable?.options?.fields?.field;
      if (activeField) {
        return activeField;
      }
      return this.getDirectGridFieldFromCell(ev?.container?.[0] || ev?.container);
    },
    applyWeightSchemaValidationMessages(schema) {
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
    getDirectGridSearchRoot() {
      const widget = this.directGridWidget;
      return widget?.wrapper?.[0] || widget?.element?.[0] || this.$refs.grid || null;
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
    clearValidationTooltipPlacementState() {
      const root = this.getDirectGridSearchRoot();
      root?.querySelectorAll?.(".ntss-validation-above")?.forEach?.(element => {
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
    onDirectGridCellClose(ev) {
      this.clearValidationTooltipPlacementTimers();
      this.stopValidationTooltipPlacementWatch();
      const closedCell = ev?.container?.[0] || ev?.container;
      if (closedCell?.classList) {
        closedCell.classList.remove("ntss-validation-above");
        this.resetValidationTooltipCalloutDirection(closedCell);
      }
      this.clearValidationTooltipPlacementState();
      this.editEnd();
    },
    getDirectGridEditorValue(input, fieldName, options = {}) {
      const triggerChange = options.triggerChange !== false;
      const widgetNames = [
        "kendoNumericTextBox",
        "kendoDropDownList",
        "kendoComboBox",
        "kendoDatePicker",
        "kendoDateTimePicker",
        "kendoTimePicker"
      ];
      for (const widgetName of widgetNames) {
        const widget = input?.data?.(widgetName);
        if (widget && typeof widget.value === "function") {
          if (triggerChange) {
            widget.trigger?.("change");
          }
          return widget.value();
        }
      }
      if (triggerChange) {
        input?.trigger?.("change");
      }
      const value = input?.val?.();
      const fieldInfo = this.getMasterRecordList?.schema?.model?.fields?.[fieldName];
      if (fieldInfo?.type === "number") {
        const numberValue = Number(value);
        return Number.isNaN(numberValue) ? value : numberValue;
      }
      return value;
    },
    flushDirectGridEditorValue() {
      const grid = this.getGridWidget();
      if (!grid) {
        return false;
      }
      const current = grid.current?.();
      const currentCell = current?.jquery ? current[0] : (current?.[0] || null);
      const editableElement = grid.editable?.element;
      const container = editableElement?.jquery ? editableElement : $(editableElement || currentCell || []);
      const input = container
        ?.find?.("input[name], textarea[name], select[name]")
        ?.filter?.((_, element) => !element.disabled && element.type !== "hidden")
        ?.first?.();
      const fieldName = grid.editable?.options?.fields?.field
        || grid.editable?.options?.field
        || input?.attr?.("name")
        || this.getDirectGridFieldFromCell(currentCell);
      if (!fieldName || !input?.length) {
        return false;
      }
      const row = $(currentCell || input.closest("tr")?.[0]).closest("tr");
      const model = grid.dataItem?.(row);
      if (!model) {
        return false;
      }
      const value = this.getDirectGridEditorValue(input, fieldName);
      const originalValue = this.getDirectGridOriginalValue(model, fieldName);
      if (this.isDirectGridSameValue(originalValue, value, fieldName)) {
        this.clearDirectGridUnchangedField({ sender: grid, model }, fieldName);
        this.clearDirectGridEditOriginal(model, fieldName);
        this.syncDirectGridModelToStore({ model });
        return false;
      }
      if (model.operation !== 1 && !this.isSortMode) {
        model.operation = 2;
      }
      if (typeof model.set === "function") {
        model.set(fieldName, value);
      } else {
        model[fieldName] = value;
      }
      model.dirty = true;
      model.dirtyFields = model.dirtyFields || {};
      model.dirtyFields[fieldName] = true;
      if (this.isSortMode && fieldName === "sortRank") {
        this.markDirectGridSortEdited(model);
      }
      this.markWeightRecordEdited(model.code);
      this.edit({ editRecord: model, isSortMode: this.isSortMode });
      this.clearDirectGridEditOriginal(model, fieldName);
      this.scheduleDirectGridRowVisualRefresh(model, model?.uid);
      this.weightEditTick += 1;
      return true;
    },
    flushDirectGridPendingEdit() {
      const grid = this.getGridWidget();
      if (!grid) {
        return false;
      }
      const flushed = this.flushDirectGridEditorValue();
      try {
        grid.closeCell?.();
      } catch (_error) {
        // direct jq では closeCell 失敗時に画面遷移判定を止めない。
      }
      if (flushed) {
        this.refreshDirectGridDirtyVisualState();
      }
      return flushed;
    },
    validateDirectKendoGrid() {
      const root = this.getGridRootElement();
      const grid = this.getGridWidget();
      this.flushDirectGridEditorValue();
      try {
        grid?.closeCell?.();
      } catch (_error) {
        // noop
      }
      const isValid = !root?.querySelector?.(".k-invalid, .k-invalid-msg");
      if (!isValid) {
        this.$nextTick(() => this.handleAddValidateArrow());
      }
      return isValid;
    },
    onDirectGridEdit(ev) {
      this.captureDirectGridEditOriginal(ev);
      this.addInputAssist(ev);
      const field = this.getDirectGridFieldFromEvent(ev);
      const cell = ev?.container?.[0] || ev?.container;
      if (!field || !cell) {
        return;
      }
      this.applyDirectGridEditorValidationMessage(cell, field);
      this.scheduleValidationTooltipPlacement();
      const inputElements = Array.from(
        cell.querySelectorAll?.("input:not([type='hidden']), textarea, select") || []
      );
      const onValidationPlacement = () => {
        this.scheduleValidationTooltipPlacement();
      };
      inputElements.forEach(input => {
        input.addEventListener("blur", onValidationPlacement, { passive: true });
        input.addEventListener("invalid", onValidationPlacement, { passive: true });
      });
    },
    onDirectGridSave(ev) {
      this.onSave(ev);
    },
    scheduleDirectGridRowVisualRefresh(record, preferredUid = null) {
      const rowKey = preferredUid || record?.uid || record?.code || "__unknown__";
      const oldRaf = this.directGridRowVisualRafIds.get(rowKey);
      if (oldRaf != null) {
        cancelAnimationFrame(oldRaf);
      }
      const rafId = requestAnimationFrame(() => {
        this.directGridRowVisualRafIds.delete(rowKey);
        this.applyDirectGridRowVisualState(record, preferredUid);
      });
      this.directGridRowVisualRafIds.set(rowKey, rafId);
    },
    applyDirectGridRowVisualState(record, preferredUid = null) {
      const grid = this.getGridWidget();
      if (!grid || !record) {
        return;
      }
      const uid = preferredUid || record.uid;
      const root = this.getGridRootElement();
      const row = uid ? root?.querySelector?.(`.k-grid-content:not(.k-grid-content-locked) tr[data-uid="${uid}"]`) : null;
      const lockedRow = uid ? root?.querySelector?.(`.k-grid-content-locked tr[data-uid="${uid}"]`) : null;
      const deleted = String(record.isDisp) === "0";
      const edited = this.isWeightGridRecordEdited(record) || this.isDirectGridSortEditedRecord(record);
      [row, lockedRow].filter(Boolean).forEach(tr => {
        tr.querySelectorAll("td").forEach(td => {
          td.classList.remove("master-edited-row", "master-deleted-row");
        });
      });
      if (edited || deleted) {
        this.changeRowColor(row?.children || [], lockedRow?.children || [], edited, deleted);
      }
      if (this.isSortMode && record?.sortRank != null) {
        [row, lockedRow].filter(Boolean).forEach(tr => this.changeSortColorByRow(tr, this.isDirectGridSortEditedRecord(record)));
      }
    },
    refreshDirectGridDirtyVisualState() {
      this.editBackgroundColor();
    },
    syncDirectGridSortRankToStore() {
      const data = this.getGridDataSource()?.data?.() || [];
      data.forEach(item => {
        const record = this.getMasterRecordList?.data?.find?.(row => row.code === item.code);
        if (record) {
          record.sortRank = item.sortRank;
          record.sortInputTime = item.sortInputTime;
        }
      });
    },

    loadGridData(){
      // delete start #9590
        // this.setCondition(this.condition);
        // delete end #9590
      this.findList();
    },
    refreshScaleGridWithoutDiscardConfirm() {
      const scale = this.$refs.scale;
      if (!scale) {
        return;
      }
      if (typeof scale.loadGridData === "function") {
        scale.loadGridData();
        return;
      }
      scale.refresh?.();
    },
    runDiscardConfirmedRefresh() {
      this.isMasterRefreshDiscarding = true;
      this.clearScrollPosition();
      this.refreshScaleGridWithoutDiscardConfirm();
      this.loadGridData();
      setTimeout(() => {
        this.isMasterRefreshDiscarding = false;
      }, 1000);
    },
    // パンくずリストをクリックされた場合に呼び出される関数
    refresh() {
      // 他の画面に遷移したときもrefresh()が発生する為、自分の画面のみ処理する
      if (this.selfScreenName !== this.$route.name
          || this.getAlertDialogs().length > 0
          || this.isMasterRefreshConfirming
          || this.isMasterRefreshDiscarding) {
        return;
      }
      this.flushDirectGridPendingEdit();
      // #9194 愁訴処置マスタは空行保存ができる仕様だが、愁訴、処置が必須となっておりフォーカスアウトできない。 linjunfeng start   
      // if (this.isChanged) {
      if (this.isChanged || !this.kendoValidator?.validate?.()) {
      // #9194 愁訴処置マスタは空行保存ができる仕様だが、愁訴、処置が必須となっておりフォーカスアウトできない。 linjunfeng end
        this.isMasterRefreshConfirming = true;
        this.$ons.notification.confirm({
           // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
            // title: "内容破棄",
            title: DIALOG_MESSAGES[13000004].title,
            // message: "編集内容が破棄されます。</br>よろしいですか？",
            message: messageFormat(DIALOG_MESSAGES[13000004].message),
            // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
          callback: answer => {
            this.isMasterRefreshConfirming = false;
            if (answer === 1) {
              this.runDiscardConfirmedRefresh();
            }
          }
        });
      } else {
        this.clearScrollPosition();
        this.$refs.scale.refresh();
        this.loadGridData();
      }
    },
    /**
     * @description スクロールバーの位置をクリアする
    */
    clearScrollPosition() {
      // this.scrollPosition.top = 0;
      // this.scrollPosition.left = 0;
    },
    /**
     * 行をコピー追加した時の処理
     */
    addedRow(){
      // スクロールバーを一番下にする
      this.lastScrollTop = this.getGridScrollHostEl()?.scrollHeight;
      this.lastScrollLeft = 0;
      this.scrollPosition.left = 0;
      this.directGridLocalChanged = true;
      this.applyDirectGridDataSourceContract({ forceRebind: true, scrollToBottom: true });
      this.scheduleDirectGridDataSourceRefresh({ forceRebind: true, scrollToBottom: true });
      this.$nextTick(() => {
        const content = this.getGridContentElement();
        if (content) {
          content.scrollTop = content.scrollHeight;
          content.scrollLeft = 0;
          this.syncDirectGridLockedScrollContract();
        }
        requestAnimationFrame(() => {
          const gridContent = this.getGridContentElement();
          if (gridContent) {
            gridContent.scrollTop = gridContent.scrollHeight;
            gridContent.scrollLeft = 0;
            this.syncDirectGridLockedScrollContract();
          }
        });
      });
    },
  },
  async created() {
    this.setLoadingScreenVisible(true);
    // add マスタ一覧 1･施設切替を可能とする 孔s start
    this.facilitylistValue = this.getFacilitySwitch;
    // add マスタ一覧 1･施設切替を可能とする 孔s end
    // #11987 2026.02.08 add スケールベッド対応 スケールベッド機能の無効・有効取得 TDC渡辺 start
    const sysFunctionListResponse = await sendRequestGetDefaultSettingDispOrder();
    const sysFunctionList = sysFunctionListResponse.data;
    this.defaultSettingObj.forEach(defaultSetting => {
      const matchFunction = sysFunctionList.find(
        sysFunction => sysFunction.function_cd === defaultSetting.funcCode
      );
      defaultSetting.dispOrder = matchFunction?.function_disp_order || null;
    });
    const useFunction = this.$store?.state?.facility?.useFunction || [];
    this.ScaleBedFunction = useFunction.includes(FUNC_SCALE_BED);
    // #11987 2026.02.08 add スケールベッド対応 スケールベッド機能の無効・有効取得 TDC渡辺 end
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
    this.directGridMounted = true;
    this.kendoValidator = { validate: () => this.validateDirectKendoGrid() };
    this.__weightValidateArrowHandler = () => this.handleAddValidateArrow();
    this.getMasterDocument()?.addEventListener?.("click", this.__weightValidateArrowHandler);
    this.$nextTick(() => {
      this.calculateGridHeight();
      this.initDirectGridIfReady();
      this.scheduleDirectGridLayoutContract();
    });
    EventBus.$on("clearScrollPosition", this.clearScrollPosition);
  },
  // add 性能改善メモリ不足 shan start
  beforeUnmount() {
    EventBus.$off("onCloseMasterEditModal", this.onCloseMasterEditModal);
    EventBus.$off("refresh", this.refresh);
    EventBus.$off("clearScrollPosition", this.clearScrollPosition);
    if (this.__weightValidateArrowHandler) {
      this.getMasterDocument()?.removeEventListener?.("click", this.__weightValidateArrowHandler);
      this.__weightValidateArrowHandler = null;
    }
    this.clearValidationTooltipPlacementTimers();
    this.stopValidationTooltipPlacementWatch();
    this.clearValidationTooltipPlacementState();
    this.destroyDirectGrid();
    [
      this.directGridLayoutRafId,
      this.directGridLayoutRefreshRafId,
      this.directGridFilterRefreshRafId,
      this.directGridDataRefreshRafId,
      this.directGridScrollSyncRafId
    ].forEach(id => {
      if (id != null) {
        cancelAnimationFrame(id);
      }
    });
    this.directGridRowVisualRafIds?.forEach?.(id => cancelAnimationFrame(id));
    this.directGridRowVisualRafIds?.clear?.();
    this.directGridEditOriginals?.clear?.();
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
  padding: 0.2em 0.1em 0.1em 0.1em;
}
.kendo-grid-toolbar-style {
  padding: 0 0.3em;
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
  font-size: 1.0em;
  padding: 0.2em 1em 0em 1em;
  line-height: 2em;
  width: auto;
}
.kendo-grid-toolbar-style {
  padding-left: 0;
}
.custom-switch {
  transform: scale(0.85);
  transform-origin: center;
  touch-action: manipulation;
}
.mobile-header {
  min-height: 30px; /* モバイル用の高さ */
}

.mst-weight-direct-jq-grid :deep(td.master-edited-row),
.mst-weight-direct-jq-grid :deep(tr.k-selected > td.master-edited-row),
.mst-weight-direct-jq-grid :deep(tr.k-state-selected > td.master-edited-row),
.mst-weight-direct-jq-grid :deep(tr.k-table-row.k-selected > td.master-edited-row) {
  color: #003300 !important;
  background-color: #ccffcc !important;
}
.mst-weight-direct-jq-grid :deep(td.master-edited-cell) {
  color: #003300 !important;
  font-weight: bold !important;
}
.mst-weight-direct-jq-grid :deep(td.master-sort-edited),
.mst-weight-direct-jq-grid :deep(tr.k-selected > td.master-sort-edited),
.mst-weight-direct-jq-grid :deep(tr.k-state-selected > td.master-sort-edited),
.mst-weight-direct-jq-grid :deep(tr.k-table-row.k-selected > td.master-sort-edited) {
  background-color: #ffff66 !important;
}
.mst-weight-direct-jq-grid :deep(td.master-deleted-row),
.mst-weight-direct-jq-grid :deep(tr.k-selected > td.master-deleted-row),
.mst-weight-direct-jq-grid :deep(tr.k-state-selected > td.master-deleted-row),
.mst-weight-direct-jq-grid :deep(tr.k-table-row.k-selected > td.master-deleted-row) {
  color: #333333 !important;
  background-color: #9d9d9d !important;
}

.kendo-grid-toolbar-style :deep(.k-tooltip.k-tooltip-validation) {
  width: auto;
}
.kendo-grid-toolbar-style :deep(.k-edit-cell) {
  position: relative;
  overflow: visible;
}
.kendo-grid-toolbar-style :deep(.k-edit-cell > .k-invalid-msg:not(.k-hidden)),
.kendo-grid-toolbar-style :deep(.k-edit-cell > .k-form-error:not(.k-hidden)),
.kendo-grid-toolbar-style :deep(.k-edit-cell > .k-validator-tooltip:not(.k-hidden)),
.kendo-grid-toolbar-style :deep(.k-edit-cell > .k-tooltip-error:not(.k-hidden)),
.mst-weight-direct-jq-grid :deep(.k-edit-cell > .k-invalid-msg:not(.k-hidden)),
.mst-weight-direct-jq-grid :deep(.k-edit-cell > .k-tooltip-error:not(.k-hidden)) {
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
.mst-weight-direct-jq-grid :deep(td.k-edit-cell.ntss-validation-above > .k-invalid-msg),
.mst-weight-direct-jq-grid :deep(td.k-edit-cell.ntss-validation-above .k-tooltip.k-tooltip-validation) {
  position: absolute !important;
  left: 0 !important;
  bottom: 38px !important;
  top: auto !important;
  margin-top: 0 !important;
  overflow: visible !important;
}
.kendo-grid-toolbar-style :deep(td.k-edit-cell.ntss-validation-above .k-callout.k-callout-s),
.mst-weight-direct-jq-grid :deep(td.k-edit-cell.ntss-validation-above .k-callout.k-callout-s) {
  top: auto !important;
  bottom: calc(-12px) !important;
  border-bottom-color: transparent !important;
  border-block-start-color: currentColor !important;
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
