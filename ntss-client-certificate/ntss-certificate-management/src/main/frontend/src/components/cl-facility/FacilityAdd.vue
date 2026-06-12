<template>
  <div class="facility-add-page">
    <!-- 題名 -->
    <p id="facility-add-title">施設編集</p>
    <div class="panel">
      <form @submit.prevent>
      <!-- 施設名 -->
      <v-ons-row>
        <v-ons-col>
          <div>
            <div id="facility-name-label" for="facility-name" class="label">
              <span>施設名:</span>
            </div>
            <div class="col-2">
              <span>{{ modalFacilityCondition.facilityName }}</span>
            </div>
          </div>
        </v-ons-col>
      </v-ons-row>
      <!-- 施設ID -->
      <v-ons-row>
        <v-ons-col>
            <div id="facility-id-label" for="facility-id" class="label">
              <span>施設コード:</span>
            </div>
            <div class="col-2">
              <span>{{ modalFacilityCondition.facilityCd }}</span>
            </div>
        </v-ons-col>
      </v-ons-row>
      <!-- 施設PW -->
      <v-ons-row>
        <v-ons-col>
          <div id="facility-pwd-label" for="facility-pwd" class="label">
            <span>施設PW:</span>
          </div>
          <div class="col-2">
            <v-ons-input
              input-id="facility-pwd"
              name="facilityPassword"
              type="password"
              autocomplete="new-password"
              maxlength="40"
              v-model="facilityPassword"
              ref="facilityPwd"
              @keydown.enter="setFocus('facility-pwd-confirm')"
              v-validate="passwordCondition"
              float
            ></v-ons-input>
          </div>
        </v-ons-col>
      </v-ons-row>
      <!-- ファシリティパスワードエラーを表示 -->
      <v-ons-row v-show="errors.has('facilityPassword')">
        <div class="label"></div>
        <div class="col-2">
          <p v-show="errors.has('facilityPassword')" class="error-message">
            {{ errors.first("facilityPassword") }}
          </p>
        </div>
      </v-ons-row>
      <!--施設パスワード確認フィールド -->
      <v-ons-row>
        <v-ons-col>
          <div id="facility-pwd-label" for="facility-pwd-confirm" class="label">
            <span>PW確認:</span>
          </div>
          <div class="col-2">
            <v-ons-input
              input-id="facility-pwd-confirm"
              name="パスワード確認"
              type="password"
              autocomplete="new-password"
              maxlength="40"
              v-model="facilityPwdConfirm"
              ref="facility-pwd-confirm"
              @keydown.enter="addOrEditFacility"
              v-validate="'confirmed:facilityPwd|required'"
              float
            ></v-ons-input>
          </div>
        </v-ons-col>
      </v-ons-row>
      <!-- ファシリティパスワード確認エラーを表示 -->
      <v-ons-row v-show="errors.has('パスワード確認')">
        <div class="label"></div>
        <div class="col-2">
          <p v-show="errors.has('パスワード確認')" class="error-message">
            {{ errors.first("パスワード確認") }}
          </p>
        </div>
      </v-ons-row>
      <!-- キャンセルボタン -->
      <v-ons-row>
        <!--mod FNSI-【1006】最新の改修対象一覧.NO43を追加 周安寧 start-->
        <!--div class="label dummy"></div>-->
        <div class="label"></div>
        <div class="col-2">
        <!--mod FNSI-【1006】最新の改修対象一覧.NO43を追加 周安寧 end-->
        <v-ons-col id="addFacilityCol">
          <div class="btn-container">
            <button
              class="button cancel-btn"
              ref="cancelButton"
              @click="closeFacilityAdd"
            >
              キャンセル
            </button>
            <button
              class="button ok-btn"
              @click="addOrEditFacility"
              ref="addOrEditFacilityButton"
              :disabled="!canSave"
            >
              OK
            </button>
          </div>
        </v-ons-col>
        <!--add FNSI-【1006】最新の改修対象一覧.NO43を追加 周安寧 start-->
        </div>
        <!--add FNSI-【1006】最新の改修対象一覧.NO43を追加 周安寧 end-->
      </v-ons-row>
      </form>
    </div>
    <!-- ローディングコンポーネント -->
    <loading-screen />
  </div>
</template>
<script>
import { mapActions, mapGetters, mapMutations } from "vuex";
import loadingScreen from "@/components/common/LoadingScreen";
export default {
  computed: {
    ...mapGetters("cl-facility", {
      modalFacilityCondition: "getModalFacilityCondition",
      getIsUpdate: "getIsUpdate",
      getFacilitySetting: "getFacilitySetting",
      getConfirmPassword: "getConfirmPassword"
    }),

    ...mapGetters("app", ["hasApiError", "getApiResult"]),

    facilityPassword: {
      get() {
        return this.modalFacilityCondition.facilityPwd;
      },

      set(value) {
        this.setPasswordByValue(value);
      }
    },

    facilityPwdConfirm: {
      get() {
        return this.getConfirmPassword;
      },

      set(value) {
        this.setConfirmPassword(value);
      }
    },
    //必要な入力をすべて確認してください
    isRequired() {
      if (this.getIsUpdate === false) {
        return (
          this.modalFacilityCondition.facilityPwd != "" &&
          this.modalFacilityCondition.facilityPwd != undefined &&
          this.modalFacilityCondition.facilityPwd.length >=
            this.getFacilitySetting.passwordMin &&
          this.modalFacilityCondition.facilityPwd === this.getConfirmPassword
        );
      } else {
        return (
          this.modalFacilityCondition.facilityPwd.length >=
            this.getFacilitySetting.passwordMin &&
          this.modalFacilityCondition.facilityPwd === this.getConfirmPassword
        );
      }
    },

    canSave() {
      return this.isRequired;
    },
    //パスワードの条件検証
    passwordCondition() {
      return this.getIsUpdate === false
        ? "required|min:" + this.getFacilitySetting.passwordMin + ""
        : "min:" + this.getFacilitySetting.passwordMin;
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

    ...mapActions("cl-facility", [
      "setModalFacilityVisible",
      "clearModalFacilityState",
      "insertFacility",
      "updateFacility",
      "setModalConditionPassword",
      "clearModalState"
    ]),

    ...mapActions("app", ["clearApiResult"]),

    ...mapMutations("cl-facility", ["setConfirmPassword"]),

    setFocus(ref) {
      this.$refs[ref].$el._input.focus();
    },

    //モーダルを閉じる
    closeFacilityAdd() {
      this.onBlur();
      this.clearModalState();
      this.clearError();
    },

    //施設アカウントの追加/編集
    async addOrEditFacility() {
      if (this.$refs.addOrEditFacilityButton.disabled) {
        return;
      }
      if (!this.getIsUpdate) {
        this.setLoadingScreenVisible(true);
        this.insertFacility()
          .then(() => {
            this.resetLoadingScreenVisibleCount();
          })
          .catch(() => {
            this.setLoadingScreenVisible(false);
            this.alert();
          });
      } else {
        this.setLoadingScreenVisible(true);
        if (this.modalFacilityCondition.facilityPwd === "") {
          this.setModalFacilityVisible(false);
          this.setLoadingScreenVisible(false);
          return;
        }
        this.updateFacility()
          .then(() => {
            this.resetLoadingScreenVisibleCount();
          })
          .catch(() => {
            this.clearModalFacilityState();
            this.setLoadingScreenVisible(false);
            this.alert();
          });
      }
      this.onBlur();
      this.clearError();
    },

    setPasswordByValue(value) {
      this.setModalConditionPassword(value);
    },

    onBlur() {
      this.$refs["facilityPwd"].$el._input.value = "";
      this.$refs["facility-pwd-confirm"].$el._input.value = "";
    },
    
    clearError() {
      this.$validator.reset();
    },

    alert() {
      if (this.hasApiError) {
        this.$nextTick(() => {
          const alert = {
            title: "エラー",
            message: this.getApiResult.message,
            callback: () => {
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
.facility-add-page {
  text-align: center;
  font-size: 10.5px;
  margin: 0px;
  background-color: aliceblue;
  box-shadow: none;
  border-radius: 10px;
  padding: 16px;
}
.facility-add-page .panel {
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
#facility-add-title {
  font-size: 3em;
  font-weight: bolder;
  color: rgb(118, 113, 113);
}
.button {
  /* add FNSI-【1006】最新の改修対象一覧.NO43を追加 周安寧 start*/
  /*width: 120px;*/
  width: 150px;
  /* add FNSI-【1006】最新の改修対象一覧.NO43を追加 周安寧 end*/
  margin: 0 0 10px 0;
}

#addFacilityCol {
  text-align: end;
/* add FNSI-【1006】最新の改修対象一覧.NO43を追加 周安寧 start*/
  width: 100%;
  margin: 0;
/* add FNSI-【1006】最新の改修対象一覧.NO43を追加 周安寧 end*/
}
.error-message {
  font-size: 14px;
  margin: 10px;
}
.label {
  width: 50px;
  box-sizing: border-box;
  font-size: 1.5em;
  height: 100%;
/* add FNSI-【1006】最新の改修対象一覧.NO43を追加 周安寧 start*/
  /*width: 20%;*/
  width: 30%;
/* add FNSI-【1006】最新の改修対象一覧.NO43を追加 周安寧 end*/
  float: left;
  padding: 5px 0;
  color: rgb(118, 113, 113);
}

#facility-pwd-label {
  padding: 10px 0;
}

.col-2 {
  box-sizing: border-box;
  font-size: 1.5em;
  height: 100%;
/* add FNSI-【1006】最新の改修対象一覧.NO43を追加 周安寧 start*/
  /*width: 80%;*/
  width: 70%;
/* add FNSI-【1006】最新の改修対象一覧.NO43を追加 周安寧 end*/
  float: left;
  padding: 5px 0;
  color: rgb(118, 113, 113);
}

.btn-container {
  display: flex;
  justify-content: flex-end;
}

.ok-btn {
/* add FNSI-【1006】最新の改修対象一覧.NO43を追加 周安寧 start*/
  /*margin-left: 100px;*/
  margin-left: 10%;
  margin-right: 10px;
  width: 150px;
/* add FNSI-【1006】最新の改修対象一覧.NO43を追加 周安寧 end*/
}

.cancel-btn {
/* add FNSI-【1006】最新の改修対象一覧.NO43を追加 周安寧 start*/
  /*float: left;*/
  font-size: 15px;
  width: 150px;
/* add FNSI-【1006】最新の改修対象一覧.NO43を追加 周安寧 end*/
}
/* @media only screen and (max-width: 900px) {
  #cl-add-title {
    font-size: 15px;
  }
  .facility-add-page .panel {
    width: 100%;
  }
  .panel {
    font-size: 10px;
  }
  .label {
    width: 30%;
  }
  .col-2 {
    width: 65%;
    float: right;
  }
  .btn-footer-col-1 {
    width: 0;
  }
  .btn-footer-col-2 {
    width: 100%;
  }
  .btn-container {
    width: 100%;
  }
  .ok-btn {
    font-size: 15px;
    width: 48%;
    margin-left: 20%;
  }
  .cancel-btn {
    font-size: 15px;
    width: 48%;
  }
  .dummy {
    width: 0;
  }
} */
</style>
