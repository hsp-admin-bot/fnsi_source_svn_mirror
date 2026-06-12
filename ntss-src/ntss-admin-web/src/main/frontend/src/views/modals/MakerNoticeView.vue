/**
 * メーカー通知登録ページ
 */
<template>
  <modal-base @onClose="cancel">
    <template #body>
      <div :class="['maker-notice', modalMessageSize]">
      <div>
        <div class="maker-notice-input">
          <label class="title">通知内容</label>
        </div>
        <div class="maker-notice-input">
          <label class="sub-title">件名：</label>
          <com-textarea
            class="com-textarea"
            :content="subject"
            idTextarea="com-textarea-subject"
            cssClass="subject-col textarea-custom-text-font textarea-resize-vertical"
            @set-content-data="setContentDataSubject"
          />
        </div>
        <div class="maker-notice-input">
          <label class="sub-title">本文：</label>
          <com-textarea
            class="com-textarea"
            :content="body"
            defaultHeight="28rem"
            idTextarea="com-textarea-body"
            cssClass="body-col textarea-custom-text-font textarea-resize-vertical"
            @set-content-data="setContentDataBody"
          />
        </div>
      </div>
      </div>
    </template>
    <template #footer>
      <div class="flex-container">
      <div class="denial-btn-area" style="background:none">
        <!-- mod FNSI-コードをマージ 江 start -->
        <!-- <v-ons-button class="button denial-btn" @click="cancel">キャンセル</v-ons-button> -->
        <v-ons-button class="button btn2-cancel denial-btn" @click="cancel">キャンセル</v-ons-button>
        <!-- mod FNSI-コードをマージ 江 end -->
      </div>
      <div class="registration-btn-area" style="background:none">
        <!-- mod FNSI-コードをマージ 江 start -->
        <!-- <v-ons-button class="button registration-btn" @click="main">実行</v-ons-button> -->
        <v-ons-button class="button btn1-execute registration-btn" @click="main">実行</v-ons-button>
        <!-- mod FNSI-コードをマージ 江 end -->
      </div>
        <!-- del FNSI-コードをマージ 江 start -->
        <!-- <v-ons-modal :visible="isSaving">
          <p class="saving-modal">
            処理中...
            <v-ons-icon icon="fa-spinner" spin />
          </p>
        </v-ons-modal> -->
        <!-- del FNSI-コードをマージ 江 end -->
      </div>
    </template>
  </modal-base>
</template>

<script>
import ModalBase from "@/components/modals/ModalBase";
import MultiModalMixin from "@/components/modals/MultiModalMixin";
import { mapActions } from "@/compat/vue/vuex";
import { ApiHelper } from "@/apis/AxiosHelper";
import CommonTextArea from "@/components/common/CommonTextArea";
import { mapGetters } from "@/compat/vue/vuex";

//FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
import {getErrorMessage} from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
import $ from "@/compat/jquery";
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end

const uriGetUser = `/notification-message/getUser`;
// del FNSI-コードをマージ 江 start
// const uriMail = `/notification-message/sendMail`;
// del FNSI-コードをマージ 江 end

export default {
  name: "accountEdit",
  mixins: [MultiModalMixin],
  components: {
    "modal-base": ModalBase,
    "com-textarea": CommonTextArea
  },
  data() {
    return {
      // del FNSI-コードをマージ 江 start
      // isSaving: false,
      // del FNSI-コードをマージ 江 end
      subject: "",
      body: ""
    };
  },
  methods: {
    ...mapActions("notification-message", [
      "registerNotificationMessage"
    ]),
    ...mapActions("multi-modal", {
      showNotificationMessage: "showNotificationMessage"
    }),
    // add FNSI-コードをマージ 江 start
    // 共通ローダー設定
    ...mapActions("loading-screen", {
      setLoadingScreenVisible: "setLoadingScreenVisible",
      setLoadingScreenMessage: "setLoadingScreenMessage",
      resetLoadingScreenVisibleCount:  "resetLoadingScreenVisibleCount"
    }),
    // add FNSI-コードをマージ 江 end

    async main() {
      if (this.subject === "" || this.body === "") {
        this.$ons.notification.alert({
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
          // title: "確認",
          // message: "件名と本文は必ず入力してください"
          title: DIALOG_MESSAGES[12000292].title,
          message: messageFormat(DIALOG_MESSAGES[12000292].message)  
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
        });
        
        return;
      }

      // mod FNSI-コードをマージ 江 start
      // this.isSaving = true;
      this.setLoadingScreenVisible(true);
      // mod FNSI-コードをマージ 江 end
      await this.registration()
        .catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
          getErrorMessage('MakerNoticeView.vue','main',error);
          //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
          throw error;
        })
        // mod FNSI-コードをマージ 江 start
        // .finally(() => (this.isSaving = false));
        .finally(() => (this.setLoadingScreenVisible(false)));
        // mod FNSI-コードをマージ 江 end

      this.$ons.notification.alert({
        // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
        // title: "完了",
        // message: "メーカー通知登録を実行しました",
        title: DIALOG_MESSAGES[12000293].title,
        message: messageFormat(DIALOG_MESSAGES[12000293].message),
        // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
        callback: answer => {
          if (answer == 0) {
            //OK
            this.showNotificationMessage();
          }
        }
      });
    },
    /**
     * メーカー通知登録実行
     */
    async registration() {

      let userList = [];
      // システムに登録している全ユーザーを取得
      const responseUser = await ApiHelper.get(`${uriGetUser}`).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
        getErrorMessage('MakerNoticeView.vue','registration',error);
        //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
        throw error;
      });
      const responseUserList = responseUser.data;
      for (let i = 0; i < responseUserList.length; i++) {
        userList[i] = responseUserList[i];
      }
      if (userList.length !== 0) {
        // mod FNSI-コードをマージ 江 start
        // // 通知メッセージ登録
        // await this.registerNotificationMessage({
        //   content: this.subject + "\n" + this.body,
        //   recipients: userList,
        //   additionalInfo: null
        // });
        // 通知メッセージ登録・メール送信処理
        this.registerNotificationMessage({
          contentSubject: this.subject,
          contentBody: this.body,
          recipients: userList,
          additionalInfo: null
        }).catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
          getErrorMessage('MakerNoticeView.vue','registration',error);
          //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
          throw error;
        });
        // mod FNSI-コードをマージ 江 end
      }
      // del FNSI-コードをマージ 江 start
      // // メール送信処理
      // await ApiHelper.post(`${uriMail}`,{
      //   subject: this.subject,
      //   body: this.body
      // }).catch(error => {
      //   throw error;
      // });
      // del FNSI-コードをマージ 江 end

    },
    /**
     * キャンセル
     */
    cancel() {
      // 変更がある場合はメッセージを表示
      if (this.subject !== "" || this.body !== "") {
        this.$ons.notification.confirm({
          // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
          // title: "内容破棄",
          title: DIALOG_MESSAGES[13000004].title,
          // message: "編集内容が破棄されます。</br>よろしいですか？",
          message: messageFormat(DIALOG_MESSAGES[13000004].message),
          // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
          callback: answer => {
            if (answer == 1) {
              //OK
              this.showNotificationMessage();
            }
          }
        });
      } else {
        this.showNotificationMessage();
      }
    },

    setContentDataSubject(newValue) {
      this.subject = newValue;
    },

    setContentDataBody(newValue) {
      this.body = newValue;
    }
  },
  created() {
    // add FNSI-コードをマージ 江 start
    // 共通ローダー:表示名設定
    this.setLoadingScreenMessage("処理中・・・");
    // add FNSI-コードをマージ 江 end
  },

  computed: {
    ...mapGetters("account-edit", ["getFontSize"]),
    modalMessageSize() {
      switch (+this.getFontSize) {
        case 0:
          return "small";
        case 1:
          return "medium";
        case 2:
          return "big";
        case 3:
          return "xbig";
        default:
          return "";
      }
    }
  },
  mounted() {
    $('div.modal-body').addClass("modal-overflow-hidden");
  }
};
</script>

<style scoped>
.maker-notice {
  position: relative;
  padding: 10px;
  text-align: center;
  overflow-y: auto;
  height: 100%;
}
.maker-notice-input {
  text-align:left;
  margin: 0px 0px 15px 0px;
}
.sub-title {
  display: inline-block;
  vertical-align: top;
}
div :deep(.subject-col) {
  font-size: 1em;
  border: solid 1px #ccc;
  font-family: inherit;
}
div :deep(.body-col) {
  font-size: 1em;
  border: solid 1px #ccc;
  font-family: inherit;
}
/* del FNSI-コードをマージ 江 start */
/* .saving-modal {
  text-align: center;
  font-size: 30px;
} */
/* del FNSI-コードをマージ 江 end */
.com-textarea {
  box-sizing: border-box;
  width: 99.5%;
}
@media screen and (max-width: 414px) {
  .com-textarea {
    box-sizing: border-box;
    width: 96%;
  }
}
@media screen and (min-width: 415px) and (max-width: 580px) {
  .com-textarea {
    box-sizing: border-box;
    width: 97%;
  }
}
@media screen and (min-width: 581px) and (max-width: 850px) {
  .com-textarea {
    box-sizing: border-box;
    width: 98%;
  }
}
@media screen and (min-width: 851px) and (max-width: 1200px) {
  .com-textarea {
    box-sizing: border-box;
    width: 98.5%;
  }
}
.maker-notice.small {
  max-height: calc(100% - 30px);
}

.maker-notice.medium {
  max-height: calc(100% - 23px);
}

.maker-notice.big {
  max-height: calc(100% - 17px);
}

.maker-notice.xbig {
  max-height: calc(100% - 14px);
}
@media print {
  .maker-notice {
    height: auto !important;
  }  
  /** テキストエリアのページ跨ぎを可能とする */
  .modal-mask {
    text-align: center;
    height: auto !important;
  }
  div :deep(.modal-wrapper){
    display: inline-block !important;
    width: 96%;
    margin-bottom: 3vh !important;
  }
}
/* 横向き印刷 */
@media print and (orientation: landscape) {
  div :deep(.custom-textarea.body-col){
    height: 16rem !important;
  }
}
</style>
