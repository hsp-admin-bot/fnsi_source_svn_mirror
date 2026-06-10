export default {
  namespaced: true,
  strict: true,
  state: {
    // 選択した施設
    selectedFacility: null,
    // 申込プラン名
    subscriptionPlanName: null,
    // 選択したプラン
    selectedPlan: null,
    // 初期フラグ
    isFirst: false,
  },
  actions: {
    /**
     * 選択した施設を設定する。
     * @param {String} facility 
     */
    setSelectedFacility({ commit }, facility) {
      commit("setSelectedFacility", facility);
    },
    /**
     * プラン名を設定する。
     * @param {String} name 
     */
    setPlanName({ commit }, name) {
      commit("setPlanName", name);
    },
    /**
     * 選択したプランを設定する。
     * @param {Object} plan 
     */
    setSelectedPlan({ commit }, plan) {
      commit("setSelectedPlan", plan);
    },
    /**
     * 初期フラグを設定する。
     * @param {*} plan 
     */
    setIsFirst({ commit }, isFirst) {
      commit("setIsFirst", isFirst);
    },
  },
  mutations: {
    setSelectedFacility: (state, facility) => {
      state.selectedFacility = facility;
    },
    setPlanName: (state, name) => {
      state.subscriptionPlanName = name;
    },
    setSelectedPlan: (state, plan) => {
      state.selectedPlan = plan;
    },
    setIsFirst: (state, isFirst) => {
      state.isFirst = isFirst;
    },
  },
  getters: {
    selectedFacility: state => state.selectedFacility,
    subscriptionPlanName: state => state.subscriptionPlanName,
    selectedPlan: state => state.selectedPlan,
    isFirst: state => state.isFirst,
  }
};
