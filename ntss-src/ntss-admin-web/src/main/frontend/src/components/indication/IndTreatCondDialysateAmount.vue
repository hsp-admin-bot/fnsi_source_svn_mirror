/** * 治療条件ー透析液使用数 */

<template>
  <!-- mod 9664補液及び透析液仕様修正します yangqingzhe start -->
  <!-- <v-ons-row> -->
    <v-ons-row :class="getIsUseFlagDialysateAmount ? 'cell-disabled' : ''">
  <!-- mod 9664補液及び透析液仕様修正します yangqingzhe end -->
    <v-ons-col class="action-condition-column">透析液使用数</v-ons-col>
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
        @change="changeButton()"
        :initial-value-lock="true"
        class="action-condition-input  ntss-custom-input-cond"
        style="width: 90px"
      /> -->
      <!-- mod #5589 2023/04/04 数値IFのスタイル全不正 張博 start -->
      <!-- <custom-input-number
        :value="displayInputValue"
        :digits="7"
        :decimal-digits="decPoint"
        :min-value="0"
        :max-value="9999999.999999999"
        :disabled="isDisabled || getIsUseFlagDialysateAmount"
        :loop-flg="false"
        @change="changeButton()"
        :initial-value-lock="true"
        class="action-condition-input  ntss-custom-input-cond"
        style="width: 90px"
      /> -->
      <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240108 linjunfeng start -->
      <!-- <custom-input-number
        :value="displayInputValue"
        :digits="7"
        :decimal-digits="decPoint"
        :min-value="0"
        :max-value="9999999"
        :disabled="isDisabled || getIsUseFlagDialysateAmount"
        :loop-flg="true"
        @change="changeButton()"
        @wheel="changeButton()"
        :initial-value-lock="true"
        class="action-condition-input  ntss-custom-input-cond"
        style="width: 90px"
      /> -->
      <!-- mod #10359 編集権限の動作不正 dengshen start -->
      <!-- <custom-input-number -->
      <!--   :value="displayInputValue" -->
      <!--   :digits="7" -->
      <!--   :decimal-digits="decPoint" -->
      <!--   :min-value="0" -->
      <!--   :max-value="9999999" -->
      <!--   :disabled="isDisabled || getIsUseFlagDialysateAmount" -->
      <!--   :loop-flg="true" -->
      <!--   :initial-value-lock="true" -->
      <!--   class="action-condition-input  ntss-custom-input-cond" -->
      <!--   style="width: 90px" -->
      <!-- /> -->
      <!-- #10196 数値IFのスタイル全不正 linjunfeng start -->
      <!-- <custom-input-number
        :value="displayInputValue"
        :digits="7"
        :decimal-digits="decPoint"
        :min-value="0"
        :max-value="9999999"
        :disabled="isDisabled || getIsUseFlagDialysateAmount || !getItemAuthorized('Indication', 'default_authority')"
        :loop-flg="true"
        :initial-value-lock="true"
        class="action-condition-input  ntss-custom-input-cond"
        style="width: 90px"
      /> -->
      <custom-input-number-pro
        :initVal="displayInputValue.initValue"
        :value="displayInputValue.editValue"
        :step="unitStep()"
        :min="0"
        :max="maxPrecision(9999999)"
        :emptyVal="null"
        :disabled="isDisabled || getIsUseFlagDialysateAmount || !getItemAuthorized('Indication', 'default_authority')"
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
      <label>{{ unitLabel }}</label>
    </v-ons-col>
    <!--mod FNSI-【1006】最新の改修対象一覧の483対応 韓 start-->
    <v-ons-col v-show="isCommentShow" style="flex-basis:60%; margin-right:5px;">
    <span>{{ displayString }}</span>
    </v-ons-col>
    <!--mod FNSI-【1006】最新の改修対象一覧の483対応 韓 end-->
  </v-ons-row>
</template>

<script>
// add #10359 編集権限の動作不正 dengshen start
import { getAuthorized } from "@/functions/common/CommonFunctions.js";
// add #10359 編集権限の動作不正 dengshen end
import { mapGetters } from "@/compat/vue/vuex";
import IndTreatCondBase from "@/components/indication/IndTreatCondBase";
import {EventBus} from "@/compat/vue/event-bus.js";
// add #10196 数値IFのスタイル全不正 linjunfeng start
import BigNumber from "@/compat/number/bignumber";
// add #10196 数値IFのスタイル全不正 linjunfeng end
export default {
  mixins: [IndTreatCondBase],

  computed: {
    ...mapGetters("pat-viewer-treat-cond", {
      isDisabled: "getDialysateDisabled",
      unitLabel: "getDialysateUnit",
      dialysateUnitChangeFlag: "getDialysateUnitChangeFlag",
      dialysateData: "getDialysateCd",
      decPoint: "getDialysateDecPoint",
      // add FNSI-【1006】最新の改修対象一覧の483対応 韓 start
      isCommentShow: "getOhdfCommentIsShow",
      displayString: "getOhdfDisplayString",
      // add FNSI-【1006】最新の改修対象一覧の483対応 韓 end
      // add 8204 周安寧 start
      getIsUseFlagDialysateAmount: "getIsUseFlagDialysateAmount"
      // add 8204 周安寧 end
    })
  },
  watch: {
    unitLabel() {
      this.unit = this.unitLabel;
    },
    // add FNSI-【8630】単位が表示されない対応 曲 start
    dialysateUnitChangeFlag() {
      if (this.dialysateUnitChangeFlag) {
        this.unitChangeFlag = true;
      }
    }
    // add FNSI-【8630】単位が表示されない対応 曲 end
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
    maxPrecision(value) {
      let num = parseInt(this.decPoint);
      if(isNaN(num)){
        return value;
      }
      const decimalNumber = parseFloat(`${value}.${'9'.repeat(num)}`);
      return Number(decimalNumber.toFixed(num));
    },
    unitStep() {
      var num = parseInt(this.decPoint);
      if(isNaN(num)){
        return 1;
      }
      var data = Number(BigNumber(10).exponentiatedBy(BigNumber(num).negated()).valueOf());
      return data;
    },
    // add #10196 数値IFのスタイル全不正 linjunfeng end
  },
  async mounted() {
    this.treatItemCd = "17";
    this.unit = this.unitLabel;
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
  min-width: 190px;
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
