/**
 *  クールマスタStore
 */

export default {
  strict: true,
  namespaced: true,
  state: {
    editKurList: [],
    isChanged: false
  },
  mutations: {
    setEditKurList(state, editKurList) {
      state.editKurList = editKurList;
    },
    setIsChanged(state, isChanged) {
      state.isChanged = isChanged;
    }
  },
  actions: {
    setEditKurList({ commit }, editKurList) {
      commit("setEditKurList", editKurList);
    },
    setIsChanged({ commit }, isChanged) {
      commit("setIsChanged", isChanged);
    }
  },
  getters: {
    getEditKurList(state) {
      return state.editKurList;
    },
    getIsChanged(state) {
      return state.isChanged;
    }
  }
};
