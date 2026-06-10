/**
 * マルチカレンダー
 */
<template>
  <modal-base @onClose="cancel" class="custom-modal">
    <div slot='body' style="height: 100%">
      <v-ons-select name="report-list" class="select-content-style" size="100%" v-model="selectedReportCd">
        <option 
          v-for="(report, index) in reportList" :key="index"
          :value="report.reportCd" 
        >{{report.reportName}}</option>
      </v-ons-select>
    </div>
    <div slot="footer" class="flex-container">
      <div class="denial-btn-area" style="background:none">
        <v-ons-button class="button denial-btn" @click="cancel">キャンセル</v-ons-button>
      </div>
      <div class="registration-btn-area" style="background:none">
        <v-ons-button class="button registration-btn" @click="registration" >確定</v-ons-button>
      </div>
    </div>
  </modal-base>
</template>

<script>
import ModalBase from "@/components/modals/ModalBase";
import MultiModalMixin from "@/components/modals/MultiModalMixin";
import { mapActions, mapGetters } from "vuex";

export default {
  name: "report-list",
  mixins: [MultiModalMixin],
  components: {
    "modal-base": ModalBase
  },
  data() {
    return {
      selectedReportCd: null
    };
  },
  computed: {
    ...mapGetters("introduction-letter", {
      reportList: "getReportList",
      reportCd: "getReportCd"
    }),
    ...mapGetters("pat-event/detail", [
      "getPatEventRecord"
    ]),
  },
  methods: {
    ...mapActions("introduction-letter", [
      "setTemplate"
    ]),
    ...mapActions("loading-screen", ["setLoadingScreenVisible"]),
    /**
     * キャンセル処理
     */
    cancel() {
      this.close();
    },
    /**
     * 確定処理
     */
    async registration() {
      if (this.selectedReportCd) {
        this.setLoadingScreenVisible(true);
        await this.setTemplate({
          patId: this.getPatEventRecord.patId,
          reportCd: this.selectedReportCd
        });
        this.setLoadingScreenVisible(false);
      }
      this.close();
    },
    /**
     * ダイアログを閉じる
     */
    close(){
      this.hideModal();
    }
  }
};
</script>

<style scoped>
.modal-container {
  width: 600px;
  height: 400px;
}
.select-content-style {
  width: 100%;
  height: 100%;
  background-color: var(--ntss-list-background-color);
  color: var(--ntss-list-body-color);
}
ons-select.select-content-style >>> .select-input {
  height: 100% !important;
  font-size: 13.3333px;
}
</style>