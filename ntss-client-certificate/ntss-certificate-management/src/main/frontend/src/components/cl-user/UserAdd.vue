<template>
  <div class="user-add-page">
    <!-- 題名 -->
    <p id="user-add-title">ユーザー追加・編集</p>
    <div class="panel">
      <!-- 氏名 -->
      <v-ons-row>
        <v-ons-col>
          <div class="col-1">
            <label id="user-name-label" for="user-name">氏名:</label>
          </div>
          <div class="col-2">
            <v-ons-input
              input-id="user-name"
              name="modalUserCondition.userName"
              type="text"
              maxlength="40"
              v-model="userName"
              ref="user-name"
              @keydown.enter="setFocus('user-id')"
              v-validate="'required'"
              float
              autofocus
            ></v-ons-input>
          </div>
        </v-ons-col>
      </v-ons-row>
      <v-ons-row v-show="errors.has('modalUserCondition.userName')">
        <div class="col-1"></div>
        <div class="col-2">
          <p
            v-show="errors.has('modalUserCondition.userName')"
            class="error-message"
          >
            {{ errors.first("modalUserCondition.userName") }}
          </p>
        </div>
      </v-ons-row>
      <!-- ID -->
      <v-ons-row>
        <v-ons-col>
          <div class="col-1">
            <label id="user-id-label" for="user-id">ID:</label>
          </div>
          <div class="col-2">
            <v-ons-input
              input-id="user-id"
              name="modalUserCondition.userId"
              :disabled="modalUserCondition.isUpdtFunction"
              type="text"
              maxlength="40"
              v-model="userId"
              ref="user-id"
              @keydown.enter="setFocus('user-department')"
              v-validate="'required|regex:^[A-Za-z0-9]+$'"
              float
            ></v-ons-input>
          </div>
        </v-ons-col>
      </v-ons-row>
      <v-ons-row v-show="errors.has('modalUserCondition.userId')">
        <div class="col-1"></div>
        <div class="col-2">
          <p
            v-show="errors.has('modalUserCondition.userId')"
            class="error-message"
          >
            {{ errors.first("modalUserCondition.userId") }}
          </p>
        </div>
      </v-ons-row>
      <!-- 部署 -->
      <v-ons-row>
        <v-ons-col>
          <div class="col-1">
            <label id="user-department-label" for="user-department"
              >部署:
            </label>
          </div>
          <div class="col-2">
            <v-ons-input
              style="width: 100%"
              input-id="user-department"
              type="text"
              maxlength="40"
              name="modalUserCondition.departmentCd"
              v-model="userDepartment"
              ref="user-department"
              @keydown.enter="setFocus('user-pass')"
              v-validate="'required'"
              float
            ></v-ons-input>
          </div>
        </v-ons-col>
      </v-ons-row>
      <v-ons-row v-show="errors.has('modalUserCondition.departmentCd')">
        <div class="col-1"></div>
        <div class="col-2">
          <p
            v-show="errors.has('modalUserCondition.departmentCd')"
            class="error-message"
          >
            {{ errors.first("modalUserCondition.departmentCd") }}
          </p>
        </div>
      </v-ons-row>
      <!-- 権限 -->
      <v-ons-row>
        <v-ons-col>
          <div class="col-1">
            <label id="user-role-label" for="user-role">権限:</label>
          </div>
          <div class="col-2">
            <v-ons-list>
                  <v-ons-select
                    style="width: 100%"
                    v-validate="'required'"
                    input-id="user-role"
                    name="modalUserCondition.userRole"
                    v-model="selectedUserRole"
                    @change="setUserRole($event)"
                    ref="user-role"
                    float
                  >
                    <option v-for="role in roles" :key="role" :value="role">
                      {{ role }}
                    </option>
                  </v-ons-select>
            </v-ons-list>
          </div>
        </v-ons-col>
      </v-ons-row>
      <v-ons-row v-show="errors.has('modalUserCondition.userRole')">
        <div class="col-1"></div>
        <div class="col-2">
          <p
            v-show="errors.has('modalUserCondition.userRole')"
            class="error-message"
          >
            {{ errors.first("modalUserCondition.userRole") }}
          </p>
        </div>
      </v-ons-row>
      <!-- 部署 -->
      <v-ons-row>
        <v-ons-col>
          <div class="col-1">
            <label id="user-pass-label" for="user-pass">PW:</label>
          </div>
          <div class="col-2">
            <v-ons-input
              style="width: 100%"
              input-id="user-pass"
              type="password"
              maxlength="40"
              name="modalUserCondition.userPass"
              @focus="editUserPass"
              v-model="userPassword"
              ref="userPass"
              v-validate="validatePassFormat"
              @keydown.enter="setFocus('password-confirm')"
              float
            ></v-ons-input>
          </div>
        </v-ons-col>
      </v-ons-row>
      <!-- パスワードフィールドのエラーを表示 -->
      <v-ons-row v-show="errors.has('modalUserCondition.userPass')">
        <div class="col-1"></div>
        <div class="col-2">
          <p
            v-show="errors.has('modalUserCondition.userPass')"
            class="error-message"
          >
            {{ errors.first("modalUserCondition.userPass") }}
          </p>
        </div>
      </v-ons-row>
      <!--del FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 start-->
      <!-- パスワードの確認フィールド -->
      <!-- <v-ons-row>
        <v-ons-col>
          <div class="col-1">
            <label id="user-pwd-confirm-label" for="user-pass">PW確認:</label>
          </div>
          <div class="col-2">
            <v-ons-input
              style="width: 100%"
              input-id="password-confirm"
              type="password"
              maxlength="40"
              name="パスワード確認"
              v-model="confirmPassword"
              ref="password-confirm"
              v-validate="'confirmed:userPass'"
              @keydown.enter="addOrEditUser"
              float
            ></v-ons-input>
          </div>  
        </v-ons-col>
      </v-ons-row> -->
      <!-- パスワード確認フィールドのエラーを表示 -->
      <!-- <v-ons-row v-show="errors.has('パスワード確認')">
        <div class="col-1"></div>
        <div class="col-2">
          <p v-show="errors.has('パスワード確認')" class="error-message">
            {{ errors.first("パスワード確認") }}
          </p>
        </div>
      </v-ons-row> -->
      <!--del FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 start-->
      <!-- キャンセルボタン -->
      <v-ons-row>
        <div class="footer-col-1"></div>
        <div class="footer-col-2">
          <v-ons-col id="addUserCol">
            <div class="btn-container">
              <button
                class="button cancel-btn"
                ref="cancelButton"
                @click="closeModal"
              >
                キャンセル
              </button>
              <button
                class="button ok-btn"
                @click="addOrEditUser"
                ref="addOrEditUserButton"
                :disabled="!canSave || isAlerting"
              >
                OK
              </button>
            </div>
          </v-ons-col>
        </div>
      </v-ons-row>
    </div>
    <loading-screen />
  </div>
</template>
<script>
import { mapActions, mapGetters, mapMutations } from "vuex";
import loadingScreen from "@/components/common/LoadingScreen";
export default {
  props: ["passMin"], //親コンポーネントからの最小パスワード
  data() {
    return {
      roles: ["管理者", "ユーザー"], //役割のリスト
      isAlerting: false,
      isCheck:false
    };
  },
  computed: {
    ...mapGetters("cl-user", {
      modalUserCondition: "getModalUserCondition",
      getConfirmPassword: "getConfirmPassword",

    }),

    ...mapGetters("app", ["hasApiError", "getApiResult"]),

    ...mapGetters("user", ["getUserId"]),

    userName: {
      get() {
        return this.modalUserCondition.userName;
      },
      set(value) {
        this.setUserNameByValue(value);
      }
    },

    userId: {
      get() {
        return this.modalUserCondition.userId;
      },
      set(value) {
        this.setUserIdByValue(value);
      }
    },

    userPassword: {
      get() {
        return this.modalUserCondition.userPass;
      },
      set(value) {
        this.setUserPasswordByValue(value);
      }
    },

    confirmPassword: {
      get() {
        return this.getConfirmPassword;
      }, 
      set(value) {
        this.setConfirmPassword(value);
      }
    },

    userDepartment: {
      get() {
        return this.modalUserCondition.departmentCd;
      },
      set(value) {
        this.setUserDepartmentByValue(value);
      }
    },

    selectedUserRole: {
      get() {
        return this.modalUserCondition.userRole;
      },
      set(value) {
        this.setUserRoleState(value);
      }
    },

    //パスワードの条件検証
    validatePassFormat() {
      if (this.isUpdtFunction) return "required|min:" + this.passMin;
      else return "required|min:" + this.passMin;
    },

    //関数が更新関数かどうかを確認します
    isUpdtFunction() {
      return this.modalUserCondition.isUpdtFunction;
    },

    //必要な入力をすべて確認してください
    isRequired() {
      //mod FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 start
      // let result =
      //   this.modalUserCondition.userId !== "" &&
      //   this.modalUserCondition.userName !== "" &&
      //   this.modalUserCondition.departmentCd !== "" &&
      //   this.modalUserCondition.userRole !== "" && this.modalUserCondition.userPass === this.confirmPassword;
        
      // if (!this.modalUserCondition.isUpdtFunction)
      //   return result && this.modalUserCondition.userPass !== ""  && this.modalUserCondition.userPass === this.confirmPassword;
      // else return result ;
      let result =
        this.modalUserCondition.userId !== "" &&
        this.modalUserCondition.userName !== "" &&
        this.modalUserCondition.departmentCd !== "" &&
        this.modalUserCondition.userRole !== "" ; 
      if (!this.modalUserCondition.isUpdtFunction || this.isCheck)
        return result && this.modalUserCondition.userPass !== ""  ;
      else 
       return result ;
      //add FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 mod
    },

    canSave() {
      return (
        this.isRequired &&
        this.$validator.errors.items.filter( 
          e => e.field.includes("modalUserCondition") > 0
        ).length === 0
      );
    },

    getUserRole() {
      return this.modalUserCondition.userRole;
    }
  },

  components: {
    "loading-screen": loadingScreen
  },
  methods: {
    ...mapActions("loading-screen", {
      setLoadingScreenVisible: "setLoadingScreenVisible",
      setLoadingScreenMessage: "setLoadingScreenMessage",
      resetLoadingScreenVisibleCount: "resetLoadingScreenVisibleCount"
    }),

    ...mapActions("cl-user", [
      "setModalUserVisible",
      "insertUser",
      "clearModalUserState",
      "updateUser"
    ]),

    ...mapMutations("cl-user", {
      setUserIdState: "setUserIdState",
      setUserNameState: "setUserNameState",
      setUserRoleState: "setUserRoleState",
      setUserDepartmentState: "setUserDepartmentState",
      setUserPasswordState: "setUserPasswordState",
      setConfirmPassword: "setConfirmPassword"
    }),

    ...mapActions("app", ["clearApiResult"]),

    ...mapActions("user", ["setUserName"]),

    setFocus(ref) {
      this.$refs[ref].$el._input.focus();
    },

    async addOrEditUser() {
      if (this.$refs.addOrEditUserButton.disabled) {
        return;
      }
      if (!this.modalUserCondition.isUpdtFunction) {
        this.setLoadingScreenVisible(true);

        this.insertUser()
          .then(() => {
            this.resetLoadingScreenVisibleCount();
          })
          .catch(error => {
            this.setLoadingScreenVisible(false);
            if (error.response.data === "duplicated") {
              if (!this.isAlerting) {
                // エラー保持状況フラグを更新
                this.isAlerting = true;
                this.$nextTick(() => {
                  const alert = {
                    title: "エラー",
                    message: "IDは既に存在します。",
                    callback: () => {
                      this.isAlerting = false;
                      this.clearApiResult();
                    }
                  };
                  this.$ons.notification.alert(alert);
                });
              }
            } else {
              this.alert();
            }
          });
      } else {
        this.setLoadingScreenVisible(true);

        this.updateUser()
          .then(() => {
            if (this.userId === this.getUserId) {
              this.setUserName(this.userName);
            }
            this.clearModalUserState();
            this.resetLoadingScreenVisibleCount();
          })
          .catch(() => {
            this.setLoadingScreenVisible(false);
            this.alert();
          });
      }
      this.clearError();
    },

    clearError() {
      this.$validator.reset();
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

    closeModal() {
      this.setModalUserVisible(false);
      this.clearModalUserState();
      this.clearError();
    },

    onBlur() {
      if (this.$refs["user-name"]) this.$refs["user-name"].$el._input.value = "";
      if (this.$refs["user-department"]) this.$refs["user-department"].$el._input.value = "";
      if (this.$refs["userPass"]) this.$refs["userPass"].$el._input.value = "";
      if (this.$refs["user-id"]) this.$refs["user-id"].$el._input.value = "";
      if (this.$refs["password-confirm"]) this.$refs["password-confirm"].$el._input.value = "";
    },
    editUserPass(){
      if (this.modalUserCondition.isUpdtFunction){
         this.modalUserCondition.userPass = "";
      }
      this.isCheck = true
    },
    setUserRole(event) {
      this.setUserRoleState(event.target.value);
    },

    setUserIdByValue(value) {
      this.setUserIdState(value);
    },

    setUserNameByValue(value) {
      this.setUserNameState(value);
    },

    setUserRoleByValue(value) {
      this.setUserRoleState(value);
    },

    setUserDepartmentByValue(value) {
      this.setUserDepartmentState(value);
    },

    setUserPasswordByValue(value) {
      this.setUserPasswordState(value);
    }
  },
  created() {
    this.setLoadingScreenMessage("処理中・・・");
    this.resetLoadingScreenVisibleCount();
  }
};
</script>
<style scoped>
.user-add-page {
  background-color: aliceblue;
  text-align: center;
  font-size: 10.5px;
  margin: 0px;
  box-shadow: none;
  border-radius: 10px;
  padding: 16px;
}
.user-add-page .panel {
  text-align: left;
  margin: 0 auto;
  width: 80%;
}
ons-col {
  width: inherit;
  margin: 10px;
}

ons-input {
  border: 0;
  padding: 0;
  color: #aaa;
  border: solid 1px #ccc;
  margin: 0;
  width: 100%;
  -webkit-border-radius: 5px;
  -moz-box-shadow: inset 0 0 4px rgba(0, 0, 0, 0.2);
  -moz-border-radius: 5px;
  -webkit-box-shadow: inset 0 0 4px rgba(0, 0, 0, 0.2);
  border-radius: 3px;
  box-shadow: inner 0 0 4px rgba(0, 0, 0, 0.2);
}

ons-radio {
  border: 0;
  padding: 0;
  color: #aaa;
  border: solid 1px #ccc;
  margin: 0;
  width: 100%;
  -webkit-border-radius: 5px;
  -moz-box-shadow: inset 0 0 4px rgba(0, 0, 0, 0.2);
  -moz-border-radius: 5px;
  -webkit-box-shadow: inset 0 0 4px rgba(0, 0, 0, 0.2);
  border-radius: 3px;
  box-shadow: inner 0 0 4px rgba(0, 0, 0, 0.2);
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
#user-add-title {
  /*mod FNSI-【1006】最新の改修対象一覧.NO49を追加 周安寧 start */
  /*font-size: 2em;*/
  font-size: 3em;
  font-weight: bolder;
  /*mod FNSI-【1006】最新の改修対象一覧.NO49を追加 周安寧 end */
  color: rgb(118, 113, 113);
}
.button {
  width: 150px;
  margin: 0 0 10px 0;
}
label {
  width: 50px;
}
#addUserCol {
  text-align: end;
  width: 100%;
}
.error-message {
  margin: 10px;
}

.col-1 {
  color: rgb(118, 113, 113);
  font-size: 1.5em;
  padding: 5px 0;
  width: 20%;
  float: left;
}

.col-2 {
  color: rgb(118, 113, 113);
  width: 80%;
  float: left;
}
.footer-col-1 {
  font-size: 1.5em;
  padding: 5px 0;
  width: 20%;
  float: left;
}
.footer-col-2 {
    width: 80%;
    float: left;
} 
.btn-container {
  box-sizing: border-box;
  display: flex;
  justify-content: flex-end;
}

.ok-btn {
  margin-left: 10%;
  margin-right: 15px;
}

.list {
  border-left: 0.5px solid #ccc;
  border-right: 0.5px solid #ccc;
}
 /* @media only screen and (max-width: 900px) {
  #cl-add-title {
    font-size: 15px;
  }
  .panel {
    font-size: 10px;
  }
  .footer-col-2 {
    width: 100%;
  }
  .btn-container {
    width: 100%;
  }
  .ok-btn {
    font-size: 15px;
    width: 48%;
    margin-left: 10%;
  }
  .cancel-btn {
    font-size: 15px;
    width: 48%;
  }
  .footer-col-1 {
    width: 0;
  }
  label {
    font-size: 1em;
  }
  .col-2 {
    width: 65%;
  }
  .col-1 {
    width: 30%;
  }
}  */
</style>
