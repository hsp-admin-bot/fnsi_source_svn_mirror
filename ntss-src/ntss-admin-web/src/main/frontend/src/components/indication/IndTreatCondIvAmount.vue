/** * 治療条件ー補液量 */

<template>
  <!-- mod 9664補液及び透析液仕様修正します yangqingzhe start -->
  <!-- <v-ons-row> -->
    <v-ons-row :class="getIsUseFlagIvAmount ? 'cell-disabled' : ''">
  <!-- mod 9664補液及び透析液仕様修正します yangqingzhe end -->
    <v-ons-col class="action-condition-column">補液量</v-ons-col>
    <v-ons-col class="action-condition-data-column">
      <!-- mod FNSI-薬剤指示画面等の画面崩れの修正 楊 start -->
      <!-- <custom-input-number
        :value="displayInputValue"
        :digits="4"
        :decimal-digits="1"
        :min-value="0.0"
        :max-value="999.0"
        :disabled="isDisabled || isDisabledFromTreatMethod"
        class="action-condition-input"
        style="width: 50px"
      /> -->
      <!--mod FNSI-【1006】最新の改修対象一覧の412対応 韓 start-->
      <!--<custom-input-number
        :value="displayInputValue"
        :digits="4"
        :decimal-digits="1"
        :min-value="0.0"
        :max-value="999.0"
        :disabled="isDisabled || isDisabledFromTreatMethod"
        class="action-condition-input ntss-custom-input-cond"
        style="width: 50px"
      />-->
      <!-- mod FNSI-障害票一覧_患者経過総合ビューアNo.102 李 start -->
      <!-- <custom-input-number
        :value="getLiquidAmountString"
        :digits="4"
        :decimal-digits="1"
        :min-value="minValueLquid"
        :max-value="999.0"
        :disabled="isDisabled || isDisabledFromTreatMethod || isAutoCal"
        class="action-condition-input ntss-custom-input-cond"
        style="width: 50px"
        @blur="onLiquidAmountBlur"
      /> -->
      <!-- add redmine 4595 数値入力IFのスタイル不正 宋qy start -->
      <!-- mod 8204 周安寧 start -->
      <!-- <custom-input-number
        :placeholder = "LiquidAmountSetPlaceholder"
        :value="getLiquidAmountString"
        :digits="4"
        :decimal-digits="1"
        :min-value="minValueLquid"
        :max-value="999.0"
        :disabled="isDisabled || isDisabledFromTreatMethod"
        class="action-condition-input ntss-custom-input-cond"
        style="width: 140px"
        @blur="onLiquidAmountBlur"
        @change="changeButton()"
        ref="amountInput"
      /> -->
      <!-- mod #5589 2023/04/11 数値IFのスタイル全不正 張博 start -->
      <!-- <custom-input-number
        :placeholder = "LiquidAmountSetPlaceholder"
        :value="getLiquidAmountString"
        :digits="4"
        :decimal-digits="1"
        :min-value="minValueLquid"
        :max-value="999.0"
        :disabled="isDisabled || isDisabledFromTreatMethod || getIsUseFlagIvAmount"
        class="action-condition-input ntss-custom-input-cond"
        style="width: 140px"
        @blur="onLiquidAmountBlur"
        @change="changeButton()"
        ref="amountInput"
      /> -->
      <!-- mod 不具合 #5920 dou start -->
      <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240108 linjunfeng start -->
      <!-- <custom-input-number
        :placeholder = "LiquidAmountSetPlaceholder"
        :value="getLiquidAmountString"
        :digits="4"
        :decimal-digits="1"
        :min-value="minValueLquid"
        :max-value="999.0"
        :disabled="isDisabled || isDisabledFromTreatMethod || getIsUseFlagIvAmount || isAutoCal"
        class="action-condition-input ntss-custom-input-cond"
        style="width: 140px"
        @blur="onLiquidAmountBlur"
        @change="changeButton()"
        @wheel="changeButton()"
        ref="amountInput"
      /> -->
      <!-- mod #10359 編集権限の動作不正 dengshen start -->
      <!-- <custom-input-number -->
      <!--   :placeholder = "LiquidAmountSetPlaceholder" -->
      <!--   :value="getLiquidAmountString" -->
      <!--   :digits="4" -->
      <!--  :decimal-digits="1" -->
      <!--   :min-value="minValueLquid" -->
      <!--   :max-value="999.0" -->
      <!--   :disabled="isDisabled || isDisabledFromTreatMethod || getIsUseFlagIvAmount || isAutoCal" -->
      <!--   class="action-condition-input ntss-custom-input-cond" -->
      <!--   style="width: 140px" -->
      <!--   @blur="onLiquidAmountBlur" -->
      <!--   ref="amountInput" -->
      <!-- /> -->
      <!-- #10196 数値IFのスタイル全不正 linjunfeng start -->
      <!-- <custom-input-number
        :placeholder = "LiquidAmountSetPlaceholder"
        :value="getLiquidAmountString"
        :digits="4"
        :decimal-digits="1"
        :min-value="minValueLquid"
        :max-value="999.0"
        :disabled="isDisabled ||
         isDisabledFromTreatMethod ||
         getIsUseFlagIvAmount ||
         isAutoCal ||
         !getItemAuthorized('Indication', 'default_authority')"
        class="action-condition-input ntss-custom-input-cond"
        style="width: 140px"
        @blur="onLiquidAmountBlur"
        ref="amountInput"
      /> -->
      <custom-input-number-pro
        :placeholder = "LiquidAmountSetPlaceholder"
        :initVal="getLiquidAmountString.initValue"
        :value="getLiquidAmountString.editValue"
        :step="0.1"
        :min="0"
        :max="999"
        :emptyVal="null"
        :disabled="isDisabled ||
         isDisabledFromTreatMethod ||
         getIsUseFlagIvAmount ||
         isAutoCal ||
         !getItemAuthorized('Indication', 'default_authority')"
        class="action-condition-input ntss-custom-input-cond"
        :class="isDisabled ||
         isDisabledFromTreatMethod ||
         getIsUseFlagIvAmount ||
         isAutoCal ||
         !getItemAuthorized('Indication', 'default_authority') ? 'nogreen':''"
        style="width: 140px"
        ref="amountInput"
        @blur="onLiquidAmountBlur"
        @handlerInput="(val) =>{ displayInputValue.editValue = val }"
      />
      <!-- #10196 数値IFのスタイル全不正 linjunfeng end -->
      <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240108 linjunfeng end -->
      <!-- mod 不具合 #5920 dou end -->
      <!-- mod #5589 2023/04/11 数値IFのスタイル全不正 張博 end -->
      <!-- mod 8204 周安寧 end -->
      <!-- add redmine 4595 数値入力IFのスタイル不正 宋qy end -->
      <!-- mod FNSI-障害票一覧_患者経過総合ビューアNo.102 李 start -->
      <!--mod FNSI-【1006】最新の改修対象一覧の412対応 韓 end-->
      <!-- mod FNSI-薬剤指示画面等の画面崩れの修正 楊 end -->
      <label>L</label>
    </v-ons-col>
    <!--add FNSI-【1006】最新の改修対象一覧の412対応 韓 start-->
    <!--mod マスタ一覧 412画面と同じように記載を表示する。 start-->
    <!--mod FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxの32対応 韓 start-->
    <v-ons-col class="mst-treatment-set-speed  mst-treatment-set-amount" style="flex-basis:55%; margin-right:5px">
    <!--mod FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxの32対応 韓 end-->
      <!--mod マスタ一覧 412画面と同じように記載を表示する。 end-->
    <span v-show="isCommentShow">
      <div v-for="(item, index) in displayString" :key="index">{{item}}</div>
    </span>
    </v-ons-col>
    <!--add FNSI-【1006】最新の改修対象一覧の412対応 韓 end-->
  </v-ons-row>
</template>

<script>
// add #10359 編集権限の動作不正 dengshen start
import { getAuthorized } from "@/functions/common/CommonFunctions.js";
// add #10359 編集権限の動作不正 dengshen end
// mod FNSI-【1006】最新の改修対象一覧の412対応 韓 start
// import { mapGetters } from "vuex";
import { mapGetters, mapMutations } from "vuex";
// mod FNSI-【1006】最新の改修対象一覧の412対応 韓 end
import IndTreatCondBase from "@/components/indication/IndTreatCondBase";
import {EventBus} from "@/eventBus";
// mod 10150 治療条件変更時のonline、offline補液関連 関  start
import {
  simpleAccDivision, accSub,divide, accMulti, toFixedWithRoundingMode
} from "@/functions/common/NumberFunctions.js";
import BigNumber from "bignumber.js";
// mod 10150 治療条件変更時のonline、offline補液関連 関  end
export default {
  mixins: [IndTreatCondBase],
  // add 不具合 #5920 dou start
  data() {
    return {
      isAutoCal: false,
      LiquidAmountSetPlaceholder: "",
    };
  },
  // add 不具合 #5920 dou end
  computed: {
    ...mapGetters("pat-viewer-treat-cond", {
      isDisabled: "getIvDisabled",
      deviceMode: "getDeviceMode",
      // add FNSI-【1006】最新の改修対象一覧の412対応 韓 start
      isCommentShow: "getLiquidAmountCommentIsShow",
      displayString: "getLiquidAmountDisplayString",
      treatTime: "getTreatTime",
      liquidDelayTiming: "getLiquidDelayTiming",
      liquidSpeed: "getLiquidSpeed",
      liquidCalPriority: "getLiquidCalPriority",
      ihdfLiquidTotal: "getIhdfLiquidTotal",
      // add 8204 周安寧 start
      getIsUseFlagIvAmount:"getIsUseFlagIvAmount"
      // add 8204 周安寧 end
    }),
    ...mapGetters("pat-viewer-modal", {
      isShowIndModal: "getIsShowIndModal"
    }),
    // del 不具合 #5920 dou start
    // data() {
    //   return {
    //     isAutoCal: false
    //   };
    // },
    // del 不具合 #5920 dou end
    // 補液量を取得
    //mod FutreNetWeb+SI課題管理No5641&&5670対応 于 start
    getLiquidAmountString() {
      if ( this.calLiquidAmount() && this.calLiquidAmount().editValue == -1 && this.calLiquidAmount().initValue != -1){
        // //mod FNSI-7194
        this.$refs.amountInput.classObject["custom-input-number-edited"] = true;
        // //mod FNSI-7194
        // #10196 数値IFのスタイル全不正 linjunfeng start
        // return "";
        this.displayInputValue.editValue = null;
        return this.displayInputValue;
        // #10196 数値IFのスタイル全不正 linjunfeng end
      // add #IES_5920 dou start
      } else if ( this.calLiquidAmount() && this.calLiquidAmount().editValue == -1 && this.calLiquidAmount().initValue == -1){
        // #10196 数値IFのスタイル全不正 linjunfeng start
        // return "";
        this.displayInputValue.editValue = null;
        return this.displayInputValue;
        // #10196 数値IFのスタイル全不正 linjunfeng end
      // add #IES_5920 dou end
      } else {
        return this.calLiquidAmount();
      }
    },
    //mod FutreNetWeb+SI課題管理No5641&&5670対応 于 end

    // del 不具合 #5920 dou start
    //add FutreNetWeb+SI課題管理No5641&&5670対応 于 start
    // LiquidAmountSetPlaceholder(){
    //   if ( this.calLiquidAmount().editValue == -1 ) {
    //     // add 不具合 #5920 dou start
    //     this.isAutoCal = true;
    //     // add 不具合 #5920 dou end
    //     return  "濾過率から算出";
    //   }else{
    //     // add 不具合 #5920 dou start
    //     this.isAutoCal = false;
    //     // add 不具合 #5920 dou end
    //     return "";
    //   }
    // },
    //add FutreNetWeb+SI課題管理No5641&&5670対応 于 end
    // del 不具合 #5920 dou end
    // add FNSI-【1006】最新の改修対象一覧の412対応 韓 end
    isDisabledFromTreatMethod() {
      // mod 9664補液及び透析液仕様修正します yangqingzhe start
      // return this.deviceMode === 10; //I-HDF
      return (
        this.deviceMode === 10 ||  //I-HDF
        this.deviceMode === 0 ||  //HD
        this.deviceMode === 1 //ECUM
      );
      // mod 9664補液及び透析液仕様修正します yangqingzhe end
    }
  },

  // add FNSI-【1006】最新の改修対象一覧の412対応 韓 start
  methods: {
    ...mapMutations("pat-viewer-treat-cond", ["setLiquidAmount"]),
    // add #10359 編集権限の動作不正 dengshen start
    getItemAuthorized(pageCd, itemCd) {
      return this.isMst || (this.isMst != true && getAuthorized(pageCd, itemCd));
    },
    // add #10359 編集権限の動作不正 dengshen end
    // 補液量を算出
    calLiquidAmount() {
      if (this.isShowIndModal) {
        /* add by chamaojia 2023-04-20 [8537] 追加Yes No計算フラグ  --start */
        let isCalculateFlag = false;
        /* add by chamaojia 2023-04-20 [8537] 追加Yes No計算フラグ  --end */
        // 指示系モーダルを表示の場合に算出する。
        let liquidAmount = this.displayInputValue.editValue;
        //(OHDF:7、OHF:8  かつ 補液量設定算出:1 の場合)
        if (this.deviceMode === 7 || this.deviceMode === 8) {
          if (this.liquidCalPriority === '1' || this.liquidCalPriority === '2') {
            //mod FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.94(外結)対応 韓 start
            //if (this.liquidDelayTiming && this.treatTime > this.liquidDelayTiming) {
            //mod FNSI-6442 劉全航 start
            // if (this.liquidSpeed && this.treatTime &&
            //   this.liquidDelayTiming && this.treatTime > this.liquidDelayTiming) {
              // mod #8816「OHDF・OHFの補液計算優先項目による補液量設定と補液速度が不正」について、対応する。 dengshen start
              // if (this.liquidSpeed && this.treatTime && this.treatTime > this.liquidDelayTiming) {
              if (this.liquidSpeed !== undefined && this.liquidSpeed !== null &&
                this.treatTime !== undefined && this.treatTime !== null && this.treatTime > this.liquidDelayTiming) {
              // mod #8816「OHDF・OHFの補液計算優先項目による補液量設定と補液速度が不正」について、対応する。 dengshen end
                //mod FNSI-6442 劉全航 end
            //mod FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.94(外結)対応 韓 end
            //   liquidAmount = this.liquidSpeed * ((this.treatTime - this.liquidDelayTiming) / 60);
              // mod 10150 治療条件変更時のonline、offline補液関連 関  start
              // liquidAmount = accMulti(
              //     this.liquidSpeed,
              //     simpleAccDivision(
              //       accSub(this.treatTime, this.liquidDelayTiming)
              //       , 60
              //     )
              //   )
                liquidAmount = toFixedWithRoundingMode(divide(Number(accMulti(
                  this.liquidSpeed,accSub(this.treatTime, this.liquidDelayTiming)
                )), 60), 1, BigNumber.ROUND_DOWN);

                // mod 10150 治療条件変更時のonline、offline補液関連 関  end
              // 補液速度×(治療時間-補液開始遅延時間)
              // add #8816「OHDF・OHFの補液計算優先項目による補液量設定と補液速度が不正」について、対応する。 dengshen start
              this.isAutoCal = true;
              // add #8816「OHDF・OHFの補液計算優先項目による補液量設定と補液速度が不正」について、対応する。 dengshen end
                isCalculateFlag = true;
            }
            //mod FNSI-7226 劉全航 start
            if(this.liquidSpeed == -1){
                // mod 10150 治療条件変更時のonline、offline補液関連 関  start
                // liquidAmount = 0;
                liquidAmount = Number(0).toFixed(1);
                // mod 10150 治療条件変更時のonline、offline補液関連 関  end
              isCalculateFlag = true;
              }
              //mod FNSI-7226 劉全航 end
          } else if (this.liquidCalPriority === '3') {
            this.minValueLquid = -1;
            liquidAmount = -1;
            isCalculateFlag = true;
            // add #8816「OHDF・OHFの補液計算優先項目による補液量設定と補液速度が不正」について、対応する。 dengshen start
            this.isAutoCal = true;
            // mod #IES_5920 dou start
            // this.LiquidSpeedSetPlaceholder = "濾過率から算出";
            this.LiquidAmountSetPlaceholder = "濾過率から算出";
            // mod #IES_5920 dou end
            // add #8816「OHDF・OHFの補液計算優先項目による補液量設定と補液速度が不正」について、対応する。 dengshen end
          }
          //mod FNSI-7226 劉全航 start
          else if(this.liquidCalPriority === '0'){
            if(liquidAmount == -1){
              liquidAmount = 0;
              isCalculateFlag = true;
            }
            // add #8816「OHDF・OHFの補液計算優先項目による補液量設定と補液速度が不正」について、対応する。 dengshen start
            this.isAutoCal = false;
            // add #8816「OHDF・OHFの補液計算優先項目による補液量設定と補液速度が不正」について、対応する。 dengshen end
          }
          //mod FNSI-7226 劉全航 end
        } else if (this.deviceMode === 10) {
          //I-HDFの場合
          liquidAmount = this.ihdfLiquidTotal;
          isCalculateFlag = true;
        }
        if (isNaN(liquidAmount) || liquidAmount == null) {
          // 内部 【結合テスト】患者経過総合ビューア_補液情報編:補液量削除後未表示為空白 start
          this.displayInputValue.editValue = null;
          // 内部 【結合テスト】患者経過総合ビューア_補液情報編:補液量削除後未表示為空白 end
          // del 不具合 #5920 dou start
          // this.isAutoCal = false;
          // del 不具合 #5920 dou end
        } else {
          // del #IES_5920 dou start
          //add #7194 2022/8/29 OHDF・OHFで濾過率から算出に設定すると補液速度と補液量が不適切 gaoey start
          // if (this.displayInputValue.editValue == -1 && this.displayInputValue.initValue == -1 && liquidAmount == -1 && this.liquidCalPriority === '3') {
          //   this.displayInputValue.initValue = 0
          // }
          // del #IES_5920 dou end
          //add #7194 2022/8/29 OHDF・OHFで濾過率から算出に設定すると補液速度と補液量が不適切 gaoey end
          this.displayInputValue.editValue = liquidAmount;
          //add 8204 周安寧 start
          if (this.deviceMode === 10){
            /* modify by chamaojia 2023-04-20 [8537] 判断条件の追加  --start */
            // 最初の計算で初期値を変更し、緑枠と保存の問題を解決
            if (this.displayInputValue.firstCalculateFlag && isCalculateFlag) {
              this.displayInputValue.initValue = liquidAmount
              this.displayInputValue.firstCalculateFlag = false;
            }
            // this.displayInputValue.initValue = liquidSpeed
            /* modify by chamaojia 2023-04-20 [8537] 判断条件の追加  --end */
          }
          //add 8204 周安寧 end
          this.setLiquidAmount(liquidAmount);
          // del 不具合 #5920 dou start
          // this.isAutoCal = true;
          // del 不具合 #5920 dou end
        }
        }
      return this.displayInputValue;
    },
    /**
     * 補液量入力値設定。
     */
    onLiquidAmountBlur() {
      this.setLiquidAmount(this.displayInputValue.editValue);
    },
     //[確認]ボタンの状態の変更をトリガーします
    changeButton() {
      EventBus.$emit("mstHolidayRegistered", false);
    },
    // add 不具合 #5920 dou start
    setLiquidAmountSetPlaceholder() {
      if (this.calLiquidAmount().editValue == -1) {
        this.isAutoCal = true;
        this.LiquidAmountSetPlaceholder = "濾過率から算出";
      } else {
        this.isAutoCal = false;
        this.LiquidAmountSetPlaceholder = "";
      }
    },
    // add 不具合 #5920 dou end
  },
  // add FNSI-【1006】最新の改修対象一覧の412対応 韓 end
  mounted() {
    this.treatItemCd = "20";
    this.unit = "L";
    // add 不具合 #5920 dou start
    this.setLiquidAmountSetPlaceholder();
    // add 不具合 #5920 dou end
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
/* add 不具合 #5920 dou start */
.action-condition-input >>> .text-input::-webkit-input-placeholder {
  color: black;
}
.nogreen >>> .text-input{
  border: 2px inset #ebebe4 !important;
}
/* add 不具合 #5920 dou end */
</style>
<!-- add redmine 4595 数値入力IFのスタイル不正 宋qy end -->
