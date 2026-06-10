/**
 * 検査項目マスタメンテナンスStore.
 */
export default {
  strict: true,
  namespaced: true,
  state: {
    // 計算式編集モーダル表示フラグ
    isShowEditFormulaModal: false,
    // 計算式
    strFormula: ""
  },
  mutations: {
    // 計算式編集モーダル表示フラグを設定
    setIsShowEditFormulaModal(state, isShowEditFormulaModal) {
      state.isShowEditFormulaModal = isShowEditFormulaModal;
    },
    // 計算式文字列を設定
    setStrFormula(state, strFormula) {
      state.strFormula = strFormula;
    }
  },
  actions: {
    /**
     * 計算式編集モーダル表示フラグを設定
     */
    setIsShowEditFormulaModal({ commit }, isShowEditFormulaModal) {
      commit("setIsShowEditFormulaModal", isShowEditFormulaModal);
    },
    /**
     * 計算式編集モーダル表示フラグを設定
     */
    setStrFormula({ commit }, strFormula) {
      commit("setStrFormula", strFormula);
    }
  },
  getters: {
    getIsShowEditFormulaModal(state) {
      return state.isShowEditFormulaModal;
    },
    getStrFormula(state) {
      return state.strFormula;
    }
  }
};
