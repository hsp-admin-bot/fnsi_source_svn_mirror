<template>
<!--mod FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.97(外結)対応 韓 start -->
    <!--<v-ons-alert-dialog
      :visible="visible"
      modifier="rowfooter"
      :footer="footerButton"
      :class="typeFooter"
    >-->
    <v-ons-alert-dialog
      :visible="visible"
      modifier="rowfooter"
      :class="typeFooter"
    >
      <span slot="title">{{ dialogTitle }}</span>
      <div :class="{'overflow_y':overflowY}">
        <p>
          <template v-for="(item, index) in message">
            <span :key="index">{{ item }}<br></span>
          </template>
        </p>
      </div>
      <!-- mod 7211 曜日パターン変更のメッセージ表示や治療予定の移動動作がおかしい 張 end -->
      <!-- add #7185 centOS7サポート切れ 付 start -->
      <template slot="footer" v-if="type === TYPE_OK">
        <v-ons-alert-dialog-button @click="confirmOk()">OK</v-ons-alert-dialog-button>
      </template>
      <template slot="footer" v-else-if="type === TYPE_OK_CANCEL">
        <v-ons-alert-dialog-button @click="confirmCancel()">Cancel</v-ons-alert-dialog-button>
        <v-ons-alert-dialog-button @click="confirmOk()">OK</v-ons-alert-dialog-button>
      </template>
      <template slot="footer" v-else-if="type === TYPE_YES_NO_CANCEL">
        <v-ons-alert-dialog-button @click="confirmCancel()">Cancel</v-ons-alert-dialog-button>
        <v-ons-alert-dialog-button @click="confirmYes()">Yes</v-ons-alert-dialog-button>
        <v-ons-alert-dialog-button @click="confirmNo()">No</v-ons-alert-dialog-button>
      </template>
      <template slot="footer" v-else-if="type === TYPE_YES_NO">
        <v-ons-alert-dialog-button @click="confirmYes()">Yes</v-ons-alert-dialog-button>
        <v-ons-alert-dialog-button @click="confirmNo()">No</v-ons-alert-dialog-button>
      </template>
      <template slot="footer" v-else-if="type === TYPE_SAVE_EXPAND">
        <v-ons-alert-dialog-button @click="confirmYes()">保存</v-ons-alert-dialog-button>
        <v-ons-alert-dialog-button @click="confirmNo()">展開保存</v-ons-alert-dialog-button>
      </template>
      <template slot="footer" v-else-if="type === TYPE_YES_NO_CANCEL_JPN">
        <v-ons-alert-dialog-button @click="confirmCancel()">ｷｬﾝｾﾙ</v-ons-alert-dialog-button>
        <v-ons-alert-dialog-button @click="confirmNo()">いいえ</v-ons-alert-dialog-button>
        <v-ons-alert-dialog-button @click="confirmYes()">はい</v-ons-alert-dialog-button>
      </template>
      <template slot="footer" v-else-if="type === TYPE_DELSAVE_SAVE_CANCEL">
        <v-ons-alert-dialog-button @click="confirmYes()">上書き優先</v-ons-alert-dialog-button>
        <v-ons-alert-dialog-button @click="confirmNo()">既存優先</v-ons-alert-dialog-button>
        <v-ons-alert-dialog-button @click="confirmCancel()">キャンセル</v-ons-alert-dialog-button>
      </template>
      <template slot="footer" v-else-if="type === TYPE_123">
        <v-ons-alert-dialog-button @click="confirm(1)">1</v-ons-alert-dialog-button>
        <v-ons-alert-dialog-button @click="confirm(2)">2</v-ons-alert-dialog-button>
        <v-ons-alert-dialog-button @click="confirm(3)">3</v-ons-alert-dialog-button>
      </template>
      <template slot="footer" v-else-if="type === TYPE_WORD">
        <v-ons-alert-dialog-button @click="confirm(1)">表示維持</v-ons-alert-dialog-button>
        <v-ons-alert-dialog-button @click="confirm(2)">編集破棄</v-ons-alert-dialog-button>
        <v-ons-alert-dialog-button @click="confirm(3)">編集維持</v-ons-alert-dialog-button>
      </template>
      <!-- add #7185 centOS7サポート切れ 付 end -->
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
const TYPE_YES_NO_CANCEL_JPN = "6";
// add FNSI-改修内容 スケジュール移動に既に同一クール、治療が存在する場合、警告を出す（日付） 穆 start
const TYPE_DELSAVE_SAVE_CANCEL = "7";
// add FNSI-改修内容 スケジュール移動に既に同一クール、治療が存在する場合、警告を出す（日付） 穆 end
// FNSI-add 現行改善対応425 孫灝 20201117 start
const TYPE_123 = "8";
// FNSI-add 現行改善対応425 孫灝 20201117 end
/* add FNSI-4212 更新対象変更時のウインドウが不正 liumx start */
const TYPE_WORD = "9";
/* add FNSI-4212 更新対象変更時のウインドウが不正 liumx end */
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
//#10300：装置設定デフォルト＞風袋と除水補正のpopover内の文字サイズが適応されていない。 Start
import {mapGetters} from "vuex";
//#10300：装置設定デフォルト＞風袋と除水補正のpopover内の文字サイズが適応されていない。 End
export default {
  data () {
    return {
      // add #7185 centOS7サポート切れ 付 start
      TYPE_OK: '1',
      TYPE_OK_CANCEL: '2',
      TYPE_YES_NO_CANCEL: '3',
      TYPE_YES_NO: '4',
      TYPE_SAVE_EXPAND: '5',
      TYPE_YES_NO_CANCEL_JPN: '6',
      TYPE_DELSAVE_SAVE_CANCEL: '7',
      TYPE_123: '8',
      TYPE_WORD: '9',
      // add #7185 centOS7サポート切れ 付 end
    }
  },
  props: {
    //add 7211 曜日パターン変更のメッセージ表示や治療予定の移動動作がおかしい 張 start
    //mod 11061 患者経過総合ビューア＞スケジュール編集でベッドのプルダウンリスト展開でDB負荷が高くシステムが操作不可となる。(恒久対応) start
    overflowY:{
        type: Boolean,
        default: true
    },
    //mod 11061 患者経過総合ビューア＞スケジュール編集でベッドのプルダウンリスト展開でDB負荷が高くシステムが操作不可となる。(恒久対応) end
    //add 7211 曜日パターン変更のメッセージ表示や治療予定の移動動作がおかしい 張 end
    // 必ずsync修飾子を付与すること!
    // ⇒ :visible.sync="flg"
    visible: {
      type: Boolean
    },

    messageCd: {
      type: Number
    },
    //add FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.97(外結)対応 韓 start
    title: {
      type: String
    },
    //add FNSI-【1006】障害票一覧_患者経過総合ビューア.xlsxのNo.97(外結)対応 韓 end

    type: {
      type: String,
      validator(value) {
        // ダイアログタイプ1,2,3以外はエラー
        return [
          TYPE_OK,
          TYPE_OK_CANCEL,
          TYPE_YES_NO_CANCEL,
          TYPE_YES_NO,
          TYPE_SAVE_EXPAND,
          // mod FNSI-改修内容 スケジュール移動に既に同一クール、治療が存在する場合、警告を出す（日付） 穆 start
          // TYPE_YES_NO_CANCEL_JPN
          TYPE_YES_NO_CANCEL_JPN,
          TYPE_DELSAVE_SAVE_CANCEL,
          // mod FNSI-改修内容 スケジュール移動に既に同一クール、治療が存在する場合、警告を出す（日付） 穆 start
          // FNSI-add 現行改善対応425 孫灝 20201117 start
          TYPE_123,
          // FNSI-add 現行改善対応425 孫灝 20201117 end
          /* add FNSI-4212 更新対象変更時のウインドウが不正 liumx start */
          TYPE_WORD
          /* add FNSI-4212 更新対象変更時のウインドウが不正 liumx end */
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
      // add #6107 2023/03/24 メッセージボックス全調整 林峻峰 start
      // const message = DIALOG_MESSAGES[this.messageCd].message;
      // if (message === undefined) {
      //   return "メッセージが定義されていません。";
      // }
      let message = '';
      if (this.messageCd && DIALOG_MESSAGES[this.messageCd] && DIALOG_MESSAGES[this.messageCd].message) {
        message = DIALOG_MESSAGES[this.messageCd].message;
      }
      if (message === '') {
        return ["メッセージが定義されていません。"];
      }
      // add #6107 2023/03/24 メッセージボックス全調整 林峻峰 end

      // パラメータ文字列を置換
      let replacedMessage = message;
      for (const param of this.stringParams) {
        replacedMessage = replacedMessage.replace(/{\$\d*}/, param);
      }
      // 改行文字列をbrタグに置換
      replacedMessage = replacedMessage.trim().split(/\n|<br>|<\/br>/);
      return replacedMessage;
    },
    dialogTitle() {
      return this.title || DIALOG_MESSAGES?.[this.messageCd]?.title;
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
          Cancel: () => this.confirmCancel(),
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
      } else if (this.type === TYPE_YES_NO_CANCEL_JPN) {
        footer = {
          ｷｬﾝｾﾙ: () => this.confirmCancel(),
          いいえ: () => this.confirmNo(),
          はい: () => this.confirmYes()
        };
        // add FNSI-改修内容 スケジュール移動に既に同一クール、治療が存在する場合、警告を出す（日付） 穆 start
      } else if (this.type === TYPE_DELSAVE_SAVE_CANCEL) {
        footer = {
          //mod 7211 曜日パターン変更のメッセージ表示や治療予定の移動動作がおかしい 張 start
          // 予定上書き: () => this.confirmYes(),
          // 既存を残す: () => this.confirmNo(),
          // キャンセル: () => this.confirmCancel()
          上書き優先: () => this.confirmYes(),
          既存優先: () => this.confirmNo(),
          キャンセル: () => this.confirmCancel()
          //mod 7211 曜日パターン変更のメッセージ表示や治療予定の移動動作がおかしい 張 end
        };
        // add FNSI-改修内容 スケジュール移動に既に同一クール、治療が存在する場合、警告を出す（日付） 穆 end
        // FNSI-add 現行改善対応425 孫灝 20201117 start
      } else if (this.type === TYPE_123) {
        footer = {
          1: () => this.confirm(1),
          2: () => this.confirm(2),
          3: () => this.confirm(3)
        };
        // FNSI-add 現行改善対応425 孫灝 20201117 end
      }
      /* add FNSI-4212 更新対象変更時のウインドウが不正 liumx start */
      else if (this.type === TYPE_WORD) {
        footer = {
          表示維持: () => this.confirm(1),
          編集破棄: () => this.confirm(2),
          編集維持: () => this.confirm(3)
        };
        /* add FNSI-4212 更新対象変更時のウインドウが不正 liumx end */
      }
      return footer;
    },
    //#10300：装置設定デフォルト＞風袋と除水補正のpopover内の文字サイズが適応されていない。 Start
    ...mapGetters("master-maintenance", {
      masterPhysicalName: "getMasterName",
    }),
    ...mapGetters("account-edit", {
      getFontSize: "getFontSize",
    }),
    //#10300：装置設定デフォルト＞風袋と除水補正のpopover内の文字サイズが適応されていない。 End
    typeFooter() {
      //#10320：注意喚起メッセージの文字サイズが中サイズ固定で表示される Start
      //#10300：装置設定デフォルト＞風袋と除水補正のpopover内の文字サイズが適応されていない。 Start
      const names = ["small", "medium", "large", "x-large"];
      const fontsize = "font-size-set-" + names[this.getFontSize];
      return `type-${this.type} ${fontsize}`;
      //#10300：装置設定デフォルト＞風袋と除水補正のpopover内の文字サイズが適応されていない。 End
      //#10320：注意喚起メッセージの文字サイズが中サイズ固定で表示される End
    }
  },

  methods: {
    confirm(answer) {
      this.closeDialog();
      this.$emit("confirm", answer);
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

<style scoped>
/*add 7211 曜日パターン変更のメッセージ表示や治療予定の移動動作がおかしい 張 start */
/* mod 11061 患者経過総合ビューア＞スケジュール編集でベッドのプルダウンリスト展開でDB負荷が高くシステムが操作不可となる。(恒久対応) start */
.overflow_y{
  height: auto;
  max-height: 70vh;
  overflow-y: auto;
}
/* mod 11061 患者経過総合ビューア＞スケジュール編集でベッドのプルダウンリスト展開でDB負荷が高くシステムが操作不可となる。(恒久対応) end */
  /*add 7211 曜日パターン変更のメッセージ表示や治療予定の移動動作がおかしい 張 end */
</style>
