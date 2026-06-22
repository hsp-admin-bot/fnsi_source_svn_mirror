/** * 治療条件ー透析液 */

<template>
  <!-- mod 9664補液及び透析液仕様修正します yangqingzhe start -->
  <!-- <v-ons-row> -->
    <v-ons-row :class="getIsUseFlagDialysate ? 'cell-disabled' : ''">
  <!-- mod 9664補液及び透析液仕様修正します yangqingzhe end -->
    <v-ons-col class="action-condition-column">透析液</v-ons-col>
    <v-ons-col class="action-condition-data-column" style="display: flex;">
      <common-master-selector
        :masterType="MasterType.MEDICATION_TREATMENT_CLASSTYPE_RECORD"
        :initItem="equipmentSelectorInitItem"
        :editItem="{ text: displayInputValue.editValue, value: displayInputValue.editCd, unit: rstUnitForCd, unitSecond: receiptUnitForCd }"
        :patientId="selectedPatId"
        :extraParams="{
          treatDate: mstExtraParams.treatDate,
          rstInfo: mstExtraParams.rstInfo,
          classType: 2,
          initValue: displayInputValue.initCd,
          medicineType: medicineType,
          actualName: rstNameForCd,
          receiptUnit: receiptUnitForCd,
          compareReceiptUnit: true
        }"
        :facilityCd="facilityCd"
        :isMedicament="'1'"
        :hasChangedOption="true"
        :changeOptionMode="'nameAndUnit'"
        :dialysisState="Number(rstDialysisState || 0)"
        :selectedItemClass="'com-basic-sub-input'"
        :backgroundColor="'#f7f7f7'"
        :btnClass="'com-basic-sub-btn'"
        :btnDisabled="getIsUseFlagDialysate || !getItemAuthorized('Indication', 'default_authority')"
        @popover-return="masterUpdateInput($event);"
      />
    </v-ons-col>
  </v-ons-row>
</template>

<script>
// add #10359 編集権限の動作不正 dengshen start
// #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
// import { getAuthorized } from "@/functions/common/CommonFunctions.js";
import { getAuthorized, getPrefix } from "@/functions/common/CommonFunctions.js";
// #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
// add #10359 編集権限の動作不正 dengshen end
import { mapMutations, mapGetters } from "@/compat/vue/vuex";
import { medicineAllergy, medicineClass, medicineIncludeDeleted, medicineMixAllergy, medicineMixIncludeDeleted, medicineMixTabooAllergyByCd, medicineTabooAllergyByCd } from "@/functions/mst/MstGetters.js";
import IndTreatCondBase from "@/components/indication/IndTreatCondBase";
import { MASTER_MAINTENANCE_CURRENT_ROUTE_NAME } from "@/constants/masterMaintenanceConstants";
import { PATVIEWER_CURRENT_ROUTE_NAME } from "@/constants/PatViewerConstants";
import { fitTermCheck } from "@/functions/common/DateTimeUtils";
//FNSI-修正 VUEのエラー場合のログ対応 liuimx add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 liuimx add end
import { ApiHelper } from "@/apis/AxiosHelper";
//mod FutreNetWeb+SI課題管理 NO.4878 劉全航 start
import { MASTER_DELETE_DISPLAY } from "@/constants/TreatmentRecord.js";
//mod FutreNetWeb+SI課題管理 NO.4878 劉全航 end
//add FutreNetWeb+SI課題管理 NO.5323 劉全航 start
import dayjs from "@/compat/date/dayjs";
//add FutreNetWeb+SI課題管理 NO.5323 劉全航 end
import {EventBus} from "@/compat/vue/event-bus.js";
// #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
import { CODES } from "@/constants/TreatmentRecord";
import { DEVICEMODE } from "@/constants/mstTreatmentDefine.js";
import IndicationOwnerMixin from '@/components/indication/IndicationOwnerMixin';
import commonMasterSelector from "@/components/common/master-selector/CommonMasterSelector.vue";
import * as MasterType from "@/components/common/master-selector/MasterType";
import { buildMasterPopover } from "@/components/common/master-selector/builder/builderFactory";
// #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
export default {
  mixins: [IndicationOwnerMixin, IndTreatCondBase],
  components: {
    "common-master-selector": commonMasterSelector,
  },

  data() {
    return {
      kbnValue: "",
      mstExtraParams: {
        treatDate: "",
        rstInfo: {
          rstName: "",
          rstUnit: ""
        }
      },
      MasterType,
      displayInputValue: {
        initValue: null,
        editValue: null,
        text: "",
        editCd: "",
        initCd: ""
      },
      mstMedicine: [],
      mstMedicineMix: [],
      masterLabelForCd: null,
      masterUnitForCd: null,
      rstUnitForCd: null,
      rstUnitBaselineForCd: null,
      rstNameForCd: null,
      receiptUnitForCd: null,
      isChangedMedicineType: false,
      isDefaultSetUnitFlg:false,
      deletedMedicine: {
        cd : null,
        isMedicineTypeMix : false
      },
      localSelectedCd: null,
      // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
      initValue : this.value
      // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
    };
  },

  computed: {
    ...mapGetters("pat-info", ["selectedPatId"]),
    ...mapGetters("pat-viewer-treat-cond", {
      dialysdateUnit: "getDialysateUnit",
      // add 8204 周安寧 start
      getIsUseFlagDialysate: "getIsUseFlagDialysate",
      // add 8204 周安寧 end
      // add 10179 患者経過総合ビューアの治療条件画面にて補液の単位が透析液の単位で表示される 張玲 start
      deviceMode:"getDeviceMode"
      // add 10179 患者経過総合ビューアの治療条件画面にて補液の単位が透析液の単位で表示される 張玲 end
    }),
    ...mapGetters("pat-viewer-popover", ["getIndStartDate"]),
    // mod FNSI-小数点の修正 楊 start
    ...mapGetters("pat-viewer-modal", { settingIndData: "getSettingIndData" }),
    // mod FNSI-小数点の修正 楊 end
    // 調製薬剤フラグ
    isMedicineTypeMix() {
      let medicineType = this.medicineType;
      if (
        this.isChangedMedicineType ||
        // this.displayInputValue.initValue !== this.displayInputValue.editValue
        this.displayInputValue.initValue != this.displayInputValue.editValue    // Mod #9973 By Tao.zhou fix the type of JSON value node.
      ) {
        // medicine_typeタイプに変更がある場合
        medicineType = this.editedMedicineType;
      }

      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
      //return medicineType === "2";
      return medicineType == 2;
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
    },
    rstDialysisState() {
      return this.dialysisStateSafe;
    },
    dialysisStateSafe() {
      const val = this.settingIndData &&
                  this.settingIndData.orderMainData &&
                  this.settingIndData.orderMainData.rstDialysisState;
      return Number(val || 0);
    },
    isActualRst() {
      return this.dialysisStateSafe !== 0;
    },
    equipmentSelectorInitItem() {
      return {
        text: this.isActualRst
          ? this.rstNameForCd != null && this.rstNameForCd !== ""
            ? this.rstNameForCd
            : this.displayInputValue.editValue
          : this.displayInputValue.initValue,
        value: this.displayInputValue.initCd,
        unit: this.isActualRst
          ? this.rstUnitBaselineForCd != null && this.rstUnitBaselineForCd !== ""
            ? this.rstUnitBaselineForCd
            : this.masterUnitForCd
          : this.masterUnitForCd
      };
    }
  },

  watch: {
    getIndStartDate: {
      handler(val) {
        this.mstExtraParams.treatDate = this.normalizeTreatDate(val);
      },
      immediate: true
    },
    inputValue: {
      handler(data) {
      // add 9664補液及び透析液仕様修正します yangqingzhe start
        if(this.treatItemCd === "15") {
          // add 9664補液及び透析液仕様修正します yangqingzhe end
          let mstMedi = this.mstMedicine;
          let mediCd = "medicineCd";
          if (this.isMedicineTypeMix) {
            mstMedi = this.mstMedicineMix;
            mediCd = "medicineMixCd";
          }

          const medicine = mstMedi.find(item => {
            return item[mediCd] == data; // mod #9973 value Number→文字列  shiyw
          });

          this.setDialysate(medicine ? {"value": medicine[mediCd]} : null);
          // del FNSI-改修内容 透析液、補液、抗凝固剤の物品が選択されていない場合に別の指示項目を編集不可とする仕組みをなくす。 周 start
          // this.setDialysateDisabled(!data);
          // del FNSI-改修内容 透析液、補液、抗凝固剤の物品が選択されていない場合に別の指示項目を編集不可とする仕組みをなくす。 周 end
          if (medicine) {
            // mod FNSI-小数点の修正 楊 start
            // this.setDialysateDecPoint(medicine.unitDecimalPointSecond);
            // mod 治療方法セットマスタ 補液使用数、透析液使用数の小数点桁数は、薬剤の指示単位小数部桁数と同じです 孔 start
            if (this.isMst) {
              // mod 9664補液及び透析液仕様修正します yangqingzhe start
              //this.setDialysateDecPoint(medicine.unitDecimalPoint);
              //mod 8107 OHDF、OHFの治療モード際に、透析液を変更した場合に補液は更新されるが、補液使用数の桁数および単位が変わらない。張 start
              // this.setIvDecPoint(medicine.unitDecimalPointSecond);
              this.setDialysateDecPoint(medicine.unitDecimalPointSecond);
              this.setDialysateUnit(medicine.unitSecond);
              if (this.deviceMode == '7' || this.deviceMode == '8' || this.deviceMode == '10') {
                this.setIvUnit(medicine["unitSecond"]);
                this.setIvDecPoint(medicine.unitDecimalPointSecond);
              }
              // mod 9664補液及び透析液仕様修正します yangqingzhe end
            } else {
              let componentDataList = this._indicationFlowOwner().componentData.filter(item => {
                return item.cd === 17;
              });
              // modify 10179 by kangjie 20240226 start
              // let rstDialysisState = componentDataList[0].fields.rstDialysisState;
              let rstDialysisState = componentDataList.length > 0 ? componentDataList[0].fields.rstDialysisState : null;
              // modify 10179 by kangjie 20240226 end
              if (rstDialysisState === "0" || this.popoverData.isMedicineCdChg) {
                // modify 10179 by kangjie 20240222 start
                // 透析液
                if (this.popoverData.type == 15) {
                  this.setDialysateDecPoint(medicine.unitDecimalPointSecond);
                }
                // this.setIvDecPoint(medicine.unitDecimalPointSecond);
                // modify 10179 by kangjie 20240222 end
              } else {
                // #9973 Mod by Zhou.tao fix this out of range problem. Start
                // add 10179 by kangjie 20240226 start
                // let valStr = componentDataList[0].fields.value.toString();
                let valStr = componentDataList.length > 0 ? componentDataList[0].fields.value.toString() : null;
                // add 10179 by kangjie 20240226 start
                // セルからの場合、DBデータ桁数を設定
                if (this.settingIndData.ordNo
                  && valStr
                  && typeof valStr === "string"
                  && valStr.indexOf(".") > 0) {
                  this.setDialysateDecPoint(valStr.split(".")[1].length);
                  this.setIvDecPoint(valStr.split(".")[1].length);
                } else {
                  // タイトルから場合、マスタの桁数設定
                  this.setDialysateDecPoint(medicine.unitDecimalPointSecond);
                  this.setIvDecPoint(medicine.unitDecimalPointSecond);
                }
                // #9973 Mod by Zhou.tao fix this out of range problem. End
              }
              // mod 治療方法セットマスタ 補液使用数、透析液使用数の小数点桁数は、薬剤の指示単位小数部桁数と同じです 孔 end
            }
            // mod FNSI-小数点の修正 楊 end
            if ((this.isDefaultSetUnitFlg || this.dialysdateUnit === null) && !this.isActualRst) {
              // add 10179 by kangjie 20240223 start
              if (this.popoverData.type != "19") {
                this.setDialysateUnit(medicine["unitSecond"]);
                this.setDialysateDecPoint(medicine.unitDecimalPointSecond);
              }
              // add 10179 by kangjie 20240223 end
              // mod 10179 患者経過総合ビューアの治療条件画面にて補液の単位が透析液の単位で表示される 張玲 start
              if (this.deviceMode == '7' || this.deviceMode == '8' || this.deviceMode == '10') {
                this.setIvUnit(medicine["unitSecond"]);
                this.setIvDecPoint(medicine["unitDecimalPointSecond"]);
              }
              // mod 10179 患者経過総合ビューアの治療条件画面にて補液の単位が透析液の単位で表示される 張玲 end
            }
            // add FNSI-【8630】単位が表示されない対応 曲 start
            if (this.isDefaultSetUnitFlg) {
              this.setDialysateUnitChangeFlag(true);
              // mod #10150 透析液コンポネントと補液関連の設定は不要 start
              if (this.deviceMode == '7' || this.deviceMode == '8' || this.deviceMode == '10') {
                this.setIvUnitChangeFlag(true);
              }
              // mod #10150 透析液コンポネントと補液関連の設定は不要 end
            }
            // add FNSI-【8630】単位が表示されない対応 曲 end
            this.isDefaultSetUnitFlg = true;
          } else {
            if (this.isDefaultSetUnitFlg) {
              this.setDialysateDecPoint(0);
              this.setDialysateUnit(null);
              // mod #10150 透析液コンポネントと補液関連の設定は不要 start
              if (this.deviceMode == '7' || this.deviceMode == '8' || this.deviceMode == '10') {
                this.setIvDecPoint(0);
                this.setIvUnit(null);
              }
              // mod #10150 透析液コンポネントと補液関連の設定は不要 end
            }
          }
        }
      },
      deep: true
    }
  },

  async mounted() {
    this.localSelectedCd = this.value;
    this.treatItemCd = "15";
    if (!this.mstExtraParams.treatDate) {
      this.mstExtraParams.treatDate = this.normalizeTreatDate(this.getIndStartDate);
    }

    await this.createPopoverData();
    const selectedMst = this.popoverData.popoverContentDataset.find(item => {
      return item.value == this.value; // mod #9973 value Number→文字列  shiyw
    });
    //8204 zhou 【デグレ】治療条件モーダルにて、使用しない項目を設定できてしまう add start
    const selectedEditMst = this.popoverData.popoverContentDataset.find(item => {
      // mod #10937 20260428 Ji start
      // return item.value == this.value; // mod #9973 value Number→文字列  shiyw
      return item.value == (this.velue ?? this.value);
      // mod #10937 20260428 Ji end
    });
    //8204 zhou 【デグレ】治療条件モーダルにて、使用しない項目を設定できてしまう add end
    //8204 zhou 【デグレ】治療条件モーダルにて、使用しない項目を設定できてしまう mod start
    //if (selectedMst) {
    if (selectedMst || selectedEditMst) {
      // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
      //add FutreNetWeb+SI課題管理 NO.5323 劉全航 start
      //var item = this.contentDataset.find(o=>o.medicineCd === this.value);
      // var item = this.contentDataset.find(o=>o.medicineCd == this.velue); // mod #9973 value Number→文字列  shiyw
      // let useEndDate = dayjs(item.useEndDate);
      // let indStartDate = dayjs(this.getIndStartDate);
      // let useEndDate = null;
      // let indStartDate = null;
      // if (item) {
      //   useEndDate = dayjs(item.useEndDate);
      //   indStartDate = dayjs(this.getIndStartDate);
      // }
      //if(useEndDate.isBefore(indStartDate)){

      // if(useEndDate != null && useEndDate.isBefore(indStartDate)){
      //   // this.displayInputValue.initValue = "【期限切れ】"+selectedMst.text;
      //   // this.displayInputValue.editValue = "【期限切れ】"+selectedMst.text;
      //   this.displayInputValue.initValue = selectedMst ? "【期限切れ】"+selectedMst.text : "";
      //   this.displayInputValue.editValue = this.isIndication ? (selectedEditMst ? "【期限切れ】"+selectedEditMst.text :"") : this.displayInputValue.initValue;
      // }else{
      //   // this.displayInputValue.initValue = selectedMst.text;
      //   // this.displayInputValue.editValue = selectedMst.text;
      //   this.displayInputValue.initValue = selectedMst ? selectedMst.text : "";
      //   this.displayInputValue.editValue = this.isIndication ? (selectedEditMst ? selectedEditMst.text : "") : this.displayInputValue.initValue;
      // }
      const masterText =
        this.masterLabelForCd != null && this.masterLabelForCd !== ""
          ? this.masterLabelForCd
          : (selectedMst ? selectedMst.text : "");
      this.displayInputValue.initValue = masterText;
      this.displayInputValue.editValue = this.isIndication ? (selectedEditMst ? selectedEditMst.text : "") : (selectedMst ? selectedMst.text : masterText);
      this.displayInputValue.text = this.displayInputValue.editValue;
      this.displayInputValue.initCd = selectedMst ? selectedMst.value : "";
      this.displayInputValue.editCd = selectedEditMst ? selectedEditMst.value : this.displayInputValue.initCd;
      this.mstExtraParams.rstInfo.rstUnit = (selectedEditMst || selectedMst).unit || "";
      this.rstUnitForCd =
        (selectedEditMst || selectedMst).unit != null && (selectedEditMst || selectedMst).unit !== ""
          ? String((selectedEditMst || selectedMst).unit)
          : this.rstUnitForCd;
      // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
      // this.displayInputValue.initValue = selectedMst.text;
      // this.displayInputValue.editValue = selectedMst.text;
      //add FutreNetWeb+SI課題管理 NO.5323 劉全航 end
      //this.popoverData.popoverContentSelected = selectedMst;
      this.popoverData.popoverContentSelected = selectedEditMst ? selectedEditMst :selectedMst ;
    // mod FNSI-改修内容 透析液、補液、抗凝固剤の物品が選択されていない場合に別の指示項目を編集不可とする仕組みをなくす。 周 start
    //8204 zhou 【デグレ】治療条件モーダルにて、使用しない項目を設定できてしまう mod end
    //}
    } else {
      // FNSI-修正 マスタ削除の対応 wangchen add start
        if(this.value){
          //mod 10150 piao start
          ApiHelper.get("/mstInfo/mstMedicine/getByCd", {medicineCd:this.value}).then(async (res) => {
          //mod 10150 piao end
              //add FutreNetWeb+SI課題管理 NO.5323 劉全航 start
              let classType = null;
              //mod 8681 ljx start
              if(res.data.classCd){
                //mod 10150 piao start
                await ApiHelper.get("/mstInfo/getMstMedicineTypeByClass",{classCd:res.data.classCd}).then((response) => {
                //mod 10150 piao end
                  classType = response.data.classType;
                });
              }
              //mod 8681 ljx end
              //add FutreNetWeb+SI課題管理 NO.5323 劉全航 end
              //mod FutreNetWeb+SI課題管理 NO.4878 劉全航 start
              // this.displayInputValue.initValue = "削除済み "+res.data.medicineName;
              // this.displayInputValue.editValue = "削除済み "+res.data.medicineName;
              // mod FNSI-FutreNetWeb+SI課題管理No.4878 李 start
              if (res && res.data && res.data.isDisp == '1' && res.data.isDel == '0') {
                //add FutreNetWeb+SI課題管理 NO.5323 劉全航 start
                if(classType !== 2){
                  this.displayInputValue.initValue = "【分類不一致】" + res.data.medicineName;
                  this.displayInputValue.editValue = "【分類不一致】" + res.data.medicineName;
                }else{
                  this.displayInputValue.initValue = res.data.medicineName;
                  this.displayInputValue.editValue = res.data.medicineName;
                }
                // this.displayInputValue.initValue = res.data.medicineName;
                // this.displayInputValue.editValue = res.data.medicineName;
                //add FutreNetWeb+SI課題管理 NO.5323 劉全航 end
              } else {
                this.displayInputValue.initValue = MASTER_DELETE_DISPLAY.DELETED + res.data.medicineName;
                this.displayInputValue.editValue = MASTER_DELETE_DISPLAY.DELETED + res.data.medicineName;
              }
              this.displayInputValue.text = this.displayInputValue.editValue;
              this.displayInputValue.initCd = this.value;
              this.displayInputValue.editCd = this.value;
              // mod FNSI-FutreNetWeb+SI課題管理No.4878 李 end
              //mod FutreNetWeb+SI課題管理 NO.4878 劉全航 end
              // del FNSI redmine 4877 4879 劉祥霖 start
              // this.popoverData.popoverContentSelected.value = null;
              // del FNSI redmine 4877 4879 劉祥霖 end
            })
        }
      // FNSI-修正 マスタ削除の対応 wangchen add end
    }
    // mod FNSI-改修内容 透析液、補液、抗凝固剤の物品が選択されていない場合に別の指示項目を編集不可とする仕組みをなくす。 周 end
    // this.checkMstDispStatus("medicineCd");
    this.mstExtraParams.treatDate = this.getIndStartDate || "";
    this.mstExtraParams.rstInfo.rstName =
      this.displayInputValue.editValue || this.displayInputValue.initValue || "";
  },

  methods: {
    ...mapMutations("pat-viewer-treat-cond", [
      "setDialysate",
      "setDialysateDisabled",
      "setDialysateDecPoint",
      "setDialysateUnit",
      // add FNSI-【8630】単位が表示されない対応 曲 start
      "setDialysateUnitChangeFlag",
      // add FNSI-【8630】単位が表示されない対応 曲 end
      "setIvUnit",
      "setIvDecPoint",
     //mod 8107 OHDF、OHFの治療モード際に、透析液を変更した場合に補液は更新されるが、補液使用数の桁数および単位が変わらない。張 end
      // add FNSI-【8630】単位が表示されない対応 曲 start
      "setIvUnitChangeFlag"
      // add FNSI-【8630】単位が表示されない対応 曲 end
    ]),
    // add #10359 編集権限の動作不正 dengshen start
    getItemAuthorized(pageCd, itemCd) {
      return this.isMst || (this.isMst != true && getAuthorized(pageCd, itemCd));
    },
    // add #10359 編集権限の動作不正 dengshen end
     //[確認]ボタンの状態の変更をトリガーします
    changeButton() {
      EventBus.$emit("mstHolidayRegistered", false);
    },
    normalizeTreatDate(val) {
      if (val == null) return "";
      return String(val).replaceAll("-", "");
    },
    masterUpdateInput(val = {}) {
      const kbnValue = val.kbnValue ?? val.type ?? val.key_type ?? this.medicineType;
      const classCd = val.classCd ?? val.classValue ?? val.key_class;
      this.displayInputValue.editValue = val.text;
      this.displayInputValue.text = val.text;
      this.displayInputValue.editCd = val.value;
      this.kbnValue = kbnValue;
      this.unit = val.unit ?? "";
      this.mstExtraParams.rstInfo.rstUnit = this.unit;
      this.rstUnitForCd =
        this.unit != null && this.unit !== "" ? String(this.unit) : this.rstUnitForCd;
      if (val?.unitSecond != null && val.unitSecond !== "") {
        this.setDialysateUnit(String(val.unitSecond));
        this.setDialysateUnitChangeFlag(true);
      }
      const data = {
        fnValue: {
          薬剤分類: classCd,
          薬剤区分: kbnValue
        },
        isDisp: val.isDisp,
        text: val.text,
        type: kbnValue,
        value: val.value,
        unit: this.unit
      };
      this.updateInputNew(data, "15");
    },
    updateInput(data) {
      this.updateInputNew(data, "15");
    },
    async createPopoverData() {
      const initValue =
        this.displayInputValue.initCd != null && this.displayInputValue.initCd !== ""
          ? this.displayInputValue.initCd
          : this.value;
      const treatDate =
        this.normalizeTreatDate(this.getIndStartDate || this.mstExtraParams.treatDate || dayjs().format("YYYYMMDD"));
      this.mstExtraParams.treatDate = treatDate;
      const extraParams = {
        treatDate,
        rstInfo: this.mstExtraParams.rstInfo,
        classType: 2,
        initValue,
        medicineType: this.medicineType
      };
      const context = {
        facilityCd: this.facilityCd,
        patientId: this.selectedPatId,
        extraParams,
        initItem: { value: initValue },
        selectedItem: { value: this.value },
        hasChangedOption: true,
        isMedicament: "1",
        dialysisState: this.dialysisStateSafe,
        allowedFields: { showMedicineFieldOnly: false, data: [] }
      };

      const popover = await buildMasterPopover(
        MasterType.MEDICATION_TREATMENT_CLASSTYPE_RECORD,
        context
      ).catch(error => {
        getErrorMessage("IndTreatCondDialysate.vue", "createPopoverData", error);
        throw error;
      });

      const categories = popover?.categories ?? [];
      const options = popover?.master?.options ?? [];
      const filteredOptions = options.filter(item => {
        return item.isDisp === "1" || String(item.value) == String(this.localSelectedCd);
      });

      const masterRow = filteredOptions.find(
        o => String(o.value) === String(this.localSelectedCd)
      );
      this.masterLabelForCd = masterRow && masterRow.text != null ? String(masterRow.text) : null;
      this.masterUnitForCd =
        masterRow && masterRow.unit != null && masterRow.unit !== ""
          ? String(masterRow.unit)
          : null;

      let rstName = "";
      let rstUnit = "";
      let receiptUnit = "";
      const om = this.settingIndData && this.settingIndData.orderMainData;
      if (
        om &&
        om.rstDialysisState != null &&
        String(om.rstDialysisState) !== "" &&
        Number(om.rstDialysisState) !== 0
      ) {
        const raw = om.indCondInfo;
        if (raw != null && raw !== "") {
          try {
            const obj = typeof raw === "string" ? JSON.parse(raw) : raw;
            const row = obj[this.treatItemCd] ?? obj[Number(this.treatItemCd)];
            rstName = row?.value_name_1 || "";
            rstUnit = row?.unit || "";
            const row17 = obj?.["17"] ?? obj?.[17];
            receiptUnit = row17?.unit || "";
          } catch (e) {
            rstName = "";
            rstUnit = "";
            receiptUnit = "";
          }
        }
      }
      this.rstUnitForCd =
        rstUnit != null && rstUnit !== "" ? String(rstUnit) : this.masterUnitForCd;
      this.rstUnitBaselineForCd =
        rstUnit != null && rstUnit !== "" ? String(rstUnit) : null;
      this.rstNameForCd = rstName != null && rstName !== "" ? String(rstName) : null;
      this.receiptUnitForCd = receiptUnit != null && receiptUnit !== "" ? String(receiptUnit) : null;
      if (this.receiptUnitForCd != null && this.receiptUnitForCd !== "") {
        this.setDialysateUnit(String(this.receiptUnitForCd));
        this.setDialysateUnitChangeFlag(true);
      }
      if (
        Number(this.dialysisStateSafe || 0) !== 0 &&
        rstUnit != null &&
        rstUnit !== ""
      ) {
        this.unit = String(rstUnit);
      }

      const contentArr = filteredOptions.map(item => ({
        ...item,
        fnValue: {
          薬剤分類: item.classCd ?? item.classValue ?? item.key_class,
          薬剤区分: item.kbnValue ?? item.key_type
        },
        type: item.kbnValue ?? item.key_type,
        text:
          rstName && String(item.value) == String(this.localSelectedCd)
            ? String(rstName)
            : item.text
      }));

      this.mstMedicine = contentArr.filter(item => String(item.kbnValue ?? item.key_type) === "1");
      this.mstMedicineMix = contentArr.filter(item => String(item.kbnValue ?? item.key_type) === "2");
      this.contentDataset = [...this.mstMedicine, ...this.mstMedicineMix];
      this.popoverData.popoverTitleHeader = "薬剤";
      this.popoverData.popoverFilter = categories.map(category => ({
        popoverFilterLabel: category.label,
        popoverFilterDataset: category.options
      }));
      this.popoverData.popoverContentLabel = "薬剤名";
      this.popoverData.popoverContentDataset = contentArr;
      this.popoverData.type = this.treatItemCd;
    },
    //#10123:透析液/補液の薬剤選択モーダルの薬剤区分の表示が不要(補液処理共有) Start
    async createPopoverDataLegacy() {
    //#10123:透析液/補液の薬剤選択モーダルの薬剤区分の表示が不要(補液処理共有) End
      // 選択中薬剤のIDを取得
      let selectedMediCd = null;
      let selectedMediMixCd = null;
      if (this.isMedicineTypeMix) {
        selectedMediMixCd = this.value;
      } else {
        selectedMediCd = this.value;
      }
      // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
      const normalClassTypeObj = {
        "15": CODES.MEDICINE_CLASS.DIALYSATE.classType,
        "19": CODES.MEDICINE_CLASS.REPLACEMENT.classType
      };
      // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
      let filterArr = [];
      let contentArr = [];
      // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
      let treatDate = null;
      // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
      const [medicineData, medicineMixData, classData] = await Promise.all([
        // マスタ系画面以外では患者のタブー・アレルギー情報込みで取得する
        // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
        // this.$route.name === MASTER_MAINTENANCE_CURRENT_ROUTE_NAME ? medicine(this.facilityCd) : medicineTabooAllergy(this.selectedPatId),
        this.$route.name === MASTER_MAINTENANCE_CURRENT_ROUTE_NAME ? medicineIncludeDeleted(this.facilityCd) : medicineAllergy(this.selectedPatId, true),
        // this.$route.name === MASTER_MAINTENANCE_CURRENT_ROUTE_NAME ? medicineMix(this.facilityCd) : medicineMixTabooAllergy(this.selectedPatId),
        this.$route.name === MASTER_MAINTENANCE_CURRENT_ROUTE_NAME ? medicineMixIncludeDeleted(this.facilityCd) : medicineMixAllergy(this.selectedPatId, true),
        // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
        medicineClass(this.facilityCd)
      ]).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
        getErrorMessage('IndTreatCondDialysate.vue', 'createPopoverData', error);
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
        throw error;
      });
      // 患者経過総合ビューア(予定)表示時は、予定範囲と薬剤の使用期限を見て表示内容を補正する
      if (this.$route.name === PATVIEWER_CURRENT_ROUTE_NAME) {
        // 薬剤
        this.mstMedicine = medicineData.filter(medi => {
          // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
          // return fitTermCheck(medi.useStartDate, medi.useEndDate, this.getIndStartDate) || medi.medicineCd == selectedMediCd; // mod #9973 value Number→文字列  shiyw
          return fitTermCheck(medi.useStartDate, medi.useEndDate, this.getIndStartDate) ||  (this.initValue != null && medi.medicineCd == this.initValue) || (this.initValue != null && medi.medicineMixCd == this.initValue);
          // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
        });
        // 調製薬剤
        this.mstMedicineMix = medicineMixData.filter(medi => {
          // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
          // return fitTermCheck(medi.maxUseStartDate, medi.minUseEndDate, this.getIndStartDate) || medi.medicineMixCd == selectedMediMixCd; // mod #9973 value Number→文字列  shiyw
          return fitTermCheck(medi.maxUseStartDate, medi.minUseEndDate, this.getIndStartDate) ||  (this.initValue != null && medi.medicineCd == this.initValue) || (this.initValue != null && medi.medicineMixCd == this.initValue);
          // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
        });
        // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
        treatDate = this.getIndStartDate;
        // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
      } else {
        // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
        // this.mstMedicine = medicineData;
        // this.mstMedicineMix = medicineMixData;
        treatDate = dayjs().format("YYYYMMDD");
        // 薬剤
        this.mstMedicine = medicineData.filter(medi => {
          return fitTermCheck(medi.useStartDate, medi.useEndDate, treatDate) || (this.initValue != null && medi.medicineCd == this.initValue);
        });
        // 調製薬剤
        this.mstMedicineMix = medicineMixData.filter(medi => {
          return fitTermCheck(medi.maxUseStartDate, medi.minUseEndDate, treatDate) || (this.initValue != null && medi.medicineMixCd == this.initValue);
        });
        // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
      }
      this.filterDataset = classData;

      // ポップオーバのフィルタデータを取りまとめる
      const filterParam = item => {
        //mod 8107 OHDF、OHFの治療モード際に、透析液を変更した場合に補液は更新されるが、補液使用数の桁数および単位が変わらない。張 start
        // return item.classType === 2;
        // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
        // return item.classType === 2||item.classType === 3;
        return item.classType === 2 || item.classType === 3 || item.medicineCd == this.initValue;
        // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
        //mod 8107 OHDF、OHFの治療モード際に、透析液を変更した場合に補液は更新されるが、補液使用数の桁数および単位が変わらない。張 end
      };
      const filterMapping = item => {
        return {
          text: item.className,
          value: item.classCd,
          // add 9664補液及び透析液仕様修正します yangqingzhe start
          classType : item.classType
          // add 9664補液及び透析液仕様修正します yangqingzhe end
        };
      };

      filterArr = this.filterDataset.filter(filterParam).map(filterMapping);
      // del 9664補液及び透析液仕様修正します yangqingzhe start
      // filterArr.unshift({ text: "すべて", value: 0 });
      // del 9664補液及び透析液仕様修正します yangqingzhe start

      // ポップオーバのコンテンツデータ(フィルタデーしたデータ)を取りまとめる
      const contentParam = item => {
        return filterArr.find(i => {
          // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
          // return item.classCd === i.value;
          return item.classCd === i.value || (this.initValue != null && item.medicineCd == this.initValue) || (this.initValue != null && item.medicineMixCd == this.initValue);
          // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
        });
      };
      const contentParamIsDisp = item => {
        // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
        // return item.isDisp === "1";
        return item.isDisp === "1" || (this.initValue != null && item.medicineCd == this.initValue) || (this.initValue != null && item.medicineMixCd == this.initValue);
        // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
      };
      // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
      let rstName = "";
      if (
        this.$route.name === PATVIEWER_CURRENT_ROUTE_NAME &&
        this.getSettingIndData && 
        this.getSettingIndData.orderMainData && 
        this.getSettingIndData.orderMainData.rstDialysisState != 0
      ) {
        const rstCondInfo = this.getSettingIndData.orderMainData.indCondInfo;
        const rstCondInfoObj = rstCondInfo ? JSON.parse(rstCondInfo) : [];
        rstName = rstCondInfoObj[this.treatItemCd]?.value_name_1;
      }
      // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
      /* modify by chamaojia 2024-02-28 [10196] The deleted data needs to be displayed in the drop-down list --start */
      // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
      const deviceModeOnline = [DEVICEMODE.OHDF, DEVICEMODE.OHF, DEVICEMODE.I_HDF];
      const deviceModeOnlineClassType = [CODES.MEDICINE_CLASS.DIALYSATE.classType, CODES.MEDICINE_CLASS.REPLACEMENT.classType];
      // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
      const contentMapping = (item, cdKey, nameKey, category, delFlag) => {
        return {
          value: category === "1" ? item[cdKey] : `${item[cdKey]}$`,
          fnValue: {
            //#10123:透析液/補液の薬剤選択モーダルの薬剤区分の表示が不要(以下薬剤区分フィルター削除) Start
            //薬剤区分: category,
            //#10123:透析液/補液の薬剤選択モーダルの薬剤区分の表示が不要 End
            薬剤分類: item.classCd
          },
          // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
          // text: delFlag ? MASTER_DELETE_DISPLAY.DELETED + item[nameKey] : item[nameKey]
          text: rstName && item[cdKey] == this.initValue ? rstName : getPrefix({ 
            treatDate: treatDate,
            normalClassType: deviceModeOnline.includes(this.deviceMode) ? deviceModeOnlineClassType : normalClassTypeObj[this.treatItemCd],
            ...item
          }) + item[nameKey]
          // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
        };
      };

      this.contentDataset = [...this.mstMedicine, this.mstMedicineMix];

      const contentMedicine = this.mstMedicine
        .filter(contentParam)
        .filter(contentParamIsDisp)
        .map(item => contentMapping(item, "medicineCd", "medicineName", "1", false));
      const contentMedicineMix = this.mstMedicineMix
        .filter(contentParam)
        .filter(contentParamIsDisp)
        .map(item =>
          contentMapping(item, "medicineMixCd", "medicineMixName", "2", false)
        );
      if (this.deletedMedicine.cd == null) {
        this.deletedMedicine.cd = this.value;
        this.deletedMedicine.isMedicineTypeMix = this.isMedicineTypeMix;
      }

      let currentMedicineOrMedicineMix = [];
      if (this.deletedMedicine.cd) {
        if (this.deletedMedicine.isMedicineTypeMix) {
          const contentMedicineMixArr = contentMedicineMix.map(item => item.value);
          const hasCurrentMedicineMix = contentMedicineMixArr.some(value => {
            return value == this.deletedMedicine.cd || value == `${this.deletedMedicine.cd}$`;
          });
          const medicineMixByCd = hasCurrentMedicineMix ? null : await medicineMixTabooAllergyByCd(this.selectedPatId==null?-1:this.selectedPatId, this.deletedMedicine.cd);
          if (medicineMixByCd) {
            currentMedicineOrMedicineMix = medicineMixByCd
                .filter(item => {return item.medicineCd == this.deletedMedicine.cd && item.isDisp == "0"});
            if (currentMedicineOrMedicineMix != null && currentMedicineOrMedicineMix.length > 0) {
              this.mstMedicineMix.push(currentMedicineOrMedicineMix[0])
              currentMedicineOrMedicineMix = currentMedicineOrMedicineMix
                  .map(item =>
                      contentMapping(item, "medicineMixCd", "medicineMixName", "2", true)
                  );
            }
          }
        } else {
          // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
          const contentMedicineArr = contentMedicine.map(item => item.value);
          const hasCurrentMedicine = contentMedicineArr.some(value => {
            return value == this.deletedMedicine.cd;
          });
          const medicineByCd = hasCurrentMedicine ? null : await medicineTabooAllergyByCd(this.selectedPatId==null?-1:this.selectedPatId, this.deletedMedicine.cd);
          // if (medicineByCd) {
          if (medicineByCd && !hasCurrentMedicine) {
          // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
            currentMedicineOrMedicineMix = medicineByCd
                .filter(item => {return item.medicineCd == this.deletedMedicine.cd && item.isDisp == "0"});
            if (currentMedicineOrMedicineMix != null && currentMedicineOrMedicineMix.length > 0) {
              this.mstMedicine.push(currentMedicineOrMedicineMix[0])
              currentMedicineOrMedicineMix = currentMedicineOrMedicineMix.map(item =>
                  contentMapping(item, "medicineCd", "medicineName", "1", true)
              );
            }
          }
        }
      }

      contentArr = [...contentMedicine, ...contentMedicineMix, ...currentMedicineOrMedicineMix];
      /* modify by chamaojia 2024-02-28 [10196] The deleted data needs to be displayed in the drop-down list --end */
      // add 9664補液及び透析液仕様修正します yangqingzhe start
      let filterDialysateArr = filterArr.filter(item => item.classType === 2);
      let filterCondIvArr = filterArr.filter(item => item.classType === 3);
      let popoverArr = Number(this.treatItemCd) === 15 ? filterDialysateArr : Number(this.treatItemCd) === 19 ? filterCondIvArr : [];
      if (Array.isArray(popoverArr)) {
        popoverArr.unshift({ text: "すべて", value: 0 });
      }
      // add 9664補液及び透析液仕様修正します yangqingzhe end
      this.popoverData.popoverTitleHeader = "薬剤";
      this.popoverData.popoverFilter = [
        //#10123:透析液/補液の薬剤選択モーダルの薬剤区分の表示が不要(以下薬剤区分フィルター削除) Start
        /*
        {
          popoverFilterLabel: "薬剤区分",
          popoverFilterDataset: [
            { text: "すべて", value: 0 },
            { text: "通常薬剤", value: "1" },
            { text: "調製薬剤", value: "2" }
          ]
        }, */
        //#10123:透析液/補液の薬剤選択モーダルの薬剤区分の表示が不要 End
        {
          popoverFilterLabel: "薬剤分類",
          // mod 9664補液及び透析液仕様修正します yangqingzhe start
          popoverFilterDataset: popoverArr
          // popoverFilterDataset: filterArr
          // mod 9664補液及び透析液仕様修正します yangqingzhe end
        }
      ];
      this.popoverData.popoverContentLabel = "薬剤名";
      // mod 9664補液及び透析液仕様修正します yangqingzhe start
      // this.popoverData.popoverContentDataset = contentArr;
      let popoverContentArr = [];
      let filterPopoverVal = popoverArr.map(item => item.value)
      contentArr.forEach((item) => {
        // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
        // if (filterPopoverVal.includes(item.fnValue.薬剤分類)) {
        if (filterPopoverVal.includes(item.fnValue.薬剤分類) || item.value == this.initValue) {
        // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
          popoverContentArr.push(item)
        }
      })
      this.popoverData.popoverContentDataset = popoverContentArr;
      // mod 9664補液及び透析液仕様修正します yangqingzhe end
    }
  }
};
</script>
