/**
 * マルチカレンダー用ストア.
 */
export default {
  strict: true,
  namespaced: true,
  state: {
    // 選択済日付リスト(YYYY-MM-DD)
    selectedDateList: [],
    // 表示用 選択済日付リスト(Date型)
    displaySelectedDateList: [],
    // 表示状態(外部から表示状態を確認)
    dsplayState: false
  },
  mutations: {
    // 選択済日付リストを設定
    setSelectedDateList(state, selectedDateList) {
      state.selectedDateList = selectedDateList;
    },
    // 表示用 選択済日付リストを設定
    setDisplaySelectedDateList(state, displaySelectedDateList) {
      state.displaySelectedDateList = displaySelectedDateList;
    },
    // 表示状態を更新
    setDsplayState(state, dsplayState) {
      state.dsplayState = dsplayState;
    }
  },
  actions: {
    /**
     * 選択済日付リストを設定
     */
    setSelectedDateList({ commit }, selectedDateList) {
      commit("setSelectedDateList", selectedDateList);
    },
    /**
     * 表示用 選択済日付リストを設定
     */
    setDisplaySelectedDateList({ commit }, displaySelectedDateList) {
      commit("setDisplaySelectedDateList", displaySelectedDateList);
    },
    /**
     * 表示状態を更新
     */
    setDsplayState({ commit }, dsplayState) {
      commit("setDsplayState", dsplayState);
    }
  },
  getters: {
    getSelectedDateList(state) {
      return state.selectedDateList;
    },
    getDisplaySelectedDateList(state) {
      return state.displaySelectedDateList;
    },
    getDsplayState(state) {
      return state.dsplayState;
    }
  }
};
