/** * 治療条件ーIP電源自動切り */

<template>
  <!-- mod 9664補液及び透析液仕様修正します yangqingzhe start -->
  <!-- <v-ons-row> -->
    <v-ons-row :class="getIsUseFlagIpAutoOff ? 'cell-disabled' : ''">
  <!-- mod 9664補液及び透析液仕様修正します yangqingzhe end -->
    <v-ons-col class="action-condition-column">IP電源自動切り</v-ons-col>
    <v-ons-col class="action-condition-data-column">
      <!-- mod 8204 周安寧 start -->
      <!-- <custom-radio
        :value="displayInputValue"
        :name="'treatCondIpAutoOffRadio'"
        :disabled="isAntiCoagulantDisabled || !isIpUse"
        :radio-value="0"
        @change="setIpAutoOff(isAutoOff),changeButton()"
      >切
      </custom-radio>
      <custom-radio
        :value="displayInputValue"
        :name="'treatCondIpAutoOffRadio'"
        :disabled="isAntiCoagulantDisabled || !isIpUse"
        :radio-value="1"
        @change="setIpAutoOff(isAutoOff),changeButton()"
      >入
      </custom-radio> -->
      <!-- mod #10359 編集権限の動作不正 dengshen start -->
      <!-- <custom-radio -->
      <!--   :value="displayInputValue" -->
      <!--   :name="'treatCondIpAutoOffRadio'" -->
      <!--   :disabled="isAntiCoagulantDisabled || !isIpUse || getIsUseFlagIpAutoOff" -->
      <!--   :radio-value="0" -->
      <!--   @change="setIpAutoOff(isAutoOff),changeButton()" -->
      <!-- >切 -->
      <custom-radio
        :value="displayInputValue"
        :name="'treatCondIpAutoOffRadio'"
        :disabled="isAntiCoagulantDisabled || !isIpUse || getIsUseFlagIpAutoOff || !getItemAuthorized('Indication', 'default_authority')"
        :radio-value="0"
        @change="setIpAutoOff(isAutoOff),changeButton()"
      >切
      <!-- mod #10359 編集権限の動作不正 dengshen end -->
      </custom-radio>
      <!-- mod #10359 編集権限の動作不正 dengshen start -->
      <!-- <custom-radio -->
      <!--   :value="displayInputValue" -->
      <!--   :name="'treatCondIpAutoOffRadio'" -->
      <!--   :disabled="isAntiCoagulantDisabled || !isIpUse || getIsUseFlagIpAutoOff" -->
      <!--   :radio-value="1" -->
      <!--   @change="setIpAutoOff(isAutoOff),changeButton()" -->
      <!-- >入 -->
      <custom-radio
        :value="displayInputValue"
        :name="'treatCondIpAutoOffRadio'"
        :disabled="isAntiCoagulantDisabled || !isIpUse || getIsUseFlagIpAutoOff || !getItemAuthorized('Indication', 'default_authority')"
        :radio-value="1"
        @change="setIpAutoOff(isAutoOff),changeButton()"
      >入
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
import { mapGetters, mapMutations } from "@/compat/vue/vuex";
import IndTreatCondBase from "@/components/indication/IndTreatCondBase";
import {EventBus} from "@/compat/vue/event-bus.js";
export default {
  mixins: [IndTreatCondBase],

  computed: {
    ...mapGetters("pat-viewer-treat-cond", {
      isAntiCoagulantDisabled: "getAntiCoagulantDisabled",
      isIpUse: "isIpUse",
      // add 8204 周安寧 start
      getIsUseFlagIpAutoOff: "getIsUseFlagIpAutoOff"
      // add 8204 周安寧 end
    }),

    /**
     * @description IP電源自動切りフラグ
     * @returns {Boolean} 入: true, 切: false
     */
    isAutoOff() {
      return this.displayInputValue.editValue == 1;
    }
  },
  //8204 zhou 【デグレ】治療条件モーダルにて、使用しない項目を設定できてしまう add start
  created(){
    if (this.isIndication) {
      this.displayInputValue.editValue = this.velue === null ? null : this.velue == 0 ? 0 : 1
      this.displayInputValue.initValue = this.value === null ? null : this.value == 0 ? 0 : 1 
    }
  },
  //8204 zhou 【デグレ】治療条件モーダルにて、使用しない項目を設定できてしまう add end
  mounted() {
    this.treatItemCd = "35";
    // 初期表示時にストアのIP電源自動切りフラグを現在の値に応じて書き換える
    this.setIpAutoOff(this.isAutoOff);
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
    ...mapMutations("pat-viewer-treat-cond", ["setIpAutoOff"])
  }
};
</script>
