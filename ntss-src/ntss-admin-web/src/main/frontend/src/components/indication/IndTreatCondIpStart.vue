/** * 治療条件ーIPスタート */

<template>
  <!-- mod 9664補液及び透析液仕様修正します yangqingzhe start -->
  <!-- <v-ons-row> -->
    <v-ons-row :class="getIsUseFlagIpStart ? 'cell-disabled' : ''">
  <!-- mod 9664補液及び透析液仕様修正します yangqingzhe end -->
    <v-ons-col class="action-condition-column">IPスタート</v-ons-col>
    <v-ons-col class="action-condition-data-column">
      <!-- mod 8204 周安寧 start -->
      <!-- <custom-radio
        :value="displayInputValue"
        :name="'treatCondIpStartRadio'"
        :disabled="isAntiCoagulantDisabled || !isIpUse"
        :radio-value="0"
        @change="changeButton()"
      >手動
      </custom-radio>
      <custom-radio
        :value="displayInputValue"
        :name="'treatCondIpStartRadio'"
        :disabled="isAntiCoagulantDisabled || !isIpUse"
        :radio-value="1"
        @change="changeButton()"
      >自動
      </custom-radio> -->
      <!-- mod #10359 編集権限の動作不正 dengshen start -->
      <!-- <custom-radio -->
      <!--   :value="displayInputValue" -->
      <!--   :name="'treatCondIpStartRadio'" -->
      <!--   :disabled="isAntiCoagulantDisabled || !isIpUse || getIsUseFlagIpStart" -->
      <!--   :radio-value="0" -->
      <!--   @change="changeButton()" -->
      <!-- >手動 -->
      <custom-radio
        :value="displayInputValue"
        :name="'treatCondIpStartRadio'"
        :disabled="isAntiCoagulantDisabled || !isIpUse || getIsUseFlagIpStart || !getItemAuthorized('Indication', 'default_authority')"
        :radio-value="0"
        @change="changeButton()"
      >手動
      <!-- mod #10359 編集権限の動作不正 dengshen end -->
      </custom-radio>
      <!-- mod #10359 編集権限の動作不正 dengshen start -->
      <!-- <custom-radio -->
      <!--   :value="displayInputValue" -->
      <!--   :name="'treatCondIpStartRadio'" -->
      <!--   :disabled="isAntiCoagulantDisabled || !isIpUse || getIsUseFlagIpStart" -->
      <!--   :radio-value="1" -->
      <!--   @change="changeButton()" -->
      <!-- >自動 -->
      <custom-radio
        :value="displayInputValue"
        :name="'treatCondIpStartRadio'"
        :disabled="isAntiCoagulantDisabled || !isIpUse || getIsUseFlagIpStart || !getItemAuthorized('Indication', 'default_authority')"
        :radio-value="1"
        @change="changeButton()"
      >自動
      <!-- mod #10359 編集権限の動作不正 dengshen end -->
      </custom-radio>
      <!-- mod 8204 周安寧 end -->
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

  computed: {
    ...mapGetters("pat-viewer-treat-cond", {
      isAntiCoagulantDisabled: "getAntiCoagulantDisabled",
      isIpUse: "isIpUse",
      // add 8204 周安寧 start
      getIsUseFlagIpStart: "getIsUseFlagIpStart"
      // add 8204 周安寧 end
    })
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
    }
  },
  //8204 zhou 【デグレ】治療条件モーダルにて、使用しない項目を設定できてしまう add start
  created(){
    if (this.isIndication) {
      this.displayInputValue.editValue = this.velue == 0 ? 0 : 1
      this.displayInputValue.initValue = this.value == 0 ? 0 : 1
    }
  },
  //8204 zhou 【デグレ】治療条件モーダルにて、使用しない項目を設定できてしまう add end
  mounted() {
    this.treatItemCd = "30";
  }
};
</script>
