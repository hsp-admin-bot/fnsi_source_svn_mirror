/** * 治療条件ー抗凝固剤持続速度 */

<template>
  <!-- mod 9664補液及び透析液仕様修正します yangqingzhe start -->
  <!-- <v-ons-row> -->
    <v-ons-row :class="getIsUseFlagAntiCoagulantFlowRate ? 'cell-disabled' : ''">
  <!-- mod 9664補液及び透析液仕様修正します yangqingzhe end -->
    <v-ons-col class="action-condition-column">抗凝固剤持続速度</v-ons-col>
    <v-ons-col class="action-condition-data-column">
      <!-- mod FNSI-薬剤指示画面等の画面崩れの修正 楊 start -->
      <!--<custom-input-number
        :value="displayInputValue"
        :digits="7"
        :decimal-digits="decPoint"
        :min-value="0"
        :max-value="9999999.999999999"
        :disabled="isDisabled"
        :loop-flg="false"
        :initial-value-lock="true"
        class="action-condition-input"
        style="width: 90px"
      /> -->
      <!-- mod 8204 周安寧 start -->
      <!-- <custom-input-number
        :value="displayInputValue"
        :digits="7"
        :decimal-digits="decPoint"
        :min-value="0"
        :max-value="9999999.999999999"
        :disabled="isDisabled"
        :loop-flg="false"
        :initial-value-lock="true"
        class="action-condition-input ntss-custom-input-cond"
        style="width: 90px"
        @change="changeButton()"
      /> -->
      <!-- mod #5589 2023/04/04 数値IFのスタイル全不正 張博 start -->
      <!-- <custom-input-number
        :value="displayInputValue"
        :digits="7"
        :decimal-digits="decPoint"
        :min-value="0"
        :max-value="9999999.999999999"
        :disabled="isDisabled || getIsUseFlagAntiCoagulantFlowRate"
        :loop-flg="false"
        :initial-value-lock="true"
        class="action-condition-input ntss-custom-input-cond"
        style="width: 90px"
        @change="changeButton()"
      /> -->
      <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240108 linjunfeng start -->
      <!-- <custom-input-number
        :value="displayInputValue"
        :digits="7"
        :decimal-digits="decPoint"
        :min-value="0"
        :max-value="9999999"
        :disabled="isDisabled || getIsUseFlagAntiCoagulantFlowRate"
        :loop-flg="true"
        :initial-value-lock="true"
        class="action-condition-input ntss-custom-input-cond"
        style="width: 90px"
        @change="changeButton()"
        @wheel="changeButton()"
      /> -->
      <!-- mod #10359 編集権限の動作不正 dengshen start -->
      <!-- <custom-input-number -->
      <!--   :value="displayInputValue" -->
      <!--   :digits="7" -->
      <!--   :decimal-digits="decPoint" -->
      <!--   :min-value="0" -->
      <!--   :max-value="9999999" -->
      <!--   :disabled="isDisabled || getIsUseFlagAntiCoagulantFlowRate" -->
      <!--   :loop-flg="true" -->
      <!--   :initial-value-lock="true" -->
      <!--   class="action-condition-input ntss-custom-input-cond" -->
      <!--   style="width: 90px" -->
      <!-- /> -->
      <!-- #10196 数値IFのスタイル全不正 linjunfeng start -->
      <!-- <custom-input-number
        :value="displayInputValue"
        :digits="7"
        :decimal-digits="decPoint"
        :min-value="0"
        :max-value="9999999"
        :disabled="isDisabled || getIsUseFlagAntiCoagulantFlowRate || !getItemAuthorized('Indication', 'default_authority')"
        :loop-flg="true"
        :initial-value-lock="true"
        class="action-condition-input ntss-custom-input-cond"
        style="width: 90px"
      /> -->
      <custom-input-number-pro
        :initVal="displayInputValue.initValue"
        :value="displayInputValue.editValue"
        :step="unitStep()"
        :min="0"
        :max="maxPrecision(9999999)"
        :emptyVal="null"
        :disabled="isDisabled || getIsUseFlagAntiCoagulantFlowRate || !getItemAuthorized('Indication', 'default_authority')"
        class="action-condition-input ntss-custom-input-cond"
        style="width: 90px"
        @handlerInput="(val) =>{ displayInputValue.editValue = val }"
      />
      <!-- #10196 数値IFのスタイル全不正 linjunfeng end -->
      <!-- mod #10359 編集権限の動作不正 dengshen end -->
      <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240108 linjunfeng end -->
      <!-- mod #5589 2023/04/04 数値IFのスタイル全不正 張博 end -->
      <!-- mod 8204 周安寧 end -->
      <!-- mod FNSI-薬剤指示画面等の画面崩れの修正 楊 end -->
      <label v-show="unitLabel">{{ unitLabel }}</label>
    </v-ons-col>
  </v-ons-row>
</template>

<script>
// add #10359 編集権限の動作不正 dengshen start
import { getAuthorized } from "@/functions/common/CommonFunctions.js";
// add #10359 編集権限の動作不正 dengshen end
import { mapGetters, mapMutations } from "@/compat/vue/vuex";
import IndTreatCondBase from "@/components/indication/IndTreatCondBase";
import {EventBus} from "@/compat/vue/event-bus.js";
// add #10196 数値IFのスタイル全不正 linjunfeng start
import BigNumber from "@/compat/number/bignumber";
// add #10196 数値IFのスタイル全不正 linjunfeng end
export default {
  mixins: [IndTreatCondBase],

  computed: {
    ...mapGetters("pat-viewer-treat-cond", {
      isDisabled: "getAntiCoagulantDisabled",
      unitLabel: "getAntiCoagulantFlowRateUnit",
      // add FNSI-【8630】単位が表示されない対応 曲 start
      antiCoagulantFlowRateUnitChangeFlag: "getAntiCoagulantFlowRateUnitChangeFlag",
      // add FNSI-【8630】単位が表示されない対応 曲 end
      decPoint: "getAntiCoagulantDecPoint",
      // add 8204 周安寧 start
      getIsUseFlagAntiCoagulantFlowRate: "getIsUseFlagAntiCoagulantFlowRate"
      // add 8204 周安寧 end
    })
  },

  watch: {
    inputValue: {
      handler(data) {
        this.setAntiCoagulantFlowRate(data);
      },
      deep: true
    },
    unitLabel() {
      this.unit = this.unitLabel;
    },
    // add FNSI-【8630】単位が表示されない対応 曲 start
    antiCoagulantFlowRateUnitChangeFlag() {
      if (this.antiCoagulantFlowRateUnitChangeFlag) {
        this.unitChangeFlag = true;
      }
    }
    // add FNSI-【8630】単位が表示されない対応 曲 end
  },

  mounted() {
    this.treatItemCd = "27";
    this.unit = this.unitLabel;
  },

  methods: {
    // add #10359 編集権限の動作不正 dengshen start
    getItemAuthorized(pageCd, itemCd) {
      return this.isMst || (this.isMst != true && getAuthorized(pageCd, itemCd));
    },
    // add #10359 編集権限の動作不正 dengshen end
  //[確認]ボタンの状態の変更をトリガーします   
    changeButton() {
      EventBus.$emit("mstHolidayRegistered", false);
    },
    // add #10196 数値IFのスタイル全不正 linjunfeng start
    unitStep() {
      var num = parseInt(this.decPoint);
      if(isNaN(num)){
        return 1;
      }
      var data = Number(BigNumber(10).exponentiatedBy(BigNumber(num).negated()).valueOf());
      return data;
    },
    maxPrecision(value) {
      let num = parseInt(this.decPoint);
      if(isNaN(num)){
        return value;
      }
      const decimalNumber = parseFloat(`${value}.${'9'.repeat(num)}`);
      return Number(decimalNumber.toFixed(num));
    },
    // add #10196 数値IFのスタイル全不正 linjunfeng end
    ...mapMutations("pat-viewer-treat-cond", ["setAntiCoagulantFlowRate"])
  }
};
</script>
<!-- add redmine 4595 数値入力IFのスタイル不正 宋qy start -->
<style scoped>
/* add 9664補液及び透析液仕様修正します yangqingzhe start */
.cell-disabled {
  background-color: var(--pat-viewer-ind-cond-info-disabled);
}
 /* add 9664補液及び透析液仕様修正します yangqingzhe end */
ons-row {
  border: 1px solid var(--ntss-border-color);
  padding: 10px;
}
.action-condition-input {
  width: 138px;
  margin: 0px 5px 0px 0px;
}
.action-condition-column {
  flex: 0 0 9%;
  max-width: 30%;
  white-space: normal;
  margin: auto;
}
.action-condition-data-column {
  margin: auto;
  padding-left: 10px;
  margin-right: 5px;
}
.ntss-custom-input-cond {
  height: 2em;
  font-size: inherit;
  width: auto;
  -webkit-box-sizing: border-box;
  box-sizing: border-box;
  display: inline-flex;
}
</style>
<!-- add redmine 4595 数値入力IFのスタイル不正 宋qy end -->
