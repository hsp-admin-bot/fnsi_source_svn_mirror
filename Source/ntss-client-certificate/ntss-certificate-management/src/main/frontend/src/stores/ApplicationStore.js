/**
 * アプリケーション共通のstore
 */
export default {
  strict: true,
  namespaced: true,
  state: {
    apiResult: {
      status: 200,
      message: ""
    }
  },
  mutations: {
    // API処理結果クリア
    clearApiResult(state) {
      state.apiResult.status = 200;
      state.apiResult.message = "";
    },
    // API処理結果設定
    setApiResult(state, { status, message }) {
      state.apiResult.status = status;
      state.apiResult.message = message;
    }
  },
  actions: {
    clearApiResult({ commit }) {
      commit("clearApiResult");
    },
    setApiResult({ commit }, { status, message }) {
      commit("setApiResult", { status: status, message: message });
    }
  },
  getters: {
    getApiResult(state) {
      return state.apiResult;
    },
    hasApiError(state) {
      return state.apiResult.status !== 200;
    }
  }
};
