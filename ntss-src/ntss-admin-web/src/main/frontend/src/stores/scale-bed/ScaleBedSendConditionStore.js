/**
 * @typedef {Object} fromScaleBedParam スケールベッドからの条件送信パラメータ
 * @property {boolean} isFromScaleBed スケールベッド画面からの遷移フラグ
 */

/**
 * スケールベッドからの条件送信画面用ストア
 */
const state = {
  isFromScaleBed: false,
  weightCd: null,
  scaleValue: null,
};

const actions = {
  /**
   * パラメータセット
   * @param {Object} param0
   * @param {fromScaleBedParam} condition
   */
  setScaleBedToWeightView({ commit }, parameter) {
    commit("setFromScaleBed", parameter);
  },
  /**
   * 条件リセット
   * @param {Object} param0
   */
  resetScaleBedToWeightView({ commit }) {
    commit("resetScaleBedToWeightView");
  },
};

// mutations
const mutations = {
  /**
   * パラメータセット
   * @param {fromScaleBedParam} condition
   */
  setFromScaleBed(state, parameter) {
    state.isFromScaleBed = true;
    state.weightCd = parameter.weightCd;
    state.scaleValue = parameter.scaleValue;
  },
  /** 条件クリア */
  resetScaleBedToWeightView(state) {
    state.isFromScaleBed = false;
    state.weightCd = null;
    state.scaleValue = null;
  },
};

// getters
const getters = {
  /** スケールベッドからの遷移フラグ取得 */
  getIsFromScaleBed: (state) => {
    return state.isFromScaleBed;
  },
  /** スケールベッドからのスケール値取得 */
  getScaleBedValue: (state) => {
    return state.scaleValue;
  },
};

export default {
  namespaced: true,
  state,
  actions,
  mutations,
  getters,
};
