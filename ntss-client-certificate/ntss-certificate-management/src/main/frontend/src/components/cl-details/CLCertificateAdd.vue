<template>
  <div class="cl-add-page">
    <!-- 題名 -->
    <!--mod FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 start-->
    <!--<p id="cl-add-title">クライアント証明書発行</p>-->
    <p id="cl-add-title">{{ getTitleName }}</p>
    <!--mod FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 end-->
    <div class="panel">
      <!-- 施設名 -->
      <v-ons-row>
        <v-ons-col>
          <div class="col-1">施設名</div>
          <div class="col-2 col-text">
            <span>{{ modalDetailsCondition.displayFacilityName }}</span>
          </div>
        </v-ons-col>
      </v-ons-row>
      <!--FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 start-->
      <!-- 施設ID -->
      <v-ons-row>
        <v-ons-col>
          <div class="col-1">施設ID</div>
          <div class="col-2 col-text">
            <span>{{ modalDetailsCondition.displayFacilityCd }}</span>
          </div>
        </v-ons-col>
      </v-ons-row>
      <!--FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 end-->
      <!-- 発行済数 -->
      <!--FNSI-del【1006】最新の改修対象一覧.NO43を修正 周安寧 start-->
      <!-- <v-ons-row>
        <v-ons-col>
          <div class="col-1">
            <label for="num-release">ダウンロード数/発行数:</label>
          </div>
          <div class="col-2 col-text">
            <span>
              {{ modalDetailsCondition.curDownload }} /
              {{ this.getPreviousMaxDownload }}</span
            >
          </div>
        </v-ons-col>
      </v-ons-row> -->
      <!--FNSI-del【1006】最新の改修対象一覧.NO43を修正 周安寧 end-->
      <!-- 発行数 -->
      <!--FNSI-del【1006】最新の改修対象一覧.NO43を修正 周安寧 start-->
      <!-- <v-ons-row>
        <v-ons-col>
          <div class="col-1">
            <label id="num-release-label" for="num-release">発行数:</label>
          </div>
          <div class="col-2">
            <v-ons-input
              input-id="max-download"
              name="maxDownload"
              type="number"
              min="0"
              v-model.number="maxDownload"
              ref="maxDownload"
              @blur="onBlurMaxDownload"
              :key="inputNumKey"
              v-validate="maxDownloadCondition"
              float
              autofocus
            ></v-ons-input>
          </div>
        </v-ons-col>
      </v-ons-row> -->

      <!-- -->
      <!-- <v-ons-row v-show="errors.has('maxDownload')">
        <div class="col-1"></div>
        <div class="col-2">
          <p v-show="errors.has('maxDownload')" class="error-message">
            {{ errors.first("maxDownload") }}
          </p>
        </div>
      </v-ons-row> -->
      <!-- 公開期限 -->
      <!-- <v-ons-row>
        <v-ons-col>
          <div class="col-1">
            <label id="date-release-label" for="date-release">公開期限:</label>
          </div>
          <div class="col-2">
            <div class="max-download-field">
              <v-ons-input
                input-id="date-release"
                name="release"
                type="date"
                v-model="release"
                ref="release"
                v-validate="'required'"
                float
              ></v-ons-input>
              <v-ons-input
                input-id="after-target"
                name="afterTarger"
                type="date"
                ref="afterTarget"
                v-if="false"
                v-model="this.now"
                float
              ></v-ons-input>
            </div>
            <div class="add-cer-field">
              <v-ons-input
                input-id="time"
                name="Time"
                type="time"
                v-model="time"
                ref="time"
                v-validate="'required'"
                float
              ></v-ons-input>
            </div>
          </div>
        </v-ons-col>
      </v-ons-row> -->
      <!-- 有効期限が現在の日付より前かどうかを検証します -->
      <!-- <v-ons-row v-show="!expiredDateValidation">
        <div class="col-1"></div>
        <div class="col-2">
          <p class="error-message">
            有効期限は現在の日付より後にする必要があります
          </p>
        </div>
      </v-ons-row> -->
      <!-- 有効期限が間違った形式であるか無効であるかを検証する -->
      <!-- <v-ons-row v-show="errors.has('release')">
        <div class="col-1"></div>
        <div class="col-2">
          <p v-show="errors.has('release')" class="error-message">
            {{ errors.first("release") }}
          </p>
        </div>
      </v-ons-row> -->
      <!--FNSI-del【1006】最新の改修対象一覧.NO43を修正 周安寧 end-->
      <!--FNSI-add【1006】最新の改修対象一覧.NO43を修正 周安寧 start-->
      <v-ons-row>
        <v-ons-col>
          <div class="col-1">
            <label id="cl-pwd-label" for="cl-pwd">施設PW</label>
          </div>
          <div class="col-2">
            <v-ons-input
              input-id="cl-pwd"
              name="facilityPassword"
              maxlength="40"
              v-model="modalDetailsCondition.facilityPassword"
              ref="Passwordfacility"
              v-validate="this.clPasswordCondition"
              float
            ></v-ons-input>
          </div>
        </v-ons-col>
      </v-ons-row>
      <!-- パスワード施設PWを表示 -->
      <v-ons-row v-show="errors.has('facilityPassword')">
        <div class="col-1"></div>
        <div class="col-2">
          <font color="red">
            <p class="error-message">{{ errors.first("facilityPassword") }}</p>
          </font>
        </div>
      </v-ons-row>
      <!-- 証明書のパスワード -->
      <v-ons-row v-show="this.getIsUpdate === false">
        <v-ons-col>
          <div class="col-1">
            <label id="cl-pwd-label" for="cl-pwd">証明書PW</label>
          </div>
          <div class="col-2">
            <v-ons-input
              input-id="cl-pwd"
              name="passwordCl"
              maxlength="40"
              v-model="modalDetailsCondition.passwordCl"
              ref="Clpassword"
              @keydown.enter="addCL"
              v-validate="this.clPasswordCondition"
              float
            ></v-ons-input>
          </div>
        </v-ons-col>
      </v-ons-row>
      <!-- パスワード証明書エラーを表示 -->
      <v-ons-row v-show="errors.has('passwordCl') && this.getIsUpdate === false" >
        <div class="col-1"></div>
        <div class="col-2">
          <font color="red">
            <p class="error-message">{{ errors.first("passwordCl") }}</p>
          </font>
        </div>
      </v-ons-row>
      <!--  パスワード証明書パスワード確認 -->
      <!-- パスワード証明書エラーを表示 -->
      <!--FNSI-add【1006】最新の改修対象一覧.NO43を修正 周安寧 end-->
      <!--FNSI-del【1006】最新の改修対象一覧.NO43を修正 周安寧 start-->
      <!-- 証明書のパスワード -->
      <!-- <v-ons-row>
        <v-ons-col>
          <div class="col-1">
            <label id="cl-pwd-label" for="cl-pwd">証明書PW:</label>
          </div>
          <div class="col-2">
            <v-ons-input
              input-id="cl-pwd"
              name="passwordCl"
              type="password"
              maxlength="40"
              v-model="clPassword"
              ref="passwordCl"
              @keydown.enter="setFocus('pwd-confirm')"
              v-validate="this.clPasswordCondition"
              float
            ></v-ons-input>
          </div>
        </v-ons-col>
      </v-ons-row> -->
      <!-- パスワード証明書エラーを表示 -->
      <!-- <v-ons-row v-show="errors.has('passwordCl')">
        <div class="col-1"></div>
        <div class="col-2">
          <font color="red">
            <p class="error-message">{{ errors.first("passwordCl") }}</p>
          </font>
        </div>
      </v-ons-row> -->
      <!--  パスワード証明書パスワード確認 -->
      <!-- <v-ons-row>
        <v-ons-col>
          <div class="col-1">
            <label id="cl-pwd-label" for="cl-pwd-confirm">PW確認:</label>
          </div>
          <div class="col-2">
            <v-ons-input
              input-id="pwd-confirm"
              name="パスワード確認"
              type="password"
              maxlength="40"
              v-model="confirmPassword"
              ref="pwd-confirm"
              @keydown.enter="addCL"
              v-validate="'confirmed:passwordCl|required'"
              float
            ></v-ons-input>
          </div>
        </v-ons-col>
      </v-ons-row> -->
      <!-- パスワード証明書パスワード確認エラーを表示 -->
      <!-- <v-ons-row v-show="errors.has('パスワード確認')">
        <div class="col-1"></div>
        <div class="col-2">
          <font color="red">
            <p class="error-message">{{ errors.first("パスワード確認") }}</p>
          </font>
        </div>
      </v-ons-row> -->
      <!--FNSI-del【1006】最新の改修対象一覧.NO43を修正 周安寧 end -->
      <!-- キャンセルボタン -->
      <v-ons-row>
        <div class="col-1 btn-footer-col-1"></div>
        <div class="col-2 btn-footer-col-2">
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
                @click="addCL"
                ref="addClButton"
                :disabled="!canSave || isAlerting"
              >
                {{ getButtonName }}
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
//add FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 start
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages.js";
//add FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 end
import moment from "moment";
export default {
  data() {
    return {
      inputNumKey: 0,
      isAlerting: false,
      addCertificateNumber: 0,
      hour: "",
      now: moment(new Date()).format("YYYY-MM-DD"),
      //add FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 start
      messageCd: 99999997
      //add FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 end
    };
  },
  computed: {
    ...mapGetters("cl-detail", {
      modalDetailsCondition: "getModalDetailsCondition",
      getCertificate: "getCertificate",
      getIsUpdate: "getIsUpdate",
      getPreviousMaxDownload: "getPreviousMaxDownload",
      getPreviousPassword: "getPreviousPassword",
      getConfirmPassword: "getConfirmPassword"
    }),

    ...mapGetters("cl-facility", {
      getFacilitySetting: "getFacilitySetting"
    }),

    ...mapGetters("app", ["hasApiError", "getApiResult"]),
    // 必要な入力をすべて確認してください
    isRequired() {
      //mod FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 start
      // if (this.getIsUpdate === false) {
      //   return (
      //     this.modalDetailsCondition.maxDownload > 0 &&
      //     this.modalDetailsCondition.maxDownload <= 2147483647 &&
      //     this.modalDetailsCondition.expiredDate !== "" &&
      //     this.modalDetailsCondition.passwordCl !== "" &&
      //     this.modalDetailsCondition.passwordCl.length >=
      //       this.getFacilitySetting.passwordMin &&
      //     this.expiredDateValidation &&
      //     this.modalDetailsCondition.passwordCl === this.getConfirmPassword
      //   );
      // } else {
      //   return (
      //     this.modalDetailsCondition.maxDownload > 0 &&
      //     this.modalDetailsCondition.maxDownload <= 2147483647 &&
      //     this.modalDetailsCondition.maxDownload >=
      //       this.modalDetailsCondition.curDownload &&
      //     this.modalDetailsCondition.expiredDate !== "" &&
      //     (this.modalDetailsCondition.passwordCl === "" ||
      //       this.modalDetailsCondition.passwordCl.length >=
      //         this.getFacilitySetting.passwordMin) &&
      //     this.expiredDateValidation &&
      //     this.modalDetailsCondition.passwordCl === this.getConfirmPassword
      //   );
      // }
      if (this.getIsUpdate === false) {
        return (
          this.modalDetailsCondition.passwordCl !== "" &&
          this.modalDetailsCondition.passwordCl.length >=
          this.getFacilitySetting.passwordMin &&
          this.modalDetailsCondition.facilityPassword !== "" &&
          this.modalDetailsCondition.facilityPassword.length >=
          this.getFacilitySetting.passwordMin); }
      else {
        return (
          this.modalDetailsCondition.facilityPassword !== "" &&
          this.modalDetailsCondition.facilityPassword.length >=
          this.getFacilitySetting.passwordMin)
      }
       //mod FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 end
    },

    canSave() {
      return this.isRequired;
    },
    //del FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 start
    //最大ダウンロードの条件検証
    // maxDownloadCondition() {
    //   return (
    //     "required|max_value:2147483647|min_value:" +
    //     (this.modalDetailsCondition.curDownload === 0
    //       ? 1
    //       : this.modalDetailsCondition.curDownload)

    //   );
    // },
    //del FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 end
    //mod FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 start
    //証明書パスワードの条件検証
    // clPasswordCondition() {
    //   return this.getIsUpdate === false
    //     ? "required|min:" + this.getFacilitySetting.passwordMin+"|max:40"
    //     : "min:" + this.getFacilitySetting.passwordMin+"|max:40";
    // },
    clPasswordCondition() {
      return "required|min:" + this.getFacilitySetting.passwordMin+"|max:40"
    },
    //mod FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 end

    expiredDateCondition() {
      return "required|after:" + this.now;
    },

    expiredDateValidation() {
      let now = new Date();
      let date = new Date(this.release + " " + this.time);
      if (date < now) {
        return false;
      } else {
        return true;
      }
    },

    time: {
      get() {
        return this.modalDetailsCondition.hour;
      },

      set(value) {
        this.setHourState(value);
      }
    },

    Clpassword: {
      get() {
        return this.modalDetailsCondition.passwordCl;
      },

      set(value) {
        this.setPasswordState(value);
      }
    },
    //mod FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 start
    Passwordfacility: {
      get() {
        return this.modalDetailsCondition.facilityPassword;
      },

      set(value) {
        this.setfacilityPasswordState(value);
      }
    },
    //mod FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 end
    confirmPassword: {
      get() {
        return this.getConfirmPassword;
      },

      set(value) {
        this.setConfirmPassword(value);
      }
    },

    release: {
      get() {
        return this.modalDetailsCondition.expiredDate;
      },

      set(value) {
        this.setPublicTimeByValue(value);
      }
    },

    maxDownload: {
      get() {
        return this.modalDetailsCondition.maxDownload;
      },
      set(value) {
        this.setMaxDownloadByValue(value);
      }
    },
    // add FNSI-[4446 メッセージ文言の修正]対応 解 start
    getButtonName: {
      get() {
        if (this.getIsUpdate) {
          return "変更";
        } else {
          return "発行";
        }
      }
    },
    getTitleName: {
      get() {
        if (this.getIsUpdate) {
          return "施設パスワード変更";
        } else {
          return "施設アカウント発行";
        }
      }
    }
    // add FNSI-[4446 メッセージ文言の修正]対応 解 end
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

    ...mapActions("cl-detail", {
      addNewCertificate: "addNewCertificate",
      setCertificate: "setCertificate",
      setModalDetailsVisible: "setModalDetailsVisible",
      //add FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 start
      setModalCertificatesVisible:"setModalCertificatesVisible",
      //add FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 end
      clearModalDetail: "clearModalDetail",
      updateCertificate: "updateCertificate",
      updateClNoPassword: "updateClNoPassword",
      demoDownload: "demoDownload",
      // add 4448修正 解 start
      selectDownloadServer: "selectDownloadServer"
      // add 4448修正 解 end
    }),

    ...mapMutations("cl-detail", {
      setMaxDownloadState: "setMaxDownloadState",
      setPasswordState: "setPasswordState",
      //add FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 start
      setfacilityPasswordState: "setfacilityPasswordState",
      //add FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 end
      setPublicTimeState: "setPublicTimeState",
      setHourState: "setHourState",
      setConfirmPassword: "setConfirmPassword"
    }),
     //add FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 start
    ...mapActions("cl-facility", [
      "setModalFacilityVisible",
      "clearModalFacilityState",
      "insertFacility",
      "updateFacility",
      "setModalConditionPassword",
      "clearModalState"
    ]),
    //add FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 end
    ...mapActions("app", ["clearApiResult"]),

    setFocus(ref) {
      this.$refs[ref].$el._input.focus();
    },

    cancel() {
      this.clearModalDetail();
      this.onBlur();
    },

    onBlur() {
      if (this.$refs["passwordCl"]) this.$refs["passwordCl"].$el._input.value = "";
      if (this.$refs["pwd-confirm"]) this.$refs["pwd-confirm"].$el._input.value = "";
      //add FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 start
      if (this.$refs["facilityPassword"]) this.$refs["facilityPassword"].$el._input.value = "";
      if (this.$refs["facility-pwd-confirm"]) this.$refs["facility-pwd-confirm"].$el._input.value = "";
      //add FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 end
    },
    //明確なモーダル
    onBlurMaxDownload() {
      if (this.getIsUpdate === true) {
        if (
          this.modalDetailsCondition.maxDownload === "" ||
          this.modalDetailsCondition.maxDownload <
            this.modalDetailsCondition.curDownload || this.maxDownload > 2147483647
        ) {
          this.setMaxDownloadByValue(this.getPreviousMaxDownload);
        }
      }
    },
    //証明書の発行/更新
    addCL() {
      if (this.$refs.addClButton.disabled) {
        return;
      }
      // add 4448修正 解 start
      this.selectDownloadServer();
      // add 4448修正 解 end
      if (this.getIsUpdate === true) {
      //add FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 start
      this.$ons.notification.confirm({
          title: "パスワード変更",
          message: DIALOG_MESSAGES[this.messageCd],
          callback: answer => {
            if (answer === 1) {
              this.setLoadingScreenVisible(true);
              this.updateCertificate()
                .then(() => {
                  this.resetLoadingScreenVisibleCount();
                  this.setModalDetailsVisible(false);
                  this.setModalCertificatesVisible(true);

                })
                .catch(() => {
                  this.setLoadingScreenVisible(false);
                  this.alert();
                });
            } else {
              // 保存処理をキャンセルして終了
            }
          }
        });
     //add FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 end
     //del FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 start
        // if (
        //   this.modalDetailsCondition.passwordCl !== "" &&
        //   this.modalDetailsCondition.passwordCl !== null
        // ) {
        //   this.setLoadingScreenVisible(true);
        //   this.updateCertificate()
        //     .then(() => {
        //       this.resetLoadingScreenVisibleCount();
        //     })
        //     .catch(() => {
        //       this.setLoadingScreenVisible(false);
        //       this.alert();
        //     });
        // } else {
        //   this.setLoadingScreenVisible(true);
        //   this.updateClNoPassword()
        //     .then(() => {
        //       this.resetLoadingScreenVisibleCount();
        //     })
        //     .catch(() => {
        //       this.setLoadingScreenVisible(false);
        //       this.alert();
        //     });
        // }
        //del FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 end
      } else {
        this.setLoadingScreenVisible(true);
        this.addNewCertificate()
        .then(() => {

            this.resetLoadingScreenVisibleCount();
            //add FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 start
            this.setModalDetailsVisible(false);
            this.setModalCertificatesVisible(true);
            //add FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 end
          })
          .catch(() => {
            this.setLoadingScreenVisible(false);
            this.alert();
          });
      }
      this.onBlur();
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

    setPublicTimeByValue(value) {
      this.setPublicTimeState(value);
    },

    setPasswordByValue(value) {
      this.setPasswordState(value);
    },
    //add FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 start
    setfacilityPasswordByValue(value) {
      this.setfacilityPasswordState(value);
    },
    //add FNSI-【1006】最新の改修対象一覧.NO43を修正 周安寧 end
    setMaxDownloadByValue(value) {
      this.setMaxDownloadState(value);
    },

    // add FNSI-「複数施設証明書を発行する」ボタンを追加 解 start
    getFacilityCd() {
      if (this.modalDetailsCondition.displayFacilityCd !== null && this.modalDetailsCondition.displayFacilityCd !== '') {
        return this.modalDetailsCondition.displayFacilityCd;
      }
      return this.modalDetailsCondition.facilityCd;
    },
    getFacilityName() {
      if (this.modalDetailsCondition.displayFacilityName !== null && this.modalDetailsCondition.displayFacilityName !== '') {
        return this.modalDetailsCondition.displayFacilityName;
      }
      return this.modalDetailsCondition.facilityName;
    }
    // add FNSI-「複数施設証明書を発行する」ボタンを追加 解 end


  },

  watch: {
    maxDownload: function(newVal) {
      if(newVal > 2147483647) {
        this.setMaxDownloadByValue(2147483647);
        this.inputNumKey += 1;
      }
    }
  }
};
</script>
<style scoped>
.cl-add-page {
  text-align: center;
  font-size: 10.5px;
  border: 1px solid black;
  margin: 0px;
  background-color: aliceblue;
  box-shadow: none;
  border-radius: 10px;
  overflow: hidden;
  padding: 16px;
  transform: rotate(90);
}
.cl-add-page .panel {
  text-align: left;
  margin: 0 auto;
  width: 80%;
}
ons-col {
  box-sizing: border-box;
  width: inherit;
  margin: 10px;
}

/* ons-row {
  min-width: 500px;
} */

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
#cl-add-title {
  font-weight: bolder;
  font-size: 3em;
  color: rgb(118, 113, 113);
}
.button {
  width: 150px;
  margin: 0 0 10px 0;
}
label {
  width: 50px;
}
#addClCol {
  text-align: end;
  width: 100%;
  margin: 0;
}
.error-message {
  margin: 10px;
}
.col-1 {
  font-size: 1.5em;
  color: rgb(118, 113, 113);
  box-sizing: border-box;
  padding: 5px 0;
  float: left;
  height: 100%;
  width: 30%;
}
.col-2 {
  font-size: 1em;
  box-sizing: border-box;
  text-align: left;
  float: left;
  width: 70%;
  height: 100%;
}

.col-2 span {
  font-size: 1.5em;
}

.col-text {
  padding: 5px 0;
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
.max-download-field {
  width: 60%;
  float: left;
}

.add-cer-field {
  width: 40%;
  float: left;
}
/* @media only screen and (max-width: 900px) {
  #cl-add-title {
    font-size: 2em;
  }
  .panel {
    font-size: 10px;
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
    width: 150px;
    margin-left: 15%;
  }
  .cancel-btn {
    font-size: 15px;
    width: 150px;
  }
} */
</style>
