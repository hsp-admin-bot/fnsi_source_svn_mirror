<template>
  <div class="login-page">
    <!-- ページのタイトル -->
    <div class="site-title">クライアント証明書管理</div>
    <div class="main-container">
      <div class="form-container">
        <!-- ログインタイトル -->
        <p id="login-title">ログイン</p>
        <div class="panel">
          <!-- ID フィールド -->
          <v-ons-row>
            <v-ons-col class="input-row">
              <label class="label" id="label-id" for="id">ID</label>
              <!-- ID入力 -->
              <v-ons-input
                input-id="id"
                name="id"
                type="text"
                maxlength="40"
                v-model="id"
                ref="id"
                @keydown.enter="setFocus('pwd')"
                float
                autofocus
                autocapitalize="off"
                v-validate="'required'"
                style="font-size:8px"
              ></v-ons-input>
            </v-ons-col>
          </v-ons-row>

          <!-- idフィールドのエラーを表示 -->
          <v-ons-row v-show="errors.has('id')">
            <div class="label"></div>
            <div class="error-message">
              <p v-show="errors.has('id')" class="p-message">
                {{ errors.first("id") }}
              </p>
            </div>
          </v-ons-row>
          <!-- パスワードフィールド -->
          <v-ons-row>
            <v-ons-col class="input-row">
              <!-- パスワードラベル -->
              <label class="label" id="pwd-label" for="pwd">PW</label>
              <!-- パスワード入力 -->
              <v-ons-input
                input-id="pwd"
                name="pwd"
                type="password"
                maxlength="40"
                v-model="pwd"
                ref="pwd"
                v-validate="validatePassFormat"
                @keydown.enter="signIn"
                float
                style="font-size:8px"
              ></v-ons-input>
            </v-ons-col>
          </v-ons-row>
          <!-- パスワードフィールドのエラーを表示 -->
          <v-ons-row v-show="errors.has('pwd')">
            <div class="label"></div>
            <div class="error-message">
              <p v-show="errors.has('pwd')" class="p-message">
                {{ errors.first("pwd") }}
              </p>
            </div>
          </v-ons-row>

          <!-- ログインボタン -->
          <v-ons-row>
            <div class="input-row">
              <label class="label"></label>
              <v-ons-col class="col-2">
                <div>
                  <button
                    class="button"
                    @click="signIn"
                    :disabled="!validation || isAlerting"
                    ref="signInButton"
                  >
                    ログイン
                  </button>
                </div>
              </v-ons-col>
            </div>
          </v-ons-row>

          <!-- 間違ったIDまたはパスワードでログインしたときのエラー -->
          <v-ons-row>
            <div class="input-row">
              <label class="label"></label>
              <v-ons-col>
                <div
                  class="error-massage"
                  id="error-massage"
                  v-if="hasAuthError"
                >
                  <p class="p-error" id="p-error">
                    認証情報が正しくありません。
                    <br />もう一度お試しください。
                  </p>
                </div>
              </v-ons-col>
            </div>
          </v-ons-row>
        </div>
        <!-- ローディング画面 -->
        <loading-screen />
      </div>
      <!-- 表示バージョン -->
      <div class="footer">
        Ver {{ parseFloat(userSetting.version).toFixed(1) }}
      </div>
    </div>
  </div>
</template>
<script>
import { mapActions, mapGetters } from "vuex";
import loadingScreen from "@/components/common/LoadingScreen";
export default {
  data() {
    return {
      id: "",
      pwd: "",
      hasAuthError: false,
      isAlerting: false
    };
  },

  components: {
    "loading-screen": loadingScreen
  },

  created() {
    document.title = "クライアント証明書管理";
    this.setLoadingScreenMessage("処理中・・・");
    this.resetLoadingScreenVisibleCount();
    this.getUserSetting();
  },

  computed: {
    ...mapGetters("cl-user", {
      userSetting: "getUserSetting"
    }),

    ...mapGetters("app", ["hasApiError", "getApiResult"]),

    ...mapGetters("user", ["isAdminUser", "isGeneralUser"]),

    ...mapGetters("loading-screen", ["getLoadingScreenVisible"]),

    //パスワードを検証する
    validatePassFormat() {
      return "required";
    },

    //ログインボタンのロックを解除する条件
    validation() {
      return this.isRequired && this.$validator.errors.items.length === 0;
    },

    //チェックIDとパスワードが空ではありません
    isRequired() {
      return this.id !== "" && this.pwd !== "";
    }
  },

  methods: {
    ...mapActions("user", {
      userSignIn: "signIn"
    }),

    ...mapActions("app", ["clearApiResult"]),

    ...mapActions("loading-screen", {
      setLoadingScreenVisible: "setLoadingScreenVisible",
      setLoadingScreenMessage: "setLoadingScreenMessage",
      resetLoadingScreenVisibleCount: "resetLoadingScreenVisibleCount"
    }),

    ...mapActions("cl-user", {
      getUserSetting: "getUserSetting"
    }),

    setFocus(ref) {
      this.$refs[ref].$el._input.focus();
    },

    // add #9199 CL証明書管理サイトのログインで認証失敗してもなにもメッセージが表示されない 20260403 start
    showLoginErrorAlert() {
      this.$ons.notification.alert({
        title: "認証エラー",
        message: "認証に失敗しました。認証情報を確認して下さい。",
        callback: () => {
          this.isAlerting = false;
          this.clearApiResult();
        }
      });
    },
    // add #9199 CL証明書管理サイトのログインで認証失敗してもなにもメッセージが表示されない 20260403 end

    //サインイン機能
    signIn() {
      if (!this.getLoadingScreenVisible && !this.isAlerting) {
        if (this.$refs.signInButton.disabled) {
          return;
        }
        this.setLoadingScreenVisible(true);
        const user = {
          userId: this.id,
          password: this.pwd,
          isUserLogin: true
        };
        this.userSignIn(user)
          .then(() => {
            if (this.isAdminUser || this.isGeneralUser) {
              this.resetLoadingScreenVisibleCount();
              this.$router.push({ name: "clManagementView" });
            }
          })
          .catch(() => {
            this.setLoadingScreenVisible(false);
            // add #9199 CL証明書管理サイトのログインで認証失敗してもなにもメッセージが表示されない 20260403 start
            this.showLoginErrorAlert();
            // add #9199 CL証明書管理サイトのログインで認証失敗してもなにもメッセージが表示されない 20260403 end
            this.alert();
          });
      }
    },

    alert() {
      if (this.hasApiError && !this.isAlerting) {
        // エラー保持状況フラグを更新
        const status = this.getApiResult.status;
        this.hasAuthError =
          (status === 401 &&
            this.getApiResult.message.includes("認証に失敗しました")) ||
          status === 403;
        this.isAlerting = true;
        this.$nextTick(() => {
          const alert = {
            title: this.hasAuthError ? "認証エラー" : "エラー",
            message: this.getApiResult.message,
            callback: () => {
              this.isAlerting = false;
              this.clearApiResult();
            }
          };
          this.$ons.notification.alert(alert);
        });
      }
    }
  },
  watch: {
    hasApiError() {
      this.alert();
    }
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
  background-color: #e8f7fb;
  /*add FNSI-【1006】最新の改修対象一覧.NO43を追加 周安寧 start*/
  min-height: 580px;
  /*add FNSI-【1006】最新の改修対象一覧.NO43を追加 周安寧 end*/
}
.footer {
  position: absolute;
  bottom: 1vh;
  /*add FNSI-【1006】最新の改修対象一覧.NO43を追加 周安寧 start*/
  /*right: 1vw;*/
  right: 4vw;
  /*add FNSI-【1006】最新の改修対象一覧.NO43を追加 周安寧 end*/
  font-size: 1rem;
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
  /*add FNSI-【1006】最新の改修対象一覧.NO43を追加 周安寧 start*/
  /*min-width: 500px;*/
  min-width: 350px;
  /*add FNSI-【1006】最新の改修対象一覧.NO43を追加 周安寧 end*/
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
  flex: 0 0 80%;
  max-width: 80%;
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
  flex: 0 0 20%;
  max-width: 20%;
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
/*del FNSI-【1006】最新の改修対象一覧.NO43を追加 周安寧 start*/
/* @media only screen and (max-width: 768px) {
  .login-page{
    font-size: 1.4em;
  }
  ons-input >>> .text-input {
    font-size: 1em;
  }
  .login-page .panel {
    text-align: left;
    margin: 0 auto;
    width: 95%;
  }
  .site-title {
    width: 100%;
    height: 10%;
    float: left;
    text-align: center;
    font-weight: bold;
    padding: 50px 0;
    font-size: 1em;
  }
  .form-container {
    width: 50%;
    margin: 0 auto;
    background-color: white;
    border-radius: 10px;
    padding: 10px;
    height: auto;
    min-width: 300px;
  }
  .label {
    flex: 0 0 22%;
    max-width: 22%;
  }
  ons-input {
    flex: 0 0 78%;
    max-width: 78%;
  }
  #login-title {
    font-size: 1em;
  }
} */
/*del FNSI-【1006】最新の改修対象一覧.NO43を追加 周安寧 end*/
</style>
