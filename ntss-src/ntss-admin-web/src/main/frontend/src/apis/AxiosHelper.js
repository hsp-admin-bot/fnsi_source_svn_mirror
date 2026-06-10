import axios from "axios";
import store from "@/stores";
import router from "@/router";
import ons from 'onsenui';

/**
 * Httpステータスに応じたメッセージを取得する.
 * @param {*} error Error
 */
function getApiErrorMessage(error) {
  const status = error.response.status;
  if (status === 400) {
    // Bad Request
    return "無効なリクエストです。";
  }
  if (status === 401 && !error.response.data.useResponseMessage) {
    // Unauthorized
    return "認証に失敗しました。認証情報を確認して下さい。";
  } else if (status === 403){
    //Forbidden
    if(error.response.data.message === "Bad credentials"){
      return "認証に失敗しました。認証情報を確認して下さい。";
    } else if (error.response.data.message.indexOf("This session has been expired") === 0) {
      return "このセッションは期限切れです。";
    } else {
      return error.response.data.message;
    }
  }
  // Others
  if (
    error.response &&
    error.response.data &&
    error.response.data.useResponseMessage
  ) {
    return error.response.data.message;
  }
  return "システムエラーが発生しました。";
}

/**
 * API成功時ハンドラ
 * @param {*} response レスポンス
 */
function handleSuccess(response) {
  store.dispatch("app/clearApiResult");
  return Promise.resolve(response);
}

/**
 * APIエラー時ハンドラ
 * @param {*} error エラー
 */
function handleError(error) {
  const status = error.response.status;
  if (status === 409) {
    if (!error.response.data) {
      // Httpステータス 409 はメッセージを表示する
      // NOTE : レスポンスデータが未指定の場合、排他エラーメッセージを表示
      ons.notification.alert({
        title: "排他エラー",
        message: getApiErrorMessage(error)
      });
    }
  } else if (status !== 400) {
    // Httpステータス 400 以外はログイン画面へ遷移させる
    store.dispatch("app/setApiResult", {
      status: status,
      message: getApiErrorMessage(error)
    });
    if (status === 403 && error.response.data.code == 0) {
      // mod #9703 強制サインアウト時に多重に破棄確認メッセージがでる。 dou start
      // router.push({ name: "signin"});
      store.dispatch("user/signOutForAuthFailed");
      // mod #9703 強制サインアウト時に多重に破棄確認メッセージがでる。 dou end
    } else {
      const userInfo = store.getters["account-edit/getStateUserAccountInfo"];
      const isStaff = (!userInfo || userInfo.patId === null || userInfo.patId <= 0) ? true : false;
      if (isStaff){
        if (status === 401 && error.response.data.useResponseMessage){
          // mod #9703 強制サインアウト時に多重に破棄確認メッセージがでる。 dou start
          // 無操作タイムアウトの場合はエラー情報なしでサインイン画面に遷移
          // router.push({ name: "signin" });
          store.dispatch("user/signOutForAuthFailed");
          // mod #9703 強制サインアウト時に多重に破棄確認メッセージがでる。 dou end
        } else {
          // エラー情報をパラメータとして含める
          const now = new Date();
          const month = parseInt(now.getMonth()) + parseInt(1);
          const strNow = now.getFullYear() + "-" + month + "-" + now.getDate() + " " + now.getHours() + ":" + now.getMinutes() + ":" + now.getSeconds()
          let params = {
            errCode: status,
            path: router.currentRoute,
            url: location.href,
            pathname: location.pathname,
            errorMEssage: error,
            errorDate: strNow
          }
          // 施設スタッフは通常のサインイン画面に遷移
          //Mod FNSI-500 Error Fix 関 start
          // router.push({ name: "signin", params: params });
          //Mod FNSI-500 Error Fix 関 end
        }
      } else {
        // 在宅透析患者は患者用のサインイン画面に遷移
        router.push({ name: "signinhome" });
      }
    }
  }
  // Httpステータス 400 は各画面(機能)でエラー処理の実施が必要
  // Httpステータス 409 はメッセージ表示以外の処理が必要な場合は各画面(機能)でエラー処理を実装する
  return Promise.reject(error);
}

/**
 * AxiosHelper
 */
let AxiosHelper = class {
  /**
   * コンストラクタ
   */
  constructor() {

    this.$http = axios.create({ baseURL: "/ntss-admin-web/api" });

    this.$http.interceptors.request.use(config => {

      // リクエストキャッシュ対策
      if (typeof config.params === "undefined") {
        config.params = {};
      }
      if (typeof config.params === "object") {
        if (
          typeof URLSearchParams === "function" &&
          config.params instanceof URLSearchParams
        ) {
          config.params.append("_", Date.now());
        } else {
          config.params._ = Date.now();
        }
      }
      return config;
    });

    this.$http.interceptors.response.use(
      response => handleSuccess(response),
      error => handleError(error)
    );
  }

  /**
   * GETリクエスト送信
   * @param {*} url RestAPI URL
   * @param {*} params 送信パラメータ
   */
  get(url, params) {
    return this.$http.get(url, { params: params });
  }

  /**
   * GETリクエスト送信
   * @param {*} url RestAPI URL
   * @param {*} params 送信パラメータ
   * @param {*} config 設定
   */
  configGet(url, params, config) {
    return this.$http.get(url, {
      params: params,
      ...config,
    });
  }

  /**
   * POSTリクエスト送信
   * @param {*} url RestAPI URL
   * @param {*} params 送信パラメータ
   */
  post(url, params) {
    return this.$http.post(url, params);
  }

  /**
   * POSTリクエスト送信
   * @param {*} url RestAPI URL
   * @param {*} params 送信パラメータ
   * @param {*} config 設定
   */
  configPost(url, params, config) {
    return this.$http.post(url, params, config);
  }
  /**
   * PUTリクエスト送信
   * @param {*} url RestAPI URL
   * @param {*} params 送信パラメータ
   */
  put(url, params, config) {
    return this.$http.put(url, params, config);
  }

  /**
   * DELETEリクエスト送信
   * @param {*} url RestAPI URL
   * @param {*} params 送信パラメータ
   */
  delete(url, params) {
    return this.$http.delete(url, { params: params });
  }
};

export let ApiHelper = new AxiosHelper();
