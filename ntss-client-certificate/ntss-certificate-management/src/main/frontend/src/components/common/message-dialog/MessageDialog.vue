<template>
  <v-ons-alert-dialog
    :visible="visible"
    modifier="rowfooter"
    :footer="footerButton"
  >
    <!-- メッセージに改行(brタグ)が含まれる場合はHTML文字列として出力 -->
    <p v-if="includesNewLine" v-html="message"></p>
    <p v-else>{{ message }}</p>
  </v-ons-alert-dialog>
</template>

<script>
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages.js";

// ダイアログタイプ定数
const TYPE_OK = "1";
const TYPE_OK_CANCEL = "2";
const TYPE_YES_NO_CANCEL = "3";
const TYPE_YES_NO = "4";
const TYPE_SAVE_EXPAND = "5";
/**
 * @description メッセージダイアログコンポーネント
 * @summary
 *   -指定されたメッセージコードとタイプに応じたダイアログを表示する。
 *      メッセージコード: "DialogMessages.js"で定義されたメッセージのコード
 *      タイプ: 1:「OK」、2:「OK/Cancel」、3:「Yes/No/Cancel」
 *   -メッセージ内に"{$n}"(nは整数)を記述すると、props.stringParamsに
 *    渡した文字列配列の要素で置換する。
 *   -返答すると、"confirm"イベントを発火する。イベントハンドラには
 *    返答に応じた文字列('OK'/'Cancel'/'Yes'/'No')が渡される。
 *
 * @example
 *   <button @click="isDialogVisible = true;">ダイアログ表示</button>
 *   <message-dialog
 *     :visible.sync="isDialogVisible"
 *     :message-cd="1"
 *     type="2"
 *     :string-params="['置換文字列1', '置換文字列2']"
 *     @confirm="confirm"
 *   />
 *
 *   ...
 *
 *   confirm(answer) {
 *     if (answer === 'OK') {
 *       // 「OK」押下時の処理
 *     } else {
 *       // 「Cancel」押下時の処理
 *     }
 *   }
 */
export default {
  props: {
    // 必ずsync修飾子を付与すること!
    // ⇒ :visible.sync="flg"
    visible: {
      type: Boolean
    },

    messageCd: {
      type: Number
    },

    type: {
      type: String,
      validator(value) {
        // ダイアログタイプ1,2,3以外はエラー
        return [
          TYPE_OK,
          TYPE_OK_CANCEL,
          TYPE_YES_NO_CANCEL,
          TYPE_YES_NO,
          TYPE_SAVE_EXPAND
        ].includes(value);
      }
    },

    stringParams: {
      type: Array,
      default: () => []
    }
  },

  computed: {
    /**
     * @description メッセージ内容
     */
    message() {
      // 定義ファイルから対応するメッセージコードの文字列を取得
      const message = DIALOG_MESSAGES[this.messageCd];
      if (message === undefined) {
        return "メッセージが定義されていません。";
      }
      // パラメータ文字列を置換
      let replacedMessage = message;
      for (const param of this.stringParams) {
        replacedMessage = replacedMessage.replace(/{\$\d*}/, param);
      }
      // 改行文字列をbrタグに置換
      replacedMessage = replacedMessage.replace(/\n/g, "<br>");
      return replacedMessage;
    },

    /**
     * @description 改行を含むか
     */
    includesNewLine() {
      return this.message.includes("<br>");
    },

    // 指定されたダイアログタイプに対応するフッター
    footerButton() {
      let footer;
      if (this.type === TYPE_OK) {
        footer = {
          OK: () => this.confirmOk()
        };
      } else if (this.type === TYPE_OK_CANCEL) {
        footer = {
          キャンセル: () => this.confirmCancel(),
          OK: () => this.confirmOk()
        };
      } else if (this.type === TYPE_YES_NO_CANCEL) {
        footer = {
          // TODO:「キャンセル」にすると文字が途切れる
          Cancel: () => this.confirmCancel(),
          Yes: () => this.confirmYes(),
          No: () => this.confirmNo()
        };
      } else if (this.type === TYPE_YES_NO) {
        footer = {
          Yes: () => this.confirmYes(),
          No: () => this.confirmNo()
        };
      } else if (this.type === TYPE_SAVE_EXPAND) {
        footer = {
          保存: () => this.confirmYes(),
          展開保存: () => this.confirmNo()
        };
      }

      return footer;
    }
  },

  methods: {
    confirm(answer) {
      this.$emit("confirm", answer);
      this.closeDialog();
    },

    confirmOk() {
      this.confirm("OK");
    },

    confirmCancel() {
      this.confirm("Cancel");
    },

    confirmYes() {
      this.confirm("Yes");
    },

    confirmNo() {
      this.confirm("No");
    },

    closeDialog() {
      // 親に表示フラグを折らせる
      this.$emit("update:visible", false);
    }
  }
};
</script>

<style scoped></style>
