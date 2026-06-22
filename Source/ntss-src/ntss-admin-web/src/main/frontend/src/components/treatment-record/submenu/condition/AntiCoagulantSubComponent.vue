/**
 * 治療記録の子機能 治療条件（抗凝固剤）
 */
<template>
  <div class="expandable-content" style="align-self: baseline;">
    <div>
      <v-ons-row :class="isUseObj[25]?'column-ground-color':null">
        <v-ons-col class="title d-flex align-items-center">
          <label class="text-color">
            抗凝固剤
          </label>
        </v-ons-col>
        <!--// add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start-->
        <common-master-selector
          :masterType="MasterType.MEDICATION_TREATMENT_CLASSTYPE_RECORD"
          :initItem="antiCoagulantSelectorInitItem"
          :editItem="antiCoagulantSelectorEditItem"
          :patientId="selectedPatId"
          :extraParams="antiCoagulantSelectorExtraParams"
          :facilityCd="getFacilityCd"
          :dialysisState="getDialysisState"
          :isMedicament="'1'"
          :hasChangedOption="true"
          :changeOptionMode="'nameAndUnit'"
          :selectedItemClass="'com-basic-sub-input'"
          :backgroundColor="'#f7f7f7'"
          :btnClass="'com-basic-sub-btn'"
          :btnDisabled="!getItemAuthorized('TreatmentRecord', 'default_authority') || !isShared"
          @popover-return="updateInput('antiCoagulant', $event)"
        />
        <!--// add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end-->
        <!--<v-ons-col class="value d-flex align-items-center">
          <show-selected-item
            :propInitValue="initModel.antiCoagulant.name"
            :propEditValue="inputModel.antiCoagulant.name"
            propBackgroundColor="#f7f7f7"
            style="min-width: 11em; width: 100%; max-width: 13em;"
          />
          <com-master-selector name="anti-coagulant" :readMasterData="getMaster" :masterDefine="masterDef" v-model="inputModel.antiCoagulant" @changeUnit="onChangeUnit"  @changeDecPoint="onChangeDecPoint" :isDisabled="!getItemAuthorized('TreatmentRecord', 'default_authority')"/>
        </v-ons-col>-->
      </v-ons-row>
      <com-number-input name="anti-coagulant-one-shot-amount" labelName="ワンショット量" :unitName="inputModel.oneShotAmountUnit" input-min-width="10em" :step="this.unitStep" :inputMin=0.0 :inputMax=99999.99 :inputType='"number"' :initialValueLock="true" v-model="inputModel.oneShotAmount" :initValue="initModel.oneShotAmount" :disabled="!getItemAuthorized('TreatmentRecord', 'default_authority')||!isShared" :class="isUseObj[26]?'column-ground-color':null"/>
      <com-number-input name="anti-coagulant-speed" labelName="持続速度" :unitName="inputModel.speedUnit" input-min-width="10em" :step="this.unitStep" :inputMin=0.0 :inputMax=99999.99 :inputType='"number"' :initialValueLock="true" v-model="inputModel.speed" :initValue="initModel.speed" :disabled="!getItemAuthorized('TreatmentRecord', 'default_authority')||!isShared" :class="isUseObj[27]?'column-ground-color':null"/>
      <com-number-input name="anti-coagulant-total-amount" labelName="持続総量" :unitName="inputModel.totalAmountUnit" input-min-width="10em" :step="this.unitStep" :inputMin=0.0 :inputMax=99999.99 :inputType='"number"' :initialValueLock="true" v-model="inputModel.totalAmount" :initValue="initModel.totalAmount" :disabled="!getItemAuthorized('TreatmentRecord', 'default_authority')||!isShared" :class="isUseObj[28]?'column-ground-color':null"/>
      <com-radio name="anti-coagulant-ip-use" labelName="IP使用選択" :radioItems=radioItems.ip v-model="inputModel.ip" :disabled="!getItemAuthorized('TreatmentRecord', 'default_authority')||!isShared" :class="isUseObj[29]?'column-ground-color':null" />
      <com-radio name="anti-coagulant-ip-start" labelName="IPスタート" :radioItems=radioItems.ipStart v-model="inputModel.ipStart" :disabled="!getItemAuthorized('TreatmentRecord', 'default_authority')||!isShared" :class="isUseObj[30]?'column-ground-color':null" />
      <com-number-input name="anti-coagulant-ip-speed" labelName="IP速度" unitName="mL/h" input-min-width="10em" :step=0.1 :inputMin=0.0 :inputMax=10.0 :inputType='"number"' v-model="inputModel.ipSpeed" :initValue="initModel.ipSpeed" :disabled="!getItemAuthorized('TreatmentRecord', 'default_authority')||!isShared" :class="isUseObj[31]?'column-ground-color':null" />
      <com-number-input name="anti-coagulant-ip-speed-max" labelName="IP速度最大値" unitName="mL/h" input-min-width="10em" :step=0.1 :inputMin=0.0 :inputMax=10.0 :inputType='"number"' v-model="inputModel.ipSpeedMax" :initValue="initModel.ipSpeedMax" :disabled="!getItemAuthorized('TreatmentRecord', 'default_authority')||!isShared" :class="isUseObj[32]?'column-ground-color':null" />
      <com-radio name="anti-coagulant-auto-one-shot" labelName="IPワンショットスタート" :radioItems=radioItems.autoOneShot v-model="inputModel.autoOneShot" :disabled="!getItemAuthorized('TreatmentRecord', 'default_authority')||!isShared" :class="isUseObj[33]?'column-ground-color':null" />
      <com-number-input name="anti-coagulant-auto-one-shot-amount" labelName="IPワンショット量" unitName="mL" input-min-width="10em" :step=0.1 :inputMin=0.0 :inputMax=20.0 :inputType='"number"' v-model="inputModel.ipOneShotAmount" :initValue="initModel.ipOneShotAmount" :disabled="!getItemAuthorized('TreatmentRecord', 'default_authority')||!isShared" :class="isUseObj[34]?'column-ground-color':null" />
      <com-radio name="anti-coagulant-ip-auto-off" labelName="IP電源自動切り" :radioItems=radioItems.autoPowerOff v-model="inputModel.ipAutoOff" :disabled="!getItemAuthorized('TreatmentRecord', 'default_authority')||!isShared" :class="isUseObj[35]?'column-ground-color':null" />
      <com-number-input name="anti-coagulant-ip-auto-off-time" labelName="IP電源自動切り時間" subLabelName="透析終了" unitName="分前" input-min-width="5em" :inputMin=0 :inputMax=120 :inputType='"number"' v-model="inputModel.ipAutoOffTime" :initValue="initModel.ipAutoOffTime" :disabled="!getItemAuthorized('TreatmentRecord', 'default_authority')||!isShared" :class="isUseObj[36]?'column-ground-color':null" />
      <com-radio name="anti-coagulant-ip-monitor-auto-off" labelName="IP電源OKモニタ切り" :radioItems=radioItems.autoPowerOff v-model="inputModel.ipMonitorAutoOff" :disabled="!getItemAuthorized('TreatmentRecord', 'default_authority')||!isShared" :class="isUseObj[37]?'column-ground-color':null" />
      <com-number-input name="anti-coagulant-ip-monitor-auto-off-time" labelName="IP電源OKモニタ切り時間" subLabelName="透析終了" unitName="分前" input-min-width="5em" :inputMin=0 :inputMax=120 :inputType='"number"' v-model="inputModel.ipMonitorAutoOffTime" :initValue="initModel.ipMonitorAutoOffTime" :disabled="!getItemAuthorized('TreatmentRecord', 'default_authority')||!isShared" :class="isUseObj[38]?'column-ground-color':null" />
    </div>
  </div>
</template>

<script>
import { mapGetters } from "@/compat/vue/vuex";
import CommonNumberInputComponent from "@/components/treatment-record/submenu/common/CommonNumberInputComponent";
//mod FNSI-redmine5848 fang start
import CommonRadio from "@/components/treatment-record/submenu/common/CommonRadioOffComponent";
//mod FNSI-redmine5848 fang end
// mod FutreNetWeb+SI課題管理 no.5531 劉全航 start
import CommonMasterSelectorComponent from "@/components/common/master-selector/TreatmentRecordSelectorComponent";
import CustomDivShowSelectedItem from "@/components/common/custom-form-tags/CustomDivShowSelectedItem";
// mod FutreNetWeb+SI課題管理 no.5531 劉全航 end
import {
  getMedicineAllTabooAllergyFilterByType,
  sendRequestGetMstMedicineClass
} from "@/apis/treatment-record";
import { medicineAntiCoagulant } from "@/components/common/master-selector/MasterSelectorDefinitions";
import { CODES } from "@/constants/TreatmentRecord";
import { AntiCoagulant } from "@/models/treatment-record/condition/AntiCoagulant";
import BigNumber from "@/compat/number/bignumber";
//#10359 mod 編集権限の動作不正 2024-06-05 卓 start
// #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
import { getAuthorized, getPrefix } from "@/functions/common/CommonFunctions.js";
// #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
//#10359 mod 編集権限の動作不正 2024-06-05 卓 end
// add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
import { medicineAllergy, medicineMixAllergy } from "@/functions/mst/MstGetters.js";
// add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
// add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start
import commonMasterSelector from "@/components/common/master-selector/CommonMasterSelector.vue";
import * as MasterType from "@/components/common/master-selector/MasterType";
import { Master } from "@/models/common/master-selector-condition/Master";
// add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end
export default {
  components: {
    "com-number-input": CommonNumberInputComponent,
    "com-radio": CommonRadio,
    "com-master-selector": CommonMasterSelectorComponent,
    "show-selected-item": CustomDivShowSelectedItem,
    // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start
    "common-master-selector": commonMasterSelector,
    // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end
  },
  emits: ["update:modelValue"],
  props: {
    // Vue3 既定 v-model は modelValue / update:modelValue を使用する。
    modelValue: {
      type: AntiCoagulant
    },
//#10359 mod 編集権限の動作不正 2024-06-05 卓 start
//#10359 mod 編集権限の動作不正 2024-06-05 卓 end
    //mod FNSI-改修内容背景色 房 start
    columnList: {
      type: Array
    },
//#10359 mod 編集権限の動作不正 2024-06-05 卓 start
//#10359 mod 編集権限の動作不正 2024-06-05 卓 end
    //mod FNSI-改修内容背景色 房 end
  },
  data() {
    return {
      // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start
      initItem:{
        text: '',
        value: ''
      },
      extraParamsList:{},
      MasterType,
      // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end
      inputModel: new AntiCoagulant(),
      masterSelected: false,
      masterDef: medicineAntiCoagulant,
      radioItems: {
        ip: CODES.IP,
        ipStart: CODES.IP_START,
        autoOneShot: CODES.AUTO_ONE_SHOT,
        autoPowerOff: CODES.AUTO_POWER_OFF
      },
      initModel: new AntiCoagulant(),
      initFlag: 1,
      isUseObj: {}
    };
  },
  computed: {
    ...mapGetters("pat-info", ["selectedPatId"]),
    // add FNSI-共有を追加 王 20200921 start
    ...mapGetters("user", ["getFacilityCd"]),
    // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start
    ...mapGetters("treatment-record/common", ["getSharedFacilityCd","getDialysisState","getTreatDate"]),
    // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end
    isShared() {
      return this.getFacilityCd === this.getSharedFacilityCd;
    },
    // add FNSI-共有を追加 王 20200921 end
    unitStep(){
      var num = parseInt(this.inputModel.decPoint);
      if(isNaN(num)){
        num = 0;
      }
      var data = Number(BigNumber(10).exponentiatedBy(BigNumber(num).negated()).valueOf());
      return data;
    },
    antiCoagulantSelectorInitItem() {
      return {
        text:
          this.initModel && this.initModel.antiCoagulant && this.initModel.antiCoagulant.name
            ? this.initModel.antiCoagulant.name
            : "",
        value:
          this.initModel && this.initModel.antiCoagulant && this.initModel.antiCoagulant.cd != null
            ? this.initModel.antiCoagulant.cd
            : null,
        unit:
          this.initModel && this.initModel.oneShotAmountUnit != null && this.initModel.oneShotAmountUnit !== ""
            ? String(this.initModel.oneShotAmountUnit)
            : null
      };
    },
    antiCoagulantSelectorEditItem() {
      return {
        text:
          this.inputModel && this.inputModel.antiCoagulant && this.inputModel.antiCoagulant.name
            ? this.inputModel.antiCoagulant.name
            : "",
        value:
          this.inputModel && this.inputModel.antiCoagulant && this.inputModel.antiCoagulant.cd != null
            ? this.inputModel.antiCoagulant.cd
            : null,
        unit:
          this.inputModel && this.inputModel.oneShotAmountUnit != null && this.inputModel.oneShotAmountUnit !== ""
            ? String(this.inputModel.oneShotAmountUnit)
            : null
      };
    },
    antiCoagulantSelectorExtraParams() {
      return Object.assign({}, this.extraParamsList || {});
    },
  },
  watch: {
    modelValue() {
      this.inputModel = this.modelValue;
      // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
      if (this.inputModel?.antiCoagulant?.cd && !this.inputModel?.antiCoagulant?.cd?.toString().includes('$')) {
        this.inputModel.antiCoagulant.cd = Number(this.inputModel.antiCoagulant.cd);
      }
      // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
      //del 10823 治療記録>治療条件で別治療日の内容を表示すると緑枠で表示されることがある 張玲 start
        Object.assign(this.initModel, this.modelValue);
        // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start
        this.initItem.text = this.initModel.antiCoagulant.name;
        this.initItem.value = this.initModel.antiCoagulant.cd;
        this.extraParamsList = {
          treatDate: this.getTreatDate,
          rstInfo: {
            rstName: this.inputModel.antiCoagulant.name,
            rstUnit: this.inputModel.oneShotAmountUnit
          },
          actualName: this.initModel?.antiCoagulant?.name || this.inputModel?.antiCoagulant?.name || "",
          classType: 1,
          // 初期値が削除・非表示でも SQL INIT で拾えるように渡す
          initValue: this.initModel.antiCoagulant.cd,
          // 初期値が通常薬剤/調製薬剤どちらか判別するために渡す
          medicineType: this.initModel.antiCoagulant.type ?? this.inputModel.antiCoagulant.type
        };
      // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end
      //del 10823 治療記録>治療条件で別治療日の内容を表示すると緑枠で表示されることがある 張玲 end
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
      const items = this.columnList.filter(e => e.category_no === 5 || e.category_no === 6);
      items?.[0]?.items?.forEach((item) => {
        this.isUseObj[item.ctl_no] = item.is_use === '0';
      });
    }
  },
  methods: {
    // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start
    updateInput(fieldKey, data = {}){
      const master = new Master(data.value, data.text);
      master.type = data.kbnValue;
      this.inputModel.oneShotAmountUnit = data.unit;
      this.inputModel.speedUnit = data.unit ? data.unit + "/h" : "";
      this.inputModel.totalAmountUnit = data.unit;
      this.inputModel[fieldKey] = master;
    },
    // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end
    // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
    async getMaster() {
      let medicineList = Promise.all([
        getMedicineAllTabooAllergyFilterByType(this.selectedPatId, CODES.MEDICINE_CLASS.ANTI_COAGULANT.classType),
        sendRequestGetMstMedicineClass(this.selectedPatId),
      ]);
      await medicineList.then(async (response)=>{
        let medicinePopover = response[0].data;
        medicinePopover.forEach((item) => {
          item.medicineName = getPrefix(item) + item.medicineName;
        })
        if (!this.initModel.antiCoagulant.cd) {
          return medicinePopover;
        }
        let medicinePopoverCd = medicinePopover.map(item => item.medicineCd)
        let cd = parseInt(this.initModel.antiCoagulant.cd);
        let name = this.initModel.antiCoagulant.name;
        if (!medicinePopoverCd.includes(cd)) {
          let medicineAll = await medicineAllergy(this.selectedPatId, true);
          let medicineAllObj = medicineAll.find(item => item.medicineCd == cd);
          let isMix = false;
          if (!medicineAllObj) {
            let medicineMixAll = await medicineMixAllergy(this.selectedPatId, true);
            medicineAllObj = medicineMixAll.find(item => item.medicineMixCd == cd);
            isMix = true;
          }
          let obj = {
            classCd: medicineAllObj.classCd,
            isDisp: "1",
            medicineCd: cd,
            medicineName: name,
            medicineType: isMix ? 2 : 1,
            unit: medicineAllObj.unit,
            unitDecimalPoint: medicineAllObj.unitDecimalPoint,
            unitDecimalPointSecond: medicineAllObj.unitDecimalPointSecond,
            unitSecond: medicineAllObj.unitSecond,
          }
          medicinePopover.push(obj)
        } else {
          medicinePopover.forEach((item) => {
            if (item.medicineCd == cd) {
              item.medicineName = name;
            }
          })
        }
        return medicinePopover;
      })
      return medicineList;
      // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
    },
    onChangeUnit(unit) {
      this.inputModel.oneShotAmountUnit = unit;
      this.inputModel.speedUnit = unit ? unit + "/h" : "";
      this.inputModel.totalAmountUnit = unit;
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
 
/* add FNSI-redmine3855 徐 start */
.isClass :deep(ons-button) {
  margin-right:30em
}
/* add FNSI-redmine3855 徐 end */
.expandable-content {
  overflow: auto;
  padding: 0.2em 0px 0.2em 0;
}
.text-color {
  color:var(--treatment-record-text-color);
}
/*/ add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start*/
:deep(.com-basic-sub-btn) {
  margin-left: 5px
}
:deep(.com-basic-sub-input) {
  min-width: 11em;
  width: 100%;
  max-width: 13em;
  background-color: #f7f7f7;
}
/*/ add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end*/
</style>
