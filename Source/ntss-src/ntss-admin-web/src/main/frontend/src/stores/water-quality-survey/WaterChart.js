export default {
  strict: process.env.NODE_ENV !== "production",
  namespaced: true,
  state: {
    rangeDate: []
  },
  getters: {
    getRangeDate(state) {
      return state.rangeDate;
    }
  },
  actions: {
    setRangeDate({ commit }, rangeDate) {
      commit("setRangeDate", rangeDate);
    }
  },
  mutations: {
    setRangeDate(state, rangeDate) {
      state.rangeDate = rangeDate;
    }
  }
};
