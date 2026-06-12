/**
 * アプリケーション共通のstore
 */

/** vue-onsenui グローバルダイアログ（v-ons-alert-dialog）用 Promise 完了コールバック */
let pendingOnsAlert = null;
let pendingOnsConfirm = null;

function normalizeOnsButtonLabels(buttonLabels, fallbackLabels) {
  if (typeof buttonLabels === "string") {
    return [buttonLabels];
  }
  if (!Array.isArray(buttonLabels) || buttonLabels.length === 0) {
    return fallbackLabels;
  }
  return buttonLabels.map(label => label != null ? String(label) : "");
}

export default {
  strict: true,
  namespaced: true,
  state: {
    path: {
      protocol: "",
      host: "",
      pathname: "",
      key: ""
    },
    apiResult: {
      status: 200,
      message: ""
    },
    queryParameters: {},
    functionCd: "",
    refreshKeyObj: {
      status: false,
      date: 0
    },
    /** ルーター／API 等からの共通アラート・確認（vue-onsenui / v-ons-alert-dialog） */
    onsDialog: {
      visible: false,
      mode: "alert",
      title: "",
      message: "",
      messageHTML: "",
      buttonLabels: ["OK"],
      modifier: "",
      dialogClass: "",
      /** 確認ダイアログでマスク／バックキー等によるキャンセルを許可するか（false のときはボタンのみ） */
      cancelable: false
    }
  },
  mutations: {
    // store設定
    setState(state, connectInfo) {
      state.path.protocol = connectInfo.protocol;
      state.path.host = connectInfo.host;
      state.path.pathname = connectInfo.pathname;
      state.path.key = connectInfo.key;
    },
    // storeクリア
    clear(state) {
      state.path.protocol = "";
      state.path.host = "";
    },
    // API処理結果クリア
    clearApiResult(state) {
      state.apiResult.status = 200;
      state.apiResult.message = "";
    },
    // API処理結果設定
    setApiResult(state, { status, message }) {
      state.apiResult.status = status;
      state.apiResult.message = message;
    },
    // クエリパラメータ設定
    setQueryParameters(state, queryParameters) {
      state.queryParameters = queryParameters;
    },
    // 機能コード設定
    setFunctionCd(state, functionCd) {
      state.functionCd = functionCd;
    },
    refreshFunction(state, obj) {
      state.refreshKeyObj = obj;
    },
    setOnsDialog(state, payload) {
      state.onsDialog = { ...state.onsDialog, ...payload };
    },
    resetOnsDialog(state) {
      state.onsDialog.visible = false;
      state.onsDialog.mode = "alert";
      state.onsDialog.title = "";
      state.onsDialog.message = "";
      state.onsDialog.messageHTML = "";
      state.onsDialog.buttonLabels = ["OK"];
      state.onsDialog.modifier = "";
      state.onsDialog.dialogClass = "";
      state.onsDialog.cancelable = false;
    }
  },
  actions: {
    setState({ commit }, connectInfo) {
      commit("setState", connectInfo);
    },
    clear({ commit }) {
      commit("clear");
    },
    clearApiResult({ commit }) {
      commit("clearApiResult");
    },
    setApiResult({ commit }, { status, message }) {
      commit("setApiResult", { status: status, message: message });
    },
    setQueryParameters({ commit }, queryParameters) {
      commit("setQueryParameters", queryParameters);
    },
    setFunctionCd({ commit }, functionCd) {
      commit("setFunctionCd", functionCd);
    },
    refreshFunction({ commit }, obj) {
      commit("refreshFunction", obj);
    },
    /**
     * アラート表示（単一 OK）。完了時に Promise resolve
     * @param {{ title?: string | null, message?: string | null, messageHTML?: string | null, buttonLabels?: unknown }} payload
     */
    showOnsAlert({ commit }, { title, message, messageHTML, buttonLabels, modifier, dialogClass }) {
      return new Promise((resolve) => {
        if (pendingOnsAlert) {
          pendingOnsAlert();
          pendingOnsAlert = null;
        }
        if (pendingOnsConfirm) {
          pendingOnsConfirm(false);
          pendingOnsConfirm = null;
        }
        pendingOnsAlert = resolve;
        commit("setOnsDialog", {
          visible: true,
          mode: "alert",
          title: title != null ? String(title) : "",
          message: message != null ? String(message) : "",
          messageHTML: messageHTML != null ? String(messageHTML) : "",
          buttonLabels: normalizeOnsButtonLabels(buttonLabels, ["OK"]),
          modifier: modifier != null ? String(modifier) : "",
          dialogClass: dialogClass != null ? dialogClass : "",
          cancelable: false
        });
      });
    },
    /**
     * 確認ダイアログ（OK / キャンセル）。選択されたボタンの index を返す
     * @param {{ title?: string | null, message?: string | null, messageHTML?: string | null, buttonLabels?: unknown, cancelable?: boolean }} payload
     */
    showOnsConfirm({ commit }, { title, message, messageHTML, buttonLabels, cancelable, modifier, dialogClass }) {
      return new Promise((resolve) => {
        if (pendingOnsAlert) {
          pendingOnsAlert();
          pendingOnsAlert = null;
        }
        if (pendingOnsConfirm) {
          pendingOnsConfirm(false);
          pendingOnsConfirm = null;
        }
        pendingOnsConfirm = resolve;
        commit("setOnsDialog", {
          visible: true,
          mode: "confirm",
          title: title != null ? String(title) : "",
          message: message != null ? String(message) : "",
          messageHTML: messageHTML != null ? String(messageHTML) : "",
          // buttonLabels: normalizeOnsButtonLabels(buttonLabels, ["キャンセル", "OK"]),
          buttonLabels: normalizeOnsButtonLabels(buttonLabels, ["Cancel", "OK"]),
          modifier: modifier != null ? String(modifier) : "",
          dialogClass: dialogClass != null ? dialogClass : "",
          cancelable: cancelable === true
        });
      });
    },
    dismissOnsAlert({ commit }) {
      if (!pendingOnsAlert) {
        return;
      }
      commit("resetOnsDialog");
      const resolve = pendingOnsAlert;
      pendingOnsAlert = null;
      resolve();
    },
    confirmOnsDialog({ commit }, answer = 1) {
      if (!pendingOnsConfirm) {
        return;
      }
      commit("resetOnsDialog");
      const resolve = pendingOnsConfirm;
      pendingOnsConfirm = null;
      resolve(Number.isInteger(answer) ? answer : 1);
    },
    cancelOnsDialog({ commit }, answer = 0) {
      if (!pendingOnsConfirm) {
        return;
      }
      commit("resetOnsDialog");
      const resolve = pendingOnsConfirm;
      pendingOnsConfirm = null;
      resolve(Number.isInteger(answer) ? answer : 0);
    }
  },
  getters: {
    getProtocol(state) {
      return state.path.protocol;
    },
    getHost(state) {
      return state.path.host;
    },
    getPathname(state) {
      return state.path.pathname;
    },
    getKey(state) {
      return state.path.key;
    },
    // ログイン画面へ遷移する際、URLにパラメータが含まれている場合に書き変わらない為、
    // window.locationに下記値を渡して遷移するように変更
    getUrl(state) {
      let url = state.path.pathname
        ? `${state.path.protocol}//${state.path.host}/${state.path.pathname}`
        : `${state.path.protocol}//${state.path.host}`;

      if (state.path.key) {
        url += "#/?key=" + state.path.key;
      }

      return url;
    },
    getApiResult(state) {
      return state.apiResult;
    },
    hasApiError(state) {
      return state.apiResult.status !== 200;
    },
    getQueryParameters(state) {
      return state.queryParameters;
    },
    getFunctionCd(state) {
      return state.functionCd;
    },
    getRefresh(state) {
      return state.refreshKeyObj;
    },
    getOnsDialog(state) {
      return state.onsDialog;
    }
  }
};
