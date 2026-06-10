/**
 * ログインPage
 */
<template>
  <div>
    <div class='login-page'>
      <button class='imgButton' type="button" @click='reload();'>
        <img src='../assets/NTSS_icon.png' class="img-icon" />
      </button>
      <div class='panel'>
        <v-ons-row>
          <v-ons-col>
            <div>
              <label id='user-id' for='userId'>ユーザーID：</label>
              <v-ons-input input-id='userId' type='text' v-model='userId' ref='userId' @keydown.enter='setFocus("passwd")' float autofocus autocapitalize="off"></v-ons-input>
            </div>
          </v-ons-col>
        </v-ons-row>
        <v-ons-row>
          <v-ons-col>
            <div>
              <label for='passwd'>パスワード：</label>
              <v-ons-input input-id='passwd' type='password' v-model='passwd' ref='passwd' @keydown.enter='signIn' float></v-ons-input>
            </div>
          </v-ons-col>
        </v-ons-row>
        <v-ons-row>
          <v-ons-col>
            <div>
              <v-ons-button class='button' @click='signIn' :disabled='!validation || isAlerting' ref='signInButton'>サインイン</v-ons-button>
            </div>
          </v-ons-col>
        </v-ons-row>
      </div>
      <v-ons-row>
        <v-ons-col>
          <div class="error-massage" id="error-massage" v-if='hasAuthError'>
            <p class="p-error" id="p-error">認証情報が正しくありません。<br>もう一度お試しください。</p>
          </div>
        </v-ons-col>
      </v-ons-row>
    </div>
  <loading-screen />
  </div>
</template>

<script>
import { mapActions, mapGetters } from "vuex";
import { getRouterName, getInitialRouterName } from "@/router/routing-helper";
import { ApiHelper } from "@/apis/AxiosHelper";
import NotificationMessageMixin from "@/components/common/notification-message/NotificationMessageMixin";
import loadingScreen from "@/components/common/LoadingScreen";
import { DIALISYS_STATE } from "@/constants/statusMapConstants.js";
//FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
import {getErrorMessage} from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end

export default {
  mixins: [NotificationMessageMixin],
  data() {
    return {
      // 利用者ID
      userId: "",
      // パスワード
      passwd: "",
      // 認証エラーかどうか
      hasAuthError: false,
      // アラート表示中
      isAlerting: false
    };
  },
  components: {
    "loading-screen": loadingScreen
  },
  computed: {
    ...mapGetters("account-edit", ["getStateUserAccountInfo"]),
    ...mapGetters("user", ["getFacilityCd"]),
    ...mapGetters("app", ["hasApiError", "getKey"]),
    // 入力チェック
    // 結果により、サインインボタン押下制御
    validation() {
      return this.validateUserId && this.validatePassword;
    },
    // ユーザーIDの入力チェック
    // 未入力またはtrimした値の文字列長が'0'の場合はfalseを返す。
    validateUserId() {
      if (this.userId.length === 0 || this.userId.trim().length === 0) {
        return false;
      }
      return true;
    },
    // パスワードの入力チェック
    // 未入力またはtrimした値の文字列長が'0'の場合はfalseを返す。
    validatePassword() {
      if (this.passwd.length === 0 || this.passwd.trim().length === 0) {
        return false;
      }
      return true;
    }
  },
  methods: {
    ...mapActions("account-edit", ["getUserAccountInfo"]),
    ...mapActions("user", {
      userSignIn: "signIn"
    }),
    ...mapActions("user", ["setUserName", "fetchUserAuthorityCds"]),
    ...mapActions("app", ["setState", "clearApiResult", "setQueryParameters"]),
    ...mapGetters("app", ["getApiResult", "getProtocol", "getHost", "getPathname", "getKey"]),
    ...mapActions("bread-crumb", ["resetKeepHistory"]),
    // 共通ローダー設定
    ...mapActions("loading-screen", {
      setLoadingScreenVisible: "setLoadingScreenVisible",
      setLoadingScreenMessage: "setLoadingScreenMessage",
      resetLoadingScreenVisibleCount:  "resetLoadingScreenVisibleCount"
    }),
    ...mapActions("pat-info", ["selectPat"]),
    ...mapActions("notification-message", ["getNotificationMessage"]),

    // フォーカスを移動する
    setFocus(ref) {
      this.$refs[ref].$el._input.focus();
    },
    // サインインボタン押下時イベント
    async signIn() {
      // サインインボタンが非活性の場合は何もしない
      if (this.$refs.signInButton.disabled) {
        return;
      }
      // 共通ローダー:画面制御
      this.setLoadingScreenVisible(true);

      // パンくずリストをクリア
      this.resetKeepHistory();

      // storeを呼び出す為の引数作成
      const user = {
        userId: this.userId,
        password: this.passwd,
        facilityCd: this.getKey,
        funcCd: this.$route.query.FUNC
      };
      // 認証処理
      this.userSignIn(user)
        .then(() => {
          // エラー保持状況フラグを更新
          this.hasAuthError = false;

          // アカウント情報を取得
          (async () => {
            await this.getUserAccountInfo();

            // 利用者権限取得.
            await this.fetchUserAuthorityCds();

            const userInfo = this.getStateUserAccountInfo;
            this.setUserName(
              userInfo.userLastName + " " + userInfo.userFirstName
            );

            if (userInfo.isProvisional === 1) {
              // 仮登録の場合は初回ログイン時アカウント登録画面に遷移
              // 共通ローダー:初期値セット(非表示)
              this.resetLoadingScreenVisibleCount();
              this.$router.push({ name: "provisional-account-edit" });
              return;
            }

            // URL指定で呼び出された場合
            if (this.goSpecifyingPage() === true) {
              // 共通ローダー:初期値セット(非表示)
              this.resetLoadingScreenVisibleCount();
              return;
            }

            // 共通ローダー:初期値セット(非表示)
            this.resetLoadingScreenVisibleCount();

            const afterSendCondition = DIALISYS_STATE.AFTER_SEND_CONDITION;
            const confirmedSendCondition = DIALISYS_STATE.CONFIRMED_SEND_CONDITION;
            const duringTreatment = DIALISYS_STATE.DURING_TREATMENT;
            const afterDrainage = DIALISYS_STATE.AFTER_DRAINAGE;

            if (userInfo.patId === null || userInfo.patId <= 0){
              // 通常は起こりえないが念のため施設スタッフがログインした際の挙動を指定
              // 初期表示メニューへ遷移
              this.goInitialFunctionPage();

              // 通知取得(未通知)
              this.getNotificationMessage();
            } else {
              // 患者の透析状態で遷移先画面を変更する
              const URL_BASE = "/pat_home_dialysis";
              ApiHelper.get(`${URL_BASE}/monitor/${userInfo.patId}`)
                .then(response => {
                  if (response.data.rst_dialysis_state === afterSendCondition ||
                      response.data.rst_dialysis_state === confirmedSendCondition ||
                      response.data.rst_dialysis_state === duringTreatment ||
                      response.data.rst_dialysis_state === afterDrainage){
                      // 透析状況モニタリング画面に遷移
                      this.$router.push({ name: "pat-home-dialysis-status" });
                  } else {
                    // 患者お知らせ画面に遷移
                    this.$router.push({ name: "pat-home-dialysis" });
                  }
                })
                .catch(error => {
                  //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
                  getErrorMessage('LoginViewHomeDialysis.vue','signIn',error);
                  //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
                  // console.log(error);
                  throw error;
                });
            }
          })();
        })
        .catch((error) => {
          //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
          getErrorMessage('LoginViewHomeDialysis.vue','signIn',error);
          //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
          this.setLoadingScreenVisible(false);
          this.alert();
        });
    },
    // 再描画イベント
    reload() {
      window.location.reload();
    },
    async created() {
      // 共通ローダー:開始画面のためリセット／表示名設定
      this.resetLoadingScreenVisibleCount();
      this.setLoadingScreenMessage("処理中・・・");
      // 接続に関する情報をApplicationStoreに登録
      const ntssProtocol = window.location.protocol;
      const ntssHost = window.location.host;
      const ntssPathName = window.location.pathname.substring(1);
      const hashedKey = this.$route.query.key
        ? this.$route.query.key
        : this.getKey;
      this.setState({
        protocol: ntssProtocol,
        host: ntssHost,
        pathname: ntssPathName,
        key: hashedKey
      });
    },
    // URL指定で呼び出された場合
    goSpecifyingPage() {
      const parameters = JSON.parse(JSON.stringify(this.$route.query));
      if (parameters.FUNC) {
        parameters.routerName = getRouterName(parameters.FUNC);
      }

      return this.moveTo(parameters);
    },
    // 初期表示メニューに遷移する
    goInitialFunctionPage() {
      this.$router.push({ name: getInitialRouterName() });
    },
    // エラーメッセージ表示
    alert() {
      if (this.hasApiError && !this.isAlerting) {
        // エラー保持状況フラグを更新
        const status = this.getApiResult().status;
        this.hasAuthError = status === 401 || status === 403;
        this.isAlerting = true;
        this.$nextTick(() => {
          const bkHasAuthError = this.hasAuthError;
          const alert = {
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
            // title: this.hasAuthError ? "認証エラー　アカウントロック" : "エラー",
            title: this.hasAuthError ? DIALOG_MESSAGES["00300007"].title : DIALOG_MESSAGES["00300008"].title,
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
            message: this.getApiResult().message,
            callback: () => {
              this.isAlerting = false;
              this.clearApiResult();
              this.hasAuthError = bkHasAuthError;
            }
          };
          this.$ons.notification.alert(alert);
        });
      }
    },
    // add by shiyw for 6119
    popstateEventListener(){
      history.pushState(null, null, null);
    }
  },
  created() {
    this.created();

    window.addEventListener('popstate', this.popstateEventListener);

    if (this.$route.query.USERID && this.$route.query.FUNC) {
      this.userId = this.$route.query.USERID;
      this.passwd = "_";
      this.$nextTick(() => {
        this.signIn();
      });
    }
  },
  mounted() {
    this.alert();
  },
  watch: {
    hasApiError() {
      this.alert();
    }
  },
  beforeDestroy() {
    window.removeEventListener('popstate', this.popstateEventListener);
  }
};
</script>

<style scoped>
/* ログイン画面のスタイル定義 */
.login-page {
  text-align: center;
  font-size: 10.5px;
  height: 100%;
  margin: 0px;
  box-shadow: none;
  border-radius: 0px;
  overflow: hidden;
  padding: 16px;
}

.login-page .panel {
  text-align: center;
  margin: 0 auto;
  width: 80%;
}

ons-col {
  text-align: left;
  width: inherit;
  margin: 10px;
}

ons-input {
  border: 0;
  padding: 0;
  color: #aaa;
  margin: 0;
  width: 100%;
  -webkit-border-radius: 5px;
  -moz-box-shadow: inset 0 0 4px rgba(0, 0, 0, 0.2);
  -moz-border-radius: 5px;
  -webkit-box-shadow: inset 0 0 4px rgba(0, 0, 0, 0.2);
  border-radius: 3px;
  box-shadow: inner 0 0 4px rgba(0, 0, 0, 0.2);
}
.img-icon {
  /* NTSSロゴアイコンの横幅 */
  width: 75%;
  height: auto;
  max-width: 310px;
}
.imgButton {
  border: 0;
  border-style: none;
  background: none;
  outline: none;
}
.button {
  width: 100%;
  margin: 0px 0px 10px 0px;
}

.p-error {
  text-align: center;
  color: red;
}
.error-link {
  text-align: center;
  display: block;
  font-size: x-small;
  margin: 20px 0px 0px 0px;
}
</style>
