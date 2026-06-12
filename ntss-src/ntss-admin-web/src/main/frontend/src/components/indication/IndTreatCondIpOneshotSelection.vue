/** * 治療条件ーIPワンショットスタート */

<template>
  <!-- mod 9664補液及び透析液仕様修正します yangqingzhe start -->
    <v-ons-row :class="getIsUseFlagIpOneshotSelection ? 'cell-disabled' : ''">
  <!-- mod 9664補液及び透析液仕様修正します yangqingzhe end -->
    <v-ons-col class="action-condition-column">IPワンショットスタート</v-ons-col>
    <v-ons-col class="action-condition-data-column">
      <custom-radio
        :value="displayInputValue"
        :name="'treatCondIpOneshotSelectionRadio'"
        :disabled="isAntiCoagulantDisabled || !isIpUse || getIsUseFlagIpOneshotSelection || !getItemAuthorized('Indication', 'default_authority')"
        :radio-value="0"
        @change="changeButton()"
      >手動
      </custom-radio>
      <custom-radio
        :value="displayInputValue"
        :name="'treatCondIpOneshotSelectionRadio'"
        :disabled="isAntiCoagulantDisabled || !isIpUse || getIsUseFlagIpOneshotSelection || !getItemAuthorized('Indication', 'default_authority')"
        :radio-value="1"
        @change="changeButton()"
      >自動
      </custom-radio>
    </v-ons-col>
    <div v-if="isOneshotChangeDialogVisible">
      <message-dialog
        v-model:visible="isOneshotChangeDialogVisible"
        :message-cd="22020001"
        type="1"
      />
    </div>
  </v-ons-row>
</template>

<script>
// add #10359 編集権限の動作不正 dengshen start
import { getAuthorized } from "@/functions/common/CommonFunctions.js";
// add #10359 編集権限の動作不正 dengshen end
import { mapGetters } from "@/compat/vue/vuex";
import IndTreatCondBase from "@/components/indication/IndTreatCondBase";
import messageDialog from "@/components/common/message-dialog/MessageDialog";
import {EventBus} from "@/compat/vue/event-bus.js";
export default {
  components: {
    "message-dialog": messageDialog
  },
  mixins: [IndTreatCondBase],

  data() {
    return {
      isOneshotChangeDialogVisible: false
    };
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
  computed: {
    ...mapGetters("pat-viewer-treat-cond", {
      isAntiCoagulantDisabled: "getAntiCoagulantDisabled",
      isIpUse: "isIpUse",
      // add 8204 周安寧 start
      getIsUseFlagIpOneshotSelection: "getIsUseFlagIpOneshotSelection"
      // add 8204 周安寧 end
    })
  },

  watch: {
    isIpUse() {
      if (!this.isIpUse && this.displayInputValue.editValue == 1) {
        // IP使用選択が「使用しない」の場合、「手動」に切り替え
        this.displayInputValue.editValue = 0;
        this.isOneshotChangeDialogVisible = true;
      }
    }
  },
  //8204 zhou 【デグレ】治療条件モーダルにて、使用しない項目を設定できてしまう add start
  created(){
    if (this.isIndication) {
      // #9973 Mod by Zhou.tao Start
      this.displayInputValue.editValue = this.velue === null ? null : this.velue == 0 ? 0 : 1
      this.displayInputValue.initValue = this.value === null ? null : this.value == 0 ? 0 : 1
      // #9973 Mod by Zhou.tao End
    }
  },
  //8204 zhou 【デグレ】治療条件モーダルにて、使用しない項目を設定できてしまう add end
  mounted() {
    this.treatItemCd = "34";
  }
};
</script>
