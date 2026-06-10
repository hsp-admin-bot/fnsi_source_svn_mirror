/** * 指示・実績DW */

<template>
  <div class="column-style">
    <v-ons-row>
      <v-ons-col class="action-condition-column">DW</v-ons-col>
      <v-ons-col class="action-condition-data-column">
        <custom-input-number
          :value="displayInputValue"
          :digits="5"
          :decimal-digits="2"
          :min-value="0.0"
          :max-value="300.00"
          class="action-condition-input"
        />
        <label>kg</label>
      </v-ons-col>
    </v-ons-row>
  </div>
</template>

<script>
// eslint-disable-next-line no-unused-vars
import { ApiHelper } from "@/apis/AxiosHelper";
import customInputNumber from "@/components/common/custom-form-tags/CustomInputNumber";
import {mapActions, mapGetters} from "vuex";
//FNSI-修正 VUEのエラー場合のログ対応 liuimx add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 liuimx add end
export default {
  components: {
    "custom-input-number": customInputNumber
  },
  props: {
    componentNames: {
      type: Array,
      default: () => [{ name: "ind-dw", fields: null }]
    },
    /**
     * @description オーダ番号
     */
    ordNo: {
      type: Number,
      default: null
    }
  },
  data() {
    return {
      displayInputValue: {
        initValue: this.componentNames[0].fields,
        editValue: this.componentNames[0].fields
      }
    };
  },
  computed: {
    ...mapGetters("pat-viewer", ["getTreatmentData"]),
    ...mapGetters("pat-viewer-modal", ["getSettingIndChildData"])
  },
  methods: {
    ...mapActions('loading-screen', [
      "startLoadingScreen",
      "finishLoadingScreen"
    ]),
    /**
     * 変更チェック
     * @description 指示コメントの編集内容に応じてメッセージを出す
     * @param num 0->保存ボタンクリック時 1->キャンセルボタンクリック時
     * @return showMessage trueを返した場合呼び出し元で処理を終了する
     */
    checkEdit(num) {
      // メッセージ表示、非表示切り替え
      let showMessage = false;
      // メッセージコード
      let messageCd = null;
      // メッセージタイプ
      let messageType = null;
      // 初期値と編集値に相違無し
      if (
        this.displayInputValue.initValue === this.displayInputValue.editValue
      ) {
        // 保存時チェックならメッセージ表示
        if (0 === num) {
          // データセルクリック時以外は以下の処理は行わない
          if (
            !this.$parent.$parent.settingData.startDateEdit ||
            !this.$parent.$parent.settingData.endDateEdit
          ) {
            return;
          }
          showMessage = true;
          messageCd = 20010003;
          messageType = "1";
        }
      } else {
        // キャンセル時チェックならメッセージ表示
        if (1 === num) {
          showMessage = true;
          messageCd = 20010001;
          messageType = "2";
        }
      }
      this.$parent.$parent.messageDialogInfo.messageCd = messageCd;
      this.$parent.$parent.messageDialogInfo.type = messageType;
      this.$parent.$parent.messageDialogInfo.isDialogVisible = showMessage;
      return showMessage;
    },

    /**
     * データの更新
     */
    async updateIndInfo() {
      console.log("indRstDw.vue updateIndInfo this.startLoadingScreen();");
      this.startLoadingScreen();
      // 保存時編集チェック
      if (this.checkEdit(0)) {
        console.log("indRstDw.vue updateIndInfo return; this.finishLoadingScreen();");
        this.finishLoadingScreen();
        // 処理終了
        return;
      }

      let stringParam = null;

      if (!this.displayInputValue.editValue) {
        stringParam = "DW";
      }

      if (stringParam) {
        this.$parent.$parent.messageDialogInfo.messageCd = 22010001;
        this.$parent.$parent.messageDialogInfo.type = "1";
        this.$parent.$parent.messageDialogInfo.stringParams = [stringParam];
        this.$parent.$parent.messageDialogInfo.isDialogVisible = true;
        console.log("indRstDw.vue updateIndInfo return; this.finishLoadingScreen();");
        this.finishLoadingScreen();
        return;
      }

      const sendJson = {};
      // オーダ番号
      sendJson.ord_no = this.ordNo;
      // DW
      sendJson.dw = this.displayInputValue.editValue;

      //データの送信
      await ApiHelper.put("/mainData/updateIndRstDw/", sendJson).catch(
        error => {
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
          getErrorMessage('indRstDw.vue', 'updateIndInfo', error);
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
          console.log("indRstDw.vue updateIndInfo throw error; this.finishLoadingScreen();");
          this.finishLoadingScreen();
          throw error;
        }
      );
      console.log("indRstDw.vue updateIndInfo hide-modal this.finishLoadingScreen();");
      this.finishLoadingScreen();
      // モーダルを閉じる
      this.$parent.$parent.$emit("hide-modal");
    }
  }
};
</script>
<style scoped>
.column-style {
  border: 1px solid var(--ntss-border-color);
  height: 100%;
  width: 100%;
  overflow-y: auto;
  overflow-x: hidden;
  box-sizing: border-box;
}
/* アクションチャート内inputタグ */
.action-condition-input {
  width: 138px;
  margin: 0px 5px 0px 0px;
}

.action-condition-column {
  flex: 0 0 30%;
  max-width: 30%;
  white-space: normal;
  margin: auto;
}

.action-condition-input-label {
  width: 100px;
  font-size: 15px;
}

.action-condition-data-column {
  margin: auto;
  padding-left: 10px;
  margin-right: 5px;
}

.action-condition-calculate-button {
  width: 25px;
  margin: 0px 0px 0px 5px;
  font-size: 11px;
  padding: 0px;
}

ons-row {
  border: 1px solid var(--ntss-border-color);
  padding: 10px;
}
</style>
