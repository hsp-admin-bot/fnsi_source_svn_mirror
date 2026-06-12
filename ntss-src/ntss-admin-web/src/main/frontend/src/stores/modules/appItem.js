/* eslint-disable */
//import router from '../../router';
import * as types from './mutation-types';

// initial state
const state = {
  keyword: 'keywords',
  gifs: []
};

// actions
const actions = {
  async testchangewords({ commit }, keywords) {
    commit(types.CHANGE_WORDS, keywords);
  }
};

// mutations
const mutations = {
  [types.CHANGE_WORDS](state, payload) {
    state.keyword = payload.keyword;
    // state.gifs = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];
  }
};

// Getters
// const getters = {
//   gifs: state => state.gifs
// };

export default {
  namespaced: true,
  state,
  // getters,
  actions,
  mutations
};
