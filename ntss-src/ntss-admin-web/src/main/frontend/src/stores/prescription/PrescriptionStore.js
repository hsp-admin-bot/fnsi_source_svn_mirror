/**
 * 処方箋Store.
 */
export default {
  strict: true,
  namespaced: true,
  state: {
    // ヘッダ検索条件
    condition: null,
    defaultCondition: null,
    ordPreNo:[],
  },
  mutations: {
    setCondition(state, condition) {
      state.condition = condition;
    },
    setDefaultCondition(state, defaultCondition) {
      state.defaultCondition = defaultCondition;
    },
    setOrdPreNo(state, ordPreNo) {
      state.ordPreNo = ordPreNo;
    },
    incrementReSearchCount(state){
      state.condition.reSearchCount++;
    },
  },
  actions: {
    // 抽出条件
    setCondition({ commit }, condition) {
      // 抽出条件セット
      commit("setCondition", JSON.parse(JSON.stringify(condition)));
    },
    // 初期抽出条件
    setDefaultCondition({ commit }, defaultCondition) {
      // 初期抽出条件セット
      commit("setDefaultCondition", JSON.parse(JSON.stringify(defaultCondition)));
    },
    setOrdPreNo({ commit }, ordPreNo) {
      // console.log(condition);
      commit("setOrdPreNo", ordPreNo);
    }
  },
  getters: {
    // 抽出条件
    getCondition(state) {
      return state.condition;
    },
    // 初期抽出条件
    getDefaultCondition(state) {
      return state.defaultCondition;
    },
    // 選択したOrdPreNo
    getOrdPreNo(state) {
      return state.ordPreNo;
    }
  }
};
