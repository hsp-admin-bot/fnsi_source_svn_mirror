/**
* マスタ選択＆数値入力共通コンポーネント
*/
<template>
  <!-- 治療記録＞体重＞透析前(透析後)体重入力＞車いすで使用 -->
  <v-ons-row v-if="typeNo === 0">
    <v-ons-col class="title">
      <label class="theme">
        {{ themeLable + (value.name != null ? value.name : "") }}
      </label>
    </v-ons-col>
    <v-ons-col class="num-value">

      <custom-input-number-pro
          ref="mySelect"
          :disabled="disabled"
          :style="{ 'min-width': inputMinWidth }"
          :value="currentValuePro"
          :emptyVal="null"
          :max="inputMax"
          :min="inputMin"
          :step="step"
          @handlerInput="handlerInput"
          @blur="handlerBlur"
        />
      <label style="margin-left: 0.5em;">{{unitName}}</label>
      <v-ons-button
        class="button select-btn btn3-normal"
        style="margin-left: 0.5em;"
        @click="createPopoverData(value.cd)"
        :disabled="disabled">選択</v-ons-button>
      <pop-over v-bind="popoverData" @popover-close="closePopover" @popover-return="updateInput" />
    </v-ons-col>
  </v-ons-row>
  
  <!-- 治療記録＞愁訴処置＞愁訴処置登録＞処置薬剤／手技で使用 -->
  <div v-else>
    <div style="display: flex; flex-wrap: wrap; align-items: center; width: 100%;">
      <label style="flex-shrink: 1; flex-grow: 1; margin-right: 1em; white-space: normal; word-break: break-word; overflow-wrap: break-word;">
        {{ themeLable + (value.name != null ? value.name : "") }}
      </label>

      <div style="display: flex; justify-content: flex-end; align-items: center; flex: 1; min-width: 200px;">
        <custom-input-number-pro
          :key="customInputNumberProKey"
          ref="mySelect"
          style="width: 6em; margin-right: 0.5em; line-height: 2em;"
          :emptyVal="null"
          :value="currentValuePro"
          :max="inputMax"
          :min="inputMin"
          :step="step"
          :disabled="disabled || !value.name"
          :invalidArray="invalidArrayMethod()"
          @handlerInput="handlerInput"
          @blur="handlerBlur"
          :required="value.cd && required"
        />
        <span style="margin-right: 0.5em;">{{ unitName }}</span>
        <!--// add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start-->
        <common-master-selector
          style="width: fit-content; flex: none;" 
          :masterType="MasterType.ANTICOAGULANT_INDICATION"
          :initItem="{text:value.name,value:value.cd}"
          :editItem="{text:value.name,value:value.cd}"
          :extraParams="{treatDate: treatDate,rstInfo:{ rstName:value.name, rstUnit: unitName}}"
          :patientId="selectedPatId"
          :facilityCd="getFacilityCd"
          :dialysisState="getDialysisState"
          :isMedicament="'0'"
          :btnName="'選択'"
          :isVisible="false"
          :hasChangedOption="true"
          :selectedItemClass="'com-basic-sub-input'"
          :backgroundColor="'#f7f7f7'"
          :btnClass="'com-basic-sub-btn'"
          :btnDisabled="disabled"
          @popover-return="masterUpdateInput($event);"
        />
        <!--<v-ons-button
          class="button select-btn btn3-normal"
          style="width: 2em; margin-left: 0.5em;"
          @click="createPopoverData(value.cd)"
          :disabled="disabled">
          選択
          <pop-over v-bind="popoverData" @popover-close="closePopover" @popover-return="updateInput" />
        </v-ons-button>-->
      <!--// add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end-->
      </div>
    </div>
  </div>
</template>

<script>
import MasterSelectorMixin from "@/components/common/master-selector/MasterSelectorMixin";
import NumberInputMixin from "@/components/treatment-record/submenu/common/NumberInputMixin";
import { MasterAndNumber } from "@/models/common/MasterAndNumber";
import BigNumber from "bignumber.js";
import CustomInputNumberPro from '@/components/common/custom-form-tags/CustomInputNumberPro';

// add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start
import commonMasterSelector from "@/components/common/master-selector/CommonMasterSelector.vue";
import * as MasterType from "@/components/common/master-selector/MasterType";
import { Master } from "@/models/common/master-selector-condition/Master";
import { getMstListCompose } from "@/apis/pat-prescription"
import { mapGetters, mapActions } from "vuex";
// add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end

export default {
  mixins: [MasterSelectorMixin, NumberInputMixin],
  components: {
    // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start
    "common-master-selector": commonMasterSelector,
    // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end
    "custom-input-number-pro": CustomInputNumberPro
  },
  // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start
  computed: {
  ...mapGetters("pat-info", ["selectedPatId"]),
  ...mapGetters("user", ["getFacilityCd"]),
  ...mapGetters("treatment-record/common", ["getDialysisState"]),
  },
  // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end
  props: {
    name: {
      type: String
    },
    value: {
      type: MasterAndNumber
    },
    disabled: {
      type: Boolean,
      default: false
    },
    showClassFilter: {
      type: Boolean,
      default: true
    },
    themeLable: {
      type: String,
      default: ""
    },
    typeNo: {
      type: Number,
      default: 0
    },
    inputMinWidth: {
      type: String,
      default: ""
    },
    inputMax:{
      type: Number,
      default: null
    },
    inputMin:{
      type: Number,
      default: null
    },
    required: {
      type: Boolean,
      default: false
    }
  },
  data() {
    return {
      // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start
      treatDate:'',
      MasterType,
      // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end
      blurFlg: false,
      focusFlg: false,
      initNum: {},
      indexNum: 0,
      customInputNumberProKey: 0,
      // 車いす重量をg⇒kgに変換して表示する必要があるので初期化の際も必要 (this.value.value / this.base) 
      // Mixinのthis.decimalLengthはこの時点では評価されないので代わりにdecimalPlacesで小数部桁数を取得する
      currentValuePro: this.value.value != null ? (this.value.value / this.base).toFixed(BigNumber(this.step).decimalPlaces()) : this.value.value,
    }
  },
  watch: {
    "value.cd" (val) {
      if (!val) {
        // 車いす「未登録」を選択した場合は値をクリアしない
        this.currentValuePro = this.typeNo === 0 ? this.currentValuePro : null;
      } else {
        this.currentValuePro = this.value.value != null ? (this.value.value / this.base).toFixed(this.decimalLength) : null;
      }
      this.$emit(
        "input",
        new MasterAndNumber(val, this.value.name, (typeof this.currentValuePro === "number" || (typeof this.currentValuePro === "string") && this.currentValuePro !== "") ? (this.currentValuePro * this.base) : null)
      );
      this.customInputNumberProKey++;
    }
  },
  mounted () {
    this.initNum = this.value
  },
  methods: {
    invalidArrayMethod() {
      const invalidNumber = 0;
      if (!this.value.cd) {
        return [];
      }
      return ['', null, invalidNumber.toFixed(this.decimalLength)];
    },
    handlerInput(val) {
      this.currentValuePro = val;
    },
    handlerBlur() {
      this.$nextTick(() => {
        this.$emit(
          "input",
          new MasterAndNumber(
            this.value.cd,
            this.value.name,
            (typeof this.currentValuePro === "number" || (typeof this.currentValuePro === "string") && this.currentValuePro !== "") ? (this.currentValuePro * this.base) : null
          )
        );
      })

    },
    // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start
    masterUpdateInput(val){
      const data = {
        fnValue:{
          '薬剤分類': val.classCd,
          '薬剤区分': val.kbnValue
        },
        isDisp: val.isDisp,
        text: val.text,
        type: val.kbnValue,
        value: Number(val.value),
        unit: val.unit,
        decPoint: val.unitDecimalPoint
      }
      this.updateInput(data)
    },
    // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end
    updateInput(data) {
      this.popoverData.popoverContentSelected = data;
      this.$emit("changeValue", data.weight === undefined ? null : data.weight);
      this.$emit("changeUnit", data.unit === undefined ? null : data.unit);
      this.$emit(
        "input",
        new MasterAndNumber(data.value, data.text, this.value.value)
      );
      if(data.hasOwnProperty("fnValue")) {
        if(data.fnValue.hasOwnProperty("薬剤区分")) {
          this.$emit("changeMedicineType", {
            medicineType: data.fnValue["薬剤区分"],
            treatClass: data.fnValue["薬剤区分"] == '1' ? 1 : data.fnValue["薬剤区分"] == '2' ? 0 : undefined
          });
        }
      }
      // 指示単位小数部:step制御用パラメータ
      var num = parseInt(data.decPoint);
      if(isNaN(num)){
        num = 0;
      }
      var step = BigNumber(10).exponentiatedBy(BigNumber(num).negated()).valueOf();
      this.$emit("changeStep", Number(step));
      this.currentValuePro && this.$emit("change", parseFloat(this.currentValuePro || 0).toFixed(data.decPoint));

      this.$nextTick(() => {
        this.$refs.mySelect.handleFocus();
      })
    }
  }
};
</script>

<style scoped>
.title ons-input {
  margin-right: 0.5em;
}
.num-value ons-input {
  width: 10em;
}
.select-btn {
  padding: 0.2em 1em 0em 1em;
  line-height: 2em;
  min-width: 4em;
  font-size: 1em;
  cursor: pointer;
}
.select-btn:hover {
  color: #212529;
}
/* // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong start*/
::v-deep .com-basic-sub-btn {
  margin-left: 5px;
}
::v-deep .com-basic-sub-input {
  min-width: 13em;
  width: 100%;
  max-width: 28em;
  background-color: #f7f7f7;
}
/* // add/ #12441 患者経過総合ビューアの実績抗凝固剤が表示されなくなる tianqidong end*/
</style>
