/**
 * 治療記録の子機能 体重（透析前・後体重入力）
 */
<template>
  <modal-base @onClose="onClickCancel">
    <div slot="body">
      <div class="expandable-content">
        <v-ons-list class="treatment-record-accordion treatment-record-modal">
          <div id="weight-modal">
            <com-number-display v-if="isInputAfterWeight()" labelName="透析前体重" unitName="kg" :digits="2" v-model="inputModel.weightBefore" />
            <!-- mod FNSI-共有を追加 王 20200921 start -->
            <!-- mod #5589 2023/03/30 数値IFのスタイル全不正 張博 start -->
        <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 start-->
            <!-- <com-number-input :labelName="weightResultLabel" unitName="kg" :step=0.01 :min=0.00 :max=300.00 v-model="inputModel.weightResult" :disabled="!isShared" /> -->
            <com-number-input :labelName="weightResultLabel" unitName="kg" :step=0.01 :inputMin=0.00 :inputMax=300.00 :inputType='"number"' v-model="inputModel.weightResult" :disabled="!getItemAuthorized('TreatmentRecord', 'default_authority')||!isShared" />
        <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 end-->
            <!-- mod #5589 2023/03/30 数値IFのスタイル全不正 張博 end -->
        <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 start-->
            <com-group-button
              labelName="風袋"
              :radioItems="radioItems.unitType"
              v-model="tareUnitCd"
              :nonAuthorize="true"
              :disabled="!isShared"
            />
        <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 end-->
            <!-- mod #5589 2023/03/30 数値IFのスタイル全不正 張博 start -->
            <!-- <com-title-number-input v-for="(tareInfo, index) in inputModel.tareInfos"
              :key="`tareInfo` + index"
              :unitName="tareNumberInputParam.unit"
              :step="tareNumberInputParam.step"
              :min="tareNumberInputParam.min"
              :max="tareNumberInputParam.max"
              :base="tareNumberInputParam.base"
              v-model="inputModel.tareInfos[index]"
              @blur="calcTareSum"
              :disabled="!isShared"
            /> -->
        <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 start-->
             <com-title-number-input v-for="(tareInfo, index) in inputModel.tareInfos"
              :key="`tareInfo` + index"
              :unitName="tareNumberInputParam.unit"
              :step="tareNumberInputParam.step"
              :inputMin="tareNumberInputParam.min"
              :inputMax="tareNumberInputParam.max"
              :base="tareNumberInputParam.base"
              :inputType='"number"'
              v-model="inputModel.tareInfos[index]"
              @blur="calcTareSum"
              :disabled="!getItemAuthorized('TreatmentRecord', 'default_authority')||!isShared"
            />
        <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 end-->
            <!-- mod #5589 2023/03/30 数値IFのスタイル全不正 張博 end -->
            <!-- mod FNSI-共有を追加 王 20200921 end -->
            <hr>
            <com-number-display labelName="風袋合計" :unitName="tareNumberInputParam.unit" :base="tareNumberInputParam.base" :digits="tareNumberInputParam.digits" v-model="inputModel.tareSum" />
            <hr>
            <!-- mod FNSI-共有を追加 王 20200921 start -->
            <!-- mod #5589 2023/03/30 数値IFのスタイル全不正 張博 start -->
        <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 start-->
            <com-master-number-input
              :unitName="'kg'"
              :step="0.01"
              :inputMin="0"
              :inputMax="300.00"
              :base="1000"
              :readMasterData="requestApis.wheelChair"
              :masterDefine="masterDefs.wheelChair"
              :showClassFilter="false"
              v-model="inputModel.wheelChair"
              input-min-width="7em"
              @blur="calcTareSum"
              @changeValue="onChangeValue"
              :disabled="!getItemAuthorized('TreatmentRecord', 'default_authority')||!isShared"
              :themeLable="'車いす：'"
            />
        <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 end-->
            <!-- mod #5589 2023/03/30 数値IFのスタイル全不正 張博 end -->
            <!-- mod FNSI-共有を追加 王 20200921 end -->
            <hr>
            <table class="weight-table">
              <tr>
                <td class="weight-col">
                  <!-- mod FNSI-共有を追加 王 20200921 start -->
                  <!-- mod #5589 2023/03/30 数値IFのスタイル全不正 張博 start -->
                  <!-- <com-number-input v-if="!isInputAfterWeight()" labelName="透析前体重" unitName="kg" :step=0.01 :min=0.00 :max=300.00 :commandButton=weightCalculationButton v-model="inputModel.weightBefore" ref="weightBefore" :disabled="!isShared" /> -->
        <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 start-->
                  <com-number-input v-if="!isInputAfterWeight()" labelName="透析前体重" unitName="kg" :step=0.01 :inputMin=0.00 :inputMax=300.00 :inputType='"number"' :commandButton=weightCalculationButton v-model="inputModel.weightBefore" ref="weightBefore" :disabled="!getItemAuthorized('TreatmentRecord', 'default_authority')||!isShared" />
                  <!-- <com-number-input v-if="isInputAfterWeight()" labelName="透析後体重" unitName="kg" :step=0.01 :min=0.00 :max=300.00 :commandButton=weightCalculationButton v-model="inputModel.weightAfter" ref="weightAfter" :disabled="!isShared" /> -->
                  <com-number-input v-if="isInputAfterWeight()" labelName="透析後体重" unitName="kg" :step=0.01 :inputMin=0.00 :inputMax=300.00 :inputType='"number"' :commandButton=weightCalculationButton v-model="inputModel.weightAfter" ref="weightAfter" :disabled="!getItemAuthorized('TreatmentRecord', 'default_authority')||!isShared" />
        <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 end-->
                  <!-- mod #5589 2023/03/30 数値IFのスタイル全不正 張博 end -->
                  <!-- mod FNSI-共有を追加 王 20200921 end -->
                </td>
              </tr>
            </table>
            <com-number-display v-if="!isInputAfterWeight()" labelName="目標体重" unitName="kg" :digits="2" v-model="inputModel.targetWeight" />
            <!-- mod FNSI-共有を追加 王 20200921 start -->
        <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 start-->
            <com-group-button
              labelName="除水補正"
              :radioItems="radioItems.unitType"
              v-model="offWaterUnitCd"
              :nonAuthorize="true"
              :disabled="!isShared"
            />
        <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 end-->
            <!-- mod #5589 2023/03/30 数値IFのスタイル全不正 張博 start -->
            <!-- <com-title-number-input v-for="(offWaterInfo, index) in inputModel.offWaterInfos"
              :key="`offWaterInfo` + index"
              :unitName="offWaterNumberInputParam.unit"
              :step="offWaterNumberInputParam.step"
              :min="offWaterNumberInputParam.min"
              :max="offWaterNumberInputParam.max"
              :base="offWaterNumberInputParam.base"
              v-model="inputModel.offWaterInfos[index]"
              @blur="calcOffWaterSum"
              :disabled="!isShared"
            /> -->
        <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 start-->
             <com-title-number-input v-for="(offWaterInfo, index) in inputModel.offWaterInfos"
              :key="`offWaterInfo` + index"
              :unitName="offWaterNumberInputParam.unit"
              :step="offWaterNumberInputParam.step"
              :inputMin="offWaterNumberInputParam.min"
              :inputMax="offWaterNumberInputParam.max"
              :base="offWaterNumberInputParam.base"
              :inputType='"number"'
              v-model="inputModel.offWaterInfos[index]"
              @blur="calcOffWaterSum"
              :disabled="!getItemAuthorized('TreatmentRecord', 'default_authority')||!isShared"
            />
        <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 end-->
            <!-- mod #5589 2023/03/30 数値IFのスタイル全不正 張博 end -->
            <!-- mod FNSI-共有を追加 王 20200921 end -->
            <hr>
            <com-number-display labelName="除水補正合計" :unitName="offWaterNumberInputParam.unit" :base="offWaterNumberInputParam.base" :digits="offWaterNumberInputParam.digits" v-model="inputModel.offWaterSum" />
            <hr>
            <table class="weight-table">
              <tr>
                <td class="weight-col">
                  <!-- mod FNSI-共有を追加 王 20200921 start -->
                  <!-- mod #5589 2023/03/30 数値IFのスタイル全不正 張博 start -->
                  <!-- <com-number-input :labelName="targetOffWaterLabel" unitName="L" :step=0.01 :min=0.00 :max=39.90 :commandButton=offWaterCalculationButton v-model="inputModel.targetOffWater" ref="targetOffWater" :disabled="!isShared" /> -->
        <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 start-->
                  <com-number-input :labelName="targetOffWaterLabel" unitName="L" :step=0.01 :inputMin=0.00 :inputMax=39.90 :inputType='"number"' :commandButton=offWaterCalculationButton v-model="inputModel.targetOffWater" ref="targetOffWater" :disabled="!getItemAuthorized('TreatmentRecord', 'default_authority')||!isShared" />
        <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 end-->
                  <!-- mod #5589 2023/03/30 数値IFのスタイル全不正 張博 end -->
                  <!-- mod FNSI-共有を追加 王 20200921 end  -->
                </td>
              </tr>
            </table>
            <com-number-display labelName="除水量制限" unitName="L" :digits="2" v-model="inputModel.offWaterLimit" />
          </div>
        </v-ons-list>
      </div>
    </div>
    <div slot="footer" class="flex-container">
      <!-- mod FNSI修正 画面スタイル(ボタン)対応 房 start -->
      <div class="denial-btn-area" style="background:none">
        <v-ons-button class="button denial-btn btn2-cancel" data-non-authorize="true" @click="onClickCancel">キャンセル</v-ons-button>
      </div>
      <div class="registration-btn-area" style="background:none">
        <!-- mod FNSI-共有を追加 王 20200921 start -->
<!--        mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療記録 20231207 ztc start-->
<!--        <v-ons-button class="button registration-btn btn1-execute" @click="onClickApply" :disabled="!isShared">確定</v-ons-button>-->
        <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 start-->
        <v-ons-button class="button registration-btn btn1-execute" @click="onClickApply" :disabled="!getItemAuthorized('TreatmentRecord', 'default_authority')||!isEditable">確定</v-ons-button>
        <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 end-->
<!--        mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療記録 20231207 ztc end-->
        <!-- mod FNSI-共有を追加 王 20200921 end -->
      </div>
      <!-- mod FNSI修正 画面スタイル(ボタン)対応 房 end -->
    </div>
  </modal-base>
</template>

<script>
import { mapGetters } from "vuex";
import ModalBase from "@/components/modals/ModalBase";
import MultiModalMixin from "@/components/modals/MultiModalMixin";
import CommonNumberInputComponent from "@/components/treatment-record/submenu/common/CommonNumberInputComponent";
import CommonGroupButtonComponent from "@/components/treatment-record/submenu/common/CommonGroupButtonComponent";
import CommonTitleAndNumberInputComponent from "@/components/treatment-record/submenu/common/CommonTitleAndNumberInputComponent";
import CommonMasterAndNumberInputComponent from "@/components/treatment-record/submenu/common/CommonMasterAndNumberInputComponent";
import CommonNumberDisplayComponent from "@/components/treatment-record/submenu/common/CommonNumberDisplayComponent";
import { CODES } from "@/constants/TreatmentRecord";
import { sendRequestGetWheelChair } from "@/apis/treatment-record";
import { wheelChair } from "@/components/common/master-selector/MasterSelectorDefinitions";
import { WeightModal } from "@/models/treatment-record/weight/WeightModal";
import { EventBus } from "@/eventBus.js";
import DiscardConfirmationMixin from "@/components/treatment-record/DiscardConfirmationMixin";
//  add FNSI-修正 権限関連 周雨晴 2020/09/28 start
//#10359 add 編集権限の動作不正 2024-06-05 卓 start
//import ComponentGuardMixin from "@/components/common/ComponentGuardMixin";
//import { AUTHORITY_CODES } from "@/constants/userAuthority";
//  add FNSI-修正 権限関連 周雨晴 2020/09/28 end
import { getAuthorized, isJsonChanged } from "@/functions/common/CommonFunctions";
//#10359 add 編集権限の動作不正 2024-06-05 卓 end

// 風袋の入力制限
const TARE_NUMBER_INPUT_PARAMS = [
  // "g"選択時の条件
  {
    unit: CODES.UNIT_TYPE.GRAM.text,
    base: 1,
    min: -300000,
    max: 300000,
    step: 1,
    digits: 0
  },
  // "kg"選択時の条件
  {
    unit: CODES.UNIT_TYPE.KILO_GRAM.text,
    base: 1000,
    min: -300.0,
    max: 300.0,
    step: 0.001,
    digits: 3
  }
];
// 除水補正の入力制限
const OFFWATER_NUMBER_INPUT_PARAMS = [
  // "g"選択時の条件
  {
    unit: CODES.UNIT_TYPE.GRAM.text,
    base: 1,
    min: -30000,
    max: 30000,
    step: 1,
    digits: 0
  },
  // "kg"選択時の条件
  {
    unit: CODES.UNIT_TYPE.KILO_GRAM.text,
    base: 1000,
    min: -30.0,
    max: 30.0,
    step: 0.001,
    digits: 3
  }
];

export default {
  //  add FNSI-修正 権限関連 周雨晴 2020/09/28 start
//#10359 mod 編集権限の動作不正 2024-06-05 卓 start
  // mixins: [MultiModalMixin, DiscardConfirmationMixin,ComponentGuardMixin],
  mixins: [MultiModalMixin, DiscardConfirmationMixin],
//#10359 mod 編集権限の動作不正 2024-06-05 卓 end
  //  add FNSI-修正 権限関連 周雨晴 2020/09/28 end
  components: {
    "modal-base": ModalBase,
    "com-number-input": CommonNumberInputComponent,
    "com-group-button": CommonGroupButtonComponent,
    "com-title-number-input": CommonTitleAndNumberInputComponent,
    "com-master-number-input": CommonMasterAndNumberInputComponent,
    "com-number-display": CommonNumberDisplayComponent
  },
  data() {
    return {
      inputModel: new WeightModal(),
      initialModel: null,
      radioItems: {
        unitType: CODES.UNIT_TYPE
      },
      masterDefs: {
        wheelChair: wheelChair
      },
      requestApis: {
        wheelChair: sendRequestGetWheelChair
      },
      tareUnitCd: CODES.UNIT_TYPE.GRAM.cd,
      offWaterUnitCd: CODES.UNIT_TYPE.GRAM.cd,
      tareNumberInputParam: TARE_NUMBER_INPUT_PARAMS[CODES.UNIT_TYPE.GRAM.cd],
      offWaterNumberInputParam: OFFWATER_NUMBER_INPUT_PARAMS[CODES.UNIT_TYPE.GRAM.cd],
      weightCalculationButton: {
        name: "計算",
        onClick: () => this.onClickWeightCalculation()
      },
      offWaterCalculationButton: {
        name: "計算",
        onClick: () => this.onClickOffWaterCalculation()
      },
      // add FNSI-修正 権限関連 周雨晴 2020/09/28 start
      //#10359 del 編集権限の動作不正 2024-06-05 卓 start
      // hasTreatmentRecordAuthority: false,
      //#10359 del 編集権限の動作不正 2024-06-05 卓 end
      // add FNSI-修正 権限関連 周雨晴 2020/09/28 end
    };
  },
  watch: {
    tareUnitCd: function(val) {
      this.tareNumberInputParam = TARE_NUMBER_INPUT_PARAMS[val];
    },
    offWaterUnitCd: function(val) {
      this.offWaterNumberInputParam = OFFWATER_NUMBER_INPUT_PARAMS[val];
    },
    /** 透析前体重 入力範囲上下限に補正 */
    "inputModel.weightBefore"(val) {
      this.inputModel.weightBefore = this.clampWeight(val, 0, 300.00);
    },
    /** 透析後体重 入力範囲上下限に補正 */
    "inputModel.weightAfter"(val) {
      this.inputModel.weightAfter = this.clampWeight(val, 0, 300.00);
    },
    /** 目標除水量/実績除水量 入力範囲上下限に補正 */
    "inputModel.targetOffWater"(val) {
      this.inputModel.targetOffWater = this.clampWeight(val, 0, 39.90);
    },
  },
  methods: {
    ...mapGetters("treatment-record/weight", [
      "isInputAfterWeight",
      "getWeightModal"
    ]),
    /**
     * 計算ボタンクリック時ハンドラ（透析前・後体重を計算する）.
     * 計算式：透析前・後体重計算 = 前・後体重測定値 - 風袋合計
     */
    onClickWeightCalculation() {
      this.inputModel.calcWeight(this.isInputAfterWeight());
      this.$nextTick(() => {
        this.$refs[
          !this.isInputAfterWeight() ? "weightBefore" : "weightAfter"
        ].roundValue();
      });
    },
    /**
     * 目標/実績除水量計算.
     * 計算式: 目標/実績除水量 = 透析前体重 - 目標体重/透析後体重 ＋ 除水補正合計
     */
    onClickOffWaterCalculation() {
      this.inputModel.calcOffWater(this.isInputAfterWeight());
      this.$nextTick(() => {
        this.$refs["targetOffWater"].roundValue();
      });
    },
    /**
     * キャンセルボタンクリック時ハンドラ.
     */
    onClickCancel() {
      if (this.isChanged) {
        this.discardConfirm(this.hideModal);
      } else {
        this.hideModal();
      }
    },
    /**
     * 反映ボタンクリック時ハンドラ.
     */
    onClickApply() {
      EventBus.$emit(
        "applyWeightModal",
        this.isInputAfterWeight(),
        this.inputModel,
        this.getDialysisState
      );
      this.hideModal();
    },
    /**
     * 風袋合計計算.
     */
    calcTareSum() {
      // 値の反映を待って計算する.
      this.$nextTick(() => {
        this.inputModel.calcTareSum();
        // this.inputModel.applyTareInfos(this.inputModel.tareInfos);
      });
    },
    /**
     * 除水補正合計計算.
     */
    calcOffWaterSum() {
      // 値の反映を待って計算する.
      this.$nextTick(() => {
        this.inputModel.calcOffWaterSum();
      });
    },
    onChangeValue(value) {
      this.inputModel.wheelChair.value = value;
      this.calcTareSum();
    },
    // add FNSI-修正 権限関連 周雨晴 2020/09/28 start
    //#10359 mod 編集権限の動作不正 2024-06-05 卓 start
    // getTreatmentRecordAuthority() {
    //  return this.hasAuthorityByCd(AUTHORITY_CODES.RST_PEDIT) || this.hasAuthorityByCd(AUTHORITY_CODES.RST_EDIT);
    // },
    // add FNSI-修正 権限関連 周雨晴 2020/09/28 end
    getItemAuthorized(pageCd, itemCd) {
      return getAuthorized(pageCd, itemCd);
    },
    //#10359 mod 編集権限の動作不正 2024-06-05 卓 end
    /** 入力範囲上下限に強制補正 */
    clampWeight(val, min, max) {
      if (val === null || val === "") return val;
      return Math.min(Math.max(val, min), max);
    },
  },
  computed: {
    // add FNSI-共有を追加 王 20200921 start
    ...mapGetters("user", ["getFacilityCd"]),
    ...mapGetters("treatment-record/common", ["getSharedFacilityCd"]),
    ...mapGetters("mst-user", {getSharedFlag: "getIsRegisteredShared"}),
    ...mapGetters("user", {facilityCd: "getFacilityCd"}),
    isShared() {
      return this.getFacilityCd === this.getSharedFacilityCd;
    },
    // add FNSI-共有を追加 王 20200921 end
    weightResultLabel() {
      return this.isInputAfterWeight() ? "後体重測定値" : "前体重測定値";
    },
    targetOffWaterLabel() {
      return this.isInputAfterWeight() ? "実績除水量" : "目標除水量";
    },
    isChanged() {
      // mod #12313 【因島】過去の治療記録-体重で無編集にも関わらず別画面に遷移すると「内容破棄」のメッセージが表示される 関 start
      // return this.initialModel !== JSON.stringify(this.inputModel);
      return isJsonChanged(this.initialModel, JSON.stringify(this.inputModel));
      // mod #12313 【因島】過去の治療記録-体重で無編集にも関わらず別画面に遷移すると「内容破棄」のメッセージが表示される 関 end
    },
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療記録 20231207 ztc start
    isEditable() {
      return !this.isShared || this.isChanged
    }
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療記録 20231207 ztc end
  },
  // add FNSI-共有を追加 王 20200921 start
  mounted() {
    const calBtn = document.getElementsByClassName("button select-btn");
    if (this.getSharedFacilityCd !== undefined && this.getSharedFacilityCd != null) {
      if (this.getSharedFlag === 1 && this.facilityCd !== this.getSharedFacilityCd) {
        for (let i = 0; i < calBtn.length; i++) {
          if (calBtn[i].innerHTML === "計算" || calBtn[i].innerHTML === "選択") {
            calBtn[i].disabled = true ;

          }
        }
      } else {
        for (let i = 0; i < calBtn.length; i++) {
         calBtn[i].disabled = false ;
        }
      }
    } else {
      for (let i = 0; i < calBtn.length; i++) {
      calBtn[i].disabled = false ;
      }
    }
    // add FNSI-修正 権限関連 周雨晴 2020/09/28 start
    //#10359 mod 編集権限の動作不正 2024-06-05 卓 start
    if(!getAuthorized('TreatmentRecord', 'default_authority')) {
          for (let i = 0; i < calBtn.length; i++) {
          if (calBtn[i].innerHTML === "計算" || calBtn[i].innerHTML === "選択") {
            calBtn[i].disabled = true ;
            }

        }
    //#10359 mod 編集権限の動作不正 2024-06-05 卓 end
    }
    // add FNSI-修正 権限関連 周雨晴 2020/09/28 end
  },
  // add FNSI-共有を追加 王 20200921 end
  created() {
    this.inputModel = this.getWeightModal().clone();
    // alert(this.inputModel.tareInfos);
    this.initialModel = JSON.stringify(this.inputModel);
    // add FNSI-修正 権限関連 周雨晴 2020/09/28 start
    //#10359 mod 編集権限の動作不正 2024-06-05 卓 start
    // this.hasTreatmentRecordAuthority = this.getTreatmentRecordAuthority();
    //#10359 mod 編集権限の動作不正 2024-06-05 卓 end
    // add FNSI-修正 権限関連 周雨晴 2020/09/28 end
  }
};
</script>

<style scoped>
#weight-modal >>> .title {
  max-width: unset;
}
.treatment-record-modal {
  margin: 0 25px;
  min-width: fit-content;
}
hr {
  border-width: 1px 0px 0px 0px;
  border-style: solid;
  border-color: #cccccc;
  height: 1px;
}
.k-button {
  width: 4em;
}
.weight-table {
  border-spacing: 0px;
  width: 100%;
}
.weight-col {
  padding: 0px;
}
.treatment-record-modal >>> ons-col.title {
  flex: 0 0 40vw;
}
.treatment-record-modal >>> ons-col.num-value {
  flex: 0 0 7em;
}
.treatment-record-modal >>> .num-value ons-input {
  width: 7em;
}
.treatment-record-modal >>> ons-col.unit {
  margin-left: 4px;
}
</style>
