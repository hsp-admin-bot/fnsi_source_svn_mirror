/**
 * 治療記録用グリッドサイズ管理用Store
 */
export default {
  strict: true,
  namespaced: true,
  state: {
    height: 200
  },
  mutations: {
    setHeight(state, height) {
      state.height = height;
    }
  },
  actions: {
    setHeight({ commit }, height) {
      commit("setHeight", height);
    }
  },
  getters: {
    getHeight(state) {
      return state.height;
    }
  }
};
