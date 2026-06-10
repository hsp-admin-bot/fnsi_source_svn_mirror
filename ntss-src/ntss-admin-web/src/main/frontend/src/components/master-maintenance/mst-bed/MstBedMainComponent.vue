/**
 * ベッドマスタメンテナンスデータページ  MainContent
 */
<template>
  <div class="main-content-area master-maintenance-page">
    <div class='ntss-list' :style="ntssListStyles" v-kendo-validator="kendoValidatorSetup">
      <kendo-grid-toolbar class="k-grid-toolbar kendo-grid-toolbar-style" :style="heightStyles">
        <div id="grid-header" :class="['header-btn-area', 'right', isMobileDevice ? 'mobile-header' : '']">
          <v-ons-button v-show="!isSortMode && isAllowAddRecord" style="float: left;" class="btn3-normal toolbar-btn" @click="addRow()">追加</v-ons-button>
          <v-ons-row v-show="isMobileDevice" style="float: left; width: 6em; height: 1em;">
            <v-ons-col width="45%" vertical-align="center">
              <label class="fab-font-color">編集</label>
            </v-ons-col>
            <v-ons-col width="55%" vertical-align="center">
              <v-ons-switch modifier="outline" class="custom-switch" style="float: left; margin-left: 2px;" v-model="allowEdit" />
            </v-ons-col>
          </v-ons-row>
          <!-- del マスタ一覧 1･施設切替を可能とする 孔 start -->
          <!--<kendo-dropdownlist ref="dropDownList" v-if="isMasterUser"
                    v-model="facilitylistValue"
                    :data-source="facilities"
                    :data-text-field="'facilityName'"
                    :data-value-field="'facilityCd'"
                    :filter="'contains'"
                    @open="onOpenFacility"
                    @change="onChangeFacility"
                    style="width: 13em;">
          </kendo-dropdownlist>-->
          <!-- del マスタ一覧 1･施設切替を可能とする 孔 end -->
          <v-ons-button modifier="outline" class="btn3-normal toolbar-btn csv-btn" style="margin-right: 10px;" v-show="!isSortMode && isAllowSort" @click="importCsv()">CSV取込</v-ons-button>
          <v-ons-button v-show="!isSortMode && isAllowSort" class="btn3-normal toolbar-btn" @click="toRankEditBtnClick()">並び順表示</v-ons-button>
          <v-ons-button v-show="isSortMode && isAllowSort" class="btn3-normal toolbar-btn" @click="sortBtnClick()">反映</v-ons-button>
        </div>
        <!-- ソート後グリッド表示 -->
          <kendo-grid :class="fontSizeSet"
          id="grid-font-size"
          ref="grid"
          :data-source="masterRecords"
          :editable="true"
          :selectable="true"
          :reorderable="false"
          :height="kendoGridHeight"
          :scrollable="true"
          :beforeEdit=modifyEditStart
          :cellClose=editEnd
          @save="onSave"
          @databound="onDataBoundKendoGrid">
          <template v-for="(column, index) in columns">
            <!-- 編集モーダル列 -->
            <kendo-grid-column
              v-if="column.field === '$modalType'"
              :key="index"
              :title="column.title"
              :field="column.field"
              :hidden="column.hidden"
              :attributes="{ class: 'btn3-kendo-normal' }"
              :editable="column.editable"
              :width="column.width"
              :format="column.format"
              :values="column.values"
              :command="{ text: '詳細', click: showMasterEditModal }"
            />
            <!-- 在宅フラグは削除する  Du -->
            <!-- <kendo-grid-column
              v-else-if="column.title === '在宅'"
              :key="index"
              :title="column.title"
              :field="column.field"
              :hidden="! facilityHemoDialysis"
              :editable="column.editable"
              :width="column.width"
              :format="column.format"
              :values="column.values"
            /> -->
            <kendo-grid-column
                v-else-if="column.title === '連携コード1'"
                :key="index"
                :title="column.title"
                :field="column.field"
                :hidden="column.hidden"
                :editable="column.editable"
                :width="column.width"
                :format="column.format"
                :values="column.values">
            </kendo-grid-column>
            <kendo-grid-column
                v-else-if="column.title === '連携コード2'"
                :key="index"
                :title="column.title"
                :field="column.field"
                :hidden="column.hidden"
                :editable="column.editable"
                :width="column.width"
                :format="column.format"
                :values="column.values">
            </kendo-grid-column>
            <!-- add/ #12696 ベッドマスタ画面で不正2件 tianqidong start -->
            <kendo-grid-column
              v-else-if="column.field === 'machineNo'"
              :key="`machineNo-${index}`"
              :title="column.title"
              :field="column.field"
              :hidden="column.hidden"
              :locked="column.locked"
              :editable="column.editable"
              :width="column.width"
              :format="column.format"
              :values="column.values"
              :editor="machineNoEditor"
            />
            <!-- add/ #12696 ベッドマスタ画面で不正2件 tianqidong end -->
            <kendo-grid-column
              v-else
              :key="index"
              :title="column.title"
              :field="column.field"
              :hidden="column.hidden"
              :locked="column.locked"
              :editable="column.editable"
              :width="column.width"
              :format="column.format"
              :values="column.values"
            />
          </template>
        </kendo-grid>
      </kendo-grid-toolbar>
      <div id="grid-footer">
        <v-ons-row v-show="!isSortMode" width="100%">
          <v-ons-col width="50%">
            <v-ons-button class="btn2-cancel denial-btn" style="width: auto;" @click="cancel">キャンセル</v-ons-button>
          </v-ons-col>
          <v-ons-col width="50%" class="right">
            <v-ons-button class="btn1-execute registration-btn" style="width: auto;" :disabled="!isChanged" @click="saveRecord">保存</v-ons-button>
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
import $ from "jquery";
import { mapActions, mapGetters } from "vuex";
import NextTransitionMixin from "@/components/NextTransitionMixin";
import MasterMaintenanceMixin from "@/components/master-maintenance/MasterMaintenanceMixin";
import { EventBus } from "@/eventBus.js";
import { Validator } from "@progress/kendo-validator-vue-wrapper";
import { ApiHelper } from "@/apis/AxiosHelper";
// 在宅フラグは削除する  Du
//import { ADVANCED_SETTINGS } from "@/constants/advancedSettings";
import { sendRequestGetMstFacilityHashByFacilityCd } from "@/apis/mst-facility-hash";
import MasterCsvComponent from "@/components/master-maintenance/MasterCsvComponent";
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages.js";
//FNSI-修正 VUEのエラー場合のログ対応 liuimx add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 liuimx add end
import { sendRequestFindRecordList,sendRequestUpdateRecordListByFacilityCd } from "@/apis/master-maintenance";
import { sendRequestGetMachineType } from "@/apis/mst-bedLayout";
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
/**
 * TODO
 * more: モーダルで編集した項目が、一覧上で「編集済み（三角マーク）」をつけたい。
 */
export default {
  mixins: [NextTransitionMixin, MasterMaintenanceMixin],
  Validator,
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
      columnWidth: 14,
      kendoValidatorSetup: {
        rules: {},
        messages: {}
      },
      // 編集失敗時のマスタ/列/スキーマ情報のバックアップ
      backupMasterRecordList: [],
      //Android端末で編集中であることを示すフラグ
      editingFlg: false,
      androidFlg: false,
      iosFlg: false,
      scrollPosition: {
        top: 0,
        left: 0
      },
      exclusionListNo: "",
      mstMachine: [],
      // 選択中の施設コード
      facilitylistValue: "",
      // 選択中施設の在宅機能有無
      // 在宅フラグは削除する  Du
      //facilityHemoDialysis: false,
      //変更前の施設
      prevFacilityCd: "",
      //ベッドマスタ タイトルはハイパーリンクではありません start
      //自画面の名称
      selfScreenName: "",
      // ベッドマスタ タイトルはハイパーリンクではありません end
      //選択施設のシステム利用設定
      facilitySysUseSetting: "",
      lastScrollTop: 0,
      lastScrollLeft: 0,
      masterCsvVisible: false,
      masterCsvTarget: null,
      //add #9009 ベッドマスタにおいて治療中のベッドに対して編集可能 張 start
      lockbedList: null,
      //add #9009 ベッドマスタにおいて治療中のベッドに対して編集可能 張 end
      allowEdit: true, // NOTE: true = 編集モード、 false = 閲覧モード
      //add #9594 ベッドマスタでプリンター及び自動印刷の設定を変更し、保存しようとするとメッセージが表示され保存できない zrx start
      dbBeforeData: [],
      bedEditVisualRafId: null,
      //add #9594 ベッドマスタでプリンター及び自動印刷の設定を変更し、保存しようとするとメッセージが表示され保存できない zrx end
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
      comparisonRecordModel: "getComparisonRecordModel",
      editRecord: "getEditRecord",
      isEdited: "isEdited",
      hasValueColumn: "hasValueColumn",
      getFacilitySwitch: "getFacilitySwitch"
    }),
    ...mapGetters("mst-bed", {
      getFacilityList: "getFacilityList"
    }),
    ...mapGetters("user", ["getAdvancedSettings"]),

    heightStyles() {
      // main部の高さをCSS変数を利用して書き換え
      return { "--height": `${this.kendoGridToolbarHeight}px` };
    },
    ntssListStyles() {
      return { display: this.columns.length === 1 ? "none" : "inherit" };
    },
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
      const originalData = this.dbBeforeData || [];
      const hasChanged = this.hasBedChanges(data, originalData);
      return (
        this.getStateUserAccountInfo !== null &&
        data !== undefined &&
        (hasChanged || this.isSorted)
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
      set() {}
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
    },
    windowWidth() {
      this.calculateColumnsWidth();
      this.calculateGridHeight();
      this.calculateGridWidth();
    },
    isDispMenu() {
      this.calculateColumnsWidth();
      this.calculateGridHeight();
      this.calculateGridWidth();
    },
    getFontSize() {
      this.calculateColumnsWidth();
      this.calculateGridHeight();
      this.calculateGridWidth();
    },
    columns:function(val){
      this.$nextTick(function(){
        if (val.length > 1)
        this.setLoadingScreenVisible(false);
      });
    }
  },

  async created() {
    this.setLoadingScreenVisible(true);
    this.calculateColumnsWidth();
    // 在宅フラグは削除する  Du
    // this.facilityHemoDialysis = this.getAdvancedSettings.func_advcds.some(
    //   setting => setting.func_advcd === ADVANCED_SETTINGS.HOME_DIALYSIS
    // );
    this.setCondition(this.condition);
    // mod マスタ一覧 1･施設切替を可能とする 孔 start
    // this.findFacilityList();
    this.facilitylistValue = this.getFacilitySwitch;
    this.findList();
    // mod マスタ一覧 1･施設切替を可能とする 孔 end

    // 共通ローダー:表示名設定
    this.setLoadingScreenMessage("処理中・・・");
    // 端末判別
    const ua = navigator.userAgent.toLowerCase();
    if (/android/.test(ua)) {
      this.androidFlg = true;
    } else if (/iphone|ipad|mac|os/.test(ua)) {
      this.iosFlg = true;
    }
    const [mstMachine] = await Promise.all([
      // mod マスタ一覧 1･施設切替を可能とする 孔s start
      // ApiHelper.get(`/bed_layout/mst_machine/${this.facilityCd}`),
      // Mst.mstPrinterSelector(this.facilityCd)
      ApiHelper.get(`/bed_layout/mst_machine/${this.getFacilitySwitch}`),
      // mod マスタ一覧 1･施設切替を可能とする 孔s end
    ]).catch((error) => {
      //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
      getErrorMessage('MstBedModal.vue', 'created', error);
      //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
      // console.log(error);
    });
    this.mstMachine = mstMachine.data;
    // 除外リスト取得
    if (this.mstMachine)
    this.exclusionListNo = this.mstMachine.filter(mst => {
      const formatCd = mst.comFormatCd;
      const formatCdType = mst.comType;
      return formatCdType == "2" && (formatCd === "A" || formatCd === "D" || formatCd === "R" || formatCd === "I" || formatCd === "J");
    }).map(mst =>String(mst.machineNo));
    // ベッドマスタ タイトルはハイパーリンクではありません start
    this.selfScreenName = this.$router.currentRoute.name;
    EventBus.$on("refresh", this.refresh);
    // ベッドマスタ タイトルはハイパーリンクではありません end
    EventBus.$on("onCloseMasterEditModal", this.onCloseMasterEditModal);
    //add #9009 ベッドマスタにおいて治療中のベッドに対して編集可能 張 start
    ApiHelper.get(`/mstInfo/selectBedListByFacilityCd/${this.getFacilitySwitch}`).then(res=>{this.lockbedList = res.data});
    //add #9009 ベッドマスタにおいて治療中のベッドに対して編集可能 張 end
    },
  // add 性能改善メモリ不足 shan start
  beforeDestroy() {
    if (this.bedEditVisualRafId != null) {
      cancelAnimationFrame(this.bedEditVisualRafId);
      this.bedEditVisualRafId = null;
    }
    EventBus.$off("refresh", this.refresh);
    EventBus.$off("onCloseMasterEditModal", this.onCloseMasterEditModal);
    EventBus.$off("clearScrollPosition", this.clearScrollPosition);
  },
  // add 性能改善メモリ不足 shan end
  mounted() {
    this.$nextTick(() => {
      this.calculateColumnsWidth();
      this.calculateGridHeight();
      this.calculateGridWidth();
    });
    EventBus.$on("clearScrollPosition", this.clearScrollPosition);
  },

  updated() {
    // editBackgroundColor は k-dirty-cell があると緑背景を付け直す。
    // Vue 再描画のたびに先に「スナップショットと同じ行」の Kendo 残留 dirty を剥がしてから配色する。
    // requestAnimationFrame で同一フレーム内の連続 updated をまとめる（sync が再度 updated を誘発するため）。
    // セル編集後は列幅・高さの再計算が必要。calculate 後にスクロールを戻さないと位置・見た目がずれる。
    if (this.bedEditVisualRafId != null) {
      cancelAnimationFrame(this.bedEditVisualRafId);
    }
    this.bedEditVisualRafId = requestAnimationFrame(() => {
      this.bedEditVisualRafId = null;
      this.$nextTick(() => {
        // refresh 直後にここで DOM から scroll を読むと 0 になり、scrollPosition を潰して先頭固定になるため読まない
        if (this.dbBeforeData?.length && this.$refs.grid) {
          this.syncBedUnchangedRowsFromDb();
          this.stripBedDomForSnapshotUnchangedRows();
        }
        this.editBackgroundColor();
        this.$nextTick(() => {
          this.calculateColumnsWidth();
          this.calculateGridHeight();
          this.calculateGridWidth();
          this.$nextTick(() => {
            this.restoreBedGridScroll();
          });
        });
      });
    });
  },

  methods: {
    ...mapActions("multi-modal", [
      "showMasterEdit"
    ]),
    ...mapActions("master-maintenance", [
      "findRecordListByFacilityCd",
      "setMasterRecordList",
      "edit",
      "setComparisonRecordModel",
      "findColumnInfo",
      "setCondition",
      "updateRecordListByFacilityCd",
      "setEditRecord",
      "editRecordBeEmpty"
    ]),
    ...mapActions("mst-status-map-bed-layout", {
    }),
    // 共通ローダー設定
    ...mapActions("loading-screen", {
      setLoadingScreenVisible: "setLoadingScreenVisible",
      setLoadingScreenMessage: "setLoadingScreenMessage",
      resetLoadingScreenVisibleCount:  "resetLoadingScreenVisibleCount"
    }),
    ...mapActions("mst-bed", {
      facilityList: "facilityList"
    }),
    ...mapActions("mst-bed", [
      "setFacilitySysUseSetting"
    ]),
    normalizeBedCompareValue(value) {
      if (value === undefined || value === null || value === "" || value === "null") {
        return "";
      }
      const numericValue = Number(value);
      return Number.isNaN(numericValue) ? `${value}` : `${numericValue}`;
    },
    normalizeBedNullableString(value) {
      if (value === undefined || value === null || value === "" || value === "null") {
        return "";
      }
      return `${value}`;
    },
    normalizeBedRecord(record) {
      if (!record) {
        return record;
      }
      record.machineNo = this.normalizeBedCompareValue(record.machineNo);
      record.shuntPosition = this.normalizeBedCompareValue(record.shuntPosition);
      record.isInfection = this.normalizeBedNullableString(record.isInfection);
      record.emergencyClass = this.normalizeBedCompareValue(record.emergencyClass);
      record.outputPrinter = this.normalizeBedNullableString(record.outputPrinter);
      record.isAutoprintBefore = this.normalizeBedNullableString(record.isAutoprintBefore);
      record.isAutoprintAfter = this.normalizeBedNullableString(record.isAutoprintAfter);
      record.isAutoprintCommit = this.normalizeBedNullableString(record.isAutoprintCommit);
      record.inHospitalCd1 = this.normalizeBedNullableString(record.inHospitalCd1);
      record.inHospitalCd2 = this.normalizeBedNullableString(record.inHospitalCd2);
      return record;
    },
    normalizeBedDataSource(localDataSource) {
      const normalizedDataSource = JSON.parse(JSON.stringify(localDataSource || {}));
      if (Array.isArray(normalizedDataSource.data)) {
        normalizedDataSource.data.forEach(record => this.normalizeBedRecord(record));
      }
      return normalizedDataSource;
    },
    getBedSchemaFieldKeys() {
      const fields = this.getMasterRecordList?.schema?.model?.fields;
      if (!fields) {
        return null;
      }
      return Object.keys(fields).filter(key => key !== "$modalType");
    },
    sanitizeBedCompareRecord(record) {
      const clone = JSON.parse(JSON.stringify(record || {}));
      this.normalizeBedRecord(clone);
      const schemaKeys = this.getBedSchemaFieldKeys();
      const IGNORE = new Set([
        "$modalType",
        "_defaultId",
        "_events",
        "_handlers",
        "dirty",
        "dirtyFields",
        "edited",
        "operation",
        "parent",
        "scaleDate",
        "scaleUserId",
        "skipSearch",
        "sortInputTime",
        "uid",
        "upDate",
        "dummy"
      ]);
      const keyList = schemaKeys || Object.keys(clone).filter(key => !IGNORE.has(key));
      const result = {};
      keyList.forEach(key => {
        if (IGNORE.has(key)) {
          return;
        }
        let val = clone[key];
        if (val === "" || val === undefined || val === "[]") {
          val = null;
        }
        result[key] = val;
      });
      return result;
    },
    bedCompareScalarForCompare(v) {
      if (v === undefined || v === null || v === "" || v === "null") {
        return null;
      }
      if (typeof v === "string") {
        const t = v.trim();
        return t === "" ? null : t;
      }
      return v;
    },
    bedCompareValuesEqual(a, b) {
      const na = this.bedCompareScalarForCompare(a);
      const nb = this.bedCompareScalarForCompare(b);
      if (na == nb) {
        return true;
      }
      const aEmpty = na === null || na === undefined;
      const bEmpty = nb === null || nb === undefined;
      if (aEmpty && bEmpty) {
        return true;
      }
      if (na instanceof Date || nb instanceof Date) {
        const ta = na instanceof Date ? na.getTime() : Number.NaN;
        const tb = nb instanceof Date ? nb.getTime() : Number.NaN;
        if (!Number.isNaN(ta) && !Number.isNaN(tb)) {
          return ta === tb;
        }
      }
      const numA = Number(na);
      const numB = Number(nb);
      if (
        !Number.isNaN(numA) &&
        !Number.isNaN(numB) &&
        `${na}`.trim() !== "" &&
        `${nb}`.trim() !== ""
      ) {
        return numA === numB;
      }
      return `${na}` === `${nb}`;
    },
    toStableBedCompareRecord(record) {
      const sanitizedRecord = this.sanitizeBedCompareRecord(record);
      return Object.keys(sanitizedRecord)
        .sort()
        .reduce((acc, key) => {
          acc[key] = sanitizedRecord[key];
          return acc;
        }, {});
    },
    isSameBedRecord(currentRecord, originalRecord) {
      const sa = this.toStableBedCompareRecord(currentRecord);
      const sb = this.toStableBedCompareRecord(originalRecord);
      const keys = new Set([...Object.keys(sa), ...Object.keys(sb)]);
      for (const key of keys) {
        if (!this.bedCompareValuesEqual(sa[key], sb[key])) {
          return false;
        }
      }
      return true;
    },
    /**
     * 行が DB 読込時スナップショットと同内容のとき、Vuex/Kendo 側の編集フラグのみを落とす
     * （deleteOperation は未定義のため明示的に削除する）
     */
    clearBedRowPendingEdit(record) {
      if (!record || typeof record !== "object") {
        return;
      }
      if (typeof record.set === "function") {
        try {
          record.set("dirty", false);
          record.set("dirtyFields", {});
          record.set("operation", null);
          record.set("edited", false);
        } catch (e) {
          /* noop */
        }
        return;
      }
      if (Object.prototype.hasOwnProperty.call(record, "operation")) {
        this.$delete(record, "operation");
      }
      if (Object.prototype.hasOwnProperty.call(record, "edited")) {
        this.$delete(record, "edited");
      }
      if (Object.prototype.hasOwnProperty.call(record, "dirty")) {
        this.$delete(record, "dirty");
      }
      if (Object.prototype.hasOwnProperty.call(record, "dirtyFields")) {
        this.$delete(record, "dirtyFields");
      }
    },
    hasBedChanges(currentRecords, originalRecords) {
      if (!Array.isArray(currentRecords) || currentRecords.length !== originalRecords.length) {
        return true;
      }
      if (!Array.isArray(originalRecords) || originalRecords.length === 0) {
        return false;
      }
      const originalsByCode = new Map(
        originalRecords.map(r => [String(r.code), r])
      );
      for (let i = 0; i < currentRecords.length; i++) {
        const row = currentRecords[i];
        const orig = originalsByCode.get(String(row.code));
        if (!orig) {
          return true;
        }
        if (!this.isSameBedRecord(row, orig)) {
          return true;
        }
      }
      return false;
    },
    /**
     * 初期スナップショットと同一内容の行から operation/dirty を落とし、
     * スキーマ項目をスナップショットで上書きする（詳細モーダル開閉後の Kendo 残留対策）
     */
    syncBedUnchangedRowsFromDb() {
      const data = this.getMasterRecordList?.data;
      const originalData = this.dbBeforeData || [];
      if (!data || !originalData.length) {
        return;
      }
      const keys = this.getBedSchemaFieldKeys();
      data.forEach(currentRecord => {
        const originalRecord = originalData.find(
          item => String(item.code) === String(currentRecord.code)
        );
        if (!originalRecord || !this.isSameBedRecord(currentRecord, originalRecord)) {
          return;
        }
        this.clearBedRowPendingEdit(currentRecord);
        const snapshot = JSON.parse(JSON.stringify(originalRecord));
        this.normalizeBedRecord(snapshot);
        if (keys && keys.length > 0) {
          keys.forEach(key => {
            if (Object.prototype.hasOwnProperty.call(snapshot, key)) {
              this.$set(currentRecord, key, snapshot[key]);
            }
          });
        }
      });
    },
    /**
     * スナップショットと同内容の行から、Kendo / mixin が付けた編集表示用クラスを DOM から除去する。
     * grid.refresh は重いためここでは呼ばない（セル編集直後は refreshBedGridAfterUnchangedSync を使う）。
     */
    stripBedDomForSnapshotUnchangedRows() {
      const grid = this.$refs.grid?.kendoWidget?.();
      if (!grid) {
        return;
      }
      const originalsByCode = new Map(
        (this.dbBeforeData || []).map(r => [String(r.code), r])
      );
      const stripDirtyDomForUnchangedRow = tr => {
        if (!tr || !grid.dataItem) {
          return;
        }
        let item;
        try {
          item = grid.dataItem(tr);
        } catch (e) {
          return;
        }
        if (!item || item.code == null) {
          return;
        }
        const orig = originalsByCode.get(String(item.code));
        if (!orig || !this.isSameBedRecord(item, orig)) {
          return;
        }
        tr.querySelectorAll("td, th").forEach(cell => {
          cell.classList.remove(
            "k-dirty-cell",
            "master-edited-cell",
            "master-edited-row",
            "master-sort-edited",
            "master-deleted-combo"
          );
          cell.querySelectorAll("span.k-dirty").forEach(span => {
            span.remove();
          });
        });
        tr.classList.remove("k-dirty-row");
      };
      if (typeof grid.items === "function") {
        grid.items().each((_, row) => stripDirtyDomForUnchangedRow(row));
      }
      if (grid.lockedTable) {
        $(grid.lockedTable)
          .find("tbody tr")
          .each((_, row) => stripDirtyDomForUnchangedRow(row));
      }
      const el = this.$refs.grid?.$el;
      if (el) {
        el.querySelectorAll("td.k-dirty-cell").forEach(td => {
          const tr = td.closest("tr");
          if (tr) {
            stripDirtyDomForUnchangedRow(tr);
          }
        });
      }
    },
    /**
     * セル保存・終了直後: 未変更行の dirty DOM を剥がす（grid.refresh は列固定・幅が崩れるため使わない）。
     */
    refreshBedGridAfterUnchangedSync() {
      this.stripBedDomForSnapshotUnchangedRows();
    },
    /**
     * Kendo Grid インスタンスから実際のスクロール位置を取得（固定列ありの場合も content を基準にする）
     */
    readBedGridScrollFromGridWidget(grid) {
      if (!grid?.content?.[0]) {
        return { top: 0, left: 0 };
      }
      const c = grid.content[0];
      const top = c.scrollTop;
      const left =
        typeof grid._scrollLeft !== "undefined" && grid._scrollLeft !== null
          ? grid._scrollLeft
          : c.scrollLeft;
      return { top, left };
    },
    /**
     * 一覧グリッドのスクロールを書き戻す（content・固定列・ヘッダ連動の scrollables）
     */
    applyBedGridScrollToWidget(top, left, widgetOverride) {
      const grid = widgetOverride || this.$refs.grid?.kendoWidget?.();
      if (!grid) {
        return;
      }
      this.scrollPosition.top = top;
      this.scrollPosition.left = left;
      if (grid.content?.[0]) {
        grid.content[0].scrollTop = top;
        grid.content[0].scrollLeft = left;
      }
      if (grid.lockedContent?.[0]) {
        grid.lockedContent[0].scrollTop = top;
      }
      if (grid.scrollables && typeof grid.scrollables.each === "function") {
        grid.scrollables.each((i, el) => {
          if (!grid.content?.[0] || el !== grid.content[0]) {
            if (el && typeof el.scrollLeft === "number") {
              el.scrollLeft = left;
            }
          }
        });
      }
    },
    /**
     * calculate* や再描画の後に一覧グリッドのスクロール位置を戻す（レイアウト確定後の複数回適用で 0 に戻されるのを防ぐ）
     */
    restoreBedGridScroll() {
      const top = this.scrollPosition.top || 0;
      const left = this.scrollPosition.left || 0;
      const run = () => this.applyBedGridScrollToWidget(top, left);
      requestAnimationFrame(run);
      this.$nextTick(run);
      [0, 32, 80].forEach(ms => setTimeout(run, ms));
    },
    // ベッドマスタ タイトルはハイパーリンクではありません start
    loadGridData() {
      // delete start #9590
      // this.setCondition(this.condition);
      // delete end #9590
      this.findList();
    },
    refresh() {
      // 他の画面に遷移したときもrefresh()が発生する為、自分の画面のみ処理する
      if (this.selfScreenName === this.$router.currentRoute.name
        && document.getElementsByTagName("ons-alert-dialog").length === 0) {
        if (this.isChanged) {
          this.$ons.notification.confirm({
            title: DIALOG_MESSAGES[12000014].title,
            // add 全マスタメッセージ調整 王 start
            // message: "編集内容が破棄されます。</br>よろしいですか？",
            message: DIALOG_MESSAGES[12000014].message,
            // add 全マスタメッセージ調整 王 end
            callback: answer => {
              if (answer === 1) {
                this.loadGridData();
              }
            }
          });
        } else {
          this.loadGridData();
        }
      }
    },
    onCloseMasterEditModal() {
      MasterMaintenanceMixin.methods.onCloseMasterEditModal.call(this);
      // 詳細閉鎖後に grid.refresh は使わない。レイアウト再計算後にスクロールを戻す。
      this.$nextTick(() => {
        // 詳細を開いたときに保存済みの scrollPosition を mixin が戻すため、ここで DOM 上書きしない
        this.syncBedUnchangedRowsFromDb();
        this.stripBedDomForSnapshotUnchangedRows();
        this.editBackgroundColor();
        this.$nextTick(() => {
          this.calculateColumnsWidth();
          this.calculateGridHeight();
          this.calculateGridWidth();
          this.$nextTick(() => {
            this.restoreBedGridScroll();
          });
        });
      });
    },
    /**
     * @description スクロールバーの位置をクリアする
    */
    clearScrollPosition() {
      this.scrollPosition.top = 0;
      this.scrollPosition.left = 0;
    },
    // ベッドマスタ タイトルはハイパーリンクではありません end
    // グリッドのデータ再表示
    gridDataRefresh() {
      const grid = this.$refs.grid;
      grid.dataSource = this.masterRecords;
    },
    async systemUseSetting() {
      if (this.facilitylistValue) {
        // 施設のシステム利用設定を取得する
        const mstFacilityHash = await sendRequestGetMstFacilityHashByFacilityCd(this.facilitylistValue);
        this.facilitySysUseSetting = mstFacilityHash.data.systemUseSetting ? mstFacilityHash.data.systemUseSetting : "";
      } else {
        this.facilitySysUseSetting = ""
      }
    },
    // マスタ一覧のデータを取得
    findList() {
      // システム利用設定取得処理
      this.systemUseSetting();
      // apiをコールして値を取得
      this.findRecordListByFacilityCd(this.facilitylistValue)
        .then(response => {
          const normalizedLocalDataSource = this.normalizeBedDataSource(
            response.data.localDataSource
          );
          this.setMasterRecordList(normalizedLocalDataSource);
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
            if (column.field === "machineNo") {
              column.values = this.normalizeBedDropdownValues(column.values);
            }
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
          // 連携コード１のインデックス取得
          const  inHospitalCd1Index = this.columns.findIndex(
            col => col.field === "inHospitalCd1"
          );
          // 連携コード２のインデックス取得
          const inHospitalCd2Index = this.columns.findIndex(
            col => col.field === "inHospitalCd2"
          );
          if(this.facilitySysUseSetting === "1") {
            // 連携コード１／連携コード２を非表示
            this.columns[inHospitalCd1Index].hidden = true;
            this.columns[inHospitalCd2Index].hidden = true;
          }
          // 初期データ内容を保存
          this.setComparisonRecordModel();
          // カラム幅等初期調整
          this.showSortColumn();
          this.$nextTick(() => {
            this.calculateGridHeight();
            this.calculateGridWidth();
            /* add スクロールの位置を維持 楊 start */
            this.$refs.grid.$el.children[1].scrollTop = this.lastScrollTop;
            this.$refs.grid.$el.children[1].scrollLeft = this.lastScrollLeft;
            /* add スクロールの位置を維持 楊 end */
          });
          //add #9594 ベッドマスタでプリンター及び自動印刷の設定を変更し、保存しようとするとメッセージが表示され保存できない zrx start
          const dataTemp = normalizedLocalDataSource.data;
          this.dbBeforeData = JSON.parse(JSON.stringify(dataTemp));
          //add #9594 ベッドマスタでプリンター及び自動印刷の設定を変更し、保存しようとするとメッセージが表示され保存できない zrx end
        })
        .catch(error => {
          if (error.response.status === 400) {
            //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
            getErrorMessage('MstBedMainComponent.vue', 'findRecordListByFacilityCd', '指定されたマスタが見つかりません。');
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
            getErrorMessage('MstBedMainComponent.vue', 'findRecordListByFacilityCd', error);
          }
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
        });
      // カラム定義情報を取得
      this.findColumnInfo();
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
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
          getErrorMessage('MstBedMainComponent.vue', 'facilityList', error);
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
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
    onOpenFacility(e) {
      // 変更前の値を取得
      this.prevFacilityCd = e.sender._old;
    },
    // add/ #12696 ベッドマスタ画面で不正2件 tianqidong start
    normalizeBedDropdownValues(values) {
      if (!Array.isArray(values)) {
        return values;
      }
      return values.reduce((list, item) => {
        const normalizedValue =
          item?.value === null || item?.value === "null" || item?.value === ""
            ? ""
            : item?.value;
        if (!list.some(option => option.value == normalizedValue)) {
          list.push({
            ...item,
            value: normalizedValue,
            text: normalizedValue === "" ? "" : item?.text
          });
        }
        return list;
      }, []);
    },
    machineNoEditor(container, data) {
      const dataSource = Array.isArray(data.values)
        ? data.values.reduce((list, item) => {
          const normalizedValue =
            item?.value === null || item?.value === "null" || item?.value === ""
              ? ""
              : item?.value;
          const exists = list.some(option => option.value === normalizedValue);
          if (!exists) {
            list.push({
              ...item,
              value: normalizedValue,
              text: normalizedValue === "" ? "" : item?.text
            });
          }
          return list;
        }, [])
        : [];
      if (!dataSource.some(item => item?.value === "")) {
        dataSource.unshift({ value: "", text: "" });
      }
      const currentValue = data.model?.[data.field] === null || data.model?.[data.field] === "null" || data.model?.[data.field] === ""
        ? ""
        : `${data.model?.[data.field]}`;
      const input = $(`<input name="${data.field}" />`).appendTo(container);
      input.kendoDropDownList({
        dataSource,
        dataTextField: "text",
        dataValueField: "value",
        valuePrimitive: true,
        value: currentValue,
        select: (e) => {
          const selectedValue =
            e.dataItem.value === null || e.dataItem.value === undefined || e.dataItem.value === ""
              ? ""
              : Number(e.dataItem.value);
          data.model.set(data.field, Number.isNaN(selectedValue) ? e.dataItem.value : selectedValue);
        }
      });
      input.data("kendoDropDownList")?.wrapper?.css("width", "100%");
    },
    // add/ #12696 ベッドマスタ画面で不正2件 tianqidong end
    //接続装置項目をモーダル画面を経由せずに画面上から直接編集できるようにする。 --start
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
      //add #9009 ベッドマスタにおいて治療中のベッドに対して編集可能 張 start
      // const ele = e.model.code
      // if (this.lockbedList&&this.lockbedList.includes(ele)) {
      //     this.$ons.notification.alert({
      //       title: DIALOG_MESSAGES[13000163].title,
      //       message: messageFormat(DIALOG_MESSAGES[13000163].message)
      //     });
      // }
      //add #9009 ベッドマスタにおいて治療中のベッドに対して編集可能 張 end
      const toFunction = this.masterRecords;
      if(!this.exclusionListNo) {
        this.exclusionListNo = []
      }
      // mod #10280 ベッドマスタに不要なカラムが存在する dengshen start
      // e.sender.columns[9].values =this.columns[9].values.
      e.sender.columns[8].values =this.columns[8].values.
      // mod #10280 ベッドマスタに不要なカラムが存在する dengshen end
      filter(element => (!toFunction.data.
      map(machine => machine.machineNo).includes(element.value.toString())
      || e.model.machineNo ==element.value )&& !this.exclusionListNo.includes(element.value.toString()))
      this.editStart(e);
    },
    //接続装置項目をモーダル画面を経由せずに画面上から直接編集できるようにする。 --end
    // 施設を選択時の動作
    onChangeFacility(e) {
      if(this.prevFacilityCd != e.sender._old) {
        // 選択施設の拡張設定を取得
        var newFacilityAdvancedSettings = {};
        let selectedIndex = e.sender.selectedIndex;
        try {
          if (e.sender.dataSource.options.data[selectedIndex].advancedSettings) {
            newFacilityAdvancedSettings = JSON.parse(e.sender.dataSource.options.data[selectedIndex].advancedSettings);
          }
        } catch(error) {
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
          getErrorMessage('MstBedMainComponent.vue', 'onChangeFacility', error);
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
          newFacilityAdvancedSettings = {};
        }

        if (!newFacilityAdvancedSettings.func_advcds) {
          newFacilityAdvancedSettings.func_advcds = [];
        }
        // 在宅フラグは削除する  Du
        // const enableHomeDialysis = newFacilityAdvancedSettings.func_advcds.some(
        //   setting => setting.func_advcd === ADVANCED_SETTINGS.HOME_DIALYSIS
        // );

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
                // 在宅フラグは削除する  Du
                // this.facilityHemoDialysis = enableHomeDialysis;
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
          // 在宅フラグは削除する  Du
          // this.facilityHemoDialysis = enableHomeDialysis;
          this.findList();
        }
      }
    },
    showMasterEditModal(e){
      // モーダル確定時にスクロール位置が戻ってしまう問題の対処
      const grid = $("div.k-grid-content")[0];
      this.scrollPosition.top = grid.scrollTop;
      this.scrollPosition.left = grid.scrollLeft;
        //add #9009 ベッドマスタにおいて治療中のベッドに対して編集可能 張 start
      const row = this.$refs.grid.kendoWidget();
      const selectedRowItem = row.dataItem(e.currentTarget.closest("tr"));
      let code = selectedRowItem.code;
         let showEdit = true;
        // if (this.lockbedList&&this.lockbedList.includes(code)) {
        //   showEdit = false;
        // this.$ons.notification.alert({
        //   title: DIALOG_MESSAGES[13000163].title,
        //   message: messageFormat(DIALOG_MESSAGES[13000163].message)
        // });
        // }
      if (showEdit) {
        //add #9009 ベッドマスタにおいて治療中のベッドに対して編集可能 張 end
      // モーダル画面表示
      this.showMasterEdit();
      }
      /**
       * 「詳細」ボタンを押下したレコードのデータを取得する。
       * see: https://www.telerik.com/forums/selected-row-at-wrappers-for-vue
       */
      e.preventDefault();
      //del #9009 ベッドマスタにおいて治療中のベッドに対して編集可能 張 start
      // const row = this.$refs.grid.kendoWidget();
      // const selectedRowItem = row.dataItem(e.currentTarget.closest("tr"));
      // let code = selectedRowItem.code;
      //del #9009 ベッドマスタにおいて治療中のベッドに対して編集可能 張 end
      // codeがない場合はcodeを付番
      if (!code) {
        this.edit({ editRecord: selectedRowItem, isSortMode: this.isSortMode });
        code = this.getMasterRecordList.data[0].code;
      }

      // プロパティを正規化する。
      const normalizedItem = this.normalization(selectedRowItem);

      // ストアに保存する。
      this.setEditRecord(normalizedItem);

      // モーダル画面表示用のシステム利用設定を設定
      this.setFacilitySysUseSetting(this.facilitySysUseSetting);
    },
    async saveRecord() {
      // 共通ローダー:表示開始
      this.setLoadingScreenVisible(true);
      //イベント発生前のスクロールバーの位置を保持（ページ内の別グリッドと取り違えないよう kendoWidget から取得）
      const bedGrid = this.$refs.grid?.kendoWidget?.();
      const scrollFrom = this.readBedGridScrollFromGridWidget(bedGrid);
      this.scrollPosition.top = scrollFrom.top;
      this.scrollPosition.left = scrollFrom.left;
      // グリッドでエラーが発生している場合は処理を中断
      if (!this.kendoValidator.validate()) {
        // 共通ローダー：表示終了
        this.setLoadingScreenVisible(false);
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

      let message = "";
      if (validateMessage.length !== 0) {
        // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
        // message = "以下の列に未入力項目が存在します。" + validateMessage;
        message = messageFormat(DIALOG_MESSAGES[12000270].message) + validateMessage;
        // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
      }
      if (validateComboMessage.length !== 0) {
        if (message.length !== 0) message = message + "</br>";
        message =
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
          // message + "以下の列の選択を見直してください。" + validateComboMessage;
          message + messageFormat(DIALOG_MESSAGES[12000006].message) + validateComboMessage;
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
          message: '<div style="text-align:left;">' + message + "</div>"
        });
        return;
      }
      const treatmentList = this.getUpdateRecordList.filter(e=> e.operation && e.operation == 2);
      //add #9009 ベッドマスタにおいて治療中のベッドに対して編集可能 林峻峰 start
      let treatmentFlg = false;
      for(let item of treatmentList) {
        //mod #9594 ベッドマスタでプリンター及び自動印刷の設定を変更し、保存しようとするとメッセージが表示され保存できない zrx start
        const beforeItem = this.dbBeforeData.find(
          m => m.code === item.code
        );
        // if (this.lockbedList && this.lockbedList.includes(item.code)) {
        //Only changes to machineNo will affect the message prompt
        if (this.lockbedList && this.lockbedList.includes(item.code) && beforeItem.machineNo !== item.machineNo) {
        //mod #9594 ベッドマスタでプリンター及び自動印刷の設定を変更し、保存しようとするとメッセージが表示され保存できない zrx end
          treatmentFlg = true;
          break;
        }
      }
      if (treatmentFlg) {
        this.setLoadingScreenVisible(false);
        this.$ons.notification.alert({
          title: DIALOG_MESSAGES[13000163].title,
          message: messageFormat(DIALOG_MESSAGES[13000163].message)
        });
        return;
      }
      //add #9009 ベッドマスタにおいて治療中のベッドに対して編集可能 林峻峰 end
      let that = this;
      let recordModelList = JSON.parse(this.comparisonRecordModel);
      const machineTypeLists = await sendRequestGetMachineType();
      let upDataList = [];
      upDataList = this.getUpdateRecordList.filter(e=> e.operation && e.operation == 2 && recordModelList.find(item => item.code == e.code).machineNo != e.machineNo)
      if (upDataList.length > 0) {
        let requestData = [];
        await sendRequestFindRecordList("mst_status_map_bed_layout").then( async response => {
          upDataList.forEach(e => {
            let itemData = []
            itemData = response.data.localDataSource.data;
            if(itemData.length > 0)
            itemData.forEach(item =>{
              let editItem = JSON.parse(item.bedLayout).obj_list;
              editItem.forEach( (edititem,index) => {
                if (e.code == edititem.bed_cd) {
                    let machine =  that.mstMachine.find(a => a.machineNo == e.machineNo);
                    editItem[index] = {
                        top: edititem.top,
                        left: edititem.left,
                        name: edititem.name,
                        model: machine ? machineTypeLists.data.find(c => machine.machineTypeCd == c.machineTypeCd).model : "",
                        width: edititem.width,
                        bed_cd: edititem.bed_cd,
                        height: edititem.height,
                        machine_no: e.machineNo ? e.machineNo : -1,
                        disp_order_no: edititem.disp_order_no,
                        machine_serial: machine ? machine.machineSerial : "",
                        machine_type_cd: machine ? machine.machineTypeCd : "",
                        is_home_dialysis: edititem.is_home_dialysis,
                    }
                }
              });
              if(JSON.stringify(JSON.parse(item.bedLayout).obj_list) != JSON.stringify(editItem)) {
                item["operation"] = 2;
                let bedLayout = JSON.parse(item.bedLayout);
                bedLayout.obj_list = editItem;
                item.bedLayout = JSON.stringify(bedLayout);
              }
           });
          });
          requestData = response.data.localDataSource.data
        })
        if (requestData && requestData.length > 0)
            await sendRequestUpdateRecordListByFacilityCd("mst_status_map_bed_layout", this.getFacilitySwitch, requestData);
      }
      // apiをコールして値を保存
      this.updateRecordListByFacilityCd({facilityCd: this.facilitylistValue, request: this.getUpdateRecordList})
        .then(response => {
          this.updateResponse = response.data;
          //共通ローダー：表示終了
          this.setLoadingScreenVisible(false);

          this.$ons.notification.alert({
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
            // title: "更新完了",
            // message: "マスタ更新が完了しました。"
            title: DIALOG_MESSAGES[12000004].title,
            message: messageFormat(DIALOG_MESSAGES[12000004].message),
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
          });
          this.isSorted = false;

          const facilityCds = this.getMasterRecordList.data
            .map(currentVal => currentVal.destinationFacilityCd)
            .filter((currentVal, index, self) => {
              return self.indexOf(currentVal) === index;
            });

          this.findList();
          if (this.masterPhysicalName === "mst_alarm_notification") {
            this.masterSynchro(facilityCds);
          }
        })
        .catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
          getErrorMessage('MstBedMainComponent.vue', 'updateRecordListByFacilityCd', error);
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
          if (error.response.status === 400) {
            //共通ローダー：表示終了
            this.setLoadingScreenVisible(false);
            this.$ons.notification.alert({
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
              // title: "更新失敗",
              title: DIALOG_MESSAGES["00300005"].title,
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
              message: error.response.data.errorMessage
            });
          }
        });
    },
    addRow() {
      // グリッドでエラーが発生している場合は処理を中断
      if (!this.kendoValidator.validate()) {
        return;
      }

      // 空レコードをストアに登録
      let d = new Object();
      const fields = this.getMasterRecordList.schema.model.fields;

      // 初期値を設定
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

        if (k === "sortRank") {
          d[k] = this.getMaxSortRank() + 1;
        }
      });

      // シャント位置
      d.shuntPosition = 0;

      this.lastScrollTop = this.$refs.grid.$el.lastChild.scrollHeight;
      // 画面編集内容をstoreに反映 ※新規レコード追加
      this.edit({ editRecord: d, isSortMode: this.isSortMode });
      // 色変え？
      this.editBackgroundColor();
    },
    onDataBoundKendoGrid(ev) {
      this.$nextTick(() => {
        requestAnimationFrame(() => {
          const top = this.scrollPosition.top || 0;
          const left = this.scrollPosition.left || 0;
          this.applyBedGridScrollToWidget(top, left, ev.sender);
        });
      });
    },
    /**
     * セル保存時: mixin の onSave は ev.sender.refresh() でスクロールが先頭に戻るため、
     * ベッドマスタでは refresh を除いた同等処理のみ行う（onSave は methods 内に置くこと）。
     */
    onSave(ev) {
      this.normalizeBedRecord(ev.model);
      const grid = ev.sender;
      const { top: preTop, left: preLeft } = this.readBedGridScrollFromGridWidget(grid);
      this.scrollPosition.top = preTop;
      this.scrollPosition.left = preLeft;
      this.scrollTop = preTop;
      this.scrollLeft = preLeft;
      this.editFlg = true;
      this.editingFlg = false;
      this.edit({ editRecord: ev.model, isSortMode: this.isSortMode });
      if (ev.model.operation === 1) {
        ev.model.edited = true;
      }
      if (!this.isRecordModified) {
        this.editBackgroundColor();
      }
      this.$nextTick(() => {
        this.syncBedUnchangedRowsFromDb();
        this.refreshBedGridAfterUnchangedSync();
        this.$nextTick(() => {
          this.editBackgroundColor();
          this.$nextTick(() => {
            this.applyBedGridScrollToWidget(preTop, preLeft);
            this.restoreBedGridScroll();
          });
        });
      });
    },
    editEnd(ev) {
      const grid = ev?.sender || this.$refs.grid?.kendoWidget?.();
      const { top, left } = this.readBedGridScrollFromGridWidget(grid);
      this.scrollPosition.top = top;
      this.scrollPosition.left = left;
      this.scrollTop = top;
      this.scrollLeft = left;
      MasterMaintenanceMixin.methods.editEnd.call(this, ev);
      this.$nextTick(() => {
        this.syncBedUnchangedRowsFromDb();
        this.refreshBedGridAfterUnchangedSync();
        this.$nextTick(() => {
          this.editBackgroundColor();
          this.$nextTick(() => {
            this.applyBedGridScrollToWidget(top, left);
            this.restoreBedGridScroll();
          });
        });
      });
    }
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
  --height: 200px;
  height: var(--height);
  border-bottom: none;
}
.toolbar-btn {
  padding: 0.2em 1em 0em 1em;
  line-height: 2em;
  width: auto;
}
.k-grid-toolbar {
  padding: 0.1em 0.3em;
}
.k-grid-toolbar span {
  margin: 0;
}
/* add 8130 全施設マスタでフリーズする 周安寧 start */
.kendo-grid-toolbar-style
  >>> .k-grid
  tr:nth-child(n + 3):nth-last-child(n-3)
  .k-tooltip.k-tooltip-validation
  .k-callout {
  border-bottom: 0;
  border-top: 6px solid #000;
  top: unset;
  bottom: -6px;
}
.kendo-grid-toolbar-style
  >>> .k-grid
  tr:nth-child(n + 3):nth-last-child(n-3)
  .k-tooltip.k-tooltip-validation {
  bottom: 38px;
}
.kendo-grid-toolbar-style >>> .k-edit-cell {
  position: relative;
  overflow: visible;
}
/* add 8130 全施設マスタでフリーズする 周安寧 end */
.kendo-grid-toolbar-style >>> .k-grid-header-locked > table {
  border-right-width: 0px;
}
.kendo-grid-toolbar-style >>> .k-grid-header-locked {
  border-right: 1px solid var(--ntss-list-border-color) !important;
}
.kendo-grid-toolbar-style >>> .k-grid-content-locked {
  z-index: 1;
  box-shadow: 1px 0px 0px 0px var(--ntss-border-color) !important;
}
.custom-switch {
  transform: scale(0.85);
  transform-origin: center;
  touch-action: manipulation;
}
.kendo-grid-toolbar-style >>> .k-grid-content-locked {
  overflow-y: scroll !important;
  -webkit-overflow-scrolling: touch;
  scrollbar-width: none;
  -ms-overflow-style: none;
}
.kendo-grid-toolbar-style >>> .k-grid-content-locked::-webkit-scrollbar {
  display: none;
}
.mobile-header {
  min-height: 30px; /* モバイル用の高さ */
}
</style>
