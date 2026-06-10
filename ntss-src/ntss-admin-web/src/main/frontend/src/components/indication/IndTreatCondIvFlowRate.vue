/** * 治療条件ー補液速度 */

<template>
  <!-- mod 9664補液及び透析液仕様修正します yangqingzhe start -->
  <!-- <v-ons-row> -->
    <v-ons-row :class="getIsUseFlagIvFlowRate ? 'cell-disabled' : ''">
  <!-- mod 9664補液及び透析液仕様修正します yangqingzhe end -->
    <v-ons-col class="action-condition-column">補液速度</v-ons-col>
    <v-ons-col class="action-condition-data-column">
      <!-- mod FNSI-薬剤指示画面等の画面崩れの修正 楊 start -->
      <!--<custom-input-number
        :value="displayInputValue"
        :digits="5"
        :decimal-digits="2"
        :min-value="0.0"
        :max-value="999.0"
        :disabled="isDisabled || isDisabledFromTreatMethod"
        class="action-condition-input"
        style="width: 90px"
      /> -->
      <!--mod FNSI-【1006】最新の改修対象一覧の412対応 韓 start-->
      <!--<custom-input-number
        :value="displayInputValue"
        :digits="5"
        :decimal-digits="2"
        :min-value="0.0"
        :max-value="999.0"
        :disabled="isDisabled || isDisabledFromTreatMethod"
        class="action-condition-input ntss-custom-input-cond"
        style="width: 90px"
      />-->
      <!-- mod FNSI-障害票一覧_患者経過総合ビューアNo.88 李 start -->
      <!-- <custom-input-number
        :value="getLiquidSpeedString"
        :digits="5"
        :decimal-digits="2"
        :min-value="minValueLquid"
        :max-value="999.0"
        :disabled="isDisabled || isDisabledFromTreatMethod || isAutoCal"
        class="action-condition-input ntss-custom-input-cond"
        style="width: 90px"
        @blur="onLiquidSpeedtBlur"
      /> -->
      <!-- mod FNSI-障害票一覧_患者経過総合ビューアNo.102 李 start -->
      <!-- <custom-input-number
        :value="getLiquidSpeedString"
        :digits="5"
        :decimal-digits="2"
        :min-value="minValueLquid"
        :max-value="999.0"
        :disabled="isDisabledFromTreatMethod"
        class="action-condition-input ntss-custom-input-cond"
        style="width: 90px"
        @blur="onLiquidSpeedtBlur"
      /> -->
      <!-- mod 8204 周安寧 start -->
      <!-- <custom-input-number
        :placeholder = "LiquidSpeedSetPlaceholder"
        :value="getLiquidSpeedString"
        :digits="5"
        :decimal-digits="2"
        :min-value="minValueLquid"
        :max-value="999.0"
        :disabled="isDisabled || isDisabledFromTreatMethod"
        class="action-condition-input ntss-custom-input-cond"
        style="width: 140px"
        @blur="onLiquidSpeedtBlur"
        @change="changeButton()"
        ref="flowRateInput"
      /> -->
      <!-- mod #5589 2023/04/11 数値IFのスタイル全不正 張博 start -->
      <!-- <custom-input-number
        :placeholder = "LiquidSpeedSetPlaceholder"
        :value="getLiquidSpeedString"
        :digits="5"
        :decimal-digits="2"
        :min-value="minValueLquid"
        :max-value="999.0"
        :disabled="isDisabled || isDisabledFromTreatMethod || getIsUseFlagIvFlowRate"
        class="action-condition-input ntss-custom-input-cond"
        style="width: 140px"
        @blur="onLiquidSpeedtBlur"
        @change="changeButton()"
        ref="flowRateInput"
      /> -->
      <!-- mod 不具合 #5920 dou start -->
      <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240108 linjunfeng start -->
      <!-- <custom-input-number
        :placeholder="LiquidSpeedSetPlaceholder"
        :value="getLiquidSpeedString"
        :digits="5"
        :decimal-digits="2"
        :min-value="minValueLquid"
        :max-value="999.0"
        :disabled="isDisabled || isDisabledFromTreatMethod || getIsUseFlagIvFlowRate || isAutoCal"
        class="action-condition-input ntss-custom-input-cond"
        style="width: 140px"
        @blur="onLiquidSpeedtBlur"
        @change="changeButton()"
        @wheel="changeButton()"
        ref="flowRateInput"
      /> -->
      <!-- mod #10359 編集権限の動作不正 dengshen start -->
      <!-- <custom-input-number -->
      <!--   :placeholder="LiquidSpeedSetPlaceholder" -->
      <!--   :value="getLiquidSpeedString" -->
      <!--   :digits="5" -->
      <!--   :decimal-digits="2" -->
      <!--   :min-value="minValueLquid" -->
      <!--   :max-value="999.0" -->
      <!--   :disabled="isDisabled || isDisabledFromTreatMethod || getIsUseFlagIvFlowRate || isAutoCal" -->
      <!--   class="action-condition-input ntss-custom-input-cond" -->
      <!--   style="width: 140px" -->
      <!--   @blur="onLiquidSpeedtBlur" -->
      <!--   ref="flowRateInput" -->
      <!-- /> -->
      <!-- #10196 数値IFのスタイル全不正 linjunfeng start -->
      <!-- <custom-input-number
        :placeholder="LiquidSpeedSetPlaceholder"
        :value="getLiquidSpeedString"
        :digits="5"
        :decimal-digits="2"
        :min-value="minValueLquid"
        :max-value="999.0"
        :disabled="isDisabled || isDisabledFromTreatMethod || getIsUseFlagIvFlowRate || isAutoCal || !getItemAuthorized('Indication', 'default_authority')"
        class="action-condition-input ntss-custom-input-cond"
        style="width: 140px"
        @blur="onLiquidSpeedtBlur"
        ref="flowRateInput"
      /> -->
      <custom-input-number-pro
        :placeholder="LiquidSpeedSetPlaceholder"
        :initVal="getLiquidSpeedString.initValue"
        :value="getLiquidSpeedString.editValue"
        :step="0.01"
        :min="minValueLquid"
        :max="999.99"
        :emptyVal="null"
        :disabled="isDisabled || isDisabledFromTreatMethod || getIsUseFlagIvFlowRate || isAutoCal || !getItemAuthorized('Indication', 'default_authority')"
        class="action-condition-input ntss-custom-input-cond"
        style="width: 140px"
        ref="flowRateInput"
        @blur="onLiquidSpeedtBlur"
        @handlerInput="(val) =>{ getLiquidSpeedString.editValue = val }"
      />
      <!-- #10196 数値IFのスタイル全不正 linjunfeng end -->
      <!-- #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療方法セットマスタ 20240108 linjunfeng end -->
      <!-- mod 不具合 #5920 dou end -->
      <!-- mod #5589 2023/04/11 数値IFのスタイル全不正 張博 end -->
      <!-- mod 8204 周安寧 end -->
      <!-- mod FNSI-障害票一覧_患者経過総合ビューアNo.102 李 end -->
      <!-- mod FNSI-障害票一覧_患者経過総合ビューアNo.88 李 end -->
      <!--mod FNSI-【1006】最新の改修対象一覧の412対応 韓 end-->
      <!-- mod FNSI-薬剤指示画面等の画面崩れの修正 楊 end -->
      <label>L/h</label>
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
import {mapGetters, mapMutations} from "vuex";
// mod FNSI-【1006】最新の改修対象一覧の412対応 韓 end
import IndTreatCondBase from "@/components/indication/IndTreatCondBase";
import {EventBus} from "@/eventBus";
import {
  simpleAccDivision, accSub, accMulti, divide, minusDecimal, toFixedWithRoundingMode
} from "@/functions/common/NumberFunctions.js";
import BigNumber from "bignumber.js";
export default {
  mixins: [IndTreatCondBase],
  // add 不具合 #5920 dou start
  data() {
    return {
      isAutoCal: false,
      LiquidSpeedSetPlaceholder: "",
    };
  },
  // add 不具合 #5920 dou end
  computed: {
    ...mapGetters("pat-viewer-treat-cond", {
      isDisabled: "getIvDisabled",
      deviceMode: "getDeviceMode",
      // add FNSI-【1006】最新の改修対象一覧の412対応 韓 start
      isCommentShow: "getLiquidSpeedCommentIsShow",
      displayString: "getLiquidSpeedDisplayString",
      treatTime: "getTreatTime",
      liquidDelayTiming: "getLiquidDelayTiming",
      liquidAmount: "getLiquidAmount",
      liquidCalPriority: "getLiquidCalPriority",
      bloodFlowRate: "getBloodFlowRate",
      liquidRateBefore: "getLiquidRateBefore",
      liquidRateAfter: "getLiquidRateAfter",
      liquidSelection: "getLiquidSelection",
      ihdfLiquidSpeed: "getIhdfLiquidSpeed",
      //add 8204 周安寧 start
      getIsUseFlagIvFlowRate: "getIsUseFlagIvFlowRate"
      //add 8204 周安寧 end
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
    // 補液速度を取得
    //mod FutreNetWeb+SI課題管理No5641&&5670対応 于 start
    getLiquidSpeedString() {
      // mod #1050 piao start
      let constCalLiquidSpeed = this.calLiquidSpeed();
      if (constCalLiquidSpeed && constCalLiquidSpeed.editValue == -1 && constCalLiquidSpeed.initValue != -1) {
        //mod FNSI-7194
        this.$refs.flowRateInput.classObject["custom-input-number-edited"] = true;
        //mod FNSI-7194
        // #10196 数値IFのスタイル全不正 linjunfeng start
        // return "";
        this.displayInputValue.editValue = null;
        return this.displayInputValue;
        // #10196 数値IFのスタイル全不正 linjunfeng end
      // add #IES_5920 dou start
      } else if (constCalLiquidSpeed && constCalLiquidSpeed.editValue == -1 && constCalLiquidSpeed.initValue == -1) {
        // mod 10150 治療条件変更時のonline、offline補液関連 関  start
        // #10196 数値IFのスタイル全不正 linjunfeng start
        // return "";
        // this.displayInputValue.editValue = null;
        if (this.liquidCalPriority != null && this.liquidCalPriority != '3') {
          this.displayInputValue.editValue = Number(0).toFixed(2);
          this.isAutoCal = false;
        }else{
          this.displayInputValue.editValue = null;
        }
        // mod 10150 治療条件変更時のonline、offline補液関連 関  end
        return this.displayInputValue;
        // #10196 数値IFのスタイル全不正 linjunfeng end
      // add #IES_5920 dou end
      } else {
        return constCalLiquidSpeed;
      }
      // mod #1050 piao end
    },
    //mod FutreNetWeb+SI課題管理No5641&&5670対応 于 end
    // add FNSI-【1006】最新の改修対象一覧の412対応 韓 end
    // del 不具合 #5920 dou start
    //add FutreNetWeb+SI課題管理No5641&&5670対応 于 start
    // LiquidSpeedSetPlaceholder() {
    //   if (this.calLiquidSpeed().editValue == -1) {
    //     // add 不具合 #5920 dou start
    //     this.isAutoCal = true;
    //     // add 不具合 #5920 dou end
    //     return "濾過率から算出";
    //   }else {
    //     // add 不具合 #5920 dou start
    //     this.isAutoCal = false;
    //     // add 不具合 #5920 dou end
    //     return "";
    //   }
    // },
    //add FutreNetWeb+SI課題管理No5641&&5670対応 于 end
    // del 不具合 #5920 dou end
    isDisabledFromTreatMethod() {
      //mod 5532 操作範囲＞補液速度が反映されない 張 start
      // return this.deviceMode === 10; //I-HDF
      switch (this.deviceMode) {
        // add 9664補液及び透析液仕様修正します yangqingzhe start
        //HD
        case 0:
          return true;
          break;
        //ECUM
        case 1:
          return true;
          break;
        // add 9664補液及び透析液仕様修正します yangqingzhe end
        //HDF
        case 2:
          return true;
          break;
        //HF
        case 3:
          return true;
          break;
        //AFBF
        case 6:
          return true;
          break;
        //I-HDF
        case 10:
          return true;
          break;
        default:
          return false;
      }
      //mod 5532 操作範囲＞補液速度が反映されない 張 end
    }
  },

  // add FNSI-【1006】最新の改修対象一覧の412対応 韓 start
  methods: {
    ...mapMutations("pat-viewer-treat-cond", ["setLiquidSpeed"]),
    // add #10359 編集権限の動作不正 dengshen start
    getItemAuthorized(pageCd, itemCd) {
      return this.isMst || (this.isMst != true && getAuthorized(pageCd, itemCd));
    },
    // add #10359 編集権限の動作不正 dengshen end
    // 補液速度を算出
    calLiquidSpeed() {
      // add 補液速度を補液量/治療時間で計算して(2つの変更で再計算)、非活性 王 start
      // if (this.isShowIndModal) {
      if (this.isShowIndModal || this.isMst) {
        /* add by chamaojia 2023-04-20 [8537] 追加Yes No計算フラグ  --start */
        let isCalculateFlag = false;
        /* add by chamaojia 2023-04-20 [8537] 追加Yes No計算フラグ  --end */
        // add 補液速度を補液量/治療時間で計算して(2つの変更で再計算)、非活性 王 end
        // 指示系モーダルを表示の場合に算出する。
        let liquidSpeed = this.displayInputValue.editValue;
        //(HDF:2、HF:3、AFBF:6の場合) 或いは (OHDF:7、OHF:8  かつ 補液速度算出:0 の場合)
        if (this.deviceMode === 2 ||
          this.deviceMode === 3 ||
          this.deviceMode === 6 ||
          ((this.deviceMode === 7 ||
              this.deviceMode === 8) &&
            this.liquidCalPriority === '0')) {
          // add 補液速度を補液量/治療時間で計算して(2つの変更で再計算)、非活性 王 start
          // if (this.liquidDelayTiming && this.treatTime > this.liquidDelayTiming) {
          //mod FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.94(外結)対応 韓 start
          //if (this.liquidDelayTiming !== undefined && this.treatTime > this.liquidDelayTiming) {
          // mod FNSI-改修内容6514修正 xuty start
          //if (this.liquidAmount && this.treatTime && this.liquidDelayTiming &&
          //  this.liquidDelayTiming !== undefined && this.treatTime > this.liquidDelayTiming) {
          // mod #8816「OHDF・OHFの補液計算優先項目による補液量設定と補液速度が不正」について、対応する。 dengshen start
          // if (this.liquidAmount && this.treatTime && this.liquidDelayTiming !== null &&
          if (this.liquidAmount !== undefined && this.liquidAmount !== null &&
            this.treatTime !== undefined && this.liquidAmount !== null && this.liquidDelayTiming !== null &&
          // mod #8816「OHDF・OHFの補液計算優先項目による補液量設定と補液速度が不正」について、対応する。 dengshen end
            this.liquidDelayTiming !== undefined && this.treatTime > this.liquidDelayTiming) {
            // mod FNSI-改修内容6514修正 xuty end
            //mod FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.94(外結)対応 韓 end
            // add 補液速度を補液量/治療時間で計算して(2つの変更で再計算)、非活性 王 start
            // liquidSpeed = this.liquidAmount / ((this.treatTime - this.liquidDelayTiming) / 60);
            // liquidSpeed = simpleAccDivision(
            //     this.liquidAmount, simpleAccDivision(
            //         accSub(this.treatTime, this.liquidDelayTiming), 60)
            // );
            // mod 10150 治療条件変更時のonline、offline補液関連 関  start
            // liquidSpeed = toFixedWithRoundingMode(divide(Number(this.liquidAmount), Number(toFixedWithRoundingMode(divide(
            //     minusDecimal(this.treatTime, this.liquidDelayTiming)
            //     , 60), 2, BigNumber.ROUND_HALF_UP))
            // ), 2, BigNumber.ROUND_HALF_UP);
            var amountInit = this.liquidAmount == "-1" ? "0" : this.liquidAmount;
            liquidSpeed = toFixedWithRoundingMode(divide(accMulti(Number(amountInit), 60), Number(accSub(this.treatTime, this.liquidDelayTiming))),2, BigNumber.ceil);

            // mod 10150 治療条件変更時のonline、offline補液関連 関  end
            // 補液量入力値/(予定毎の治療時間－補液開始遅延時間）＝補液速度として保存する。
            // add #8816「OHDF・OHFの補液計算優先項目による補液量設定と補液速度が不正」について、対応する。 dengshen start
            this.isAutoCal = true;
            // add #8816「OHDF・OHFの補液計算優先項目による補液量設定と補液速度が不正」について、対応する。 dengshen end
            isCalculateFlag = true;
          }
          //mod FNSI-7226 劉全航 start
          if (this.liquidAmount == 0) {
            // mod #10150 補液速度(小数点以下２桁、切り上げ) zkm start
            // liquidSpeed = 0;
            liquidSpeed = Number(0).toFixed(2);
            // mod #10150 補液速度(小数点以下２桁、切り上げ) zkm end
            isCalculateFlag = true;
          }
          //mod FNSI-7226 劉全航 end
        } else if (this.deviceMode === 7 || this.deviceMode === 8) {
          // (OHDF:7、OHF:8 )
          if (this.liquidCalPriority === '2') {
            // 補液比率:2 の場合、血流量mL/min×補液比率%=補液速度L/h
            // mod 10150 治療条件変更時のonline、offline補液関連 関  start
            // const liquidRate = (this.liquidSelection === 1) ? this.liquidRateBefore : this.liquidRateAfter;
            // liquidSpeed = accMulti(
            //   this.bloodFlowRate
            //   , liquidRate / 100
            //   , 60
            // ) / 1000;
            // liquidSpeed = this.bloodFlowRate * (liquidRate / 100) * 60 / 1000;
            const liquidRate = (this.liquidSelection == 1) ? this.liquidRateBefore : this.liquidRateAfter;
            liquidSpeed = toFixedWithRoundingMode(
              accMulti(
              accMulti(this.bloodFlowRate,liquidRate)
              ,60
              ) / 100000, 2, BigNumber.ceil
            );
            // mod 10150 治療条件変更時のonline、offline補液関連 関  end
            // add #8816「OHDF・OHFの補液計算優先項目による補液量設定と補液速度が不正」について、対応する。 dengshen start
            this.isAutoCal = true;
            // add #8816「OHDF・OHFの補液計算優先項目による補液量設定と補液速度が不正」について、対応する。 dengshen end
            isCalculateFlag = true;
          } else if (this.liquidCalPriority === '3') {
            this.minValueLquid = -1;
            liquidSpeed = -1;
            isCalculateFlag = true;
            // add #8816「OHDF・OHFの補液計算優先項目による補液量設定と補液速度が不正」について、対応する。 dengshen start
            this.isAutoCal = true;
            this.LiquidSpeedSetPlaceholder = "濾過率から算出";
            // add #8816「OHDF・OHFの補液計算優先項目による補液量設定と補液速度が不正」について、対応する。 dengshen end
          }
          //mod FNSI-7226 劉全航 start
          else if (this.liquidCalPriority === '1') {
            if (liquidSpeed == -1) {
              liquidSpeed = 0;
              isCalculateFlag = true;
              // add #8816「OHDF・OHFの補液計算優先項目による補液量設定と補液速度が不正」について、対応する。 dengshen start
              this.isAutoCal = false;
              // add #8816「OHDF・OHFの補液計算優先項目による補液量設定と補液速度が不正」について、対応する。 dengshen end
            }
          }
          //mod FNSI-7226 劉全航 end
        } else if (this.deviceMode === 10) {
          //I-HDFの場合
          liquidSpeed = this.ihdfLiquidSpeed;
          isCalculateFlag = true;
        }
        if (isNaN(liquidSpeed) || liquidSpeed == null) {
          // modify 10150_9664 by kangjie 20240912 start
          // this.displayInputValue.editValue = this.displayInputValue.initValue;
          if (this.deviceMode === 9 || this.deviceMode === -1) {
            this.displayInputValue.editValue = null;
          isCalculateFlag = true;
          } else {
            this.displayInputValue.editValue = this.displayInputValue.initValue;
          }
          // modify 10150_9664 by kangjie 20240912 end
          // del 不具合 #5920 dou start
          // this.isAutoCal = false;
          // del 不具合 #5920 dou end
        } else {
          // del #IES_5920 dou start
          //add #7194 2022/8/29 OHDF・OHFで濾過率から算出に設定すると補液速度と補液量が不適切 gaoey start
          // if (this.displayInputValue.editValue == -1 && this.displayInputValue.initValue == -1 && liquidSpeed == -1 && this.liquidCalPriority === '3') {
          //   this.displayInputValue.initValue = 0
          // }
          //add #7194 2022/8/29 OHDF・OHFで濾過率から算出に設定すると補液速度と補液量が不適切 gaoey end
          // del #IES_5920 dou end
          this.displayInputValue.editValue = liquidSpeed;
          //add 8204 周安寧 start
          if (this.deviceMode === 2 ||
            this.deviceMode === 3 ||
            this.deviceMode === 6 || this.deviceMode === 10) {
            /* modify by chamaojia 2023-04-20 [8537] 判断条件の追加  --start */
            // 最初の計算で初期値を変更し、緑枠と保存の問題を解決
            if (this.displayInputValue.firstCalculateFlag && isCalculateFlag) {
              this.displayInputValue.initValue = liquidSpeed
              this.displayInputValue.firstCalculateFlag = false;
            }
            // this.displayInputValue.initValue = liquidSpeed
            /* modify by chamaojia 2023-04-20 [8537] 判断条件の追加  --end */
          }
          //add 8204 周安寧 end
          this.setLiquidSpeed(liquidSpeed);
          // del 不具合 #5920 dou start
          // this.isAutoCal = true;
          // del 不具合 #5920 dou end
        }
      }
      return this.displayInputValue;
    },

    /**
     * 補液速度入力値設定。
     */
    onLiquidSpeedtBlur() {
      // 内部 治療法セットマスタタ補液速度が異常を示します start
      // modify 10150_9664 by kangjie 20240912 start
      // if (!this.displayInputValue.editValue) {
      //   this.getLiquidSpeedString.editValue = null
      //   this.getLiquidSpeedString.initValue = null
      // }
      // modify 10150_9664 by kangjie 20240912 end
      // 内部 治療法セットマスタタ補液速度が異常を示します end
      this.setLiquidSpeed(this.displayInputValue.editValue);
    },
    //[確認]ボタンの状態の変更をトリガーします
    changeButton() {
      EventBus.$emit("mstHolidayRegistered", false);
    },
    // add 不具合 #5920 dou start
    setLiquidSpeedSetPlaceholder() {
      if (this.calLiquidSpeed().editValue == -1) {
        this.isAutoCal = true;
        this.LiquidSpeedSetPlaceholder = "濾過率から算出";
      } else {
        this.isAutoCal = false;
        this.LiquidSpeedSetPlaceholder = "";
      }
    }
    // add 不具合 #5920 dou end
  },
  // add FNSI-【1006】最新の改修対象一覧の412対応 韓 end
  mounted() {
    this.treatItemCd = "24";
    this.unit = "L/h";
    // add 不具合 #5920 dou start
    this.setLiquidSpeedSetPlaceholder();
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

/* add 不具合 #5920 dou end */
</style>
<!-- add redmine 4595 数値入力IFのスタイル不正 宋qy end -->
