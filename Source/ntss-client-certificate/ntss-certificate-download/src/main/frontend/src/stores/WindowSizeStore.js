/**
 * Windowサイズ管理用Store
 */

export default {
  namespaced: true,
  state: {
    windowHeight: 0, // Window高
    windowWidth: 0, // Window幅
  },
  mutations: {
    setSize(state, { windowHeight, windowWidth }) {
      // Window高設定
      state.windowHeight = windowHeight;

      // Window幅設定
      state.windowWidth = windowWidth;
    }
  },
  actions: {
    // Window(高・幅)設定
    setSize({ commit }, { windowHeight, windowWidth }) {
      commit("setSize", {
        windowHeight: windowHeight,
        windowWidth: windowWidth
      })
    },
  },
  getters: {
    // Window高さ取得
    getWindowHeight(state) {
      return state.windowHeight;
    },
    // Window幅取得
    getWindowWidth(state) {
      return state.windowWidth;
    },
  }
};
