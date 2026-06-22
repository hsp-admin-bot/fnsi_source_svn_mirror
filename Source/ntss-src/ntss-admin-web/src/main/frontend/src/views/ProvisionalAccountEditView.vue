/**
 * 初回ログイン時アカウント登録
 */
<template>
  <v-card>
    <div class="main account-edit" :style="heightProvisionalStyles">
      <div class="main-content-area account-edit-input">
        <div style="text-align:left;">
          <div v-if="isProvisional || isConsent">
            <h1 class="h1">{{ userAccountInfo.userLastName }} {{ userAccountInfo.userFirstName }} さん</h1>
            <h1 class="h1">こんにちは</h1>
            <h1 class="h-hallo float-clear h1">ご利用ありがとうございます</h1>
          </div>
          <div v-else>
            <h1 class="h1" style="height: 4rem;"></h1>
          </div>
          <p v-if="isProvisional">利用者情報を登録してください</p>
          <p v-else-if="isPasswordExpired">パスワードの有効期限が切れました。再設定をお願いします。</p>
          <p v-show="isProvisional || isPasswordExpired" class="required">*必須</p>
        </div>
        <div v-show="isProvisional || isPasswordExpired" class="panel">
          <table class="table-userInfo">
            <tbody account-edit-tbody>
              <tr v-show="isProvisional">
                <td class="title">
                  <label>新しい
                    <br>ユーザーID*:
                  </label>
                </td>
                <td valign="bottom" colspan="10">
                  <v-ons-input
                    input-id="dispUserId"
                    name="dispUserId"
                    type="text"
                    @keyup.enter="setFocus('password')"
                    float
                    autocapitalize="off"
                    v-model="dispUserId"
                    ref="dispUserId"
                    data-validation-label="ユーザーID"
                    v-rules="'required|max: 12|alpha_num_symbol'"
                    @blur="checkDuplicated"
                    class="form-input"
                  />
                  <p
                    v-show="hasValidationError('dispUserId')"
                    class="error-message"
                  >{{ getValidationError('dispUserId') }}</p>
                  <!-- #10977 インジェクション対応 linjunfeng start -->
                  <!-- <p v-show="isDuplication" class="error-message" v-html="getStateMessage"></p> -->
                  <div v-show="isDuplication" class="error-message" v-for="(item, index) in getStateMessage.split('<br/>')" :key="index" >
                    {{ item }}
                  </div>
                  <!-- #10977 インジェクション対応 linjunfeng end -->
                </td>
              </tr>
              <tr>
                <td class="title">
                  <label>現在の
                    <br>パスワード*：
                  </label>
                </td>
                <td valign="bottom" colspan="10">
                  <div class="password-wrapper">
                    <v-ons-input
                      input-id="current-password"
                      name="current-password"
                      type="password"
                      @keyup.enter="setFocus('password')"
                      @blur="checkMatchCurrentPassword"
                      float
                      v-model="userPasswordCurrent"
                      data-validation-label="現在のパスワード"
                      v-rules="'required|alpha_num_symbol|max:40'"
                      ref="current-password"
                      class="form-input"
                    />
                    <v-ons-icon icon="fa-eye" size="18px" class="password-eyeicon" @click="clickEyeIcon($event)"/>
                  </div>
                  <p
                    v-show="this.userPasswordCurrent && !isCorrectCurrentPassword"
                    class="error-message"
                  >現在のパスワードが一致しません。</p>
                </td>
              </tr>
              <tr>
                <td class="title">
                  <label>新しい
                    <br>パスワード*：
                  </label>
                </td>
                <td valign="bottom" colspan="10">
                  <div class="password-wrapper">
                    <v-ons-input
                      input-id="password"
                      name="password"
                      type="password"
                      @keyup.enter="setFocus('confirm-password')"
                      float
                      v-model="userPassword"
                      data-validation-label="パスワード"
                      v-rules="'required|alpha_num_symbol|max:40'"
                      ref="password"
                      class="form-input"
                    />
                    <v-ons-icon icon="fa-eye" size="18px" class="password-eyeicon" @click="clickEyeIcon($event)"/>
                  </div>
                  <p
                    v-show="hasValidationError('password')"
                    class="error-message"
                  >{{ getValidationError('password') }}</p>
                </td>
              </tr>
              <tr>
                <td class="title">(確認)
                  <br>パスワード*：
                </td>
                <td valign="bottom" colspan="10">
                  <div class="password-wrapper">
                    <v-ons-input
                      input-id="confirm-password"
                      name="confirm-password"
                      type="password"
                      @keyup.enter="registration"
                      float
                      v-model="userPasswordConfirm"
                      data-validation-label="確認パスワード"
                      v-rules="'required|alpha_num_symbol|max:40|confirmed:password'"
                      ref="confirm-password"
                      class="form-input"
                    />
                    <v-ons-icon icon="fa-eye" size="18px" class="password-eyeicon" @click="clickEyeIcon($event)"/>
                  </div>
                  <p
                    v-show="hasValidationError('confirm-password')"
                    class="error-message"
                  >{{ getValidationError('confirm-password') }}</p>
                </td>
              </tr>

              <tr v-show="isProvisional">
                <td class="title">
                  <label>氏名*:
                  </label>
                </td>
                <td valign="bottom" colspan="5">
                  <v-ons-input
                    input-id="dispUserLastName"
                    name="dispUserLastName"
                    type="text"
                    @keyup.enter="setFocus('password')"
                    float
                    autocapitalize="off"
                    v-model="dispUserLastName"
                    ref="dispUserLastName"
                    data-validation-label="姓"
                    v-rules="'required'"
                    @blur="checkDuplicated"
                    class="form-input"
                  />
                </td>

                <td valign="bottom" colspan="5">
                  <v-ons-input
                    input-id="dispUserFirstName"
                    name="dispUserFirstName"
                    type="text"
                    @keyup.enter="setFocus('password')"
                    float
                    autocapitalize="off"
                    v-model="dispUserFirstName"
                    ref="dispUserFirstName"
                    data-validation-label="姓"
                    v-rules="'required'"
                    @blur="checkDuplicated"
                    class="form-input"
                  />
                </td>
              </tr>
              <tr>
                <td>
                </td>
                <td valign="bottom" colspan="10">
                  <p
                    v-show="hasValidationError('dispUserLastName')"
                    class="error-message"
                  >{{ getValidationError('dispUserLastName') }}</p>
                  <p
                    v-show="!hasValidationError('dispUserLastName') && hasValidationError('dispUserFirstName')"
                    class="error-message"
                  >{{ getValidationError('dispUserFirstName') }}</p>
                  <!-- #10977 インジェクション対応 linjunfeng start -->
                  <!-- <p v-show="isDuplication" class="error-message" v-html="getStateMessage"></p> -->
                  <div v-show="isDuplication" class="error-message" v-for="(item, index) in getStateMessage.split('<br/>')" :key="index" >
                    {{ item }}
                  </div>
                  <!-- #10977 インジェクション対応 linjunfeng end -->
                </td>
              </tr>

              <tr v-show="isProvisional">
                <td class="title">
                  <label>メニュー:
                  </label>
                </td>
                <td valign="bottom" colspan="1">
                  <button
                    class="button btn3-normal registration-btn form-input"
                    @click="showMenuBarEdit()"
                  >設定</button>
                </td>
              </tr>

            </tbody>
          </table>
        </div>
        <div v-show="isConsent && (isProvisional || !isPasswordExpired)">
          <br><br>
          <div class="personal-info-msg">
            <span v-html="this.personalInfoMsg"></span>
          </div>
          <br><br>
          <label class="form-input">
            <v-ons-checkbox
              input-id="personalInfoCheck"
              name="personalInfoCheck"
              v-model="personalInfoCheck"
              ref="personalInfoCheck"
              v-rules="'required:invalidateFalse'"
            />上記の個人情報取扱い規約について同意する
          </label>
          <br><br>
        </div>

        <div class="registration-btn-area" style="background:none; bottom: auto;">
          <button
            class="button btn1-execute registration-btn form-input"
            @click="registration"
            :disabled="hasAnyValidationError || !isComplete || isDuplication"
            ref="registrationButton"
          >確定</button>
        </div>
        <loading-screen />
      </div>
    </div>
    <fab-component v-show="isStaff"/>
    <multi-modal-view />
  </v-card>
</template>

<script>
import FabComponent from "@/components/FabComponent";
import MultiModal from "@/components/modals/MultiModal";
import { ApiHelper } from "@/apis/AxiosHelper";

import { mapGetters, mapActions } from "@/compat/vue/vuex";
import loadingScreen from "@/components/common/LoadingScreen";
import { sendRequestGetMstFacilitySettingValue as getMstFacilitySettingValue } from "@/apis/facility-setting";
import { sendRequestCheckMatchCurrentPassword, sendRequestIsAvailablePassword } from "@/apis/User";
import { PASSWORD_POLICY, NUM_OF_PASSWORD, pwdLvLow, pwdLvNormal, pwdLvHigh, PASSWORD_VALIDITY_PERIOD } from "@/constants/facilitySetting";
import { SYS_USE_TYPE } from "@/constants/sysUseConstants";
import dayjs from "@/compat/date/dayjs";
//FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
import {getErrorMessage} from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
import {changeShowPassword} from "@/functions/common/CommonFunctions";
import { focusComponentInput } from "@/functions/common/LayoutMeasureHelper";
export default {
  name: "provisionalAccountEdit",
  components: {
    "fab-component": FabComponent,
    "loading-screen": loadingScreen,
    "multi-modal-view": MultiModal
  },
  data() {
    return {
      userPassword: "",
      userPasswordConfirm: "",
      userPasswordCurrent: "",
      dispUserId: "",
      dispUserLastName: "",
      dispUserFirstName: "",
      personalInfoCheck: null,
      personalInfoMsg:"",
      //Enterキー押下回数
      confirmEnterCount : 0,
      passwordValidityPeriod: 999,
      isCorrectCurrentPassword: false,
    };
  },
  computed: {
    ...mapGetters("account-edit", [
      "getStateUserAccountInfo",
      "isDuplicatedUser",
      "getRegistResult",
      "getMessage"
    ]),
    ...mapGetters("user", ["getSystemUseSetting"]),
    ...mapGetters("mst-facility-setting",{getValueSignIn: "getValueSignIn"}),
    ...mapGetters("mst-user",{getUserOTP: "getUserOTP"}),
    heightProvisionalStyles() {
      // 本画面は router の単体ルートで親に高さがなく、% 指定だと ntss.css の .main{height:var(--height)} が
      // 解決できず 0 になり、.main-content-area(position:absolute) ごと見えなくなる。ビューポート基準のみ本画面で使用する。
      return { "--height": "100vh" };
    },
    /**
     * ユーザ情報取得.
     * @return stateに登録されたユーザ情報
     */
    userAccountInfo() {
      return this.getStateUserAccountInfo;
    },
    isDuplication() {
      return this.isDuplicatedUser;
    },
    registResult() {
      return this.getRegistResult;
    },
    getStateMessage() {
      const message = this.getMessage;
      if (message != null) {
        return message.replace("\n", "<br/>");
      }
      return "";
    },
    /**
     * 仮登録フラグの取得.
     * @return 仮登録の場合、true
     */
    isProvisional() {
      return this.userAccountInfo.isProvisional === 1;
    },

    /**
     * 個人情報取扱い同意フラグの取得.
     * @return 次世代FNかつ未同意の場合、true
     */
    isConsent() {
      /* 個人情報取扱い同意規約を非表示にする対応 ( 戻す場合は同コメントアウト箇所を検索し、関連箇所を対応してください )
      return this.getSystemUseSetting >= SYS_USE_TYPE.FNSI_ONLY && this.userAccountInfo.isConsent === 0;
      */
      return this.getSystemUseSetting > SYS_USE_TYPE.REMS_AND_FNSI && this.userAccountInfo.isConsent === 0;
    },

    /**
     * パスワード有効期限切れか.
     * @return 前回変更日から有効期間以上経っているか、前回変更日がnullなら、true
     */
    isPasswordExpired() {
      if (this.passwordValidityPeriod === 0) {
        // パスワード有効期間が0の場合は無期限のため、期限切れチェックをしない
        return false;
      }
      if (this.userAccountInfo.regPasswordDate === null) {
        // 前回変更日がnullなら、true
        return true;
      }
      // 現在日時
      const nowDate = dayjs(new Date());
      // パスワード変更日時
      const regPasswordDate = dayjs(this.userAccountInfo.regPasswordDate);
      // 差分
      const monthDiff = nowDate.diff(regPasswordDate, 'months');
      return monthDiff >= this.passwordValidityPeriod;
    },

    /**
     * 入力項目が設定済みであるかどうか.
     * ・仮登録かつ未同意
     * ・仮登録かつ同意済
     * ・パスワード期限切れ
     * ・登録済かつ未同意
     * @return 設定済みの場合、true
     */
    isComplete() {
      if(this.isProvisional && this.isConsent){
        return this.userPassword && this.userPasswordConfirm && this.userPasswordCurrent && this.isCorrectCurrentPassword && this.dispUserId && this.personalInfoCheck;
      }else if(this.isProvisional){
        return this.userPassword && this.userPasswordConfirm && this.userPasswordCurrent && this.isCorrectCurrentPassword && this.dispUserId;
      }else if(this.isPasswordExpired){
        return this.userPassword && this.userPasswordConfirm && this.userPasswordCurrent && this.isCorrectCurrentPassword;
      }else{
        return this.personalInfoCheck;
      }
    },
    ...mapGetters("app", {
      url: "getUrl",
      protocol: "getProtocol",
      host: "getHost",
      pathname: "getPathname",
      key: "getKey"
    })
  },
  methods: {
    ...mapActions("account-edit", [
      "updateUserAccountInfo",
      "setDuplicatedUser",
      "registProvisionalUserAccount",
      "clearUserAccountInfo",
      "checkDuplicatedUser",
      "getUserAccountInfo"
    ]),
    ...mapActions("multi-modal", {
      showMenuBarEdit: "showMenuBarEdit"
    }),
    // 共通ローダー設定
    ...mapActions("loading-screen", {
      setLoadingScreenVisible: "setLoadingScreenVisible",
      setLoadingScreenMessage: "setLoadingScreenMessage",
      resetLoadingScreenVisibleCount:  "resetLoadingScreenVisibleCount"
    }),
    ...mapActions("user", { userSignOut: "signOut" }),
    ...mapActions("mst-facility-setting", ["sendRequestGetValueSignInByFacilityCd"]),
    ...mapActions("mst-user",["sendRequestCreateMstUserOTP",
                              "sendRequestUpdateSecretKey"]),
    // フォーカスを移動する
    setFocus(ref) {
      focusComponentInput(this.$refs[ref]);
    },
    /**
     * 処理：入力された現在のパスワードをチェック
     */
    async checkMatchCurrentPassword() {
      const params = {
        userId: this.userAccountInfo.userId,
        CurrentPassword: this.userPasswordCurrent
      }
      sendRequestCheckMatchCurrentPassword(params)
        .then(response => {
          this.isCorrectCurrentPassword = response.data;
        });
    },
    /**
     * 処理：入力された情報でアカウント情報登録(更新)
     */
    async registration() {
      // Enterキー連続押下時のエラー発生対応
      this.confirmEnterCount += 1;
      if (this.confirmEnterCount !== 1) {
        return;
      }
      // 確定ボタンが非活性の場合は何もしない
      if (this.$refs.registrationButton.disabled) {
        //再度実行できるためEnterキー押下回数を初期化する
        this.confirmEnterCount = 0;
        return;
      }
      
      if (this.isProvisional) { // パスワード有効期限切れ画面の場合は項目非表示のため実施しない
        // 氏名の必須入力チェック
        const isLastNameValid = await this.validateField("dispUserLastName");
        const isFirstNameValid = await this.validateField("dispUserFirstName");
        if (!isLastNameValid || !isFirstNameValid) {
          //再度実行できるためEnterキー押下回数を初期化する
          this.confirmEnterCount = 0;
          return;
        }
      }
      
      // 共通ローダー:表示開始
      this.setLoadingScreenVisible(true);
      // 仮登録ユーザーのみ：パスワードポリシーチェック
      if(this.isProvisional || this.isPasswordExpired){
        //ポリシーパスワードの取得
        var policyPassword = await this.getPolicyPassword();
        var lengthPassword = await this.getLengthPassword();
        //パスワードを認証する
        if (await this.checkFacilityPassword(policyPassword, lengthPassword, this.userPassword, this.userPasswordCurrent) == false) {
          this.setLoadingScreenVisible(false);
          //再度実行できるためEnterキー押下回数を初期化する
          this.confirmEnterCount = 0;
          return;
        }
      }

      // パスワード利用可能チェック
      if (await this.checkIsAvailablePassword(this.userAccountInfo.userId, this.userPassword, this.userAccountInfo.facilityCd) === false) {
        this.setLoadingScreenVisible(false);
        //再度実行できるためEnterキー押下回数を初期化する
        this.confirmEnterCount = 0;
        return;
      }

      // APIコールパラメータセット
      const request = {
        facilityCd: this.userAccountInfo.facilityCd,
        dispUserIdPre: this.userAccountInfo.dispUserId,
        dispUserIdNew: this.dispUserId,
        userPasswordNew: this.userPassword,
        userLastName: this.dispUserLastName,
        userFirstName: this.dispUserFirstName,
        isProvisional: this.isProvisional,
        isConsent: this.isConsent
      };
      // 更新処理呼び出し
      await this.registProvisionalUserAccount(request)
        .then(() => {
          // 共通ローダー:表示終了
          this.setLoadingScreenVisible(false);
          // サインアウト
          this.signOut();
        })
        .catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
          getErrorMessage('ProvisionalAccountEditView.vue','registration',error);
          //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
          if (error.response.status === 400) {
            // 共通ローダー:表示終了
            this.setLoadingScreenVisible(false);
            let message = error.response.data.errorMessage;
            if (message != null) {
              message = message.replace("\n", "<br/>");
            }
            this.$ons.notification.alert({
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // title: "更新に失敗しました。",
              title: DIALOG_MESSAGES["00300009"].title,
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
              message
            });
            //再度実行できるためEnterキー押下回数を初期化する
            this.confirmEnterCountnter = 0;
          }
        });
    },
    // サインアウト処理 TODO FabPage.vueの処理と共通化したい
    signOut() {
      // ポップアップ画面のクローズ
      this.popoverVisible = false;

      // storeに保持している利用者情報をクリア
      this.userSignOut();
      this.clearUserAccountInfo();
      // ログイン画面へ遷移
      // ※URLにパラメータが含まれている場合に書き変わらない為、
      //   window.locationで遷移するように変更
      if (this.isStaff) {
        // 施設スタッフ向けログイン画面に遷移
        window.location.href = this.url;
      } else {
        // 在宅透析患者向けログイン画面に遷移
        window.location.href = this.protocol + "//" + this.host + "/" + this.pathname + "#/home-dialysis/?key=" + this.key;
      }
    },
    /**
     * 重複ユーザーか否かをチェックします。
     * ユーザーID(dispUserId)のエラーがない場合のみ、チェックします。
     * TODO validatorをextendして共通的に使えるようにしたい
     */
    checkDuplicated() {
      const errors = this.validationErrors.filter(
        item => item.field === "dispUserId"
      );
      if (errors.length === 0) {
        const userInfo = {
          userId: this.userAccountInfo.userId,
          dispUserId: this.dispUserId
        };
        this.checkDuplicatedUser(userInfo).catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
          getErrorMessage('ProvisionalAccountEditView.vue','registration',error);
          //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
          if (error.response.status === 400) {
            // TODO APIで400とすべきところも200で返しているため、ここにはこない。
          }
        });
      } else {
        // ほかにエラーがある状態の場合は、メッセージを表示させない
        this.setDuplicatedUser(false);
      }
    },

    // 入力した新しいパスワードが使用可能かチェック
    async checkIsAvailablePassword(userId, newPassword, facilityCd) {
      if(newPassword == null){
          return true;
      }
      const params = {
        userId: userId,
        newPassword: newPassword,
        facilityCd: facilityCd
      };

      const response = await sendRequestIsAvailablePassword(params)

      if (response.data === false) {
        this.$ons.notification.alert({
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
          // title: "無効なパスワード",
          // message: "パスワード再利用禁止です！"
          title: DIALOG_MESSAGES['00200124'].title,
          message: messageFormat(DIALOG_MESSAGES['00200124'].message)
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
        });
        return false;
      }

      return true;
    },
    //施設のパスワードを確認する
    checkFacilityPassword(facilityValue, lengthPassword, password, currentPassword) {
      var par,messagePopup, checkLengthError = false;
      if(password == null){
          return true;
      }

      messagePopup = password === currentPassword ? "現在のパスワードと異なるパスワード<br>" : "";

      if(lengthPassword == 16){
          messagePopup = messagePopup + lengthPassword + "文字"
      }else{
          messagePopup = messagePopup + lengthPassword + "文字以上16文字以下"
      }

      if(password.length < lengthPassword){
          checkLengthError = true;
      }
      switch (facilityValue) {
        case 1:
          if (checkLengthError || password.length > 16) {
            this.$ons.notification.alert({
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // title: "無効なパスワード",
              title: DIALOG_MESSAGES["00300010"].title,
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
              message: messagePopup
            });
            return false;
          }
          break;
        case 2:
          par = new RegExp(pwdLvLow)
          if(par.test(password) == false || checkLengthError){
            this.$ons.notification.alert({
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // title: "無効なパスワード",
              title: DIALOG_MESSAGES["00300010"].title,
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
              message: messagePopup+".<br>英字と数字を含む"
            });
            return false;
          }
          break;
        case 3:
          par = new RegExp(pwdLvNormal)
          if (par.test(password) == false || checkLengthError) {
            this.$ons.notification.alert({
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // title: "無効なパスワード",
              title: DIALOG_MESSAGES["00300010"].title,
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
              message: messagePopup+".<br>次の4つのカテゴリのうち3つから文字を使う<br>-英大文字(AからZ)<br>-英小文字(aからz)<br>-10進数の数字(0から9)<br>-記号(!、$、#、% など)"
            });
            return false;
          }
          break;
        case 4:
          par = new RegExp(pwdLvHigh)
          if (par.test(password) == false || checkLengthError) {
            this.$ons.notification.alert({
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // title: "無効なパスワード",
              title: DIALOG_MESSAGES["00300010"].title,
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
              message: messagePopup+".<br>次の4種類の文字を使う。<br>-英大文字(AからZ)<br>-英小文字(aからz)<br>-10進数の数字(0から9)<br>-記号(!、$、#、% など)"
            });
            return false;
          }
          break;
      }
      return true;
    },
    //ポリシーのパスワードを取得する
    async getPolicyPassword() {
      const pwdPolicyRes = await getMstFacilitySettingValue(this.getStateUserAccountInfo.facilityCd, PASSWORD_POLICY);
      const pwdPolicy = pwdPolicyRes.data;

      return pwdPolicy;
    },

    //パスワードの長さを取得する
    async getLengthPassword() {
      const pwdLengthRes = await getMstFacilitySettingValue(this.getStateUserAccountInfo.facilityCd, NUM_OF_PASSWORD);
      const pwdLength = pwdLengthRes.data;
      return pwdLength;
    },

    // sys_system_defineから個人情報取扱い規約を取得(apisの作成はしない)
    async setPersonalInfoMsg(){
      const ctlNo = 26;
      const sysSystemDefine = await ApiHelper.get(`/sys_system_define/getSysSystemDefine/${ctlNo}`);
      if(sysSystemDefine.data.length > 0){
        const categoryNames = JSON.parse(sysSystemDefine.data[0].value);
        this.personalInfoMsg = categoryNames.html;
      }
    },
     /**
     * パスワード表示非表示切り替え
     * @param {object} event イベント
     */
    clickEyeIcon(event){
      changeShowPassword(event);
    }
  },
  async created() {
    // 共通ローダー:表示名設定
    this.setLoadingScreenMessage("処理中・・・");
    getMstFacilitySettingValue(this.getStateUserAccountInfo.facilityCd, PASSWORD_VALIDITY_PERIOD)
      .then(response => {
        this.passwordValidityPeriod = response.data;
      });
    this.dispUserId = this.getStateUserAccountInfo.dispUserId;
    this.dispUserLastName = this.getStateUserAccountInfo.userLastName;
    this.dispUserFirstName = this.getStateUserAccountInfo.userFirstName;
    this.isStaff = (this.userAccountInfo.patId === null || this.userAccountInfo.patId <= 0) ? true : false;
    setTimeout(() => this.setFocus("dispUserId"), 500);
    this.sendRequestGetValueSignInByFacilityCd(this.getStateUserAccountInfo.facilityCd);
    this.setPersonalInfoMsg();
  }
};
</script>

<style scoped>
.h1 {
  font-size: 1.5rem;
  margin: 0;
}
.img-ntss {
  width: 8rem;
}
.float-left {
  float: left;
}
.float-clear {
  clear: both;
}
p {
  margin: 0;
}
.required {
  font-size: 0.8rem;
  margin: 0px 0px 15px 0px;
}
.table-userInfo {
  width: 100%;
  table-layout: fixed;
  border-collapse: separate;
  border-spacing: 5px 10px;
  margin: -30px 0px 0px 0px;
}
.title {
  width: 8em;
}
.form-input {
  font-size: 1rem;
}
.personal-info-msg{
  text-align:left;
  max-width:600px;
  max-height:200px;
  overflow-y:auto;
  overflow-x:hidden;
  margin:0 auto;
  border-style: ridge;
  font-size: 0.8rem;
}
</style>
