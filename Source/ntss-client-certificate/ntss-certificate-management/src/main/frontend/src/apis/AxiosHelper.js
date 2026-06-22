import axios from "axios";
import store from "@/stores";
import router from "@/router";
import ons from "onsenui";

// ★追加：セッションエラーアラートの多重表示防止フラグ
// 同一ページで複数のリクエストが並行して 401 を受け取った場合でも、
// アラートは1回だけ表示する。
let isSessionErrorAlerted = false;

/**
 * Httpステータスに応じたメッセージを取得する.
 * @param {*} error Error
 */

function getApiErrorMessage(error) {
  /*
  const status = error.response.status;
  if (status === 400) {
    // Bad Request
    return "無効なリクエストです。";
  }
  if (status === 401 && !error.response.data.useResponseMessage) {
    // Unauthorized
    return "認証に失敗しました。認証情報を確認して下さい。";
  } else if (status === 403) {
    //Forbidden
    if (error.response.data.message === "Bad credentials") {
      return "認証に失敗しました。認証情報を確認して下さい。";
    } else {
      return error.response.data.message;
    }
  }


   */
  // Others
  if (
    error.response &&
    error.response.data &&
    error.response.data.message
  ) {
    if (error.response.data.message.indexOf('認証に失敗') >= 0 ||
      error.response.data.message.indexOf('ロック') >= 0) {
      return error.response.data.message;
    }

  }
  return "システムエラーが発生しましたので処理を終了します。";
}

// del FNSI-#4445の修正 解 end

/**
 * API成功時ハンドラ
 * @param {*} response レスポンス
 */
function handleSuccess(response) {
  store.dispatch("app/clearApiResult");
  return Promise.resolve(response);
}

function getCurrentRouteName() {
  const curRoute = router.currentRoute && router.currentRoute.value
    ? router.currentRoute.value
    : router.currentRoute;
  return curRoute && curRoute.name;
}

function pushLoginRoute(routeName) {
  if (getCurrentRouteName() !== routeName) {
    router.push({ name: routeName });
  }
}

/**
 * APIエラー時ハンドラ
 * @param {*} error エラー
 */
function handleError(error) {
  // mod 6365の修正 xiebzh start
  // mod 6674の修正 xiebzh start
  //if (error && error.response && error.response.data.indexOf('duplicated') >= 0) {
  if (error && error.response && error.response.data && !error.response.data.message && error.response.data.indexOf('duplicated') >= 0) {
  // mod 6674の修正 xiebzh end
    return Promise.reject(error);
  }
  // mod 6365の修正 xiebzh end
  // del FNSI-#4445の修正 解 start
  //const status = error.response.status;

  //if (status === 409) {
    // Httpステータス 409 はメッセージを表示する
  const status = error.response.status;
  if (status !== 401) {
    ons.notification.alert({
      title: "エラー",
      message: getApiErrorMessage(error)
    });
  }

  //} else if (status !== 400)

    //store.dispatch("app/setApiResult", {
    //  status: status,
    //  message: getApiErrorMessage(error)
    //});

    const isFacility = store.getters["user/isFacilityRole"];
    const isUser = store.getters["user/isUserRole"];

    if (status === 401) {
      // ★追加：クロスタブ・セッション乗っ取り対策
      // 別タブで別ユーザーがログインしてセッションが入れ替わった場合に 401 が返る。
      // ユーザーに通知してからログイン画面へ遷移する。
      // alert の callback 内でリダイレクトすることで、
      // ユーザーがメッセージを確認してから画面が切り替わる。
      store.dispatch("user/clearSignIn");
      if (!isSessionErrorAlerted) {
        isSessionErrorAlerted = true;
        ons.notification.alert({
          title: "セッションエラー",
          message: "別のユーザーでログインが行われたため、ログイン画面に戻ります。",
          callback: () => {
            isSessionErrorAlerted = false;
            if (isUser) {
              pushLoginRoute("clManagementLogin");
            } else if (isFacility) {
              pushLoginRoute("clDownloadLogin");
            } else {
              pushLoginRoute("clManagementLogin");
            }
          }
        });
      }
      // Promise.reject() を返すと呼び出し元コンポーネントで未捕捉エラーが発生するため、
      // 永続 pending の Promise を返して伝播を抑止する。
      return new Promise(() => {});
    }

    if (isUser) {
      if (getCurrentRouteName() !== "clManagementLogin") {
        store.dispatch("user/clearSignIn");
        pushLoginRoute("clManagementLogin");
      }
    } else if (isFacility) {
      if (getCurrentRouteName() !== "clDownloadLogin") {
        store.dispatch("user/clearSignIn");
        pushLoginRoute("clDownloadLogin");
      }
    } else {
      if (
        getCurrentRouteName() !== "clManagementLogin" &&
        getCurrentRouteName() !== "clDownloadLogin"
      ) {
        store.dispatch("user/clearSignIn");
        pushLoginRoute("clManagementLogin");
      }
    }

  //} else {
    //store.dispatch("app/setApiResult", {
    //  status: status,
    //  message: getApiErrorMessage(error)
    //});
 // }
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
    this.http = axios.create({ baseURL: "/ntss-certificate-management/api" });

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

      // ★追加：クロスタブ・セッション乗っ取り対策
      // このタブでログインしたユーザーID（グローバル変数）をリクエストヘッダーに付与する。
      // サーバー側の CurrentUserHeaderFilter が実際のセッションユーザーと照合し、
      // 不一致の場合は処理を実行せずに 401 を返す。
      if (window.__ntssLoginUserId) {
        config.headers = config.headers || {};
        config.headers["X-Expected-User"] = window.__ntssLoginUserId;
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
