/**
 * 共通ローダー用Store
 */
export default {
  namespaced: true,
  state: {
    displayCount: 0,  // 表示カウンタ
    suspendCount: 0,  // ダイアログ表示中の一時非表示カウンタ
    locked: false,    // 親画面の一括読込中は子の start/finish を無視する
    suppressedLoadCount: 0, // lock 中に start された子コンポーネント用（finish のみ後から来る場合の整合）
    value: ""         // 表示文字列
  },
  mutations: {
    setDisplayCount(state, count) {
      state.displayCount = count;
    },
    setSuppressedLoadCount(state, count) {
      state.suppressedLoadCount = count;
    },
    setStateValue(state, value) {
      state.value = value;
    },
    setSuspendCount(state, count) {
      state.suspendCount = count;
    },
    setLocked(state, locked) {
      state.locked = locked;
    }
  },
  actions: {
    // 表示開始
    startLoadingScreen({ state, commit, dispatch }, message) {
      if (state.locked) {
        commit("setSuppressedLoadCount", state.suppressedLoadCount + 1);
        return;
      }
      // message省略時は"処理中・・・"とする
      const normalizedMessage = (message != null) ? `${message}` : "処理中・・・";
      dispatch("setLoadingScreenMessage", normalizedMessage);
      dispatch("setLoadingScreenVisible", true);
    },
    // 表示終了
    finishLoadingScreen({ state, commit, dispatch }) {
      if (state.suppressedLoadCount > 0) {
        commit("setSuppressedLoadCount", state.suppressedLoadCount - 1);
        return;
      }
      if (state.locked) {
        return;
      }
      dispatch("setLoadingScreenVisible", false);
    },
    lockLoadingScreen({ commit }) {
      commit("setLocked", true);
      commit("setSuppressedLoadCount", 0);
    },
    unlockLoadingScreen({ commit }) {
      commit("setLocked", false);
    },
    // 共通ローダー付きで関数を実行する
    async executeWithLoadingScreen({ dispatch }, asyncTask) {
      dispatch("startLoadingScreen");
      let result;
      try {
        result = await (typeof asyncTask === "function" ? asyncTask() : asyncTask);
      } finally {
        dispatch("finishLoadingScreen");
      }
      return result;
    },

    // ダイアログ表示中だけ共通ローダーの可視状態を一時停止する
    suspendLoadingScreen({ state, commit }) {
      commit("setSuspendCount", state.suspendCount + 1);
    },
    // ダイアログ終了後に共通ローダーの可視状態を復帰する
    resumeLoadingScreen({ state, commit }) {
      const tmpCount = state.suspendCount > 0 ? state.suspendCount - 1 : 0;
      commit("setSuspendCount", tmpCount);
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
      commit("setSuspendCount", 0);
      commit("setSuppressedLoadCount", 0);
      commit("setLocked", false);
    }
  },
  getters: {
    getLoadingScreenLocked(state) {
      return state.locked;
    },
    // 表示状態取得
    getLoadingScreenVisible(state) {
      return state.displayCount > 0 && state.suspendCount === 0;
    },
    // 表示文字列取得
    getLoadingScreenMessage(state) {
      return state.value;
    }
  }
};
