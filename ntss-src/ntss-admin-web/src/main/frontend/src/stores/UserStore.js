/**
 * ユーザ認証ストア
 */
 import {
  sendRequestLogin,
  sendRequestLogout,
  sendRequestGetUserAuthorityCds,
  sendRequestDeleteSignin
} from "@/apis/User";
import { sendRequestGetMstFacilityHashByFacilityCd } from "@/apis/mst-facility-hash";
import {
  sendRequestGetMstFacilityByCd,
  sendRequestGetOtpFailureCntByHash
} from "@/apis/facility";
import { sendRequestGetMstFacilitySettingValue } from "@/apis/facility-setting";
import store from "@/stores";
import { LOCAL_STORAGE_KEY } from "@/constants/localStorageConstants";
import { SYNC_SIGN_IN } from "@/constants/facilitySetting";
// xie add メモリにて利用者マスタ一覧取得 Start
import { ApiHelper } from "@/apis/AxiosHelper";
import router from "@/router";
// xie add メモリにて利用者マスタ一覧取得 End

/* ユーザタイプ定義 */
// 管理タイプ
export const USER_TYPE_ADMIN = "1";
// 一般タイプ
const USER_TYPE_GENERAL = "0";
/* 管理者フラグ定義 */
// 管理者ユーザ
const USER_TYPE_ADMINISTRATOR = "1";

// システム用アカウント
const USER_TYPE_FOR_SYSTEM = "2";

export default {
  strict: true,
  namespaced: true,
  state: {
    dispUserId: null,
    userId: null,
    userName: null,
    userType: null,
    administrator: null,
    isSuccess: false,
    facilityCd: null,
    signInTimestamp: -1,
    authorityCds: [],
    systemUseSetting: null,
    advancedSettings: {},
    reponseMessage : {
      code : null,
      message : null
    },
    /**
     * サインアウトしたか否か.
     */
    isSignOut: false,
    accountLockSetting: null,
    failureCnt: null,
    otpFailureCnt: null,
    // xie add メモリにて利用者マスタ一覧取得 Start
    mstPersonalUser: null,
    // xie add メモリにて利用者マスタ一覧取得 End
    /* add by yangzhaokai 2022-11-01 #7755 サインイン画面にてデベロッパーツールを起動状態でサインイン実行不可 --start */
    isDisableDevtool: false,
    /* add by yangzhaokai 2022-11-01 #7755 サインイン画面にてデベロッパーツールを起動状態でサインイン実行不可 --end */
    /* add by liuzhibo 2022-11-22[6872]ログの検索条件に前のユーザ時の条件が表示され、消えない -- start */
    lastUserId: null
    /* add by liuzhibo 2022-11-22[6872]ログの検索条件に前のユーザ時の条件が表示され、消えない -- end */
  },
  mutations: {
    // 認証成功した利用者IDを格納
    setDispUserId(state, dispUserId) {
      state.dispUserId = dispUserId;
    },
    setUserId(state, userId) {
      state.userId = userId;
    },
    // 認証成功した利用者氏名を格納
    setUserName(state, userName) {
      state.userName = userName;
    },
    // 認証成功可否の状態を格納
    setIsSuccess(state, isSuccess) {
      state.isSuccess = isSuccess;
    },
    // 利用者種別を格納
    setUserType(state, userType) {
      state.userType = userType;
    },
    // 管理者フラグを格納
    setAdministrator(state, administrator) {
      state.administrator = administrator;
    },
    // 施設コードを格納
    setFacilityCd(state, facilityCd) {
      state.facilityCd = facilityCd;
    },
    // システム利用設定を格納
    setSystemUseSetting(state, systemUseSetting) {
      state.systemUseSetting = systemUseSetting;
    },
    // 認証成功した利用者情報を格納
    setUser(state, user) {
      state.userName = user.userName;
      state.userType = user.userType;
      state.administrator = user.administrator;
      state.facilityCd = user.facilityCd;
    },
    // サインイン時刻を格納
    setSignInTimestamp(state, timestamp) {
      state.signInTimestamp = timestamp;
    },
    /**
     * 利用者権限情報を格納する.
     * @param {*} state stateオブジェクト
     * @param {*} authorityCds 利用者権限情報
     */
    setAuthorityCds(state, authorityCds) {
      state.authorityCds = authorityCds;
    },
    // 施設拡張設定を格納
    setAdvancedSettings(state, advancedSettings) {
      state.advancedSettings = advancedSettings;
    },
    //応答メッセージを取得する
    setResponse(state, reponseMessage){
      state.reponseMessage = reponseMessage;
    },
    /**
     * サインアウトフラグを格納する.
     * @param {*} state stateオブジェクト
     * @param {boolean} isSignOut サインアウトフラグ
     */
    setIsSignOut(state, isSignOut) {
      state.isSignOut = isSignOut;
    },
    // アカウントロック設定を格納
    setAccountLockSetting(state, accountLockSetting) {
      state.accountLockSetting = accountLockSetting;
    },
    // サインイン失敗許容回数を格納
    setFailureCnt(state, failureCnt) {
      state.failureCnt = failureCnt;
    },
    // 2要素認証失敗許容回数を格納
    setOtpFailureCnt(state, otpFailureCnt) {
      state.otpFailureCnt = otpFailureCnt;
    },
    // xie add メモリにて利用者マスタ一覧取得 Start
    setMstPersonalUser(state, mstPersonalUser) {
      state.mstPersonalUser = mstPersonalUser;
    },
    // xie add メモリにて利用者マスタ一覧取得 End
    /* add by yangzhaokai 2022-11-01 #7755 サインイン画面にてデベロッパーツールを起動状態でサインイン実行不可 --start */
    // デベロッパーツールを設定する
    setIsDisableDevtool(state, isDisableDevtool) {
      state.isDisableDevtool = isDisableDevtool;
    },
    /* add by yangzhaokai 2022-11-01 #7755 サインイン画面にてデベロッパーツールを起動状態でサインイン実行不可 --end */
    /* add by liuzhibo 2022-11-22[6872]ログの検索条件に前のユーザ時の条件が表示され、消えない -- start */
    setLastUserId(state, lastUserId) {
      state.lastUserId = lastUserId;
    }
    /* add by liuzhibo 2022-11-22[6872]ログの検索条件に前のユーザ時の条件が表示され、消えない -- end */
  },
  actions: {
    // 認証成功した利用者IDを格納
    setDispUserId({ commit }, dispUserId) {
      commit("setDispUserId", dispUserId);
    },
    /*  add #9764  by zhangruixue 2023-09-04 --start */
    // サインイン失敗許容回数を格納
    setFailureCnt({ commit }, failureCnt) {
      commit("setFailureCnt", failureCnt);
    },
    // アカウントロック設定を格納
    setAccountLockSetting({ commit }, accountLockSetting) {
      commit("setAccountLockSetting", accountLockSetting);
    },
    // 2要素認証失敗許容回数を格納
    setOtpFailureCnt({ commit }, otpFailureCnt) {
      commit("setOtpFailureCnt", otpFailureCnt);
    },
    /* add #9764  by zhangruixue 2023-09-04 --end */
    setUserId({ commit }, userId) {
      commit("setUserId", userId);
    },
    // 認証成功した利用者氏名を格納
    setUserName({ commit }, userName) {
      commit("setUserName", userName);
    },
    // 認証成功可否の状態を格納
    setIsSuccess({ commit }, isSuccess) {
      commit("setIsSuccess", isSuccess);
    },
    // 利用者種別を格納
    setUserType({ commit }, userType) {
      commit("setUserType", userType);
    },
    // 管理者フラグを格納
    setAdministrator({ commit }, administrator) {
      commit("setAdministrator", administrator);
    },
    // 施設コードを格納
    setFacilityCd({ commit }, facilityCd) {
      commit("setFacilityCd", facilityCd);
    },
    // システム利用設定を格納
    async setSystemUseSetting({ commit }, facilityCd) {
      const mstFacilityHash = await sendRequestGetMstFacilityHashByFacilityCd(facilityCd);
      commit("setSystemUseSetting", mstFacilityHash.data.systemUseSetting);
      // サインイン失敗時設定を格納
      commit("setAccountLockSetting", mstFacilityHash.data.accountLockSetting);
      commit("setFailureCnt", mstFacilityHash.data.failureCnt);
      commit("setOtpFailureCnt", mstFacilityHash.data.otpFailureCnt);
    },
    // 認証成功した利用者情報を格納
    setUser({ commit }, user) {
      commit("setUser", user);
    },

    // xie add メモリにて利用者マスタ一覧取得 Start
    setPersonalUser({ commit }, facilityCd) {
      ApiHelper.get(`/mstInfo/mstPersonalUser`, {
        facility_cd: facilityCd
      }).then((res) => {
        commit("setMstPersonalUser", res.data);
      });

    },
    // xie add メモリにて利用者マスタ一覧取得 End
    // 施設拡張設定を格納
    setAdvancedSettings({ commit }, advancedSettings) {
      commit("advancedSettings", advancedSettings);
    },
    // サインイン失敗時設定を格納
    async setSignInFailSetting({ commit }, facilityCd) {
      const mstFacilityHash = await sendRequestGetMstFacilityHashByFacilityCd(facilityCd);
      commit("setAccountLockSetting", mstFacilityHash.data.accountLockSetting);
      commit("setFailureCnt", mstFacilityHash.data.failureCnt);
      commit("setOtpFailureCnt", mstFacilityHash.data.otpFailureCnt);
    },
    // 認証アクション
    // 引数：user -> json(userId, password, facilityCd)
    signIn({ state, commit }, user) {
      // 選択中の患者情報をクリア
      store.dispatch("pat-info/clearSelectedPat");

      commit("setIsSuccess", false);
      commit("setUserId", null);
      commit("setDispUserId", null);
      commit("setUserType", null);
      commit("setAdministrator", null);
      commit("setFacilityCd", null);
      commit("setIsSignOut", false);
      /* add by yangzhaokai 2022-11-01 #7755 サインイン画面にてデベロッパーツールを起動状態でサインイン実行不可 --start */
      // modify 10718 by kangjie 20240711 start
      var consoleStatus = document.getElementById("consoleFrame").contentWindow.isOpenConsole();
      // if (state.isDisableDevtool) {
      if (consoleStatus) {
        // modify 10718 by kangjie 20240711 end
        //commit("setIsDisableDevtool", false); /* delete by shiyw 2022-11-08 #7755 ブラウザのメニューからデベロッパーツールを起動すると、起動を検知して強制サインアウト  */
        const messageResponse = {
          code : 999,
          message : 'デベロッパーツールを開いています。'
        }
        commit("setResponse", messageResponse);
        return null;
      }
      /* add by yangzhaokai 2022-11-01 #7755 サインイン画面にてデベロッパーツールを起動状態でサインイン実行不可 --end */

      // 認証API呼出し
      return sendRequestLogin(user).then(async response => {

        // ユーザータイプを判定
        if (response.data.userType && response.data.userType.toString() === USER_TYPE_FOR_SYSTEM) {
          // システム用アカウントの場合、ログインを失敗させる
          const errorMessageResponse = {
            code: 999,
            message: "認証に失敗しました。認証情報を確認して下さい。",
            hasAuthError: true
          }
          commit("setResponse", errorMessageResponse);
          return;
        }

        const messageResponse = {
          code : response.data.code,
          message : response.data.message
        }
        commit("setResponse", messageResponse);

        /* delete by yangzhaokai 2022-11-01 #7755 サインイン画面にてデベロッパーツールを起動状態でサインイン実行不可 --start */
        //#6694 サインイン画面にてデベロッパーツールを起動状態でサインイン実行不可＋メッセージ
        // let num = 0;
        // const devtools = new Date();
        // devtools.toString = function() {
        //   num++;
        //   if (num > 1) {
        //     messageResponse.code = 999;
        //     messageResponse.message = 'デベロッパーツールを開いています。';
        //     commit("setResponse", messageResponse);
        //     return null;
        //   }
        // }
        // console.log('', devtools);
        /* delete by yangzhaokai 2022-11-01 #7755 サインイン画面にてデベロッパーツールを起動状態でサインイン実行不可 --end */

        //下記のコードが最新版のchromeで失効になる。
        //const element = new Image();
        //Object.defineProperty(element, 'id', {
        //get: function () {
        //messageResponse.code = 999;
        //messageResponse.message = 'デベロッパーツールを開いています。';
        //commit("setResponse", messageResponse);
        //return null;
        //}
        //});
         //console.log('%c', element);
        //ログインが成功した場合、またはotpパスワードなしでログインした場合
        if(response.data.code == null) {
          commit("setIsSuccess", true);
          commit("setUserId", response.data.userId);
          commit("setDispUserId", user.userId);
          commit("setFacilityCd", response.data.facilityCd);
          commit("setUserType", response.data.userType);
          commit("setAdministrator", response.data.administrator);
          // サインイン時刻の設定
          const sTime = new Date().getTime();
          commit("setSignInTimestamp", sTime);
          localStorage.setItem(LOCAL_STORAGE_KEY.SIGN_IN_TIME, sTime);

          // 施設拡張設定を取得
          const responseFacility = await sendRequestGetMstFacilityByCd(response.data.facilityCd)
          .catch(error => {
            throw error;
          });
          let advancedSettings = {};
          try {
            if (responseFacility.data.advancedSettings) {
              advancedSettings = JSON.parse(
                responseFacility.data.advancedSettings
              );
            }
          } catch {
            advancedSettings = {};
          }
          if (!advancedSettings.func_advcds) {
            advancedSettings.func_advcds = [];
          }
          commit("setAdvancedSettings", advancedSettings);
          }
      })
      .catch(async error => {
        //無効なOTPパスワード
        const errorResponse = {
          code : error.response.data.code,
          message : error.response.data.message
        }
        commit("setResponse", errorResponse);
      });
    },
    /**
     * サインアウト処理.
     *
     * @param {*} commit commitオブジェクト
     */
    signOut({ commit }) {

      // サインアウトの場合はタブ内全てがサインアウトされる為、明示的にLocalStorageから情報を削除する
      localStorage.removeItem(LOCAL_STORAGE_KEY.FACILITY_HASH);
      localStorage.removeItem(LOCAL_STORAGE_KEY.SIGN_IN_COUNT);
      // サインイン管理情報を削除する.
      const terminalUniqueString = localStorage.getItem(LOCAL_STORAGE_KEY.TERMINAL_UNIQUE_STRING);
      sendRequestDeleteSignin(terminalUniqueString);
      // サインアウト処理
      return sendRequestLogout().then(() => {
        commit("setUserId", null);
        commit("setDispUserId", null);
        commit("setUserType", null);
        commit("setAdministrator", null);
        commit("setFacilityCd", null);
        commit("setSignInTimestamp", -1);
        commit("setAdvancedSettings", null);
        commit("setIsSignOut", true);
        // 他のタブのサインアウト処理を発火
        localStorage.setItem(LOCAL_STORAGE_KEY.SIGN_OUT_TRIGGER, new Date());
      });
    },
    // add #9703 強制サインアウト時に多重に破棄確認メッセージがでる。 dou start
    signOutForAuthFailed({ commit }) {
      localStorage.removeItem(LOCAL_STORAGE_KEY.FACILITY_HASH);
      localStorage.removeItem(LOCAL_STORAGE_KEY.SIGN_IN_COUNT);
      commit("setUserId", null);
      commit("setDispUserId", null);
      commit("setUserType", null);
      commit("setAdministrator", null);
      commit("setFacilityCd", null);
      commit("setSignInTimestamp", -1);
      commit("setAdvancedSettings", null);
      commit("setIsSignOut", true);
      // 他のタブのサインアウト処理を発火
      store.dispatch("user/clearSignIn");
      store.dispatch("account-edit/clearUserAccountInfo");
      store.dispatch("account-edit/setTheme", 0);
      store.dispatch("bread-crumb/resetKeepHistory");
      router.push({ name: "signin"});
    },
    // add #9703 強制サインアウト時に多重に破棄確認メッセージがでる。 dou end
    // サインイン時刻をクリアする
    clearSignIn({ commit }) {
      commit("setUserId", null);
      commit("setDispUserId", null);
      commit("setUserType", null);
      commit("setAdministrator", null);
      commit("setFacilityCd", null);
      commit("setSignInTimestamp", -1);
      commit("setAdvancedSettings", null);
      commit("setIsSignOut", true);
    },
    /**
     * 利用者マスタより利用者権限情報を取得する.
     * @param {*} commit commitオブジェクト
     */
    fetchUserAuthorityCds({ commit }) {
      return sendRequestGetUserAuthorityCds().then(response => {
        commit("setAuthorityCds", response.data);
      });
    },
    /**
     * 同時サインイン可否
     *
     * @param {*} commit commitオブジェクト
     * @param {String} facilityCd 施設コード
     * @returns {boolean} 同時サインイン許可の場合はtrueを返します.
     */
    /* eslint-disable no-unused-vars */
    async isSyncSignIn({ commit }, facilityCd) {
      return await sendRequestGetMstFacilitySettingValue(facilityCd, SYNC_SIGN_IN)
        .then(response => {
          return response.data === 1;
        }).catch(error => {
          console.log(error);
          return false;
        });
    },
    // サインアウト状態を再設定
    setIsSignOut({ commit }, isSignOut) {
      commit("setIsSignOut", isSignOut);
    },
    // 2要素認証失敗許容回数を施設設定から取得
    preLoadOtpFailureCnt({ commit }, facilityHash) {
      sendRequestGetOtpFailureCntByHash(facilityHash).then(response => {
        commit("setOtpFailureCnt", response.data);
      });
    },
    /* add by yangzhaokai 2022-11-01 #7755 サインイン画面にてデベロッパーツールを起動状態でサインイン実行不可 --start */
    // デベロッパーツールを設定する
    setIsDisableDevtool({ commit }, isDisableDevtool) {
      commit("setIsDisableDevtool", isDisableDevtool);
    },
    /* add by yangzhaokai 2022-11-01 #7755 サインイン画面にてデベロッパーツールを起動状態でサインイン実行不可 --end */
    /* add by liuzhibo 2022-11-22[6872]ログの検索条件に前のユーザ時の条件が表示され、消えない -- start */
    setLastUserId({ commit }, lastUserId) {
      commit("setLastUserId", lastUserId);
    }
    /* add by liuzhibo 2022-11-22[6872]ログの検索条件に前のユーザ時の条件が表示され、消えない -- end */
  },
  getters: {
    // ユーザーID取得
    getDispUserId(state) {
      return state.dispUserId;
    },
    // 管理タイプかどうか
    isAdminUser(state) {
      return state.userType && state.userType.toString() === USER_TYPE_ADMIN;
    },
    // 一般タイプかどうか
    isGeneralUser(state) {
      return state.userType.toString() === USER_TYPE_GENERAL;
    },
    // 管理者ユーザかどうか
    isAdministrator(state) {
      return state.administrator.toString() === USER_TYPE_ADMINISTRATOR;
    },
    // ログイン認証成功かどうか
    isSuccess(state) {
      return state.isSuccess;
    },
    // ユーザタイプ取得
    getUserType(state) {
      return state.userType;
    },
    // 管理者フラグ取得
    getAdministrator(state) {
      return state.administrator;
    },
    // 施設コード取得
    getFacilityCd(state) {
      return state.facilityCd;
    },
    // サインイン時刻取得
    getSignInTimestamp(state) {
      return state.signInTimestamp;
    },
    /**
     * 利用者権限情報を取得する.
     * @param {*} state stateオブジェクト
     */
    getUserAuthorityCds(state) {
      return state.authorityCds;
    },
    // システム利用設定を取得
    getSystemUseSetting(state) {
      return state.systemUseSetting;
    },
    // 施設拡張設定を取得
    getAdvancedSettings(state) {
      return state.advancedSettings;
    },
    //応答メッセージを取得する
    getResponse(state) {
      return state.reponseMessage;
    },
    getUserId(state) {
      return state.userId;
    },
    /**
     * サインイン有無を返す.
     * @param {*} state Stateオブジェクト
     */
    isSignIn(state) {
      return state.dispUserId !== null;
    },
    /**
     * サインアウトしたか否か.
     *
     * @param {*} state stateオブジェクト
     * @returns サインアウトした場合はtrue
     */
    isSignOut(state) {
      return state.isSignOut;
    },
    // アカウントロック設定を取得
    getAccountLockSetting(state) {
      return state.accountLockSetting;
    },
    // サインイン失敗許容回数を取得
    getFailureCnt(state) {
      return state.failureCnt;
    },
    // 2要素認証失敗許容回数を取得
    getOtpFailureCnt(state) {
      return state.otpFailureCnt;
    },
    // xie add メモリにて利用者マスタ一覧取得 Start
    getMstPersonalUser(state) {
      return state.mstPersonalUser;
    },
    // xie add メモリにて利用者マスタ一覧取得 End
    /* add by yangzhaokai 2022-11-01 #7755 サインイン画面にてデベロッパーツールを起動状態でサインイン実行不可 --start */
    getIsDisableDevtool: state => state.isDisableDevtool,
    /* add by yangzhaokai 2022-11-01 #7755 サインイン画面にてデベロッパーツールを起動状態でサインイン実行不可 --end */
    /* add by liuzhibo 2022-11-22[6872]ログの検索条件に前のユーザ時の条件が表示され、消えない -- start */
    getLastUserId: state => state.lastUserId,
    /* add by liuzhibo 2022-11-22[6872]ログの検索条件に前のユーザ時の条件が表示され、消えない -- end */
  }
};
