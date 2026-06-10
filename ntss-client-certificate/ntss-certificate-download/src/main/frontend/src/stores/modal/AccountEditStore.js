/**
 * アカウント編集Store.
 */

export default {
  strict: true,
  namespaced: true,
  state: {
    fontSize: 1,
    theme: 0
  },
  mutations: {
    /**
     * 文字サイズ設定.
     */
    setFontSize(state, fontSize) {
      state.fontSize = fontSize;
    },
    /**
     * テーマ設定.
     */
    setTheme(state, theme) {
      state.theme = theme;
    }
  },
  actions: {
    /**
     * 文字サイズ設定処理.
     */
    setFontSize({ commit }, fontSize) {
      commit("setFontSize", fontSize);
    },
    /**
     * テーマ設定処理.
     */
    setTheme({ commit }, theme) {
      commit("setTheme", theme);
    },
    /**
     * テーマリセット処理.
     */
    resetTheme({ commit }) {
      commit("setTheme", 0);
    }
  },
  getters: {
    getTheme(state) {
      return state.theme;
    },
    getFontSize(state) {
      return state.fontSize;
    }
  }
};
