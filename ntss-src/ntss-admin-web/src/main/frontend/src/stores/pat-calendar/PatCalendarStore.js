// add 9941 患者カレンダーで内容保持がされていない。 関 start
/**
 * 患者カレンダーStore.
 */
export default {
  strict: true,
  namespaced: true,
  state: {
    expandFlg: null,
    selectedLayout: null,
  },
  mutations: {
    setExpandFlg(state, expandFlg) {
      state.expandFlg = expandFlg;
    },
    /**
     * 画面状態.
     */
    setSelectedLayout(state, selectedLayout) {
      state.selectedLayout = selectedLayout.selectedLayout;
    },
  },
  actions: {
    setExpandFlg({ commit }, expandFlg) {
      commit("setExpandFlg", expandFlg);
    },
    setSelectedLayoutForSave({ commit }, selectedLayout) {
      commit("setSelectedLayout", selectedLayout);
    },
  },
  getters: {
    getExpandFlg(state) {
      return state.expandFlg;
    },
    getSelectedLayout(state) {
      return state.selectedLayout;
    },
  }
};
// add 9941 患者カレンダーで内容保持がされていない。 関 end
