function isSameHistoryEntry(left, right) {
  return String(left?.depth ?? "") === String(right?.depth ?? "")
    && String(left?.title ?? "") === String(right?.title ?? "")
    && String(left?.routerName ?? "") === String(right?.routerName ?? "")
    && String(left?.historyKey ?? "") === String(right?.historyKey ?? "");
}

function cloneHistoryList(historyList) {
  return Array.isArray(historyList) ? historyList.map((item) => ({ ...item })) : [];
}

/**
 * パンくずリスト制御情報Store
 */
export default {
  namespaced: true,
  state: {
    // アクセス履歴（階層(depth)と画面名(title)と
    // ルーター名(routerName)と履歴特定キー(historyKey)を管理）
    accessHistory: [],
    // アクセス保持履歴(フッター画面遷移のみ履歴クリア)
    accessKeepHistory: [],
    // add #8043 2022/10/26 【デグレ】ブラウザバックするとパンくずリストに追加される dou start
    popstate: false,
    // add #8043 2022/10/26 【デグレ】ブラウザバックするとパンくずリストに追加される dou end
    fromName: '',
    hisData: []
  },
  mutations: {
    // add #8043 2022/10/26 【デグレ】ブラウザバックするとパンくずリストに追加される dou start
    setPopstate(state) {
      state.popstate = true;
    },
    clearPopstate(state) {
      state.popstate = false;
    },
    setFromName(state, { fromName }) {
      state.fromName = fromName;
    },
    // add #8043 2022/10/26 【デグレ】ブラウザバックするとパンくずリストに追加される dou end
    // アクセス履歴リセット
    resetHistory(state) {
      state.accessHistory.splice(0, state.accessHistory.length);
    },
    // アクセス保持履歴リセット
    resetKeepHistory(state) {
      state.accessKeepHistory.splice(0, state.accessKeepHistory.length);
    },

    // アクセス履歴追加
    addHistory(state, { depth, title, routerName, historyKey }) {
      const nextHistory = {
        depth,
        title,
        routerName,
        historyKey
      };

      // パラメータで指定された階層(depth)以降を履歴より削除
      const replaceIndex = state.accessHistory.findIndex((v) => v.depth >= depth);
      if (replaceIndex >= 0) {
        const existing = state.accessHistory[replaceIndex];
        if (replaceIndex === state.accessHistory.length - 1 && isSameHistoryEntry(existing, nextHistory)) {
          return;
        }
        state.accessHistory.splice(replaceIndex, state.accessHistory.length - replaceIndex);
      }

      const lastHistory = state.accessHistory[state.accessHistory.length - 1];
      if (isSameHistoryEntry(lastHistory, nextHistory)) {
        return;
      }

      // アクセス履歴追加
      state.accessHistory.push(nextHistory);
    },

    // アクセス保持履歴追加(フッター以外から遷移)
    addKeepHistory(state, { depth, title, routerName, historyKey }) {
      const nextHistory = {
        depth,
        title,
        routerName,
        historyKey
      };
      const lastHistory = state.accessKeepHistory[state.accessKeepHistory.length - 1];
      if (isSameHistoryEntry(lastHistory, nextHistory)) {
        return;
      }
      // アクセス履歴追加
      state.accessKeepHistory.push(nextHistory);
    },

    sethisData(state, history) {
      state.hisData = history;
    },

    setKeepHistory(state, keepHistory) {
      state.accessKeepHistory = cloneHistoryList(keepHistory);
    },

    // タイトルをリセットする
    resetTitle(state, { depth, newTitle }) {
      state.accessHistory.some(e => {
        if (e.depth === depth) {
          e.title = newTitle;
          return true;
        }
        return false;
      });
    },
  },
  getters: {
    // add #8043 2022/10/26 【デグレ】ブラウザバックするとパンくずリストに追加される dou start
    getPopstate(state) {
      return state.popstate;
    },
    // add #8043 2022/10/26 【デグレ】ブラウザバックするとパンくずリストに追加される dou end
    // アクセス履歴配列取得
    getHistory(state) {
      return state.accessHistory;
    },
    // アクセス保持履歴配列取得
    getKeepHistory(state) {
      return state.accessKeepHistory;
    },

    // 指定された階層のタイトルを取得
    getTitle: state => depth => {
      const e = state.accessHistory.find(e => {
        return e.depth === depth;
      });
      return e ? e.title : "";
    },
    getFromName(state) {
      return state.fromName;
    },
    gethisData(state) {
      return state.hisData;
    },
  },
  actions: {
    // add #8043 2022/10/26 【デグレ】ブラウザバックするとパンくずリストに追加される dou start
    setPopstate({ commit }) {
      commit("setPopstate");
    },
    clearPopstate({ commit }) {
      commit("clearPopstate");
    },
    // add #8043 2022/10/26 【デグレ】ブラウザバックするとパンくずリストに追加される dou end
    setFromName({ commit }, {fromName}) {
      commit("setFromName", {fromName});
    },    
    // アクセス履歴リセット
    resetHistory({ commit }) {
      commit("resetHistory");
    },

    // アクセス保持履歴リセット
    resetKeepHistory({ commit }) {
      commit("resetKeepHistory");
    },

    // アクセス履歴追加
    addHistory({ commit }, { depth, title, routerName, historyKey }) {
      if (!depth) {
        // 階層未設定の場合、履歴をリセット＆履歴管理対象外
        commit("resetHistory");
        return;
      }
      commit("addHistory", {
        depth,
        title,
        routerName,
        historyKey
      });
    },

    // アクセス保持履歴追加
    addKeepHistory(
      { commit },
      { depth, title, routerName, historyKey, accessKey = null }
    ) {
      if (accessKey === "footer") {
        // パラメータで指定された階層(depth)以降を履歴より削除
        commit("resetKeepHistory");
      }

      if (!depth) {
        // 階層未設定の場合、履歴をリセット＆履歴管理対象外
        commit("resetKeepHistory");
        return;
      }
      commit("addKeepHistory", {
        depth,
        title,
        routerName,
        historyKey
      });
    },

    setKeepHistory({ commit }, keepHistory) {
      commit("setKeepHistory", keepHistory);
    },

    sethisData({ commit }, history) {
      commit("sethisData", history);
    },

    // タイトルをリセットする
    resetTitle({ commit }, param) {
      commit("resetTitle", param);
    },
  }
};
