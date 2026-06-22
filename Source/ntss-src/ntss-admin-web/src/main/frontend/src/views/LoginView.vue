/**
* ログインPage
*/
<template>
  <div style="height: 100%;" :style="{'background-color': this.colorCode ? this.colorCode : '#fafafa'}" v-if='isEnable'>
    <div class='login-page' v-if="!this.isLoginSuccess">
      <div class='imgButton' type="button" @click='reload();'>
        <img src='../assets/ntss_icon_3.png' class="img-icon" v-show="this.useSetting == '3'"/>
        <img src='../assets/ntss_icon_2.png' class="img-icon" v-show="this.useSetting == '2'"/>
        <img src='../assets/ntss_icon_1.png' class="img-icon" v-show="this.useSetting == '1'"/>
        <img src='../assets/ntss_icon_0.png' class="img-icon" v-show="this.useSetting == '0'"/>
        <img src='../assets/ntss_icon_spacer.png' class="img-icon" v-show="this.useSetting == '-1' "/>
      </div>
      <div class='panel' :class="[{'display-none': !isSigninDisp}]">
        <v-ons-row>
          <v-ons-col>
            <div>
              <label id='user-id' for='userId'>ユーザーID：</label>
              <v-ons-input input-id='userId' :disabled="isDisabled" type='text' v-model='userId' ref='userId' @keyup.enter='setFocus("passwd")' float autofocus autocapitalize="off"></v-ons-input>
            </div>
          </v-ons-col>
        </v-ons-row>
        <v-ons-row>
          <v-ons-col>
            <div>
              <label for='passwd'>パスワード：</label>
                <div class="password-wrapper">
                  <v-ons-input input-id='passwd' :disabled="isDisabled" type='password' v-model='passwd' ref='passwd' @keyup.enter='signIn' float></v-ons-input>
                  <v-ons-icon icon="fa-eye" size="18px" class="password-eyeicon" @click="clickEyeIcon($event)"/>
                </div>
            </div>
          </v-ons-col>
        </v-ons-row>
        <v-ons-row>
          <v-ons-col>
            <div>
              <v-ons-button class='btn1-execute' @click='signIn' v-throttle :disabled='!validation || isAlerting || isDisabled' ref='signInButton'>サインイン</v-ons-button>
            </div>
          </v-ons-col>
        </v-ons-row>
      </div>
      <v-ons-row>
        <v-ons-col>
          <div class="error-massage" id="error-massage" v-if='hasAuthError'>
            <p class="p-error" id="p-error">認証情報が正しくありません。<br>もう一度お試しください。</p>
          </div>
          <!-- FNSI-修正 4082対応 xiebzh add start -->
          <div class="error-massage" v-if="isDisabled">
            <p class="p-error">
              既にサインイン済みのため別施設ではサインインできません。<br>
              この施設でサインインしたい場合はサインイン中のアカウントをサインアウトして、<br>
              この画面を再読み込みしてください。
            </p>
          </div>
          <!-- FNSI-修正 4082対応 xiebzh add end -->
        </v-ons-col>
      </v-ons-row>
      <!-- システムエラー時による画面遷移時に表示 -->
      <v-ons-row v-if="sysErrFlg" style="flex-direction: column;">
        <div style="font-size: 2em; margin: 0 auto; text-align: initial;">
          <label></label>
        </div>
        <div style="display: flex; justify-content: center;" :style="{ 'height': imgHeight + 'px' }">
          <div style="width: 60%;">
            <img id="errorImg" style="width: 100%;"
                 src='../assets/error-img.png'
            />
          </div>
          <div style="margin-top: auto;">
            <kendo-qrcode :value="errorText" :size="120" :encoding="'UTF_8'"></kendo-qrcode>
          </div>
        </div>
      </v-ons-row>
    </div>
    <!-- 認証ビュー -->
    <div class="login-page" v-if="this.isLoginSuccess">

      <div class="panel">
        <div v-if="this.hasQRCodeImg">
          <v-ons-list modifier="inset" class="list-bg">
            <v-ons-list-header > 2要素認証登録</v-ons-list-header>
            <!-- 設定状態の表示と秘密鍵作成・更新ボタン -->
            <v-ons-list-item class="ntss-theme-screen" modifier="nodivider">
              <div class="mfa-container">
                <div class="mfa-message">
                  状態：未設定
                </div>
                <v-ons-button
                  class="btn3-normal mfa-button"
                  @click="EnableQRcode"
                >
                  {{ registerButtonMessage }}
                </v-ons-button>
              </div>
            </v-ons-list-item>
            <!-- QRコード-->
            <v-ons-list-item class="ntss-theme-screen" modifier="nodivider" v-bind:class="[this.isMadeQrCode ? 'QRcodeActive' : 'QRcodeInactive']">
              <div id="bgQRcode">
                <img :src="this.QRcodeImg" >
              </div>
            </v-ons-list-item>
            <!-- 秘密鍵表示と登録ボタン -->
            <table class="ntss-theme-screen" v-bind:class="[this.isMadeQrCode ? 'QRcodeActive' : 'QRcodeInactive']">
              <tbody>
              <!-- 秘密鍵表示 -->
              <tr style="word-break: break-all;">
                <td
                  valign="bottom"
                  colspan="2"
                  style="padding-right: 7px;"
                  class="mfa-message"
                >
                  <label>秘密鍵: {{ inputSecretKey }}</label>
                </td>
              </tr>
              <!-- 認証コード入力(スマホ) -->
              <tr v-if="this.isAndroid || this.isIOS">
                <td colspan="2">
                  <v-ons-input
                    type="text"
                    float
                    v-model="registCheckOTP"
                    width="2em"
                  />
                </td>
              </tr>
              <!-- 認証コード入力(PC) + 登録ボタン(スマホ/PC) -->
              <tr>
                <td v-if="!this.isAndroid && !this.isIOS" >
                  <v-ons-input
                    type="text"
                    float
                    v-model="registCheckOTP"
                    width="2em"
                  />
                </td>
                <td>
                  <v-ons-button
                    style="padding: 0px 5px;"
                    class="btn1-execute mfa-button"
                    @click="updateSecretKey"
                    v-bind:disabled="registCheckOTP === ''"
                  >
                    認証コードチェック・設定保存
                  </v-ons-button>
                </td>
              </tr>
              </tbody>
            </table>
          </v-ons-list>
          <v-ons-row>
            <v-ons-col>
              <div>
                <v-ons-button class="btn2-cancel"  @click='backToLogin'>キャンセル</v-ons-button>
              </div>
            </v-ons-col>
          </v-ons-row>
        </div>
        <div v-else>
          <v-ons-row>
            <v-ons-col>
              <div>
                <label>2要素認証</label>
                <hr/>
              </div>
            </v-ons-col>
          </v-ons-row>
          <v-ons-row>
            <v-ons-col>
              <div>
                <label>ワンタイムパスワードを入力してください。</label><br>
                <v-ons-input type='text' input-id="otp" v-model="otp" ref='otp' float autofocus autocapitalize="off" @keyup.enter='checkOTP'></v-ons-input>
              </div>
            </v-ons-col>
          </v-ons-row>
          <v-ons-row>
            <v-ons-col>
              <div>
                <v-ons-button class="btn1-execute" :disabled='!validationOTP' ref='checkOtpButton' @click='checkOTP'>送信</v-ons-button>
                <v-ons-button class="btn2-cancel"  @click='backToLogin'>キャンセル</v-ons-button>
              </div>
            </v-ons-col>
          </v-ons-row>
        </div>
      </div>
      <!-- エラーメッセージ -->
      <v-ons-row>
        <v-ons-col>
          <div class="error-massage" id="error-massage" v-if='hasAuthError'>
            <p class="p-error" id="p-error">認証エラー<br>ワンタイムパスワードが正しくありません</p>
          </div>
        </v-ons-col>
      </v-ons-row>
    </div>
    <loading-screen />
  </div>
</template>

<script>
import { mapActions, mapGetters, mapMutations  } from "@/compat/vue/vuex";
import { getRouterName, getInitialRouterName } from "@/router/routing-helper";
import NotificationMessageMixin from "@/components/common/notification-message/NotificationMessageMixin";
import loadingScreen from "@/components/common/LoadingScreen";
import { TITLE } from "@/constants/sysUseConstants";
import { LOCAL_STORAGE_KEY } from "@/constants/localStorageConstants";
import axios from "@/compat/http/axios";
import dayjs from "@/compat/date/dayjs";
import { ApiHelper } from "@/apis/AxiosHelper";
import { webPushSubscribe, saveNotificationList } from "@/functions/WebPushFunctions";
import {
  sendRequestGetSignin,
  sendRequestGetSigninByUserId,
  sendRequestRegistSignin,
  sendRequestDeleteSignin,
  sendRequestLogoutAnother
} from "@/apis/User";
import PatGroup from "@/apis/pat-group";

// add 2020-09-25 FNSI-4200ポートを使用している 孫 start
const uriGetCardAppPort = `/card_state/get_card_app_ports`;
// add 2020-09-25 FNSI-4200ポートを使用している 孫 end
import { sendRequestGetMstFacilitySettingValue as getMstFacilitySettingValue } from "@/apis/facility-setting";
import { PASSWORD_VALIDITY_PERIOD } from "@/constants/facilitySetting";
import UserAuthorityMixin from "@/components/common/UserAuthorityMixin";
import { URL_SIGNIN, URL_SIGNIN_SECRETKEY, IS_SIGNIN_DISP } from "@/constants/facilitySetting";
import { PATIENT_SEARCH } from "@/constants/defaultSettingConstants";
import { deepCopy ,changeShowPassword} from "@/functions/common/CommonFunctions";
import { EventBus } from "@/compat/vue/event-bus.js";
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
/* add by chamaojia 2023-04-26 [5958] 共通jsを参照  --start */
import { createTerminalUniqueString, deleteSignin, updateFavicons } from "@/functions/SigninFunction";
/* add by chamaojia 2023-04-26 [5958] 共通jsを参照  --end */
import { SESSION_STORAGE_KEY, SESSION_STORAGE_VALUE } from "@/constants/sessionStorageConstants";
import { focusComponentInput, getAppElement, getScopedDocument, getScopedElementById,
  getScopedWindow} from "@/functions/common/LayoutMeasureHelper";

export default {
  mixins: [NotificationMessageMixin, UserAuthorityMixin],
  data() {
    return {
      // 利用者ID
      userId: "",
      // パスワード
      passwd: "",
      // 認証エラーかどうか
      hasAuthError: false,
      // アラート表示中
      isAlerting: false,
      // システムエラーflg
      sysErrFlg: false,
      // QRコードの値
      errorText: "",
      // 表示画像の縦幅補正
      imgHeight: 0,
      cardCd: "",
      cardIdm: "",
      loginByCardFlag: false,
      //ログインの成功を確認する
      isLoginSuccess: false,
      //OTP値
      otp: "",
      //QRコード画像を取得
      QRcodeImg : "",
      //QRコード画像を確認
      hasQRCodeImg : false,
      isCardDeviceConnected: false,
      useSetting:"-1",
      /**
       * 機能コード
       */
      funcCd: "",
      //2要素認証登録
      inputSecretKey : "",
      OTPLoginFailCount: 0,
      isMadeQrCode: false,
      registCheckOTP: "",
      isAndroid: false,
      isIOS: false,
      fontSize: "",
      createOTPData: null,
      //要素認証画面からのEnterキー押下回数
      otpEnterCount: 0,
      loginByUrlFlag: false,
      isEnable:false,
      // FNSI-修正 4082対応 xiebzh add start
      isDifferentFacailityFlg: false,
      // FNSI-修正 4082対応 xiebzh add end
      // ベッドグループマスタ
      mstBedGroup: null,
      // 患者グループマスタ
      patGroups: null,
      //背景色のカラーコード
      colorCode: "",
      //liyanze-z add 
      isLoginRequest:false,
      // サインインIF表示
      isSigninDisp:true,
    };
  },
  components: {
    "loading-screen": loadingScreen
  },
  computed: {
    ...mapGetters("account-edit", ["getStateUserAccountInfo", "getFontSize", "getInitialFunction","getDefaultSetting"]),
    ...mapGetters("user", ["getFacilityCd", "getResponse", "getSystemUseSetting", "getOtpFailureCnt"]),
    ...mapGetters("app", ["hasApiError", "getKey"]),
    ...mapGetters("mst-facility-setting",{ getValueSignIn: "getValueSignIn" }),
    ...mapGetters("loading-screen", {
      isLoadingScreenVisible: "getLoadingScreenVisible"
    }),
    ...mapGetters("websocket-card", ["getSocketIsConnected", "getSocketMessages", "getSocketIsError", "getCardDeviceStatus"]),
    ...mapGetters("notification", ["getIsRegisteredNotification"]),
    ...mapGetters("mst-user", ["getUserOTP"]),
    // add #8576 【デグレ】サインアウト後サインインすると強制サインアウトのメッセージが表示される dengshen start
    ...mapGetters("app", { url: "getUrl" }),
    // add #8576 【デグレ】サインアウト後サインインすると強制サインアウトのメッセージが表示される dengshen end
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
    },
    //値ログインを取得
    valueSignIn(){
      return this.getValueSignIn;
    },
    //入力OTPを確認
    validationOTP() {
      if (this.otp.length === 0) {
        return false;
      }
      return true;
    },
    //応答メッセージを取得
    getResponseMessage(){
      return this.getResponse;
    },
    //ユーザーOTPの取得
    userOTP(){
      return this.getUserOTP;
    },
    // 秘密鍵作成・更新ボタンのメッセージ内容
    registerButtonMessage() {
      return this.isMadeQrCode ? "秘密鍵更新" : "秘密鍵作成";
    },

    // FNSI-修正 4082対応 xiebzh add start
    isDisabled() {
      return this.isDifferentFacailityFlg;
    }
    // FNSI-修正 4082対応 xiebzh add end
  },
  methods: {
    getLoginWindow() {
      return getScopedWindow(this.$el || this);
    },
    ...mapActions("account-edit", ["getUserAccountInfoSignIn", "clearUserAccountInfo"]),
    ...mapActions("user", {
      userSignIn: "signIn",
      userSignOut: "signOut",
      isSyncSignIn: "isSyncSignIn",
      setIsSignOut: "setIsSignOut",
      preLoadOtpFailureCnt: "preLoadOtpFailureCnt",
      // xie add メモリにて利用者マスタ一覧取得 Start
      setPersonalUser: "setPersonalUser",
      // xie add メモリにて利用者マスタ一覧取得 End
      // add 10159 【因島データ】FNWで作成した患者カードがコンバート施設で使用できない　吉 start
      setDispUserId:"setDispUserId",
      // add 10159 【因島データ】FNWで作成した患者カードがコンバート施設で使用できない　吉 end
    }),
    ...mapActions("user", ["setUserName", "setSystemUseSetting", "fetchUserAuthorityCds"]),
    ...mapActions("app", ["setState", "clearApiResult", "setQueryParameters", "setFunctionCd"]),
    ...mapGetters("app", ["getApiResult", "getFunctionCd"]),
    ...mapActions("bread-crumb", ["resetKeepHistory"]),
    // 共通ローダー設定
    ...mapActions("loading-screen", {
      setLoadingScreenVisible: "setLoadingScreenVisible",
      setLoadingScreenMessage: "setLoadingScreenMessage",
      resetLoadingScreenVisibleCount:  "resetLoadingScreenVisibleCount"
    }),
    ...mapActions("pat-info", ["selectPat","clearSearchedPatList"]),
    ...mapMutations("pat-info", ["addSearchedPatList", "setPatSearchType"]),
    ...mapActions("notification-message", ["getNotificationMessage", "getNotificationMessageForLogin"]),
    ...mapActions("facility", ["getUseFuncByFacilityCd"]),
    ...mapMutations("report-menu", ["setSelectedTreatDate"]),
    ...mapActions("mst-facility-setting", ["sendRequestGetValueSignInByFacilityCd"]),
    // mod FNSI-メニューに共有ON／共有OFFを追加する。 周 start
    //...mapActions("mst-user", ["sendRequestUpdateIsSetQrCode"]),
    ...mapActions("mst-user", ["sendRequestUpdateIsSetQrCode",
      "sendRequestUpdateSigninDate",
      "setIsRegisteredShared"]),
    // mod FNSI-メニューに共有ON／共有OFFを追加する。 周 end
    // mod FNSI-4200ポートを使用している 孫 start
    //...mapActions("websocket-card", ["connect", "close", "clearSocketMessage"]),
    ...mapActions("websocket-card", ["init", "connect", "close", "clearSocketMessage"]),
    // mod FNSI-4200ポートを使用している 孫 end
    ...mapActions("notification", ["setIsRegisteredNotificationFromDb"]),
    ...mapMutations("notification", ["setIsRegisteredNotification"]),
    ...mapGetters("user", [
      "getSignInTimestamp",
      "isSignIn",
      "isSignOut"
    ]),
    /* del by chamaojia 2025-05-21 [11871]  --start */
    /*...mapActions("sys-facility", ["loadSysFacility"]),*/
    /* del by chamaojia 2025-05-21 [11871]  --end */
    ...mapActions("mst-menu-group", ["getMenuGroupList"]),
    ...mapMutations("websocket", ["setToastDuration"]),
    // フォーカスを移動する
    setFocus(ref) {
      focusComponentInput(this.$refs[ref]);
    },
    /**
     * 既にサインインしている場合、サインイン済の施設と同じ施設かをチェックする.
     * @returns true : 同じ施設
     *          false : 異なる施設
     */
    isDifferentFacaility() {
      // アラート表示中の場合は何もしない.
      if (this.isAlerting) {
        return;
      }
      // 異なる施設コードの場合はエラーメッセージを表示して何もしない.
      const facilityHash = localStorage.getItem(LOCAL_STORAGE_KEY.FACILITY_HASH);
      const signInCount = localStorage.getItem(LOCAL_STORAGE_KEY.SIGN_IN_COUNT);
      if (signInCount && Number(signInCount) > 0 &&
        facilityHash && this.getKey && facilityHash !== this.getKey) {
        // アラート表示中フラグをオンにする.
        this.isAlerting = true;
        this.$ons.notification.alert({
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
          // title: "エラー",
          // message: "既にサインイン済の為<br>別の施設ではサインイン出来ません。",
          title: DIALOG_MESSAGES[12000278].title,
          message: messageFormat(DIALOG_MESSAGES[12000278].message),
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
          callback: () => {
            // アラートを閉じる際に、アラート表示中フラグをオフにする.
            this.isAlerting = false;
            // FNSI-修正 4082対応 xiebzh add start
            this.isDifferentFacailityFlg = true;
            // FNSI-修正 4082対応 xiebzh add end
          }
        });


        return false;
      }
      // FNSI-修正 4082対応 xiebzh add start
      this.isDifferentFacailityFlg = false;
      // FNSI-修正 4082対応 xiebzh add end
      return true;
    },
    /**
     * サインイン可能か否かを判断する.
     * 判断は下記の通りとし、該当する場合にfalseを返却する.
     *  ・共通ローダー画面が表示される
     *  ・カードによるサインインではなくてかつ、サインインボタンが非活性
     *  ・既にサインインしている施設と異なる
     *
     * @returns サインイン可能な場合、trueを返す.
     */
    async canSignIn() {
      // 共通ローダー画面が表示されている場合.
      if(this.isLoadingScreenVisible) {
        return false;
      }
      // カードでのサインインでは無くて、サインインボタンが非活性の場合は何もしない
      if (!this.loginByCardFlag) {
        if (this.$refs.signInButton.disabled) {
          return false;
        }
      }
      // 異なる施設コードの場合はエラーメッセージを表示して何もしない.
      if (!this.isDifferentFacaility()) {
        return false;
      }

      // 別ユーザーでサインインしていないかをチェックする.
      // サインインしている場合にはメッセージを表示させる.
      // ※2つ以上のタブでサインイン画面を表示した場合に、tab1でサインイン後、
      //   tab2で別ユーザーでサインインする事を防止する.
      const sysSigninManager = await sendRequestGetSignin(createTerminalUniqueString());
      if (sysSigninManager.data.length === 0) {
        return true;
      }
      //
      if (sysSigninManager.data[0].dispUserId !== this.userId) {
        await this.$ons.notification.alert({
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
          // title: "エラー",
          // message: "既に別ユーザーでサインイン済です。<br>サインイン済のユーザーでサインインします。",
          title: DIALOG_MESSAGES[12000279].title,
          message: messageFormat(DIALOG_MESSAGES[12000279].message),
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
          callback: () => {
            this.userId = sysSigninManager.data[0].dispUserId
            this.passwd = "_";
            this.funcCd = "_";
            return;
          }
        });
      }
      return true;
    },

    /**
     * パスワード有効期限切れか.
     * @param ユーザー情報
     * @return 前回変更日から有効期間以上経っているか、前回変更日がnullなら、true
     */
    async checkIsPasswordExpired(userInfo) {
      const passwordValidityPeriodResponse = await getMstFacilitySettingValue(userInfo.facilityCd, PASSWORD_VALIDITY_PERIOD);
      const passwordValidityPeriod = passwordValidityPeriodResponse.data; // パスワード有効期間
      if (passwordValidityPeriod === 0) {
        // パスワード有効期間が0の場合は無期限のため、期限切れチェックをしない
        return false;
      }
      if (userInfo.regPasswordDate === null) {
        // 前回変更日がnullなら、true
        return true;
      }
      // 現在日時
      const nowDate = dayjs(new Date());
      // パスワード変更日時
      const regPasswordDate = dayjs(userInfo.regPasswordDate);
      // 差分
      const monthDiff = nowDate.diff(regPasswordDate, 'months');
      return monthDiff >= passwordValidityPeriod;
    },

    /**
     * サインイン処理
     */
    /* modify by chamaojia 2025-03-18 [11587] new parameter 【autoSignInFlag】 --start */
    // autoSignInFlag   ture: it's automatic login
    async signIn(autoSignInFlag = false) {
    /* modify by chamaojia 2025-03-18 [11587] new parameter 【autoSignInFlag】 --end */

      autoSignInFlag = autoSignInFlag === true;

      //liyanze-z add
      this.isLoginRequest = true;

      // サインイン可能か否か
      if (!await this.canSignIn()) {
        return;
      }

      // 2要素認証失敗カウンターのクリア
      this.OTPLoginFailCount = 0;

      // システムエラーを非表示にする.
      this.sysErrFlg = false;
      // 共通ローダー:画面制御
      this.setLoadingScreenVisible(true);

      // パンくずリストをクリア
      this.resetKeepHistory();

      // storeを呼び出す為の引数作成
      let user = null;
      if (this.loginByCardFlag == true) {
        user = {
          cardCd: this.cardCd,
          facilityCd: this.getKey,
          funcCd: this.$route.query.FUNC,
          mode: this.$route.query.MODE
        };
      } else if (this.loginByUrlFlag == true) {
        user = {
          userId: this.userId,
          password: this.passwd,
          facilityCd: this.getKey,
          funcCd: this.$route.query.FUNC,
          mode: this.$route.query.MODE,
          // 自動サインインによりパスワード無しでサインインさせる為のフラグ
          userIdOnly: true
        };
      } else {
        /* modify by chamaojia 2025-03-18 [11587] new parameter 【autoSignInFlag】 --start */
        user = {
          userId: this.userId,
          password: this.passwd,
          facilityCd: this.getKey,
          funcCd: this.funcCd ? this.funcCd : this.$route.query.FUNC,
          mode: this.$route.query.MODE,
          autoSignInFlag : autoSignInFlag
        };
        /* modify by chamaojia 2025-03-18 [11587] new parameter 【autoSignInFlag】 --end */
      }
      // 認証処理
      this.userSignIn(user)
        .then(() =>{
          // エラー保持状況フラグを更新
          this.hasAuthError = false;
          if(this.getResponseMessage.code == null) {
            // 選択中患者及び患者検索リストのクリア
            this.clearSearchedPatList();
            // 次回LoginView開始時にストアのクリアを行うフラグを立てる
            this.setNeedsCleanStore(true);

            // アカウント情報を取得
            (async () => {
              await this.getUserAccountInfoSignIn();
              // 利用者権限取得.
              await this.fetchUserAuthorityCds();

              const userInfo = this.getStateUserAccountInfo;
              
              // メニューグループマスタ取得
              await this.getMenuGroupList(userInfo.facilityCd);
              
              // add 10159 【因島データ】FNWで作成した患者カードがコンバート施設で使用できない　吉 start
              this.setDispUserId(userInfo.dispUserId);
              // add 10159 【因島データ】FNWで作成した患者カードがコンバート施設で使用できない　吉 end
              this.setUserName(
                userInfo.userLastName + " " + userInfo.userFirstName
              );
              // add FNSI-メニューに共有ON／共有OFFを追加する。 周 start
              this.setIsRegisteredShared(userInfo.patientShared);
              // add FNSI-メニューに共有ON／共有OFFを追加する。 周 end

              // システム利用設定を追加
              await this.setSystemUseSetting(userInfo.facilityCd);

              // ログイン時アカウント登録画面への移動フラグ
              // 仮登録
              const isProvisional = userInfo.isProvisional === 1;
              /* 個人情報取扱い同意規約を非表示にする対応 ( 戻す場合は同コメントアウト箇所を検索し、関連箇所を対応してください )
              // 次世代fnかつ個人情報取扱い同意規約未同意
              const isConsentAndUseNextGenFN = userInfo.isConsent === 0 && this.getSystemUseSetting >= 2;
              */
              // パスワード有効期限切れ
              const isPasswordExpired = await this.checkIsPasswordExpired(userInfo);

              // 仮登録 または 次世代fnかつ個人情報取扱い同意規約未同意 または パスワード有効期限切れ
              /* 個人情報取扱い同意規約を非表示にする対応 ( 戻す場合は同コメントアウト箇所を検索し、関連箇所を対応してください )
              if (isProvisional || isConsentAndUseNextGenFN || isPasswordExpired) {
              */
              if (isProvisional || isPasswordExpired) {
                // 共通ローダー:初期値セット(非表示)
                this.resetLoadingScreenVisibleCount();
                this.$router.push({ name: "provisional-account-edit" });
                return;
              }

              // 同時サインイン可否設定の取得.
              const isSyncSignIn = await this.isSyncSignIn(userInfo.facilityCd);
              // 複数端末で同時サインイン不可の場合
              if (!isSyncSignIn) {
                // 既に同じアカウントでのサインイン管理情報を取得
                const signInList = await sendRequestGetSigninByUserId(userInfo.userId);
                // 取得したサインイン管理情報から同じ端末識別文字列の情報を取得
                // なければ、sameTerminalは空リストとなる.
                const sameTerminal = signInList.data
                  .filter(s => s.terminalUniqueString === createTerminalUniqueString());
                // 異なる端末からサインインしている場合.
                if (sameTerminal.length === 0 && signInList && signInList.data.length > 0) {
                  let signOut = false;
                  this.setLoadingScreenVisible(false);
                  await this.$ons.notification.confirm({
                    modifier:"info",
                    // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
                    // title: "確認",
                    title: DIALOG_MESSAGES[13000156].title,
                    // message: "既にサインインしています。<br>強制サインアウトしますか？",
                    message: messageFormat(DIALOG_MESSAGES[13000156].message),
                    // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
                    callback: answer => {
                      signOut = answer === 0 ? true : false;
                    }
                  });
                  if (signOut) {
                    return;
                  } else {
                    // 強制サインアウト
                    const params = {
                      userId: userInfo.userId,
                      // add #10160 複数端末同時サインイン無効時の強制サインアウトが動作しない。 dou start
                      facilityCd: userInfo.facilityCd,
                      // add #10160 複数端末同時サインイン無効時の強制サインアウトが動作しない。 dou end
                      terminalUniqueString: createTerminalUniqueString()
                    };
                    await sendRequestLogoutAnother(params);
                  }
                }
              }

              await this.getUseFuncByFacilityCd();

              //検索サイドバー初期検索コール
              await this.defaultSearchPat(userInfo.facilityCd);

              // xie add メモリにて利用者マスタ一覧取得 Start
              // 利用者マスタ一覧取得
              this.setPersonalUser(userInfo.facilityCd).catch(error => {
                console.log(error);
              });
              // xie add メモリにて利用者マスタ一覧取得 End

              //サインイン日時更新
              const userId = {
                userId : userInfo.userId
              }
              await this.sendRequestUpdateSigninDate(userId);

              // URL指定かどうかで遷移先を変更
              if (this.checkIsUrlDirect() === true) {
                // URL指定で特定画面に遷移
                const successTransition = await this.goSpecifyingPage();
                if (!successTransition) {
                  // 遷移失敗時、初期表示メニューへ遷移
                  this.goInitialFunctionPage();
                }
                // 共通ローダー:初期値セット(非表示)
                this.resetLoadingScreenVisibleCount();
              } else {
                // 初期表示メニューへ遷移
                this.goInitialFunctionPage();
                // 共通ローダー:初期値セット(非表示)
                this.resetLoadingScreenVisibleCount();
              }

              // WebPushに必要な情報を登録
              this.registWebPushData();

              // userInfoのuserSettingsを見て、通知の有効無効を確認したい
              if (userInfo.userSettings.personal_settings.length > 0 &&
                typeof(userInfo.userSettings.personal_settings[0].values) !== "undefined") {
                const notifySetting = userInfo.userSettings.personal_settings.find(item => {
                  return item.tab_define_cd === 8;
                }).values;
                const KurNoSetting = "29"; // クール未登録通知 あとで定数化したい
                const notifySettingKurNotSet = notifySetting.find(item => {
                  return item.setting_identifier === KurNoSetting && item.value === true;
                });

                if (notifySettingKurNotSet) {
                  // xie 5544 start
                  console.log("1s");
                  //await ApiHelper.get("/mainData/notifyKurNotSet");
                  await ApiHelper.get("/mainData/notifyKurNotSet").then(() => {
                    console.log("1e");
                  });
                  // xie 5544 end
                }

                const BedNoSetting = "30"; // ベッド未登録通知 あとで定数化したい
                const notifySettingBedNotSet = notifySetting.find(item => {
                  return item.setting_identifier === BedNoSetting && item.value === true;
                });

                if (notifySettingBedNotSet) {
                  // xie 5544 start
                  //await ApiHelper.get("/mainData/notifyBedNotSet");
                  console.log("2s");
                  await ApiHelper.get("/mainData/notifyBedNotSet").then(() => {
                    console.log("2e");
                  });
                  // xie 5544 end
                }
                const ToastDuration = "39"; // トースト通知表示時間
                const toastVal = notifySetting.find(item => item.setting_identifier === ToastDuration);
                if (toastVal) {
                  this.setToastDuration(toastVal.value);
                }
              }

              // del FNSi6531通知が重複して行われる chen start
              // 通知取得(未通知)
              // mod bug 6605 修正 chen start
              // this.$nextTick(() => {
              //   setTimeout(() => {
              //     console.log("3s");
              //     // this.getNotificationMessageForLogin();
              //     console.log("3e");
              //   }, 100);
              // });
              // this.getNotificationMessage();
              // mod bug 6605 修正 chen end
              // del FNSi6531通知が重複して行われる chen end

              // LocalStorageに必要な情報を書込む
              // サインイン時の施設ハッシュ値を格納
              localStorage.setItem(LOCAL_STORAGE_KEY.FACILITY_HASH, this.getKey);
              // 自端末でサインインしているカウント数を格納
              let signinCount = localStorage.getItem(LOCAL_STORAGE_KEY.SIGN_IN_COUNT);
              // サインインカウント数がない場合
              if (!signinCount) {
                signinCount = 0;
              }
              // サインイン回数をインクリメントし格納
              localStorage.setItem(LOCAL_STORAGE_KEY.SIGN_IN_COUNT, Number(signinCount) + 1);

              // サインイン管理のパラメータ
              const request = {
                terminalUniqueString: createTerminalUniqueString(),
                facilityCd: userInfo.facilityCd,
                userId: userInfo.userId
              };
              // DB登録
              await sendRequestRegistSignin(request);

              // 他のタブの自動サインイン処理発火 (初回サインイン時のみ)
              if (localStorage.getItem(LOCAL_STORAGE_KEY.SIGN_IN_COUNT) == 1) {
                await localStorage.setItem(LOCAL_STORAGE_KEY.SIGN_IN_TRIGGER, new Date());
              }
              // add FNSI-4200ポートを使用している 孫 start
              // カードリーダーAPPを接続します
              if (!this.getSocketIsConnected || null === this.getCardDeviceStatus) {
                // card appのwebsokcet以外場合、接続したサービスを閉じました
                if (this.getSocketIsConnected) {
                  this.close();
                  await SleepNSeconds(100);
                }

                // 遅延のミリ秒(millisecond)
                let delayMillisecond = 1000;

                // localStorageのportを利用する
                let defaultPort = localStorage.getItem("CARD_APP_PORT");
                // add 9511 FNSiカードアプリが一方のブラウザとしかつながらない。　吉 start
                if(!/^\d+$/.test(defaultPort)){
                  localStorage.removeItem("CARD_APP_PORT");
                  defaultPort = null;
                }
                // add 9511 FNSiカードアプリが一方のブラウザとしかつながらない。　吉 end
                if (null !== defaultPort) {
                  // localStorageがあり場合、接続を実施する
                  this.init({ port: defaultPort, facilityCd: "" });
                  this.connect();

                  // Nミリ秒を待つ
                  await SleepNSeconds(delayMillisecond);
                }

                // 接続確認実施
                // APP接続しません、または、カードリーダーが無し
                if (null !== userInfo.facilityCd && "" !== userInfo.facilityCd) {
                  if (!this.getSocketIsConnected || null === this.getCardDeviceStatus) {
                    // 「カードアプリポート管理」からportを取得する
                    let facilityCd = userInfo.facilityCd;
                    let cardPorts = await ApiHelper.get(`${uriGetCardAppPort}/${facilityCd}`).catch(() => {
                      throw new Error("カードアプリポート管理から、ポートを取得しません。");
                    });

                    // portsをループする
                    let portList = new Array();
                    if (cardPorts.data.toString().indexOf(",") == -1) {
                      portList[0] = cardPorts.data.toString();
                    } else {
                      portList = cardPorts.data.toString().split(",");
                    }
                    for(let i = 0; i < portList.length; i++) {
                      // APP接続しません、または、カードリーダーが無し
                      if (!this.getSocketIsConnected || null === this.getCardDeviceStatus) {
                        // card appのwebsokcet以外場合、接続したサービスを閉じました
                        if (this.getSocketIsConnected) {
                          this.close();
                          await SleepNSeconds(100);
                        }

                        // 接続を実施する
                        this.init({ port: portList[i], facilityCd: "" });
                        this.connect();

                        // Nミリ秒を待つ
                        await SleepNSeconds(delayMillisecond);
                      }
                    }
                  }
                }
              } else {
                this.isCardDeviceConnected = this.getCardDeviceStatus
              }

              function SleepNSeconds(num) {
                return new Promise((resolve) => {
                  setTimeout(() => {
                    resolve(1*num);
                  }, num);
                } );
              }
              // add FNSI-4200ポートを使用している 孫 end
            })();
          }
          // ワンタイムパスワードを利用するための初回ログイン（QRコードによる秘密鍵の設定）
          // responseのサンプル {code: "2", message: "{"dispUserId": "nkk", "facilityCd": "009997"}"}
          else if(this.getResponseMessage.code == 2) {
            this.resetLoadingScreenVisibleCount();
            this.hasQRCodeImg = true;
            this.createOTPData = JSON.parse(this.getResponseMessage.message);
            this.isLoginSuccess = true;
          }
          // ワンタイムパスワードの設定が完了した後（二回目以降のログイン）
          else if(this.getResponseMessage.code == 1) {
            this.preLoadOtpFailureCnt(this.getKey);
            this.hasQRCodeImg = false;
            this.resetLoadingScreenVisibleCount();
            this.isLoginSuccess = true;
          }
          // デベロッパーツールが開かれている状態でログインしようとした場合
          else if (this.getResponseMessage.code === 999) {
            this.setLoadingScreenVisible(false);
            this.hasAuthError = this.getResponseMessage.hasAuthError ? true : false;
            this.$ons.notification.alert({
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // title: "エラー",
              title: DIALOG_MESSAGES['00300008'].title,
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
              message: this.getResponseMessage.message,
              callback: () => {
                this.isAlerting = false;
                this.clearApiResult();
              }
            });
            
            //liyanze-z add
            this.isLoginRequest = false;
          }
        })
        .catch((error) => {
          this.loginByUrlFlag = false;
          this.setLoadingScreenVisible(false);
          this.alert();

          //liyanze-z add
          this.isLoginRequest = false;
        });
    },
    /**
     * 再描画イベント
     */
    reload() {
      //console.log(this.isLoginRequest)
      if(this.isLoginRequest == true){
        return
      }
      //liyanze-z add 
      window.location.reload();
    },
    /**
     * 画面生成処理
     */
    async createLoad() {
      if (!this.getSocketIsConnected) {
        // add FNSI-313 体重計モード起動ブラウザにスタッフカードでのサインインを可能にする 夏 start
        let defaultPort = localStorage.getItem("CARD_APP_PORT");
        // add 9511 FNSiカードアプリが一方のブラウザとしかつながらない。　吉 start
        if(!/^\d+$/.test(defaultPort)){
          localStorage.removeItem("CARD_APP_PORT");
          defaultPort = null;
        }
        // add 9511 FNSiカードアプリが一方のブラウザとしかつながらない。　吉 end
        if (null !== defaultPort) {
          // localStorageがあり場合、接続を実施する
          this.init({ port: defaultPort, facilityCd: "" });
          // add FNSI-313 体重計モード起動ブラウザにスタッフカードでのサインインを可能にする 夏 end
          this.connect();
          // add FNSI-313 体重計モード起動ブラウザにスタッフカードでのサインインを可能にする 夏 start
        }
        // add FNSI-313 体重計モード起動ブラウザにスタッフカードでのサインインを可能にする 夏 end
      } else {
        this.isCardDeviceConnected = this.getCardDeviceStatus
      }

      // 共通ローダー:開始画面のためリセット／表示名設定
      this.resetLoadingScreenVisibleCount();
      this.setLoadingScreenMessage("処理中・・・");
      // 接続に関する情報をApplicationStoreに登録


      // DEL #7221 2023/02/05 BY HandsomeLin Start

      // const ntssProtocol = window.location.protocol;
      // const ntssHost = window.location.host;
      // const ntssPathName = window.location.pathname.substring(1);
      // const hashedKey = this.$route.query.key
      //   ? this.$route.query.key
      //   : this.getKey;
      // this.setState({
      //   protocol: ntssProtocol,
      //   host: ntssHost,
      //   pathname: ntssPathName,
      //   key: hashedKey
      // });

      // DEL #7221 2023/02/05 BY HandsomeLin End
    },

    /**
     * ソケット再接続処理
     */
    reconnectSocket() {
      const param = this;
      this.socketInterval = setInterval(function() {
        param.connect();
        clearInterval(this.socketInterval);
      }, 10000);
    },
    /**
     * URL指定で呼びだされたかの確認
     * パラメータに機能コード(FUNC)があればtrueを返す
     */
    checkIsUrlDirect() {
      let parameters = JSON.parse(JSON.stringify(this.$route.query));
      return Object.prototype.hasOwnProperty.call(parameters, "FUNC");
    },
    /**
     * URL指定で呼びだされた場合
     */
    async goSpecifyingPage() {
      let parameters = JSON.parse(JSON.stringify(this.$route.query));
      const userType = this.getStateUserAccountInfo.userType;

      // 施設患者IDを内部患者IDに変換
      if (parameters.PATID) {
        try {
          const response = await ApiHelper.get(`/patPersonalMain/getPatIdByHospPatId/${parameters.PATID}`)
          parameters.PATID = response.data;
        } catch (err) {
          parameters.PATID = null;
        }
      }

      if (!parameters.FUNC) {
        parameters.FUNC = this.getFunctionCd();
      } else {
        this.setFunctionCd(parameters.FUNC);
        // 異なる施設の場合
        if (!await this.isDifferentFacaility()) {
          return;
        }
        if (!this.hasNextAuthority(parameters.FUNC)) {
          parameters.routerName = getRouterName(this.getInitialFunction, userType);
          parameters.hasAuth = false;
        } else {
          this.setQueryParameters(parameters);
          parameters.routerName = getRouterName(parameters.FUNC, userType);
          parameters.hasAuth = true;
        }
      }
      return this.moveTo(parameters);
    },
    /**
     * 初期表示メニュー遷移
     */
    goInitialFunctionPage() {
      this.$router.push({ name: getInitialRouterName() });
    },
    /**
     * アラート表示
     * ※エラーがある場合のみアラートを表示する.
     */
    alert() {
      if (this.hasApiError && !this.isAlerting) {
        //再度実行できるためEnterキー押下回数を初期化する
        this.otpEnterCount = 0;

        // エラー保持状況フラグを更新
        const status = this.getApiResult().status;
        this.hasAuthError = (status === 401 && this.getApiResult().message.includes("認証に失敗しました")) || status === 403;
        // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
        // let txtTitle = "エラー";
        let txtTitle = DIALOG_MESSAGES["00300008"].title;
        // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
        if (this.hasAuthError) {
          if (status === 403 && (this.getApiResult().message.includes("アカウントをロック") || this.getApiResult().message.includes("アカウントロック"))) {
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
            // txtTitle = "認証エラー：アカウントロック";
            txtTitle = DIALOG_MESSAGES["00300007"].title;
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
          } else {
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
            // txtTitle = "認証エラー";
            txtTitle = DIALOG_MESSAGES["00300019"].title;
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
          }
        } else if (status === 401 && this.getApiResult().message.includes("以下のいずれかの理由によりサインアウトしました")) {
          txtTitle = "サインアウト";
        }
        this.isAlerting = true;
        this.$nextTick(() => {
          const alert = {
            title: txtTitle,
            messageHTML: this.getApiResult().message,
            callback: () => {
              this.isAlerting = false;
              this.clearApiResult();
              // xie ipadサインインできない対応 start
              // 強制的にサインイン画面に戻す
              this.backToLogin();
              // xie ipadサインインできない対応 end
              // add #8576 【デグレ】サインアウト後サインインすると強制サインアウトのメッセージが表示される dengshen start
              window.location.href = this.url;
              window.location.reload();
              // add #8576 【デグレ】サインアウト後サインインすると強制サインアウトのメッセージが表示される dengshen end
            }
          };
          this.$ons.notification.alert(alert);
        });

      }
    },
    //add 9354施設設定マスタNo63の２要素認証失敗許容回数で設定した回数に関係なく１度間違えるとサインイン画面に戻る zhao start
    alertEf() {
      if (this.hasApiError && !this.isAlerting) {
        this.otpEnterCount = 0;
        let txtTitle = DIALOG_MESSAGES["00300019"].title;
        this.isAlerting = true;
        this.$nextTick(() => {
          const alert = {
            title: txtTitle,
            messageHTML: this.getApiResult().message,
            callback: () => {
              this.isAlerting = false;
              this.clearApiResult();
              this.otp = "";// add #10258 二要素認証の失敗時に入力IFがクリアされない 宮崎
            }
          };
          this.$ons.notification.alert(alert);
        });
      }
    },
    //add 9354施設設定マスタNo63の２要素認証失敗許容回数で設定した回数に関係なく１度間違えるとサインイン画面に戻る zhao end
    /**
     * 画像リサイズ処理
     */
    imgResize() {
      let imgObj = getScopedElementById("errorImg", this.$el || this);
      if (imgObj !== null) {
        this.$nextTick(() => {
          this.imgHeight = imgObj.clientHeight;
        });
      }
    },
    /**
     * 初期患者検索
     *
     * @param {String} facilityCd 施設コード
     */
    async defaultSearchPat(facilityCd){
      
      // マスタ取得
      // 検索条件のベッドグループ、患者グループがマスタから削除済かの判定に使用
      try {
        const [responseBedGroup, patGroups] = await Promise.all([
          ApiHelper.get("/mstInfo/mstRoomBedGroup", {
            facilityCd: facilityCd
          }),
          PatGroup.list(facilityCd)
        ]);
        this.mstBedGroup = responseBedGroup.data;
        this.patGroups = patGroups.data.patGroupInfo;
      } catch (error) {
        this.setLoadingScreenVisible(false);
        throw new Error("[LoginView.vue]defaultSearchPat(): マスタ取得失敗", { cause: error });
      }
      
      // 初回検索用条件-検索サイドバーと同じ手順
      const treatDate = dayjs().format("YYYYMMDD");
      this.setSelectedTreatDate(treatDate);
      const conditions = this.createDefaultConditions(treatDate, facilityCd);
      // 簡易検索
      const uriSimple = "/patInfo/getSimpleSearchResult";
      const resSimple = await ApiHelper.post(uriSimple, {...conditions,patIdList: []
      }).catch(() => {
        this.setLoadingScreenVisible(false);
        throw new Error("[LoginView.vue]defaultSearchPat(): 初期検索失敗");
      });
      this.setPatSearchType(1);
      // 必要なカラムのみ取り出す
      const patPersonalInfoList = resSimple.data.map(pat => {
        return {
          pat_id:pat.pat_id,hosp_pat_id:pat.hosp_pat_id,pat_sex: pat.pat_sex,
          pat_last_name:pat.pat_last_name,pat_first_name:pat.pat_first_name,is_same:pat.is_same
          // add FNSI-終了およびその結果を通知機能で教える 江 start
          ,pat_first_name_kana:pat.pat_first_name_kana,pat_last_name_kana:pat.pat_last_name_kana
          // add FNSI-終了およびその結果を通知機能で教える 江 end
          ,in_out_class:pat.in_out_class
        };
      });
      // 検索サイドバーと同じ手順でデータ抽出
      const filteredPatList = patPersonalInfoList.filter(pat => {
        const patName = `${pat.pat_last_name}${pat.pat_first_name}`;
        const regexp = new RegExp(`.*${""}.*`);
        return regexp.test(patName) || regexp.test(pat.hosp_pat_id);
      });
      // 患者リストに追加
      await this.addSearchedPatList(filteredPatList);
      /* del by chamaojia 2025-05-21 [11871]  --start */
      /*this.$nextTick(async () => {
        await this.loadSysFacility(true);
      });*/
      /* del by chamaojia 2025-05-21 [11871]  --end */
    },
    /**
     * 個人設定で登録した初期値を元に検索パラメータを作成
     *
     * @param {String} treatDate 治療日
     * @param {String} facilityCd 施設コード
     */
    createDefaultConditions(treatDate, facilityCd) {
      // 初期値を入れる
      let kurCdList = [];
      let bedGroupCd = null;
      let selectedPatGroups = [];
      let queryPatGroupsMethod = '2';

      // デフォルト設定
      const defaultCondition = deepCopy(this.getDefaultSetting[PATIENT_SEARCH.KEY_NAME]);
      // console.log("defaultCondition: %o", JSON.parse(JSON.stringify(defaultCondition)));
      if (defaultCondition) {
        // デフォルト設定が存在する場合は適用
        if (defaultCondition[PATIENT_SEARCH.KEY_NAME_KUR_CD_LIST] != null) {
          kurCdList = defaultCondition[PATIENT_SEARCH.KEY_NAME_KUR_CD_LIST];
        }
        if (defaultCondition[PATIENT_SEARCH.KEY_NAME_BED_GROUP_LIST] != null) {
          bedGroupCd = defaultCondition[PATIENT_SEARCH.KEY_NAME_BED_GROUP_LIST];
          // ベッドグループがマスタから削除されている場合は初期値にする
          if (!this.mstBedGroup.some(item => item.roomBedGroupCd === bedGroupCd)) {
            bedGroupCd = 0;
          }
        }
        if (defaultCondition[PATIENT_SEARCH.KEY_NAME_SELECTED_PAT_GROUPS] != null) {
          selectedPatGroups = defaultCondition[PATIENT_SEARCH.KEY_NAME_SELECTED_PAT_GROUPS];
          // 患者グループがマスタから削除されている場合は配列内のから対象コードを削除
          const validPatGroupCds = this.patGroups.map(item => item.patGroupCd);
          selectedPatGroups = selectedPatGroups.filter(value => validPatGroupCds.includes(value));
        }
        if (defaultCondition[PATIENT_SEARCH.KEY_NAME_QUERY_PAT_GROUPS_METHOD] != null) {
          queryPatGroupsMethod = defaultCondition[PATIENT_SEARCH.KEY_NAME_QUERY_PAT_GROUPS_METHOD];
        }

        return {
          ord_schedule:{
            treatDate,
            kurCdList,
            bedGroupCd: bedGroupCd === 0 ? null : bedGroupCd,
            treatDayOfWeekList:[]
          },
          facilityCdList:[facilityCd],
          patGroupSearch:{
            patGroupCd:selectedPatGroups,
            searchType:parseInt(queryPatGroupsMethod)
          }
        }
      }
    },
    /**
     * ワンタイムパスワードチェック
     */
    async checkOTP() {
      // Enterキー連続押下時のエラー発生対応
      this.otpEnterCount += 1;
      if (this.otpEnterCount !== 1) {
        return;
      }
      if (this.$refs.checkOtpButton.disabled) {
        this.otpEnterCount = 0;
        return;
      }
      if (this.otp === "") {
        this.otpEnterCount = 0;
        return;
      }
      // 共通ローダー:画面制御
      this.setLoadingScreenVisible(true);

      // パンくずリストをクリア
      this.resetKeepHistory();

      const user = {
        userId: this.userId,
        password: this.passwd,
        facilityCd: this.getKey,
        funcCd: this.$route.query.FUNC,
        mode: this.$route.query.MODE,
        otpCd : this.otp,
        // 自動サインインによりパスワード無しでサインインさせる為のフラグ
        userIdOnly: this.loginByUrlFlag
      }
      this.userSignIn(user)
        .then(() => {
          if (this.getResponseMessage.code == null) {
            // エラー保持状況フラグを更新
            this.hasAuthError = false;

            // 選択中患者及び患者検索リストのクリア
            this.clearSearchedPatList();

            (async () => {
              await this.getUserAccountInfoSignIn();

              // 利用者権限取得.
              await this.fetchUserAuthorityCds();

              const userInfo = this.getStateUserAccountInfo;
              
              // メニューグループマスタ取得
              await this.getMenuGroupList(userInfo.facilityCd);
              
              this.setUserName(
                userInfo.userLastName + " " + userInfo.userFirstName
              );
              // システム利用設定を追加
              await this.setSystemUseSetting(userInfo.facilityCd);

              // 同時サインイン可否設定の取得.
              const isSyncSignIn = await this.isSyncSignIn(userInfo.facilityCd);
              // 複数端末で同時サインイン不可の場合
              if (!isSyncSignIn) {
                // 既に同じアカウントでのサインイン管理情報を取得
                const signInList = await sendRequestGetSigninByUserId(userInfo.userId);
                // 取得したサインイン管理情報から同じ端末識別文字列の情報を取得
                // なければ、sameTerminalは空リストとなる.
                const sameTerminal = signInList.data
                  .filter(s => s.terminalUniqueString === createTerminalUniqueString());
                // 異なる端末からサインインしている場合.
                if (sameTerminal.length === 0 && signInList && signInList.data.length > 0) {
                  let signOut = false;
                  this.setLoadingScreenVisible(false);
                  await this.$ons.notification.confirm({
                    modifier:"info",
                    // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
                    // title: "確認",
                    title: DIALOG_MESSAGES[13000156].title,
                    // message: "既にサインインしています。<br>強制サインアウトしますか？",
                    message: messageFormat(DIALOG_MESSAGES[13000156].message),
                    // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
                    callback: answer => {
                      signOut = answer === 0 ? true : false;
                    }
                  });
                  if (signOut) {
                    this.otpEnterCount = 0;
                    return;
                  } else {
                    // 強制サインアウト
                    const params = {
                      userId: userInfo.userId,
                      // add #10160 複数端末同時サインイン無効時の強制サインアウトが動作しない。 dou start
                      facilityCd: userInfo.facilityCd,
                      // add #10160 複数端末同時サインイン無効時の強制サインアウトが動作しない。 dou end
                      terminalUniqueString: createTerminalUniqueString()
                    };
                    await sendRequestLogoutAnother(params);
                  }
                }
              }

              await this.getUseFuncByFacilityCd();

              //検索サイドバー初期検索コール
              await this.defaultSearchPat(userInfo.facilityCd);

              // xie add メモリにて利用者マスタ一覧取得 Start
              // 利用者マスタ一覧取得
              this.setPersonalUser(userInfo.facilityCd).catch(error => {
                console.log(error);
              });
              // xie add メモリにて利用者マスタ一覧取得 End

              const user = {
                userId : userInfo.userId,
                isSetQrCode : 1
              }
              await this.sendRequestUpdateIsSetQrCode(user);

              // URL指定かどうかで遷移先を変更
              if (this.checkIsUrlDirect() === true) {
                // URL指定で特定画面に遷移
                const successTransition = await this.goSpecifyingPage();
                if (!successTransition) {
                  // 遷移失敗時、初期表示メニューへ遷移
                  this.goInitialFunctionPage();
                }
                // 共通ローダー:初期値セット(非表示)
                this.resetLoadingScreenVisibleCount();
              } else {
                // 初期表示メニューへ遷移
                this.goInitialFunctionPage();
                // 共通ローダー:初期値セット(非表示)
                this.resetLoadingScreenVisibleCount();
              }

              // 通知取得(未通知)
              this.getNotificationMessage();

              // LocalStorageに必要な情報を書込む
              // サインイン時の施設ハッシュ値を格納
              localStorage.setItem(LOCAL_STORAGE_KEY.FACILITY_HASH, this.getKey);
              // 自端末でサインインしているカウント数を格納
              let signinCount = localStorage.getItem(LOCAL_STORAGE_KEY.SIGN_IN_COUNT);
              // サインインカウント数がない場合
              if (!signinCount) {
                signinCount = 0;
              }
              // サインイン回数をインクリメントし格納
              localStorage.setItem(LOCAL_STORAGE_KEY.SIGN_IN_COUNT, Number(signinCount) + 1);

              // サインイン管理のパラメータ
              const request = {
                terminalUniqueString: createTerminalUniqueString(),
                facilityCd: userInfo.facilityCd,
                userId: userInfo.userId
              };
              // DB登録
              await sendRequestRegistSignin(request);

              // 他のタブの自動サインイン処理発火 (初回サインイン時のみ)
              if (localStorage.getItem(LOCAL_STORAGE_KEY.SIGN_IN_COUNT) == 1) {
                await localStorage.setItem(LOCAL_STORAGE_KEY.SIGN_IN_TRIGGER, new Date());
              }
            })();
          } else if(this.getResponseMessage.code == 0) {
            //無効なOTPパスワード
            this.setLoadingScreenVisible(false);
            this.failedCheckOTP();
          }
        })
        .catch((error) => {
          this.loginByUrlFlag = false;
          this.setLoadingScreenVisible(false);
          this.failedCheckOTP();
        })
    },
    //エラーメッセージを表示
    alertErrorOTP(){
      this.hasAuthError = true;
      this.$nextTick(() => {
        const alert = {
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
          // title: "Failed to authenticate.",
          // message: "OTP code is invalid",
          title: DIALOG_MESSAGES[12000280].title,
          message: messageFormat(DIALOG_MESSAGES[12000280].message)
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
        };
        this.$ons.notification.alert(alert);
      });
    },
    //OTP認証失敗時の処理
    //失敗回数が2要素認証失敗許容回数の上限に達した場合、強制的にサインイン画面に戻す
    failedCheckOTP(){
      this.OTPLoginFailCount++;
      //add 2要素認証の失敗許容回数の対応 xie start
      //if (this.OTPLoginFailCount >= this.getOtpFailureCnt) {
      if (this.OTPLoginFailCount > this.getOtpFailureCnt) {
        //add 2要素認証の失敗許容回数の対応 xie end

        // 失敗時専用のアラートを出す
        // アラート表示中フラグをオンにする.
        this.isAlerting = true;
        this.$ons.notification.alert({
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
          // title: "認証エラー",
          // message: "2要素認証に" + this.OTPLoginFailCount + "回失敗しましたので、2要素認証割り当てデバイスを確認いただき、サインインからやり直してください。",
          title: DIALOG_MESSAGES[12000281].title,
          message: messageFormat(DIALOG_MESSAGES[12000281].message, this.OTPLoginFailCount),
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
          callback: () => {
            // アラートを閉じる際に、アラート表示中フラグをオフにする.
            this.isAlerting = false;
            //再度実行できるためEnterキー押下回数を初期化する
            this.otpEnterCount = 0;
          }
        });
        // 2要素認証失敗カウンターのクリア
        this.OTPLoginFailCount = 0;

        // 強制的にサインイン画面に戻す
        this.backToLogin();
      } else {
        // 汎用アラートを出す
        //mod 9354施設設定マスタNo63の２要素認証失敗許容回数で設定した回数に関係なく１度間違えるとサインイン画面に戻る zhao start
        //this.alert();
        this.alertEf();
        //mod 9354施設設定マスタNo63の２要素認証失敗許容回数で設定した回数に関係なく１度間違えるとサインイン画面に戻る zhao end
      }
    },
    //ログアウト
    backToLogin(){
      this.userSignOut();
      this.clearUserAccountInfo();
      this.userId = "";
      this.passwd = "";
      this.otp = "";
      this.isLoginSuccess = false;
      this.hasAuthError = false;
      this.isMadeQrCode = false;
      this.registCheckOTP = "";
      this.inputSecretKey = "";
      this.QRcodeImg = "";

      //liyanze-z add
      this.isLoginRequest = false;
    },
    /**
     * カードでのサインイン処理.
     */
    async loginByCard() {
      if (this.isCardDeviceConnected) {
        const response = await axios
          .get("/ntss-admin-web/api/facilitySetting/methodLogin?facilityHash=" + encodeURI(this.getKey));
        if (response.data == 0) return;
        try {
          const userId = await axios
            .get("/ntss-admin-web/api/facilitySetting/getUserId?facilityHash=" + encodeURI(this.getKey) + "&userId=" + this.cardCd + "&cardIdm=" + this.cardIdm);
          this.userId = userId.data.toString();
          if (response.data == 2) {
            this.loginByCardFlag = true;
            this.signIn();
          }
        } catch (error) {
          this.userId = "";
          this.$ons.notification.alert({
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
            // title: "認証に失敗しました",
            // message: "アクセスカードが無効です"
            title: DIALOG_MESSAGES[12000282].title,
            message: messageFormat(DIALOG_MESSAGES[12000282].message)
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
          });
        }
      } else {
        this.loginByCardFlag = false;
      }
    },
    // WebPushに必要な情報を登録
    async registWebPushData() {
      // 通知の登録状況をセット(初期状態はfalse)
      this.setIsRegisteredNotification(false);
      // 公開鍵
      let publicKey = null;
      // Subscription処理の戻り値
      let subscriptionObj = null;

      // ブラウザが通知非対応の場合は終了
      if ("Notification" in window === false) {
        return;
      }

      // [01] 通知許可
      // Chrome の 設定 -> 詳細設定 -> プライバシーとセキュリティ -> サイトの設定 -> 通知 から初期化する
      let permission = Notification.permission;

      // 通知がブロックされている場合は終了
      if (permission === "denied") {
        return;
      }

      // 承認処理
      await Notification.requestPermission(response => {
        permission = response;
      });

      // 承認失敗時(承認ダイアログを閉じるなど)またはブロックされた場合は終了、ボタンは通知OFFにする
      if (permission !== "granted") {
        return;
      }

      // [02] 鍵取得
      await ApiHelper.get( `/send-push/publicKey`)
        .then(response => {
          publicKey = response.data;
        })
        .catch(error => {
          throw error;
        });

      // [03] 端末固有文字列の生成
      // localStorage から端末固有文字列を取得(未保存の場合はnull)
      const terminalUniqueString =
        localStorage.getItem(LOCAL_STORAGE_KEY.TERMINAL_UNIQUE_STRING);

      if (terminalUniqueString === null) {
        // 端末固有文字列生成.
        createTerminalUniqueString();
      } else {
        // 保存済み時はsys_notification_listにレコードがあれば通知ON、なければ通知OFFのため処理を抜ける

        // DBから取得したデータを元に通知の登録状況をセット
        await this.setIsRegisteredNotificationFromDb(terminalUniqueString);
        // 通知OFF時に処理を抜ける
        if (this.getIsRegisteredNotification === false) {
          return;
        }
      }

      // [04] Subscription
      await webPushSubscribe(publicKey)
        .then(response => {
          subscriptionObj = response;
        })
        .catch(error => {
          throw error;
        });

      // サブスクリプションエラー時、通知をOFFにする
      if (subscriptionObj === null) {
        // ブラウザの通知解除(unSubscribe)
        navigator.serviceWorker.ready.then(function(reg) {
          reg.pushManager.getSubscription().then(function(subscription) {
            subscription.unsubscribe();
          })
        });

        if (terminalUniqueString !== null) {
          // 施設コード、ログイン者のIDに該当する送信先を削除する
          await ApiHelper.put(`/send-push/pushDelete/${terminalUniqueString}`)
            .catch(error => {
              throw error;
            });
        }

        await this.setIsRegisteredNotificationFromDb(terminalUniqueString);
        return;
      }

      // [05] 宛先情報をサーバに保存
      await saveNotificationList(
        this.getFacilityCd,
        this.getStateUserAccountInfo.userId,
        terminalUniqueString,
        subscriptionObj
      );

      // DBから取得したデータを元に通知の登録状況をセット
      await this.setIsRegisteredNotificationFromDb(terminalUniqueString);

    },
    /* del by chamaojia 2023-04-26 [5958] App.vueに移行しました。ログインページは使用されていません  --start */
    // /**
    //  * タブ/ブラウザを閉じる際のイベント処理.
    //  *
    //  * LocalStoregeに登録している情報をクリア若しくは変更する.
    //  * 同一端末で複数のタブ若しくはブラウザにてサインインしている場合に、
    //  * タブ若しくはブラウザ間で情報をやり取りする為にLocalStoregeを使用する.
    //  *
    //  * 注意：
    //  *  ブラウザは同一(例えば、safariとGoogleChromeを同じ端末で起動した場合は共有されない)で
    //  *  ある事が前提であり、GoogleChromeの場合、Chromeにサインインしているユーザーが同じである事.
    //  */
    // beforeUnload() {
    //   // サインインしている状態でタブ若しくはブラウザが閉じられた場合
    //   this.$nextTick(() => {
    //     // サインインしている場合
    //     // ※サインアウトしないでタブやブラウザを閉じた場合がある.
    //     if (!this.isSignOut() && this.isSignIn()) {
    //       const signInCount = localStorage.getItem(LOCAL_STORAGE_KEY.SIGN_IN_COUNT) - 1;
    //       if (signInCount <= 0) {
    //         localStorage.removeItem(LOCAL_STORAGE_KEY.FACILITY_HASH);
    //         localStorage.removeItem(LOCAL_STORAGE_KEY.SIGN_IN_COUNT);
    //       } else {
    //         localStorage.setItem(LOCAL_STORAGE_KEY.SIGN_IN_COUNT, signInCount);
    //       }
    //     }
    //     this.$nextTick(() => {
    //       // unload イベントは発火しない為、beforeunload の後続処理で実行する
    //       deleteSignin();
    //     });
    //   });
    // },
    /* del by chamaojia 2023-04-26 [5958] App.vueに移行しました。ログインページは使用されていません  --end */
    /* del by chamaojia 2023-04-26 [5958] 共通jsに抽出  --start */
    // /**
    //  * サインイン管理から削除.
    //  * ※LocalStorageに格納されているサインイン回数が0以下の場合に削除する.
    //  */
    // async deleteSignin() {
    //   // LocalStorageからサインインカウントを取得
    //   const signInCount = localStorage.getItem(LOCAL_STORAGE_KEY.SIGN_IN_COUNT);
    //   // サインインカウントが0より大きい場合は何もしない
    //   // ※サインインされていると判断
    //   if (signInCount > 0) {
    //     return;
    //   }
    //   // サインインカウントが0以下若しくは登録されていない場合、
    //   // サインイン管理テーブルから端末固有文字列をキーに削除
    //   await sendRequestDeleteSignin(createTerminalUniqueString());
    // },
    // /**
    //  * 端末固有文字列を作成し、LocalStorageに格納し返却する.
    //  * 既に端末固有文字列が登録済の場合、LocalStorageには登録せず、
    //  * 登録されている端末固有文字列を返却する.
    //  *
    //  * @returns 端末固有文字列
    //  */
    // createTerminalUniqueString() {
    //   // LocalStorageから
    //   let terminalUniqueString =
    //     localStorage.getItem(LOCAL_STORAGE_KEY.TERMINAL_UNIQUE_STRING);
    //
    //   if (terminalUniqueString === null) {
    //     // 未保存時は端末固有文字列を生成し、ローカルストレージにセットしてその後の処理を実行
    //     terminalUniqueString = new Date().getTime().toString(16) + Math.floor(1000 * Math.random()).toString(16);
    //     localStorage.setItem(LOCAL_STORAGE_KEY.TERMINAL_UNIQUE_STRING, terminalUniqueString);
    //   }
    //   return terminalUniqueString;
    // },
    /* del by chamaojia 2023-04-26 [5958] 共通jsに抽出  --end */
    //QRコードを有効にする
    async EnableQRcode(){
      this.setLoadingScreenVisible(true);
      const response = await ApiHelper.get(`/register_otp/cre_mst_user_otp/${this.createOTPData.dispUserId}/${this.createOTPData.facilityCd}`);

      // 成功の場合、QRコード生成
      if (response.status === 200) {
        this.inputSecretKey = response.data.mtsUserSecretKey;
        this.QRcodeImg =  "data:image/jpeg;base64," + response.data.mstUserQR64;
        this.isMadeQrCode = true;
      }
      this.registCheckOTP = "";
      this.setLoadingScreenVisible(false);
    },
    //秘密鍵を更新する
    async updateSecretKey(){
      // 処理しないパターン
      if (
        this.registCheckOTP === "" ||                    // 認証コード未入力
        !this.isMadeQrCode                                // 画面上で秘密鍵生成前
      ) {
        return;
      }

      this.setLoadingScreenVisible(true);
      const response = await ApiHelper.put(`/register_otp/checkOTP/${this.registCheckOTP}/${this.inputSecretKey}`);

      // 認証コードチェック失敗
      if (!response.data) {
        this.setLoadingScreenVisible(false);
        this.$ons.notification.alert({
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
          // title: "認証エラー",
          // message: "認証コードに誤りがあります。設定を見直し、新しい認証コードで登録してください。"
          title: DIALOG_MESSAGES[12000283].title,
          message: messageFormat(DIALOG_MESSAGES[12000283].message)
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
        });
        return;
      }
      const userIdresponse = await ApiHelper.put(`/register_otp/get_user_id/${this.createOTPData.dispUserId}/${this.createOTPData.facilityCd}`);
      const userId = userIdresponse.data; // 内部利用者ID
      await ApiHelper.put(`/register_otp/upd_scret_key/${userId}/${this.inputSecretKey}`)
        .then(async ()=>{
          await ApiHelper.put(`/register_otp/upd_is_set_qr_code/${userId}/1`);
          this.setLoadingScreenVisible(false);
          this.$ons.notification.alert({
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
            // title: "更新完了",
            // message: "2要素認証を有効にしました。"
            title: DIALOG_MESSAGES[12000284].title,
            message: messageFormat(DIALOG_MESSAGES[12000284].message)
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
          });
          // サインイン画面に戻す
          this.backToLogin();
        })
    },
    // created()、もしくは他画面でサインインした際に自動でサインインする処理
    /* modify by chamaojia 2025-03-18 [11587] new parameter 【autoSignInFlag】 --start */
    // autoSignInFlag   ture: it's automatic login
    async initialProc(webSocketChkFlg, autoSignInFlag = false) {
      //背景色のカラーコード取得
      const colorCodeResponse = await axios.get("/ntss-admin-web/api/sign-in/color_code");
      if(colorCodeResponse.data){
        this.colorCode = colorCodeResponse.data;
      }
      sessionStorage.setItem(SESSION_STORAGE_KEY.BACKGROUND_COLOR_CODE, this.colorCode);

      /* modify by chamaojia 2025-03-18 [11587] new parameter 【autoSignInFlag】 --end */
      // 端末判別
      const ua = navigator.userAgent;
      if (ua.match(/Android/)) {
        this.isAndroid = true;
      } else if (ua.match(/iPhone|iPad/)) {
        this.isIOS = true;
      }
      const hashKey = this.$route.query.key
        ? this.$route.query.key
        : this.getKey;

      // サインインIF表示設定を取得
      await axios.get("/ntss-admin-web/api/facilities/MstFacilityHash/getIsSigninDisp?hashValue=" + encodeURI(this.getKey))
        .then(response => {
          // IF表示設定が非表示の場合はフラグをfalseにする
          if (response?.data[IS_SIGNIN_DISP] === "0") {
            this.isSigninDisp = false;
          }
        }).catch(() => {
          // APIエラー時はフラグをtrueに強制
          this.isSigninDisp = true;
        });

      // ADD #7221 2023/02/05 BY HandsomeLin Start
      //   The purpose is to make the form logo and page title display earlier.
      axios.get(`/ntss-admin-web/api/facilities/MstFacilityHash/UseSys/hash`,{
        params:{hashValue: this.getKey}
      }).then(response =>{
        // API結果セット
        this.useSetting = response.data != null ? response.data: 0;
        getScopedDocument(this.$el || this).title = TITLE[this.useSetting];
        // favicon設定
        updateFavicons(this.useSetting);
      }).catch(() =>{
        // APIエラー時パラメータをセット
        this.useSetting = 0;
        getScopedDocument(this.$el || this).title = TITLE[this.useSetting];
        // favicon設定
        updateFavicons(this.useSetting);
      });
      // ADD #7221 2023/02/05 BY HandsomeLin End

      //add FNSI-【1006】最新の改修対象一覧.NO54を追加 周安寧 start
      try {
        let response = await axios.get("/ntss-admin-web/api/client-cer?facilityCd=" + encodeURI(hashKey));
        if (!response.data) {
          this.isEnable = false;
          //#9710：サインイン画面でのCL証明書由来情報の施設チェック処理で不整合となった場合の表示画面修正(再修正) Start
          window.location = 'error/404-certificate.html'
          //#9710：サインイン画面でのCL証明書由来情報の施設チェック処理で不整合となった場合の表示画面修正(再修正) End
          return
        } else {
          this.isEnable = true;
        }
      } catch (error) {
        // xie ipadサインインできない対応 start
        // 強制的にサインイン画面に戻す
        window.location.reload();
        //this.backToLogin();
        // xie ipadサインインできない対応 end
        // console.log(error)
      }
      //add FNSI-【1006】最新の改修対象一覧.NO54を追加 周安寧 end
      // 自動サインインイベント
      this.getLoginWindow().removeEventListener("storage", this.autoSignIn);
      this.getLoginWindow().addEventListener('storage', this.autoSignIn);
      // パラメータが存在する場合はシステムエラー部を表示する
      if (Object.keys(this.$route.params).length > 0) {
        this.sysErrFlg = true;
        let params = this.$route.params;
        this.errorText =
          "発生時刻：" + params.errorDate +
          "\n画面名：" + params.path.meta.title +
          "\nURL：" + params.url +
          "\nステータスコード：" + params.errCode +
          "\nエラーメッセージ：" + params.errorMEssage
      } else {
        this.sysErrFlg = false;
      }
      this.createLoad();
      //del FNSI-【1006】最新の改修対象一覧.NO46を削除 周安寧 start
      // try {
      //   let response = await axios.get("/ntss-admin-web/api/client-cer?facilityCd=" + encodeURI(this.getKey));
      //   if (!response.data) {
      //     this.$ons.notification.alert({
      //       title: "エラー",
      //       message: "選択された証明書が不正になっています。"
      //     });
      //   }
      // } catch (error) {
      //   console.log(error)
      // }
      //del FNSI-【1006】最新の改修対象一覧.NO46を追加 周安寧 end
      // セッションタイムアウト確認
      await axios.get("/ntss-admin-web/api/sign-in/check/sessiontimeout").then(response => {
        // セッションが確認できなかった場合、サインイン画面に追い出す
        if (!response.data) {
          localStorage.setItem(LOCAL_STORAGE_KEY.SIGN_IN_COUNT, 0);
          localStorage.setItem(LOCAL_STORAGE_KEY.SIGN_OUT_TRIGGER, new Date());
        }
      }).catch((error) => {
        // タイムアウトもしくはその他エラーが発生した場合は、タイムアウトか接続できない状態の為、サインイン画面に追い出す
        localStorage.setItem(LOCAL_STORAGE_KEY.SIGN_IN_COUNT, 0);
        localStorage.setItem(LOCAL_STORAGE_KEY.SIGN_OUT_TRIGGER, new Date());
      });

      // サインイン管理情報取得
      let signinList = [];
      // 端末固有情報生成
      const terminalUniqueString = createTerminalUniqueString();
      await sendRequestGetSignin(terminalUniqueString).then(response => {
        if (response.status === 200 && response.data && response.data.length === 1 && !this.isSignOut()) {
          signinList = response.data;
        } else if (response.data && response.data.length === 0 && !this.isSignOut()) {
          // 初期表示時に countが残っていて サインイン情報がない場合、countの消し忘れか、サインアウトされたタブが残っている状態のため、サインイン画面に追い出す
          localStorage.setItem(LOCAL_STORAGE_KEY.SIGN_IN_COUNT, 0);
          localStorage.setItem(LOCAL_STORAGE_KEY.SIGN_OUT_TRIGGER, new Date());
        }
      });

      if (webSocketChkFlg) {
        // 自端末のWebSocket接続を確認して、接続が無ければcountをリセットする
        await axios.get(`/ntss-admin-web/api/websocketcertification/websocket_connect_status`, {
          params:{
            hashValue: this.getKey,
            localHashValue: localStorage.getItem(LOCAL_STORAGE_KEY.FACILITY_HASH) ? localStorage.getItem(LOCAL_STORAGE_KEY.FACILITY_HASH) : "",
            terminalUniqueString: terminalUniqueString
          }
        }).then(response =>{
          if (!response.data) {
            // 応答が false の場合、接続中タブがない為、カウントを初期化
            localStorage.setItem(LOCAL_STORAGE_KEY.SIGN_IN_COUNT, 0);
          }
        }).catch((error) => {
          // 取得失敗した場合もカウントを初期化する
          localStorage.setItem(LOCAL_STORAGE_KEY.SIGN_IN_COUNT, 0);
        });
      }

      // mod #9258 2023/08/29 deleteSigninの場所をここへ移動 朴 start
      // LocalStorageにサインイン情報がない状態でデータベースには登録されている場合が
      // 発生する事が確認された為、LocalStorageに登録されていない場合にデータベースから
      // サインイン管理情報を削除する様に対応
      await deleteSignin();
      // 保持データをサインイン管理情報を削除に追従
      if (localStorage.getItem(LOCAL_STORAGE_KEY.SIGN_IN_COUNT) == 0 && signinList.length === 1) {
        signinList = [];
        // サインイン管理情報が削除された為、他のタブもサインアウトさせる
        localStorage.setItem(LOCAL_STORAGE_KEY.SIGN_OUT_TRIGGER, new Date());
      }
      // mod #9258 2023/08/29 deleteSigninの場所をここへ移動 朴 end

      // 体重計モードの時、全画面メッセージを表示する
      if(this.$route.query.MODE === "1")
      {
        localStorage.setItem(LOCAL_STORAGE_KEY.FULL_SCREEN_MSG_SHOW, true);
      }

      // DEL #7221 2023/02/05 BY HandsomeLin Start
      //   The purpose is to make the form logo and page title display earlier.
      //   Move this code to the top of the method.

      // axios.get(`/ntss-admin-web/api/facilities/MstFacilityHash/UseSys/hash`,{
      //   params:{hashValue: this.getKey}
      // }).then(response =>{
      //   // API結果セット
      //   this.useSetting = response.data != null ? response.data: 0;
      //   getScopedDocument(this.$el || this).title = TITLE[this.useSetting];
      // }).catch((error) =>{
      //   // APIエラー時パラメータをセット
      //   this.useSetting = 0;
      //   getScopedDocument(this.$el || this).title = TITLE[this.useSetting];
      // });

      // DEL #7221 2023/02/05 BY HandsomeLin End


      // 異なる施設の場合
      if (!await this.isDifferentFacaility()) {
        return;
      }
      // del #8323 【デグレ】体重計モードのサインインにて、パスワードが間違っていてもサインインできる dou start
      // if (this.$route.query.USERID && this.$route.query.FUNC) {
      //   this.userId = this.$route.query.USERID;
      //   this.passwd = "_";
      //   this.$nextTick(() => {
      //     this.signIn();
      //   });
      // } else
      // del #8323 【デグレ】体重計モードのサインインにて、パスワードが間違っていてもサインインできる dou end
      // mod #9258 2023/08/29 ログイン済み化関係なくUSERID存在すれば分岐させる 朴 start
      //if (this.$route.query.USERID && localStorage.getItem(LOCAL_STORAGE_KEY.SIGN_IN_COUNT) == 0) {
      if (this.$route.query.USERID) {
      // mod #9258 2023/08/29 ログイン済み化関係なくUSERID存在すれば分岐させる 朴 end
        // 自動サインインの処理(他タブでサインインが検出された場合は処理しない)
        this.userId = this.$route.query.USERID ? this.$route.query.USERID : "";
        this.passwd = this.$route.query.PASSWORD ? this.$route.query.PASSWORD : "";
        // URLサインイン設定を取得
        const response = await axios.get("/ntss-admin-web/api/facilities/MstFacilityHash/getUrlSignin?hashValue=" + encodeURI(this.getKey));
        switch(response.data[URL_SIGNIN]) {
          case "1":
            // 利用者ID + 秘密鍵
            if (response.data[URL_SIGNIN_SECRETKEY] != this.$route.query.SECRETKEY) {
              this.$ons.notification.alert({
                // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
                // title: "サインインに失敗しました",
                // message: "秘密鍵が不一致です。"
                title: DIALOG_MESSAGES[12000285].title,
                message: messageFormat(DIALOG_MESSAGES[12000285].message)
                // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
              });
            } else {
              this.loginByUrlFlag = true;
              this.signIn();
            }
            break;
          case "2":
            // 利用者ID + パスワード
            this.signIn();
            break;
          case "3":
            // 利用者ID
            this.loginByUrlFlag = true;
            this.signIn();
            break;
          default:
            // "0"：使用しない
            this.$ons.notification.alert({
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // title: "サインインに失敗しました",
              // message: "URLサインイン設定を確認してください。"
              title: DIALOG_MESSAGES[12000286].title,
              message: messageFormat(DIALOG_MESSAGES[12000286].message)
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
            });
        }
      }

      // mod #9258 2023/08/29 USERID存在しない場合、ログイン済みで自動サインイン 朴 start
      else if (signinList.length === 1) {
      // mod #9258 2023/08/29 USERID存在しない場合、ログイン済みで自動サインイン 朴 end
        // 同じ端末固有文字列で接続されている為、自動でサインインする
        this.userId = signinList[0].dispUserId;
        this.passwd = "_";
        this.funcCd = "_";
        this.$nextTick(() => {
          /* modify by chamaojia 2025-03-18 [11587] new parameter 【autoSignInFlag】 --start */
          this.signIn(autoSignInFlag);
          /* modify by chamaojia 2025-03-18 [11587] new parameter 【autoSignInFlag】 --end */
        });
      }

      // 画面幅変更時の処理
      this.getLoginWindow().addEventListener("resize", this.imgResize);
      // ブラウザクローズイベント
      // ※本イベントはタブ/ブラウザのクローズイベントなのでremoveすると発火しない為、
      //   removeしない.
      /* modify by chamaojia 2022-12-06 [5958] 事件监听迁移到APP.vue中 --start */
      // window.addEventListener("beforeunload", this.beforeUnload);
      /* modify by chamaojia 2022-12-06 [5958] 事件监听迁移到APP.vue中 --end */
    },
    // 他のタブで初回サインインしたら追従してサインインする
    autoSignIn(e) {
      // localStorageの特定のkeyが変更されたら発火する
      if (e.key === LOCAL_STORAGE_KEY.SIGN_IN_TRIGGER && !this.hasQRCodeImg) {
        // サインイン状況を初期化してから初期処理を実施
        this.setIsSignOut(false);
        // 利用者ID
        this.userId = "";
        this.passwd = "";
        /* modify by chamaojia 2025-03-18 [11587] add automatic login parameter input --start */
        this.initialProc(false, true);
        /* modify by chamaojia 2025-03-18 [11587] add automatic login parameter input --end */
      }
    },
    setNeedsCleanStore(isNeeded) {
      sessionStorage.setItem(
        SESSION_STORAGE_KEY.NEEDS_CLEAN_STORE_BEFORE_SIGN_IN,
        isNeeded
          ? SESSION_STORAGE_VALUE.NEEDS_CLEAN_STORE_BEFORE_SIGN_IN.TRUE
          : SESSION_STORAGE_VALUE.NEEDS_CLEAN_STORE_BEFORE_SIGN_IN.FALSE
      );
    },
    cleanStoreIfNeeded() {
      if (sessionStorage.getItem(SESSION_STORAGE_KEY.NEEDS_CLEAN_STORE_BEFORE_SIGN_IN) === SESSION_STORAGE_VALUE.NEEDS_CLEAN_STORE_BEFORE_SIGN_IN.TRUE) {
        this.setNeedsCleanStore(false);
        window.location.reload();
        return true;
      }
      return false;
    },
    /**
     * パスワード表示非表示切り替え
     * @param {object} event イベント
     */
    clickEyeIcon(event){
      changeShowPassword(event);
    }
  },

  /**
   * created
   */
  async created() {
    // ADD #7221 2023/02/05 BY HandsomeLin Start
    //   The purpose is to make the form logo and page title display earlier.
    //   Value (getKey) needs to be initialized before the api invoke.
    //   These values are independent of any business logic.
    //   This is the status attribute of the browser. It should be initialized as soon as possible.

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
    // DEL #7221 2023/02/05 BY HandsomeLin End

    await this.initialProc(true);
  },
  mounted() {
    // add 10718 by kangjie 20240723 start
    if (this.getLoginWindow().sessionStorage.getItem("consoleStatus") == 'on' &&
      !(sessionStorage.getItem(SESSION_STORAGE_KEY.NEEDS_CLEAN_STORE_BEFORE_SIGN_IN)
        === SESSION_STORAGE_VALUE.NEEDS_CLEAN_STORE_BEFORE_SIGN_IN.TRUE)) {
      this.$ons.notification.alert({
        title: "サインアウト",
        message: "デベロッパーツールが開かれたのでサインアウトしました。</br>デベロッパーツールを閉じて、サインインしてください。"
      });
    }
    // add 10718 by kangjie 20240723 end
    this.alert();
    // （alert表示中でなく）ストアのクリアが必要な場合はページのリロードを行う
    // alert表示中の場合はそのメッセージが閉じられてリロードが行われた際に
    // 改めてこの判定を通る
    if (!this.isAlerting && this.cleanStoreIfNeeded()) {
      // ページのリロードが行われた場合はこの先の処理をスキップする
      return;
    }

    // 縦スクロール設定
    getAppElement(this.$el || this).style.overflowY = "auto";
    // システムエラー部の画像の縦幅を設定する
    if (getScopedElementById("errorImg", this.$el || this) !== null) {
      const loopId = setInterval(
        (function(scope){
          return function() {
            let imgSize = getScopedElementById("errorImg", scope.$el || scope)?.naturalWidth || 0;
            if (imgSize !== 0) {
              scope.imgResize();
              clearInterval(loopId);
            }
          };
        })(this), 300);
    }

    setTimeout(() => {
      this.setFocus('userId');
    });
  },
  beforeUnmount() {
    clearInterval(this.socketInterval);
    // 画面を閉じたときにイベント/Styleを除去
    this.getLoginWindow().removeEventListener("resize", this.imgResize);
    getAppElement(this.$el || this).style.overflowY = "";
    // 自動サインインイベント
    this.getLoginWindow().removeEventListener("storage", this.autoSignIn);
  },
  watch: {
    getSocketIsConnected(value) {
      this.isCardDeviceConnected = false;
      if (!value === true) {
        // 再接続
        this.reconnectSocket();
      } else {
        clearInterval(this.socketInterval);
      }
    },
    getSocketMessages(value) {
      if (value == null) return;
      const splitMsg = value.split("\t");
      if (splitMsg.length > 1) {
        if (splitMsg[0] == "CARD_CLIENT") {
          switch(splitMsg[1]) {
            case "CARD_READER_STATUS":
              this.isCardDeviceConnected = JSON.parse(splitMsg[2].toLowerCase());
              break;
            case "CARD_STAFF_INFO":
              this.cardCd = splitMsg[2];
              this.cardIdm =  splitMsg[3];
              this.loginByCard();
              break;
          }
          this.clearSocketMessage();
        }
      }
    },
    hasApiError() {
      this.setLoadingScreenVisible(false);
      // ワンタイムパスワード不正時の処理はfailedCheckOTP()で行うため、
      // "ワンタイムパスワードが正しくありません"のアラートは出さない
      if (!this.getApiResult().message.includes("ワンタイムパスワードが正しくありません")) {
        this.alert();
      }
    }
  }
};
</script>

<style scoped>
/* ログイン画面のスタイル定義 */
.login-page {
  text-align: center;
  font-size: 10.5px;
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

.login-page .button {
  font-size: initial;
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
  border: solid 1px #ccc;
  margin: 0;
  width: 100%;
  -webkit-border-radius: 5px;
  -moz-box-shadow: inset 0 0 4px rgba(0, 0, 0, 0.2);
  -moz-border-radius: 5px;
  -webkit-box-shadow: inset 0 0 4px rgba(0, 0, 0, 0.2);
  border-radius: 3px;
  box-shadow: inner 0 0 4px rgba(0, 0, 0, 0.2);
  font-size: 150%;
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
.bgQRcode{
  width: 250px;
  height: 200px;
  border: 1px solid red;
  display: flex;
  align-items: center;
  justify-content: center;
  overflow: hidden;
}

/* 2要素認証のメッセージ表示、ボタン */
.mfa-container {
  display: flex;
  align-items: center;
}
.mfa-message {
  width: fit-content;
  margin: 10px;
  font-size: initial;
}
.mfa-button {
  width: fit-content;
  margin: 0px;
}
#bgQRcode{
  width: 200px;
  height: 200px;
  border: 1px solid red;
  display: flex;
  align-items: center;
  justify-content: center;
  overflow: hidden;
}
.QRcodeInactive{
  visibility: hidden;
}
.QRcodeActive{
  visibility: visible;
}
.list-header {
  font-size: initial;
  display: flex;
  align-items: center;
}
.list-bg {
  background-color: var(--ntss-base-background-color);
}
.display-none {
  display: none;
}
</style>
