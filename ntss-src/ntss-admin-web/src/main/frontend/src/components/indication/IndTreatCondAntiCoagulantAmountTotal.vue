/** * 治療条件ー抗凝固剤持続総量 */

<template>
  <!-- mod 9664補液及び透析液仕様修正します yangqingzhe start -->
  <!-- <v-ons-row> -->
    <v-ons-row :class="getIsUseFlagAntiCoagulantAmountTotal ? 'cell-disabled' : ''">
  <!-- mod 9664補液及び透析液仕様修正します yangqingzhe end -->
    <v-ons-col class="action-condition-column">抗凝固剤持続総量</v-ons-col>
    <!-- del FNSI-改修内容 持抗凝固剤続総量チェックボックスを追加 穆 start -->
    <!-- <v-ons-col class="action-condition-data-column">
      <custom-input-number
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
      />
      <label>{{ unitLabel }}</label>
      <button
        :disabled="isDisabled"
        class="action-condition-calculate-button"
        @click="calculateAmount"
      >計算
      </button>
    </v-ons-col> -->
    <!-- del FNSI-改修内容 持抗凝固剤続総量チェックボックスを追加 穆 end -->
    <!-- add FNSI-改修内容 持抗凝固剤続総量チェックボックスを追加 穆 start -->
    <v-ons-col class="action-condition-data-column">
      <!-- mod FNSI-薬剤指示画面等の画面崩れの修正 楊 start -->
      <!--<custom-input-number
        :value="displayInputValue"
        :digits="7"
        :decimal-digits="decPoint"
        :min-value="0"
        :max-value="9999999.999999999"
        :disabled="newDisabled"
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
        :disabled="newDisabled"
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
        :disabled="newDisabled || getIsUseFlagAntiCoagulantAmountTotal"
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
        :disabled="newDisabled || getIsUseFlagAntiCoagulantAmountTotal"
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
      <!--   :disabled="newDisabled || getIsUseFlagAntiCoagulantAmountTotal" -->
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
        :disabled="newDisabled || getIsUseFlagAntiCoagulantAmountTotal || !getItemAuthorized('Indication', 'default_authority')"
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
        :disabled="newDisabled || getIsUseFlagAntiCoagulantAmountTotal || !getItemAuthorized('Indication', 'default_authority')"
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
      <!-- mod 8204 周安寧 start -->
      <!-- <button
        :disabled="newDisabled"
        class="action-condition-calculate-button button btn3-normal"
        @click="calculateAmount(),changeButton()"
      >計算
      </button> -->
      <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240108 linjunfeng start -->
      <!-- <button
        :disabled="newDisabled || getIsUseFlagAntiCoagulantAmountTotal"
        class="action-condition-calculate-button button btn3-normal"
        @click="calculateAmount(),changeButton()"
      >計算 -->
      <!-- mod #10359 編集権限の動作不正 dengshen start -->
      <!-- <button -->
      <!--   :disabled="newDisabled || getIsUseFlagAntiCoagulantAmountTotal" -->
      <!--   class="action-condition-calculate-button button btn3-normal" -->
      <!--   @click="calculateAmount()" -->
      <!-- >計算 -->
<!--      mod 11790 抗凝固剤持続総量の計算をするとマイナスになる事がある zkm start-->
<!--      <button-->
<!--        :disabled="newDisabled || getIsUseFlagAntiCoagulantAmountTotal || !getItemAuthorized('Indication', 'default_authority')"-->
<!--        class="action-condition-calculate-button button btn3-normal"-->
<!--        @click="calculateAmount()"-->
<!--      >計算-->
      <button
        :disabled="newDisabled || getIsUseFlagAntiCoagulantAmountTotal || !getItemAuthorized('Indication', 'default_authority') || getAntiCoagulantFlowRate == null || Number(getAntiCoagulantFlowRate) === 0"
        class="action-condition-calculate-button button btn3-normal"
        @click="calculateAmount()"
      >計算
<!--      mod 11790 抗凝固剤持続総量の計算をするとマイナスになる事がある zkm end-->
      <!-- mod #10359 編集権限の動作不正 dengshen end -->
      <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240108 linjunfeng end -->
      </button>
      <!-- mod 8204 周安寧 end -->
    </v-ons-col>
    <!-- mod FNSI-薬剤指示画面等の画面崩れの修正 楊 start -->
    <!-- <v-ons-col class="action-condition-column" style="300px"> -->
    <!--mod FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxの32対応 韓 start-->
      <!--      mod 11790 抗凝固剤持続総量の計算をするとマイナスになる事がある zkm start-->
<!--    <v-ons-col style="flex-basis:55%; margin-right:5px; white-space:normal;">-->
    <v-ons-col v-if="!isMst" style="flex-basis:55%; margin-right:5px; white-space:normal;">
      <!--      mod 11790 抗凝固剤持続総量の計算をするとマイナスになる事がある zkm end-->
    <!--mod FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxの32対応 韓 end-->
      <!-- mod FNSI-薬剤指示画面等の画面崩れの修正 楊 end -->
      <!-- mod 8204 周安寧 start -->
      <!-- <v-ons-checkbox
      :disabled="isDisabled"
       @click="unitCheck($event.target),changeButton()"
       class="checkbox"></v-ons-checkbox> -->
       <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240108 linjunfeng start -->
       <!-- <v-ons-checkbox
       :disabled="isDisabled || getIsUseFlagAntiCoagulantAmountTotal"
       @click="unitCheck($event.target),changeButton()"
       class="checkbox"></v-ons-checkbox> -->
      <!-- mod #10359 編集権限の動作不正 dengshen start -->
      <!--  <v-ons-checkbox -->
      <!--  :disabled="isDisabled || getIsUseFlagAntiCoagulantAmountTotal" -->
      <!--  @change="unitCheck($event.target)" -->
      <!--  class="checkbox"></v-ons-checkbox> -->
      <v-ons-checkbox
        :disabled="isDisabled || getIsUseFlagAntiCoagulantAmountTotal || !getItemAuthorized('Indication', 'default_authority')"
        @change="unitCheck($event.target)"
        class="checkbox"></v-ons-checkbox>
      <!-- mod #10359 編集権限の動作不正 dengshen end -->
       <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240108 linjunfeng end -->
       <!-- mod 8204 周安寧 end -->
       <!-- mod FNSI-4882 劉全航 start -->
       <!-- <label>治療毎の治療時間から総量を計算した値を採用</label> -->
       <label :class="classObject">治療毎の治療時間から総量を計算した値を採用</label>
       <!-- mod FNSI-4882 劉全航 end -->
    </v-ons-col>
    <!-- add FNSI-改修内容 持抗凝固剤続総量チェックボックスを追加 穆 end -->
  </v-ons-row>
</template>

<script>
// add #10359 編集権限の動作不正 dengshen start
import { getAuthorized } from "@/functions/common/CommonFunctions.js";
// add #10359 編集権限の動作不正 dengshen end
// mod FNSI-改修内容 持抗凝固剤続総量チェックボックスを追加 穆 start
// import { mapGetters } from "vuex";
import { mapGetters, mapMutations } from "vuex";
// add FNSI-改修内容 持抗凝固剤続総量チェックボックスを追加 穆 end
import IndTreatCondBase from "@/components/indication/IndTreatCondBase";
import {EventBus} from "@/eventBus";
import {
  simpleAccDivision, accMulti, accSub
} from "@/functions/common/NumberFunctions.js";
// add #10196 数値IFのスタイル全不正 linjunfeng start
import BigNumber from "bignumber.js";
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages.js";
import {messageFormat} from "@/functions/common/MessageFormat";
// add #10196 数値IFのスタイル全不正 linjunfeng end
export default {
  mixins: [IndTreatCondBase],
  // add FNSI-改修内容 持抗凝固剤続総量チェックボックスを追加 穆 start
  data() {
    return {
      newDisabled: true
    };
  },
  // add FNSI-改修内容 持抗凝固剤続総量チェックボックスを追加 穆 end

  computed: {
    ...mapGetters("pat-viewer-treat-cond", {
      isDisabled: "getAntiCoagulantDisabled",
      unitLabel: "getAntiCoagulantAmountTotalUnit",
      // add FNSI-【8630】単位が表示されない対応 曲 start
      antiCoagulantAmountTotalUnitChangeFlag: "getAntiCoagulantAmountTotalUnitChangeFlag",
      // add FNSI-【8630】単位が表示されない対応 曲 end
      antiCoagulantFlowRate: "getAntiCoagulantFlowRate",
      treatTime: "getTreatTime",
      isIpAutoOff: "isIpAutoOff",
      ipAutoOffTiming: "getIpAutoOffTiming",
      decPoint: "getAntiCoagulantDecPoint",
      // add 11790 抗凝固剤持続総量の計算をするとマイナスになる事がある zkm start
      // add 11943 抗凝固剤治療指示のバグ修正 追加 zkm start
      isIpUse: "isIpUse",
      // add 11943 抗凝固剤治療指示のバグ修正 追加 zkm end
      getAntiCoagulantFlowRate: "getAntiCoagulantFlowRate",
      // add 11790 抗凝固剤持続総量の計算をするとマイナスになる事がある zkm end
      // add 8204 周安寧 start
      getIsUseFlagAntiCoagulantAmountTotal: "getIsUseFlagAntiCoagulantAmountTotal"
      // add 8204 周安寧 end
    })
    // mod FNSI-4882 劉全航 start
    ,classObject: function(){
        if(this.newDisabled === true){
          return "label-edited";
        }else{
          return "";
        }
    }
    // mod FNSI-4882 劉全航 end
  },
  watch: {
    unitLabel() {
      this.unit = this.unitLabel;
      // add FNSI-改修内容 持抗凝固剤続総量チェックボックスを追加 穆 start
      this.newDisabled = this.isDisabled;
      // add FNSI-改修内容 持抗凝固剤続総量チェックボックスを追加 穆 end
    },
    // add FNSI-【8630】単位が表示されない対応 曲 start
    antiCoagulantAmountTotalUnitChangeFlag() {
      if (this.antiCoagulantAmountTotalUnitChangeFlag) {
        this.unitChangeFlag = true;
      }
    }
    // add FNSI-【8630】単位が表示されない対応 曲 end
  },
  mounted() {
    this.treatItemCd = "28";
    this.unit = this.unitLabel;
    // add FNSI-改修内容 持抗凝固剤続総量チェックボックスを追加 穆 start
    this.newDisabled = this.isDisabled;
    // add FNSI-改修内容 持抗凝固剤続総量チェックボックスを追加 穆 end
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
    // add FNSI-改修内容 持抗凝固剤続総量チェックボックスを追加 穆 start
    ...mapMutations("pat-viewer-treat-cond", ["setCheckDisabled"]),
    unitCheck(e) {
      this.newDisabled = e.checked;
      this.setCheckDisabled(this.newDisabled);
    },
    // add FNSI-改修内容 持抗凝固剤続総量チェックボックスを追加 穆 end
    //upd 抗凝固剤持続総量自動計算エラー 修正 20230712 ztc start
    calculateAmount() {
      if (!this.isIpAutoOff) {
        this.displayInputValue.editValue = simpleAccDivision(
          accMulti(this.antiCoagulantFlowRate, this.treatTime), 60)
      } else {
        // mod 11790 抗凝固剤持続総量の計算をするとマイナスになる事がある zkm start
        // this.displayInputValue.editValue = accMulti(
        //   this.antiCoagulantFlowRate
        //   , simpleAccDivision(
        //     accSub(this.treatTime, this.ipAutoOffTiming)
        //     , 60
        //   )
        // );
        // mod 11943 抗凝固剤治療指示のバグ修正 追加 zkm start
        // const ipActionTime = accSub(this.treatTime, this.ipAutoOffTiming);
        const ipActionTime = accSub(this.treatTime, this.isIpUse ? this.ipAutoOffTiming : 0);
        // mod 11943 抗凝固剤治療指示のバグ修正 追加 zkm end
        if (ipActionTime <= 0) {
          this.$ons.notification.alert({
            title: DIALOG_MESSAGES[10400015].title,
            message: messageFormat(DIALOG_MESSAGES[10400015].message),
          });
        } else {
          this.displayInputValue.editValue = accMulti(this.antiCoagulantFlowRate, simpleAccDivision(ipActionTime, 60));
        }
        // mod 11790 抗凝固剤持続総量の計算をするとマイナスになる事がある zkm end
      }
      this.displayInputValue.editValue = isNaN(this.displayInputValue.editValue)
        ? null
        : parseFloat(this.displayInputValue.editValue).toFixed(this.decPoint);
    },
    //upd 抗凝固剤持続総量自動計算エラー 修正 20230712 ztc end
    // add #10196 数値IFのスタイル全不正 linjunfeng start
    unitStep() {
      var num = parseInt(this.decPoint);
      if(isNaN(num)){
        return 1;
      }
      if (!this.isMst) {
          let componentDataList = this.$parent.$parent.componentData.filter(item => {
            return item.cd === 26;
          });
          let rstDialysisState = "0";
          if(componentDataList&&componentDataList.length>0){
              rstDialysisState = componentDataList[0].fields.rstDialysisState;
          }
          const currentDecPoint = BigNumber(this.displayInputValue.editValue).decimalPlaces();
          if (rstDialysisState !== "0" && currentDecPoint > this.decPoint) {
            num = currentDecPoint
          }
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
};
</script>
<!-- add redmine 4595 数値入力IFのスタイル不正 宋qy start -->
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
/* mod FNSI-4882 劉全航 start */
.label-edited {
  color: green;
  font-weight: bold;
}
/* mod FNSI-4882 劉全航 end */
</style>
<!-- add redmine 4595 数値入力IFのスタイル不正 宋qy end -->
