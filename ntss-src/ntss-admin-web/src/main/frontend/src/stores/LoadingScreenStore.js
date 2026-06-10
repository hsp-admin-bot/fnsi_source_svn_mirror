/**
 * 共通ローダー用Store
 */
export default {
  namespaced: true,
  state: {
    displayCount: 0,  // 表示カウンタ
    value: ""         // 表示文字列
  },
  mutations: {
    setDisplayCount(state, count) {
      state.displayCount = count;
    },
    setStateValue(state, value) {
      state.value = value;
    }
  },
  actions: {
    // 表示開始
    startLoadingScreen({ dispatch }, message) {
      // message省略時は"処理中・・・"とする
      const normalizedMessage = (message != null) ? `${message}` : "処理中・・・";
      dispatch("setLoadingScreenMessage", normalizedMessage);
      dispatch("setLoadingScreenVisible", true);
    },
    // 表示終了
    finishLoadingScreen({ dispatch }) {
      dispatch("setLoadingScreenVisible", false);
    },
    // 共通ローダー付きで関数を実行する
    async executeWithLoadingScreen({ dispatch }, asyncTask) {
      dispatch("startLoadingScreen");
      let result = undefined;
      try {
        result = await (typeof asyncTask === "function" ? asyncTask() : asyncTask);
      } finally {
        dispatch("finishLoadingScreen");
      }
      return result;
    },

    // 表示状態設定
    setLoadingScreenVisible({ state, commit }, isVisible) {
      // 表示(true) = カウントアップ、非表示(false) = カウントダウン
      let tmpCount = state.displayCount;
      if (isVisible === true) {
        tmpCount++;
      } else if (isVisible === false && tmpCount > 0) {
        tmpCount--;
      }
      commit("setDisplayCount", tmpCount);
    },
    // 表示文字列設定
    setLoadingScreenMessage({ commit }, value) {
      commit("setStateValue", value);
    },
    // 強制非表示
    resetLoadingScreenVisibleCount({ commit }) {
      commit("setDisplayCount", 0);
    }
  },
  getters: {
    // 表示状態取得
    getLoadingScreenVisible(state) {
      return state.displayCount > 0;
    },
    // 表示文字列取得
    getLoadingScreenMessage(state) {
      return state.value;
    }
  }
};
