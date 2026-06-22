/** * 治療条件ー補液使用数 */

<template>
  <!-- mod 9664補液及び透析液仕様修正します yangqingzhe start -->
  <!-- <v-ons-row> -->
    <v-ons-row :class="getIsUseFlagIvCount ? 'cell-disabled' : ''">
  <!-- mod 9664補液及び透析液仕様修正します yangqingzhe end -->
    <v-ons-col class="action-condition-column">補液使用数</v-ons-col>
    <v-ons-col class="action-condition-data-column">
      <!-- mod FNSI-薬剤指示画面等の画面崩れの修正 楊 start -->
      <!--<custom-input-number
        :value="displayInputValue"
        :digits="5"
        :decimal-digits="decPoint"
        :min-value="0"
        :max-value="99999.999999999"
        :disabled="isDisabled"
        :loop-flg="false"
        :initial-value-lock="true"
        class="action-condition-input"
        style="width: 90px"
      /> -->
      <!-- mod #5589 2023/04/04 数値IFのスタイル全不正 張博 start -->
      <!-- <custom-input-number
        :value="displayInputValue"
        :digits="5"
        :decimal-digits="decPoint"
        :min-value="0"
        :max-value="99999.999999999"
        :disabled="isDisabled"
        :loop-flg="false"
        :initial-value-lock="true"
        class="action-condition-input ntss-custom-input-cond"
        style="width: 90px"
        @change="changeButton()"
      /> -->
      <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240108 linjunfeng start -->
      <!-- <custom-input-number
        :value="displayInputValue"
        :digits="5"
        :decimal-digits="decPoint"
        :min-value="0"
        :max-value="99999"
        :disabled="isDisabled"
        :loop-flg="true"
        :initial-value-lock="true"
        class="action-condition-input ntss-custom-input-cond"
        style="width: 90px"
        @change="changeButton()"
      /> -->
      <!-- mod #10359 編集権限の動作不正 dengshen start -->
      <!-- <custom-input-number -->
      <!--   :value="displayInputValue" -->
      <!--   :digits="5" -->
      <!--   :decimal-digits="decPoint" -->
      <!--   :min-value="0" -->
      <!--   :max-value="99999" -->
      <!--   :disabled="isDisabled" -->
      <!--   :loop-flg="true" -->
      <!--   :initial-value-lock="true" -->
      <!--   class="action-condition-input ntss-custom-input-cond" -->
      <!--   style="width: 90px" -->
      <!-- /> -->
      <!-- #10196 数値IFのスタイル全不正 linjunfeng start -->
      <!-- <custom-input-number
        :value="displayInputValue"
        :digits="5"
        :decimal-digits="decPoint"
        :min-value="0"
        :max-value="99999"
        :disabled="isDisabled || !getItemAuthorized('Indication', 'default_authority')"
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
        :max="maxPrecision(99999)"
        :emptyVal="null"
        :disabled="isDisabled || !getItemAuthorized('Indication', 'default_authority')"
        class="action-condition-input ntss-custom-input-cond"
        style="width: 90px"
        @handlerInput="(val) =>{ displayInputValue.editValue = val }"
      />
      <!-- #10196 数値IFのスタイル全不正 linjunfeng end -->
      <!-- mod #10359 編集権限の動作不正 dengshen end -->
      <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240108 linjunfeng end -->
      <!-- mod #5589 2023/04/04 数値IFのスタイル全不正 張博 end -->
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
  },
  computed: {
    ...mapGetters("pat-viewer-treat-cond", {
      //mod FNSI-6955 劉全航 start
      // isDisabled: "getIvDisabled",
      getIvDisabled: "getIvDisabled",
      //mod FNSI-6955 劉全航 end
      unitLabel: "getIvUnit",
      // add FNSI-【8630】単位が表示されない対応 曲 start
      ivUnitChangeFlag: "getIvUnitChangeFlag",
      // add FNSI-【8630】単位が表示されない対応 曲 end
      ivData: "getIvCd",
      decPoint: "getIvDecPoint",
      // add FNSI-【1006】最新の改修対象一覧の483対応 韓 start
      isCommentShow: "getOhdfCommentIsShow",
      displayString: "getOhdfDisplayString",
      // add FNSI-【1006】最新の改修対象一覧の483対応 韓 end
      //mod FNSI-6955 劉全航 start
      deviceMode: "getDeviceMode",
      //mod FNSI-6955 劉全航 end
      //add 8204 周安寧 start
      getIsUseFlagIvCount:"getIsUseFlagIvCount"
      //add 8204 周安寧 end
    }),
    //mod FNSI-6955 劉全航 start
    isDisabled(){
      //mod 8204 周安寧 start
      //return this.getIvDisabled || this.deviceMode === 10;
      // mod 9664補液及び透析液仕様修正します yangqingzhe start
      // return this.getIvDisabled || this.deviceMode === 10 || this.getIsUseFlagIvCount;
      return (this.deviceMode === 0 || //HD
        this.deviceMode === 1 ||//ECUM
        this.getIvDisabled || this.getIsUseFlagIvCount
      );
      // mod 9664補液及び透析液仕様修正します yangqingzhe end
      //mod 8204 周安寧 end
    }
    //mod FNSI-6955 劉全航 end
  },
  watch: {
    unitLabel() {
      this.unit = this.unitLabel;
    },
    // add FNSI-【8630】単位が表示されない対応 曲 start
    ivUnitChangeFlag() {
      if (this.ivUnitChangeFlag) {
        this.unitChangeFlag = true;
      }
    }
    // add FNSI-【8630】単位が表示されない対応 曲 end
  },
  async mounted() {
    this.treatItemCd = "22";
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
