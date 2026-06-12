/**
 * 患者イベントサブカテゴリマスタ  mst_pat_event_sub_category
 */
<template>
  <div class="main-content-area master-maintenance-page">
    <div class="ntss-list" ref="ntssList" :style="ntssListStyles">
      <div class="k-grid-toolbar k-header kendo-grid-toolbar-style" :style="heightStyles">
        <div id="grid-header" :class="['header-btn-area', 'right', isMobileDevice ? 'mobile-header' : '']">
          <v-ons-button
            modifier="outline"
            class="btn3-normal toolbar-btn"
            style="float: left;"
            v-show="!isSortMode && isAllowAddRecord"
            @click="addRow()"
          >追加</v-ons-button>
          <!-- del マスタ一覧 1･施設切替を可能とする 王 start -->
          <!--          <kendo-dropdownlist-->
          <!--            ref="dropDownList"-->
          <!--            v-if="isMasterUser"-->
          <!--            v-model="facilitylistValue"-->
          <!--            :data-source="facilities"-->
          <!--            :data-text-field="'facilityName'"-->
          <!--            :data-value-field="'facilityCd'"-->
          <!--            :filter="'contains'"-->
          <!--            @open="onOpenFacility"-->
          <!--            @change="onChangeFacility"-->
          <!--            style="width: 13em;"-->
          <!--          ></kendo-dropdownlist>-->
          <!-- del マスタ一覧 1･施設切替を可能とする 王 end -->
          <v-ons-row v-show="isMobileDevice" style="float: left; width: 7em; height: 1em;">
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
            v-show="!isSortMode && isAllowAddRecord && !iosFlg && !androidFlg"
            @click="importCsv($event)"
          >CSV取込</v-ons-button>
          <v-ons-button
            modifier="outline"
            class="btn3-normal toolbar-btn"
            v-show="!isSortMode && isAllowSort"
            @click="toRankEditBtnClick()"
          >並び順表示</v-ons-button>
          <v-ons-button
            modifier="outline"
            class="btn3-normal toolbar-btn"
            v-show="isSortMode && isAllowSort"
            @click="sortBtnClick()"
          >反映</v-ons-button>
        </div>
        <div
          v-show="columns.length > 1"
          id="grid-font-size"
          ref="gridRoot"
          :class="[fontSizeSet, 'ntss-kendo-grid-legacy', 'mst-pat-event-sub-category-direct-jq-grid']"
        ></div>
      </div>
      <div id="grid-footer">
        <v-ons-row width="100%" :style="{ visibility: this.isSortMode ? 'hidden' : 'visible' }">
          <v-ons-col width="50%">
            <v-ons-button type="button" class="btn2-cancel button denial-btn" style="width: auto;" @click="cancel">キャンセル</v-ons-button>
          </v-ons-col>
          <v-ons-col width="50%" class="right">
            <v-ons-button
              type="button"
              class="btn1-execute button registration-btn"
              style="width: auto;"
              :disabled="!isChanged || saveRecordInProgress"
              @click="saveRecord"
            >保存</v-ons-button>
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
import { mapActions, mapGetters } from "@/compat/vue/vuex";
import { EventBus } from "@/compat/vue/event-bus.js";

import MasterCsvComponent from "@/components/master-maintenance/MasterCsvComponent";
import commonCalender from "@/components/common/custom-calendar/CustomCalendar";
import { createApp, markRaw } from "@/compat/vue/runtime";
import { ADVANCED_SETTINGS } from "@/constants/advancedSettings";
import { ApiHelper } from "@/apis/AxiosHelper.js";
//FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
import { messageFormat } from "@/functions/common/MessageFormat";
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
import dayjs from "@/compat/date/dayjs";
import {
  bindGridEditorEnterToCloseCell,
  bindGridEditorDropDownListToCloseCell,
  getGridEditorDropDownListWidget,
  resolveGridEditorDropDownListSaveValue,
} from "@/compat/kendo/grid-edit";
import {
  createJQueryValidator,
  destroyJQueryValidator,
} from "@/compat/kendo/kendo-jquery.js";
import { appendValidationCallout } from "@/compat/kendo/validator.js";
import kendo from "@progress/kendo-ui";
import $ from "jquery";

// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
/**
 * TODO
 * more: モーダルで編集した項目が、一覧上で「編集済み（三角マーク）」をつけたい。
 */
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
          locked: false,
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
      kendoGridToolbarHeight: 500,
      kendoGridHeight: 300,
      columnWidth: 14,
      kendoValidatorSetup: {
        rules: {},
        messages: {},
      },
      mstSynchroApiParams: {
        mstTable: "mst_m_notice",
        deviceEdgeNo: -1,
      },
      //Android端末で編集中であることを示すフラグ
      editingFlg: false,
      androidFlg: false,
      iosFlg: false,
      scrollPosition: {
        top: 0,
        left: 0,
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
      reportlist:[],
      userType: "",
      lastScrollTop: 0,
      lastScrollLeft: 0,
      preserveGridScrollAfterSave: false,
      allowEdit: true, // NOTE: true = 編集モード、 false = 閲覧モード
      directGridWidget: null,
      directGridMounted: false,
      directGridDataSource: null,
      directGridLayoutRafId: null,
      directGridScrollSyncRafId: null,
      directGridFilterRefreshRafId: null,
      directGridAppliedHeight: null,
      directGridRowVisualRafIds: markRaw(new Map()),  
      directGridSortEditedCodes: markRaw(new Set()),
      directGridEditedFieldsByCode: markRaw(new Map()),
      kendoValidator: null,
      validationTooltipPlacementIntervalId: null,
      validationTooltipPlacementTimers: [],
      validationTooltipPlacementRafId: null,
      validationTooltipObserver: null,
      saveRecordInProgress: false,
      isInitialLoadComplete: false,
      suppressUseTypeSaveReentry: false,
      syncingTemplateCdCellDisplay: false,
    };
  },
  computed: {
    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight",
      windowWidth: "getWindowWidth",
    }),
    ...mapGetters("account-edit", {
      isDispMenu: "isDispMenu",
      getFontSize: "getFontSize",
      getStateUserAccountInfo: "getStateUserAccountInfo",
    }),
    ...mapGetters("user", ["getAdvancedSettings"]),
    ...mapGetters("user", { facilityCd: "getFacilityCd" }),
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
      return `${condition.recordName || ""}|${condition.includeDeleted ? 1 : 0}`;
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
      getFacilityList: "getFacilityList",
      getFacilitySwitch: "getFacilitySwitch"
    }),
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
    masterRecords() {
      this.normalizePatEventSubCategoryStoreData();
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
      if (!this.isInitialLoadComplete) {
        return false;
      }
      const data = this.getMasterRecordList.data;
      return (
        this.getStateUserAccountInfo !== null &&
        data !== undefined &&
        (data.filter(row => row.operation > 0 || row.edited || row.dirty).length ||
          this.isRecordModified ||
          this.isSorted ||
          (this.kendoValidator && !this.kendoValidator.validate()))
      );
    },
    isMobileDevice() {
      return this.iosFlg || this.androidFlg;
    },
  },
  watch: {
    windowHeight() {
      this.scheduleDirectGridLayoutContract();
    },
    windowWidth() {
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
      "getDeviceEdgeNoList",
      "mstSyncDeviceEdge",
      "findRecordListByFacilityCd",
    ]),
    ...mapActions("master-maintenance", {
      facilityList: "facilityList",
    }),
    DisableDetailBtn() {
      if (this.getGridTableEl()?.tBodies != null && this.getGridDataSource().data) {
        const tbodyc = (this.getGridTbodyEl()?.children || []);
        const gridData = this.getGridDataSource().data;
        gridData.forEach((dataRow, index) => {
          // ログインユーザの行を無効化
          if (dataRow.useType != "3" && tbodyc[index]?.children?.[5]?.children?.[0]) {
            // ログインユーザの管理者／ID/PWリセット/ロック解除/削除機能を無効化
            tbodyc[index].children[5].children[0].style.display = "none"
          }
        });
      }
    },
    checkUseType(e) {
      if (e.useType == "") {
        return false;
      }
      return true;
    },
	//テンプレート データ設定
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
      if (e.model.useType == '3'){
        e.sender.columns[7].values = this.columns[7].values.filter(element => element.isReport);
      }else if (e.model.useType == '') {
        e.sender.columns[7].values = [];
      }else{
        e.sender.columns[7].values = this.columns[7].values.filter(element => !element.isReport);
      }
      this.editStart(e);
    },
    // fix 2026/06/03 種別変更時にテンプレート表示のみ同期（save 再入防止） 名前 start
    syncTemplateCdCellDisplayOnly(event) {
      const model = event?.model;
      if (!model || this.syncingTemplateCdCellDisplay) {
        return;
      }
      this.syncingTemplateCdCellDisplay = true;
      try {
        const record = this.getDirectGridModelPlain(model);
        const rows = this.getDirectGridRowsByRecord(record, model?.uid);
        rows.forEach(row => {
          const cell = this.findDirectGridCellForField(row, "templateCd");
          if (!cell || cell.classList.contains("k-edit-cell")) {
            return;
          }
          cell.textContent = "";
        });
        this.unmarkDirectGridEditedField(record, "templateCd");
      } finally {
        this.syncingTemplateCdCellDisplay = false;
      }
    },
    // fix 2026/06/03 種別変更時にテンプレート表示のみ同期（save 再入防止） 名前 end
    useTypeSave(e) {
      if (this.suppressUseTypeSaveReentry) {
        return;
      }
      const values = { ...(e.values || {}) };
      const field = Object.keys(values || {})[0];
      if (!field) {
        return;
      }
      const useTypeChanged =
        Object.prototype.hasOwnProperty.call(values, "useType")
        && values.useType != e.model.useType;
      if (useTypeChanged) {
        values.templateCd = "";
      }
      const oldValue = e.model[field];
      const newValue = values[field];
      if (oldValue != newValue) {
        this.suppressUseTypeSaveReentry = true;
        try {
          this.onSave({ ...e, values });
        } finally {
          this.suppressUseTypeSaveReentry = false;
        }
        if (useTypeChanged) {
          this.syncTemplateCdCellDisplayOnly(e);
        }
      }
    },
    showMasterEditModalTransit(e) {
      const row = this.getGridWidget();
      const selectedRowItem = row?.dataItem?.(e.currentTarget.closest("tr"));
      if (selectedRowItem?.useType == "3") {
        this.showMasterEditModal(e);
      }
    },
    // グリッドのデータ再表示
    gridDataRefresh() {
      this.setGridDataSource(this.masterRecords);
    },
    // 施設一覧のデータを取得
    findFacilityList() {
      // 日機装ユーザ以外の場合
      if (this.getStateUserAccountInfo.userType !== 1) {
        // ログイン者の担当施設を選択（初期値は自分の所属する施設）
        // add マスタ一覧 1･施設切替を可能とする 王 start
        // this.facilitylistValue = this.getStateUserAccountInfo.facilityCd;
        this.facilitylistValue = this.getFacilitySwitch;
        // add マスタ一覧 1･施設切替を可能とする 王 end
        // 選択した施設を元にベッド一覧の取得
        this.findList();
        return;
      }
      // apiをコールして施設一覧を取得
      this.facilityList()
        .then(() => {
          // ログイン者の担当施設を選択
          // add マスタ一覧 1･施設切替を可能とする 王 start
          // this.facilitylistValue = this.getStateUserAccountInfo.facilityCd;
          this.facilitylistValue = this.getFacilitySwitch;
          // add マスタ一覧 1･施設切替を可能とする 王 end
          // 選択した施設を元にベッド一覧の取得
          this.findList();
        })
        .catch((error) => {
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
          getErrorMessage('MstPatEventSubCategoryMainComponent.vue', 'findFacilityList', '指定されたマスタが見つかりません。');
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
    onOpenFacility(e) {
      // 変更前の値を取得
      this.prevFacilityCd = e.sender._old;
    },
    // 施設を選択時の動作
    onChangeFacility(e) {
      if (this.prevFacilityCd != e.sender._old) {
        // 選択施設の拡張設定を取得
        var newFacilityAdvancedSettings = {};
        const selectedItem = e?.sender?.dataItem?.() || e?.sender?.value?.();
        try {
          if (selectedItem?.advancedSettings) {
            newFacilityAdvancedSettings = JSON.parse(selectedItem.advancedSettings);
          }
        } catch(error) {
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
          getErrorMessage('MstPatEventSubCategoryMainComponent.vue', 'onChangeFacility', error);
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
          newFacilityAdvancedSettings = {};
        }

        if (!newFacilityAdvancedSettings.func_advcds) {
          newFacilityAdvancedSettings.func_advcds = [];
        }

        const enableHomeDialysis = newFacilityAdvancedSettings.func_advcds.some(
          (setting) => setting.func_advcd === ADVANCED_SETTINGS.HOME_DIALYSIS
        );

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
                // 選択施設の在宅機能有無を取得
                this.facilityHemoDialysis = enableHomeDialysis;
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
          // 選択施設の在宅機能有無を取得
          this.facilityHemoDialysis = enableHomeDialysis;
          this.findList();
        }
      }
    },
    // 共通ローダー設定
    ...mapActions("loading-screen", {
      setLoadingScreenVisible: "setLoadingScreenVisible",
      setLoadingScreenMessage: "setLoadingScreenMessage",
      resetLoadingScreenVisibleCount: "resetLoadingScreenVisibleCount",
    }),
    ...mapActions("mst-synchro", ["startMstSynchro"]),
    getCurrentRouteName() {
      return this.$router?.currentRoute?.value?.name || this.$router?.currentRoute?.name || this.$route?.name || "";
    },
    cancel() {
      this.$router?.back?.();
    },
    normalizePatEventSubCategoryStoreData() {
      const data = this.getFilteredMasterRecordList?.data;
      if (!data) {
        return;
      }
      //add FNSI-改修内容テンプレートマスタ、カテゴリマスタにデータがない場合、サブカテゴリマスタのテンプレートとカテゴリ項目に表示されたCDを空白に修正必要 任 start
      this.columns.forEach((column) => {
        if (column.field === "categoryCd" && column.values.length === 0) {
          data.forEach((item) => {
            item.categoryCd = null;
          });
        } else if (column.field === "templateCd" && column.values.length === 0) {
          data.forEach((item) => {
            item.templateCd = null;
          });
        }
      });
      //add FNSI-改修内容テンプレートマスタ、カテゴリマスタにデータがない場合、サブカテゴリマスタのテンプレートとカテゴリ項目に表示されたCDを空白に修正必要 任 end
      data.forEach((item) => {
        if (item.useType == "3" && item.templateCd && item.templateCd.toString().indexOf("a") < 0) {
          item.templateCd = "a" + item.templateCd;
        } else if (item.templateCd == null) {
          item.templateCd = "";
        }
      });
    },
    /**
     * DBのYYYYMMDD形式をKendo日付列表示用のDateに変換する（手技マスタと同じ）
     */
    yyyymmddToDate(value) {
      if (value == null || value === "") {
        return value;
      }
      if (value instanceof Date) {
        return value;
      }
      const str = String(value);
      const fromYyyymmdd = dayjs(str, "YYYYMMDD", true);
      if (fromYyyymmdd.isValid()) {
        return fromYyyymmdd.toDate();
      }
      const fromIsoDate = dayjs(str, "YYYY-MM-DD", true);
      if (fromIsoDate.isValid()) {
        return fromIsoDate.toDate();
      }
      const fromIsoDateTime = str.match(/^(\d{4})-(\d{2})-(\d{2})T/);
      if (fromIsoDateTime) {
        return new Date(
          Number(fromIsoDateTime[1]),
          Number(fromIsoDateTime[2]) - 1,
          Number(fromIsoDateTime[3])
        );
      }
      return value;
    },
    convertPatEventSubCategoryDatesForGrid(data) {
      if (!Array.isArray(data)) {
        return;
      }
      ["inHospAStartdate", "inHospBStartdate"].forEach((field) => {
        data.forEach((row) => {
          if (row[field] != null && row[field] !== "") {
            row[field] = this.yyyymmddToDate(row[field]);
          }
        });
      });
    },
    normalizePatEventSubCategoryDateFields(record) {
      if (!record) {
        return;
      }
      ["inHospAStartdate", "inHospBStartdate"].forEach((field) => {
        if (record[field] != null && record[field] !== "") {
          record[field] = this.yyyymmddToDate(record[field]);
        }
      });
    },
    formatPatEventSubCategoryDatesForSave(data = this.getMasterRecordList?.data) {
      if (!Array.isArray(data)) {
        return;
      }
      data.forEach((row) => {
        ["inHospAStartdate", "inHospBStartdate"].forEach((field) => {
          if (row[field] != null && row[field] !== "") {
            row[field] = dayjs(row[field]).format("YYYYMMDD");
          }
        });
      });
    },
    validateDirectKendoGrid() {
      if (this.kendoValidator && typeof this.kendoValidator.validate === "function") {
        return this.kendoValidator.validate();
      }
      return true;
    },
    initKendoValidatorIfReady() {
      const ntssList = this.$refs.ntssList;
      if (!ntssList || this.columns.length <= 1) {
        return;
      }
      installComponentJQuery();
      destroyJQueryValidator(ntssList);
      this.kendoValidator = createJQueryValidator(ntssList, this.kendoValidatorSetup);
    },
    destroyKendoValidator() {
      destroyJQueryValidator(this.$refs.ntssList);
      this.kendoValidator = null;
    },
    validateBeforeGridAction() {
      return this.validateDirectKendoGrid();
    },
    // fix 2026/06/02 バリデーション tooltip 位置調整 MasterRecordComponent 同等 start
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
        // fix 2026/06/03 DropDown フォーカス喪失直後はメッセージ DOM のみ先に出る場合がある 名前 start
        if (
          element.classList.contains("k-invalid-msg")
          && element.closest?.(".k-dropdownlist, .k-dropdown, .k-picker, .k-legacy-dropdownlist")
          && editCell.contains?.(element)
        ) {
          return element;
        }
        // fix 2026/06/03 DropDown フォーカス喪失直後はメッセージ DOM のみ先に出る場合がある 名前 end
      }
      return null;
    },
    getDirectGridEditCellAnchor(editCell) {
      if (!editCell) {
        return null;
      }
      return (
        editCell.querySelector(".k-input.k-textbox, .k-picker, .k-dropdownlist, .k-dropdown, .k-input")
        || editCell.querySelector("input, textarea, select, .k-input-inner, .k-textbox")
        || editCell
      );
    },
    // DropDownList 内に挿入された tooltip をセル直下へ移し、textbox と同じ absolute 配置契約を適用する
    ensureDirectGridValidationTooltipHost(editCell, tooltip) {
      if (!editCell || !tooltip) {
        return tooltip || null;
      }
      if (tooltip.parentElement === editCell) {
        tooltip.setAttribute?.("data-ntss-validation-hoisted", "1");
        return tooltip;
      }
      const widgetHost = tooltip.closest?.(".k-dropdownlist, .k-dropdown, .k-picker, .k-legacy-dropdownlist");
      if (!widgetHost || !editCell.contains?.(widgetHost)) {
        return tooltip;
      }
      const anchor = this.getDirectGridEditCellAnchor(editCell);
      if (anchor?.parentElement === editCell && anchor.nextSibling !== tooltip) {
        editCell.insertBefore(tooltip, anchor.nextSibling);
      } else {
        editCell.appendChild(tooltip);
      }
      tooltip.setAttribute?.("data-ntss-validation-hoisted", "1");
      return tooltip;
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
      let tooltip = this.findVisibleValidationTooltip(editCell);
      if (!tooltip) {
        return;
      }
      tooltip = this.ensureDirectGridValidationTooltipHost(editCell, tooltip) || tooltip;
      root.querySelectorAll(".ntss-validation-above").forEach(element => {
        if (element !== editCell) {
          element.classList.remove("ntss-validation-above");
          this.resetValidationTooltipCalloutDirection(element);
        }
      });
      const anchor = this.getDirectGridEditCellAnchor(editCell);
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
    teardownValidationTooltipPlacement() {
      this.clearValidationTooltipPlacementTimers();
      this.stopValidationTooltipPlacementWatch();
      this.teardownValidationTooltipPlacementObserver();
      this.clearValidationTooltipPlacementState();
    },
    clearValidationTooltipPlacementState() {
      this.getDirectGridSearchRoot()?.querySelectorAll?.(".ntss-validation-above")?.forEach?.(element => {
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
    // fix 2026/06/02 バリデーション tooltip 位置調整 MasterRecordComponent 同等 end
    getColumnIndex(fieldName) {
      return this.columns.findIndex(e => e.field === fieldName);
    },
    getMaxSortRank() {
      const data = this.getFilteredMasterRecordList?.data || [];
      return data.length > 0 ? data.reduce((a, b) => Math.max(a, +b.sortRank || 0), 0) : 0;
    },
    calculateColumnsWidth() {
      const widthMap = [12, 14, 16, 18];
      this.columnWidth = widthMap[Number(this.getFontSize || 1)] || 14;
    },
    calculateGridHeight() {
      const wh = Number(this.windowHeight) || window.innerHeight || 0;
      const header = document.getElementsByClassName("header");
      const headerHeight = header?.length ? header[header.length - 1].clientHeight : 0;
      const footerMenu = document.getElementById("footer-menu");
      const footerMenuHeight = (this.isDispMenu === 1 && footerMenu ? footerMenu.clientHeight : 0) + 5;
      this.kendoGridToolbarHeight = Math.max(100, wh - headerHeight - footerMenuHeight);
      const gridFooter = document.getElementById("grid-footer");
      const gridHeader = document.getElementById("grid-header");
      this.kendoGridHeight = Math.max(160, this.kendoGridToolbarHeight - ((gridFooter?.clientHeight || 0) + (gridHeader?.clientHeight || 0)));
    },
    calculateGridWidth() {
      this.resizeDirectGrid();
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
    getDirectGridHeaderWrap() {
      return this.getGridRootEl()?.querySelector?.(".k-grid-header-wrap") || null;
    },
    getGridWidget() {
      return this.directGridWidget || null;
    },
    getGridContentEl() {
      return this.getDirectGridScrollContent();
    },
    getGridScrollHostEl() {
      return this.getDirectGridScrollContent();
    },
    getGridDataSource() {
      return { data: Array.from(this.directGridWidget?.dataSource?.data?.() || []) };
    },
    getGridTableEl() {
      return this.directGridWidget?.table?.[0] || null;
    },
    getGridTbodyEl() {
      return this.directGridWidget?.tbody?.[0] || null;
    },
    getGridColumns() {
      return this.directGridWidget?.columns || [];
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
      const top = position.top ?? 0;
      const left = position.left ?? 0;
      content.scrollTop = top;
      content.scrollLeft = left;
      const headerWrap = this.getDirectGridHeaderWrap();
      if (headerWrap) {
        headerWrap.scrollLeft = left;
      }
      this.scrollPosition.top = top;
      this.scrollPosition.left = left;
      this.lastScrollTop = top;
      this.lastScrollLeft = left;
      this.syncDirectGridLockedScrollPosition(top);
    },
    storeDirectGridScrollPosition() {
      const pos = this.getGridScrollPosition();
      this.scrollPosition.top = pos.top;
      this.scrollPosition.left = pos.left;
      this.lastScrollTop = pos.top;
      this.lastScrollLeft = pos.left;
    },
    restoreDirectGridScrollPosition() {
      const top = this.scrollPosition.top ?? this.lastScrollTop ?? 0;
      const left = this.scrollPosition.left ?? this.lastScrollLeft ?? 0;
      this.setGridScrollPosition({ top, left });
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
    setLastScroll() {
      this.storeDirectGridScrollPosition();
    },
    getDirectGridDataSourceOption() {
      const source = this.masterRecords || {};
      return {
        ...source,
        data: Array.isArray(source.data) ? source.data : [],
      };
    },
    createDirectGridDataSource() {
      this.directGridDataSource = markRaw(new kendo.data.DataSource(this.getDirectGridDataSourceOption()));
      return this.directGridDataSource;
    },
    buildDirectGridColumns() {
      return this.columns.map(column => {
        const gridColumn = { ...column };
        if (column.field) {
          gridColumn.attributes = {
            ...(gridColumn.attributes || {}),
            "data-field": column.field
          };
        }
        if (column.field === "$modalType") {
          gridColumn.attributes = { class: "btn3-kendo-normal", "data-field": column.field };
          gridColumn.command = { text: "選択", click: event => this.showMasterEditModalTransit(event) };
        }
        if (column.title === "在宅") {
          gridColumn.hidden = !this.facilityHemoDialysis;
        }
        if (column.dataType === "date") {
          gridColumn.editor = (container, options) => this.eachModelCalendar(container, options);
        }
        if (column.dataType === "color") {
          gridColumn.template = column.colorTemplate;
          gridColumn.editor = (container, options) => this.colorEditor(container, options);
        }
        if (column.dataType === "textarea") {
          gridColumn.editor = (container, options) => this.textareaEditor(container, options);
        }
        if (column.dataType === "number") {
          gridColumn.round = false;
          gridColumn.restrictDecimals = true;
          gridColumn.editor = (container, options) => this.numericEditor(container, options);
        }
        if (column.field === "templateCd") {
          gridColumn.editable = model => this.checkUseType(model);
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
        this.initKendoValidatorIfReady();
        this.$nextTick(() => {
          this.installValidationTooltipPlacementObserver();
        });
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
        beforeEdit: event => this.modifyEditStart(event),
        edit: event => this.onDirectGridEdit(event),
        cellClose: event => this.onDirectGridCellClose(event),
        save: event => this.useTypeSave(event),
        dataBound: event => this.onDirectGridDataBound(event),
        columns: this.buildDirectGridColumns()
      });
      this.directGridWidget = markRaw($(root).data("kendoGrid"));
      this.directGridAppliedHeight = this.kendoGridHeight;
      this.applyDirectGridStyleContract();
      this.initKendoValidatorIfReady();
      this.scheduleDirectGridLayoutContract();
      this.$nextTick(() => {
        this.installValidationTooltipPlacementObserver();
      });
    },
    destroyDirectGrid() {
      this.teardownValidationTooltipPlacement();
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
      this.directGridAppliedHeight = null;
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
      const preservedScroll = !resetScroll ? {
        top: this.scrollPosition.top ?? this.lastScrollTop ?? 0,
        left: this.scrollPosition.left ?? this.lastScrollLeft ?? 0,
      } : null;
      if (!resetScroll && !this.preserveGridScrollAfterSave) {
        this.storeDirectGridScrollPosition();
      }
      grid.dataSource.data(this.getDirectGridDataSourceOption().data || []);
      if (resetScroll) {
        this.setGridScrollPosition({ top: 0, left: 0 });
        this.preserveGridScrollAfterSave = false;
      }
      this.$nextTick(() => {
        this.applyDirectGridStyleContract();
        this.editBackgroundColor();
        this.DisableDetailBtn();
        if (!resetScroll) {
          const scroll = preservedScroll || {
            top: this.scrollPosition.top ?? this.lastScrollTop ?? 0,
            left: this.scrollPosition.left ?? this.lastScrollLeft ?? 0,
          };
          this.setGridScrollPosition(scroll);
          this.scheduleDirectGridPostColumnScrollSync();
        }
      });
    },
    setGridDataSource(source) {
      const data = Array.isArray(source?.data) ? source.data : Array.isArray(source) ? source : [];
      this.directGridWidget?.dataSource?.data?.(data);
    },
    resizeDirectGrid() {
      const grid = this.directGridWidget;
      if (!grid) {
        return;
      }
      try {
        if (this.directGridAppliedHeight !== this.kendoGridHeight) {
          grid.setOptions({ height: this.kendoGridHeight });
          this.directGridAppliedHeight = this.kendoGridHeight;
        }
        grid.resize(true);
        this.applyDirectGridLockedWidthContract();
        this.applyDirectGridLockedHeightContract();
        this.$nextTick(() => {
          this.scheduleValidationTooltipPlacement();
        });
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
      root.querySelectorAll("th").forEach(th => th.classList.add("k-header"));
      [
        ".k-grid-content tbody",
        ".k-grid-content-locked tbody"
      ].forEach(selector => {
        root.querySelectorAll(selector).forEach(tbody => {
          Array.from(tbody.querySelectorAll("tr")).forEach((tr, index) => {
            const alt = index % 2 === 1;
            tr.classList.add("k-master-row");
            tr.classList.toggle("k-alt", alt);
            tr.classList.toggle("k-table-alt-row", alt);
          });
        });
      });
      root.querySelectorAll("td:not(.k-edit-cell)").forEach(td => td.classList.add("k-td", "k-table-td"));
      root.querySelectorAll("td.k-edit-cell").forEach(td => td.classList.remove("k-td", "k-table-td"));
      this.applyDirectGridLockedWidthContract();
      this.applyDirectGridLockedHeightContract();
      this.syncDirectGridLockedScrollPosition();
    },
    isDirectGridDateField(field) {
      return field === "inHospAStartdate" || field === "inHospBStartdate";
    },
    prepareDirectGridEditCell(cell) {
      const td = cell?.closest?.("td") || cell;
      td?.classList?.remove?.("k-td", "k-table-td");
    },
    hasDirectGridFieldValueChanged(oldValue, newRawValue, field) {
      if (this.isDirectGridDateField(field)) {
        const oldDate = oldValue instanceof Date ? oldValue : this.yyyymmddToDate(oldValue);
        const newDate = newRawValue === "" || newRawValue == null ? null : this.yyyymmddToDate(newRawValue);
        if (!oldDate && !newDate) {
          return false;
        }
        if (!oldDate || !newDate) {
          return true;
        }
        return !dayjs(oldDate).isSame(dayjs(newDate), "day");
      }
      return oldValue != newRawValue;
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
      // ここで値を直接 onSave してから closeCell する（MasterRecordComponent 経路と同等の結果）。
      if (model && field) {
        const changed = this.hasDirectGridFieldValueChanged(model[field], normalizedValue, field);
        if (changed) {
          this.onSave({
            model,
            values: { [field]: normalizedValue },
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
        this.$nextTick(() => {
          if (model?.code != null) {
            const record = (this.getMasterRecordList?.data || []).find(
              item => String(item.code) === String(model.code)
            ) || model;
            this.scheduleDirectGridRowVisualRefresh(record, {
              preferredUid: model.uid,
              deferUntilCellClose: true,
            });
          }
        });
      });
    },
    scheduleDirectGridLayoutContract() {
      if (!this.preserveGridScrollAfterSave) {
        this.storeDirectGridScrollPosition();
      }
      if (this.directGridLayoutRafId != null) {
        cancelAnimationFrame(this.directGridLayoutRafId);
      }
      this.directGridLayoutRafId = requestAnimationFrame(() => {
        this.calculateColumnsWidth();
        this.calculateGridHeight();
        if (!this.editingFlg) {
          this.resizeDirectGrid();
        }
        this.applyDirectGridStyleContract();
        this.restoreDirectGridScrollPosition();
        this.directGridLayoutRafId = requestAnimationFrame(() => {
          this.directGridLayoutRafId = null;
          if (!this.editingFlg) {
            this.resizeDirectGrid();
          }
          this.applyDirectGridStyleContract();
          this.restoreDirectGridScrollPosition();
          this.scheduleDirectGridPostColumnScrollSync();
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
      this.DisableDetailBtn();
      this.installValidationTooltipPlacementObserver();
      this.scheduleValidationTooltipPlacement();
    },
    editStart(e) {
      this.editingFlg = true;
      if (this.isMobileDevice && !this.allowEdit) {
        e?.preventDefault?.();
      }
    },
    onDirectGridEdit(event) {
      bindGridEditorEnterToCloseCell(event?.sender || this.directGridWidget, event?.container);
      bindGridEditorDropDownListToCloseCell(event?.sender || this.directGridWidget, event?.container);
      this.addInputAssistCore(event);
      const field = this.getDirectGridFieldFromEvent(event);
      const cell = event?.container?.[0] || event?.container;
      if (!field || !cell) {
        return;
      }
      this.applyDirectGridEditorValidationMessage(cell, field);
      this.scheduleValidationTooltipPlacement();
      const onValidationPlacement = () => {
        this.scheduleValidationTooltipPlacement();
      };
      const inputs = Array.from(
        cell.querySelectorAll?.("input:not([type='hidden']), textarea, select") || []
      );
      inputs.forEach(input => {
        input.addEventListener("blur", onValidationPlacement, { passive: true });
        input.addEventListener("invalid", onValidationPlacement, { passive: true });
        input.addEventListener("change", onValidationPlacement, { passive: true });
      });
      const bindDropDownValidation = () => {
        const dropDownWidget = getGridEditorDropDownListWidget(event?.container);
        if (!dropDownWidget || dropDownWidget.__ntssPatEventSubCategoryValidationBound) {
          return;
        }
        dropDownWidget.__ntssPatEventSubCategoryValidationBound = true;
        const onDropDownDirtyPreview = () => {
          const editField = this.getDirectGridFieldFromEvent(event);
          if (!editField || !event?.model) {
            return;
          }
          const resolved = resolveGridEditorDropDownListSaveValue(
            editField,
            event,
            this.getMasterRecordList?.schema?.model?.fields
          );
          const nextValue = resolved !== undefined
            ? resolved
            : (typeof dropDownWidget.value === "function" ? dropDownWidget.value() : undefined);
          if (nextValue === undefined) {
            return;
          }
          const visualRecord = this.getDirectGridModelPlain(event.model, { [editField]: nextValue });
          this.markDirectGridEditedField(visualRecord, editField);
          this.scheduleDirectGridRowVisualRefresh(visualRecord, {
            preferredUid: event?.model?.uid,
            field: editField,
          });
        };
        try {
          dropDownWidget.bind?.("change", onValidationPlacement);
          dropDownWidget.bind?.("select", onValidationPlacement);
          dropDownWidget.bind?.("close", onValidationPlacement);
          dropDownWidget.bind?.("open", onValidationPlacement);
          dropDownWidget.bind?.("change", onDropDownDirtyPreview);
          dropDownWidget.bind?.("select", onDropDownDirtyPreview);
        } catch (_error) {
          // noop
        }
        const dropDownElement = dropDownWidget.wrapper?.[0] || dropDownWidget.element?.[0];
        dropDownElement?.addEventListener?.("focusin", onValidationPlacement, { passive: true });
      };
      bindDropDownValidation();
      setTimeout(bindDropDownValidation, 0);
      setTimeout(bindDropDownValidation, 100);
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
      this.editEnd(ev);
    },
    addInputAssistCore(event) {
      const field = this.getDirectGridFieldFromEvent(event);
      const cell = event?.container?.[0] || event?.container;
      if (!field || !cell) {
        return;
      }
      this.prepareDirectGridEditCell(cell);
      if (this.isDirectGridDateField(field)) {
        return;
      }
      const input = cell?.querySelector?.("input");
      if (!input) {
        return;
      }
      const onInput = () => {
        const value = this.readDirectGridEditorValue(cell);
        const visualRecord = this.getDirectGridModelPlain(event.model, { [field]: value });
        this.markDirectGridEditedField(visualRecord, field);
        if (this.isSortMode && field === "sortRank") {
          this.setDirectGridSortManuallyEdited(visualRecord, this.isSortRankChangedFromSnapshot(visualRecord));
        }
        this.scheduleDirectGridRowVisualRefresh(visualRecord, {
          preferredUid: event?.model?.uid,
          field,
        });
      };
      input.addEventListener("input", onInput, { passive: true });
      input.addEventListener("change", onInput, { passive: true });
      setTimeout(onInput, 0);
    },
    editEnd() {
      this.editingFlg = false;
    },
    onSave(event) {
      const model = event?.model;
      if (!model) {
        return;
      }
      const field = this.getDirectGridFieldFromEvent(event);
      const dropDownWidget = getGridEditorDropDownListWidget(event?.container);
      const values = {};
      // fix 2026/06/03 DropDown save は編集中列のみ反映（表示テキスト混入防止） 名前 start
      if (dropDownWidget && field) {
        const resolved = resolveGridEditorDropDownListSaveValue(
          field,
          event,
          this.getMasterRecordList?.schema?.model?.fields
        );
        if (resolved !== undefined) {
          values[field] = resolved;
        } else if (typeof dropDownWidget.value === "function") {
          const widgetValue = dropDownWidget.value();
          if (widgetValue !== undefined) {
            values[field] = widgetValue;
          }
        }
      } else {
        Object.assign(values, event?.values || {});
        if (field && Object.keys(values).length === 0) {
          const value = this.readDirectGridEditorValue(event?.container?.[0] || event?.container);
          if (value !== undefined) {
            values[field] = value;
          }
        }
      }
      const savedFields = field ? [field] : Object.keys(values || {});
      // fix 2026/06/03 DropDown save は編集中列のみ反映（表示テキスト混入防止） 名前 end
      Object.keys(values).forEach(key => {
        if (typeof model.set === "function") {
          model.set(key, values[key]);
        } else {
          model[key] = values[key];
        }
      });
      this.normalizePatEventSubCategoryDateFields(model);
      let updatedRecord = this.getDirectGridModelPlain(model, values);
      this.reconcileDirectGridEditedFields(updatedRecord, savedFields);

      if (this.isSortMode && Object.prototype.hasOwnProperty.call(values, "sortRank")) {
        const sortChanged = this.isSortRankChangedFromSnapshot(updatedRecord);
        this.setDirectGridSortManuallyEdited(updatedRecord, sortChanged);
        if (!sortChanged) {
          try {
            event?.sender?.refresh?.();
          } catch (_error) {
            // noop
          }
          this.scheduleDirectGridRowVisualRefresh(updatedRecord, {
            preferredUid: model?.uid,
            deferUntilCellClose: true,
          });
          return;
        }
        if (model.operation !== 1) {
          delete model.edited;
        }
        updatedRecord = this.getDirectGridModelPlain(model, values);
        this.edit({ editRecord: updatedRecord, isSortMode: this.isSortMode });
        this.scheduleDirectGridRowVisualRefresh(updatedRecord, {
          preferredUid: model?.uid,
          deferUntilCellClose: true,
        });
        return;
      }

      if (model.operation === 1) {
        model.edited = true;
        updatedRecord.edited = true;
      } else if (!model.operation) {
        model.operation = 2;
        model.edited = true;
        updatedRecord.operation = 2;
        updatedRecord.edited = true;
      }
      this.edit({ editRecord: updatedRecord, isSortMode: this.isSortMode });
      // fix 2026/06/02 cellClose 後に行背景色を反映 MasterRecordComponent 同等
      this.scheduleDirectGridRowVisualRefresh(updatedRecord, {
        preferredUid: model?.uid,
        deferUntilCellClose: true,
      });
    },
    parseComparisonRecordModel() {
      try {
        return JSON.parse(this.$store?.state?.["master-maintenance"]?.comparisonRecordModel || "[]");
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
      if (!record) {
        return null;
      }
      if (record.code !== undefined && record.code !== null) {
        return String(record.code);
      }
      if (record.uid) {
        return String(record.uid);
      }
      return null;
    },
    isDirectGridAddedRecord(record) {
      return !!record && (record.operation === 1 || String(record.operation) === "1" || record.isAddRow === true);
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
      if (!key || !fieldName || fieldName === "dummy" || fieldName === "sortRank" || fieldName.startsWith("$")) {
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
    clearDirectGridEditedFields(record) {
      const key = this.getDirectGridRecordKey(record);
      if (key) {
        this.directGridEditedFieldsByCode?.delete?.(key);
      }
    },
    patEventSubCategoryCompareValuesEqual(a, b) {
      return String(a ?? "") === String(b ?? "");
    },
    getDirectGridNewRecordDefaultValue(fieldName) {
      const fields = this.getMasterRecordList?.schema?.model?.fields;
      const def = fields?.[fieldName];
      if (!def) {
        return null;
      }
      if (def.defaultValue !== undefined) {
        return def.defaultValue;
      }
      if (def.type === "string") {
        return "";
      }
      if (def.type === "number") {
        return 0;
      }
      if (def.type === "date") {
        return null;
      }
      if (def.type === "color") {
        return "#000000";
      }
      return null;
    },
    isDirectGridAddedFieldChangedFromDefault(record, fieldName) {
      if (!this.isDirectGridAddedRecord(record)) {
        return false;
      }
      const current = this.getComboCompareValue(record, fieldName, record[fieldName]);
      const base = this.getComboCompareValue(
        record,
        fieldName,
        this.getDirectGridNewRecordDefaultValue(fieldName)
      );
      return !this.patEventSubCategoryCompareValuesEqual(current, base);
    },
    isDirectGridFieldValueDirty(record, fieldName, original = null) {
      if (!record || !fieldName) {
        return false;
      }
      const skip = new Set(["sortRank", "sortInputTime", "dummy", "uid", "$modalType"]);
      if (skip.has(fieldName) || fieldName.startsWith("$")) {
        return false;
      }
      if (this.getDirectGridEditedFields(record).includes(fieldName)) {
        return true;
      }
      const baseline = original ?? (this.isDirectGridAddedRecord(record) ? null : this.findOriginalRecord(record));
      if (!baseline) {
        return this.isDirectGridAddedFieldChangedFromDefault(record, fieldName);
      }
      const current = this.getComboCompareValue(record, fieldName, record[fieldName]);
      const base = this.getComboCompareValue(baseline, fieldName, baseline[fieldName]);
      return !this.patEventSubCategoryCompareValuesEqual(current, base);
    },
    isDirectGridFieldDirty(record, fieldName) {
      return this.isDirectGridFieldValueDirty(record, fieldName);
    },
    reconcileDirectGridEditedFields(record, fieldNames = []) {
      if (!record || !Array.isArray(fieldNames) || fieldNames.length === 0) {
        return;
      }
      const original = this.isDirectGridAddedRecord(record) ? null : this.findOriginalRecord(record);
      fieldNames.forEach(fieldName => {
        if (!fieldName || fieldName.startsWith("$") || fieldName === "dummy" || fieldName === "sortRank") {
          return;
        }
        // 新規行は save 直後に session 未登録のため、保存列は常に mark する
        if (this.isDirectGridAddedRecord(record)) {
          this.markDirectGridEditedField(record, fieldName);
          return;
        }
        if (this.isDirectGridFieldValueDirty(record, fieldName, original)) {
          this.markDirectGridEditedField(record, fieldName);
        } else {
          this.unmarkDirectGridEditedField(record, fieldName);
        }
      });
    },
    setDirectGridSortManuallyEdited(record, edited) {
      const key = this.getDirectGridRecordKey(record);
      if (!key) {
        return;
      }
      edited ? this.directGridSortEditedCodes.add(key) : this.directGridSortEditedCodes.delete(key);
    },
    isDirectGridSortManuallyEdited(record) {
      const key = this.getDirectGridRecordKey(record);
      return !!key && this.directGridSortEditedCodes.has(key);
    },
    getDirectGridModelPlain(model, overrides = {}) {
      const plain = typeof model?.toJSON === "function" ? model.toJSON() : clonePlain(model || {});
      Object.keys(overrides || {}).forEach(key => {
        plain[key] = overrides[key];
      });
      return plain;
    },
    readDirectGridEditorValue(container) {
      const input = container?.querySelector?.("input");
      if (!input) {
        return undefined;
      }
      const value = input.value;
      const numeric = Number(value);
      return value !== "" && !Number.isNaN(numeric) ? numeric : value;
    },
    getDirectGridFieldFromCell(cell) {
      const dataField = cell?.getAttribute?.("data-field") || cell?.dataset?.field;
      if (dataField) {
        return dataField;
      }
      const row = cell?.closest?.("tr");
      const grid = this.directGridWidget;
      if (!row || !Array.isArray(grid?.columns)) {
        return null;
      }
      const isLockedRow = !!row.closest?.(".k-grid-content-locked");
      const cells = Array.from(row.children || []);
      const cellIndex = cells.indexOf(cell);
      if (cellIndex < 0) {
        return null;
      }
      let visibleCellIndex = 0;
      for (let columnIndex = 0; columnIndex < grid.columns.length; columnIndex++) {
        const column = grid.columns[columnIndex];
        if (column.hidden) {
          continue;
        }
        if (!!column.locked !== isLockedRow) {
          continue;
        }
        if (visibleCellIndex === cellIndex) {
          return column.field || null;
        }
        visibleCellIndex += 1;
      }
      return null;
    },
    getDirectGridFieldFromEvent(ev) {
      const activeField = ev?.sender?.editable?.options?.fields?.field;
      return activeField || this.getDirectGridFieldFromCell(ev?.container?.[0] || ev?.container);
    },
    getDirectGridRowsByRecord(record, preferredUid = null) {
      const root = this.getGridRootEl();
      const grid = this.directGridWidget;
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
    resolveDirectGridCellByColumnField(row, fieldName) {
      const grid = this.directGridWidget;
      if (!row || !fieldName || !Array.isArray(grid?.columns)) {
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
      return null;
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
      return this.resolveDirectGridCellByColumnField(row, fieldName);
    },
    getDirectGridCellsByField(rows, fieldName) {
      if (!fieldName) {
        return [];
      }
      return (rows || [])
        .map(row => this.findDirectGridCellForField(row, fieldName))
        .filter(Boolean);
    },
    // fix 2026/06/03 k-dirty-cell 同期 名前 start
    markDirectGridDirtyCell(cell) {
      if (!cell?.classList) {
        return;
      }
      cell.classList.add("k-dirty-cell", "master-edited-cell");
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
    getDirectGridChangedFields(record) {
      if (!record) {
        return [];
      }
      const skip = new Set(["sortRank", "sortInputTime", "dummy", "uid", "$modalType"]);
      return (this.columns || [])
        .map(column => column.field)
        .filter(field => field && !field.startsWith("$") && !skip.has(field))
        .filter(field => this.isDirectGridFieldDirty(record, field));
    },
    getDirectGridDirtyFieldNames(record) {
      if (!record) {
        return [];
      }
      const skip = new Set(["sortRank", "sortInputTime", "dummy", "uid", "$modalType"]);
      const fromSnapshot = this.getDirectGridChangedFields(record);
      const fromSession = this.getDirectGridEditedFields(record).filter(
        fieldName => fieldName && !fieldName.startsWith("$") && !skip.has(fieldName)
          && this.isDirectGridFieldDirty(record, fieldName)
      );
      return [...new Set([...fromSnapshot, ...fromSession])];
    },
    resolveDirectGridDirtyFieldNames(record, activeField = null) {
      const skip = new Set(["sortRank", "sortInputTime", "dummy", "uid", "$modalType"]);
      const fields = new Set(this.getDirectGridDirtyFieldNames(record));
      if (
        activeField
        && !skip.has(activeField)
        && !activeField.startsWith("$")
        && this.isDirectGridFieldDirty(record, activeField)
      ) {
        fields.add(activeField);
      }
      return [...fields];
    },
    syncDirectGridDirtyCellMarkers(record, rows, activeField = null) {
      this.resolveDirectGridDirtyFieldNames(record, activeField).forEach(field => {
        this.getDirectGridCellsByField(rows, field).forEach(cell => {
          this.markDirectGridDirtyCell(cell);
        });
      });
    },
    // fix 2026/06/03 k-dirty-cell 同期 名前 end
    // fix 2026/06/03 削除済みコンボ参照セルの背景色（master-deleted-combo） 名前 start
    shouldApplyDirectGridDeletedComboVisual() {
      // Vue2 did not mark blank combo display cells on this screen.
      return false;
    },
    applyDirectGridDeletedComboVisual(record, rows) {
      if (!record || !rows?.length) {
        return;
      }
      if (!this.shouldApplyDirectGridDeletedComboVisual()) {
        return;
      }
      if (record.operation === 1 || record.isDisp === "0") {
        return;
      }
      const codeText = String(record.code ?? "").replaceAll(",", "");
      if (codeText === "") {
        return;
      }
      this.columns.forEach(column => {
        if (column.values == null || !column.field || column.field === "dummy") {
          return;
        }
        if (!this.hasValueColumn(codeText, column.field)) {
          return;
        }
        this.getDirectGridCellsByField(rows, column.field).forEach(cell => {
          if ((cell.textContent || "") === "") {
            cell.classList.add("master-deleted-combo");
          }
        });
      });
    },
    // fix 2026/06/03 削除済みコンボ参照セルの背景色（master-deleted-combo） 名前 end
    clearDirectGridRowVisualState(rows) {
      rows.forEach(row => {
        row.classList.remove("k-dirty-row", "master-edited-row");
        Array.from(row.children || []).forEach(cell => {
          cell.classList.remove(
            "master-edited-row",
            "master-edited-cell",
            "master-sort-edited",
            "master-deleted-combo",
            "k-dirty-cell"
          );
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
    shouldShowEditedRowVisual(record, field = null) {
      if (record?.code == null) {
        return false;
      }
      if (this.isEdited(record.code)) {
        return true;
      }
      if (record.operation === 2 || (record.operation === 1 && record.edited)) {
        return true;
      }
      if (field) {
        const original = this.findOriginalRecord(record);
        if (original && record[field] != original[field]) {
          return true;
        }
      }
      return false;
    },
    scheduleDirectGridRowVisualRefresh(record, options = {}) {
      if (!record) {
        return;
      }
      const { deferUntilCellClose = false, preferredUid = null, field = null } = options;
      const key = record.uid || record.code || "__unknown__";
      const pendingId = this.directGridRowVisualRafIds.get(key);
      if (pendingId != null) {
        cancelAnimationFrame(pendingId);
      }
      const run = () => {
        this.directGridRowVisualRafIds.delete(key);
        this.applyDirectGridRowVisualState(record, preferredUid, null, field);
      };
      const scheduleRun = () => {
        if (deferUntilCellClose) {
          requestAnimationFrame(() => requestAnimationFrame(run));
          return;
        }
        const rafId = requestAnimationFrame(run);
        this.directGridRowVisualRafIds.set(key, rafId);
      };
      if (deferUntilCellClose) {
        this.$nextTick(scheduleRun);
      } else {
        scheduleRun();
      }
    },
    applyDirectGridRowVisualState(record, preferredUid = null, resolvedRows = null, field = null) {
      if (!record) {
        return;
      }
      const rows = resolvedRows || this.getDirectGridRowsByRecord(record, preferredUid);
      if (!rows.length) {
        return;
      }
      this.clearDirectGridRowVisualState(rows);
      const changed = this.shouldShowEditedRowVisual(record, field);
      const sortChanged = this.isDirectGridSortManuallyEdited(record);
      if (!changed && !sortChanged) {
        this.applyDirectGridDeletedComboVisual(record, rows);
        return;
      }
      const sortRankIndex = this.getColumnIndex("sortRank");
      const dummyIndex = this.getColumnIndex("dummy");
      const { lockedRows, scrollableRows } = this.splitDirectGridRows(rows);
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
        this.syncDirectGridDirtyCellMarkers(record, rows, field);
      }
      if (sortChanged) {
        // Vue2 changeSortColor() と同じく、ユーザーが編集した行の並び順列とダミー列だけを黄色にする。
        const sortRows = lockedRows.length ? lockedRows : rows;
        this.getDirectGridCellsByField(sortRows, "sortRank").forEach(cell => {
          this.markDirectGridDirtyCell(cell);
          cell.classList.add("master-sort-edited");
        });
        this.getDirectGridCellsByField(sortRows, "dummy").forEach(cell => {
          cell.classList.add("master-sort-edited");
        });
      }
      this.applyDirectGridDeletedComboVisual(record, rows);
    },
    buildDirectGridRowsByCodeMap() {
      const root = this.getGridRootEl();
      const grid = this.directGridWidget;
      const result = new Map();
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
    editBackgroundColor() {
      this.refreshDirectGridDirtyVisualState();
    },
    editableColumns() {
      this.columns.forEach(column => {
        column.editable = column.field === "sortRank" ? () => false : column.originalEditable ? () => true : () => false;
      });
      this.syncDirectGridColumnEditableContract();
    },
    disableColumns() {
      this.columns.forEach(column => {
        column.editable = column.field === "sortRank" ? (this.isAllowSort ? () => true : () => false) : () => false;
      });
      this.syncDirectGridColumnEditableContract();
    },
    syncDirectGridColumnEditableContract() {
      const grid = this.directGridWidget;
      if (!grid) {
        return;
      }
      (this.columns || []).forEach(col => {
        if (!col.field) {
          return;
        }
        const kendoCol = (grid.columns || []).find(kc => kc.field === col.field);
        if (kendoCol) {
          kendoCol.editable = col.editable;
        }
      });
    },
    setDirectGridColumnHidden(field, hidden) {
      const grid = this.directGridWidget;
      if (!grid) {
        return;
      }
      const column = (grid.columns || []).find(item => item.field === field);
      if (!column || !!column.hidden === !!hidden) {
        return;
      }
      hidden ? grid.hideColumn(field) : grid.showColumn(field);
    },
    showSortColumn() {
      const sortRank = this.columns.find(column => column.field === "sortRank");
      const dummy = this.columns.find(column => column.field === "dummy");
      if (sortRank) {
        sortRank.hidden = !(this.isAllowSort && this.isSortMode);
      }
      if (dummy) {
        dummy.hidden = !sortRank?.hidden;
      }
      this.setDirectGridColumnHidden("sortRank", !!sortRank?.hidden);
      this.setDirectGridColumnHidden("dummy", !!dummy?.hidden);
      this.scheduleDirectGridLayoutContract();
    },
    syncDirectGridSortValuesToMasterRecords() {
      const data = this.directGridWidget?.dataSource?.data?.();
      if (!data || !Array.isArray(this.getMasterRecordList?.data)) {
        return;
      }
      const rows = typeof data.toJSON === "function" ? data.toJSON() : Array.from(data);
      rows.forEach((row, index) => {
        const target = this.getMasterRecordList.data.find(record => String(record.code) === String(row.code)) || this.getMasterRecordList.data[index];
        if (target && row.sortRank !== undefined) {
          target.sortRank = row.sortRank;
          target.sortInputTime = row.sortInputTime || Date.now();
        }
      });
    },
    sort() {
      const list = this.getMasterRecordList?.data || [];
      list.sort((a, b) => a.sortRank - b.sortRank || (a.sortInputTime || 0) - (b.sortInputTime || 0));
      for (let i = 0; i < list.length; i++) {
        if (list[i].isDisp === "1") {
          list[i].sortRank = i + 1;
        }
      }
    },
    sortChange(tempData) {
      let flag = false;
      const list = this.getMasterRecordList?.data || [];
      list.forEach(item => {
        tempData.forEach(tempItem => {
          if (item.code === tempItem.code && item.sortRank !== tempItem.sortRank) {
            flag = true;
          }
        });
      });
      return flag;
    },
    toRankEditBtnClick() {
      if (!this.validateBeforeGridAction()) {
        return;
      }
      this.isSortMode = true;
      this.disableColumns();
      this.showSortColumn();
      this.$nextTick(() => {
        this.editBackgroundColor();
      });
    },
    sortBtnClick() {
      try {
        this.directGridWidget?.closeCell?.();
      } catch (_error) {
        // noop
      }
      this.syncDirectGridSortValuesToMasterRecords();
      (this.getMasterRecordList?.data || []).forEach(record => {
        this.setDirectGridSortManuallyEdited(record, this.isSortRankChangedFromSnapshot(record));
      });
      const tempData = clonePlain(this.getMasterRecordList?.data || []);
      this.isSortMode = false;
      this.editableColumns();
      this.showSortColumn();
      this.sort();
      this.isSorted = this.sortChange(tempData);
      this.refreshDirectGridDataFromMasterRecords();
    },
    convertToStr(messageArr) {
      if (!messageArr || messageArr.length === 0) {
        return "";
      }
      const unique = messageArr.reduce((acc, cur) => acc.includes(cur) ? acc : acc.concat(cur), []);
      return "</br>&nbsp&nbsp・" + unique.join("</br>&nbsp&nbsp・");
    },
    validateRequired() {
      const validateMessageArr = [];
      const fields = this.getMasterRecordList?.schema?.model?.fields || {};
      (this.getMasterRecordList?.data || []).filter(row => row.isDisp !== "0").forEach(row => {
        Object.keys(fields).forEach(key => {
          if (fields[key]?.validation?.required && row[key] !== null && row[key] === "") {
            const columnInfo = this.columns.find(column => column.field == key);
            if (columnInfo?.title) {
              validateMessageArr.push(columnInfo.title);
            }
          }
        });
      });
      return this.convertToStr(validateMessageArr);
    },
    getComboCompareValue(row, field, rawValue) {
      if (rawValue === null || rawValue === undefined || rawValue === "") {
        return rawValue;
      }
      if (field === "templateCd" && row.useType == "3") {
        const text = String(rawValue);
        return text.startsWith("a") ? text.slice(1) : text;
      }
      return rawValue;
    },
    validateComboValue() {
      const comboFields = this.columns
        .filter(column => column.values != null)
        .map(column => ({
          field: column.field,
          title: column.title,
          values: column.values,
        }));

      const gridData = this.getMasterRecordList;
      let rows = (gridData?.data || []).filter(row => row.isDisp !== "0" && row.isDel === "0");
      // No4355：患者イベントカテゴリマスタでカテゴリ削除時のサブカテゴリ削除可否（MasterMaintenanceMixin と同じ）
      if (this.masterPhysicalName === "mst_pat_event_sub_category") {
        rows = (gridData?.data || []).filter(row => row.isDel !== "0" && row.categoryCd);
      }

      const validateMessageArr = [];
      for (let rowIdx = 0; rowIdx < rows.length; rowIdx++) {
        for (let comboIdx = 0; comboIdx < comboFields.length; comboIdx++) {
          const field = comboFields[comboIdx].field;
          const rawValue = rows[rowIdx][field];
          const compareValue = this.getComboCompareValue(rows[rowIdx], field, rawValue);
          const index = comboFields[comboIdx].values.findIndex(e => {
            const optionValue = field === "templateCd" && rows[rowIdx].useType == "3"
              ? this.getComboCompareValue(rows[rowIdx], field, e.value)
              : e.value;
            return optionValue == compareValue || e.value == rawValue;
          });
          // EOL 6951：編集行（operation あり）のみコンボ整合性をチェック（mixin と同じ）
          const operation = rows[rowIdx].operation;
          if (operation !== 1 && operation !== 2) {
            continue;
          }
          if (index < 0 && rawValue !== null && rawValue !== "") {
            validateMessageArr.push(comboFields[comboIdx].title);
          }
        }
      }
      return this.convertToStr(validateMessageArr);
    },
    normalization(items) {
      const columnNames = (this.columnDefinition || this.columns || []).map(column => column.field);
      return Object.keys(items || {}).filter(key => columnNames.includes(key) || key === "isAddRow").reduce((acc, key) => {
        acc[key] = items[key];
        return acc;
      }, {});
    },
    showMasterEditModal(e) {
      const content = this.getGridContentEl();
      this.scrollTop = content?.scrollTop || 0;
      this.scrollLeft = content?.scrollLeft || 0;
      this.showMasterEdit();
      e?.preventDefault?.();
      const selectedRowItem = this.getGridWidget()?.dataItem?.(e.currentTarget.closest("tr"));
      if (!selectedRowItem) {
        return;
      }
      if (!selectedRowItem.code) {
        this.edit({ editRecord: selectedRowItem, isSortMode: this.isSortMode });
      }
      this.setEditRecord(this.normalization(selectedRowItem));
    },
    importCsv(event = null) {
      if (!this.validateBeforeGridAction()) {
        return;
      }
      this.masterCsvTarget = event?.target || null;
      this.masterCsvVisible = true;
    },
    prehideCsvPopover() {
      this.masterCsvVisible = false;
      this.refreshDirectGridDataFromMasterRecords();
    },
    onCloseMasterEditModal() {
      this.$nextTick(() => {
        this.refreshDirectGridDataFromMasterRecords();
        this.setGridScrollPosition({ top: this.scrollTop || 0, left: this.scrollLeft || 0 });
      });
    },
    refresh() {
      if (this.selfScreenName === this.getCurrentRouteName() && document.getElementsByTagName("ons-alert-dialog").length === 0) {
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
      }
    },
    eachModelCalendar(container, data) {
      if (this.androidFlg === true) {
        // Androidの場合は、HTML5のカレンダーを表示
        $(`<input type="date" name="${data.field}" />`).appendTo(container);
      } else {
        this.prepareDirectGridEditCell(container?.[0] || container);
        let moveOutFlg = false;
        container.mouseenter(() => (moveOutFlg = false));
        container.mouseleave(() => (moveOutFlg = true));
        // デスクトップ、iOSの場合は、処理で補正したHTML5のカレンダーを表示
        let nowData;
        let hasInitValue = true;
        const editedData = data.model[data.field];
        let nowDtatString;
        if (editedData) {
          nowData = this.yyyymmddToDate(editedData);
        } else {
          nowData = new Date();
          hasInitValue = false;
        }
        nowDtatString =
          nowData.getFullYear() +
          "-" +
          ("0" + (nowData.getMonth() + 1)).slice(-2) +
          "-" +
          ("0" + nowData.getDate()).slice(-2);
        // #5590 2023/04/20 ×を常に表示するように修正 林峻峰 start
        if (!editedData) {
          nowDtatString = "";
        }
        // #5590 2023/04/20 ×を常に表示するように修正 林峻峰 end
        //#10715：日付IF修正20240910検証NG対応：村上Start
        $(
          `<span class="direct-date-editor-wrap"><input type="date" style="width:8em" id="displayedDummyEditor" class="ntss-input-date" min="1880-01-01" max="2099-12-31" value="${nowDtatString}"/><input type="date" id="hiddenDateInputEditor" name="${data.field}" style="display: none;"/><span id="clear" class="k-icon k-i-close close-btn direct-date-clear" title="clear"></span></span>`
        ).appendTo(container);
        const editorRoot = container?.[0] || container;
        const queryEditorElement = (selector) => editorRoot?.querySelector?.(selector) || null;
        const displayedDummyEditor = queryEditorElement("#displayedDummyEditor");
        const hiddenDateInputEditor = queryEditorElement("#hiddenDateInputEditor");
        const clearButton = queryEditorElement("#clear");
        // フォーカスアウトで編集データを反映するイベントを発火
        displayedDummyEditor?.addEventListener("blur", function (ev) {
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
              resultData =
                dayData.getFullYear() +
                "-" +
                ("0" + (dayData.getMonth() + 1)).slice(-2) +
                "-" +
                ("0" + dayData.getDate()).slice(-2);
            }

            // 変更前の値と比較し、同じ値の場合は処理しない。又は、初期値がない場合、必ず処理する。
            if ((!hasInitValue || nowDtatString != resultData) && hiddenDateInputEditor) {
              hiddenDateInputEditor.value = resultData;
              // name="${data.field}" で割り当てた箇所に付与されているchangeメソッドを発火します。次いで@saveの処理が発生します。
              $(hiddenDateInputEditor).trigger("change");
            }
          });

        const commonCalenderMountNode = (editorRoot?.ownerDocument || this.$el?.ownerDocument || document).createElement("span");
        container.append(commonCalenderMountNode);
        const commonCalenderApp = createApp(commonCalender, {
          onInput: (value) => {
            this.finishDirectGridCalendarEdit(
              hiddenDateInputEditor,
              displayedDummyEditor,
              value,
              data.model,
              data.field
            );
          }
        });
        let commonCalenderPicker = commonCalenderApp.mount(commonCalenderMountNode);
        commonCalenderPicker.setSilently(nowDtatString);
        //  #5590 2023/05/15 iPadでSafariを使うと、数字に×が被る。修正 張博 start
        const userAgent = ((this?.$el?.ownerDocument?.defaultView?.navigator?.userAgent) || globalThis?.navigator?.userAgent || "");
        if (userAgent.indexOf("Intel Mac OS") > -1) {
          displayedDummyEditor?.addEventListener("change", (ev) => {
            if (hiddenDateInputEditor) {
              hiddenDateInputEditor.value = ev.target.value;
              // name="${data.field}" で割り当てた箇所に付与されているchangeメソッドを発火します。次いで@saveの処理が発生します。
              $(hiddenDateInputEditor).trigger('change');
            }
          });
        } else {
          displayedDummyEditor?.addEventListener("change", (ev) => {
            commonCalenderPicker.setSilently(ev.target.value);
          });
        }
        //  #5590 2023/05/15 iPadでSafariを使うと、数字に×が被る。修正 張博 end
        // #5590 2023/04/20 ×を常に表示するように修正 林峻峰 start
        // let clear = `<span id="clear" class="k-icon k-i-close close-btn" title="clear" style="position:relative;right:65px;bottom:1px;color: #212529;z-index:9999999" ></span>`
        // container.append(clear);
        clearButton?.addEventListener("mousedown", () => {
          this.finishDirectGridCalendarEdit(
            hiddenDateInputEditor,
            displayedDummyEditor,
            null,
            data.model,
            data.field
          );
        });
        // #5590 2023/04/20 ×を常に表示するように修正 林峻峰 end
        //  #5590 2023/05/12 iPadでSafariを使うと、数字に×が被る。修正 張博 start
        clearButton?.addEventListener("touchstart", () => {
          this.finishDirectGridCalendarEdit(
            hiddenDateInputEditor,
            displayedDummyEditor,
            null,
            data.model,
            data.field
          );
        });
        //  #5590 2023/05/12 iPadでSafariを使うと、数字に×が被る。修正 張博 end
      }
    },
    colorEditor(container, data) {
      const dummyField = $("<input/>")
        .attr("name", data.field)
        .css("display", "none")
        .appendTo(container);

      const colorPicker = $("<input/>").appendTo(container).kendoColorPicker({
        value: data.model[data.field],
        palette: "basic",
        tileSize: {
          width: 32,
          height: 24,
        },
        change: (e) => {
          this.$nextTick(() => {
            dummyField.val(e.value).trigger("change");
          });
        },
      }).data("kendoColorPicker");

      colorPicker?.open?.();
    },
    /**
     * @description textarea(改行可能なテキストボックス)用のkendo editor
     */
    textareaEditor(container, data) {
      $(
        `<textarea name="${data.field}" class="k-valid k-textarea" style="font-size: 1.0em;"/>`
      ).appendTo(container);
    },
    numericEditor(container, options) {
      const format = options.format.slice(3, options.format.length - 1);
      const decimals = format.slice(1);
      $('<input data-bind="value:' + options.field + '"/>')
        .appendTo(container)
        .kendoNumericTextBox({ format, decimals, round: false });
    },
    // マスタ一覧のデータを取得
    findList() {
      this.isInitialLoadComplete = false;
      // apiをコールして値を取得
      this.findRecordListByFacilityCd(this.facilitylistValue)
        .then((response) => {
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
              },
            });
          }

          // editableをKendoUI用にfunctionオブジェクトに変換
          const toFunction = response.data.columns;
          toFunction.forEach((column) => {
            // 初期表示時の編集可否を退避
            column.originalEditable = column.editable;
            // 編集可否を関数化
            column.editable = column.editable ? () => true : () => false;
            // 列幅初期化
            column["width"] = column.width ? column.width : "0";
            if (column.field == "templateCd"){
              this.reportlist.forEach(item => {
                column.values.push(item)
              }
              )
            }
          });
          this.columns = toFunction;

          // 横スクロールバーを表示するために列幅を指定
          this.columns.forEach((column) => {
            // 「削除」のプルダウンが改行しない幅に調整
            // mod #7289-マスタの削除ボタンが縦表示になる 徐博 start
            // column.width = column.field === "isDisp" ? "8em" : this.columnWidth + "em";
            column.width = column.field === "isDisp" ? "9em" : this.columnWidth + "em";
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
            values: null,
          });
          // カラム幅等初期調整
          this.showSortColumn();
          // templateCd の a 前缀等を正規化してから快照（sys-medicine / MasterRecordComponent と同じ順序）
          this.normalizePatEventSubCategoryStoreData();
          // 手技マスタと同様、API取得直後に1回だけ日付をgrid表示用Dateへ変換する
          this.convertPatEventSubCategoryDatesForGrid(this.getFilteredMasterRecordList?.data);
          this.setComparisonRecordModel();
          this.directGridSortEditedCodes.clear();
          this.isInitialLoadComplete = true;
          this.$nextTick(() => {
            this.calculateGridHeight();
            this.calculateGridWidth();
            this.initDirectGridIfReady();
            this.refreshDirectGridDataFromMasterRecords();
            this.scheduleDirectGridLayoutContract();
            /* add スクロールの位置を維持 楊 start */
            const savedScrollTop = this.scrollPosition.top ?? this.lastScrollTop ?? 0;
            const savedScrollLeft = this.scrollPosition.left ?? this.lastScrollLeft ?? 0;
            const restoreSavedScroll = () => {
              this.setGridScrollPosition({ top: savedScrollTop, left: savedScrollLeft });
            };
            restoreSavedScroll();
            this.$nextTick(() => {
              restoreSavedScroll();
              requestAnimationFrame(() => {
                restoreSavedScroll();
                this.preserveGridScrollAfterSave = false;
              });
            });
            setTimeout(() => {
              this.lastScrollTop = 0;
              this.lastScrollLeft = 0;
            }, 1000);
            /* add スクロールの位置を維持 楊 end */
          });
          // 色カラムのテンプレート生成
          this.columns
            .filter((column) => column.dataType === "color")
            .forEach((column) => {
              column.colorTemplate = (dataItem) => {
                const value = dataItem[`${column.field}`];
                return `<div style='background-color: ${value}; width: 4em;'>&nbsp;</div>`;
              };
            });
        })
        .catch((error) => {
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
          getErrorMessage('MstPatEventSubCategoryMainComponent.vue', 'findList', '指定されたマスタが見つかりません。');
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
      // カラム定義情報を取得
      this.findColumnInfo();
    },
    setFilterCondition(condition) {
      this.condition.recordName = condition.recordName;
      this.condition.includeDeleted = condition.includeDeleted;
    },
    async saveRecord() {
      if (this.saveRecordInProgress || !this.isInitialLoadComplete || !this.isChanged) {
        return;
      }
      this.saveRecordInProgress = true;
      // 共通ローダー:表示開始
      this.setLoadingScreenVisible(true);
      /* add スクロールの位置を維持 楊 start */
      this.storeDirectGridScrollPosition();
      this.preserveGridScrollAfterSave = true;
      /* add スクロールの位置を維持 楊 end */
      try {
        this.directGridWidget?.closeCell?.();
      } catch (_error) {
        // noop
      }
      this.syncDirectGridSortValuesToMasterRecords();
      // グリッドでエラーが発生している場合は処理を中断
      if (!this.validateBeforeGridAction()) {
        this.scheduleValidationTooltipPlacement();
        // 共通ローダー：表示終了
        this.setLoadingScreenVisible(false);
        this.saveRecordInProgress = false;
        this.preserveGridScrollAfterSave = false;
        this.restoreDirectGridScrollPosition();
        return;
      }

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
      this.getMasterRecordList.data.forEach(e=> {
        if (e.useType == "3" && e.templateCd.toString().indexOf('a') >= 0)
          e.templateCd = e.templateCd.replace("a","");
      });
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
          message + messageFormat(DIALOG_MESSAGES[12000006].message) + validateComboMessage;
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
      }
      // エラーメッセージは左寄せで表示
      if (message.length !== 0) {
        //共通ローダー：表示終了
        this.setLoadingScreenVisible(false);
        this.preserveGridScrollAfterSave = false;
        this.restoreDirectGridScrollPosition();
        try {
          await this.$ons.notification.alert({
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
            // title: "チェックエラー",
            title: DIALOG_MESSAGES[12000006].title,
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
            message: '<div style="text-align:left;">' + message + "</div>",
          });
        } finally {
          this.saveRecordInProgress = false;
        }
        return;
      }

      // apiをコールして値を保存
      this.formatPatEventSubCategoryDatesForSave();
      this.updateRecordListByFacilityCd({
        facilityCd: this.facilitylistValue,
        request: this.getUpdateRecordList,
      })
        .then((response) => {
          this.updateResponse = response.data;

          if (this.masterPhysicalName === "mst_exam_item") {
            this.masterSynchroOrder();
          } else {
            this.$ons.notification.alert({
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // title: "更新完了",
              // message: "マスタ更新が完了しました。"
              title: DIALOG_MESSAGES[12000004].title,
              message: messageFormat(DIALOG_MESSAGES[12000004].message),
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
            });
          }

          const facilityCds = this.getMasterRecordList.data
            .map((currentVal) => currentVal.destinationFacilityCd)
            .filter((currentVal, index, self) => {
              return self.indexOf(currentVal) === index;
            });

          this.findList();
          if (this.masterPhysicalName === "mst_alarm_notification") {
            this.masterSynchro(facilityCds);
          }
        })
        .catch((error) => {
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
          getErrorMessage('MstPatEventSubCategoryMainComponent.vue', 'saveRecord', error);
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
          this.preserveGridScrollAfterSave = false;
          this.restoreDirectGridScrollPosition();
          if (error.response.status === 400) {
            this.$ons.notification.alert({
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // title: "更新失敗",
              title: DIALOG_MESSAGES["00300005"].title,
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
              message: error.response.data.errorMessage,
            });
          }
        })
        // 共通ローダー：表示終了
        .finally(() => {
          this.setLoadingScreenVisible(false);
          this.saveRecordInProgress = false;
        });
    },
    masterSynchro(facilityCds) {
      facilityCds.forEach(async (facilityCd) => {
        await this.startMstSynchro({
          mstTable: this.mstSynchroApiParams.mstTable,
          facilityCd: facilityCd,
          deviceEdgeNo: this.mstSynchroApiParams.deviceEdgeNo,
        });
      });
    },
    // マスタ同期
    masterSynchroOrder() {
      this.setLoadingScreenVisible(true);
      this.getDeviceEdgeNoList().then((res) => {
        let array = res.data;
        if (array && array.length > 0) {
          array = array.sort((r) => r.deviceEdgeNo);
          this.synchroMstToDeviceEdge(array, 0);
        }
      });
    },
    // 指定したデバイスエッジとのマスタ同期
    synchroMstToDeviceEdge(list, idx) {
      // mod #6107 2023/04/04 メッセージボックス全調整 林峻峰 start
      // let title = `${this.getLogicalMasterName}同期`;
      let title = messageFormat(DIALOG_MESSAGES['00100009'].title, this.getLogicalMasterName);
      // mod #6107 2023/04/04 メッセージボックス全調整 林峻峰 end
      const infos = list;
      if (infos.length <= idx) {
        return;
      }
      const info = infos[idx];
      const name = "デバイスエッジ：" + info.deviceName + "</br></br>";

      // マスタ同期
      this.mstSyncDeviceEdge({
        facilityCd: null,
        deviceEdgeNo: info.deviceEdgeNo,
      })
        .then(() => {
          if (infos.length === idx + 1) {
            // 共通ローダー：表示終了
            this.setLoadingScreenVisible(false);
            this.$ons.notification.alert({
              title: title,
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // message: "マスタ同期が完了しました。"
              message: messageFormat(DIALOG_MESSAGES['00100009'].message),
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
            });
          } else {
            // 次のデバイスエッジ
            this.synchroMstToDeviceEdge(list, idx + 1);
          }
        })
        .catch((error) => {
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
          getErrorMessage('MstPatEventSubCategoryMainComponent.vue', 'synchroMstToDeviceEdge', name +'との同期に失敗しました。デバイスエッジの装置と整合性が取れていないので再度「保存」を行ってください。');
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
          this.setLoadingScreenVisible(false);
          if (error.response.status === 400) {
            // 共通ローダー：表示終了
            this.$ons.notification.alert({
              title: title,
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // message:
              //   name +
              //   "との同期に失敗しました。<br>デバイスエッジの装置と整合性が<br>取れていないので<br>再度「保存」を行ってください。"
              message: messageFormat(DIALOG_MESSAGES[12000320].message, name),
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
            });
            return;
          }
        });
    },
    addRow() {
      try {
        this.directGridWidget?.closeCell?.();
      } catch (_error) {
        // noop
      }
      this.syncDirectGridSortValuesToMasterRecords();
      // グリッドでエラーが発生している場合は処理を中断
      if (!this.validateBeforeGridAction()) {
        this.scheduleValidationTooltipPlacement();
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
          d[k] = 0;
        } else if (fields[k].type === "date") {
          d[k] = new Date();
        } else if (fields[k].type === "color") {
          d[k] = "#000000";
        } else {
          d[k] = null;
        }

        // 初期時、新しいレコードに全レコードの並び順の最大値をセット
        if (k === "sortRank") {
          d[k] = this.getMaxSortRank() + 1;
        }
      });
      // add #7300-マスタ新規追加時に利用開始日/使用開始日/使用終了日にデフォルト値が入る 徐博 start
      if (this.masterPhysicalName === "mst_pat_event_sub_category") {
        d.inHospAStartdate = ""
        d.inHospBStartdate = ""
      }
      // add #7300-マスタ新規追加時に利用開始日/使用開始日/使用終了日にデフォルト値が入る 徐博 end
      this.lastScrollLeft = 0;
      this.scrollPosition.left = 0;
      this.edit({ editRecord: d, isSortMode: this.isSortMode });
      this.refreshDirectGridDataFromMasterRecords(true);
      this.$nextTick(() => {
        const content = this.getDirectGridScrollContent();
        if (content) {
          const top = Math.max(0, content.scrollHeight - content.clientHeight);
          this.setGridScrollPosition({ top, left: 0 });
        }
        this.editBackgroundColor();
        requestAnimationFrame(() => {
          const gridContent = this.getDirectGridScrollContent();
          if (gridContent) {
            const top = Math.max(0, gridContent.scrollHeight - gridContent.clientHeight);
            this.setGridScrollPosition({ top, left: 0 });
          }
        });
      });
    },
  },
  async created() {
    this.setLoadingScreenVisible(true);
    this.facilityHemoDialysis = this.getAdvancedSettings.func_advcds.some(
      (setting) => setting.func_advcd === ADVANCED_SETTINGS.HOME_DIALYSIS
    );
    await Promise.all([
      // mod #12326 【因島】帳票マスタの「非表示」設定が意図せぬ動作をしている sunsy start
      // ApiHelper.get("/report/getMstReportByFacilityCd/" + this.getFacilitySwitch).then(response => {
      ApiHelper.get("/report/getMstReportByFacilityCdNoIsDisp/" + this.getFacilitySwitch).then(response => {
      // mod #12326 【因島】帳票マスタの「非表示」設定が意図せぬ動作をしている sunsy end
        if(response.data) {
          response.data.forEach(element => {
            // mod #12326 【因島】帳票マスタの「非表示」設定が意図せぬ動作をしている sunsy start
            // if (element.isDisp == "1" && element.reportClass == 9)
            if (element.reportClass == 9)
            // mod #12326 【因島】帳票マスタの「非表示」設定が意図せぬ動作をしている sunsy end
            this.reportlist.push({
                value: "a"+element.reportCd,
                text: element.reportName,
                isReport:true
              });
          });
        }
      })
    ])
    .catch(error => {
      //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
      getErrorMessage('MstPatEventSubCategoryMainComponent.vue', 'created', error);
      //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
      throw error;
    });
    // apiをコールして施設一覧を取得
    this.findFacilityList();
    this.calculateColumnsWidth();
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
  },
  // add 性能改善メモリ不足 shan start
  beforeUnmount() {
    EventBus.$off("onCloseMasterEditModal", this.onCloseMasterEditModal);
    EventBus.$off("refresh", this.refresh);
    this.teardownValidationTooltipPlacement();
    this.destroyKendoValidator();
    this.destroyDirectGrid();
    [
      this.directGridLayoutRafId,
      this.directGridScrollSyncRafId,
      this.directGridFilterRefreshRafId
    ].forEach(id => {
      if (id != null) {
        cancelAnimationFrame(id);
      }
    });
    this.directGridRowVisualRafIds?.forEach?.(id => cancelAnimationFrame(id));
    this.directGridRowVisualRafIds?.clear?.();
    this.directGridEditedFieldsByCode?.clear?.();
  },
  // add 性能改善メモリ不足 shan end
};
</script>

<!-- 個別スタイル定義 -->
<style lang="scss" scoped>
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
  font-size: 1em;
  padding: 0.2em 1em 0em 1em;
  line-height: 2em;
  width: auto;
}
.csv-btn {
  margin-right: 1em;
}
.kendo-grid-toolbar-style {
  padding: 0.1em 0.3em;
}
.kendo-grid-toolbar-style :deep(.k-tooltip.k-tooltip-validation) {
  width: auto;
}

/* fix 2026/06/02 バリデーション tooltip 位置調整 MasterRecordComponent 同等 start */
.kendo-grid-toolbar-style :deep(.k-edit-cell) {
  position: relative;
  overflow: visible;
}
.kendo-grid-toolbar-style :deep(.k-edit-cell > .k-invalid-msg:not(.k-hidden)),
.kendo-grid-toolbar-style :deep(.k-edit-cell > .k-form-error:not(.k-hidden)),
.kendo-grid-toolbar-style :deep(.k-edit-cell > .k-validator-tooltip:not(.k-hidden)),
.kendo-grid-toolbar-style :deep(.k-edit-cell > .k-tooltip-error:not(.k-hidden)),
.mst-pat-event-sub-category-direct-jq-grid :deep(.k-edit-cell > .k-invalid-msg:not(.k-hidden)),
.mst-pat-event-sub-category-direct-jq-grid :deep(.k-edit-cell > .k-tooltip-error:not(.k-hidden)),
.mst-pat-event-sub-category-direct-jq-grid :deep(.k-edit-cell > .k-validator-tooltip:not(.k-hidden)),
.mst-pat-event-sub-category-direct-jq-grid :deep(.k-edit-cell > .k-tooltip.k-tooltip-validation:not(.k-hidden)) {
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

/* DropDownList 内 tooltip は JS でセル直下へ移すため、widget 内の duplicate は非表示 */
.mst-pat-event-sub-category-direct-jq-grid :deep(.k-edit-cell .k-dropdownlist .k-invalid-msg),
.mst-pat-event-sub-category-direct-jq-grid :deep(.k-edit-cell .k-dropdownlist .k-tooltip-validation),
.mst-pat-event-sub-category-direct-jq-grid :deep(.k-edit-cell .k-dropdown .k-invalid-msg),
.mst-pat-event-sub-category-direct-jq-grid :deep(.k-edit-cell .k-dropdown .k-tooltip-validation),
.mst-pat-event-sub-category-direct-jq-grid :deep(.k-edit-cell .k-picker .k-invalid-msg),
.mst-pat-event-sub-category-direct-jq-grid :deep(.k-edit-cell .k-picker .k-tooltip-validation),
.mst-pat-event-sub-category-direct-jq-grid :deep(.k-edit-cell .k-legacy-dropdownlist .k-invalid-msg),
.mst-pat-event-sub-category-direct-jq-grid :deep(.k-edit-cell .k-legacy-dropdownlist .k-tooltip-validation) {
  display: none !important;
}

.mst-pat-event-sub-category-direct-jq-grid :deep(.k-edit-cell .k-dropdownlist),
.mst-pat-event-sub-category-direct-jq-grid :deep(.k-edit-cell .k-picker),
.mst-pat-event-sub-category-direct-jq-grid :deep(.k-edit-cell .k-legacy-dropdownlist) {
  position: relative;
  z-index: 1;
}

.kendo-grid-toolbar-style :deep(.k-edit-cell .k-tooltip-content) {
  font-family: inherit !important;
  font-size: inherit !important;
  font-weight: normal !important;
  line-height: 1.4 !important;
}

/* JS ntss-validation-above：スクロール領域下端で tooltip をセル上に表示 */
.kendo-grid-toolbar-style :deep(td.k-edit-cell.ntss-validation-above > .k-invalid-msg),
.kendo-grid-toolbar-style :deep(td.k-edit-cell.ntss-validation-above .k-invalid-msg.k-tooltip-error),
.kendo-grid-toolbar-style :deep(td.k-edit-cell.ntss-validation-above .k-tooltip.k-tooltip-error),
.kendo-grid-toolbar-style :deep(td.k-edit-cell.ntss-validation-above .k-tooltip.k-tooltip-validation),
.kendo-grid-toolbar-style :deep(td.k-edit-cell.ntss-validation-above .k-validator-tooltip),
.mst-pat-event-sub-category-direct-jq-grid :deep(td.k-edit-cell.ntss-validation-above > .k-invalid-msg),
.mst-pat-event-sub-category-direct-jq-grid :deep(td.k-edit-cell.ntss-validation-above .k-invalid-msg.k-tooltip-error),
.mst-pat-event-sub-category-direct-jq-grid :deep(td.k-edit-cell.ntss-validation-above .k-tooltip.k-tooltip-error),
.mst-pat-event-sub-category-direct-jq-grid :deep(td.k-edit-cell.ntss-validation-above .k-tooltip.k-tooltip-validation),
.mst-pat-event-sub-category-direct-jq-grid :deep(td.k-edit-cell.ntss-validation-above .k-validator-tooltip),
.mst-pat-event-sub-category-direct-jq-grid :deep(.k-grid-content-locked tbody > tr:nth-last-child(-n + 2) td.k-edit-cell > .k-invalid-msg),
.mst-pat-event-sub-category-direct-jq-grid :deep(.k-grid-content-locked tbody > tr:nth-last-child(-n + 2) td.k-edit-cell .k-tooltip.k-tooltip-error) {
  position: absolute !important;
  left: 0 !important;
  bottom: 39px !important;
  top: auto !important;
  overflow: visible !important;
  padding: 9px 15px !important;
  align-items: center;
  margin: 0.5em;
}

.kendo-grid-toolbar-style :deep(td.k-edit-cell.ntss-validation-above .k-callout.k-callout-s),
.mst-pat-event-sub-category-direct-jq-grid :deep(td.k-edit-cell.ntss-validation-above .k-callout.k-callout-s),
.mst-pat-event-sub-category-direct-jq-grid :deep(.k-grid-content tbody > tr:nth-last-child(-n + 2) td.k-edit-cell .k-callout.k-callout-n) {
  top: auto !important;
  bottom: calc(-12px) !important;
  border-bottom-color: transparent !important;
  border-block-start-color: #000000 !important;
}
/* fix 2026/06/02 バリデーション tooltip 位置調整 MasterRecordComponent 同等 end */

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
.custom-switch {
  transform: scale(0.85);
  transform-origin: center;
  touch-action: manipulation;
}
.mobile-header {
  min-height: 30px; /* モバイル用の高さ */
}

.mst-pat-event-sub-category-direct-jq-grid {
  width: 100%;
}

/* MasterRecordComponent と同様、編集セル (.k-edit-cell) は overflow を壊さない */
.kendo-grid-toolbar-style :deep(.k-grid-content td:not(.k-edit-cell)),
.kendo-grid-toolbar-style :deep(.k-grid-content .k-table-td:not(.k-edit-cell)),
.kendo-grid-toolbar-style :deep(.k-grid-content-locked td:not(.k-edit-cell)),
.kendo-grid-toolbar-style :deep(.k-grid-content-locked .k-table-td:not(.k-edit-cell)) {
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.mst-pat-event-sub-category-direct-jq-grid :deep(td.master-sort-edited),
.mst-pat-event-sub-category-direct-jq-grid :deep(tr.k-selected > td.master-sort-edited),
.mst-pat-event-sub-category-direct-jq-grid :deep(tr.k-state-selected > td.master-sort-edited),
.mst-pat-event-sub-category-direct-jq-grid :deep(tr.k-table-row.k-selected > td.master-sort-edited) {
  background-color: #ffff66 !important;
}
.mst-pat-event-sub-category-direct-jq-grid :deep(td.k-dirty-cell) {
  font-weight: bold;
}
.mst-pat-event-sub-category-direct-jq-grid :deep(.direct-date-editor-wrap) {
  display: inline-block;
  position: relative;
  line-height: 1;
}
.mst-pat-event-sub-category-direct-jq-grid :deep(.direct-date-clear) {
  align-items: center;
  color: #212529;
  display: inline-flex;
  height: 1em;
  justify-content: center;
  left: 75%;
  line-height: 1;
  position: absolute;
  top: 50%;
  transform: translateY(-50%);
  width: 1em;
  z-index: 9999999;
}
.mst-pat-event-sub-category-direct-jq-grid :deep(tr.master-edited-row > td),
.mst-pat-event-sub-category-direct-jq-grid :deep(tr.master-edited-row > .k-table-td),
.mst-pat-event-sub-category-direct-jq-grid :deep(.k-table-row.master-edited-row > td),
.mst-pat-event-sub-category-direct-jq-grid :deep(.k-table-row.master-edited-row > .k-table-td),
.mst-pat-event-sub-category-direct-jq-grid :deep(td.master-edited-row),
.mst-pat-event-sub-category-direct-jq-grid :deep(.k-table-td.master-edited-row),
.mst-pat-event-sub-category-direct-jq-grid :deep(td.master-edited-cell),
.mst-pat-event-sub-category-direct-jq-grid :deep(.k-table-td.master-edited-cell) {
  border-color: var(--master-maintenance-kgrid-border-color, var(--ntss-list-border-color)) !important;
  border-style: solid !important;
  border-width: 0 0 1px 1px !important;
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
