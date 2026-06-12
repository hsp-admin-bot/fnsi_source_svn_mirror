/**
 * チェックリストモーダル画面用ページ
 */
<template>
  <modal-base @onClose="closeUserIdResetModal">
    <template #header></template>
    <template #body>
      <div class="custom-style-header">
      <h3 class="print-title">{{ txtSystemUseSetting }} 初回登録シート<br></h3>
      <h3 class="title">{{ txtFacilityNm }}</h3>

      <h5 v-if="clCertificateAndVpn" class="title">インターネット経由用URL(要クライアント証明書)：</h5>
      <div id="vueAppMstUserIdReset" class="vue-app obj-center-style" >
        <kendo-qrcode :value="txtUrl" :size="120" :encoding="'UTF_8'"></kendo-qrcode>
      </div>
      <div class="flex-container print-login-url-box">
        <div class="login-url-style print-login-url-style">{{ txtUrl }}</div>
        <div class="registration-btn-area print-none" style="background:none">
          <v-ons-button class="btn3-normal registration-btn" @click="copyUrl">コピー</v-ons-button>
        </div>
      </div>

      <div v-if="clCertificateAndVpn">
        <h5 class="title">VPN経由用URL：</h5>
        <div id="vueAppMstUserIdReset2" class="vue-app obj-center-style">
          <kendo-qrcode :value="txtUrl2" :size="120" :encoding="'UTF_8'"></kendo-qrcode>
        </div>
        <div class="flex-container print-login-url-box">
          <div class="login-url-style print-login-url-style">{{ txtUrl2 }}</div>
          <div class="registration-btn-area print-none" style="background:none">
            <v-ons-button class="btn3-normal registration-btn" @click="copyUrl2">コピー</v-ons-button>
          </div>
        </div>
      </div>

      <h3 class="obj-center-style">{{ txtUsrNm }}</h3>
      <h3 class="id-pwd-style">{{ txtUsrId }}</h3>
      <h3 class="id-pwd-style">{{ txtUsrPwd }}</h3>
<!--      add redmine4504 実行アカウントフルネームと現在時刻を表示する 孔 start-->
      <h3 class="id-pwd-style">{{ txtExecutionUserName }}</h3>
      <h3 class="id-pwd-style">{{ txtCreateDate }}</h3>
<!--      add redmine4504 実行アカウントフルネームと現在時刻を表示する 孔 end-->
      <div class="comment-style print-comment-style">
        <p class="comment-row-style print-comment-row-style">
      本書は新たな利用者がアカウント登録をするためのアクセス情報です。<br><br>
      この情報が外部に漏洩すると、外部の者によりシステムを利用される恐れがあるので厳重に管理してください。<br><br>
      新規利用者の方は、以下の手順でアカウント登録を完了してください。<br>
      ①URLまたはQRコードからサイトにアクセスしてください。施設用のサインイン画面が表示されます。<br>
      ②この記載の仮ユーザーID、仮パスワードを入力しサインインしてください。<br>
      ③正規のユーザーID、パスワードを登録する画面が表示するので画面に従い登録してください。<br>
      ④登録完了するとサインイン画面に戻るので、登録したユーザーID、パスワードでサインインしてください。<br><br>
      サインイン成功にてシステムの利用が可能となります。<br>
      必要に応じて画面右上のボタンからアカウント情報を変更してください。<br><br>
      5回以上サインインに失敗するとアカウントはロックされます。<br>
      アカウントロックはシステム管理者にて解除可能です。
        </p>
      </div>
      </div>
    </template>

    <template #footer>
      <div class="flex-container print-none">
      <div class="denial-btn-area" style="background:none">
        <v-ons-button class="btn3-normal registration-btn" @click="printUserIdResetModal">印刷</v-ons-button>
      </div>
      <div class="registration-btn-area" style="background:none">
        <v-ons-button class="btn2-cancel registration-btn" @click="closeUserIdResetModal">閉じる</v-ons-button>
      </div>
      </div>
    </template>
  </modal-base>
</template>

<script>
import ModalBase from "@/components/modals/ModalBase";
import {mapState, mapActions, mapGetters} from "@/compat/vue/vuex";
import dayjs from "@/compat/date/dayjs";
import { ApiHelper } from "@/apis/AxiosHelper";
import { getScopedDocument, getScopedWindow, queryElementBySelectors, appendScopedChild, removeScopedChild } from "@/functions/common/LayoutMeasureHelper";

export default {
  name: "UserIdResetModal",
  components: {
    "modal-base": ModalBase
  },
  data() {
    return {
      txtUrl2: "",
      // 施設マスタのVPN設定が「CL証明書URLおよびVPN用URL」であるか
      clCertificateAndVpn: false,
      printGuardElement: null,
      printGuardParent: null
    };
  },
  computed: {
    ...mapGetters("account-edit", ["getUserName"]),
    ...mapState("mst-user", ["userInfoModal"]),
    ...mapGetters("master-maintenance", {
      getFacilitySwitch: "getFacilitySwitch"
    }),
    // add redmine4504 実行アカウントフルネームと現在時刻を表示する 孔 start
    txtCreateDate() {
      // 施設名を返却
      return "実行時刻　：　" + dayjs().format("YYYY-MM-DD HH:mm");
    },
    txtExecutionUserName() {
      // 施設名を返却
      return "実行者　：　" + this.getUserName;
    },
    // add redmine4504 実行アカウントフルネームと現在時刻を表示する 孔 end
    txtFacilityNm() {
      // 施設名を返却
      return this.userInfoModal.facilityName;
    },
    txtUsrNm() {
      // ユーザー名を返却
      return this.userInfoModal.userName + "　さん";
    },
    txtUsrId() {
      // 仮ユーザーIDを返却
      return "仮ユーザーID　：　" + this.userInfoModal.dispUserId;
    },
    txtUsrPwd() {
      // 仮パスワードを返却
      return "仮パスワード　：　" + this.userInfoModal.userPassword;
    },
    txtUrl() {
      // ログインページURLを返却
      return this.userInfoModal.loginUrl;
    },
    txtSystemUseSetting() {
      // システム利用設定文字列を返却
      let dispSystem = "";
      // システム利用設定ごとの利用可能機能
      switch (this.userInfoModal.systemUseSetting) {
        case "1":
          // ReMSのみ
          dispSystem = "ReMS";
          break;
        case "2":
          // FNSiのみ
          dispSystem = "FutureNetWeb⁺Si";
          break;
        case "3":
          // ReMS + FNSi
          dispSystem = "FutureNetWeb⁺Si・ReMS";
          break;
      }
      return dispSystem;
    }
  },
  async created() {
    // 施設マスタのVPNセット、対応するURLを取得
    ApiHelper.get(
      `/master_maintenance/mst_user/get_vpn_set/${this.getFacilitySwitch}`).then(response => {
      const resData = response.data;
      if (resData.vpnSet == 2) {
        // 施設マスタのVPNセットが 2：CL証明書URLおよびVPN用URLを表示
        this.txtUrl2 = resData.url2;
        this.clCertificateAndVpn = true;
      }
    });

  },
  beforeUnmount(){
    // menu頂部に置く
    this.getUserMenuElement()?.style && (this.getUserMenuElement().style.zIndex = "9999");
    this.getUnreadNotificationElement()?.style && (this.getUnreadNotificationElement().style.zIndex = "10000");
  },
  mounted() {
    // 印刷時用制御classとdivのセット
    const scopedDocument = this.getScopedDoc();
    const set = scopedDocument.createElement('div');
    const div = this.getMainRootElement();
    const main = this.getContentContainerElement();
    div?.classList?.add('none-print');
    appendScopedChild(main, set);
    this.printGuardElement = set;
    this.printGuardParent = main || null;
  },
  methods: {
    ...mapActions("multi-modal", ["hideModal"]),
    ...mapActions("mst-checklist", [
      "setSelectEditSetting",
      "setDialysisProgName",
      "regEditData",
      "sortData"
    ]),

    getScopedDoc() {
      return getScopedDocument(this.$el || null);
    },
    getUserMenuElement() {
      return queryElementBySelectors(['#user-menu'], this.$el || null);
    },
    getUnreadNotificationElement() {
      return queryElementBySelectors(['.notification.unread-count', '.notification.unread-count'], this.$el || null);
    },
    getContentContainerElement() {
      return queryElementBySelectors(['.content-container'], this.$el || null);
    },
    getMainRootElement() {
      return queryElementBySelectors(['#main-id'], this.$el || null);
    },
    createCopySelectionNode(value) {
      const scopedDocument = this.getScopedDoc();
      var tmp = scopedDocument.createElement("div");
      var pre = scopedDocument.createElement("pre");
      pre.style.webkitUserSelect = "auto";
      pre.style.userSelect = "auto";
      tmp.appendChild(pre).textContent = value;
      var s = tmp.style;
      s.position = "fixed";
      s.right = "200%";
      return tmp;
    },
    // コピーボタン
    copyUrl() {
      // ログインURLをクリップボードにコピー
      // 空div 生成
      const scopedDocument = this.getScopedDoc();
      var tmp = this.createCopySelectionNode(this.txtUrl);
      const body = scopedDocument.body || scopedDocument.documentElement;
      appendScopedChild(body, tmp);
      scopedDocument.getSelection()?.selectAllChildren(tmp);
      scopedDocument.execCommand("copy");
      removeScopedChild(tmp, body);
    },
    // コピーボタン
    copyUrl2() {
      // ログインURLをクリップボードにコピー
      // 空div 生成
      const scopedDocument = this.getScopedDoc();
      var tmp = this.createCopySelectionNode(this.txtUrl2);
      const body = scopedDocument.body || scopedDocument.documentElement;
      appendScopedChild(body, tmp);
      scopedDocument.getSelection()?.selectAllChildren(tmp);
      scopedDocument.execCommand("copy");
      removeScopedChild(tmp, body);
    },
    // 印刷ボタン
    printUserIdResetModal() {
      // 画面を印刷
      (getScopedWindow(this.$el || this) || window).print();
    },
    // 閉じるボタン
    closeUserIdResetModal() {
      // 印刷時用制御classとdivの削除
      const div = this.getMainRootElement();
      div?.classList?.remove('none-print');
      if (this.printGuardParent && this.printGuardElement && this.printGuardParent.contains(this.printGuardElement)) {
        removeScopedChild(this.printGuardElement, this.printGuardParent);
      }
      this.printGuardElement = null;
      this.printGuardParent = null;
      // モーダルを非表示にする
      this.hideModal();
    }
  }
};
</script>

<style scoped>
.obj-center-style {
  text-align: center;
}
.id-pwd-style {
  text-align: center;
  word-break: keep-all;
}
.comment-style {
  text-align: center;
  margin: 0 2em;
}
.comment-row-style {
  text-align: left;
  display: inline-block;
}
.title {
  margin-left: 0.33em;
}

.login-url-style {
  word-break: break-word;
  padding-right: 2em;
  margin-right: 2em;
  margin-left: 1em;
}

.print-title{
  display: none;
}

.custom-style-header h3 {
  font-size: 1.5em;
}

/* 印刷時自要素内スタイル */
@media print {
  .modal-mask{
    background-color: #fff !important;
    background: rgba(255, 255, 255, 1);
    background-image: -webkit-linear-gradient(rgba(255,255,255,1) 100%,rgba(255,255,255,1) 100%);
    background-image:         linear-gradient(rgba(255,255,255,1) 100%,rgba(255,255,255,1) 100%);
  }
  .modal-mask :deep(.modal-container){
    background: #fff !important;
    height: 100%;
  }
  .modal-mask :deep(.modal-body){
    color: #050505 !important;
    top: unset;
  }
  .modal-mask :deep(.modal-header),
  .modal-mask :deep(.modal-footer){
    display: none !important;
  }
  .print-none {
    display: none !important;
  }
  .print-login-url-box {
    display: block;
    text-align: center;
    margin: 0 20px;
  }
  .print-login-url-style {
    font-size: 16px;
    text-align: left;
    display: inline-block;
    padding-right: 20px;
    margin-right: 20px;
    margin-left: 10px;
  }
  .print-comment-style {
    text-align: center;
    margin: 0 10px;
  }
  .print-comment-row-style {
    font-size: 12px;
  }
  .print-title{
    margin-left: 0.33em;
    display: inline;
  }
  .title{
    margin-top: 5px;
    margin-bottom: 0;
    margin-left: 0.33em;
  }
  .custom-style-header h3 {
    font-size: 24px;
    margin-top: 0.5em;
    margin-bottom: 0.5em;
  }
}

/* 印刷時ヘッダー・フッター非表示(Chrome限定) */
@page {
  margin: 0;
}
</style>
