/** * 治療条件ーIP速度 */

<template>
  <!-- mod 9664補液及び透析液仕様修正します yangqingzhe start -->
  <!-- <v-ons-row> -->
    <v-ons-row :class="getIsUseFlagIpFlowRate ? 'cell-disabled' : ''">
  <!-- mod 9664補液及び透析液仕様修正します yangqingzhe end -->
    <v-ons-col class="action-condition-column">IP速度</v-ons-col>
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
      /> -->
      <!-- mod 8204 周安寧 start -->
      <!-- mod FNSI-5989 劉全航 start -->
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
        :disabled="isAntiCoagulantDisabled || !isIpUse || getIsUseFlagIpFlowRate"
        class="action-condition-input ntss-custom-input-cond"
        style="width: 60px"
        @change="changeButton()"
      /> -->
      <!-- mod #10359 編集権限の動作不正 dengshen start -->
      <!-- <custom-input-number -->
      <!--   :value="displayInputValue" -->
      <!--   :digits="2" -->
      <!--   :decimal-digits="1" -->
      <!--   :min-value="0.0" -->
      <!--   :max-value="10.0" -->
      <!--   :disabled="isAntiCoagulantDisabled || !isIpUse || getIsUseFlagIpFlowRate" -->
      <!--   class="action-condition-input ntss-custom-input-cond" -->
      <!--   style="width: 60px" -->
      <!--   @change="changeButton()" -->
      <!--   @wheel="changeButton()" -->
      <!-- /> -->
      <!-- #10196 数値IFのスタイル全不正 linjunfeng start -->
      <!-- <custom-input-number
        :value="displayInputValue"
        :digits="2"
        :decimal-digits="1"
        :min-value="0.0"
        :max-value="10.0"
        :disabled="isAntiCoagulantDisabled || !isIpUse || getIsUseFlagIpFlowRate || !getItemAuthorized('Indication', 'default_authority')"
        class="action-condition-input ntss-custom-input-cond"
        style="width: 60px"
        @change="changeButton()"
        @wheel="changeButton()"
      /> -->
      <custom-input-number-pro
        :initVal="displayInputValue.initValue"
        :value="displayInputValue.editValue"
        :step="0.1"
        :min="0"
        :max="10"
        :emptyVal="null"
        :disabled="isAntiCoagulantDisabled || !isIpUse || getIsUseFlagIpFlowRate || !getItemAuthorized('Indication', 'default_authority')"
        class="action-condition-input ntss-custom-input-cond"
        style="width: 60px"
        @handlerInput="(val) =>{ displayInputValue.editValue = val }"
      />
      <!-- #10196 数値IFのスタイル全不正 linjunfeng end -->
      <!-- mod #10359 編集権限の動作不正 dengshen end -->
      <!-- mod #5589 2023/04/11 数値IFのスタイル全不正 張博 end -->
      <!-- mod FNSI-5989 劉全航 end -->
      <!-- mod 8204 周安寧 end -->
      <!-- mod redmine 4595 数値入力IFのスタイル不正 宋qy end -->
      <!-- mod FNSI-薬剤指示画面等の画面崩れの修正 楊 end -->
      <label>mL/h</label>
      <!-- <button
        :disabled="isCalcBtnDisabled || getIsUseFlagIPConflg"
        class="action-condition-calculate-button button btn3-normal"
        @click="calculateAmount(),changeButton()"
      >計算 -->
      <!-- mod #10359 編集権限の動作不正 dengshen start -->
      <!-- <button -->
      <!--   :disabled="isCalcBtnDisabled || getIsUseFlagIpFlowRate" -->
      <!--   class="action-condition-calculate-button button btn3-normal" -->
      <!--   @click="calculateAmount(),changeButton()" -->
      <!-- >計算 -->
      <button
        :disabled="isCalcBtnDisabled || getIsUseFlagIpFlowRate || !getItemAuthorized('Indication', 'default_authority')"
        class="action-condition-calculate-button button btn3-normal"
        @click="calculateAmount(),changeButton()"
      >計算
      <!-- mod #10359 編集権限の動作不正 dengshen end -->
      </button>
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
import {
  simpleAccDivision
} from "@/functions/common/NumberFunctions.js";
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages.js";
import {messageFormat} from "@/functions/common/MessageFormat";

export default {
  mixins: [IndTreatCondBase],

  computed: {
    ...mapGetters("pat-viewer-treat-cond", {
      isAntiCoagulantDisabled: "getAntiCoagulantDisabled",
      isIpUse: "isIpUse",
      antiCoagulantQuantity: "getAntiCoagulantQuantity",
      antiCoagulantFlowRate: "getAntiCoagulantFlowRate",
      //add FNSI-指示値・装置設定・装置プログラムの相関チェック 安寧 start
      antiCoagulantFlowRateDisable: "getAntiCoagulantFlowRateDisable",
      //add FNSI-指示値・装置設定・装置プログラムの相関チェック 安寧 end
      // add 8204 周安寧 start
      getIsUseFlagIpFlowRate: "getIsUseFlagIpFlowRate"
      // add 8204 周安寧 end
    }),

    isCalcBtnDisabled() {
      return (
        this.isAntiCoagulantDisabled ||
        !this.isIpUse ||
        (this.antiCoagulantFlowRate == null || Number(this.antiCoagulantFlowRate) === 0) ||
        !(this.antiCoagulantQuantity.before && this.antiCoagulantQuantity.after)
        //add FNSI-指示値・装置設定・装置プログラムの相関チェック 安寧 start
        ||this.antiCoagulantFlowRateDisable
        //add FNSI-指示値・装置設定・装置プログラムの相関チェック 安寧 end
      );
    }
  },

  mounted() {
    this.treatItemCd = "32";
    this.unit = "mL/h";
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
    calculateAmount() {
      // mod 11790 抗凝固剤持続総量の計算をするとマイナスになる事がある zkm start
      // this.displayInputValue.editValue = simpleAccDivision(
      //   this.antiCoagulantFlowRate
      //   , simpleAccDivision(this.antiCoagulantQuantity.before, this.antiCoagulantQuantity.after)
      // )
      // if(isNaN(this.displayInputValue.editValue)){
      //   this.displayInputValue.editValue = null;
      // }else{
      //   try {
      //     this.displayInputValue.editValue = Number(
      //       this.displayInputValue.editValue
      //     ).toFixed(1)
      //   } catch (e) {
      //     this.displayInputValue.editValue = null;
      //   }
      // }
      const maxAmount = Number.parseFloat("10.0").toFixed(1);
      const calculateRes = simpleAccDivision(
        this.antiCoagulantFlowRate
        , simpleAccDivision(this.antiCoagulantQuantity.before, this.antiCoagulantQuantity.after)
      )
      if(isNaN(calculateRes)){
        this.displayInputValue.editValue = null;
      } else if (calculateRes > maxAmount) {
        this.$ons.notification.alert({
          title: DIALOG_MESSAGES[10400016].title,
          message: messageFormat(DIALOG_MESSAGES[10400016].message),
        });
        this.displayInputValue.editValue = maxAmount;
      } else{
        try {
          this.displayInputValue.editValue = Number(calculateRes).toFixed(1)
        } catch (e) {
          this.displayInputValue.editValue = null;
        }
      }
      // mod 11790 抗凝固剤持続総量の計算をするとマイナスになる事がある zkm end
    }
  }
};
</script>
<style scoped>
/* add 9664補液及び透析液仕様修正します yangqingzhe start */
.cell-disabled {
  background-color: var(--pat-viewer-ind-cond-info-disabled);
}
 /* add 9664補液及び透析液仕様修正します yangqingzhe end */
.action-condition-calculate-button {
  margin: 0px 0px 0px 5px;
  padding: 0 0.3em 0 0.3em;
}
ons-row {
  border: 1px solid var(--ntss-border-color);
  padding: 10px;
}

/* add FNSI-薬剤指示画面等の画面崩れの修正 楊 start */
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
/* add FNSI-薬剤指示画面等の画面崩れの修正 楊 end */
</style>
