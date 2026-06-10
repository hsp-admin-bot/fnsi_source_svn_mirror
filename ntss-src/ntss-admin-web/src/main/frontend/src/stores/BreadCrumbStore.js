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
	hisData:[]
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
      // パラメータで指定された階層(depth)以降を履歴より削除
      state.accessHistory.some((v, i) => {
        if (v.depth >= depth)
          state.accessHistory.splice(i, state.accessHistory.length - i);
      });
      // アクセス履歴追加
      state.accessHistory.push({
        depth,
        title,
        routerName,
        historyKey
      });
    },

    // アクセス保持履歴追加(フッター以外から遷移)
    addKeepHistory(state, { depth, title, routerName, historyKey }) {
      // アクセス履歴追加
      state.accessKeepHistory.push({
        depth,
        title,
        routerName,
        historyKey
      });
    },
    sethisData(state,history){
      state.hisData = history
    },

    setKeepHistory(state, keepHistory) {
      state.accessKeepHistory = keepHistory;
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
	gethisData(state){
      return state.hisData
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
