/** * 治療条件ーIP使用選択 */

<template>
  <!-- mod 9664補液及び透析液仕様修正します yangqingzhe start -->
  <!-- <v-ons-row> -->
    <v-ons-row :class="getIsUseFlagIpSelection ? 'cell-disabled' : ''">
  <!-- mod 9664補液及び透析液仕様修正します yangqingzhe end -->
    <v-ons-col class="action-condition-column">IP使用選択</v-ons-col>
    <v-ons-col class="action-condition-data-column">
      <!-- mod 8204 周安寧 start -->
      <!-- <custom-radio
        :value="displayInputValue"
        :name="'treatCondIpSelectionRadio'"
        :disabled="getAntiCoagulantDisabled"
        :radio-value="1"
        @change="setIpUse(isIpUse),changeButton()"
      >使用する
      </custom-radio>
      <custom-radio
        :value="displayInputValue"
        :name="'treatCondIpSelectionRadio'"
        :disabled="getAntiCoagulantDisabled"
        :radio-value="0"
        @change="setIpUse(isIpUse),changeButton()"
      >使用しない
      </custom-radio> -->
      <!-- mod #10359 編集権限の動作不正 dengshen start -->
      <!-- <custom-radio -->
      <!--   :value="displayInputValue" -->
      <!--   :name="'treatCondIpSelectionRadio'" -->
      <!--   :disabled="getAntiCoagulantDisabled || getIsUseFlagIpSelection" -->
      <!--   :radio-value="1" -->
      <!--   @change="setIpUse(isIpUse),changeButton()" -->
      <!-- >使用する -->
      <custom-radio
        :value="displayInputValue"
        :name="'treatCondIpSelectionRadio'"
        :disabled="getAntiCoagulantDisabled || getIsUseFlagIpSelection || !getItemAuthorized('Indication', 'default_authority')"
        :radio-value="1"
        @change="setIpUse(isIpUse),changeButton()"
      >使用する
      <!-- mod #10359 編集権限の動作不正 dengshen end -->
      </custom-radio>
      <!-- mod #10359 編集権限の動作不正 dengshen start -->
      <!-- <custom-radio -->
      <!--   :value="displayInputValue" -->
      <!--   :name="'treatCondIpSelectionRadio'" -->
      <!--   :disabled="getAntiCoagulantDisabled || getIsUseFlagIpSelection" -->
      <!--   :radio-value="0" -->
      <!--   @change="setIpUse(isIpUse),changeButton()" -->
      <!-- >使用しない -->
      <custom-radio
        :value="displayInputValue"
        :name="'treatCondIpSelectionRadio'"
        :disabled="getAntiCoagulantDisabled || getIsUseFlagIpSelection || !getItemAuthorized('Indication', 'default_authority')"
        :radio-value="0"
        @change="setIpUse(isIpUse),changeButton()"
      >使用しない
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
    // mod 8204 周安寧 start
    //...mapGetters("pat-viewer-treat-cond", ["getAntiCoagulantDisabled"]),
    ...mapGetters("pat-viewer-treat-cond", ["getAntiCoagulantDisabled", "getIsUseFlagIpSelection"]),
    // mod 8204 周安寧 end
    /**
     * @description IP使用フラグ
     * @returns {Boolean} 使用する: true, 使用しない: false
     */
    isIpUse() {
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
    this.treatItemCd = "29";
    // 初期表示時にストアのIP使用フラグを現在の値に応じて書き換える
    this.setIpUse(this.isIpUse);
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
    ...mapMutations("pat-viewer-treat-cond", ["setIpUse"])
  }
};
</script>
