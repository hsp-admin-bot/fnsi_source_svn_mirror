<template>
  <div id="indication-main">
    <router-view v-if="!isLoading"></router-view>

    <!-- Loading -->
    <!-- FNSI6729-ローダーが他の画面と異なる 周 del start
    <v-ons-modal :visible="isLoading">
      <p class="loading-modal">
        処理中
        <v-ons-icon icon="fa-spinner" spin />
      </p>
    </v-ons-modal>
    FNSI6729-ローダーが他の画面と異なる 周 del end -->
    <!-- / Loading -->
  </div>
</template>

<script>
import { mapActions, mapGetters, mapMutations } from "@/compat/vue/vuex";
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end

export default {
  name: "IndicationMainView",
  data() {
    return {
      isLoading: true
    };
  },
  computed: {
    ...mapGetters("indication", ["isTreatmentUnit"])
  },
  methods: {
    ...mapActions("indication", [
      "checkFacilitySetting",
      "getUserInfo",
      "getMst",
      "checkIsDoctor",
      "clearState"
    ]),
    ...mapActions("treatment-record/common", ["setOrdNoForSideBarRecord"]),
    // FNSI6729-ローダーが他の画面と異なる 周 add start
    ...mapActions("loading-screen", ["setLoadingScreenVisible", "setLoadingScreenMessage"]),
    // FNSI6729-ローダーが他の画面と異なる 周 add end
    ...mapMutations("pat-info", ["setSrcFuncName"])
  },
  async created() {
    // FNSI6729-ローダーが他の画面と異なる 周 add start
    this.setLoadingScreenMessage("処理中・・・");
    this.setLoadingScreenVisible(true);
    // FNSI6729-ローダーが他の画面と異なる 周 add end
    try {
      await Promise.all([
        this.checkFacilitySetting(),
        this.getUserInfo(),
        this.getMst(),
        this.checkIsDoctor()
      ]);

      if (this.isTreatmentUnit === null) {
        // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
        // this.$ons.notification.alert("施設マスタにて施設単位の設定が必要です。", {
        //   title: "エラー"
        // });
        this.$ons.notification.alert(messageFormat(DIALOG_MESSAGES[12000287].message)  , {
          title: DIALOG_MESSAGES[12000287].title
        });
        // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
      }
    } finally {
      this.isLoading = false;

      // FNSI6729-ローダーが他の画面と異なる 周 add start
      this.setLoadingScreenVisible(false);
      // FNSI6729-ローダーが他の画面と異なる 周 add end
    }
  },
  beforeUnmount() {
    // 自画面で開始した共通ローダーを、遷移時にも Vue2 の画面破棄と同じく閉じる。
    this.setLoadingScreenVisible(false);
    this.clearState();
    this.setSrcFuncName("");
    this.setOrdNoForSideBarRecord(null);
  }
};
</script>

<style scoped>
.loading-modal {
  font-size: 2.4em;
}
</style>
