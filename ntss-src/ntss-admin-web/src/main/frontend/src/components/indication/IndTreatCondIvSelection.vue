/** * 治療条件ー補液選択 */

<template>
  <!-- mod 9664補液及び透析液仕様修正します yangqingzhe start -->
  <!-- <v-ons-row> -->
    <v-ons-row :class="getIsUseFlagIvSelection ? 'cell-disabled' : ''">
  <!-- mod 9664補液及び透析液仕様修正します yangqingzhe end -->
    <v-ons-col class="action-condition-column">補液選択</v-ons-col>
    <v-ons-col class="action-condition-data-column">
      <!--mod FNSI-【1006】最新の改修対象一覧の412対応 韓 start-->
      <!--<custom-radio
        :value="displayInputValue"
        :name="'treatCondIvSelectionRadio'"
        :disabled="isDisabled || isDisabledFromTreatMethod"
        :radio-value="1"
      >前補液
      </custom-radio>
      <custom-radio
        :value="displayInputValue"
        :name="'treatCondIvSelectionRadio'"
        :disabled="isDisabled || isDisabledFromTreatMethod"
        :radio-value="0"
      >後補液
      </custom-radio>-->
      <!-- mod #10359 編集権限の動作不正 dengshen start -->
      <!-- <custom-radio -->
      <!--   :value="displayInputValue" -->
      <!--   :name="'treatCondIvSelectionRadio'" -->
      <!--   :disabled="isDisabled || isDisabledFromTreatMethod" -->
      <!--   :radio-value="1" -->
      <!--   @change="setLiquidSelection(Number(displayInputValue.editValue)),changeButton()" -->
      <!-- >前補液 -->
      <custom-radio
        :value="displayInputValue"
        :name="'treatCondIvSelectionRadio'"
        :disabled="isDisabled || isDisabledFromTreatMethod || !getItemAuthorized('Indication', 'default_authority')"
        :radio-value="1"
        @change="setLiquidSelection(Number(displayInputValue.editValue)),changeButton()"
      >前補液
      <!-- mod #10359 編集権限の動作不正 dengshen end -->
      </custom-radio>
      <!-- mod #10359 編集権限の動作不正 dengshen start -->
      <!-- <custom-radio -->
      <!--   :value="displayInputValue" -->
      <!--   :name="'treatCondIvSelectionRadio'" -->
      <!--   :disabled="isDisabled || isDisabledFromTreatMethod" -->
      <!--   :radio-value="0" -->
      <!--   @change="setLiquidSelection(Number(displayInputValue.editValue)),changeButton()" -->
      <!-- >後補液 -->
      <custom-radio
        :value="displayInputValue"
        :name="'treatCondIvSelectionRadio'"
        :disabled="isDisabled || isDisabledFromTreatMethod || !getItemAuthorized('Indication', 'default_authority')"
        :radio-value="0"
        @change="setLiquidSelection(Number(displayInputValue.editValue)),changeButton()"
      >後補液
      <!-- mod #10359 編集権限の動作不正 dengshen end -->
      </custom-radio>
      <!--add FNSI-【1006】最新の改修対象一覧の412対応 韓 end-->
    </v-ons-col>
  </v-ons-row>
</template>

<script>
// add #10359 編集権限の動作不正 dengshen start
import { getAuthorized } from "@/functions/common/CommonFunctions.js";
// add #10359 編集権限の動作不正 dengshen end
// mod FNSI-【1006】最新の改修対象一覧の412対応 韓 start
// import { mapGetters } from "@/compat/vue/vuex";
   import { mapGetters, mapMutations } from "@/compat/vue/vuex";
// mod FNSI-【1006】最新の改修対象一覧の412対応 韓 end
import IndTreatCondBase from "@/components/indication/IndTreatCondBase";
import {EventBus} from "@/compat/vue/event-bus.js";
export default {
  mixins: [IndTreatCondBase],

  computed: {
    ...mapGetters("pat-viewer-treat-cond", {
      isDisabled: "getIvDisabled",
      deviceMode: "getDeviceMode",
      // add 8204 周安寧 start
      getIsUseFlagIvSelection:"getIsUseFlagIvSelection"
      // add 8204 周安寧 end
    }),

    isDisabledFromTreatMethod() {
      // mod 8204 周安寧 start
      //return this.deviceMode === 10; //I-HDF
      // mod 9664補液及び透析液仕様修正します yangqingzhe start
      // return this.deviceMode === 10 || this.getIsUseFlagIvSelection; //I-HDF
      return (this.deviceMode === 0 || //HD
        this.deviceMode === 1 || //ECUM
        this.getIsUseFlagIvSelection

      );
      // mod 9664補液及び透析液仕様修正します yangqingzhe end
      // mod 8204 周安寧 end
    }
  },
  //8204 zhou 【デグレ】治療条件モーダルにて、使用しない項目を設定できてしまう add start
  created(){
    if (this.isIndication) {
      // #9973 Mod by Zhou.tao change the type of value. Start
      // this.displayInputValue.editValue = this.velue === null ? null : this.velue === 0 ? 0 : 1
      // this.displayInputValue.initValue = this.value === null ? null : this.value === 0 ? 0 : 1
      this.displayInputValue.editValue = this.velue === null ? null : this.velue == 0 ? 0 : 1;
      this.displayInputValue.initValue = this.value === null ? null : this.value == 0 ? 0 : 1;
      // #9973 Mod by Zhou.tao change the type of value. Start
    }
  },
  //8204 zhou 【デグレ】治療条件モーダルにて、使用しない項目を設定できてしまう add end
  mounted() {
    this.treatItemCd = "21";
  },
// add FNSI-【1006】最新の改修対象一覧の412対応 韓 start
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
    ...mapMutations("pat-viewer-treat-cond", ["setLiquidSelection"])
  }
// add FNSI-【1006】最新の改修対象一覧の412対応 韓 end
};
</script>

<style scoped>
.cell-disabled {
  background-color: var(--pat-viewer-ind-cond-info-disabled);
}
</style>
