/**
 * マスタ編集（愁訴処置マスタ）の愁訴マスタ編集モーダル
 */
<template>
  <modal-base @onClose="cancel">
        <template #body>
<div>
      <div class="expandable-content">
        <v-ons-row class="col-width">
          <v-ons-col width="30%">
            <label>愁訴</label>
          </v-ons-col>
          <v-ons-col>
            <input
              class="name-style"
              v-model="actualModel.name"
              type="text"
              ref="name"
              maxlength="256"
            />
          </v-ons-col>
        </v-ons-row>
        <v-ons-row class="col-width">
          <v-ons-col width="30%">
            <label>連携コード1</label>
          </v-ons-col>
          <v-ons-col>
            <input
              class="inhosp-style"
              v-model="actualModel.inHospitalCd1"
              type="text"
              ref="inhospitalCd1"
              maxlength="20"
            />
          </v-ons-col>
        </v-ons-row>
        <v-ons-row class="col-width">
          <v-ons-col width="30%">
            <label>連携コード2</label>
          </v-ons-col>
          <v-ons-col>
            <input
              class="inhosp-style"
              v-model="actualModel.inHospitalCd2"
              type="text"
              ref="inhospitalCd2"
              maxlength="20"
            />
          </v-ons-col>
        </v-ons-row>
      </div>
    </div>
    </template>
        <template #footer>
<div class="flex-container">
      <div class="denial-btn-area" style="background:none">
        <v-ons-button class="button btn2-cancel denial-btn" @click="cancel">
          キャンセル
        </v-ons-button>
      </div>
      <div class="registration-btn-area" style="background:none">
        <v-ons-button
          :disabled="!isChanged"
          class="button registration-btn common-style-select-button"
          @click="reflect"
        >
          確定
        </v-ons-button>
      </div>
    </div>
    </template>
  </modal-base>
</template>

<script>
import { mapGetters, mapActions } from "@/compat/vue/vuex";
import ModalBase from "@/components/modals/ModalBase";
import MultiModalMixin from "@/components/modals/MultiModalMixin";
import { MstComplaint } from "@/models/master-maintenance/mst-complaint/MstComplaint";
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
import { replaceNullWithEmptyString } from "@/utils/util.js";

export default {
  mixins: [MultiModalMixin],
  components: {
    "modal-base": ModalBase
  },
  data() {
    return {
      actualModel: new MstComplaint(),
      comparisonModel: {}
    };
  },
  methods: {
    ...mapGetters("mst-complaint", ["getMstComplaintEdit"]),
    ...mapActions("mst-complaint", ["setMstComplaintEdit"]),
    /**
     * 初期処理
     */
    init() {
      // 編集対象のモデルをストアより取得
      this.comparisonModel = this.getMstComplaintEdit();
      this.actualModel = new MstComplaint();
      Object.assign(this.actualModel, this.comparisonModel);
    },
    /**
     * キャンセルボタン押下時イベント処理
     */
    cancel() {
      if (this.isChanged) {
        this.$ons.notification.confirm({
          // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
            // title: "内容破棄",
            title: DIALOG_MESSAGES[13000004].title,
            // message: "編集内容が破棄されます。</br>よろしいですか？",
            message: messageFormat(DIALOG_MESSAGES[13000004].message),
            // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
          callback: answer => {
            if (answer === 1) {
              this.hideModal();
            }
          }
        });
        return;
      }
      this.hideModal();
    },
    /**
     * 確定ボタン押下時イベント処理
     */
    reflect() {
      // 入力した内容を反映
      if (this.isChanged) {
        // 修正ありにする
        this.actualModel.updated();
        Object.assign(this.comparisonModel, this.actualModel);
      }
      this.hideModal();
    }
  },
  computed: {
    /**
     * 編集中フラグ.
     */
    isChanged() {
      if (
        replaceNullWithEmptyString(this.actualModel.name) != replaceNullWithEmptyString(this.comparisonModel.name) ||
        replaceNullWithEmptyString(this.actualModel.inHospitalCd1) != replaceNullWithEmptyString(this.comparisonModel.inHospitalCd1) ||
        replaceNullWithEmptyString(this.actualModel.inHospitalCd2) != replaceNullWithEmptyString(this.comparisonModel.inHospitalCd2)
        ) {
        return true;
      }
      return false;
    }
  },
  async created() {
    await this.init();
  }
}
</script>

<style scoped>
.expandable-content {
  background-color: inherit;
  background-image: none;
  font-family: inherit;
  padding: 1em;
}
.expandable-content :deep(ons-row) {
  margin-top: 5px;
}
.name-style {
  width: 100%;
}
.inhosp-style {
  font-size: 1em;
}
.col-width {
  width: 50%
}
</style>
