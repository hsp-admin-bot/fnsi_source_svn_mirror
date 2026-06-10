/** * 治療条件ーIP電源自動切り時間 */

<template>
  <!-- mod 9664補液及び透析液仕様修正します yangqingzhe start -->
  <!-- <v-ons-row> -->
    <v-ons-row :class="getIsUseFlagIpAutoOffTiming ? 'cell-disabled' : ''">
  <!-- mod 9664補液及び透析液仕様修正します yangqingzhe end -->
    <v-ons-col class="action-condition-column">IP電源自動切り時間</v-ons-col>
    <v-ons-col class="action-condition-data-column">
      <label>治療終了</label>
      <!-- mod FNSI-薬剤指示画面等の画面崩れの修正 楊 start -->
      <!--<custom-input-number
        :value="displayInputValue"
        :digits="3"
        :min-value="0.0"
        :max-value="120"
        :disabled="isAntiCoagulantDisabled || !isIpUse || !isIpAutoOff"
        class="action-condition-input"
        style="width: 40px"
      /> -->
      <!-- mod 8204 周安寧 start -->
      <!-- <custom-input-number
        :value="displayInputValue"
        :digits="3"
        :min-value="0.0"
        :max-value="120"
        :disabled="isAntiCoagulantDisabled || !isIpUse || !isIpAutoOff"
        class="action-condition-input ntss-custom-input-cond"
        style="width: 40px"
        @change="changeButton()"
      /> -->
      <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240108 linjunfeng start -->
      <!-- <custom-input-number
        :value="displayInputValue"
        :digits="3"
        :min-value="0.0"
        :max-value="120"
        :disabled="isAntiCoagulantDisabled || !isIpUse || !isIpAutoOff || getIsUseFlagIpAutoOffTiming"
        class="action-condition-input ntss-custom-input-cond"
        style="width: 50px"
        @change="changeButton()"
      /> -->
      <!-- mod #10359 編集権限の動作不正 dengshen start -->
      <!-- <custom-input-number -->
      <!--   :value="displayInputValue" -->
      <!--   :digits="3" -->
      <!--   :min-value="0.0" -->
      <!--   :max-value="120" -->
      <!--   :disabled="isAntiCoagulantDisabled || !isIpUse || !isIpAutoOff || getIsUseFlagIpAutoOffTiming" -->
      <!--   class="action-condition-input ntss-custom-input-cond" -->
      <!--   style="width: 50px" -->
      <!-- /> -->
      <!-- #10196 数値IFのスタイル全不正 linjunfeng start -->
      <!-- <custom-input-number
        :value="displayInputValue"
        :digits="3"
        :min-value="0.0"
        :max-value="120"
        :disabled="isAntiCoagulantDisabled ||
         !isIpUse ||
         !isIpAutoOff ||
         getIsUseFlagIpAutoOffTiming ||
         !getItemAuthorized('Indication', 'default_authority')"
        class="action-condition-input ntss-custom-input-cond"
        style="width: 50px"
      /> -->
      <custom-input-number-pro
        :initVal="displayInputValue.initValue"
        :value="displayInputValue.editValue"
        :step="1"
        :min="0"
        :max="120"
        :emptyVal="null"
        :disabled="isAntiCoagulantDisabled ||
         !isIpUse ||
         !isIpAutoOff ||
         getIsUseFlagIpAutoOffTiming ||
         !getItemAuthorized('Indication', 'default_authority')"
        class="action-condition-input ntss-custom-input-cond"
        style="width: 50px"
        @handlerInput="(val) =>{ displayInputValue.editValue = val }"
      />
      <!-- #10196 数値IFのスタイル全不正 linjunfeng end -->
      <!-- mod #10359 編集権限の動作不正 dengshen end -->
      <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240108 linjunfeng end -->
      <!-- mod 8204 周安寧 end -->
      <!-- mod FNSI-薬剤指示画面等の画面崩れの修正 楊 end -->
      <span>分前</span>
    </v-ons-col>
  </v-ons-row>
</template>

<script>
// add #10359 編集権限の動作不正 dengshen start
import { getAuthorized } from "@/functions/common/CommonFunctions.js";
// add #10359 編集権限の動作不正 dengshen end
import { mapGetters, mapMutations } from "vuex";
import IndTreatCondBase from "@/components/indication/IndTreatCondBase";
import {EventBus} from "@/eventBus";
export default {
  mixins: [IndTreatCondBase],

  computed: {
    ...mapGetters("pat-viewer-treat-cond", {
      isAntiCoagulantDisabled: "getAntiCoagulantDisabled",
      isIpUse: "isIpUse",
      isIpAutoOff: "isIpAutoOff",
      // add 8204 周安寧 start
      getIsUseFlagIpAutoOffTiming: "getIsUseFlagIpAutoOffTiming"
      // add 8204 周安寧 end
    })
  },

  watch: {
    inputValue: {
      handler(data) {
        this.setIpAutoOffTiming(data);
      },
      deep: true
    }
  },

  mounted() {
    this.treatItemCd = "36";
    this.unit = "分";
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
    ...mapMutations("pat-viewer-treat-cond", ["setIpAutoOffTiming"])
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
