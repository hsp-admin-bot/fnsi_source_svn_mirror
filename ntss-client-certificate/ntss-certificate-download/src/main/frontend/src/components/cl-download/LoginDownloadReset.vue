<template>
  <div class="login-page">
    <!-- ログインタイトル -->
    <div class="site-title">クライアント証明書ダウロード</div>
    <div class="main-container">
      <!-- コンテンツを中央に配置するための「フォームコンテナ」の使用 -->
      <div class="form-container">
        <!-- 題名 -->
        <p id="login-title">パスワード変更</p>
        <div class="panel">
          <v-ons-row>
            <v-ons-col class="input-row">
              <!-- 施設パスワードラベル -->
              <label class="label" id="pwd-label">現在のPW</label>
              <!-- コンテンツを入力する入力タグ -->
              <!-- mod 6653修正 解 start  -->
              <!--
              <v-ons-input
                input-id="current-password"
                name="current-password"
                type="password"
                v-model="userPasswordCurrent"
                @keyup.enter="setFocus('password')"
                @blur="checkMatchCurrentPassword"
                v-validate="'required'"
                maxlength="40"
                ref="current-password"
                float
              ></v-ons-input>
              -->

              <v-ons-input
                input-id="current-password"
                name="current-password"
                type="password"
                v-model="userPasswordCurrent"
                @keyup.enter="setFocus('password')"
                @keyup="checkMatchCurrentPassword"
                @blur="checkOnblur"
                v-validate="'required'"
                maxlength="40"
                ref="current-password"
                float
              ></v-ons-input>
              <!-- mod 6653修正 解 end  -->
            </v-ons-col>
          </v-ons-row>
           <v-ons-row v-show="errors.has('current-password')">
            <div class="col-1"></div>
            <div class="col-2">
              <font color="red">
                <p class="error-message">{{ errors.first("current-password") }}</p>
              </font>
            </div>
          </v-ons-row>
          <!-- FSNI-#6653 フォーカスを抜けるタイミングでチェック処理に修正 ljx start -->
          <!--<v-ons-row v-show="isUserPasswordCurrent && !isCorrectCurrentPassword">-->
          <v-ons-row v-show="isUserPasswordCurrent && !isCorrectCurrentPassword && isOnBlur">
          <!-- FSNI-#6653 フォーカスを抜けるタイミングでチェック処理に修正 ljx start -->
            <div class="col-1"></div>
            <div class="col-2">
              <font color="red">
                <p class="error-message">現在のパスワードが一致しません。</p>
              </font>
            </div>
          </v-ons-row>
        <v-ons-row>
          <v-ons-col class="input-row">
            <!-- 施設パスワードラベル -->
            <label class="label" id="pwd-label">新しいPW</label>
            <!-- コンテンツを入力する入力タグ -->
            <v-ons-input
              input-id="password"
                name="password"
                type="password"
                maxlength="40"
                v-model="userPassword"
                ref="password"
                @keyup.enter="setFocus('confirm-password')"
                v-validate="passwordCondition"
                float
            ></v-ons-input>
          </v-ons-col>
      </v-ons-row>
      <!-- パスワード証明書エラーを表示 -->
      <v-ons-row v-show="errors.has('password')">
        <div class="col-1"></div>
        <div class="col-2">
          <font color="red">
            <p class="error-message">{{ errors.first("password") }}</p>
          </font>
        </div>
      </v-ons-row>
      <!--  パスワード証明書パスワード確認 -->
      <v-ons-row>
        <v-ons-col class="input-row">
          <!-- 施設パスワードラベル -->
          <label class="label" id="pwd-label" >PWの再入力</label>
          <!-- コンテンツを入力する入力タグ -->
          <v-ons-input
              input-id="confirm-password"
              name="confirm-password"
              type="password"
              maxlength="40"
              v-model="userPasswordConfirm"
              ref="confirm-password"
              data-vv-as="PWの再入力"
              v-validate="passwordConfirm"
              @keyup.enter="registration"
              float
            ></v-ons-input>
        </v-ons-col>
      </v-ons-row>
      <!-- パスワード証明書パスワード確認エラーを表示 -->
      <v-ons-row v-show="errors.has('confirm-password')">
        <div class="col-1"></div>
        <div class="col-2">
          <font color="red">
            <p class="error-message">{{ errors.first("confirm-password") }}</p>
          </font>
        </div>
      </v-ons-row>
      <!-- キャンセルボタン -->
      <v-ons-row>
        <div class="col-btn-1"></div>
        <div class="col-btn-2">
          <v-ons-col id="addClCol">
            <div class="btn-container">
              <button
                class="button cancel-btn"
                ref="cancelButton"
                @click="cancel()"
              >
                キャンセル
              </button>
              <button
                class="button ok-btn"
                @click="registration"
                ref="addClButton"
                :disabled="!canSave "
              >
                OK
              </button>
            </div>
          </v-ons-col>
        </div>
      </v-ons-row>
     </div>
    </div>
  </div>
    <!-- ローディング画面 -->
    <loading-screen />
  </div>
</template>
<script>
import { mapActions, mapGetters } from "vuex";
import loadingScreen from "@/components/common/LoadingScreen";
import { ApiHelper } from "@/apis/AxiosHelper";
export default {
  data() {
    return {
      userPassword: "",
      userPasswordConfirm: "",
      userPasswordCurrent: "",
      isCorrectCurrentPassword: false,
      isAlerting: false,
      isOnBlur: false,
    };
  },

  created() {
    document.title = "クライアント証明書ダウンロード";
    this.setFacilitySetting();
  },

  components: {
    "loading-screen": loadingScreen
  },
  computed: {
    ...mapGetters("user", ["isFacilityRole"]),

    ...mapGetters("app", ["hasApiError", "getApiResult"]),

    ...mapGetters("loading-screen", ["getLoadingScreenVisible"]),

    ...mapGetters("cl-facility", ["getFacilitySetting"]),

    ...mapGetters("cl-facility", ["getProvisional","getFacilityCd"]),

     /**
     * 仮登録フラグの取得.
     * @return 仮登録の場合、true
     */
    isProvisional() {
      return this.getProvisional === 1;
    },

    isUserPasswordCurrent() {
      return this.userPasswordCurrent.length > 0;
    },
    //証明書パスワードの条件検証
    passwordCondition() {
      return "required|min:" + this.getFacilitySetting.passwordMin+"|max:40"
    },
    passwordConfirm() {
      return "required|min:" + this.getFacilitySetting.passwordMin+"|max:40|confirmed:password"
    },
    // 必要な入力をすべて確認してください
    canSave() {
         return (
          this.userPasswordCurrent.length !== 0 >=
          this.getFacilitySetting.passwordMin
          && this.userPassword.length !== 0 && this.userPassword.length >=
          this.getFacilitySetting.passwordMin
          && this.userPasswordConfirm.length !== 0 && this.userPasswordConfirm.length >=
          this.getFacilitySetting.passwordMin && this.isCorrectCurrentPassword &&
          this.userPassword === this.userPasswordConfirm )
    },
  },
  methods: {
    ...mapActions("loading-screen", {
      setLoadingScreenVisible: "setLoadingScreenVisible",
      setLoadingScreenMessage: "setLoadingScreenMessage",
      resetLoadingScreenVisibleCount: "resetLoadingScreenVisibleCount"
    }),

    ...mapActions("app", ["clearApiResult"]),

    ...mapActions("user", {
      userSignIn: "signIn"
    }),
    ...mapActions("user", {
      signOut: "signOut"
    }),

    ...mapActions("cl-facility", ["setFacilitySetting"]),

    setFocus(ref) {
      this.$refs[ref].$el._input.focus();
    },

    checkOnblur(){
      this.isOnBlur = true;
    },
    /**
         * 処理：入力された現在のパスワードをチェック
         */
    async checkMatchCurrentPassword() {
      const params = {
        facilityCd: this.getFacilityCd,
        CurrentPassword: this.userPasswordCurrent
      }
      await ApiHelper.get("/cl-facility/checkMatchCurrentPassword", params)
        .then(response => {
          this.isCorrectCurrentPassword = response.data;
        });
      //add FSNI-#6653 フォーカスを抜けるタイミングでチェック処理に修正 ljx start
      this.isOnBlur = false;
      //add FSNI-#6653 フォーカスを抜けるタイミングでチェック処理に修正 ljx end
    },

    /**
     * 処理：入力された情報でアカウント情報登録(更新)
     */
    async registration() {

      if (!this.canSave) {
        return;
      }
      // 共通ローダー:表示開始
      this.setLoadingScreenVisible(true);
      // 仮登録ユーザーのみ：パスワードポリシーチェック
      if(this.isProvisional){
        // APIコールパラメータセット
        const request = {
          facilityCd: this.getFacilityCd,
          facilityPassword: this.userPassword
        };
        // 更新処理呼び出し
        await ApiHelper.put("/cl-facility/updateProvisional", request)
          .then(() => {
                  // 共通ローダー:表示開始
            this.setLoadingScreenVisible(false);
            this.$router.push({ name: "ClCertificateDownload" });
          })
          .catch(error => {
            if (error.response.status === 400) {
              // 共通ローダー:表示終了
              this.setLoadingScreenVisible(false);
              let message = error.response.data.errorMessage;
              if (message != null) {
                message = message.replace("\n", "<br/>");
              }
              this.$ons.notification.alert({
                title: "更新に失敗しました。",
                message
              });
              //再度実行できるためEnterキー押下回数を初期化する
              this.confirmEnterCountnter = 0;
               // サインアウト
              this.Logout();
            }
        });
      }
    },
    alert() {
      if (this.hasApiError && !this.isAlerting) {
        // エラー保持状況フラグを更新
        this.isAlerting = true;
        this.$nextTick(() => {
          const alert = {
            title: "エラー",
            message: this.getApiResult.message,
            callback: () => {
              this.isAlerting = false;
              this.clearApiResult();
            }
          };
          this.$ons.notification.alert(alert);
        });
      }
    },
    cancel() {
      this.signOut();
      this.$router.push({ name: "clDownloadLogin" });
    },
  }
};
</script>
<style scoped>
.login-page {
  text-align: center;
  font-size: 15px;
  height: 100%;
  margin: 0px;
  box-shadow: none;
  border-radius: 0px;
  overflow: hidden;
  padding: 0;
  background-color: rgb(240, 242, 243);
  min-height: 580px;
}
.site-title {
  width: 100%;
  height: 20%;
  float: left;
  text-align: center;
  font-size: 2em;
  font-weight: bold;
  padding: 50px 0;
}
.form-container {
  width: 30%;
  margin: 0 auto;
  background-color: white;
  border-radius: 10px;
  padding: 10px;
  height: auto;
  min-width: 400px;
}
.main-container {
  width: 100%;
  height: auto;
  float: left;
}
.login-page .panel {
  text-align: left;
  margin: 0 auto;
  width: 80%;
}
ons-col {
  width: inherit;
  margin: 10px;
  max-width: auto;
}

ons-input {
  border: 0;
  padding: 0;
  color: #aaa;
  border: solid 1px #ccc;
  -webkit-border-radius: 5px;
  -moz-box-shadow: inset 0 0 4px rgba(0, 0, 0, 0.2);
  -moz-border-radius: 5px;
  -webkit-box-shadow: inset 0 0 4px rgba(0, 0, 0, 0.2);
  border-radius: 3px;
  box-shadow: inner 0 0 4px rgba(0, 0, 0, 0.2);
  float: right;
  flex: 0 0 70%;
  max-width: 70%;
}
ons-input >>> .text-input {
  font-size: 1.7em;
  width: 100%;
}
.p-error {
  text-align: start;
  color: red;
  margin: 0px;
}
.error-link {
  text-align: center;
  display: block;
  font-size: x-small;
  margin: 20px 0px 0px 0px;
}
#login-title {
  font-size: 2em;
  font-weight: bold;
}
.button {
  width: 50%;
}
.input-row {
  display: flex;
  width: 100%;
}
.label {
  flex: 0 0 30%;
  max-width: 30%;
  align-items: center;
  justify-content: left;
  display: flex;
}
#p-error {
  text-align: center;
}

.col-1 {
  width: 4vw;
}

.col-2 {
  text-align: center;
}

.col-btn-1 {
  margin-top: 20px;
  float: left;
  width: 30%;
}
.col-btn-2 {
  margin-top: 20px;
  float: left;
  width: 70%;
  text-align: left;
}
.btn-container {
  display: flex;
  justify-content: flex-end;
  width: 100%;
}

.ok-btn {
  margin-left: 10%;
  margin-right: 10px;
  width: 150px;
}
.cancel-btn {
  font-size: 15px;
  width: 150px;
}
#addClCol {
  text-align: end;
  width: 100%;
  margin: 0;
}
</style>
