<template>
  <modal-base @onClose="closeMasterEditModal">
    <div slot="header">
      <!-- eslint-disable-next-line vue/require-component-is -->
      <component :is="header" />
    </div>
    <div slot="body" :class="masterPhysicalName">
      <!-- eslint-disable-next-line vue/require-component-is -->
      <component
        :is="main"
        ref="child"
        @closeMasterEditModal="closeMasterEditModal"
      />
    </div>
    <div slot="footer" class="flex-container">
      <div class="denial-btn-area" style="background:none">
        <v-ons-button class="button btn2-cancel denial-btn" @click="closeMasterEditModal">
          キャンセル
        </v-ons-button>
      </div>
      <div class="registration-btn-area" style="background:none">
        <v-ons-button
          :disabled="registeredFlag"
          class="button registration-btn common-style-select-button"
          @click="saveMasterRecordToStore"
        >
          確定
        </v-ons-button>
      </div>
    </div>
  </modal-base>
</template>

<script>
import {
  REPORT_GRAPH
} from "@/constants/mstTreatmentDefine.js";
//FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
import {getErrorMessage} from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
import {mapActions, mapGetters} from "vuex";
import MasterEditModalBase from "@/views/master-maintenance/MasterEditModalBase";
import {EventBus} from "@/eventBus.js";
import _ from 'lodash';
import {deepCopy} from "@/functions/common/CommonFunctions";
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
import {accSub} from "@/functions/common/NumberFunctions";
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
import { ApiHelper } from "@/apis/AxiosHelper";
import { count } from '@progress/kendo-data-query/dist/npm/array.operators';

export default {
  name: "MasterEditModal",
  components: {
    // --------------------------------------
    // 個々のページのImportをここで行なってください
    // 要素名は下記にしてください（要素名はケバブケースで記載してください。（mst_hoge → mst-hoge））
    //   Mainページ：テーブル論理名（例：mst_hoge）
    //     "mst-hoge": () => import("@/components/master-maintenance/MasterComponentMstHoge")
    //   Headerページ：テーブル論理名＋_header（例：mst_hoge_header）
    //     "mst-hoge-header": () => import("@/components/master-maintenance/MasterComponentMstHogeHeader")
    //   Headerのコンポーネントが指定されない場合は、MasterEditModalHeaderComponent.vueが描画されます。
    // --------------------------------------
    "modal-base": MasterEditModalBase,
    // TODO: eslintによるエラー
    /* eslint-disable vue/no-unused-components */
    "default-header": () =>
      import("@/components/master-maintenance/MasterEditModalHeaderComponent"),
    // (例)mst_test_tableの編集用モーダルは以下のようにインポートします。
    // ヘッダーをインポートしない場合は、default-headerがヘッダーコンポーネントとして利用されます。
    "mst-test-table-header": () =>
      import(
        "@/components/master-maintenance/mst-test-table/MasterModalComponentMstTestTableHeader.vue"
      ),
    "mst-test-table": () =>
      import(
        "@/components/master-maintenance/mst-test-table/MasterModalComponentMstTestTable.vue"
      ),
    "mst-destination-group-header": () =>
      import(
        "@/components/master-maintenance/mst-destination-group/MasterDestinationGroupComponentHeader.vue"
      ),
    "mst-destination-group": () =>
      import(
        "@/components/master-maintenance/mst-destination-group/MasterDestinationGroupComponent.vue"
      ),
    "mst-comsv-setting-header": () =>
      import(
        "@/components/master-maintenance/mst-comsv-setting/MasterModalComponentMstComSvSettingHeader.vue"
      ),
    "mst-comsv-setting": () =>
      import(
        "@/components/master-maintenance/mst-comsv-setting/MasterModalComponentMstComSvSetting.vue"
      ),
    "mst-alarm-notification-header": () =>
      import(
        "@/components/master-maintenance/mst-alarm-notification/MasterAlarmNotificationComponentHeader.vue"
      ),
    "mst-alarm-notification": () =>
      import(
        "@/components/master-maintenance/mst-alarm-notification/MasterAlarmNotificationComponent.vue"
      ),
    "mst-bed-header": () =>
      import("@/components/master-maintenance/mst-bed/MstBedModalHeader.vue"),
    "mst-bed": () =>
      import("@/components/master-maintenance/mst-bed/MstBedModal.vue"),
    "mst-medicine-group-header": () =>
      import(
        "@/components/master-maintenance/mst-medicine-group/MasterModalComponentMstMedicineGroupHeader.vue"
      ),
    "mst-medicine-group": () =>
      import(
        "@/components/master-maintenance/mst-medicine-group/MasterModalComponentMstMedicineGroup.vue"
      ),
    "mst-medicine-set-header": () =>
      import(
        "@/components/master-maintenance/mst-medicine-set/MasterModalComponentMstMedicineSetHeader.vue"
      ),
    "mst-medicine-set": () =>
      import(
        "@/components/master-maintenance/mst-medicine-set/MasterModalComponentMstMedicineSet.vue"
      ),
    "mst-equipment-set-header": () =>
      import(
        "@/components/master-maintenance/mst-equipment-set/MasterModalComponentMstEquipmentSetHeader.vue"
      ),
    "mst-equipment-set": () =>
      import(
        "@/components/master-maintenance/mst-equipment-set/MasterModalComponentMstEquipmentSet.vue"
      ),
    "mst-pat-viewer-layout-header": () =>
      import(
        "@/components/master-maintenance/mst-pat-viewer-layout/MasterModalComponentPatViewerLayoutHeader.vue"
      ),
    "mst-pat-viewer-layout": () =>
      import(
        "@/components/master-maintenance/mst-pat-viewer-layout/MasterModalComponentPatViewerLayout.vue"
      ),
    "mst-room-bed-group-header": () =>
      import(
        "@/components/master-maintenance/mst-bed-group/MstRoomBedGroupMainComponentHeader.vue"
      ),
    "mst-room-bed-group": () =>
      import(
        "@/components/master-maintenance/mst-bed-group/MstRoomBedGroupMainComponent.vue"
      ),
    "mst-treatment-set-header": () =>
      import(
        "@/components/master-maintenance/mst-treatment-set/MasterModalComponentMstTreatmentSetHeader.vue"
      ),
    "mst-treatment-set": () =>
      import(
        "@/components/master-maintenance/mst-treatment-set/MasterModalComponentMstTreatmentSet.vue"
      ),
    "mst-treatment-status-layout-header": () =>
      import(
        "@/components/master-maintenance/mst-treatment-status-layout/MstTreatmentStatusLayoutComponentHeader.vue"
      ),
    "mst-treatment-status-layout": () =>
      import(
        "@/components/master-maintenance/mst-treatment-status-layout/MstTreatmentStatusLayoutComponent.vue"
      ),
    "mst-taboo-allergy-header": () =>
      import(
        "@/components/master-maintenance/mst-taboo-allergy/MstTabooAllergyMainComponentHeader.vue"
      ),
    "mst-taboo-allergy": () =>
      import(
        "@/components/master-maintenance/mst-taboo-allergy/MstTabooAllergyMainComponent.vue"
      ),
      //ADD 患者イベントサブカテゴリマスタ 孔s START
    "mst-pat-event-sub-category-header": () =>
      import(
        "@/components/master-maintenance/mst_pat_event_sub_category/MstModalPatEventSubCategoryHeaderComponent.vue"
      ),
    "mst-pat-event-sub-category": () =>
      import(
        "@/components/master-maintenance/mst_pat_event_sub_category/MstModalPatEventSubCategoryMainComponent.vue"
      ),
      //ADD 患者イベントサブカテゴリマスタ 孔s END
    "mst-treatment-header": () =>
      import(
        "@/components/master-maintenance/mst-treatment/MstTreatmentMainComponentHeader.vue"
      ),
    "mst-treatment": () =>
      import(
        "@/components/master-maintenance/mst-treatment/MstTreatmentMainComponent.vue"
      ),
    "mst-facility": () =>
      import(
        "@/components/master-maintenance/mst-facility/MstFacilityModal.vue"
      ),
    "mst-wheel-chair-header": () =>
      import(
        "@/components/master-maintenance/mst-wheel-chair/MasterModalComponentMstWheelChairHeader.vue"
      ),
    "mst-wheel-chair": () =>
      import(
        "@/components/master-maintenance/mst-wheel-chair/MasterModalComponentMstWheelChair.vue"
      ),
    "mst-job-header": () =>
      import(
        "@/components/master-maintenance/mst-job/MstJobMainModalComponentHeader.vue"
      ),
    "mst-job": () =>
      import(
        "@/components/master-maintenance/mst-job/MstJobMainModalComponent.vue"
      ),
    "mst-round-type-header": () =>
      import(
        "@/components/master-maintenance/mst-round-type/MasterRoundTypeComponentHeader.vue"
      ),
    "mst-round-type": () =>
      import(
        "@/components/master-maintenance/mst-round-type/MasterRoundTypeComponent.vue"
      ),
    "mst-pat-list-layout-header": () =>
      import(
        "@/components/master-maintenance/mst-pat-list-layout/MstPatListLayoutMainComponentHeader.vue"
      ),
    "mst-pat-list-layout": () =>
      import(
        "@/components/master-maintenance/mst-pat-list-layout/MstPatListLayoutMainComponent.vue"
      ),
    "mst-pat-event-data-template-header": () =>
      import(
        "@/components/master-maintenance/mst-pat-event-template/MstPatEventTemplateModalHeader.vue"
      ),
    "mst-pat-event-data-template": () =>
      import(
        "@/components/master-maintenance/mst-pat-event-template/MstPatEventTemplateModal.vue"
      ),
    "mst-trend-graph-template-header": () =>
      import(
        "@/components/master-maintenance/mst-trend-graph-template/MstTrendGraphTemplateModalHeader.vue"
      ),
    "mst-trend-graph-template": () =>
      import(
        "@/components/master-maintenance/mst-trend-graph-template/MstTrendGraphTemplateModal.vue"
      ),
    "mst-trend-graph-monitor-set-header": () =>
      import(
        "@/components/master-maintenance/mst-trend-graph-monitor-set/MstTrendGraphMonitorSetModalHeader.vue"
      ),
    "mst-trend-graph-monitor-set": () =>
      import(
        "@/components/master-maintenance/mst-trend-graph-monitor-set/MstTrendGraphMonitorSetModal.vue"
      ),
    "mst-com-fixed-phrase-header": () =>
      import(
        "@/components/master-maintenance/mst-com-fixed-phrase/MstComFixedPhraseModalHeader.vue"
      ),
    "mst-com-fixed-phrase": () =>
      import(
        "@/components/master-maintenance/mst-com-fixed-phrase/MstComFixedPhraseModal.vue"
      ),
    "mst-rad-set-header": () =>
      import(
        "@/components/master-maintenance/mst-rad-set/MstRadSetModalComponentHeader.vue"
      ),
    "mst-rad-set": () =>
      import(
        "@/components/master-maintenance/mst-rad-set/MstRadSetModalComponent.vue"
      ),
    "mst-exam-item-header": () =>
      import(
        "@/components/master-maintenance/mst-exam-item/MstExamItemMainModalComponentHeader.vue"
      ),
    "mst-exam-item": () =>
      import(
        "@/components/master-maintenance/mst-exam-item/MstExamItemMainModalComponent.vue"
      ),
    "mst-exam-set-header": () =>
      import(
        "@/components/master-maintenance/mst-exam-set/MstExamSetHeaderComponent.vue"
      ),
    "mst-exam-set": () =>
      import(
        "@/components/master-maintenance/mst-exam-set/MstExamSetMainComponent.vue"
      ),
    "mst-pat-calendar-layout-header": () =>
      import(
        "@/components/master-maintenance/mst-pat-calendar-layout/MstPatCalendarLayoutMainComponentHeader.vue"
      ),
    "mst-pat-calendar-layout": () =>
      import(
        "@/components/master-maintenance/mst-pat-calendar-layout/MstPatCalendarLayoutMainComponent.vue"
      ),
    "mst-medicine-header": () =>
      import(
        "@/components/master-maintenance/mst-medicine/MstMedicineMainModalComponentHeader.vue"
      ),
    "mst-medicine": () =>
      import(
        "@/components/master-maintenance/mst-medicine/MstMedicineMainModalComponent.vue"
      ),
    "mst-medicine-mix-header": () =>
      import(
        "@/components/master-maintenance/mst-medicine-mix/MasterModalComponentMstMedicineMixHeader.vue"
      ),
    "mst-medicine-mix": () =>
      import(
        "@/components/master-maintenance/mst-medicine-mix/MasterModalComponentMstMedicineMix.vue"
      ),
    "mst-machine-header": () =>
      import(
        "@/components/master-maintenance/mst-machine/MstMachineMainModalComponentHeader.vue"
      ),
    "mst-machine": () =>
      import(
        "@/components/master-maintenance/mst-machine/MstMachineMainModalComponent.vue"
      ),
    "mst-take-medicine-header": () =>
      import(
        "@/components/master-maintenance/mst-take-medicine/MstTakeMedicineComponentHeader.vue"
      ),
    "mst-take-medicine": () =>
      import(
        "@/components/master-maintenance/mst-take-medicine/MstTakeMedicineComponent.vue"
      ),
    "mst-facility-calendar-layout-header": () =>
      import(
        "@/components/master-maintenance/mst-facility-calendar-layout/MstFacilityCalendarLayoutMainComponentHeader.vue"
      ),
    "mst-facility-calendar-layout": () =>
      import(
        "@/components/master-maintenance/mst-facility-calendar-layout/MstFacilityCalendarLayoutMainComponent.vue"
      ),
    "mst-mainte-layout-group-header": () =>
      import(
        "@/components/master-maintenance/mst-inspection-layout-group/MstInspectionLayoutGroupHeader.vue"
      ),
    "mst-mainte-layout-group": () =>
      import(
        "@/components/master-maintenance/mst-inspection-layout-group/MstInspectionLayoutGroupComponent.vue"
      ),
    "mst-mainte-layout-header": () =>
      import(
        "@/components/master-maintenance/mst-inspection-layout/MstInspectionMainHeader.vue"
      ),
    "mst-mainte-layout": () =>
      import(
        "@/components/master-maintenance/mst-inspection-layout/MstInspectionMainComponent.vue"
      ),
    "mst-water-survey-point": () =>
      import (
        "@/components/water-quality-survey/modal/WaterQualitySurveyTypeModal.vue"
      ),
    "mst-menu-group": () =>
      import(
        "@/components/master-maintenance/mst-menu-group/MstMenuGroupModalComponent.vue"
      ),
    "mst-menu-group-header": () =>
      import(
        "@/components/master-maintenance/mst-menu-group/MstMenuGroupModalComponentHeader.vue"
      ),
    "mst-url-link-register": () =>
      import(
        "@/components/url-link-register/UrlLinkRegisterMainComponent.vue"
      ),
    "mst-url-link-register-header": () =>
      import(
        "@/components/url-link-register/UrlLinkRegisterHeaderComponent.vue"
      ),
    "mst-holiday-header": () =>
      import(
        "@/components/master-maintenance/mst-holiday/MstHolidayMainModalComponentHeader.vue"
      ),
    "mst-holiday": () =>
      import(
        "@/components/master-maintenance/mst-holiday/MstHolidayMainModalComponent.vue"
      ),
    "mst-addition-header": () =>
      import(
        "@/components/master-maintenance/mst-addition/MasterModalComponentMstAdditionHeader.vue"
      ),
    "mst-addition": () =>
      import(
        "@/components/master-maintenance/mst-addition/MasterModalComponentMstAddition.vue"
      ),
    "mst-mainte-category-header": () =>
      import(
        "@/components/master-maintenance/mst-mainte-category/MstMainteCategoryMainHeader.vue"
      ),
    "mst-mainte-category": () =>
      import(
        "@/components/master-maintenance/mst-mainte-category/MstMainteCategoryMainComponent.vue"
      ),
    //ADD 投薬支援マスタ 孔s START
    "mst-medicine-support-header": () =>
      import(
        "@/components/master-maintenance/mst-medicine-support/MstMedicineSupportMainModalComponentHeader.vue"
        ),
    "mst-medicine-support": () =>
      import(
        "@/components/master-maintenance/mst-medicine-support/MstMedicineSupportMainModalComponent.vue"
        ),
    //ADD 投薬支援マスタ 孔s END
    //ADD 水質検査種別マスタ 孔s START
    "mst-water-survey-type-header": () =>
      import(
        "@/components/master-maintenance/mst-water-survey-type/MstWaterSurveyTypeModalHeader.vue"
        ),
    "mst-water-survey-type": () =>
      import(
        "@/components/master-maintenance/mst-water-survey-type/MstWaterSurveyTypeModal.vue"
        ),
    //ADD 水質検査種別マスタ 孔s END
    "mst-prescription-set": () =>
      import(
        "@/components/master-maintenance/mst-prescription-set/MstPrescriptionSetModalComponent.vue"
      ),
    "mst-prescription-set-header": () =>
      import(
        "@/components/master-maintenance/mst-prescription-set/MstPrescriptionSetModalComponentHeader.vue"
      ),    
  },
  data() {
    return {
      main: "",
      header: "",
      registeredFlag: false
    };
  },
  computed: {
    ...mapGetters("master-maintenance", {
      getMasterRecordList: "getMasterRecordList",
      masterPhysicalName: "getMasterName",
      editRecord: "getEditRecord",
      getFacilitySwitch: "getFacilitySwitch",
      schema: "getSchema"
    }),
    ...mapGetters("mst-pat-event-template", {
      getInputParams: "getInputParams"
    }),
  },
  watch: {
    // add #12696 ベッドマスタ画面で不正2件 tianqidong start
    editRecord: {
      deep: true,
      handler() {
        this.syncBedRegisteredFlag();
      }
    },
    getMasterRecordList: {
      deep: true,
      handler() {
        this.syncBedRegisteredFlag();
      }
    }
    // add #12696 ベッドマスタ画面で不正2件 tianqidong end
  },
  created() {
    // 物理名をケバブケースに変換、コンポーネントを設定
    const physicalNameAsKebab = this.masterPhysicalName.replace(/_/g, "-");
    this.main = physicalNameAsKebab;

    const headerComponentName = `${physicalNameAsKebab}-header`;
    if (this.$options.components[headerComponentName]) {
      // 該当のヘッダComponentがある場合は該当ヘッダを使用
      this.header = headerComponentName;
    } else {
      // 該当のヘッダComponentがない場合はデフォルトヘッダを使用
      this.header = "default-header";
    }
    EventBus.$on( "mstHolidayRegistered", this.modRegisteredFlag);
    window.onbeforeprint = () => {
      //印刷不要な要素を非表示にする
      document.getElementsByClassName('content-container')[0].style.display = 'none'
    };
    window.onafterprint = () => {
      //隠し要素を放す
      document.getElementsByClassName('content-container')[0].style.display = 'block'
    };
    this.$nextTick(() => {
      this.syncBedRegisteredFlag();
    });
  },
  methods: {
    ...mapActions("multi-modal", ["hideModal"]),
    ...mapActions("master-maintenance", [
      "setEditRecord",
      "setMasterRecordList",
      "editRecordBeEmpty"
    ]),
    ...mapActions("mst-job", [
      "setIsMenuSettings"
    ]),
    modRegisteredFlag(val) {
      // add #12696 ベッドマスタ画面で不正2件 tianqidong start
      if (this.masterPhysicalName === "mst_bed") {
        this.syncBedRegisteredFlag();
        return;
      }
      // add #12696 ベッドマスタ画面で不正2件 tianqidong end
      this.registeredFlag = val;
    },
    syncBedRegisteredFlag() {
      // add #12696 ベッドマスタ画面で不正2件 tianqidong start
      if (this.masterPhysicalName !== "mst_bed") return;
      if (!this.editRecord || !this.getMasterRecordList?.data) return;
      const existsInList = this.getMasterRecordList.data.some(
        record => record.code === this.editRecord.code
      );
      if (!existsInList) {
        this.registeredFlag = false;
        return;
      }
      this.registeredFlag = this.hasChange(this.editRecord, this.getMasterRecordList);
      // add #12696 ベッドマスタ画面で不正2件 tianqidong end
    },
    objectToJson(record) {
      let clone = JSON.parse(JSON.stringify(record));
      clone = Object.keys(clone).reduce((acc, key) => {
        try {
          // mode kang 2023/06/15 start   Exception:SyntaxError: Unexpected token 'P', "PA" is not valid JSON
          // acc[key] = JSON.stringify(JSON.parse(JSON.stringify(record[key])));
          acc[key] = JSON.parse(JSON.stringify(record[key]));
          // mode kang 2023/06/15 end
        } catch (error) {
          //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
          getErrorMessage('MasterEditModal.vue','objectToJson',error);
          //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
          acc[key] = record[key];
        }
        return acc;
      }, {});

      return JSON.stringify(clone).replace(/\n|\t|null|""/g, "");
    },
    applyBedCompareNormalizationForPick(record) {
      if (!record || typeof record !== "object") {
        return;
      }
      const normalizeCompareValue = value => {
        if (value === undefined || value === null || value === "" || value === "null") {
          return "";
        }
        const numericValue = Number(value);
        return Number.isNaN(numericValue) ? `${value}` : `${numericValue}`;
      };
      const normalizeNullableString = value => {
        if (value === undefined || value === null || value === "" || value === "null") {
          return "";
        }
        return `${value}`;
      };
      record.machineNo = normalizeCompareValue(record.machineNo);
      record.shuntPosition = normalizeCompareValue(record.shuntPosition);
      record.isInfection = normalizeNullableString(record.isInfection);
      record.emergencyClass = normalizeCompareValue(record.emergencyClass);
      record.outputPrinter = normalizeNullableString(record.outputPrinter);
      record.isAutoprintBefore = normalizeNullableString(record.isAutoprintBefore);
      record.isAutoprintAfter = normalizeNullableString(record.isAutoprintAfter);
      record.isAutoprintCommit = normalizeNullableString(record.isAutoprintCommit);
      record.inHospitalCd1 = normalizeNullableString(record.inHospitalCd1);
      record.inHospitalCd2 = normalizeNullableString(record.inHospitalCd2);
    },
    hasChange(editRecordOrg, masterRecordListOrg) {

      let editRecord = deepCopy(editRecordOrg);
      let masterRecordList = deepCopy(masterRecordListOrg);

      let dispInfo1 = null;
      let dispInfo2 = null;

      if (this.masterPhysicalName === "mst_pat_list_layout") {
        if (editRecord.templateCd === 3) {
          let record = masterRecordList.data[masterRecordList.data.findIndex(
            masterRecord => masterRecord.code === editRecord.code
          )];
          let edit = JSON.parse(editRecord.dispItemInfo);
          let init = null;
          // 新規追加時にはデータが存在しない為、データの有無を確認してからparseを行う
          if (record.dispItemInfo) {
            init = JSON.parse(record.dispItemInfo);
          }
          if (init === null) init = [];
          let count = 0;
          edit.forEach(edit => {
            init.forEach( rec => {
              if (edit.category === rec.category && JSON.stringify(edit.items) === JSON.stringify(rec.items)) {
                count++;
              }
            });
          });
          if (!(count === edit.length && count === init.length)) {
            return false;
          }
          dispInfo1 = editRecord.dispItemInfo;
          editRecord.dispItemInfo = null;
          dispInfo2 = record.dispItemInfo;
          record.dispItemInfo = null;
        }
      }

      const index = masterRecordList.data.findIndex(
        masterRecord => masterRecord.code === editRecord.code
      );
      const keys = Object.keys(this.schema.model.fields).filter(
        field => field !== "$modalType"
      );

      //空値をnullに統一する
      for(var i=0; i<keys.length; i++){
        if(editRecord[keys[i]] === "" ||
          editRecord[keys[i]] === undefined ||
          editRecord[keys[i]] === "[]"){
          editRecord[keys[i]] = null;
        }
        if(masterRecordList.data[index][keys[i]] === "" ||
          masterRecordList.data[index][keys[i]] === undefined ||
          masterRecordList.data[index][keys[i]] === "[]"){
          masterRecordList.data[index][keys[i]] = null;
        }
      }

      const normalizedEditRecord = _.pick(editRecord, keys);
      const normalizedMasterRecord = _.pick(masterRecordList.data[index], keys);
      // ベッドマスタ: 一覧と詳細で数値/文字列の揺れがあると「未変更」でも差分扱いになるため、比較前に揃える
      if (this.masterPhysicalName === "mst_bed") {
        this.applyBedCompareNormalizationForPick(normalizedEditRecord);
        this.applyBedCompareNormalizationForPick(normalizedMasterRecord);
      }
      const recordJson = this.objectToJson(normalizedEditRecord);
      const editRecordJson = this.objectToJson(normalizedMasterRecord);

      if (this.masterPhysicalName === "mst_pat_list_layout") {
        if (editRecord.templateCd === 3) {
          editRecord.dispItemInfo = dispInfo1;
          masterRecordList.data[masterRecordList.data.findIndex(
            masterRecord => masterRecord.code === editRecord.code
          )].dispItemInfo = dispInfo2;
        }
      }

      return recordJson === editRecordJson;
    },
    stringifyJsonToParse(val) {
      return JSON.stringify(JSON.parse(val));
    },
    isEmptyOrNot(val) {
      return val !== null && val !== "" && val !== undefined;
    },
    // mod 11790 抗凝固剤持続総量の計算をするとマイナスになる事がある zkm start
    // saveMasterRecordToStore() {
    async saveMasterRecordToStore() {
      // mod 11790 抗凝固剤持続総量の計算をするとマイナスになる事がある zkm end
      // del #11321 【たくしん会】データリストレイアウトマスタ＞身体情報(追加登録)とデータリスト表示バグ zkm start
      // if (this.masterPhysicalName === "mst_pat_list_layout") {
      //   let editRecordClone = _.cloneDeep(this.editRecord);
      //   let dispItemInfo = JSON.parse(editRecordClone.dispItemInfo);
      //   const index = dispItemInfo.findIndex((item) => {
      //     return item.category === "physical_info";
      //   })
      //   if (index > -1) {
      //     dispItemInfo[index].items = dispItemInfo[index].items.filter((item) => {
      //       return item !== "inspection_date_time";
      //     });
      //     dispItemInfo[index].items.unshift("inspection_date_time");
      //   }
      //   editRecordClone.dispItemInfo = JSON.stringify(dispItemInfo);
      //   this.setEditRecord(editRecordClone);
      // }
      // del #11321 【たくしん会】データリストレイアウトマスタ＞身体情報(追加登録)とデータリスト表示バグ zkm end
      // add #9595 #9542、#9304、#10151仮想スクロールテーブルの再構築 start
      const onRegistration = this.$refs.child.validateOnRegistration;
      if (onRegistration) {
        const validationResult = onRegistration();
        if (!validationResult) return;
      }
      if (["mst_medicine", "mst_exam_item", "mst_taboo_allergy", "mst_job"].includes(this.masterPhysicalName)) {
        if (this.masterPhysicalName === "mst_job") this.setIsMenuSettings(true);
        const editRecord = this.$refs.child.editRecordClone;
        this.setEditRecord(editRecord);
        this.hideModal();
        return;
      }
      // add #9595 #9542、#9304、#10151仮想スクロールテーブルの再構築 end

      if(this.masterPhysicalName === "mst_pat_event_data_template" && this.checkScoreEmpty()){
        // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
        // this.$ons.notification.alert({
        //     title: "チェックエラー",
        //     message: `<div style="text-align:left;">スコアは空にできません。<br> </div>`
        //   });
        this.$ons.notification.alert(`<div style="text-align:left;">${messageFormat(DIALOG_MESSAGES['00200086'].message)}<br> </div>`  , {
          title: DIALOG_MESSAGES['00200086'].title
        });
        // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
        return;
      }

      const masterRecordList = this.getMasterRecordList;

      // state.editRecordを取得
      const editRecord = this.editRecord;

      // 車いすマスタで個人所有に変更の場合
      if(this.masterPhysicalName === "mst_wheel_chair" && editRecord.isPersonal === "1" && !!editRecord.patId){
        const checkResult = await this.checkWheelChairAssigningResult(editRecord);
        if (!checkResult) return;
      }

      // 休日マスタは後続処理で編集状態の設定を実施しているため変更有無チェックをスキップ
      if(this.masterPhysicalName != "mst_holiday") {
        if(this.hasChange(editRecord, masterRecordList)) {
          this.hideModal();
          EventBus.$emit("onCloseMasterEditModal");
          return;
        }
      }

      // operationがないときは編集とみなす
      if (!editRecord.operation) {
        editRecord.operation = 2;
      } else if (editRecord.operation === 1) {
        // "追加"の場合は、"編集済"フラグを立てる
        editRecord.edited = true;
      }
      if( this.masterPhysicalName == "mst_holiday" ) {
        let holiday0s = [];
        let holiday1s = [];
        JSON.parse(editRecord.holiday).forEach(e=> {
          if(e.class == "0") holiday0s.push(e);
          if(e.class == "1") holiday1s.push(e);
          delete e["class"];
        })
        this.getMasterRecordList.data.forEach(element => {
          if(element.year && element.regDate != "" && editRecord.code == element.code) {
            element["operation"] = 2;
            element.holiday = JSON.stringify(holiday0s);
            element.year = editRecord.year;
          }else if (element.year && element.regDate != "" && editRecord.code+1 == element.code) {
            element["operation"] = 2;
            element.holiday = JSON.stringify(holiday1s);
            element.year = editRecord.year;
          }else if ((element.year == ""|| element.regDate == "") && editRecord.code == element.code){
            element.holiday = JSON.stringify(holiday0s);
            element["operation"] = 1;
            element["edited"]= true;
            element.year = editRecord.year
          }else if ((element.year == "" || element.regDate == "") && editRecord.code+1 == element.code){
            element.holiday = JSON.stringify(holiday1s);
            element["operation"] = 1;
            element["edited"]= true;
            element.year = editRecord.year
          }
        });
      }

      // add 11790 抗凝固剤持続総量の計算をするとマイナスになる事がある zkm start
      if ("mst_treatment_set" === this.masterPhysicalName) {
        const indInfo = JSON.parse(editRecord.indCondInfo);
        // mod 11943 抗凝固剤治療指示のバグ修正 追加 zkm start
        // if (_.has(indInfo, "35") && _.has(indInfo, "1") && _.has(indInfo, "36")
        if (_.has(indInfo, "29") && _.has(indInfo, "35") && _.has(indInfo, "1") && _.has(indInfo, "36")
          // mod 11943 抗凝固剤治療指示のバグ修正 追加 zkm end
          && this.hasAntiCoagulantAmountTotalChange(editRecord.code, masterRecordList, indInfo)) {
          // 「1: 入り」なら
          // mod 11943 抗凝固剤治療指示のバグ修正 追加 zkm start
          // if (indInfo["35"].value === '1') {
          if (indInfo["29"].value === '1' && indInfo["35"].value === '1') {
            // mod 11943 抗凝固剤治療指示のバグ修正 追加 zkm end
            if (accSub(indInfo["1"].value, indInfo["36"].value) <= 0) {
              await this.$ons.notification.alert({
                title: DIALOG_MESSAGES[10400014].title,
                message: messageFormat(DIALOG_MESSAGES[10400014].message),
              });
            }
          }
        }
      }
      // add 11790 抗凝固剤持続総量の計算をするとマイナスになる事がある zkm end
      // state.masterRecordListにマージ
      const index = masterRecordList.data.findIndex(
        masterRecord => masterRecord.code === editRecord.code
      );
      if (this.masterPhysicalName != "mst_holiday" )
        masterRecordList.data[index] = editRecord;
      //NO6796 帳票血圧の初期デフォルト値のきおく ljg start
      if (this.masterPhysicalName === "mst_treatment" )
      if(!masterRecordList.data[index].reportGraphSetting)
        masterRecordList.data[index].reportGraphSetting = JSON.stringify(REPORT_GRAPH.DEFAULT_JSON_DATA);
      //NO6796 帳票血圧の初期デフォルト値のきおく ljg end
      // TODO: 対症療法的なので直したい。
      // 配列の要素を入れ替えただけでは、「stateの変更」とみなしてくれず、一覧が再描画されなかった。
      // state.masterRecordListをwatchする（？）
      this.setMasterRecordList(undefined);
      this.setMasterRecordList(masterRecordList);
      // if (this.masterPhysicalName == "mst_job")  this.setIsMenuSettings(true);
      // state.editRecordを空にする
      this.editRecordBeEmpty();
      // モーダルを非表示に
      this.hideModal();

      EventBus.$emit("onCloseMasterEditModal");
    },
    closeMasterEditModal() {
      //mod マスタ詳細画面がありません破棄メッセージ 张博 start
      if (!this.registeredFlag) {
        this.$ons.notification.confirm({
          title: DIALOG_MESSAGES[13000004].title,
          message: messageFormat(DIALOG_MESSAGES[13000004].message),
          callback: (answer) => {
            if (answer === 1) {
              this.sureClose();
            }
          },
        });
      } else {
        this.sureClose();
      }
    },
    //mod マスタ詳細画面がありません破棄メッセージ 张博 end
    // add 11790 抗凝固剤持続総量の計算をするとマイナスになる事がある zkm start
    hasAntiCoagulantAmountTotalChange(code, masterRecordListOrg, indInfo) {

      let editRecord = deepCopy(indInfo);
      let masterRecordList = deepCopy(masterRecordListOrg);

      const masterRecord = masterRecordList.data.filter(
        masterRecord => masterRecord.code === code
      );

      if (masterRecord.length > 0 && masterRecord[0].indCondInfo) {
        masterRecordList = JSON.parse(masterRecord[0].indCondInfo);
      }
      // mod 12183 特定の治療方法で治療時間を変更すると処理中のままになる zkm start
      // const keys = Array.of("1", "35", "36");
      const keys = Array.of("1", "35", "36", "29");
      // mod 12183 特定の治療方法で治療時間を変更すると処理中のままになる zkm end

      const normalizedEditRecord = _.pick(editRecord, keys);
      const normalizedMasterRecord = _.pick(masterRecordList, keys);

      const recordJson = this.objectToJson(normalizedEditRecord);
      const editRecordJson = this.objectToJson(normalizedMasterRecord);

      return recordJson !== editRecordJson;
    },
    // add 11790 抗凝固剤持続総量の計算をするとマイナスになる事がある zkm end
    sureClose(){
      //6641----------------------------------ljg  start
      if(this.main == "mst-pat-viewer-layout" && this.editRecord.dispPeriodClass == 1){
       // state.editRecordを空にする
      this.editRecordBeEmpty();
      // モーダルを非表示に
      setTimeout(() => {
          this.hideModal();
          EventBus.$emit("onCloseMasterEditModal");
        },200);
      //6641------------------------------------ljg  end
      }else{
      // state.editRecordを空にする
      this.editRecordBeEmpty();
      // モーダルを非表示に
      this.hideModal();
      EventBus.$emit("onCloseMasterEditModal");
      }
    },
    // 患者イベントテンプレートマスタ
    checkScoreEmpty(){
      let flag = false;
      const listScoreFormatClass = new Map().set(3, 'score-list').set(4, 'score-radio').set(6,'score-check');
      let textCalcValue = document.getElementById("com-textarea-event-score-calc")?document.getElementById("com-textarea-event-score-calc").value:"";
      if(textCalcValue !== ""){
        let textCalc = new Set(textCalcValue.replace(/\[|\]|\+|-|\*|\\|\//g, " ").split(' '));
        textCalc.delete("");
        for(const item of this.getInputParams){
          if(listScoreFormatClass.has(item.format_class)){
            for(const value of item.item_json.values) {
              if(textCalc.has(item.field_name) && value.score === ""){
                this.changecolor(listScoreFormatClass.get(item.format_class),false);
                flag = true;
                continue;
              }else{
                this.changecolor(listScoreFormatClass.get(item.format_class),true);
              }
            }
          }
        }
      }
      return flag;
    },
    changecolor(className,inIt){
      for(let item of document.getElementsByClassName(className)){
        if(inIt){
          item.firstElementChild.style.backgroundColor = '#F7F7F7';
        }else if(item.value === ""){
          item.firstElementChild.style.backgroundColor = 'red';
        }
      }
    },
    // 車いす共用所有済みチェック
    async checkWheelChairAssigningResult(editRecord){
      let flag = true;
      // 対象車いすに紐づく患者を取得
      const response = await ApiHelper.get(
        `/patInfo/getWheelChairAssigningPatIdList/${this.getFacilitySwitch}/${editRecord.code}`
      ).catch(error => {
        getErrorMessage('MasterEditModal.vue', 'checkWheelChairAssigning', error);
        throw error;
      });

      // 車いすがすでに患者に共用所有されている場合警告
      if(response.data.length > 0){
        await this.$ons.notification.confirm({
          title: DIALOG_MESSAGES[13000171].title,
          message: messageFormat(DIALOG_MESSAGES[13000171].message),
          callback: (answer) => {
            // キャンセル押下時は中断のフラグにする
            if (answer === 0) {
              flag = false;
            }
          },
        });
      }
      return flag;
    },
  },
  beforeDestroy() {
    EventBus.$off( "mstHolidayRegistered", null);
    window.onbeforeprint = null
    window.onafterprint = null
  }
};
</script>

<style scoped>
.mst_alarm_notification,
.mst_destination_group {
  height: 100%;
  padding: 5px 10px 0px;
}
.mst_pat_list_layout {
  height: 100%;
}
.mst_mainte_layout {
  height: 100%;
  overflow-y: auto;
}
</style>
