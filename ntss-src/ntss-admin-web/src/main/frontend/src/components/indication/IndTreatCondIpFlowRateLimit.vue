/** * 治療条件ーIP速度最大値 */

<template>
  <!-- mod 9664補液及び透析液仕様修正します yangqingzhe start -->
  <!-- <v-ons-row> -->
    <v-ons-row :class="getIsUseFlagIpFlowRateLimit ? 'cell-disabled' : ''">
  <!-- mod 9664補液及び透析液仕様修正します yangqingzhe end -->
    <v-ons-col class="action-condition-column">IP速度最大値</v-ons-col>
    <v-ons-col class="action-condition-data-column">
      <!-- mod FNSI-薬剤指示画面等の画面崩れの修正 楊 start -->
      <!--<custom-input-number
        :value="displayInputValue"
        :digits="2"
        :decimal-digits="1"
        :min-value="0.0"
        :max-value="10.0"
        :disabled="isAntiCoagulantDisabled || !isIpUse"
        class="action-condition-input"
        style="width: 50px"
      /> -->
      <!-- mod 8204 周安寧 start -->
      <!-- mod redmine 4595 数値入力IFのスタイル不正 宋qy start -->
      <!-- <custom-input-number
        :value="displayInputValue"
        :digits="2"
        :decimal-digits="1"
        :min-value="0.0"
        :max-value="10.0"
        :disabled="isAntiCoagulantDisabled || !isIpUse"
        class="action-condition-input ntss-custom-input-cond"
        style="width: 60px"
        @change="changeButton()"
      /> -->
      <!-- mod #5589 2023/04/11 数値IFのスタイル全不正 張博 start -->
      <!-- <custom-input-number
        :value="displayInputValue"
        :digits="2"
        :decimal-digits="1"
        :min-value="0.0"
        :max-value="10.0"
        :disabled="isAntiCoagulantDisabled || !isIpUse || getIsUseFlagIpFlowRateLimit"
        class="action-condition-input ntss-custom-input-cond"
        style="width: 60px"
        @change="changeButton()"
      /> -->
      <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240108 linjunfeng start -->
      <!-- <custom-input-number
        :value="displayInputValue"
        :digits="2"
        :decimal-digits="1"
        :min-value="0.0"
        :max-value="10.0"
        :disabled="isAntiCoagulantDisabled || !isIpUse || getIsUseFlagIpFlowRateLimit"
        class="action-condition-input ntss-custom-input-cond"
        style="width: 60px"
        @change="changeButton()"
        @wheel="changeButton()"
      /> -->
      <!-- mod #10359 編集権限の動作不正 dengshen start -->
      <!-- <custom-input-number -->
      <!--   :value="displayInputValue" -->
      <!--   :digits="2" -->
      <!--   :decimal-digits="1" -->
      <!--   :min-value="0.0" -->
      <!--   :max-value="10.0" -->
      <!--   :disabled="isAntiCoagulantDisabled || !isIpUse || getIsUseFlagIpFlowRateLimit" -->
      <!--   class="action-condition-input ntss-custom-input-cond" -->
      <!--   style="width: 60px" -->
      <!-- /> -->
      <!-- #10196 数値IFのスタイル全不正 linjunfeng start -->
      <!-- <custom-input-number
        :value="displayInputValue"
        :digits="2"
        :decimal-digits="1"
        :min-value="0.0"
        :max-value="10.0"
        :disabled="isAntiCoagulantDisabled || !isIpUse || getIsUseFlagIpFlowRateLimit || !getItemAuthorized('Indication', 'default_authority')"
        class="action-condition-input ntss-custom-input-cond"
        style="width: 60px"
      /> -->
      <custom-input-number-pro
        :initVal="displayInputValue.initValue"
        :value="displayInputValue.editValue"
        :step="0.1"
        :min="0"
        :max="10"
        :emptyVal="null"
        :disabled="isAntiCoagulantDisabled || !isIpUse || getIsUseFlagIpFlowRateLimit || !getItemAuthorized('Indication', 'default_authority')"
        class="action-condition-input ntss-custom-input-cond"
        style="width: 60px"
        @handlerInput="(val) =>{ displayInputValue.editValue = val }"
      />
      <!-- #10196 数値IFのスタイル全不正 linjunfeng end -->
      <!-- mod #10359 編集権限の動作不正 dengshen end -->
      <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240108 linjunfeng end -->
      <!-- mod #5589 2023/04/11 数値IFのスタイル全不正 張博 end -->
      <!-- mod redmine 4595 数値入力IFのスタイル不正 宋qy end -->
      <!-- mod 8204 周安寧 end -->
      <!-- mod FNSI-薬剤指示画面等の画面崩れの修正 楊 end -->
      <label>mL/h</label>
    </v-ons-col>
  </v-ons-row>
</template>

<script>
// add #10359 編集権限の動作不正 dengshen start
import { getAuthorized } from "@/functions/common/CommonFunctions.js";
// add #10359 編集権限の動作不正 dengshen end
import { mapGetters } from "vuex";
import IndTreatCondBase from "@/components/indication/IndTreatCondBase";
import {EventBus} from "@/eventBus";
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
    }
  },
  computed: {
    ...mapGetters("pat-viewer-treat-cond", {
      isAntiCoagulantDisabled: "getAntiCoagulantDisabled",
      isIpUse: "isIpUse",
      // add 8204 周安寧 start
      getIsUseFlagIpFlowRateLimit: "getIsUseFlagIpFlowRateLimit" 
      // add 8204 周安寧 end
    })
  },

  mounted() {
    this.treatItemCd = "33";
    this.unit = "mL/h";
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
