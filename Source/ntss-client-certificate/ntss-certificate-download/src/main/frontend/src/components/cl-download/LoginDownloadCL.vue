<template>
  <div class="login-page">
    <!-- ログインタイトル -->
    <div class="site-title">クライアント証明書ダウロード</div>
    <div class="main-container">
      <!-- コンテンツを中央に配置するための「フォームコンテナ」の使用 -->
      <div class="form-container">
        <!-- 題名 -->
        <p id="login-title">ログイン</p>
        <div class="panel">
          <form @submit.prevent>
          <v-ons-row>
            <v-ons-col>
              <div class="input-row">
                <!-- 施設ラベル -->
                <label class="label" id="label-id" for="id">施設ID</label>
                <!-- コンテンツを入力する入力タグ -->
                <v-ons-input
                  input-id="id"
                  type="text"
                  v-model="id"
                  name="id"
                  ref="id"
                  maxlength="40"
                  @keydown.enter="setFocus('pwd')"
                  float
                  autofocus
                  autocapitalize="off"
                  v-validate="'required'"
                  style="font-size:8px;"
                ></v-ons-input>
              </div>
            </v-ons-col>
          </v-ons-row>

          <!-- idフィールドのエラーを表示 -->
          <v-ons-row v-if="errors.has('id')">
            <label class="label"></label>
            <v-ons-col>
              <div class="error-message">
                <p class="p-error">{{ errors.first("id") }}</p>
              </div>
            </v-ons-col>
          </v-ons-row>
          <v-ons-row>
            <v-ons-col class="input-row">
              <!-- 施設パスワードラベル -->
              <label class="label" id="pwd-label" for="pwd">施設PW</label>
              <!-- コンテンツを入力する入力タグ -->
              <v-ons-input
                input-id="pwd"
                type="password"
                v-model="pwd"
                autocomplete="current-password"
                maxlength="40"
                name="password"
                ref="pwd"
                @keydown.enter="signIn"
                float
                v-validate="passwordCondition"
                style="font-size:8px;"
              ></v-ons-input>
            </v-ons-col>
          </v-ons-row>
          <!-- パスワードフィールドのエラーを表示 -->
          <v-ons-row v-if="errors.has('password')">
            <label class="label"></label>
            <v-ons-col>
              <div class="error-message">
                <p class="p-error">{{ errors.first("password") }}</p>
              </div>
            </v-ons-col>
          </v-ons-row>

          <!-- ログインボタン -->

          <v-ons-row>
            <div class="input-row">
              <label class="label"></label>
              <v-ons-col class="col-2">
                <button
                  class="button"
                  @click="signIn"
                  :disabled="!validation || isAlerting"
                  ref="signInButton"
                >
                  ログイン
                </button>
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
                </div>
              </v-ons-col>
            </div>
          </v-ons-row>
          </form>
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
      id: "",
      pwd: "",
      hasAuthError: false,
      isAlerting: false
    };
  },

  created() {
    document.title = "クライアント証明書ダウンロード";
    this.setFacilitySetting();
    //add FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 start

    if (this.$route.query.key !== undefined) {
       this.id = this.$route.query.key
    }
    //add FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 end
  },

  components: {
    "loading-screen": loadingScreen
  },
  computed: {
    ...mapGetters("user", ["isFacilityRole"]),

    ...mapGetters("app", ["hasApiError", "getApiResult"]),

    ...mapGetters("loading-screen", ["getLoadingScreenVisible"]),

    ...mapGetters("cl-facility", ["getFacilitySetting"]),
    //パスワードとIDが空でない場合は「true」を返します
    validation() {
      return this.validateId && this.validatePassword;
    },

    //検証IDが空ではありません
    validateId() {
      if (this.id.length === 0 || this.id.trim().length === 0) {
        return false;
      }
      return true;
    },

    //パスワードが空ではないことを検証する
    validatePassword() {
      if (
        this.pwd.length === 0 ||
        this.pwd.trim().length === 0 ||
        this.pwd.length < this.getFacilitySetting.passwordMin
      ) {
        return false;
      }
      return true;
    },

    passwordCondition() {
      return "required";
    }
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

    ...mapActions("cl-facility", ["setFacilitySetting"]),
    //add FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 start
    ...mapActions("cl-facility", ["setProvisional"]),
    //add FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 end
    setFocus(ref) {
      this.$refs[ref].$el._input.focus();
    },

    //ログイン機能
    async signIn() {
      if (!this.getLoadingScreenVisible && !this.isAlerting) {
        if (this.$refs.signInButton.disabled) {
          return;
        }
        this.setLoadingScreenVisible(true);
        const user = {
          userId: this.id,
          password: this.pwd,
          isUserLogin: false
        };

        this.userSignIn(user)
          .then(() => {
            if (this.isFacilityRole) {
              this.resetLoadingScreenVisibleCount();
              //mod FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 start
              // 仮登録
              ApiHelper.get("/cl-facility/getProvisional?facilityCd="+ user.userId)
              .then(res => {
                const isProvisional = res.data.isProvisional === 1;
                this.setProvisional(res.data)
                  if(isProvisional) {
                    this.$router.push({ name: "LoginDownloadReset" });
                    return
                  } else {
                    this.$router.push({ name: "ClCertificateDownload" });
                  }
              //mod FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 end
              });
            }
          })
          .catch(() => {
            this.setLoadingScreenVisible(false);
            this.alert();
          });
      }
    },

    alert() {
      if (this.hasApiError && !this.isAlerting) {
        // エラー保持状況フラグを更新
        const status = this.getApiResult.status;
        this.hasAuthError = (status === 401);
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
  /*add FNSI-【1006】最新の改修対象一覧.NO43を追加 周安寧 start*/
  min-height: 580px;
  /*add FNSI-【1006】最新の改修対象一覧.NO43を追加 周安寧 end*/
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
  /*mod FNSI-【1006】最新の改修対象一覧.NO43を追加 周安寧 start*/
  /*min-width: 500px;*/
  min-width: 400px;
  /*mod FNSI-【1006】最新の改修対象一覧.NO43を追加 周安寧 end*/
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
ons-input :deep(.text-input) {
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
/*del FNSI-【1006】最新の改修対象一覧.NO43を追加 周安寧 start
/*@media only screen and (max-width: 768px) {
  .login-page{
    font-size: 1.4em;
  }
  ons-input :deep(.text-input) {
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
}*/
/*del FNSI-【1006】最新の改修対象一覧.NO43を追加 周安寧 end */
</style>
