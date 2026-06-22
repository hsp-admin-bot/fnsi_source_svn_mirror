/**
 * 治療記録の子機能 治療条件（透析液）
 */
<template>
<!-- mod FutreNetWeb+SI課題管理 no.5531 劉全航 start -->
<!-- <div class="expandable-content"> -->
  <div class="expandable-content" style="align-self: baseline;">
<!-- mod FutreNetWeb+SI課題管理 no.5531 劉全航 end -->
    <div>
      <!-- mod FNSI-改修内容背景色 房 start -->
      <!-- mod FNSI-redmine3855 徐 start -->
      <!-- <com-master-selector name="dialysate" labelName="透析液" :readMasterData="getMaster" :masterDefine="masterDef" v-model="inputModel.dialysate" @changeUnit="onChangeUnit" @changeDecPoint="onChangeDecPoint" :class="styleFlag?'column-ground-color':null"/> -->
      <!-- mod FutreNetWeb+SI課題管理 no.5531 劉全航 start -->
      <v-ons-row :class="isUseObj[15]?'column-ground-color':null">
        <v-ons-col class="title d-flex align-items-center">
          <label class="text-color">
            透析液
          </label>
        </v-ons-col>
        <v-ons-col class="value d-flex align-items-center">
          <common-master-selector
            :masterType="MasterType.MEDICATION_TREATMENT_CLASSTYPE_RECORD"
            :initItem="dialysateSelectorInitItem"
            :editItem="dialysateSelectorEditItem"
            :patientId="selectedPatId"
            :extraParams="dialysateSelectorExtraParams"
            :facilityCd="getFacilityCd"
            :dialysisState="getDialysisState"
            :hasChangedOption="true"
            :changeOptionMode="'nameAndUnit'"
            :selectedItemClass="'com-basic-sub-input'"
            :backgroundColor="'#f7f7f7'"
            :btnClass="'com-basic-sub-btn'"
            :btnDisabled="!getItemAuthorized('TreatmentRecord', 'default_authority') || !isShared"
            @popover-return="updateInput('dialysate', $event)"
          />
        </v-ons-col>
      </v-ons-row>
      <!-- <com-master-selector name="dialysate" labelName="透析液" :readMasterData="getMaster" :masterDefine="masterDef" v-model="inputModel.dialysate" @changeUnit="onChangeUnit" @changeDecPoint="onChangeDecPoint" v-show="!isMobileBrowser" :class="['isClass', styleFlag?'column-ground-color':null]"/>
      <com-master-selector name="dialysate" labelName="透析液" :readMasterData="getMaster" :masterDefine="masterDef" v-model="inputModel.dialysate" @changeUnit="onChangeUnit" @changeDecPoint="onChangeDecPoint" v-show="isMobileBrowser" :class="[styleFlag?'column-ground-color':null]"/> -->
      <!-- mod FutreNetWeb+SI課題管理 no.5531 劉全航 end -->
      <!-- mod FNSI-redmine3855 徐 end -->
      <!-- mod FNSI-共有を追加 王 20200921 start -->
      <!-- mod #5589 2023/03/30 数値IFのスタイル全不正 張博 start -->
      <!-- <com-number-input name="dialysate-flow-rate" labelName="透析液流量" unitName="mL/min" input-min-width="10em" :min=100 :max=700 v-model="inputModel.flowRate" :disabled="!isShared || styleFlag" :class="styleFlag?'column-ground-color':null" :initValue="initModel.flowRate" />
      <com-number-input name="dialysate-amount" labelName="透析液使用数" :unitName="inputModel.amountUnit" input-min-width="10em" :step="this.unitStep" :min=0.00 :max=99999.99 :initialValueLock="true" v-model="inputModel.amount" :disabled="!isShared || styleFlag" :class="styleFlag?'column-ground-color':null" :initValue="initModel.amount" />
      <com-number-input name="dialysate-temperature" labelName="透析液温度" unitName="℃" input-min-width="10em" :step=0.1 :min=33.0 :max=40.0 v-model="inputModel.temperature" :disabled="!isShared || styleFlag" :class="styleFlag?'column-ground-color':null" :initValue="initModel.temperature" /> -->
      <!-- mod #9342 start ljx -->
      <!--<com-number-input name="dialysate-flow-rate" labelName="透析液流量" unitName="mL/min" input-min-width="10em" :step="1" :inputMin="100"  :inputMax="700" :inputType='"number"' v-model="inputModel.flowRate" :disabled="!isShared || styleFlag" :class="styleFlag?'column-ground-color':null" :initValue="initModel.flowRate" />
      <com-number-input name="dialysate-amount" labelName="透析液使用数" :unitName="inputModel.amountUnit" input-min-width="10em" :step="this.unitStep" :inputMin=0.00 :inputMax=99999.99 :inputType='"number"' :initialValueLock="true" v-model="inputModel.amount" :disabled="!isShared || styleFlag" :class="styleFlag?'column-ground-color':null" :initValue="initModel.amount" />
      <com-number-input name="dialysate-temperature" labelName="透析液温度" unitName="℃" input-min-width="10em" :step=0.1 :inputMin=33.0 :inputMax=40.0 :inputType='"number"' v-model="inputModel.temperature" :disabled="!isShared || styleFlag" :class="styleFlag?'column-ground-color':null" :initValue="initModel.temperature" />-->
        <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 start-->
      <com-number-input name="dialysate-flow-rate" labelName="透析液流量" unitName="mL/min" input-min-width="10em" :step="1" :inputMin="100"  :inputMax="700" :inputType='"number"' v-model="inputModel.flowRate" :disabled="!getItemAuthorized('TreatmentRecord', 'default_authority') ||!isShared" :class="isUseObj[16]?'column-ground-color':null" :initValue="initModel.flowRate" />
      <com-number-input name="dialysate-amount" labelName="透析液使用数" :unitName="inputModel.amountUnit" input-min-width="10em" :step="this.unitStep" :inputMin=0.00 :inputMax=99999.99 :inputType='"number"' :initialValueLock="true" v-model="inputModel.amount" :disabled=" !getItemAuthorized('TreatmentRecord', 'default_authority')||!isShared" :class="isUseObj[17]?'column-ground-color':null" :initValue="initModel.amount" />
      <com-number-input name="dialysate-temperature" labelName="透析液温度" unitName="℃" input-min-width="10em" :step=0.1 :inputMin=33.0 :inputMax=40.0 :inputType='"number"' v-model="inputModel.temperature" :disabled="!getItemAuthorized('TreatmentRecord', 'default_authority')||!isShared" :class="isUseObj[18]?'column-ground-color':null" :initValue="initModel.temperature" />
        <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 end-->
      <!-- mod #9342 end ljx -->
      <!-- mod #5589 2023/03/30 数値IFのスタイル全不正 張博 end -->
      <!-- mod FNSI-共有を追加 王 20200921 end -->
      <!-- mod FNSI-改修内容背景色 房 end -->
    </div>
  </div>
</template>

<script>
import { mapGetters } from "@/compat/vue/vuex";
import CommonNumberInputComponent from "@/components/treatment-record/submenu/common/CommonNumberInputComponent";
// mod FutreNetWeb+SI課題管理 no.5531 劉全航 start
// import CommonMasterSelectorComponent from "@/components/common/master-selector/CommonMasterSelectorComponent";
import CommonMasterSelectorComponent from "@/components/common/master-selector/TreatmentRecordSelectorComponent";
import CustomDivShowSelectedItem from "@/components/common/custom-form-tags/CustomDivShowSelectedItem";
// mod FutreNetWeb+SI課題管理 no.5531 劉全航 end
import {
  getMedicineAllTabooAllergyFilterByType,
  sendRequestGetMstMedicineClass
} from "@/apis/treatment-record";
//#10123:透析液/補液の薬剤選択モーダルの薬剤区分の表示が不要 Start
import { medicineDialysateReplacement } from "@/components/common/master-selector/MasterSelectorDefinitions";
//#10123:透析液/補液の薬剤選択モーダルの薬剤区分の表示が不要 End
import { CODES } from "@/constants/TreatmentRecord";
import { Dialysate } from "@/models/treatment-record/condition/Dialysate";
import BigNumber from "@/compat/number/bignumber";
//#10359 mod 編集権限の動作不正 2024-06-05 卓 start
// #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
// import { getAuthorized } from "@/functions/common/CommonFunctions.js";
import { getAuthorized, getPrefix } from "@/functions/common/CommonFunctions.js";
// #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
//#10359 mod 編集権限の動作不正 2024-06-05 卓 end
// add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
import { medicineAllergy } from "@/functions/mst/MstGetters.js";
// add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
import commonMasterSelector from "@/components/common/master-selector/CommonMasterSelector.vue";
import * as MasterType from "@/components/common/master-selector/MasterType";
import { Master } from "@/models/common/master-selector-condition/Master";

export default {
  components: {
    "com-number-input": CommonNumberInputComponent,
    "com-master-selector": CommonMasterSelectorComponent,
    "show-selected-item": CustomDivShowSelectedItem,
    "common-master-selector": commonMasterSelector
  },
  emits: ["update:modelValue"],
  props: {
    // Vue3 既定 v-model は modelValue / update:modelValue を使用する。
    modelValue: {
      type: Dialysate
    },
    //mod FNSI-改修内容背景色 房 start
    columnList: {
      type: Array
    },
    //mod FNSI-改修内容背景色 房 end
    //add FNSI修正 結合バッグ20 房 start
    treatmentConditionCd : {
      type: Number
    },
    replacementData: {
      type: Object
    },
    //#10359 mod 編集権限の動作不正 2024-06-05 卓 start
    // hasAuthority: {
    //   type: Boolean
    // }
    //#10359 mod 編集権限の動作不正 2024-06-05 卓 end
    //add FNSI修正 結合バッグ20 房 end

  },
  data() {
    return {
      inputModel: new Dialysate(),
      //#10123:透析液/補液の薬剤選択モーダルの薬剤区分の表示が不要 Start
      masterDef: medicineDialysateReplacement,
      //#10123:透析液/補液の薬剤選択モーダルの薬剤区分の表示が不要 End
      //mod FNSI-改修内容背景色 房 start
      styleFlag: false,
      //mod FNSI-改修内容背景色 房 end
      initModel: new Dialysate(),
      initFlag: 1,
      isUseObj: {},
      MasterType,
      initItem:{
        text: "",
        value: ""
      },
      extraParamsList:{},
      receiptUnitForCd: null,
    };
  },
  computed: {
    ...mapGetters("pat-info", ["selectedPatId"]),
    // add FNSI-共有を追加 王 20200921 start
    ...mapGetters("user", ["getFacilityCd"]),
    ...mapGetters("treatment-record/common", ["getSharedFacilityCd", "getTreatDate", "getDialysisState"]),
    isShared() {
      return this.getFacilityCd === this.getSharedFacilityCd;
    },
    // add FNSI-redmine3855 徐 start
    isMobileBrowser() {
      return /android|iphone|ipad/i.test(((this?.$el?.ownerDocument?.defaultView?.navigator?.userAgent) || globalThis?.navigator?.userAgent || ""));
    },
    // add FNSI-redmine3855 徐 end
    // add FNSI-共有を追加 王 20200921 end
    // 単位小数部:step制御用パラメータ
    unitStep(){
      var num = parseInt(this.inputModel.decPoint);
      if(isNaN(num)){
        num = 0;
      }
      var data = Number(BigNumber(10).exponentiatedBy(BigNumber(num).negated()).valueOf());
      return data;
    },
    dialysateSelectorInitItem() {
      return {
        text: this.initItem && this.initItem.text ? this.initItem.text : "",
        value: this.initItem && this.initItem.value != null ? this.initItem.value : null,
        unit:
          this.initModel && this.initModel.unit != null && this.initModel.unit !== ""
            ? String(this.initModel.unit)
            : null,
        unitSecond:
          this.initModel && this.initModel.amountUnit != null && this.initModel.amountUnit !== ""
            ? String(this.initModel.amountUnit)
            : null
      };
    },
    dialysateSelectorEditItem() {
      return {
        text:
          this.inputModel && this.inputModel.dialysate && this.inputModel.dialysate.name
            ? this.inputModel.dialysate.name
            : "",
        value:
          this.inputModel && this.inputModel.dialysate && this.inputModel.dialysate.cd != null
            ? this.inputModel.dialysate.cd
            : null,
        unit:
          this.inputModel && this.inputModel.unit != null && this.inputModel.unit !== ""
            ? String(this.inputModel.unit)
            : null,
        unitSecond: this.receiptUnitForCd != null && this.receiptUnitForCd !== "" ? this.receiptUnitForCd : null
      };
    },
    dialysateSelectorExtraParams() {
      const extra = Object.assign({}, this.extraParamsList || {});
      extra.receiptUnit = this.initModel.amountUnit;
      extra.compareReceiptUnit = true;
      return extra;
    },
  },
  watch: {
    modelValue() {
      this.inputModel = this.modelValue;
      //mod 10823 治療記録>治療条件で別治療日の内容を表示すると緑枠で表示されることがある 張玲 start
      Object.assign(this.initModel, this.modelValue);
      this.initItem.text = this.initModel.dialysate.name;
      this.initItem.value = this.initModel.dialysate.cd;
      this.receiptUnitForCd =
        this.inputModel && this.inputModel.amountUnit != null && this.inputModel.amountUnit !== ""
          ? String(this.inputModel.amountUnit)
          : null;
      this.extraParamsList = {
        treatDate: this.getTreatDate,
        rstInfo: {
          rstName: this.inputModel.dialysate.name,
          rstUnit: this.inputModel.amountUnit
        },
        actualName:
          (this.initModel && this.initModel.dialysate && this.initModel.dialysate.name
            ? this.initModel.dialysate.name
            : (this.inputModel && this.inputModel.dialysate && this.inputModel.dialysate.name
              ? this.inputModel.dialysate.name
              : "")),
        classType: 2,
        // 初期値が削除・非表示でも SQL INIT で拾えるように渡す
        initValue: this.initModel.dialysate.cd,
        // 透析液は通常薬剤として扱う
        medicineType: 1
      };
      // if (this.initFlag == 1) {
      //   Object.assign(this.initModel, this.modelValue);
      //   this.initFlag = 2;
      // }
      //mod 10823 治療記録>治療条件で別治療日の内容を表示すると緑枠で表示されることがある 張玲 end
    },
    inputModel: {
      handler: function(val) {
        //add FNSI修正 結合バッグ20 房 start
        // mod 7884 補液の「選択」を非活性にする事 房 start
        if (this.treatmentConditionCd == 7 || this.treatmentConditionCd == 8 || this.treatmentConditionCd == 10) {
        // mod 7884 補液の「選択」を非活性にする事 房 end
          if (this.replacementData != undefined && this.replacementData != null) {
            if (val != undefined && val != null) {
              this.replacementData.replacement.cd = val.dialysate.cd;
              this.replacementData.replacement.name = val.dialysate.name;
              // add 9351 by kangjie 20240206 start
              this.replacementData.useCountUnit = val.amountUnit;
              this.replacementData.decPoint = val.decPoint;
              // add 9351 by kangjie 20240206 end
            }
          }
        }
        //add FNSI修正 結合バッグ20 房 end
        this.$emit("update:modelValue", val);
      },
      deep: true
    },
    //mod FNSI-改修内容背景色 房 start
    columnList() {
      //add FNSI-9369 ljx start
      if(this.columnList == null){
        return;
      }
      //add FNSI-9369 ljx end
      const items = this.columnList.filter(e => e.category_no === 3);
      // upd #11255 FNWで指示無し実績をコンバートしたデータを患者経過総合ビューアで表示するとフリーズする。 20241203 ztc start
      // if (items[0].items[0].is_use === "1") {
      if (items[0] && items[0].items && items[0].items[0] && items[0].items[0].is_use === "1") {
        // upd #11255 FNWで指示無し実績をコンバートしたデータを患者経過総合ビューアで表示するとフリーズする。 20241203 ztc end
        this.styleFlag = false;
      } else {
        this.styleFlag = true;
      }
      items?.[0]?.items?.forEach((item) => {
        this.isUseObj[item.ctl_no] = item.is_use === '0';
      });
    }
    //mod FNSI-改修内容背景色 房 end
  },
  methods: {
    // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
    async getMaster() {
      // return Promise.all([
      //   getMedicineAllTabooAllergyFilterByType(this.selectedPatId, CODES.MEDICINE_CLASS.DIALYSATE.classType),
      //   sendRequestGetMstMedicineClass()
      // ]);
      let medicineList = Promise.all([
        getMedicineAllTabooAllergyFilterByType(this.selectedPatId, CODES.MEDICINE_CLASS.DIALYSATE.classType),
        sendRequestGetMstMedicineClass(this.selectedPatId)
      ])
      await medicineList.then(async (response)=>{
        let medicinePopover = response[0].data;
        medicinePopover.forEach((item) => {
          item.medicineName = getPrefix(item) + item.medicineName;
        })
        if (!this.initModel.dialysate.cd) {
          return medicinePopover;
        }
        let medicinePopoverCd = medicinePopover.map(item => item.medicineCd)
        if (!medicinePopoverCd.includes(Number(this.initModel.dialysate.cd))) {
          let medicineAll = await medicineAllergy(this.selectedPatId, true);
          let medicineAllObj = medicineAll.find(item => item.medicineCd == this.initModel.dialysate.cd);
          let obj = {
            classCd: medicineAllObj.classCd,
            isDisp: "1",
            medicineCd: this.initModel.dialysate.cd,
            medicineName: this.initModel.dialysate.name,
            medicineType: 1,
            unit: medicineAllObj.unit,
            unitDecimalPoint: medicineAllObj.unitDecimalPoint,
            unitDecimalPointSecond: medicineAllObj.unitDecimalPointSecond,
            unitSecond: medicineAllObj.unitSecond,
          }
          medicinePopover.push(obj)
        } else {
          medicinePopover.forEach((item) => {
            if (item.medicineCd == this.initModel.dialysate.cd) {
              item.medicineName = this.initModel.dialysate.name;
              item.medicineCd = this.initModel.dialysate.cd;
            }
          })
        }
        return medicinePopover;
      })
      return medicineList;
    },
    // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
    onChangeUnit(unit) {
      this.inputModel.amountUnit = unit;
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
      this.receiptUnitForCd = data.unitSecond != null && data.unitSecond !== "" ? String(data.unitSecond) : null;
      this.inputModel.amountUnit = this.receiptUnitForCd;
      this.inputModel.decPoint =
        data.unitDecimalPointSecond != null && data.unitDecimalPointSecond !== ""
          ? data.unitDecimalPointSecond
          : data.unitDecimalPoint;
    },
  }
};
</script>

<style scoped>
.column-ground-color {
  background-color: #D3D3D3;
  min-width: fit-content;
}

/* column-ground-color をあてた場合、黒背景だと文字が見えなくなる為、文字色(白)を解除する */
.column-ground-color :deep(label) {
  color: unset !important;
}
 /* mod FutreNetWeb+SI課題管理 no.5531 劉全航 start */
/* add FNSI-redmine3855 徐 start */
/* .isClass :deep(ons-button){
  margin-right:30em
} */
/* add FNSI-redmine3855 徐 end */
.text-color {
  color:var(--treatment-record-text-color);
}
/* mod FutreNetWeb+SI課題管理 no.5531 劉全航 end */
.expandable-content {
  overflow: auto;
  padding: 0.2em 0px 0.2em 0;
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
