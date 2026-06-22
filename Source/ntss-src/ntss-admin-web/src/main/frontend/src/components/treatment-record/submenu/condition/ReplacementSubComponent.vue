/**
 * 治療記録の子機能 治療条件（補液）
 */
<template>
  <div class="expandable-content" style="align-self: baseline;">
    <div>
      <v-ons-row :class="isUseObj[19]?'column-ground-color':null">
        <v-ons-col class="title d-flex align-items-center">
          <label class="text-color">
            補液
          </label>
        </v-ons-col>
        <v-ons-col class="value d-flex align-items-center">
          <common-master-selector
            :masterType="MasterType.MEDICATION_TREATMENT_CLASSTYPE_RECORD"
            :initItem="replacementSelectorInitItem"
            :editItem="replacementSelectorEditItem"
            :patientId="selectedPatId"
            :facilityCd="getFacilityCd"
            :hasChangedOption="true"
            :extraParams="replacementSelectorExtraParams"
            :dialysisState="getDialysisState"
            :changeOptionMode="'nameAndUnit'"
            :selectedItemClass="'com-basic-sub-input'"
            :backgroundColor="'#f7f7f7'"
            :btnClass="'com-basic-sub-btn'"
            :btnDisabled="treatCondition || !isShared"
            @popover-return="updateInput('replacement', $event)"
          />
        </v-ons-col>
      </v-ons-row>
      <com-number-input name="fluid-replacement-amount" labelName="補液量" unitName="L" input-min-width="10em" :step=0.1 :inputMin=0.0 :inputMax=999.0 :inputType='"number"' v-model="inputModel.amount" :initValue="initModel.amount" :disabled="!getItemAuthorized('TreatmentRecord', 'default_authority')||!isShared" :class="isUseObj[20]?'column-ground-color':null"/>
      <com-radio name="fluid-replacement-select" labelName="補液選択" :radioItems=radioItems.timing v-model="inputModel.timing" :disabled="!getItemAuthorized('TreatmentRecord', 'default_authority')||!isShared" :class="isUseObj[21]?'column-ground-color':null"/>
      <com-number-input name="fluid-replacement-use-count" labelName="補液使用数" :unitName="inputModel.useCountUnit" input-min-width="10em" :step="this.unitStep" :inputMin=0.0 :inputMax=999.99 :inputType='"number"' :initialValueLock="true" v-model="inputModel.useCount" :initValue="initModel.useCount" :disabled="!getItemAuthorized('TreatmentRecord', 'default_authority')||!isShared" :class="isUseObj[22]?'column-ground-color':null"/>
      <com-number-input name="fluid-replacement-temperature" labelName="補液温度" unitName="℃" input-min-width="10em" :step=0.1 :inputMin=33.0 :inputMax=40.0 :inputType='"number"' v-model="inputModel.temperature" :initValue="initModel.temperature" :disabled="!getItemAuthorized('TreatmentRecord', 'default_authority')||!isShared" :class="isUseObj[23]?'column-ground-color':null"/>
      <com-number-input name="fluid-replacement-speed" labelName="補液速度" unitName="L/h" input-min-width="10em" :step=0.01 :inputMin=0.0 :inputMax=999.0 :inputType='"number"' v-model="inputModel.speed" :initValue="initModel.speed" :disabled="!getItemAuthorized('TreatmentRecord', 'default_authority')||!isShared" :class="isUseObj[24]?'column-ground-color':null"/>
    </div>
  </div>
</template>

<script>
import { mapGetters } from "@/compat/vue/vuex";
import CommonNumberInputComponent from "@/components/treatment-record/submenu/common/CommonNumberInputComponent";
import CommonRadioOff from "@/components/treatment-record/submenu/common/CommonRadioOffComponent";
import CommonMasterSelectorComponent from "@/components/common/master-selector/TreatmentRecordSelectorComponent";
import CustomDivShowSelectedItem from "@/components/common/custom-form-tags/CustomDivShowSelectedItem";

import {
  getMedicineAllTabooAllergyFilterByType,
  sendRequestGetMstMedicineClass
} from "@/apis/treatment-record";
import { medicineDialysateReplacement } from "@/components/common/master-selector/MasterSelectorDefinitions";
import { CODES } from "@/constants/TreatmentRecord";
import { Replacement } from "@/models/treatment-record/condition/Replacement";
import BigNumber from "@/compat/number/bignumber";
import { getAuthorized, getPrefix } from "@/functions/common/CommonFunctions.js";
import { medicineAllergy } from "@/functions/mst/MstGetters.js";
import commonMasterSelector from "@/components/common/master-selector/CommonMasterSelector.vue";
import * as MasterType from "@/components/common/master-selector/MasterType";
import { Master } from "@/models/common/master-selector-condition/Master";
export default {
  components: {
    "com-number-input": CommonNumberInputComponent,
    "com-radio": CommonRadioOff,
    "com-master-selector": CommonMasterSelectorComponent,
    "show-selected-item": CustomDivShowSelectedItem,
    "common-master-selector": commonMasterSelector
  },
  emits: ["update:modelValue"],
  props: {
    // Vue3 既定 v-model は modelValue / update:modelValue を使用する。
    modelValue: {
      type: Replacement
    },
    columnList: {
      type: Array
    },
    treatmentConditionCd:{
      type: Number
    },
  },
  data() {
    return {
      inputModel: new Replacement(),
      masterDef: medicineDialysateReplacement,
      radioItems: {
        timing: CODES.FLUID_REPLACEMENT_TIMING
      },
      initModel: new Replacement(),
      initFlag: 1,
      isUseObj: {},
      MasterType,
      extraParamsList:{},
      receiptUnitForCd: null
    };
  },
  computed: {
    ...mapGetters("pat-info", ["selectedPatId"]),
    ...mapGetters("user", ["getFacilityCd"]),
    ...mapGetters("treatment-record/common", ["getSharedFacilityCd", "getTreatDate", "getDialysisState"]),
    isShared() {
      return this.getFacilityCd === this.getSharedFacilityCd;
    },
    unitStep(){
      var num = parseInt(this.inputModel.decPoint);
      if(isNaN(num)){
        num = 0;
      }
      var data = Number(BigNumber(10).exponentiatedBy(BigNumber(num).negated()).valueOf());
      return data;
    },
    replacementSelectorInitItem() {
      return {
        text:
          this.initModel && this.initModel.replacement && this.initModel.replacement.name
            ? this.initModel.replacement.name
            : "",
        value:
          this.initModel && this.initModel.replacement && this.initModel.replacement.cd != null
            ? this.initModel.replacement.cd
            : null,
        unit:
          this.initModel && this.initModel.unit != null && this.initModel.unit !== ""
            ? String(this.initModel.unit)
            : null,
        unitSecond:
          this.initModel && this.initModel.useCountUnit != null && this.initModel.useCountUnit !== ""
            ? String(this.initModel.useCountUnit)
            : null
      };
    },
    replacementSelectorEditItem() {
      return {
        text:
          this.inputModel && this.inputModel.replacement && this.inputModel.replacement.name
            ? this.inputModel.replacement.name
            : "",
        value:
          this.inputModel && this.inputModel.replacement && this.inputModel.replacement.cd != null
            ? this.inputModel.replacement.cd
            : null,
        unit:
          this.inputModel && this.inputModel.unit != null && this.inputModel.unit !== ""
            ? String(this.inputModel.unit)
            : null,
        unitSecond:
          this.receiptUnitForCd != null && this.receiptUnitForCd !== "" ? this.receiptUnitForCd : null
      };
    },
    replacementSelectorExtraParams() {
      const extra = Object.assign({}, this.extraParamsList || {});
      extra.receiptUnit = this.initModel.useCountUnit;
      extra.compareReceiptUnit = true;
      return extra;
    },
    // add FNSI-redmine3855 徐 start
    isMobileBrowser() {
      return /android|iphone|ipad/i.test(((this?.$el?.ownerDocument?.defaultView?.navigator?.userAgent) || globalThis?.navigator?.userAgent || ""));
    },
    // add FNSI-redmine3855 徐 end
    //add FNSI修正 結合バッグ20 房 start
    // mod 7884 補液の「選択」を非活性にする事 房 start
    treatCondition() {
    //#10359 mod 編集権限の動作不正 2024-06-05 卓 start
      if (!getAuthorized('TreatmentRecord', 'default_authority')
        ||(this.treatmentConditionCd == 7 || this.treatmentConditionCd == 8 || this.treatmentConditionCd == 10)) {
        return true;
      } else {
        return false;
      }
    }
     //#10359 mod 編集権限の動作不正 2024-06-05 卓 end
    // mod 7884 補液の「選択」を非活性にする事 房 end
    //add FNSI修正 結合バッグ20 房 end
  },
  watch: {
    modelValue() {
      this.inputModel = this.modelValue;
      Object.assign(this.initModel, this.modelValue);
      this.receiptUnitForCd =
        this.inputModel && this.inputModel.useCountUnit != null && this.inputModel.useCountUnit !== ""
          ? String(this.inputModel.useCountUnit)
          : null;
      this.extraParamsList = {
        treatDate: this.getTreatDate,
        rstInfo: {
          rstName: this.inputModel.replacement.name,
          rstUnit: this.inputModel.useCountUnit
        },
        actualName:
          (this.initModel && this.initModel.replacement && this.initModel.replacement.name
            ? this.initModel.replacement.name
            : (this.inputModel && this.inputModel.replacement && this.inputModel.replacement.name
              ? this.inputModel.replacement.name
              : "")),
        classType: 3,
        // 初期値が削除・非表示でも SQL INIT で拾えるように渡す
        initValue: this.initModel.replacement.cd,
        // 補液は通常薬剤として扱う
        medicineType: 1
      };
    },
    inputModel: {
      handler: function(val) {
        this.$emit("update:modelValue", val);
      },
      deep: true
    },
    columnList() {
      if(this.columnList == null){
        return;
      }
      const items = this.columnList.filter(e => e.category_no === 4);
      if (items && items[0] && items[0].items) {
        items[0].items.forEach((item) => {
          this.isUseObj[item.ctl_no] = item.is_use === "0";
        });
      }
    }
  },
  methods: {
    // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
    // getMaster() {
    async getMaster() {
      // return Promise.all([
      //   getMedicineAllTabooAllergyFilterByType(this.selectedPatId, CODES.MEDICINE_CLASS.REPLACEMENT.classType),
      //   sendRequestGetMstMedicineClass(),
      //   getMedicineAllTabooAllergyFilterByType(this.selectedPatId, CODES.MEDICINE_CLASS.DIALYSATE.classType)
      // ]);
      let medicineList = Promise.all([
        getMedicineAllTabooAllergyFilterByType(this.selectedPatId, CODES.MEDICINE_CLASS.REPLACEMENT.classType),
        sendRequestGetMstMedicineClass(this.selectedPatId),
        getMedicineAllTabooAllergyFilterByType(this.selectedPatId, CODES.MEDICINE_CLASS.DIALYSATE.classType)
      ])
      await medicineList.then(async (response)=>{
        let medicinePopover = response[0].data.concat(response[2].data);
        medicinePopover.forEach((item) => {
          item.medicineName = getPrefix(item) + item.medicineName;
        })
        if (!this.initModel.replacement.cd) {
          return medicinePopover;
        }
        let medicinePopoverCd = medicinePopover.map(item => item.medicineCd)
        if (!medicinePopoverCd.includes(Number(this.initModel.replacement.cd))) {
          let medicineAll = await medicineAllergy(this.selectedPatId, true);
          let medicineAllObj = medicineAll.find(item => item.medicineCd == this.initModel.replacement.cd);
          let obj = {
            classCd: medicineAllObj.classCd,
            isDisp: "1",
            medicineCd: this.initModel.replacement.cd,
            medicineName: this.initModel.replacement.name,
            medicineType: 1,
            unit: medicineAllObj.unit,
            unitDecimalPoint: medicineAllObj.unitDecimalPoint,
            unitDecimalPointSecond: medicineAllObj.unitDecimalPointSecond,
            unitSecond: medicineAllObj.unitSecond,
          }
          medicinePopover.push(obj)
        } else {
          medicinePopover.forEach((item) => {
            if (item.medicineCd == this.initModel.replacement.cd) {
              item.medicineName = this.initModel.replacement.name;
              item.medicineCd = this.initModel.replacement.cd;
            }
          })
        }
        return medicinePopover;
      })
      return medicineList;
      // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
    },
    onChangeUnit(unit) {
      this.inputModel.useCountUnit = unit;
    },
    onChangeDecPoint(decPoint){
      this.inputModel.decPoint = decPoint;
    },
    initValueEdit(){
      Object.assign(this.initModel, this.inputModel);
    },
   //#10359 mod 編集権限の動作不正 2024-06-05 卓 start
    getItemAuthorized(pageCd, itemCd) {
      return getAuthorized(pageCd, itemCd);
    },
   //#10359 mod 編集権限の動作不正 2024-06-05 卓 end
    updateInput(fieldKey, data = {}){
      const master = new Master(data.value, data.text);
      this.inputModel[fieldKey] = master;
      this.inputModel.unit = data.unit != null && data.unit !== "" ? String(data.unit) : null;
      this.receiptUnitForCd =
        data.unitSecond != null && data.unitSecond !== "" ? String(data.unitSecond) : null;
      this.inputModel.useCountUnit = this.receiptUnitForCd;
      this.inputModel.decPoint =
        data.unitDecimalPointSecond != null && data.unitDecimalPointSecond !== ""
          ? data.unitDecimalPointSecond
          : data.unitDecimalPoint;
    },
  }
};
</script>

<style scoped>
:deep(ons-checkbox.checkbox) {
  margin-top: 0;
}

.column-ground-color {
  background-color: #D3D3D3;
  min-width: fit-content;
}

/* column-ground-color をあてた場合、黒背景だと文字が見えなくなる為、文字色(白)を解除する */
.column-ground-color :deep(label) {
  color: unset !important;
}
.text-color {
  color:var(--treatment-record-text-color);
}
.expandable-content {
  overflow: auto;
  padding: 0.2em 0px 0.2em 0;
  width: 100%;
}
:deep(.com-basic-sub-btn) {
  margin-left: 5px
}
:deep(.com-basic-sub-input) {
  min-width: 11em;
  width: 100%;
  max-width: 13em;
  background-color: #f7f7f7;
}
</style>
