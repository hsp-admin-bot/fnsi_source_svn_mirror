import axios from "axios";
import store from "@/stores";
import router from "@/router";

// mod FNSI-#9201の修正 解 start
/**
 * Httpステータスに応じたメッセージを取得する.
 * @param {*} error Error
 */
function getApiErrorMessage(error) {
  
  const status = error.response.status;
  if (
    error.response &&
    error.response.data &&
    error.response.data.message
  ) {
      return error.response.data.message;
  }
  else if (status === 401) {
      return "認証に失敗しました。認証情報を確認して下さい。";
  }
  
  return "システムエラーが発生しましたので処理を終了します。";
}
// mod FNSI-#9201の修正 解 start

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

  store.dispatch("app/setApiResult", {
    status: status,
    message: getApiErrorMessage(error)
  });
  
  const isFacility = store.getters["user/isFacilityRole"];
  const isUser = store.getters["user/isUserRole"];
  const curRoute = router.currentRoute;
  if (isUser) {
    if (curRoute.name !== "clManagementLogin") {
      router.push({ name: "clManagementLogin" });
    }
  } else if (isFacility) {
    if (curRoute.name !== "clDownloadLogin") {
      router.push({ name: "clDownloadLogin" });
    }
  } else {
    if (
      curRoute.name !== "clManagementLogin" &&
      curRoute.name !== "clDownloadLogin"
    ) {
      router.push({ name: "clManagementLogin" });
    }
  }

  // Httpステータス 400 は各画面(機能)でエラー処理の実施が必要
  // Httpステータス 409 はメッセージ表示以外の処理が必要な場合は各画面(機能)でエラー処理を実装する
  return Promise.reject(error);
}

/**
 * リクエスト送信可能な状態かどうかを判定する.
 */
function isValid() {
  // 別タブでサインインされていないか
  // （サインイン時刻が一致しているかどうかで判定する）
  const timestampInStore = store.getters["user/getSignInTimestamp"];
  const timestampInStorage = localStorage.getItem("s-time")
    ? Number(localStorage.getItem("s-time"))
    : -1;
  if (timestampInStore >= 0 && timestampInStore !== timestampInStorage) {
    store.dispatch("user/clearSignIn");
    store.dispatch("account-edit/setTheme", 0);
    return false;
  }
  return true;
}

/**
 * AxiosHelper
 */
const AxiosHelper = class {
  /**
   * コンストラクタ
   */
  constructor() {
    this.http = axios.create({ baseURL: "/ntss-certificate-download/api" });

    this.http.interceptors.request.use(config => {
      // リクエスト送信可能な状態かどうか
      const signInRestriction = store.getters["user/getSignInRestriction"];
      if (signInRestriction && !isValid()) {
        const error = {
          status: 401,
          response: {
            data: {
              useResponseMessage: true,
              message:
                "<div style='text-align: left'><ul><li>別のタブで、他のサインインを検出しました。</li><li>操作を続ける場合は、確認の上、再度サインインしてください。</li></ul></div>"
            }
          }
        };
        return Promise.reject(error);
      }

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

    this.http.interceptors.response.use(
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
    return this.http.get(url, { params: params });
  }

  /**
   * POSTリクエスト送信
   * @param {*} url RestAPI URL
   * @param {*} params 送信パラメータ
   */
  post(url, params) {
    return this.http.post(url, params);
  }

  /**
   * PUTリクエスト送信
   * @param {*} url RestAPI URL
   * @param {*} params 送信パラメータ
   */
  put(url, params, config) {
    return this.http.put(url, params, config);
  }

  /**
   * DELETEリクエスト送信
   * @param {*} url RestAPI URL
   * @param {*} params 送信パラメータ
   */
  delete(url, params) {
    return this.http.delete(url, { params: params });
  }
};

export const ApiHelper = new AxiosHelper();
