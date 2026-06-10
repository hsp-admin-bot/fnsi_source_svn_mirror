/** * 治療条件ーIPワンショット量 */

<template>
  <!-- mod 9664補液及び透析液仕様修正します yangqingzhe start -->
  <!-- <v-ons-row> -->
    <v-ons-row :class="getIsUseFlagIpOneshotAmount ? 'cell-disabled' : ''">
  <!-- mod 9664補液及び透析液仕様修正します yangqingzhe end -->
    <v-ons-col class="action-condition-column">IPワンショット量</v-ons-col>
    <v-ons-col class="action-condition-data-column">
      <!-- mod FNSI-薬剤指示画面等の画面崩れの修正 楊 start -->
      <!-- <custom-input-number
        :value="displayInputValue"
        :digits="3"
        :decimal-digits="1"
        :min-value="0.0"
        :max-value="20.0"
        :disabled="isAntiCoagulantDisabled || !isIpUse"
        class="action-condition-input"
        style="width: 50px"
      /> -->
      <!-- add redmine 4595 数値入力IFのスタイル不正 宋qy start -->
      <!-- <custom-input-number
        :value="displayInputValue"
        :digits="3"
        :decimal-digits="1"
        :min-value="0.0"
        :max-value="20.0"
        :disabled="isAntiCoagulantDisabled || !isIpUse"
        class="action-condition-input ntss-custom-input-cond"
        style="width: 60px"
      /> -->
      <!-- mod 8204 周安寧 start -->
      <!-- mod FNSI-5989 劉全航 start -->
      <!-- <custom-input-number
        :value="displayInputValue"
        :digits="3"
        :decimal-digits="1"
        :min-value="0.0"
        :max-value="20.0"
        :disabled="isAntiCoagulantDisabled || !isIpUse"
        class="action-condition-input ntss-custom-input-cond"
        style="width: 60px"
        @change="changeButton()"
      /> -->
      <!-- mod #5589 2023/04/11 数値IFのスタイル全不正 張博 start -->
      <!-- <custom-input-number
        :value="displayInputValue"
        :digits="3"
        :decimal-digits="1"
        :min-value="0.0"
        :max-value="20.0"
        :disabled="isAntiCoagulantDisabled || !isIpUse || getIsUseFlagIpOneshotAmount"
        class="action-condition-input ntss-custom-input-cond"
        style="width: 60px"
        @change="changeButton()"
      /> -->
      <!-- mod #10359 編集権限の動作不正 dengshen start -->
      <!-- <custom-input-number -->
      <!--   :value="displayInputValue" -->
      <!--   :digits="3" -->
      <!--   :decimal-digits="1" -->
      <!--   :min-value="0.0" -->
      <!--   :max-value="20.0" -->
      <!--   :disabled="isAntiCoagulantDisabled || !isIpUse || getIsUseFlagIpOneshotAmount" -->
      <!--   class="action-condition-input ntss-custom-input-cond" -->
      <!--   style="width: 60px" -->
      <!--   @change="changeButton()" -->
      <!--   @wheel="changeButton()" -->
      <!-- /> -->
      <!-- #10196 数値IFのスタイル全不正 linjunfeng start -->
      <!-- <custom-input-number
        :value="displayInputValue"
        :digits="3"
        :decimal-digits="1"
        :min-value="0.0"
        :max-value="20.0"
        :disabled="isAntiCoagulantDisabled || !isIpUse || getIsUseFlagIpOneshotAmount || !getItemAuthorized('Indication', 'default_authority')"
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
        :max="20"
        :emptyVal="null"
        :disabled="isAntiCoagulantDisabled || !isIpUse || getIsUseFlagIpOneshotAmount || !getItemAuthorized('Indication', 'default_authority')"
        class="action-condition-input ntss-custom-input-cond"
        style="width: 60px"
        @handlerInput="(val) =>{ displayInputValue.editValue = val }"
      />
      <!-- #10196 数値IFのスタイル全不正 linjunfeng end -->
      <!-- mod #10359 編集権限の動作不正 dengshen end -->
      <!-- mod #5589 2023/04/11 数値IFのスタイル全不正 張博 end -->
      <!-- mod FNSI-5989 劉全航 end -->
      <!-- mod 8204 周安寧 end -->
      <!-- add redmine 4595 数値入力IFのスタイル不正 宋qy end -->
      <!-- mod FNSI-薬剤指示画面等の画面崩れの修正 楊 end -->
      <label>mL</label>
      <!-- mod #10359 編集権限の動作不正 dengshen start -->
      <!-- <button -->
      <!--   :disabled="isCalcBtnDisabled" -->
      <!--   class="action-condition-calculate-button button btn3-normal" -->
      <!--   @click="calculateAmount(),changeButton()" -->
      <!-- >計算 -->
      <button
        :disabled="isCalcBtnDisabled || !getItemAuthorized('Indication', 'default_authority')"
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
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
import {messageFormat} from "@/functions/common/MessageFormat";
export default {
  mixins: [IndTreatCondBase],

  computed: {
    ...mapGetters("pat-viewer-treat-cond", {
      isAntiCoagulantDisabled: "getAntiCoagulantDisabled",
      isIpUse: "isIpUse",
      antiCoagulantQuantity: "getAntiCoagulantQuantity",
      antiCoagulantOneshotAmount: "getAntiCoagulantOneshotAmount",
      //add FNSI-指示値・装置設定・装置プログラムの相関チェック 安寧 start
      antiCoagulantAmountDisable: "getAntiCoagulantAmountDisable",
      //add FNSI-指示値・装置設定・装置プログラムの相関チェック 安寧 end
      // add 8204 周安寧 start
      getIsUseFlagIpOneshotAmount: "getIsUseFlagIpOneshotAmount"
      // add 8204 周安寧 end
    }),

    isCalcBtnDisabled() {
      return (
        this.isAntiCoagulantDisabled ||
        !this.isIpUse ||
        (this.antiCoagulantOneshotAmount == null || Number(this.antiCoagulantOneshotAmount) === 0) ||
        !(this.antiCoagulantQuantity.before && this.antiCoagulantQuantity.after)
        //add FNSI-指示値・装置設定・装置プログラムの相関チェック 安寧 start
        ||this.antiCoagulantAmountDisable
        //add FNSI-指示値・装置設定・装置プログラムの相関チェック 安寧 end
        // add 8204 周安寧 start
        ||this.getIsUseFlagIpOneshotAmount
        // add 8204 周安寧 end
      );
    }
  },

  mounted() {
    this.treatItemCd = "31";
    this.unit = "mL";
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
      // this.displayInputValue.editValue =
      //   this.antiCoagulantOneshotAmount /
      //   (this.antiCoagulantQuantity.before / this.antiCoagulantQuantity.after);
      // if(isNaN(this.displayInputValue.editValue)){
      //   this.displayInputValue.editValue = null;
      // }else{
      //   let numString = this.displayInputValue.editValue.toString();
      //   let index = numString.indexOf(".");
      //   if(index !== -1){
      //     this.displayInputValue.editValue = Number.parseFloat(numString.substring(0, index+2)) ;
      //   }else{
      //     this.displayInputValue.editValue =Number.parseFloat(numString.substring(0)) ;
      //   }
      // }
      const maxAmount = Number.parseFloat("20.0").toFixed(1);
      const calculateRes =
        this.antiCoagulantOneshotAmount /
        (this.antiCoagulantQuantity.before / this.antiCoagulantQuantity.after);
      if(isNaN(calculateRes)){
        this.displayInputValue.editValue = null;
      } else if (calculateRes > maxAmount) {
        this.$ons.notification.alert({
          title: DIALOG_MESSAGES[10400016].title,
          message: messageFormat(DIALOG_MESSAGES[10400016].message),
        });
        this.displayInputValue.editValue = maxAmount;
      } else {
        let numString = calculateRes.toString();
        let index = numString.indexOf(".");
        if(index !== -1){
          this.displayInputValue.editValue = Number.parseFloat(numString.substring(0, index+2)) ;
        }else{
          this.displayInputValue.editValue =Number.parseFloat(numString.substring(0)) ;
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
