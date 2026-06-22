/**
 * 治療記録の子機能 治療条件ページ
 */
<template>
  <submenu-base v-if="hasOrdNo">
    <template #main>
      <div id="condition-component">
      <v-ons-list class="treatment-record-accordion">
        <v-ons-list-item expandable v-model:expanded="isExpandedBasic" id="basic-sub">
          <label>治療条件</label>
          <!-- mod FNSI-改修内容背景色 房 start -->
        <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 start-->
<!--          <basic-sub v-model="actualModel.basic" :comboList="treatmentList" :columnList="treatmentColumnList" :hasAuthority="authority" :displayInputValue="displayInputValue" ref="basic-sub" />-->
          <basic-sub v-model="actualModel.basic" :comboList="treatmentList" :columnList="treatmentColumnList" :displayInputValue="displayInputValue" ref="basic-sub" />
        <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 end-->
          <!-- mod FNSI-改修内容背景色 房 end -->
        </v-ons-list-item>
        <v-ons-list-item expandable v-model:expanded="isExpandedDialysate" id="dialysate-sub">
          <label>透析液</label>
          <!-- mod FNSI-改修内容背景色 房 start -->
          <!-- mod FNSI修正 結合バッグ20 房 start -->
        <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 start-->
<!--          <dialysate-sub v-model="actualModel.dialysate" :columnList="treatmentColumnList" :treatmentConditionCd="treatmentConditionCd" :replacementData="actualModel.replacement" :hasAuthority="authority" ref="dialysate-sub" />-->
          <dialysate-sub v-model="actualModel.dialysate" :columnList="treatmentColumnList" :treatmentConditionCd="treatmentConditionCd" :replacementData="actualModel.replacement"  ref="dialysate-sub" />
        <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 end-->
          <!-- mod FNSI修正 結合バッグ20 房 end -->
          <!-- mod FNSI-改修内容背景色 房 end -->
        </v-ons-list-item>
        <v-ons-list-item expandable v-model:expanded="isExpandedReplacement" id="replacement-sub">
          <label>補液</label>
          <!-- mod FNSI-改修内容背景色 房 start -->
          <!-- mod FNSI修正 結合バッグ20 房 start -->
        <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 start-->
<!--          <replacement-sub v-model="actualModel.replacement" :columnList="treatmentColumnList" :treatmentConditionCd="treatmentConditionCd" :hasAuthority="authority" ref="replacement-sub" />-->
          <replacement-sub v-model="actualModel.replacement" :columnList="treatmentColumnList" :treatmentConditionCd="treatmentConditionCd" ref="replacement-sub" />
        <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 end-->
          <!-- mod FNSI修正 結合バッグ20 房 end -->
          <!-- mod FNSI-改修内容背景色 房 end -->
        </v-ons-list-item>
        <v-ons-list-item
          expandable
          v-model:expanded="isExpandedAntiCoagulant"
          id="anti-coagulant-sub"
        >
          <label>抗凝固剤</label>
          <!-- mod FNSI-改修内容背景色 房 start -->
        <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 start-->
<!--          <anti-coagulant-sub v-model="actualModel.antiCoagulant" :authorized="authorized" :columnList="treatmentColumnList" :hasAuthority="authority" ref="anti-coagulant-sub" />-->
              <anti-coagulant-sub v-model="actualModel.antiCoagulant"  :columnList="treatmentColumnList"  ref="anti-coagulant-sub" />
        <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 end-->
          <!-- mod FNSI-改修内容背景色 房 end -->
        </v-ons-list-item>
      </v-ons-list>
      </div>
    </template>
    <template #footer>
      <div class="flex-container treatment-submenu">
      <div class="denial-btn-area">
        <!-- mod FNSI-権限関連 王 20200927 start -->
        <!-- mod FNSI修正 画面スタイル(ボタン)対応 房 start -->
        <v-ons-button class="button denial-btn btn2-cancel" data-non-authorize="true" @click="onClickCancel">キャンセル</v-ons-button>
        <!-- mod FNSI修正 画面スタイル(ボタン)対応 房 end -->
        <!-- mod FNSI-権限関連 王 20200927 end -->
      </div>
      <div class="registration-btn-area">
        <!-- mod FNSI-共有を追加 王 20200921 start -->
        <!-- mod FNSI修正 画面スタイル(ボタン)対応 房 start -->
<!--        mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療記録 20231207 ztc start-->
<!--        <v-ons-button class="button registration-btn btn1-execute" :disabled="!canSave || isReadOnly || !isShared" @click="onClickSave">保存</v-ons-button>-->
        <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 start-->
        <v-ons-button class="button registration-btn btn1-execute" :disabled="!getItemAuthorized('TreatmentRecord', 'default_authority')||isEditable" @click="onClickSave">保存</v-ons-button>
        <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 end-->
<!--        mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療記録 20231207 ztc end-->
        <!-- mod FNSI修正 画面スタイル(ボタン)対応 房 end -->
        <!-- mod FNSI-共有を追加 王 20200921 end -->
      </div>
      </div>
    </template>
  </submenu-base>
</template>

<script>
// add #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療記録 20231207 ztc start
import {mapActions, mapGetters, mapMutations} from "@/compat/vue/vuex";
// add #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療記録 20231207 ztc end
import SubmenuBase from "@/components/treatment-record/SubmenuBaseComponent";
import BasicSubComponent from "@/components/treatment-record/submenu/condition/BasicSubComponent";
import DialysateSubComponent from "@/components/treatment-record/submenu/condition/DialysateSubComponent";
import ReplacementSubComponent from "@/components/treatment-record/submenu/condition/ReplacementSubComponent";
import AntiCoagulantSubComponent from "@/components/treatment-record/submenu/condition/AntiCoagulantSubComponent";
import DiscardConfirmationMixin from "@/components/treatment-record/DiscardConfirmationMixin";
//#10359 mod 編集権限の動作不正 2024-06-05 卓 start
// import ComponentGuardMixin from "@/components/common/ComponentGuardMixin";
import { Basic } from "@/models/treatment-record/condition/Basic";
import { Dialysate } from "@/models/treatment-record/condition/Dialysate";
import { Replacement } from "@/models/treatment-record/condition/Replacement";
import { AntiCoagulant } from "@/models/treatment-record/condition/AntiCoagulant";
// import { AUTHORITY_CODES } from "@/constants/userAuthority";
import { EventBus } from "@/compat/vue/event-bus.js";
import { CODES } from "@/constants/TreatmentRecord";
// mod #11471 ord_mian操作時の治療モードデータの登録 関 start
// add FNSI-改修内容背景色修正 房 start
import {
  sendRequestGetReportInfoByOrdNoWithLoader,
  sendRequestGetGetRstCondInfoSettingByOrdNo
} from "@/apis/treatment-record";
// add FNSI-改修内容背景色修正 房 end
// mod #11471 ord_mian操作時の治療モードデータの登録 関 end
import {
  sendRequestGetMstMedicineClass,
  getMedicineAllTabooAllergy,
  sendRequestGetMstEquipmentTabooAllergy,
  sendRequestGetMstDialyzerTabooAllergy
} from "@/apis/treatment-record";
//FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
import {getErrorMessage} from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
// add #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療記録 20240111 ztc start
import {getAuthorized} from "@/functions/common/CommonFunctions";
import { getScopedElementsByClassName } from "@/functions/common/LayoutMeasureHelper";
// add #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療記録 20240111 ztc end
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
//#10359 mod 編集権限の動作不正 2024-06-05 卓 end

export default {
//#10359 mod 編集権限の動作不正 2024-06-05 卓 start
  // mixins: [DiscardConfirmationMixin, ComponentGuardMixin],
  mixins: [DiscardConfirmationMixin],
//#10359 mod 編集権限の動作不正 2024-06-05 卓 end
  components: {
    "submenu-base": SubmenuBase,
    "basic-sub": BasicSubComponent,
    "dialysate-sub": DialysateSubComponent,
    "replacement-sub": ReplacementSubComponent,
    "anti-coagulant-sub": AntiCoagulantSubComponent,
  },
  data() {
    return {
      originalCondition: null,
      comparisonModel: "",
      actualModel: {
        basic: null,
        dialysate: null,
        replacement: null,
        antiCoagulant: null,
      },
      isExpandedBasic: false,
      isExpandedDialysate: false,
      isExpandedReplacement: false,
      isExpandedAntiCoagulant: false,
      treatmentList: undefined,
      //#10359 mod 編集権限の動作不正 2024-06-05 卓 start
      // authorityCds: [ AUTHORITY_CODES.RST_PEDIT, AUTHORITY_CODES.RST_EDIT ],
      //#10359 mod 編集権限の動作不正 2024-06-05 卓 end
      selfScreenName:"",
      // add FNSI-改修内容背景色修正 房 start
      treatmentColumnList: undefined,
      // add FNSI-改修内容背景色修正 房 end
      // add 9342 治療記録の治療条件で無効項目が編集不可となった。　吉 start
      filteredCtlNos:[],
      // add 9342 治療記録の治療条件で無効項目が編集不可となった。　吉 end
      //add メッセージ順番修正 房 start
      alertFlag: true,
      //add メッセージ順番修正 房 end
      //add FNSI修正 結合バッグ20 房 start
      treatmentConditionCd: null,
      //add FNSI修正 結合バッグ20 房 end
      //#10359 mod 編集権限の動作不正 2024-06-05 卓 start
      // authority:null,
      //#10359 mod 編集権限の動作不正 2024-06-05 卓 end
      // add 6668 治療時間が72時間まで入力できない 房 start
      displayInputValue:{
        initValue: null,
        editValue: null
      },
      // add 6668 治療時間が72時間まで入力できない 房 end
      // add 10824 治療記録>治療条件を編集するとord_mainのrst_cond_infの一部がnullになる 関 start
      dialyzerInfo: null,
      equipmentInfo: null,
      mstMedicineInfo: null,
      mstMedicineMixInfo: null,
      // add 10824 治療記録>治療条件を編集するとord_mainのrst_cond_infの一部がnullになる 関 end
    };
  },
  computed: {
    ...mapGetters("treatment-record/common", ["getOrdNo", "getOrd"]),
    // add FNSI-共有を追加 王 20200921 start
    ...mapGetters("user", ["getFacilityCd"]),
    ...mapGetters("treatment-record/common", ["getSharedFacilityCd"]),
    ...mapGetters("mst-user", {getSharedFlag: "getIsRegisteredShared"}),
    ...mapGetters("user", {facilityCd: "getFacilityCd"}),
    isShared() {
      return this.getFacilityCd === this.getSharedFacilityCd;
    },
    // add FNSI-共有を追加 王 20200921 end
    /**
     * データの編集があるかどうか.
     */
    isChanged() {
      if (this.comparisonModel && this.actualModel) {
        return !this.compareObjects(this.comparisonModel,this.actualModel)
      } else {
        return false;
      }
    },
    /**
     * 保存ボタンがクリックできるかどうか.
     */
    canSave() {
      return this.isChanged;
    },

    isReadOnly() {
      return this.getOrd.readOnly;
    },
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療記録 20231207 ztc start
    isEditable(){
      this.setIsPatInfoChaned(!(this.isReadOnly || !this.isShared || !this.canSave))
    //#10359 mod 編集権限の動作不正 2024-06-05 卓 start
      return !getAuthorized("TreatmentRecord","default_authority") || (this.isReadOnly || !this.isShared || !this.canSave);
    //#10359 mod 編集権限の動作不正 2024-06-05 卓 end
    }
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療記録 20231207 ztc end
  },
  methods: {
    ...mapActions("treatment-record/condition", [
      "getTreatmentRecordCondition",
      "updateTreatmentRecordCondition"
    ]),
    ...mapActions("reference-combo", ["getTreatmentMethodComboList"]),
    ...mapGetters("pat-info", ["selectedPatId"]),
    ...mapActions("treatment-record/common", ["getMstMachineByOrdNoRst","sendRequestChangeTreatTime"]),
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療記録 20231207 ztc start
    ...mapMutations("pat-info", ["setIsPatInfoChaned"]),
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療記録 20231207 ztc end
	//#10359 mod 編集権限の動作不正 2024-06-05 卓 start
    getItemAuthorized(pageCd, itemCd) {
      return getAuthorized(pageCd, itemCd);
    },
	//#10359 mod 編集権限の動作不正 2024-06-05 卓 end
    /**
     * 初期化処理（"治療条件"取得）.
     */
    async init() {
      if (!this.getOrdNo) {
        return;
      }
      Promise.all([
        this.getTreatmentRecordCondition({
          ordNo: this.getOrdNo,
          selectedPatId: this.selectedPatId()
        }),
        this.getTreatmentMethodComboList({ selectedPatId: this.selectedPatId() }),
        sendRequestGetMstEquipmentTabooAllergy(this.selectedPatId()),
        sendRequestGetMstDialyzerTabooAllergy(this.selectedPatId()),
        //add 10823 治療記録>治療条件で別治療日の内容を表示すると緑枠で表示されることがある 張玲 start
        sendRequestGetReportInfoByOrdNoWithLoader(this.getOrdNo, this.selectedPatId()),
        //add 10823 治療記録>治療条件で別治療日の内容を表示すると緑枠で表示されることがある 張玲 end
        // add #11471 ord_mian操作時の治療モードデータの登録 関 start
        sendRequestGetGetRstCondInfoSettingByOrdNo(this.getOrdNo, this.selectedPatId())
        // add #11471 ord_mian操作時の治療モードデータの登録 関 end
      ]).then(async(response) => {
        this.originalCondition = response[0].data;
        this.treatmentList = response[1].data;
        // mod 10824 治療記録>治療条件を編集するとord_mainのrst_cond_infの一部がnullになる 関 start
        // const equipmentInfo = response[2].data;
        // const dialyzerInfo = response[3].data;
        this.equipmentInfo = response[2].data;
        this.dialyzerInfo = response[3].data;
        // mod 10824 治療記録>治療条件を編集するとord_mainのrst_cond_infの一部がnullになる 関 end
        // mod #11471 ord_mian操作時の治療モードデータの登録 関 start
        //add 10823 治療記録>治療条件で別治療日の内容を表示すると緑枠で表示されることがある 張玲 start
        // this.treatmentColumnList = JSON.parse(response[4].data.treatmentConditionSetting);
        this.treatmentColumnList = JSON.parse(response[5].data.treatmentConditionSetting);
        // mod #11471 ord_mian操作時の治療モードデータの登録 関 end
        if (null != this.treatmentColumnList) {
          this.filteredCtlNos = this.treatmentColumnList
            .flatMap(obj => obj.items)
            .filter(item => item.is_use === "0")
            .map(item => item.ctl_no)
            .flat();
        }
        //add 10823 治療記録>治療条件で別治療日の内容を表示すると緑枠で表示されることがある 張玲 end

        const condInfo = JSON.parse(this.originalCondition.rst_cond_info);
        // add 9360 抗凝固剤のワンショット量・持続速度・持続総量の保存が正しくできない zhou start
        //mod FNSI-9369 ljx start
        // if (condInfo[25]!== undefined && condInfo[25].medicine_type == CODES.MEDICINE_TYPE.MIX.cd) {
        //   condInfo[25].value = condInfo[25].value + "$";
        // }
        //<!--// add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start-->
        //if (condInfo && condInfo[25]!== undefined && condInfo[25].medicine_type == CODES.MEDICINE_TYPE.MIX.cd) {
          //condInfo[25].value = condInfo[25].value + "$";
        //}
        //<!--// add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end-->
        //mod FNSI-9369 ljx end
        // add 9360 抗凝固剤のワンショット量・持続速度・持続総量の保存が正しくできない zhou end
        const treatmentCd = this.originalCondition.rst_treatment_cd;
        //add FNSI修正 結合バッグ20 房 start
        this.treatmentConditionCd = this.originalCondition.device_mode;
        //add FNSI修正 結合バッグ20 房 end
        const treatmentName = this.originalCondition.rst_treatment_name;

        this.originalCondition.rst_cond_info = condInfo ? condInfo : {};
        this.actualModel.basic = new Basic(
          this.originalCondition.ind_treat_start_time,
          condInfo,
          this.originalCondition.rst_dw,
          treatmentCd,
          treatmentName
        );
        // add 6668 治療時間が72時間まで入力できない 房 start
        //mod FNSI-9369 ljx start
        // this.displayInputValue.initValue = this.originalCondition.rst_cond_info[1].value;
        // this.displayInputValue.editValue = this.originalCondition.rst_cond_info[1].value;
        this.displayInputValue.initValue = this.originalCondition.rst_cond_info[1]?this.originalCondition.rst_cond_info[1].value:null;
        this.displayInputValue.editValue = this.originalCondition.rst_cond_info[1]?this.originalCondition.rst_cond_info[1].value:null;
        //mod FNSI-9369 ljx end
        // add 6668 治療時間が72時間まで入力できない 房 end
        // 医療材料・ダイアライザ―の名称を置き換える
        //FNSI#5678-修正 治療条件のデータがマスタに参照ではなく、実績より取得。 del  ljx  start
        /* this.actualModel.basic.adsorptionColumn.name = this.actualModel.basic.adsorptionColumn.cd ?
           equipmentInfo.filter(e => {
             return e.equipmentCd === this.actualModel.basic.adsorptionColumn.cd;
           }).length > 0 ? equipmentInfo.filter(e => {
               return e.equipmentCd === this.actualModel.basic.adsorptionColumn.cd;
             })[0].equipmentName : "" :
            "";
         this.actualModel.basic.primaryFilm.name = this.actualModel.basic.primaryFilm.cd ?
           equipmentInfo.filter(e => {
             return e.equipmentCd === this.actualModel.basic.primaryFilm.cd;
           }).length > 0 ? equipmentInfo.filter(e => {
               return e.equipmentCd === this.actualModel.basic.primaryFilm.cd;
             })[0].equipmentName : "" :
            "";
         this.actualModel.basic.secondaryFilm.name = this.actualModel.basic.secondaryFilm.cd ?
           equipmentInfo.filter(e => {
             return e.equipmentCd === this.actualModel.basic.secondaryFilm.cd;
           }).length > 0 ? equipmentInfo.filter(e => {
               return e.equipmentCd === this.actualModel.basic.secondaryFilm.cd;
             })[0].equipmentName : "" :
            "";
         this.actualModel.basic.punctureNeedleA.name = this.actualModel.basic.punctureNeedleA.cd ?
           equipmentInfo.filter(e => {
             return e.equipmentCd === this.actualModel.basic.punctureNeedleA.cd;
           }).length > 0 ? equipmentInfo.filter(e => {
             return e.equipmentCd === this.actualModel.basic.punctureNeedleA.cd;
           })[0].equipmentName : "" :
            "";
         this.actualModel.basic.punctureNeedleV.name = this.actualModel.basic.punctureNeedleV.cd ?
           equipmentInfo.filter(e => {
             return e.equipmentCd === this.actualModel.basic.punctureNeedleV.cd;
           }).length > 0 ? equipmentInfo.filter(e => {
               return e.equipmentCd === this.actualModel.basic.punctureNeedleV.cd;
             })[0].equipmentName : "" :
            "";
         this.actualModel.basic.punctureNeedleSn.name = this.actualModel.basic.punctureNeedleSn.cd ?
           equipmentInfo.filter(e => {
             return e.equipmentCd === this.actualModel.basic.punctureNeedleSn.cd;
           }).length > 0 ? equipmentInfo.filter(e => {
               return e.equipmentCd === this.actualModel.basic.punctureNeedleSn.cd;
             })[0].equipmentName : "" :
            "";
         this.actualModel.basic.bloodCircuit.name = this.actualModel.basic.bloodCircuit.cd ?
           equipmentInfo.filter(e => {
             return e.equipmentCd === this.actualModel.basic.bloodCircuit.cd;
           }).length > 0 ? equipmentInfo.filter(e => {
               return e.equipmentCd === this.actualModel.basic.bloodCircuit.cd;
             })[0].equipmentName : "" :
            "";

         this.actualModel.basic.dialyzer.name = this.actualModel.basic.dialyzer.cd ?
           dialyzerInfo.filter(d => {
             return d.dialyzerCd === this.actualModel.basic.dialyzer.cd;
           }).length > 0 ? dialyzerInfo.filter(d => {
             return d.dialyzerCd === this.actualModel.basic.dialyzer.cd;
           })[0].modelNumber : "" :
            "";*/
        //FNSI#5678-修正 治療条件のデータがマスタに参照ではなく、実績より取得。 del  ljx  end

        // 最新の薬剤を取得
        // TODO 薬剤セットマスタを考慮してない。必要があれば実装する
        const medicineAndClassResponse = await this.fetchMedicineAll();
        const medicine = medicineAndClassResponse[0].data;

        const mstMedicine = medicine.filter(m => {
          // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
          //return m.medicineType === CODES.MEDICINE_TYPE.NORMAL.cd;
          return m.medicineType == CODES.MEDICINE_TYPE.NORMAL.cd;
          // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
        });
        const mstMedicineMix = medicine.filter(m => {
          // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
          //return m.medicineType === CODES.MEDICINE_TYPE.MIX.cd;
          return m.medicineType == CODES.MEDICINE_TYPE.MIX.cd;
          // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
        });
        // add 10824 治療記録>治療条件を編集するとord_mainのrst_cond_infの一部がnullになる 関 start
        this.mstMedicineInfo = mstMedicine;
        this.mstMedicineMixInfo = mstMedicineMix;
        // add 10824 治療記録>治療条件を編集するとord_mainのrst_cond_infの一部がnullになる 関 end

        this.actualModel.dialysate = new Dialysate(condInfo,mstMedicine,mstMedicineMix);
        this.actualModel.replacement = new Replacement(condInfo,mstMedicine,mstMedicineMix);
        this.actualModel.antiCoagulant = new AntiCoagulant(condInfo,mstMedicine,mstMedicineMix);
        this.comparisonModel = JSON.parse(JSON.stringify(this.actualModel));
        if (this.treatmentConditionCd == 7 || this.treatmentConditionCd == 8 || this.treatmentConditionCd == 10) {
          if (this.comparisonModel.replacement != undefined && this.comparisonModel.replacement != null) {
            if (this.actualModel.dialysate != undefined && this.actualModel.dialysate != null) {
              this.comparisonModel.replacement.replacement.cd = this.actualModel.dialysate.dialysate.cd;
              this.comparisonModel.replacement.replacement.name = this.actualModel.dialysate.dialysate.name;
            }
          }
        }
        // 治療方法コンボとの突合
        // コンボリスト内に該当のord_mainの治療方法が存在するか否か
        const contain =
          this.treatmentList.find(
            e => e.cd === treatmentCd && e.text === treatmentName
          ) !== undefined;
        if (!contain) {
          // 削除/名称変更されたコード
          this.treatmentList.unshift({
            cd: treatmentCd,
            text: treatmentName,
            hidden: true
          });
        }
        // アコーディオン開く
        this.isExpandedBasic = true;
        this.isExpandedDialysate = true;
        this.isExpandedReplacement = true;
        this.isExpandedAntiCoagulant = true;
      });
    },
    /**
     * 再初期化処理.
     */
    refresh() {
      // 子機能ボタンエリアの更新
      this.$emit("update");
      if (this.selfScreenName !== this.$route.name) {
        return;
      }
      //mod #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。 張玲 start
      //mod メッセージ順番修正 房 start
      // if (this.isChanged && this.alertFlag) {
      //   this.discardConfirm(this.init);
      // } else {
      //   this.init();
      // }
      this.init();
      //mod #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。 張玲 end
      this.alertFlag = true;
      //mod メッセージ順番修正 房 end
    },
    // add #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。zhangyue start
    eventBusRefresh() {
      if (this.selfScreenName !== this.$route.name) {
        return;
      }
      if (this.isChanged && this.alertFlag) {
        this.discardConfirm(this.init);
      } else {
        this.init();
      }
      this.alertFlag = true;
    },
    // add #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。zhangyue end
    /**
     * "保存"ボタンクリックハンドラ.
     */
    onClickSave() {
      if(this.isReadOnly) {
        return;
      }
      const copyObject = JSON.parse(JSON.stringify(this.originalCondition));
      //変更前の治療時間を取得。
      /* mod by shiyw 2024-03-18 #10196 ord_mainのデータ定義の修正:？？患者场合ord_main.rst_cond_info为null --start */
      //const oldTreatTime = copyObject.rst_cond_info[1].value;
      const oldTreatTime = copyObject.rst_cond_info[1]?.value;
      /* mod by shiyw 2024-03-18 #10196 ord_mainのデータ定義の修正:？？患者场合ord_main.rst_cond_info为null --end */
      if (this.actualModel.basic.singleNeedle == null) {
        this.actualModel.basic.punctureNeedleA.name = null;
        this.actualModel.basic.punctureNeedleA.cd = null;
        this.actualModel.basic.punctureNeedleV.name = null;
        this.actualModel.basic.punctureNeedleV.cd = null;
        this.actualModel.basic.punctureNeedleSn.name = null;
        this.actualModel.basic.punctureNeedleSn.cd = null;
      }
      // mod 10824 治療記録>治療条件を編集するとord_mainのrst_cond_infの一部がnullになる 関 start
      // this.actualModel.basic.reflect(copyObject);
      // this.actualModel.dialysate.reflect(copyObject);
      // this.actualModel.replacement.reflect(copyObject);
      // this.actualModel.antiCoagulant.reflect(copyObject);

      this.actualModel.basic.reflect(copyObject, this.comparisonModel.basic, this.actualModel.basic
      , this.dialyzerInfo, this.equipmentInfo);
      this.actualModel.antiCoagulant.reflect(copyObject, this.comparisonModel.antiCoagulant, this.actualModel.antiCoagulant, this.mstMedicineInfo, this.mstMedicineMixInfo);
      // mod 10824 治療記録>治療条件を編集するとord_mainのrst_cond_infの一部がnullになる 関 end
      // mod #10824 透析液エリアの変更値設定修正 zkm start
      this.actualModel.dialysate.reflect(copyObject, this.comparisonModel.dialysate, this.actualModel.dialysate);
      this.actualModel.replacement.reflect(copyObject, this.comparisonModel.replacement, this.actualModel.replacement);
      // mod #10824 透析液エリアの変更値設定修正 zkm end
      // 変更有無のチェック
      /* modify by chamaojia 2023-10-27 [9973] ループのオブジェクト変更、A針/V針とSN針排他後に必要 --start */
      Object.keys(copyObject.rst_cond_info).forEach(key => {
        const src = this.originalCondition.rst_cond_info[key];
        const target = copyObject.rst_cond_info[key];
        /* modify by chamaojia 2024-01-31 [10196] The database has removed this content --start */
        if (src !== undefined) {
        //   target.ind_user_id = this.getStateUserAccountInfo().userId;
        //   target.ind_user_last_name = this.getStateUserAccountInfo().userLastName;
        //   target.ind_user_first_name = this.getStateUserAccountInfo().userFirstName;
        // } else {
        if (
              src.value != target.value ||
          src.value_name_1 !== target.value_name_1 ||
          src.unit !== target.unit
        ) {
          // add 9342 治療記録の治療条件で無効項目が編集不可となった。　吉 start
          if(this.filteredCtlNos.includes(key) && target.value == null){
            delete copyObject.rst_cond_info[key];
          }
          // else{
          //   // add 9342 治療記録の治療条件で無効項目が編集不可となった。　吉 end
          //   target.upd_user_id = this.getStateUserAccountInfo().userId;
          //   target.upd_user_last_name = this.getStateUserAccountInfo().userLastName;
          //   target.upd_user_first_name = this.getStateUserAccountInfo().userFirstName;
          //   // add 9342 治療記録の治療条件で無効項目が編集不可となった。　吉 start
          // }
          // add 9342 治療記録の治療条件で無効項目が編集不可となった。　吉 end
        }
        }
        /* modify by chamaojia 2024-01-31 [10196] The database has removed this content --end */
      });
      /* modify by chamaojia 2023-10-27 [9973] ループのオブジェクト変更、A針/V針とSN針排他後に必要 --end */
      //変更後の治療時間を取得。
      // mod 11454 時間外加算自動処理が機能していない zkm start
      // const newTreatTime = copyObject.rst_cond_info[1].value;
      const newTreatTime = !copyObject.rst_cond_info[1] ? oldTreatTime : copyObject.rst_cond_info[1].value;
      // mod 11454 時間外加算自動処理が機能していない zkm end
      copyObject.rst_dw = this.actualModel.basic.dw;
      // del #9973 shiyw start
      //mod 9342 ljx start
      //if (typeof copyObject.rst_cond_info[17].value === "string") {
      //if (typeof copyObject.rst_cond_info[17]?.value === "string") {
      //  //mod 9342 ljx end
      //  copyObject.rst_cond_info[17].value = Number(copyObject.rst_cond_info[17].value);
      //}
      // del #9973 shiyw end
      const payload = {
        ordNo: this.getOrdNo,
        treatmentRecordCondition: copyObject
      };
      copyObject.rst_cond_info = JSON.stringify(copyObject.rst_cond_info);

      this.updateTreatmentRecordCondition(payload)
        .then(() => {
          // 初期化処理を実行
          this.init();
          // 子機能ボタンエリアの更新
          this.$emit("update");
        })
        .catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
          getErrorMessage('IndicationConditionComponent.vue','onClickSave','必須項目が入力されていません。');
          //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
          if (error.response.status === 400) {
            this.$ons.notification.alert({
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // title: "更新失敗",
              // message: "必須項目が入力されていません。"
              title: DIALOG_MESSAGES['00200070'].title,
              message: messageFormat(DIALOG_MESSAGES['00200070'].message)
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
            });
          }
        });
      let elements = getScopedElementsByClassName("custom-input-edited", this.$el || this);
      for (let i = elements.length-1; i >= 0; i--) {
        elements[i].classList.remove("custom-input-edited");
      }
      if (this.$refs['basic-sub'] != undefined) {
        this.$refs['basic-sub'].initValueEdit();
      }
      if (this.$refs['dialysate-sub'] != undefined) {
        this.$refs['dialysate-sub'].initValueEdit();
      }
      if (this.$refs['replacement-sub'] != undefined) {
        this.$refs['replacement-sub'].initValueEdit();
      }
      if (this.$refs['anti-coagulant-sub'] != undefined) {
        this.$refs['anti-coagulant-sub'].initValueEdit();
      }

      if(oldTreatTime !== newTreatTime){
        //治療時間が変更される場合、デバイスエッジへ通知。
      this.getMstMachineByOrdNoRst({
        ordNo: this.getOrdNo,
        selectedPatId: this.selectedPatId()
      }).then(machineRes => {
        const params = {
          ordNo: this.getOrdNo, //オーダー番号
          machineNo: machineRes.data[0].machineNo, //装置マスタ.装置番号
          deviceEdgeNo: machineRes.data[0].deviceEdgeNo, //デバイスエッジ番号
          facilityCd: this.facilityCd //施設コード
        };
        try {
          this.sendRequestChangeTreatTime(params);
        } catch (e) {

          getErrorMessage('MedicineComponent.vue','updateMediInfo',e)

          this.$ons.notification.alert({
            modifier: "warn",
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
            // title: "送信に失敗しました",
            // message: `装置へ送信に失敗しました。`
            title: DIALOG_MESSAGES['00200033'].title,
            message: messageFormat(DIALOG_MESSAGES['00200033'].message),
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
          });
        }
      });
    }
    },
    //mod 内結バッグNo.67修正 房 start
    /**
     * "キャンセル"ボタンクリックハンドラ.
     */
    onClickCancel() {
      // 編集済みであれば確認ダイアログを表示して初期化処理を実行
      if (this.isChanged) {
        this.discardConfirm(this.backTreatmentRecord);
      } else {
        this.backTreatmentRecord();
      }
    },
    /**
     * 治療記録のトップ画面に遷移.
     */
    backTreatmentRecord() {
      // 画面遷移前に変更内容を同期する.
      // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療記録 20231207 ztc start
      // this.comparisonModel = JSON.stringify(this.actualModel);
      this.comparisonModel = JSON.parse(JSON.stringify(this.actualModel));
      this.eventBusRefresh();
      // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療記録 20231207 ztc end
      // this.$nextTick(() => {
      //   this.$router.push({ name: "treatment-record" });
      // });
    },
    //mod 内結バッグNo.67修正 房 end
    /**
     * 薬剤（薬剤マスタと調整薬剤マスタ）、薬剤分類マスタを取得する.
     */
    fetchMedicineAll() {
      const patId = this.selectedPatId();
      return Promise.all([
        getMedicineAllTabooAllergy(patId),
        sendRequestGetMstMedicineClass(this.selectedPatId())
      ]);
    },
    //add メッセージ順番修正 房 start
    getChangeStatus(){
      return this.isChanged;
    },
    updateChangeStatus(){
      this.alertFlag = false;
    },
    //add メッセージ順番修正 房 end
    //#10359 mod 編集権限の動作不正 2024-06-05 卓 start
    // getTreatmentRecordAuthority() {
    //   return this.hasAuthorityByCd(AUTHORITY_CODES.RST_PEDIT) || this.hasAuthorityByCd(AUTHORITY_CODES.RST_EDIT);
    // },
    //#10359 mod 編集権限の動作不正 2024-06-05 卓 end
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療記録 20240111 ztc start
    compareObjects(obj1, obj2) {
      if (this.isJSON(obj1)) {
        obj1 = JSON.parse(obj1)
      }
      if (this.isJSON(obj2)) {
        obj2 = JSON.parse(obj2)
      }

      // 基本型(文字列、数字など)の場合は、そのまま等価比較をします。
      if (!this.isObject(obj1)) {
        if (this.isNumber(obj1) && this.isNumber(obj2)) {
          return Number(obj1) == Number(obj2);
        }
        return obj1 == obj2;
      }

      if (obj1.length !== obj2.length) {
        return false;
      }
      // 1つ目のオブジェクトの属性名を全て取得します
      const keys = Object.keys(obj1);
      // 属性を横断して深さを比較します
      for (let key of keys) {
        if (!this.compareObjects(obj1[key], obj2[key])) {
          return false;
        }
      }
      return true;
    },
    isObject(value) {
      return value && typeof value === 'object';
    },
    isJSON(str) {
      try {
        JSON.parse(str);
        return true;
      } catch (e) {
        return false;
      }
    },
    isNumber(str) {
      return !isNaN(parseFloat(str)) && isFinite(str);
    },
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療記録 20240111 ztc end
  },
  async created() {
    // 画面名称取得
    this.selfScreenName = this.$route.name;
    EventBus.$on("refresh", this.eventBusRefresh);

    // OrdMainレコードをチェックする
    if (!this.checkOrdNo()) {
      return;
    }
    //del 10823 治療記録>治療条件で別治療日の内容を表示すると緑枠で表示されることがある 張玲 start
    // add FNSI-改修内容背景色修正 房 start
    // await sendRequestGetReportInfoByOrdNoWithLoader(this.getOrdNo).then(res => {
    //   this.treatmentColumnList = JSON.parse(res.data.treatmentConditionSetting);
    //   // add 9342 治療記録の治療条件で無効項目が編集不可となった。　吉 start
    //   // "is_use": "0"に関するctl_noのデータを抽出する
    //   //mod 9324 checklist ???患者の治療方法の判定 gjn start
    //   if(null != this.treatmentColumnList) {
    //     this.filteredCtlNos = this.treatmentColumnList
    //       .flatMap(obj => obj.items)
    //       .filter(item => item.is_use === "0")
    //       .map(item => item.ctl_no)
    //       .flat();
    //   }
    //   //mod 9324 checklist ???患者の治療方法の判定 gjn end
    //   // add 9342 治療記録の治療条件で無効項目が編集不可となった。　吉 end
    // });
    // add FNSI-改修内容背景色修正 房 end
    //del 10823 治療記録>治療条件で別治療日の内容を表示すると緑枠で表示されることがある 張玲 end

    // 治療記録(治療条件取得)
    await this.init();
  },
  // add FNSI-共有を追加 王 20200921 start
  mounted() {
    const selectBtn = getScopedElementsByClassName("button select-btn", this.$el || this);
    if (this.getSharedFacilityCd !== undefined && this.getSharedFacilityCd != null) {
      if (this.getSharedFlag === 1 && this.facilityCd !== this.getSharedFacilityCd) {
        for (let i = 0; i < selectBtn.length; i++) {
         selectBtn[i].disabled = true ;
        }
      } else {
        for (let i = 0; i < selectBtn.length; i++) {
         selectBtn[i].disabled = false ;
        }
      }
    } else {
      for (let i = 0; i < selectBtn.length; i++) {
      selectBtn[i].disabled = false ;
      }
    }
  },
  // add FNSI-共有を追加 王 20200921 end
  /**
   * コンポーネント破棄
   */
  beforeUnmount() {
    // イベント解除
    // del refresh方法処理不正について、対応する。 dengshen start
    // EventBus.$off("refresh");
    // del refresh方法処理不正について、対応する。 dengshen end
    // add #9271 他の画面への切り替え時のパンくずクリックは有効になりません。 linjunfeng start
    // mod #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。zhangyue start
    // EventBus.$off("refresh", this.refresh);
    EventBus.$off("refresh", this.eventBusRefresh);
    // mod #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。zhangyue end
    // add #9271 他の画面への切り替え時のパンくずクリックは有効になりません。 linjunfeng end
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  }
};
</script>
<style scoped>
  :deep(ons-checkbox.checkbox) {
    margin-top: 0;
  }
  .treatment-record-accordion {
    overflow: hidden;
  }
  #basic-sub {
    overflow: hidden;
    border: 1px solid #dddddd;
  }
  #dialysate-sub {
    overflow: hidden;
    border: 1px solid #dddddd;
  }
  #replacement-sub {
    overflow: hidden;
    border: 1px solid #dddddd;
  }
  #anti-coagulant-sub {
    overflow: hidden;
    border: 1px solid #dddddd;
  }
</style>
