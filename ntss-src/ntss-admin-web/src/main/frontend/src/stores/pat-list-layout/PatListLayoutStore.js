export default {
  strict: !import.meta.env.PROD,
  namespaced: true,
  state: {
    prevEditRecord: [],
    originalList: []
  },

  getters: {
    getPrevEditRecord(state) {
      return state.prevEditRecord;
    },
    getOriginalList(state) {
      return state.originalList;
    }
  },
  actions: {
    setPrevEditRecord({ commit }, prevEditRecord) {
      commit("setPrevEditRecord", prevEditRecord);
    },
    setOriginalList({ commit }, originalList) {
      commit("setOriginalList", originalList);
    },
  },
  mutations: {
    setPrevEditRecord(state, prevEditRecord) {
      state.prevEditRecord = prevEditRecord;
    },
    setOriginalList(state, originalList) {
      state.originalList = originalList;
    }
  }
};
