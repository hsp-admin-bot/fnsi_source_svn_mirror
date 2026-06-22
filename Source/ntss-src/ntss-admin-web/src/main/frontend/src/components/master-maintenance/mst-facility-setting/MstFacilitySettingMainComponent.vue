<template>
  <div class='main-content-area master-maintenance-page'>
    <div class='ntss-list' v-if="this.columns.length">
      <div :class="['k-grid-toolbar', 'k-header', 'kendo-grid-toolbar-style', { 'no-scroll': isMobileDevice }]" :style="heightStyles">
        <div v-if="isMobileDevice" class="header-btn-area mobile-edit-toolbar">
          <label class="fab-font-color">編集</label>
          <v-ons-switch modifier="outline" v-model="allowEdit" />
        </div>
        <!-- <div v-if="isMasterUser" class='header-btn-area right'> -->
          <!-- del マスタ一覧 1･施設切替を可能とする 孔 start-->
          <!--<kendo-dropdownlist
                    v-model="facilitylistValue"
                    :data-source="facilitys"
                    :data-text-field="'facilityName'"
                    :data-value-field="'facilityCd'"
                    :filter="'contains'"
                    @open="onOpenFacility"
                    @change="onChangeFacility"
                    style="width: 13em;">
          </kendo-dropdownlist>-->
          <!-- del マスタ一覧 1･施設切替を可能とする 孔 end-->
        <!-- </div>
        <div v-else class='header-btn-area left'>
        </div> -->
        <div
          v-show="columns.length > 1"
          ref="gridRoot"
          :class="[
            fontSizeSet,
            'ntss-kendo-grid-legacy',
            'mst-facility-setting-direct-jq-grid'
          ]"
          style="clear: both;"
        ></div>
      </div>
      <!-- 高さ調整 -->
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
import _ from "@/compat/collections/lodash";
import dayjs from "@/compat/date/dayjs";
import { mapActions, mapGetters } from "@/compat/vue/vuex";
import messageDialog from "@/components/common/message-dialog/MessageDialog";
import { EventBus } from "@/compat/vue/event-bus.js";
import { ApiHelper } from "@/apis/AxiosHelper";
import { sendRequestGetMstFacilityHashByFacilityCd } from "@/apis/mst-facility-hash";
import {
  URL_SIGNIN,
  URL_SIGNIN_SECRETKEY,
  TREATMENT_PROGRESS_CHART,
  TREATMENT_PROGRESS_CHART_HANDWRITING,
  DAILY_INSPECTION_RECORD_BOOK,
  PERIODIC_INSPECTION_RECORD_BOOK,
  // add #12462 患者情報共有 ligh start
  SHR_PAT_INFO,
  // add #12462 患者情報共有 ligh end
  STATUS_MAP_TREATMENT_INDICATOR,
  STATUS_MAP_SCHEDULE_INDICATOR
} from "@/constants/facilitySetting";
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
import { cloneDeep, isEqual } from "@/compat/collections/lodash";

import { getScopedAlertDialogs, getScopedElementById } from "@/functions/common/LayoutMeasureHelper";
import { messageFormat } from "@/functions/common/MessageFormat";
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
import kendo from "@progress/kendo-ui";
import $ from "jquery";
import {
  bindGridEditorEnterToCloseCell,
  ensureGridEditorMultiSelectHeaderSearchIcon,
  scheduleClearGridEditorMultiSelectRowHeight,
  scheduleGridEditorMultiSelectRowHeight
} from "@/compat/kendo/grid-edit";
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
  return widget._old ?? null;
}

function setKendoWidgetValue(widget, value) {
  if (!widget) {
    return;
  }
  if (typeof widget.value === "function") {
    widget.value(value);
  } else {
    widget._old = value;
  }
}


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
      kendoGridHeight: '100%',
      kendoValidator: null,
      kendoValidatorSetup: {
        rules: {},
        messages: {}
      },
      facilitylistValue: "",

      // DB取得個別ドロップダウンリスト表示項目
      kendoGridDrop:{
        doctorList:null
        // add 施設設定マスタ 帳票未指定時のデフォルト帳票を指定可能 孔s start
        ,reportList:null
        // add 施設設定マスタ 帳票未指定時のデフォルト帳票を指定可能 孔s end
      },

      // 並び順管理マスタ
      mstSelector: [],
      shrFacilityList: [],

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
      footerHeight: 40,
      tableKey: 0,
      iosFlg: false,
      allowEdit: true, // NOTE: true = 編集モード、 false = 閲覧モード
      // 初期値退避用オブジェクト
      originalDataSource: null,
      scrollTop: 0,
      scrollLeft: 0,
      directGridDataSource: null,
      directGridWidget: null,
      directGridMounted: false,
      directGridReady: false,
      directGridLayoutRafId: null,
      directGridDataSourceRafId: null,
      directGridScrollSyncRafId: null,
      directGridResizeHandler: null,
      directGridColumnSignature: "",
      directGridBodyColumnFields: null,
      facilitySettingDispValueBodyColumnIndex: null,
      directGridLockedColumnFields: null,
      directGridRowVisualRafIds: markRaw(new Map()),
    };
  },
  computed: {
    ...mapGetters("master-maintenance", { getFacilitySwitch: "getFacilitySwitch",}),
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
      return { "height": `calc(100% - ${this.footerHeight}px)` };
    },
    ...mapGetters("mst-facility-setting", {
      getFacilityList: "getFacilityList",
      getFilteredMasterRecordList: "getFilteredMasterRecordList",
      getEditRecord: "getEditRecord",
      getUpdateRecordList: "getUpdateRecordList",
      getMasterRecordList: "getMasterRecordList"
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
      // 復元後に isChanged を再計算させるため tableKey を参照する
      void this.tableKey;
      const data = this.getMasterRecordList.data;
      if (!Array.isArray(data)) {
        return false;
      }
      const originalData = Array.isArray(this.originalDataSource) ? this.originalDataSource : [];
      const hasEffectiveChange = data.some((row) => {
        const originalItem = originalData.find((item) =>
          String(item?.facilitySettingNo ?? "") === String(row?.facilitySettingNo ?? "")
        );
        if (!originalItem) {
          return false;
        }
        return !this.isFacilitySettingRowUnchangedByModel(row, originalItem);
      });
      return (
        this.getStateUserAccountInfo !== null &&
        (hasEffectiveChange ||
          this.isSorted)
      );
    },
    editRecord(){
      return this.getEditRecord;
    },
    isMobileDevice() {
      return this.iosFlg || this.androidFlg;
    },
    facilitySettingFilterSignature() {
      const state = this.$store?.state?.["mst-facility-setting"] || {};
      return JSON.stringify({
        condition: state.condition || {},
        userType: state.userType || "",
        facilitySysUseSetting: state.facilitySysUseSetting || ""
      });
    }
  },
  watch: {
    windowHeight() {
      this.calculateGridHeight();
      this.scheduleDirectGridLayoutContract();
    },
    isDispMenu() {
      this.calculateGridHeight();
      this.scheduleDirectGridLayoutContract();
    },
    getFontSize() {
      this.calculateGridHeight();
      this.scheduleDirectGridLayoutContract();
    },
    async facilitylistValue() {
      if (this.facilitylistValue) {
        // 施設のシステム利用設定を取得する
        const mstFacilityHash = await sendRequestGetMstFacilityHashByFacilityCd(this.facilitylistValue);
        this.setFacilitySysUseSetting(mstFacilityHash.data.systemUseSetting ? mstFacilityHash.data.systemUseSetting : "");
      } else {
        this.setFacilitySysUseSetting("");
      }
    },
    columns(val) {
      this.$nextTick(() => {
        if (Array.isArray(val) && val.length > 1) {
          this.setLoadingScreenVisible(false);
          this.initDirectGridIfReady();
          this.applyDirectGridColumnsContract();
          this.scheduleDirectGridLayoutContract();
        }
      });
    },
    facilitySettingFilterSignature() {
      this.applyDirectGridDataSourceContract({ resetScroll: true });
    }
  },
  methods: {
    ...mapActions("multi-modal", [
      "showUserMasterIdReset",
      "showUserMasterAuthFunction"
    ]),
    ...mapActions("mst-facility-setting", [
      "getFacilitySettingDataList",
      "edit",
      "setEditRecord",
      "facilityList",
      "setCondition",
      "setUserData",
      "setMasterRecordList",
      "setUserType",
      "getDoctorsAtFacility",
      "setFacilitySysUseSetting"
    ]),
    // 共通ローダー設定
    ...mapActions("loading-screen", {
      setLoadingScreenVisible: "setLoadingScreenVisible",
      setLoadingScreenMessage: "setLoadingScreenMessage",
      resetLoadingScreenVisibleCount:  "resetLoadingScreenVisibleCount"
    }),
    ...mapActions("user", ["setSignInFailSetting"]),
    onSave(ev) {
      if (ev.model.facilitySettingNo == '1012' || ev.model.facilitySettingNo == '1014') return;
      // add redmine 4675 医療材料表示順、投与薬剤表示順の不正 孔 start
      if (Number(ev.model.inputType) === 7) {
        // redmine 4675: 編集中の都度 edit しない。表示文字列の同期のみ。
        this.syncFacilitySettingMultiSelectDisplayModel(ev.model);
        return;
      }
      // add redmine 4675 医療材料表示順、投与薬剤表示順の不正 孔 end
      const position = this.getGridScrollPosition();
      this.scrollLeft = position.left;
      this.scrollTop = position.top;
      this.editFlg = true;

      this.editingFlg = false;
      this.applyFacilitySettingSaveValuesToModel(ev);

      if (this.finalizeFacilitySettingRowIfRevertedToOriginal(ev)) {
        this.scheduleDirectGridLayoutContract();
        return;
      }

      this.edit({ editRecord: ev.model, isSortMode: this.isSortMode });

      if (Number(ev.model.operation) > 0) {
        ev.model.edited = true;
      }

      const markEditedRowVisual = () => {
        this.applyDirectGridRowVisualState(ev.model, ev.model?.uid);
        this.findDirectGridRowsForRecord(ev.model, ev.model?.uid).forEach((row) => {
          this.markFacilitySettingValueCellsEdited(row, ev.model);
        });
        this.syncFacilitySettingDispValueCellDisplay(ev.model, ev.model?.uid);
      };
      this.scheduleDirectGridRowVisualState(ev.model, ev.model?.uid);
      this.$nextTick(() => {
        markEditedRowVisual();
        requestAnimationFrame(markEditedRowVisual);
      });
      this.scheduleDirectGridLayoutContract();
    },
    onDataBoundKendoGrid(ev) {
      this.directGridWidget = markRaw(ev?.sender || this.directGridWidget);
      this.invalidateDirectGridColumnFieldCache();
      this.applyDirectGridLegacyStyleContract();
      this.refreshDirectGridVisualState();
      this.syncAllFacilitySettingDispValueCellDisplays();
      if (this.scrollTop > 0 || this.scrollLeft > 0) {
        this.$nextTick(() => {
          this.setGridScrollPosition({ top: this.scrollTop, left: this.scrollLeft });
        });
      }
    },
    measureMasterElementHeight(element, defaultValue = 0) {
      if (!element) {
        return defaultValue;
      }
      const clientHeight = element.clientHeight;
      if (Number.isFinite(clientHeight) && clientHeight > 0) {
        return clientHeight;
      }
      const rectHeight = element.getBoundingClientRect?.().height;
      return Number.isFinite(rectHeight) && rectHeight > 0 ? rectHeight : defaultValue;
    },
    getMasterLayoutElements() {
      const root = this.$el || null;
      const ownerDocument = root?.ownerDocument || document;
      return {
        header: ownerDocument.querySelector?.(".header") || ownerDocument.getElementsByClassName?.("header")?.[0] || null,
        footerMenu: ownerDocument.getElementById?.("footer-menu") || null,
        gridFooter: root?.querySelector?.("#grid-footer") || null,
        mainContentArea: root?.querySelector?.(".main-content-area") || root || null
      };
    },
    isMasterLayoutReady(options = {}) {
      const { requireGridFooter = false } = options;
      const elements = this.getMasterLayoutElements();
      if (!elements.header && !this.windowHeight) {
        return false;
      }
      if (requireGridFooter && !elements.gridFooter) {
        return false;
      }
      return true;
    },
    runWhenMasterLayoutReady(callback, options = {}) {
      const retries = options.retries ?? 6;
      const delay = options.delay ?? 16;
      const run = (remaining) => {
        this.$nextTick(() => {
          if (this.isMasterLayoutReady(options)) {
            callback();
            return;
          }
          if (remaining > 0) {
            setTimeout(() => run(remaining - 1), delay);
          }
        });
      };
      run(retries);
      return Promise.resolve(true);
    },
    getMasterViewportBaseHeight(menuOffset = 0) {
      const elements = this.getMasterLayoutElements();
      const wh = this.windowHeight || window.innerHeight || 0;
      const hh = this.measureMasterElementHeight(elements.header, 0);
      const fmh = ((this.isDispMenu === 1 ? this.measureMasterElementHeight(elements.footerMenu, 0) : 0) || 0) + menuOffset;
      return { wh, hh, fmh };
    },
    getMasterGridFooterHeight(defaultValue = 0) {
      return this.measureMasterElementHeight(this.getMasterLayoutElements().gridFooter, defaultValue);
    },
    // Windowの高さからGirdコンポーネント領域の高さを算出
    calculateGridHeight() {
      if (!this.editingFlg) {
        if (!this.isMasterLayoutReady({ requireGridFooter: true })) {
          this.runWhenMasterLayoutReady(() => {
            this.calculateGridHeight();
          }, {
            name: 'mst-facility-setting:calculate-grid-height',
            requireGridFooter: true,
            retries: 8,
            delay: 16
          });
          return false;
        }
        const { wh, hh, fmh } = this.getMasterViewportBaseHeight();
        this.kendoGridToolbarHeight = wh - hh - fmh;
        this.kendoGridToolbarHeight =
          this.kendoGridToolbarHeight < 340 ? 340 : this.kendoGridToolbarHeight;

        const footerHeight = this.getMasterGridFooterHeight(0);
        this.footerHeight = footerHeight;
        this.kendoGridHeight = '100%';
        this.$nextTick(() => {
          this.resizeDirectGrid();
          this.scheduleDirectGridLayoutContract();
        });
      }
      return true;
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
      if (this.androidFlg) {
        this.editingFlg = true;
      }
      this.syncFacilitySettingSelectorModelFromStore(e?.model);
      bindGridEditorEnterToCloseCell(e?.sender || this.getDirectGridWidget(), e?.container);
    },
    closeFacilitySettingGridEditCell() {
      requestAnimationFrame(() => {
        try {
          this.getDirectGridWidget()?.closeCell?.();
        } catch (_error) {
          // noop
        }
        this.editingFlg = false;
      });
    },
    editEnd(ev) {
      this.editingFlg = false;
      // mod redmine 4675 医療材料表示順、投与薬剤表示順の不正 孔 start
      //if(ev.model.facilitySettingNo == '1012' || ev.model.facilitySettingNo == '1014') {
      if (ev.model.facilitySettingNo == '1012' || ev.model.facilitySettingNo == '1014' ||
        Number(ev.model.inputType) === 7) {
      // mod redmine 4675 医療材料表示順、投与薬剤表示順の不正 孔 end
        if (Number(ev.model.inputType) === 7) {
          this.syncFacilitySettingMultiSelectDisplayModel(ev.model);
          this.clearFacilitySettingMultiSelectEditorHeight(ev);
        }
        if (this.finalizeFacilitySettingRowIfRevertedToOriginal(ev)) {
          this.scheduleDirectGridLayoutContract();
          return;
        }

        this.edit({ editRecord: ev.model, isSortMode: false });

        if (ev.model.operation === 1) {
          ev.model.edited = true;
        }

        // Vue2 の cellClose は現在行の状態だけを反映する。direct jq でも全表 refresh / 全表配色は行わない。
        this.scheduleDirectGridRowVisualState(ev.model, ev.model?.uid);
        this.$nextTick(() => {
          this.applyDirectGridRowVisualState(ev.model, ev.model?.uid);
          this.syncFacilitySettingDispValueCellDisplay(ev.model, ev.model?.uid);
        });
        this.scheduleDirectGridLayoutContract();
      }
    },

    findOriginalFacilitySetting(model) {
      if (!model || !Array.isArray(this.originalDataSource)) {
        return null;
      }
      return this.originalDataSource.find(
        (item) => String(item?.facilitySettingNo) === String(model?.facilitySettingNo)
      ) || null;
    },
    normalizeFacilitySettingCompareText(value) {
      return String(value ?? "").replace(/\r\n|\r/g, "\n");
    },
    isFacilitySettingRowUnchanged(model, event = null) {
      const originalItem = this.findOriginalFacilitySetting(model);
      if (!originalItem) {
        return false;
      }
      if (event?.values && typeof event.values === "object") {
        const editField = Object.keys(event.values)[0];
        if (editField) {
          return this.isFacilitySettingFieldUnchanged(
            model,
            originalItem,
            editField,
            event.values[editField]
          );
        }
      }
      if (event?.container?.[0] || event?.container) {
        const colIndex = this.getDirectGridCellIndex(event.container?.[0] || event.container);
        const editField = this.getDirectGridColumnField(colIndex);
        if (editField) {
          return this.isFacilitySettingFieldUnchanged(
            model,
            originalItem,
            editField,
            model[editField]
          );
        }
      }
      return this.isFacilitySettingRowUnchangedByModel(model, originalItem);
    },
    getFacilitySettingOnOffOptions() {
      return [{ id: "0", name: "OFF" }, { id: "1", name: "ON" }];
    },
    resolveFacilitySettingOnOffId(value, dispValue) {
      const options = this.getFacilitySettingOnOffOptions();
      const byId = options.find((item) => String(item.id) === String(value));
      if (byId) {
        return String(byId.id);
      }
      const byName = options.find(
        (item) =>
          String(item.name) === String(value) ||
          String(item.name) === String(dispValue)
      );
      if (byName) {
        return String(byName.id);
      }
      return String(value ?? "");
    },
    syncFacilitySettingOnOffModel(model) {
      if (!model || Number(model.inputType) !== 3) {
        return;
      }
      const id = this.resolveFacilitySettingOnOffId(model.value ?? model.val, model.dispValue);
      const option = this.getFacilitySettingOnOffOptions().find((item) => String(item.id) === id);
      if (!option) {
        return;
      }
      model.value = option.id;
      model.val = option.id;
      model.dispValue = option.name;
    },
    resolveFacilitySettingOptionId(model, originalItem, editField, editedValue) {
      const inputType = Number(model.inputType);
      if (inputType === 3) {
        if (editField === "dispValue" && editedValue != null && editedValue !== "") {
          return this.resolveFacilitySettingOnOffId(null, editedValue);
        }
        return this.resolveFacilitySettingOnOffId(
          model.value ?? model.val ?? editedValue,
          model.dispValue
        );
      }
      if (inputType === 4 || inputType === 5 || inputType === 8 || inputType === 9) {
        if (editField === "value" || editField === "val") {
          return String(editedValue ?? model.value ?? model.val ?? "");
        }
        const jsonData = this.parseJsonValue(model.optionValue, []);
        const byName = jsonData.find((item) => String(item.name) === String(editedValue ?? model.dispValue));
        if (byName) {
          return String(byName.id);
        }
        return String(model.value ?? model.val ?? editedValue ?? "");
      }
      return String(model.value ?? model.val ?? editedValue ?? "");
    },
    isFacilitySettingFieldUnchanged(model, originalItem, editField, editedValue) {
      const inputType = Number(model.inputType);
      if (inputType === 6) {
        const originalValue = originalItem?.[editField];
        return isEqual(
          this.normalizeFacilitySettingCompareText(originalValue),
          this.normalizeFacilitySettingCompareText(editedValue)
        );
      }
      if (inputType === 2) {
        return isEqual(
          String(originalItem.dispValue ?? ""),
          String(model.dispValue ?? editedValue ?? "")
        );
      }
      if (inputType === 3 || inputType === 4 || inputType === 5 || inputType === 8 || inputType === 9) {
        const originalId = this.resolveFacilitySettingOptionId(
          originalItem,
          originalItem,
          "value",
          originalItem.value ?? originalItem.val
        );
        const currentId = this.resolveFacilitySettingOptionId(
          model,
          originalItem,
          editField,
          editedValue
        );
        return isEqual(originalId, currentId);
      }
      const originalValue = originalItem?.[editField];
      return isEqual(originalValue, editedValue);
    },
    isFacilitySettingRowUnchangedByModel(model, originalItem) {
      const inputType = Number(model.inputType);
      if (inputType === 6) {
        return isEqual(
          this.normalizeFacilitySettingCompareText(originalItem.dispValue),
          this.normalizeFacilitySettingCompareText(model.dispValue)
        );
      }
      if (inputType === 7) {
        return isEqual(
          this.normalizeMultiSelectValues(originalItem.value ?? originalItem.val),
          this.normalizeMultiSelectValues(model.value ?? model.val)
        );
      }
      if (inputType === 4 || inputType === 5 || inputType === 8 || inputType === 9 || inputType === 3) {
        const originalId = this.resolveFacilitySettingOptionId(
          originalItem,
          originalItem,
          "value",
          originalItem.value ?? originalItem.val
        );
        const currentId = this.resolveFacilitySettingOptionId(
          model,
          originalItem,
          "value",
          model.value ?? model.val
        );
        return isEqual(originalId, currentId);
      }
      if (inputType === 2) {
        return isEqual(String(originalItem.dispValue ?? ""), String(model.dispValue ?? ""));
      }
      return isEqual(originalItem.dispValue, model.dispValue);
    },
    applyFacilitySettingSaveValuesToModel(ev) {
      const model = ev?.model;
      if (!model || !ev?.values || typeof ev.values !== "object") {
        return;
      }
      Object.keys(ev.values).forEach((field) => {
        model[field] = ev.values[field];
      });
      if (Number(model.inputType) === 3) {
        this.syncFacilitySettingOnOffModel(model);
      } else if ([4, 5, 8, 9].includes(Number(model.inputType)) && (
        Object.prototype.hasOwnProperty.call(ev.values, "dispValue") ||
        Object.prototype.hasOwnProperty.call(ev.values, "value") ||
        Object.prototype.hasOwnProperty.call(ev.values, "val")
      )) {
        const optionList = this.parseJsonValue(model.optionValue, []);
        const savedValue = ev.values.value ?? ev.values.val ?? ev.values.dispValue ?? model.value ?? model.val ?? model.dispValue;
        const match = this.findOptionValueById(optionList, savedValue)
          || this.findOptionValueByName(optionList, savedValue);
        if (match) {
          model.value = String(match.id);
          model.val = String(match.id);
          model.dispValue = match.name;
        }
      }
    },
    scheduleFacilitySettingDropdownEditorCommit(model) {
      if (!model) {
        return;
      }
      const ownerWindow = this.$el?.ownerDocument?.defaultView || window;
      const runFallbackCommit = () => {
        if (!model || Number(model.operation) > 0) {
          return;
        }
        if (this.finalizeFacilitySettingRowIfRevertedToOriginal({ model })) {
          this.scheduleDirectGridLayoutContract();
          return;
        }
        this.editFlg = true;
        this.editingFlg = false;
        this.edit({ editRecord: model, isSortMode: false });
        if (Number(model.operation) > 0) {
          model.edited = true;
        }
        const markEditedRowVisual = () => {
          this.applyDirectGridRowVisualState(model, model?.uid);
          this.findDirectGridRowsForRecord(model, model?.uid).forEach((row) => {
            this.markFacilitySettingValueCellsEdited(row, model);
          });
        };
        this.scheduleDirectGridRowVisualState(model, model?.uid);
        this.$nextTick(() => {
          markEditedRowVisual();
          ownerWindow.requestAnimationFrame?.(markEditedRowVisual);
        });
        this.scheduleDirectGridLayoutContract();
      };
      this.$nextTick(() => {
        if (typeof ownerWindow.requestAnimationFrame === "function") {
          ownerWindow.requestAnimationFrame(runFallbackCommit);
        } else {
          ownerWindow.setTimeout(runFallbackCommit, 0);
        }
      });
    },
    restoreFacilitySettingRowFromOriginal(model) {
      const originalItem = this.findOriginalFacilitySetting(model);
      if (!originalItem) {
        return;
      }
      ["value", "val", "dispValue"].forEach((field) => {
        if (Object.prototype.hasOwnProperty.call(originalItem, field)) {
          model[field] = originalItem[field];
        }
      });
      model.operation = 0;
      model.edited = false;
      if (model.dirtyFields && typeof model.dirtyFields === "object") {
        Object.keys(model.dirtyFields).forEach((field) => {
          delete model.dirtyFields[field];
        });
      }
      model.dirty = false;
      const storeRecord = this.getMasterRecordList?.data?.find((item) =>
        String(item?.facilitySettingNo ?? "") === String(model?.facilitySettingNo ?? "")
        || String(item?.dispOrder ?? "") === String(model?.dispOrder ?? "")
      );
      if (storeRecord && storeRecord !== model) {
        ["value", "val", "dispValue"].forEach((field) => {
          if (Object.prototype.hasOwnProperty.call(originalItem, field)) {
            storeRecord[field] = originalItem[field];
          }
        });
        storeRecord.operation = 0;
        storeRecord.edited = false;
      }
    },
    isFacilitySettingRowInGridDataSource(model) {
      const grid = this.getDirectGridWidget();
      if (!grid?.dataSource || !model) {
        return false;
      }
      const items = grid.dataSource.data?.() || [];
      return items.some(
        (item) =>
          item === model ||
          item.uid === model.uid ||
          item.facilitySettingNo === model.facilitySettingNo
      );
    },
    refreshFacilitySettingGridRowAfterRevert(model) {
      const grid = this.getDirectGridWidget();
      if (!grid?.dataSource || !model) {
        return;
      }
      if (this.isFacilitySettingRowInGridDataSource(model)) {
        return;
      }
      const position = this.getGridScrollPosition();
      grid.dataSource.data(this.getDirectGridDisplayData());
      this.$nextTick(() => {
        this.applyDirectGridLegacyStyleContract();
        this.setGridScrollPosition(position);
        this.applyDirectGridRowVisualState(model, model.uid);
      });
    },
    findDirectGridRowsForRecord(record, preferredUid = null) {
      const grid = this.getDirectGridWidget();
      if (!grid || !record) {
        return [];
      }
      const uid = preferredUid || record.uid;
      if (uid) {
        const rowsByUid = Array.from(
          this.getDirectGridRootEl()?.querySelectorAll?.(`tbody tr[data-uid="${uid}"]`) || []
        );
        if (rowsByUid.length) {
          return rowsByUid;
        }
      }
      const data = grid.dataSource?.data?.() || [];
      const index = Array.from(data).findIndex(
        (item) =>
          item === record ||
          item.uid === record.uid ||
          item.dispOrder === record.dispOrder ||
          item.facilitySettingNo === record.facilitySettingNo
      );
      if (index < 0) {
        return [];
      }
      return Array.from(this.getDirectGridRootEl()?.querySelectorAll?.("tbody") || [])
        .map((tbody) => tbody.children?.[index])
        .filter(Boolean);
    },
    clearFacilitySettingGridRowActiveState(event) {
      const grid = this.getDirectGridWidget();
      const uid = event?.model?.uid;
      try {
        grid?.clearSelection?.();
      } catch (_error) {
        // noop
      }
      const rowClasses = ["k-selected", "k-state-selected", "k-grid-edit-row"];
      const cellClasses = [
        "k-state-selected",
        "k-selected",
        "k-edit-cell",
        "k-focus",
        "k-focused"
      ];
      const clearRow = (row) => {
        if (!row) {
          return;
        }
        rowClasses.forEach((className) => row.classList.remove(className));
        Array.from(row.children || []).forEach((cell) => {
          cellClasses.forEach((className) => cell.classList.remove(className));
        });
      };
      this.findDirectGridRowsForRecord(event?.model, uid).forEach(clearRow);
      if (uid) {
        const root = this.getDirectGridRootEl();
        root
          ?.querySelectorAll?.(`tbody tr[data-uid="${uid}"]`)
          ?.forEach?.(clearRow);
      }
    },
    clearFacilitySettingGridDirtyState(event) {
      const rows = this.findDirectGridRowsForRecord(event?.model, event?.model?.uid);
      rows.forEach((row) => {
        Array.from(row.children || []).forEach((cell) => {
          cell.classList.remove(
            "k-dirty-cell",
            "master-edited-cell",
            "master-edited-row",
            "master-sort-edited",
            "master-deleted-row"
          );
          cell.querySelector?.(".k-dirty")?.remove();
        });
      });
    },
    isFacilitySettingRecordEdited(record) {
      return Number(record?.operation || 0) > 0 || record?.edited === true;
    },
    /**
     * 編集終了時に初期値へ戻っている場合、dirty 表示を解除し store の変更フラグを戻す。
     * cancelChanges は direct jqGrid では行を dataSource から除去するため使用しない。
     * @param {Object} e - KendoGridのイベント引数
     * @returns {boolean} 初期値へ戻した場合 true
     */
    finalizeFacilitySettingRowIfRevertedToOriginal(e) {
      const model = e?.model;
      const originalItem = this.findOriginalFacilitySetting(model);
      if (!model || !originalItem) {
        return false;
      }
      if (!this.isFacilitySettingRowUnchanged(model, e)) {
        return false;
      }
      this.restoreFacilitySettingRowFromOriginal(model);
      this.clearFacilitySettingGridDirtyState(e);
      this.refreshFacilitySettingGridRowAfterRevert(model);
      this.$nextTick(() => {
        this.clearFacilitySettingGridDirtyState(e);
        this.clearFacilitySettingGridRowActiveState(e);
        this.applyDirectGridRowVisualState(model, model?.uid);
        this.tableKey += 1;
      });
      return true;
    },
    revertFacilitySettingRowIfUnchanged(e) {
      return this.finalizeFacilitySettingRowIfRevertedToOriginal(e);
    },

    // マスタ一覧のデータを取得
    async findList() {
      // スクロールの位置を維持
      let scrollTop = 0;
      let scrollLeft = 0;
      if (this.$refs.gridRoot != null) {
        const position = this.getGridScrollPosition();
        scrollTop = position.top;
        scrollLeft = position.left;
      }
      // 設定値リストのうちDB参照系をコールして再取得
      await this.setkendoGridDropList();

      // apiをコールして施設設定マスタの値を取得
      return this.getFacilitySettingDataList(this.facilitylistValue)
        .then(async response => {
          // editableをKendoUI用にfunctionオブジェクトに変換
          const toFunction = response.data.columns;
          toFunction.forEach(column => {
            // 編集可否を関数化
            column.editable = column.editable ? () => true : () => false;
            // 列幅初期化
            column["width"] = column.width ? column.width : "0";
          });
          this.columns = toFunction;

          // 横スクロールバーを表示するために列幅を指定
          this.columns.forEach(column => {
            // 設定説明列の幅を拡張するように指定
            column.width = column.field === "description" ? "24em" : "14em";
            column.encoded = column.field === "description" || column.field === "functionName" ? false : true;
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
          // 編集モードによって並び順項目の表示・非表示を切り替える（この画面ではソート順変更の変更はしない）
          // （先頭ダミー要素列と並び順列を交互に表示・非表示する）
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

          // マスタから選択肢の一覧をとる行の情報リスト
          let masterPhysicalNameList = [];
          // add #12462 患者情報共有 ligh start
          let options = [];
          // add #12462 患者情報共有 ligh end
          let referenceMasterList = [];

          // 画面表示項目と値格納項目の分離
          this.getMasterRecordList.data.forEach((columnData,index)=> {
            if(columnData.inputType === 9){
              // 施設別医師選択専用
              let matchData = this.kendoGridDrop.doctorList.filter(function(item){
                if(item.id == columnData.value) return true;
              });
              // 設定医師のデフォルトフォーカス
              if(matchData.length > 0){
                columnData.dispValue = matchData[0].name;
              }else{
                columnData.dispValue = " ";
              }
              columnData.optionValue = JSON.stringify(this.kendoGridDrop.doctorList);

            // add 施設設定マスタ 帳票未指定時のデフォルト帳票を指定可能 孔s start
            }else if(columnData.inputType === 8){
              // 帳票選択専用
              let matchData = this.kendoGridDrop.reportList.filter(function(item){
                if(item.id == columnData.value) return true;
              });
              if(matchData.length > 0){
                columnData.dispValue = matchData[0].name;
              }else{
                columnData.dispValue = " ";
              }
              columnData.optionValue = JSON.stringify(this.kendoGridDrop.reportList);
            // add 施設設定マスタ 帳票未指定時のデフォルト帳票を指定可能 孔s end

            // add redmine 4675 医療材料表示順、投与薬剤表示順の不正 孔 start
            }else if(columnData.inputType === 7){
              const jsonData = this.parseJsonValue(columnData.optionValue, []);
              // mod #12462 患者情報共有 ligh start
              if (jsonData.length == 1) {
                // 対象テーブルを取得
                const optionValueOld = this.parseJsonValue(columnData.optionValue);
                const masterPhysicalName = optionValueOld[0].master_physical_name;

                // この行の情報をリストに格納
                masterPhysicalNameList.push(masterPhysicalName);
                options.push(optionValueOld[0]);
                referenceMasterList.push({
                  masterPhysicalName: masterPhysicalName,
                  index: index
                });
              } else {
                const values = this.normalizeMultiSelectValues(columnData.value);
                columnData.value = JSON.stringify(values);
                columnData.val = JSON.stringify(values);
                columnData.dispValue = this.buildMultiSelectDisplayValue(jsonData, values, columnData);
              }
              // mod #12462 患者情報共有 ligh end
            // add redmine 4675 医療材料表示順、投与薬剤表示順の不正 孔 end
            }else if(columnData.inputType === 5){
              // 対象テーブルを取得
              const optionValueOld = this.parseJsonValue(columnData.optionValue)
              const masterPhysicalName = optionValueOld[0].master_physical_name;

              // この行の情報をリストに格納
              masterPhysicalNameList.push(masterPhysicalName);
              // add #12462 患者情報共有 ligh start
              options.push(optionValueOld[0]);
              // add #12462 患者情報共有 ligh end
              referenceMasterList.push({
                masterPhysicalName: masterPhysicalName,
                index: index
              });

            }else if(columnData.inputType === 4){
              const jsonData = this.parseJsonValue(columnData.optionValue, []);
              const matchData = this.findOptionValueById(jsonData, columnData.value);
              columnData.dispValue = matchData?.name ?? "";

            }else if (columnData.inputType === 3){
              const matchData = this.getFacilitySettingOnOffOptions().find(
                (item) => String(item.id) === String(columnData.value)
              );
              columnData.dispValue = matchData?.name ?? "";

            } else if (columnData.inputType === 2) {
              // 入力分類(inputType)が2:数値型の場合、処理内で数値型だったり文字列だったり揺れがある。数値型だと不都合な処理がある為、文字列に統一
              columnData.dispValue = columnData.value;
              if (columnData.dispValue != null) {
                columnData.dispValue = String(columnData.dispValue);
              }

            }else{
              columnData.dispValue = columnData.value;
            }

            if (columnData.facilitySettingNo == '1012' || columnData.facilitySettingNo == '1014') {
              // 時間項目の施設設定番号(facilitySettingNo)の場合、表示用に99:99フォーマットに変換
              columnData.dispValue = columnData.value;
              if (columnData.dispValue != null) {
                const str = String(columnData.dispValue);
                if (/^\d{4}$/.test(str)) {
                  columnData.dispValue = str.substring(0, 2) + ':' + str.substring(2);
                }
              }
            }
          });
          // マスタから選択肢の一覧をとる
          //del 施設設定マスタ バッグ修正 孔s start
          // const selectorResponse =
          //   await ApiHelper.get(
          //     `/facilitySetting/getSelectorDataList/${this.facilitylistValue}/${masterPhysicalNameList}`
          //   );
          //del 施設設定マスタ バッグ修正 孔s end
          //add 施設設定マスタ バッグ修正 孔s start
          let selectorResponse = [];
          // mod #12462 患者情報共有 ligh start
          // if(masterPhysicalNameList.length>0){
          //   selectorResponse =
          //     await ApiHelper.get(
          //       `/facilitySetting/getSelectorDataList/${this.facilitylistValue}/${masterPhysicalNameList}`
          //     )
          // }
          if(options.length>0){
            let facilityList = options.reduce((map, item) => {
              const key = item.facility_cd || '__NO_FACILITY__'
              if (!map[key]) {
                map[key] = []
              }
              map[key].push(item.master_physical_name)
              return map
            }, {});
            for (const key in facilityList) {
              const facilityCd = key === '__NO_FACILITY__' ? this.facilitylistValue : key
              const items = facilityList[key];
              let res = await ApiHelper.get(
                `/facilitySetting/getSelectorDataList/${facilityCd}/${items}`
              )
              selectorResponse.push(...res.data);
            }
          }

          // 共有設定を持つ施設リスト取得 Add ligh start
          let shrRes = await ApiHelper.get(
            `/shrPatInfo/facilityCdDown`
          )
          const shrFacilityList = shrRes.data.filterFacility || [];
          this.shrFacilityList = shrFacilityList;
          // 共有設定を持つ施設リスト取得 Add ligh end

          // mod #12462 患者情報共有 ligh end
          //add 施設設定マスタ バッグ修正 孔s end

          for (const ref of referenceMasterList) {

            // const mstSelector = selectorResponse.data.filter(item => {
            //   if (item.masterPhysicalName == ref.masterPhysicalName) return true;
            // });
            const mstSelector = selectorResponse.filter(item => {
              if (item.masterPhysicalName == ref.masterPhysicalName) return true;
            });
            let columnData = this.getMasterRecordList.data[ref.index];

            if (columnData.inputType == 7) {
              // 並び順管理マスタから設定値リストを抽出
              let jsonData = [];
              if (mstSelector[0]) {
                for (let item of mstSelector[0].orderSettings.items) {
                  if (mstSelector[0].masterPhysicalName == 'mst_facility') {
                    const facilityKey = String(item.code ?? item.name ?? "");
                    const matchedFacility = shrFacilityList.find(
                      (shrItem) =>
                        String(shrItem.facilityCd) === facilityKey
                        || String(shrItem.facilityName) === facilityKey
                    );
                    if (matchedFacility) {
                      jsonData.push({
                        id: matchedFacility.facilityCd,
                        name: matchedFacility.facilityName
                      });
                    }
                  } else {
                    jsonData.push({
                      id: item.code,
                      name: item.name
                    });
                  }
                }
              }
              if (
                String(columnData.facilitySettingNo) === SHR_PAT_INFO
                && jsonData.length === 0
                && Array.isArray(shrFacilityList)
              ) {
                shrFacilityList.forEach((shrItem) => {
                  jsonData.push({
                    id: shrItem.facilityCd,
                    name: shrItem.facilityName
                  });
                });
              }
              columnData.optionValue = JSON.stringify(jsonData);
              const values = this.normalizeMultiSelectValues(columnData.value);
              columnData.value = JSON.stringify(values);
              columnData.val = JSON.stringify(values);
              columnData.dispValue = this.buildMultiSelectDisplayValue(jsonData, values, columnData);
            } else {

              // 並び順管理マスタから設定値リストを抽出
              let jsonData = [{id: "-1", name: " "}];
              if (mstSelector[0]) {
                for (let item of mstSelector[0].orderSettings.items) {
                  jsonData.push({
                    id: item.code,
                    name: item.name
                  });
                }
              }
              columnData.optionValue = JSON.stringify(jsonData);

              // デフォルト値の選択
              let matchData = jsonData.filter(function (item) {
                if (item.id == columnData.value) return true;
              });

              if (matchData.length > 0) {
                columnData.dispValue = matchData[0].name;
              } else {
                columnData.dispValue = " ";
              }
            }

            this.getMasterRecordList.data[ref.index] = columnData;
          }
          this.setMasterRecordList(this.getMasterRecordList);
          // 初期値退避用オブジェクトに検索結果をディープコピー
          this.originalDataSource = cloneDeep(this.getMasterRecordList.data);
          this.tableKey += 1;
          // mod #12462 患者情報共有 ligh end
          // inputType5: getSelectorDataList 完了後に Grid を初期化しないと optionValue が placeholder のまま編集候補が空になる
          this.$nextTick(() => {
            this.calculateGridHeight();
            this.initDirectGridIfReady();
            this.applyDirectGridDataSourceContract();
            this.scheduleDirectGridLayoutContract();
            this.syncAllFacilitySettingDispValueCellDisplays();
            this.setGridScrollPosition({ top: scrollTop, left: scrollLeft });
          });

          // del redmine 4635 パンくずリストを用いて画面の再読み込みを行うとレイアウトが崩れる 孔 start
          // // 横スクロールバーを表示するために列幅を指定
          // this.columns.forEach(column => {
          //   // 設定説明列の幅を拡張するように指定
          //   column.width = column.field === "description" ? "24em" : "14em";
          //   column.encoded = column.field === "description" || column.field === "functionName" ? false : true;
          // });
          // // 先頭列ダミー要素追加（並び順列の変更内容が"かぶって"表示されてしまう事象の対応のため）
          // this.columns.unshift({
          //   title: " ",
          //   field: "dummy",
          //   hidden: false,
          //   editable: () => false,
          //   width: "10px",
          //   format: "",
          //   values: null
          // });
          //
          // // カラム幅等初期調整
          // // 編集モードによって並び順項目の表示・非表示を切り替える（この画面ではソート順変更の変更はしない）
          // // （先頭ダミー要素列と並び順列を交互に表示・非表示する）
          // const sortRankIndex = this.columns.findIndex(
          //   col => col.field === "sortRank"
          // );
          // if (sortRankIndex >= 0) {
          //   this.columns[sortRankIndex].hidden = true;
          //   const dummyIndex = this.columns.findIndex(
          //     col => col.field === "dummy"
          //   );
          //   if (dummyIndex >= 0) {
          //     this.columns[dummyIndex].hidden = false;
          //   }
          // }
          //
          // this.$nextTick(() => {
          //   this.calculateGridHeight();
          //   // 元のスクロール位置に移動
          //   this.$refs.grid.$el.children[1].scrollTop = scrollTop;
          //   this.$refs.grid.$el.children[1].scrollLeft = scrollLeft;
          // });
          // del redmine 4635 パンくずリストを用いて画面の再読み込みを行うとレイアウトが崩れる 孔 end
        })
        .catch(error => {
          const status = error?.response?.status;
          if (status === 400) {
            this.$ons.notification.alert({
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
              // title: "取得失敗",
              // message: "指定されたマスタが見つかりません。"
              title: DIALOG_MESSAGES[12000003].title,
              message: messageFormat(DIALOG_MESSAGES[12000003].message),
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
            });
            return;
          }
        });
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
          alert(error);
          const status = error?.response?.status;
          if (status === 400) {
            this.$ons.notification.alert({
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
              // title: "取得失敗",
              // message: "指定されたマスタが見つかりません。"
              title: DIALOG_MESSAGES[12000003].title,
              message: messageFormat(DIALOG_MESSAGES[12000003].message),
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
            });
            return;
          }
        });
    },
    setFilterCondition(condition) {
      this.condition.userType = this.getStateUserAccountInfo.userType;
      this.condition.recordName = condition.recordName;
      this.$nextTick(() => {
        this.applyDirectGridDataSourceContract({ resetScroll: true });
      });
    },
    setFacilitylistValue() {
      this.facilitylistValue = this.getStateUserAccountInfo.facilityCd;
    },

    async setkendoGridDropList(){
      // 施設別医師リスト取得
      const doctorResponse= await this.getDoctorsAtFacility(this.facilitylistValue);
      let doctorList = [{id: "0", name: " "}];
      doctorResponse.data.forEach(doctor => {
        doctorList.push({
          id:`${doctor.user_id}`,
          name:`${doctor.user_last_name} ${doctor.user_first_name}`
        });
      });
      this.kendoGridDrop.doctorList = doctorList;

      // add 施設設定マスタ 帳票未指定時のデフォルト帳票を指定可能 孔s start
      // 帳票リスト取得
      // mod #12326 【因島】帳票マスタの「非表示」設定が意図せぬ動作をしている sunsy start
      // const reportResponse = await ApiHelper.get(`/report/getMstReportByFacilityCd/${this.facilitylistValue}`)
      const reportResponse = await ApiHelper.get(`/report/getMstReportByFacilityCdNoIsDisp/${this.facilitylistValue}`)
      // mod #12326 【因島】帳票マスタの「非表示」設定が意図せぬ動作をしている sunsy end
      let reportList = [{id: "0", name: " "}];
      if (reportResponse.data && reportResponse.data.length > 0) {
        reportResponse.data.forEach(report => {
          if (report.reportClass === 1) {
            reportList.push({
              id:`${report.reportCd}`,
              name:`${report.reportName}`
            });
          }
        });
      }
      this.kendoGridDrop.reportList = reportList;
      // add 施設設定マスタ 帳票未指定時のデフォルト帳票を指定可能 孔s end
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
            // mod #6107 2023/03/23 メッセージボックス全調整 張博 end,
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
        const gridHeader = this.getGridHeaderEl();
        if (gridHeader?.textContent != null && gridHeader.textContent !== " ") {
          // #8519 編集した項目のバッググラウンドが黄緑にならない 訾浩 start
          // return;
          gridHeader.classList?.add("master-grid-header")
          // #8519 編集した項目のバッググラウンドが黄緑にならない 訾浩 end
        }
        // グリッドにレコードがなければ処理終了
        if (!this.getGridTableEl()?.tBodies || !this.getGridTbodyEl()) {
          return;
        }

        const tbodyc = this.getGridTbodyEl()
          .children;
        for (let rwCount = 0; rwCount < tbodyc.length; rwCount++) {
          const currentTrc = tbodyc[rwCount].children;

          // 編集項目の色を変更
          let edited = this.changeEditColor(currentTrc);

          // 並び順以外の項目が変更されていた場合は、削除か修正にあわせて並び順より後の項目の背景色を変更
          this.changeRowColor(currentTrc, edited, false);
        }
      });
    },
    changeEditColor(currentTrc) {
      let edited = false;
      const row = currentTrc[0]?.parentElement;
      // 変更されたセルの文字色を変更
      for (let clCount = 0; clCount < currentTrc.length; clCount++) {
        const field = row
          ? this.getDirectGridColumnFieldForRow(row, clCount)
          : this.getDirectGridColumnField(clCount);
        if (this.isEditRow(currentTrc[clCount]) && field !== "sortRank") {
          currentTrc[clCount].classList?.add("master-edited-cell");
          edited = true;
          if ((field === "value" || field === "dispValue") && row) {
            const record = this.getDirectGridWidget()?.dataItem?.(row);
            this.markFacilitySettingValueCellsEdited(row, record);
          }
        }
      }
      return edited;
    },
    isEditRow(currentTd) {
      // 編集した行を判定
      return currentTd.classList.contains("k-dirty-cell");
    },
    changeRowColor(currentTrc, edited, deleted) {
      if (!edited && !deleted) {
        return;
      }
      const addClass = deleted ? "master-deleted-row" : "master-edited-row";
      const row = currentTrc[0]?.parentElement;
      if (!row) {
        return;
      }
      const leafColumns = this.getDirectGridLeafColumnsForRow(row);
      const sortRankIndex = leafColumns.findIndex((column) => column.field === "sortRank");
      const startIndex = sortRankIndex >= 0 ? sortRankIndex + 1 : 0;
      for (let clCount = startIndex; clCount < currentTrc.length; clCount++) {
        currentTrc[clCount].classList?.add(addClass);
      }
    },
    getColumnIndex(fieldName) {
      // 指定された項目がない場合はマイナスが返る
      return this.columns.findIndex(e => e.field === fieldName);
    },
    getDirectGridWidget() {
      return this.directGridWidget || $(this.$refs.gridRoot).data("kendoGrid") || null;
    },
    getDirectGridRootEl() {
      return this.$refs.gridRoot || null;
    },
    getDirectGridContentEl() {
      const grid = this.getDirectGridWidget();
      return grid?.content?.[0] || this.getDirectGridRootEl()?.querySelector?.(".k-grid-content") || null;
    },
    getDirectGridLockedContentEl() {
      const grid = this.getDirectGridWidget();
      return grid?.lockedContent?.[0] || this.getDirectGridRootEl()?.querySelector?.(".k-grid-content-locked") || null;
    },
    getGridHeaderEl() {
      return this.getDirectGridRootEl()?.querySelector?.(".k-grid-header") || null;
    },
    getGridTableEl() {
      return this.getDirectGridWidget()?.table?.[0] || this.getDirectGridRootEl()?.querySelector?.(".k-grid-content table") || null;
    },
    getGridTbodyEl() {
      return this.getDirectGridWidget()?.tbody?.[0] || this.getDirectGridRootEl()?.querySelector?.(".k-grid-content tbody") || null;
    },
    getDirectGridVisibleColumns() {
      const grid = this.getDirectGridWidget();
      return (grid?.columns || this.columns || []).filter((column) => !column.hidden);
    },
    getDirectGridCellIndex(cellEl) {
      if (cellEl && typeof cellEl.cellIndex === "number") {
        return cellEl.cellIndex;
      }
      return -1;
    },
    getDirectGridColumnField(index) {
      if (index < 0) {
        return undefined;
      }
      const visibleColumns = this.getDirectGridVisibleColumns();
      return visibleColumns[index]?.field;
    },
    flattenDirectGridLeafColumns(columns = []) {
      const result = [];
      (columns || []).forEach((column) => {
        if (Array.isArray(column?.columns) && column.columns.length) {
          result.push(...this.flattenDirectGridLeafColumns(column.columns));
          return;
        }
        result.push(column);
      });
      return result;
    },
    invalidateDirectGridColumnFieldCache() {
      this.directGridBodyColumnFields = null;
      this.directGridLockedColumnFields = null;
      this.facilitySettingDispValueBodyColumnIndex = null;
    },
    getFacilitySettingDispValueBodyColumnIndex() {
      if (typeof this.facilitySettingDispValueBodyColumnIndex === "number") {
        return this.facilitySettingDispValueBodyColumnIndex;
      }
      const root = this.getDirectGridRootEl();
      const headerTable = root?.querySelector(".k-grid-header-wrap table")
        || root?.querySelector(".k-grid-header table");
      const headerCells = headerTable?.querySelectorAll("thead tr th");
      if (headerCells?.length) {
        const headers = Array.from(headerCells);
        for (let i = 0; i < headers.length; i++) {
          if (headers[i].getAttribute("data-field") === "dispValue") {
            this.facilitySettingDispValueBodyColumnIndex = i;
            return i;
          }
        }
        for (let i = 0; i < headers.length; i++) {
          if (String(headers[i].textContent ?? "").trim() === "設定値") {
            this.facilitySettingDispValueBodyColumnIndex = i;
            return i;
          }
        }
      }
      return this.getDirectGridBodyColumnFields().indexOf("dispValue");
    },
    getDirectGridBodyColumnFields() {
      if (Array.isArray(this.directGridBodyColumnFields)) {
        return this.directGridBodyColumnFields;
      }
      const sourceColumns = this.getDirectGridWidget()?.columns || this.columns || [];
      this.directGridBodyColumnFields = this.flattenDirectGridLeafColumns(sourceColumns)
        .filter((column) => !column.hidden && !column.locked)
        .map((column) => column.field)
        .filter(Boolean);
      return this.directGridBodyColumnFields;
    },
    getDirectGridLockedColumnFields() {
      if (Array.isArray(this.directGridLockedColumnFields)) {
        return this.directGridLockedColumnFields;
      }
      const sourceColumns = this.getDirectGridWidget()?.columns || this.columns || [];
      this.directGridLockedColumnFields = this.flattenDirectGridLeafColumns(sourceColumns)
        .filter((column) => !column.hidden && !!column.locked)
        .map((column) => column.field)
        .filter(Boolean);
      return this.directGridLockedColumnFields;
    },
    isDirectGridLockedRow(row) {
      return !!row?.closest?.(".k-grid-content-locked");
    },
    getDirectGridLeafColumnsForRow(row) {
      const grid = this.getDirectGridWidget();
      const sourceColumns = grid?.columns || this.columns || [];
      return this.flattenDirectGridLeafColumns(sourceColumns).filter(
        (column) => !column.hidden && !!column.locked === this.isDirectGridLockedRow(row)
      );
    },
    getDirectGridVisibleColumnsForRow(row) {
      return this.getDirectGridLeafColumnsForRow(row);
    },
    getDirectGridColumnFieldForRow(row, cellIndex) {
      if (cellIndex < 0) {
        return undefined;
      }
      const cell = row?.children?.[cellIndex];
      const dataField = cell?.getAttribute?.("data-field");
      if (dataField) {
        return dataField;
      }
      return this.getDirectGridLeafColumnsForRow(row)[cellIndex]?.field;
    },
    findFacilitySettingDispValueCell(row, record = null) {
      if (!row || this.isDirectGridLockedRow(row)) {
        return null;
      }
      const byDataField = row.querySelector?.('td[data-field="dispValue"]');
      if (byDataField) {
        return byDataField;
      }
      const columnIndex = this.getFacilitySettingDispValueBodyColumnIndex();
      if (columnIndex >= 0) {
        const cell = row.children?.[columnIndex];
        if (cell) {
          return cell;
        }
      }
      const model = record || this.getDirectGridWidget()?.dataItem?.(row);
      if (model?.dispValue == null) {
        return null;
      }
      const dispText = String(model.dispValue);
      return Array.from(row.children || []).find((td) => {
        const text = td.textContent ?? "";
        return text === dispText || text.trim() === dispText.trim();
      }) || null;
    },
    markFacilitySettingValueCellsEdited(row, record = null) {
      this.findFacilitySettingDispValueCell(row, record)?.classList.add("master-edited-cell");
    },
    syncFacilitySettingMultiSelectDisplayModel(model) {
      if (!model || Number(model.inputType) !== 7) {
        return;
      }
      this.syncFacilitySettingMultiSelectModelFromStore(model);
      const optionValue = this.resolveFacilitySettingEditorOptionList(model);
      const values = this.normalizeMultiSelectValues(model.val ?? model.value);
      model.val = JSON.stringify(values);
      model.value = JSON.stringify(values);
      model.dispValue = this.buildMultiSelectDisplayValue(optionValue, values, model);
    },
    getGridScrollPosition() {
      const content = this.getDirectGridContentEl();
      return {
        top: content?.scrollTop || 0,
        left: content?.scrollLeft || 0
      };
    },
    setGridScrollPosition(position = {}) {
      const content = this.getDirectGridContentEl();
      const lockedContent = this.getDirectGridLockedContentEl();
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
    buildDirectGridDataSourceConfig() {
      const source = this.masterRecords || { data: [] };
      if (Array.isArray(source)) {
        return { data: source };
      }
      // Vue2 の <kendo-grid :data-source="masterRecords"> は data/schema/model を参照で渡す。
      // JSON clone すると validation / model / row object が脱落するため、direct jq でも浅い option に留める。
      return {
        ...source,
        data: Array.isArray(source.data) ? source.data : []
      };
    },
    getDirectGridDisplayData() {
      const source = this.masterRecords;
      if (Array.isArray(source)) {
        return source;
      }
      return Array.isArray(source?.data) ? source.data : [];
    },
    buildDirectGridColumns() {
      return (this.columns || []).map((column) => {
        const directColumn = { ...column };
        if (column.field === "dispOrder") {
          directColumn.width = "4em";
          directColumn.editor = this.editorInput;
        } else if (column.title === "設定値" || column.field === "dispValue") {
          directColumn.editor = this.editorInput;
          // direct jq 移行後は dispValue の DOM 反映が save / cellClose まで遅れる行があるため、
          // 設定値列は model から表示文言を毎回解決する。
          directColumn.template = (dataItem) => this.resolveFacilitySettingDisplayText(dataItem);
        }
        return directColumn;
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
    applyDirectGridColumnsContract() {
      const grid = this.getDirectGridWidget();
      if (!grid) {
        return;
      }
      const nextSignature = this.getDirectGridColumnSignature();
      if (this.directGridColumnSignature !== nextSignature) {
        grid.setOptions({ columns: this.buildDirectGridColumns() });
        this.directGridColumnSignature = nextSignature;
        this.invalidateDirectGridColumnFieldCache();
      }
    },
    initDirectGridIfReady() {
      if (!this.directGridMounted || this.columns.length <= 1 || !this.$refs.gridRoot) {
        return;
      }
      installComponentJQuery();
      const $gridRoot = $(this.$refs.gridRoot);
      const existingGrid = $gridRoot.data("kendoGrid");
      if (existingGrid) {
        this.directGridWidget = markRaw(existingGrid);
        this.applyDirectGridColumnsContract();
        this.applyDirectGridDataSourceContract();
        this.scheduleDirectGridLayoutContract();
        return;
      }
      const dataSourceConfig = this.buildDirectGridDataSourceConfig();
      this.directGridDataSource = markRaw(new kendo.data.DataSource(dataSourceConfig));
      this.applyDirectGridLegacyShellClasses();
      $gridRoot.kendoGrid({
        dataSource: this.directGridDataSource,
        columns: this.buildDirectGridColumns(),
        editable: true,
        selectable: true,
        reorderable: false,
        height: this.kendoGridHeight,
        scrollable: true,
        beforeEdit: this.editStart,
        cellClose: this.editEnd,
        save: this.onSave,
        dataBound: this.onDataBoundKendoGrid
      });
      this.directGridWidget = markRaw($gridRoot.data("kendoGrid"));
      this.directGridReady = !!this.directGridWidget;
      this.directGridColumnSignature = this.getDirectGridColumnSignature();
      this.invalidateDirectGridColumnFieldCache();
      this.applyDirectGridLegacyStyleContract();
      this.scheduleDirectGridLayoutContract();
    },
    destroyDirectGrid() {
      if (this.directGridLayoutRafId != null) {
        cancelAnimationFrame(this.directGridLayoutRafId);
        this.directGridLayoutRafId = null;
      }
      if (this.directGridDataSourceRafId != null) {
        cancelAnimationFrame(this.directGridDataSourceRafId);
        this.directGridDataSourceRafId = null;
      }
      if (this.directGridScrollSyncRafId != null) {
        cancelAnimationFrame(this.directGridScrollSyncRafId);
        this.directGridScrollSyncRafId = null;
      }
      this.directGridRowVisualRafIds?.forEach?.((rafId) => cancelAnimationFrame(rafId));
      this.directGridRowVisualRafIds?.clear?.();
      const grid = this.getDirectGridWidget();
      if (grid) {
        grid.destroy();
      }
      if (this.$refs.gridRoot) {
        $(this.$refs.gridRoot).empty();
      }
      this.directGridWidget = null;
      this.directGridDataSource = null;
      this.directGridReady = false;
      this.directGridColumnSignature = "";
    },
    applyDirectGridDataSourceContract(options = {}) {
      const { resetScroll = false } = options;
      if (!this.directGridMounted || this.columns.length <= 1) {
        return;
      }
      if (!this.getDirectGridWidget()) {
        this.initDirectGridIfReady();
        return;
      }
      if (this.directGridDataSourceRafId != null) {
        cancelAnimationFrame(this.directGridDataSourceRafId);
      }
      this.directGridDataSourceRafId = requestAnimationFrame(() => {
        this.directGridDataSourceRafId = null;
        const grid = this.getDirectGridWidget();
        if (!grid?.dataSource) {
          return;
        }
        const position = resetScroll ? { top: 0, left: 0 } : this.getGridScrollPosition();
        grid.dataSource.data(this.getDirectGridDisplayData());
        this.$nextTick(() => {
          this.applyDirectGridLegacyStyleContract();
          this.refreshDirectGridVisualState();
          try {
            grid.refresh?.();
          } catch (_error) {
            // noop
          }
          this.syncAllFacilitySettingDispValueCellDisplays();
          this.setGridScrollPosition(position);
        });
      });
    },
    resizeDirectGrid() {
      const grid = this.getDirectGridWidget();
      if (!grid) {
        return;
      }
      try {
        grid.resize?.(true);
      } catch (_error) {
        grid.resize?.();
      }
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
          this.scheduleDirectGridLockedScrollContract();
        });
      });
    },
    scheduleDirectGridLockedScrollContract() {
      if (this.directGridScrollSyncRafId != null) {
        cancelAnimationFrame(this.directGridScrollSyncRafId);
      }
      this.directGridScrollSyncRafId = requestAnimationFrame(() => {
        this.directGridScrollSyncRafId = requestAnimationFrame(() => {
          this.directGridScrollSyncRafId = null;
          const position = this.getGridScrollPosition();
          this.setGridScrollPosition(position);
        });
      });
    },
    applyDirectGridLockedWidthContract() {
      const root = this.getDirectGridRootEl();
      if (!root) {
        return;
      }
      const lockedHeader = root.querySelector(".k-grid-header-locked");
      const lockedContent = root.querySelector(".k-grid-content-locked");
      const lockedContainer = root.querySelector(".k-grid-header-locked, .k-grid-content-locked")?.parentElement;
      if (!lockedHeader && !lockedContent) {
        return;
      }
      const fontSize = parseFloat(getComputedStyle(root).fontSize || "16") || 16;
      const lockedWidth = (this.columns || [])
        .filter((column) => column.locked && !column.hidden)
        .reduce((total, column) => total + this.resolveDirectGridColumnWidth(column.width, fontSize), 0);
      if (lockedWidth <= 0) {
        return;
      }
      [lockedHeader, lockedContent, lockedContainer].forEach((element) => {
        if (element) {
          element.style.width = `${lockedWidth}px`;
          element.style.minWidth = `${lockedWidth}px`;
        }
      });
      root.querySelectorAll(".k-grid-header-locked table,.k-grid-content-locked table").forEach((element) => {
        element.style.width = `${lockedWidth}px`;
        element.style.minWidth = `${lockedWidth}px`;
      });
    },
    applyDirectGridLockedHeightContract() {
      const content = this.getDirectGridContentEl();
      const lockedContent = this.getDirectGridLockedContentEl();
      if (!content || !lockedContent) {
        return;
      }
      const contentHeight = content.clientHeight;
      if (contentHeight > 0) {
        lockedContent.style.height = `${contentHeight}px`;
        lockedContent.style.maxHeight = `${contentHeight}px`;
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
      const root = this.getDirectGridRootEl();
      if (!root) {
        return;
      }
      root.classList.add("ntss-kendo-grid-legacy", "k-widget", "k-grid", "k-editable", "k-display-block");
    },
    applyDirectGridLegacyContentClasses() {
      const root = this.getDirectGridRootEl();
      if (!root) {
        return;
      }
      root.querySelectorAll("th").forEach((th) => th.classList.add("k-header"));
      const grid = this.getDirectGridWidget();
      root.querySelectorAll(".k-grid-content tbody tr, .k-grid-content-locked tbody tr").forEach((tr, index) => {
        tr.classList.add("k-master-row");
        tr.classList.toggle("k-alt", index % 2 === 1);
        if (grid?.dataItem) {
          try {
            const dataItem = grid.dataItem(tr);
            if (dataItem) {
              tr.__ntssKendoDataItem = dataItem;
            }
          } catch (_error) {
            // noop
          }
        }
      });
      root.querySelectorAll("td").forEach((td) => td.classList.add("k-td", "k-table-td"));
    },
    applyDirectGridLegacyStyleContract() {
      this.applyDirectGridLegacyShellClasses();
      this.applyDirectGridLegacyContentClasses();
      this.applyDirectGridLockedWidthContract();
      this.applyDirectGridLockedHeightContract();
    },
    applyDirectGridRowVisualState(record, preferredUid = null) {
      const rows = this.findDirectGridRowsForRecord(record, preferredUid);
      if (!rows.length || !record) {
        return;
      }
      const editedByStore = this.isFacilitySettingRecordEdited(record);
      const unchanged = !editedByStore && this.isFacilitySettingRowUnchanged(record);

      rows.forEach((row) => {
        const cells = Array.from(row.children || []);
        const isLocked = !!row.closest?.(".k-grid-content-locked");
        const hadDirty = cells.some((cell) => cell.classList.contains("k-dirty-cell"));

        cells.forEach((cell) => {
          cell.classList.remove(
            "master-edited-cell",
            "master-edited-row",
            "master-deleted-row",
            "master-sort-edited"
          );
          if (unchanged) {
            cell.classList.remove("k-dirty-cell");
            cell.querySelector?.(".k-dirty")?.remove();
          }
        });

        if (unchanged) {
          return;
        }

        const rowEdited = editedByStore || hadDirty;
        if (!rowEdited) {
          return;
        }

        if (!isLocked) {
          cells.forEach((cell) => {
            cell.classList.add("master-edited-row");
          });
          this.markFacilitySettingValueCellsEdited(row, record);
        }

        cells.forEach((cell, cellIndex) => {
          const field = this.getDirectGridColumnFieldForRow(row, cellIndex);
          if (cell.classList.contains("k-dirty-cell") && field !== "sortRank") {
            cell.classList.add("master-edited-cell");
          }
          if (field === "value" || field === "dispValue") {
            this.markFacilitySettingValueCellsEdited(row, record);
          }
        });
      });

      if (unchanged) {
        this.clearFacilitySettingGridRowActiveState({ model: record });
      }
    },
    scheduleDirectGridRowVisualState(record, preferredUid = null) {
      const key = String(record?.facilitySettingNo || record?.dispOrder || preferredUid || "__row__");
      if (!this.directGridRowVisualRafIds) {
        this.directGridRowVisualRafIds = markRaw(new Map());
      }
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
    refreshDirectGridVisualState() {
      const grid = this.getDirectGridWidget();
      if (!grid?.dataSource) {
        return;
      }
      const data = grid.dataSource.data();
      Array.from(data || []).forEach((record) => this.applyDirectGridRowVisualState(record, record.uid));
    },

    syncFacilitySettingPersistValues(columnData) {
      const inputType = Number(columnData?.inputType);
      if (inputType === 4 || inputType === 5 || inputType === 8 || inputType === 9) {
        const jsonData = this.resolveFacilitySettingEditorOptionList(columnData);
        const strictMatch = jsonData.find(
          (item) =>
            String(item.name) === String(columnData.dispValue)
            && String(item.id) === String(columnData.val ?? columnData.value)
        );
        const byVal = this.findOptionValueById(jsonData, columnData.val ?? columnData.value);
        const byDisp = this.findOptionValueByName(jsonData, columnData.dispValue);
        const match = strictMatch || byVal || byDisp;
        if (match) {
          columnData.value = String(match.id);
          columnData.val = String(match.id);
          columnData.dispValue = match.name;
        }
        return;
      }
      if (inputType === 7) {
        const jsonData = this.resolveFacilitySettingEditorOptionList(columnData);
        const valueData = this.normalizeMultiSelectValues(columnData.val || columnData.value);
        const normalizedValues = valueData.filter((value) => this.findOptionValueById(jsonData, value));
        columnData.val = JSON.stringify(normalizedValues);
        columnData.value = JSON.stringify(normalizedValues);
        columnData.dispValue = this.buildMultiSelectDisplayValue(jsonData, normalizedValues, columnData);
        return;
      }
      if (inputType === 3) {
        const match = this.getFacilitySettingOnOffOptions().find(
          (item) => String(item.name) === String(columnData.dispValue)
        ) || this.getFacilitySettingOnOffOptions().find(
          (item) => String(item.id) === String(columnData.value ?? columnData.val)
        );
        if (match) {
          columnData.value = match.id;
          columnData.val = match.id;
          columnData.dispValue = match.name;
        }
        return;
      }
      columnData.value = columnData.dispValue;
    },
    async saveRecord() {
      // 共通ローダー:表示開始
      this.setLoadingScreenVisible(true);
      try {
        //イベント発生前のスクロールバーの位置を保持
        const { top: scrollTop, left: scrollLeft } = this.getGridScrollPosition();
        this.scrollTop = scrollTop;
        this.scrollLeft = scrollLeft;
        // masterListの表示値から登録値を再設定(ドロップダウンリストの表示と値を再設定)
        //画面表示項目と値格納項目の再分離
        this.getMasterRecordList.data.forEach((columnData) => {
          this.syncFacilitySettingPersistValues(columnData);
        });
        this.setMasterRecordList(this.getMasterRecordList);

        // 登録用項目一覧
        const keys = [
          "facilitySettingNo",
          "value"
        ];

        // 必須入力チェック
        if (!this.isFilledRequired()) {
          return;
        }

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
        await ApiHelper.put("/master_maintenance/saveMstFacilitySetting", editRecord);

        // サインイン失敗時の設定
        await this.setSignInFailSetting(this.facilitylistValue);

        this.$ons.notification.alert({
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
          // title: "更新完了",
          // message: "マスタ更新が完了しました。"
          title: DIALOG_MESSAGES[12000004].title,
          message: messageFormat(DIALOG_MESSAGES[12000004].message),
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
        });

        await this.findList();
      } catch (error) {
        console.error("[mst-facility-setting] saveRecord failed", error);
      } finally {
        // 共通ローダー:表示終了（例外時も必ず閉じる）
        this.setLoadingScreenVisible(false);
      }
    },
    /**
     * @description 必須項目チェック
     * @summary 未入力の必須項目があったらダイアログを表示する
     * @returns {Boolean} true: 未入力なし, false: 未入力あり
     */
    isFilledRequired() {
      // 設定によって必須の有無が変わる項目の値を取得
      const urlSignin = this.getUpdateRecordList.find(
        item => item.facilitySettingNo === URL_SIGNIN
      );
      let req = false;
      // URLサインイン設定で、秘密鍵が必要な場合のみ必須判定する
      if (urlSignin && urlSignin.value === "1") {
        req = this.getUpdateRecordList.some(
          item => item.facilitySettingNo === URL_SIGNIN_SECRETKEY && (item.dispValue === null || item.dispValue === "")
        )
      }
      if (
        this.getUpdateRecordList.some(
          item => item.facilitySettingNo != URL_SIGNIN_SECRETKEY &&
            item.facilitySettingNo != TREATMENT_PROGRESS_CHART &&
            item.facilitySettingNo != TREATMENT_PROGRESS_CHART_HANDWRITING &&
            item.facilitySettingNo != DAILY_INSPECTION_RECORD_BOOK &&
            item.facilitySettingNo != PERIODIC_INSPECTION_RECORD_BOOK &&
            // add #12462 患者情報共有 ligh start
            item.facilitySettingNo != SHR_PAT_INFO &&
            // add #12462 患者情報共有 ligh end
            item.facilitySettingNo != STATUS_MAP_TREATMENT_INDICATOR &&
            item.facilitySettingNo != STATUS_MAP_SCHEDULE_INDICATOR &&
            (item.dispValue === null || item.dispValue === "")) || req) {
        this.isDialogVisible = true;
        this.messageCd = 20010002;
        this.stringParams = ["設定値"];
        return false;
      }
      return true;
    },

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
                this.clearScrollPosition();
                this.findList();
              }
            }
          });
        } else {
          this.clearScrollPosition();
          this.findList();
        }
      }
    },
    /**
     * @description スクロールバーの位置をクリアする
     */
    clearScrollPosition() {
      this.scrollTop = 0;
      this.scrollLeft = 0;
    },
    parseLegacyFacilitySettingOptionList(value) {
      if (typeof value !== "string" || !/^\s*\[\s*\{/.test(value) || !/\bid\s*:/.test(value)) {
        return null;
      }
      const items = [];
      const pattern = /\{id\s*:\s*([^,}]+)\s*,\s*name\s*:\s*(.+?)\s*\}/g;
      let match = pattern.exec(value);
      while (match) {
        items.push({
          id: String(match[1]).trim(),
          name: String(match[2]).trim(),
        });
        match = pattern.exec(value);
      }
      return items.length > 0 ? items : null;
    },
    parseJsonValue(value, fallback = null) {
      if (value == null || value === "") {
        return fallback;
      }
      if (typeof value !== "string") {
        return value;
      }
      try {
        return JSON.parse(value);
      } catch (_error) {
        const legacyList = this.parseLegacyFacilitySettingOptionList(value);
        if (legacyList != null) {
          return legacyList;
        }
        return fallback;
      }
    },
    isFacilitySettingSelectorPlaceholder(list) {
      return Array.isArray(list)
        && list.length === 1
        && list[0]?.master_physical_name
        && list[0]?.id == null
        && list[0]?.name == null;
    },
    syncFacilitySettingMultiSelectModelFromStore(model) {
      if (!model || Number(model.inputType) !== 7) {
        return;
      }
      const storeRow = (this.getMasterRecordList?.data || []).find((row) => {
        if (model.facilitySettingNo != null && row?.facilitySettingNo != null) {
          return String(row.facilitySettingNo) === String(model.facilitySettingNo);
        }
        return model.dispOrder != null && String(row.dispOrder) === String(model.dispOrder);
      });
      if (!storeRow) {
        return;
      }
      const storeList = this.parseJsonValue(storeRow.optionValue, []);
      if (Array.isArray(storeList) && !this.isFacilitySettingSelectorPlaceholder(storeList) && storeList.length > 0) {
        model.optionValue = storeRow.optionValue;
      }
      if ((model.dispValue == null || String(model.dispValue).trim() === "") && storeRow.dispValue != null) {
        model.dispValue = storeRow.dispValue;
      }
    },
    getFacilitySettingModelField(model, field) {
      if (!model) {
        return undefined;
      }
      if (typeof model.get === "function") {
        const value = model.get(field);
        return value !== undefined ? value : model[field];
      }
      return model[field];
    },
    setFacilitySettingModelField(model, field, value) {
      if (!model) {
        return;
      }
      if (typeof model.set === "function") {
        model.set(field, value);
        return;
      }
      model[field] = value;
    },
    ensureFacilitySettingModelDispValue(model) {
      if (!model) {
        return;
      }
      const currentDispValue = this.getFacilitySettingModelField(model, "dispValue");
      if (currentDispValue != null && String(currentDispValue).trim() !== "") {
        return;
      }
      this.syncFacilitySettingSelectorModelFromStore(model);
      const syncedDispValue = this.getFacilitySettingModelField(model, "dispValue");
      if (syncedDispValue != null && String(syncedDispValue).trim() !== "") {
        return;
      }
      const inputType = Number(this.getFacilitySettingModelField(model, "inputType"));
      if (inputType === 3) {
        this.syncFacilitySettingOnOffModel(model);
        return;
      }
      if (inputType === 7) {
        this.syncFacilitySettingMultiSelectDisplayModel(model);
        return;
      }
      if ([4, 5, 8, 9].includes(inputType)) {
        const optionList = this.resolveFacilitySettingEditorOptionList(model);
        const value = this.getFacilitySettingModelField(model, "value")
          ?? this.getFacilitySettingModelField(model, "val");
        const match = this.findOptionValueById(optionList, value);
        if (match?.name != null) {
          this.setFacilitySettingModelField(model, "dispValue", match.name);
        }
        return;
      }
      const rawValue = this.getFacilitySettingModelField(model, "value");
      if (rawValue != null && rawValue !== "") {
        this.setFacilitySettingModelField(model, "dispValue", String(rawValue));
      }
    },
    resolveFacilitySettingDisplayText(model) {
      if (!model) {
        return "";
      }
      this.ensureFacilitySettingModelDispValue(model);
      const dispValue = this.getFacilitySettingModelField(model, "dispValue");
      return dispValue == null ? "" : String(dispValue);
    },
    syncFacilitySettingDispValueCellDisplay(record, preferredUid = null) {
      if (!record) {
        return;
      }
      const displayText = this.resolveFacilitySettingDisplayText(record);
      const rows = this.findDirectGridRowsForRecord(record, preferredUid);
      rows.forEach((row) => {
        if (this.isDirectGridLockedRow(row)) {
          return;
        }
        const cell = this.findFacilitySettingDispValueCell(row, record);
        if (!cell || cell.classList.contains("k-edit-cell")) {
          return;
        }
        if ((cell.textContent ?? "") !== displayText) {
          cell.textContent = displayText;
        }
      });
    },
    syncAllFacilitySettingDispValueCellDisplays() {
      const grid = this.getDirectGridWidget();
      if (!grid?.dataSource) {
        return;
      }
      Array.from(grid.dataSource.data() || []).forEach((record) => {
        this.syncFacilitySettingDispValueCellDisplay(record, record?.uid);
      });
    },
    syncFacilitySettingSelectorModelFromStore(model) {
      if (!model || ![4, 5, 8, 9].includes(Number(model.inputType))) {
        return;
      }
      const storeRow = (this.getMasterRecordList?.data || []).find((row) => {
        if (model.facilitySettingNo != null && row?.facilitySettingNo != null) {
          return String(row.facilitySettingNo) === String(model.facilitySettingNo);
        }
        return model.dispOrder != null && String(row.dispOrder) === String(model.dispOrder);
      });
      if (!storeRow) {
        return;
      }
      const storeList = this.parseJsonValue(storeRow.optionValue, []);
      if (Array.isArray(storeList) && !this.isFacilitySettingSelectorPlaceholder(storeList)) {
        model.optionValue = storeRow.optionValue;
      }
      if ((model.dispValue == null || String(model.dispValue).trim() === "") && storeRow.dispValue != null) {
        model.dispValue = storeRow.dispValue;
      }
      if ((model.value == null || model.value === "") && storeRow.value != null && storeRow.value !== "") {
        model.value = storeRow.value;
        model.val = storeRow.val ?? storeRow.value;
      }
    },
    resolveFacilitySettingEditorOptionList(model) {
      if (!model) {
        return [];
      }
      const inputType = Number(model.inputType);
      if (inputType === 9 && Array.isArray(this.kendoGridDrop?.doctorList)) {
        return this.kendoGridDrop.doctorList;
      }
      if (inputType === 8 && Array.isArray(this.kendoGridDrop?.reportList)) {
        return this.kendoGridDrop.reportList;
      }
      let rawOptionValue = model.optionValue;
      if (typeof model.get === "function") {
        const fromModel = model.get("optionValue");
        if (fromModel !== undefined && fromModel !== null) {
          rawOptionValue = fromModel;
        }
      }
      let list = this.parseJsonValue(rawOptionValue, []);
      if (!Array.isArray(list)) {
        list = [];
      }
      if (this.isFacilitySettingSelectorPlaceholder(list)) {
        const storeRow = (this.getMasterRecordList?.data || []).find((row) => {
          if (model.facilitySettingNo != null && row?.facilitySettingNo != null) {
            return String(row.facilitySettingNo) === String(model.facilitySettingNo);
          }
          return model.dispOrder != null && String(row.dispOrder) === String(model.dispOrder);
        });
        list = storeRow ? this.parseJsonValue(storeRow.optionValue, []) : [];
        if (!Array.isArray(list)) {
          list = [];
        }
      }
      if (
        list.length === 0
        && String(model.facilitySettingNo) === SHR_PAT_INFO
        && Array.isArray(this.shrFacilityList)
      ) {
        list = this.shrFacilityList.map((shrItem) => ({
          id: shrItem.facilityCd,
          name: shrItem.facilityName
        }));
      }
      return list;
    },
    normalizeMultiSelectValues(value) {
      const parsed = Array.isArray(value) ? value : this.parseJsonValue(value, []);
      if (!Array.isArray(parsed)) {
        return [];
      }
      return parsed
        .filter((item) => item !== undefined && item !== null && item !== "")
        .map((item) => String(item));
    },
    findOptionValueById(optionValue = [], candidate) {
      return (optionValue || []).find((item) => String(item?.id) === String(candidate));
    },
    findOptionValueByName(optionValue = [], candidate) {
      if (candidate === undefined || candidate === null) {
        return undefined;
      }
      // inputType5 の未選択表示は name:" " のため trim しない（trim すると空白行に一致できずドロップダウンが未選択見た目になる）
      return (optionValue || []).find((item) => String(item?.name) === String(candidate));
    },
    buildMultiSelectDisplayValue(optionValue = [], values = [], columnData) {
      const selectedItems = [];
      const normalizedValues = this.normalizeMultiSelectValues(values);
      normalizedValues.forEach((value) => {
        const optionItem = this.findOptionValueById(optionValue, value);
        if (optionItem) {
          selectedItems.push(optionItem);
        }
      });
      let dispText = "";
      selectedItems.forEach((item) => {
        dispText = this.buildTextMultiSelect(dispText, item.name, columnData);
      });
      return dispText;
    },
    getFacilitySettingMultiSelectRowHeightOptions() {
      return {
        gridRoot: this.getDirectGridRootEl?.(),
        wrapperClassName: "mst-facility-setting-edit-multiselect",
        minHeight: "2em",
        afterSync: () => this.scheduleDirectGridLockedScrollContract?.()
      };
    },
    scheduleFacilitySettingMultiSelectEditorHeight(widget) {
      scheduleGridEditorMultiSelectRowHeight(
        widget,
        this.getFacilitySettingMultiSelectRowHeightOptions()
      );
    },
    clearFacilitySettingMultiSelectEditorHeight(event = null) {
      scheduleClearGridEditorMultiSelectRowHeight(
        event?.container?.get?.(0) || event?.container?.[0] || event?.container || this.getDirectGridRootEl?.(),
        {
          gridRoot: this.getDirectGridRootEl?.(),
          uid: event?.model?.uid,
          afterClear: () => this.scheduleDirectGridLockedScrollContract?.()
        }
      );
    },
    applyFacilitySettingMultiSelectValue(widget, values) {
      if (!widget) {
        return;
      }
      setKendoWidgetValue(widget, values);
      widget.refresh?.();
      this.scheduleFacilitySettingMultiSelectEditorHeight(widget);
    },
    /**
     * NumericTextBox 上でのホイール: 既定の数値変更を止め、縦スクロールだけ Grid に反映する
     */
    applyFacilitySettingGridScrollFromWheel(wheelEvent, fromElement = null) {
      if (!wheelEvent || typeof wheelEvent.deltaY !== "number") return;
      let dy = wheelEvent.deltaY;
      if (wheelEvent.deltaMode === 1) dy *= 16;
      else if (wheelEvent.deltaMode === 2) {
        dy *= wheelEvent.target?.ownerDocument?.defaultView?.innerHeight ?? 640;
      }
      const content = fromElement?.closest?.(".k-grid")?.querySelector?.(".k-grid-content") || this.getDirectGridContentEl();
      if (!(content instanceof HTMLElement)) return;
      const maxTop = Math.max(0, (content.scrollHeight || 0) - (content.clientHeight || 0));
      const nextTop = Math.min(maxTop, Math.max(0, (content.scrollTop || 0) + dy));
      this.setGridScrollPosition({ top: nextTop, left: content.scrollLeft || 0 });
    },
    /**
     * @description 編集時、テキストボックスをDB指定の入力フィールドへ変換
     * @summary inputType 1.テキストボックス 2.数値用テキストボックス 3.ドロップダウンリスト(ON/OFF選択用) 4.ドロップダウンリスト(DB設定項目の選択)
     * @param container grid生成情報
     * @param data DB取得値
     */
    editorInput(container, data) {
      // add redmine 4675 医療材料表示順、投与薬剤表示順の不正 孔 start
      if (data.model.inputType == 7) {
        const rawValues = data.model.val ? data.model.val : data.model.value;
        const vm = this;
        const optionValue = this.resolveFacilitySettingEditorOptionList(data.model);
        const values = this.normalizeMultiSelectValues(rawValues);
        data.model.val = JSON.stringify(values);
        data.model.value = JSON.stringify(values);
        // Vue2 互換: 編集開始中の dispValue は表示文字列ではなく選択配列を保持
        data.model.dispValue = [...values];
        const $multiSelect = $(`<select name="${data.field || "dispValue"}" multiple="multiple"></select>`)
          .appendTo(container)
          .kendoMultiSelect({
            autoClose: false,
            dataSource: optionValue,
            dataTextField: "name",
            dataValueField: "id",
            filter: "contains",
            value: values,
            headerTemplate: `
              <div style="padding: 8px 10px; border-bottom: 1px solid rgb(204, 204, 204);">
                <span id="custom-search-container" class="custom-search-container k-textbox k-space-right"
                      style="width: 100%; display: flex; align-items: center; transition: all 0.2s ease; border: 1px solid rgb(204, 204, 204); border-radius: 2px; box-sizing: border-box; background: white;">
                  <input
                    class="custom-header-search"
                    style="width: 100%; border: none; outline: none; background: transparent; padding: 4px 0;"
                    onmousedown="window.preventKendoClose = true;"
                    onblur="window.preventKendoClose = false;"
                  />
                  <span class="k-icon k-i-zoom ntss-grid-editor-multiselect-header-search-icon" style="margin-left: 4px; margin-right: 8px; color: rgb(102, 102, 102); width: 16px; height: 16px; flex: 0 0 16px; display: inline-flex; align-items: center; justify-content: center;"></span>
                </span>
              </div>
            `,
            open: function(e) {
              const widget = e.sender;
              const popup = widget.popup.element;
              ensureGridEditorMultiSelectHeaderSearchIcon(widget);
              const headerInput = popup.find(".custom-header-search");
              const searchContainer = popup.find(".custom-search-container, #custom-search-container");

              searchContainer.css({
                border: "1px solid #ccc",
                borderRadius: "2px",
                boxSizing: "border-box",
                background: "#fff"
              });
              headerInput.off(".ntssFacilitySettingMultiSelect");
              headerInput.on("mousedown.ntssFacilitySettingMultiSelect click.ntssFacilitySettingMultiSelect", function(ev) {
                ev.stopPropagation();
                $(this).focus();
              });

              headerInput.on("focus.ntssFacilitySettingMultiSelect", function() {
                searchContainer.css("border", "2px solid green");
              }).on("blur.ntssFacilitySettingMultiSelect", function() {
                searchContainer.css("border", "1px solid #ccc");
              });

              headerInput.on("input.ntssFacilitySettingMultiSelect", function() {
                const value = $(this).val();
                widget.dataSource.filter({
                  field: "name",
                  operator: "contains",
                  value: value
                });
              });
              vm.scheduleFacilitySettingMultiSelectEditorHeight(widget);
            },

            change: function(e) {
              const widget = e.sender;
              let currentValues = vm.normalizeMultiSelectValues(getKendoWidgetValue(e.sender));
              if (data.model.facilitySettingNo == TREATMENT_PROGRESS_CHART
                || data.model.facilitySettingNo == TREATMENT_PROGRESS_CHART_HANDWRITING
                || data.model.facilitySettingNo == DAILY_INSPECTION_RECORD_BOOK
                || data.model.facilitySettingNo == PERIODIC_INSPECTION_RECORD_BOOK) {
                if (currentValues.length > 3) {
                  currentValues = currentValues.slice(0, 3);
                  setKendoWidgetValue(e.sender, currentValues);
                }
              }
              data.model["val"] = JSON.stringify(currentValues);
              data.model["value"] = JSON.stringify(currentValues);
              vm.syncFacilitySettingMultiSelectDisplayModel(data.model);
              const headerInput = widget.popup.element.find(".custom-header-search");
              headerInput.val("");
              widget.dataSource.filter({});
              e.sender.input.val("");
              e.sender.search("");
              vm.scheduleFacilitySettingMultiSelectEditorHeight(e.sender);
            },
            close: function(e) {
              const ownerDocument = e.sender?.element?.[0]?.ownerDocument || document;
              const ownerWindow = ownerDocument.defaultView || window;
              if (ownerWindow.preventKendoClose || $(ownerDocument.activeElement).hasClass("custom-header-search")) {
                e.preventDefault();
                return false;
              }
            }
          });
        const multiSelectWidget = $multiSelect.data("kendoMultiSelect");
        this.applyFacilitySettingMultiSelectValue(
          multiSelectWidget,
          values
        );
        $multiSelect.blur(() => {
          const currentValues = vm.normalizeMultiSelectValues(data.model["val"] || data.model["value"]);
          data.model["val"] = JSON.stringify(currentValues);
          data.model["value"] = JSON.stringify(currentValues);
          vm.syncFacilitySettingMultiSelectDisplayModel(data.model);
          vm.applyFacilitySettingMultiSelectValue(
            multiSelectWidget,
            currentValues
          );
        });
      // add redmine 4675 医療材料表示順、投与薬剤表示順の不正 孔 end
      } else if (data.model.facilitySettingNo == "1012" || data.model.facilitySettingNo == "1014") {
        const inputId = String(data.field || "dispValue");
        $(`<span style="position:relative"><input type="time" id="${inputId}" name="${data.field}" class="time-wrapper" style="width: 7em;" data-bind="value:dispValue" ></span>`)
          .appendTo(container);
        const idtag = getScopedElementById(inputId, container?.[0] || container || this.$el || this);
        this.listener = (event) => {
          if (event.key === "Delete" || event.key === "Backspace") {
            event.preventDefault();
          }
        };
        idtag?.addEventListener?.("keydown", this.listener);
      // mod 施設設定マスタ 帳票未指定時のデフォルト帳票を指定可能 孔s start
      } else if (data.model.inputType == 4 || data.model.inputType == 5 || data.model.inputType == 9 || data.model.inputType == 8) {
      // mod 施設設定マスタ 帳票未指定時のデフォルト帳票を指定可能 孔s end
        const optionValue = this.resolveFacilitySettingEditorOptionList(data.model);
        if (!optionValue.length) {
          $(`<label>${data.model.dispValue ?? ""}</label>`).appendTo(container);
          return;
        }
        const vm = this;
        const model = data.model;
        const findById = (candidate) => vm.findOptionValueById(optionValue, candidate);
        const findByName = (candidate) => vm.findOptionValueByName(optionValue, candidate);
        const applySelection = (widget, selectedId, suppressChange = false) => {
          const selectedItem = findById(selectedId);
          if (!selectedItem) {
            return false;
          }
          if (widget) {
            const applyValue = () => setKendoWidgetValue(widget, String(selectedItem.id));
            if (suppressChange) {
              withProgrammaticKendoUpdate(widget, applyValue);
            } else {
              applyValue();
            }
          }
          model.val = String(selectedItem.id);
          model.value = String(selectedItem.id);
          model.dispValue = selectedItem.name || "";
          return true;
        };
        let initialId = "";
        const matchedByValue = findById(model.value);
        if (matchedByValue) {
          initialId = matchedByValue.id;
        }
        const matchedByVal = findById(model.val);
        if (matchedByVal) {
          initialId = matchedByVal.id;
        }
        if (!initialId && model.dispValue != null) {
          const matchedByDisp = findByName(model.dispValue);
          if (matchedByDisp) {
            initialId = matchedByDisp.id;
          }
        }
        if (!initialId && Number(model.inputType) === 5) {
          const blankOption = findById("-1");
          if (blankOption) {
            initialId = blankOption.id;
          }
        }
        const $dbDropdown = $(`<input class="k-textbox" name="${data.field}" data-bind="value:value"/>`)
          .appendTo(container)
          .kendoDropDownList({
            dataSource: optionValue,
            dataTextField: "name",
            dataValueField: "id",
            autoSelectFirstOnEmpty: false,
            value: initialId === "" || initialId == null ? null : String(initialId),
            change(e) {
              if (applySelection(e.sender, getKendoWidgetValue(e.sender))) {
                vm.closeFacilitySettingGridEditCell();
                vm.scheduleFacilitySettingDropdownEditorCommit(model);
              }
            },
            filter: "contains"
          });
        const dbDropdownWidget = $dbDropdown.data("kendoDropDownList");
        if (initialId !== "" && initialId != null) {
          applySelection(dbDropdownWidget, initialId, true);
          vm.$nextTick(() => applySelection(dbDropdownWidget, initialId, true));
        }
        $dbDropdown.blur(() => {
          const value = model.val || model.value;
          const byId = findById(value);
          if (byId?.name != null) {
            model.dispValue = byId.name;
            return;
          }
          const byName = findByName(model.dispValue);
          if (byName) {
            model.val = String(byName.id);
            model.value = String(byName.id);
            model.dispValue = byName.name;
          }
        });
      } else if (data.model.inputType == 3) {
        const onOffDataSource = [{ id: "0", name: "OFF" }, { id: "1", name: "ON" }];
        const findOnOffById = (candidate) => onOffDataSource.find((item) => String(item.id) === String(candidate));
        const findOnOffByName = (candidate) => onOffDataSource.find((item) => String(item.name) === String(candidate));
        let onOffDisplayValue = "";
        const onOffFromDispValue = findOnOffByName(data.model.dispValue);
        if (onOffFromDispValue) {
          onOffDisplayValue = onOffFromDispValue.name;
        }
        if (!onOffDisplayValue) {
          const onOffFromValue = findOnOffById(data.model.value);
          if (onOffFromValue) {
            onOffDisplayValue = onOffFromValue.name;
          }
        }
        if (!onOffDisplayValue) {
          const onOffFromVal = findOnOffById(data.model.val);
          if (onOffFromVal) {
            onOffDisplayValue = onOffFromVal.name;
          }
        }
        const vm = this;
        const applyOnOffSelection = (sender) => {
          const selectedName = getKendoWidgetValue(sender);
          const selectedItem = findOnOffByName(selectedName);
          if (!selectedItem) {
            return false;
          }
          data.model.dispValue = selectedItem.name;
          data.model.value = selectedItem.id;
          data.model.val = selectedItem.id;
          return true;
        };
        $(`<input class="k-textbox" name="${data.field}" data-bind="value:dispValue"/>`)
          .appendTo(container)
          .kendoDropDownList({
            dataSource: onOffDataSource,
            dataTextField: "name",
            dataValueField: "name",
            value: onOffDisplayValue,
            change(e) {
              if (applyOnOffSelection(e.sender)) {
                vm.closeFacilitySettingGridEditCell();
                vm.scheduleFacilitySettingDropdownEditorCommit(data.model);
              }
            }
          })
          .blur(() => {
            if (data.model.dispValue) {
              const selectedItem = findOnOffByName(data.model.dispValue);
              if (selectedItem) {
                data.model.dispValue = selectedItem.name;
                data.model.value = selectedItem.id;
                data.model.val = selectedItem.id;
              }
            } else if (data.model.value != null && data.model.value !== "") {
              const selectedItem = findOnOffById(data.model.value);
              if (selectedItem) {
                data.model.dispValue = selectedItem.name;
                data.model.value = selectedItem.id;
                data.model.val = selectedItem.id;
              }
            }
          });
      } else if (data.model.inputType == 2) {
        const numberScope = this.parseJsonValue(data.model.optionValue, null);
        const rawMin = numberScope && numberScope[0] ? numberScope[0].min : null;
        const rawMax = numberScope && numberScope[0] ? numberScope[0].max : null;
        const rawInitialValue = data.model.dispValue ?? data.model.value;
        const normalizedInitialValue = rawInitialValue == null
          ? null
          : Number(String(rawInitialValue).replace(/日$/, ""));
        const initialValue = Number.isFinite(normalizedInitialValue) ? normalizedInitialValue : null;
        const numericTextBoxOptions = {
          name: data.field,
          min: rawMin === null || rawMin === undefined || rawMin === "" ? null : Number(rawMin),
          max: rawMax === null || rawMax === undefined || rawMax === "" ? null : Number(rawMax),
          decimals: 0,
          format: "n0",
          value: initialValue,
          restrictDecimals: true,
          change: function(e) {
            const currentValue = getKendoWidgetValue(e.sender);
            data.model.dispValue = currentValue == null ? "" : String(currentValue);
            if (data.model.facilitySettingNo == "3008") {
              data.model.dispValue = data.model.dispValue === "-1" || data.model.dispValue == null ? "-1" : data.model.dispValue + "日";
            }
          }
        };
        $(`<input class="k-numerictextbox" name="${data.field}"/>`)
          .appendTo(container)
          .kendoNumericTextBox(numericTextBoxOptions);
        const numericTextBox = $(container).find(".k-numerictextbox").data("kendoNumericTextBox");
        const numericWrapEl = numericTextBox?.wrapper?.get?.(0) || numericTextBox?.wrapper?.[0];
        // ホイールで数値が変わらないよう既定動作を抑止し、縦スクロールは Grid 本体へ移す
        const suppressNumericWheelSpin = (e) => {
          e.preventDefault();
          e.stopPropagation();
          this.applyFacilitySettingGridScrollFromWheel(e, numericWrapEl);
        };
        if (numericWrapEl instanceof HTMLElement) {
          numericWrapEl.addEventListener("wheel", suppressNumericWheelSpin, { passive: false, capture: true });
        }
        numericTextBox.element.on("blur", () => {
          if(numericTextBox){
            numericTextBox.trigger('change')
          }
        })
      } else if (data.model.inputType == 1) {
        let textScope;
        textScope = data.model.optionValue !== "" ? this.parseJsonValue(data.model.optionValue, [{ maxlength: "128" }])[0].maxlength : "128";
        $(`<input type="text" class="k-input k-textbox k-valid" name="${data.field}" maxlength="${textScope}" data-bind="value:dispValue"/>`)
          .appendTo(container);
      } else if (data.model.inputType == 6) {
        $('<textarea data-text-field="Label" class="k-textbox k-valid" data-value-field="Value" data-bind="value:dispValue" style="width: ' + (container.width() - 10) + 'px;height:' + (container.height() - 12) + 'px;margin-top:10px;margin-bottom:10px;resize:vertical;max-height:65vh;" />').appendTo(container);
      } else {
        this.editingFlg = false;
        $(`<label>${data.model.value}</label>`).appendTo(container);
      }
    },
    cancel() {
      // 前画面に戻る
      // 編集破棄確認はMasterRecordView.vueで行う
      this.$router.go(-1);
    },
    /**
     * 入力分類「7: マルチセレクト」表示用のテキスト生成 
     */
    buildTextMultiSelect(text = "", addText = "", columnData) {
      const concatString = [SHR_PAT_INFO, STATUS_MAP_TREATMENT_INDICATOR, STATUS_MAP_SCHEDULE_INDICATOR].includes(columnData.facilitySettingNo) ? " " : " > ";
      const sym = text.length > 0 ? concatString : "";
      return text + sym + " [ " + addText + " ] ";
    }
  },
  created() {
    this.setLoadingScreenVisible(true);
    this.setUserType(this.getStateUserAccountInfo.userType);
    // mod マスタ一覧 1･施設切替を可能とする 孔s start
    // this.findFacilityList();`
    this.facilitylistValue = this.getFacilitySwitch
    this.findList()
    // mod マスタ一覧 1･施設切替を可能とする 孔s end
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
    this.selfScreenName = this.$route.name;
    EventBus.$on("refresh", this.refresh);
    this.runWhenMasterLayoutReady(() => {
      this.footerHeight = this.getMasterGridFooterHeight(0);
    }, {
      name: 'mst-facility-setting:created-footer-height',
      requireGridFooter: true,
      retries: 8,
      delay: 16
    });
  },
  mounted() {
    installComponentJQuery();
    EventBus.$emit("calculateMainHeight");
    this.directGridMounted = true;
    this.$nextTick(() => {
      this.calculateGridHeight();
      this.initDirectGridIfReady();
    });
    this.directGridResizeHandler = () => {
      this.calculateGridHeight();
      this.scheduleDirectGridLayoutContract();
    };
    window.addEventListener("resize", this.directGridResizeHandler);
    EventBus.$on("clearScrollPosition", this.clearScrollPosition);
  },
  beforeUnmount() {
    EventBus.$off("refresh", this.refresh);
    EventBus.$off("clearScrollPosition", this.clearScrollPosition);
    if (this.directGridResizeHandler) {
      window.removeEventListener("resize", this.directGridResizeHandler);
      this.directGridResizeHandler = null;
    }
    this.destroyDirectGrid();
  }
};
</script>

<!-- 個別スタイル定義 -->
<style scoped>
.ntss-list{
  display: flex;
  flex-direction: column;
  height: 100%;
}
.right {
  text-align: right;
}
.header-btn-area {
  height: auto;
  padding: 0.1em 0.1em 0.1em 0.1em;
}
.mobile-edit-toolbar {
  display: inline-flex;
  align-items: center;
  float: left;
  gap: 0.5em;
  height: 2em;
  padding: 0 0.3em;
  line-height: 1;
}
.mobile-edit-toolbar .fab-font-color {
  margin: 0;
  white-space: nowrap;
  flex-shrink: 0;
}
.mobile-edit-toolbar :deep(ons-switch) {
  display: inline-flex;
  align-items: center;
  flex-shrink: 0;
  vertical-align: middle;
}
.mobile-edit-toolbar :deep(.switch) {
  --switch-width: 44px;
  --switch-height: 26px;
  width: 44px !important;
  min-width: 44px !important;
  max-width: 44px !important;
  height: 26px !important;
  min-height: 26px !important;
  padding: 0 !important;
  margin: 0;
  vertical-align: middle;
}
.mobile-edit-toolbar :deep(.switch__toggle) {
  border-radius: 13px;
  box-shadow: inset 0 0 0 1.5px var(--switch-border-color);
}
.mobile-edit-toolbar :deep(:checked + .switch__toggle) {
  box-shadow: inset 0 0 0 1.5px var(--switch-checked-background-color);
}
.mobile-edit-toolbar :deep(.switch__handle) {
  width: 22px !important;
  height: 22px !important;
  top: 2px !important;
  left: 2px !important;
  right: auto !important;
  border-radius: 50%;
  box-shadow: 0 1px 2px rgba(0, 0, 0, 0.22);
}
.mobile-edit-toolbar :deep(:checked + .switch__toggle > .switch__handle) {
  left: auto !important;
  right: 2px !important;
  box-shadow: 0 1px 2px rgba(0, 0, 0, 0.22);
}
#grid-footer {
  margin: 0;
  padding: 5px 5px 5px 5px;
  /* bottom: 0;
  position: absolute; */
  width: inherit;
}
.kendo-grid-toolbar-style {
  height: calc(100% - 40px);
  border-bottom: none;
}
.k-grid-toolbar {
  padding: 0 0.3em;
}
:deep(.k-selectable tbody tr td),
:deep(.k-grid .k-table-td),
:deep(.k-grid .k-grid-content td),
:deep(.k-grid .k-grid-content-locked td) {
  overflow: visible !important;
  white-space: normal !important;
  vertical-align: top;
}
/* 設定値列: k-dirty が hidden の value 列につくため master-edited-cell を JS で付与。念のため表示セルも明示 */
:deep(.mst-facility-setting-direct-jq-grid .k-grid-content tbody td.master-edited-cell) {
  color: #003300 !important;
  font-weight: bold !important;
}

:deep(.k-grid .k-grid-edit-row td),
:deep(.k-grid .k-grid-edit-row .k-edit-cell) {
  overflow: visible !important;
  white-space: normal !important;
  vertical-align: top;
}
/* 設定値セル編集時: DropDownList の選択文言が長い場合に折り返す（Kendo は既定で nowrap のため） */
:deep(.k-grid .k-grid-edit-row .k-edit-cell .k-dropdownlist.k-picker),
:deep(.k-grid .k-grid-edit-row .k-edit-cell .k-legacy-dropdownlist.k-dropdownlist.k-picker) {
  display: grid !important;
  grid-template-columns: minmax(0, 1fr) auto;
  align-items: start;
  column-gap: 0.55em;
  row-gap: 0;
  width: 100%;
  max-width: 100%;
  height: auto;
  min-height: 2em;
  white-space: normal;
  box-sizing: border-box;
}
:deep(.k-grid .k-grid-edit-row .k-edit-cell .k-dropdownlist.k-picker .k-input-inner.k-dropdown-wrap),
:deep(.k-grid .k-grid-edit-row .k-edit-cell .k-legacy-dropdownlist.k-dropdownlist.k-picker .k-input-inner.k-dropdown-wrap),
:deep(.k-grid .k-grid-edit-row .k-edit-cell .k-legacy-dropdownlist.k-dropdownlist.k-picker .k-dropdown-wrap) {
  grid-column: 1;
  grid-row: 1;
  display: flex;
  flex-direction: column;
  align-items: stretch;
  height: auto;
  min-height: inherit;
  white-space: normal;
  min-width: 0;
  width: auto;
  max-width: none;
  padding-inline-end: 0;
  margin-right: 0;
  box-sizing: border-box;
}
/* 折り返しでも三角ボタンと重ならないよう領域を確保（テーマ側の absolute レイアウトも打ち消し） */
:deep(.k-grid .k-grid-edit-row .k-edit-cell .k-dropdownlist.k-picker .k-select.k-input-button),
:deep(.k-grid .k-grid-edit-row .k-edit-cell .k-dropdownlist.k-picker button.k-select),
:deep(.k-grid .k-grid-edit-row .k-edit-cell .k-legacy-dropdownlist.k-dropdownlist.k-picker .k-select.k-input-button),
:deep(.k-grid .k-grid-edit-row .k-edit-cell .k-legacy-dropdownlist.k-dropdownlist.k-picker button.k-select) {
  grid-column: 2;
  grid-row: 1;
  justify-self: end;
  flex: 0 0 auto;
  flex-shrink: 0;
  align-self: start;
  margin-top: 2px;
  margin-left: 0;
  margin-inline-start: 0;
  position: relative !important;
  inset: unset !important;
  width: auto;
  min-width: 2.25rem;
  z-index: 1;
}
:deep(.k-grid .k-grid-edit-row .k-edit-cell .k-dropdownlist.k-picker .k-input-value-text),
:deep(.k-grid .k-grid-edit-row .k-edit-cell .k-legacy-dropdownlist.k-dropdownlist.k-picker .k-input-value-text) {
  white-space: normal !important;
  word-break: break-word;
  overflow-wrap: break-word;
  text-overflow: clip;
  overflow: hidden;
  max-width: 100%;
  padding-right: 0.125em;
  box-sizing: border-box;
}
.mobile-edit-toolbar .custom-switch {
  touch-action: manipulation;
  -webkit-tap-highlight-color: transparent;
}
.no-scroll {
  overflow-x: hidden;
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
