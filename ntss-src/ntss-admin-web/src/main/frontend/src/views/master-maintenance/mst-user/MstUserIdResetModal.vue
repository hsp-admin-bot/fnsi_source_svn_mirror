/**
 * チェックリストモーダル画面用ページ
 */
<template>
  <modal-base @onClose="closeUserIdResetModal">
    <div slot="header"></div>
    <div slot="body" class="custom-style-header">
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

    <div slot="footer" class="flex-container print-none">
      <div class="denial-btn-area" style="background:none">
        <v-ons-button class="btn3-normal registration-btn" @click="printUserIdResetModal">印刷</v-ons-button>
      </div>
      <div class="registration-btn-area" style="background:none">
        <v-ons-button class="btn2-cancel registration-btn" @click="closeUserIdResetModal">閉じる</v-ons-button>
      </div>
    </div>
  </modal-base>
</template>

<script>
import ModalBase from "@/components/modals/ModalBase";
import {mapState, mapActions, mapGetters} from "vuex";
import moment from "moment";
import { ApiHelper } from "@/apis/AxiosHelper";

export default {
  name: "UserIdResetModal",
  components: {
    "modal-base": ModalBase
  },
  data() {
    return {
      txtUrl2: "",
      // 施設マスタのVPN設定が「CL証明書URLおよびVPN用URL」であるか
      clCertificateAndVpn: false
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
      return "実行時刻　：　" + moment().format("YYYY-MM-DD HH:mm");
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
      `/master_maintenance/mst_user/get_vpn_set/${this.getFacilitySwitch}`
    ).then(response => {
      const resData = response.data;
      if (resData.vpnSet == 2) {
        // 施設マスタのVPNセットが 2：CL証明書URLおよびVPN用URLを表示
        this.txtUrl2 = resData.url2;
        this.clCertificateAndVpn = true;
      }
    });

  },
  beforeDestroy(){
    // menu頂部に置く
    document.getElementById("user-menu").style.zIndex = "9999"
    document.getElementsByClassName("notification unread-count")[0].style.zIndex = "10000"
  },
  mounted() {
    // 印刷時用制御classとdivのセット
    const set = document.createElement('div');
    const div = document.getElementById('main-id');
    const main = document.getElementsByClassName('content-container');
    div?.classList?.add('none-print');
    main[0].appendChild(set);
  },
  methods: {
    ...mapActions("multi-modal", ["hideModal"]),
    ...mapActions("mst-checklist", [
      "setSelectEditSetting",
      "setDialysisProgName",
      "regEditData",
      "sortData"
    ]),
    // コピーボタン
    copyUrl() {
      // ログインURLをクリップボードにコピー
      // 空div 生成
      var tmp = document.createElement("div");
      // 選択用のタグ生成
      var pre = document.createElement("pre");
      // 親要素のCSSで user-select: none だとコピーできないので書き換える
      pre.style.webkitUserSelect = "auto";
      pre.style.userSelect = "auto";
      tmp.appendChild(pre).textContent = this.txtUrl;
      // 要素を画面外へ
      var s = tmp.style;
      s.position = "fixed";
      s.right = "200%";
      // body に追加
      document.body.appendChild(tmp);
      // 要素を選択
      document.getSelection().selectAllChildren(tmp);
      // クリップボードにコピー
      document.execCommand("copy");
      // 要素削除
      document.body.removeChild(tmp);
    },
    // コピーボタン
    copyUrl2() {
      // ログインURLをクリップボードにコピー
      // 空div 生成
      var tmp = document.createElement("div");
      // 選択用のタグ生成
      var pre = document.createElement("pre");
      // 親要素のCSSで user-select: none だとコピーできないので書き換える
      pre.style.webkitUserSelect = "auto";
      pre.style.userSelect = "auto";
      tmp.appendChild(pre).textContent = this.txtUrl2;
      // 要素を画面外へ
      var s = tmp.style;
      s.position = "fixed";
      s.right = "200%";
      // body に追加
      document.body.appendChild(tmp);
      // 要素を選択
      document.getSelection().selectAllChildren(tmp);
      // クリップボードにコピー
      document.execCommand("copy");
      // 要素削除
      document.body.removeChild(tmp);
    },
    // 印刷ボタン
    printUserIdResetModal() {
      // 画面を印刷
      window.print();
    },
    // 閉じるボタン
    closeUserIdResetModal() {
      // 印刷時用制御classとdivの削除
      const div = document.getElementById('main-id');
      div.classList.remove('none-print');
      const main = document.getElementsByClassName('content-container');
      main[0].removeChild(main[0].lastChild);
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
  .modal-mask >>>.modal-container{
    background: #fff !important;
    height: 100%;
  }
  .modal-mask >>>.modal-body{
    color: #050505 !important;
    top: unset;
  }
  .modal-mask >>>.modal-header,
  .modal-mask >>>.modal-footer{
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
